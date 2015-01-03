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
    databaseEntryInTooltipCheckbox = nil,
    databaseMinLevelSlider = nil,
    databasePruneOnLoadCheckbox = nil,
    databasePruneNowButton = nil,
    databasePruneDaysSlider = nil,

    showMopLegProgressCheckbox = nil
}

local _FONT_FILENAMES = {
    byFilename = {
        ["Fonts\\FRIZQT__.TTF"] = { id = 1, name = "Friz Quadrata" },
        ["Fonts\\ARIALN.TTF"]   = { id = 2, name = "Arial Narrow" },
        ["Fonts\\SKURRI.ttf"]   = { id = 3, name = "Skurri" },
        ["Fonts\\MORPHEUS.ttf"] = { id = 4, name = "Morpheus" }
    },
    byId = {
        [1] = "Fonts\\FRIZQT__.TTF",
        [2] = "Fonts\\ARIALN.TTF",
        [3] = "Fonts\\SKURRI.ttf",
        [4] = "Fonts\\MORPHEUS.ttf"
    }
}

local _SCROLL_BAR_SPACE = 32

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
-- the following workaround honors the steps with minimal impact to performance.
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
    subtitle:SetPoint("RIGHT", self.mainFrame, _SCROLL_BAR_SPACE, 0)
    subtitle:SetNonSpaceWrap(true)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetJustifyV("TOP")
    subtitle:SetText("Version: " .. Geary.version .. "\n" .. Geary.notes)

    -- Create sections
    local section = self:_CreateIconSection(self.mainFrame, subtitle)
    section = self:_CreateInterfaceSection(self.mainFrame, section)
    section = self:_CreateDatabaseSection(self.mainFrame, section)
    section = self:_CreateInspectionSection(self.mainFrame, section)

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

function Geary_Options_Interface:_CreateIconSection(parent, previousSection)

    -- Section container
    local section = CreateFrame("Frame", "$parent_Icon_Section", parent)
    section:SetSize(parent:GetWidth() - _SCROLL_BAR_SPACE, 70)
    section:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -5)

    -- Icon header
    local iconHeader = self:_CreateHeader(section, "Geary Icon Button")
    iconHeader:SetWidth(section:GetWidth())
    iconHeader:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)

    -- Icon shown
    local checkbox = CreateFrame("CheckButton", "$parent_Icon_Shown_Checkbox", section, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", iconHeader, "BOTTOMLEFT", 0, -5)
    checkbox.Label = _G[checkbox:GetName() .. "Text"]
    checkbox.Label:SetText("Show Icon Button")
    checkbox.tooltipText = "Shows the Geary quick access icon"
    BlizzardOptionsPanel_RegisterControl(checkbox, checkbox:GetParent())
    self.iconShownCheckbox = checkbox

    -- Icon scale
    local slider = CreateFrame("Slider", "$parent_Icon_Scale_Slider", section, "OptionsSliderTemplate")
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
    slider.tooltipText = "Scale of the Geary quick access icon"
    slider.tooltipOwnerPoint = "ANCHOR_TOP"
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, "%")
    end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.iconScaleSlider = slider

    return section
end

local function _logFontFilenameDropdownInitialize(self, level)
    local info
    for id, filename in ipairs(_FONT_FILENAMES.byId) do
        info = UIDropDownMenu_CreateInfo()
        info.text = _FONT_FILENAMES.byFilename[filename].name
        info.value = filename
        info.func = function(self)
            UIDropDownMenu_SetSelectedID(Geary_Options_Interface.logFontFilenameDropdown, self:GetID())
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

