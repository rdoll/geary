--[[
	Geary group interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Group = {
	fontString = nil,
	contentsFrame = nil,
	rowsFrame = nil,
	groupEntries = {}
}

function Geary_Interface_Group:init(parent)

    local fontString = parent:CreateFontString("$parent_Group_FontString", "ARTWORK", "GameFontNormal")
    fontString:Hide()
    fontString:SetPoint("CENTER", parent, "CENTER", 0, 0)
    fontString:SetText("You are not in a group")
    self.fontString = fontString

	-- Main container for tab
	local contentsFrame = CreateFrame("Frame", "$parent_Group", parent)
	contentsFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
	contentsFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
	contentsFrame:Hide()
	self.contentsFrame = contentsFrame

	-- Table header row frame
	local headerFrame = CreateFrame("Frame", "$parent_Header", contentsFrame)
	headerFrame:SetPoint("TOPLEFT", contentsFrame, "TOPLEFT")
	headerFrame:SetPoint("TOPRIGHT", contentsFrame, "TOPRIGHT")

	-- Table header row frame contents
	local headerFontString = headerFrame:CreateFontString("$parent_FontString")
	headerFontString:SetFont("Fonts\\FRIZQT__.TTF", 10)
	headerFontString:SetPoint("TOPLEFT", headerFrame, "TOPLEFT")
	headerFontString:SetText(Geary.CC_FAILED ..
		"Fac  Cls  Spe  Rol  Lvl  iLevel    Name                     " .. 
		"Missing       Inspected" .. Geary.CC_END)

	-- Set table header row frame's height to fit contents
	headerFrame:SetHeight(headerFontString:GetHeight())
	
	-- Table body scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", contentsFrame,
		"UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT")
	scrollFrame:SetPoint("BOTTOMRIGHT", contentsFrame, "BOTTOMRIGHT")
	
	-- Table body scroll frame container for rows
	local rowsFrame = CreateFrame("Frame", "$parent_Rows", scrollFrame)
	rowsFrame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT")
	rowsFrame:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())
	rowsFrame.rows = {}
	self.rowsFrame = rowsFrame

	-- Tie rows container frame to scroll frame
	scrollFrame:SetScrollChild(rowsFrame)
	
	Geary_Interface:createTab("Group",
		function () Geary_Interface_Group:Show() end,
		function () Geary_Interface_Group:Hide() end
	)
end

function Geary_Interface_Group:Show()
	self:updateGroupEntries()
	if Geary:isTableEmpty(self.groupEntries) then
		self.fontString:Show()
		self.contentsFrame:Hide()
	else
		self.fontString:Hide()
		self.contentsFrame:Show()
		self:renderEntries()
	end
end

function Geary_Interface_Group:Hide()
	self.fontString:Hide()
	self.contentsFrame:Hide()
end

-- TODO While this tab is shown, party/group/raid changed event and automatically update
function Geary_Interface_Group:onChanged()
	if self.contentsFrame:IsShown() then
		self:Show()
	end
end

