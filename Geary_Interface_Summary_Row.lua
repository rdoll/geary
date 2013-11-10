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

    local o = {
        rowButton = nil,
        playerGuid = nil,
        onClickHandler = nil
    }
    setmetatable(o, self)
    self.__index = self
    o:_CreateContents(config.parent)
    return o
end

function Geary_Interface_Summary_Row:_CreateContents(parent)

    -- Increment static unique row number (cannot use self -- that's an instance)
    Geary_Interface_Summary_Row.summaryRowNumber = Geary_Interface_Summary_Row.summaryRowNumber + 1

    -- Characteristics of the frame's contents
    local rowHeight = Geary_Interface_Summary_Row.rowHeight
    local fontFilename = Geary_Interface_Summary_Row.fontFilename
    local fontSize = Geary_Interface_Summary_Row.fontSize
    local fontCharacterWidth = Geary_Interface_Summary_Row.fontCharacterWidth
    local fontHalfCharacterWidth = floor(fontCharacterWidth)

    -- Outermost container for row (points set by caller)
    self.rowButton = CreateFrame("Button", "$parent_SummaryRow_" .. Geary_Interface_Summary_Row.summaryRowNumber, parent)
    self.rowButton:SetHeight(rowHeight)

    -- Start with the backdrop hidden and show/hide it on enter/leave
    self.rowButton:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
        tile = true,
        tileSize = 32
    })
    self.rowButton:SetBackdropColor(0, 0, 0, 0)
    self.rowButton:SetScript("OnEnter", function(frame, motion)
        frame:SetBackdropColor(1, 1, 1, 1)
    end)
    self.rowButton:SetScript("OnLeave", function(frame, motion)
        frame:SetBackdropColor(0, 0, 0, 0)
    end)
    self.rowButton:SetScript("OnHide", function(frame, motion)
        frame:SetBackdropColor(0, 0, 0, 0)
    end)

    -- Trap clicks we care about
    self.rowButton.row = self
    self.rowButton:RegisterForClicks("RightButtonUp")
    self.rowButton:SetScript("OnClick", function(self, mouseButton, down)
        if mouseButton == "RightButton" then
            self.row:OnClick(mouseButton, down)
        end
    end)

    -- Faction texture
    self.factionTexture = self.rowButton:CreateTexture("$parent_Faction", "OVERLAY")
    self.factionTexture:SetPoint("TOPLEFT", self.rowButton, "TOPLEFT", 2, 0)
    self.factionTexture:SetSize(rowHeight, rowHeight)

    -- Class texture
    self.classTexture = self.rowButton:CreateTexture("$parent_Class", "OVERLAY")
    self.classTexture:SetPoint("TOPLEFT", self.factionTexture, "TOPRIGHT", 12, 0)
    self.classTexture:SetSize(rowHeight, rowHeight)

    -- Specialization texture
    self.specTexture = self.rowButton:CreateTexture("$parent_Spec", "OVERLAY")
    self.specTexture:SetPoint("TOPLEFT", self.classTexture, "TOPRIGHT", 12, 0)
    self.specTexture:SetSize(rowHeight, rowHeight)

    -- Role texture
    self.roleTexture = self.rowButton:CreateTexture("$parent_Role", "OVERLAY")
    self.roleTexture:SetPoint("TOPLEFT", self.specTexture, "TOPRIGHT", 14, 0)
    self.roleTexture:SetSize(rowHeight, rowHeight)

    -- Level font string
    self.levelFontString = self.rowButton:CreateFontString("$parent_Level", "ARTWORK")
    self.levelFontString:SetPoint("TOPLEFT", self.roleTexture, "TOPRIGHT", 8, 0)
    self.levelFontString:SetSize((2 * fontCharacterWidth) + 1, rowHeight)  -- Add 1 because 34 doesn't fit
    self.levelFontString:SetFont(fontFilename, fontSize)
    self.levelFontString:SetJustifyH("RIGHT")
    self.levelFontString:SetJustifyV("MIDDLE")

    -- Equipped item level font string
    self.iLevelFontString = self.rowButton:CreateFontString("$parent_iLevel", "ARTWORK")
    self.iLevelFontString:SetPoint("TOPLEFT", self.levelFontString, "TOPRIGHT", 8, 0)
    -- 5 digits plus a period
    self.iLevelFontString:SetSize(5 * fontCharacterWidth + fontHalfCharacterWidth, rowHeight)
    self.iLevelFontString:SetFont(fontFilename, fontSize)
    self.iLevelFontString:SetJustifyH("RIGHT")
    self.iLevelFontString:SetJustifyV("MIDDLE")

    -- Name font string
    self.nameFontString = self.rowButton:CreateFontString("$parent_Name", "ARTWORK")
    self.nameFontString:SetPoint("TOPLEFT", self.iLevelFontString, "TOPRIGHT", 8, 0)
    self.nameFontString:SetSize(14 * fontCharacterWidth, rowHeight)
    self.nameFontString:SetFont(fontFilename, fontSize)
    self.nameFontString:SetJustifyH("LEFT")
    self.nameFontString:SetJustifyV("MIDDLE")

    -- Missing font string
    self.missingFontString = self.rowButton:CreateFontString("$parent_Missing", "ARTWORK")
    self.missingFontString:SetPoint("TOPLEFT", self.nameFontString, "TOPRIGHT", 10, 0)
    -- Up to 4 digits, a slash, and 2 spaces
    self.missingFontString:SetSize(5 * fontCharacterWidth + (2 * fontHalfCharacterWidth), rowHeight)
    self.missingFontString:SetFont(fontFilename, fontSize)
    self.missingFontString:SetJustifyH("CENTER")
    self.missingFontString:SetJustifyV("MIDDLE")

    -- Inspected at font string
    self.inspectedFontString = self.rowButton:CreateFontString("$parent_Inspected", "ARTWORK")
    self.inspectedFontString:SetPoint("TOPLEFT", self.missingFontString, "TOPRIGHT", 12, 0)
    self.inspectedFontString:SetPoint("RIGHT", self.rowButton, "RIGHT", 0, 0)
    self.inspectedFontString:SetHeight(rowHeight)
    self.inspectedFontString:SetFont(fontFilename, fontSize)
    self.inspectedFontString:SetJustifyH("LEFT")
    self.inspectedFontString:SetJustifyV("MIDDLE")
