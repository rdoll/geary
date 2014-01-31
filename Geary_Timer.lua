--[[
    Geary timer

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Timer = {
    timerFrame = CreateFrame("Frame", "Geary_Timer_Frame"),
    nextTimerId = 1
}

function Geary_Timer:new(o)
    local newObject = {
        durationMillis = 0,
        callback = nil
    }
    if o then
        for name, value in pairs(o) do
            newObject[name] = value
        end
    end

    newObject.animationGroup = Geary_Timer.timerFrame:CreateAnimationGroup()
    newObject.animation = newObject.animationGroup:CreateAnimation()

    -- On timer expiration, use a closure to call the timer's callback with the timer object as the only argument
    newObject.animation:SetScript("OnFinished", function(animation, requested)
        newObject.callback(newObject)
    end)

    setmetatable(newObject, self)
    self.__index = self
    return newObject
end

function Geary_Timer:Start(durationMillis, callback)
    self:Stop()
    self.durationMillis = durationMillis
    self.callback = callback
    self:_Start()
end

function Geary_Timer:_Start()
    if not self.callback then
        Geary:Print(Geary.CC_ERROR .. "Timer missing callback" .. Geary.CC_END)
        return
    end

    -- Per AceTimer 3.0, animations less than 100ms may fail randomly
    if not self.durationMillis or self.durationMillis < 100 then
        self.durationMillis = 100
    end

    self.animation:SetDuration(self.durationMillis / 1000)
    self.animationGroup:Play()
end

function Geary_Timer:Restart()
    self:Stop()
    self:_Start()
end

function Geary_Timer:Stop()
    self.animationGroup:Stop()
end
