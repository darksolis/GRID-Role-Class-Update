--[[--------------------------------------------------------------------
    GridFrameDecorations.lua
    Integrated role icons, CoA/standard class icons, and unit power bars.
    Grid 1.30300.1308 / WoW 3.3.5a
----------------------------------------------------------------------]]

local _, ns = ...
local L = ns.L

local GridFrame = Grid:GetModule("GridFrame")
local GridFrameDecorations = Grid:NewModule("GridFrameDecorations")
_G.GridFrameDecorations = GridFrameDecorations

GridFrameDecorations.menuName = "Role, Class & Power"

local MEDIA = "Interface\\AddOns\\Grid\\Decorations\\"
local CLASS_ATLAS = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
local WHITE = "Interface\\AddOns\\Grid\\white16x16"
local POWER_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

local ROLE_TEXTURES = {
    TANK = MEDIA .. "Role_Tank",
    HEALER = MEDIA .. "Role_Healer",
    DAMAGER = MEDIA .. "Role_DPS",
    DPS = MEDIA .. "Role_DPS",
    SUPPORT = MEDIA .. "Role_Support_v3",
}

local STANDARD_CLASS_COORDS = {
    WARRIOR     = { 0, 0.25, 0, 0.25 },
    MAGE        = { 0.25, 0.50, 0, 0.25 },
    ROGUE       = { 0.50, 0.75, 0, 0.25 },
    DRUID       = { 0.75, 1, 0, 0.25 },
    HUNTER      = { 0, 0.25, 0.25, 0.50 },
    SHAMAN      = { 0.25, 0.50, 0.25, 0.50 },
    PRIEST      = { 0.50, 0.75, 0.25, 0.50 },
    WARLOCK     = { 0.75, 1, 0.25, 0.50 },
    PALADIN     = { 0, 0.25, 0.50, 0.75 },
    DEATHKNIGHT = { 0.25, 0.50, 0.50, 0.75 },
}

local COA_CLASS_NAMES = {
    NECROMANCER = true, PYROMANCER = true, CULTIST = true, STARCALLER = true,
    SUNCLERIC = true, TINKER = true, RUNEMASTER = true, PRIMALIST = true,
    REAPER = true, VENOMANCER = true, CHRONOMANCER = true, BLOODMAGE = true,
    GUARDIAN = true, STORMBRINGER = true, FELSWORN = true, BARBARIAN = true,
    WITCHDOCTOR = true, WITCHHUNTER = true, KNIGHTOFXOROTH = true,
    TEMPLAR = true, RANGER = true,
}

local POWER_COLORS = {
    [0] = { 0.00, 0.55, 1.00 }, -- Mana
    [1] = { 0.90, 0.10, 0.10 }, -- Rage
    [2] = { 1.00, 0.50, 0.25 }, -- Focus
    [3] = { 1.00, 0.85, 0.10 }, -- Energy
    [4] = { 0.00, 1.00, 1.00 }, -- Happiness
    [5] = { 0.20, 0.80, 1.00 }, -- Runes
    [6] = { 0.00, 0.82, 1.00 }, -- Runic Power
}

GridFrameDecorations.defaultDB = {
    enabled = true,

    showTank = true,
    showHealer = true,
    showDPS = true,
    showSupport = true,
    roleSize = 13,
    rolePosition = "TOPLEFT",

    enableRoleMenu = true,
    unknownRoleFallback = "NONE",
    decorationsSchemaVersion = 2,

    showClass = true,
    preferCoAIcons = true,
    showStandardClassFallback = true,
    classSize = 13,
    classPosition = "TOPRIGHT",

    showPower = true,
    powerHeight = 4,
    powerInset = 1,
    powerBackgroundAlpha = 0.85,
    hidePowerWhenEmpty = false,

    iconInset = 1,
    iconAlpha = 1,
    manualRoles = {},
    debug = false,
}

local function NormalizeClassToken(value)
    if not value then return nil end
    return string.upper((string.gsub(value, "[^%a%d]", "")))
end

local function NormalizeName(value)
    if not value then return nil end
    value = string.gsub(value, "%-.*$", "")
    return string.lower(value)
