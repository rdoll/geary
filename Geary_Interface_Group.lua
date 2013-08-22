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
    groupEntries = {}
}

function Geary_Interface_Group:init(parent)

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
    self.summaryTable = Geary_Interface_Summary_Table:new{ parent = self.contentsFrame }

    -- Summary stats
    self.summaryFontString = self.contentsFrame:CreateFontString("$parent_Group_SummaryFontString", "ARTWORK",
        "GameFontNormal")
    self.summaryFontString:Hide()
    self.summaryFontString:SetPoint("LEFT", self.contentsFrame, "LEFT", 27, 0)
    self.summaryFontString:SetPoint("RIGHT", self.contentsFrame, "RIGHT")
    self.summaryFontString:SetPoint("BOTTOM", self.contentsFrame, "BOTTOM", 0, -18)
    self.summaryFontString:SetJustifyH("CENTER")
    self.summaryFontString:SetJustifyV("MIDDLE")

    Geary_Interface:createTab("Group",
        function() Geary_Interface_Group:Show() end,
        function() Geary_Interface_Group:Hide() end)
end

function Geary_Interface_Group:Show()
    self:updateGroupEntries()
    if Geary:isTableEmpty(self.groupEntries) then
        self.contentsFrame:Hide()
        self.summaryFontString:Hide()
        self.noGroupFontString:Show()
    else
        self.noGroupFontString:Hide()
        self.summaryFontString:Hide()
        self.contentsFrame:Show()
        self:renderEntries()
    end
end

function Geary_Interface_Group:Hide()
    self.noGroupFontString:Hide()
    self.summaryFontString:Hide()
    self.contentsFrame:Hide()
end

-- TODO While this tab is shown, party/group/raid changed event and automatically update
function Geary_Interface_Group:onChanged()
    if self.contentsFrame:IsShown() then
        self:Show()
    end
end

function Geary_Interface_Group:updateGroupEntries()

    wipe(self.groupEntries)

    local unitPrefix, unitLimit, entry, guid
    if IsInRaid() then
        -- Player is included in raid units
        unitPrefix = "raid"
        unitLimit = 40
    elseif IsInGroup() then
        -- Player is not included in party units
        guid = UnitGUID("player")
        local entry = Geary_Database:getEntry(guid)
        self.groupEntries[guid] = entry and entry or Geary_Database_Entry:createFromUnit("player")
        unitPrefix = "party"
        unitLimit = 4
    else
        return
    end

    local unit
    for unitNumber = 1, unitLimit do
        unit = unitPrefix .. unitNumber
        guid = UnitGUID(unit)
        if guid then
            entry = Geary_Database:getEntry(guid)
            self.groupEntries[guid] = entry and entry or Geary_Database_Entry:createFromUnit(unit)
        end
    end
end

function Geary_Interface_Group:renderEntries()

    -- Hide all rows to start
    self.summaryTable:hideAllRows()

    -- Fill in one row at a time from entries
    local inspectedCount, groupItemCount, groupILevelTotal = 0, 0, 0
    local row, rowNumber = nil, 1
    for _, entry in pairs(self.groupEntries) do
        if entry.inspectedAt ~= nil then
            inspectedCount = inspectedCount + 1
            groupItemCount = groupItemCount + entry.itemCount
            groupILevelTotal = groupILevelTotal + entry.iLevelTotal
        end

        row = self.summaryTable:getRow(rowNumber)
        rowNumber = rowNumber + 1
        row:setFaction(entry.playerFaction)
        row:setClass(entry.playerClassId)
        row:setSpec(entry.playerSpecId)
        row:setRole(entry.playerSpecId)
        row:setLevel(entry.playerLevel)
        row:setILevel(entry.itemCount, entry.iLevelTotal)
        row:setName(entry.playerName, entry.playerRealm, entry.playerClassId)
        row:setMissing(entry:getMissingRequiredCount(), entry:getMissingOptionalCount())
        row:setInspected(entry.inspectedAt)
        row:Show()
    end

    -- Show group summary stats
    local summary = "Inspected " .. inspectedCount .. " of " .. Geary:tableSize(self.groupEntries)
        .. " group members"
    if inspectedCount > 0 and groupItemCount > 0 then
        summary = summary .. " averaging " .. ("%.2f"):format(groupILevelTotal / groupItemCount) .. " item level"
    end
    self.summaryFontString:SetText(summary)
    self.summaryFontString:Show()
end
