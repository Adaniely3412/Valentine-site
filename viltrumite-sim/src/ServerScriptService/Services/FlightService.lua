local FlightService = {}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config        = require(ReplicatedStorage.Modules.Config)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)

local flying = {}  -- [userId] = bool

local function R()
	return ReplicatedStorage:WaitForChild("Remotes", 10)
end

function FlightService.ToggleFlight(player)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local pl = char:GetAttribute("PowerLevel") or 0
	if pl < Config.MIN_FLIGHT_PL then
		R().ShowNotification:FireClient(player,
			"Need Power Level " .. Config.MIN_FLIGHT_PL .. " to fly!", "error")
		return
	end

	local state = not (flying[player.UserId] or false)
	flying[player.UserId] = state
	char:SetAttribute("IsFlying", state)

	hum.PlatformStand = state
	if not state then
		-- Kill flight velocity on land
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local bv = root:FindFirstChild("FlightVelocity")
			if bv then bv:Destroy() end
		end
	end

	R().FlightStateChanged:FireClient(player, state)
end

function FlightService.UpdateFlight(player, velocity)
	if not flying[player.UserId] then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Anti-cheat speed cap
	local bl = BloodlineData.Get(char:GetAttribute("Bloodline") or "Human")
	local maxSpeed = Config.BASE_FLIGHT_SPEED * bl.speedMult * Config.SPRINT_MULTIPLIER
	if velocity.Magnitude > maxSpeed * 1.6 then
		velocity = velocity.Unit * maxSpeed
	end

	local bv = root:FindFirstChild("FlightVelocity")
	if bv and bv:IsA("BodyVelocity") then
		bv.Velocity = velocity
	end
end

function FlightService.IsFlying(player)
	return flying[player.UserId] or false
end

function FlightService.OnPlayerRemoving(player)
	flying[player.UserId] = nil
end

return FlightService
