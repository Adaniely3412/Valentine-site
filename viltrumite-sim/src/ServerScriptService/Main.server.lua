-- Server bootstrap. Wires all services, remotes, and game-loop together.

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

-- Wait for RemoteSetup to finish
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
assert(Remotes, "[Main] Remotes folder never appeared — check RemoteSetup script.")

local PlayerDataService  = require(script.Parent.Services.PlayerDataService)
local CombatService      = require(script.Parent.Services.CombatService)
local FlightService      = require(script.Parent.Services.FlightService)
local ConquestService    = require(script.Parent.Services.ConquestService)
local BossService        = require(script.Parent.Services.BossService)
local DestructionService = require(script.Parent.Services.DestructionService)
local QuestService       = require(script.Parent.Services.QuestService)
local LeaderboardService = require(script.Parent.Services.LeaderboardService)
local GuildService       = require(script.Parent.Services.GuildService)
local MapService         = require(script.Parent.Services.MapService)

local Config        = require(ReplicatedStorage.Modules.Config)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)
local CosmeticData  = require(ReplicatedStorage.Modules.CosmeticData)

-- Build the world first
MapService.Build()

-- ── Player lifecycle ─────────────────────────────────────────────

local function onCharacterAdded(player, character, data)
	local hum  = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	local bl    = BloodlineData.Get(data.bloodline)
	local tier, tierIdx = PlayerDataService.GetTier(data.powerLevel)

	-- Stamp attributes (visible to client)
	character:SetAttribute("Bloodline",   data.bloodline)
	character:SetAttribute("PowerLevel",  data.powerLevel)
	character:SetAttribute("Faction",     data.faction or "Earth Defenders")
	character:SetAttribute("IsFlying",    false)
	character:SetAttribute("InHitstun",   false)
	character:SetAttribute("IsBlocking",  false)
	character:SetAttribute("ComboCount",  0)
	character:SetAttribute("NotifMsg",    "")

	-- Scale stats
	hum.MaxHealth  = Config.BASE_HEALTH * bl.durabilityMult * (1 + tierIdx * 0.5)
	hum.Health     = hum.MaxHealth
	hum.WalkSpeed  = 16 * bl.speedMult
	hum.JumpPower  = 50

	-- Passive regeneration
	task.spawn(function()
		while character.Parent and hum.Health > 0 do
			task.wait(1)
			if hum.Health < hum.MaxHealth then
				hum.Health = math.min(hum.MaxHealth, hum.Health + bl.regenRate)
			end
		end
	end)

	-- On death cleanup
	hum.Died:Connect(function()
		FlightService.OnPlayerRemoving(player)
		local bv = root:FindFirstChild("FlightVelocity")
		if bv then bv:Destroy() end
	end)

	-- Bloodline reveal (slight delay for client to finish loading)
	task.delay(0.6, function()
		Remotes.BloodlineAssigned:FireClient(player, data.bloodline, bl)
		Remotes.StatsUpdated:FireClient(player, data)
	end)
end

Players.PlayerAdded:Connect(function(player)
	local data = PlayerDataService.Load(player)
	QuestService.Load(player)
	LeaderboardService.OnPlayerAdded(player)
	GuildService.OnPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character, data)
	end)
	if player.Character then
		onCharacterAdded(player, player.Character, data)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerDataService.Remove(player)
	QuestService.Remove(player)
	LeaderboardService.OnPlayerRemoving(player)
	GuildService.OnPlayerRemoving(player)
	FlightService.OnPlayerRemoving(player)
end)

-- ── Remote bindings ──────────────────────────────────────────────

Remotes.CombatHit.OnServerEvent:Connect(function(player, targetCharacter, moveName, comboCount)
	CombatService.ProcessHit(player, targetCharacter, moveName, comboCount)
end)

Remotes.CombatBlock.OnServerEvent:Connect(function(player, isBlocking)
	CombatService.ProcessBlock(player, isBlocking)
end)

-- UseMove handled below with destruction hook

