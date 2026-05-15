-- Procedurally builds Empire City — the Invincible universe's primary setting.
-- Run once at server start. Delete this and use a Studio-built map when ready.

local MapService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config            = require(ReplicatedStorage.Modules.Config)

-- ── Folders ───────────────────────────────────────────────────────

local mapFolder = Instance.new("Folder")
mapFolder.Name   = "Map"
mapFolder.Parent = workspace

local zonesFolder = Instance.new("Folder")
zonesFolder.Name   = "Zones"
zonesFolder.Parent = workspace

-- ── Part helpers ──────────────────────────────────────────────────

local function P(name, size, cf, color, mat, trans, parent)
	local p = Instance.new("Part")
	p.Name         = name
	p.Size         = size
	p.CFrame       = cf
	p.Color        = typeof(color) == "Color3" and color or Color3.fromRGB(180,180,180)
	p.Material     = mat or Enum.Material.SmoothPlastic
	p.Transparency = trans or 0
	p.Anchored     = true
	p.CanCollide   = true
	p.CastShadow   = true
	p.Parent       = parent or mapFolder
	return p
end

local function W(name, size, cf, color, mat, parent)
	local w = Instance.new("WedgePart")
	w.Name     = name; w.Size = size; w.CFrame = cf
	w.Color    = typeof(color) == "Color3" and color or Color3.fromRGB(120,120,120)
	w.Material = mat or Enum.Material.SmoothPlastic
	w.Anchored = true; w.CanCollide = true
	w.Parent   = parent or mapFolder
	return w
end

local function sign(part, text, color, offsetY)
	local bb = Instance.new("BillboardGui")
	bb.Size         = UDim2.new(0, 220, 0, 46)
	bb.StudsOffset  = Vector3.new(0, offsetY or 4, 0)
	bb.AlwaysOnTop  = false
	bb.Adornee      = part
	bb.Parent       = part
	local lbl = Instance.new("TextLabel")
	lbl.Size                 = UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3           = color or Color3.new(1,1,1)
	lbl.TextStrokeTransparency = 0.3
	lbl.Font                 = Enum.Font.GothamBold
	lbl.TextSize             = 16
	lbl.Text                 = text
	lbl.Parent               = bb
end

local function pointLight(parent, color, brightness, range)
	local pl = Instance.new("PointLight")
	pl.Color = color; pl.Brightness = brightness; pl.Range = range
	pl.Parent = parent
end

local function neonTrim(part, color)
	local t = part:Clone()
	t.Name         = part.Name.."_Trim"
	t.Size         = Vector3.new(part.Size.X + 0.2, 0.4, part.Size.Z + 0.2)
	t.CFrame       = part.CFrame * CFrame.new(0, part.Size.Y / 2, 0)
	t.Color        = color
	t.Material     = Enum.Material.Neon
	t.Transparency = 0.3
	t.CastShadow   = false
	t.Parent       = mapFolder
end

-- ── Lighting ──────────────────────────────────────────────────────

local function setupLighting()
	local L = game:GetService("Lighting")
	L.Ambient        = Color3.fromRGB(70, 70, 90)
	L.Brightness     = 2
	L.GlobalShadows  = true
	L.OutdoorAmbient = Color3.fromRGB(110, 110, 140)
	L.ShadowSoftness = 0.5
	L.ClockTime      = 14.5

	local sky = Instance.new("Sky"); sky.Parent = L
	sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
	sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
	sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
	sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
	sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
	sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"

	local atm = Instance.new("Atmosphere"); atm.Parent = L
	atm.Density = 0.3; atm.Offset = 0.1
	atm.Color   = Color3.fromRGB(199,199,199)
	atm.Decay   = Color3.fromRGB(96,120,139)
	atm.Glare   = 0.15; atm.Haze = 1.5
end

-- ── Ground & roads ────────────────────────────────────────────────

local function buildGround()
	-- Remove Studio default Baseplate so terrain shows
	local bp = workspace:FindFirstChild("Baseplate")
	if bp then bp:Destroy() end

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain:FillBlock(CFrame.new(0,-4,0), Vector3.new(1400,8,1400), Enum.Material.Grass)
		-- Main roads
		terrain:FillBlock(CFrame.new(0,0,0),   Vector3.new(14,0.5,600), Enum.Material.Asphalt) -- N-S
		terrain:FillBlock(CFrame.new(0,0,0),   Vector3.new(600,0.5,14), Enum.Material.Asphalt) -- E-W
		terrain:FillBlock(CFrame.new(60,0,0),  Vector3.new(14,0.5,400), Enum.Material.Asphalt)
		terrain:FillBlock(CFrame.new(-60,0,0), Vector3.new(14,0.5,400), Enum.Material.Asphalt)
		terrain:FillBlock(CFrame.new(0,0,60),  Vector3.new(400,0.5,14), Enum.Material.Asphalt)
		terrain:FillBlock(CFrame.new(0,0,-60), Vector3.new(400,0.5,14), Enum.Material.Asphalt)
		-- Rocky hill under Viltrum Outpost
		terrain:FillBlock(CFrame.new(130,15,90), Vector3.new(110,34,110), Enum.Material.Rock)
	end

	-- Sidewalk pavement strips alongside main roads
	P("SidewalkN1", Vector3.new(4,0.4,600), CFrame.new( 8,0.2,0),  Color3.fromRGB(160,160,155), Enum.Material.Concrete)
	P("SidewalkN2", Vector3.new(4,0.4,600), CFrame.new(-8,0.2,0),  Color3.fromRGB(160,160,155), Enum.Material.Concrete)
	P("SidewalkE1", Vector3.new(600,0.4,4), CFrame.new(0,0.2, 8),  Color3.fromRGB(160,160,155), Enum.Material.Concrete)
	P("SidewalkE2", Vector3.new(600,0.4,4), CFrame.new(0,0.2,-8),  Color3.fromRGB(160,160,155), Enum.Material.Concrete)
