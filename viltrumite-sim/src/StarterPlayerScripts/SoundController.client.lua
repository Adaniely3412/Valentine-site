-- Plays 3D positional sounds on the client in response to server events.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")

local Remotes    = ReplicatedStorage:WaitForChild("Remotes")
local SoundData  = require(ReplicatedStorage.Modules.SoundData)

-- ── Sound pool ────────────────────────────────────────────────────
-- Reuse Sound instances attached to a workspace Part for 3D audio.

local soundPart = Instance.new("Part")
soundPart.Anchored    = true
soundPart.CanCollide  = false
soundPart.Transparency = 1
soundPart.Size        = Vector3.new(1, 1, 1)
soundPart.Name        = "SoundEmitter"
soundPart.Parent      = workspace

local function playSound(soundName, position)
	local id, volume, rolloff = SoundData.Get(soundName)
	if not id then return end

	-- Create a temporary Part at position for 3D audio
	local emitter       = Instance.new("Part")
	emitter.Anchored    = true
	emitter.CanCollide  = false
	emitter.Transparency = 1
	emitter.Size        = Vector3.new(1, 1, 1)
	emitter.Position    = position or Vector3.new(0, 0, 0)
	emitter.Parent      = workspace

	local sound              = Instance.new("Sound")
	sound.SoundId            = id
	sound.Volume             = volume or 1.0
	sound.RollOffMaxDistance = rolloff or 40
	sound.RollOffMinDistance = 5
	sound.RollOffMode        = Enum.RollOffMode.InverseTapered
	sound.Parent             = emitter
	sound:Play()

	-- Clean up after sound finishes (max 8 seconds)
	Debris:AddItem(emitter, math.max(sound.TimeLength > 0 and sound.TimeLength or 2, 0.5) + 0.2)
end

-- ── Remote listener ───────────────────────────────────────────────

Remotes.PlaySound.OnClientEvent:Connect(function(soundName, position)
	if typeof(position) ~= "Vector3" then position = Vector3.zero end
	playSound(soundName, position)
end)

-- Hit effects already carry sfx name — play it locally too
Remotes.HitEffect.OnClientEvent:Connect(function(targetChar, _gore, sfx)
	if not sfx then return end
	local root = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	if root then
		playSound(sfx, root.Position)
	end
end)
