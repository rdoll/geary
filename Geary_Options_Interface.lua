--[[
    Geary options interface

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Options_Interface = {
    contentsCreated = false,

    mainFrame = nil,

    iconShownCheckbox = nil,
    iconScaleSlider = nil,

    interfaceScaleSlider = nil,
    logFontHeightSlider = nil,
    logFontFilenameDropdown = nil,

    databaseEnabledCheckbox = nil,
    databaseMinLevelSlider = nil,
    databasePruneOnLoadCheckbox = nil,
    databasePruneNowButton = nil,
    databasePruneDaysSlider = nil
}

local _fontFilenames = {
    byFilename = {
        ["Fonts\\FRIZQT__.TTF"] = { id = 1, name = "Friz Quadrata" },
        ["Fonts\\ARIALN.TTF"] = { id = 2, name = "Arial Narrow" },
        ["Fonts\\SKURRI.ttf"] = { id = 3, name = "Skurri" },
        ["Fonts\\MORPHEUS.ttf"] = { id = 4, name = "Morpheus" }
    },
    byId = {
        [1] = "Fonts\\FRIZQT__.TTF",
        [2] = "Fonts\\ARIALN.TTF",
        [3] = "Fonts\\SKURRI.ttf",
        [4] = "Fonts\\MORPHEUS.ttf"
    }
}

function Geary_Options_Interface:Init()
    -- Add our options frame to the Interface Addon Options GUI
    local frame = CreateFrame("Frame", "Geary_Ui_Options_Frame", UIParent)
    frame:Hide()
    frame.name = Geary.title
    frame.default = function(self) Geary_Options_Interface:OnDefault(self) end
    frame.okay = function(self) Geary_Options_Interface:OnOkay(self) end
    frame:SetScript("OnShow", function(self) Geary_Options_Interface:OnShow(self) end)
    InterfaceOptions_AddCategory(frame)
    self.mainFrame = frame
end

--
-- Starting in 5.4, sliders don't properly respect the step values and OnValueChanged events
-- will receive fractional values. As detailed at http://www.wowwiki.com/Patch_5.4.0/API_changes#Slider,
-- the following workaround honors the steps with a minimal impact to performance.
--
local function _sliderOnValueChangedFix(slider, value, valueSuffix)
    -- start fix
    if not slider._onsetting then  -- is single threaded
        slider._onsetting = true
        slider:SetValue(slider:GetValue())
        value = slider:GetValue()  -- cant use original 'value' parameter
        slider._onsetting = false
    else
        return  -- ignore recursion for actual event handler
    end
    -- end fix
    slider.Value:SetText(valueSuffix ~= nil and (value .. valueSuffix) or value)  -- handle the event
end

function Geary_Options_Interface:_CreateContents()

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
    local section = self:_CreateIconSection(subtitle)
    section = self:_CreateInterfaceSection(section)
    section = self:_CreateDatabaseSection(section)
    section = self:_CreateDatabasePruneInputs(section)

    -- Mark created so we don't recreate everything
    self.contentsCreated = true
end

function Geary_Options_Interface:_CreateHeader(parent, name)

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

function Geary_Options_Interface:_CreateIconSection(previousItem)

    -- Icon header
    local iconHeader = self:_CreateHeader(self.mainFrame, "Geary Icon Button")
    iconHeader:SetWidth(self.mainFrame:GetWidth() - 32)
    iconHeader:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", -2, -5)

    -- Icon shown
    local checkbox = CreateFrame("CheckButton", "$parent_Icon_Shown_Checkbox", self.mainFrame,
        "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", iconHeader, "BOTTOMLEFT", 0, -5)
    checkbox.Label = _G[checkbox:GetName() .. "Text"]
    checkbox.Label:SetText("Show Icon Button")
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Shows the Geary quick access icon")
    end)
    checkbox:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(checkbox, checkbox:GetParent())
    self.iconShownCheckbox = checkbox

    -- Icon scale
    local slider = CreateFrame("Slider", "$parent_Icon_Scale_Slider", self.mainFrame, "OptionsSliderTemplate")
    slider:SetWidth(190)
    slider:SetHeight(14)
    slider:SetMinMaxValues(10, 200)
    slider:SetValueStep(1)
    slider:SetStepsPerPage(1)
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
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, "%")
    end)
    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Scale of the Geary quick access icon")
    end)
    slider:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.iconScaleSlider = slider

    return self.iconShownCheckbox
end

