--[[
	Geary group interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Group = {
	fontString = nil,
	scrollFrame = nil,
	editBox = nil,
	groupEntries = {}
}

function Geary_Interface_Group:init(parent)

    local fontString = parent:CreateFontString("$parent_Group", "ARTWORK", "GameFontNormal")
    fontString:Hide()
    fontString:SetPoint("CENTER", parent, "CENTER", 0, 0)
    fontString:SetText("You are not in a group")
    self.fontString = fontString

	local frame = CreateFrame("ScrollFrame", "$parent_Group", parent, "UIPanelScrollFrameTemplate")
		-- "UIPanelScrollFrameTemplate2")  Includes borders around the scrollbar
	frame:Hide()
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
	frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
	self.scrollFrame = frame

	local editBox = CreateFrame("EditBox", "$parent_EditBox", self.scrollFrame)
	editBox:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT")
	editBox:SetSize(self.scrollFrame:GetWidth(), self.scrollFrame:GetHeight())
	editBox:SetMultiLine(true)
	editBox:SetIndentedWordWrap(false)
	editBox:SetAutoFocus(false)
	editBox:EnableMouse(true)
	editBox:EnableMouseWheel(true)
	editBox:Disable()
	-- TODO Add options to control this
	editBox:SetFont("Fonts\\FRIZQT__.TTF", 10)
	self.editBox = editBox
	
	self.scrollFrame:SetScrollChild(self.editBox)

	Geary_Interface:createTab("Group",
		function () Geary_Interface_Group:Show() end,
		function () Geary_Interface_Group:Hide() end
	)
end

function Geary_Interface_Group:Show()
	self:updateGroupEntries()
	if Geary:isTableEmpty(self.groupEntries) then
		self.fontString:Show()
		self.scrollFrame:Hide()
		self.editBox:SetText("")
	else
		self.fontString:Hide()
		self.scrollFrame:Show()
		self:renderEntries()
	end
end

function Geary_Interface_Group:Hide()
	self.fontString:Hide()
	self.scrollFrame:Hide()
	self.editBox:SetText("")
end

-- TODO While this tab is shown, party/group/raid changed event and automatically update
function Geary_Interface_Group:onChanged()
	if self.scrollFrame:IsShown() then
		self:Show()
	end
end

-- TODO Need a better solution than this
function Geary_Interface_Group:makeFakeEntry(unit, guid)
	local name, realm = UnitName(unit)
	local _, classTag, _ = UnitClass(unit)
	local entry = {
		neverInspected = true,
		fullName =  name .. ((realm and strlen(realm) > 0) and ("-" .. realm) or ""),
		classColor = Geary.CC_START .. RAID_CLASS_COLORS[classTag].colorStr,
		level = UnitLevel(unit)
	}
	return entry
end

function Geary_Interface_Group:updateGroupEntries()

	wipe(self.groupEntries)

	local unitPrefix, unitLimit, entry, guid
	if IsInRaid() then
		-- Player is included in raid units
		unitPrefix = "raid"
		unitLimit = 40
	elseif IsInGroup() then
		-- Player is not included in party units
		guid = UnitGUID("player")
		local entry = Geary_Database:getEntry(guid)
		self.groupEntries[guid] = entry and entry or self:makeFakeEntry("player", guid)
		unitPrefix = "party"
		unitLimit = 4
	else
		return
	end
	
	local unit
	for unitNumber = 1, unitLimit do
		unit = unitPrefix .. unitNumber
		guid = UnitGUID(unit)
		if guid then
			entry = Geary_Database:getEntry(guid)
			self.groupEntries[guid] = entry and entry or self:makeFakeEntry(unit, guid)
		end
	end
end

-- TODO Temp to help with column alignment
function Geary_Interface_Group:strpad2(str, len)
	return ("%-" .. (strlen(str) + ((len - strlen(str)) * 2)) .. "s"):format(str)
end

function Geary_Interface_Group:renderEntries()

	self.editBox:SetText(Geary.CC_FAILED ..
		"Fac  Cls  Spe  Rol  Lvl  iLevel    Name                     Missing    Inspected At\n" ..
		Geary.CC_END)
	
	local inspectedCount, groupItemCount, groupILevelTotal = 0, 0, 0
	local missingRequired, missingOptional
	for guid, entry in pairs(self.groupEntries) do
		if entry.neverInspected then
			self.editBox:Insert(
				("%s  -      -      -      -     %s   ---.--%s     %s    %s- / -    Never%s\n"):format(
					Geary.CC_NA,
					entry.level and entry.level or " -  ",
					Geary.CC_END,
					entry.classColor .. self:strpad2(strsub(entry.fullName, 1, 16), 16) .. Geary.CC_END,
					Geary.CC_NA,
					Geary.CC_END))
		else
			inspectedCount = inspectedCount + 1
			groupItemCount = groupItemCount + entry.itemCount
			groupILevelTotal = groupILevelTotal + entry.iLevelTotal
			missingRequired = entry:getMissingRequiredCount()
			missingOptional = entry:getMissingOptionalCount()
			self.editBox:Insert(
				(" %s    %s    %s    %s   %2d  %6.2f  %s    %s / %s    %s\n"):format(
					entry:getFactionInlineIcon(),
					entry:getClassInlineIcon(),
					entry:getSpecInlineIcon(),
					entry:getRoleInlineIcon(),
					entry.playerLevel,
					entry:getEquippedItemLevel(),
					entry:classColorize(self:strpad2(strsub(entry:getPlayerFullName(), 1, 16), 16)),
					(missingRequired > 0 and Geary.CC_MISSING or Geary.CC_CORRECT) .. missingRequired ..
						Geary.CC_END,
					(missingOptional > 0 and Geary.CC_OPTIONAL or Geary.CC_CORRECT) .. missingOptional ..
						Geary.CC_END,
					Geary.CC_NA .. entry:getInspectedAt() .. Geary.CC_END))
		end
	end
	
	if inspectedCount > 0 then
		self.editBox:Insert(Geary.CC_FAILED .. 
			"\n -- Group average iLevel is " .. Geary.CC_END ..
			("%6.2f"):format(groupILevelTotal / groupItemCount) .. Geary.CC_END .. 
			Geary.CC_FAILED .. " --" .. Geary.CC_END)
	end
	
	self.editBox:Insert(Geary.CC_FAILED .. "\n -- " .. inspectedCount .. " of " ..
		Geary:tableSize(self.groupEntries) .. " group members inspected " ..
		"(misaligned columns are temporary) --" .. Geary.CC_END)
end
