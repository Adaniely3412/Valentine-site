-- Manages power aura visuals on the local character.
-- Aura scales with power level tier; color matches bloodline.
-- Fires shockwave ring on tier-up.

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root      = character:WaitForChild("HumanoidRootPart")

local Remotes       = ReplicatedStorage:WaitForChild("Remotes")
local Config        = require(ReplicatedStorage.Modules.Config)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)

-- ── Aura tier config ─────────────────────────────────────────────
-- Tier index maps to Config.TIERS

local TIER_AURA = {
	-- [tierIndex] = { rate, speed, size, lightBrightness, lightRange, hasPulse }
	[1] = { rate = 0,   speed = 0,  size = 0,    lb = 0,   lr = 0,  pulse = false },  -- Human
	[2] = { rate = 2,   speed = 2,  size = 0.08, lb = 0.5, lr = 6,  pulse = false },  -- Trained
	[3] = { rate = 8,   speed = 4,  size = 0.12, lb = 1,   lr = 10, pulse = false },  -- Enhanced
	[4] = { rate = 20,  speed = 6,  size = 0.18, lb = 2,   lr = 16, pulse = true  },  -- Viltrumite Stir
	[5] = { rate = 45,  speed = 10, size = 0.28, lb = 3.5, lr = 24, pulse = true  },  -- Viltrumite
	[6] = { rate = 80,  speed = 16, size = 0.40, lb = 5,   lr = 35, pulse = true  },  -- Elite
	[7] = { rate = 150, speed = 22, size = 0.55, lb = 8,   lr = 50, pulse = true  },  -- Pure
}

-- ── State ─────────────────────────────────────────────────────────
local auraPart     = nil
local auraEmitter  = nil
local auraLight    = nil
local currentTier  = 1
local pulseTimer   = 0
local pulsing      = false

-- ── Build aura parts ──────────────────────────────────────────────

local function buildAura()
	if auraPart then auraPart:Destroy() end

	auraPart           = Instance.new("Part")
	auraPart.Name      = "AuraPart"
	auraPart.Size      = Vector3.new(0.2, 0.2, 0.2)
	auraPart.Anchored  = false
	auraPart.CanCollide = false
	auraPart.Transparency = 1
	auraPart.CastShadow = false
	auraPart.Parent    = character

	local weld         = Instance.new("WeldConstraint")
	weld.Part0         = root
	weld.Part1         = auraPart
	weld.Parent        = auraPart
	auraPart.CFrame    = root.CFrame

	-- Particle emitter
	auraEmitter             = Instance.new("ParticleEmitter")
	auraEmitter.LightEmission = 0.8
	auraEmitter.LightInfluence = 0
	auraEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.2),
		NumberSequenceKeypoint.new(0.6, 0.5),
		NumberSequenceKeypoint.new(1,   1),
	})
	auraEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 0),
	})
	auraEmitter.Rotation       = NumberRange.new(-180, 180)
	auraEmitter.RotSpeed       = NumberRange.new(-60, 60)
	auraEmitter.SpreadAngle    = Vector2.new(25, 25)
	auraEmitter.LockedToPart   = false
	auraEmitter.VelocityInheritance = 0.3
	auraEmitter.Rate           = 0
	auraEmitter.Parent         = auraPart

	-- Point light
	auraLight             = Instance.new("PointLight")
	auraLight.Brightness  = 0
	auraLight.Range       = 0
	auraLight.Parent      = auraPart
end

-- ── Apply tier settings ───────────────────────────────────────────

local function applyTier(tierIdx, bloodlineColor)
	local cfg = TIER_AURA[tierIdx] or TIER_AURA[1]
	if not auraEmitter or not auraLight then return end

	auraEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   bloodlineColor),
		ColorSequenceKeypoint.new(0.5, bloodlineColor:Lerp(Color3.fromRGB(255,255,255), 0.3)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,255,255)),
	})
	auraEmitter.Speed         = NumberRange.new(cfg.speed * 0.6, cfg.speed)
	auraEmitter.Size          = NumberSequence.new({
		NumberSequenceKeypoint.new(0, cfg.size * 1.5),
		NumberSequenceKeypoint.new(0.5, cfg.size),
		NumberSequenceKeypoint.new(1, 0),
	})

	TweenService:Create(auraEmitter, TweenInfo.new(0.6), { Rate = cfg.rate }):Play()

	auraLight.Color      = bloodlineColor
	TweenService:Create(auraLight, TweenInfo.new(0.6), {
		Brightness = cfg.lb,
		Range      = cfg.lr,
	}):Play()
