--[[
	Geary item details
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Item = {
	tooltip = CreateFrame("GameTooltip", "Geary_Tooltip_Scanner", nil, "GameTooltipTemplate")
}

-- Details of all slots and what they can contain (slotNumber filled in during init)
local _slotDetails = {
	HeadSlot          = { slotNumber = nil, canEnchant = false },
	NeckSlot          = { slotNumber = nil, canEnchant = false },
	ShoulderSlot      = { slotNumber = nil, canEnchant = true  },
	BackSlot          = { slotNumber = nil, canEnchant = true  },
	ChestSlot         = { slotNumber = nil, canEnchant = true  },
	WaistSlot         = { slotNumber = nil, canEnchant = false },
	LegsSlot          = { slotNumber = nil, canEnchant = true  },
	FeetSlot          = { slotNumber = nil, canEnchant = true  },
	WristSlot         = { slotNumber = nil, canEnchant = true  },
	HandsSlot         = { slotNumber = nil, canEnchant = true  },
	Finger0Slot       = { slotNumber = nil, canEnchant = false },
	Finger1Slot       = { slotNumber = nil, canEnchant = false },
	Trinket0Slot      = { slotNumber = nil, canEnchant = false },
	Trinket1Slot      = { slotNumber = nil, canEnchant = false },
	MainHandSlot      = { slotNumber = nil, canEnchant = true  },
	SecondaryHandSlot = { slotNumber = nil, canEnchant = true  }
}

-- Names of empty gem sockets in tooltips
-- TODO Make these locale specific Blizzard strings
local _socketNames = {
	"Meta Socket",
	"Blue Socket",
	"Red Socket",
	"Yellow Socket",
	"Prismatic Socket",
	"Cogwheel Socket",
	"Sha-Touched"
}

function Geary_Item:init()
	-- Determine inventory slot numbers from names
	for slotName, slotData in pairs(_slotDetails) do
		slotData.slotNumber, _ = GetInventorySlotInfo(slotName)
	end
end

function Geary_Item:getInvSlots()
	local slots = {}
	for slotName, slotData in pairs(_slotDetails) do
		slots[slotData.slotNumber] = slotName
	end
	return slots
end

function Geary_Item:isInvSlotName(slotName)
	return _slotDetails[slotName] ~= nil
end

function Geary_Item:isTwoHandWeapon()
	return self.iType == "Weapon" and (
		self.subType == "Bows" or
		self.subType == "Crossbows" or
		self.subType == "Guns" or
		self.subType == "Fishing Poles" or
		self.subType == "Polearms" or
		self.subType == "Staves" or
		self.subType == "Two-Handed Axes" or
		self.subType == "Two-Handed Maces" or
		self.subType == "Two-Handed Swords")
end

function Geary_Item:iLevelWithUpgrades()
	local upgrades = "-/-"
	if self.upgradeMax > 0 then
		if self.upgradeLevel < self.upgradeMax then
			upgrades = YELLOW_FONT_COLOR_CODE .. self.upgradeLevel .. "/" .. self.upgradeMax ..
				FONT_COLOR_CODE_CLOSE
		else
			upgrades = GREEN_FONT_COLOR_CODE .. self.upgradeLevel .. "/" .. self.upgradeMax ..
				FONT_COLOR_CODE_CLOSE
		end
	end
	return tostring(self.iLevel) .. " " .. upgrades
end

function Geary_Item:new(o)
	local newObject = {
		slot = nil,
		link = nil,
		id = nil,
		name = nil,
		rarity = nil,
		iLevel = 0,
		iType = nil,
		subType = nil,
		filledSockets = {},
		emptySockets = {},
		failedJewelIds = {},
		missingBeltBuckle = false,
		canEnchant = false,
		enchantText = nil,
		upgradeLevel = 0,
		upgradeMax = 0,
		upgradeItemLevelMissing = 0
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

function Geary_Item:probe()
	if self.link == nil then
		error("Cannot probe item without link")
		return
	end
	
	if self.slot == nil then
		error("Cannot probe item without slot")
		return
	end
	
	-- Workaround an item link bug with the signed suffixId being unsigned in the link
	self.link = self:_itemLinkSuffixIdBugWorkaround(self.link)
	
	-- Get base item info
	self.id = self.link:match("|Hitem:(%d+):")
	self.canEnchant = _slotDetails[self.slot].canEnchant
	self.name, _, self.rarity, _, _, self.iType, self.subType, _, _, _, _ = GetItemInfo(self.link)

	-- Parse data from the item's tooltip
	self:_parseTooltip()
	
	-- Get socketed gem information
	self:_getGems()

	-- If this is a waist item, see if the belt buckle is missing
	if self.slot == "WaistSlot" then
		self:_checkForBeltBuckle()
	end
	
	-- Ensure we got the data we should have
	if self.iLevel < 1 then
		Geary:print(RED_FONT_COLOR_CODE .. "ERROR: No item level found in " .. self.link ..
			FONT_COLOR_CODE_CLOSE)
	end

	-- Report info about the item
	Geary:log(("%s %s %s %s %s"):format(self:iLevelWithUpgrades(), self.link, 
		self.slot:gsub("Slot$", ""), self.iType, self.subType))
	
	for _, text in pairs(self.emptySockets) do
		-- TODO Abstract colors to constants or methods
		Geary:log("   No gem in " .. text, 1, 0, 0)
	end

	for _, itemLink in pairs(self.filledSockets) do
		local inlineGemTexture = self:_getGemInlineTexture(itemLink, Geary_Options:getLogFontHeight())
		-- TODO Abstract colors to constants or methods
		if inlineGemTexture == nil then
			Geary:log("   Gem " .. itemLink, 0, 1, 0)
		else
			Geary:log("   Gem " .. inlineGemTexture .. " " .. itemLink, 0, 1, 0)
		end
	end

	for socketIndex, _ in ipairs(self.failedJewelIds) do
		-- TODO Abstract colors to constants or methods
		Geary:log("   Failed to get gem in socket " .. socketIndex, 1, 0, 1)
	end
	
	if self.enchantText ~= nil then
		-- TODO Abstract colors to constants or methods
		Geary:log("   " .. self.enchantText, 0, 1, 0)
	elseif self.canEnchant then
		-- TODO Abstract colors to constants or methods
		Geary:log("   Missing enchant!", 1, 0, 0)
	end
	
	if self.missingBeltBuckle then
		-- TODO Abstract colors to constants or methods
		Geary:log("   Missing belt buckle!", 1, 0, 0)
	end
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

-- The root cause seems to be GetInventoryItemLink returns a link with the suffixId as
-- unsigned when it has to be signed.
--
function Geary_Item:_itemLinkSuffixIdBugWorkaround(link)
	local before, suffixId, after = link:match("(.-item:.-:.-:.-:.-:.-:.-:)(.-)(:.+)")
	if tonumber(suffixId) > 32767 then
		-- Too large for 16-bit signed, so convert unsigned to signed
		return before .. (-1 * (65536 - suffixId)) .. after
	else
		-- Already a signed int, so no workaround necessary
		return link
	end
end

function Geary_Item:_parseTooltip()

	-- Ensure owner is set (ClearLines unsets owner)
	-- ANCHOR_NONE without setting any points means it's never rendered
	self.tooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')

	-- Build tooltip for item
	-- Note that SetHyperlink on the same item link twice in a row closes the tooltip
	-- which deletes its content; so we ClearLines when done
	self.tooltip:SetHyperlink(self.link)

	-- Parase the left side text (right side text isn't useful)
	for lineNum = 1, self.tooltip:NumLines(), 1 do
		(function ()  -- Function so we can use return as "continue"
			local text = _G["Geary_Tooltip_ScannerTextLeft" .. lineNum]:GetText()
			-- Eat any color codes (e.g. gem stats have them)
			-- TODO Or do I want to keep those to indicate this is a gem?
			text = text:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
			
			Geary:debugLog(text, 0.5, 0.5, 0.5)
			
			-- TODO Use locale appropriate Blizzard defined strings
			local iLevel = text:match("^%s*Item Level (%d+)")
			if iLevel then
				self:_setItemLevel(tonumber(iLevel))
				return  -- "continue"
			end
			
			-- TODO Use locale appropriate Blizzard defined strings
			local upgradeLevel, upgradeMax = text:match("^%s*Upgrade Level: (%d+)/(%d+)")
			if upgradeLevel and upgradeMax then
				self:_setUpgrades(tonumber(upgradeLevel), tonumber(upgradeMax))
				return  -- "continue"
			end
			
			-- TODO Use locale appropriate Blizzard defined strings
			if text:match("^%s*Enchanted:") then
				self:_setEnchantText(text)
				return  -- "continue"
			end

			for _, socketName in pairs(_socketNames) do
				if text == socketName then
					tinsert(self.emptySockets, text)
					return  -- "continue"
				end
			end
		end)()
	end

	-- Clear the tooltip's content (which also clears its owner)
	self.tooltip:ClearLines()
end

function Geary_Item:_getGems()
	-- Get jewelIds from the item link
	local jewelId = {}
	jewelId[1], jewelId[2], jewelId[3], jewelId[4] =
		self.link:match("item:%d+:%d+:(%d+):(%d+):(%d+):(%d+):")

	-- Check all sockets for a gem
	for socketIndex = 1, 4, 1 do
		local itemName, itemLink = GetItemGem(self.link, socketIndex)
		if itemLink == nil then
			if jewelId[socketIndex] ~= nil and tonumber(jewelId[socketIndex]) ~= 0 then
				-- GetItemGem returned nil because the gem is not in the player's local cache
				self.failedJewelIds[socketIndex] = jewelId[socketIndex]
				Geary:debugLog(("GetItemGem(%s, %i) returned nil when link had %d"):format(
					self.link:gsub("|", "||"), socketIndex, tonumber(jewelId[socketIndex])),
					0.5, 0.5, 0.5)
			end
		else
			tinsert(self.filledSockets, itemLink)
		end
	end
end

function Geary_Item:_getGemInlineTexture(itemLink, size)
	local texture = select(10, GetItemInfo(itemLink))
	if texture == nil and texture:len() == 0 then
		return nil
	end
	local itemId = itemLink:match("item:(%d+):")
	if itemId == nil then
		return "|T" .. texture .. ":" .. size .. ":" .. size .. "|t"
	else
		return "|Hitem:" .. itemId .. "|h|T" .. texture .. ":" .. size .. ":" .. size .. "|t|h"
	end
end

function Geary_Item:_setItemLevel(iLevel)
	if self.iLevel > 0 then
		Geary:print(RED_FONT_COLOR_CODE .. "ERROR: Multiple item levels found in " .. self.link ..
			FONT_COLOR_CODE_CLOSE)
	else
		self.iLevel = iLevel
	end
end

function Geary_Item:_setUpgrades(upgradeLevel, upgradeMax)
	if self.upgradeLevel > 0 or self.upgradeMax > 0 then
		Geary:print(RED_FONT_COLOR_CODE .. "ERROR: Multiple upgrade levels found in " .. self.link ..
			FONT_COLOR_CODE_CLOSE)
	else
		self.upgradeLevel = upgradeLevel
		self.upgradeMax = upgradeMax
		if upgradeLevel < upgradeMax then
			if self.rarity <= ITEM_QUALITY_RARE then
				-- Rare quality items use 1500 Justive Points to upgrade 8 levels
				self.upgradeItemLevelMissing = (upgradeMax - upgradeLevel) * 8
			else
				-- Epic quality items use 750 Valor Points to upgrade 4 levels
				self.upgradeItemLevelMissing = (upgradeMax - upgradeLevel) * 4			
			end
		end
	end
end

function Geary_Item:_setEnchantText(enchantText)
	if self.enchantText ~= nil then
		Geary:print(RED_FONT_COLOR_CODE .. "ERROR: Multiple enchant texts found in " .. self.link ..
			FONT_COLOR_CODE_CLOSE)
	else
		self.enchantText = enchantText
	end
end

-- There is no good way to check for a belt buckle.
-- What we do is count the gems in the BASE item and compare that with the number of gem's
-- in THIS item. If THIS item doesn't have one more gem than the BASE item, it doesn't have
-- a belt buckle (or has a belt buckle with no gem in it).
-- Note: This is tooltip parsing similar to the full parse, but we just care about empty sockets.
function Geary_Item:_checkForBeltBuckle()

	-- Get the base item info from this item
	local _, baseItemLink = GetItemInfo(self.id)

	-- Ensure owner is set (ClearLines unsets owner)
	-- ANCHOR_NONE without setting any points means it's never rendered)
	self.tooltip:SetOwner(UIParent, 'ANCHOR_NONE')

	-- Build tooltip for item
	-- Note that SetHyperlink on the same item link twice in a row closes the tooltip
	-- which deletes its content; so we ClearLines when done
	self.tooltip:SetHyperlink(baseItemLink)

	-- Parase the left side text (right side text isn't useful)
	local baseSocketCount = 0
	for lineNum = 1, self.tooltip:NumLines(), 1 do
		(function ()  -- Function so we can use return as "continue"
			local text = _G["Geary_Tooltip_ScannerTextLeft" .. lineNum]:GetText()
			Geary:debugLog("buckle: " .. text, 0.5, 0.5, 0.5)
			
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
	-- If total is <= the count in the base item, the belt buckle is missing
	Geary:debugLog(("buckle: filled=%i, failed=%i, empty=%i, base=%i"):format(#self.filledSockets,
		#self.failedJewelIds, #self.emptySockets, baseSocketCount), 0.5, 0.5, 0.5)
	if #self.filledSockets + #self.failedJewelIds + #self.emptySockets <= baseSocketCount then
		self.missingBeltBuckle = true
	end
end