-- Handles all combat input, client-side hit detection, move execution, and gore effects.

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")
local camera    = workspace.CurrentCamera

local Remotes   = ReplicatedStorage:WaitForChild("Remotes")
local Config    = require(ReplicatedStorage.Modules.Config)
local MovesetData = require(ReplicatedStorage.Modules.MovesetData)

-- ── State ────────────────────────────────────────────────────────
local comboCount  = 0
local comboTimer  = 0
local isAttacking = false
local isBlocking  = false
local specialCDs  = {}

-- ── Helpers ──────────────────────────────────────────────────────

local function getTargets(origin, range, aoeAngle)
	local hits = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p == player then continue end
		local c = p.Character
		if not c then continue end
		local r = c:FindFirstChild("HumanoidRootPart")
		if not r then continue end
		local h = c:FindFirstChildOfClass("Humanoid")
		if not h or h.Health <= 0 then continue end
		local dist = (r.Position - origin.Position).Magnitude
		if dist > range then continue end
		if aoeAngle then
			local dot = (r.Position - origin.Position).Unit:Dot(origin.CFrame.LookVector)
			if dot < math.cos(math.rad(aoeAngle / 2)) then continue end
		end
		table.insert(hits, c)
	end
	return hits
end

local function closestTarget(targets)
	local best, bestDist = nil, math.huge
	for _, c in ipairs(targets) do
		local r = c:FindFirstChild("HumanoidRootPart")
		if r then
			local d = (r.Position - rootPart.Position).Magnitude
			if d < bestDist then best, bestDist = c, d end
		end
	end
	return best
end

-- ── Gore / hit particles ─────────────────────────────────────────

local GORE_PARTICLES = {
	BloodSplatter_Small   = { count = 8,  speed = 15, spread = 40 },
	BloodSplatter_Medium  = { count = 16, speed = 22, spread = 55 },
	BloodSplatter_Large   = { count = 28, speed = 30, spread = 70 },
	BloodSplatter_Massive = { count = 55, speed = 45, spread = 90 },
	GoreExplosion         = { count = 80, speed = 60, spread = 360 },
	EarBleed              = { count = 5,  speed = 8,  spread = 20 },
	BloodTrail            = { count = 20, speed = 35, spread = 30 },
}

local function spawnGore(targetChar, goreType)
	local root = targetChar:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local cfg = GORE_PARTICLES[goreType] or GORE_PARTICLES.BloodSplatter_Small

	local anchor = Instance.new("Part")
	anchor.Anchored   = true
	anchor.CanCollide = false
	anchor.Size       = Vector3.new(0.2, 0.2, 0.2)
	anchor.CFrame     = root.CFrame
	anchor.Transparency = 1
	anchor.Parent     = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(180, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 0)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(60,  0, 0)),
	})
	emitter.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Speed       = NumberRange.new(cfg.speed * 0.7, cfg.speed)
	emitter.SpreadAngle = Vector2.new(cfg.spread / 2, cfg.spread / 2)
	emitter.Lifetime    = NumberRange.new(0.4, 1.0)
	emitter.Rate        = 0
	emitter.LightEmission = 0.1
	emitter.Parent      = anchor
	emitter:Emit(cfg.count)

	Debris:AddItem(anchor, 1.5)
end

-- Impact flash
local function spawnImpactFlash(targetChar)
	local root = targetChar:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local flash = Instance.new("Part")
	flash.Anchored    = true
	flash.CanCollide  = false
	flash.Size        = Vector3.new(1.5, 1.5, 1.5)
	flash.Shape       = Enum.PartType.Ball
	flash.Material    = Enum.Material.Neon
	flash.Color       = Color3.fromRGB(255, 200, 50)
	flash.Transparency = 0.3
	flash.CFrame      = root.CFrame
	flash.Parent      = workspace
	Debris:AddItem(flash, 0.08)
end

-- ── Screen shake ─────────────────────────────────────────────────

local function shakeCamera(intensity)
	local elapsed = 0
	local duration = 0.45
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		if elapsed >= duration then conn:Disconnect(); return end
		local t = 1 - (elapsed / duration)
		local mag = intensity * 2.5 * t
		camera.CFrame = camera.CFrame *
			CFrame.new((math.random() - 0.5) * mag, (math.random() - 0.5) * mag, 0)
	end)
end

-- ── Animation stub ───────────────────────────────────────────────
-- Set an attribute so UIController / future animation module can react.
local function playAnim(name)
	character:SetAttribute("CurrentAnim", name)
end

-- ── M1 Combo ─────────────────────────────────────────────────────

local function doM1()
	if isAttacking or isBlocking then return end
	isAttacking = true
	comboCount  = (comboCount % Config.MAX_COMBO) + 1

	local move = MovesetData.GetComboMove(comboCount)
	if not move then isAttacking = false; return end

	playAnim(move.animation)

	local targets = getTargets(rootPart, move.range)
	for _, tChar in ipairs(targets) do
		Remotes.CombatHit:FireServer(tChar, "M1", comboCount)
		spawnGore(tChar, move.gore)
		spawnImpactFlash(tChar)
	end

	character:SetAttribute("ComboCount", comboCount)
	comboTimer = Config.COMBO_WINDOW

	task.wait(0.22)
	isAttacking = false
