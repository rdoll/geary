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
        interfaceScale = 1.0,
        logFontFilename = "Fonts\\FRIZQT__.TTF",
        logFontHeight = 10,
        databaseEnabled = true,
        databaseMinLevel = Geary_Player.MAX_LEVEL,
        databasePruneOnLoad = false,
        databasePruneDays = 180,
        showMopLegProgress = true,
        showDatabaseEntryInTooltips = true
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
        local verComp = Geary:VersionCompare(Geary.version, Geary_Saved_Options.version)
        if verComp == -1 then
            Geary:Print("Upgrading options from " .. Geary_Saved_Options.version .. " to " .. Geary.version)
            if Geary:VersionCompare("5.1.17-beta", Geary_Saved_Options.version) == -1 then
                self:_UpgradeTo5_1_17_beta()
            end
            if Geary:VersionCompare("5.4.4-alpha-5", Geary_Saved_Options.version) == -1 then
                self:_UpgradeTo5_4_4_alpha_5()
            end
            if Geary:VersionCompare("6.0.3-release", Geary_Saved_Options.version) == -1 then
                self:_UpgradeTo6_0_3_release()
            end
        elseif verComp == 1 then
            Geary:Print(Geary.CC_ERROR .. "Options version " .. Geary_Saved_Options.version ..
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
function Geary_Options:_UpgradeTo5_1_17_beta()
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

-- Due to a slider bug in 5.4, we could have inappropriate floating point numbers, so fix them
function Geary_Options:_UpgradeTo5_4_4_alpha_5()
    Geary_Saved_Options.iconScale = floor(Geary_Saved_Options.iconScale * 100) / 100
    Geary_Saved_Options.logFontHeight = floor(Geary_Saved_Options.logFontHeight)
    Geary_Saved_Options.databaseMinLevel = floor(Geary_Saved_Options.databaseMinLevel)
end

-- Assume players who used Geary in MoP with a min level of 90 want a min level of 100 in WoD
function Geary_Options:_UpgradeTo6_0_3_release()
    if Geary_Saved_Options.databaseMinLevel == 90 then
        Geary_Saved_Options.databaseMinLevel = 100
    end
end

--
-- Icon shown
--

function Geary_Options:GetDefaultIconShown()
    return self.default.iconShown
end

function Geary_Options:IsIconShown()
    return Geary_Saved_Options.iconShown
end

function Geary_Options:SetIconShown(iconShown)
    Geary_Saved_Options.iconShown = iconShown
end

--
-- Icon scale
--

function Geary_Options:GetDefaultIconScale()
    return self.default.iconScale
end

function Geary_Options:GetIconScale()
    return Geary_Saved_Options.iconScale
end

function Geary_Options:SetIconScale(scale)
    Geary_Saved_Options.iconScale = scale
end

--
-- Interface scale
--

function Geary_Options:GetDefaultInterfaceScale()
    return self.default.interfaceScale
end

function Geary_Options:GetInterfaceScale()
    return Geary_Saved_Options.interfaceScale
end

function Geary_Options:SetInterfaceScale(scale)
    Geary_Saved_Options.interfaceScale = scale
end

--
-- Log font filename
--

function Geary_Options:GetDefaultLogFontFilename()
    return self.default.logFontFilename
end

function Geary_Options:GetLogFontFilename()
    return Geary_Saved_Options.logFontFilename
end

function Geary_Options:SetLogFontFilename(fontFilename)
    Geary_Saved_Options.logFontFilename = fontFilename
end

--
-- Log font height
--

function Geary_Options:GetDefaultLogFontHeight()
    return self.default.logFontHeight
end

function Geary_Options:GetLogFontHeight()
    return Geary_Saved_Options.logFontHeight
end

function Geary_Options:SetLogFontHeight(fontHeight)
    Geary_Saved_Options.logFontHeight = fontHeight
end

--
-- Database enabled
--

function Geary_Options:GetDefaultDatabaseEnabled()
    return self.default.databaseEnabled
end

function Geary_Options:IsDatabaseEnabled()
    return Geary_Saved_Options.databaseEnabled
end

function Geary_Options:SetDatabaseEnabled(enabled)
    Geary_Saved_Options.databaseEnabled = enabled
end

--
-- Database minimum character level to store
--

function Geary_Options:GetDefaultDatabaseMinLevel()
    return self.default.databaseMinLevel
end

function Geary_Options:GetDatabaseMinLevel()
    return Geary_Saved_Options.databaseMinLevel
end

function Geary_Options:SetDatabaseMinLevel(minLevel)
    Geary_Saved_Options.databaseMinLevel = minLevel
end

--
-- Database prune on load
--

function Geary_Options:GetDefaultDatabasePruneOnLoad()
    return self.default.databasePruneOnLoad
end

function Geary_Options:IsDatabasePruneOnLoad()
    return Geary_Saved_Options.databasePruneOnLoad
end

function Geary_Options:SetDatabasePruneOnLoad(pruneOnLoad)
    Geary_Saved_Options.databasePruneOnLoad = pruneOnLoad
end

--
-- Database prune after days
--

function Geary_Options:GetDefaultDatabasePruneDays()
    return self.default.databasePruneDays
end

function Geary_Options:GetDatabasePruneDays()
    return Geary_Saved_Options.databasePruneDays
end

function Geary_Options:SetDatabasePruneDays(pruneDays)
    Geary_Saved_Options.databasePruneDays = pruneDays
end

--
-- Show Mists of Pandaria legendary quest progress
--

function Geary_Options:GetDefaultShowMopLegProgress()
    return self.default.showMopLegProgress
end

function Geary_Options:GetShowMopLegProgress()
    return Geary_Saved_Options.showMopLegProgress
end

function Geary_Options:SetShowMopLegProgress(shown)
    Geary_Saved_Options.showMopLegProgress = shown
end

--
-- Show database entry summary in unit tooltips
--

function Geary_Options:GetDefaultShowDatabaseEntryInTooltips()
    return self.default.showDatabaseEntryInTooltips
end

function Geary_Options:IsShowDatabaseEntryInTooltips()
    return Geary_Saved_Options.showDatabaseEntryInTooltips
end

function Geary_Options:SetShowDatabaseEntryInTooltips(enabled)
    Geary_Saved_Options.showDatabaseEntryInTooltips = enabled
end