function Geary_Options_Interface:_CreateInterfaceSection(parent, previousSection)

    -- Section container
    local section = CreateFrame("Frame", "$parent_Interface_Section", parent)
    section:SetSize(parent:GetWidth() - _SCROLL_BAR_SPACE, 100)
    section:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -10)

    -- Geary interface header
    local interfaceHeader = self:_CreateHeader(section, "Geary Interface")
    interfaceHeader:SetWidth(section:GetWidth())
    interfaceHeader:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)

    -- Interface scale slider
    local slider = CreateFrame("Slider", "$parent_Interface_Scale_Slider", section, "OptionsSliderTemplate")
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
    slider.tooltipText = "Scale of the interface window"
    slider.tooltipOwnerPoint = "ANCHOR_TOP"
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, "%")
    end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.interfaceScaleSlider = slider

    -- Log font height slider
    local slider = CreateFrame("Slider", "$parent_Log_Font_Height_Slider", section, "OptionsSliderTemplate")
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
    slider.tooltipText = "Size of the font in the log interface"
    slider.tooltipOwnerPoint = "ANCHOR_TOP"
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, nil)
    end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.logFontHeightSlider = slider

    -- Log font filename dropdown
    local label = section:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    label:SetText("Log Font:")
    label:SetPoint("TOPLEFT", self.logFontHeightSlider, "BOTTOMLEFT", 0, -25)

    local dropdown = CreateFrame("Button", "$parent_Log_Font_Filename_Dropdown", section, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", label, "RIGHT", 0, -3)
    self.logFontFilenameDropdown = dropdown  -- Required by initialize function
    UIDropDownMenu_Initialize(dropdown, _logFontFilenameDropdownInitialize)
    UIDropDownMenu_SetWidth(dropdown, 100)
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_SetSelectedID(dropdown, _FONT_FILENAMES.byFilename[Geary_Options.GetLogFontFilename()].id)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    return section
end

function Geary_Options_Interface:_CreateDatabaseSection(parent, previousSection)

    -- Section container
    local section = CreateFrame("Frame", "$parent_Database_Section", parent)
    section:SetSize(parent:GetWidth() - _SCROLL_BAR_SPACE, 140)
    section:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -10)

    -- Geary database header
    local databaseHeader = self:_CreateHeader(section, "Geary Interface")
    databaseHeader:SetWidth(section:GetWidth())
    databaseHeader:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)

    -- Database enabled checkbox
    local enabledCheckbox = CreateFrame("CheckButton", "$parent_Database_Enabled_Checkbox", section,
        "InterfaceOptionsCheckButtonTemplate")
    enabledCheckbox:SetPoint("TOPLEFT", databaseHeader, "BOTTOMLEFT", 0, -5)
    enabledCheckbox.Label = _G[enabledCheckbox:GetName() .. "Text"]
    enabledCheckbox.Label:SetText("Database Enabled")
    enabledCheckbox.tooltipText = "Enable Database storage of character inspections"
    BlizzardOptionsPanel_RegisterControl(enabledCheckbox, enabledCheckbox:GetParent())
    self.databaseEnabledCheckbox = enabledCheckbox

    -- Show database entriy summary in unit tooltips checkbox
    local tooltipCheckbox = CreateFrame("CheckButton", "$parent_Database_Entry_In_Tooltip_Checkbox", section,
        "InterfaceOptionsSmallCheckButtonTemplate")
    tooltipCheckbox:SetPoint("TOPLEFT", enabledCheckbox, "BOTTOMLEFT", 10, 0)
    tooltipCheckbox.Label = _G[tooltipCheckbox:GetName() .. "Text"]
    tooltipCheckbox.Label:SetText("Show entry in tooltips")
    tooltipCheckbox.tooltipText = "Show summary of database entry in player tooltips"
    BlizzardOptionsPanel_RegisterControl(tooltipCheckbox, tooltipCheckbox:GetParent())
    BlizzardOptionsPanel_SetupDependentControl(enabledCheckbox, tooltipCheckbox)
    self.databaseEntryInTooltipCheckbox = tooltipCheckbox

    -- Database storage character minimum level slider
    local slider = CreateFrame("Slider", "$parent_Database_Min_Level_Slider", section, "OptionsSliderTemplate")
    slider:SetWidth(190)
    slider:SetHeight(14)
    slider:SetMinMaxValues(1, Geary_Player.MAX_LEVEL)
    slider:SetValueStep(1)
    slider:SetStepsPerPage(1)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("TOPLEFT", databaseHeader, "BOTTOM", 0, -30)
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
    slider.tooltipText = "Minimum character level stored in the database"
    slider.tooltipOwnerPoint = "ANCHOR_TOP"
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, nil)
    end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Save it
    self.databaseMinLevelSlider = slider

    -- Pseudo-header for alignment
    local rowAligner = CreateFrame("Frame", nil, section)
    rowAligner:SetHeight(1)
    rowAligner:SetWidth(parent:GetWidth() - _SCROLL_BAR_SPACE)
    rowAligner:SetPoint("TOPLEFT", section, "TOPLEFT", 0, -80)

    -- Database prune on load checkbox
    local pruneCheckbox = CreateFrame("CheckButton", "$parent_Database_Prune_On_Load_Checkbox", section,
        "InterfaceOptionsCheckButtonTemplate")
    pruneCheckbox:SetPoint("TOPLEFT", rowAligner, "BOTTOMLEFT", 0, -5)
    pruneCheckbox.Label = _G[pruneCheckbox:GetName() .. "Text"]
    pruneCheckbox.Label:SetText("Auto Prune On Load")
    pruneCheckbox.tooltipText = "Automatically prune old database entries when loaded"
    BlizzardOptionsPanel_RegisterControl(pruneCheckbox, pruneCheckbox:GetParent())
    self.databasePruneOnLoadCheckbox = pruneCheckbox

    -- Database prune now button
    local button = CreateFrame("Button", "$parent_Database_Prune_Now_Button", section, "OptionsButtonTemplate")
    button:SetSize(100, 20)
    button:SetText("Prune Now")
    button:SetPoint("TOPLEFT", pruneCheckbox, "BOTTOMLEFT", 2, -3)
    button:SetScript("OnClick", function(self)
        local pruneDays = Geary_Options_Interface.databasePruneDaysSlider:GetValue()
        Geary_Database:PruneNow(pruneDays)
    end)
    BlizzardOptionsPanel_RegisterControl(button, button:GetParent())
    self.databasePruneNowButton = button

    -- Database days to prune old entries
    local slider = CreateFrame("Slider", "$parent_Database_Prune_Days_Slider", section, "OptionsSliderTemplate")
    slider:SetWidth(190)
    slider:SetHeight(14)
    slider:SetMinMaxValues(1, 180)
    slider:SetValueStep(1)
    slider:SetStepsPerPage(1)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("TOPLEFT", rowAligner, "BOTTOM", 0, -30)
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
    slider.tooltipText = "Database entries this old or older are deleted when pruned"
    slider.tooltipOwnerPoint = "ANCHOR_TOP"
    -- Handlers
    slider:SetScript("OnValueChanged", function(self, value)
        _sliderOnValueChangedFix(self, value, " days")
    end)
    BlizzardOptionsPanel_RegisterControl(slider, slider:GetParent())
    -- Set an initial value (which is never saved in our options)
    slider:SetValue(180)
    -- Save it
    self.databasePruneDaysSlider = slider

    return section
