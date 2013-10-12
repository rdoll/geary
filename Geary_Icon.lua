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

function Geary_Icon:init()
    local button = CreateFrame("Button", "Geary_Ui_Icon_Button", UIParent)
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:SetResizable(false)
    button:SetSize(70, 70)
    button:SetScale(Geary_Options:getIconScale())
    button:SetPoint("CENTER", UIParent, "CENTER")
    button:SetBackdrop({
        bgFile   = "Interface\\ICONS\\INV_Misc_EngGizmos_30.png",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
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
    button:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "RightButtonUp",
        "Button4Up", "Button5Up")
    button:SetScript("OnClick", function(self, mouseButton, down) Geary_Icon:OnClick(mouseButton, down) end)
    if Geary_Options:isIconShown() then
        button:Show()
    else
        button:Hide()
    end
    self.button = button
end

function Geary_Icon:OnClick(mouseButton, down)
    if mouseButton == "LeftButton" then
        Geary_Inspect:InspectTarget()
    elseif mouseButton == "MiddleButton" then
        Geary_Interface:toggle()
    elseif mouseButton == "RightButton" then
        Geary_Inspect:InspectSelf()
    elseif mouseButton == "Button4" or mouseButton == "Button5" then
        Geary_Options_Interface:toggle()
    end
end

function Geary_Icon:Show()
    self.button:Show()
    Geary_Options:setIconShown()
end

function Geary_Icon:Hide()
    self.button:Hide()
    Geary_Options:setIconHidden()
end

function Geary_Icon:toggle()
    if (self.button:IsShown()) then
        self:Hide()
    else
        self:Show()
    end
end

function Geary_Icon:setScale(scale)
    self.button:SetScale(scale)
    Geary_Options:setIconScale(scale)
end