end

local function NormalizeRole(role)
    if not role then return nil end
    role = string.upper(tostring(role))
    if role == "HEAL" then role = "HEALER" end
    if role == "DPS" or role == "DAMAGE" or role == "MELEEDPS" or role == "MELEE_DPS"
        or role == "RANGEDDPS" or role == "RANGED_DPS" then
        role = "DAMAGER"
    end
    if role == "AUTO" or role == "CLEAR" or role == "NONE" then return nil end
    if role == "TANK" or role == "HEALER" or role == "DAMAGER" or role == "SUPPORT" then
        return role
    end
end

local function GetPower(unit)
    if UnitPower and UnitPowerMax and UnitPowerType then
        return UnitPower(unit) or 0, UnitPowerMax(unit) or 0, UnitPowerType(unit) or 0
    end
    return UnitMana(unit) or 0, UnitManaMax(unit) or 0, UnitManaType(unit) or 0
end

local function GetRole(unit)
    local name = NormalizeName(UnitName(unit))
    local manual = name and NormalizeRole(GridFrameDecorations.db.profile.manualRoles[name])
    if manual then return manual end

    if GetPartyAssignment and GetPartyAssignment("MAINTANK", unit) then
        return "TANK"
    end

    if UnitGroupRolesAssigned then
        local role = NormalizeRole(UnitGroupRolesAssigned(unit))
        if role then
            return role
        end
    end

    -- Some custom 3.3.5 clients expose a role helper under a different name.
    if GetUnitRole then
        local role = NormalizeRole(GetUnitRole(unit))
        if role then
            return role
        end
    end

    return GridFrameDecorations.db.profile.unknownRoleFallback
end

local function RoleIsEnabled(role)
    local db = GridFrameDecorations.db.profile
    if role == "TANK" then return db.showTank end
    if role == "HEALER" then return db.showHealer end
    if role == "SUPPORT" then return db.showSupport end
    return db.showDPS
end

local function GetCustomClassCoords(classToken, className)
    local token = NormalizeClassToken(classToken)
    local name = NormalizeClassToken(className)
    local candidates = {
        _G.COA_CLASS_ICON_TCOORDS,
        _G.ASCENSION_CLASS_ICON_TCOORDS,
        _G.CUSTOM_CLASS_ICON_TCOORDS,
        _G.CLASS_ICON_TCOORDS,
    }

    for _, coordsTable in ipairs(candidates) do
        if type(coordsTable) == "table" then
            local coords = (token and coordsTable[token]) or (name and coordsTable[name])
            if coords then return coords end
        end
    end
end

local function GetCustomClassAtlas()
    return _G.COA_CLASS_ICON_TEXTURE
        or _G.ASCENSION_CLASS_ICON_TEXTURE
        or _G.CUSTOM_CLASS_ICON_TEXTURE
        or CLASS_ATLAS
end

local function GetClassIcon(unit)
    local className, classToken = UnitClass(unit)
    if not className and not classToken then return nil end

    local token = NormalizeClassToken(classToken)
    local name = NormalizeClassToken(className)
    local db = GridFrameDecorations.db.profile

    if db.preferCoAIcons and (COA_CLASS_NAMES[token] or COA_CLASS_NAMES[name]) then
        local coords = GetCustomClassCoords(classToken, className)
        if coords then
            return GetCustomClassAtlas(), coords
        end

        -- Ascension clients may expose individual class icon files instead of an atlas.
        -- Try the server's conventional custom icon path; the texture object remains
        -- safe if a specific client build does not contain it.
        local directToken = token or name
        if directToken then
            return "Interface\\Icons\\ClassIcon_" .. directToken, nil, true
        end
    end

    if db.showStandardClassFallback then
        local coords = GetCustomClassCoords(classToken, className) or STANDARD_CLASS_COORDS[token]
        if coords then
            return GetCustomClassAtlas(), coords
        end
    end
end

