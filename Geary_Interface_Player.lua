--[[
	Geary player interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Player = {
	mainFrame = nil,
	unavailFontString = nil,
	paperDoll = {
		frame = nil,
		model = nil,
		hasPlayer = false,
		slots = {
			HeadSlot          = { side = "left",  frame = nil, icon = nil, item = nil },
			NeckSlot          = { side = "left",  frame = nil, icon = nil, item = nil },
			ShoulderSlot      = { side = "left",  frame = nil, icon = nil, item = nil },
			BackSlot          = { side = "left",  frame = nil, icon = nil, item = nil },
			ChestSlot         = { side = "left",  frame = nil, icon = nil, item = nil },
			WristSlot         = { side = "left",  frame = nil, icon = nil, item = nil },
			HandsSlot         = { side = "right", frame = nil, icon = nil, item = nil },
			WaistSlot         = { side = "right", frame = nil, icon = nil, item = nil },
			LegsSlot          = { side = "right", frame = nil, icon = nil, item = nil },
			FeetSlot          = { side = "right", frame = nil, icon = nil, item = nil },
			Finger0Slot       = { side = "right", frame = nil, icon = nil, item = nil },
			Finger1Slot       = { side = "right", frame = nil, icon = nil, item = nil },
			Trinket0Slot      = { side = "right", frame = nil, icon = nil, item = nil },
			Trinket1Slot      = { side = "right", frame = nil, icon = nil, item = nil },
			MainHandSlot      = { side = "left",  frame = nil, icon = nil, item = nil },
			SecondaryHandSlot = { side = "left",  frame = nil, icon = nil, item = nil }
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

	self:initPaperDoll(self.mainFrame)

	Geary_Interface:createTab("Player",
		function () Geary_Interface_Player:Show() end,
		function () Geary_Interface_Player:Hide() end
	)
end

function Geary_Interface_Player:initPaperDoll(parent)
	local frame = CreateFrame("Frame", "$parent_PaperDollFrame", parent)
	frame:Hide()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT")
	frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -186, 0)
	self.paperDoll.frame = frame

	self:initModel(self.paperDoll.frame)
	self:initSlots(self.paperDoll.frame)
end

function Geary_Interface_Player:initModel(parent)

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

function Geary_Interface_Player:initSlots(parent)

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
		
		if self.paperDoll.slots[slotName].side == "left" then
			if lastLeft then
				frame:SetPoint("TOPLEFT", lastLeft, "BOTTOMLEFT", 0, 2)
			else
				frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -2)
			end
			lastLeft = frame
		elseif self.paperDoll.slots[slotName].side == "right" then
			if lastRight then
				frame:SetPoint("TOPRIGHT", lastRight, "BOTTOMRIGHT", 0, 2)
			else
				frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -2)
			end
			lastRight = frame
		end
		
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
		
		self.paperDoll.slots[slotName].frame = frame
	end
end

function Geary_Interface_Player:clear()
	self.paperDoll.hasPlayer = false
	self.paperDoll.model:ClearModel()
	for slotName, slotData in pairs(self.paperDoll.slots) do
		slotData.item = nil
		slotData.icon:Hide()
		self:_setItemBorder(slotName, nil)
	end
	if self.mainFrame:IsVisible() then
		self:Show()
	end
end

function Geary_Interface_Player:setModel(unit)
	if unit ~= nil then
		SetPaperDollBackground(self.paperDoll.model, unit)
		self.paperDoll.model:SetUnit(unit)
		self.paperDoll.hasPlayer = true
	else
		self.paperDoll.hasPlayer = false
	end
	if self.mainFrame:IsVisible() then
		self:Show()
	end
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
end

function Geary_Interface_Player:_setItemBorder(slotName, item)
	if item == nil then
		self.paperDoll.slots[slotName].frame:SetBackdropBorderColor(0, 0, 0, 0)
	else
		local r, g, b, _ = GetItemQualityColor(item.quality)
		self.paperDoll.slots[slotName].frame:SetBackdropBorderColor(r, g, b, 1)
	end
end

function Geary_Interface_Player:markMissingItems()
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
			end
		end
	end
end

function Geary_Interface_Player:Show()
	if self.paperDoll.hasPlayer then
		self.paperDoll.frame:Show()
		self.unavailFontString:Hide()
	else
		self.paperDoll.frame:Hide()
		self.unavailFontString:Show()
	end
	self.mainFrame:Show()
end

function Geary_Interface_Player:Hide()
	self.mainFrame:Hide()
end