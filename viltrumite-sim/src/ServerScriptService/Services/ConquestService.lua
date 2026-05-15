local ConquestService = {}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Modules.Config)

local zones = {}
local scores = { ["Viltrumite Empire"] = 0, ["Earth Defenders"] = 0 }
local active = false

local function R() return ReplicatedStorage:WaitForChild("Remotes", 10) end

local function fireAll(name, ...)
	local remotes = R()
	local ev = remotes:FindFirstChild(name)
	if ev then ev:FireAllClients(...) end
end

-- Init zones
for _, name in ipairs(Config.ZONE_NAMES) do
	zones[name] = {
		name          = name,
		controller    = nil,
		progress      = 0,
		capturingTeam = nil,
		occupants     = { ["Viltrumite Empire"] = 0, ["Earth Defenders"] = 0 },
	}
end

function ConquestService.Start()
	active = true
	for t in pairs(scores) do scores[t] = 0 end
	for _, z in pairs(zones) do
		z.controller    = nil
		z.progress      = 0
		z.capturingTeam = nil
		z.occupants     = { ["Viltrumite Empire"] = 0, ["Earth Defenders"] = 0 }
	end
	fireAll("ScoreUpdate", scores)
end

function ConquestService.PlayerEntered(zoneName, player)
	local z = zones[zoneName]
	if not z then return end
	local faction = player.Character and player.Character:GetAttribute("Faction")
	if not faction then return end
	z.occupants[faction] = (z.occupants[faction] or 0) + 1
end

function ConquestService.PlayerLeft(zoneName, player)
	local z = zones[zoneName]
	if not z then return end
	local faction = player.Character and player.Character:GetAttribute("Faction")
	if not faction then return end
	z.occupants[faction] = math.max(0, (z.occupants[faction] or 0) - 1)
end

function ConquestService.Tick(dt)
	if not active then return end

	for zoneName, z in pairs(zones) do
		local empire = z.occupants["Viltrumite Empire"] or 0
		local earth  = z.occupants["Earth Defenders"]   or 0

		-- Score tick for zone controller
		if z.controller then
			scores[z.controller] = scores[z.controller] + Config.ZONE_SCORE_RATE * dt
		end

		-- Capture logic
		local dominant, size
		if empire > earth then
			dominant, size = "Viltrumite Empire", empire - earth
		elseif earth > empire then
			dominant, size = "Earth Defenders", earth - empire
		end

		if dominant and z.controller ~= dominant then
			z.capturingTeam = dominant
			local rate = size * (100 / Config.ZONE_CAPTURE_TIME)
			z.progress = math.min(100, z.progress + rate * dt)
			if z.progress >= 100 then
				local old        = z.controller
				z.controller     = dominant
				z.progress       = 0
				z.capturingTeam  = nil
				fireAll("ZoneCapture", zoneName, dominant, old)
			end
		elseif empire == 0 and earth == 0 and z.progress > 0 then
			-- Slow neutralise when empty
			z.progress = math.max(0, z.progress - (50 / Config.ZONE_CAPTURE_TIME) * dt)
		end

		fireAll("ZoneProgress", zoneName, z.progress, z.capturingTeam, z.controller)
	end

	-- Win check
	fireAll("ScoreUpdate", scores)
	for team, score in pairs(scores) do
		if score >= Config.WIN_SCORE then
			active = false
			fireAll("ConquestWin", team, scores)
			task.delay(30, ConquestService.Start)  -- restart after 30 s
			break
		end
	end
end

function ConquestService.GetZones()  return zones  end
function ConquestService.GetScores() return scores end

return ConquestService