end

-- ── Street lights ─────────────────────────────────────────────────

local function streetLights()
	local positions = {
		Vector3.new(12,0,40), Vector3.new(12,0,-40), Vector3.new(12,0,80), Vector3.new(12,0,-80),
		Vector3.new(-12,0,40),Vector3.new(-12,0,-40),Vector3.new(-12,0,80),Vector3.new(-12,0,-80),
		Vector3.new(40,0,12), Vector3.new(-40,0,12), Vector3.new(80,0,12), Vector3.new(-80,0,12),
		Vector3.new(40,0,-12),Vector3.new(-40,0,-12),Vector3.new(80,0,-12),Vector3.new(-80,0,-12),
	}
	for _, pos in ipairs(positions) do
		local pole  = P("Pole",  Vector3.new(0.4,12,0.4), CFrame.new(pos+Vector3.new(0,6,0)),
			Color3.fromRGB(60,60,60), Enum.Material.Metal)
		local head  = P("LHead", Vector3.new(3,0.6,1.5),  CFrame.new(pos+Vector3.new(1.5,12.3,0)),
			Color3.fromRGB(60,60,60), Enum.Material.Metal)
		local bulb  = P("Bulb",  Vector3.new(1,0.5,1),    CFrame.new(pos+Vector3.new(1.5,11.9,0)),
			Color3.fromRGB(255,245,200), Enum.Material.Neon, 0.2)
		pointLight(bulb, Color3.fromRGB(255,240,180), 1.5, 28)
	end
end

-- ── SPAWN — Central plaza ─────────────────────────────────────────

local function buildSpawnPlaza()
	-- Plaza slab
	P("Plaza",     Vector3.new(50,0.6,50), CFrame.new(0,0.3,0),  Color3.fromRGB(200,195,185), Enum.Material.Concrete)
	P("PlazaRing", Vector3.new(52,0.3,52), CFrame.new(0,0.1,0),  Color3.fromRGB(100,150,255), Enum.Material.Neon, 0.5)

	-- Hero monument — stylised Invincible symbol (stacked cylinder + wedge)
	P("MonBase",   Vector3.new(4,4,4),     CFrame.new(0,2.3,0),  Color3.fromRGB(30,30,30), Enum.Material.Granite)
	P("MonPillar", Vector3.new(1.5,8,1.5), CFrame.new(0,7.3,0),  Color3.fromRGB(50,50,60), Enum.Material.Metal)
	P("MonFigure", Vector3.new(3,5,2),     CFrame.new(0,14.5,0), Color3.fromRGB(30,80,200), Enum.Material.SmoothPlastic)
	P("MonCape",   Vector3.new(1,4,3),     CFrame.new(0,13,-1),  Color3.fromRGB(255,220,0), Enum.Material.SmoothPlastic)

	local monument = P("MonLight", Vector3.new(0.2,0.2,0.2), CFrame.new(0,17,0),
		Color3.fromRGB(30,80,200), Enum.Material.Neon)
	pointLight(monument, Color3.fromRGB(80,120,255), 4, 50)
	sign(monument, "EMPIRE CITY", Color3.fromRGB(200,220,255), 6)

	-- Benches
	for _, x in ipairs({-18, 18}) do
		P("Bench"..x, Vector3.new(6,1,1.5), CFrame.new(x,0.8,0), Color3.fromRGB(100,70,40), Enum.Material.Wood)
	end
end

-- ── LANDMARK 1 — Grayson Residence (conquest zone) ───────────────
-- "A nice suburban house on a nice suburban street.
--  Nolan Grayson lived here for 20 years. Built a life. Had a family.
--  Then murdered the Guardians of the Globe." — Cecil Stedman

local GR = Vector3.new(0, 0, -130)

