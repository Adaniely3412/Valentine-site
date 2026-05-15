-- Spawns boss NPCs, runs their AI state machine, and handles rewards on kill.
-- Bosses are fully server-authoritative: they pick targets, move, and deal damage server-side.

local BossService = {}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Debris            = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterData  = require(ReplicatedStorage.Modules.CharacterData)
local BloodlineData  = require(ReplicatedStorage.Modules.BloodlineData)
local MovesetData    = require(ReplicatedStorage.Modules.MovesetData)
local Config         = require(ReplicatedStorage.Modules.Config)

local function R() return ReplicatedStorage:WaitForChild("Remotes", 10) end

-- ── AI constants ─────────────────────────────────────────────────
local AGGRO_RANGE   = 65
local DEAGGRO_RANGE = 140
local ATTACK_RANGE  = 9
local RUSH_RANGE    = 55
local CLAP_RANGE    = 22
local AI_TICK       = 0.18   -- seconds between AI updates

-- Boss spawn locations (world positions — match your Studio map)
local SPAWN_POSITIONS = {
	["Omni-Man"]      = Vector3.new(0,   5,  -80),
	["Thragg"]        = Vector3.new(120, 5,   80),
	["Conquest"]      = Vector3.new(-80, 5,  120),
	["Immortal"]      = Vector3.new(50,  5,  -50),
}

-- Patrol waypoints relative to spawn (will be offset at runtime)
local PATROL_OFFSETS = {
	Vector3.new(12, 0, 0),
	Vector3.new(12, 0, 12),
	Vector3.new(0,  0, 12),
	Vector3.new(0,  0, 0),
}

local activeBosses = {}   -- [bossName] = bossState table
local aiTimer      = 0

-- ── NPC builder ───────────────────────────────────────────────────

local FACTION_COLORS = {
	["Viltrumite Empire"] = { body = BrickColor.new("Crimson"),          head = BrickColor.new("Pastel orange") },
	["Earth Defenders"]   = { body = BrickColor.new("Bright blue"),      head = BrickColor.new("Pastel orange") },
	default               = { body = BrickColor.new("Medium stone grey"), head = BrickColor.new("Pastel orange") },
}

local function motor6d(parent, name, p0, p1, c0, c1)
	local m    = Instance.new("Motor6D")
	m.Name     = name
	m.Part0    = p0
	m.Part1    = p1
	m.C0       = c0
	m.C1       = c1
	m.Parent   = parent
	return m
end