end

-- ── Special moves ────────────────────────────────────────────────

local function useSpecial(moveName)
	local move = MovesetData.Get(moveName)
	if not move then return end

	if specialCDs[moveName] then
		character:SetAttribute("NotifMsg", move.name .. " on cooldown")
		return
	end

	local pl = character:GetAttribute("PowerLevel") or 0
	if pl < (move.requiredPL or 0) then
		character:SetAttribute("NotifMsg", "Need PL " .. move.requiredPL .. " for " .. move.name)
		return
	end

	local requiredBL = move.requiredBloodline
	if requiredBL and character:GetAttribute("Bloodline") ~= requiredBL then
		character:SetAttribute("NotifMsg", move.name .. " requires " .. requiredBL)
		return
	end

	if move.requiresFlight and not character:GetAttribute("IsFlying") then
		character:SetAttribute("NotifMsg", move.name .. " requires Flight (Z)")
		return
	end

	-- Lock cooldown
	specialCDs[moveName] = true
	character:SetAttribute("CD_" .. moveName, true)
	task.delay(move.cooldown, function()
		specialCDs[moveName] = nil
		character:SetAttribute("CD_" .. moveName, false)
	end)

	playAnim(move.animation)

	-- Target selection
	local targets
	if move.aoeAngle then
		targets = getTargets(rootPart, move.range, move.aoeAngle)
	elseif move.isGrab then
		local all = getTargets(rootPart, move.range)
		local best = closestTarget(all)
		targets = best and { best } or {}
	else
		targets = getTargets(rootPart, move.range)
	end

	for _, tChar in ipairs(targets) do
		Remotes.UseMove:FireServer(moveName, tChar)
		spawnGore(tChar, move.gore or "BloodSplatter_Large")
		spawnImpactFlash(tChar)
	end

	-- Dash for ViltrumiteRush
	if moveName == "ViltrumiteRush" and #targets > 0 then
		local tRoot = targets[1]:FindFirstChild("HumanoidRootPart")
		if tRoot then
			local bv = Instance.new("BodyVelocity")
			bv.Velocity   = (tRoot.Position - rootPart.Position).Unit * move.dashSpeed
			bv.MaxForce   = Vector3.new(1e6, 1e6, 1e6)
			bv.P          = 1e5
			bv.Parent     = rootPart
			Debris:AddItem(bv, 0.14)
		end
	end
end

-- ── Input ────────────────────────────────────────────────────────

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then doM1() end
	if input.KeyCode == Enum.KeyCode.Q then
		isBlocking = true
		Remotes.CombatBlock:FireServer(true)
	end
	if input.KeyCode == Enum.KeyCode.E then useSpecial("SonicClap") end
	if input.KeyCode == Enum.KeyCode.R then useSpecial("ViltrumiteRush") end
	if input.KeyCode == Enum.KeyCode.F then useSpecial("EarthShatter") end
	if input.KeyCode == Enum.KeyCode.G then useSpecial("ThoraxStrike") end
	if input.KeyCode == Enum.KeyCode.T then useSpecial("SupremeOverdrive") end
end)

UserInputService.InputEnded:Connect(function(input, gp)
	if input.KeyCode == Enum.KeyCode.Q then
		isBlocking = false
		Remotes.CombatBlock:FireServer(false)
	end
end)

-- ── Heartbeat ────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function(dt)
	if comboTimer > 0 then
		comboTimer -= dt
		if comboTimer <= 0 then
			comboCount = 0
			character:SetAttribute("ComboCount", 0)
		end
	end
end)

-- ── Remote listeners ─────────────────────────────────────────────

Remotes.HitEffect.OnClientEvent:Connect(function(tChar, gore, _sfx)
	spawnGore(tChar, gore)
	spawnImpactFlash(tChar)
end)

Remotes.ScreenShake.OnClientEvent:Connect(function(intensity)
	shakeCamera(intensity)
end)

Remotes.Ragdoll.OnClientEvent:Connect(function(tChar, enable)
	local h = tChar:FindFirstChildOfClass("Humanoid")
	if h then
		h:ChangeState(enable
			and Enum.HumanoidStateType.Physics
			or  Enum.HumanoidStateType.GettingUp)
	end
end)

-- ── Respawn ──────────────────────────────────────────────────────

player.CharacterAdded:Connect(function(newChar)
	character   = newChar
	humanoid    = newChar:WaitForChild("Humanoid")
	rootPart    = newChar:WaitForChild("HumanoidRootPart")
	comboCount  = 0
	comboTimer  = 0
	isAttacking = false
	isBlocking  = false
	specialCDs  = {}
end)
