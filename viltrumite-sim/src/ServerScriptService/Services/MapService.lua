-- Procedurally generates the game world at server start.
-- Builds Grayson Residence, GDA HQ, Viltrum Outpost, roads, and zone triggers.
-- Drop in your own Studio-built map and delete this file once you have one.

local MapService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")

local Config = require(ReplicatedStorage.Modules.Config)

-- ── Lighting / atmosphere ─────────────────────────────────────────

local function setupLighting()
	local lighting = game:GetService("Lighting")
	lighting.Ambient          = Color3.fromRGB(80, 80, 100)
	lighting.Brightness       = 2
	lighting.GlobalShadows    = true
	lighting.OutdoorAmbient   = Color3.fromRGB(120, 120, 150)
	lighting.ShadowSoftness   = 0.4
	lighting.ClockTime        = 14  -- afternoon

	local sky = Instance.new("Sky")
	sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
	sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
	sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
	sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
	sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
	sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
	sky.Parent   = lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density   = 0.35
	atmosphere.Offset    = 0.1
	atmosphere.Color     = Color3.fromRGB(199, 199, 199)
	atmosphere.Decay     = Color3.fromRGB(96, 120, 139)
	atmosphere.Glare     = 0.2
	atmosphere.Haze      = 1.8
	atmosphere.Parent    = lighting
end

-- ── Part builder helpers ──────────────────────────────────────────

local mapFolder = Instance.new("Folder")
mapFolder.Name  = "Map"
mapFolder.Parent = workspace

local zonesFolder = Instance.new("Folder")
zonesFolder.Name  = "Zones"
zonesFolder.Parent = workspace

local function P(name, size, cf, color, material, transparency, parent)
	local p = Instance.new("Part")
	p.Name         = name
	p.Size         = size
	p.CFrame       = cf
	p.BrickColor   = BrickColor.new(color or "Medium stone grey")
	p.Material     = material or Enum.Material.SmoothPlastic
	p.Transparency = transparency or 0
	p.Anchored     = true
	p.CanCollide   = true
	p.CastShadow   = true
	p.Parent       = parent or mapFolder
	return p
end

local function wedge(name, size, cf, color, material)
	local w = Instance.new("WedgePart")
	w.Name       = name
	w.Size       = size
	w.CFrame     = cf
	w.BrickColor = BrickColor.new(color or "Medium stone grey")
	w.Material   = material or Enum.Material.SmoothPlastic
	w.Anchored   = true
	w.CanCollide = true
	w.Parent     = mapFolder
	return w
end

local function cylinder(name, diameter, height, cf, color, material)
	local c = Instance.new("Part")
	c.Name     = name
	c.Shape    = Enum.PartType.Cylinder
	c.Size     = Vector3.new(height, diameter, diameter)
	c.CFrame   = cf * CFrame.Angles(0, 0, math.pi / 2)
	c.BrickColor = BrickColor.new(color or "Reddish Brown")
	c.Material = material or Enum.Material.Wood
	c.Anchored = true
	c.Parent   = mapFolder
	return c
end

local function ball(name, diameter, cf, color, material)
	local b = Instance.new("Part")
	b.Name   = name
	b.Shape  = Enum.PartType.Ball
	b.Size   = Vector3.new(diameter, diameter, diameter)
	b.CFrame = cf
	b.BrickColor = BrickColor.new(color or "Bright green")
	b.Material   = material or Enum.Material.Grass
	b.Anchored   = true
	b.Parent = mapFolder
	return b
end

local function light(pos, color, brightness, range)
	local lp = P("Light", Vector3.new(0.2,0.2,0.2), CFrame.new(pos), "Black", Enum.Material.Neon, 0)
	local pl = Instance.new("PointLight")
	pl.Color      = color
	pl.Brightness = brightness or 3
	pl.Range      = range or 20
	pl.Parent     = lp
	return lp
end

-- ── Ground / terrain ──────────────────────────────────────────────

