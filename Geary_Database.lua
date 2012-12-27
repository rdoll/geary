--[[

--]]

Geary_Database = {}

-- Note: At this point, the rest of the addon is not initialized
function Geary_Database:ADDON_LOADED()
	if Geary_Saved_Database == nil or Geary_Saved_Database.version == nil then
		Geary_Saved_Database = {}
		Geary:debugPrint("Initialized Geary_Saved_Database")
	else
		Geary:debugPrint("Geary_Saved_Database already at version " .. Geary_Saved_Database.version)
	end
	Geary_Saved_Database.version = Geary.version
end