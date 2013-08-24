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
        itemCount         = 0,
        iLevelTotal       = 0,
        missingItems      = 0, -- empty + failed
        missingGems       = 0, -- missing + failed
        missingEnchants   = 0,
        missingBeltBuckle = false,
        missingUpgrades   = 0,
        missingEotbp      = 0,
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

function Geary_Database_Entry:makeObject(entryTable)
    setmetatable(entryTable, self)
    self.__index = self
end

function Geary_Database_Entry:createFromInspection(inspect)
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
        inspectedAt       = time()
    }
end

function Geary_Database_Entry:createFromUnit(unit)
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

function Geary_Database_Entry:getMissingRequiredCount()
    return self.missingItems + self.missingGems + self.missingEnchants + (self.missingBeltBuckle and 1 or 0)
end

function Geary_Database_Entry:getMissingOptionalCount()
    return self.missingUpgrades + self.missingEotbp + (self.missingCoh and 1 or 0) + (self.missingCov and 1 or 0)
end
