local CombatService = {}

local Players           = game:GetService("Players")
local Debris            = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config      = require(ReplicatedStorage.Modules.Config)
local MovesetData = require(ReplicatedStorage.Modules.MovesetData)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)

local specialCDs = {}  -- [userId_moveName] = true while on cooldown
local ragdolled  = {}  -- [character] = true

local function R()
	return ReplicatedStorage:WaitForChild("Remotes", 10)
end

local function charToPlayer(character)
	return Players:GetPlayerFromCharacter(character)
end

-- ── Damage ────────────────────────────────────────────────────────

local function calcDamage(raw, attacker, target)
	-- Blocking
	if target:GetAttribute("IsBlocking") then raw = raw * 0.3 end

	-- Attacker PL scaling: +50% per 100k PL
	local aPL = attacker:GetAttribute("PowerLevel") or 0
	raw = raw * (1 + (aPL / 100000) * 0.5)

	-- Target bloodline durability
	local tBL = target:GetAttribute("Bloodline") or "Human"
	raw = raw / BloodlineData.Get(tBL).durabilityMult

	return math.max(1, math.floor(raw))
end

local function applyDamage(target, damage)
	local hum = target:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return 0 end
	hum:TakeDamage(damage)
	return damage
end

-- ── Knockback ────────────────────────────────────────────────────

local function applyKnockback(target, attackerRoot, kbData)
	local root = target:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local dir    = (root.Position - attackerRoot.Position)
	local flatDir = Vector3.new(dir.X, 0, dir.Z)
	if flatDir.Magnitude < 0.01 then flatDir = attackerRoot.CFrame.LookVector end
	flatDir = flatDir.Unit

	local world = Vector3.new(
		flatDir.X * kbData.Z + kbData.X,
		kbData.Y,
		flatDir.Z * kbData.Z + kbData.Z
	)

	local bv        = Instance.new("BodyVelocity")
	bv.Velocity     = world
	bv.MaxForce     = Vector3.new(1e5, 1e5, 1e5)
	bv.P            = 1e4
	bv.Parent       = root
	Debris:AddItem(bv, 0.35)
end

-- ── Hitstun ───────────────────────────────────────────────────────

local function applyHitstun(target, duration)
	local hum = target:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	target:SetAttribute("InHitstun", true)
	hum.WalkSpeed  = 0
	hum.JumpPower  = 0
	task.delay(duration, function()
		if target and target.Parent then
			target:SetAttribute("InHitstun", false)
			hum.WalkSpeed  = 16 * (BloodlineData.Get(target:GetAttribute("Bloodline") or "Human").speedMult)
			hum.JumpPower  = 50
		end
	end)
end

-- ── Ragdoll ───────────────────────────────────────────────────────

local function triggerRagdoll(character, duration)
	if ragdolled[character] then return end
	ragdolled[character] = true
	local remotes = R()
	for _, p in ipairs(Players:GetPlayers()) do
		remotes.Ragdoll:FireClient(p, character, true)
	end
	task.delay(duration, function()
		ragdolled[character] = nil
		if character and character.Parent then
			for _, p in ipairs(Players:GetPlayers()) do
				remotes.Ragdoll:FireClient(p, character, false)
			end
		end
	end)
end

-- ── Validation ───────────────────────────────────────────────────

local function validate(attacker, target, move)
	if not (attacker and target and attacker.Parent and target.Parent) then return false end
	local aR = attacker:FindFirstChild("HumanoidRootPart")
	local tR = target:FindFirstChild("HumanoidRootPart")
	if not (aR and tR) then return false end
	if (aR.Position - tR.Position).Magnitude > move.range * 2.2 then return false end  -- 2.2× lag buffer
	local hum = target:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	return true
end

-- ── Screen shake broadcast ────────────────────────────────────────

local function broadcastShake(origin, intensity)
	local remotes = R()
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		if c then
			local root = c:FindFirstChild("HumanoidRootPart")
			if root then
				local d = (root.Position - origin).Magnitude
				if d < 120 then
					remotes.ScreenShake:FireClient(p, intensity * (1 - d / 120))
				end
			end
		end
	end
end

-- ── Public API ───────────────────────────────────────────────────

function CombatService.ProcessHit(attackerPlayer, targetCharacter, moveName, comboCount)
	local attacker = attackerPlayer.Character
	if not attacker then return end

	local move
	if moveName == "M1" then
		move = MovesetData.GetComboMove(comboCount or 1)
	else
		move = MovesetData.Get(moveName)
	end
	if not move then return end

	if not validate(attacker, targetCharacter, move) then return end

	-- Special / ultimate cooldown gate
	if move.type == "special" or move.type == "ultimate" then
		local key = attackerPlayer.UserId .. "_" .. moveName
		if specialCDs[key] then return end
		specialCDs[key] = true
		task.delay(move.cooldown, function() specialCDs[key] = nil end)
	end

	local aRoot = attacker:FindFirstChild("HumanoidRootPart")

	local dmg = calcDamage(move.damage, attacker, targetCharacter)
	applyDamage(targetCharacter, dmg)
	applyKnockback(targetCharacter, aRoot, move.knockback)
	applyHitstun(targetCharacter, move.hitstun)

	if move.type == "combo_finisher" then
		triggerRagdoll(targetCharacter, 2.2)
	end
	if move.screenShake then
		broadcastShake(aRoot.Position, 1.0)
	end

	-- Hit effects on all clients
	local remotes = R()
	for _, p in ipairs(Players:GetPlayers()) do
		remotes.HitEffect:FireClient(p, targetCharacter, move.gore, move.sfx)
	end

	-- Progression
	local PlayerDataService = require(script.Parent.PlayerDataService)
	PlayerDataService.AddXP(attackerPlayer, Config.XP_PER_HIT * (comboCount or 1))

	local hum = targetCharacter:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then
		PlayerDataService.AddXP(attackerPlayer, Config.XP_PER_KILL)
		local atkData = PlayerDataService.Get(attackerPlayer)
		if atkData then atkData.kills = atkData.kills + 1 end
		local defPlayer = charToPlayer(targetCharacter)
		if defPlayer then
			local defData = PlayerDataService.Get(defPlayer)
			if defData then defData.deaths = defData.deaths + 1 end
		end
	end
end

function CombatService.ProcessBlock(player, isBlocking)
	local c = player.Character
	if c then c:SetAttribute("IsBlocking", isBlocking) end
end

return CombatService
