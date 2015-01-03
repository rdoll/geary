--[[
    Geary item details

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Item = {
    tooltip = CreateFrame("GameTooltip", "Geary_Tooltip_Scanner", nil, "GameTooltipTemplate"),

    -- Inexplicably missing constants
    MAX_GEMS = 4
}

-- Details of all slots and what they can contain (slotNumber filled in during init)
-- Enchant min: nil = not enchantable, 1 = MoP and WoD or just WoD enchant avail
-- Enchant max: 599 = MoP items and lower only, nil = no limit up through WoD items
local _slotDetails = {
    HeadSlot          = { order = 1,  slotNumber = nil, enchantMinILevel = nil, enchantMaxILevel = nil },
    NeckSlot          = { order = 2,  slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = nil },
    ShoulderSlot      = { order = 3,  slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = 599 },
    BackSlot          = { order = 4,  slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = nil },
    ChestSlot         = { order = 5,  slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = 599 },
    WristSlot         = { order = 6,  slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = 599 },
    HandsSlot         = { order = 7,  slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = 599 },
    WaistSlot         = { order = 8,  slotNumber = nil, enchantMinILevel = nil, enchantMaxILevel = nil },
    LegsSlot          = { order = 9,  slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = 599 },
    FeetSlot          = { order = 10, slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = 599 },
    Finger0Slot       = { order = 11, slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = nil },
    Finger1Slot       = { order = 12, slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = nil },
    Trinket0Slot      = { order = 13, slotNumber = nil, enchantMinILevel = nil, enchantMaxILevel = nil },
    Trinket1Slot      = { order = 14, slotNumber = nil, enchantMinILevel = nil, enchantMaxILevel = nil },
    MainHandSlot      = { order = 15, slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = nil },
    SecondaryHandSlot = { order = 16, slotNumber = nil, enchantMinILevel = 1,   enchantMaxILevel = 599 }
}

-- Index = order of slots, value = { slotName = "slot name", slotNumber = # }
-- Filled in during init based on _slotDetails.*.order
local _slotOrder = {}

-- Names of empty gem sockets in tooltips
local _socketNames = {
    EMPTY_SOCKET_META,
    EMPTY_SOCKET_BLUE,
    EMPTY_SOCKET_RED,
    EMPTY_SOCKET_YELLOW,
    EMPTY_SOCKET_PRISMATIC,
    EMPTY_SOCKET_COGWHEEL,
    EMPTY_SOCKET_HYDRAULIC
}

function Geary_Item:Init()
    -- Determine inventory slot numbers from names and set the slot order
    for slotName, slotData in pairs(_slotDetails) do
        slotData.slotNumber, _ = GetInventorySlotInfo(slotName)
        _slotOrder[slotData.order] = slotName
    end
end

function Geary_Item:GetInvSlotsInOrder()
    return _slotOrder
end

function Geary_Item:GetSlotNumberForName(slotName)
    return _slotDetails[slotName].slotNumber
end

function Geary_Item:IsInvSlotName(slotName)
    return _slotDetails[slotName] ~= nil
end

function Geary_Item:IsWeaponSlot()
    return self.slot == "MainHandSlot" or self.slot == "SecondaryHandSlot"
end

function Geary_Item:IsWeapon()
    return self:IsWeaponSlot() and
        (self.invType == "INVTYPE_2HWEAPON" or
            self.invType == "INVTYPE_RANGED" or
            self.invType == "INVTYPE_RANGEDRIGHT" or
            self.invType == "INVTYPE_WEAPONMAINHAND" or
            self.invType == "INVTYPE_WEAPONOFFHAND" or
            self.invType == "INVTYPE_WEAPON")
end

function Geary_Item:IsTwoHandWeapon()
    return self:IsWeaponSlot() and
        (self.invType == "INVTYPE_2HWEAPON" or self.invType == "INVTYPE_RANGED" or self.invType == "INVTYPE_RANGEDRIGHT")
end

function Geary_Item:GetCanEnchant()
    return self.canEnchant
end

function Geary_Item:IsEnchanted()
    return self.enchantText ~= nil
end

function Geary_Item:GetEnchantText()
    return self.enchantText or ""
end

--
-- Player can do legendary quest and item is a weapon that is one of the following:
--   + Sha-Touched
--   + T15 LFR (502, 506, 510)
--   + T15 Normal (522, 526, 530)
--   + T15 Normal Thunderforged (528, 532, 536)  ** 528/532/536 conflicts with T16 LFR **
--   + T15 Heroic (535, 539, 543)
--   + T15 Heroic Thunderforged (541, 545, 549)
--
-- But is NOT:
--   + Heroic scenario (516, 520, 524)
--   + T16 LFR (528, 532, 536, 540, 544)  ** 528/532/536 conflicts with T15 Normal Thunderforged **
--   + T16 Flex (540, 544, 548, 552, 556)
--
-- For the conflicting T15 Normal Thunderforged and T16 LFR item levels, use item IDs.
--
function Geary_Item:CanHaveEotbp(player)

    if not player:CanDoMopLegQuest() then
        return false  -- Player ineligible for legendary
    end

    if not self:IsWeapon() then
        return false  -- Not a weapon type EotBP can be used on
    end

    if self.isShaTouched then
        return true  -- Sha-Touched can have EotBP
    end

    if self.iLevel == 502 or self.iLevel == 506 or self.iLevel == 510 then
        return true  -- T15 LFR item
    elseif self.iLevel == 522 or self.iLevel == 526 or self.iLevel == 530 then
        return true  -- T15 Normal item
    elseif self.iLevel == 535 or self.iLevel == 539 or self.iLevel == 543 then
        return true  -- T15 Heroic item
    elseif self.iLevel == 541 or self.iLevel == 545 or self.iLevel == 549 then
        return true  -- T15 Heroic Thunderforged item
    elseif self.iLevel ~= 528 and self.iLevel ~= 532 and self.iLevel ~= 536 then
        return false  -- Not T15 Normal Thunderforged or T16 LFR item
    end

    if self.id == 96004      -- Worldbreaker's Stormscythe
        or self.id == 96038  -- Kura-Kura, Kazra'jin's Skullcleaver
        or self.id == 96181  -- Uroe, Harbinger of Terror
        or self.id == 96050  -- Shattered Tortoiseshell Longbow
        or self.id == 96231  -- Miracoran, the Vehement Chord
        or self.id == 96153  -- Voice of the Quilen
        or self.id == 96130  -- Acid-Spine Bonemace
        or self.id == 96142  -- Hand of the Dark Animus
        or self.id == 96187  -- Torall, Rod of the Shattered Throne
        or self.id == 96233  -- Zeeg's Ancient Kegsmasher
        or self.id == 96239  -- Jerthud, Graceful Hand of the Savior
        or self.id == 96230  -- Invocation of the Dawn
        or self.id == 96175  -- Shan-Dun, Breaker of Hope
        or self.id == 96249  -- Bo-Ris, Horror in the Night
        or self.id == 96012  -- Soulblade of the Breaking Storm
        or self.id == 96162  -- Qon's Flaming Scimitar
        or self.id == 96248  -- Do-tharak, the Swordbreaker
        or self.id == 96047  -- Zerat, Malakk's Soulburning Greatsword
        or self.id == 96247  -- Greatsword of Frozen Hells
        or self.id == 96019  -- Jalak's Maelstrom Staff
        or self.id == 96029  -- Dinomancer's Spiritbinding Spire
        or self.id == 96092  -- Giorgio's Caduceus of Pure Moods
        or self.id == 96167  -- Suen-Wo, Spire of the Falling Sun
        or self.id == 96234  -- Darkwood Spiritstaff
        or self.id == 96042  -- Amun-Thoth, Sul's Spiritrending Talons
        or self.id == 96163  -- Wu-Lai, Bladed Fan of the Consorts
        or self.id == 97128  -- Tia-Tia, the Scything Star
        or self.id == 96070  -- Megaera's Poisoned Fang
        or self.id == 96115  -- Ritual Dagger of the Mind's Eye
        or self.id == 96146  -- Athame of the Sanguine Ritual
        or self.id == 96152  -- Iron Qon's Boot Knife
        or self.id == 96232  -- Fyn's Flickering Dagger
        or self.id == 96238  -- Nadagast's Exsanguinator
        or self.id == 96100  -- Durumu's Baleful Gaze
        or self.id == 96032  -- Venomlord's Totemic Wand
    then
        return true  -- T15 Normal Thunderforged item
    end

    return false  -- Anything else
end

-- Player can do legendary quest and has a head item with sockets
function Geary_Item:CanHaveCohMeta(player)
    return player:CanDoMopLegQuest() and self.slot == "HeadSlot" and
        (not Geary:IsTableEmpty(self.filledSockets) or
            not Geary:IsTableEmpty(self.emptySockets) or not Geary:IsTableEmpty(self.failedJewelIds))
end

-- Player can do legendary quest
function Geary_Item:CanHaveCovOrLegCloak(player)
    return player:CanDoMopLegQuest()
end

-- Determines if the item is a cloak with an item ID of the 6 Cloaks of Virtue
-- NOTE: Must use item IDs to be locale independent
function Geary_Item:IsCov()
    return
        self.id == 98146 or  -- Oxhorn Bladebreaker
        self.id == 98147 or  -- Tigerclaw Cape
        self.id == 98148 or  -- Tigerfang Wrap
        self.id == 98149 or  -- Cranewing Cloak
        self.id == 98150 or  -- Jadefire Drape
        self.id == 98335     -- Oxhoof Greatcloak
end

function Geary_Item:IsMissingRequired()
    return self.iLevel == 0 or not Geary:IsTableEmpty(self.emptySockets) or
        not Geary:IsTableEmpty(self.failedJewelIds) or (self:GetCanEnchant() and not self:IsEnchanted()) or
        self.isMissingBeltBuckle
end

function Geary_Item:IsMissingOptional()
    return self.upgradeItemLevelMissing > 0 or
        (Geary_Options:GetShowMopLegProgress() and (self.isMissingEotbp or self.isMissingCohMeta or self.isMissingCov))
end

function Geary_Item:ILevelWithUpgrades()
    local upgrades = ""
    if self.upgradeMax > 0 then
        upgrades = " " .. (self.upgradeLevel < self.upgradeMax and Geary.CC_UPGRADE or Geary.CC_CORRECT) ..
            self.upgradeLevel .. "/" .. self.upgradeMax .. Geary.CC_END
    end

    local _, _, _, colorCode = GetItemQualityColor(self.quality)
    return Geary.CC_START .. colorCode .. tostring(self.iLevel) .. Geary.CC_END .. upgrades
end

function Geary_Item:_CanHaveBeltBuckle(slotName, iLevel)
    return slotName == "WaistSlot" and iLevel <= 599
end

function Geary_Item:GetBeltBuckleItemWithTexture()
    return self:_GetItemLinkWithTexture(90046, "Living Steel Belt Buckle")
end

function Geary_Item:GetEotbpItemWithTexture()
    return self:_GetItemLinkWithTexture(93403, "Eye of the Black Prince")
end

function Geary_Item:GetItemLinkWithInlineTexture()
    return self.inlineTexture == nil and self.link or (self.inlineTexture .. " " .. self.link)
end

function Geary_Item:GetGemLinkWithInlineTexture(itemLink)
    local inlineGemTexture = self:_GetItemInlineTexture(itemLink)
    if inlineGemTexture == nil then
        return itemLink
    else
        return inlineGemTexture .. " " .. itemLink
    end
end

function Geary_Item:_GetItemLinkWithTexture(itemId, itemName)
    local itemLink = select(2, GetItemInfo(itemId))
    if itemLink == nil then
        Geary:DebugLog(itemName, "item ID", itemId, "not in local cache")
        return itemName
    end
    local inlineTexture = self:_GetItemInlineTexture(itemLink)
    if inlineTexture == nil then
        return itemLink
    else
        return inlineTexture .. " " .. itemLink
    end
end

function Geary_Item:_GetItemInlineTexture(itemLink)
    local size = Geary_Options:GetLogFontHeight()
    local texture = select(10, GetItemInfo(itemLink))
    if texture == nil or texture:len() == 0 then
        return nil
    end
    local itemId = itemLink:match("item:(%d+):")
    if itemId == nil then
        return "|T" .. texture .. ":" .. size .. ":" .. size .. "|t"
    else
        return "|Hitem:" .. itemId .. "|h|T" .. texture .. ":" .. size .. ":" .. size .. "|t|h"
    end
end

function Geary_Item:new(o)
    local newObject = {
        slot                    = nil,
        link                    = nil,
        id                      = nil,
        name                    = nil,
        quality                 = nil,
        iLevel                  = 0,
        iType                   = nil,
        subType                 = nil,
        invType                 = nil,
        texture                 = nil,
        inlineTexture           = nil,
        filledSockets           = {},
        emptySockets            = {},
        failedJewelIds          = {},
        canHaveBeltBuckle       = false,
        isMissingBeltBuckle     = false,
        canEnchant              = false,
        enchantText             = nil,
        upgradeLevel            = 0,
        upgradeMax              = 0,
        upgradeItemLevelMissing = 0,
        isShaTouched            = false,
        hasEotbp                = false,
        isMissingEotbp          = false,
        hasCohMeta              = false,
        isMissingCohMeta        = false,
        hasCov                  = false,
        isMissingCov            = false,
        hasLegCloak             = false,
        isMissingLegCloak       = false
    }
    if o then
        for name, value in pairs(o) do
            newObject[name] = value
        end
    end
    setmetatable(newObject, self)
    self.__index = self
    return newObject
end

function Geary_Item:Probe(player)
    if self.link == nil then
        error("Cannot probe item without link")
        return false
    end

    if self.slot == nil then
        error("Cannot probe item without slot")
        return false
    end

    -- Workaround an item link bug with the signed suffixId being unsigned in the link
    self.link = self:_ItemLinkSuffixIdBugWorkaround(self.link)

    -- Get base item info
    self.id = tonumber(self.link:match("|Hitem:(%d+):"))
    self.name, _, self.quality, _, _, self.iType, self.subType, _, self.invType, self.texture, _ = GetItemInfo(self.link)
    self.inlineTexture = self:_GetItemInlineTexture(self.link)

    -- Parse data from the item's tooltip
    self:_ParseTooltip()

    -- Ensure we got the data we should have
    -- Note that this also covers the case when the Server fails to send us any tooltip information
    if self.iLevel < 1 then
        Geary:Log(Geary.CC_FAILED .. self.slot .. " item has no item level in " .. self.link .. Geary.CC_END)
        return false
    end

    -- Set enchantable
    self:_SetCanEnchant(self.slot, self.iLevel)

    -- Get socketed gem information
    self:_GetGems(self.slot)

    -- Check for special cases wrt gems
    self.canHaveBeltBuckle = self:_CanHaveBeltBuckle(self.slot, self.iLevel)
    if self.canHaveBeltBuckle then
        self.isMissingBeltBuckle = self:_IsMissingExtraGem()
    end

    if self:CanHaveEotbp(player) then
        self.isMissingEotbp = self:_IsMissingExtraGem()
        self.hasEotbp = not self.isMissingEotbp
    end

    if self:CanHaveCohMeta(player) then
        self.isMissingCohMeta = not self.hasCohMeta
    end

    if self.slot == "BackSlot" and self:CanHaveCovOrLegCloak(player) then
        if self.quality == LE_ITEM_QUALITY_LEGENDARY then
            self.hasCov = false
            self.isMissingCov = false
            self.hasLegCloak = true
            self.isMissingLegCloak = false
        else
            self.hasCov = self:IsCov()
            self.isMissingCov = not self.hasCov
            self.hasLegCloak = false
            self.isMissingLegCloak = true
        end
    end

    -- Report info about the item
    Geary:Log(("%s %s %s %s %s"):format(self:ILevelWithUpgrades(), self:GetItemLinkWithInlineTexture(),
        self.slot:gsub("Slot$", ""), self.iType, self.subType))

    for _, text in pairs(self.emptySockets) do
        Geary:Log(Geary.CC_MISSING .. "   No gem in " .. text .. Geary.CC_END)
    end

    for _, itemLink in pairs(self.filledSockets) do
        Geary:Log(Geary.CC_CORRECT .. "   Gem " .. self:GetGemLinkWithInlineTexture(itemLink) .. Geary.CC_END)
    end

    for socketIndex, _ in ipairs(self.failedJewelIds) do
        Geary:Log(Geary.CC_FAILED .. "   Failed to get gem in socket " .. socketIndex .. Geary.CC_END)
    end

    if self:IsEnchanted() then
        Geary:Log(Geary.CC_CORRECT .. "   " .. self:GetEnchantText() .. Geary.CC_END)
    elseif self:GetCanEnchant() then
        Geary:Log(Geary.CC_MISSING .. "   Missing enchant!" .. Geary.CC_END)
    end

    if self.isMissingBeltBuckle then
        Geary:Log(Geary.CC_MISSING .. "   Missing " .. self:GetBeltBuckleItemWithTexture() .. Geary.CC_END)
    end

    if Geary_Options:GetShowMopLegProgress() then
        if self.isMissingEotbp then
            Geary:Log(Geary.CC_OPTIONAL .. "   Missing " .. self:GetEotbpItemWithTexture() .. Geary.CC_END)
        end
        if self.isMissingCohMeta then
            Geary:Log(Geary.CC_OPTIONAL .. "   Missing Crown of Heaven legendary meta gem" .. Geary.CC_END)
        end
        if self.isMissingCov then
            Geary:Log(Geary.CC_OPTIONAL .. "   Missing Cloak of Virtue" .. Geary.CC_END)
        elseif self.isMissingLegCloak then
            Geary:Log(Geary.CC_OPTIONAL .. "   Missing legendary cloak" .. Geary.CC_END)
        end
    end

    return true
end

--
-- As of 5.1, there is a bug that causes tooltip's SetHyperlink to not render
-- the stats on random stat items when the suffixId is greater than 32767.
--
-- Details:
--   http://us.battle.net/wow/en/forum/topic/7414946222
--
-- Example link that doesn't render stats unless we make the suffixId signed:
--   |cff0070dd|Hitem:89491:0:0:0:0:0:65398:1042810102:90:451|h[Firewool Cord]|h|r
--
-- Fixed link:
--   |cff0070dd|Hitem:89491:0:0:0:0:0:-138:1042810102:90:451|h[Firewool Cord of the Feverflare]|h|r
--
-- The root cause seems to be GetInventoryItemLink returns a link with the suffixId as
-- unsigned when it has to be signed.
--
function Geary_Item:_ItemLinkSuffixIdBugWorkaround(link)
    local before, suffixId, after = link:match("(.-item:.-:.-:.-:.-:.-:.-:)(.-)(:.+)")
    if tonumber(suffixId) > 32767 then
        -- Too large for 16-bit signed, so convert unsigned to signed
        return before .. (-1 * (65536 - suffixId)) .. after
    else
        -- Already a signed int, so no workaround necessary
        return link
    end
end

-- Build search strings using Blizzard localized strings outside of functions so they are done once
-- Convert non-positional %d and positional %#$d print marker with (%d+) for regex
-- ITEM_LEVEL = "Item Level %d"
local _itemLevelRegex = "^%s*" .. ITEM_LEVEL:gsub("%%d", "(%%d+)"):gsub("%%%d+%$d", "(%%d+)")
-- ITEM_UPGRADE_TOOLTIP_FORMAT = "Upgrade Level: %d/%d"
local _upgradeLevelRegex = "^%s*" .. ITEM_UPGRADE_TOOLTIP_FORMAT:gsub("%%d", "(%%d+)"):gsub("%%%d+%$d", "(%%d+)")
-- EMPTY_SOCKET_HYDRAULIC = "Sha-Touched"
local _shaTouchedString = '"' .. EMPTY_SOCKET_HYDRAULIC .. '"'
-- ENCHANTED_TOOLTIP_LINE = "Enchanted: %s"
local _enchantedRegexHead = "^%s*" .. ENCHANTED_TOOLTIP_LINE:gsub("%%s", "")

function Geary_Item:_ParseTooltip()

    -- Ensure owner is set (ClearLines unsets owner)
    -- ANCHOR_NONE without setting any points means it's never rendered
    self.tooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')

    -- Build tooltip for item
    -- Note that SetHyperlink on the same item link twice in a row closes the tooltip
    -- which deletes its content; so we ClearLines when done
    self.tooltip:SetHyperlink(self.link)

    -- Parase the left side text (right side text isn't useful)
    for lineNum = 1, self.tooltip:NumLines() do
        (function(self) -- Function so we can use return as "continue"
            local text = _G["Geary_Tooltip_ScannerTextLeft" .. lineNum]:GetText()
            -- Eat any color codes (e.g. gem stats have them)
            text = text:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
            Geary:DebugLog(text)

            local iLevel = text:match(_itemLevelRegex)
            if iLevel then
                self:_SetItemLevel(tonumber(iLevel))
                return  -- "continue"
            end

            local upgradeLevel, upgradeMax = text:match(_upgradeLevelRegex)
            if upgradeLevel and upgradeMax then
                self:_SetUpgrades(tonumber(upgradeLevel), tonumber(upgradeMax))
                return  -- "continue"
            end

            if text:match(_enchantedRegexHead) then
                self:_SetEnchantText(text)
                return  -- "continue"
            end

            if text == _shaTouchedString then
                self.isShaTouched = true
                return  -- "continue"
            end

            for _, socketName in pairs(_socketNames) do
                if text == socketName then
                    tinsert(self.emptySockets, text)
                    return  -- "continue"
                end
            end
        end)(self)
    end

    -- Clear the tooltip's content (which also clears its owner)
    self.tooltip:ClearLines()
end

function Geary_Item:_GetGems(slot)
    -- Get jewelIds from the item link
    local jewelId = {}
    jewelId[1], jewelId[2], jewelId[3], jewelId[4] = self.link:match("item:.-:.-:(.-):(.-):(.-):(.-):")

    -- Check all sockets for a gem
    for socketIndex = 1, self.MAX_GEMS do
        local itemName, itemLink = GetItemGem(self.link, socketIndex)
        if itemLink == nil then
            if jewelId[socketIndex] ~= nil and tonumber(jewelId[socketIndex]) ~= 0 then
                -- GetItemGem returned nil because the gem is not in the player's local cache
                self.failedJewelIds[socketIndex] = jewelId[socketIndex]
                Geary:DebugLog(("GetItemGem(%s, %i) returned nil when link had %d"):format(self.link:gsub("|", "||"),
                    socketIndex, tonumber(jewelId[socketIndex])))
            end
        else
            if slot == "HeadSlot" then
                -- Head slot item, so look for the legendary meta gem
                local gemQuality = select(3, GetItemInfo(itemLink))
                if gemQuality == nil then
                    -- Not sure this is possible, but check it to be safe
                    -- We failed to get the gem's quality from its link, so count it as failed
                    self.failedJewelIds[socketIndex] = jewelId[socketIndex]
                    Geary:DebugLog("Failed to get item quality from gem", itemLink)
                else
                    if gemQuality == LE_ITEM_QUALITY_LEGENDARY then
                        self.hasCohMeta = true
                    end
                    tinsert(self.filledSockets, itemLink)
                end
            else
                tinsert(self.filledSockets, itemLink)
            end
        end
    end
end

function Geary_Item:_SetItemLevel(iLevel)
    if self.iLevel > 0 then
        Geary:Print(Geary.CC_ERROR .. "ERROR: Multiple item levels found on " .. self.link .. Geary.CC_END)
    else
        self.iLevel = iLevel
    end
end

function Geary_Item:_SetUpgrades(upgradeLevel, upgradeMax)
    if self.upgradeLevel > 0 or self.upgradeMax > 0 then
        Geary:Print(Geary.CC_ERROR .. "ERROR: Multiple upgrade levels found on " .. self.link .. Geary.CC_END)
    else
        self.upgradeLevel = upgradeLevel
        self.upgradeMax = upgradeMax
        if upgradeLevel < upgradeMax then
            if self.quality <= LE_ITEM_QUALITY_RARE then
                -- Rare quality items cost 750 Justice Points to upgrade 8 levels
                self.upgradeItemLevelMissing = (upgradeMax - upgradeLevel) * 8
            else
                -- Epic quality items cost 250 Valor Points to upgrade 4 levels
                self.upgradeItemLevelMissing = (upgradeMax - upgradeLevel) * 4
            end
        end
    end
end

function Geary_Item:_SetCanEnchant(slotName, iLevel)

    if slotName == nil or iLevel == nil then
        self.canEnchant = false
        return
    end

    -- In WoD, only weapons (not offhands) can be enchanted.
    -- If this is a weapon in the offhand slot, for enchants it is the same as the main hand slot
    -- which is only weapons.
    if slotName == "SecondaryHandSlot" and self:IsWeapon() then
        slotName = "MainHandSlot"
    end

    local minILevel, maxILevel = _slotDetails[slotName].enchantMinILevel, _slotDetails[slotName].enchantMaxILevel
    if minILevel == nil or iLevel < minILevel then
        self.canEnchant = false  -- Slot never enchantable or can be enchanted but item's ilevel is too low
    elseif maxILevel == nil then
        self.canEnchant = true   -- Slot can be enchanted, item's ilevel is above min, and there is no max
    else
        self.canEnchant = iLevel <= maxILevel  -- Enchantable is <= non-nil max
    end
end

function Geary_Item:_SetEnchantText(enchantText)
    if self.enchantText ~= nil then
        Geary:Print(Geary.CC_ERROR .. "ERROR: Multiple enchants found on " .. self.link .. Geary.CC_END)
    else
        self.enchantText = enchantText
    end
end

-- Per http://wow.curseforge.com/addons/geary/tickets/1-does-not-detect-belt-buckle-if-no-gem-is-in-it/
-- there is no good way to check for an extra socket from a belt buckle or Eye of the Black Prince,
-- so instead we look for gems in the extra socket. By comparing the number of sockets in the BASE item
-- versus the number of gems and sockets in THIS item, we can tell if there is an extra gem.
-- Note: This is tooltip parsing similar to the full parse, but we just care about empty sockets.
function Geary_Item:_IsMissingExtraGem()

    -- Get the base item info from this item
    local _, baseItemLink = GetItemInfo(self.id)

    -- Ensure owner is set (ClearLines unsets owner)
    -- ANCHOR_NONE without setting any points means it's never rendered
    self.tooltip:SetOwner(UIParent, 'ANCHOR_NONE')

    -- Build tooltip for item
    -- Note that SetHyperlink on the same item link twice in a row closes the tooltip
    -- which deletes its content; so we ClearLines when done
    self.tooltip:SetHyperlink(baseItemLink)

    -- Parse the left side text (right side text isn't useful)
    local baseSocketCount = 0
    for lineNum = 1, self.tooltip:NumLines() do
        (function()  -- Function so we can use return as "continue"
            local text = _G["Geary_Tooltip_ScannerTextLeft" .. lineNum]:GetText()
            Geary:DebugLog("extra gem:", text)

            for _, socketName in pairs(_socketNames) do
                if text == socketName then
                    baseSocketCount = baseSocketCount + 1
                    return  -- "continue"
                end
            end
        end)()
    end

    -- Clear the tooltip's content (which also clears its owner)
    self.tooltip:ClearLines()

    -- Total sockets in THIS item is filled plus failed plus empty
    -- If total is <= the count in the base item, the extra gem is missing
    Geary:DebugLog(("extra gem: filled=%i, failed=%i, empty=%i, base=%i"):format(Geary:TableSize(self.filledSockets),
        Geary:TableSize(self.failedJewelIds), Geary:TableSize(self.emptySockets), baseSocketCount))
    if Geary:TableSize(self.filledSockets) + Geary:TableSize(self.failedJewelIds) +
        Geary:TableSize(self.emptySockets) <= baseSocketCount
    then
        return true
    else
        return false
    end
end