local function CreateIconFrame(parent)
    local border = CreateFrame("Frame", nil, parent)
    border:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    border:SetBackdropColor(0.03, 0.03, 0.03, 0.95)
    border:SetBackdropBorderColor(0, 0, 0, 1)
    border:SetFrameLevel(parent:GetFrameLevel() + 7)
    border:EnableMouse(false)

    local texture = border:CreateTexture(nil, "ARTWORK")
    texture:SetPoint("TOPLEFT", border, "TOPLEFT", 1, -1)
    texture:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, 1)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    border.texture = texture
    return border
end


local roleMenuFrame = CreateFrame("Frame", "GridDarksolisRoleMenu", UIParent, "UIDropDownMenuTemplate")

function GridFrameDecorations:InspectFrameUnit(frameObject)
    if not frameObject or not frameObject.unit or not UnitExists(frameObject.unit) then return end
    if InCombatLockdown and InCombatLockdown() then
        Grid:Print("Players cannot be inspected during combat.")
        return
    end

    local unit = frameObject.unit
    if not UnitIsPlayer(unit) then
        Grid:Print("That Grid unit is not a player.")
        return
    end

    if CanInspect and not CanInspect(unit, false) then
        Grid:Print("That player is too far away or cannot currently be inspected.")
        return
    end

    CloseDropDownMenus()

    if not IsAddOnLoaded("Blizzard_InspectUI") and LoadAddOn then
        LoadAddOn("Blizzard_InspectUI")
    end

    if InspectUnit then
        InspectUnit(unit)
    elseif NotifyInspect then
        NotifyInspect(unit)
        if InspectFrame and ShowUIPanel then
            ShowUIPanel(InspectFrame)
        end
    else
        Grid:Print("This client does not expose a direct inspect API.")
    end
end

function GridFrameDecorations:TradeFrameUnit(frameObject)
    if not frameObject or not frameObject.unit or not UnitExists(frameObject.unit) then return end
    if InCombatLockdown and InCombatLockdown() then
        Grid:Print("Players cannot be traded with during combat.")
        return
    end

    local unit = frameObject.unit
    if not UnitIsPlayer(unit) then
        Grid:Print("That Grid unit is not a player.")
        return
    end

    if UnitIsUnit and UnitIsUnit(unit, "player") then
        Grid:Print("You cannot trade with yourself.")
        return
    end

    CloseDropDownMenus()

    if InitiateTrade then
        InitiateTrade(unit)
    else
        Grid:Print("This client does not expose a direct trade API.")
    end
end

function GridFrameDecorations:WhisperFrameUnit(frameObject)
    if not frameObject or not frameObject.unit or not UnitExists(frameObject.unit) then return end

    local unit = frameObject.unit
    if not UnitIsPlayer(unit) then
        Grid:Print("That Grid unit is not a player.")
        return
    end

    if UnitIsUnit and UnitIsUnit(unit, "player") then
        Grid:Print("You cannot whisper yourself.")
        return
    end

    local name = UnitName(unit)
    if not name then return end

    CloseDropDownMenus()

    if ChatFrame_SendTell then
        ChatFrame_SendTell(name)
    elseif ChatFrame_OpenChat then
        ChatFrame_OpenChat("/w " .. name .. " ")
    else
        Grid:Print("This client does not expose a whisper chat API.")
    end
end

