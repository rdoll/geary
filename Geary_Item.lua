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
	"Meta Socket",
	"Blue Socket",
	"Red Socket",
	"Yellow Socket",
	"Prismatic Socket",
	"Cogwheel Socket",
	"Sha-Touched"
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

function Geary_Item:isMissingRequired()
	return self.iLevel == 0 or #self.emptySockets > 0 or #self.failedJewelIds > 0 or
		(self.canEnchant and self.enchantText == nil) or self.isMissingBeltBuckle or
		self.isMissingEotbp
end

function Geary_Item:isMissingOptional()
	return self.upgradeItemLevelMissing > 0
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
		isMissingEotbp = false
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
	self.name, _, self.quality, _, _, self.iType, self.subType, _, _, self.texture, _ = GetItemInfo(self.link)
	self.inlineTexture = self:_getItemInlineTexture(self.link)

	-- Parse data from the item's tooltip
	self:_parseTooltip()
	
	-- Get socketed gem information
	self:_getGems()

	-- If this item can have an extra gem in it, check for it
	if self.slot == "WaistSlot" then
		self.isMissingBeltBuckle = self:_isMissingExtraGem()
	end
	if self.isShaTouched then
		self.isMissingEotbp = self:_isMissingExtraGem()
	end
	
	-- Ensure we got the data we should have
	if self.iLevel < 1 then
		Geary:print(Geary.CC_ERROR .. "ERROR: No item level found in " .. self.link .. Geary.CC_END)
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
		Geary:log(Geary.CC_MISSING .. "   Missing " .. self:getEotbpItemWithTexture() .. Geary.CC_END)
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
	for lineNum = 1, self.tooltip:NumLines() do
		(function ()  -- Function so we can use return as "continue"
			local text = _G["Geary_Tooltip_ScannerTextLeft" .. lineNum]:GetText()
			-- Eat any color codes (e.g. gem stats have them)
			text = text:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
			Geary:debugLog(text)
			
			local iLevel = text:match("^%s*Item Level%s+(%d+)")
			if iLevel then
				self:_setItemLevel(tonumber(iLevel))
				return  -- "continue"
			end
			
			local upgradeLevel, upgradeMax = text:match("^%s*Upgrade Level:%s+(%d+)/(%d+)")
			if upgradeLevel and upgradeMax then
				self:_setUpgrades(tonumber(upgradeLevel), tonumber(upgradeMax))
				return  -- "continue"
			end
			
			if text:match("^%s*Enchanted:") then
				self:_setEnchantText(text)
				return  -- "continue"
			end

			if text == '"Sha-Touched"' then
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

function Geary_Item:_getGems()
	-- Get jewelIds from the item link
	local jewelId = {}
	jewelId[1], jewelId[2], jewelId[3], jewelId[4] =
		self.link:match("item:.-:.-:(.-):(.-):(.-):(.-):")

	-- Check all sockets for a gem
	for socketIndex = 1, 4 do
		local itemName, itemLink = GetItemGem(self.link, socketIndex)
		if itemLink == nil then
			if jewelId[socketIndex] ~= nil and tonumber(jewelId[socketIndex]) ~= 0 then
				-- GetItemGem returned nil because the gem is not in the player's local cache
				self.failedJewelIds[socketIndex] = jewelId[socketIndex]
				Geary:debugLog(("GetItemGem(%s, %i) returned nil when link had %d"):format(
					self.link:gsub("|", "||"), socketIndex, tonumber(jewelId[socketIndex])))
			end
		else
			tinsert(self.filledSockets, itemLink)
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

-- There is no good way to check for an extra gem from a belt buckle or Eye of the Black Prince.
-- What we do is count the gems in the BASE item and compare that with the number of gems
-- in THIS item. If THIS item doesn't have one more gem than the BASE item, it doesn't have
-- an extra gem (or it has a belt buckle/EotBP socket with no gem in it).
-- Note: This is tooltip parsing similar to the full parse, but we just care about empty sockets.
function Geary_Item:_isMissingExtraGem()

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
	Geary:debugLog(("extra gem: filled=%i, failed=%i, empty=%i, base=%i"):format(#self.filledSockets,
		#self.failedJewelIds, #self.emptySockets, baseSocketCount))
	if #self.filledSockets + #self.failedJewelIds + #self.emptySockets <= baseSocketCount then
		return true
	else
		return false
	end
end