end

function Geary_Interface_Summary_Row:GetButton()
    return self.rowButton
end

function Geary_Interface_Summary_Row:Show()
    self.rowButton:Show()
end

function Geary_Interface_Summary_Row:Hide()
    self.rowButton:Hide()
end

function Geary_Interface_Summary_Row:SetOnClickHandler(onClickHander)
    self.onClickHandler = onClickHander
end

function Geary_Interface_Summary_Row:OnClick(mouseButton, down)
    if self.onClickHandler ~= nil then
        self.onClickHandler(self, mouseButton, down)
    end
end

local _unknownTextureFilename = "Interface\\ICONS\\INV_Misc_QuestionMark"
local _unknownTextureInline = "|T" .. _unknownTextureFilename .. ":0|t"

function Geary_Interface_Summary_Row:_SetUnknownIconTexture(texture)
    texture:SetTexture(_unknownTextureFilename)
    texture:SetTexCoord(0, 1, 0, 1)
end

function Geary_Interface_Summary_Row:GetGuid()
    return self.playerGuid
end

function Geary_Interface_Summary_Row:SetGuid(guid)
    self.playerGuid = guid
end

function Geary_Interface_Summary_Row:SetFaction(factionName)
    if factionName == "Horde" then
        self.factionTexture:SetTexture("Interface\\PVPFrame\\PVP-Currency-Horde")
        self.factionTexture:SetTexCoord(2 / 32, 30 / 32, 2 / 32, 30 / 32)
    elseif factionName == "Alliance" then
        self.factionTexture:SetTexture("Interface\\PVPFrame\\PVP-Currency-Alliance")
        self.factionTexture:SetTexCoord(4 / 32, 28 / 32, 2 / 32, 30 / 32)
    else
        self:_SetUnknownIconTexture(self.factionTexture)
    end
end

function Geary_Interface_Summary_Row:SetClass(classId)
    local _, classTag, _ = GetClassInfo(classId or 0) -- translate nil to 0
    if CLASS_ICON_TCOORDS[classTag] == nil then
        self:_SetUnknownIconTexture(self.classTexture)
    else
        self.classTexture:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        self.classTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classTag]))
    end
end

function Geary_Interface_Summary_Row:SetSpec(specId)
    local _, _, _, icon = GetSpecializationInfoByID(specId or 0) -- translate nil to 0
    if icon == nil then
        self:_SetUnknownIconTexture(self.specTexture)
    else
        self.specTexture:SetTexture(icon)
    end
end

local _roleIconTexCoords = {
    ["TANK"]    = {  0 / 64, 19 / 64, 22 / 64, 41 / 64 },
    ["HEALER"]  = { 20 / 64, 39 / 64,  1 / 64, 20 / 64 },
    ["DAMAGER"] = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 }
}

function Geary_Interface_Summary_Row:SetRole(specId)
    local roleTag = GetSpecializationRoleByID(specId or 0) -- translate nil to 0
    if roleTag == nil then
        self:_SetUnknownIconTexture(self.roleTexture)
    else
        self.roleTexture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        self.roleTexture:SetTexCoord(unpack(_roleIconTexCoords[roleTag]))
    end
end

function Geary_Interface_Summary_Row:SetLevel(level)
    self.levelFontString:SetText(level or _unknownTextureInline)
end

function Geary_Interface_Summary_Row:SetILevel(itemCount, iLevelTotal)
    if itemCount and iLevelTotal and itemCount > 0 then
        self.iLevelFontString:SetFormattedText("%6.2f", iLevelTotal / itemCount)
    else
        self.iLevelFontString:SetText(_unknownTextureInline)
    end
end

function Geary_Interface_Summary_Row:SetName(name, realm, classId)
    if name == nil or strlen(name) == 0 then
        self.nameFontString:SetText(_unknownTextureInline)
    else
        self.nameFontString:SetText(Geary_Player:ClassColorize(classId, Geary_Player:FullPlayerName(name, realm)))
    end
end

function Geary_Interface_Summary_Row:SetMissing(requiredCount, optionalCount)
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

function Geary_Interface_Summary_Row:SetInspected(inspected)
    self.inspectedFontString:SetText(Geary:ColorizedRelativeDateTime(inspected))
end

function Geary_Interface_Summary_Row:SetFromEntry(entry)
    self:SetGuid(entry.playerGuid)
    self:SetFaction(entry.playerFaction)
    self:SetClass(entry.playerClassId)
    self:SetSpec(entry.playerSpecId)
    self:SetRole(entry.playerSpecId)
    self:SetLevel(entry.playerLevel)
    self:SetILevel(entry.itemCount, entry.iLevelTotal)
    self:SetName(entry.playerName, entry.playerRealm, entry.playerClassId)
    self:SetMissing(entry:GetMissingRequiredCount(), entry:GetMissingOptionalCount())
    self:SetInspected(entry.inspectedAt)
end
