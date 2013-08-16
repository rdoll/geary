--[[
	Geary persistent database entry
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Database_Entry = {
	default = {
		playerGuid = nil,
		playerName = nil,
		playerRealm = nil,
		playerFaction = nil,
		playerLevel = nil,
		playerClassId = nil,
		playerSpecId = nil,
		itemCount = 0,
		iLevelTotal = 0,
		missingItems = 0,  -- empty + failed
		missingGems = 0,   -- missing + failed
		missingEnchants = 0,
		missingBeltBuckle = false,
		missingUpgrades = 0,
		missingEotbp = 0,
		missingCoh = false,
		missingCov = false,
		inspectedAt = nil
	}
}

function Geary_Database_Entry:new(o)
	o = o or {}
	for name, value in pairs(self.default) do
		if o[name] == nil then
			o[name] = value
		end
	end
	setmetatable(o, self)
	self.__index = self
	return o
end

function Geary_Database_Entry:makeObject(entryTable)
	setmetatable(entryTable, self)
	self.__index = self
end

function Geary_Database_Entry:createFromInspection(inspect)
	return self:new{
		playerGuid 		  	= inspect.player.guid,
		playerName 	      	= inspect.player.name,
		playerRealm 	  	= inspect.player.realm,
		playerFaction 	  	= inspect.player.faction,
		playerLevel 	  	= inspect.player.level,
		playerClassId 	  	= inspect.player.classId,
		playerSpecId 	  	= inspect.player.spec ~= nil and inspect.player.spec.id or nil,
		itemCount 	      	= inspect.itemCount,
		iLevelTotal 	  	= inspect.iLevelTotal,
		missingItems 	  	= inspect.emptySlots + inspect.failedSlots,
		missingGems 	  	= inspect.emptySockets + inspect.failedJewelIds,
		missingEnchants   	= inspect.unenchantedCount,
		missingBeltBuckle 	= inspect.isMissingBeltBuckle,
		missingUpgrades		= inspect.upgradeMax - inspect.upgradeLevel,
		missingEotbp 	  	= inspect.eotbpMissing,
		missingCoh 		  	= inspect.isMissingCohMeta,
		missingCov 	      	= inspect.isMissingCov,
		inspectedAt       	= time()
	}
end

function Geary_Database_Entry:createFromUnit(unit)
	local name, realm = UnitName(unit)
	local _, _, classId = UnitClass(unit)
	return self:new{
		playerName    = name,
		playerRealm   = realm,
		playerClassId = classId,
		playerLevel   = UnitLevel(unit)
	}
end

function Geary_Database_Entry:getPlayerFullName()
	return Geary_Player:fullPlayerName(self.playerName, self.playerRealm)
end

function Geary_Database_Entry:getFactionInlineIcon()
	-- Add 2 to log font height which is used as editbox font size
	local size = Geary_Options:getLogFontHeight() + 2
	if self.playerFaction == "Horde" then
		return "|TInterface\\PVPFrame\\PVP-Currency-Horde.png:" ..
			size .. ":" .. size .. ":0:0:32:32:2:30:2:30|t"
	elseif self.playerFaction == "Alliance" then
		return "|TInterface\\PVPFrame\\PVP-Currency-Alliance.png:" ..
			size .. ":" .. size .. ":0:0:32:32:4:28:2:30|t"
	else
		return "(?)"
	end
end

-- TODO Temp to help with column alignment
function Geary_Database_Entry:strpad2prefix(str, len)
	return ("%" .. (strlen(str) + ((len - strlen(str)) * 2)) .. "s"):format(str)
end

function Geary_Database_Entry:getEquippedItemLevelString()
	local iLevelString
	if self.itemCount and self.itemCount > 0 then
		iLevelString = ("%6.2f"):format(self.iLevelTotal / self.itemCount)
	else
		iLevelString = "?"
	end
	return self:strpad2prefix(iLevelString, 6)
end

function Geary_Database_Entry:getClassInlineIcon()
	return Geary.CC_NA .. "(?)" .. Geary.CC_END
end

function Geary_Database_Entry:getSpecName()
	if self.playerSpecId == nil then
		return "None"
	end
	
	local _, specName = GetSpecializationInfoByID(self.playerSpecId)
	return specName
end

function Geary_Database_Entry:getSpecInlineIcon()
	if self.playerSpecId == nil then
		return "(?)"
	end
	local _, _, _, icon = GetSpecializationInfoByID(self.playerSpecId)
	-- Add 2 to log font height which is used as editbox font size
	return "|T" .. icon .. ":" .. (Geary_Options:getLogFontHeight() + 2) .. "|t"
	--return "|T" .. icon .. ":12:12:0:0:64:64:0:63:0:63|t"
end

function Geary_Database_Entry:getRoleInlineIcon()
	return Geary.CC_DEBUG .. "(?)" .. Geary.CC_END
end

function Geary_Database_Entry:getMissingRequiredCount()
	return self.missingItems + self.missingGems + self.missingEnchants +
		(self.missingBeltBuckle and 1 or 0)
end

function Geary_Database_Entry:getMissingOptionalCount()
	return self.missingUpgrades + self.missingEotbp + (self.missingCoh and 1 or 0) +
		(self.missingCov and 1 or 0)
end
