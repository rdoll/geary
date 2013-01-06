--[[
	Geary persistent options manager
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Options = {
	default = {
		iconShown = true,
		iconScale = 1.0,
		logFontFilename = "Fonts\\FRIZQT__.TTF",
		logFontHeight = 10
	}
}

-- Note: At this point, the rest of the addon is not initialized
function Geary_Options:ADDON_LOADED()

	-- Create an empty table if first run
	if Geary_Saved_Options == nil then
		Geary_Saved_Options = {}
	end
	
	-- If a version exists, see if we need to upgrade it
	if Geary_Saved_Options.version ~= nil then
		if Geary_Saved_Options.version < Geary.version then
			Geary:print("Upgrading options from " .. Geary_Saved_Options.version .. " to " ..
				Geary.version)
		end
		if Geary_Saved_Options.version < "5.1.17-beta" then
			self:_upgradeTo5_1_17_beta()
		end
		-- Add future upgrades here
	end
	
	-- If any option is missing, set it to the default
	local name, value
	for name, value in pairs(self.default) do
		if Geary_Saved_Options[name] == nil then
			Geary_Saved_Options[name] = value
		end
	end
	
	-- The options are now correct for this version
	Geary_Saved_Options.version = Geary.version
end

-- Moved .icon.shown and .icon.scale to .iconShown and .iconScale
function Geary_Options:_upgradeTo5_1_17_beta()
	-- Options will be this version when this method is done
	local newOptions = { version = "5.1.17-beta" }

	if Geary_Saved_Options.icon ~= nil then
		if Geary_Saved_Options.icon.shown ~= nil then
			newOptions.iconShown = Geary_Saved_Options.icon.shown
		end
		if Geary_Saved_Options.icon.scale ~= nil then
			newOptions.iconScale = Geary_Saved_Options.icon.scale
		end
	end
	
	Geary_Saved_Options = newOptions
end

function Geary_Options:isIconShown()
	return Geary_Saved_Options.iconShown
end

function Geary_Options:setIconShown()
	Geary_Saved_Options.iconShown = true
end

function Geary_Options:setIconHidden()
	Geary_Saved_Options.iconShown = false
end

function Geary_Options:getIconScale()
	return Geary_Saved_Options.iconScale
end

function Geary_Options:setIconScale(scale)
	Geary_Saved_Options.iconScale = scale
end

function Geary_Options:getLogFontFilename()
	return Geary_Saved_Options.logFontFilename
end

function Geary_Options:setLogFontFilename(fontFilename)
	Geary_Saved_Options.logFontFilename = fontFilename
end

function Geary_Options:getLogFontHeight()
	return Geary_Saved_Options.logFontHeight
end

function Geary_Options:setLogFontHeight(fontHeight)
	Geary_Saved_Options.logFontHeight = fontHeight
end