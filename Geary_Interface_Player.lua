--[[
    Geary player interface

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Player = {
    mainFrame = nil,
    summary   = nil,
    paperDoll = {
        frame     = nil,
        model     = nil,
        hasPlayer = false,
        slots     = {
            HeadSlot          = { side = "left",  frame = nil, icon = nil, info = nil, item = nil },
            NeckSlot          = { side = "left",  frame = nil, icon = nil, info = nil, item = nil },
            ShoulderSlot      = { side = "left",  frame = nil, icon = nil, info = nil, item = nil },
            BackSlot          = { side = "left",  frame = nil, icon = nil, info = nil, item = nil },
            ChestSlot         = { side = "left",  frame = nil, icon = nil, info = nil, item = nil },
            WristSlot         = { side = "left",  frame = nil, icon = nil, info = nil, item = nil },
            HandsSlot         = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            WaistSlot         = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            LegsSlot          = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            FeetSlot          = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            Finger0Slot       = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            Finger1Slot       = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            Trinket0Slot      = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            Trinket1Slot      = { side = "right", frame = nil, icon = nil, info = nil, item = nil },
            MainHandSlot      = { side = "left",  frame = nil, icon = nil, info = nil, item = nil },
            SecondaryHandSlot = { side = "left",  frame = nil, icon = nil, info = nil, item = nil }
        }
    }
}

function Geary_Interface_Player:Init(parent)

    local frame = CreateFrame("Frame", "$parent_Frame", parent)
    frame:Hide()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT")
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT")
    self.mainFrame = frame

    local fontString = self.mainFrame:CreateFontString("$parent_UnavailFontString", "ARTWORK", "GameFontNormal")
    fontString:Hide()
    fontString:SetPoint("CENTER", self.mainFrame, "CENTER")
    fontString:SetText("No inspection details available")
    frame.unavailFontString = fontString

    self:_InitPaperDoll(self.mainFrame)
    self:_InitSummary(self.mainFrame, self.paperDoll.frame)

    Geary_Interface:CreateTab("Player",
        function() Geary_Interface_Player:Show() end,
        function() Geary_Interface_Player:Hide() end)
end

function Geary_Interface_Player:_InitPaperDoll(parent)
    local frame = CreateFrame("Frame", "$parent_PaperDollFrame", parent)
    frame:Hide()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT")
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -186, 0)
    self.paperDoll.frame = frame

    self:_InitModel(self.paperDoll.frame)
    self:_InitSlots(self.paperDoll.frame)
end

function Geary_Interface_Player:_InitModel(parent)

    -- Scale the model widths and heights which were pulled from the PaperDollFrame
    local scale = 0.8888

    -- TODO Add border esp on RHS?
    local model = CreateFrame("PlayerModel", "$parent_Model", parent, "ModelWithControlsTemplate")
    model:SetSize(231 * scale, 320 * scale)
    model:SetPoint("TOPLEFT", 36, 0)

    local bgTopLeft = model:CreateTexture("$parent_BackgroundTopLeft", "BACKGROUND")
    bgTopLeft:SetSize(212 * scale, 245 * scale)
    bgTopLeft:SetPoint("TOPLEFT", 0, 0)
    bgTopLeft:SetTexCoord(0.171875, 1, 0.0392156862745098, 1)
    model.BackgroundTopLeft = bgTopLeft

    local bgTopRight = model:CreateTexture("$parent_BackgroundTopRight", "BACKGROUND")
    bgTopRight:SetSize(19 * scale, 245 * scale)
    bgTopRight:SetPoint("TOPLEFT", bgTopLeft, "TOPRIGHT")
    bgTopRight:SetTexCoord(0, 0.296875, 0.0392156862745098, 1)
    model.BackgroundTopRight = bgTopRight

    local bgBotLeft = model:CreateTexture("$parent_BackgroundBotLeft", "BACKGROUND")
    bgBotLeft:SetSize(212 * scale, 128 * scale)
    bgBotLeft:SetPoint("TOPLEFT", bgTopLeft, "BOTTOMLEFT")
    bgBotLeft:SetTexCoord(0.171875, 1, 0, 1)
    model.BackgroundBotLeft = bgBotLeft

    local bgBotRight = model:CreateTexture("$parent_BackgroundBotRight", "BACKGROUND")
    bgBotRight:SetSize(19 * scale, 128 * scale)
    bgBotRight:SetPoint("TOPLEFT", bgTopLeft, "BOTTOMRIGHT")
    bgBotRight:SetTexCoord(0, 0.296875, 0, 1)
    model.BackgroundBotRight = bgBotRight

    local bgOverlay = model:CreateTexture("$parent_BackgroundOverlay", "BORDER")
    bgOverlay:SetPoint("TOPLEFT", bgTopLeft)
    bgOverlay:SetPoint("BOTTOMRIGHT", bgBotRight, 0 * scale, 52 * scale)
    bgOverlay:SetTexture(0, 0, 0)
    model.BackgroundOverlay = bgOverlay

    Model_OnLoad(model, MODELFRAME_MAX_PLAYER_ZOOM, nil, nil, function(self, button) Model_OnMouseUp(self, button) end)

    self.paperDoll.model = model
end

function Geary_Interface_Player:_InitSlots(parent)

    local lastLeft, lastRight
    for _, slotName in ipairs(Geary_Item:GetInvSlotsInOrder()) do

        local frame = CreateFrame("Frame", "$parent_" .. slotName .. "_Frame", parent)
        frame.emptyTooltip = _G[slotName:upper()]
        frame.paperDollSide = self.paperDoll.slots[slotName].side
        frame.slotData = self.paperDoll.slots[slotName]
        frame:SetSize(37, 37)
        frame:SetBackdrop({
            bgFile = _G["Character" .. slotName .. "IconTexture"]:GetTexture(),
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })

        local icon = frame:CreateTexture("$parent_Icon", "ARTWORK")
        icon:Hide()
        icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -3)
        icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)
        self.paperDoll.slots[slotName].icon = icon

        local info = CreateFrame("Frame", "$parent_" .. slotName .. "_Info", parent)
        info:SetWidth(46)
        info:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tile = true,
            tileSize = 64,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        info:SetBackdropColor(0, 0, 0, 0) -- Default to no background
        info:SetFrameStrata("MEDIUM")
        info:SetFrameLevel(127) -- Might need to set this to self.paperDoll.model + x when shown
        info.side = self.paperDoll.slots[slotName].side
        info.tooltip = slotName

        info.fontString = info:CreateFontString("$parent_FontString", "OVERLAY")
        -- TODO Allow font to be configured via options
        info.fontString:SetFont("Fonts\\FRIZQT__.TTF", 10)
        info.fontString:SetJustifyV("TOP")
        info.fontString:SetPoint("TOPLEFT", info, "TOPLEFT", 0, -3)
        info.fontString:SetPoint("TOPRIGHT", info, "TOPRIGHT", 0, -3)
        info.fontString:SetHeight(10)

        info.enchantTexture = info:CreateTexture("$parent_Enchant_Texture", "OVERLAY")
        info.enchantTexture:SetSize(10, 10)

        info.gemTextures = {}
        for gemIndex = 1, Geary_Item.MAX_GEMS do
            info.gemTextures[gemIndex] = info:CreateTexture("$parent_Gem_Texture_" .. gemIndex, "OVERLAY")
            info.gemTextures[gemIndex]:SetSize(10, 10)
        end

        if self.paperDoll.slots[slotName].side == "left" then
            if lastLeft then
                frame:SetPoint("TOPLEFT", lastLeft, "BOTTOMLEFT", 0, 2)
            else
                frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -2)
            end
            lastLeft = frame

            info:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0)
            info:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 0, 2)

            info.fontString:SetJustifyH("LEFT")

            info.enchantTexture:SetPoint("TOPLEFT", info.fontString, "BOTTOMLEFT", 0, -1)

            info.gemTextures[1]:SetPoint("TOPLEFT", info.enchantTexture, "BOTTOMLEFT", 0, -1)
            info.gemTextures[2]:SetPoint("LEFT", info.gemTextures[1], "RIGHT", 2, 0)
            info.gemTextures[3]:SetPoint("LEFT", info.gemTextures[2], "RIGHT", 2, 0)
            info.gemTextures[4]:SetPoint("LEFT", info.gemTextures[3], "RIGHT", 2, 0)
        elseif self.paperDoll.slots[slotName].side == "right" then
            if lastRight then
                frame:SetPoint("TOPRIGHT", lastRight, "BOTTOMRIGHT", 0, 2)
            else
                frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -2)
            end
            lastRight = frame

            info:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, 0)
            info:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, 2)

            info.fontString:SetJustifyH("RIGHT")

            info.enchantTexture:SetPoint("TOPRIGHT", info.fontString, "BOTTOMRIGHT", 0, -1)

            info.gemTextures[1]:SetPoint("TOPRIGHT", info.enchantTexture, "BOTTOMRIGHT", 0, -1)
            info.gemTextures[2]:SetPoint("RIGHT", info.gemTextures[1], "LEFT", -2, 0)
            info.gemTextures[3]:SetPoint("RIGHT", info.gemTextures[2], "LEFT", -2, 0)
            info.gemTextures[4]:SetPoint("RIGHT", info.gemTextures[3], "LEFT", -2, 0)
        end

        info:SetScript("OnEnter", function(self)
            -- TODO Allow setting the font type/size via options
            if self.tooltip ~= nil then
                if self.side == "left" then
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
                elseif self.side == "right" then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
                else
                    Geary:Print(Geary.CC_ERROR .. "Unknown info side '" .. tostring(self.side) .. "'" .. Geary.CC_END)
                end
                GameTooltip:SetText(self.tooltip)
            end
        end)
        info:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        self.paperDoll.slots[slotName].info = info

        -- When hovering over a slot, change cursor when dressing room modifer key is pressed/released
        frame:RegisterEvent("MODIFIER_STATE_CHANGED")
        frame:SetScript("OnEvent", function(self, event, ...)
            if event == "MODIFIER_STATE_CHANGED" then
                if self:IsMouseOver() then
                    if IsModifiedClick("DRESSUP") and self.slotData.item ~= nil then
                        ShowInspectCursor()
                    else
                        ResetCursor()
                    end
                end
            end
        end)

        -- When entering a slot, show item tooltip (if any) and set dressing room or regular cursor
        frame:SetScript("OnEnter", function(self)
            -- Anchor the tooltip to the left or right of the icon so it doesn't cover the paper doll
            if self.paperDollSide == "left" then
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, self:GetHeight())
            elseif self.paperDollSide == "right" then
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, self:GetHeight())
            else
                Geary:Print(Geary.CC_ERROR .. "Unknown paperDollSide '" .. tostring(self.paperDollSide) .. "'" .. Geary.CC_END)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            end
            ResetCursor() -- Default to normal cursor
            if self.slotData.item == nil then
                GameTooltip:SetText(self.emptyTooltip)
            else
                GameTooltip:SetHyperlink(self.slotData.item.link)
                -- If dressing room modifier is held down, show dressing room cursor
                if (IsModifiedClick("DRESSUP")) then
                    ShowInspectCursor()
                end
            end
            GameTooltip:Show()
        end)

        -- When leaving a slot, reset everything
        frame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            ResetCursor()
        end)

        -- When a slot with an item is clicked, handle as the character frame does
        frame:SetScript("OnMouseDown", function(self)
            if self.slotData.item ~= nil then
                HandleModifiedItemClick(self.slotData.item.link)
            end
        end)

        self.paperDoll.slots[slotName].frame = frame
    end
