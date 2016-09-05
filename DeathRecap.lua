-- DeathRecap: Print last 5 damages on death.
-- Author: Dagonix@Brisesol (EU)

local addoninfo, deathrecap = ...

local playerId
local lastDamages = {}

local function nilAsZero(value)
	if value == nil then
		return 0
	else
		return value
	end
end

local function sumDamage(info)
	return nilAsZero(info.damage) + math.abs(nilAsZero(info.damageAbsorbed)) + nilAsZero(info.overkill)
end

local function printDamage(info)
	local totalDamage = sumDamage(info)
	local trueDamage = nilAsZero(info.damage)
	
	local trueDamageStr = trueDamage ~= totalDamage and "(" .. trueDamage .. ")" or ""
	local critStr = info.crit and " (crit)" or ""
	local typeStr = info.type and " (" .. info.type .. ")" or " (physical)"
	local fromStr = ""
	local abilityStr = ""
	
	if info.casterName ~= nil then
		fromStr = " from [" .. info.casterName .. "]"
	end
	if info.abilityName ~= nil then
		abilityStr = " using [" .. info.abilityName .. "]"
	end
	print(info.date .. ": " .. totalDamage .. trueDamageStr .. critStr .. fromStr .. abilityStr .. typeStr)
end

local function onDamage(e, info)
	if info.target == playerId and sumDamage(info) > 0 then
		if table.getn(lastDamages) >= 5 then
			table.remove(lastDamages, 1)
		end
		info.date = os.date("%X")
		table.insert(lastDamages, info)
	end
end

local function printLastDamage()
	for index,damage in ipairs(lastDamages) do
		printDamage(damage)
	end
	lastDamages = {}
end

local function onDeath(e, info)
	if info.target == playerId then
		print("Killed by " .. info.casterName .. ", last damages:")
		printLastDamage()
	end
end

playerId = Inspect.Unit.Lookup("player")

Command.Event.Attach(Event.Combat.Death, onDeath, "Handle Deaths")
Command.Event.Attach(Event.Combat.Damage, onDamage, "Handle Damage")
Command.Event.Attach(Command.Slash.Register("tdc"), printLastDamage, "debug onDeath")

print("Use /tdc to print last damage")