end

function Geary_Options_Interface:_CreateInspectionSection(parent, previousSection)

    -- Section container
    local section = CreateFrame("Frame", "$parent_Inspection_Section", parent)
    section:SetSize(parent:GetWidth() - _SCROLL_BAR_SPACE, 50)
    section:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -10)

    -- Geary inspection header
    local inspectionHeader = self:_CreateHeader(section, "Geary Inspection")
    inspectionHeader:SetWidth(section:GetWidth())
    inspectionHeader:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)

    -- Show MoP legendary quest progress
    local checkbox = CreateFrame("CheckButton", "$parent_Show_Mop_Leg_Progress_Checkbox", section,
        "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", inspectionHeader, "BOTTOMLEFT", 0, -5)
    checkbox.Label = _G[checkbox:GetName() .. "Text"]
    checkbox.Label:SetText("Show MoP Legendary Progress")
    checkbox.tooltipText = "Show Mists of Pandaria legendary cloak quest progress"
    BlizzardOptionsPanel_RegisterControl(checkbox, checkbox:GetParent())
    self.showMopLegProgressCheckbox = checkbox

    return section
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
    self.iconScaleSlider:SetValue(floor(Geary_Options:GetIconScale() * 100))
    self.interfaceScaleSlider:SetValue(floor(Geary_Options:GetInterfaceScale() * 100))
    -- Note: Not sure why, but must initialize before setting a value or we get garbage text
    UIDropDownMenu_Initialize(self.logFontFilenameDropdown, _logFontFilenameDropdownInitialize)
    UIDropDownMenu_SetSelectedID(self.logFontFilenameDropdown,
        _FONT_FILENAMES.byFilename[Geary_Options:GetLogFontFilename()].id)
    self.logFontHeightSlider:SetValue(Geary_Options:GetLogFontHeight())
    self.databaseEnabledCheckbox:SetChecked(Geary_Options:IsDatabaseEnabled())
    self.databaseEntryInTooltipCheckbox:SetChecked(Geary_Options:IsShowDatabaseEntryInTooltips())
    self.databaseMinLevelSlider:SetValue(Geary_Options:GetDatabaseMinLevel())
    self.databasePruneOnLoadCheckbox:SetChecked(Geary_Options:IsDatabasePruneOnLoad())
    self.databasePruneDaysSlider:SetValue(Geary_Options:GetDatabasePruneDays())
    self.showMopLegProgressCheckbox:SetChecked(Geary_Options:GetShowMopLegProgress())
