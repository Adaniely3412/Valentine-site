-- Builds and updates all HUD elements: health, power level, bloodline, combo, conquest, notifications.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()

local Remotes       = ReplicatedStorage:WaitForChild("Remotes")
local Config        = require(ReplicatedStorage.Modules.Config)
local BloodlineData = require(ReplicatedStorage.Modules.BloodlineData)

-- ── ScreenGui ────────────────────────────────────────────────────

local sg = Instance.new("ScreenGui")
sg.Name             = "ViltrumiteHUD"
sg.ResetOnSpawn     = false
sg.IgnoreGuiInset   = true
sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
sg.Parent           = playerGui

-- ── Builder helpers ──────────────────────────────────────────────

local function frame(parent, name, size, pos, bg, transp)
	local f = Instance.new("Frame")
	f.Name                  = name
	f.Size                  = size
	f.Position              = pos
	f.BackgroundColor3      = bg or Color3.fromRGB(0, 0, 0)
	f.BackgroundTransparency = transp or 0.5
	f.BorderSizePixel       = 0
	f.Parent                = parent
	return f
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
end

local function label(parent, name, text, size, pos, color, fsize, font)
	local l = Instance.new("TextLabel")
	l.Name                  = name
	l.Text                  = text
	l.Size                  = size
	l.Position              = pos
	l.BackgroundTransparency = 1
	l.TextColor3            = color or Color3.fromRGB(255, 255, 255)
	l.Font                  = font  or Enum.Font.GothamBold
	l.TextSize              = fsize or 16
	l.TextXAlignment        = Enum.TextXAlignment.Left
	l.TextStrokeTransparency = 0.6
	l.Parent                = parent
	return l
end

local function bar(parent, fillColor)
	local bg  = frame(parent, "BG",   UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(20,20,20), 0.35)
	local fill = frame(bg,   "Fill", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), fillColor, 0)
	corner(bg, 4); corner(fill, 4)
	return bg, fill
end

-- ── Health panel (bottom-left) ───────────────────────────────────

local hpPanel = frame(sg, "HP", UDim2.new(0,310,0,58), UDim2.new(0,18,1,-80), Color3.fromRGB(10,10,10), 0.35)
corner(hpPanel)
label(hpPanel, "Title", "HP",     UDim2.new(0,40,0,18), UDim2.new(0,10,0,4),  Color3.fromRGB(255,80,80),  13)
local hpBarBG, hpBarFill = bar(
	frame(hpPanel, "BarArea", UDim2.new(1,-20,0,14), UDim2.new(0,10,0,26), Color3.fromRGB(0,0,0), 1),
	Color3.fromRGB(220, 30, 30))
local hpText = label(hpPanel, "Num", "100 / 100",
	UDim2.new(1,-20,0,14), UDim2.new(0,10,0,8), Color3.fromRGB(255,200,200), 12)
hpText.TextXAlignment = Enum.TextXAlignment.Right

-- ── Power Level panel (bottom-center) ────────────────────────────

local plPanel = frame(sg, "PL", UDim2.new(0,270,0,68), UDim2.new(0.5,-135,1,-80), Color3.fromRGB(10,10,10), 0.35)
corner(plPanel)
local plTitle = label(plPanel, "Title", "POWER LEVEL",
	UDim2.new(1,0,0,18), UDim2.new(0,0,0,5), Color3.fromRGB(255,200,50), 11)
plTitle.TextXAlignment = Enum.TextXAlignment.Center
local plNum = label(plPanel, "Num", "0",
	UDim2.new(1,0,0,34), UDim2.new(0,0,0,20), Color3.fromRGB(255,255,150), 30, Enum.Font.GothamBlack)
plNum.TextXAlignment = Enum.TextXAlignment.Center
local tierLbl = label(plPanel, "Tier", "HUMAN",
	UDim2.new(1,0,0,14), UDim2.new(0,0,0,52), Color3.fromRGB(200,200,200), 12)
tierLbl.TextXAlignment = Enum.TextXAlignment.Center

-- ── Bloodline panel (top-left) ────────────────────────────────────

local blPanel = frame(sg, "BL", UDim2.new(0,220,0,78), UDim2.new(0,18,0,18), Color3.fromRGB(10,10,10), 0.35)
corner(blPanel)
label(blPanel, "Title", "BLOODLINE", UDim2.new(1,0,0,16), UDim2.new(0,10,0,4), Color3.fromRGB(180,180,180), 11)
local blName   = label(blPanel, "Name",   "Human",  UDim2.new(1,-20,0,22), UDim2.new(0,10,0,20), Color3.fromRGB(255,255,255), 17)
local blRarity = label(blPanel, "Rarity", "Common", UDim2.new(1,-20,0,16), UDim2.new(0,10,0,46), Color3.fromRGB(160,160,160), 13)

-- ── Combo counter (mid-right) ─────────────────────────────────────

