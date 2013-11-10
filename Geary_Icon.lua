--[[
    Geary icon manager

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Icon = {
    button = nil
}

function Geary_Icon:Init()
    self.button = self:_CreateButton()
    self:_CreateCooldown(self.button)
end

function Geary_Icon:_CreateButton()
    local button = CreateFrame("Button", "Geary_Ui_Icon_Button", UIParent)
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:SetResizable(false)
    button:SetSize(70, 70)
    button:SetScale(Geary_Options:GetIconScale())
    button:SetPoint("CENTER", UIParent, "CENTER")
    button:SetBackdrop({
        bgFile   = "Interface\\ICONS\\INV_Misc_EngGizmos_30.png",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = false,
        tileSize = 32,
        edgeSize = 32,
        insets   = { left = 6, right = 6, top = 6, bottom = 6 }
    })
    button:SetHighlightTexture("Interface\\BUTTONS\\ButtonHilight-Square.png", "ADD")
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", button.StartMoving)
    button:SetScript("OnDragStop", button.StopMovingOrSizing)
    button:SetScript("OnHide", button.StopMovingOrSizing)
    button:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "RightButtonUp", "Button4Up", "Button5Up")
    button:SetScript("OnClick", function(self, mouseButton, down) Geary_Icon:OnClick(mouseButton, down) end)

    if Geary_Options:IsIconShown() then
        button:Show()
    else
        button:Hide()
    end

    return button
end

function Geary_Icon:_CreateCooldown(button)
    button.cooldown = CreateFrame("Cooldown", button:GetName() .. "_Cooldown", button)
    button.cooldown:SetAllPoints(button:GetName())
end

function Geary_Icon:OnClick(mouseButton, down)
    if mouseButton == "LeftButton" then
        Geary_Inspect:InspectTarget()
    elseif mouseButton == "MiddleButton" then
        Geary_Interface:Toggle()
    elseif mouseButton == "RightButton" then
        Geary_Inspect:InspectSelf()
    elseif mouseButton == "Button4" or mouseButton == "Button5" then
        Geary_Options_Interface:Toggle()
    end
end

function Geary_Icon:Show()
    self.button:Show()
    Geary_Options:SetIconShown(true)
end

function Geary_Icon:Hide()
    self.button:Hide()
    Geary_Options:SetIconShown(false)
end

function Geary_Icon:Toggle()
    if (self.button:IsShown()) then
        self:Hide()
    else
        self:Show()
    end
end

function Geary_Icon:SetScale(scale)
    self.button:SetScale(scale)
    Geary_Options:SetIconScale(scale)
end

function Geary_Icon:StartBusy(duration)
    self.button.cooldown:SetCooldown(GetTime(), duration)
end

function Geary_Icon:StopBusy()
    self.button.cooldown:SetCooldown(0, 0)
end