local function buildGraysonResidence()
	local o = GR

	-- Suburban street / driveway
	P("Driveway", Vector3.new(12,0.3,24), CFrame.new(o+Vector3.new(8,0.15,-10)),
		Color3.fromRGB(80,80,80), Enum.Material.Concrete)

	-- Foundation
	P("Foundation", Vector3.new(46,1,36), CFrame.new(o+Vector3.new(0,0.5,0)),
		Color3.fromRGB(220,210,200), Enum.Material.Concrete)

	-- Lower floor walls
	P("WallF1", Vector3.new(46,10,1),  CFrame.new(o+Vector3.new(0,5.5,-17.5)), Color3.fromRGB(240,235,225), Enum.Material.SmoothPlastic)
	P("WallB1", Vector3.new(46,10,1),  CFrame.new(o+Vector3.new(0,5.5, 17.5)), Color3.fromRGB(240,235,225), Enum.Material.SmoothPlastic)
	P("WallL1", Vector3.new(1,10,36),  CFrame.new(o+Vector3.new(-22.5,5.5,0)), Color3.fromRGB(240,235,225), Enum.Material.SmoothPlastic)
	P("WallR1", Vector3.new(1,10,36),  CFrame.new(o+Vector3.new( 22.5,5.5,0)), Color3.fromRGB(240,235,225), Enum.Material.SmoothPlastic)

	-- Roof (slight gable suggestion)
	P("Roof",   Vector3.new(50,1.5,40), CFrame.new(o+Vector3.new(0,11.2,0)),   Color3.fromRGB(80,50,40),  Enum.Material.Brick)
	W("GableL", Vector3.new(50,5,0.5),  CFrame.new(o+Vector3.new(0,13.5,-20)) * CFrame.Angles(0,math.pi/2,0), Color3.fromRGB(80,50,40), Enum.Material.Brick)
	W("GableR", Vector3.new(50,5,0.5),  CFrame.new(o+Vector3.new(0,13.5, 20)) * CFrame.Angles(0,-math.pi/2,0), Color3.fromRGB(80,50,40), Enum.Material.Brick)

	-- Front door
	P("Door",     Vector3.new(4,7,0.6),  CFrame.new(o+Vector3.new(0,3.5,-18)),  Color3.fromRGB(90,50,30), Enum.Material.Wood)
	P("Doorframe",Vector3.new(5,8,0.5),  CFrame.new(o+Vector3.new(0,4,-18.3)),  Color3.fromRGB(220,215,205))

	-- Windows (dark frosted)
	P("WinFL",  Vector3.new(7,4.5,0.4), CFrame.new(o+Vector3.new(-10,6,-18)),   Color3.fromRGB(100,140,180), Enum.Material.Neon, 0.6)
	P("WinFR",  Vector3.new(7,4.5,0.4), CFrame.new(o+Vector3.new( 10,6,-18)),   Color3.fromRGB(100,140,180), Enum.Material.Neon, 0.6)
	P("WinSL",  Vector3.new(0.4,4,8),   CFrame.new(o+Vector3.new(-22.8,6, 5)),  Color3.fromRGB(100,140,180), Enum.Material.Neon, 0.6)
	P("WinSR",  Vector3.new(0.4,4,8),   CFrame.new(o+Vector3.new( 22.8,6, 5)),  Color3.fromRGB(100,140,180), Enum.Material.Neon, 0.6)

	-- Front porch light
	local pLight = P("PorchLight", Vector3.new(0.5,0.5,0.5), CFrame.new(o+Vector3.new(0,10,-18.5)), Color3.fromRGB(255,220,150), Enum.Material.Neon)
	pointLight(pLight, Color3.fromRGB(255,230,180), 2, 20)

	-- White picket fence
	for i = -3, 3 do
		P("FP"..i, Vector3.new(0.3,3.5,0.3), CFrame.new(o+Vector3.new(i*8,1.75,-30)), Color3.fromRGB(245,245,245), Enum.Material.Wood)
		if i < 3 then
			P("FR"..i, Vector3.new(8,0.3,0.3),   CFrame.new(o+Vector3.new(i*8+4,2.5,-30)), Color3.fromRGB(245,245,245), Enum.Material.Wood)
			P("FR2"..i,Vector3.new(8,0.3,0.3),   CFrame.new(o+Vector3.new(i*8+4,1.2,-30)), Color3.fromRGB(245,245,245), Enum.Material.Wood)
		end
	end

	-- Trees in yard
	for _, tp in ipairs({Vector3.new(-26,0,-120), Vector3.new(26,0,-120), Vector3.new(-24,0,-140), Vector3.new(24,0,-142)}) do
		local tr = P("TreeTrunk", Vector3.new(1.5,12,1.5), CFrame.new(tp+Vector3.new(0,6,0)), Color3.fromRGB(90,55,30), Enum.Material.Wood)
		P("TreeLeaves", Vector3.new(12,10,12), CFrame.new(tp+Vector3.new(0,16,0)), Color3.fromRGB(50,120,40), Enum.Material.Grass)
	end

	-- Mailbox
	P("Mailbox",    Vector3.new(1.2,2,1.2), CFrame.new(o+Vector3.new(-15,1,-29)), Color3.fromRGB(30,60,180), Enum.Material.Metal)
	P("MailboxTop", Vector3.new(1.8,1,1.8), CFrame.new(o+Vector3.new(-15,2.5,-29)), Color3.fromRGB(30,60,180), Enum.Material.Metal)

	-- Cecil NPC stand
	local cecilStand = P("CecilNPC", Vector3.new(2,4,2), CFrame.new(o+Vector3.new(-18,2,-28)),
		Color3.fromRGB(40,40,50), Enum.Material.Metal)
	cecilStand:SetAttribute("NPCName", "Cecil Stedman")
	local prompt           = Instance.new("ProximityPrompt")
	prompt.ActionText      = "Talk to Cecil"
	prompt.ObjectText      = "Cecil Stedman — GDA Director"
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.HoldDuration    = 0
	prompt.MaxActivationDistance = 12
	prompt.Parent          = cecilStand
	sign(cecilStand, "CECIL STEDMAN  GDA", Color3.fromRGB(180,220,255), 5)

	-- House name sign
	local houseSgn = P("HouseSgn", Vector3.new(6,1,0.3), CFrame.new(o+Vector3.new(0,1,-31)), Color3.fromRGB(240,235,225))
	sign(houseSgn, "GRAYSON RESIDENCE", Color3.fromRGB(255,255,255), 3)