local function _logFontFilenameDropdownInitialize(self, level)
    local info
    for id, filename in ipairs(_fontFilenames.byId) do
        info = UIDropDownMenu_CreateInfo()
        info.text = _fontFilenames.byFilename[filename].name
        info.value = filename
        info.func = function(self)
            UIDropDownMenu_SetSelectedID(Geary_Options_Interface.logFontFilenameDropdown, self:GetID())
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

function Geary_Options_Interface:_CreateInterfaceSection(previousItem)

    -- Geary interface header
    local interfaceHeader = self:_CreateHeader(self.mainFrame, "Geary Interface")
    interfaceHeader:SetWidth(self.mainFrame:GetWidth() - 32)
    interfaceHeader:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, -45)

    -- Interface scale slider
    local slider = CreateFrame("Slider", "$parent_Interface_Scale_Slider", self.mainFrame, "OptionsSliderTemplate")
    slider:SetWidth(190)
    slider:SetHeight(14)
    slider:SetMinMaxValues(50, 200)
    slider:SetValueStep(1)
    slider:SetStepsPerPage(1)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("TOPLEFT", interfaceHeader, "BOTTOMLEFT", 10, -30)
    slider:Enable()
    -- Label above
    slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    slider.Label:SetPoint("TOPLEFT", -5, 18)
    slider.Label:SetText("Interface Scale:")
    -- Lowest value label
    slider.Low = _G[slider:GetName() .. "Low"]
    slider.Low:SetText("50%")
    -- Highest value label
    slider.High = _G[slider:GetName() .. "High"]
    slider.High:SetText("200%")
    -- Current value label
    slider.Value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
    slider.Value:SetPoint("BOTTOM", 0, -10)
    slider.Value:SetWidth(50)
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, "%")
    end)
    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Scale of the interface window")
    end)
    slider:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.interfaceScaleSlider = slider

    -- Log font height slider
    local slider = CreateFrame("Slider", "$parent_Log_Font_Height_Slider", self.mainFrame, "OptionsSliderTemplate")
    slider:SetWidth(190)
    slider:SetHeight(14)
    slider:SetMinMaxValues(8, 16)
    slider:SetValueStep(1)
    slider:SetStepsPerPage(1)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("TOPLEFT", interfaceHeader, "BOTTOM", 0, -30)
    slider:Enable()
    -- Label above
    slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    slider.Label:SetPoint("TOPLEFT", -5, 18)
    slider.Label:SetText("Log Font Size:")
    -- Lowest value label
    slider.Low = _G[slider:GetName() .. "Low"]
    slider.Low:SetText("8")
    -- Highest value label
    slider.High = _G[slider:GetName() .. "High"]
    slider.High:SetText("16")
    -- Current value label
    slider.Value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
    slider.Value:SetPoint("BOTTOM", 0, -10)
    slider.Value:SetWidth(50)
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, nil)
    end)
    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Size of the font in the log interface")
    end)
    slider:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.logFontHeightSlider = slider

    -- Log font filename dropdown
    local label = self.mainFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    label:SetText("Log Font:")
    label:SetPoint("TOPLEFT", self.logFontHeightSlider, "BOTTOMLEFT", 0, -25)

    local dropdown = CreateFrame("Button", "$parent_Log_Font_Filename_Dropdown", self.mainFrame,
        "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", label, "RIGHT", 0, -3)
    self.logFontFilenameDropdown = dropdown  -- Required by initialize function
    UIDropDownMenu_Initialize(dropdown, _logFontFilenameDropdownInitialize)
    UIDropDownMenu_SetWidth(dropdown, 100)
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_SetSelectedID(dropdown, _fontFilenames.byFilename[Geary_Options.GetLogFontFilename()].id)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    return self.interfaceScaleSlider
end

