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
	HeadSlot          = { order = 1,  slotNumber = nil, canEnchant = false },
	NeckSlot          = { order = 2,  slotNumber = nil, canEnchant = false },
	ShoulderSlot      = { order = 3,  slotNumber = nil, canEnchant = true  },
	BackSlot          = { order = 4,  slotNumber = nil, canEnchant = true  },
	ChestSlot         = { order = 5,  slotNumber = nil, canEnchant = true  },
	WristSlot         = { order = 6,  slotNumber = nil, canEnchant = true  },
	HandsSlot         = { order = 7,  slotNumber = nil, canEnchant = true  },
	WaistSlot         = { order = 8,  slotNumber = nil, canEnchant = false },
	LegsSlot          = { order = 9,  slotNumber = nil, canEnchant = true  },
	FeetSlot          = { order = 10, slotNumber = nil, canEnchant = true  },
	Finger0Slot       = { order = 11, slotNumber = nil, canEnchant = false },
	Finger1Slot       = { order = 12, slotNumber = nil, canEnchant = false },
	Trinket0Slot      = { order = 13, slotNumber = nil, canEnchant = false },
	Trinket1Slot      = { order = 14, slotNumber = nil, canEnchant = false },
	MainHandSlot      = { order = 15, slotNumber = nil, canEnchant = true  },
	SecondaryHandSlot = { order = 16, slotNumber = nil, canEnchant = true  }
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

function Geary_Item:init()
	-- Determine inventory slot numbers from names and set the slot order
	for slotName, slotData in pairs(_slotDetails) do
		slotData.slotNumber, _ = GetInventorySlotInfo(slotName)
		_slotOrder[slotData.order] = slotName
	end
end

function Geary_Item:getInvSlotsInOrder()
	return _slotOrder
end

function Geary_Item:getSlotNumberForName(slotName)
	return _slotDetails[slotName].slotNumber
end

function Geary_Item:isInvSlotName(slotName)
	return _slotDetails[slotName] ~= nil
end

function Geary_Item:isWeapon()
	return self.slot == "MainHandSlot" or self.slot == "SecondaryHandSlot"
end

function Geary_Item:isTwoHandWeapon()
	return self:isWeapon() and (
		self.invType == "INVTYPE_2HWEAPON" or
		self.invType == "INVTYPE_RANGED" or
		self.invType == "INVTYPE_RANGEDRIGHT")
end

-- Player can do legendary quest and has a Sha-Touched or 502+ iLevel weapon
function Geary_Item:canHaveEotbp(player)
	return player:isMaxLevel() and
		(self.isShaTouched or
			(self.iLevel >= 502 and self:isWeapon() and (
				self.invType == "INVTYPE_2HWEAPON" or
				self.invType == "INVTYPE_RANGED" or
				self.invType == "INVTYPE_RANGEDRIGHT" or
				self.invType == "INVTYPE_WEAPONMAINHAND" or
				self.invType == "INVTYPE_WEAPONOFFHAND" or
				self.invType == "INVTYPE_WEAPON")
			)
		)
end

-- Player can do legendary quest and has a head item with sockets
function Geary_Item:canHaveCohMeta(player)
	return player:isMaxLevel() and self.slot == "HeadSlot" and
		(not Geary:isTableEmpty(self.filledSockets) or
			 not Geary:isTableEmpty(self.emptySockets) or not Geary:isTableEmpty(self.failedJewelIds)
		)
end

-- Player can do legendary quest
function Geary_Item:canHaveCov(player)
	return player:isMaxLevel()
end

-- Determines if the item is a cloak with an item ID of the 6 Cloaks of Virtue
-- NOTE: Must use item IDs to be locale independent
function Geary_Item:isCov()
	return
		self.id == 98146 or  -- Oxhorn Bladebreaker
		self.id == 98147 or  -- Tigerclaw Cape
		self.id == 98148 or  -- Tigerfang Wrap
		self.id == 98149 or  -- Cranewing Cloak
		self.id == 98150 or  -- Jadefire Drape
		self.id == 98335     -- Oxhoof Greatcloak
end

