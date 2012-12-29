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
	classId = nil,
	className = nil,
	level = nil
}

function Geary_Player:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Geary_Player:isMaxLevel()
	return self.level == 90
end

function Geary_Player:getInfo()
	if self.unit == nil then
		error("Cannot get player info without unit!")
		return
	end
	
	self.guid = UnitGUID(self.unit)
	self.className, self.classId, _, _, _, self.name, self.realm = GetPlayerInfoByGUID(self.guid)
	self.faction = select(1, UnitFactionGroup(self.unit))
	self.level = UnitLevel(self.unit)
end

function Geary_Player:getFullName()
	return self.name .. (((self.realm == nil) or (self.realm == "")) and "" or ("-" .. self.realm))
end