--[[

--]]

Geary_Interface_Icon = {
	button = nil
}

function Geary_Interface_Icon:init()
	local button = CreateFrame("Button", "Geary_Ui_Icon_Button", UIParent)
	button:SetMovable(true)
	button:SetClampedToScreen(true)
	button:SetResizable(false)
	button:SetSize(70, 70)
	button:SetScale(Geary_Options:getIconScale())
	button:SetPoint("CENTER", UIParent, "CENTER")
	button:SetBackdrop({
		bgFile   = [[Interface\ICONS\Spell_Magic_PolymorphRabbit.png]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile     = false,
		tileSize = 32,
		edgeSize = 32,
		insets   = { left = 6, right = 6, top = 6, bottom = 6 }
	})
	-- TODO Use one of these to highlight on click down and remove on click up
	-- Interface/BUTTONS/ButtonHilight-Square.png
	-- Interface/BUTTONS/CheckButtonHilight.png
	button:EnableMouse(true)
	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", button.StartMoving)
	button:SetScript("OnDragStop", button.StopMovingOrSizing)
	button:SetScript("OnHide", button.StopMovingOrSizing)
	button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	button:SetScript("OnClick", function (self) Geary_Interface_Icon:OnClick(self) end)
	if Geary_Options:isIconShown() then
		button:Show()
	else
		button:Hide()
	end
	self.button = button
end

function Geary_Interface_Icon:OnClick(button)
	if SecureCmdOptionParse("[btn:2]") then
		Geary_Inspect:inspectPlayer()
	else
		Geary_Inspect:inspectTarget()
	end
end

function Geary_Interface_Icon:Show()
	self.button:Show()
	Geary_Options:setIconShown()
end

function Geary_Interface_Icon:Hide()
	self.button:Hide()
	Geary_Options:setIconHidden()
end

function Geary_Interface_Icon:toggle()
	if (self.button:IsShown()) then
		self:Hide()
	else
		self:Show()
	end
end