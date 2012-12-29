--[[
	Geary item details
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Item = {
	tooltip = CreateFrame("GameTooltip", "Geary_Tooltip_Scanner", UIParent, "GameTooltipTemplate")
}

-- Details of all slots and what they can contain
local slotDetails = {
	HeadSlot = {
		slotNumber = nil,
		canEnchant = false
	},
	NeckSlot = {
		slotNumber = nil,
		canEnchant = false
	},
	ShoulderSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	BackSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	ChestSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	WaistSlot = {
		slotNumber = nil,
		canEnchant = false  -- TODO Does belt buckle count as an enchant?
	},
	LegsSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	FeetSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	WristSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	HandsSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	Finger0Slot = {
		slotNumber = nil,
		canEnchant = false  -- TODO Must handle enchanter enchants
	},
	Finger1Slot = {
		slotNumber = nil,
		canEnchant = false  -- TODO Must handle enchanter enchants
	},
	Trinket0Slot = {
		slotNumber = nil,
		canEnchant = false
	},
	Trinket1Slot = {
		slotNumber = nil,
		canEnchant = false
	},
	MainHandSlot = {
		slotNumber = nil,
		canEnchant = true
	},
	SecondaryHandSlot = {
		slotNumber = nil,
		canEnchant = true
	}
}

-- Names of empty gem sockets in tooltips
-- TODO Make these locale specific Blizzard strings
local socketNames = {
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
	local slotName, slotData
	for slotName, slotData in pairs(slotDetails) do
		slotData.slotNumber, _ = GetInventorySlotInfo(slotName)
	end
end

function Geary_Item:getInvSlots()
	local slots = {}
	for slotName, slotData in pairs(slotDetails) do
		slots[slotData.slotNumber] = slotName
	end
	return slots
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
		name = nil,
		rarity = nil,
		iLevel = 0,
		iType = nil,
		subType = nil,
		filledSockets = {},
		emptySockets = {},
		canEnchant = false,
		enchantText = nil,
		upgradeLevel = 0,
		upgradeMax = 0,
		upgradeItemLevelMissing = 0
	}
	if o then
		local name, value
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

	-- Get base item info
	self.canEnchant = slotDetails[self.slot].canEnchant
	self.name, _, self.rarity, _, _, self.iType, self.subType, _, _, _, _ = GetItemInfo(self.link)

	-- Parse data from the item's tooltip
	self:_parseTooltip()
	
	-- Get socketed gem information
	self:_getGems()

	-- Ensure we got the data we should have
	if self.iLevel < 1 then
		Geary:print(RED_FONT_COLOR_CODE .. "ERROR: No item level found in " .. self.link ..
			FONT_COLOR_CODE_CLOSE)
	end

	-- Report info about the item
	Geary:log(("%s %s %s %s %s"):format(self:iLevelWithUpgrades(), self.link, 
		self.slot:gsub("Slot$", ""), self.iType, self.subType))
	
	local text
	for _, text in pairs(self.emptySockets) do
		-- TODO Abstract colors to constants or methods
		Geary:log("   No gem in " .. text, 1, 0, 0)
	end

	for _, text in pairs(self.filledSockets) do
		-- TODO Abstract colors to constants or methods
		Geary:log("   Gem " .. text, 0, 1, 0)
	end

	if self.enchantText ~= nil then
		-- TODO Abstract colors to constants or methods
		Geary:log("   " .. self.enchantText, 0, 1, 0)
	elseif self.canEnchant then
		-- TODO Abstract colors to constants or methods
		Geary:log("   Missing enchant!", 1, 0, 0)
	end
end

function Geary_Item:_parseTooltip()

	-- Ensure owner is set (ClearLines unsets owner)
	-- ANCHOR_NONE without setting any points means it's never rendered
	self.tooltip:SetOwner(UIParent, 'ANCHOR_NONE')

	-- Build tooltip for item
	-- Note that SetHyperlink on the same item link twice in a row closes the tooltip
	-- which deletes its content; so we ClearLines when done
	self.tooltip:SetHyperlink(self.link)

	-- Parase the left side text (right side text isn't useful)
	local lineNum, socketName
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

			for _, socketName in pairs(socketNames) do
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
	local socketIndex
	for socketIndex = 1, 4, 1 do
		local itemName, itemLink = GetItemGem(self.link, socketIndex)
		if itemName ~= nil then
			tinsert(self.filledSockets, itemLink)
		end
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