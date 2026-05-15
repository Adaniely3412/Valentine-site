-- Handles combat animations triggered by the CurrentAnim attribute.
-- Roblox's built-in Animate LocalScript owns idle / walk / run / jump / fall.
-- This controller only takes over for combat moves and flight state.

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local animator  = humanoid:WaitForChild("Animator")

local Remotes       = ReplicatedStorage:WaitForChild("Remotes")
local AnimationData = require(ReplicatedStorage.Modules.AnimationData)

local loadedAnims  = {}
local loadedTracks = {}

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

local function stop(animName, fadeTime)
	local track = loadedTracks[animName]
	if track and track.IsPlaying then
		track:Stop(fadeTime or 0.2)
	end
end

-- ── Flight — disable/enable the default Animate script ───────────

local defaultAnimate = nil

local function setFlight(on)
	if not defaultAnimate then
		defaultAnimate = character:FindFirstChild("Animate")
	end
	if defaultAnimate then
		defaultAnimate.Disabled = on
	end
	if on then
		local t = getTrack("FlyIdle")
		if t and not t.IsPlaying then t:Play(0.2) end
	else
		stop("FlyIdle", 0.2)
		stop("FlyForward", 0.2)
		if defaultAnimate then defaultAnimate.Disabled = false end
	end
end

character:GetAttributeChangedSignal("IsFlying"):Connect(function()
	setFlight(character:GetAttribute("IsFlying") == true)
end)

-- ── Flight forward vs idle blend ─────────────────────────────────

RunService.Heartbeat:Connect(function()
	if not character:GetAttribute("IsFlying") then return end
	local moving = humanoid.MoveDirection.Magnitude > 0.1
	if moving then
		stop("FlyIdle", 0.15)
		local t = getTrack("FlyForward")
		if t and not t.IsPlaying then t:Play(0.15) end
	else
		stop("FlyForward", 0.15)
		local t = getTrack("FlyIdle")
		if t and not t.IsPlaying then t:Play(0.15) end
	end
end)

-- ── Combat animation trigger (server sets CurrentAnim attribute) ──

local lastAnimName = ""

character:GetAttributeChangedSignal("CurrentAnim"):Connect(function()
	local animName = character:GetAttribute("CurrentAnim")
	if not animName or animName == "" or animName == lastAnimName then return end
	lastAnimName = animName

	local track = getTrack(animName)
	if not track then return end

	-- Stop any other Action4 tracks
	for name, t in pairs(loadedTracks) do
		if t.IsPlaying and name ~= animName and t.Priority == Enum.AnimationPriority.Action4 then
			t:Stop(0.1)
		end
	end

	track:Play(0.05)
	task.delay(track.Length > 0 and track.Length or 0.5, function()
		if character:GetAttribute("CurrentAnim") == animName then
			character:SetAttribute("CurrentAnim", "")
		end
	end)
end)

-- ── Server-triggered animations ───────────────────────────────────

Remotes.PlayAnimation.OnClientEvent:Connect(function(targetChar, animName)
	if targetChar ~= character then return end
	local track = getTrack(animName)
	if track then track:Play(0.05) end
end)

-- ── Respawn ───────────────────────────────────────────────────────

player.CharacterAdded:Connect(function(newChar)
	character    = newChar
	humanoid     = newChar:WaitForChild("Humanoid")
	animator     = humanoid:WaitForChild("Animator")
	loadedAnims  = {}
	loadedTracks = {}
	lastAnimName = ""
	defaultAnimate = nil

	-- Re-wire attribute signals on new character
	newChar:GetAttributeChangedSignal("IsFlying"):Connect(function()
		setFlight(newChar:GetAttribute("IsFlying") == true)
	end)

	newChar:GetAttributeChangedSignal("CurrentAnim"):Connect(function()
		local animName = newChar:GetAttribute("CurrentAnim")
		if not animName or animName == "" or animName == lastAnimName then return end
		lastAnimName = animName
		local track = getTrack(animName)
		if not track then return end
		for name, t in pairs(loadedTracks) do
			if t.IsPlaying and name ~= animName and t.Priority == Enum.AnimationPriority.Action4 then
				t:Stop(0.1)
			end
		end
		track:Play(0.05)
		task.delay(track.Length > 0 and track.Length or 0.5, function()
			if newChar:GetAttribute("CurrentAnim") == animName then
				newChar:SetAttribute("CurrentAnim", "")
			end
		end)
	end)
end)
