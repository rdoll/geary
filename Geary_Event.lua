--[[
    Geary global event manager

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Event = {
    eventFrame = CreateFrame("Frame", "Geary_Event_Frame"),
    nextEventHandlerId = 1
}

function Geary_Event:Init()
    self.eventFrame.events = {}
    self.eventFrame:SetScript("OnEvent", function(self, eventName, ...)
        self:_HandleEvent(eventName, ...)
    end)
    self:RegisterEvent("PLAYER_LOGOUT", function() Geary_Event:PLAYER_LOGOUT() end)
end

function Geary_Event.eventFrame:_RegisterEvent(eventHandlerId, eventName, callback)
    Geary:DebugPrint(Geary.CC_DEBUG .. "Geary_Event registering", eventHandlerId, "for", eventName, Geary.CC_END)

    if self.events[eventName] == nil then
        self.events[eventName] = {}
    end

    if Geary:IsTableEmpty(self.events[eventName]) then
        self:RegisterEvent(eventName)
        Geary:DebugPrint(Geary.CC_DEBUG .. "Geary_Event registered", eventName, Geary.CC_END)
    end

    self.events[eventName][eventHandlerId] = callback
end

function Geary_Event.eventFrame:_HandleEvent(eventName, ...)
    for handlerId, callback in pairs(self.events[eventName]) do
        Geary:DebugPrint(Geary.CC_DEBUG .. "Geary_Event calling handler ID", handlerId, "for event", eventName, Geary.CC_END)
        callback(...)
    end
end

function Geary_Event.eventFrame:_FindEventNameForHandlerId(eventHandlerId)
    for eventName, handlers in pairs(self.events) do
        for handlerId, _ in pairs(handlers) do
            if handlerId == eventHandlerId then
                return eventName
            end
        end
    end
    return nil
end

function Geary_Event.eventFrame:_UnregisterEvent(eventHandlerId)
    local eventName = self:_FindEventNameForHandlerId(eventHandlerId)
    if eventName == nil then
        Geary:Print(Geary.CC_ERROR .. "Geary_Event failed to find ID", eventHandlerId, Geary.CC_END)
        return
    end
    Geary:DebugPrint(Geary.CC_DEBUG .. "Geary_Event unregistering ID", eventHandlerId, "from", eventName, Geary.CC_END)

    self.events[eventName][eventHandlerId] = nil
    if Geary:IsTableEmpty(self.events[eventName]) then
        self:UnregisterEvent(eventName)
        self.events[eventName] = nil
        Geary:DebugPrint(Geary.CC_DEBUG .. "Geary_Event unregistered", eventName, Geary.CC_END)
    end
end

function Geary_Event.eventFrame:_UnregisterAll()
    for eventName, _ in pairs(self.events) do
        self:UnregisterEvent(eventName)
        self.events[eventName] = nil
        Geary:DebugPrint(Geary.CC_DEBUG .. "Geary_Event unregistered", eventName, Geary.CC_END)
    end
end

-- callback is a function that receives the arguments applicable to its event
function Geary_Event:RegisterEvent(eventName, callback)
    local eventHandlerId = self.nextEventHandlerId
    self.nextEventHandlerId = self.nextEventHandlerId + 1
    self.eventFrame:_RegisterEvent(eventHandlerId, eventName, callback)
    return eventHandlerId
end

function Geary_Event:UnregisterEvent(eventHandlerId)
    self.eventFrame:_UnregisterEvent(eventHandlerId)
end

function Geary_Event:PLAYER_LOGOUT()
    self.eventFrame:_UnregisterAll()
end
