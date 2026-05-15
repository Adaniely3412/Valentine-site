-- Builds training station geometry, sets up ProximityPrompts, and awards stat points.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService  = game:GetService("DataStoreService")
local Workspace         = game:GetService("Workspace")

local TrainingData      = require(ReplicatedStorage.Modules.TrainingData)

local Remotes           -- assigned in Init
local TrainingDS        = DataStoreService:GetDataStore("TrainingData_v1")

local cooldowns  = {}   -- [userId][stationId] = os.time() when cooldown expires
local playerData = {}   -- [userId] = { Strength=0, Speed=0, Endurance=0, Focus=0 }

local TrainingService = {}

-- ── DataStore helpers ─────────────────────────────────────────────

local function dsKey(userId) return "train_" .. userId end

local function loadData(player)
	local uid  = player.UserId
	local ok, result = pcall(function()
		return TrainingDS:GetAsync(dsKey(uid))
	end)
	if ok and result then
		playerData[uid] = result
	else
		playerData[uid] = { Strength=0, Speed=0, Endurance=0, Focus=0 }
	end
	cooldowns[uid] = {}
end

local function saveData(player)
	local uid = player.UserId
	local d   = playerData[uid]
	if not d then return end
	pcall(function()
		TrainingDS:SetAsync(dsKey(uid), d)
	end)
end

-- ── Stat application ──────────────────────────────────────────────

function TrainingService.ApplyStats(player)
	local uid  = player.UserId
	local d    = playerData[uid]
	if not d then return end
	local char = player.Character
	if not char then return end

	-- Store as character attributes so CombatService can read them
	char:SetAttribute("TrainStrength",  d.Strength  or 0)
	char:SetAttribute("TrainSpeed",     d.Speed     or 0)
	char:SetAttribute("TrainEndurance", d.Endurance or 0)
	char:SetAttribute("TrainFocus",     d.Focus     or 0)

	-- Apply Endurance → MaxHealth bonus on top of what Main set
	local hum = char:FindFirstChild("Humanoid")
	if hum then
		local bonus = (d.Endurance or 0) * TrainingData.BONUS_PER_POINT.Endurance
		hum.MaxHealth = hum.MaxHealth + bonus
		hum.Health    = hum.MaxHealth
	end

	-- Apply Speed bonus
	local hum2 = char:FindFirstChild("Humanoid")
	if hum2 then
		hum2.WalkSpeed = hum2.WalkSpeed + (d.Speed or 0) * TrainingData.BONUS_PER_POINT.Speed
	end
end

function TrainingService.GetStats(player)
	return playerData[player.UserId] or { Strength=0, Speed=0, Endurance=0, Focus=0 }
end

-- ── Station builder ───────────────────────────────────────────────

