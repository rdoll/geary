--[[
    Geary inspection summary table

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Summary_Table = {
    fontFilename = "Fonts\\FRIZQT__.TTF",
    fontSize = 10
}

function Geary_Interface_Summary_Table:new(config)
    if config == nil or config.parent == nil then
        error("SummaryTable requires a parent to instantiate")
        return nil
    end

    local o = {
        rowsFrame = nil,
        rows = {}
    }
    setmetatable(o, self)
    self.__index = self
    o:createContents(config.parent)
    return o
end

function Geary_Interface_Summary_Table:createContents(parent)

    -- Characteristics of the frame's contents
    local fontFilename = Geary_Interface_Summary_Table.fontFilename
    local fontSize = Geary_Interface_Summary_Table.fontSize

    -- Table header row frame
    local headerFrame = CreateFrame("Frame", "$parent_Header", parent)
    headerFrame:SetPoint("TOPLEFT", parent, "TOPLEFT")
    headerFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT")

    -- Table header row frame contents
    local headerFontString = headerFrame:CreateFontString("$parent_FontString")
    headerFontString:SetFont(fontFilename, fontSize)
    headerFontString:SetPoint("TOPLEFT", headerFrame, "TOPLEFT")
    headerFontString:SetText(Geary.CC_FAILED ..
        "Fac  Cls  Spe  Rol  Lvl    iLevel    Name                         Missing     Inspected" .. Geary.CC_END)

    -- Set table header row frame's height to fit contents
    headerFrame:SetHeight(headerFontString:GetHeight())

    -- Table body scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT")

    -- Table body scroll frame container for rows
    self.rowsFrame = CreateFrame("Frame", "$parent_Rows", scrollFrame)
    self.rowsFrame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT")
    self.rowsFrame:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())

    -- Tie rows container frame to scroll frame
    scrollFrame:SetScrollChild(self.rowsFrame)
end

function Geary_Interface_Summary_Table:getRow(rowNumber)

    if self.rows[rowNumber] == nil then

        -- Row does not exist so create it
        local row = Geary_Interface_Summary_Row:new({parent = self.rowsFrame})

        -- Place row in the table
        -- Note: Assumes rows are always created in sequential order
        row:getFrame():SetPoint("LEFT", self.rowsFrame, "LEFT", 0, 0)
        row:getFrame():SetPoint("RIGHT", self.rowsFrame, "RIGHT", -0, 0)
        if rowNumber == 1 then
            -- First row is linked to top of rowsFrame
            row:getFrame():SetPoint("TOP", self.rowsFrame, "TOP", 0, -1)
        else
            -- Subsequent rows are beneath their predecessor
            row:getFrame():SetPoint("TOP", self.rows[rowNumber - 1]:getFrame(), "BOTTOM", 0, -1)
        end

        self.rows[rowNumber] = row
    end

    return self.rows[rowNumber]
end

function Geary_Interface_Summary_Table:hideAllRows()
    for _, row in pairs(self.rows) do
        row:Hide()
    end
end
