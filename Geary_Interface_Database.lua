--[[
    Geary database interface

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Database = {
    noEntriesfontString = nil,
    contentsFrame = nil,
    summaryTable = nil
}

function Geary_Interface_Database:init(parent)

    -- Nothing to see here message
    self.noEntriesfontString = parent:CreateFontString("$parent_Database_FontString", "ARTWORK", "GameFontNormal")
    self.noEntriesfontString:Hide()
    self.noEntriesfontString:SetPoint("CENTER", parent, "CENTER", 0, 0)
    self.noEntriesfontString:SetText("No inspection results stored in database")

    -- Main container for tab
    self.contentsFrame = CreateFrame("Frame", "$parent_Database", parent)
    self.contentsFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    self.contentsFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
    self.contentsFrame:Hide()

    -- Summary table
    self.summaryTable = Geary_Interface_Summary_Table:new{
        parent = self.contentsFrame,
        owner = self
    }

    -- TODO Need a better place for this button and it should match the frame's theme
    -- TODO StatTemplate looks promising, but has some default scripts specific to achievements
    local button = CreateFrame("Button", "$parent_DeleteAll", self.contentsFrame, "OptionsButtonTemplate")
    button:SetSize(95, 17)
    button:SetPoint("BOTTOM", self.contentsFrame, "BOTTOM", 24, -21)
    button:SetText("Delete All")
    button:SetScript("OnClick", function(self) Geary_Interface_Database:deleteAll() end)

    -- Summary stats
    self.summaryFontString = self.contentsFrame:CreateFontString("$parent_Group_SummaryFontString", "ARTWORK",
        "GameFontNormal")
    self.summaryFontString:Hide()
    self.summaryFontString:SetPoint("LEFT", button, "RIGHT", 20, 0)
    self.summaryFontString:SetPoint("RIGHT", self.contentsFrame, "RIGHT", 0, 0)
    self.summaryFontString:SetPoint("BOTTOM", self.contentsFrame, "BOTTOM", 0, -18)
    self.summaryFontString:SetJustifyH("CENTER")
    self.summaryFontString:SetJustifyV("MIDDLE")

    Geary_Interface:createTab("Database",
        function() Geary_Interface_Database:Show() end,
        function() Geary_Interface_Database:Hide() end)
end

function Geary_Interface_Database:Show()
    if Geary_Database:getNumberEntries() == 0 then
        self.contentsFrame:Hide()
        self.summaryFontString:Hide()
        self.noEntriesfontString:Show()
    else
        self.noEntriesfontString:Hide()
        self.summaryFontString:Hide()
        self.contentsFrame:Show()
        self:renderEntries()
    end
end

function Geary_Interface_Database:Hide()
    self.noEntriesfontString:Hide()
    self.summaryFontString:Hide()
    self.contentsFrame:Hide()
end

function Geary_Interface_Database:onChanged()
    if self.contentsFrame:IsShown() then
        self:Show()
    end
end

function Geary_Interface_Database:deleteAll()
    Geary_Database:deleteAll()
end

function Geary_Interface_Database:renderEntries()

    -- Hide all rows to start
    self.summaryTable:hideAllRows()

    -- Fill in one row at a time from entries
    local row, rowNumber, orderedPairsFunc = nil, 1, self.summaryTable:getOrderedPairsFunc()
    for _, entry in orderedPairsFunc(Geary_Database:getAllEntries(), self.summaryTable:isAscendingOrder()) do
        row = self.summaryTable:getRow(rowNumber)
        rowNumber = rowNumber + 1
        row:setFromEntry(entry)
        row:setOnClickHandler(function (row, mouseButton, down)
            Geary_Inspect:inspectGuid(row:getGuid())
        end)
        row:Show()
    end

    -- Show summary stats
    self.summaryFontString:SetText(rowNumber - 1 .. " entries")
    self.summaryFontString:Show()
end