function Geary_Options_Interface:_CreateDatabaseSection(previousItem)

    -- Geary database header
    local interfaceHeader = self:_CreateHeader(self.mainFrame, "Geary Database")
    interfaceHeader:SetWidth(self.mainFrame:GetWidth() - 32)
    interfaceHeader:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", -10, -60)

    -- Database enabled
    local checkbox = CreateFrame("CheckButton", "$parent_Database_Enabled_Checkbox", self.mainFrame,
        "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", interfaceHeader, "BOTTOMLEFT", 0, -5)
    checkbox.Label = _G[checkbox:GetName() .. "Text"]
    checkbox.Label:SetText("Database Enabled")
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Enable Database storage of character inspections")
    end)
    checkbox:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(checkbox, checkbox:GetParent())
    self.databaseEnabledCheckbox = checkbox

    -- Database storage character minimum level slider
    local slider = CreateFrame("Slider", "$parent_Database_Min_Level_Slider", self.mainFrame, "OptionsSliderTemplate")
    slider:SetWidth(190)
    slider:SetHeight(14)
    slider:SetMinMaxValues(1, Geary_Player.MAX_LEVEL)
    slider:SetValueStep(1)
    slider:SetStepsPerPage(1)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("TOPLEFT", interfaceHeader, "BOTTOM", 0, -30)
    slider:Enable()
    -- Label above
    slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    slider.Label:SetPoint("TOPLEFT", -5, 18)
    slider.Label:SetText("Min Level for Storage:")
    -- Lowest value label
    slider.Low = _G[slider:GetName() .. "Low"]
    slider.Low:SetText("1")
    -- Highest value label
    slider.High = _G[slider:GetName() .. "High"]
    slider.High:SetText(Geary_Player.MAX_LEVEL)
    -- Current value label
    slider.Value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
    slider.Value:SetPoint("BOTTOM", 0, -10)
    slider.Value:SetWidth(50)
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, nil)
    end)
    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Minimum character level stored in the database")
    end)
    slider:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.databaseMinLevelSlider = slider

    return checkbox
end

function Geary_Options_Interface:_CreateDatabasePruneInputs(previousItem)

    -- Pseudo-header for alignment
    local interfaceHeader = CreateFrame("Frame", nil, previousItem)
    interfaceHeader:SetHeight(1)
    interfaceHeader:SetWidth(self.mainFrame:GetWidth() - 32)
    interfaceHeader:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, -25)

    -- Database prune on load checkbox
    local checkbox = CreateFrame("CheckButton", "$parent_Database_Prune_On_Load_Checkbox", self.mainFrame,
        "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", interfaceHeader, "BOTTOMLEFT", 0, -5)
    checkbox.Label = _G[checkbox:GetName() .. "Text"]
    checkbox.Label:SetText("Auto Prune On Load")
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Automatically prune old database entries when loaded")
    end)
    checkbox:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(checkbox, checkbox:GetParent())
    self.databasePruneOnLoadCheckbox = checkbox

    -- Database prune now button
    local button = CreateFrame("Button", "$parent_Database_Prune_Now_Button", self.mainFrame, "OptionsButtonTemplate")
    button:SetSize(100, 20)
    button:SetText("Prune Now")
    button:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 2, -3)
    button:SetScript("OnClick", function(self)
        local pruneDays = Geary_Options_Interface.databasePruneDaysSlider:GetValue()
        Geary_Database:PruneNow(pruneDays)
    end)
    BlizzardOptionsPanel_RegisterControl(button, button:GetParent())
    self.databasePruneNowButton = button

    -- Database days to prune old entries
    local slider = CreateFrame("Slider", "$parent_Database_Prune_Days_Slider", self.mainFrame, "OptionsSliderTemplate")
    slider:SetWidth(190)
    slider:SetHeight(14)
    slider:SetMinMaxValues(1, 180)
    slider:SetValueStep(1)
    slider:SetStepsPerPage(1)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("TOPLEFT", interfaceHeader, "BOTTOM", 0, -30)
    slider:Enable()
    -- Label above
    slider.Label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    slider.Label:SetPoint("TOPLEFT", -5, 18)
    slider.Label:SetText("Prune Entries Older Than:")
    -- Lowest value label
    slider.Low = _G[slider:GetName() .. "Low"]
    slider.Low:SetText("1")
    -- Highest value label
    slider.High = _G[slider:GetName() .. "High"]
    slider.High:SetText("180")
    -- Current value label
    slider.Value = slider:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
    slider.Value:SetPoint("BOTTOM", 0, -10)
    slider.Value:SetWidth(100)
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, " days")
    end)
    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 16, 4)
        GameTooltip:SetText("Database entries this old or older are deleted when pruned")
    end)
    slider:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Set an initial value (which is never saved in our options)
    slider:SetValue(180)
    -- Save it
    self.databasePruneDaysSlider = slider

    return self.databasePruneDaysSlider
end

function Geary_Options_Interface:Show()
    InterfaceOptionsFrame_OpenToCategory(self.mainFrame)
    -- Per http://www.wowpedia.org/Patch_5.3.0/API_changes
    -- We need to call this twice if the user has never opened the addon panel before
    InterfaceOptionsFrame_OpenToCategory(self.mainFrame)
end

