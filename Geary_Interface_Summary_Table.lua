--[[
    Geary inspection summary table

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Summary_Table = {
    fontFilename = "Fonts\\FRIZQT__.TTF",
    fontSize = 10,
    sortOrders = {
        { orderedPairsFunc = Geary_Database_Entry.orderedPairsByName,   ascendingOrder = true  },
        { orderedPairsFunc = Geary_Database_Entry.orderedPairsByName,   ascendingOrder = false },
        { orderedPairsFunc = Geary_Database_Entry.orderedPairsByILevel, ascendingOrder = true  },
        { orderedPairsFunc = Geary_Database_Entry.orderedPairsByILevel, ascendingOrder = false }
    }
}

function Geary_Interface_Summary_Table:new(config)
    if config == nil or config.parent == nil then
        error("SummaryTable requires a parent to instantiate")
        return nil
    end

    local o = {
        owner = config ~= nil and config.owner ~= nil and config.owner or nil,
        rowsFrame = nil,
        rows = {},
        sortOrderIndex = 1,
        onSortOrderChangedFunc = nil
    }
    setmetatable(o, self)
    self.__index = self
    o:_CreateContents(config.parent)
    return o
end

function Geary_Interface_Summary_Table:_CreateContents(parent)

    -- Characteristics of the frame's contents
    local fontFilename = Geary_Interface_Summary_Table.fontFilename
    local fontSize = Geary_Interface_Summary_Table.fontSize

    -- Table header row frame
    local headerButton = CreateFrame("Button", "$parent_Header", parent)
    headerButton:SetPoint("TOPLEFT", parent, "TOPLEFT")
    headerButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT")

    -- Trap clicks we care about
    headerButton.summaryTable = self
    headerButton:RegisterForClicks("LeftButtonUp")
    headerButton:SetScript("OnClick", function(self, mouseButton, down)
        if mouseButton == "LeftButton" then
            self.summaryTable:setNextSortOrder()
        end
    end)

    -- Table header row frame contents
    local headerFontString = headerButton:CreateFontString("$parent_FontString")
    headerFontString:SetFont(fontFilename, fontSize)
    headerFontString:SetPoint("TOPLEFT", headerButton, "TOPLEFT")
    headerFontString:SetText(Geary.CC_HEADER ..
        "Fac  Cls  Spe  Rol    Lvl    iLevel    Name                          Missing     Inspected" .. Geary.CC_END)

    -- Set table header row frame's height to fit contents
    headerButton:SetHeight(headerFontString:GetHeight())

    -- Table body scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", headerButton, "BOTTOMLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT")

    -- Table body scroll frame container for rows
    self.rowsFrame = CreateFrame("Frame", "$parent_Rows", scrollFrame)
    self.rowsFrame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT")
    self.rowsFrame:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())

    -- Tie rows container frame to scroll frame
    scrollFrame:SetScrollChild(self.rowsFrame)
end

function Geary_Interface_Summary_Table:GetRow(rowNumber)

    if self.rows[rowNumber] == nil then

        -- Row does not exist so create it
        local row = Geary_Interface_Summary_Row:new{parent = self.rowsFrame}

        -- Place row in the table
        -- Note: Assumes rows are always created in sequential order
        row:GetButton():SetPoint("LEFT", self.rowsFrame, "LEFT", 0, 0)
        row:GetButton():SetPoint("RIGHT", self.rowsFrame, "RIGHT", -0, 0)
        if rowNumber == 1 then
            -- First row is linked to top of rowsFrame
            row:GetButton():SetPoint("TOP", self.rowsFrame, "TOP", 0, -1)
        else
            -- Subsequent rows are beneath their predecessor
            row:GetButton():SetPoint("TOP", self.rows[rowNumber - 1]:GetButton(), "BOTTOM", 0, -1)
        end

        self.rows[rowNumber] = row
    end

    return self.rows[rowNumber]
end

function Geary_Interface_Summary_Table:HideAllRows()
    for _, row in pairs(self.rows) do
        row:Hide()
    end
end

function Geary_Interface_Summary_Table:setNextSortOrder()
    self.sortOrderIndex = self.sortOrderIndex + 1
    if Geary_Interface_Summary_Table.sortOrders[self.sortOrderIndex] == nil then
        self.sortOrderIndex = 1
    end
    if self.owner ~= nil then
        self.owner:OnChanged()
    end
end

function Geary_Interface_Summary_Table:GetOrderedPairsFunc()
    return Geary_Interface_Summary_Table.sortOrders[self.sortOrderIndex].orderedPairsFunc
end

function Geary_Interface_Summary_Table:IsAscendingOrder()
    return Geary_Interface_Summary_Table.sortOrders[self.sortOrderIndex].ascendingOrder
end
