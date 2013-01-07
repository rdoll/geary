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

local _fontFilenames = {
	byFilename = {
		["Fonts\\FRIZQT__.TTF"] = { id = 1, name = "Friz Quadrata" },
		["Fonts\\ARIALN.TTF"]   = { id = 2, name = "Arial Narrow"  },
		["Fonts\\SKURRI.ttf"]   = { id = 3, name = "Skurri"        },
		["Fonts\\MORPHEUS.ttf"] = { id = 4, name = "Morpheus"      }
	},
	byId = {
		[1] = "Fonts\\FRIZQT__.TTF",
		[2] = "Fonts\\ARIALN.TTF",
		[3] = "Fonts\\SKURRI.ttf",
		[4] = "Fonts\\MORPHEUS.ttf"
	}
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
	
	-- Create sections
	local section = self:_createIconSection(subtitle)
	section = self:_createInterfaceSection(section)
	
	-- Mark created so we don't recreate everything
	self.contentsCreated = true
end

function Geary_Interface_Options:_createIconSection(previousItem)

	-- Icon header
	local iconHeader = self:_createHeader(self.mainFrame, "Geary Icon Button")
	iconHeader:SetWidth(self.mainFrame:GetWidth() - 32)
	iconHeader:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", -2, -5)

	-- Icon shown
	local checkbox = CreateFrame("CheckButton", "$parent_Icon_Shown_Checkbox", self.mainFrame,
		"InterfaceOptionsCheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", iconHeader, "BOTTOMLEFT", -2, -5)
	checkbox.Label = _G[checkbox:GetName() .. "Text"]
	checkbox.Label:SetText("Show Icon Button")
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
	slider:SetPoint("TOPLEFT", iconHeader, "BOTTOM", 0, -30)
	slider:Enable()
	-- Label above
	slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	slider.Label:SetPoint("TOPLEFT", -5, 18)
	slider.Label:SetText("Icon Button Scale:")
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

	return self.iconShownCheckbox
end

local function _logFontFilenameDropdownInitialize(self, level)
	local id, filename, info
	for id, filename in ipairs(_fontFilenames.byId) do
		info = UIDropDownMenu_CreateInfo()
		info.text = _fontFilenames.byFilename[filename].name
		info.value = filename
		info.func = function (self)
			UIDropDownMenu_SetSelectedID(Geary_Interface_Options.logFontFilenameDropdown, self:GetID())
		end
		UIDropDownMenu_AddButton(info, level)
	end
end

function Geary_Interface_Options:_createInterfaceSection(previousItem)

	-- Geary interface header
	local interfaceHeader = self:_createHeader(self.mainFrame, "Geary Interface")
	interfaceHeader:SetWidth(self.mainFrame:GetWidth() - 32)
	interfaceHeader:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, -45)

	-- Log font filename dropdown
	local label = self.mainFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	label:SetText("Log Font:")
	label:SetPoint("TOPLEFT", interfaceHeader, "BOTTOMLEFT", 5, -15)

	local dropdown = CreateFrame("Button", "$parent_Log_Font_Filename_Dropdown", self.mainFrame,
		"UIDropDownMenuTemplate")
	dropdown:SetPoint("LEFT", label, "RIGHT", 0, -3)
	self.logFontFilenameDropdown = dropdown  -- Required by initialize function
	UIDropDownMenu_Initialize(dropdown, _logFontFilenameDropdownInitialize)
	UIDropDownMenu_SetWidth(dropdown, 100)
	UIDropDownMenu_SetButtonWidth(dropdown, 124)
	UIDropDownMenu_SetSelectedID(dropdown,
		_fontFilenames.byFilename[Geary_Options.getLogFontFilename()].id)
	UIDropDownMenu_JustifyText(dropdown, "LEFT")
	
	-- Log font height slider
	
	return self.logFontFilenameDropdown  -- TODO update to font height slider
end

function Geary_Interface_Options:_createHeader(parent, name)

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(16)

	local text = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	text:SetPoint("TOP")
	text:SetPoint("BOTTOM")
	text:SetJustifyH("CENTER")
	text:SetText(name)

	local leftLine = frame:CreateTexture(nil, "BACKGROUND")
	leftLine:SetHeight(8)
	leftLine:SetPoint("LEFT", 3, 0)
	leftLine:SetPoint("RIGHT", text, "LEFT", -5, 0)
	leftLine:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	leftLine:SetTexCoord(0.81, 0.94, 0.5, 1)

	local rightLine = frame:CreateTexture(nil, "BACKGROUND")
	rightLine:SetHeight(8)
	rightLine:SetPoint("RIGHT", -3, 0)
	rightLine:SetPoint("LEFT", text, "RIGHT", 5, 0)
	rightLine:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	rightLine:SetTexCoord(0.81, 0.94, 0.5, 1)
	
	return frame
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
	-- Note: Not sure why, but must initialize before setting a value or we get garbage text
	UIDropDownMenu_Initialize(self.logFontFilenameDropdown, _logFontFilenameDropdownInitialize)
	UIDropDownMenu_SetSelectedID(self.logFontFilenameDropdown,
		_fontFilenames.byFilename[Geary_Options:getLogFontFilename()].id)
end

function Geary_Interface_Options:onDefault(frame)
	self.iconShownCheckbox:SetChecked(Geary_Options:getDefaultIconShown())
	self.iconScaleSlider:SetValue(ceil(Geary_Options:getDefaultIconScale() * 100))
	-- Note: Not sure why, but must initialize before setting a value or we get garbage text
	UIDropDownMenu_Initialize(self.logFontFilenameDropdown, _logFontFilenameDropdownInitialize)
	UIDropDownMenu_SetSelectedID(self.logFontFilenameDropdown,
		_fontFilenames.byFilename[Geary_Options:getDefaultLogFontFilename()].id)
end

function Geary_Interface_Options:onOkay(frame)
	if self.iconShownCheckbox:GetChecked() then
		Geary_Interface_Icon:Show()
	else
		Geary_Interface_Icon:Hide()
	end
	Geary_Interface_Icon:setScale(self.iconScaleSlider:GetValue() / 100)
	Geary_Interface_Log:setFont(
		_fontFilenames.byId[UIDropDownMenu_GetSelectedID(self.logFontFilenameDropdown)],
		Geary_Options:getLogFontHeight())  -- TODO change to option slider
end