StaticPopupDialogs["GRID_DARKSOLIS_CONFIRM_REMOVE"] = {
    text = "Remove %s from the raid?",
    button1 = "Remove",
    button2 = "Cancel",
    OnAccept = function(self, data)
        if not data or not data.name then return end
        if InCombatLockdown and InCombatLockdown() then
            Grid:Print("Raid members cannot be removed during combat.")
            return
        end
        if UninviteUnit then
            UninviteUnit(data.name)
        else
            Grid:Print("This client does not expose the raid removal API.")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function GridFrameDecorations:RemoveFrameUnit(frameObject)
    if not frameObject or not frameObject.unit or not UnitExists(frameObject.unit) then return end
    if InCombatLockdown and InCombatLockdown() then
        Grid:Print("Raid members cannot be removed during combat.")
        return
    end

    local unit = frameObject.unit
    if not UnitIsPlayer(unit) then
        Grid:Print("That Grid unit is not a player.")
        return
    end

    if UnitIsUnit and UnitIsUnit(unit, "player") then
        Grid:Print("Use Leave Party or Leave Raid to remove yourself.")
        return
    end

    local isLeader = UnitIsGroupLeader and UnitIsGroupLeader("player")
    local isAssistant = UnitIsGroupAssistant and UnitIsGroupAssistant("player")

    if not isLeader and IsRaidLeader then
        isLeader = IsRaidLeader()
    end
    if not isAssistant and IsRaidOfficer then
        isAssistant = IsRaidOfficer()
    end

    if not isLeader and not isAssistant then
        Grid:Print("You must be the raid leader or an assistant to remove players.")
        return
    end

    local name = UnitName(unit)
    if not name then return end

    CloseDropDownMenus()

    local popup = StaticPopup_Show and StaticPopup_Show("GRID_DARKSOLIS_CONFIRM_REMOVE", name)
    if popup then
        popup.data = { name = name }
    else
        Grid:Print("The confirmation dialog could not be opened.")
    end
end

function GridFrameDecorations:OpenRoleMenu(frameObject)
    if not frameObject or not frameObject.unit or not UnitExists(frameObject.unit) then return end
    if InCombatLockdown and InCombatLockdown() then
        Grid:Print("Manual Grid role assignment is unavailable during combat.")
        return
    end

    local unit = frameObject.unit
    local fullName = UnitName(unit)
    if not fullName then return end
    local normalized = NormalizeName(fullName)
    local current = normalized and self.db.profile.manualRoles[normalized]

    local menu = {
        {
            text = "|cff4bb8ff" .. fullName .. "|r",
            isTitle = true,
            notCheckable = true,
        },
        {
            text = "Auto Detect",
            checked = not current,
            func = function() GridFrameDecorations:SetManualRole(fullName, "AUTO") end,
        },
        {
            text = "Tank",
            checked = current == "TANK",
            func = function() GridFrameDecorations:SetManualRole(fullName, "TANK") end,
        },
        {
            text = "Healer",
            checked = current == "HEALER",
            func = function() GridFrameDecorations:SetManualRole(fullName, "HEALER") end,
        },
        {
            text = "DPS",
            checked = current == "DAMAGER" or current == "MELEE" or current == "RANGED",
            func = function() GridFrameDecorations:SetManualRole(fullName, "DAMAGER") end,
        },
        {
            text = "Support",
            checked = current == "SUPPORT",
            func = function() GridFrameDecorations:SetManualRole(fullName, "SUPPORT") end,
        },
        {
            text = "Inspect Player",
            notCheckable = true,
            func = function() GridFrameDecorations:InspectFrameUnit(frameObject) end,
        },
        {
            text = "Trade Player",
            notCheckable = true,
            func = function() GridFrameDecorations:TradeFrameUnit(frameObject) end,
        },
        {
            text = "Whisper Player",
            notCheckable = true,
            func = function() GridFrameDecorations:WhisperFrameUnit(frameObject) end,
        },
        {
            text = "|cffff5555Remove from Raid|r",
            notCheckable = true,
            func = function() GridFrameDecorations:RemoveFrameUnit(frameObject) end,
        },
        {
            text = "Cancel",
            notCheckable = true,
            func = function() CloseDropDownMenus() end,
        },
    }

    EasyMenu(menu, roleMenuFrame, "cursor", 0, 0, "MENU")
end

function GridFrameDecorations:HandleFrameMouseUp(frameObject, button)
    local db = self.db.profile
    if not db.enabled or not db.enableRoleMenu or button ~= "RightButton" then return end
    self:OpenRoleMenu(frameObject)
end

function GridFrameDecorations:AttachFrame(frameObject)
    if not frameObject or frameObject.decorations then return end

    local frame = frameObject.frame
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetAllPoints(frame)
    overlay:SetFrameLevel(frame:GetFrameLevel() + 6)
    overlay:EnableMouse(false)

    local role = CreateIconFrame(overlay)
    local class = CreateIconFrame(overlay)

    local powerBG = overlay:CreateTexture(nil, "BORDER")
    powerBG:SetTexture(WHITE)

    local power = CreateFrame("StatusBar", nil, overlay)
    power:SetStatusBarTexture(POWER_TEXTURE)
    power:SetMinMaxValues(0, 1)
    power:SetValue(0)
    power:SetFrameLevel(overlay:GetFrameLevel() + 1)
    power:EnableMouse(false)

    local highlight = power:CreateTexture(nil, "OVERLAY")
    highlight:SetTexture(WHITE)
    highlight:SetVertexColor(1, 1, 1, 0.16)
    highlight:SetPoint("TOPLEFT", power, "TOPLEFT", 0, 0)
    highlight:SetPoint("TOPRIGHT", power, "TOPRIGHT", 0, 0)
    highlight:SetHeight(1)

    frameObject.decorations = {
        overlay = overlay,
        role = role,
        class = class,
        power = power,
        powerBG = powerBG,
    }

    if not frameObject.decorationsRoleMenuHooked then
        frame:HookScript("OnMouseUp", function(_, button)
            GridFrameDecorations:HandleFrameMouseUp(frameObject, button)
        end)
        frameObject.decorationsRoleMenuHooked = true
    end

    self:LayoutFrame(frameObject)
    self:UpdateFrame(frameObject)
end

local function PlaceIcon(icon, parent, position, inset, powerHeight)
    icon:ClearAllPoints()
    if position == "BOTTOMLEFT" then
        icon:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", inset, powerHeight + inset + 2)
    elseif position == "BOTTOMRIGHT" then
        icon:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -inset, powerHeight + inset + 2)
    elseif position == "TOPRIGHT" then
        icon:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -inset, -inset)
    else
        icon:SetPoint("TOPLEFT", parent, "TOPLEFT", inset, -inset)
    end