function Geary_Options_Interface:Hide()
    if InterfaceOptionsFrameCancel == nil then
        Geary:Print(Geary.CC_ERROR .. "Cannot hide Interface options" .. Geary.CC_END)
    else
        -- If the cancel button isn't visible, clicking it causes the frame to be shown
        if InterfaceOptionsFrameCancel:IsVisible() then
            -- Simulate a left-mouse button click on the Interface frame's cancel button
            InterfaceOptionsFrameCancel:Click("LeftButton", true)
        end
    end
end

function Geary_Options_Interface:Toggle()
    if InterfaceOptionsFrame:IsShown() then
        Geary_Options_Interface:Hide()
    else
        Geary_Options_Interface:Show()
    end
end

function Geary_Options_Interface:OnShow(frame)
    -- Create options frame contents once when necessary
    if not self.contentsCreated then
        self:_CreateContents()
    end

    -- Make the options match the current settings
    self.iconShownCheckbox:SetChecked(Geary_Options:IsIconShown())
    self.iconScaleSlider:SetValue(ceil(Geary_Options:GetIconScale() * 100))
    self.interfaceScaleSlider:SetValue(ceil(Geary_Options:GetInterfaceScale() * 100))
    -- Note: Not sure why, but must initialize before setting a value or we get garbage text
    UIDropDownMenu_Initialize(self.logFontFilenameDropdown, _logFontFilenameDropdownInitialize)
    UIDropDownMenu_SetSelectedID(self.logFontFilenameDropdown,
        _fontFilenames.byFilename[Geary_Options:GetLogFontFilename()].id)
    self.logFontHeightSlider:SetValue(Geary_Options:GetLogFontHeight())
    self.databaseEnabledCheckbox:SetChecked(Geary_Options:IsDatabaseEnabled())
    self.databaseMinLevelSlider:SetValue(Geary_Options:GetDatabaseMinLevel())
    self.databasePruneOnLoadCheckbox:SetChecked(Geary_Options:IsDatabasePruneOnLoad())
    self.databasePruneDaysSlider:SetValue(Geary_Options:GetDatabasePruneDays())
end

function Geary_Options_Interface:OnDefault(frame)
    self.iconShownCheckbox:SetChecked(Geary_Options:GetDefaultIconShown())
    self.iconScaleSlider:SetValue(ceil(Geary_Options:GetDefaultIconScale() * 100))
    self.interfaceScaleSlider:SetValue(ceil(Geary_Options:GetDefaultInterfaceScale() * 100))
    -- Note: Not sure why, but must initialize before setting a value or we get garbage text
    UIDropDownMenu_Initialize(self.logFontFilenameDropdown, _logFontFilenameDropdownInitialize)
    UIDropDownMenu_SetSelectedID(self.logFontFilenameDropdown,
        _fontFilenames.byFilename[Geary_Options:GetDefaultLogFontFilename()].id)
    self.logFontHeightSlider:SetValue(Geary_Options:GetDefaultLogFontHeight())
    self.databaseEnabledCheckbox:SetChecked(Geary_Options:GetDefaultDatabaseEnabled())
    self.databaseMinLevelSlider:SetValue(Geary_Options:GetDefaultDatabaseMinLevel())
    self.databasePruneOnLoadCheckbox:SetChecked(Geary_Options:GetDefaultDatabasePruneOnLoad())
    self.databasePruneDaysSlider:SetValue(Geary_Options:GetDefaultDatabasePruneDays())
end

function Geary_Options_Interface:OnOkay(frame)

    if self.iconShownCheckbox:GetChecked() then
        Geary_Icon:Show()
    else
        Geary_Icon:Hide()
    end
    Geary_Icon:SetScale(self.iconScaleSlider:GetValue() / 100)

    Geary_Interface:SetScale(self.interfaceScaleSlider:GetValue() / 100)
    Geary_Interface_Log:SetFont(_fontFilenames.byId[UIDropDownMenu_GetSelectedID(self.logFontFilenameDropdown)],
        self.logFontHeightSlider:GetValue())

    if self.databaseEnabledCheckbox:GetChecked() then
        Geary_Database:Enable()
    else
        Geary_Database:Disable()
    end
    Geary_Database:SetMinLevel(self.databaseMinLevelSlider:GetValue())
    Geary_Database:SetPruneOnLoad(self.databasePruneOnLoadCheckbox:GetChecked() and true or false)
    Geary_Database:SetPruneDays(self.databasePruneDaysSlider:GetValue())
end
