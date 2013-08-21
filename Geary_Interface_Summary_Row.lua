--[[
    Geary inspection summary row

    LICENSE
    Geary is in the Public Domain as a thanks for the efforts of other AddOn
    developers that have made my WoW experience better for many years.
    Any credits to me (FoamHead) and/or Geary would be appreciated.
--]]

Geary_Interface_Summary_Row = {
    summaryRowNumber = 0,
    fontFilename = "Fonts\\FRIZQT__.TTF",
    fontSize = 10,
    fontCharacterWidth = 7,
    rowHeight = 12
}

-- Returns a uniquely named row frame that's a child of config.parent
function Geary_Interface_Summary_Row:new(config)
    if config == nil or config.parent == nil then
        error("SummaryRow requires a parent to instantiate")
        return nil
    end

    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:createContents(config.parent)
    return o
end

function Geary_Interface_Summary_Row:createContents(parent)

    -- Increment static unique row number (cannot use self -- that's an instance)
    Geary_Interface_Summary_Row.summaryRowNumber = Geary_Interface_Summary_Row.summaryRowNumber + 1

    -- Characteristics of the frame's contents
    local rowHeight = Geary_Interface_Summary_Row.rowHeight
    local fontFilename = Geary_Interface_Summary_Row.fontFilename
    local fontSize = Geary_Interface_Summary_Row.fontSize
    local fontCharacterWidth = Geary_Interface_Summary_Row.fontCharacterWidth
    local fontHalfCharacterWidth = floor(fontCharacterWidth)

    -- Outermost container for row (points set by caller)
    self.rowFrame = CreateFrame("Frame", "$parent_SummaryRow_" .. Geary_Interface_Summary_Row.summaryRowNumber, parent)
    self.rowFrame:SetHeight(rowHeight)

    -- Start with the backdrop hidden and show/hide it on enter/leave
    self.rowFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
        tile = true,
        tileSize = 32
    })
    self.rowFrame:SetBackdropColor(0, 0, 0, 0)
    self.rowFrame:SetScript("OnEnter", function(frame, motion)
        frame:SetBackdropColor(1, 1, 1, 1)
    end)
    self.rowFrame:SetScript("OnLeave", function(frame, motion)
        frame:SetBackdropColor(0, 0, 0, 0)
    end)
    self.rowFrame:SetScript("OnHide", function(frame, motion)
        frame:SetBackdropColor(0, 0, 0, 0)
    end)

    -- Faction texture
    self.factionTexture = self.rowFrame:CreateTexture("$parent_Faction", "OVERLAY")
    self.factionTexture:SetPoint("TOPLEFT", self.rowFrame, "TOPLEFT", 2, 0)
    self.factionTexture:SetSize(rowHeight, rowHeight)

    -- Class texture
    self.classTexture = self.rowFrame:CreateTexture("$parent_Class", "OVERLAY")
    self.classTexture:SetPoint("TOPLEFT", self.factionTexture, "TOPRIGHT", 12, 0)
    self.classTexture:SetSize(rowHeight, rowHeight)

    -- Specialization texture
    self.specTexture = self.rowFrame:CreateTexture("$parent_Spec", "OVERLAY")
    self.specTexture:SetPoint("TOPLEFT", self.classTexture, "TOPRIGHT", 12, 0)
    self.specTexture:SetSize(rowHeight, rowHeight)

    -- Role texture
    self.roleTexture = self.rowFrame:CreateTexture("$parent_Role", "OVERLAY")
    self.roleTexture:SetPoint("TOPLEFT", self.specTexture, "TOPRIGHT", 14, 0)
    self.roleTexture:SetSize(rowHeight, rowHeight)

    -- Level font string
    self.levelFontString = self.rowFrame:CreateFontString("$parent_Level", "ARTWORK")
    self.levelFontString:SetPoint("TOPLEFT", self.roleTexture, "TOPRIGHT", 8, 0)
    self.levelFontString:SetSize(2 * fontCharacterWidth, rowHeight)
    self.levelFontString:SetFont(fontFilename, fontSize)
    self.levelFontString:SetJustifyH("RIGHT")
    self.levelFontString:SetJustifyV("MIDDLE")

    -- Equipped item level font string
    self.iLevelFontString = self.rowFrame:CreateFontString("$parent_iLevel", "ARTWORK")
    self.iLevelFontString:SetPoint("TOPLEFT", self.levelFontString, "TOPRIGHT", 8, 0)
    -- 5 digits plus a period
    self.iLevelFontString:SetSize(5 * fontCharacterWidth + fontHalfCharacterWidth, rowHeight)
    self.iLevelFontString:SetFont(fontFilename, fontSize)
    self.iLevelFontString:SetJustifyH("RIGHT")
    self.iLevelFontString:SetJustifyV("MIDDLE")

    -- Name font string
    self.nameFontString = self.rowFrame:CreateFontString("$parent_Name", "ARTWORK")
    self.nameFontString:SetPoint("TOPLEFT", self.iLevelFontString, "TOPRIGHT", 8, 0)
    self.nameFontString:SetSize(14 * fontCharacterWidth, rowHeight)
    self.nameFontString:SetFont(fontFilename, fontSize)
    self.nameFontString:SetJustifyH("LEFT")
    self.nameFontString:SetJustifyV("MIDDLE")

    -- Missing font string
    self.missingFontString = self.rowFrame:CreateFontString("$parent_Missing", "ARTWORK")
    self.missingFontString:SetPoint("TOPLEFT", self.nameFontString, "TOPRIGHT", 10, 0)
    -- Up to 4 digits, a slash, and 2 spaces
    self.missingFontString:SetSize(5 * fontCharacterWidth + (2 * fontHalfCharacterWidth), rowHeight)
    self.missingFontString:SetFont(fontFilename, fontSize)
    self.missingFontString:SetJustifyH("CENTER")
    self.missingFontString:SetJustifyV("MIDDLE")

    -- Inspected at font string
    self.inspectedFontString = self.rowFrame:CreateFontString("$parent_Inspected", "ARTWORK")
    self.inspectedFontString:SetPoint("TOPLEFT", self.missingFontString, "TOPRIGHT", 12, 0)
    self.inspectedFontString:SetPoint("RIGHT", self.rowFrame, "RIGHT", 0, 0)
    self.inspectedFontString:SetHeight(rowHeight)
    self.inspectedFontString:SetFont(fontFilename, fontSize)
    self.inspectedFontString:SetJustifyH("LEFT")
    self.inspectedFontString:SetJustifyV("MIDDLE")
