--[[
    Geary game tooltip hooks

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Tooltip = {
    hooked = false
}

function Geary_Tooltip:Init()
    if Geary_Options:IsShowDatabaseEntryInTooltips() then
        self:Enable()
    end
end

function Geary_Tooltip:Enable()
    -- Only hook once
    if not self.hooked then
        GameTooltip:HookScript("OnTooltipSetUnit", function(...) Geary_Tooltip:OnTooltipSetUnit(...) end)
        self.hooked = true
    end
    Geary_Options:SetShowDatabaseEntryInTooltips(true)
end

function Geary_Tooltip:Disable()
    -- No way to unhook
    Geary_Options:SetShowDatabaseEntryInTooltips(false)
end

function Geary_Tooltip:OnTooltipSetUnit(...)

    if not Geary_Options:IsShowDatabaseEntryInTooltips() then
        return
    end

    local name, unit = GameTooltip:GetUnit()
    if not unit then
        Geary:DebugPrint("Tooltip has no unit for name", tostring(name))
        return
    end

    local guid = UnitGUID(unit)
    if not tonumber(guid) then
        Geary:DebugPrint("Could not find guid for name", tostring(name))
        return
    end

    local entry = Geary_Database:GetEntry(guid)
    Geary:DebugPrint("name", tostring(name), "unit", tostring(unit), "guid", tostring(guid), "entry", tostring(entry))
    if entry then
        self:AddEntrySummaryToTooltip(entry, GameTooltip)
    end
end

function Geary_Tooltip:AddEntrySummaryToTooltip(entry, tooltip)

    local iLevel = entry:GetILevel()
    local iLevelColor = Geary.CC_NA
    if iLevel then
        iLevelColor = "|cffffffff"
    else
        iLevel = "?"
    end

    local requiredMissing = entry:GetMissingRequiredCount()
    local requiredMissingColor = Geary.CC_NA
    if requiredMissing then
        requiredMissingColor = requiredMissing > 0 and Geary.CC_MISSING or Geary.CC_CORRECT
    else
        requiredMissing = "?"
    end

    local optionalMissing = entry:GetMissingOptionalCount()
    local optionalMissingColor = Geary.CC_NA
    if optionalMissing then
        optionalMissingColor = optionalMissing > 0 and Geary.CC_OPTIONAL or Geary.CC_CORRECT
    else
        optionalMissing = "?"
    end

    tooltip:AddLine("Geary: "
        .. iLevelColor .. iLevel .. Geary.CC_END .. "  "
        .. requiredMissingColor .. requiredMissing .. Geary.CC_END .. "/"
        .. optionalMissingColor .. optionalMissing .. Geary.CC_END .. "  "
        .. Geary:ColorizedRelativeDateTime(entry.inspectedAt, true))
end
