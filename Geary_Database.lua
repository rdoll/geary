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
		local verComp = Geary:versionCompare(Geary.version, Geary_Saved_Database.version)
		if verComp == -1 then
			Geary:print("Upgrading database from " .. Geary_Saved_Database.version .. " to " ..
				Geary.version)
		elseif verComp == 1 then
			Geary:print(Geary.CC_ERROR .. "Database version " .. Geary_Saved_Database.version ..
				" is newer than Geary version " .. Geary.version .. ". Errors may occur!" .. Geary.CC_END)
		end
		-- Add future upgrades here
	end
	
	-- The database is now correct for this version
	Geary_Saved_Database.version = Geary.version
end

-- Convert flat tables into object instances
function Geary_Database:_makeObjects()
	if not self.madeObjects then
		for _, entryTable in pairs(Geary_Saved_Database.results) do
			Geary_Database_Entry:makeObject(entryTable)
		end
		self.madeObjects = true
	end
end

function Geary_Database:getAllEntries()
	self:_makeObjects()
	return Geary_Saved_Database.results
end

function Geary_Database:getNumberEntries()
	return Geary:tableSize(Geary_Saved_Database.results)
end

function Geary_Database:deleteAll()
	wipe(Geary_Saved_Database.results)
end

function Geary_Database:storeInspection(inspect)
	if Geary_Options:isDatabaseEnabled() and inspect.player.level >= Geary_Options:getDatabaseMinLevel() then
		local entry = Geary_Database_Entry:createFromInspection(inspect)
		self:addEntry(entry)
	else
		Geary:debugPrint("Not storing " .. inspect.player:getFullNameLink())
	end
end

function Geary_Database:addEntry(entry)
	Geary_Saved_Database.results[entry.playerGuid] = entry
	Geary_Interface_Database:onChanged()
end

function Geary_Database:deleteEntry(guid)
	Geary_Saved_Database.results[guid] = nil
	Geary_Interface_Database:onChanged()
end

function Geary_Database:enable()
	Geary_Options:setDatabaseEnabled()
	-- Geary_Interface_Database:onChanged()
end

function Geary_Database:disable()
	Geary_Options:setDatabaseDisabled()
	-- TODO Should purge all entries?
	-- Geary_Interface_Database:onChanged()
end

function Geary_Database:setMinLevel(minLevel)
	Geary_Options:setDatabaseMinLevel(minLevel)
	-- TODO Should purge all entries below minLevel?
	-- Geary_Interface_Database:onChanged()
end
