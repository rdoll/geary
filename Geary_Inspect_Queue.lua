--[[
    Geary inspection queue

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Inspect_Queue = {
    queue = {}
}

function Geary_Inspect_Queue:_GetGuidIndex(guid)
    for index = 1, #self.queue do
        if self.queue[index] == guid then
            return index
        end
    end
    return nil
end

function Geary_Inspect_Queue:AddGuid(guid)
    local index = self:_GetGuidIndex(guid)
    if index == nil then
        tinsert(self.queue, guid)
    else
        Geary:DebugPrint(Geary.CC_DEBUG .. "Guid", guid, "already in inspect queue" .. Geary.CC_END)
    end
end

function Geary_Inspect_Queue:RemoveGuid(guid)
    local index = self:_GetGuidIndex(guid)
    if index == nil then
        Geary:DebugPrint(Geary.CC_DEBUG .. "Guid", guid, "not in inspect queue" .. Geary.CC_END)
    else
        tremove(self.queue, index)
    end
end

function Geary_Inspect_Queue:Clear()
    wipe(self.queue)
end

function Geary_Inspect_Queue:NextGuid()
    if #self.queue == 0 then
        return nil
    else
        local guid = tremove(self.queue, 1)
        return guid
    end
end

function Geary_Inspect_Queue:GetCount()
    return #self.queue
end
