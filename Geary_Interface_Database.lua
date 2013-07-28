--[[
	Geary database interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Database = {
	scrollFrame = nil,
	editBox = nil
}

function Geary_Interface_Database:init(parent)

	local frame = CreateFrame("ScrollFrame", "$parent_Database", parent, "UIPanelScrollFrameTemplate")
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

	-- TODO Need a better place for this button and it should match the frame's theme
	-- TODO StatTemplate looks promising, but has some default scripts specific to achievements
	local button = CreateFrame("Button", "$parent_DeleteAll", self.scrollFrame, "OptionsButtonTemplate")
	button:SetSize(95, 17)
	button:SetPoint("BOTTOM", self.scrollFrame, "BOTTOM", 24, -21)
	button:SetText("Delete All")
	button:SetScript("OnClick", function (self)	Geary_Interface_Database:deleteAll() end)

	Geary_Interface:createTab("Database",
		function () Geary_Interface_Database:Show() end,
		function () Geary_Interface_Database:Hide() end
	)
end

function Geary_Interface_Database:Show()
	self.scrollFrame:Show()
	self:renderEntries()
end

function Geary_Interface_Database:Hide()
	self.scrollFrame:Hide()
	self.editBox:SetText("\n")
end

function Geary_Interface_Database:onChanged()
	if self.scrollFrame:IsShown() then
		self:Show()
	end
end

function Geary_Interface_Database:deleteAll()
	Geary_Database:deleteAll()
	self:renderEntries()
end

-- TODO Temp to help with column alignment
function Geary_Interface_Database:strpad2(str, len)
	return ("%-" .. (strlen(str) + ((len - strlen(str)) * 2)) .. "s"):format(str)
end

function Geary_Interface_Database:renderEntries()
	self.editBox:SetText(Geary.CC_FAILED ..
		"Fac  Cls  Spe  Rol  Lvl  iLevel    Name                     " .. 
		"Missing    Inspected At" .. Geary.CC_END .. "\n")
	local missingRequired, missingOptional
	for _, entry in pairs(Geary_Database:getAllEntries()) do
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
	self.editBox:Insert(Geary.CC_FAILED .. "\n -- " .. Geary_Database:getNumberEntries() ..
		" inspection results stored (misaligned columns are temporary) --" .. Geary.CC_END)
end
