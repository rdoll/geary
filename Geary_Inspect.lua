--[[
    Geary inspection manager

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Inspect = {
    items           = {},    -- Make table once and wipe it in reset
    timerId         = nil,   -- Inspection in progress timer ID
    INSPECT_TIMEOUT = 3000,  -- Time in ms to wait before assuming an inspect failed
    INSPECT_TRIES   = 3      -- Try to get inspect data from server this many times
}

function Geary_Inspect:_ResetInfo()
    self.inProgress = false
    self.inspectTry = 0
    self.player = nil
end

function Geary_Inspect:_ResetData()
    self.hasTwoHandWeapon        = false
    self.filledSlots             = 0
    self.emptySlots              = 0
    self.failedSlots             = 0
    self.itemCount               = 0
    self.iLevelTotal             = 0
    self.iLevelEquipped          = 0.0
    self.minItem                 = nil
    self.maxItem                 = nil
    wipe(self.items)
    self.filledSockets           = 0
    self.emptySockets            = 0
    self.failedJewelIds          = 0
    self.isMissingBeltBuckle     = false
    self.enchantedCount          = 0
    self.unenchantedCount        = 0
    self.upgradeLevel            = 0
    self.upgradeMax              = 0
    self.upgradeItemLevelMissing = 0
    self.eotbpFilled             = 0
    self.eotbpMissing            = 0
    self.hasCohMeta              = false
    self.isMissingCohMeta        = false
    self.hasCov                  = false
    self.isMissingCov            = false
    self.hasLegCloak             = false
    self.isMissingLegCloak       = false
end

function Geary_Inspect:_StartTimer()
    self.timerId = Geary_Timer:Start(self.INSPECT_TIMEOUT, false, function(secondsLeft) Geary_Inspect:_TimerExpired() end)
end

function Geary_Inspect:_StopTimer()
    if self.timerId ~= nil then
        Geary_Timer:Stop(self.timerId)
        self.timerId = nil
    end
end

function Geary_Inspect:_TimerExpired()
    if self.inspectTry < self.INSPECT_TRIES then
        self:_ReinspectRequest()
    else
        self:_InspectionFailed()
        Geary:log(Geary.CC_FAILED .. "Inspection failed after " .. self.INSPECT_TRIES .. " tries." .. Geary.CC_END)
    end
end

function Geary_Inspect:PLAYER_LOGOUT()
    if self.inProgress then
        self:_InspectionOver()
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

    if not self.player:isUnitStillSamePlayer() then
        self:_InspectionTargetChanged()
        return
    end

    -- Player's specialization
    self.player:INSPECT_READY()
    Geary_Interface_Player:inspectionStart(self)

    -- Player inventory
    local itemLink
    for _, slotName in ipairs(Geary_Item:getInvSlotsInOrder()) do
        itemLink = GetInventoryItemLink(self.player.unit, Geary_Item:getSlotNumberForName(slotName))
        if itemLink == nil then
            self:_ProcessEmptySlot(slotName)
        else
            self:_ProcessFilledSlot(slotName, itemLink)
        end
    end

    if (self.failedJewelIds > 0 or self.emptySlots > 0 or self.failedSlots > 0) and
        self.inspectTry < self.INSPECT_TRIES
    then
        -- We failed to get them gem for a jewelId or there are empty slots which the server
        -- may not have sent to us. Since retries are left, hope one will get the missing data.
        Geary:log(Geary.CC_FAILED .. "Will retry to get missing data." .. Geary.CC_END)
        return
    end

    -- Total number of slots that should have an item
    self.itemCount = self.filledSlots + self.emptySlots + self.failedSlots

    -- Inspection is complete
    self.iLevelEquipped = self.iLevelTotal / self.itemCount
    self:_InspectionPassed()

    -- Show summary
    self:_ShowSummary()
end

function Geary_Inspect:_ProcessEmptySlot(slotName)

    -- Increase empty slot count if appropriate
    if slotName == "SecondaryHandSlot" and self.hasTwoHandWeapon and not self.player:hasTitansGrip() then
        Geary:debugLog(slotName, "is empty, but using 2Her and does not have Titan's Grip")
    else
        self.emptySlots = self.emptySlots + 1
        Geary:log(Geary.CC_MISSING .. slotName .. " is empty!" .. Geary.CC_END)
    end

    -- Mark missing belt buckle if waist item
    if slotName == "WaistSlot" then
        self.isMissingBeltBuckle = true
    end
end

function Geary_Inspect:_ProcessFilledSlot(slotName, itemLink)

    local item = Geary_Item:new{ slot = slotName, link = itemLink }
    if not item:probe(self.player) then
        -- Item probe failed (and logged why), so track a failed item
        self.failedSlots = self.failedSlots + 1
        return
    end

    self.items[slotName] = item
    self.filledSlots = self.filledSlots + 1

    self.iLevelTotal = self.iLevelTotal + item.iLevel
    if self.minItem == nil or item.iLevel < self.minItem.iLevel then
        self.minItem = item
    end
    if self.maxItem == nil or item.iLevel > self.maxItem.iLevel then
        self.maxItem = item
    end

    if item.isMissingBeltBuckle then
        self.isMissingBeltBuckle = true
    end

    -- Can only have legendary questline items if max level
    if self.player:isMaxLevel() then
        if item.hasEotbp then
            self.eotbpFilled = self.eotbpFilled + 1
        end
        if item.isMissingEotbp then
            self.eotbpMissing = self.eotbpMissing + 1
        end

        if slotName == "HeadSlot" then
            self.hasCohMeta = item.hasCohMeta
            self.isMissingCohMeta = item.isMissingCohMeta
        end

        if slotName == "BackSlot" then
            self.hasCov = item.hasCov
            self.isMissingCov = item.isMissingCov
            self.hasLegCloak = item.hasLegCloak
            self.isMissingLegCloak = item.isMissingLegCloak
        end
    end

    if slotName == "MainHandSlot" and item:isTwoHandWeapon() then
        self.hasTwoHandWeapon = true
    end

    self.filledSockets = self.filledSockets + Geary:tableSize(item.filledSockets)
    self.emptySockets = self.emptySockets + Geary:tableSize(item.emptySockets)
    self.failedJewelIds = self.failedJewelIds + Geary:tableSize(item.failedJewelIds)

    if item.canEnchant and not item.enchantText then
        self.unenchantedCount = self.unenchantedCount + 1
    end
    if item.enchantText then
        self.enchantedCount = self.enchantedCount + 1
    end

    self.upgradeLevel = self.upgradeLevel + item.upgradeLevel
    self.upgradeMax = self.upgradeMax + item.upgradeMax
    self.upgradeItemLevelMissing = self.upgradeItemLevelMissing + item.upgradeItemLevelMissing

    -- Add to player interface if we successfully parsed everything about the item
    if Geary:isTableEmpty(item.failedJewelIds) then
        Geary_Interface_Player:setItem(slotName, item)
    end
end

-- Endgame minimum item level milestones
-- NOTE: Must be in order from lowest iLevel to highest
local _itemLevelMilestones = {
    { iLevel = 435, milestone = "LFD heroic" },
    { iLevel = 460, milestone = "MV LFR" },
    { iLevel = 470, milestone = "HoF/ToES LFR" },
    { iLevel = 480, milestone = "ToT LFR" },
    { iLevel = 496, milestone = "SoO LFR" }
}

function Geary_Inspect:GetItemLevelMilestone()
    if self.player:isMaxLevel() then
        for index, data in ipairs(_itemLevelMilestones) do
            if (self.iLevelEquipped < data.iLevel) then
                return ((data.iLevel * self.itemCount) - self.iLevelTotal), data.milestone
            end
        end
    end
    return nil, nil
end

function Geary_Inspect:_ShowSummary()

    Geary:log()
    Geary:log(("--- %s %s %i %s %s ---"):format(self.player:getFactionInlineIcon(),
        self.player:getFullNameLink(), self.player.level, self.player:getColorizedClassName(),
        self.player:getSpecWithInlineIcon()))

    Geary:log(("%.2f equipped iLevel (%i%s items with %i total)"):format(self.iLevelEquipped,
        self.itemCount,
        self.hasTwoHandWeapon and (self.player:hasTitansGrip() and " (TG)" or " (2H)") or "",
        self.iLevelTotal))

    local milestoneLevel, milestoneName = self:GetItemLevelMilestone()
    if milestoneLevel then
        Geary:log(Geary.CC_MILESTONE .. milestoneLevel .. " iLevel points until " .. milestoneName .. " ready" ..
            Geary.CC_END)
    end

    if self.upgradeItemLevelMissing > 0 then
        Geary:log(Geary.CC_UPGRADE .. ("%.2f max iLevel after %i upgrades (%i filled)"):format(
            (self.iLevelTotal + self.upgradeItemLevelMissing) / self.itemCount,
            self.upgradeMax - self.upgradeLevel, self.upgradeLevel) .. Geary.CC_END)
    elseif self.upgradeMax > 0 then
        Geary:log(Geary.CC_CORRECT .. "All item upgrades filled" .. Geary.CC_END)
    end

    if self.emptySlots > 0 then
        Geary:log(Geary.CC_MISSING .. self.emptySlots .. " item slots are empty!" .. Geary.CC_END)
    end

    if self.failedSlots > 0 then
        Geary:log(Geary.CC_FAILED .. self.failedSlots .. " item slots failed!" .. Geary.CC_END)
    end

    if self.isMissingBeltBuckle then
        Geary:log(Geary.CC_MISSING .. "Missing " .. Geary_Item:getBeltBuckleItemWithTexture() .. Geary.CC_END)
    end

    if self.eotbpMissing > 0 then
        Geary:log(Geary.CC_OPTIONAL .. "Missing " .. self.eotbpMissing .. " " .. Geary_Item:getEotbpItemWithTexture() ..
            Geary.CC_END)
    end
    if self.isMissingCohMeta then
        Geary:log(Geary.CC_OPTIONAL .. "Missing Crown of Heaven legendary meta gem" .. Geary.CC_END)
    end
    if self.isMissingCov then
        Geary:log(Geary.CC_OPTIONAL .. "Missing Cloak of Virtue" .. Geary.CC_END)
    elseif self.isMissingCov then
        Geary:log(Geary.CC_OPTIONAL .. "Missing legendary cloak" .. Geary.CC_END)
    end

    if self.emptySockets > 0 then
        Geary:log(Geary.CC_MISSING .. self.emptySockets .. " gem sockets empty!" .. Geary.CC_END)
    elseif self.filledSockets > 0 then
        Geary:log(Geary.CC_CORRECT .. "All sockets filled" .. Geary.CC_END)
    end

    if self.failedJewelIds > 0 then
        Geary:log(Geary.CC_FAILED .. self.failedJewelIds .. " gems could not be obtained!" .. Geary.CC_END)
    end

    if self.unenchantedCount > 0 then
        Geary:log(Geary.CC_MISSING .. self.unenchantedCount .. " items missing enchants!" .. Geary.CC_END)
    elseif self.enchantedCount > 0 then
        Geary:log(Geary.CC_CORRECT .. "All items enchanted" .. Geary.CC_END)
    end

    if self.minItem ~= nil then
        Geary:log(("Lowest %s %s %s"):format(self.minItem:iLevelWithUpgrades(), self.minItem.inlineTexture,
            self.minItem.link))
    end

    if self.maxItem ~= nil then
        Geary:log(("Highest %s %s %s"):format(self.maxItem:iLevelWithUpgrades(), self.maxItem.inlineTexture,
            self.maxItem.link))
    end
end

function Geary_Inspect:_InspectionOver()
    self:_StopTimer()
    self.inProgress = false
    Geary:UnregisterEvent("INSPECT_READY")
    ClearInspectPlayer()
end

function Geary_Inspect:_InspectionTargetChanged()
    local message = Geary.CC_FAILED .. "Unit " .. self.player.unit .. " changed, aborting inspection of " ..
        self.player:getFullNameLink() .. Geary.CC_END
    Geary:print(message)
    Geary:log(message)
    self:_InspectionFailed()
end

function Geary_Inspect:_InspectionFailed()
    self:_InspectionOver()
    Geary_Interface_Player:inspectionFailed(self)
end

function Geary_Inspect:_InspectionPassed()
    self:_InspectionOver()
    Geary_Interface_Player:inspectionEnd(self)
    Geary_Database:storeInspection(self)
end

function Geary_Inspect:_InspectUnitRequest(unit)
    -- Cannot do two inspections at once
    if self.inProgress then
        Geary:print(Geary.CC_FAILED .. "Cannot inspect", unit, "while inspection of", self.player:getFullNameLink(),
            "still in progress." .. Geary.CC_END)
        return
    end

    -- Reset everything and show the UI for results
    self:_ResetInfo()
    self:_StopTimer()
    Geary_Interface_Log:clearIfTooLarge()
    Geary_Interface:Show()

    -- Player info
    self.player = Geary_Player:new{ unit = unit }
    self.player:probeInfo()

    -- Reset the player interface
    Geary_Interface_Player:clear()

    -- Request inspection
    self:_MakeInspectRequest()
end

function Geary_Inspect:_ReinspectRequest()
    if self.player:isUnitStillSamePlayer() then
        Geary:log(Geary.CC_FAILED .. "Inspection failed, retrying..." .. Geary.CC_END)
        self:_MakeInspectRequest()
    else
        self:_InspectionTargetChanged()
    end
end

function Geary_Inspect:_MakeInspectRequest()
    self.inProgress = true;
    self:_ResetData()
    Geary:log()
    Geary:log(("Inspecting %s %s %s %i %s (%s)"):format(self.player.unit, self.player:getFactionInlineIcon(),
        self.player:getFullNameLink(), self.player.level, self.player:getColorizedClassName(), self.player.guid))
    self.inspectTry = self.inspectTry + 1
    Geary_Interface_Player:inspectionStart(self)
    self:_StartTimer()
    Geary:RegisterEvent("INSPECT_READY")
    NotifyInspect(self.player.unit)
end

function Geary_Inspect:_InspectUnit(unit)
    if CanInspect(unit) then
        if CheckInteractDistance(unit, 1) then
            self:_InspectUnitRequest(unit)
        else
            Geary:print(Geary.CC_ERROR .. "Can inspect, but out of range", unit .. Geary.CC_END)
        end
    else
        Geary:print(Geary.CC_ERROR .. "Cannot inspect", unit .. Geary.CC_END)
    end
end

function Geary_Inspect:InspectSelf()
    self:_InspectUnitRequest("player")
end

function Geary_Inspect:InspectTarget()
    self:_InspectUnit("target")
end

function Geary_Inspect:InspectGroup()
    Geary:print(Geary.CC_ERROR .. "Group inspection is not yet implemented." .. Geary.CC_END)
end

function Geary_Inspect:InspectGuid(guid)

    if guid == nil then
        Geary:debugPrint("Cannot inspect nil guid")
        return
    end

    if guid == UnitGUID("player") then
        self:InspectSelf()
        return
    end

    if guid == UnitGUID("target") then
        self:InspectTarget()
        return
    end

    local unitPrefix, unitLimit
    if IsInRaid() then
        unitPrefix = "raid"
        unitLimit = 40
    elseif IsInGroup() then
        unitPrefix = "party"
        unitLimit = 4
    else
        -- Not in any kind of group
        Geary:print(Geary.CC_ERROR .. "Can only inspect yourself or your target." .. Geary.CC_END)
        return
    end

    local unit
    for unitNumber = 1, unitLimit do
        unit = unitPrefix .. unitNumber
        if guid == UnitGUID(unit) then
            self:_InspectUnit(unit)
            return
        end
    end

    Geary:print(Geary.CC_ERROR .. "Can only inspect yourself, your target, or your group members." .. Geary.CC_END)
end
