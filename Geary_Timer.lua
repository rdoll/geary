--[[
    Geary timer manager

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Timer = {
    timerFrame = CreateFrame("Frame", "Geary_Timer_Frame"),
    nextTimerId = 1
}

function Geary_Timer:Init()
    self.timerFrame.timers = {}
end

function Geary_Timer.timerFrame:_StartTimer(timerId, seconds, callback)
    Geary:debugPrint(Geary.CC_DEBUG .. "Geary_Timer starting timer", timerId, "for", seconds, "seconds" .. Geary.CC_END)

    if Geary:isTableEmpty(self.timers) then
        self:SetScript("OnUpdate", self._OnUpdate)
        Geary:debugPrint(Geary.CC_DEBUG .. "Geary_Timer hooked OnUpdate" .. Geary.CC_END)
    end

    self.timers[timerId] = {
        seconds = seconds,
        callback = callback
    }
end

function Geary_Timer.timerFrame:_OnUpdate(secondsSinceLastUpdate)
    local expired = {}

    for timerId, timerData in pairs(self.timers) do
        timerData.seconds = timerData.seconds - secondsSinceLastUpdate
        if timerData.seconds <= 0 then
            Geary:debugPrint(Geary.CC_DEBUG .. "Geary_Timer expired callback for", timerId, Geary.CC_END)
            timerData.callback()
            expired[timerId] = 1  -- Defer timer removal from table until not iterating over table
        end
    end

    for timerId, _ in pairs(expired) do
        self:_StopTimer(timerId)
    end
end

function Geary_Timer.timerFrame:_StopTimer(timerId)
    Geary:debugPrint(Geary.CC_DEBUG .. "Geary_Timer stopping timer", timerId, Geary.CC_END)
    self.timers[timerId] = nil
    if Geary:isTableEmpty(self.timers) then
        self:SetScript("OnUpdate", nil)
        Geary:debugPrint(Geary.CC_DEBUG .. "Geary_Timer unhooked OnUpdate" .. Geary.CC_END)
    end
end

-- callback is a function that receives no arguments called upon expiry
function Geary_Timer:Start(milliseconds, callback)
    local timerId = self.nextTimerId
    self.nextTimerId = self.nextTimerId + 1
    self.timerFrame:_StartTimer(timerId, milliseconds / 1000, callback)
    return timerId
end

function Geary_Timer:Stop(timerId)
    self.timerFrame:_StopTimer(timerId)
end