end

-- ── LANDMARK 2 — GDA Headquarters (conquest zone) ────────────────
-- The Global Defense Agency — Cecil's domain.

local GDA = Vector3.new(-90, 0, 100)

local function buildGDAHQ()
	local o = GDA

	-- Main facility block
	P("GDAMain",   Vector3.new(80,22,60),  CFrame.new(o+Vector3.new(0,11,0)),     Color3.fromRGB(50,55,65), Enum.Material.Concrete)
	P("GDAFront",  Vector3.new(80,22,1),   CFrame.new(o+Vector3.new(0,11,-30.5)), Color3.fromRGB(60,65,80), Enum.Material.SmoothPlastic)
	-- GDA Blue stripe branding
	P("GDAStripe1",Vector3.new(80,3,1.5),  CFrame.new(o+Vector3.new(0,11,-31)),   Color3.fromRGB(0,100,220), Enum.Material.Neon, 0.25)
	P("GDAStripe2",Vector3.new(80,1,1.5),  CFrame.new(o+Vector3.new(0,18,-31)),   Color3.fromRGB(0,80,180), Enum.Material.Neon, 0.4)

	-- Window grid (5 rows × 8 cols)
	for row = 0, 4 do
		for col = -3, 3 do
			P("GWin"..row..col, Vector3.new(6,3.5,0.5),
				CFrame.new(o+Vector3.new(col*9, 4.5+row*4, -31.2)),
				Color3.fromRGB(120,180,255), Enum.Material.Neon, 0.45)
		end
	end

	-- Side wings
	P("WingL",  Vector3.new(20,14,60), CFrame.new(o+Vector3.new(-50,7,0)),  Color3.fromRGB(45,50,60), Enum.Material.Concrete)
	P("WingR",  Vector3.new(20,14,60), CFrame.new(o+Vector3.new( 50,7,0)),  Color3.fromRGB(45,50,60), Enum.Material.Concrete)

	-- Roof / helipad
	P("Helipad", Vector3.new(24,0.6,24),  CFrame.new(o+Vector3.new(0,22.3,5)),    Color3.fromRGB(40,40,45), Enum.Material.Metal)
	P("HeliH",   Vector3.new(16,0.3,0.8), CFrame.new(o+Vector3.new(0,22.7,5)),    Color3.fromRGB(255,200,0), Enum.Material.Neon)
	P("HeliV",   Vector3.new(0.8,0.3,16), CFrame.new(o+Vector3.new(0,22.7,5)),    Color3.fromRGB(255,200,0), Enum.Material.Neon)
	P("HeliCirc",Vector3.new(18,0.2,18),  CFrame.new(o+Vector3.new(0,22.6,5)),    Color3.fromRGB(255,200,0), Enum.Material.Neon, 0.5)

	-- Roof antenna / comms array
	P("Antenna", Vector3.new(0.8,10,0.8), CFrame.new(o+Vector3.new(30,27,0)),     Color3.fromRGB(80,80,90), Enum.Material.Metal)
	P("AntDish", Vector3.new(5,5,0.5),    CFrame.new(o+Vector3.new(30,31,0)),     Color3.fromRGB(180,180,190), Enum.Material.Metal)

	-- Flood lights
	for _, x in ipairs({-55, 55}) do
		local fl = P("FloodPole"..x, Vector3.new(0.8,16,0.8), CFrame.new(o+Vector3.new(x,8,30)), Color3.fromRGB(60,60,65), Enum.Material.Metal)
		local fb = P("FloodBulb"..x, Vector3.new(4,1.5,2),    CFrame.new(o+Vector3.new(x,16.5,29)), Color3.fromRGB(220,230,255), Enum.Material.Neon, 0.1)
		pointLight(fb, Color3.fromRGB(200,220,255), 5, 70)
	end

	-- Perimeter security fence
	for i = -5, 5 do
		P("FPostF"..i, Vector3.new(0.6,5,0.6), CFrame.new(o+Vector3.new(i*10,2.5,-40)), Color3.fromRGB(30,30,35), Enum.Material.Metal)
		P("FPostB"..i, Vector3.new(0.6,5,0.6), CFrame.new(o+Vector3.new(i*10,2.5, 40)), Color3.fromRGB(30,30,35), Enum.Material.Metal)
	end
	P("FRailF",  Vector3.new(102,0.6,0.6), CFrame.new(o+Vector3.new(0,4,-40)),  Color3.fromRGB(30,30,35), Enum.Material.Metal)
	P("FRailB",  Vector3.new(102,0.6,0.6), CFrame.new(o+Vector3.new(0,4, 40)),  Color3.fromRGB(30,30,35), Enum.Material.Metal)
	P("FRailL",  Vector3.new(0.6,0.6,82),  CFrame.new(o+Vector3.new(-51,4,0)),  Color3.fromRGB(30,30,35), Enum.Material.Metal)
	P("FRailR",  Vector3.new(0.6,0.6,82),  CFrame.new(o+Vector3.new( 51,4,0)),  Color3.fromRGB(30,30,35), Enum.Material.Metal)

	-- Guard booth + barrier
	P("Booth",     Vector3.new(5,6,5),   CFrame.new(o+Vector3.new(6,3,-41)),  Color3.fromRGB(50,55,65), Enum.Material.Concrete)
	P("BoothRoof", Vector3.new(6,0.6,6), CFrame.new(o+Vector3.new(6,6.3,-41)),Color3.fromRGB(40,40,50), Enum.Material.Metal)
	P("Barrier",   Vector3.new(10,1,0.5),CFrame.new(o+Vector3.new(-3,1,-41)), Color3.fromRGB(255,80,0),  Enum.Material.Neon, 0.2)

	-- GDA sign on building
	local gdaSign = P("GDASgn", Vector3.new(40,6,0.5), CFrame.new(o+Vector3.new(0,19,-31.5)),
		Color3.fromRGB(10,10,20), Enum.Material.SmoothPlastic)
	sign(gdaSign, "GLOBAL DEFENSE AGENCY", Color3.fromRGB(0,160,255), 2)

	-- Underground bunker entrance hint (ramp going down behind building)
	W("BunkerRamp", Vector3.new(8,3,12),
		CFrame.new(o+Vector3.new(0,-1.5,42)) * CFrame.Angles(math.rad(-14),0,0),
		Color3.fromRGB(40,40,45), Enum.Material.Concrete)
	P("BunkerDoor", Vector3.new(8,6,0.5), CFrame.new(o+Vector3.new(0,3,48.5)),
		Color3.fromRGB(20,20,25), Enum.Material.Metal)
	sign(P("BunkerSgn", Vector3.new(8,2,0.5), CFrame.new(o+Vector3.new(0,6.5,48.5)),
		Color3.fromRGB(20,20,25)), "AUTHORIZED PERSONNEL ONLY", Color3.fromRGB(255,60,60), 2)
