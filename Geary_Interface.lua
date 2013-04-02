--[[
	Geary main interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface = {
	mainFrame = nil,
	contentFrame = nil,
	tabs = {
		byId = {},
		byName = {},
		count = 0
	}
}

function Geary_Interface:init()

	-- Create the main interface elements
	self:_createMainFrame()
	self:_createContentFrame(self.mainFrame)

	-- Init interface tab modules
	Geary_Interface_Player:init(self.contentFrame)
	Geary_Interface_Group:init(self.contentFrame)
	Geary_Interface_Database:init(self.contentFrame)
	Geary_Interface_Log:init(self.contentFrame)

	-- Tabs created, so initialize their state and select initial tab
	PanelTemplates_SetNumTabs(self.mainFrame, self.tabs.count)
    self.mainFrame.selectedTab = self.tabs.byName["Player"]
    PanelTemplates_UpdateTabs(self.mainFrame)
	self:_tabOnClick(self.mainFrame.selectedTab)
end

function Geary_Interface:_createMainFrame()

	local frame = CreateFrame("Frame", "Geary_Ui_Main", UIParent)
	frame:Hide()
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetResizable(false)
	frame:SetToplevel(true)
	frame:SetSize(507, 330)    -- 66% smaller than AchievementFrame
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:SetBackdrop({
		bgFile   = "Interface\\AchievementFrame\\UI-Achievement-StatsBackground",
		edgeFile = "Interface\\AchievementFrame\\UI-Achievement-WoodBorder",
		tile     = false,
		edgeSize = 64,
		insets   = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame:SetBackdropColor(0.33, 0.33, 0.33, 1)
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetScript("OnHide", function (self)
		PlaySound("AchievementMenuClose")
		self:StopMovingOrSizing()
	end)
	self.mainFrame = frame
	
	local texture
	texture = frame:CreateTexture("$parent_Metal_Border_Left", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Left")
	texture:SetSize(11, 288)
	texture:SetPoint("LEFT", 17, 0)
	texture:SetTexCoord(0, 1, 0, 0.87)

	texture = frame:CreateTexture("$parent_Metal_Border_Right", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Left")
	texture:SetSize(11, 288)
	texture:SetPoint("RIGHT", -12, 0)
	texture:SetTexCoord(0, 1, 0.87, 0)

	texture = frame:CreateTexture("$parent_Metal_Border_Bottom", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Top")
	texture:SetSize(297, 11)
	texture:SetPoint("BOTTOMLEFT", 28, 19)
	texture:SetPoint("BOTTOMRIGHT", -28, 19)
	texture:SetTexCoord(0, 0.87, 1, 0)

	texture = frame:CreateTexture("$parent_Metal_Border_Top", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Top")
	texture:SetSize(297, 11)
	texture:SetPoint("TOPLEFT", 28, -11)
	texture:SetPoint("TOPRIGHT", -28, -11)
	texture:SetTexCoord(0, 0.87, 1, 0)

	texture = frame:CreateTexture("$parent_Metal_Border_Top_Left", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	texture:SetDrawLayer("ARTWORK", 1)  -- On top of horiz/vert borders
	texture:SetSize(24, 24)
	texture:SetPoint("TOPLEFT", 13, -12)
	texture:SetTexCoord(1, 0, 1, 0)

	texture = frame:CreateTexture("$parent_Metal_Border_Top_Right", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	texture:SetDrawLayer("ARTWORK", 1)  -- On top of horiz/vert borders
	texture:SetSize(24, 24)
	texture:SetPoint("TOPRIGHT", -14, -12)
	texture:SetTexCoord(0, 1, 1, 0)

	texture = frame:CreateTexture("$parent_Metal_Border_Bottom_Left", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	texture:SetDrawLayer("ARTWORK", 1)  -- On top of horiz/vert borders
	texture:SetSize(24, 24)
	texture:SetPoint("BOTTOMLEFT", 13, 15)
	texture:SetTexCoord(1, 0, 0, 1)

	texture = frame:CreateTexture("$parent_Metal_Border_Bottom_Right", "ARTWORK")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-MetalBorder-Joint")
	texture:SetDrawLayer("ARTWORK", 1)  -- On top of horiz/vert borders
	texture:SetSize(24, 24)
	texture:SetPoint("BOTTOMRIGHT", -13, 15)
	texture:SetTexCoord(0, 1, 0, 1)

	texture = frame:CreateTexture("$parent_Wood_Border_Top_Left", "OVERLAY")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	texture:SetSize(64, 64)
	texture:SetPoint("TOPLEFT", 4, -2)
	texture:SetTexCoord(0, 1, 0, 1)

	texture = frame:CreateTexture("$parent_Wood_Border_Top_Right", "OVERLAY")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	texture:SetSize(64, 64)
	texture:SetPoint("TOPRIGHT", -4, -2)
	texture:SetTexCoord(1, 0, 0, 1)

	texture = frame:CreateTexture("$parent_Wood_Border_Bottom_Left", "OVERLAY")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	texture:SetSize(64, 64)
	texture:SetPoint("BOTTOMLEFT", 4, 3)
	texture:SetTexCoord(0, 1, 1, 0)

	texture = frame:CreateTexture("$parent_Wood_Border_Bottom_Right", "OVERLAY")
	texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-WoodBorder-Corner")
	texture:SetSize(64, 64)
	texture:SetPoint("BOTTOMRIGHT", -4, 3)
	texture:SetTexCoord(1, 0, 1, 0)

	local fontString = frame:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
	fontString:SetText(Geary.title .. " v" .. Geary.version)
	fontString:SetPoint("TOP", self.mainFrame, "TOP", 0, -4)
	
	local button = CreateFrame("Button", "$parent_Close_Button", self.mainFrame, "UIPanelCloseButton")
	button:SetPoint("TOPRIGHT", self.mainFrame, "TOPRIGHT", 3, 4)
	button:SetScript("OnClick", function (self)	HideParentPanel(self) end)
end

function Geary_Interface:_createContentFrame(parent)
	local frame = CreateFrame("Frame", "$parent_Content", parent)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 22, -21)
	frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -22, 24)
	self.contentFrame = frame
end

-- NOTE: AchievementFrameTabButtonTemplate is defined in the Blizzard_AchievementUI AddOn
-- NOTE: which must be loaded before we can use the template. This is done via a TOC dependency.
function Geary_Interface:createTab(tabName, showFunc, hideFunc)

	-- Create it
	local tabId = self.tabs.count + 1
	local tab = CreateFrame("Button", "$parentTab" .. tabId, self.mainFrame,
		"AchievementFrameTabButtonTemplate")
	tab:SetID(tabId)
	tab:SetText(tabName)
	if tabId == 1 then
		tab:SetPoint("BOTTOMLEFT", 11, -30)
	else
		tab:SetPoint("LEFT", _G[self.mainFrame:GetName() .. "Tab" .. (tabId - 1)], "RIGHT", -5, 0)
	end
	tab:SetScript("OnClick", function (self)
		PlaySound("igCharacterInfoTab")
		Geary_Interface:_tabOnClick(self:GetID())
	end)
	
	-- Store tab data
	self.tabs.byId[tabId] = {
		name = tabName,
		show = showFunc,
		hide = hideFunc
	}
	self.tabs.byName[tabName] = tabId
	self.tabs.count = tabId
end

function Geary_Interface:selectTab(tabName)
	if self.tabs.byName[tabName] == nil then
		Geary:print(Geary.CC_ERROR .. "Cannot find tab '" .. tabName .. "'" .. Geary.CC_END)
	else
		self:_tabOnClick(self.tabs.byName[tabName])
	end
end

function Geary_Interface:_tabOnClick(clickedTabId)

	-- Update tabs to show which is selected
	local mainFrameName = self.mainFrame:GetName()
    PanelTemplates_Tab_OnClick(_G[mainFrameName .. "Tab" .. clickedTabId], self.mainFrame)
    for tabId = 1, #self.tabs do
        _G[mainFrameName .. "Tab" .. tabId].text:SetPoint("CENTER", 0, tabId == clickedTabId and -5 or -3)
    end

	-- Update contents to display the selected tab
	for tabId, tabData in ipairs(self.tabs.byId) do
		if tabId == clickedTabId then
			tabData.show()
		else
			tabData.hide()
		end
	end
end

function Geary_Interface:Show()
	self.mainFrame:Show()
end

function Geary_Interface:Hide()
	self.mainFrame:Hide()
end

function Geary_Interface:toggle()
	if (self.mainFrame:IsShown()) then
		self:Hide()
	else
		self:Show()
	end
end