local function buildRig(bossName, bossData, spawnPos)
	local colors = FACTION_COLORS[bossData.faction] or FACTION_COLORS.default
	local model  = Instance.new("Model")
	model.Name   = bossName

	local function part(name, size, bc, transparent, noCollide)
		local p = Instance.new("Part")
		p.Name         = name
		p.Size         = size
		p.BrickColor   = bc or colors.body
		p.Transparency = transparent or 0
		p.CanCollide   = not noCollide
		p.Parent       = model
		return p
	end

	-- R6 parts
	local root  = part("HumanoidRootPart", Vector3.new(2,2,1),   colors.body, 1, true)
	local torso = part("Torso",            Vector3.new(2,2,1),   colors.body)
	local head  = part("Head",             Vector3.new(2,1,1),   colors.head)
	local lArm  = part("Left Arm",         Vector3.new(1,2,1),   colors.body)
	local rArm  = part("Right Arm",        Vector3.new(1,2,1),   colors.body)
	local lLeg  = part("Left Leg",         Vector3.new(1,2,1),   colors.body)
	local rLeg  = part("Right Leg",        Vector3.new(1,2,1),   colors.body)

	-- Place at spawn (root is the anchor)
	root.CFrame = CFrame.new(spawnPos + Vector3.new(0, 3, 0))
	torso.CFrame = root.CFrame
	head.CFrame  = root.CFrame * CFrame.new(0, 1.5, 0)
	lArm.CFrame  = root.CFrame * CFrame.new(-1.5, 0, 0)
	rArm.CFrame  = root.CFrame * CFrame.new(1.5,  0, 0)
	lLeg.CFrame  = root.CFrame * CFrame.new(-0.5, -2, 0)
	rLeg.CFrame  = root.CFrame * CFrame.new(0.5,  -2, 0)

	-- Standard R6 Motor6D joints
	local π = math.pi
	motor6d(root,  "RootJoint",      root,  torso, CFrame.new(0,-1,0,-1,0,0,0,0,1,0,1,0), CFrame.new(0,-1,0,-1,0,0,0,0,1,0,1,0))
	motor6d(torso, "Neck",           torso, head,  CFrame.new(0,1,0,-1,0,0,0,0,1,0,1,0),  CFrame.new(0,-0.5,0,-1,0,0,0,0,1,0,1,0))
	motor6d(torso, "Left Shoulder",  torso, lArm,  CFrame.new(-1,0.5,0,0,0,-1,0,1,0,1,0,0), CFrame.new(0.5,0.5,0,0,0,-1,0,1,0,1,0,0))
	motor6d(torso, "Right Shoulder", torso, rArm,  CFrame.new(1,0.5,0,0,0,1,0,1,0,-1,0,0),  CFrame.new(-0.5,0.5,0,0,0,1,0,1,0,-1,0,0))
	motor6d(torso, "Left Hip",       torso, lLeg,  CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0), CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0))
	motor6d(torso, "Right Hip",      torso, rLeg,  CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0),  CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0))

	-- Humanoid
	local hum         = Instance.new("Humanoid")
	hum.MaxHealth     = bossData.health
	hum.Health        = bossData.health
	hum.WalkSpeed     = 26
	hum.JumpPower     = 65
	hum.DisplayName   = bossData.displayName
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff  -- we use our own billboard
	hum.Parent        = model

	-- Overhead billboard: name + HP bar
	local billboard         = Instance.new("BillboardGui")
	billboard.Name          = "BossInfo"
	billboard.Size          = UDim2.new(0, 220, 0, 54)
	billboard.StudsOffset   = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop   = false
	billboard.Parent        = root

	local nameTag               = Instance.new("TextLabel")
	nameTag.Size                = UDim2.new(1, 0, 0.52, 0)
	nameTag.BackgroundTransparency = 1
	nameTag.TextColor3          = Color3.fromRGB(255, 80, 80)
	nameTag.Font                = Enum.Font.GothamBold
	nameTag.TextSize            = 15
	nameTag.Text                = bossData.displayName
	nameTag.TextStrokeTransparency = 0.4
	nameTag.Parent              = billboard

	local hpBG                  = Instance.new("Frame")
	hpBG.Name                   = "HPBG"
	hpBG.Size                   = UDim2.new(1, 0, 0.40, 0)
	hpBG.Position               = UDim2.new(0, 0, 0.58, 0)
	hpBG.BackgroundColor3       = Color3.fromRGB(40, 40, 40)
	hpBG.BorderSizePixel        = 0
	hpBG.Parent                 = billboard
	local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0,3); c1.Parent = hpBG

	local hpFill                = Instance.new("Frame")
	hpFill.Name                 = "HPFill"
	hpFill.Size                 = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3     = Color3.fromRGB(220, 30, 30)
	hpFill.BorderSizePixel      = 0
	hpFill.Parent               = hpBG
	local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0,3); c2.Parent = hpFill

	-- Aura glow
	local bl = BloodlineData.Get(bossData.bloodline)
	local light        = Instance.new("PointLight")
	light.Color        = bl.auraColor
	light.Brightness   = 3
	light.Range        = 20
	light.Parent       = root

	model.PrimaryPart = root
	model.Parent      = workspace
	return model, hum, hpFill
end

-- ── Dialogue ─────────────────────────────────────────────────────