end

-- ── LANDMARK 3 — Viltrum Outpost (conquest zone) ─────────────────
-- An advance fortification established by Viltrumite scouts.

local VO = Vector3.new(130, 38, 90)

local function buildViltrumOutpost()
	local o = VO

	-- Pillars
	for _, off in ipairs({Vector3.new(-28,0,-28),Vector3.new(28,0,-28),Vector3.new(-28,0,28),Vector3.new(28,0,28)}) do
		P("Pillar", Vector3.new(5,42,5), CFrame.new(o+off+Vector3.new(0,-21,0)), Color3.fromRGB(120,20,20), Enum.Material.Metal)
		-- diagonal brace
		P("Brace",  Vector3.new(3,3,40), CFrame.new(o+off+Vector3.new(0,-10, off.Z > 0 and -14 or 14)),
			Color3.fromRGB(100,15,15), Enum.Material.Metal)
	end

	-- Cross braces
	P("BH1", Vector3.new(56,2,2), CFrame.new(o+Vector3.new(0,-22,-28)), Color3.fromRGB(120,20,20), Enum.Material.Metal)
	P("BH2", Vector3.new(56,2,2), CFrame.new(o+Vector3.new(0,-22, 28)), Color3.fromRGB(120,20,20), Enum.Material.Metal)
	P("BV1", Vector3.new(2,2,56), CFrame.new(o+Vector3.new(-28,-22,0)), Color3.fromRGB(120,20,20), Enum.Material.Metal)
	P("BV2", Vector3.new(2,2,56), CFrame.new(o+Vector3.new( 28,-22,0)), Color3.fromRGB(120,20,20), Enum.Material.Metal)

	-- Main platform deck
	P("Deck",    Vector3.new(68,3,68),  CFrame.new(o+Vector3.new(0,0,0)),   Color3.fromRGB(100,15,15),  Enum.Material.Metal)
	P("DeckEdge",Vector3.new(72,1,72),  CFrame.new(o+Vector3.new(0,-1.5,0)),Color3.fromRGB(150,20,20),  Enum.Material.Metal)
	neonTrim(P("DeckNeon",Vector3.new(68,0.5,68),CFrame.new(o+Vector3.new(0,1.5,0)),Color3.fromRGB(200,0,0),Enum.Material.Neon,0.3), Color3.fromRGB(255,0,0))

	-- Alien energy core
	P("Core",      Vector3.new(7,10,7),  CFrame.new(o+Vector3.new(0,6.5,0)), Color3.fromRGB(180,0,0),   Enum.Material.Neon, 0.25)
	P("CoreInner", Vector3.new(4,12,4),  CFrame.new(o+Vector3.new(0,7,0)),   Color3.fromRGB(255,30,0),  Enum.Material.Neon, 0.1)
	P("CoreBase",  Vector3.new(10,2,10), CFrame.new(o+Vector3.new(0,2,0)),   Color3.fromRGB(80,10,10),  Enum.Material.Metal)
	local coreGlow = P("CoreGlow", Vector3.new(0.5,0.5,0.5), CFrame.new(o+Vector3.new(0,13,0)),
		Color3.fromRGB(255,0,0), Enum.Material.Neon)
	pointLight(coreGlow, Color3.fromRGB(255,30,0), 10, 100)
	sign(coreGlow, "VILTRUM OUTPOST", Color3.fromRGB(255,80,80), 8)

	-- Battlements
	for i = -2, 2 do
		for _, side in ipairs({"F","B"}) do
			local z = side=="F" and -35 or 35
			P("Batt"..side..i, Vector3.new(5,4,3), CFrame.new(o+Vector3.new(i*12,2.5,z)), Color3.fromRGB(100,15,15), Enum.Material.Metal)
		end
		for _, side in ipairs({"L","R"}) do
			local x = side=="L" and -35 or 35
			P("Batt"..side..i, Vector3.new(3,4,5), CFrame.new(o+Vector3.new(x,2.5,i*12)), Color3.fromRGB(100,15,15), Enum.Material.Metal)
		end
	end

	-- Ramp access
	W("Ramp", Vector3.new(8,38,18),
		CFrame.new(VO+Vector3.new(38,-19,0)) * CFrame.Angles(0,math.pi/2,0),
		Color3.fromRGB(60,60,70), Enum.Material.Concrete)

	-- Viltrumite banner flags
	for _, x in ipairs({-34, 34}) do
		P("FlagPole"..x, Vector3.new(0.5,12,0.5), CFrame.new(o+Vector3.new(x,7.5,-35)), Color3.fromRGB(80,80,90), Enum.Material.Metal)
		P("Flag"..x,     Vector3.new(0.3,5,8),     CFrame.new(o+Vector3.new(x+4,12,-35)),Color3.fromRGB(180,0,0),  Enum.Material.SmoothPlastic)
	end
