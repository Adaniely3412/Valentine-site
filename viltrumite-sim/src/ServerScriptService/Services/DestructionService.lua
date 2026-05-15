-- Handles EarthShatter craters, building damage, and environmental destruction.
-- Craters dig into Terrain. Buildings tagged "Destructible" in the workspace react to impacts.

local DestructionService = {}

local Players           = game:GetService("Players")
local Debris            = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function R() return ReplicatedStorage:WaitForChild("Remotes", 10) end

-- ── Crater ────────────────────────────────────────────────────────

local CRATER_DEPTH  = 5
local DEBRIS_COUNT  = 14

local function spawnDebris(center, radius)
	for i = 1, DEBRIS_COUNT do
		local angle  = (i / DEBRIS_COUNT) * math.pi * 2
		local spread = radius * (0.3 + math.random() * 0.7)
		local offset = Vector3.new(math.cos(angle) * spread, math.random(2, 8), math.sin(angle) * spread)

		local chunk  = Instance.new("Part")
		chunk.Size   = Vector3.new(math.random(1, 4), math.random(1, 3), math.random(1, 4))
		chunk.CFrame = CFrame.new(center + offset) * CFrame.Angles(
			math.random() * math.pi,
			math.random() * math.pi,
			math.random() * math.pi
		)
		chunk.BrickColor = BrickColor.new("Brown")
		chunk.Material   = Enum.Material.Rock
		chunk.Anchored   = false
		chunk.CanCollide = true
		chunk.Parent     = workspace

		-- Give initial outward velocity
		local bv        = Instance.new("BodyVelocity")
		bv.Velocity     = offset.Unit * math.random(15, 45) + Vector3.new(0, math.random(10, 25), 0)
		bv.MaxForce     = Vector3.new(1e5, 1e5, 1e5)
		bv.P            = 1e4
		bv.Parent       = chunk
		Debris:AddItem(bv, 0.4)
		Debris:AddItem(chunk, 12)
	end
end

local function digTerrain(center, radius, depth)
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if not terrain then return end
	-- Carve a cylinder into the terrain
	local steps = 6
	for i = 1, steps do
		local t   = (i - 1) / (steps - 1)
		local r   = radius * (1 - t * 0.5)
		local y   = center.Y - depth * t
		local size = Vector3.new(r * 2, depth / steps + 1, r * 2)
		local cf   = CFrame.new(center.X, y, center.Z)
		terrain:FillBlock(cf, size, Enum.Material.Air)
	end
end

local function spawnCraterRing(center, radius)
	-- Rim of scorched earth
	local rim     = Instance.new("Part")
	rim.Shape     = Enum.PartType.Cylinder
	rim.Size      = Vector3.new(0.4, radius * 2, radius * 2)
	rim.CFrame    = CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2)
	rim.Anchored  = true
	rim.CanCollide = false
	rim.BrickColor = BrickColor.new("Black")
	rim.Material   = Enum.Material.Asphalt
	rim.Parent     = workspace
	Debris:AddItem(rim, 90)  -- lasts 90 seconds then fades
end

function DestructionService.CreateCrater(position, radius)
	radius = radius or 18
	digTerrain(position, radius, CRATER_DEPTH)
	spawnDebris(position, radius)
	spawnCraterRing(position, radius)

	-- Notify clients to play sound
	R().PlaySound:FireAllClients("CraterImpact", position)
end

-- ── Building destruction ──────────────────────────────────────────
-- Tag building parts with the CollectionService tag "Destructible" in Studio.
-- On impact, parts crack (material → SmoothPlastic, transparency increases),
-- and eventually break into debris after taking enough hits.

local buildingHP = {}  -- [part] = remaining HP

local function damageBuilding(part, damage)
	if not part:HasTag("Destructible") then return end
	local hp = buildingHP[part]
	if hp == nil then
		hp = 100  -- default HP for destructible parts
		buildingHP[part] = hp
	end
	hp = hp - damage
	buildingHP[part] = hp

	-- Visual damage stages
	if hp <= 0 then
		-- Shatter into debris
		local center = part.Position
		local size   = part.Size
		for i = 1, math.min(8, math.floor((size.X * size.Z) / 4)) do
			local chunk  = Instance.new("Part")
			chunk.Size   = Vector3.new(
				math.random() * size.X * 0.4 + 0.5,
				math.random() * size.Y * 0.4 + 0.5,
				math.random() * size.Z * 0.4 + 0.5)
			chunk.BrickColor = part.BrickColor
			chunk.Material   = part.Material
			chunk.CFrame     = CFrame.new(center + Vector3.new(
				(math.random() - 0.5) * size.X,
				(math.random() - 0.5) * size.Y,
				(math.random() - 0.5) * size.Z))
			chunk.Parent     = workspace
			local bv = Instance.new("BodyVelocity")
			bv.Velocity  = Vector3.new((math.random()-0.5)*20, math.random(5,20), (math.random()-0.5)*20)
			bv.MaxForce  = Vector3.new(1e5,1e5,1e5)
			bv.P         = 1e4
			bv.Parent    = chunk
			Debris:AddItem(bv, 0.5)
			Debris:AddItem(chunk, 15)
		end
		part:Destroy()
		buildingHP[part] = nil

	elseif hp <= 33 then
		part.Transparency = 0.4
		part.Material     = Enum.Material.Cracked

	elseif hp <= 66 then
		part.Transparency = 0.15
		part.Material     = Enum.Material.Concrete
	end
end

-- ── Impact zones ──────────────────────────────────────────────────
-- Called by CombatService when EarthShatter or heavy finisher hits.

function DestructionService.OnImpact(position, radius, damage)
	-- Crater in terrain
	DestructionService.CreateCrater(position, radius)

	-- Damage nearby destructible buildings
	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("BasePart") and desc:HasTag("Destructible") then
			local d = (desc.Position - position).Magnitude
			if d <= radius * 1.5 then
				local falloff = 1 - (d / (radius * 1.5))
				damageBuilding(desc, damage * falloff)
			end
		end
	end

	-- Screen shake for all nearby players
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		if not c then continue end
		local r = c:FindFirstChild("HumanoidRootPart")
		if r then
			local dist = (r.Position - position).Magnitude
			if dist < 120 then
				R().ScreenShake:FireClient(p, 1.2 * (1 - dist / 120))
			end
		end
	end
end

return DestructionService