local function buildGround()
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		-- Fill flat grass baseplate
		terrain:FillBlock(CFrame.new(0, -3, 0), Vector3.new(1200, 6, 1200), Enum.Material.Grass)
		-- Roads (gray asphalt strips)
		terrain:FillBlock(CFrame.new(0, -0.4, 0),   Vector3.new(12, 1, 400), Enum.Material.Asphalt)  -- N-S
		terrain:FillBlock(CFrame.new(0, -0.4, 20),   Vector3.new(400, 1, 12), Enum.Material.Asphalt) -- E-W
		-- Elevated hill for Viltrum Outpost
		terrain:FillBlock(CFrame.new(120, 18, 80), Vector3.new(100, 40, 100), Enum.Material.Rock)
	else
		-- Fallback: giant flat part
		P("Ground", Vector3.new(1200, 6, 1200), CFrame.new(0,-3,0), "Sand", Enum.Material.Grass)
	end
end

-- ── Grayson Residence ─────────────────────────────────────────────
-- Positioned near (0, 0, -80) to match Omni-Man boss spawn.

local GR = Vector3.new(0, 0, -80)

local function buildGraysonResidence()
	local o = GR  -- origin

	-- Foundation slab
	P("Foundation", Vector3.new(44,1,34), CFrame.new(o + Vector3.new(0,0.5,0)), "White", Enum.Material.Concrete)

	-- Walls
	P("WallFront",  Vector3.new(44,10,1), CFrame.new(o + Vector3.new(0,5.5,-16.5)), "White", Enum.Material.SmoothPlastic)
	P("WallBack",   Vector3.new(44,10,1), CFrame.new(o + Vector3.new(0,5.5, 16.5)), "White", Enum.Material.SmoothPlastic)
	P("WallLeft",   Vector3.new(1,10,34), CFrame.new(o + Vector3.new(-21.5,5.5,0)), "White", Enum.Material.SmoothPlastic)
	P("WallRight",  Vector3.new(1,10,34), CFrame.new(o + Vector3.new( 21.5,5.5,0)), "White", Enum.Material.SmoothPlastic)

	-- Roof (flat with slight overhang)
	P("Roof", Vector3.new(48,1.5,38), CFrame.new(o + Vector3.new(0,11,0)), "Medium stone grey", Enum.Material.SmoothPlastic)

	-- Door cutout (simulated with a slightly inset darker block)
	P("Door", Vector3.new(4,7,0.5), CFrame.new(o + Vector3.new(0,3.5,-17)), "Dark orange", Enum.Material.Wood)

	-- Windows (dark glass look)
	P("WinFR", Vector3.new(6,4,0.4), CFrame.new(o + Vector3.new(-8, 6,-16.8)), "Black", Enum.Material.Neon, 0.7)
	P("WinFL", Vector3.new(6,4,0.4), CFrame.new(o + Vector3.new( 8, 6,-16.8)), "Black", Enum.Material.Neon, 0.7)
	P("WinSL", Vector3.new(0.4,4,8), CFrame.new(o + Vector3.new(-21.8,6, 4)),  "Black", Enum.Material.Neon, 0.7)
	P("WinSR", Vector3.new(0.4,4,8), CFrame.new(o + Vector3.new( 21.8,6, 4)),  "Black", Enum.Material.Neon, 0.7)

	-- Yard fence
	for i = -3, 3 do
		P("FenceF"..i, Vector3.new(0.3,3,0.3), CFrame.new(o + Vector3.new(i*8, 1.5,-28)), "White", Enum.Material.Wood)
		P("FenceRail"..i, Vector3.new(8,0.3,0.3), CFrame.new(o + Vector3.new(i*8-4, 2.5,-28)), "White", Enum.Material.Wood)
	end

	-- Trees
	for _, tp in ipairs({Vector3.new(-28,0,-72), Vector3.new(28,0,-72), Vector3.new(-26,0,-88)}) do
		cylinder("TreeTrunk", 1.5, 10, CFrame.new(tp + Vector3.new(0,5,0)), "Reddish Brown")
		ball("TreeTop", 10, CFrame.new(tp + Vector3.new(0,13,0)), "Bright green")
	end

	-- Mailbox
	P("Mailbox",    Vector3.new(1,2,1), CFrame.new(o + Vector3.new(-14,1,-24)), "Bright blue", Enum.Material.Metal)
	P("MailboxTop", Vector3.new(1.5,1,1.5), CFrame.new(o + Vector3.new(-14,2.5,-24)), "Bright blue", Enum.Material.Metal)

	-- Ambient light
	light(o + Vector3.new(0,12,0), Color3.fromRGB(255,240,200), 2, 30)

	-- Cecil NPC stand (interaction point)
	local cecilStand = P("CecilNPC", Vector3.new(2,4,2), CFrame.new(o + Vector3.new(-16,2,-26)), "Dark stone grey", Enum.Material.Metal)
	cecilStand:SetAttribute("NPCName", "Cecil Stedman")

	local prompt             = Instance.new("ProximityPrompt")
	prompt.ActionText        = "Talk to Cecil"
	prompt.ObjectText        = "Cecil Stedman"
	prompt.KeyboardKeyCode   = Enum.KeyCode.F
	prompt.HoldDuration      = 0
	prompt.MaxActivationDistance = 12
	prompt.Parent            = cecilStand
