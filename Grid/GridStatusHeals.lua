--[[--------------------------------------------------------------------
	GridStatusHeals.lua
	GridStatus module for tracking incoming healing spells.
----------------------------------------------------------------------]]

local _, ns = ...
local L = ns.L

local GridRoster = Grid:GetModule("GridRoster")

local settings
local playerGUID

local GridStatusHeals = Grid:GetModule("GridStatus"):NewModule("GridStatusHeals")
GridStatusHeals.menuName = L["Heals"]
GridStatusHeals.options = false

GridStatusHeals.defaultDB = {
	debug = false,
	alert_heals = {
		text = L["Incoming heals"],
		enable = true,
		color = { r = 0, g = 1, b = 0, a = 1 },
		priority = 50,
		range = false,
		icon = nil,
	},
}

local healsOptions = {}

function GridStatusHeals:OnInitialize()
	self.super.OnInitialize(self)

	self:RegisterEvent("PLAYER_LOGIN", function() playerGUID = UnitGUID("player") end)

	settings = GridStatusHeals.db.profile.alert_heals
	self:RegisterStatus("alert_heals", L["Incoming heals"], healsOptions, true)
end

function GridStatusHeals:OnStatusEnable(status)
	if status == "alert_heals" then
		-- register events
		self:RegisterEvent("UNIT_HEAL_PREDICTION", "UpdateIncomingHeals")
	end
end

function GridStatusHeals:OnStatusDisable(status)
	if status == "alert_heals" then
		self:UnregisterEvent("UNIT_HEAL_PREDICTION")

		self.core:SendStatusLostAllUnits("alert_heals")
	end
end

function GridStatusHeals:Reset()
	settings = GridStatusHeals.db.profile.alert_heals
	self.super.Reset(self)
end

function GridStatusHeals:UpdateIncomingHeals(unit)
	if unit then
		local guid = UnitGUID(unit)
		local incoming = UnitGetIncomingHeals(unit)
		if incoming and incoming > 0 then
			self:SendIncomingHealsStatus(guid, incoming, UnitHealth(unit) + incoming, UnitHealthMax(unit))
		else
			self.core:SendStatusLost(guid, "alert_heals")
		end
	end
end

function GridStatusHeals:SendIncomingHealsStatus(guid, incoming, estimatedHealth, maxHealth)
	-- add heal modifier to incoming value caused by buffs and debuffs
	-- local modifier = UnitHealModifierGet(unitName)
	-- local effectiveIncoming = modifier * incoming

	local incomingText
	if incoming > 999 then
		incomingText = ("+%.1fk"):format(incoming / 1000)
	else
		incomingText = ("+%d"):format(incoming)
	end
	self.core:SendStatusGained(guid, "alert_heals", settings.priority, (settings.range and 40), settings.color, incomingText, estimatedHealth, maxHealth, settings.icon)
end