end

function Geary_Interface_Player:_InitSummary(parent, paperDollFrame)

    local frame = CreateFrame("Frame", "$parent_Summary", parent)
    frame:Hide()
    frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, -4)
    frame:SetPoint("BOTTOMLEFT", paperDollFrame, "BOTTOMRIGHT", 4, 4)

    local fontString = frame:CreateFontString("$parent_PlayerFontString", "ARTWORK")
    fontString:SetFont("Fonts\\FRIZQT__.TTF", 10)
    fontString:SetJustifyV("TOP")
    fontString:SetJustifyH("CENTER")
    fontString:SetPoint("TOPLEFT", frame, "TOPLEFT")
    fontString:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -55)
    frame.playerFontString = fontString

    local editBox = CreateFrame("EditBox", "$parent_StatsEditBox", frame)
    editBox:SetFont("Fonts\\FRIZQT__.TTF", 10)
    editBox:SetPoint("TOPLEFT", frame.playerFontString, "BOTTOMLEFT", 10, 0)
    editBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    editBox:SetMultiLine(true)
    editBox:SetIndentedWordWrap(false)
    editBox:SetAutoFocus(false)
    editBox:EnableMouse(true)
    editBox:EnableMouseWheel(false)
    editBox:SetHyperlinksEnabled(true)
    editBox:Disable()
    editBox:SetScript("OnHyperlinkClick", function(self, link, text, button)
        SetItemRef(link, text, button)
    end)
    editBox:SetScript("OnHyperlinkEnter", function(self, link, text)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    editBox:SetScript("OnHyperlinkLeave", function(self, link, text)
        GameTooltip:Hide()
    end)
    frame.statsEditBox = editBox

    self.summary = frame
end

function Geary_Interface_Player:Clear()

    self.paperDoll.hasPlayer = false
    self.paperDoll.model:ClearModel()
    self.summary.playerFontString:SetText("")
    self.summary.statsEditBox:SetText("")

    for slotName, slotData in pairs(self.paperDoll.slots) do
        slotData.item = nil
        slotData.info:SetBackdropColor(0, 0, 0, 0)
        slotData.info.tooltip = nil
        slotData.info.fontString:SetText("")
        slotData.info.enchantTexture:SetTexture(0, 0, 0, 0)
        for gemIndex = 1, Geary_Item.MAX_GEMS do
            slotData.info.gemTextures[gemIndex]:SetTexture(0, 0, 0, 0)
        end
        slotData.icon:Hide()
        self:_SetItemBorder(slotName, nil)
    end

    if self.mainFrame:IsVisible() then
        self:Show()
    end
end

function Geary_Interface_Player:_SetPlayerSummaryText(inspect)
    self.summary.playerFontString:SetFormattedText("\n" ..
        "%s %s\n" .. -- Player name and faction
        "%i %s %s\n", -- Level, class, and spec
        inspect.player:GetFactionInlineIcon(), inspect.player:GetFullNameLink(),
        inspect.player.level, inspect.player:GetColorizedClassName(), inspect.player:GetSpecWithInlineIcon())
end

function Geary_Interface_Player:InspectionStart(inspect)

    self.paperDoll.hasPlayer = true

    SetPaperDollBackground(self.paperDoll.model, inspect.player.unit)
    self.paperDoll.model:SetUnit(inspect.player.unit)

    self:_SetPlayerSummaryText(inspect)
    self.summary.statsEditBox:SetText("         Inspection try #" .. inspect.inspectTry .. "...")

    if self.mainFrame:IsVisible() then
        self:Show()
    end
end

function Geary_Interface_Player:InspectionFailed(inspect)
    self:_MarkMissingItems(inspect)
    self:_SetPlayerSummaryText(inspect)
    self.summary.statsEditBox:SetText(Geary.CC_FAILED .. "          Inspection failed" .. Geary.CC_END)
end

function Geary_Interface_Player:InspectionEnd(inspect)

    self:_SetPlayerSummaryText(inspect)
    self:_MarkMissingItems(inspect)

    -- TODO This is duplicated work from Geary_Inspect using private data

    local itemColor, itemCounts, itemTwoHand
    itemColor = (inspect.emptySlots > 0 or inspect.failedSlots > 0) and Geary.CC_MISSING or Geary.CC_CORRECT
    itemCounts = inspect.filledSlots .. "/" .. inspect.itemCount
    itemTwoHand = inspect.hasTwoHandWeapon and (inspect.player:HasTitansGrip() and " (TG)" or " (2H)") or ""

    local upgradeColor, upgradeCounts = Geary.CC_NA, "-"
    if inspect.upgradeMax > 0 then
        upgradeColor = inspect.upgradeItemLevelMissing > 0 and Geary.CC_UPGRADE or Geary.CC_CORRECT
        upgradeCounts = inspect.upgradeLevel .. "/" .. inspect.upgradeMax
    end

    local enchantColor, enchantCounts = Geary.CC_NA, "-"
    if inspect.enchantedCount > 0 or inspect.unenchantedCount > 0 then
        enchantColor = inspect.unenchantedCount > 0 and Geary.CC_MISSING or Geary.CC_CORRECT
        enchantCounts = inspect.enchantedCount .. "/" .. (inspect.enchantedCount + inspect.unenchantedCount)
    end

    local beltColor, beltString
    if inspect.isMissingBeltBuckle then
        beltColor = Geary.CC_MISSING
        beltString = "No"
    else
        beltColor = Geary.CC_CORRECT
        beltString = "Yes"
    end

    local gemColor, gemCounts = Geary.CC_NA, "-"
    if inspect.emptySockets > 0 or inspect.failedJewelIds > 0 or inspect.filledSockets > 0 then
        gemColor = (inspect.emptySockets > 0 or inspect.failedJewelIds > 0) and Geary.CC_MISSING or Geary.CC_CORRECT
        gemCounts = inspect.filledSockets .. "/" .. (inspect.filledSockets + inspect.emptySockets + inspect.failedJewelIds)
    end

    local eotbpColor, eotbpCounts = Geary.CC_NA, "-"
    if Geary_Options:GetShowMopLegProgress() then
        if inspect.eotbpFilled > 0 or inspect.eotbpMissing > 0 then
            eotbpColor = inspect.eotbpMissing > 0 and Geary.CC_OPTIONAL or Geary.CC_CORRECT
            eotbpCounts = inspect.eotbpFilled .. "/" .. (inspect.eotbpFilled + inspect.eotbpMissing)
        end
    end

    local cohColor, cohString = Geary.CC_NA, "-"
    if Geary_Options:GetShowMopLegProgress() then
        if inspect.hasCohMeta or inspect.isMissingCohMeta then
            if inspect.hasCohMeta then
                cohColor = Geary.CC_CORRECT
                cohString = "Yes"
            else
                cohColor = Geary.CC_OPTIONAL
                cohString = "No"
            end
        end
    end

    local covColor, covString = Geary.CC_NA, "-"
    local legCloakColor, legCloakString = Geary.CC_NA, "-"
    if Geary_Options:GetShowMopLegProgress() then
        if inspect.hasCov or inspect.isMissingCov then
            -- Has or is missing CoV, so leg cloak is n/a
            if inspect.hasCov then
                covColor = Geary.CC_CORRECT
                covString = "Yes"
            else
                covColor = Geary.CC_OPTIONAL
                covString = "No"
            end
        elseif inspect.hasLegCloak or inspect.isMissingLegCloak then
            -- Does not have CoV, but has or is missing leg cloak
            if inspect.hasLegCloak then
                legCloakColor = Geary.CC_CORRECT
                legCloakString = "Yes"
            else
                legCloakColor = Geary.CC_OPTIONAL
                legCloakString = "No"
            end
        end
    end

    local upgradedColor, upgradedILevel = Geary.CC_NA, "-"
    if inspect.upgradeItemLevelMissing > 0 then
        upgradedColor = Geary.CC_UPGRADE
        upgradedILevel = ("%.2f"):format((inspect.iLevelTotal + inspect.upgradeItemLevelMissing) / inspect.itemCount)
    end

    local milestoneLevel, milestoneName = inspect:GetItemLevelMilestone()
    local milestoneColor, milestoneString = Geary.CC_NA, "-"
    if milestoneLevel ~= nil then
        milestoneColor = Geary.CC_MILESTONE
        milestoneString = milestoneLevel .. " to " .. milestoneName
    end

    local minItemColor, minItemString = Geary.CC_NA, "-"
    if inspect.minItem ~= nil then
        minItemColor = ""
        minItemString = inspect.minItem.link:gsub("[|]h.-[|]h",
            "|h" .. inspect.minItem:ILevelWithUpgrades() .. " " .. inspect.minItem.inlineTexture .. "|h")
    end

    local maxItemColor, maxItemString = Geary.CC_NA, "-"
    if inspect.maxItem ~= nil then
        maxItemColor = ""
        maxItemString = inspect.maxItem.link:gsub("[|]h.-[|]h",
            "|h" .. inspect.maxItem:ILevelWithUpgrades() .. " " .. inspect.maxItem.inlineTexture .. "|h")
    end

    local mopLegProgress = ""
    if Geary_Options:GetShowMopLegProgress() then
        mopLegProgress =
            eotbpColor .. "EotBP: " .. eotbpCounts .. Geary.CC_END .. "\n" ..
            cohColor .. "CoH Meta: " .. cohString .. Geary.CC_END .. "\n" ..
            covColor .. "CoV: " .. covString .. Geary.CC_END .. "\n" ..
            legCloakColor .. "Leg Cloak: " .. legCloakString .. Geary.CC_END .. "\n"
    end

    self.summary.statsEditBox:SetText(
        itemColor .. "Items: " .. itemCounts .. itemTwoHand .. Geary.CC_END .. "\n" ..
        upgradeColor .. "Upgrades: " .. upgradeCounts .. Geary.CC_END .. "\n" ..
        "\n" ..
        enchantColor .. "Enchants: " .. enchantCounts .. Geary.CC_END .. "\n" ..
        beltColor .. "Belt Buckle: " .. beltString .. Geary.CC_END .. "\n" ..
        "\n" ..
        gemColor .. "Gems: " .. gemCounts .. Geary.CC_END .. "\n" ..
        "\n" ..
        mopLegProgress ..
        "\n" ..
        "Equipped iLevel: " .. ("%.2f"):format(inspect.iLevelEquipped) .. "\n" ..
        upgradedColor .. "Upgraded iLevel: " .. upgradedILevel .. Geary.CC_END .. "\n" ..
        "\n" ..
        milestoneColor .. "Next: " .. milestoneString .. Geary.CC_END .. "\n" ..
        "\n" ..
        minItemColor .. "Lowest Item: " .. minItemString .. Geary.CC_END .. "\n" ..
        maxItemColor .. "Highest Item: " .. maxItemString .. Geary.CC_END)
end

function Geary_Interface_Player:SetItem(slotName, item)

    if self.paperDoll.slots[slotName] == nil then
        Geary:Print(Geary.CC_FAILED .. "Invalid slotName", slotName, "for paper doll" .. Geary.CC_END)
        return
    end

    local slotData = self.paperDoll.slots[slotName]

    if slotData.item ~= nil and slotData.item.link == item.link then
        -- Geary:DebugPrint(Geary.CC_DEBUG .. "Paper doll slot", slotName, "already", item.link .. Geary.CC_END)
        return
    end

    slotData.item = item

    slotData.icon:SetTexture(item.texture)
    slotData.icon:SetTexCoord(0, 1, 0, 1) -- Must reset in case icon was previously missing item texture
    slotData.icon:Show()
    self:_SetItemBorder(slotName, item)

    self:_AddInfoTooltipText(slotData.info, item:ILevelWithUpgrades() .. " " .. item:GetItemLinkWithInlineTexture())
    slotData.info.fontString:SetText(item:ILevelWithUpgrades())
    self:_SetEnchantIcon(slotData.info, item)
    self:_SetGemIcons(slotData.info, item)

    if Geary_Options:GetShowMopLegProgress() then
        if item.isMissingCohMeta then
            self:_AddInfoTooltipText(slotData.info,
                Geary.CC_OPTIONAL .. "Missing Crown of Heaven legendary meta gem" .. Geary.CC_END)
        end
        if item.isMissingCov then
            self:_AddInfoTooltipText(slotData.info, Geary.CC_OPTIONAL .. "Missing Cloak of Virtue" .. Geary.CC_END)
        end
    end

    -- Set the background color based on any issues with this item
    if item:IsMissingRequired() then
        slotData.info:SetBackdropColor(1, 0, 0, 0.44)
    elseif item:IsMissingOptional() then
        slotData.info:SetBackdropColor(1, 1, 0, 0.33)
    else
        slotData.info:SetBackdropColor(0, 0, 0, 0)
    end
end

function Geary_Interface_Player:_SetEnchantIcon(info, item)
    if item:IsEnchanted() then
        info.enchantTexture:SetTexture("Interface\\ICONS\\inv_misc_enchantedscroll")
        self:_AddInfoTooltipText(info, Geary.CC_CORRECT .. item:GetEnchantText() .. Geary.CC_END)
    else
        if item:CanEnchant() then
            info.enchantTexture:SetTexture("Interface\\COMMON\\Indicator-Red")
            info.enchantTexture:SetTexCoord(0.125, 0.875, 0.125, 0.875)
            self:_AddInfoTooltipText(info, Geary.CC_ERROR .. "Missing enchant" .. Geary.CC_END)
        else
            info.enchantTexture:SetTexture(0, 0, 0, 0)
        end
    end
end

function Geary_Interface_Player:_SetGemIcons(info, item)
    local gemTextureIndex = 1

    -- Clear all
    for gemNum = 1, Geary_Item.MAX_GEMS do
        info.gemTextures[gemTextureIndex]:SetTexture(0, 0, 0, 0)
    end

    -- Filled gems
    for gemNum = 1, Geary_Item.MAX_GEMS do
        if item.filledSockets[gemNum] ~= nil then
            local texture = select(10, GetItemInfo(item.filledSockets[gemNum]))
            if texture == nil then
                -- Generic failsafe
                texture = "Interface\\ICONS\\INV_Misc_Gem_Variety_01"
            end
            info.gemTextures[gemTextureIndex]:SetTexture(texture)
            self:_AddInfoTooltipText(info, Geary.CC_CORRECT .. "Gem " .. Geary.CC_END ..
                Geary_Item:GetGemLinkWithInlineTexture(item.filledSockets[gemNum]))
            gemTextureIndex = gemTextureIndex + 1
        end
    end

    -- Missing gems
    for gemNum = 1, Geary_Item.MAX_GEMS do
        if item.emptySockets[gemNum] ~= nil then
            info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Red")
            info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
            self:_AddInfoTooltipText(info, Geary.CC_ERROR .. "Empty " .. item.emptySockets[gemNum] .. Geary.CC_END)
            gemTextureIndex = gemTextureIndex + 1
        end
    end

    -- Failed gems
    for gemNum = 1, Geary_Item.MAX_GEMS do
        if item.failedJewelIds[gemNum] ~= nil then
            info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Red")
            info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
            self:_AddInfoTooltipText(info, Geary.CC_FAILED .. "Failed to get gem details" .. Geary.CC_END)
            gemTextureIndex = gemTextureIndex + 1
        end
    end

    -- Missing belt buckle
    if item.isMissingBeltBuckle then
        info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Red")
        info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
        self:_AddInfoTooltipText(info, Geary.CC_ERROR .. "Missing " .. Geary_Item:GetBeltBuckleItemWithTexture() ..
            Geary.CC_END)
        gemTextureIndex = gemTextureIndex + 1
    end

    -- Missing Eye of the Black Prince
    if Geary_Options:GetShowMopLegProgress() and item.isMissingEotbp then
        info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Yellow")
        info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
        self:_AddInfoTooltipText(info, Geary.CC_OPTIONAL .. "Missing " .. Geary_Item:GetEotbpItemWithTexture() ..
            Geary.CC_END)
        gemTextureIndex = gemTextureIndex + 1
    end
end

function Geary_Interface_Player:_AddInfoTooltipText(info, text)
    if info.tooltip == nil then
        info.tooltip = text
    else
        info.tooltip = info.tooltip .. "\n" .. text
    end
end

function Geary_Interface_Player:_SetItemBorder(slotName, item)
    -- TODO If the item's probe failed, would be nice to see CC_FAILED color on border
    if item == nil then
        self.paperDoll.slots[slotName].frame:SetBackdropBorderColor(0, 0, 0, 0)
    else
        local r, g, b, _ = GetItemQualityColor(item.quality)
        self.paperDoll.slots[slotName].frame:SetBackdropBorderColor(r, g, b, 1)
    end
end

function Geary_Interface_Player:_MarkMissingItems(inspect)
    local mainHandIsTwoHand = false
    for _, slotName in ipairs(Geary_Item:GetInvSlotsInOrder()) do
        local slotData = self.paperDoll.slots[slotName]
        if slotName == "MainHandSlot" and slotData.item ~= nil then
            mainHandIsTwoHand = slotData.item:IsTwoHandWeapon()
        end
        if slotData.item == nil then
            if slotName == "SecondaryHandSlot" and mainHandIsTwoHand and not inspect.player:HasTitansGrip()
            then
                Geary:DebugLog(slotName, "not missing because main hand is 2Her and no Titan's Grip")
            else
                -- A red circle with slash through it
                slotData.icon:SetTexture("Interface\\Transmogrify\\Textures.png")
                slotData.icon:SetTexCoord(0.28906250, 0.55468750, 0.51171875, 0.57812500)
                slotData.icon:Show()

                slotData.frame:SetBackdropBorderColor(1, 0, 0, 1)
                slotData.info:SetBackdropColor(1, 0, 0, 0.5)
                self:_AddInfoTooltipText(slotData.info, Geary.CC_ERROR .. TRANSMOGRIFY_INVALID_REASON1 .. Geary.CC_END)
            end
        end
    end
end

function Geary_Interface_Player:Show()
    if self.paperDoll.hasPlayer then
        self.paperDoll.frame:Show()
        self.summary:Show()
        self.mainFrame.unavailFontString:Hide()
    else
        self.paperDoll.frame:Hide()
        self.summary:Hide()
        self.mainFrame.unavailFontString:Show()
    end
    self.mainFrame:Show()
end

function Geary_Interface_Player:Hide()
    self.mainFrame:Hide()
end
