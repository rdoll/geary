--[[
    Geary persistent database entry

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Database_Entry = {
    default = {
        playerGuid        = nil,
        playerName        = nil,
        playerRealm       = nil,
        playerFaction     = nil,
        playerLevel       = nil,
        playerClassId     = nil,
        playerSpecId      = nil,
        itemCount         = nil,
        iLevelTotal       = nil,
        missingItems      = nil,  -- empty + failed
        missingGems       = nil,  -- missing + failed
        missingEnchants   = nil,
        missingBeltBuckle = false,
        missingUpgrades   = nil,
        missingEotbp      = nil,
        missingCoh        = false,
        missingCov        = false,
        inspectedAt       = nil
    }
}

function Geary_Database_Entry:new(o)
    o = o or {}
    for name, value in pairs(self.default) do
        if o[name] == nil then
            o[name] = value
        end
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

function Geary_Database_Entry:MakeObject(entryTable)
    setmetatable(entryTable, self)
    self.__index = self
end

function Geary_Database_Entry:CreateFromInspection(inspect)
    return self:new{
        playerGuid        = inspect.player.guid,
        playerName        = inspect.player.name,
        playerRealm       = inspect.player.realm,
        playerFaction     = inspect.player.faction,
        playerLevel       = inspect.player.level,
        playerClassId     = inspect.player.classId,
        playerSpecId      = inspect.player.spec ~= nil and inspect.player.spec.id or nil,
        itemCount         = inspect.itemCount,
        iLevelTotal       = inspect.iLevelTotal,
        missingItems      = inspect.emptySlots + inspect.failedSlots,
        missingGems       = inspect.emptySockets + inspect.failedJewelIds,
        missingEnchants   = inspect.unenchantedCount,
        missingBeltBuckle = inspect.isMissingBeltBuckle,
        missingUpgrades   = inspect.upgradeMax - inspect.upgradeLevel,
        missingEotbp      = inspect.eotbpMissing,
        missingCoh        = inspect.isMissingCohMeta,
        missingCov        = inspect.isMissingCov,
        missingLegCloak   = inspect.isMissingLegCloak,
        inspectedAt       = time()
    }
end

function Geary_Database_Entry:CreateFromUnit(unit)
    local name, realm = UnitName(unit)
    local _, _, classId = UnitClass(unit)
    return self:new{
        playerGuid    = UnitGUID(unit),
        playerName    = name,
        playerRealm   = realm,
        playerClassId = classId,
        playerLevel   = UnitLevel(unit)
    }
end

function Geary_Database_Entry:GetMissingRequiredCount()
    if self.missingItems == nil and self.missingGems == nil and self.missingEnchants == nil then
        return nil
    else
        return (self.missingItems or 0) + (self.missingGems or 0) + (self.missingEnchants or 0)
            + (self.missingBeltBuckle and 1 or 0)
    end
end

function Geary_Database_Entry:GetMissingOptionalCount()
    local count = self.missingUpgrades  -- nil or # missing

    -- If showing MoP legendary progress and progress has been tracked
    if Geary_Options:GetShowMopLegProgress() and self.missingEotbp ~= nil then
        count = (count or 0) + (self.missingEotbp or 0) + (self.missingCoh and 1 or 0)
            + (self.missingCov and 1 or (self.missingLegCloak and 1 or 0))
    end

    return count
end

function Geary_Database_Entry:GetFullName()
    return Geary_Player:FullPlayerName(self.playerName, self.playerRealm)
end

--
-- Table of entries ordered pairs functions
-- NOTE: These are member functions, NOT methods
--

local function _orderByLt(a, b) return a.sortKey < b.sortKey end
local function _orderByGt(a, b) return a.sortKey > b.sortKey end

local function _orderedNextPair(t, n)
    local key = t[t.__next]
    if not key then return end
    t.__next = t.__next + 1
    return key.sourceKey, t.__source[key.sourceKey]
end

function Geary_Database_Entry.orderedPairsByName(entries, ascending)
    local keys, kn = { __source = entries, __next = 1 }, 1
    for guid, entry in pairs(entries) do
        keys[kn] = {
            sourceKey = guid,
            sortKey = entry:GetFullName()
        }
        kn  = kn + 1
    end
    table.sort(keys, ascending and _orderByLt or _orderByGt)
    return _orderedNextPair, keys
end

function Geary_Database_Entry.orderedPairsByILevel(entries, ascending)
    local keys, kn = { __source = entries, __next = 1 }, 1
    for guid, entry in pairs(entries) do
        local ilevel = 0
        if entry.itemCount and entry.iLevelTotal and entry.itemCount > 0 then
            ilevel = entry.iLevelTotal / entry.itemCount
        end
        keys[kn] = {
            sourceKey = guid,
            sortKey = ilevel
        }
        kn  = kn + 1
    end
    table.sort(keys, ascending and _orderByLt or _orderByGt)
    return _orderedNextPair, keys
end

function Geary_Database_Entry:GetInspectedAtDaysAgo()
    return self.inspectedAt ~= nil and floor((time() - self.inspectedAt) / (24 * 60 * 60)) or 0
end
