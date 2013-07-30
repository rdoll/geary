--[[
	Geary test module
	
	LICENSE
	Geary is in the Public Domain as a thanks for the efforts of other AddOn
	developers that have made my WoW experience better for many years.
	Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

--[[
	This entire file starts out fully commented out to save WoW memory space.
	It must be manually uncommented to run tests.
--] ]	

Geary_Test = {}

-- Automatically adds a space between arguments and a newline at end
function Geary_Test:header(name)
	print(" ")
	print(YELLOW_FONT_COLOR_CODE .. "-- Geary_Test: " .. name .. " --|r")
end

function Geary_Test:all()
	self:dates()
end

function Geary_Test:dates()
	self:header("dates")
	print("nil =", Geary:colorizedRelativeDateTime(nil))
	print("-1 =", Geary:colorizedRelativeDateTime(-1))
	print("0 =", Geary:colorizedRelativeDateTime(0))
	print("-1s =", Geary:colorizedRelativeDateTime(time() + 1))
	print("0s =", Geary:colorizedRelativeDateTime(time()))
	print("1s =", Geary:colorizedRelativeDateTime(time() - 1))
	print("58s =", Geary:colorizedRelativeDateTime(time() - 58))
	print("59s =", Geary:colorizedRelativeDateTime(time() - 59))
	print("1m =", Geary:colorizedRelativeDateTime(time() - 60))
	print("1m1s =", Geary:colorizedRelativeDateTime(time() - 60 - 1))
	print("4m58s =", Geary:colorizedRelativeDateTime(time() - (4 * 60) - 58))
	print("4m59s =", Geary:colorizedRelativeDateTime(time() - (4 * 60) - 59))
	print("5m =", Geary:colorizedRelativeDateTime(time() - (5 * 60)))
	print("5m1s =", Geary:colorizedRelativeDateTime(time() - (5 * 60) - 1))
	print("59m58s =", Geary:colorizedRelativeDateTime(time() - (59 * 60) - 58))
	print("59m59s =", Geary:colorizedRelativeDateTime(time() - (59 * 60) - 59))
	print("1h =", Geary:colorizedRelativeDateTime(time() - (60 * 60)))
	print("1h0m1s =", Geary:colorizedRelativeDateTime(time() - (1 * 60 * 60) - (0 * 60) - 1))
	print("6h59m59s =", Geary:colorizedRelativeDateTime(time() - (6 * 60 * 60) - (59 * 60) - 59))
	print("7h =", Geary:colorizedRelativeDateTime(time() - (7 * 60 * 60) - (0 * 60) - 0))
	print("7h0m1s =", Geary:colorizedRelativeDateTime(time() - (7 * 60 * 60) - (0 * 60) - 1))
	print("23h59m59s =", Geary:colorizedRelativeDateTime(time() - (23 * 60 * 60) - (59 * 60) - 59))
	print("1d =", Geary:colorizedRelativeDateTime(
		time() - (1 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 0))
	print("1d0h0m1s =", Geary:colorizedRelativeDateTime(
		time() - (1 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
	print("6d23h59m59s =", Geary:colorizedRelativeDateTime(
		time() - (6 * 24 * 60 * 60) - (23 * 60 * 60) - (59 * 60) - 59))
	print("7d =", Geary:colorizedRelativeDateTime(
		time() - (7 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 0))
	print("7d0h0m1s =", Geary:colorizedRelativeDateTime(
		time() - (7 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
	print("31d0h0m1s =", Geary:colorizedRelativeDateTime(
		time() - (31 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
end

--[ [
	End of commenting out entire file
--]]
