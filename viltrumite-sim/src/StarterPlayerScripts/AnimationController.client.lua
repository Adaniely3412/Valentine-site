-- Plays animations on the local character by watching the CurrentAnim attribute.
-- Also handles locomotion blending (idle/walk/run/fly) automatically.

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local animator  = humanoid:WaitForChild("Animator") or Instance.new("Animator", humanoid)

local Remotes       = ReplicatedStorage:WaitForChild("Remotes")
local AnimationData = require(ReplicatedStorage.Modules.AnimationData)

-- Track loaded animation instances and their tracks
local loadedAnims  = {}  -- [animName] = Animation instance
local loadedTracks = {}  -- [animName] = AnimationTrack
local currentLocoTrack = nil

-- ── Load & play ───────────────────────────────────────────────────

local function getTrack(animName)
	if loadedTracks[animName] then return loadedTracks[animName] end
	local id, priority = AnimationData.Get(animName)
	if not id then return nil end

	local anim          = Instance.new("Animation")
	anim.AnimationId    = id
	loadedAnims[animName] = anim

	local track         = animator:LoadAnimation(anim)
	track.Priority      = priority or Enum.AnimationPriority.Action
	loadedTracks[animName] = track
	return track
end

local function play(animName, fadeTime)
	local track = getTrack(animName)
	if not track then return end
	if track.IsPlaying then return end
	track:Play(fadeTime or 0.1)
end

local function stop(animName, fadeTime)
	local track = loadedTracks[animName]
	if track and track.IsPlaying then
		track:Stop(fadeTime or 0.2)
	end
end

-- ── Locomotion auto-blend ─────────────────────────────────────────

local prevLoco = ""

local function updateLocomotion()
	local isFlying = character:GetAttribute("IsFlying")
	local speed    = humanoid.MoveDirection.Magnitude > 0.1
		and humanoid.WalkSpeed or 0

	local loco
	if isFlying then
		loco = speed > 1 and "FlyForward" or "FlyIdle"
	elseif speed > 1 then
		loco = humanoid.WalkSpeed > 20 and "Run" or "Walk"
	else
		loco = "Idle"
	end

	if loco ~= prevLoco then
		if prevLoco ~= "" then stop(prevLoco, 0.15) end
		play(loco, 0.15)
		prevLoco = loco
	end
end

-- ── Combat animation trigger ──────────────────────────────────────

local lastAnimName = ""

character:GetAttributeChangedSignal("CurrentAnim"):Connect(function()
	local animName = character:GetAttribute("CurrentAnim")
	if not animName or animName == "" or animName == lastAnimName then return end
	lastAnimName = animName

	local track = getTrack(animName)
	if not track then return end

	-- Stop previous combat track if different
	for name, t in pairs(loadedTracks) do
		if t.IsPlaying and name ~= animName and t.Priority == Enum.AnimationPriority.Action4 then
			t:Stop(0.1)
		end
	end

	track:Play(0.05)
	-- Auto-clear attribute so same anim can retrigger
	task.delay(track.Length > 0 and track.Length or 0.5, function()
		if character:GetAttribute("CurrentAnim") == animName then
			character:SetAttribute("CurrentAnim", "")
		end
	end)
end)

-- ── Server-triggered animations (e.g. boss hit reactions) ─────────

Remotes.PlayAnimation.OnClientEvent:Connect(function(targetChar, animName)
	if targetChar ~= character then return end  -- only handle our own character
	local track = getTrack(animName)
	if track then track:Play(0.05) end
end)

-- ── RunService loop ───────────────────────────────────────────────

RunService.Heartbeat:Connect(updateLocomotion)

-- ── Respawn ──────────────────────────────────────────────────────

player.CharacterAdded:Connect(function(newChar)
	character    = newChar
	humanoid     = newChar:WaitForChild("Humanoid")
	animator     = humanoid:WaitForChild("Animator") or Instance.new("Animator", humanoid)
	loadedAnims  = {}
	loadedTracks = {}
	prevLoco     = ""
	lastAnimName = ""
end)