end

function GridFrameDecorations:LayoutFrame(frameObject)
    local d = frameObject and frameObject.decorations
    if not d then return end

    local db = self.db.profile
    local powerHeight = db.showPower and db.powerHeight or 0

    d.overlay:SetAlpha(db.iconAlpha)

    d.role:SetWidth(db.roleSize)
    d.role:SetHeight(db.roleSize)
    PlaceIcon(d.role, d.overlay, db.rolePosition, db.iconInset, powerHeight)

    d.class:SetWidth(db.classSize)
    d.class:SetHeight(db.classSize)
    PlaceIcon(d.class, d.overlay, db.classPosition, db.iconInset, powerHeight)

    d.powerBG:ClearAllPoints()
    d.powerBG:SetPoint("BOTTOMLEFT", d.overlay, "BOTTOMLEFT", db.powerInset, db.powerInset)
    d.powerBG:SetPoint("BOTTOMRIGHT", d.overlay, "BOTTOMRIGHT", -db.powerInset, db.powerInset)
    d.powerBG:SetHeight(db.powerHeight + 2)
    d.powerBG:SetVertexColor(0.02, 0.02, 0.02, db.powerBackgroundAlpha)

    d.power:ClearAllPoints()
    d.power:SetPoint("BOTTOMLEFT", d.overlay, "BOTTOMLEFT", db.powerInset + 1, db.powerInset + 1)
    d.power:SetPoint("BOTTOMRIGHT", d.overlay, "BOTTOMRIGHT", -(db.powerInset + 1), db.powerInset + 1)
    d.power:SetHeight(db.powerHeight)
end