local comboFrame = frame(sg, "Combo", UDim2.new(0,160,0,70), UDim2.new(1,-180,0.5,-110), Color3.fromRGB(0,0,0), 1)
local comboNum  = label(comboFrame, "Num",  "", UDim2.new(1,0,0.6,0), UDim2.new(0,0,0,0),   Color3.fromRGB(255,200,50), 52, Enum.Font.GothamBlack)
local comboWord = label(comboFrame, "Word", "", UDim2.new(1,0,0.38,0), UDim2.new(0,0,0.6,0), Color3.fromRGB(255,150,50), 16)
comboNum.TextXAlignment  = Enum.TextXAlignment.Right
comboWord.TextXAlignment = Enum.TextXAlignment.Right

-- ── Conquest panel (top-right) ────────────────────────────────────

local cqPanel = frame(sg, "CQ", UDim2.new(0,238,0,158), UDim2.new(1,-256,0,18), Color3.fromRGB(10,10,10), 0.35)
corner(cqPanel)
label(cqPanel, "Title", "CONQUEST", UDim2.new(1,0,0,17), UDim2.new(0,10,0,4), Color3.fromRGB(200,150,50), 12)
local cqEmpire = label(cqPanel, "Empire", "EMPIRE: 0", UDim2.new(1,-20,0,18), UDim2.new(0,10,0,24), Color3.fromRGB(255,80,80),  15)
local cqEarth  = label(cqPanel, "Earth",  "EARTH: 0",  UDim2.new(1,-20,0,18), UDim2.new(0,10,0,44), Color3.fromRGB(80,180,255), 15)

local zoneLabels = {}
for i, zName in ipairs(Config.ZONE_NAMES) do
	zoneLabels[zName] = label(cqPanel, "Zone" .. i,
		zName:sub(1, 14) .. ": ---",
		UDim2.new(1,-20,0,15), UDim2.new(0,10,0,66 + (i-1)*22),
		Color3.fromRGB(180,180,180), 12)
end

-- ── Flight indicator (top-center) ────────────────────────────────

local flyLbl = label(sg, "Fly", "[ AIRBORNE ]",
	UDim2.new(0,200,0,22), UDim2.new(0.5,-100,0,108),
	Color3.fromRGB(100,210,255), 14)
flyLbl.TextXAlignment = Enum.TextXAlignment.Center
flyLbl.Visible = false

-- ── Notification (top-center) ─────────────────────────────────────

local notifLbl = label(sg, "Notif", "",
	UDim2.new(0,500,0,38), UDim2.new(0.5,-250,0,62),
	Color3.fromRGB(255,255,100), 18)
notifLbl.TextXAlignment  = Enum.TextXAlignment.Center
notifLbl.TextStrokeTransparency = 0
notifLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
local notifTimer = 0

-- ── Update functions ─────────────────────────────────────────────

local function formatPL(pl)
	if pl >= 1e6 then return string.format("%.2fM", pl / 1e6) end
	if pl >= 1e3 then return string.format("%.1fK", pl / 1e3) end
	return tostring(pl)
end

local function updateHP(cur, max)
	local pct = math.clamp(cur / max, 0, 1)
	hpBarFill.Size = UDim2.new(pct, 0, 1, 0)
	hpText.Text    = math.floor(cur) .. " / " .. math.floor(max)
	hpBarFill.BackgroundColor3 =
		pct > 0.5 and Color3.fromRGB(220, 30, 30)  or
		pct > 0.25 and Color3.fromRGB(220,120, 30) or
		Color3.fromRGB(220, 220, 30)
end

local function updatePL(pl)
	plNum.Text = formatPL(pl)
	local tier = Config.TIERS[1]
	for i = #Config.TIERS, 1, -1 do
		if pl >= Config.TIERS[i].minPL then tier = Config.TIERS[i]; break end
	end
	plNum.TextColor3 = tier.color
	tierLbl.Text     = tier.name:upper()
	tierLbl.TextColor3 = tier.color
end

local function updateBloodline(bname)
	local bd = BloodlineData.Get(bname)
	blName.Text  = bname
	blName.TextColor3 = bd.auraColor
	blRarity.Text = bd.rarity:upper()
	local rc = { Common=Color3.fromRGB(200,200,200), Uncommon=Color3.fromRGB(100,220,100),
	             Rare=Color3.fromRGB(100,150,255), Legendary=Color3.fromRGB(255,200,50) }
	blRarity.TextColor3 = rc[bd.rarity] or Color3.fromRGB(200,200,200)
end

local function notify(msg, kind)
	notifLbl.Text = msg
	notifTimer    = 3.5
	local colors  = { error=Color3.fromRGB(255,80,80), success=Color3.fromRGB(80,255,80), info=Color3.fromRGB(100,200,255) }
	notifLbl.TextColor3 = colors[kind] or Color3.fromRGB(255,255,100)
