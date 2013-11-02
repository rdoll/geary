--[[
    Geary persistent database manager

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Database = {
    madeObjects = false
}

-- Note: At this point, the rest of the addon is not initialized
function Geary_Database:ADDON_LOADED()

    -- Create an empty table if first run
    if Geary_Saved_Database == nil then
        Geary_Saved_Database = {}
    end
    if Geary_Saved_Database.results == nil then
        Geary_Saved_Database.results = {}
    end

    -- If a version exists, see if we need to upgrade it
    if Geary_Saved_Database.version ~= nil then
        local verComp = Geary:VersionCompare(Geary.version, Geary_Saved_Database.version)
        if verComp == -1 then
            Geary:Print("Upgrading database from " .. Geary_Saved_Database.version .. " to " .. Geary.version)
            if Geary:VersionCompare("5.4.2-release", Geary_Saved_Database.version) == -1 then
                self:_UpgradeTo5_4_2_release()
            end
        elseif verComp == 1 then
            Geary:Print(Geary.CC_ERROR .. "Database version " .. Geary_Saved_Database.version ..
                " is newer than Geary version " .. Geary.version .. ". Errors may occur!" .. Geary.CC_END)
        end
    end

    -- The database is now correct for this version
    Geary_Saved_Database.version = Geary.version
end

-- Added missingLegCloak to Geary_Database_Entry
function Geary_Database:_UpgradeTo5_4_2_release()
    for _, entry in pairs(Geary_Saved_Database.results) do
        entry.missingLegCloak = false
    end
end

-- Convert flat tables into object instances
-- Lazy, one-time conversion so we don't slow down addon loading
function Geary_Database:_MakeObjects()
    if not self.madeObjects then
        for _, entryTable in pairs(Geary_Saved_Database.results) do
            Geary_Database_Entry:MakeObject(entryTable)
        end
        self.madeObjects = true
    end
end

function Geary_Database:GetAllEntries()
    self:_MakeObjects()
    return Geary_Saved_Database.results
end

function Geary_Database:GetNumberEntries()
    return Geary:TableSize(Geary_Saved_Database.results)
end

function Geary_Database:DeleteAll()
    wipe(Geary_Saved_Database.results)
    Geary_Interface_Database:OnChanged()
    Geary_Interface_Group:OnChanged()
end

function Geary_Database:StoreInspection(inspect)
    if Geary_Options:IsDatabaseEnabled() and inspect.player.level >= Geary_Options:GetDatabaseMinLevel() then
        local entry = Geary_Database_Entry:CreateFromInspection(inspect)
        self:AddEntry(entry)
    else
        Geary:DebugPrint("Not storing " .. inspect.player:GetFullNameLink())
    end
end

function Geary_Database:AddEntry(entry)
    Geary_Saved_Database.results[entry.playerGuid] = entry
    Geary_Interface_Database:OnChanged()
    Geary_Interface_Group:OnChanged()
end

function Geary_Database:GetEntry(guid)
    local entry = Geary_Saved_Database.results[guid]
    if entry ~= nil then
        self:_MakeObjects()
        return entry
    else
        return nil
    end
end

function Geary_Database:DeleteEntry(guid)
    Geary_Saved_Database.results[guid] = nil
    Geary_Interface_Database:OnChanged()
    Geary_Interface_Group:OnChanged()
end

function Geary_Database:Enable()
    Geary_Options:SetDatabaseEnabled()
    -- Geary_Interface_Database:OnChanged()
end

function Geary_Database:Disable()
    Geary_Options:SetDatabaseDisabled()
    -- TODO Should purge all entries?
    -- Geary_Interface_Database:OnChanged()
end

function Geary_Database:SetMinLevel(minLevel)
    Geary_Options:SetDatabaseMinLevel(minLevel)
    -- TODO Should purge all entries below minLevel?
    -- Geary_Interface_Database:OnChanged()
end