function GridFrameDecorations:UpdateFrame(frameObject)
    if not frameObject then return end
    if not frameObject.decorations then self:AttachFrame(frameObject) end

    local d = frameObject.decorations
    local db = self.db.profile
    local unit = frameObject.unit

    if not db.enabled or not unit or not UnitExists(unit) then
        d.overlay:Hide()
        return
    end

    d.overlay:Show()

    local role = GetRole(unit)
    local roleTexture = role and ROLE_TEXTURES[role]
    if role ~= "NONE" and RoleIsEnabled(role) and roleTexture then
        d.role.texture:SetTexture(nil)
        d.role.texture:SetTexCoord(0, 1, 0, 1)
        d.role.texture:SetTexture(roleTexture)
        d.role.texture:SetVertexColor(1, 1, 1, 1)
        d.role.texture:SetTexCoord(0.04, 0.96, 0.04, 0.96)
        d.role:Show()
    else
        d.role.texture:SetTexture(nil)
        d.role:Hide()
    end

    if db.showClass then
        local texture, coords, direct = GetClassIcon(unit)
        if texture then
            d.class.texture:SetTexture(texture)
            if coords then
                d.class.texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            elseif direct then
                d.class.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            end
            d.class:Show()
        else
            d.class:Hide()
        end
    else
        d.class:Hide()
    end

    if db.showPower then
        local value, maximum, powerType = GetPower(unit)
        maximum = math.max(maximum or 0, 1)
        value = math.min(value or 0, maximum)
        local color = POWER_COLORS[powerType] or POWER_COLORS[0]

        d.power:SetMinMaxValues(0, maximum)
        d.power:SetValue(value)
        d.power:SetStatusBarColor(color[1], color[2], color[3], 1)

        if db.hidePowerWhenEmpty and value <= 0 then
            d.power:Hide()
            d.powerBG:Hide()
        else
            d.power:Show()
            d.powerBG:Show()
        end
    else
        d.power:Hide()
        d.powerBG:Hide()
    end
end

function GridFrameDecorations:RefreshAll(layoutOnly)
    if not GridFrame.registeredFrames then return end
    for _, frameObject in pairs(GridFrame.registeredFrames) do
        if not frameObject.decorations then self:AttachFrame(frameObject) end
        self:LayoutFrame(frameObject)
        if not layoutOnly then self:UpdateFrame(frameObject) end
    end
end

function GridFrameDecorations:SetManualRole(name, role)
    name = NormalizeName(name)
    if not name then return false end

    local originalRole = role and string.upper(tostring(role))
    role = NormalizeRole(role)
    if not role then
        if originalRole == "AUTO" or originalRole == "CLEAR" or originalRole == "NONE" or not originalRole then
            self.db.profile.manualRoles[name] = nil
            self:RefreshAll()
            return true
        end
        return false
    end

    self.db.profile.manualRoles[name] = role
    self:RefreshAll()
    return true
end

local function ToggleOption(key, label, description)
    return {
        type = "toggle",
        name = label,
        desc = description or label,
        get = function() return GridFrameDecorations.db.profile[key] end,
        set = function(value)
            GridFrameDecorations.db.profile[key] = value
            GridFrameDecorations:RefreshAll()
        end,
    }
end

local function RangeOption(key, label, minValue, maxValue, stepValue, description)
    return {
        type = "range",
        name = label,
        desc = description or label,
        min = minValue,
        max = maxValue,
        step = stepValue,
        get = function() return GridFrameDecorations.db.profile[key] end,
        set = function(value)
            GridFrameDecorations.db.profile[key] = value
            GridFrameDecorations:RefreshAll()
        end,
    }
end