local function fireDialogue(bossModel, line)
	local remotes = R()
	remotes.ShowDialogue:FireAllClients(bossModel, line)
end

local function pickDialogue(bossState, phase)
	local data = bossState.data
	local lines = data.dialogue and data.dialogue[phase]
	if not lines or #lines == 0 then return nil end
	return lines[math.random(#lines)]
end

-- ── Attack logic ──────────────────────────────────────────────────

local function bossAttack(bossState, targetChar)
	local model   = bossState.model
	local root    = model.PrimaryPart
	if not root then return end
	local tRoot   = targetChar:FindFirstChild("HumanoidRootPart")
	if not tRoot  then return end

	local dist    = (root.Position - tRoot.Position).Magnitude
	local now     = os.clock()
	local cds     = bossState.moveCDs

	-- Low-health rage dialogue
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health < hum.MaxHealth * 0.5 and not bossState.rageDialogueFired then
		bossState.rageDialogueFired = true
		local line = pickDialogue(bossState, "lowHP")
		if line then fireDialogue(model, line) end
	end

	local function onCD(name, duration)
		if cds[name] then return true end
		cds[name] = true
		task.delay(duration, function() cds[name] = nil end)
		return false
	end

	-- Prioritise moves by range / impact
	if dist <= ATTACK_RANGE then
		-- M1 combo burst (3 rapid hits)
		if not onCD("M1", 0.9) then
			for i = 1, math.random(2, 4) do
				task.delay((i-1) * 0.22, function()
					local tHum = targetChar:FindFirstChildOfClass("Humanoid")
					if tHum and tHum.Health > 0 then
						local mv = MovesetData.GetComboMove(i <= 4 and i or 5)
						local dmg = mv and mv.damage or 10
						tHum:TakeDamage(dmg * 0.8)  -- NPC deals 80% of listed damage
						R().HitEffect:FireAllClients(targetChar, mv and mv.gore or "BloodSplatter_Medium", mv and mv.sfx or "Punch_Medium")
					end
				end)
			end
		end

		-- ThoraxStrike (grab) — if in bossData.moves and not on CD
		if bossState.data.powerLevel >= 100000 and not onCD("ThoraxStrike", 28) then
			local tHum = targetChar:FindFirstChildOfClass("Humanoid")
			if tHum and tHum.Health > 0 then
				tHum:TakeDamage(70)
				R().HitEffect:FireAllClients(targetChar, "GoreExplosion", "BoneCrunch")
				R().ScreenShake:FireAllClients(1.0)
				local bv = Instance.new("BodyVelocity")
				bv.Velocity   = Vector3.new(0, 50, 0) + (tRoot.Position - root.Position).Unit * 120
				bv.MaxForce   = Vector3.new(1e5, 1e5, 1e5)
				bv.P          = 1e4
				bv.Parent     = tRoot
				Debris:AddItem(bv, 0.35)
			end
		end

	elseif dist <= CLAP_RANGE then
		-- Sonic Clap
		if not onCD("SonicClap", 10) then
			for _, p in ipairs(Players:GetPlayers()) do
				local c = p.Character
				if not c then continue end
				local r2 = c:FindFirstChild("HumanoidRootPart")
				if not r2 then continue end
				if (r2.Position - root.Position).Magnitude <= CLAP_RANGE then
					local h = c:FindFirstChildOfClass("Humanoid")
					if h then
						h:TakeDamage(20)
						local bv = Instance.new("BodyVelocity")
						bv.Velocity   = (r2.Position - root.Position).Unit * 50
						bv.MaxForce   = Vector3.new(1e5, 1e5, 1e5)
						bv.P          = 1e4
						bv.Parent     = r2
						Debris:AddItem(bv, 0.35)
						R().HitEffect:FireAllClients(c, "EarBleed", "SonicClap")
					end
				end
			end
			R().ScreenShake:FireAllClients(0.6)
		end

	elseif dist <= RUSH_RANGE then
		-- Viltrumite Rush dash
		if not onCD("ViltrumiteRush", 14) then
			local dir = (tRoot.Position - root.Position).Unit
			local bv  = Instance.new("BodyVelocity")
			bv.Velocity   = dir * 480
			bv.MaxForce   = Vector3.new(1e6, 1e6, 1e6)
			bv.P          = 1e5
			bv.Parent     = root
			Debris:AddItem(bv, 0.16)
			-- Damage on arrival
			task.delay(0.15, function()
				local tHum = targetChar:FindFirstChildOfClass("Humanoid")
				if tHum and tHum.Health > 0 then
					tHum:TakeDamage(38)
					R().HitEffect:FireAllClients(targetChar, "BloodTrail", "SonicBoom")
					R().ScreenShake:FireAllClients(0.8)
				end
			end)
		end
	end
end

-- ── AI tick per boss ──────────────────────────────────────────────

local function tickBoss(bossName, bossState)
	local model = bossState.model
	if not model or not model.Parent then
		activeBosses[bossName] = nil
		return
	end
	local hum  = model:FindFirstChildOfClass("Humanoid")
	local root = model.PrimaryPart
	if not hum or not root or hum.Health <= 0 then return end

	-- Find nearest alive player
	local nearest, nearestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		if not c then continue end
		local r = c:FindFirstChild("HumanoidRootPart")
		if not r then continue end
		local h = c:FindFirstChildOfClass("Humanoid")
		if not h or h.Health <= 0 then continue end
		local d = (r.Position - root.Position).Magnitude
		if d < nearestDist then nearest = p; nearestDist = d end
	end

	local state = bossState.state

	if state == "IDLE" or state == "PATROL" then
		if nearest and nearestDist < AGGRO_RANGE then
			bossState.state  = "AGGRO"
			bossState.target = nearest
			local line = pickDialogue(bossState, "spawn")
			if line then fireDialogue(model, line) end
			R().BossSpawned:FireAllClients(bossName, bossState.data.powerLevel)
		else
			-- Patrol: walk between offsets around spawn
			bossState.patrolTimer = (bossState.patrolTimer or 0) + AI_TICK
			if bossState.patrolTimer >= 3 then
				bossState.patrolTimer = 0
				bossState.patrolIdx = (bossState.patrolIdx % #PATROL_OFFSETS) + 1
				local dest = bossState.spawnPos + PATROL_OFFSETS[bossState.patrolIdx]
				hum:MoveTo(dest)
			end
		end

	elseif state == "AGGRO" then
		local target = bossState.target
		if not target or not target.Character then
			bossState.state = "PATROL"; bossState.target = nil; return
		end
		local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if not tRoot then bossState.state = "PATROL"; return end
		local dist = (root.Position - tRoot.Position).Magnitude

		if (root.Position - bossState.spawnPos).Magnitude > DEAGGRO_RANGE or nearestDist > DEAGGRO_RANGE then
			bossState.state = "RESETTING"; bossState.target = nil; return
		end

		if dist <= ATTACK_RANGE + 3 then
			bossState.state = "COMBAT"
		else
			hum:MoveTo(tRoot.Position)
			local line = pickDialogue(bossState, "combat")
			if line and math.random(20) == 1 then fireDialogue(model, line) end
		end

	elseif state == "COMBAT" then
		local target = bossState.target
		if not target or not target.Character then
			bossState.state = "PATROL"; return
		end
		local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if not tRoot then bossState.state = "PATROL"; return end
		local dist = (root.Position - tRoot.Position).Magnitude

		if dist > ATTACK_RANGE + 8 then
			bossState.state = "AGGRO"; return
		end

		-- Face target
		root.CFrame = CFrame.lookAt(root.Position, Vector3.new(tRoot.Position.X, root.Position.Y, tRoot.Position.Z))

		bossAttack(bossState, target.Character)

	elseif state == "RESETTING" then
		local spawnDist = (root.Position - bossState.spawnPos).Magnitude
		if spawnDist > 6 then
			hum:MoveTo(bossState.spawnPos)
		else
			-- Fast regen while resetting
			if hum.Health < hum.MaxHealth then
				hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * 0.05)
			else
				bossState.state           = "IDLE"
				bossState.rageDialogueFired = false
			end
		end
	end
end

-- ── HP sync ───────────────────────────────────────────────────────

local function syncHP(bossState)
	local model = bossState.model
	local hum   = model and model:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local pct  = hum.Health / hum.MaxHealth
	local fill = model.PrimaryPart and model.PrimaryPart:FindFirstChild("BossInfo")
		and model.PrimaryPart.BossInfo:FindFirstChild("HPBG")
		and model.PrimaryPart.BossInfo.HPBG:FindFirstChild("HPFill")
	if fill then
		fill.Size = UDim2.new(pct, 0, 1, 0)
	end
	R().BossHealthUpdate:FireAllClients(bossState.name, hum.Health, hum.MaxHealth)
end

-- ── Spawn / despawn ───────────────────────────────────────────────

function BossService.Spawn(bossName)
	if activeBosses[bossName] then return end
	local data = CharacterData.Get(bossName)
	if not data then warn("[BossService] Unknown boss:", bossName); return end

	local spawnPos = SPAWN_POSITIONS[bossName] or Vector3.new(0, 5, 0)
	local model, hum, _ = buildRig(bossName, data, spawnPos)

	local bossState = {
		name              = bossName,
		data              = data,
		model             = model,
		state             = "IDLE",
		target            = nil,
		spawnPos          = spawnPos,
		patrolIdx         = 1,
		patrolTimer       = 0,
		moveCDs           = {},
		rageDialogueFired = false,
	}
	activeBosses[bossName] = bossState

	-- Death handler
	hum.Died:Connect(function()
		bossState.state = "DEAD"
		local line = pickDialogue(bossState, "defeated")
		if line then fireDialogue(model, line) end

		-- Reward all nearby players
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if not c then continue end
			local r = c:FindFirstChild("HumanoidRootPart")
			if r and (r.Position - spawnPos).Magnitude < 200 then
				local PlayerDataService = require(script.Parent.PlayerDataService)
				local rewards = data.rewards or {}
				if rewards.xp then PlayerDataService.AddXP(p, rewards.xp) end
				if rewards.title then
					local pd = PlayerDataService.Get(p)
					if pd then
						local has = false
						for _, t in ipairs(pd.titles) do if t == rewards.title then has = true end end
						if not has then table.insert(pd.titles, rewards.title) end
					end
				end
			end
		end

		R().BossDefeated:FireAllClients(bossName, "")

		-- Remove model after a few seconds, respawn after delay
		task.delay(6, function()
			if model and model.Parent then model:Destroy() end
			activeBosses[bossName] = nil
		end)
		task.delay(data.respawnImmune and 12 or 120, function()  -- Immortal respawns fast
			BossService.Spawn(bossName)
		end)
	end)

	-- HP sync on change
	hum:GetPropertyChangedSignal("Health"):Connect(function()
		syncHP(bossState)
	end)

	print("[BossService] Spawned:", bossName, "at", spawnPos)
end

function BossService.SpawnAll()
	for bossName in pairs(SPAWN_POSITIONS) do
		task.delay(math.random(0, 5), function()  -- stagger spawns
			BossService.Spawn(bossName)
		end)
	end
end

-- ── Heartbeat AI loop ─────────────────────────────────────────────

RunService.Heartbeat:Connect(function(dt)
	aiTimer += dt
	if aiTimer < AI_TICK then return end
	aiTimer = 0
	for name, state in pairs(activeBosses) do
		local ok, err = pcall(tickBoss, name, state)
		if not ok then warn("[BossService] AI error for", name, ":", err) end
	end
end)

return BossService
