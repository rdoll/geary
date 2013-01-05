--[[
	Geary inspection manager
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Inspect = {
	items = {},                         -- Make table once and wipe it in reset
	timerFrame = CreateFrame("Frame"),  -- Frame for timer OnUpdate tick events
	inspectTimeout = 3000,              -- Time in ms to wait before assuming an inspect failed
	inspectTries = 3                    -- Try to get inspect data from server this many times
}

function Geary_Inspect:resetInfo()
	self.inProgress = false
	self.inspectTry = 0
	self.player = nil
end

function Geary_Inspect:resetData()
	self.hasTwoHandWeapon = false
	self.emptySlots = 0
	self.itemCount = 0
	self.iLevelTotal = 0
	self.iLevelEquipped = 0.0
	self.minItem = nil
	self.maxItem = nil
	wipe(self.items)
	self.filledSockets = 0
	self.emptySockets = 0
	self.missingBeltBuckle = false
	self.unenchantedCount = 0
	self.upgradeLevel = 0
	self.upgradeMax = 0
	self.upgradeItemLevelMissing = 0
end

function Geary_Inspect:startTimer(milliseconds)
	self.timerFrame.expires = milliseconds / 1000
	self.timerFrame:SetScript("OnUpdate", self.timerFrame.OnUpdate)
end

function Geary_Inspect:stopTimer()
	self.timerFrame.expires = 0
	self.timerFrame:SetScript("OnUpdate", nil)
end

function Geary_Inspect.timerFrame:OnUpdate(sinceLastUpdate)
	self.expires = self.expires - sinceLastUpdate
	if self.expires <= 0 then
		Geary_Inspect:timerExpired()
	end
end

function Geary_Inspect:timerExpired()
	Geary_Inspect:stopTimer()
	if self.inspectTry < self.inspectTries then
		Geary_Inspect:reinspectRequest()
	else
		Geary_Inspect:inspectionOver()
		Geary:log("Inspection failed after " .. self.inspectTries .. " tries.", 1, 0, 1)
	end
end

function Geary_Inspect:PLAYER_LOGOUT()
	if self.inProgress then
		self:inspectionOver()
		ClearInspectPlayer()
	end
end

function Geary_Inspect:INSPECT_READY(unitGuid)

	if not self.inProgress then
		error("Inspection not in progress! (" .. unitGuid .. ")")
		return
	end
	
	if self.player == nil then
		error("Missing player to inspect! (" .. unitGuid .. ")")
		return
	end

	if self.player.guid ~= unitGuid then
		Geary:debugLog("Skipping inspection of wrong unitGuid " .. unitGuid)
		return
	end

	-- Player's specialization
	self.player:INSPECT_READY()
	
	-- Player inventory
	local slotNumber, slotName
	for slotNumber, slotName in pairs(Geary_Item:getInvSlots()) do
		self.itemCount = self.itemCount + 1
		local itemLink = GetInventoryItemLink(self.player.unit, slotNumber)
		if itemLink == nil then
			if slotName == "SecondaryHandSlot" and self.hasTwoHandWeapon then
				Geary:debugLog(slotName .. " is empty, but using 2Her")
			else
				self.emptySlots = self.emptySlots + 1
				Geary:log(slotName .. " is empty!", 1, 0, 0)
			end
		else
			local item = Geary_Item:new{ slot = slotName, link = itemLink }
			item:probe()
			self.iLevelTotal = self.iLevelTotal + item.iLevel
			if self.minItem == nil or item.iLevel < self.minItem.iLevel then
				self.minItem = item
			end
			if self.maxItem == nil or item.iLevel > self.maxItem.iLevel then
				self.maxItem = item
			end
			if item.missingBeltBuckle then
				self.missingBeltBuckle = true
			end
			if slotName == "MainHandSlot" and item:isTwoHandWeapon() then
				self.hasTwoHandWeapon = true
			end
			-- TODO: This is a poor man's way to account for Titan's Grip
			--       The above MH check sets hasTwoHandWeapon to true, and if the player
			--  	 has anything in their OH, we undo it presuming Titan's Grip.
			--       Note that this requires the MH to be parsed BEFORE the OH
			if slotName == "SecondaryHandSlot" then
				self.hasTwoHandWeapon = false
			end
			self.items[slotName] = item
			self.filledSockets = self.filledSockets + #item.filledSockets
			self.emptySockets = self.emptySockets + #item.emptySockets
			if item.canEnchant and not item.enchantText then
				self.unenchantedCount = self.unenchantedCount + 1
			end
			self.upgradeLevel = self.upgradeLevel + item.upgradeLevel
			self.upgradeMax = self.upgradeMax + item.upgradeMax
			self.upgradeItemLevelMissing = self.upgradeItemLevelMissing + item.upgradeItemLevelMissing
		end
	end

	if self.emptySlots > 0 and self.player.level >= 60 and self.inspectTry < self.inspectTries then
		-- The character should have items in every slot, so retry assuming the server
		-- didn't send us the item info.
		Geary:log("Will retry to get data for empty slots.", 1, 0, 1)
		return
	end

	-- TODO: Need to really account for Titan's grip here (not just hacky thing above)
	if self.hasTwoHandWeapon then
		self.itemCount = self.itemCount - 1
	end

	-- Inspection is over
	self.iLevelEquipped = self.iLevelTotal / self.itemCount
	self:inspectionOver()

	-- Summary
	Geary:log(" ")
	Geary:log(("--- %s %s %i %s %s ---"):format(self.player:getFactionInlineIcon(),
		self.player:getFullNameLink(), self.player.level, self.player:getColorizedClassName(),
		self.player:getSpecWithInlineIcon()))
	Geary:log(("%.2f equipped iLevel (%i%s items with %i total)"):format(self.iLevelEquipped,
		self.itemCount, self.hasTwoHandWeapon and " (2H)" or "", self.iLevelTotal))
	if self.player:isMaxLevel() then
		if self.iLevelEquipped >= 470 then
			Geary:debugLog("Ready for all LFD/LFR content")
		elseif self.iLevelEquipped >= 460 then
			Geary:log(((470 * self.itemCount) - self.iLevelTotal) ..
				" item levels until HoF/TES LFR ready", 1, 0.49, 0.04)
		elseif self.iLevelEquipped >= 435 then
			Geary:log(((460 * self.itemCount) - self.iLevelTotal) ..
				" item levels until MV LFR ready", 1, 0.49, 0.04)
		else
			Geary:log(((435 * self.itemCount) - self.iLevelTotal) ..
				" item levels until LFD heroic ready", 1, 0.49, 0.04)
		end
	end
	if self.upgradeItemLevelMissing > 0 then
		Geary:log(("%.2f max iLevel after %i upgrades (%i filled)"):format(
			(self.iLevelTotal + self.upgradeItemLevelMissing) / self.itemCount,
			self.upgradeMax - self.upgradeLevel, self.upgradeLevel),
			1, 0.96, 0.41)
	elseif self.upgradeMax > 0 then
		Geary:log("All item upgrades filled", 0, 1, 0)
	end
	if self.emptySlots > 0 then
		Geary:log(self.emptySlots .. " item slots are empty!", 1, 0, 0)
	end
	if self.missingBeltBuckle then
		Geary:log("Missing belt buckle!", 1, 0, 0)
	end
	if self.emptySockets > 0 then
		Geary:log(self.emptySockets .. " gem sockets empty!", 1, 0, 0)
	elseif self.filledSockets > 0 then
		Geary:log("All sockets are filled", 0, 1, 0)
	end
	if self.unenchantedCount > 0 then
		Geary:log(self.unenchantedCount .. " items missing enchants!", 1, 0, 0)
	else
		Geary:log("All items are enchanted", 0, 1, 0)
	end
	if self.minItem ~= nil then
		Geary:log(("Lowest %s %s"):format(self.minItem:iLevelWithUpgrades(), self.minItem.link))
	end
	if self.maxItem ~= nil then
		Geary:log(("Highest %s %s"):format(self.maxItem:iLevelWithUpgrades(), self.maxItem.link))
	end
end

-- Disable everything after a successful or failed inspection
function Geary_Inspect:inspectionOver()
	self:stopTimer()
	self.inProgress = false
	Geary:UnregisterEvent("INSPECT_READY")
end

function Geary_Inspect:inspectUnitRequest(unit)
	-- Cannot do two inspections at once
	if self.inProgress then
		Geary:print(RED_FONT_COLOR_CODE .. "Cannot inspect " .. unit .. " while inspection of " ..
			self.player:getFullNameLink() .. " still in progress." .. FONT_COLOR_CODE_CLOSE)
		return
	end

	-- Reset everything and show the UI for results
	self:resetInfo()
	self:stopTimer()
	Geary_Interface:Show()

	-- Player info
	self.player = Geary_Player:new{unit = unit}
	self.player:probeInfo()

	-- Request inspection
	self:makeInspectRequest()
end

function Geary_Inspect:reinspectRequest()
	Geary:log("Inspection failed, retrying...", 1, 0, 1)
	self:makeInspectRequest()
end

function Geary_Inspect:makeInspectRequest()
	self.inProgress = true;
	self:resetData()
	Geary:log(" ")
	Geary:log(("Inspecting %s %s %s %i %s (%s)"):format(self.player.unit,
		self.player:getFactionInlineIcon(), self.player:getFullNameLink(), self.player.level,
		self.player:getColorizedClassName(), self.player.guid))
	self.inspectTry = self.inspectTry + 1
	self:startTimer(self.inspectTimeout)
	Geary:RegisterEvent("INSPECT_READY")
	NotifyInspect(self.player.unit)
end

function Geary_Inspect:inspectUnit(unit)
	if CanInspect(unit) then
		if CheckInteractDistance(unit, 1) then
			self:inspectUnitRequest(unit)
		else
			Geary:print("Can inspect, but out of range " .. unit)
		end
	else
		Geary:print("Cannot inspect " .. unit)
	end
end

function Geary_Inspect:inspectSelf()
	self:inspectUnitRequest("player")
end

function Geary_Inspect:inspectTarget()
	self:inspectUnit("target")
end

function Geary_Inspect:inspectGroup()
	Geary:print("Group inspection is not implemented yet.")
end