Remotes.FlightToggle.OnServerEvent:Connect(function(player)
	FlightService.ToggleFlight(player)
end)

Remotes.FlightUpdate.OnServerEvent:Connect(function(player, velocity)
	if typeof(velocity) == "Vector3" then
		FlightService.UpdateFlight(player, velocity)
	end
end)

Remotes.GetPlayerData.OnServerInvoke = function(player)
	return PlayerDataService.Get(player)
end

-- ── Conquest zone touch detection ────────────────────────────────
-- Expects Part instances in Workspace (or Workspace.Zones) whose Name
-- matches one of Config.ZONE_NAMES.  Create these in Studio!

task.spawn(function()
	task.wait(5)
	local zonesFolder = Workspace:FindFirstChild("Zones") or Workspace

	for _, zoneName in ipairs(Config.ZONE_NAMES) do
		local part = zonesFolder:FindFirstChild(zoneName)
		if not part then
			warn("[Main] Zone part not found in Workspace:", zoneName,
				"— Create a Part named '" .. zoneName .. "' in Workspace or a 'Zones' folder.")
		else
			part.Touched:Connect(function(hit)
				local p = Players:GetPlayerFromCharacter(hit.Parent)
				if p then ConquestService.PlayerEntered(zoneName, p) end
			end)
			part.TouchEnded:Connect(function(hit)
				local p = Players:GetPlayerFromCharacter(hit.Parent)
				if p then ConquestService.PlayerLeft(zoneName, p) end
			end)
		end
	end
end)

-- ── Quest remotes ────────────────────────────────────────────────

Remotes.AcceptQuest.OnServerEvent:Connect(function(player, questId)
	QuestService.AssignQuest(player, questId)
end)

-- Cecil ProximityPrompt (MapService places it on the CecilNPC part)
workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("ProximityPrompt") and desc.ActionText == "Talk to Cecil" then
		desc.Triggered:Connect(function(triggeringPlayer)
			QuestService.OpenDialog(triggeringPlayer)
		end)
	end
end)
-- Handle already-added prompts (race condition guard)
for _, desc in ipairs(workspace:GetDescendants()) do
	if desc:IsA("ProximityPrompt") and desc.ActionText == "Talk to Cecil" then
		desc.Triggered:Connect(function(triggeringPlayer)
			QuestService.OpenDialog(triggeringPlayer)
		end)
	end
end

-- Hook quest progress into combat events
local _origHit = CombatService.ProcessHit
CombatService.ProcessHit = function(attackerPlayer, ...)
	_origHit(attackerPlayer, ...)
	QuestService.OnHit(attackerPlayer, 1)
end

-- Hook boss deaths for quest progress
Remotes.BossDefeated.OnServerEvent = nil  -- BossService fires this event; listen here
local _bossDiedConn
_bossDiedConn = Remotes.BossDefeated.OnClientEvent  -- server-side: catch via BossDefeated broadcast
-- Actually hook via a BindableEvent pattern inside BossService is cleaner;
-- instead we expose a callback table:
-- BossService fires Remotes.BossDefeated:FireAllClients(bossName, killerName)
-- We intercept by listening for the leaderboard / quest bridge on the same frame.
-- Since BossDefeated is server→all, we hook the zone capture and PL change instead:

Remotes.PowerLevelUp.OnServerEvent = nil  -- already a server event from StatsUpdated
-- PL quest hook fires from PlayerDataService.AddPowerLevel → already calls StatsUpdated.
-- We override AddPowerLevel to also call QuestService:
local _origAddPL = PlayerDataService.AddPowerLevel
PlayerDataService.AddPowerLevel = function(player, amount)
	_origAddPL(player, amount)
	local data = PlayerDataService.Get(player)
	if data then QuestService.OnPLChanged(player, data.powerLevel) end
end

