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

function Geary_Interface_Log:init(parent)

	local frame = CreateFrame("ScrollFrame", "$parent_Log", parent, "UIPanelScrollFrameTemplate")
		-- "UIPanelScrollFrameTemplate2")  Includes borders around the scrollbar
	frame:Hide()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", -9, -2)
	frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
	self.scrollFrame = frame

	local editBox = CreateFrame("EditBox", "$parent_EditBox", self.scrollFrame)
	editBox:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT")
	editBox:SetSize(self.scrollFrame:GetWidth(), self.scrollFrame:GetHeight())
	editBox:SetMultiLine(true)
	editBox:SetIndentedWordWrap(true)  -- TODO This doesn't seem to be working
	editBox:SetAutoFocus(false)
	editBox:EnableMouse(true)
	editBox:EnableMouseWheel(true)
	editBox:SetHyperlinksEnabled(true)
	editBox:Disable()
	editBox:SetFont(Geary_Options:getLogFontFilename(), Geary_Options:getLogFontHeight())
	editBox:SetScript("OnHyperlinkClick", function (self, link, text, button)
		SetItemRef(link, text, button)
	end)
	editBox:SetScript("OnHyperlinkEnter", function (self, link, text)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end)
	editBox:SetScript("OnHyperlinkLeave", function (self, link, text)
		GameTooltip:Hide()
	end)
	-- As text is added, scroll to the bottom so the most recent lines are visible
	editBox:SetScript("OnTextSet", function (self, userInput)
		Geary_Interface_Log:_setScrollBarToBottom()
	end)
	editBox:SetScript("OnTextChanged", function (self, userInput)
		Geary_Interface_Log:_setScrollBarToBottom()
	end)
	self.editBox = editBox
	
	self.scrollFrame:SetScrollChild(self.editBox)

	-- TODO Need a better place for this button and it should match the frame's theme
	-- TODO StatTemplate looks promising, but has some default scripts specific to achievements
	local button = CreateFrame("Button", "$parent_Clear", self.scrollFrame, "OptionsButtonTemplate")
	button:SetPoint("BOTTOM", self.scrollFrame, "BOTTOM", 24, -22)
	button:SetText("Clear")
	button:SetScript("OnClick", function (self)	Geary_Interface_Log:clear() end)

	Geary_Interface:createTab("Log",
		function () Geary_Interface_Log.scrollFrame:Show() end,
		function () Geary_Interface_Log.scrollFrame:Hide() end
	)
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