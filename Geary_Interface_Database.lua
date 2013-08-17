--[[
    Geary database interface

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Database = {
    contentsFrame = nil,
    rowsFrame = nil
}

function Geary_Interface_Database:init(parent)

    -- Main container for tab
    local contentsFrame = CreateFrame("Frame", "$parent_Database", parent)
    contentsFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    contentsFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
    contentsFrame:Hide()
    self.contentsFrame = contentsFrame

    -- Table header row frame
    local headerFrame = CreateFrame("Frame", "$parent_Header", contentsFrame)
    headerFrame:SetPoint("TOPLEFT", contentsFrame, "TOPLEFT")
    headerFrame:SetPoint("TOPRIGHT", contentsFrame, "TOPRIGHT")

    -- Table header row frame contents
    local headerFontString = headerFrame:CreateFontString("$parent_FontString")
    headerFontString:SetFont("Fonts\\FRIZQT__.TTF", 10)
    headerFontString:SetPoint("TOPLEFT", headerFrame, "TOPLEFT")
    headerFontString:SetText(Geary.CC_FAILED ..
        "Fac  Cls  Spe  Rol  Lvl  iLevel    Name                     Missing       Inspected" .. Geary.CC_END)

    -- Set table header row frame's height to fit contents
    headerFrame:SetHeight(headerFontString:GetHeight())

    -- Table body scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", contentsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", contentsFrame, "BOTTOMRIGHT")

    -- Table body scroll frame container for rows
    local rowsFrame = CreateFrame("Frame", "$parent_Rows", scrollFrame)
    rowsFrame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT")
    rowsFrame:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())
    rowsFrame.rows = {}
    self.rowsFrame = rowsFrame

    -- Tie rows container frame to scroll frame
    scrollFrame:SetScrollChild(rowsFrame)

    -- TODO Need a better place for this button and it should match the frame's theme
    -- TODO StatTemplate looks promising, but has some default scripts specific to achievements
    local button = CreateFrame("Button", "$parent_DeleteAll", self.contentsFrame, "OptionsButtonTemplate")
    button:SetSize(95, 17)
    button:SetPoint("BOTTOM", self.contentsFrame, "BOTTOM", 24, -21)
    button:SetText("Delete All")
    button:SetScript("OnClick", function(self) Geary_Interface_Database:deleteAll() end)

    Geary_Interface:createTab("Database",
        function() Geary_Interface_Database:Show() end,
        function() Geary_Interface_Database:Hide() end)
end

function Geary_Interface_Database:Show()
    self.contentsFrame:Show()
    self:renderEntries()
end

function Geary_Interface_Database:Hide()
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

function Geary_Interface_Database:clearRows()
    for _, row in pairs(self.rowsFrame.rows) do
        row:Hide()
    end
end

function Geary_Interface_Database:getRow(rowNumber)

    if self.rowsFrame.rows[rowNumber] ~= nil then
        -- Row was already created, so just return it
        return self.rowsFrame.rows[rowNumber]
    end

    -- Row does not exist so create it
    -- Note: Assumes rows are always created in sequential order
    local frame = CreateFrame("Frame", "$parent_Row_" .. rowNumber, self.rowsFrame)
    if rowNumber == 1 then
        -- First row is linked to top of rowsFrame
        frame:SetPoint("TOPLEFT", self.rowsFrame, "TOPLEFT")
        frame:SetPoint("TOPRIGHT", self.rowsFrame, "TOPRIGHT")
    else
        -- Subsequent rows are linked to their predecessor
        frame:SetPoint("TOPLEFT", self.rowsFrame.rows[rowNumber - 1], "BOTTOMLEFT")
        frame:SetPoint("TOPRIGHT", self.rowsFrame.rows[rowNumber - 1], "BOTTOMRIGHT")
    end
    frame:SetHeight(12)

    -- Contents of row
    local fontString = frame:CreateFontString("$parent_FontString")
    fontString:SetFont("Fonts\\FRIZQT__.TTF", 10)
    fontString:SetPoint("TOPLEFT", frame, "TOPLEFT")
    fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("TOP")
    frame.fontString = fontString

    self.rowsFrame.rows[rowNumber] = frame
    return frame
end

-- TODO Temp to help with column alignment
function Geary_Interface_Database:strpad2(str, len)
    return ("%-" .. (strlen(str) + ((len - strlen(str)) * 2)) .. "s"):format(str)
end

function Geary_Interface_Database:renderEntries()

    local missingRequired, missingOptional, row
    local rowNumber = 1
    for _, entry in pairs(Geary_Database:getAllEntries()) do
        missingRequired = entry:getMissingRequiredCount()
        missingOptional = entry:getMissingOptionalCount()
        row = self:getRow(rowNumber)
        row.fontString:SetText((" %s    %s    %s    %s   %2d  %s  %s    %s / %s       %s"):format(
            entry:getFactionInlineIcon(),
            entry:getClassInlineIcon(),
            entry:getSpecInlineIcon(),
            entry:getRoleInlineIcon(),
            entry.playerLevel,
            entry:getEquippedItemLevelString(),
            Geary_Player:classColorize(entry.playerClassId, self:strpad2(strsub(entry:getPlayerFullName(), 1, 16), 16)),
            (missingRequired > 0 and Geary.CC_MISSING or Geary.CC_CORRECT) .. missingRequired .. Geary.CC_END,
            (missingOptional > 0 and Geary.CC_OPTIONAL or Geary.CC_CORRECT) .. missingOptional .. Geary.CC_END,
            Geary:colorizedRelativeDateTime(entry.inspectedAt)))
        rowNumber = rowNumber + 1
    end

    row = self:getRow(rowNumber)
    row.fontString:SetText(Geary.CC_FAILED .. " -- " .. Geary_Database:getNumberEntries() ..
        " inspection results stored (misaligned columns are temporary) --" .. Geary.CC_END)
end