end

-- ── GDA HQ ────────────────────────────────────────────────────────
-- Near (-80, 0, 120) to match Conquest spawn.

local GDA = Vector3.new(-80, 0, 120)

local function buildGDAHQ()
	local o = GDA

	-- Main building
	P("GDAMain",     Vector3.new(70,20,50), CFrame.new(o + Vector3.new(0,10,0)),   "Dark stone grey", Enum.Material.Concrete)
	P("GDAFacade",   Vector3.new(70,20,1),  CFrame.new(o + Vector3.new(0,10,-25.5)),"Medium stone grey",Enum.Material.SmoothPlastic)
	-- GDA stripe
	P("GDAStripe",   Vector3.new(70,2,1.5), CFrame.new(o + Vector3.new(0,10,-26)), "Bright blue", Enum.Material.Neon, 0.3)
	-- Windows grid (4 rows x 8 cols)
	for row = 0, 3 do
		for col = -3, 3 do
			P("Win"..row..col, Vector3.new(5,3,0.5),
				CFrame.new(o + Vector3.new(col*8, 6+row*5, -26.2)),
				"Cyan", Enum.Material.Neon, 0.5)
		end
	end
	-- Roof helipad
	P("Helipad",     Vector3.new(20,0.5,20), CFrame.new(o + Vector3.new(10,20.5,5)),  "Dark stone grey",Enum.Material.SmoothPlastic)
	P("HeliH",       Vector3.new(14,0.2,0.6),CFrame.new(o + Vector3.new(10,21,5)),    "Bright yellow",  Enum.Material.Neon)
	P("HeliV",       Vector3.new(0.6,0.2,14),CFrame.new(o + Vector3.new(10,21,5)),    "Bright yellow",  Enum.Material.Neon)

	-- Perimeter fence (posts + rails)
	for i = -4, 4 do
		P("FPostF"..i, Vector3.new(0.5,4,0.5), CFrame.new(o + Vector3.new(i*8,2,-35)), "Black", Enum.Material.Metal)
		P("FPostB"..i, Vector3.new(0.5,4,0.5), CFrame.new(o + Vector3.new(i*8,2, 35)), "Black", Enum.Material.Metal)
	end
	P("FRailF", Vector3.new(72,0.5,0.5), CFrame.new(o + Vector3.new(0,3.5,-35)), "Black", Enum.Material.Metal)
	P("FRailB", Vector3.new(72,0.5,0.5), CFrame.new(o + Vector3.new(0,3.5, 35)), "Black", Enum.Material.Metal)
	P("FRailL", Vector3.new(0.5,0.5,70), CFrame.new(o + Vector3.new(-36,3.5,0)),"Black", Enum.Material.Metal)
	P("FRailR", Vector3.new(0.5,0.5,70), CFrame.new(o + Vector3.new( 36,3.5,0)),"Black", Enum.Material.Metal)

	-- Flood lights
	light(o + Vector3.new(-30,22,0), Color3.fromRGB(200,220,255), 4, 50)
	light(o + Vector3.new( 30,22,0), Color3.fromRGB(200,220,255), 4, 50)

	-- Guard booth
	P("Booth", Vector3.new(4,5,4), CFrame.new(o + Vector3.new(0,2.5,-36)), "Dark stone grey", Enum.Material.Concrete)
	P("BoothRoof", Vector3.new(5,0.5,5), CFrame.new(o + Vector3.new(0,5.25,-36)), "Dark stone grey")
end

-- ── Viltrum Outpost ───────────────────────────────────────────────
-- Near (120, 40, 80) — elevated on pillars to match Thragg's high-ground.