-- Zone capture → quest check
Remotes.ZoneCapture.OnServerEvent = nil  -- ZoneCapture is server→all; hook ConquestService
local _origZoneCapture = ConquestService.PlayerEntered
-- Count controlled zones after each tick; fire QuestService
local prevControlCounts = {}
local _origTick = ConquestService.Tick
ConquestService.Tick = function(dt)
	_origTick(dt)
	local zones   = ConquestService.GetZones()
	local counts  = { ["Viltrumite Empire"]=0, ["Earth Defenders"]=0 }
	for _, z in pairs(zones) do
		if z.controller then counts[z.controller] = counts[z.controller] + 1 end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		local faction = (p.Character and p.Character:GetAttribute("Faction")) or "Earth Defenders"
		local held    = counts[faction] or 0
		if held ~= (prevControlCounts[p.UserId] or -1) then
			prevControlCounts[p.UserId] = held
			QuestService.OnZonesCaptured(p, held)
		end
	end
end

-- ── Leaderboard remotes ───────────────────────────────────────────

Remotes.GetLeaderboard.OnServerEvent:Connect(function(player)
	LeaderboardService.Broadcast()
end)

Remotes.GetSessionBoard.OnServerEvent:Connect(function(player)
	local board = LeaderboardService.GetSessionBoard()
	Remotes.SessionBoard:FireClient(player, board)
end)

-- ── Guild remotes ─────────────────────────────────────────────────

Remotes.CreateGuild.OnServerEvent:Connect(function(player, name, faction)
	GuildService.Create(player, name, faction)
end)

Remotes.JoinGuild.OnServerEvent:Connect(function(player, name)
	GuildService.Join(player, name)
end)

Remotes.LeaveGuild.OnServerEvent:Connect(function(player)
	GuildService.Leave(player)
end)

-- ── Cosmetics ────────────────────────────────────────────────────

Remotes.EquipCosmetic.OnServerEvent:Connect(function(player, costumeName)
	local data = PlayerDataService.Get(player)
	if not data then return end
	if not CosmeticData.IsUnlocked(costumeName, data) then
		Remotes.ShowNotification:FireClient(player, "Costume not unlocked yet!", "error")
		return
	end
	data.equippedCostume = costumeName
	-- Apply body colors to character
	local char = player.Character
	if char then
		local costume = CosmeticData.Get(costumeName)
		if costume then
			local function setColor(partName, colorName)
				local p = char:FindFirstChild(partName)
				if p and p:IsA("BasePart") then
					p.BrickColor = BrickColor.new(colorName)
				end
			end
			local bc = costume.bodyColor
			setColor("Torso",      bc.torso)
			setColor("Left Arm",   bc.limbs)
			setColor("Right Arm",  bc.limbs)
			setColor("Left Leg",   bc.limbs)
			setColor("Right Leg",  bc.limbs)
			setColor("Head",       bc.head)
			char:SetAttribute("EquippedCostume", costumeName)
		end
	end
	Remotes.CostumeChanged:FireAllClients(player, costumeName)
end)

Remotes.GetOwnedCosmetics.OnServerInvoke = function(player)
	local data = PlayerDataService.Get(player)
	if not data then return {} end
	local result = {}
	for name in pairs(CosmeticData.Costumes) do
		result[name] = CosmeticData.IsUnlocked(name, data)
	end
	return result
end

-- ── EarthShatter destruction hook ────────────────────────────────
-- CombatService fires this when an EarthShatter move lands.
Remotes.UseMove.OnServerEvent:Connect(function(player, moveName, targetCharacter)
	CombatService.ProcessHit(player, targetCharacter, moveName, 1)
	if moveName == "EarthShatter" then
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				DestructionService.OnImpact(root.Position, 20, 60)
			end
		end
	end
end)

-- ── Game loops ───────────────────────────────────────────────────

ConquestService.Start()

RunService.Heartbeat:Connect(function(dt)
	ConquestService.Tick(dt)
end)

-- Spawn all bosses after world loads
task.delay(8, function()
	BossService.SpawnAll()
end)

print("[ViltrumiteSimulator] Server v" .. Config.VERSION .. " online.")
