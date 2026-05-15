-- Server bootstrap. Wires all services, remotes, and game-loop together.

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

-- Wait for RemoteSetup to finish
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
assert(Remotes, "[Main] Remotes folder never appeared — check RemoteSetup script.")

local PlayerDataService = require(script.Parent.Services.PlayerDataService)
local CombatService     = require(script.Parent.Services.CombatService)
local FlightService     = require(script.Parent.Services.FlightService)
local ConquestService   = require(script.Parent.Services.ConquestService)

local Config        = require(ReplicatedStorage.Modules.Config)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)

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
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character, data)
	end)
	-- If character already exists (Studio Play Mode edge-case)
	if player.Character then
		onCharacterAdded(player, player.Character, data)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerDataService.Remove(player)
	FlightService.OnPlayerRemoving(player)
end)

-- ── Remote bindings ──────────────────────────────────────────────

Remotes.CombatHit.OnServerEvent:Connect(function(player, targetCharacter, moveName, comboCount)
	CombatService.ProcessHit(player, targetCharacter, moveName, comboCount)
end)

Remotes.CombatBlock.OnServerEvent:Connect(function(player, isBlocking)
	CombatService.ProcessBlock(player, isBlocking)
end)

Remotes.UseMove.OnServerEvent:Connect(function(player, moveName, targetCharacter)
	CombatService.ProcessHit(player, targetCharacter, moveName, 1)
end)

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

-- ── Game loops ───────────────────────────────────────────────────

ConquestService.Start()

RunService.Heartbeat:Connect(function(dt)
	ConquestService.Tick(dt)
end)

print("[ViltrumiteSimulator] Server v" .. Config.VERSION .. " online.")
