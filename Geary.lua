--[[
    Geary main module

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary = {
    -- AddOn info
    version = nil,
    title   = nil,
    notes   = nil,

    -- Login session info
    homeRealmName = nil,

    -- Debug settings
    debugOn = false,

    -- Event handling
    eventsFrame = nil,
    events      = {},

    -- Font Color Codes
    CC_START     = "|c",
    CC_ERROR     = RED_FONT_COLOR_CODE,
    CC_FAILED    = "|cffff00ff",
    CC_MISSING   = RED_FONT_COLOR_CODE,
    CC_CORRECT   = GREEN_FONT_COLOR_CODE,
    CC_UPGRADE   = YELLOW_FONT_COLOR_CODE,
    CC_OPTIONAL  = YELLOW_FONT_COLOR_CODE,
    CC_MILESTONE = ORANGE_FONT_COLOR_CODE,
    CC_NA        = "|cff909090",
    CC_DEBUG     = GRAY_FONT_COLOR_CODE,
    CC_END       = FONT_COLOR_CODE_CLOSE,

    -- Inexplicably missing constants
    MAX_GEMS = 4
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
    self.title   = GetAddOnMetadata("Geary", "Title")
    self.notes   = GetAddOnMetadata("Geary", "Notes")
    self:print("Loaded version", self.version)
    _usage = _usage:gsub("VERSION", Geary.version, 1)
    self.homeRealmName = GetRealmName()

    -- Key bindings
    _G["BINDING_HEADER_GEARY_BINDINGS_HEADER"] = self.title
    _G["BINDING_NAME_GEARY_INSPECT_SELF"]      = "Inspect Self"
    _G["BINDING_NAME_GEARY_INSPECT_TARGET"]    = "Inspect Target"
    _G["BINDING_NAME_GEARY_INSPECT_GROUP"]     = "Inspect Group"
    _G["BINDING_NAME_GEARY_SHOW_UI"]           = "Show Interface"
    _G["BINDING_NAME_GEARY_HIDE_UI"]           = "Hide Interface"
    _G["BINDING_NAME_GEARY_TOGGLE_UI"]         = "Toggle Interface"
    _G["BINDING_NAME_GEARY_SHOW_ICON"]         = "Show Icon"
    _G["BINDING_NAME_GEARY_HIDE_ICON"]         = "Hide Icon"
    _G["BINDING_NAME_GEARY_TOGGLE_ICON"]       = "Toggle Icon"
    _G["BINDING_NAME_GEARY_SHOW_OPTIONS"]      = "Show Options"
    _G["BINDING_NAME_GEARY_HIDE_OPTIONS"]      = "Hide Options"
    _G["BINDING_NAME_GEARY_TOGGLE_OPTIONS"]    = "Toggle Options"

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
        Geary_Item:init() -- Must be before Geary_Interface_Player
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

--
-- Debugging and logging utilities
--

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
-- Table utilities that LUA lacks
--
-- Both # and table.getn return 0 if the table doesn't contain sequential indexes starting with one,
-- so make our own functions.
--

function Geary:isTableEmpty(t)
    if t ~= nil then
        for _ in pairs(t) do
            return false
        end
    end
    return true
end

function Geary:tableSize(t)
    local count = 0
    if t ~= nil then
        for _ in pairs(t) do
            count = count + 1
        end
    end
    return count
end

--
-- Version comparison utils
--

-- Smartly compare full version strings
-- Returns:
--   -1 if version1 is less than version2
--    0 if version1 equals version2
--    1 if version1 is greater than version2
function Geary:versionCompare(version1, version2)

    -- Split versions into a table of parts
    local v1Parts = version1 ~= nil and { strsplit(".-", version1) } or {}
    local v2Parts = version2 ~= nil and { strsplit(".-", version2) } or {}

    -- Compare each part
    for index = 1, max(#v1Parts, #v2Parts) do
        local partResult = self:_versionPartCompare(v1Parts[index], v2Parts[index])
        if partResult ~= 0 then
            return partResult  -- Parts did not match, so we're done
        end
    end

    return 0  -- All parts matched, so versions must be the same
end

-- Smartly compare a single version string
-- Returns:
--   -1 if v1Part is less than v2Part
--    0 if v1Part equals v2Part
--    1 if v1Part is greater than v2Part
function Geary:_versionPartCompare(v1Part, v2Part)

    -- Check lengths first
    if v1Part ~= nil and v2Part == nil then
        return -1  -- v2 is empty, but v1 is not so v1 is greater
    elseif v1Part == nil and v2Part == nil then
        return 0  -- Both parts are empty so they are equal
    elseif v1Part == nil and v2Part ~= nil then
        return 1  -- v1 is empty, but v2 is not so v2 is greater
    end

    -- Neither part is empty, compare numeric firsst
    local v1Num = tonumber(v1Part)
    local v2Num = tonumber(v2Part)
    if v1Num ~= nil and v2Num == nil then
        return -1  -- v2 is non-numeric, but v1 is so v1 is greater
    elseif v1Num == nil and v2Num == nil then
        -- Both are non-numeric
    elseif v1Num == nil and v2Num ~= nil then
        return 1  -- v1 is non-numeric, but v2 is so v2 is greater
    elseif v1Num > v2Num then
        return -1  -- Both are numeric and v1 is greater
    elseif v1Num == v2Num then
        return 0  -- Both are numeric and equal
    elseif v1Num < v2Num then
        return 1  -- Both are numeric and v2 is greater
    end

    -- Compare as strings
    if v1Part > v2Part then
        return -1  -- v1 is the greater string
    elseif v1Part == v2Part then
        return 0  -- Both are the same string
    elseif v1Part < v2Part then
        return 1  -- v2 is the greater string
    end
end


--
-- Date/time utilities
--

function Geary:colorizedRelativeDateTime(timestamp)

    if timestamp == nil or timestamp < 1 then
        return self.CC_NA .. "never" .. self.CC_END
    end

    local timeDiff = time() - timestamp
    if timeDiff < 5 * 60 then
        -- Less than 5 minutes
        return GREEN_FONT_COLOR_CODE .. "< 5 minutes ago" .. self.CC_END
    elseif timeDiff < 60 * 60 then
        -- 2 to 59 minutes
        return "|cff20bb20" .. floor(timeDiff / 60) .. " minutes ago" .. self.CC_END
    elseif timeDiff < 7 * 60 * 60 then
        -- 1 to 6 hours
        return "|cff20bbbb" .. floor(timeDiff / (60 * 60)) .. " hours ago" .. self.CC_END
    elseif timeDiff < 24 * 60 * 60 then
        -- 6 to 23 hours
        return YELLOW_FONT_COLOR_CODE .. floor(timeDiff / (60 * 60)) .. " hours ago" .. self.CC_END
    elseif timeDiff < 7 * 24 * 60 * 60 then
        -- 1 to 7 days
        return ORANGE_FONT_COLOR_CODE .. floor(timeDiff / (24 * 60 * 60)) .. " days ago" .. self.CC_END
    else
        -- More than 7 days
        return RED_FONT_COLOR_CODE .. floor(timeDiff / (24 * 60 * 60)) .. " days ago" .. self.CC_END
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
        slotName = "MainHandSlot" -- Default to anything enchantable
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
    Geary_Interface:selectTab("Log")
    Geary_Interface:Show()
    Geary:debugLog()
    Geary:debugLog("--- Dumping", slotName, "item", itemLink, "---")
    local item = Geary_Item:new{
        slot = slotName,
        link = itemLink
    }
    local player = Geary_Player:new{ unit = "player" } -- Use only guaranteed player we can get at
    player:probeInfo()
    item:probe(player)

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