end

-- ── LANDMARK 4 — Burger Mart ──────────────────────────────────────
-- "Mark Grayson worked here before saving the world. It closed at 10pm."

local function buildBurgerMart()
	local o = Vector3.new(40, 0, 30)

	P("BMFloor", Vector3.new(22,0.5,18), CFrame.new(o+Vector3.new(0,0.25,0)),     Color3.fromRGB(180,170,160), Enum.Material.Concrete)
	P("BMWallF", Vector3.new(22,8,1),    CFrame.new(o+Vector3.new(0,4.5,-8.5)),   Color3.fromRGB(220,50,30),   Enum.Material.SmoothPlastic)
	P("BMWallB", Vector3.new(22,8,1),    CFrame.new(o+Vector3.new(0,4.5, 8.5)),   Color3.fromRGB(200,200,200), Enum.Material.SmoothPlastic)
	P("BMWallL", Vector3.new(1,8,18),    CFrame.new(o+Vector3.new(-10.5,4.5,0)),  Color3.fromRGB(220,50,30),   Enum.Material.SmoothPlastic)
	P("BMWallR", Vector3.new(1,8,18),    CFrame.new(o+Vector3.new( 10.5,4.5,0)),  Color3.fromRGB(220,50,30),   Enum.Material.SmoothPlastic)
	P("BMRoof",  Vector3.new(24,1,20),   CFrame.new(o+Vector3.new(0,9,0)),        Color3.fromRGB(180,30,15),   Enum.Material.SmoothPlastic)

	-- Window
	P("BMWin",   Vector3.new(10,4,0.5),  CFrame.new(o+Vector3.new(-4,5,-9)),      Color3.fromRGB(200,230,255), Enum.Material.Neon, 0.55)
	-- Door
	P("BMDoor",  Vector3.new(4,6,0.5),   CFrame.new(o+Vector3.new(5,3.5,-9)),     Color3.fromRGB(120,80,50),   Enum.Material.Wood)

	-- Yellow sign stripe
	P("BMSign",  Vector3.new(22,2.5,0.5),CFrame.new(o+Vector3.new(0,7.5,-9.2)),   Color3.fromRGB(255,200,0),   Enum.Material.Neon, 0.1)
	sign(P("BMSignFace", Vector3.new(14,2,0.5), CFrame.new(o+Vector3.new(0,7.5,-9.5)),
		Color3.fromRGB(180,0,0)), "BURGER MART", Color3.fromRGB(255,230,0), 1)

	-- Outdoor seating
	for _, pos in ipairs({Vector3.new(-6,0,-13), Vector3.new(0,0,-13), Vector3.new(6,0,-13)}) do
		P("Table", Vector3.new(3,1,3), CFrame.new(o+pos+Vector3.new(0,0.7,0)), Color3.fromRGB(200,160,100), Enum.Material.Wood)
	end
