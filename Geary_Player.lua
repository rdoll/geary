--[[
	Geary player manager
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Player = {
	unit = nil,
	guid = nil,
	name = nil,
	realm = nil,
	faction = nil,
	className = nil,
	classId = nil,
	level = nil,
	spec = nil,
	
	-- Why oh why isn't there a constant for this?
	MAX_LEVEL = 90
}

function Geary_Player:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Geary_Player:classColorize(classId, text)
	local _, classTag, _ = GetClassInfo(classId or 0)  -- translate nil to zero to prevent errors
	text = text or ""
	if RAID_CLASS_COLORS[classTag] == nil then
		return text
	else
		return Geary.CC_START .. RAID_CLASS_COLORS[classTag].colorStr .. text .. Geary.CC_END
	end
end

function Geary_Player:fullPlayerName(name, realm)
	if name == nil then
		return nil
	end
	if realm == nil or strlen(realm) == 0 or realm == Geary.homeRealmName then
		return name
	else
		return name .. "-" .. realm
	end
end

function Geary_Player:isMaxLevel()
	return self.level == self.MAX_LEVEL
end

function Geary_Player:probeInfo()
	if self.unit == nil then
		error("Cannot get player info without unit!")
		return
	end
	
	self.guid = UnitGUID(self.unit)
	self.name, self.realm = UnitName(self.unit)
	-- realm is nil when on home realm, but empty string when player is on home realm and DCed
	if self.realm == nil or strlen(self.realm) == 0 then
		self.realm = Geary.homeRealmName  -- No realm means home realm
	end
	self.className, _, self.classId = UnitClass(self.unit)
	self.level = UnitLevel(self.unit)
	self.faction, _ = UnitFactionGroup(self.unit)
end

function Geary_Player:isUnitStillSamePlayer()
	return self.guid == UnitGUID(self.unit)
end

function Geary_Player:getFullNameLink()
	return format(TEXT_MODE_A_STRING_DEST_UNIT, "", self.guid, self.name,
		self:fullPlayerName(self.name, self.realm))
end

function Geary_Player:getFactionInlineIcon()
	if self.faction == "Horde" then
		return "|TInterface\\PVPFrame\\PVP-Currency-Horde.png:16:16:0:0:32:32:2:30:2:30|t"
	elseif self.faction == "Alliance" then
		return "|TInterface\\PVPFrame\\PVP-Currency-Alliance.png:16:16:0:0:32:32:4:28:2:30|t"
	else
		return "(?)"
	end
end

function Geary_Player:getColorizedClassName()
	return self:classColorize(self.classId, self.className)
end

local _roleInlineIcons = {
	["TANK"]    = INLINE_TANK_ICON,
	["HEALER"]  = INLINE_HEALER_ICON,
	["DAMAGER"] = INLINE_DAMAGER_ICON
}

function Geary_Player:getSpecWithInlineIcon()
	if self.spec == nil then
		return "NoSpec"
	elseif self.spec.role ~= nil and _roleInlineIcons[self.spec.role] ~= nil then
		return self.spec.name .. " " .. _roleInlineIcons[self.spec.role]
	else
		return self.spec.name
	end
end

-- Fury warriors level 38 and higher have Titan's grip
-- I wish there were Blizzard constants for these dang literals :(
function Geary_Player:hasTitansGrip()
	return self.classId ~= nil and self.classId == 1 and
		self.level ~= nil and self.level >= 38 and
		self.spec ~= nil and self.spec.id ~= nil and self.spec.id == 72
end

function Geary_Player:INSPECT_READY()

	-- This can be called multiple times if inspection retries are necessary,
	-- so if we already have spec info, don't bother asking for it again
	if self.spec ~= nil then
		return
	end
	
	local specId, specName, roleTag
	if self.unit == "player" then
		local nonGlobSpecId = GetSpecialization()
		if nonGlobSpecId == nil then
			Geary:print(Geary.CC_ERROR .. "nonGlobSpecId is nil!" .. Geary.CC_END)
			return
		end
		specId, specName, _, _, _, roleTag = GetSpecializationInfo(nonGlobSpecId)
	else
		local globSpecId = GetInspectSpecialization(self.unit)
		if globSpecId == nil then
			Geary:print(Geary.CC_ERROR .. "globSpecId is nil!" .. Geary.CC_END)
			return
		elseif globSpecId == 0 then
			Geary:print(Geary.CC_ERROR .. "globSpecId is 0 -- server didn't send it" .. Geary.CC_END)
			return
		end
		--
		-- From http://www.wowpedia.org/API_GetSpecializationInfoByID
		--
		-- Warning: As of 2012/07/12, this seems to be quite often buggy:
		-- The return of GetInspectSpecialization() should be a number less than 500,
		-- but sometimes is far greater and not interpretable. FrameXML is therefore
		-- 'validating' the value by calling GetSpecializationRoleByID(), and only
		-- if that returns a non-nil value, it decodes the number with GetSpecializationInfoByID().
		--
		roleTag = GetSpecializationRoleByID(globSpecId)
		if roleTag == nil then
			Geary:print(Geary.CC_ERROR .. "globSpecId " .. globSpecId .. " is invalid!" .. Geary.CC_END)
			return
		end
		specId, specName, _, _, _, _, _ = GetSpecializationInfoByID(globSpecId)
	end
	
	if specName == nil then
		Geary:print(Geary.CC_ERROR .. "specName is nil!" .. Geary.CC_END)
		return
	elseif roleTag == nil then
		Geary:print(Geary.CC_ERROR .. "roleTag is nil!" .. Geary.CC_END)
		return
	end
	
	self.spec = {
		id = specId,
		name = specName,
		role = roleTag
	}
end