--[[
	Geary player interface
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Player = {
	fontString = nil
}

function Geary_Interface_Player:init(parent)
	local fontString = parent:CreateFontString("$parent_Player", "ARTWORK", "GameFontNormal")
	fontString:Hide()
	fontString:SetPoint("CENTER", parent, "CENTER", 0, 0)
	fontString:SetText("Player summary is not yet implemented")
	self.fontString = fontString

	Geary_Interface:createTab("Player",
		function () Geary_Interface_Player.fontString:Show() end,
		function () Geary_Interface_Player.fontString:Hide() end
	)
end
