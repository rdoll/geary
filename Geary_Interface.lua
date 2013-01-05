--[[
	Geary main interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface = {
	mainFrame = nil
}

function Geary_Interface:init()

	-- Create the interface elements
	self:_createMainFrame()
	self:_createHeader()
	self:_createClearButton()
	self:_createCloseButton()
	
	-- Init interface tab modules
	Geary_Interface_Player:init()
	Geary_Interface_Group:init()
	Geary_Interface_Database:init()
	Geary_Interface_Log:init()
	
	-- Init integrated options
	Geary_Interface_Options:init()
	
	-- Init the main icon button
	Geary_Interface_Icon:init()
end

function Geary_Interface:_createMainFrame()
	local frame = CreateFrame("Frame", "Geary_Ui_Main", UIParent)
	frame:Hide()
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetResizable(false)
	frame:SetSize(470, 300)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:SetBackdrop({
		bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile     = true,
		tileSize = 32,
		edgeSize = 32,
		insets   = { left = 8, right = 8, top = 8, bottom = 8 }
	})
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetScript("OnHide", frame.StopMovingOrSizing)
	self.mainFrame = frame
end

function Geary_Interface:_createHeader()
	local texture = self.mainFrame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	texture:SetSize(350, 50)
	texture:SetPoint("TOP", self.mainFrame, "TOP", 0, 12)
	local fontString = self.mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontString:SetPoint("TOP", texture, "TOP", 0, -10)
	fontString:SetText(Geary.title .. " v" .. Geary.version)
end

function Geary_Interface:_createClearButton()
	local button = CreateFrame("Button", nil, self.mainFrame, "OptionsButtonTemplate")
	button:SetPoint("BOTTOM", -60, 15)
	button:SetText("Clear")
	button:SetScript("OnClick", function (self)	Geary_Interface_Log:Clear() end)
end

function Geary_Interface:_createCloseButton()
	local button = CreateFrame("Button", nil, self.mainFrame, "OptionsButtonTemplate")
	button:SetPoint("BOTTOM", 60, 15)
	button:SetText(CLOSE)
	button:SetScript("OnClick", function (self)	HideParentPanel(self) end)
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