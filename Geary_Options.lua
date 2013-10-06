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
        logFontHeight = 10,
        databaseEnabled = true,
        databaseMinLevel = Geary_Player.MAX_LEVEL
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
        local verComp = Geary:versionCompare(Geary.version, Geary_Saved_Options.version)
        if verComp == -1 then
            Geary:print("Upgrading options from " .. Geary_Saved_Options.version .. " to " .. Geary.version)
            if Geary:versionCompare("5.1.17-beta", Geary_Saved_Options.version) == -1 then
                self:_upgradeTo5_1_17_beta()
            end
        elseif verComp == 1 then
            Geary:print(Geary.CC_ERROR .. "Options version " .. Geary_Saved_Options.version ..
                " is newer than Geary version " .. Geary.version .. ". Errors may occur!" .. Geary.CC_END)
        end
    end

    -- If any option is missing, set it to the default
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

--
-- Icon shown
--

function Geary_Options:getDefaultIconShown()
    return self.default.iconShown
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

--
-- Icon scale
--

function Geary_Options:getDefaultIconScale()
    return self.default.iconScale
end

function Geary_Options:getIconScale()
    return Geary_Saved_Options.iconScale
end

function Geary_Options:setIconScale(scale)
    Geary_Saved_Options.iconScale = scale
end

--
-- Log font filename
--

function Geary_Options:getDefaultLogFontFilename()
    return self.default.logFontFilename
end

function Geary_Options:getLogFontFilename()
    return Geary_Saved_Options.logFontFilename
end

function Geary_Options:setLogFontFilename(fontFilename)
    Geary_Saved_Options.logFontFilename = fontFilename
end

--
-- Log font height
--

function Geary_Options:getDefaultLogFontHeight()
    return self.default.logFontHeight
end

function Geary_Options:getLogFontHeight()
    return Geary_Saved_Options.logFontHeight
end

function Geary_Options:setLogFontHeight(fontHeight)
    Geary_Saved_Options.logFontHeight = fontHeight
end

--
-- Database enabled
--

function Geary_Options:getDefaultDatabaseEnabled()
    return self.default.databaseEnabled
end

function Geary_Options:isDatabaseEnabled()
    return Geary_Saved_Options.databaseEnabled
end

function Geary_Options:setDatabaseEnabled()
    Geary_Saved_Options.databaseEnabled = true
end

function Geary_Options:setDatabaseDisabled()
    Geary_Saved_Options.databaseEnabled = false
end

--
-- Database minimum character level to store
--

function Geary_Options:getDefaultDatabaseMinLevel()
    return self.default.databaseMinLevel
end

function Geary_Options:getDatabaseMinLevel()
    return Geary_Saved_Options.databaseMinLevel
end

function Geary_Options:setDatabaseMinLevel(minLevel)
    Geary_Saved_Options.databaseMinLevel = minLevel
end
