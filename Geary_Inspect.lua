--[[
    Geary inspection manager

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Inspect = {
    items                      = {},    -- Make table once and wipe it in reset
    timer                      = nil,   -- Inspection in progress timer
    playerLogoutEventHandlerId = nil,   -- Event handler ID for PLAYER_LOGOUT event
    inspectReadyEventHandlerId = nil,   -- Event handler ID for INSPECT_READY event
    INSPECT_TIMEOUT            = 3000,  -- Time in ms to wait before assuming an inspect failed
    INSPECT_TRIES              = 3      -- Try to get inspect data from server this many times
}

--
-- Initialization
--

function Geary_Inspect:Init()
    self.timer = Geary_Timer:new{
        durationMillis = self.INSPECT_TIMEOUT,
        callback = function(timer)
            Geary_Inspect:_TimerExpired()
        end
    }
    self.playerLogoutEventHandlerId = Geary_Event:RegisterEvent("PLAYER_LOGOUT", function()
        Geary_Inspect:PLAYER_LOGOUT()
    end)
end

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
    self.canHaveBeltBuckle       = false
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

--
-- Timer
--

function Geary_Inspect:_TimerExpired()
    if self.inspectTry < self.INSPECT_TRIES then
        self:_ReinspectRequest()
    else
        self:_InspectionFailed()
        Geary:Log(Geary.CC_FAILED .. "Inspection failed after", self.INSPECT_TRIES, "tries." .. Geary.CC_END)
    end
end

--
-- Events
--

function Geary_Inspect:_RegisterInspectionEvents()
    if Geary_Inspect.inspectReadyEventHandlerId == nil then
        Geary_Inspect.inspectReadyEventHandlerId =
            Geary_Event:RegisterEvent("INSPECT_READY", function (unitGuid) Geary_Inspect:INSPECT_READY(unitGuid) end)
    end
end

function Geary_Inspect:_UnregisterInspectionEvents()
    if Geary_Inspect.inspectReadyEventHandlerId ~= nil then
        Geary_Event:UnregisterEvent(Geary_Inspect.inspectReadyEventHandlerId)
        Geary_Inspect.inspectReadyEventHandlerId = nil
    end
end

function Geary_Inspect:PLAYER_LOGOUT()
    self.timer:Stop()
    if self.inProgress then
        self:_InspectionOver()
        Geary_Event:UnregisterEvent(Geary_Inspect.playerLogoutEventHandlerId)
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

    if not self.player:IsUnitStillSamePlayer() then
        self:_InspectionTargetChanged()
        return
    end

    -- Player's specialization
    self.player:INSPECT_READY()
    Geary_Interface_Player:InspectionStart(self)

    -- Player inventory
    local itemLink
    for _, slotName in ipairs(Geary_Item:GetInvSlotsInOrder()) do
        itemLink = GetInventoryItemLink(self.player.unit, Geary_Item:GetSlotNumberForName(slotName))
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
        Geary:Log(Geary.CC_FAILED .. "Will retry to get missing data." .. Geary.CC_END)
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

--
-- Inspection in progress indicator
--

function Geary_Inspect:_StartInProgress()
    Geary_Icon:StartBusy(self.INSPECT_TIMEOUT / 1000)  -- Convert millis to seconds
end

function Geary_Inspect:_StopInProgress()
    Geary_Icon:StopBusy()
end

--
-- Business logic
--

function Geary_Inspect:_ProcessEmptySlot(slotName)

    -- Increase empty slot count if appropriate
    if slotName == "SecondaryHandSlot" and self.hasTwoHandWeapon and not self.player:HasTitansGrip() then
        Geary:DebugLog(slotName, "is empty, but using 2Her and does not have Titan's Grip")
    else
        self.emptySlots = self.emptySlots + 1
        Geary:Log(Geary.CC_MISSING .. slotName .. " is empty!" .. Geary.CC_END)
    end

    -- Mark missing belt buckle if waist item
    if slotName == "WaistSlot" then
        self.canHaveBeltBuckle = true
        self.isMissingBeltBuckle = true
    end
end

function Geary_Inspect:_ProcessFilledSlot(slotName, itemLink)

    local item = Geary_Item:new{ slot = slotName, link = itemLink }
    if not item:Probe(self.player) then
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

    if item.canHaveBeltBuckle then
        self.canHaveBeltBuckle = true
    end
    if item.isMissingBeltBuckle then
        self.isMissingBeltBuckle = true
    end

    if self.player:CanDoMopLegQuest() then
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

    if slotName == "MainHandSlot" and item:IsTwoHandWeapon() then
        self.hasTwoHandWeapon = true
    end

    self.filledSockets = self.filledSockets + Geary:TableSize(item.filledSockets)
    self.emptySockets = self.emptySockets + Geary:TableSize(item.emptySockets)
    self.failedJewelIds = self.failedJewelIds + Geary:TableSize(item.failedJewelIds)

    if item:GetCanEnchant() and not item:IsEnchanted() then
        self.unenchantedCount = self.unenchantedCount + 1
    end
    if item:IsEnchanted() then
        self.enchantedCount = self.enchantedCount + 1
    end

    self.upgradeLevel = self.upgradeLevel + item.upgradeLevel
    self.upgradeMax = self.upgradeMax + item.upgradeMax
    self.upgradeItemLevelMissing = self.upgradeItemLevelMissing + item.upgradeItemLevelMissing

    -- Add to player interface if we successfully parsed everything about the item
    if Geary:IsTableEmpty(item.failedJewelIds) then
        Geary_Interface_Player:SetItem(slotName, item)
    end
end

-- Endgame minimum item level milestones
-- NOTE: Must be in order from lowest iLevel to highest
local _ITEM_LEVEL_MILESTONES = {
    { iLevel = 600, milestone = "LFD normal" },
    { iLevel = 610, milestone = "LFD heroic" },
    { iLevel = 615, milestone = "HM LFR" }
}

function Geary_Inspect:GetItemLevelMilestone()
    if self.player:IsMaxLevel() then
        for index, data in ipairs(_ITEM_LEVEL_MILESTONES) do
            if (self.iLevelEquipped < data.iLevel) then
                return ((data.iLevel * self.itemCount) - self.iLevelTotal), data.milestone
            end
        end
    end
    return nil, nil
end

function Geary_Inspect:_ShowSummary()

    Geary:Log()
    Geary:Log(("--- %s %s %i %s %s ---"):format(self.player:GetFactionInlineIcon(),
        self.player:GetFullNameLink(), self.player.level, self.player:GetColorizedClassName(),
        self.player:GetSpecWithInlineIcon()))

    Geary:Log(("%.2f equipped iLevel (%i%s items with %i total)"):format(self.iLevelEquipped,
        self.itemCount,
        self.hasTwoHandWeapon and (self.player:HasTitansGrip() and " (TG)" or " (2H)") or "",
        self.iLevelTotal))

    local milestoneLevel, milestoneName = self:GetItemLevelMilestone()
    if milestoneLevel then
        Geary:Log(Geary.CC_MILESTONE .. milestoneLevel .. " iLevel points until " .. milestoneName .. " ready" ..
            Geary.CC_END)
    end

    if self.upgradeItemLevelMissing > 0 then
        Geary:Log(Geary.CC_UPGRADE .. ("%.2f max iLevel after %i upgrades (%i filled)"):format(
            (self.iLevelTotal + self.upgradeItemLevelMissing) / self.itemCount,
            self.upgradeMax - self.upgradeLevel, self.upgradeLevel) .. Geary.CC_END)
    elseif self.upgradeMax > 0 then
        Geary:Log(Geary.CC_CORRECT .. "All item upgrades filled" .. Geary.CC_END)
    end

    if self.emptySlots > 0 then
        Geary:Log(Geary.CC_MISSING .. self.emptySlots .. " item slots are empty!" .. Geary.CC_END)
    end

    if self.failedSlots > 0 then
        Geary:Log(Geary.CC_FAILED .. self.failedSlots .. " item slots failed!" .. Geary.CC_END)
    end

    if self.isMissingBeltBuckle then
        Geary:Log(Geary.CC_MISSING .. "Missing " .. Geary_Item:GetBeltBuckleItemWithTexture() .. Geary.CC_END)
    end

    if Geary_Options:GetShowMopLegProgress() then
        if self.eotbpMissing > 0 then
            Geary:Log(Geary.CC_OPTIONAL .. "Missing " .. self.eotbpMissing .. " " .. Geary_Item:GetEotbpItemWithTexture() ..
                Geary.CC_END)
        end
        if self.isMissingCohMeta then
            Geary:Log(Geary.CC_OPTIONAL .. "Missing Crown of Heaven legendary meta gem" .. Geary.CC_END)
        end
        if self.isMissingCov then
            Geary:Log(Geary.CC_OPTIONAL .. "Missing Cloak of Virtue" .. Geary.CC_END)
        elseif self.isMissingCov then
            Geary:Log(Geary.CC_OPTIONAL .. "Missing legendary cloak" .. Geary.CC_END)
        end
    end

    if self.emptySockets > 0 then
        Geary:Log(Geary.CC_MISSING .. self.emptySockets .. " gem sockets empty!" .. Geary.CC_END)
    elseif self.filledSockets > 0 then
        Geary:Log(Geary.CC_CORRECT .. "All sockets filled" .. Geary.CC_END)
    end

    if self.failedJewelIds > 0 then
        Geary:Log(Geary.CC_FAILED .. self.failedJewelIds .. " gems could not be obtained!" .. Geary.CC_END)
    end

    if self.unenchantedCount > 0 then
        Geary:Log(Geary.CC_MISSING .. self.unenchantedCount .. " items missing enchants!" .. Geary.CC_END)
    elseif self.enchantedCount > 0 then
        Geary:Log(Geary.CC_CORRECT .. "All items enchanted" .. Geary.CC_END)
    end

    if self.minItem ~= nil then
        Geary:Log(("Lowest %s %s %s"):format(self.minItem:ILevelWithUpgrades(), self.minItem.inlineTexture,
            self.minItem.link))
    end

    if self.maxItem ~= nil then
        Geary:Log(("Highest %s %s %s"):format(self.maxItem:ILevelWithUpgrades(), self.maxItem.inlineTexture,
            self.maxItem.link))
    end
end

function Geary_Inspect:_InspectionOver()
    self.inProgress = false
    self.timer:Stop()
    self:_UnregisterInspectionEvents()
    self:_StopInProgress()
    ClearInspectPlayer()
end

function Geary_Inspect:_InspectionTargetChanged()
    local message = Geary.CC_FAILED .. "Unit " .. self.player.unit .. " changed, aborting inspection of " ..
        self.player:GetFullNameLink() .. Geary.CC_END
    Geary:Print(message)
    Geary:Log(message)
    self:_InspectionFailed()
end

function Geary_Inspect:_InspectionFailed()
    self:_InspectionOver()
    Geary_Interface_Player:InspectionFailed(self)
    self:_InspectNextInQueue()
end

function Geary_Inspect:_InspectionPassed()
    self:_InspectionOver()
    Geary_Interface_Player:InspectionEnd(self)
    Geary_Database:StoreInspection(self)
    self:_InspectNextInQueue()
end

function Geary_Inspect:_InspectNextInQueue()
    while Geary_Inspect_Queue:GetCount() > 0 do
        local guid = Geary_Inspect_Queue:NextGuid()
        self:InspectGuid(guid)
        if self.inProgress then
            return  -- Inspecting next
        else
            -- This guid could not be inspected, so try next
        end
    end
end

function Geary_Inspect:_InspectUnitRequest(unit)

    -- Cannot do two inspections at once
    if self.inProgress then
        Geary:Print(Geary.CC_FAILED .. "Cannot inspect", unit, "while inspection of", self.player:GetFullNameLink(),
            "still in progress." .. Geary.CC_END)
        return
    end

    -- Reset everything and show the UI for results
    self:_ResetInfo()
    self.timer:Stop()
    self:_UnregisterInspectionEvents()
    self:_StopInProgress()
    Geary_Interface_Log:ClearIfTooLarge()
    Geary_Interface:Show()

    -- Player info
    self.player = Geary_Player:new{ unit = unit }
    self.player:Probe()

    -- Reset the player interface
    Geary_Interface_Player:Clear()

    -- Request inspection
    self:_MakeInspectRequest()
end

function Geary_Inspect:_ReinspectRequest()
    if self.player:IsUnitStillSamePlayer() then
        Geary:Log(Geary.CC_FAILED .. "Inspection failed, retrying..." .. Geary.CC_END)
        self:_MakeInspectRequest()
    else
        self:_InspectionTargetChanged()
    end
end

function Geary_Inspect:_MakeInspectRequest()
    self.inProgress = true;
    self:_ResetData()
    Geary:Log()
    Geary:Log(("Inspecting %s %s %s %i %s (%s)"):format(self.player.unit, self.player:GetFactionInlineIcon(),
        self.player:GetFullNameLink(), self.player.level, self.player:GetColorizedClassName(), self.player.guid))
    self.inspectTry = self.inspectTry + 1
    Geary_Interface_Player:InspectionStart(self)
    self.timer:Restart()
    self:_RegisterInspectionEvents()
    self:_StartInProgress()
    NotifyInspect(self.player.unit)
end

function Geary_Inspect:_InspectUnit(unit)
    if CanInspect(unit) then
        if CheckInteractDistance(unit, 1) then
            self:_InspectUnitRequest(unit)
        else
            Geary:Print(Geary.CC_ERROR .. "Can inspect, but out of range", unit .. Geary.CC_END)
        end
    else
        Geary:Print(Geary.CC_ERROR .. "Cannot inspect", unit .. Geary.CC_END)
    end
end

function Geary_Inspect:InspectSelf()
    self:_InspectUnitRequest("player")
end

function Geary_Inspect:InspectTarget()
    self:_InspectUnit("target")
end

function Geary_Inspect:InspectGroup()

    -- Cannot do two inspections at once
    if self.inProgress then
        local count = Geary_Inspect_Queue:GetCount()
        if count > 0 then
            Geary:Print(Geary.CC_FAILED .. "Aborting inspection of remaining", count, "group members." .. Geary.CC_END)
            Geary_Inspect_Queue:Clear()
        else
            Geary:Print(Geary.CC_FAILED .. "Cannot inspect group while inspection of", self.player:GetFullNameLink(),
                "still in progress." .. Geary.CC_END)
        end
        return
    end

    local unitPrefix, unitLimit
    if IsInRaid() then
        -- Player is included in raid units
        unitPrefix = "raid"
        unitLimit = 40
    elseif IsInGroup() then
        -- Player is not included in party units
        Geary_Inspect_Queue:AddGuid(UnitGUID("player"))
        unitPrefix = "party"
        unitLimit = 4
    else
        Geary:Print(Geary.CC_ERROR .. "Not in a group to inspect." .. Geary.CC_END)
        return
    end

    local unit, guid
    for unitNumber = 1, unitLimit do
        unit = unitPrefix .. unitNumber
        guid = UnitGUID(unit)
        if guid ~= nil then
            Geary_Inspect_Queue:AddGuid(guid)
        end
    end

    self:_InspectNextInQueue()
end

function Geary_Inspect:InspectGuid(guid)

    if guid == nil then
        Geary:DebugPrint("Cannot inspect nil guid")
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
        Geary:Print(Geary.CC_ERROR .. "Can only inspect yourself or your target." .. Geary.CC_END)
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

    Geary:Print(Geary.CC_ERROR .. "Can only inspect yourself, your target, or your group members." .. Geary.CC_END)
end
