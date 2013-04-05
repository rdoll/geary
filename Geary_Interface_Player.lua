--[[
	Geary player interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Player = {
	mainFrame = nil,
	summary = nil,
	unavailFontString = nil,
	paperDoll = {
		frame = nil,
		model = nil,
		hasPlayer = false,
		slots = {
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

function Geary_Interface_Player:init(parent)

	local frame = CreateFrame("Frame", "$parent_Frame", parent)
	frame:Hide()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT")
	frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT")
	self.mainFrame = frame

	local fontString = self.mainFrame:CreateFontString("$parent_UnavailFontString", "ARTWORK",
		"GameFontNormal")
	fontString:Hide()
	fontString:SetPoint("CENTER", self.mainFrame, "CENTER")
	fontString:SetText("No inspection details available")
	self.unavailFontString = fontString

	self:_initPaperDoll(self.mainFrame)
	self:_initSummary(self.mainFrame, self.paperDoll.frame)

	Geary_Interface:createTab("Player",
		function () Geary_Interface_Player:Show() end,
		function () Geary_Interface_Player:Hide() end
	)
end

function Geary_Interface_Player:_initPaperDoll(parent)
	local frame = CreateFrame("Frame", "$parent_PaperDollFrame", parent)
	frame:Hide()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT")
	frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -186, 0)
	self.paperDoll.frame = frame

	self:_initModel(self.paperDoll.frame)
	self:_initSlots(self.paperDoll.frame)
end

function Geary_Interface_Player:_initModel(parent)

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
	
	Model_OnLoad(model, MODELFRAME_MAX_PLAYER_ZOOM, nil, nil,
		function (self, button) Model_OnMouseUp(self, button) end)

	self.paperDoll.model = model
end

function Geary_Interface_Player:_initSlots(parent)

	local lastLeft, lastRight
	for _, slotName in ipairs(Geary_Item:getInvSlotsInOrder()) do

		local frame = CreateFrame("Frame", "$parent_" .. slotName .. "_Frame", parent)
		frame.emptyTooltip = _G[slotName:upper()]
		frame.paperDollSide = self.paperDoll.slots[slotName].side
		frame.slotData = self.paperDoll.slots[slotName]
		frame:SetSize(37, 37)
		frame:SetBackdrop({
			bgFile   = _G["Character" .. slotName .. "IconTexture"]:GetTexture(),
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile     = false,
			edgeSize = 16,
			insets   = { left = 3, right = 3, top = 3, bottom = 3 }
		})
				
		local icon = frame:CreateTexture("$parent_Icon", "ARTWORK")
		icon:Hide()
		icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -3)
		icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)
		self.paperDoll.slots[slotName].icon = icon
		
		local info = CreateFrame("Frame", "$parent_" .. slotName .. "_Info", parent)
		info:SetWidth(46)
		info:SetBackdrop({
			bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
			tile     = true,
			tileSize = 64,
			insets   = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		info:SetBackdropColor(0, 0, 0, 0)  -- Default to no background
		info:SetFrameStrata("HIGH")
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
		for gemIndex = 1, 4 do
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

		info:SetScript("OnEnter", function (self)
			-- TODO Allow setting the font type/size via options
			if self.tooltip ~= nil then
				if self.side == "left" then
					GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
				elseif self.side == "right" then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
				else
					Geary:print(Geary.CC_ERROR .. "Unknown info side '" ..
						(self.side == nil and "nil" or self.side) .. "'" .. Geary.CC_END)
				end
				GameTooltip:SetText(self.tooltip)
			end
		end)
		info:SetScript("OnLeave", function (self)
			GameTooltip:Hide()
		end)
		
		self.paperDoll.slots[slotName].info = info

		frame:SetScript("OnEnter", function (self)
			-- Anchor the tooltip to the left or right of the icon so it doesn't cover the paper doll
			if self.paperDollSide == "left" then
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, self:GetHeight())
			elseif self.paperDollSide == "right" then
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, self:GetHeight())
			else
				Geary:print(Geary.CC_ERROR .. "Unknown paperDollSide '" ..
					(self.paperDollSide == nil and "nil" or self.paperDollSide) .. "'" .. Geary.CC_END)
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			end
			if self.slotData.item == nil then
				GameTooltip:SetText(self.emptyTooltip)
			else
				GameTooltip:SetHyperlink(self.slotData.item.link)
			end
			GameTooltip:Show()
		end)
		frame:SetScript("OnLeave", function (self)
			GameTooltip:Hide()
		end)
		frame:SetScript("OnMouseDown", function (self)
			if self.slotData.item ~= nil then
				HandleModifiedItemClick(self.slotData.item.link)
			end
		end)
		
		self.paperDoll.slots[slotName].frame = frame
	end
end

function Geary_Interface_Player:_initSummary(parent, paperDollFrame)

	local frame = CreateFrame("Frame", "$parent_Summary", parent)
	frame:Hide()
	frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, -4)
	frame:SetPoint("BOTTOMLEFT", paperDollFrame, "BOTTOMRIGHT", 4, 4)
	
	local fontString = frame:CreateFontString("$parent_FontString", "ARTWORK")
	fontString:SetFont("Fonts\\FRIZQT__.TTF", 10)
	fontString:SetJustifyV("TOP")
	fontString:SetJustifyH("CENTER")
	fontString:SetPoint("TOPLEFT", frame, "TOPLEFT")
	fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	frame.fontString = fontString

	self.summary = frame
end

function Geary_Interface_Player:clear()

	self.paperDoll.hasPlayer = false
	self.paperDoll.model:ClearModel()
	self.summary.fontString:SetText("")

	for slotName, slotData in pairs(self.paperDoll.slots) do
		slotData.item = nil
		slotData.info:SetBackdropColor(0, 0, 0, 0)
		slotData.info.tooltip = nil
		slotData.info.fontString:SetText("")
		slotData.info.enchantTexture:SetTexture(0, 0, 0, 0)
		for gemIndex = 1, 4 do
			slotData.info.gemTextures[gemIndex]:SetTexture(0, 0, 0, 0)
		end
		slotData.icon:Hide()
		self:_setItemBorder(slotName, nil)
	end

	if self.mainFrame:IsVisible() then
		self:Show()
	end
end

function Geary_Interface_Player:inspectionStart(inspect)

	self.paperDoll.hasPlayer = true

	SetPaperDollBackground(self.paperDoll.model, inspect.player.unit)
	self.paperDoll.model:SetUnit(inspect.player.unit)

	-- TODO Hyperlinks don't seem to work here
	-- TODO This is duplicated work from Geary_Inspect and some of it is private (e.g. milestones)
	self.summary.fontString:SetFormattedText(
		"\n" ..
		"--- %s %s ---\n" ..
		"%i %s %s\n" ..
		"\n" ..
		"\n" ..
		"Inspection in progress...",
		inspect.player:getFactionInlineIcon(), inspect.player:getFullNameLink(),
		inspect.player.level, inspect.player:getColorizedClassName(), inspect.player:getSpecWithInlineIcon()
	)
	
	if self.mainFrame:IsVisible() then
		self:Show()
	end
end

function Geary_Interface_Player:inspectionEnd(inspect)

	self:_markMissingItems()

	-- TODO This is duplicated work from Geary_Inspect using private data

	local milestoneLevel, milestoneName = inspect:getItemLevelMilestone()
	local milestone = ""
	if milestoneLevel ~= nil then
		milestone = Geary.CC_MILESTONE .. "Until " .. milestoneName .. ": " .. milestoneLevel ..
			" iLevels" .. Geary.CC_END
	end

	local upgrades = "\n"
	if inspect.upgradeItemLevelMissing > 0 then
		upgrades = Geary.CC_UPGRADE .. ("Max possible iLevel: %.2f\nUpgrades: %i of %i filled"):format(
			(inspect.iLevelTotal + inspect.upgradeItemLevelMissing) / inspect.itemCount,
			inspect.upgradeLevel, inspect.upgradeMax) .. Geary.CC_END
	elseif inspect.upgradeMax > 0 then
		upgrades = "\n" .. Geary.CC_CORRECT .. "All item upgrades filled" .. Geary.CC_END
	end

	local emptySlots = ""
	if inspect.emptySlots > 0 then
		emptySlots = Geary.CC_ERROR .. "Empty slots: " .. inspect.emptySlots .. Geary.CC_END
	end

	local failedSlots = ""
	if inspect.failedSlots > 0 then
		failedSlots = Geary.CC_FAILED .. "Failed slots: " .. inspect.failedSlots .. Geary.CC_END
	end

	local enchantStatus = ""
	if inspect.unenchantedCount > 0 then
		enchantStatus = Geary.CC_MISSING .. "Missing enchants: " .. inspect.unenchantedCount .. " items" ..
			Geary.CC_END
	elseif inspect.enchantedCount > 0 then
		enchantStatus = Geary.CC_CORRECT .. "All items enchanted" .. Geary.CC_END
	end

	local socketStatus = ""
	if inspect.emptySockets > 0 then
		socketStatus = Geary.CC_MISSING .. "Empty sockets: " .. inspect.emptySockets .. Geary.CC_END
	elseif inspect.filledSockets > 0 then
		socketStatus = Geary.CC_CORRECT .. "All sockets filled" .. Geary.CC_END
	end
	
	local failedJewels = ""
	if inspect.failedJewelIds > 0 then
		failedJewels = Geary.CC_FAILED .. "Failed gems: " .. inspect.failedJewelIds .. Geary.CC_END
	end	
	
	local missingBeltBuckle = ""
	if inspect.isMissingBeltBuckle then
		missingBeltBuckle = Geary.CC_MISSING .. "Missing belt buckle" .. Geary.CC_END
	end
	
	local missingEotBP = ""
	if inspect.missingEotbpCount > 0 then
		missingEotBP = Geary.CC_MISSING .. "Missing " .. inspect.missingEotbpCount .. " EotBP" ..
			Geary.CC_END
	end
	
	local lowestItem = ""
	if inspect.minItem ~= nil then
		lowestItem = "Lowest item: " .. inspect.minItem:iLevelWithUpgrades() .. " " ..
			inspect.minItem.inlineTexture
	end

	local highestItem = ""
	if inspect.maxItem ~= nil then
		highestItem = "Highest item: " .. inspect.maxItem:iLevelWithUpgrades() .. " " ..
			inspect.maxItem.inlineTexture
	end
	
	-- TODO Hyperlinks don't seem to work here
	self.summary.fontString:SetFormattedText(
		"\n" ..
		"--- %s %s ---\n" ..  -- Player name and faction
		"%i %s %s\n" ..  -- Level, class, and spec
		"\n" ..
		"\n" ..
		"Equipped iLevel: %.2f\n" ..  -- Equipped iLevel
		"\n" ..
		"%s\n" ..  -- Milestone (if any)
		"\n" ..
		"%s\n" ..  -- Upgrades (2 lines, if any)
		"\n" ..
		"%s\n" ..  -- Empty slots
		"%s\n" ..  -- Failed slots
		"\n" ..
		"%s\n" ..  -- Missing/all enchants
		"\n" ..
		"%s\n" ..  -- Empty/filled sockets
		"%s\n" ..  -- Failed jewels (if any)
		"%s\n" ..  -- Missing belt buckle (if one)
		"%s\n" ..  -- Missing EotBP (if any)
		"\n" ..
		"%s\n" ..  -- Lowest item (if any)
		"%s",      -- Highest item (if any)
		inspect.player:getFactionInlineIcon(), inspect.player:getFullNameLink(),
		inspect.player.level, inspect.player:getColorizedClassName(), inspect.player:getSpecWithInlineIcon(),
		inspect.iLevelEquipped,
		milestone,
		upgrades,
		emptySlots,
		failedSlots,
		enchantStatus,
		socketStatus,
		failedJewels,
		missingBeltBuckle,
		missingEotBP,
		lowestItem,
		highestItem
	)
	
	-- I believe this makes a link with the ilevel and texture, but links don't work in the fontString
	-- inspect.minItem.link:gsub("[|]h.-[|]h", "|h" .. inspect.minItem:iLevelWithUpgrades() .. " " ..
	--			inspect.minItem.inlineTexture .. "|h")
end

function Geary_Interface_Player:setItem(slotName, item)

	if self.paperDoll.slots[slotName] == nil then
		Geary:print(Geary.CC_FAILED .. "Invalid slotName", slotName, "for paper doll" .. Geary.CC_END)
		return
	end
	
	local slotData = self.paperDoll.slots[slotName]
	
	if slotData.item ~= nil and slotData.item.link == item.link then
		Geary:debugPrint(Geary.CC_DEBUG .. "Paper doll slot", slotName, "already", item.link .. Geary.CC_END)
		return
	end

	slotData.item = item
	
	slotData.icon:SetTexture(item.texture)
	slotData.icon:Show()
	self:_setItemBorder(slotName, item)
	
	self:_addInfoTooltipText(slotData.info, item:iLevelWithUpgrades() .. " " .. 
		item:getItemLinkWithInlineTexture())
	slotData.info.fontString:SetText(item:iLevelWithUpgrades())
	self:_setEnchantIcon(slotData.info, item)
	self:_setGemIcons(slotData.info, item)
	
	-- Set the background color based on any issues with this item
	if item:isMissingRequired() then
		slotData.info:SetBackdropColor(1, 0, 0, 0.5)
	elseif item:isMissingOptional() then
		slotData.info:SetBackdropColor(1, 1, 0, 0.5)
	else
		slotData.info:SetBackdropColor(0, 0, 0, 0)
	end
end

function Geary_Interface_Player:_setEnchantIcon(info, item)
	if item.enchantText == nil then
		if item.canEnchant then
			info.enchantTexture:SetTexture("Interface\\COMMON\\Indicator-Red")
			info.enchantTexture:SetTexCoord(0.125, 0.875, 0.125, 0.875)
			self:_addInfoTooltipText(info, Geary.CC_ERROR .. "Missing enchant" .. Geary.CC_END)
		else
			info.enchantTexture:SetTexture(0, 0, 0, 0)
		end
	else
		info.enchantTexture:SetTexture("Interface\\ICONS\\inv_misc_enchantedscroll")
		self:_addInfoTooltipText(info, Geary.CC_CORRECT .. item.enchantText .. Geary.CC_END)
	end
end

function Geary_Interface_Player:_setGemIcons(info, item)
	local gemTextureIndex = 1
	
	-- Clear all
	for gemNum = 1, 4 do
		info.gemTextures[gemTextureIndex]:SetTexture(0, 0, 0, 0)
	end
	
	-- Filled gems
	for gemNum = 1, #item.filledSockets do
		local texture = select(10, GetItemInfo(item.filledSockets[gemNum]))
		if texture == nil then
			-- Generic failsafe
			texture = "Interface\\ICONS\\INV_Misc_Gem_Variety_01"
		end
		info.gemTextures[gemTextureIndex]:SetTexture(texture)
		self:_addInfoTooltipText(info, Geary.CC_CORRECT .. "Gem " .. Geary.CC_END ..
			Geary_Item:getGemLinkWithInlineTexture(item.filledSockets[gemNum]))
		gemTextureIndex = gemTextureIndex + 1
	end

	-- Missing gems
	for gemNum = 1, #item.emptySockets do
		info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Red")
		info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		self:_addInfoTooltipText(info, Geary.CC_ERROR .. "Empty " .. item.emptySockets[gemNum] ..
			" socket" .. Geary.CC_END)
		gemTextureIndex = gemTextureIndex + 1
	end
	
	-- Failed gems
	for gemNum = 1, #item.failedJewelIds do
		info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Red")
		info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		self:_addInfoTooltipText(info, Geary.CC_FAILED .. "Failed to get gem details" .. Geary.CC_END)
		gemTextureIndex = gemTextureIndex + 1
	end
	
	-- Missing belt buckle
	if item.isMissingBeltBuckle then
		info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Red")
		info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		self:_addInfoTooltipText(info, Geary.CC_ERROR .. "Missing " ..
			Geary_Item:getBeltBuckleItemWithTexture() .. Geary.CC_END)
		gemTextureIndex = gemTextureIndex + 1
	end
	
	-- Missing Eye of the Black Prince
	if item.isMissingEotbp then
		info.gemTextures[gemTextureIndex]:SetTexture("Interface\\COMMON\\Indicator-Red")
		info.gemTextures[gemTextureIndex]:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		self:_addInfoTooltipText(info, Geary.CC_ERROR .. "Missing " ..
			Geary_Item:getEotbpItemWithTexture() .. Geary.CC_END)
		gemTextureIndex = gemTextureIndex + 1
	end
end

function Geary_Interface_Player:_addInfoTooltipText(info, text)
	if info.tooltip == nil then
		info.tooltip = text
	else
		info.tooltip = info.tooltip .. "\n" .. text
	end
end

function Geary_Interface_Player:_setItemBorder(slotName, item)
	-- TODO If the item's probe failed, would be nice to see CC_FAILED color on border
	if item == nil then
		self.paperDoll.slots[slotName].frame:SetBackdropBorderColor(0, 0, 0, 0)
	else
		local r, g, b, _ = GetItemQualityColor(item.quality)
		self.paperDoll.slots[slotName].frame:SetBackdropBorderColor(r, g, b, 1)
	end
end

function Geary_Interface_Player:_markMissingItems()
	local mainHandIsTwoHand = false
	for _, slotName in ipairs(Geary_Item:getInvSlotsInOrder()) do
		local slotData = self.paperDoll.slots[slotName]
		if slotName == "MainHandSlot" and slotData.item ~= nil then
			mainHandIsTwoHand = slotData.item:isTwoHandWeapon()
		end
		if slotData.item == nil then
			if slotName == "SecondaryHandSlot" and mainHandIsTwoHand then
				-- Offhand is NOT considered empty because main hand is a 2Her
				Geary:debugLog(slotName, "not missing because main hand is 2Her")
			else
				self.paperDoll.slots[slotName].frame:SetBackdropBorderColor(1, 0, 0, 1)
				self.paperDoll.slots[slotName].info:SetBackdropColor(1, 0, 0, 0.5)
				self:_addInfoTooltipText(self.paperDoll.slots[slotName].info,
					Geary.CC_ERROR .. slotName .. " is empty" .. Geary.CC_END)
			end
		end
	end
end

function Geary_Interface_Player:Show()
	if self.paperDoll.hasPlayer then
		self.paperDoll.frame:Show()
		self.summary:Show()
		self.unavailFontString:Hide()
	else
		self.paperDoll.frame:Hide()
		self.summary:Hide()
		self.unavailFontString:Show()
	end
	self.mainFrame:Show()
end

function Geary_Interface_Player:Hide()
	self.mainFrame:Hide()
end