end

-- ── Shockwave on tier-up ──────────────────────────────────────────

local function spawnShockwave(color, scale)
	local ring           = Instance.new("Part")
	ring.Shape           = Enum.PartType.Cylinder
	ring.Size            = Vector3.new(0.4, 0.6, 0.6)
	ring.CFrame          = root.CFrame * CFrame.Angles(0, 0, math.pi/2)
	ring.Anchored        = true
	ring.CanCollide      = false
	ring.BrickColor      = BrickColor.new("Bright red")
	ring.Color           = color
	ring.Material        = Enum.Material.Neon
	ring.CastShadow      = false
	ring.Parent          = workspace

	local targetSize     = Vector3.new(0.2, scale, scale)
	local expandTween    = TweenService:Create(ring,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = targetSize, Transparency = 1 })
	expandTween:Play()
	expandTween.Completed:Connect(function() ring:Destroy() end)

	-- Ground impact ring
	local groundRing     = Instance.new("Part")
	groundRing.Shape     = Enum.PartType.Cylinder
	groundRing.Size      = Vector3.new(0.3, 0.5, 0.5)
	groundRing.CFrame    = CFrame.new(root.Position.X, root.Position.Y - 2.8, root.Position.Z)
		* CFrame.Angles(0, 0, math.pi/2)
	groundRing.Anchored  = true
	groundRing.CanCollide = false
	groundRing.Color     = color
	groundRing.Material  = Enum.Material.Neon
	groundRing.CastShadow = false
	groundRing.Parent    = workspace

	local gt = TweenService:Create(groundRing,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.15, scale * 1.4, scale * 1.4), Transparency = 1 })
	gt:Play()
	gt.Completed:Connect(function() groundRing:Destroy() end)
end

-- ── Tier detection ────────────────────────────────────────────────

local function getTier(pl)
	local idx = 1
	for i = #Config.TIERS, 1, -1 do
		if pl >= Config.TIERS[i].minPL then idx = i; break end
	end
	return idx
end

-- ── Init & update ─────────────────────────────────────────────────

buildAura()

local function updateAura()
	if not character.Parent then return end
	local pl         = character:GetAttribute("PowerLevel") or 0
	local bloodline  = character:GetAttribute("Bloodline")  or "Human"
	local bl         = BloodlineData.Get(bloodline)
	local newTier    = getTier(pl)

	if newTier ~= currentTier then
		-- Tier changed
		if newTier > currentTier then
			-- Tier-UP shockwave
			local shockScale = 14 + newTier * 8
			spawnShockwave(bl.auraColor, shockScale)
			Remotes.ShowNotification:FireServer()  -- handled client-locally via attribute
			character:SetAttribute("NotifMsg", "POWER TIER: " .. Config.TIERS[newTier].name:upper() .. "!")
		end
		currentTier = newTier
		applyTier(newTier, bl.auraColor)
	end
end

-- ── Pulse effect (heartbeat throb on active tiers) ─────────────────

RunService.RenderStepped:Connect(function(dt)
	if not auraEmitter then return end
	local cfg = TIER_AURA[currentTier]
	if not cfg or not cfg.pulse then return end

	pulseTimer += dt
	local pulse = 1 + math.sin(pulseTimer * 3) * 0.25
	auraEmitter.Rate = cfg.rate * pulse
end)

-- ── PL attribute watcher ──────────────────────────────────────────

character:GetAttributeChangedSignal("PowerLevel"):Connect(updateAura)
character:GetAttributeChangedSignal("Bloodline"):Connect(function()
	currentTier = 0  -- force reapply
	updateAura()
end)

updateAura()  -- init on spawn

-- ── Respawn ──────────────────────────────────────────────────────

player.CharacterAdded:Connect(function(newChar)
	character    = newChar
	root         = newChar:WaitForChild("HumanoidRootPart")
	currentTier  = 1
	pulseTimer   = 0
	auraPart     = nil
	auraEmitter  = nil
	auraLight    = nil
	buildAura()
	updateAura()
	newChar:GetAttributeChangedSignal("PowerLevel"):Connect(updateAura)
	newChar:GetAttributeChangedSignal("Bloodline"):Connect(function()
		currentTier = 0; updateAura()
	end)
end)