GridFrameDecorations.options = {
    type = "group",
    name = "Role, Class & Power",
    desc = "Role icons, CoA class icons, and power bars integrated into Grid frames.",
    args = {
        enabled = {
            type = "toggle",
            name = "Enable Frame Decorations",
            desc = "Master switch for all role icons, class icons, and power bars.",
            order = 1,
            get = function() return GridFrameDecorations.db.profile.enabled end,
            set = function(value)
                GridFrameDecorations.db.profile.enabled = value
                GridFrameDecorations:RefreshAll()
            end,
        },
        roleHeader = { type = "header", name = "Role Icons", order = 10 },
        showTank = ToggleOption("showTank", "Show Tank Icons", "Display the tank shield for detected or manually assigned tanks."),
        showHealer = ToggleOption("showHealer", "Show Healer Icons", "Display the healer icon for detected or manually assigned healers."),
        showDPS = ToggleOption("showDPS", "Show DPS Icons", "Display the single DPS icon for damage dealers."),
        showSupport = ToggleOption("showSupport", "Show Support Icons", "Display the dedicated Support icon for manually assigned or detected support players."),
        roleSize = RangeOption("roleSize", "Role Icon Size", 8, 24, 1, "Set the role icon size in pixels."),
        rolePosition = {
            type = "text",
            name = "Role Icon Position",
            desc = "Choose which corner of each Grid frame displays the role icon.",
            order = 15,
            validate = {
                TOPLEFT = "Top Left", TOPRIGHT = "Top Right",
                BOTTOMLEFT = "Bottom Left", BOTTOMRIGHT = "Bottom Right",
            },
            get = function() return GridFrameDecorations.db.profile.rolePosition end,
            set = function(value)
                GridFrameDecorations.db.profile.rolePosition = value
                GridFrameDecorations:RefreshAll(true)
            end,
        },

        roleMenuHeader = { type = "header", name = "Manual Role Assignment", order = 16 },
        enableRoleMenu = {
            type = "toggle",
            name = "Enable Right-Click Role Menu",
            desc = "Allows manual role assignment directly from a Grid player frame with plain right-click.",
            order = 17,
            get = function() return GridFrameDecorations.db.profile.enableRoleMenu end,
            set = function(value) GridFrameDecorations.db.profile.enableRoleMenu = value end,
        },
        unknownRoleFallback = {
            type = "text",
            name = "When Auto Detection Fails",
            desc = "Choose whether an unknown player shows as DPS or has no role icon.",
            order = 19,
            validate = {
                DAMAGER = "Show DPS Icon",
                NONE = "Hide Role Icon",
            },
            get = function() return GridFrameDecorations.db.profile.unknownRoleFallback end,
            set = function(value)
                GridFrameDecorations.db.profile.unknownRoleFallback = value
                GridFrameDecorations:RefreshAll()
            end,
        },

        classHeader = { type = "header", name = "Class Icons", order = 20 },
        showClass = ToggleOption("showClass", "Show Class Icons", "Display a class icon on every Grid player frame."),
        preferCoAIcons = ToggleOption("preferCoAIcons", "Use CoA Class Icons", "Prefer Conquest of Azeroth custom class icons when the client exposes them."),
        showStandardClassFallback = ToggleOption("showStandardClassFallback", "Use Standard Class Fallback", "Use standard WoW class icons when a CoA icon cannot be resolved."),
        classSize = RangeOption("classSize", "Class Icon Size", 8, 24, 1, "Set the class icon size in pixels."),
        classPosition = {
            type = "text",
            name = "Class Icon Position",
            desc = "Choose which corner of each Grid frame displays the class icon.",
            order = 25,
            validate = {
                TOPLEFT = "Top Left", TOPRIGHT = "Top Right",
                BOTTOMLEFT = "Bottom Left", BOTTOMRIGHT = "Bottom Right",
            },
            get = function() return GridFrameDecorations.db.profile.classPosition end,
            set = function(value)
                GridFrameDecorations.db.profile.classPosition = value
                GridFrameDecorations:RefreshAll(true)
            end,
        },

        powerHeader = { type = "header", name = "Power Bars", order = 30 },
        showPower = ToggleOption("showPower", "Show Power Bars", "Display each player power resource, including mana, rage, energy, and runic power."),
        hidePowerWhenEmpty = ToggleOption("hidePowerWhenEmpty", "Hide Empty Power Bars", "Hide the power bar when the unit has no usable power resource."),
        powerHeight = RangeOption("powerHeight", "Power Bar Height", 2, 10, 1, "Set the power bar height in pixels."),
        powerInset = RangeOption("powerInset", "Power Bar Inset", 0, 5, 1, "Set the spacing between the power bar and the frame edges."),
        powerBackgroundAlpha = RangeOption("powerBackgroundAlpha", "Power Bar Background Opacity", 0, 1, 0.05, "Adjust the darkness behind the power bar."),

        polishHeader = { type = "header", name = "Appearance", order = 40 },
        iconInset = RangeOption("iconInset", "Icon Edge Inset", 0, 6, 1, "Set the spacing between icons and the frame edges."),
        iconAlpha = RangeOption("iconAlpha", "Icon and Bar Opacity", 0.25, 1, 0.05, "Adjust the opacity of role icons, class icons, and power bars."),
        reset = {
            type = "execute",
            name = "Reset Decoration Settings",
            desc = "Restore the role, class, and power display defaults.",
            order = 50,
            func = function()
                for key, value in pairs(GridFrameDecorations.defaultDB) do
                    if type(value) ~= "table" then
                        GridFrameDecorations.db.profile[key] = value
                    end
                end
                GridFrameDecorations.db.profile.manualRoles = {}
                GridFrameDecorations:RefreshAll()
            end,
        },
    },
}

