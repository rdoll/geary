--[[
    Geary timer

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Timer = {
    timerFrame = CreateFrame("Frame"),
    nextTimerId = 1
}

function Geary_Timer:Init()
    self.timerFrame.timers = {}
end

function Geary_Timer.timerFrame:StartTimer(timerId, seconds, callOnEveryTick, callback)
    Geary:print("Geary_Timer starting timer", timerId, "for", seconds)

    if Geary:isTableEmpty(self.timers) then
        self:SetScript("OnUpdate", self.OnUpdate)
        Geary:print("Geary_Timer hooked OnUpdate")
    end

    self.timers[timerId] = {
        seconds = seconds,
        callOnEveryTick = callOnEveryTick,
        callback = callback
    }
end

function Geary_Timer.timerFrame:OnUpdate(secondsSinceLastUpdate)
    local expired = {}

    for timerId, timerData in pairs(self.timers) do
        timerData.seconds = timerData.seconds - secondsSinceLastUpdate
        if timerData.seconds <= 0 then
            Geary:print("Geary_Timer expired callback for", timerId)
            timerData.callback(0)
            expired[timerId] = 1  -- Defer timer removal from table until not iterating over table
        elseif timerData.callOnEveryTick then
            Geary:print("Geary_Timer tick callback for", timerId)
            timerData.callback(timerData.seconds)
        end
    end

    for timerId, _ in pairs(expired) do
        self:StopTimer(timerId)
    end
end

function Geary_Timer.timerFrame:StopTimer(timerId)
    Geary:print("Geary_Timer stopping timer", timerId)
    self.timers[timerId] = nil
    if Geary:isTableEmpty(self.timers) then
        self:SetScript("OnUpdate", nil)
        Geary:print("Geary_Timer unhooked OnUpdate")
    end
end

function Geary_Timer:Start(milliseconds, callOnEveryTick, callback)
    local timerId = self.nextTimerId
    self.nextTimerId = self.nextTimerId + 1
    self.timerFrame:StartTimer(timerId, milliseconds / 1000, callOnEveryTick, callback)
    return timerId
end

function Geary_Timer:Stop(timerId)
    self.timerFrame:StopTimer(timerId)
end