end

function Geary_Options_Interface:OnDefault(frame)
    self.iconShownCheckbox:SetChecked(Geary_Options:GetDefaultIconShown())
    self.iconScaleSlider:SetValue(floor(Geary_Options:GetDefaultIconScale() * 100))
    self.interfaceScaleSlider:SetValue(floor(Geary_Options:GetDefaultInterfaceScale() * 100))
    -- Note: Not sure why, but must initialize before setting a value or we get garbage text
    UIDropDownMenu_Initialize(self.logFontFilenameDropdown, _logFontFilenameDropdownInitialize)
    UIDropDownMenu_SetSelectedID(self.logFontFilenameDropdown,
        _FONT_FILENAMES.byFilename[Geary_Options:GetDefaultLogFontFilename()].id)
    self.logFontHeightSlider:SetValue(Geary_Options:GetDefaultLogFontHeight())
    self.databaseEnabledCheckbox:SetChecked(Geary_Options:GetDefaultDatabaseEnabled())
    self.databaseEntryInTooltipCheckbox:SetChecked(Geary_Options:GetDefaultShowDatabaseEntryInTooltips())
    self.databaseMinLevelSlider:SetValue(Geary_Options:GetDefaultDatabaseMinLevel())
    self.databasePruneOnLoadCheckbox:SetChecked(Geary_Options:GetDefaultDatabasePruneOnLoad())
    self.databasePruneDaysSlider:SetValue(Geary_Options:GetDefaultDatabasePruneDays())
    self.showMopLegProgressCheckbox:SetChecked(Geary_Options:GetDefaultShowMopLegProgress())
end

function Geary_Options_Interface:OnOkay(frame)

    if self.iconShownCheckbox:GetChecked() then
        Geary_Icon:Show()
    else
        Geary_Icon:Hide()
    end
    Geary_Icon:SetScale(self.iconScaleSlider:GetValue() / 100)

    Geary_Interface:SetScale(self.interfaceScaleSlider:GetValue() / 100)
    Geary_Interface_Log:SetFont(_FONT_FILENAMES.byId[UIDropDownMenu_GetSelectedID(self.logFontFilenameDropdown)],
        self.logFontHeightSlider:GetValue())

    if self.databaseEnabledCheckbox:GetChecked() then
        Geary_Database:Enable()
    else
        Geary_Database:Disable()
    end
    if self.databaseEntryInTooltipCheckbox:GetChecked() then
        Geary_Tooltip:Enable()
    else
        Geary_Tooltip:Disable()
    end
    Geary_Database:SetMinLevel(self.databaseMinLevelSlider:GetValue())
    Geary_Database:SetPruneOnLoad(self.databasePruneOnLoadCheckbox:GetChecked() and true or false)
    Geary_Database:SetPruneDays(self.databasePruneDaysSlider:GetValue())

    Geary_Options:SetShowMopLegProgress(self.showMopLegProgressCheckbox:GetChecked() and true or false)
end
