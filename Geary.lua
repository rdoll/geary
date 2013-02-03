--[[
	Geary main module
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary = {
	version = nil,
	title = nil,
	notes = nil,
	debugOn = false,
	eventsFrame = nil,
	events = {},
	-- Font Color Codes
	CC_START = "|c",
	CC_ERROR = RED_FONT_COLOR_CODE,
	CC_FAILED = "|cffff00ff",
	CC_MISSING = RED_FONT_COLOR_CODE,
	CC_CORRECT = GREEN_FONT_COLOR_CODE,
	CC_UPGRADE = YELLOW_FONT_COLOR_CODE,
	CC_MILESTONE = ORANGE_FONT_COLOR_CODE,
	CC_DEBUG = GRAY_FONT_COLOR_CODE,
	CC_END = FONT_COLOR_CODE_CLOSE
}

-- "VERSION" gets replaced with the TOC version
local _usage = [[
Geary version VERSION Usage
/geary inspect <self | target | group>
/geary ui <show | hide | toggle>
/geary icon <show | hide | toggle>
/geary options <show | hide | toggle>
/geary debug [on | off]
/geary dumpitem <itemid | itemlink> [slotname]
]]

function Geary:init()
	-- Our info
	self.version = GetAddOnMetadata("Geary", "Version")
	self.title = GetAddOnMetadata("Geary", "Title")
	self.notes = GetAddOnMetadata("Geary", "Notes")
	self:print("Loaded version", self.version)
	_usage = _usage:gsub("VERSION", Geary.version, 1)

	-- Key bindings
	_G["BINDING_HEADER_GEARY_BINDINGS_HEADER"] = self.title
	_G["BINDING_NAME_GEARY_INSPECT_SELF"] = "Inspect Self"
	_G["BINDING_NAME_GEARY_INSPECT_TARGET"] = "Inspect Target"
	_G["BINDING_NAME_GEARY_INSPECT_GROUP"] = "Inspect Group"
	_G["BINDING_NAME_GEARY_SHOW_UI"] = "Show Interface"
	_G["BINDING_NAME_GEARY_HIDE_UI"] = "Hide Interface"
	_G["BINDING_NAME_GEARY_TOGGLE_UI"] = "Toggle Interface"
	_G["BINDING_NAME_GEARY_SHOW_ICON"] = "Show Icon"
	_G["BINDING_NAME_GEARY_HIDE_ICON"] = "Hide Icon"
	_G["BINDING_NAME_GEARY_TOGGLE_ICON"] = "Toggle Icon"
	_G["BINDING_NAME_GEARY_SHOW_OPTIONS"] = "Show Options"
	_G["BINDING_NAME_GEARY_HIDE_OPTIONS"] = "Hide Options"
	_G["BINDING_NAME_GEARY_TOGGLE_OPTIONS"] = "Toggle Options"
	
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
		Geary_Icon:init()
		Geary_Options_Interface:init()
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

-- Automatically adds a space between arguments and a newline at end
function Geary:print(...)
	print(self.title .. ":", ...)
end

function Geary:debugPrint(...)
	if self.debugOn then
		self:print(...)
	end
end

function Geary:_log(...)
	local args = { ... }
	for index, value in ipairs(args) do
		Geary_Interface_Log:append(value)
		if index < #args then
			Geary_Interface_Log:append(" ")
		end
	end
end

-- Automatically adds a space between arguments and a newline at end
function Geary:log(...)
	self:_log(...)
	Geary_Interface_Log:append("\n")
end

function Geary:debugLog(...)
	if self.debugOn then
		Geary_Interface_Log:append(self.CC_DEBUG)
		self:_log(...)
		Geary_Interface_Log:append(self.CC_END)
		Geary_Interface_Log:append("\n")
	end
end


--
-- Main
--
Geary:init()


--
-- Slash commands
--

local function _slashCommandInspect(rest)
	if rest == "self" then
		Geary_Inspect:inspectSelf()
	elseif rest == "target" then
		Geary_Inspect:inspectTarget()
	elseif rest == "group" then
		Geary_Inspect:inspectGroup()
	else
		print(_usage)
	end
end

local function _slashCommandUi(rest)
	if rest == "show" then
		Geary_Interface:Show()
	elseif rest == "hide" then
		Geary_Interface:Hide()
	elseif rest == "toggle" then
		Geary_Interface:toggle()
	else
		print(_usage)
	end
end

local function _slashCommandIcon(rest)
	if rest == "show" then
		Geary_Icon:Show()
	elseif rest == "hide" then
		Geary_Icon:Hide()
	elseif rest == "toggle" then
		Geary_Icon:toggle()
	else
		print(_usage)
	end
end

local function _slashCommandOptions(rest)
	if rest == "show" then
		Geary_Options_Interface:Show()
	elseif rest == "hide" then
		Geary_Options_Interface:Hide()
	elseif rest == "toggle" then
		Geary_Options_Interface:toggle()
	else
		print(_usage)
	end
end

local function _slashCommandDebug(rest)		
	if rest == "on" then
		Geary.debugOn = true
	elseif rest == "off" then
		Geary.debugOn = false
	elseif rest:len() > 0 then
		print(_usage)
		return
	end
	Geary:print("Debugging is " .. (Geary:isDebugOn() and "on" or "off"))
end

local function _slashCommandDumpItem(rest)

	local itemLink, slotBaseName, slotName
	if rest:match("^|c") then
		itemLink, slotBaseName = rest:match("^(|c.-|r)%s*(.*)$")
	elseif rest:match("^%d") then
		local itemId
		itemId, slotBaseName = rest:match("^(%d+)%s*(.*)$")
		_, itemLink = GetItemInfo(tonumber(itemId))
		if itemLink == nil then
			Geary:print(Geary.CC_FAILED .. "Item ID", itemId, "not in local cache." .. Geary.CC_END)
			return
		end
	else
		print(_usage)
		return
	end
	
	if slotBaseName == nil or slotBaseName:len() == 0 then
		slotName = "MainHandSlot"  -- Default to anything enchantable
	else
		slotName = slotBaseName .. "Slot"
	end
	if not Geary_Item:isInvSlotName(slotName) then
		Geary:print(Geary.CC_ERROR .. "Invalid slot name", slotBaseName .. Geary.CC_END)
		return
	end
	
	local oldDebug = Geary.debugOn
	Geary.debugOn = true
	
	Geary_Interface_Log:clearIfTooLarge()
	Geary_Interface:Show()
	Geary:debugLog()
	Geary:debugLog("--- Dumping", slotName, "item", itemLink, "---")
	local item = Geary_Item:new{
		slot = slotName,
		link = itemLink
	}
	item:probe()
	
	if not DevTools_Dump then
		LoadAddOn("Blizzard_DebugTools")
	end
	if DevTools_Dump then
		DevTools_Dump(item)
	else
		Geary:debugPrint("Failed to load Blizzard_DebugTools or find DevTools_Dump")
	end
	
	Geary.debugOn = oldDebug
end

SLASH_GEARY1 = "/geary";

function SlashCmdList.GEARY(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "inspect" then
		_slashCommandInspect(rest)
	elseif command == "ui" then
		_slashCommandUi(rest)
	elseif command == "icon" then
		_slashCommandIcon(rest)
	elseif command == "options" then
		_slashCommandOptions(rest)
	elseif command == "debug" then
		_slashCommandDebug(rest)
	elseif command == "dumpitem" then
		_slashCommandDumpItem(rest)
	else
		print(_usage)
	end
end