local function buildStation(station)
	local model  = Instance.new("Model")
	model.Name   = station.name
	model.Parent = Workspace

	-- Platform
	local platform = Instance.new("Part")
	platform.Name     = "Platform"
	platform.Anchored = true
	platform.Size     = station.size
	platform.CFrame   = CFrame.new(station.position)
	platform.BrickColor  = BrickColor.new(station.color.r*255//1, station.color.g*255//1, station.color.b*255//1)
	platform.Color       = station.color
	platform.Material    = station.material
	platform.CanCollide  = true
	platform.Parent      = model

	-- Low surrounding walls (visual only)
	local wallH = 1.5
	local wallThick = 0.4
	local hw = station.size.X/2
	local hd = station.size.Z/2
	local wallDefs = {
		{sz=Vector3.new(station.size.X, wallH, wallThick), pos=Vector3.new(0,wallH/2+station.size.Y/2, hd+wallThick/2)},
		{sz=Vector3.new(station.size.X, wallH, wallThick), pos=Vector3.new(0,wallH/2+station.size.Y/2,-hd-wallThick/2)},
		{sz=Vector3.new(wallThick, wallH, station.size.Z+wallThick*2), pos=Vector3.new( hw+wallThick/2, wallH/2+station.size.Y/2, 0)},
		{sz=Vector3.new(wallThick, wallH, station.size.Z+wallThick*2), pos=Vector3.new(-hw-wallThick/2, wallH/2+station.size.Y/2, 0)},
	}
	for _, wd in ipairs(wallDefs) do
		local w = Instance.new("Part")
		w.Anchored = true
		w.Size     = wd.sz
		w.CFrame   = CFrame.new(station.position + wd.pos)
		w.Color    = station.wallColor
		w.Material = Enum.Material.SmoothPlastic
		w.CanCollide = true
		w.Transparency = 0.4
		w.Parent = model
	end

	-- Neon energy pillar on platform center
	local pillar = Instance.new("Part")
	pillar.Name      = "EnergyPillar"
	pillar.Anchored  = true
	pillar.Shape     = Enum.PartType.Cylinder
	pillar.Size      = Vector3.new(3, 0.3, 0.3)
	pillar.CFrame    = CFrame.new(station.position + Vector3.new(0, station.size.Y/2 + 0.15, 0))
		* CFrame.Angles(0, 0, math.pi/2)
	pillar.Color     = station.color
	pillar.Material  = Enum.Material.Neon
	pillar.CanCollide= false
	pillar.Parent    = model

	-- Billboard label
	local billboard = Instance.new("BillboardGui")
	billboard.Size   = UDim2.new(0, 180, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.Adornee = platform
	billboard.AlwaysOnTop = false
	billboard.Parent  = platform

	local label = Instance.new("TextLabel")
	label.Size  = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.Text = station.name:upper()
	label.Parent = billboard

	-- ProximityPrompt
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText    = "Train"
	pp.ObjectText    = station.name
	pp.HoldDuration  = station.holdTime
	pp.MaxActivationDistance = 8
	pp.KeyboardKeyCode = Enum.KeyCode.E
	pp.Parent = platform

	pp.Triggered:Connect(function(trigPlayer)
		local uid = trigPlayer.UserId
		local now = os.time()

		-- Check cooldown
		if cooldowns[uid] and cooldowns[uid][station.id] then
			local remaining = cooldowns[uid][station.id] - now
			if remaining > 0 then
				Remotes.ShowNotification:FireClient(
					trigPlayer,
					string.format("Cooldown: %ds remaining for %s", remaining, station.name),
					"warning"
				)
				return
			end
		end

		-- Award stat point
		local d    = playerData[uid]
		if not d then return end
		local stat = station.stat
		d[stat] = math.min(TrainingData.MAX_POINTS, (d[stat] or 0) + 1)

		-- Set cooldown
		if not cooldowns[uid] then cooldowns[uid] = {} end
		cooldowns[uid][station.id] = now + TrainingData.COOLDOWN

		-- Fire PL reward via callback wired by Main.server.lua
		if TrainingService.OnTrainComplete then
			TrainingService.OnTrainComplete(trigPlayer, station.id)
		end
		Remotes.TrainingComplete:FireClient(trigPlayer, station.id, stat, d[stat])

		-- Broadcast updated stats for the UI
		Remotes.TrainingStatUpdate:FireClient(trigPlayer, d)

		-- Apply speed/endurance changes immediately if character exists
		local char = trigPlayer.Character
		if char then
			if stat == "Endurance" then
				local hum = char:FindFirstChild("Humanoid")
				if hum then
					local bonus = TrainingData.BONUS_PER_POINT.Endurance
					hum.MaxHealth = hum.MaxHealth + bonus
				end
			elseif stat == "Speed" then
				local hum = char:FindFirstChild("Humanoid")
				if hum then
					hum.WalkSpeed = hum.WalkSpeed + TrainingData.BONUS_PER_POINT.Speed
				end
			end
			char:SetAttribute("Train" .. stat, d[stat])
		end

		-- Notify
		Remotes.ShowNotification:FireClient(
			trigPlayer,
			string.format("+1 %s | %s: %d/%d", stat, station.name, d[stat], TrainingData.MAX_POINTS),
			"success"
		)

		saveData(trigPlayer)
	end)

	return model
end

-- ── Public API ────────────────────────────────────────────────────

function TrainingService.Init(remotes, playerDataService)
	Remotes = remotes

	-- Build all stations
	for _, station in ipairs(TrainingData.Stations) do
		buildStation(station)
	end

	-- Return PL reward hook for Main to wire in
	TrainingService._playerDataService = playerDataService
end

function TrainingService.OnPlayerAdded(player)
	loadData(player)
end

function TrainingService.OnPlayerRemoving(player)
	saveData(player)
	playerData[player.UserId]  = nil
	cooldowns[player.UserId]   = nil
end

return TrainingService
