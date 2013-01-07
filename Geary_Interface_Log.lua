--[[
	Geary log interface

	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Log = {
	mainFrame = nil,
	messages = nil,
	scrollBar = nil,
	scrollUpButton = nil,
	scrollDownButton = nil,
	MAX_MESSAGE_LINES = 23  -- TODO This should be calculated, not hard coded
}

function Geary_Interface_Log:init()
	self:_createMainFrame()
	self:_createMessagesFrame()
	self:_createScrollBar()
end

function Geary_Interface_Log:_createMainFrame()
	self.mainFrame = CreateFrame("Frame", "Geary_Ui_Log_Main", Geary_Interface.mainFrame)
	self.mainFrame:SetPoint("CENTER", 0, 0)
	self.mainFrame:SetSize(Geary_Interface.mainFrame:GetWidth(), Geary_Interface.mainFrame:GetHeight())
end

function Geary_Interface_Log:_createMessagesFrame()
	local messages = CreateFrame("ScrollingMessageFrame", nil, self.mainFrame)
	messages:SetPoint("CENTER", -10, 10)
	messages:SetSize(self.mainFrame:GetWidth() - 60, self.mainFrame:GetHeight() - 60)
	messages:SetFont(Geary_Options:getLogFontFilename(), Geary_Options:getLogFontHeight())
	messages:SetTextColor(1, 1, 1, 1)
	messages:SetJustifyH("LEFT")
	messages:SetFading(false)
	messages:SetMaxLines(500)
	messages:SetIndentedWordWrap(true)
	messages:EnableMouse(true)
	messages:EnableMouseWheel(true)
	messages:SetHyperlinksEnabled(true)
	messages:SetScript("OnHyperlinkClick", function (self, link, text, button)
		SetItemRef(link, text, button)
	end)
	messages:SetScript("OnHyperlinkEnter", function (self, link, text)
		GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end)
	messages:SetScript("OnHyperlinkLeave", function (self, link, text)
		GameTooltip:Hide()
	end)
	messages:SetScript("OnMouseWheel", function(self, delta)
		Geary_Interface_Log:OnMouseWheel(Geary_Interface_Log.scrollBar, delta)
	end)
	self.messages = messages
end

-- TODO Should be able to drag scrollbar handle to scroll
function Geary_Interface_Log:_createScrollBar()
	local scrollBar = CreateFrame("Slider", "$parent_Scrollbar", self.mainFrame, "UIPanelScrollBarTemplate")
	scrollBar:SetPoint("RIGHT", self.mainFrame, "RIGHT", -10, 10)
	scrollBar:SetSize(30, self.mainFrame:GetHeight() - 90)
	scrollBar:SetMinMaxValues(0, 0)
	scrollBar:SetValueStep(1)
	scrollBar.scrollStep = 1
	scrollBar:SetScript("OnValueChanged", function(self, value)
		Geary_Interface_Log:OnValueChanged(self, value)
	end)
	scrollBar:SetScript("OnMouseWheel", function(self, delta)
		Geary_Interface_Log:OnMouseWheel(self, delta)
	end)
	self.scrollBar = scrollBar
	self.scrollUpButton = _G[scrollBar:GetName() .. "ScrollUpButton"]
	self.scrollDownButton = _G[scrollBar:GetName() .. "ScrollDownButton"]
	self:_syncScrollBar()
end

function Geary_Interface_Log:AddMessage(...)
	self.messages:AddMessage(...)
	self:_syncScrollBar()
end

function Geary_Interface_Log:Clear()
	self.messages:Clear()
	self:_syncScrollBar()
end

-- Syncs the scrollbar to the messages list.
-- If the messages list doesn't require a scrollbar, disable it,
-- otherwise enable it and set the scroll buttons and handle correctly.
-- Notes:
--   + The ScrollingMessageFrame's scroll offset of 0 is the bottom-most line
--     but the scrollbar's minimum value of 0 is the top-most line
--   + The scrollbar's OnValueChanged is only called when the value changes,
--     so make the min value 1 and use 0 when the scrollbar is disabled
function Geary_Interface_Log:_syncScrollBar()
	local numMessages = self.messages:GetNumMessages()
	if  numMessages <= self.MAX_MESSAGE_LINES then
		self.scrollBar:Disable()
		self.scrollBar:SetMinMaxValues(0, 0)
		self.scrollBar:SetValue(0)
		self.scrollUpButton:Disable()
		self.scrollDownButton:Disable()
	else
		local minValue = 1
		local maxValue = numMessages - self.MAX_MESSAGE_LINES + 1
		local currentScroll = self.messages:GetCurrentScroll()
		local newValue = maxValue - currentScroll
		if newValue < minValue then
			newValue = minValue
		end
		-- Geary:debugPrint(("sync: numMess=%i, currScroll=%i, newVal=%i, minVal=%i, maxVal=%i"):format(
		--	numMessages, currentScroll, newValue, minValue, maxValue))
		self.scrollBar:Enable()
		self.scrollBar:SetMinMaxValues(minValue, maxValue)
		self.scrollBar:SetValue(newValue)
	end
end

-- Enable or disable the scroll bar buttons based on the scroll bar's
-- current value versus the minimum and maximum values
function Geary_Interface_Log:_syncScrollBarButtons(currentValue, minValue, maxValue)
	if currentValue == minValue then
		self.scrollUpButton:Disable()
	else
		self.scrollUpButton:Enable()
	end
	if currentValue == maxValue then
		self.scrollDownButton:Disable()
	else
		self.scrollDownButton:Enable()
	end
end

function Geary_Interface_Log:OnValueChanged(scrollBar, value)
	local minValue, maxValue = scrollBar:GetMinMaxValues()
	-- Geary:debugPrint(("sbvalchange: val=%i, min=%i, max=%i, currOffset=%i, numLines=%i, newOffset=%i"):
	--	format(value, minValue, maxValue, self.messages:GetCurrentScroll(),
	--	self.messages:GetNumMessages(), maxValue - value))
	self.messages:SetScrollOffset(maxValue - value)
	self:_syncScrollBarButtons(value, minValue, maxValue)
end

function Geary_Interface_Log:OnMouseWheel(scrollBar, delta)
	local currentValue = scrollBar:GetValue()
	local minValue, maxValue = scrollBar:GetMinMaxValues()

	if delta < 0 and currentValue < maxValue then
		currentValue = math.min(maxValue, currentValue + 1)
		scrollBar:SetValue(currentValue)
	elseif delta > 0 and currentValue > minValue then
		currentValue = math.max(minValue, currentValue - 1)
		scrollBar:SetValue(currentValue)
	end
end

function Geary_Interface_Log:setFont(fontFilename, fontHeight)
	self.messages:SetFont(fontFilename, fontHeight)
	Geary_Options:setLogFontFilename(fontFilename)
	Geary_Options:setLogFontHeight(fontHeight)
end