--[[
    Geary log interface

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Log = {
    scrollFrame = nil,
    editBox = nil,
    LETTERS_MAX = 10000
}

function Geary_Interface_Log:Init(parent)

    local frame = CreateFrame("ScrollFrame", "$parent_Log", parent, "UIPanelScrollFrameTemplate")
    -- "UIPanelScrollFrameTemplate2")  Includes borders around the scrollbar
    frame:Hide()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
    self.scrollFrame = frame

    local editBox = CreateFrame("EditBox", "$parent_EditBox", self.scrollFrame)
    editBox:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT")
    editBox:SetSize(self.scrollFrame:GetWidth(), self.scrollFrame:GetHeight())
    editBox:SetMultiLine(true)
    -- NOTE I would like to make this true, but \nfoo indents foo :(
    editBox:SetIndentedWordWrap(false)
    editBox:SetAutoFocus(false)
    editBox:EnableMouse(true)
    editBox:EnableMouseWheel(true)
    editBox:SetHyperlinksEnabled(true)
    editBox:Disable()
    editBox:SetFont(Geary_Options:GetLogFontFilename(), Geary_Options:GetLogFontHeight())
    editBox:SetScript("OnHyperlinkClick", function(self, link, text, button)
        SetItemRef(link, text, button)
    end)
    editBox:SetScript("OnHyperlinkEnter", function(self, link, text)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    editBox:SetScript("OnHyperlinkLeave", function(self, link, text)
        GameTooltip:Hide()
    end)
    -- As text is added, scroll to the bottom so the most recent lines are visible
    editBox:SetScript("OnTextSet", function(self, userInput)
        Geary_Interface_Log:_SetScrollBarToBottom()
    end)
    editBox:SetScript("OnTextChanged", function(self, userInput)
        Geary_Interface_Log:_SetScrollBarToBottom()
    end)
    self.editBox = editBox

    self.scrollFrame:SetScrollChild(self.editBox)

    -- TODO Need a better place for this button and it should match the frame's theme
    -- TODO StatTemplate looks promising, but has some default scripts specific to achievements
    local button = CreateFrame("Button", "$parent_Clear", self.scrollFrame, "OptionsButtonTemplate")
    button:SetSize(75, 17)
    button:SetPoint("BOTTOM", self.scrollFrame, "BOTTOM", 24, -21)
    button:SetText("Clear")
    button:SetScript("OnClick", function(self) Geary_Interface_Log:Clear() end)

    Geary_Interface:CreateTab("Log",
        function() Geary_Interface_Log.scrollFrame:Show() end,
        function() Geary_Interface_Log.scrollFrame:Hide() end)
end

function Geary_Interface_Log:_SetScrollBarToBottom()
    self.scrollFrame:SetVerticalScroll(self.scrollFrame:GetVerticalScrollRange())
end

function Geary_Interface_Log:Append(newText)
    if (newText ~= nil) then
        self.editBox:Insert(newText)
    end
end

-- Callers can use this to clear the log at the start of an operation so it doesn't get too large
-- Note: Ideally I'd like to prune the old lines to make room, but that cratered my client so
--       we're going with a clear controlled by callers
function Geary_Interface_Log:ClearIfTooLarge()
    if self.editBox:GetNumLetters() > self.LETTERS_MAX then
        self:Clear()
    end
end

function Geary_Interface_Log:Clear()
    self.editBox:SetText("")
end

function Geary_Interface_Log:SetFont(fontFilename, fontHeight)
    self.editBox:SetFont(fontFilename, fontHeight)
    Geary_Options:SetLogFontFilename(fontFilename)
    Geary_Options:SetLogFontHeight(fontHeight)
end
