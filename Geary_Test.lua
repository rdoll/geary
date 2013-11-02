--[[
    Geary test module

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

--[[
    This entire file starts fully commented out to save WoW memory space.
    It must be manually uncommented to run tests.
--] ]

Geary_Test = {}

-- Automatically adds a space between arguments and a newline at end
function Geary_Test:_Header(name)
    print(" ")
    print(YELLOW_FONT_COLOR_CODE .. "-- Geary_Test: " .. name .. " --|r")
end

function Geary_Test:All()
    self:Dates()
    self:Tables()
    self:Entries()
    self:Versions()
    self:ClassColors()
end

function Geary_Test:Dates()
    self:_Header("Dates")
    print("nil =", Geary:ColorizedRelativeDateTime(nil))
    print("-1 =", Geary:ColorizedRelativeDateTime(-1))
    print("0 =", Geary:ColorizedRelativeDateTime(0))
    print("-1s =", Geary:ColorizedRelativeDateTime(time() + 1))
    print("0s =", Geary:ColorizedRelativeDateTime(time()))
    print("1s =", Geary:ColorizedRelativeDateTime(time() - 1))
    print("58s =", Geary:ColorizedRelativeDateTime(time() - 58))
    print("59s =", Geary:ColorizedRelativeDateTime(time() - 59))
    print("1m =", Geary:ColorizedRelativeDateTime(time() - 60))
    print("1m1s =", Geary:ColorizedRelativeDateTime(time() - 60 - 1))
    print("4m58s =", Geary:ColorizedRelativeDateTime(time() - (4 * 60) - 58))
    print("4m59s =", Geary:ColorizedRelativeDateTime(time() - (4 * 60) - 59))
    print("5m =", Geary:ColorizedRelativeDateTime(time() - (5 * 60)))
    print("5m1s =", Geary:ColorizedRelativeDateTime(time() - (5 * 60) - 1))
    print("59m58s =", Geary:ColorizedRelativeDateTime(time() - (59 * 60) - 58))
    print("59m59s =", Geary:ColorizedRelativeDateTime(time() - (59 * 60) - 59))
    print("1h =", Geary:ColorizedRelativeDateTime(time() - (60 * 60)))
    print("1h0m1s =", Geary:ColorizedRelativeDateTime(time() - (1 * 60 * 60) - (0 * 60) - 1))
    print("6h59m59s =", Geary:ColorizedRelativeDateTime(time() - (6 * 60 * 60) - (59 * 60) - 59))
    print("7h =", Geary:ColorizedRelativeDateTime(time() - (7 * 60 * 60) - (0 * 60) - 0))
    print("7h0m1s =", Geary:ColorizedRelativeDateTime(time() - (7 * 60 * 60) - (0 * 60) - 1))
    print("23h59m59s =", Geary:ColorizedRelativeDateTime(time() - (23 * 60 * 60) - (59 * 60) - 59))
    print("1d =", Geary:ColorizedRelativeDateTime(time() - (1 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 0))
    print("1d0h0m1s =", Geary:ColorizedRelativeDateTime(time() - (1 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
    print("6d23h59m59s =", Geary:ColorizedRelativeDateTime(time() - (6 * 24 * 60 * 60) - (23 * 60 * 60) - (59 * 60) - 59))
    print("7d =", Geary:ColorizedRelativeDateTime(time() - (7 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 0))
    print("7d0h0m1s =", Geary:ColorizedRelativeDateTime(time() - (7 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
    print("31d0h0m1s =", Geary:ColorizedRelativeDateTime(time() - (31 * 24 * 60 * 60) - (0 * 60 * 60) - (0 * 60) - 1))
end

function Geary_Test:Tables()
    self:_Header("Tables")
    print("nil =", Geary:TableSize(nil), Geary:IsTableEmpty(nil) and "empty" or "not empty")
    print("{} =", Geary:TableSize({}), Geary:IsTableEmpty({}) and "empty" or "not empty")
    print("{\"x\"} =", Geary:TableSize({ "x" }), Geary:IsTableEmpty({ "x" }) and "empty" or "not empty")
    print("{x=\"y\"} =", Geary:TableSize({ x = "y" }), Geary:IsTableEmpty({ x = "y" }) and "empty" or "not empty")
    print("{[\"0\"]=\"x\"} =", Geary:TableSize({ ["0"] = "x" }),
        Geary:IsTableEmpty({ ["0"] = "x" }) and "empty" or "not empty")
    print("{[\"1\"]=\"x\"} =", Geary:TableSize({ ["1"] = "x" }),
        Geary:IsTableEmpty({ ["1"] = "x" }) and "empty" or "not empty")
    print("{[\"2\"]=\"x\"} =", Geary:TableSize({ ["2"] = "x" }),
        Geary:IsTableEmpty({ ["2"] = "x" }) and "empty" or "not empty")
    print("{\"x\", \"y\"} =", Geary:TableSize({ "x", "y" }),
        Geary:IsTableEmpty({ "x", "y" }) and "empty" or "not empty")
    print("{x=\"y\", a=\"b\"} =", Geary:TableSize({ x = "y", a = "b" }),
        Geary:IsTableEmpty({ x = "y" }) and "empty" or "not empty")
    print("{[\"0\"]=\"x\", [\"1\"] = \"y\"} =", Geary:TableSize({ ["0"] = "x", ["1"] = "y" }),
        Geary:IsTableEmpty({ ["0"] = "x", ["1"] = "y" }) and "empty" or "not empty")
    print("{[\"0\"]=\"x\", [\"2\"] = \"y\"} =", Geary:TableSize({ ["0"] = "x", ["2"] = "y" }),
        Geary:IsTableEmpty({ ["0"] = "x", ["2"] = "y" }) and "empty" or "not empty")
    print("{[\"1\"]=\"x\", [\"2\"] = \"y\"} =", Geary:TableSize({ ["1"] = "x", ["2"] = "y" }),
        Geary:IsTableEmpty({ ["1"] = "x", ["2"] = "y" }) and "empty" or "not empty")
    print("{[\"1\"]=\"x\", [\"3\"] = \"y\"} =", Geary:TableSize({ ["1"] = "x", ["3"] = "y" }),
        Geary:IsTableEmpty({ ["1"] = "x", ["3"] = "y" }) and "empty" or "not empty")
    print("{[\"2\"]=\"x\", [\"4\"] = \"y\"} =", Geary:TableSize({ ["2"] = "x", ["4"] = "y" }),
        Geary:IsTableEmpty({ ["2"] = "x", ["4"] = "y" }) and "empty" or "not empty")
end

function Geary_Test:Entries()

    local tableAsString
    tableAsString = function (t)
        if t == nil then return "nil" end
        local s = ""
        for k, v in pairs(t) do
            s = s .. (strlen(s) > 0 and ", " or "") .. k .. "=" .. (type(v) == "table" and tableAsString(v) or v)
        end
        return "{" .. s .. "}"
    end

    local t

    self:_Header("Entries by name")
    local joinOrderedByName = function (t, f)
        local s = ""
        for k, v in Geary_Database_Entry.orderedPairsByName(t, f) do
            s = s .. (strlen(s) > 0 and ", " or "") .. k .. "=" .. tableAsString(v)
        end
        return "{" .. s .. "}"
    end
    t = { ["0x12"] = { playerName = "foo" }, ["0x23"] = { playerName = "bar" } }
    print(tableAsString(t) .. " ASC =", joinOrderedByName(t, true))
    print(tableAsString(t) .. " DESC =", joinOrderedByName(t, false))

    self:_Header("Entries by iLevel")
    local joinOrderedByILevel = function (t, f)
        local s = ""
        for k, v in Geary_Database_Entry.orderedPairsByILevel(t, f) do
            s = s .. (strlen(s) > 0 and ", " or "") .. k .. "=" .. tableAsString(v)
        end
        return s
    end
    t = { ["0x12"] = {}, ["0x23"] = { itemCount = 0, iLevelTotal = 2 }, ["0x05"] = { itemCount = 2, iLevelTotal = 10 } }
    print(tableAsString(t) .. " ASC =", joinOrderedByILevel(t, true))
    print(tableAsString(t) .. " DESC =", joinOrderedByILevel(t, false))
end

function Geary_Test:Versions()
    self:_Header("Versions")
    print("nil v nil", Geary:VersionCompare(nil, nil))
    print("nil v \"\"", Geary:VersionCompare(nil, ""))
    print("\"\" v nil", Geary:VersionCompare("", nil))
    print("\"\" v \"\"", Geary:VersionCompare("", ""))
    print("\"0\" v \"0\"", Geary:VersionCompare("0", "0"))
    print("\"0\" v \"1\"", Geary:VersionCompare("0", "1"))
    print("\"1\" v \"0\"", Geary:VersionCompare("1", "0"))
    print("\"0.4\" v \"0\"", Geary:VersionCompare("0.4", "0"))
    print("\"0\" v \"0.4\"", Geary:VersionCompare("0", "0.4"))
    print("\"0-4\" v \"0.4\"", Geary:VersionCompare("0.4", "0.4"))
    print("\"0.5\" v \"0.4\"", Geary:VersionCompare("0.5", "0.4"))
    print("\"0.4\" v \"0.5\"", Geary:VersionCompare("0.4", "0.5"))
    print("\"0.4\" v \"0-10\"", Geary:VersionCompare("0.4", "0.10"))
    print("\"0.10\" v \"0.4\"", Geary:VersionCompare("0.10", "0.4"))
    print("\"5.3.7-beta\" v \"5.3.7-beta\"", Geary:VersionCompare("5.3.7-beta", "5.3.7-beta"))
    print("\"5.3.10-beta\" v \"5.3.7-beta\"", Geary:VersionCompare("5.3.10-beta", "5.3.7-beta"))
    print("\"5.3.7-beta\" v \"5.3.7-alpha\"", Geary:VersionCompare("5.3.7-beta", "5.3.7-alpha"))
    print("\"5.3.7-release\" v \"5.3.7-beta\"", Geary:VersionCompare("5.3.7-release", "5.3.7-beta"))
end

function Geary_Test:ClassColors()
    self:_Header("ClassColors")
    print(nil, "\"\"", "=", Geary_Player:ClassColorize(nil, ""))
    print(0, "unknown", "=", Geary_Player:ClassColorize(0, "unknown"))
    for classId = 1, GetNumClasses() + 1 do
        local className = GetClassInfo(classId)
        print(classId, className, "=", Geary_Player:ClassColorize(classId, className))
    end
end

function Geary_Test:Tab()

    local parent = _G["Geary_Ui_Main_Content"]

    -- Main container for tab
    self.contentsFrame = CreateFrame("Frame", "$parent_Test", parent)
    self.contentsFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    self.contentsFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 1)
    self.contentsFrame:Hide()

    -- Summary table
    self.summaryTable = Geary_Interface_Summary_Table:new({parent = self.contentsFrame})

    -- Test summary rows
    local row1 = self.summaryTable:GetRow(1)
    row1:SetFaction("Horde")
    row1:SetClass(1)
    row1:SetSpec(71)
    row1:SetRole(71)
    row1:SetLevel(1)
    row1:SetILevel(16, 8)
    row1:SetName("Ll", "Thrall", 1)
    row1:SetMissing(16, 32)
    row1:SetInspected(time())

    local row2 = self.summaryTable:GetRow(2)
    row2:SetFaction("Alliance")
    row2:SetClass(11)
    row2:SetSpec(250)
    row2:SetRole(250)
    row2:SetLevel(90)
    row2:SetILevel(15, 15 * 500)
    row2:SetName("Testnametwo", "Islongerthanspace", 11)
    row2:SetMissing(0, 0)
    row2:SetInspected(time() - (60 * 60))

    local row3 = self.summaryTable:GetRow(3)
    row3:SetFaction(nil)
    row3:SetClass(nil)
    row3:SetSpec(nil)
    row3:SetRole(nil)
    row3:SetLevel(nil)
    row3:SetILevel(nil, nil)
    row3:SetName(nil, nil, nil)
    row3:SetMissing(nil, nil)
    row3:SetInspected(nil)

    -- Create tab
    Geary_Interface:CreateTab("Test",
        function() Geary_Test.contentsFrame:Show() end,
        function() Geary_Test.contentsFrame:Hide() end)

    -- Show the newly created tab
    Geary_Interface:Show()
    Geary_Interface:SelectTab("Test")
end

--[ [
    End of commenting out entire file
--]]