-- TODO Need a better solution than this
function Geary_Interface_Group:makeFakeEntry(unit, guid)
	local name, realm = UnitName(unit)
	local _, _, classId = UnitClass(unit)
	local entry = {
		neverInspected = true,
		fullName =  name .. ((realm and strlen(realm) > 0) and ("-" .. realm) or ""),
		playerClassId = classId,
		playerLevel = UnitLevel(unit)
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

function Geary_Interface_Group:getRow(rowNumber)

	if self.rowsFrame.rows[rowNumber] ~= nil then
		-- Row was already created, so just return it
		return self.rowsFrame.rows[rowNumber]
	end
	
	-- Row does not exist so create it
	-- Note: Assumes rows are always created in sequential order
	local frame = CreateFrame("Frame", "$parent_Row_" .. rowNumber, self.rowsFrame)
	if rowNumber == 1 then
		-- First row is linked to top of rowsFrame
		frame:SetPoint("TOPLEFT", self.rowsFrame, "TOPLEFT")
		frame:SetPoint("TOPRIGHT", self.rowsFrame, "TOPRIGHT")
	else
		-- Subsequent rows are linked to their predecessor
		frame:SetPoint("TOPLEFT", self.rowsFrame.rows[rowNumber - 1], "BOTTOMLEFT")
		frame:SetPoint("TOPRIGHT", self.rowsFrame.rows[rowNumber - 1], "BOTTOMRIGHT")
	end
	frame:SetHeight(12)
	
	-- Contents of row
	local fontString = frame:CreateFontString("$parent_FontString")
	fontString:SetFont("Fonts\\FRIZQT__.TTF", 10)
	fontString:SetPoint("TOPLEFT", frame, "TOPLEFT")
	fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	fontString:SetJustifyH("LEFT")
	fontString:SetJustifyV("TOP")
	frame.fontString = fontString

	self.rowsFrame.rows[rowNumber] = frame
	return frame
end

-- TODO Temp to help with column alignment
function Geary_Interface_Group:strpad2(str, len)
	return ("%-" .. (strlen(str) + ((len - strlen(str)) * 2)) .. "s"):format(str)
end

function Geary_Interface_Group:renderEntries()

	local inspectedCount, groupItemCount, groupILevelTotal = 0, 0, 0
	local missingRequired, missingOptional, row
	local rowNumber = 1
	for guid, entry in pairs(self.groupEntries) do
		if entry.neverInspected then
			row = self:getRow(rowNumber)
			row.fontString:SetText(
				("%s  -      -      -      -     %s   ---.--%s     %s    %s- / -       never%s"):format(
					Geary.CC_NA,
					entry.playerLevel and entry.playerLevel or " -  ",
					Geary.CC_END,
					Geary_Player:classColorize(
						entry.playerClassId, self:strpad2(strsub(entry.fullName, 1, 16), 16)),
					Geary.CC_NA,
					Geary.CC_END))
		else
			inspectedCount = inspectedCount + 1
			groupItemCount = groupItemCount + entry.itemCount
			groupILevelTotal = groupILevelTotal + entry.iLevelTotal
			missingRequired = entry:getMissingRequiredCount()
			missingOptional = entry:getMissingOptionalCount()
			row = self:getRow(rowNumber)
			row.fontString:SetText(
				(" %s    %s    %s    %s   %2d  %6.2f  %s    %s / %s       %s"):format(
					entry:getFactionInlineIcon(),
					entry:getClassInlineIcon(),
					entry:getSpecInlineIcon(),
					entry:getRoleInlineIcon(),
					entry.playerLevel,
					entry:getEquippedItemLevel(),
					Geary_Player:classColorize(entry.playerClassId,
						self:strpad2(strsub(entry:getPlayerFullName(), 1, 16), 16)),
					(missingRequired > 0 and Geary.CC_MISSING or Geary.CC_CORRECT) .. missingRequired ..
						Geary.CC_END,
					(missingOptional > 0 and Geary.CC_OPTIONAL or Geary.CC_CORRECT) .. missingOptional ..
						Geary.CC_END,
					Geary:colorizedRelativeDateTime(entry.inspectedAt)))
		end
		rowNumber = rowNumber + 1
	end
	
	if inspectedCount > 0 then
		row = self:getRow(rowNumber)
		row.fontString:SetText(Geary.CC_FAILED .. 
			" -- Group average iLevel is " .. Geary.CC_END ..
			("%6.2f"):format(groupILevelTotal / groupItemCount) .. Geary.CC_END .. 
			Geary.CC_FAILED .. " --" .. Geary.CC_END)
		rowNumber = rowNumber + 1
	end

	row = self:getRow(rowNumber)
	row.fontString:SetText(Geary.CC_FAILED .. " -- " .. inspectedCount .. " of " ..
		Geary:tableSize(self.groupEntries) .. " group members inspected " ..
		"(misaligned columns are temporary) --" .. Geary.CC_END)
end
