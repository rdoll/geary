--[[

--]]

Geary = {
	version = nil,
	title = nil,
	debugOn = false,
	eventsFrame = nil,
	events = {}
}

-- "VERSION" gets replaced with the TOC version
local usage = [[
Geary version VERSION Usage
/geary inspect [player | target | group]
/geary [show | hide | toggle]
/geary dumpitem [itemid | itemlink]
/geary debug [on | off]
]]

function Geary:init()
	-- Our info
	self.version = GetAddOnMetadata("Geary", "Version")
	self.title = GetAddOnMetadata("Geary", "Title")
	self:print("Loaded version " .. self.version)
	usage = usage:gsub("VERSION", Geary.version, 1)

	-- Key bindings
	_G["BINDING_HEADER_GEARY_BINDINGS_HEADER"] = self.title
	_G["BINDING_NAME_Geary Show UI"] = "Show Interface"
	_G["BINDING_NAME_Geary Hide UI"] = "Hide Interface"
	_G["BINDING_NAME_Geary Toggle UI"] = "Toggle Interface"
	_G["BINDING_NAME_Geary Show Icon"] = "Show Icon"
	_G["BINDING_NAME_Geary Hide Icon"] = "Hide Icon"
	_G["BINDING_NAME_Geary Toggle Icon"] = "Toggle Icon"
	_G["BINDING_NAME_Geary Inspect Self"] = "Inspect Self"
	_G["BINDING_NAME_Geary Inspect Target"] = "Inspect Target"
	_G["BINDING_NAME_Geary Inspect Group"] = "Inspect Group"
	
	-- Set script handlers for defined events
	-- Note that the event first argument is eaten when the handler is invoked
	self.eventsFrame = CreateFrame("Frame", "Geary_EventsFrame")
	self.eventsFrame:Hide()
	self.eventsFrame:SetScript("OnEvent", function(self, event, ...)
		Geary.events[event](self, ...)
	end)

	-- Register loading events
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGOUT")
end

function Geary:RegisterEvent(eventName)
	self.eventsFrame:RegisterEvent(eventName)
end

function Geary:UnregisterEvent(eventName)
	self.eventsFrame:UnregisterEvent(eventName)
end

function Geary.events:ADDON_LOADED(addOnName)
	if addOnName == "Geary" then
		-- Don't need to track ADDON_LOADED anymore
		Geary:UnregisterEvent("ADDON_LOADED")
		
		-- Init saved variables first
		Geary_Options:ADDON_LOADED()
		Geary_Database:ADDON_LOADED()
	
		-- Init other modules
		Geary_Item:init()
		Geary_Interface:init()
	end
end

function Geary.events:PLAYER_LOGOUT()
	-- Unregister all events
	for eventName, _ in pairs(self) do
		Geary:UnregisterEvent(eventName)
	end
	
	-- Abort any inspection in progress
	Geary_Inspect:PLAYER_LOGOUT()
end

function Geary.events:INSPECT_READY(unitGuid)
	Geary_Inspect:INSPECT_READY(unitGuid)
end

function Geary:isDebugOn()
	return self.debugOn
end

function Geary:print(...)
	print(self.title .. ":", ...)
end

function Geary:debugPrint(...)
	if self.debugOn then
		self:print(...)
	end
end

function Geary:log(...)
	Geary_Interface_Log:AddMessage(...)
end

function Geary:debugLog(...)
	if self.debugOn then
		self:log(...)
	end
end


--
-- Main
--
Geary:init()


--
-- Slash commands
--

SLASH_GEARY1 = "/geary";

function SlashCmdList.GEARY(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "inspect" then
		if rest == "player" then
			Geary_Inspect:inspectPlayer()
		elseif rest == "target" then
			Geary_Inspect:inspectTarget()
		elseif rest == "group" then
			Geary_Inspect:inspectGroup()
		else
			print(usage)
			return
		end
	elseif command == "show" then
		Geary_Interface:Show()
	elseif command == "hide" then
		Geary_Interface:Hide()
	elseif command == "toggle" then
		Geary_Interface:toggle()
	elseif command == "debug" then
		if rest == "on" then
			Geary.debugOn = true
		elseif rest == "off" then
			Geary.debugOn = false
		elseif rest ~= "" then
			print(usage)
			return
		end
		print("Geary debugging is " .. (Geary:isDebugOn() and "on" or "off"))
	elseif command == "dumpitem" then
		if rest:match("^%d+$") or rest:match("^|") then
			Geary_Interface:Show()
			Geary_Interface_Log:Clear()
			local oldDebug = Geary.debugOn
			Geary.debugOn = true
			local itemLink
			if rest:match("^|") then
				itemLink = rest
			else
				_, itemLink = GetItemInfo(tonumber(rest))
			end
			local item = Geary_Item:new{
				slot = "MainHandSlot",   -- Doesn't matter; just want something that can be enchanted
				link = itemLink
			}
			item:probe()
			if DevTools_Dump then
				DevTools_Dump(item)
			end
			Geary.debugOn = oldDebug
		else
			print(usage)
			return
		end
	else
		print(usage)
		return
	end
end