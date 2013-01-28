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

function Geary_Interface_Log:init()
	self.scrollFrame = CreateFrame("ScrollFrame", "Geary_Ui_Log", Geary_Interface.mainFrame,
		"UIPanelScrollFrameTemplate")
		--"UIPanelScrollFrameTemplate2")  Includes borders around the scrollbar
	self.scrollFrame:SetPoint("TOPLEFT", Geary_Interface.mainFrame, "TOPLEFT", 4, -18)
	self.scrollFrame:SetPoint("BOTTOMRIGHT", Geary_Interface.mainFrame, "BOTTOMRIGHT", -36, 44)

	self.editBox = CreateFrame("EditBox", "Geary_Ui_Log_EditBox", self.scrollFrame)
	self.editBox:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT")
	self.editBox:SetSize(self.scrollFrame:GetWidth(), self.scrollFrame:GetHeight())
	self.editBox:SetMultiLine(true)
	self.editBox:SetIndentedWordWrap(true)  -- TODO This doesn't seem to be working
	self.editBox:SetAutoFocus(false)
	self.editBox:EnableMouse(true)
	self.editBox:EnableMouseWheel(true)
	self.editBox:SetHyperlinksEnabled(true)
	self.editBox:Disable()
	self.editBox:SetFont(Geary_Options:getLogFontFilename(), Geary_Options:getLogFontHeight())
	self.editBox:SetScript("OnHyperlinkClick", function (self, link, text, button)
		SetItemRef(link, text, button)
	end)
	self.editBox:SetScript("OnHyperlinkEnter", function (self, link, text)
		GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end)
	self.editBox:SetScript("OnHyperlinkLeave", function (self, link, text)
		GameTooltip:Hide()
	end)
	-- As text is added, scroll to the bottom so the most recent lines are visible
	self.editBox:SetScript("OnTextSet", function (self, userInput)
		Geary_Interface_Log:_setScrollBarToBottom()
	end)
	self.editBox:SetScript("OnTextChanged", function (self, userInput)
		Geary_Interface_Log:_setScrollBarToBottom()
	end)
	
	self.scrollFrame:SetScrollChild(self.editBox)
end

function Geary_Interface_Log:_setScrollBarToBottom()
	self.scrollFrame:SetVerticalScroll(self.scrollFrame:GetVerticalScrollRange())
end

function Geary_Interface_Log:append(newText)
	if (newText ~= nil) then
		self.editBox:Insert(newText)
	end
end

-- Callers can use this to clear the log at the start of an operation so it doesn't get too large
-- Note: Ideally I'd like to prune the old lines to make room, but that cratered my client so
--       we're going with a clear controlled by callers
function Geary_Interface_Log:clearIfTooLarge()
	if self.editBox:GetNumLetters() > self.LETTERS_MAX then
		self:clear()
	end
end

function Geary_Interface_Log:clear()
	self.editBox:SetText("")
end

function Geary_Interface_Log:setFont(fontFilename, fontHeight)
	self.editBox:SetFont(fontFilename, fontHeight)
	Geary_Options:setLogFontFilename(fontFilename)
	Geary_Options:setLogFontHeight(fontHeight)
end