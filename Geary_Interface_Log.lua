--[[

--]]

Geary_Interface_Log = {
	mainFrame = nil,
	messages = nil,
	scrollBar = nil
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
	messages:SetPoint("CENTER", 0, 10)
	messages:SetSize(self.mainFrame:GetWidth() - 30, self.mainFrame:GetHeight() - 60)
	messages:SetFont("Fonts\\FRIZQT__.TTF", 10)
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
	local scrollBar = CreateFrame("Slider", nil, self.mainFrame, "UIPanelScrollBarTemplate")
	scrollBar:SetPoint("RIGHT", self.mainFrame, "RIGHT", -10, 10)
	scrollBar:SetSize(30, self.mainFrame:GetHeight() - 90)
	scrollBar:SetMinMaxValues(0, 0)
	scrollBar:SetValueStep(1)
	scrollBar.scrollStep = 4
	scrollBar:SetScript("OnValueChanged", function(self, value)
		Geary_Interface_Log:OnValueChanged(self, value)
	end)
	scrollBar:SetScript("OnMouseWheel", function(self, delta)
		Geary_Interface_Log:OnMouseWheel(self, delta)
	end)
	self.scrollBar = scrollBar
end

function Geary_Interface_Log:AddMessage(...)
	self.messages:AddMessage(...)
	-- TODO: GetCurrentLine wraps to zero?
	self.scrollBar:SetMinMaxValues(0, self.messages:GetCurrentLine())
	self.scrollBar:SetValue(self.messages:GetCurrentLine())
end

function Geary_Interface_Log:Clear()
	self.messages:Clear()
end

function Geary_Interface_Log:OnValueChanged(scrollBar, value)
	local newOffset = select(2, scrollBar:GetMinMaxValues()) - value
	self.messages:SetScrollOffset(newOffset)
end

function Geary_Interface_Log:OnMouseWheel(scrollBar, delta)
	local cur_val = scrollBar:GetValue()
	local min_val, max_val = scrollBar:GetMinMaxValues()

	if delta < 0 and cur_val < max_val then
		cur_val = math.min(max_val, cur_val + 1)
		scrollBar:SetValue(cur_val)
	elseif delta > 0 and cur_val > min_val then
		cur_val = math.max(min_val, cur_val - 1)
		scrollBar:SetValue(cur_val)
	end
end