end

function Geary_Interface_Summary_Row:getFrame()
    return self.rowFrame
end

local _unknownTextureFilename = "Interface\\ICONS\\INV_Misc_QuestionMark"
local _unknownTextureInline = "|T" .. _unknownTextureFilename .. ":0|t"

function Geary_Interface_Summary_Row:_setUnknownIconTexture(texture)
    texture:SetTexture(_unknownTextureFilename)
    texture:SetTexCoord(0, 1, 0, 1)
end

function Geary_Interface_Summary_Row:setFaction(factionName)
    if factionName == "Horde" then
        self.factionTexture:SetTexture("Interface\\PVPFrame\\PVP-Currency-Horde")
        self.factionTexture:SetTexCoord(2 / 32, 30 / 32, 2 / 32, 30 / 32)
    elseif factionName == "Alliance" then
        self.factionTexture:SetTexture("Interface\\PVPFrame\\PVP-Currency-Alliance")
        self.factionTexture:SetTexCoord(4 / 32, 28 / 32, 2 / 32, 30 / 32)
    else
        self:_setUnknownIconTexture(self.factionTexture)
    end
end

function Geary_Interface_Summary_Row:setClass(classId)
    local _, classTag, _ = GetClassInfo(classId or 0) -- translate nil to 0
    if CLASS_ICON_TCOORDS[classTag] == nil then
        self:_setUnknownIconTexture(self.classTexture)
    else
        self.classTexture:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        self.classTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classTag]))
    end
end

function Geary_Interface_Summary_Row:setSpec(specId)
    local _, _, _, icon = GetSpecializationInfoByID(specId or 0) -- translate nil to 0
    if icon == nil then
        self:_setUnknownIconTexture(self.specTexture)
    else
        self.specTexture:SetTexture(icon)
    end
end

local _roleIconTexCoords = {
    ["TANK"]    = {  0 / 64, 19 / 64, 22 / 64, 41 / 64 },
    ["HEALER"]  = { 20 / 64, 39 / 64,  1 / 64, 20 / 64 },
    ["DAMAGER"] = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 }
}

function Geary_Interface_Summary_Row:setRole(specId)
    local roleTag = GetSpecializationRoleByID(specId or 0) -- translate nil to 0
    if roleTag == nil then
        self:_setUnknownIconTexture(self.roleTexture)
    else
        self.roleTexture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        self.roleTexture:SetTexCoord(unpack(_roleIconTexCoords[roleTag]))
    end
end

function Geary_Interface_Summary_Row:setLevel(level)
    self.levelFontString:SetText(level or _unknownTextureInline)
end

function Geary_Interface_Summary_Row:setILevel(itemCount, iLevelTotal)
    if itemCount and itemCount > 0 then
        self.iLevelFontString:SetFormattedText("%6.2f", iLevelTotal / itemCount)
    else
        self.iLevelFontString:SetText(_unknownTextureInline)
    end
end

function Geary_Interface_Summary_Row:setName(name, realm, classId)
    if name == nil or strlen(name) == 0 then
        self.nameFontString:SetText(_unknownTextureInline)
    else
        self.nameFontString:SetText(Geary_Player:classColorize(classId, Geary_Player:fullPlayerName(name, realm)))
    end
end

function Geary_Interface_Summary_Row:setMissing(requiredCount, optionalCount)
    local required, optional
    if requiredCount == nil then
        required = _unknownTextureInline
    else
        required = (requiredCount > 0 and Geary.CC_MISSING or Geary.CC_CORRECT) .. requiredCount .. Geary.CC_END
    end
    if optionalCount == nil then
        optional = _unknownTextureInline
    else
        optional = (optionalCount > 0 and Geary.CC_OPTIONAL or Geary.CC_CORRECT) .. optionalCount .. Geary.CC_END
    end
    self.missingFontString:SetText(required .. " / " .. optional)
end

function Geary_Interface_Summary_Row:setInspected(inspected)
    self.inspectedFontString:SetText(Geary:colorizedRelativeDateTime(inspected))
end