-- Set explicit option ordering after helper creation.
GridFrameDecorations.options.args.showTank.order = 11
GridFrameDecorations.options.args.showHealer.order = 12
GridFrameDecorations.options.args.showDPS.order = 13
GridFrameDecorations.options.args.showSupport.order = 14
GridFrameDecorations.options.args.roleSize.order = 15
GridFrameDecorations.options.args.showClass.order = 21
GridFrameDecorations.options.args.preferCoAIcons.order = 22
GridFrameDecorations.options.args.showStandardClassFallback.order = 23
GridFrameDecorations.options.args.classSize.order = 24
GridFrameDecorations.options.args.showPower.order = 31
GridFrameDecorations.options.args.hidePowerWhenEmpty.order = 32
GridFrameDecorations.options.args.powerHeight.order = 33
GridFrameDecorations.options.args.powerInset.order = 34
GridFrameDecorations.options.args.powerBackgroundAlpha.order = 35
GridFrameDecorations.options.args.iconInset.order = 41
GridFrameDecorations.options.args.iconAlpha.order = 42

function GridFrameDecorations:OnInitialize()
    self.super.OnInitialize(self)

    -- Version 2 changes the automatic-detection fallback from DPS to hidden.
    -- Run once per profile so existing installs receive the new intended default.
    if not self.db.profile.decorationsSchemaVersion or self.db.profile.decorationsSchemaVersion < 2 then
        self.db.profile.unknownRoleFallback = "NONE"
        self.db.profile.decorationsSchemaVersion = 2
    end

    local manualRoles = self.db.profile.manualRoles
    if manualRoles then
        for name, role in pairs(manualRoles) do
            local normalized = NormalizeRole(role)
            manualRoles[name] = normalized
        end
    end
    self.debugging = self.db.profile.debug
end

function GridFrameDecorations:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "RefreshAll")
    self:RegisterEvent("Grid_RosterUpdated", "RefreshAll")
    self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "RefreshAll")
    self:RegisterEvent("UNIT_DISPLAYPOWER", "UpdateUnit")
    self:RegisterEvent("UNIT_MANA", "UpdateUnit")
    self:RegisterEvent("UNIT_MAXMANA", "UpdateUnit")
    self:RegisterEvent("UNIT_RAGE", "UpdateUnit")
    self:RegisterEvent("UNIT_ENERGY", "UpdateUnit")
    self:RegisterEvent("UNIT_RUNIC_POWER", "UpdateUnit")
    self:RegisterEvent("Grid_ColorsChanged", "RefreshAll")
    self:RefreshAll()
end

function GridFrameDecorations:OnDisable()
    if not GridFrame.registeredFrames then return end
    for _, frameObject in pairs(GridFrame.registeredFrames) do
        if frameObject.decorations then frameObject.decorations.overlay:Hide() end
    end
end

function GridFrameDecorations:Reset()
    self.super.Reset(self)
    self:RefreshAll()
end

function GridFrameDecorations:UpdateUnit(unit)
    if not unit or not GridFrame.registeredFrames then return end
    for _, frameObject in pairs(GridFrame.registeredFrames) do
        if frameObject.unit == unit then
            self:UpdateFrame(frameObject)
        end
    end
end

SLASH_GRIDROLE1 = "/gridrole"
SlashCmdList.GRIDROLE = function(message)
    local name, role = string.match(message or "", "^(%S+)%s+(%S+)$")
    if name and role and GridFrameDecorations:SetManualRole(name, role) then
        Grid:Print("Role override updated for " .. name .. ".")
    else
        Grid:Print("Usage: /gridrole PlayerName tank|healer|dps|support|auto")
    end
end