function Geary_Item:isMissingRequired()
	return self.iLevel == 0 or not Geary:isTableEmpty(self.emptySockets) or
		not Geary:isTableEmpty(self.failedJewelIds) or (self.canEnchant and self.enchantText == nil) or
		self.isMissingBeltBuckle
end

function Geary_Item:isMissingOptional()
	return self.upgradeItemLevelMissing > 0  or self.isMissingEotbp or self.isMissingCohMeta or
		self.isMissingCov
end

function Geary_Item:iLevelWithUpgrades()
	local upgrades = ""
	if self.upgradeMax > 0 then
		upgrades = " " .. (self.upgradeLevel < self.upgradeMax and Geary.CC_UPGRADE or Geary.CC_CORRECT) ..
			self.upgradeLevel .. "/" .. self.upgradeMax .. Geary.CC_END
	end
	
	local _, _, _, colorCode = GetItemQualityColor(self.quality)
	return Geary.CC_START .. colorCode .. tostring(self.iLevel) .. Geary.CC_END .. upgrades
end

function Geary_Item:getBeltBuckleItemWithTexture()
	return self:_getItemLinkWithTexture(90046, "Living Steel Belt Buckle")
end

function Geary_Item:getEotbpItemWithTexture()
	return self:_getItemLinkWithTexture(93403, "Eye of the Black Prince")
end

function Geary_Item:getItemLinkWithInlineTexture()
	return self.inlineTexture == nil and self.link or (self.inlineTexture .. " " .. self.link)
end

function Geary_Item:getGemLinkWithInlineTexture(itemLink)
	local inlineGemTexture = self:_getItemInlineTexture(itemLink)
	if inlineGemTexture == nil then
		return itemLink
	else
		return inlineGemTexture .. " " .. itemLink
	end
end

function Geary_Item:_getItemLinkWithTexture(itemId, itemName)
	local itemLink = select(2, GetItemInfo(itemId))
	if itemLink == nil then
		Geary:debugLog(itemName, "item ID", itemId, "not in local cache")
		return itemName
	end
	local inlineTexture = self:_getItemInlineTexture(itemLink)
	if inlineTexture == nil then
		return itemLink
	else
		return inlineTexture .. " " .. itemLink
	end
end

function Geary_Item:_getItemInlineTexture(itemLink)
	local size = Geary_Options:getLogFontHeight()
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
		slot = nil,
		link = nil,
		id = nil,
		name = nil,
		quality = nil,
		iLevel = 0,
		iType = nil,
		subType = nil,
		invType = nil,
		texture = nil,
		inlineTexture = nil,
		filledSockets = {},
		emptySockets = {},
		failedJewelIds = {},
		isMissingBeltBuckle = false,
		canEnchant = false,
		enchantText = nil,
		upgradeLevel = 0,
		upgradeMax = 0,
		upgradeItemLevelMissing = 0,
		isShaTouched = false,
		hasEotbp = false,
		isMissingEotbp = false,
		hasCohMeta = false,
		isMissingCohMeta = false,
		hasCov = false,
		isMissingCov = false
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