end

local function updateCombo(count)
	if count and count > 0 then
		comboNum.Text  = count .. "x"
		comboWord.Text = count >= 5 and "FINISHER!" or "COMBO"
		local pulse = TweenService:Create(comboNum, TweenInfo.new(0.08, Enum.EasingStyle.Bounce), { TextSize = 58 })
		pulse:Play()
		pulse.Completed:Connect(function()
			TweenService:Create(comboNum, TweenInfo.new(0.08), { TextSize = 52 }):Play()
		end)
		comboNum.TextColor3  = count >= 5 and Color3.fromRGB(255,50,50) or
		                       count >= 3 and Color3.fromRGB(255,150,50) or
		                       Color3.fromRGB(255,200,50)
	else
		comboNum.Text  = ""
		comboWord.Text = ""
	end
end

-- ── Remote listeners ─────────────────────────────────────────────

Remotes.BloodlineAssigned.OnClientEvent:Connect(function(bname, bd)
	updateBloodline(bname)
	notify("Bloodline: " .. bname .. " [" .. bd.rarity .. "]", "info")
end)

Remotes.StatsUpdated.OnClientEvent:Connect(function(data)
	if data.powerLevel then updatePL(data.powerLevel) end
	if data.bloodline  then updateBloodline(data.bloodline) end
end)

Remotes.PowerLevelUp.OnClientEvent:Connect(function(newPL, oldPL)
	updatePL(newPL)
	if newPL - oldPL >= 1000 then
		notify("POWER LEVEL: " .. formatPL(newPL), "success")
	end
end)

Remotes.FlightStateChanged.OnClientEvent:Connect(function(state)
	flyLbl.Visible = state
end)

Remotes.ZoneCapture.OnClientEvent:Connect(function(zName, team, _old)
	notify(team .. " captured " .. zName .. "!", "info")
end)

Remotes.ZoneProgress.OnClientEvent:Connect(function(zName, progress, capTeam, controller)
	local lbl = zoneLabels[zName]
	if not lbl then return end
	local short = zName:sub(1, 14)
	if controller then
		lbl.Text = short .. ": " .. (controller == "Viltrumite Empire" and "EMPIRE" or "EARTH")
		lbl.TextColor3 = controller == "Viltrumite Empire" and Color3.fromRGB(255,120,120) or Color3.fromRGB(120,180,255)
	elseif capTeam then
		lbl.Text = short .. ": " .. math.floor(progress) .. "%"
		lbl.TextColor3 = Color3.fromRGB(255,220,100)
	else
		lbl.Text = short .. ": ---"
		lbl.TextColor3 = Color3.fromRGB(180,180,180)
	end
end)

Remotes.ScoreUpdate.OnClientEvent:Connect(function(s)
	cqEmpire.Text = "EMPIRE: " .. math.floor(s["Viltrumite Empire"] or 0)
	cqEarth.Text  = "EARTH:  " .. math.floor(s["Earth Defenders"]   or 0)
end)

Remotes.ConquestWin.OnClientEvent:Connect(function(team)
	notify(team:upper() .. " WINS THE CONQUEST!", "success")
end)

Remotes.ShowNotification.OnClientEvent:Connect(function(msg, kind)
	notify(msg, kind)
end)

Remotes.BossSpawned.OnClientEvent:Connect(function(bossName, pl)
	notify("BOSS: " .. bossName .. " [PL " .. formatPL(pl) .. "] APPEARED!", "error")
end)

Remotes.BossDefeated.OnClientEvent:Connect(function(bossName, killerName)
	notify(killerName .. " defeated " .. bossName .. "!", "success")
end)

-- ── RenderStepped update loop ─────────────────────────────────────

RunService.RenderStepped:Connect(function(dt)
	if character and character.Parent then
		local h = character:FindFirstChildOfClass("Humanoid")
		if h then updateHP(h.Health, h.MaxHealth) end
		updateCombo(character:GetAttribute("ComboCount") or 0)
		local msg = character:GetAttribute("NotifMsg")
		if msg and msg ~= "" then
			notify(msg, "error")
			character:SetAttribute("NotifMsg", "")
		end
	end
	if notifTimer > 0 then
		notifTimer -= dt
		if notifTimer <= 0 then notifLbl.Text = "" end
	end
end)

-- ── Initial data fetch ────────────────────────────────────────────

task.spawn(function()
	task.wait(1.2)
	local GetPlayerData = Remotes:WaitForChild("GetPlayerData")
	local data = GetPlayerData:InvokeServer()
	if data then
		if data.powerLevel then updatePL(data.powerLevel) end
		if data.bloodline  then updateBloodline(data.bloodline) end
	end
end)

-- ── Respawn ──────────────────────────────────────────────────────

player.CharacterAdded:Connect(function(newChar)
	character = newChar
end)