local VO = Vector3.new(120, 40, 80)

local function buildViltrumOutpost()
	local o = VO

	-- Ground pillars (4 corners)
	for _, off in ipairs({Vector3.new(-24,0,-24),Vector3.new(24,0,-24),Vector3.new(-24,0,24),Vector3.new(24,0,24)}) do
		P("Pillar", Vector3.new(4,44,4), CFrame.new(o + off + Vector3.new(0,-22,0)), "Dark red", Enum.Material.Metal)
	end
	-- Cross braces
	P("BraceH1", Vector3.new(48,2,2), CFrame.new(o + Vector3.new(0,-20,-24)), "Dark red", Enum.Material.Metal)
	P("BraceH2", Vector3.new(48,2,2), CFrame.new(o + Vector3.new(0,-20, 24)), "Dark red", Enum.Material.Metal)
	P("BraceV1", Vector3.new(2,2,48), CFrame.new(o + Vector3.new(-24,-20,0)), "Dark red", Enum.Material.Metal)
	P("BraceV2", Vector3.new(2,2,48), CFrame.new(o + Vector3.new( 24,-20,0)), "Dark red", Enum.Material.Metal)

	-- Main platform
	P("Platform",   Vector3.new(60,3,60), CFrame.new(o + Vector3.new(0,0,0)),  "Dark red",  Enum.Material.Metal)
	P("PlatEdge",   Vector3.new(64,1,64), CFrame.new(o + Vector3.new(0,-1,0)), "Crimson",   Enum.Material.Metal)
	-- Alien energy core (glowing)
	P("Core",       Vector3.new(6,8,6),   CFrame.new(o + Vector3.new(0,5.5,0)), "Crimson",  Enum.Material.Neon, 0.3)
	P("CoreInner",  Vector3.new(4,10,4),  CFrame.new(o + Vector3.new(0,6,0)),   "Bright red",Enum.Material.Neon, 0.1)

	-- Core light
	local coreLight = Instance.new("PointLight")
	coreLight.Color      = Color3.fromRGB(255, 30, 30)
	coreLight.Brightness = 8
	coreLight.Range      = 80
	coreLight.Parent     = P("CoreGlow", Vector3.new(0.2,0.2,0.2), CFrame.new(o + Vector3.new(0,10,0)), "Bright red", Enum.Material.Neon)

	-- Battlements
	for i = -2, 2 do
		P("BattF"..i, Vector3.new(4,3,2), CFrame.new(o + Vector3.new(i*10,2.5,-31)), "Dark red", Enum.Material.Metal)
		P("BattB"..i, Vector3.new(4,3,2), CFrame.new(o + Vector3.new(i*10,2.5, 31)), "Dark red", Enum.Material.Metal)
		P("BattL"..i, Vector3.new(2,3,4), CFrame.new(o + Vector3.new(-31,2.5,i*10)), "Dark red", Enum.Material.Metal)
		P("BattR"..i, Vector3.new(2,3,4), CFrame.new(o + Vector3.new( 31,2.5,i*10)), "Dark red", Enum.Material.Metal)
	end

	-- Ramp access from ground
	wedge("Ramp", Vector3.new(8,40,20),
		CFrame.new(VO + Vector3.new(32,-20,0)) * CFrame.Angles(0, math.pi/2, 0),
		"Dark stone grey", Enum.Material.Concrete)
end

-- ── City block between zones ──────────────────────────────────────

local function buildCityBlock(center, w, h, d, color)
	P("Building", Vector3.new(w,h,d), CFrame.new(center + Vector3.new(0, h/2, 0)), color or "Medium stone grey", Enum.Material.Concrete)
	-- Windows
	for row = 0, math.floor(h/5)-1 do
		for col = -1, 1 do
			P("Win", Vector3.new(w*0.3, 3, 0.4),
				CFrame.new(center + Vector3.new(col*(w*0.35), 4+row*5, d/2+0.2)),
				"Cyan", Enum.Material.Neon, 0.5)
		end
	end
end

