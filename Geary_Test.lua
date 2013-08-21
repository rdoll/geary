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
    self:tables()
    self:versions()
    self:classColors()
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
    print("1d =", Geary:colorizedRelativeDateTime(time() - (1 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 0))
    print("1d0h0m1s =", Geary:colorizedRelativeDateTime(time() - (1 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
    print("6d23h59m59s =", Geary:colorizedRelativeDateTime(time() - (6 * 24 * 60 * 60) - (23 * 60 * 60) - (59 * 60) - 59))
    print("7d =", Geary:colorizedRelativeDateTime(time() - (7 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 0))
    print("7d0h0m1s =", Geary:colorizedRelativeDateTime(time() - (7 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
    print("31d0h0m1s =", Geary:colorizedRelativeDateTime(time() - (31 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
end

function Geary_Test:tables()
    self:header("tables")
    print("nil =", Geary:tableSize(nil), Geary:isTableEmpty(nil) and "empty" or "not empty")
    print("{} =", Geary:tableSize({}), Geary:isTableEmpty({}) and "empty" or "not empty")
    print("{\"x\"} =", Geary:tableSize({ "x" }), Geary:isTableEmpty({ "x" }) and "empty" or "not empty")
    print("{x=\"y\"} =", Geary:tableSize({ x = "y" }), Geary:isTableEmpty({ x = "y" }) and "empty" or "not empty")
    print("{[\"0\"]=\"x\"} =", Geary:tableSize({ ["0"] = "x" }),
        Geary:isTableEmpty({ ["0"] = "x" }) and "empty" or "not empty")
    print("{[\"1\"]=\"x\"} =", Geary:tableSize({ ["1"] = "x" }),
        Geary:isTableEmpty({ ["1"] = "x" }) and "empty" or "not empty")
    print("{[\"2\"]=\"x\"} =", Geary:tableSize({ ["2"] = "x" }),
        Geary:isTableEmpty({ ["2"] = "x" }) and "empty" or "not empty")
    print("{\"x\", \"y\"} =", Geary:tableSize({ "x", "y" }),
        Geary:isTableEmpty({ "x", "y" }) and "empty" or "not empty")
    print("{x=\"y\", a=\"b\"} =", Geary:tableSize({ x = "y", a = "b" }),
        Geary:isTableEmpty({ x = "y" }) and "empty" or "not empty")
    print("{[\"0\"]=\"x\", [\"1\"] = \"y\"} =", Geary:tableSize({ ["0"] = "x", ["1"] = "y" }),
        Geary:isTableEmpty({ ["0"] = "x", ["1"] = "y" }) and "empty" or "not empty")
    print("{[\"0\"]=\"x\", [\"2\"] = \"y\"} =", Geary:tableSize({ ["0"] = "x", ["2"] = "y" }),
        Geary:isTableEmpty({ ["0"] = "x", ["2"] = "y" }) and "empty" or "not empty")
    print("{[\"1\"]=\"x\", [\"2\"] = \"y\"} =", Geary:tableSize({ ["1"] = "x", ["2"] = "y" }),
        Geary:isTableEmpty({ ["1"] = "x", ["2"] = "y" }) and "empty" or "not empty")
    print("{[\"1\"]=\"x\", [\"3\"] = \"y\"} =", Geary:tableSize({ ["1"] = "x", ["3"] = "y" }),
        Geary:isTableEmpty({ ["1"] = "x", ["3"] = "y" }) and "empty" or "not empty")
    print("{[\"2\"]=\"x\", [\"4\"] = \"y\"} =", Geary:tableSize({ ["2"] = "x", ["4"] = "y" }),
        Geary:isTableEmpty({ ["2"] = "x", ["4"] = "y" }) and "empty" or "not empty")
end

function Geary_Test:versions()
    self:header("versions")
    print("nil v nil", Geary:versionCompare(nil, nil))
    print("nil v \"\"", Geary:versionCompare(nil, ""))
    print("\"\" v nil", Geary:versionCompare("", nil))
    print("\"\" v \"\"", Geary:versionCompare("", ""))
    print("\"0\" v \"0\"", Geary:versionCompare("0", "0"))
    print("\"0\" v \"1\"", Geary:versionCompare("0", "1"))
    print("\"1\" v \"0\"", Geary:versionCompare("1", "0"))
    print("\"0.4\" v \"0\"", Geary:versionCompare("0.4", "0"))
    print("\"0\" v \"0.4\"", Geary:versionCompare("0", "0.4"))
    print("\"0-4\" v \"0.4\"", Geary:versionCompare("0.4", "0.4"))
    print("\"0.5\" v \"0.4\"", Geary:versionCompare("0.5", "0.4"))
    print("\"0.4\" v \"0.5\"", Geary:versionCompare("0.4", "0.5"))
    print("\"0.4\" v \"0-10\"", Geary:versionCompare("0.4", "0.10"))
    print("\"0.10\" v \"0.4\"", Geary:versionCompare("0.10", "0.4"))
    print("\"5.3.7-beta\" v \"5.3.7-beta\"", Geary:versionCompare("5.3.7-beta", "5.3.7-beta"))
    print("\"5.3.10-beta\" v \"5.3.7-beta\"", Geary:versionCompare("5.3.10-beta", "5.3.7-beta"))
    print("\"5.3.7-beta\" v \"5.3.7-alpha\"", Geary:versionCompare("5.3.7-beta", "5.3.7-alpha"))
    print("\"5.3.7-release\" v \"5.3.7-beta\"", Geary:versionCompare("5.3.7-release", "5.3.7-beta"))
end

function Geary_Test:classColors()
    self:header("classColors")
    print(nil, "\"\"", "=", Geary_Player:classColorize(nil, ""))
    print(0, "unknown", "=", Geary_Player:classColorize(0, "unknown"))
    for classId = 1, GetNumClasses() + 1 do
        local className = GetClassInfo(classId)
        print(classId, className, "=", Geary_Player:classColorize(classId, className))
    end
end

function Geary_Test:tab()

    local parent = _G["Geary_Ui_Main_Content"]

    -- Main container for tab
    self.contentsFrame = CreateFrame("Frame", "$parent_Test", parent)
    self.contentsFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    self.contentsFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
    self.contentsFrame:Hide()

    -- Summary table
    self.summaryTable = Geary_Interface_Summary_Table:new({parent = self.contentsFrame})

    -- Test summary rows
    local row1 = self.summaryTable:getRow(1)
    row1:setFaction("Horde")
    row1:setClass(1)
    row1:setSpec(71)
    row1:setRole(71)
    row1:setLevel(1)
    row1:setILevel(16, 8)
    row1:setName("Ll", "Thrall", 1)
    row1:setMissing(16, 32)
    row1:setInspected(time())

    local row2 = self.summaryTable:getRow(2)
    row2:setFaction("Alliance")
    row2:setClass(11)
    row2:setSpec(250)
    row2:setRole(250)
    row2:setLevel(90)
    row2:setILevel(15, 15 * 500)
    row2:setName("Testnametwo", "Islongerthanspace", 11)
    row2:setMissing(0, 0)
    row2:setInspected(time() - (60 * 60))

    local row3 = self.summaryTable:getRow(3)
    row3:setFaction(nil)
    row3:setClass(nil)
    row3:setSpec(nil)
    row3:setRole(nil)
    row3:setLevel(nil)
    row3:setILevel(nil, nil)
    row3:setName(nil, nil, nil)
    row3:setMissing(nil, nil)
    row3:setInspected(nil)

    -- Create tab
    Geary_Interface:createTab("Test",
        function() Geary_Test.contentsFrame:Show() end,
        function() Geary_Test.contentsFrame:Hide() end)

    -- Show the newly created tab
    Geary_Interface:Show()
    Geary_Interface:selectTab("Test")
end

--[ [
    End of commenting out entire file
--]]
