local PlayerDataService = {}

local Players            = game:GetService("Players")
local DataStoreService   = game:GetService("DataStoreService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local Config        = require(ReplicatedStorage.Modules.Config)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)

local DataStore = DataStoreService:GetDataStore(Config.DATASTORE_KEY)
local cache     = {}  -- [userId] = data table

local DEFAULT = {
	powerLevel     = 0,
	bloodline      = "Human",
	xp             = 0,
	kills          = 0,
	deaths         = 0,
	titles         = {},
	cosmetics      = {},
	equippedCostume = "Default",
	faction        = "Earth Defenders",
	conquestScore  = 0,
	joinDate       = 0,
}

local function deepCopy(t)
	local c = {}
	for k, v in pairs(t) do
		c[k] = type(v) == "table" and deepCopy(v) or v
	end
	return c
end

local function getRemotes()
	return ReplicatedStorage:WaitForChild("Remotes", 15)
end

-- ── Load ──────────────────────────────────────────────────────────

function PlayerDataService.Load(player)
	local key = "player_" .. player.UserId
	local saved
	local ok, err = pcall(function() saved = DataStore:GetAsync(key) end)

	local data = deepCopy(DEFAULT)
	data.joinDate = os.time()

	if ok and saved then
		for k, v in pairs(saved) do data[k] = v end
	else
		-- First visit — roll bloodline
		local rolled = BloodlineData.Roll(Config.BLOODLINE_WEIGHTS)
		data.bloodline  = rolled
		data.powerLevel = BloodlineData.Get(rolled).startingPL
		if err then warn("[PlayerDataService] Load error for", player.Name, ":", err) end
	end

	cache[player.UserId] = data
	return data
end

-- ── Save ──────────────────────────────────────────────────────────

function PlayerDataService.Save(player)
	local data = cache[player.UserId]
	if not data then return end
	local key = "player_" .. player.UserId
	local ok, err = pcall(function() DataStore:SetAsync(key, data) end)
	if not ok then warn("[PlayerDataService] Save error for", player.Name, ":", err) end
end

-- ── Accessors ─────────────────────────────────────────────────────

function PlayerDataService.Get(player)
	return cache[player.UserId]
end

function PlayerDataService.Set(player, stat, value)
	local data = cache[player.UserId]
	if not data then return end
	data[stat] = value
	local R = getRemotes()
	if R then R.StatsUpdated:FireClient(player, { [stat] = value }) end
end

-- ── Progression ───────────────────────────────────────────────────

function PlayerDataService.AddXP(player, amount)
	local data = cache[player.UserId]
	if not data then return end

	local bl = BloodlineData.Get(data.bloodline)
	local bonus = 1.0
	for _, p in ipairs(bl.passives) do
		if p == "Ancient Blood" then bonus = 1.15 end
	end
	local gained = math.floor(amount * bonus * Config.XP_MULTIPLIER)
	data.xp = data.xp + gained

	PlayerDataService.AddPowerLevel(player, math.floor(gained / 100))

	local R = getRemotes()
	if R then R.XPGained:FireClient(player, gained) end
end

function PlayerDataService.AddPowerLevel(player, amount)
	local data = cache[player.UserId]
	if not data then return end
	local bl   = BloodlineData.Get(data.bloodline)
	local prev = data.powerLevel
	data.powerLevel = math.min(prev + amount, bl.maxPowerLevel)
	if data.powerLevel == prev then return end

	-- Sync attribute on character
	local char = player.Character
	if char then char:SetAttribute("PowerLevel", data.powerLevel) end

	local R = getRemotes()
	if R then
		R.PowerLevelUp:FireClient(player, data.powerLevel, prev)
		R.StatsUpdated:FireClient(player, { powerLevel = data.powerLevel })
	end
end

function PlayerDataService.GetTier(pl)
	local tiers = Config.TIERS
	for i = #tiers, 1, -1 do
		if pl >= tiers[i].minPL then return tiers[i], i end
	end
	return tiers[1], 1
end

-- ── Cleanup ───────────────────────────────────────────────────────

function PlayerDataService.Remove(player)
	PlayerDataService.Save(player)
	cache[player.UserId] = nil
end

-- Auto-save
task.spawn(function()
	while true do
		task.wait(Config.SAVE_INTERVAL)
		for _, p in ipairs(Players:GetPlayers()) do
			PlayerDataService.Save(p)
		end
	end
end)

return PlayerDataService
