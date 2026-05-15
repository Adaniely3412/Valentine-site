-- Tracks per-player quest progress, handles objective completion, and grants rewards.
-- Hooks: call QuestService.OnHit, OnBossKilled, OnPLChanged, OnZonesCaptured from Main.

local QuestService = {}

local Players           = game:GetService("Players")
local DataStoreService  = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestData     = require(ReplicatedStorage.Modules.QuestData)
local CosmeticData  = require(ReplicatedStorage.Modules.CosmeticData)

local QuestStore = DataStoreService:GetDataStore("QuestData_v1")
local cache = {}  -- [userId] = { completed = {id=true}, active = { [questId] = {progress} } }

local function R() return ReplicatedStorage:WaitForChild("Remotes", 10) end

-- ── Persistence ───────────────────────────────────────────────────

local function defaultState()
	return { completed = {}, active = {} }
end

function QuestService.Load(player)
	local key = "quests_" .. player.UserId
	local saved
	local ok, err = pcall(function() saved = QuestStore:GetAsync(key) end)
	if ok and saved then
		cache[player.UserId] = saved
	else
		if err then warn("[QuestService] Load error:", err) end
		cache[player.UserId] = defaultState()
	end

	-- Auto-assign first quest if player has none active and none completed
	local state = cache[player.UserId]
	if not next(state.completed) and not next(state.active) then
		QuestService.AssignQuest(player, "first_blood")
	else
		-- Reassign any available quests they haven't started yet
		local available = QuestData.GetAvailable(state.completed)
		for _, q in ipairs(available) do
			if not state.active[q.id] then
				QuestService.AssignQuest(player, q.id)
			end
		end
	end
end

function QuestService.Save(player)
	local state = cache[player.UserId]
	if not state then return end
	local key = "quests_" .. player.UserId
	pcall(function() QuestStore:SetAsync(key, state) end)
end

function QuestService.Remove(player)
	QuestService.Save(player)
	cache[player.UserId] = nil
end

-- ── Quest assignment ──────────────────────────────────────────────

function QuestService.AssignQuest(player, questId)
	local q     = QuestData.Get(questId)
	if not q then return end
	local state = cache[player.UserId]
	if not state then return end
	if state.completed[questId] or state.active[questId] then return end

	-- Build progress table from objectives
	local progress = {}
	for _, obj in ipairs(q.objectives) do
		progress[obj.id] = 0
	end
	state.active[questId] = progress

	R().QuestAssigned:FireClient(player, q, progress)
end

-- ── Completion ────────────────────────────────────────────────────

local function completeQuest(player, questId)
	local q     = QuestData.Get(questId)
	local state = cache[player.UserId]
	if not state then return end

	state.completed[questId] = true
	state.active[questId]    = nil

	-- Apply rewards
	local rewards = q.rewards or {}
	local PlayerDataService = require(script.Parent.PlayerDataService)
	if rewards.xp         then PlayerDataService.AddXP(player, rewards.xp) end
	if rewards.powerLevel then PlayerDataService.AddPowerLevel(player, rewards.powerLevel) end
	if rewards.title      then
		local pd = PlayerDataService.Get(player)
		if pd then
			local has = false
			for _, t in ipairs(pd.titles) do if t == rewards.title then has = true end end
			if not has then table.insert(pd.titles, rewards.title) end
		end
	end
	-- Costume unlock: add to player data owned cosmetics (IsUnlocked checks titles)
	-- CosmeticData uses title-based unlocks so the reward title handles it.

	R().QuestCompleted:FireClient(player, q)

	-- Assign next quest automatically
	if q.next then
		task.delay(2, function()
			if player and player.Parent then
				QuestService.AssignQuest(player, q.next)
			end
		end)
	end
end

-- ── Objective progress ────────────────────────────────────────────

local function tickObjective(player, questId, objId, amount)
	local state = cache[player.UserId]
	if not state then return end
	local progress = state.active[questId]
	if not progress then return end

	local q   = QuestData.Get(questId)
	if not q  then return end

	-- Find the objective
	local obj
	for _, o in ipairs(q.objectives) do
		if o.id == objId then obj = o; break end
	end
	if not obj then return end

	progress[objId] = math.min((progress[objId] or 0) + amount, obj.required)
	R().QuestProgress:FireClient(player, questId, objId, progress[objId], obj.required)

	-- Check all objectives complete
	local allDone = true
	for _, o in ipairs(q.objectives) do
		if (progress[o.id] or 0) < o.required then allDone = false; break end
	end
	if allDone then completeQuest(player, questId) end
end

local function updatePlayerQuests(player, objType, data)
	local state = cache[player.UserId]
	if not state then return end
	for questId, progress in pairs(state.active) do
		local q = QuestData.Get(questId)
		if not q then continue end
		for _, obj in ipairs(q.objectives) do
			if obj.type == objType then
				if objType == "defeat_boss" then
					if obj.target == nil or obj.target == data.bossName then
						tickObjective(player, questId, obj.id, 1)
					end
				elseif objType == "reach_pl" then
					if (data.pl or 0) >= obj.required then
						tickObjective(player, questId, obj.id, obj.required)
					end
				elseif objType == "hits" then
					tickObjective(player, questId, obj.id, data.count or 1)
				elseif objType == "hold_zones" then
					if (data.zoneCount or 0) >= obj.required then
						tickObjective(player, questId, obj.id, obj.required)
					end
				end
			end
		end
	end
end

-- ── Public hooks (called from Main.server.lua) ────────────────────

function QuestService.OnHit(player, count)
	updatePlayerQuests(player, "hits", { count = count or 1 })
end

function QuestService.OnBossKilled(player, bossName)
	updatePlayerQuests(player, "defeat_boss", { bossName = bossName })
end

function QuestService.OnPLChanged(player, pl)
	updatePlayerQuests(player, "reach_pl", { pl = pl })
end

function QuestService.OnZonesCaptured(player, zoneCount)
	updatePlayerQuests(player, "hold_zones", { zoneCount = zoneCount })
end

function QuestService.GetState(player)
	return cache[player.UserId]
end

-- ── Remote: open quest dialog ─────────────────────────────────────
-- Fired when player uses Cecil's ProximityPrompt (handled in Main).

function QuestService.OpenDialog(player)
	local state    = cache[player.UserId]
	if not state then return end
	local available = QuestData.GetAvailable(state.completed)
	local active    = {}
	for id, progress in pairs(state.active) do
		table.insert(active, { quest = QuestData.Get(id), progress = progress })
	end
	R().OpenQuestDialog:FireClient(player, available, active, state.completed)
end

return QuestService
