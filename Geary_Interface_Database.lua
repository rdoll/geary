--[[
	Geary database interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Database = {
	fontString = nil
}

function Geary_Interface_Database:init(parent)
	local fontString = parent:CreateFontString("$parent_Database", "ARTWORK", "GameFontNormal")
	fontString:Hide()
	fontString:SetPoint("CENTER", parent, "CENTER", 0, 0)
	fontString:SetText("Database is not yet implemented")
	self.fontString = fontString
	
	Geary_Interface:createTab("Database",
		function () Geary_Interface_Database.fontString:Show() end,
		function () Geary_Interface_Database.fontString:Hide() end
	)
end
