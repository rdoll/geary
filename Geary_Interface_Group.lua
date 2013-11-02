--[[
    Geary group interface

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Group = {
    noGroupFontString = nil,
    contentsFrame = nil,
    summaryTable = nil,
    summaryFontString = nil,
    groupRosterUpdateEventHandlerId = nil,
    groupEntries = {}
}

function Geary_Interface_Group:Init(parent)

    -- Nothing to see here message
    self.noGroupFontString = parent:CreateFontString("$parent_Group_NoGroupFontString", "ARTWORK", "GameFontNormal")
    self.noGroupFontString:Hide()
    self.noGroupFontString:SetPoint("CENTER", parent, "CENTER", 0, 0)
    self.noGroupFontString:SetText("You are not in a group")

    -- Main container for tab
    self.contentsFrame = CreateFrame("Frame", "$parent_Group", parent)
    self.contentsFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    self.contentsFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
    self.contentsFrame:Hide()

    -- Summary table
    self.summaryTable = Geary_Interface_Summary_Table:new{
        parent = self.contentsFrame,
        owner = self
    }

    -- Summary stats
    self.summaryFontString = self.contentsFrame:CreateFontString("$parent_Group_SummaryFontString", "ARTWORK",
        "GameFontNormal")
    self.summaryFontString:Hide()
    self.summaryFontString:SetPoint("LEFT", self.contentsFrame, "LEFT", 27, 0)
    self.summaryFontString:SetPoint("RIGHT", self.contentsFrame, "RIGHT")
    self.summaryFontString:SetPoint("BOTTOM", self.contentsFrame, "BOTTOM", 0, -18)
    self.summaryFontString:SetJustifyH("CENTER")
    self.summaryFontString:SetJustifyV("MIDDLE")

    Geary_Interface:CreateTab("Group",
        function() Geary_Interface_Group:Show() end,
        function() Geary_Interface_Group:Hide() end)
end

function Geary_Interface_Group:_RegisterEvents()
    if self.groupRosterUpdateEventHandlerId == nil then
        self.groupRosterUpdateEventHandlerId =
            Geary_Event:RegisterEvent("GROUP_ROSTER_UPDATE", function() Geary_Interface_Group:GROUP_ROSTER_UPDATE() end)
    end
end

function Geary_Interface_Group:GROUP_ROSTER_UPDATE()
    self:OnChanged()
end

function Geary_Interface_Group:_UnregisterEvents()
    if self.groupRosterUpdateEventHandlerId ~= nil then
        Geary_Event:UnregisterEvent(self.groupRosterUpdateEventHandlerId)
        self.groupRosterUpdateEventHandlerId = nil
    end
end

function Geary_Interface_Group:Show()
    self:UpdateGroupEntries()
    if Geary:IsTableEmpty(self.groupEntries) then
        self.contentsFrame:Hide()
        self.summaryFontString:Hide()
        self.noGroupFontString:Show()
    else
        self.noGroupFontString:Hide()
        self.summaryFontString:Hide()
        self.contentsFrame:Show()
        self:RenderEntries()
    end
    self:_RegisterEvents()
end

function Geary_Interface_Group:Hide()
    self.noGroupFontString:Hide()
    self.summaryFontString:Hide()
    self.contentsFrame:Hide()
    self:_UnregisterEvents()
end

function Geary_Interface_Group:OnChanged()
    if self.contentsFrame:IsShown() or self.noGroupFontString:IsShown() then
        self:Show()
    end
end

function Geary_Interface_Group:UpdateGroupEntries()

    wipe(self.groupEntries)

    local unitPrefix, unitLimit, entry, guid
    if IsInRaid() then
        -- Player is included in raid units
        Geary:DebugPrint("In a raid")
        unitPrefix = "raid"
        unitLimit = 40
    elseif IsInGroup() then
        -- Player is not included in party units
        Geary:DebugPrint("In a party")
        guid = UnitGUID("player")
        local entry = Geary_Database:GetEntry(guid)
        self.groupEntries[guid] = entry and entry or Geary_Database_Entry:CreateFromUnit("player")
        unitPrefix = "party"
        unitLimit = 4
    else
        -- Not in any kind of group
        Geary:DebugPrint("Not in a group")
        return
    end

    local unit
    for unitNumber = 1, unitLimit do
        unit = unitPrefix .. unitNumber
        guid = UnitGUID(unit)
        if guid then
            entry = Geary_Database:GetEntry(guid)
            self.groupEntries[guid] = entry and entry or Geary_Database_Entry:CreateFromUnit(unit)
        end
    end
end

function Geary_Interface_Group:RenderEntries()

    -- Hide all rows to start
    self.summaryTable:HideAllRows()

    -- Fill in one row at a time from entries
    local inspectedCount, groupItemCount, groupILevelTotal = 0, 0, 0
    local row, rowNumber, orderedPairsFunc = nil, 1, self.summaryTable:GetOrderedPairsFunc()
    for _, entry in orderedPairsFunc(self.groupEntries, self.summaryTable:IsAscendingOrder()) do
        if entry.inspectedAt ~= nil then
            inspectedCount = inspectedCount + 1
            groupItemCount = groupItemCount + entry.itemCount
            groupILevelTotal = groupILevelTotal + entry.iLevelTotal
        end

        row = self.summaryTable:GetRow(rowNumber)
        rowNumber = rowNumber + 1
        row:SetFromEntry(entry)
        row:SetOnClickHandler(function (row, mouseButton, down)
            Geary_Inspect:InspectGuid(row:GetGuid())
        end)
        row:Show()
    end

    -- Show group summary stats
    local summary = "Inspected " .. inspectedCount .. " of " .. Geary:TableSize(self.groupEntries)
        .. " group members"
    if inspectedCount > 0 and groupItemCount > 0 then
        summary = summary .. " averaging " .. ("%.2f"):format(groupILevelTotal / groupItemCount) .. " item level"
    end
    self.summaryFontString:SetText(summary)
    self.summaryFontString:Show()
end