function Geary_Item:probe(player)
	if self.link == nil then
		error("Cannot probe item without link")
		return false
	end
	
	if self.slot == nil then
		error("Cannot probe item without slot")
		return false
	end
	
	-- Workaround an item link bug with the signed suffixId being unsigned in the link
	self.link = self:_itemLinkSuffixIdBugWorkaround(self.link)
	
	-- Get base item info
	self.id = tonumber(self.link:match("|Hitem:(%d+):"))
	self.canEnchant = _slotDetails[self.slot].canEnchant
	self.name, _, self.quality, _, _, self.iType, self.subType, _, self.invType, self.texture, _ =
		GetItemInfo(self.link)
	self.inlineTexture = self:_getItemInlineTexture(self.link)

	-- Parse data from the item's tooltip
	self:_parseTooltip()
	
	-- Ensure we got the data we should have
	-- Note that this also covers the case when the Server fails to send us any tooltip information
	if self.iLevel < 1 then
		Geary:log(Geary.CC_FAILED .. self.slot .. " item has no item level in " .. self.link ..
			Geary.CC_END)
		return false
	end

	-- Get socketed gem information
	self:_getGems(self.slot)

	-- Check for special cases wrt gems
	if self.slot == "WaistSlot" then
		self.isMissingBeltBuckle = self:_isMissingExtraGem()
	end

	if self:canHaveEotbp(player) then
		self.isMissingEotbp = self:_isMissingExtraGem()
		self.hasEotbp = not self.isMissingEotbp
	end

	if self:canHaveCohMeta(player) then
		self.isMissingCohMeta = not self.hasCohMeta
	end
	
	if self.slot == "BackSlot" and self:canHaveCov(player) then
		self.hasCov = self:isCov()
		self.isMissingCov = not self.hasCov
	end

	-- Report info about the item
	Geary:log(("%s %s %s %s %s"):format(self:iLevelWithUpgrades(), self:getItemLinkWithInlineTexture(),
		self.slot:gsub("Slot$", ""), self.iType, self.subType))
	
	for _, text in pairs(self.emptySockets) do
		Geary:log(Geary.CC_MISSING .. "   No gem in " .. text .. Geary.CC_END)
	end

	for _, itemLink in pairs(self.filledSockets) do
		Geary:log(Geary.CC_CORRECT .. "   Gem " .. self:getGemLinkWithInlineTexture(itemLink) .. Geary.CC_END)
	end

	for socketIndex, _ in ipairs(self.failedJewelIds) do
		Geary:log(Geary.CC_FAILED .. "   Failed to get gem in socket " .. socketIndex .. Geary.CC_END)
	end
	
	if self.enchantText ~= nil then
		Geary:log(Geary.CC_CORRECT .. "   " .. self.enchantText .. Geary.CC_END)
	elseif self.canEnchant then
		Geary:log(Geary.CC_MISSING .. "   Missing enchant!" .. Geary.CC_END)
	end
	
	if self.isMissingBeltBuckle then
		Geary:log(Geary.CC_MISSING .. "   Missing " .. self:getBeltBuckleItemWithTexture() .. Geary.CC_END)
	end
	if self.isMissingEotbp then
		Geary:log(Geary.CC_OPTIONAL .. "   Missing " .. self:getEotbpItemWithTexture() .. Geary.CC_END)
	end
	if self.isMissingCohMeta then
		Geary:log(Geary.CC_OPTIONAL .. "   Missing Crown of Heaven legendary meta gem" ..
			Geary.CC_END)
	end
	if self.isMissingCov then
		Geary:log(Geary.CC_OPTIONAL .. "   Missing Cloak of Virtue" .. Geary.CC_END)
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

-- Build search strings using Blizzard localized strings outside of functions so they are done once
-- ITEM_LEVEL = "Item Level %d"
local _itemLevelRegex = "^%s*" .. ITEM_LEVEL:gsub("%%d", "(%%d+)")
-- ITEM_UPGRADE_TOOLTIP_FORMAT = "Upgrade Level: %d/%d"
local _upgradeLevelRegex = "^%s*" .. ITEM_UPGRADE_TOOLTIP_FORMAT:gsub("%%d", "(%%d+)")
-- EMPTY_SOCKET_HYDRAULIC = "Sha-Touched"
local _shaTouchedString = '"' .. EMPTY_SOCKET_HYDRAULIC .. '"'
-- ENCHANTED_TOOLTIP_LINE = "Enchanted: %s"
local _enchantedRegex = "^%s*" .. ENCHANTED_TOOLTIP_LINE:gsub("%%s", "")