end

-- ── LANDMARK 5 — Reginald Vel Johnson High School ────────────────
-- Mark Grayson's school. Normal high school. Occasionally attacked by supervillains.

local function buildHighSchool()
	local o = Vector3.new(-40, 0, -90)

	-- Main building
	P("SchoolMain",  Vector3.new(70,16,40), CFrame.new(o+Vector3.new(0,8,0)),    Color3.fromRGB(180,140,100), Enum.Material.Brick)
	P("SchoolFront", Vector3.new(70,16,1),  CFrame.new(o+Vector3.new(0,8,-20.5)),Color3.fromRGB(160,120,80),  Enum.Material.Brick)
	-- Columns
	for _, x in ipairs({-25, -15, -5, 5, 15, 25}) do
		P("Col"..x,  Vector3.new(1.5,16,1.5), CFrame.new(o+Vector3.new(x,8,-21)), Color3.fromRGB(220,210,195), Enum.Material.Concrete)
	end
	-- Roof
	P("SchoolRoof",  Vector3.new(74,1.5,44), CFrame.new(o+Vector3.new(0,16.7,0)), Color3.fromRGB(100,80,60), Enum.Material.Concrete)

	-- Windows (2 rows)
	for row = 0, 1 do
		for col = -3, 3 do
			P("SchWin"..row..col, Vector3.new(6,3.5,0.5),
				CFrame.new(o+Vector3.new(col*8, 5+row*7, -21.3)),
				Color3.fromRGB(160,200,230), Enum.Material.Neon, 0.5)
		end
	end

	-- Entrance canopy
	P("Canopy",  Vector3.new(16,0.8,6),  CFrame.new(o+Vector3.new(0,14,-24)),   Color3.fromRGB(120,100,70), Enum.Material.Concrete)

	-- Front doors
	P("SchDoor1",Vector3.new(3,7,0.5),   CFrame.new(o+Vector3.new(-2,3.5,-21.3)),Color3.fromRGB(60,50,40),  Enum.Material.Wood)
	P("SchDoor2",Vector3.new(3,7,0.5),   CFrame.new(o+Vector3.new( 2,3.5,-21.3)),Color3.fromRGB(60,50,40),  Enum.Material.Wood)

	-- Football field
	P("Field",   Vector3.new(80,0.4,50), CFrame.new(o+Vector3.new(0,0.2,55)),    Color3.fromRGB(50,140,50),  Enum.Material.Grass)
	P("FieldLine1",Vector3.new(80,0.1,0.5),CFrame.new(o+Vector3.new(0,0.45,55)), Color3.fromRGB(255,255,255))
	-- Goal posts
	for _, side in ipairs({-1, 1}) do
		P("GoalBase"..side,Vector3.new(0.8,6,0.8),  CFrame.new(o+Vector3.new(side*40,3,55)),   Color3.fromRGB(255,200,0),Enum.Material.Metal)
		P("GoalBar"..side, Vector3.new(12,0.8,0.8),  CFrame.new(o+Vector3.new(side*40,8,55)),   Color3.fromRGB(255,200,0),Enum.Material.Metal)
		P("GoalL"..side,   Vector3.new(0.8,4,0.8),   CFrame.new(o+Vector3.new(side*40-6,10,55)),Color3.fromRGB(255,200,0),Enum.Material.Metal)
		P("GoalR"..side,   Vector3.new(0.8,4,0.8),   CFrame.new(o+Vector3.new(side*40+6,10,55)),Color3.fromRGB(255,200,0),Enum.Material.Metal)
	end

	-- School sign
	local sgnBase = P("SchoolSign",Vector3.new(30,3,0.5),CFrame.new(o+Vector3.new(0,3,-28)),
		Color3.fromRGB(160,120,80), Enum.Material.Brick)
	sign(sgnBase, "REGINALD VEL JOHNSON HIGH", Color3.fromRGB(255,240,200), 4)
end

-- ── Downtown skyscrapers ──────────────────────────────────────────

