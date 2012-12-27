--[[

--]]

Geary_Options = {}

-- Note: At this point, the rest of the addon is not initialized
function Geary_Options:ADDON_LOADED()
	if Geary_Saved_Options == nil or Geary_Saved_Options.version == nil then
		Geary_Saved_Options = {
			icon = {
				shown = true,
				scale = 0.5
			}
		}
		Geary:debugPrint("Initialized Geary_Saved_Options")
	else
		Geary:debugPrint("Geary_Saved_Options already at version " .. Geary_Saved_Options.version)
	end
	Geary_Saved_Options.version = Geary.version
end

function Geary_Options:isIconShown()
	return Geary_Saved_Options.icon.shown
end

function Geary_Options:setIconShown()
	Geary_Saved_Options.icon.shown = true
end

function Geary_Options:setIconHidden()
	Geary_Saved_Options.icon.shown = false
end

function Geary_Options:getIconScale()
	return Geary_Saved_Options.icon.scale
end

function Geary_Options:setIconScale(sacle)
	Geary_Saved_Options.icon.scale = scale
end