-- Manages leaderstats (Roblox player list), global top-10 rankings, and live session board.

local LeaderboardService = {}

local Players           = game:GetService("Players")
local DataStoreService  = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PLStore     = DataStoreService:GetOrderedDataStore("Leaderboard_PL_v1")
local KillsStore  = DataStoreService:GetOrderedDataStore("Leaderboard_Kills_v1")

local function R() return ReplicatedStorage:WaitForChild("Remotes", 10) end

-- ── Leaderstats (shows in Roblox player list) ─────────────────────

function LeaderboardService.InitPlayer(player, playerData)
	local stats = Instance.new("Folder")
	stats.Name  = "leaderstats"
	stats.Parent = player

	local function stat(name, value)
		local v = Instance.new("IntValue")
		v.Name   = name
		v.Value  = value or 0
		v.Parent = stats
		return v
	end

	local plStat    = stat("Power Level", math.floor(playerData.powerLevel or 0))
	local killsStat = stat("Kills",       playerData.kills or 0)
	local deathsStat = stat("Deaths",     playerData.deaths or 0)

	-- Keep leaderstats in sync with live data
	local function syncStats()
		local PlayerDataService = require(script.Parent.PlayerDataService)
		local data = PlayerDataService.Get(player)
		if not data then return end
		plStat.Value     = math.floor(data.powerLevel or 0)
		killsStat.Value  = data.kills  or 0
		deathsStat.Value = data.deaths or 0
	end

	-- Sync every 5 seconds (cheap, avoids attribute listeners)
	task.spawn(function()
		while player and player.Parent do
			task.wait(5)
			syncStats()
		end
	end)
end

-- ── Global ordered leaderboard ────────────────────────────────────

local function saveToGlobal(player, playerData)
	local pl    = math.floor(playerData.powerLevel or 0)
	local kills = playerData.kills or 0
	pcall(function() PLStore:SetAsync(tostring(player.UserId), pl) end)
	pcall(function() KillsStore:SetAsync(tostring(player.UserId), kills) end)
end

local function fetchTop10(store)
	local ok, pages = pcall(function()
		return store:GetSortedAsync(false, 10)  -- descending, 10 entries
	end)
	if not ok or not pages then return {} end
	local ok2, page = pcall(function() return pages:GetCurrentPage() end)
	if not ok2 then return {} end
	return page
end

local function buildLeaderboardData()
	local plPage    = fetchTop10(PLStore)
	local killsPage = fetchTop10(KillsStore)

	local function enrich(page)
		local out = {}
		for rank, entry in ipairs(page) do
			-- Try to get display name from Players service (may not be online)
			local displayName = "[Unknown]"
			local ok, info = pcall(function()
				return game:GetService("Players"):GetNameFromUserIdAsync(tonumber(entry.key))
			end)
			if ok and info then displayName = info end
			table.insert(out, {
				rank  = rank,
				name  = displayName,
				value = entry.value,
				userId = tonumber(entry.key),
			})
		end
		return out
	end

	return {
		powerLevel = enrich(plPage),
		kills      = enrich(killsPage),
	}
end

function LeaderboardService.Broadcast()
	local data = buildLeaderboardData()
	R().LeaderboardUpdate:FireAllClients(data)
end

-- ── Session leaderboard (players currently online) ────────────────

function LeaderboardService.GetSessionBoard()
	local PlayerDataService = require(script.Parent.PlayerDataService)
	local rows = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerDataService.Get(player)
		if data then
			table.insert(rows, {
				name       = player.DisplayName,
				powerLevel = math.floor(data.powerLevel or 0),
				kills      = data.kills or 0,
				bloodline  = data.bloodline or "Human",
			})
		end
	end
	table.sort(rows, function(a, b) return a.powerLevel > b.powerLevel end)
	return rows
end

-- ── Player join / leave ───────────────────────────────────────────

function LeaderboardService.OnPlayerAdded(player)
	local PlayerDataService = require(script.Parent.PlayerDataService)
	-- Wait for data to be loaded
	task.spawn(function()
		task.wait(2)
		local data = PlayerDataService.Get(player)
		if data then
			LeaderboardService.InitPlayer(player, data)
		end
	end)
end

function LeaderboardService.OnPlayerRemoving(player)
	local PlayerDataService = require(script.Parent.PlayerDataService)
	local data = PlayerDataService.Get(player)
	if data then saveToGlobal(player, data) end
end

-- Periodic global refresh
task.spawn(function()
	while true do
		task.wait(120)  -- every 2 minutes
		LeaderboardService.Broadcast()
	end
end)

return LeaderboardService