local function buildCityBlocks()
	-- Scatter buildings between the three zones
	local blocks = {
		{ Vector3.new(50, 0, 20),   20, 25, 15 },
		{ Vector3.new(-40,0,-20),   18, 20, 14 },
		{ Vector3.new(30, 0,-50),   16, 30, 12 },
		{ Vector3.new(-20,0, 60),   22, 18, 16 },
		{ Vector3.new(70, 0,-20),   14, 35, 14 },
		{ Vector3.new(0,  0, 50),   25, 22, 18 },
		{ Vector3.new(-60,0, 60),   16, 28, 12 },
		{ Vector3.new(60, 0, 40),   18, 24, 14 },
	}
	for _, b in ipairs(blocks) do
		buildCityBlock(b[1], b[2], b[3], b[4], "Medium stone grey")
	end
end

-- ── Conquest zone triggers ─────────────────────────────────────────
-- Invisible large Parts named exactly as Config.ZONE_NAMES.

local ZONE_CENTERS = {
	["Grayson Residence"] = GR  + Vector3.new(0, 1, 0),
	["GDA HQ"]            = GDA + Vector3.new(0, 1, 0),
	["Viltrum Outpost"]   = VO  + Vector3.new(0, 1, 0),
}

local ZONE_COLORS = {
	["Grayson Residence"] = Color3.fromRGB(80, 200, 80),
	["GDA HQ"]            = Color3.fromRGB(80, 120, 255),
	["Viltrum Outpost"]   = Color3.fromRGB(255, 60, 60),
}

local function buildZones()
	for _, zoneName in ipairs(Config.ZONE_NAMES) do
		local center = ZONE_CENTERS[zoneName]
		local zColor = ZONE_COLORS[zoneName]
		if not center then
			warn("[MapService] No center defined for zone:", zoneName)
			continue
		end

		-- Trigger part
		local trigger        = P(zoneName, Vector3.new(40, 1, 40),
			CFrame.new(center), "Medium stone grey", Enum.Material.SmoothPlastic, 1, zonesFolder)
		trigger.CanCollide   = false

		-- Visible floor marker (decal-like neon ring on ground)
		local marker         = P(zoneName.."_Marker", Vector3.new(42, 0.3, 42),
			CFrame.new(center + Vector3.new(0,-0.5,0)), "Medium stone grey", Enum.Material.SmoothPlastic, 0.6, mapFolder)
		marker.BrickColor    = BrickColor.new("Medium stone grey")
		marker.Color         = zColor
		marker.CastShadow    = false

		-- Zone name billboard above
		local bb             = Instance.new("BillboardGui")
		bb.Size              = UDim2.new(0, 260, 0, 40)
		bb.StudsOffset       = Vector3.new(0, 6, 0)
		bb.AlwaysOnTop       = false
		bb.Parent            = trigger

		local lbl            = Instance.new("TextLabel")
		lbl.Size             = UDim2.new(1,0,1,0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3       = zColor
		lbl.Font             = Enum.Font.GothamBold
		lbl.TextSize         = 17
		lbl.Text             = zoneName:upper()
		lbl.TextStrokeTransparency = 0.3
		lbl.Parent           = bb

		-- Ambient zone light
		local zLight = Instance.new("PointLight")
		zLight.Color      = zColor
		zLight.Brightness = 2
		zLight.Range      = 30
		zLight.Parent     = marker
	end
end

-- ── Spawn platform (neutral) ──────────────────────────────────────

local function buildSpawnArea()
	P("SpawnPad",  Vector3.new(40, 1, 40), CFrame.new(0, 0.5, 0), "White", Enum.Material.SmoothPlastic)
	P("SpawnRing", Vector3.new(42, 0.3, 42), CFrame.new(0,-0.2,0), "Bright yellow", Enum.Material.Neon, 0.4)

	local spawnLight = Instance.new("PointLight")
	spawnLight.Color      = Color3.fromRGB(255, 255, 150)
	spawnLight.Brightness = 3
	spawnLight.Range      = 40
	spawnLight.Parent     = P("SpawnLight", Vector3.new(0.2,0.2,0.2), CFrame.new(0,5,0), "Bright yellow", Enum.Material.Neon)
end

-- ── Public build ──────────────────────────────────────────────────

function MapService.Build()
	setupLighting()
	buildGround()
	buildSpawnArea()
	buildGraysonResidence()
	buildGDAHQ()
	buildViltrumOutpost()
	buildCityBlocks()
	buildZones()
	print("[MapService] World generated.")
end

return MapService
