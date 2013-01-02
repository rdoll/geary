--[[
	Geary options interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Options = {
	mainFrame = nil,
	contentsCreated = false,
	iconShownCheckbox = nil,
	iconScaleSlider = nil
}

function Geary_Interface_Options:init()
	-- Add our options frame to the Interface Addon Options GUI
	local frame = CreateFrame("Frame", "Geary_Ui_Options_Frame", UIParent)
	frame:Hide()
	frame.name = Geary.title
	frame.default = function (self) Geary_Interface_Options:onDefault(self) end
	frame.okay = function (self) Geary_Interface_Options:onOkay(self) end
	frame:SetScript("OnShow", function (self) Geary_Interface_Options:OnShow(self) end)
	InterfaceOptions_AddCategory(frame)
	self.mainFrame = frame
end

function Geary_Interface_Options:_createContents()

	-- Title
	local title = self.mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(Geary.title)

	-- Subtitle
	local subtitle = self.mainFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", self.mainFrame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("Version: " .. Geary.version .. "\n" .. Geary.notes)
	
	-- Icon shown
	local checkbox = CreateFrame("CheckButton", "$parent_Icon_Shown_Checkbox", self.mainFrame,
		"InterfaceOptionsCheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -5)
	checkbox.Label = _G[checkbox:GetName() .. "Text"]
	checkbox.Label:SetText("Show Icon")
	checkbox:SetScript("OnEnter", function (self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
		GameTooltip:SetText("Shows the Geary quick access icon")
	end)
	checkbox:SetScript("OnLeave", function (self) GameTooltip:Hide() end)
	BlizzardOptionsPanel_RegisterControl(checkbox, checkbox:GetParent())
	self.iconShownCheckbox = checkbox
	
	-- Icon scale
	local slider = CreateFrame("Slider", "$parent_Icon_Scale_Slider", self.mainFrame,
		"OptionsSliderTemplate")
	slider:SetWidth(190)
	slider:SetHeight(14)
	slider:SetMinMaxValues(10, 200)
	slider:SetValueStep(1)
	slider:SetOrientation("HORIZONTAL")
	slider:SetPoint("TOPLEFT", self.iconShownCheckbox, "BOTTOMLEFT", 10, -30)
	slider:Enable()
	-- Label above
	slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	slider.Label:SetPoint("TOPLEFT", -5, 18)
	slider.Label:SetText("Icon Scale:")
	-- Lowest value label
	slider.Low = _G[slider:GetName() .. "Low"]
	slider.Low:SetText("10%")
	-- Highest value label
	slider.High = _G[slider:GetName() .. "High"]
	slider.High:SetText("200%")
	-- Current value label
	slider.Value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
	slider.Value:SetPoint("BOTTOM", 0, -10)
	slider.Value:SetWidth(50)
	-- Handlers
	slider:SetScript("OnValueChanged", function (self, value)
		self.Value:SetText(value .. "%")
	end)
	slider:SetScript("OnEnter", function (self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
		GameTooltip:SetText("Scale of the Geary quick access icon")
	end)
	slider:SetScript("OnLeave", function (self) GameTooltip:Hide() end)
	BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
	-- Save it
	self.iconScaleSlider = slider

	self.contentsCreated = true
end

function Geary_Interface_Options:Show()
	 InterfaceOptionsFrame_OpenToCategory(self.mainFrame)
end

function Geary_Interface_Options:OnShow(frame)
	-- Create options frame contents once when necessary
	if not self.contentsCreated then
		self:_createContents()
	end
	
	-- Make the options match the current settings
	self.iconShownCheckbox:SetChecked(Geary_Options:isIconShown())
	self.iconScaleSlider:SetValue(ceil(Geary_Options:getIconScale() * 100))
end

function Geary_Interface_Options:onDefault(frame)
	self.iconShownCheckbox:SetChecked(Geary_Options.defaultIconShown)
	self.iconScaleSlider:SetValue(ceil(Geary_Options.defaultIconScale * 100))
end

function Geary_Interface_Options:onOkay(frame)
	if self.iconShownCheckbox:GetChecked() then
		Geary_Interface_Icon:Show()
	else
		Geary_Interface_Icon:Hide()
	end
	Geary_Interface_Icon:setScale(self.iconScaleSlider:GetValue() / 100)
end