function Geary_Item:_parseTooltip()

	-- Ensure owner is set (ClearLines unsets owner)
	-- ANCHOR_NONE without setting any points means it's never rendered
	self.tooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')

	-- Build tooltip for item
	-- Note that SetHyperlink on the same item link twice in a row closes the tooltip
	-- which deletes its content; so we ClearLines when done
	self.tooltip:SetHyperlink(self.link)

	-- Parase the left side text (right side text isn't useful)
	for lineNum = 1, self.tooltip:NumLines() do
		(function ()  -- Function so we can use return as "continue"
			local text = _G["Geary_Tooltip_ScannerTextLeft" .. lineNum]:GetText()
			-- Eat any color codes (e.g. gem stats have them)
			text = text:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
			Geary:debugLog(text)
			
			local iLevel = text:match(_itemLevelRegex)
			if iLevel then
				self:_setItemLevel(tonumber(iLevel))
				return  -- "continue"
			end
			
			local upgradeLevel, upgradeMax = text:match(_upgradeLevelRegex)
			if upgradeLevel and upgradeMax then
				self:_setUpgrades(tonumber(upgradeLevel), tonumber(upgradeMax))
				return  -- "continue"
			end
			
			if text:match(_enchantedRegex) then
				self:_setEnchantText(text)
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
		end)()
	end

	-- Clear the tooltip's content (which also clears its owner)
	self.tooltip:ClearLines()
end

function Geary_Item:_getGems(slot)
	-- Get jewelIds from the item link
	local jewelId = {}
	jewelId[1], jewelId[2], jewelId[3], jewelId[4] =
		self.link:match("item:.-:.-:(.-):(.-):(.-):(.-):")

	-- Check all sockets for a gem
	for socketIndex = 1, Geary.MAX_GEMS do
		local itemName, itemLink = GetItemGem(self.link, socketIndex)
		if itemLink == nil then
			if jewelId[socketIndex] ~= nil and tonumber(jewelId[socketIndex]) ~= 0 then
				-- GetItemGem returned nil because the gem is not in the player's local cache
				self.failedJewelIds[socketIndex] = jewelId[socketIndex]
				Geary:debugLog(("GetItemGem(%s, %i) returned nil when link had %d"):format(
					self.link:gsub("|", "||"), socketIndex, tonumber(jewelId[socketIndex])))
			end
		else
			if slot == "HeadSlot" then
				-- Head slot item, so look for the legendary meta gem
				local gemQuality = select(3, GetItemInfo(itemLink))
				if gemQuality == nil then
					-- Not sure this is possible, but check it to be safe
					-- We failed to get the gem's quality from its link, so count it as failed
					self.failedJewelIds[socketIndex] = jewelId[socketIndex]
					Geary:debugLog("Failed to get item quality from gem", itemLink)
				else
					if gemQuality == ITEM_QUALITY_LEGENDARY then
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

function Geary_Item:_setItemLevel(iLevel)
	if self.iLevel > 0 then
		Geary:print(Geary.CC_ERROR .. "ERROR: Multiple item levels found on " .. self.link .. Geary.CC_END)
	else
		self.iLevel = iLevel
	end
end

function Geary_Item:_setUpgrades(upgradeLevel, upgradeMax)
	if self.upgradeLevel > 0 or self.upgradeMax > 0 then
		Geary:print(Geary.CC_ERROR .. "ERROR: Multiple upgrade levels found on " .. self.link ..
			Geary.CC_END)
	else
		self.upgradeLevel = upgradeLevel
		self.upgradeMax = upgradeMax
		if upgradeLevel < upgradeMax then
			if self.quality <= ITEM_QUALITY_RARE then
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
		Geary:print(Geary.CC_ERROR .. "ERROR: Multiple enchants found on " .. self.link .. Geary.CC_END)
	else
		self.enchantText = enchantText
	end
end

-- Per http://wow.curseforge.com/addons/geary/tickets/1-does-not-detect-belt-buckle-if-no-gem-is-in-it/
-- there is no good way to check for an extra socket from a belt buckle or Eye of the Black Prince,
-- so instead we look for gems in the extra socket. By comparing the number of sockets in the BASE item
-- versus the number of gems and sockets in THIS item, we can tell if there is an extra gem.
-- Note: This is tooltip parsing similar to the full parse, but we just care about empty sockets.
function Geary_Item:_isMissingExtraGem()

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
		(function ()  -- Function so we can use return as "continue"
			local text = _G["Geary_Tooltip_ScannerTextLeft" .. lineNum]:GetText()
			Geary:debugLog("extra gem:", text)
			
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
	Geary:debugLog(("extra gem: filled=%i, failed=%i, empty=%i, base=%i"):format(
		Geary:tableSize(self.filledSockets), Geary:tableSize(self.failedJewelIds),
		Geary:tableSize(self.emptySockets), baseSocketCount))
	if Geary:tableSize(self.filledSockets) + Geary:tableSize(self.failedJewelIds) +
		Geary:tableSize(self.emptySockets) <= baseSocketCount
	then
		return true
	else
		return false
	end
end