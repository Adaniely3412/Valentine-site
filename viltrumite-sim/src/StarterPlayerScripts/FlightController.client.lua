-- Handles flight physics, input, and camera feel entirely on the client.

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Debris            = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")
local camera    = workspace.CurrentCamera

local Remotes       = ReplicatedStorage:WaitForChild("Remotes")
local Config        = require(ReplicatedStorage.Modules.Config)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)

-- ── State ────────────────────────────────────────────────────────
local isFlying        = false
local isSprinting     = false
local flightVel       = Vector3.zero
local targetVel       = Vector3.zero
local bodyGyro        = nil
local bodyVelocity    = nil

-- Sonic trail emitter reference
local sonicTrail      = nil

-- ── Speed ────────────────────────────────────────────────────────

local function getSpeed()
	local bl = BloodlineData.Get(character:GetAttribute("Bloodline") or "Human")
	local base = Config.BASE_FLIGHT_SPEED * bl.speedMult
	return isSprinting and base * Config.SPRINT_MULTIPLIER or base
end

-- ── Enable / disable ─────────────────────────────────────────────

local function enableFlight()
	isFlying = true
	humanoid.PlatformStand = true

	bodyGyro           = Instance.new("BodyGyro")
	bodyGyro.D         = 80
	bodyGyro.P         = 8000
	bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bodyGyro.CFrame    = rootPart.CFrame
	bodyGyro.Parent    = rootPart

	bodyVelocity           = Instance.new("BodyVelocity")
	bodyVelocity.Name      = "FlightVelocity"
	bodyVelocity.MaxForce  = Vector3.new(1e6, 1e6, 1e6)
	bodyVelocity.P         = 9000
	bodyVelocity.Velocity  = Vector3.zero
	bodyVelocity.Parent    = rootPart

	-- Sonic trail for sprint
	sonicTrail             = Instance.new("Trail")
	sonicTrail.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(150, 200, 255)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
	})
	sonicTrail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	sonicTrail.WidthScale  = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	sonicTrail.Lifetime    = 0.25
	sonicTrail.Enabled     = false
	local a0 = Instance.new("Attachment"); a0.Name = "TrailA0"; a0.Position = Vector3.new(0, 1, 0);  a0.Parent = rootPart
	local a1 = Instance.new("Attachment"); a1.Name = "TrailA1"; a1.Position = Vector3.new(0, -1, 0); a1.Parent = rootPart
	sonicTrail.Attachment0 = a0
	sonicTrail.Attachment1 = a1
	sonicTrail.Parent      = rootPart
end

local function disableFlight()
	isFlying  = false
	isSprinting = false
	humanoid.PlatformStand = false
	flightVel  = Vector3.zero
	targetVel  = Vector3.zero
	if bodyGyro     then bodyGyro:Destroy();     bodyGyro = nil     end
	if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	if sonicTrail   then sonicTrail:Destroy();   sonicTrail = nil   end
	-- Clean up trail attachments
	local a0 = rootPart:FindFirstChild("TrailA0")
	local a1 = rootPart:FindFirstChild("TrailA1")
	if a0 then a0:Destroy() end
	if a1 then a1:Destroy() end
end

-- ── Input ────────────────────────────────────────────────────────

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Z then
		Remotes.FlightToggle:FireServer()
	end
	if input.KeyCode == Enum.KeyCode.LeftShift and isFlying then
		isSprinting = true
		if sonicTrail then sonicTrail.Enabled = true end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = false
		if sonicTrail then sonicTrail.Enabled = false end
	end
end)

-- ── Server confirmation ──────────────────────────────────────────

Remotes.FlightStateChanged.OnClientEvent:Connect(function(state)
	if state then
		enableFlight()
	else
		disableFlight()
	end
end)

-- ── RenderStepped flight loop ────────────────────────────────────

RunService.RenderStepped:Connect(function(dt)
	if not isFlying or not rootPart.Parent then return end

	local camCF   = camera.CFrame
	local fwd     = Vector3.new(camCF.LookVector.X,  0, camCF.LookVector.Z)
	local right   = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
	if fwd.Magnitude  > 0 then fwd   = fwd.Unit   end
	if right.Magnitude > 0 then right = right.Unit end

	local dir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W)            then dir += fwd   end
	if UserInputService:IsKeyDown(Enum.KeyCode.S)            then dir -= fwd   end
	if UserInputService:IsKeyDown(Enum.KeyCode.A)            then dir -= right end
	if UserInputService:IsKeyDown(Enum.KeyCode.D)            then dir += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space)        then dir += Vector3.yAxis end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)  then dir -= Vector3.yAxis end

	local speed = getSpeed()
	targetVel = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero

	-- Smooth interpolation
	local alpha   = math.clamp(Config.FLIGHT_ACCELERATION * (isSprinting and 2 or 1), 0, 1)
	flightVel     = flightVel:Lerp(targetVel, alpha)

	if bodyVelocity then
		bodyVelocity.Velocity = flightVel
	end

	-- Orient character toward movement
	if flightVel.Magnitude > 4 and bodyGyro then
		bodyGyro.CFrame = CFrame.new(Vector3.zero, flightVel.Unit)
	end

	-- Send to server every ~5 frames for validation
	if math.random(5) == 1 then
		Remotes.FlightUpdate:FireServer(flightVel)
	end
end)

-- ── Respawn ──────────────────────────────────────────────────────

player.CharacterAdded:Connect(function(newChar)
	character   = newChar
	humanoid    = newChar:WaitForChild("Humanoid")
	rootPart    = newChar:WaitForChild("HumanoidRootPart")
	isFlying    = false
	isSprinting = false
	flightVel   = Vector3.zero
	targetVel   = Vector3.zero
	bodyGyro    = nil
	bodyVelocity = nil
	sonicTrail  = nil
end)