local function buildDowntown()
	local buildings = {
		-- { center, w, h, d, color, neonColor }
		{ Vector3.new( 35, 0,  25), 18, 50, 14, Color3.fromRGB(60,70,90),   Color3.fromRGB(100,150,255) },
		{ Vector3.new(-35, 0,  25), 16, 40, 14, Color3.fromRGB(70,65,60),   Color3.fromRGB(255,180,0)   },
		{ Vector3.new( 35, 0, -25), 14, 60, 12, Color3.fromRGB(50,60,80),   Color3.fromRGB(0,200,255)   },
		{ Vector3.new(-35, 0, -25), 18, 35, 16, Color3.fromRGB(80,75,70),   Color3.fromRGB(255,100,100) },
		{ Vector3.new( 80, 0,  25), 20, 45, 18, Color3.fromRGB(55,60,75),   Color3.fromRGB(200,255,200) },
		{ Vector3.new(-80, 0, -20), 18, 38, 14, Color3.fromRGB(65,60,55),   Color3.fromRGB(255,200,100) },
		{ Vector3.new( 80, 0, -25), 14, 55, 12, Color3.fromRGB(45,55,70),   Color3.fromRGB(100,200,255) },
		{ Vector3.new(-80, 0,  25), 22, 30, 18, Color3.fromRGB(75,70,65),   Color3.fromRGB(255,150,200) },
		-- Empire Tower (tallest landmark)
		{ Vector3.new( 0,  0,  35), 20, 80, 20, Color3.fromRGB(40,45,60),   Color3.fromRGB(100,100,255) },
	}

	for i, b in ipairs(buildings) do
		local ctr, w, h, d, col, neon = b[1], b[2], b[3], b[4], b[5], b[6]
		local bld = P("Building"..i, Vector3.new(w,h,d), CFrame.new(ctr+Vector3.new(0,h/2,0)), col, Enum.Material.SmoothPlastic)

		-- Setback top floors
		local topH = math.floor(h*0.2)
		P("BTop"..i, Vector3.new(w-4,topH,d-4), CFrame.new(ctr+Vector3.new(0, h+topH/2, 0)), col, Enum.Material.SmoothPlastic)

		-- Window grid
		local rows = math.floor(h/5)
		for row = 0, math.min(rows-1, 8) do
			for col2 = -1, 1 do
				P("BW"..i..row..col2, Vector3.new(w*0.28, 2.5, 0.4),
					CFrame.new(ctr + Vector3.new(col2*(w*0.34), 4+row*5, d/2+0.2)),
					Color3.fromRGB(150,200,240), Enum.Material.Neon, 0.45)
			end
		end

		-- Neon top trim
		local topPart = P("BNeon"..i, Vector3.new(w+0.4,0.5,d+0.4),
			CFrame.new(ctr+Vector3.new(0,h+0.25,0)), neon, Enum.Material.Neon, 0.2)
		pointLight(topPart, neon, 3, 40)
	end

	-- Empire Tower sign
	local empSign = P("EmpireTowerSgn", Vector3.new(16,2,0.5),
		CFrame.new(Vector3.new(0, 82, 35+11)),
		Color3.fromRGB(20,20,30), Enum.Material.SmoothPlastic)
	sign(empSign, "EMPIRE TOWER", Color3.fromRGB(200,200,255), 3)
end

-- ── Conquest zone triggers ────────────────────────────────────────

local ZONE_CENTERS = {
	["Grayson Residence"] = GR  + Vector3.new(0, 1, 8),
	["GDA HQ"]            = GDA + Vector3.new(0, 1, 0),
	["Viltrum Outpost"]   = VO  + Vector3.new(0, 1, 0),
}
local ZONE_COLORS = {
	["Grayson Residence"] = Color3.fromRGB(80, 200, 80),
	["GDA HQ"]            = Color3.fromRGB(50, 120, 255),
	["Viltrum Outpost"]   = Color3.fromRGB(255, 50, 50),
}

local function buildZones()
	for _, zoneName in ipairs(Config.ZONE_NAMES) do
		local center = ZONE_CENTERS[zoneName]
		local zColor = ZONE_COLORS[zoneName]
		if not center then continue end

		-- Invisible trigger volume
		local trigger      = P(zoneName, Vector3.new(50,1,50),
			CFrame.new(center), Color3.fromRGB(128,128,128), Enum.Material.SmoothPlastic, 1, zonesFolder)
		trigger.CanCollide = false

		-- Ground ring marker
		local marker = P(zoneName.."_Marker", Vector3.new(52,0.3,52),
			CFrame.new(center+Vector3.new(0,-0.5,0)), zColor, Enum.Material.Neon, 0.65, mapFolder)
		marker.CastShadow = false
		pointLight(marker, zColor, 1.5, 35)
	end
end

-- ── Public ────────────────────────────────────────────────────────

function MapService.Build()
	setupLighting()
	buildGround()
	streetLights()
	buildSpawnPlaza()
	buildGraysonResidence()
	buildGDAHQ()
	buildViltrumOutpost()
	buildBurgerMart()
	buildHighSchool()
	buildDowntown()
	buildZones()
	print("[MapService] Empire City generated.")
end

return MapService
