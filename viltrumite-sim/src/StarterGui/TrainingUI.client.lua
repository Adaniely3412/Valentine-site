-- Training stat panel. Shows STR / SPD / END / FOC progress bars.
-- Slides in from the left when training stats arrive.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")

local MAX_PTS   = 100

-- ── Panel ─────────────────────────────────────────────────────────

local sg = Instance.new("ScreenGui")
sg.Name = "TrainingUI"; sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "TrainingPanel"
panel.Size = UDim2.new(0, 200, 0, 152)
panel.Position = UDim2.new(0, -210, 0, 120)  -- starts off-screen left
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Parent = sg

local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0, 10); pc.Parent = panel

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, 0, 0, 28)
titleLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 35)
titleLbl.BackgroundTransparency = 0
titleLbl.BorderSizePixel = 0
titleLbl.TextColor3 = Color3.fromRGB(200, 200, 255)
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.Text = "TRAINING STATS"
titleLbl.Parent = panel
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 10); tc.Parent = titleLbl

local STATS = {
	{ key="Strength",  label="STR", color=Color3.fromRGB(255,80,80)   },
	{ key="Speed",     label="SPD", color=Color3.fromRGB(80,200,255)  },
	{ key="Endurance", label="END", color=Color3.fromRGB(80,255,120)  },
	{ key="Focus",     label="FOC", color=Color3.fromRGB(180,100,255) },
}

local barRefs = {}

local function makeStatRow(statDef, yOffset)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -12, 0, 24)
	row.Position = UDim2.new(0, 6, 0, yOffset)
	row.BackgroundTransparency = 1
	row.Parent = panel

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, 30, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = statDef.color
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.Text = statDef.label
	lbl.Parent = row

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -70, 0, 10)
	bg.Position = UDim2.new(0, 34, 0.5, -5)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
	bg.BorderSizePixel = 0
	bg.Parent = row
	local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 5); bgc.Parent = bg

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = statDef.color
	fill.BorderSizePixel = 0
	fill.Parent = bg
	local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 5); fc.Parent = fill

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0, 30, 1, 0)
	valLbl.Position = UDim2.new(1, -34, 0, 0)
	valLbl.BackgroundTransparency = 1
	valLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	valLbl.Font = Enum.Font.Gotham
	valLbl.TextSize = 11
	valLbl.Text = "0"
	valLbl.Parent = row

	barRefs[statDef.key] = { fill=fill, bg=bg, val=valLbl }
end

for i, statDef in ipairs(STATS) do
	makeStatRow(statDef, 30 + (i-1)*28)
end

-- ── Show/hide helpers ─────────────────────────────────────────────

local isVisible = false
local function slideIn()
	if isVisible then return end
	isVisible = true
	panel.Position = UDim2.new(0, -210, 0, 120)
	TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 10, 0, 120)}):Play()
end

local function updateBars(stats)
	for key, refs in pairs(barRefs) do
		local pts = stats[key] or 0
		local frac = pts / MAX_PTS
		TweenService:Create(refs.fill, TweenInfo.new(0.4, Enum.EasingStyle.Quad),
			{Size = UDim2.new(frac, 0, 1, 0)}):Play()
		refs.val.Text = tostring(pts)
	end
end

-- ── Flash notification on training complete ───────────────────────

local function flashComplete(stationId, stat, points)
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(0, 260, 0, 54)
	flash.Position = UDim2.new(0.5, -130, 0, -60)
	flash.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	flash.BackgroundTransparency = 0.05
	flash.BorderSizePixel = 0
	flash.Parent = sg
	local flc = Instance.new("UICorner"); flc.CornerRadius = UDim.new(0, 10); flc.Parent = flash

	local flbl = Instance.new("TextLabel")
	flbl.Size = UDim2.new(1, 0, 1, 0)
	flbl.BackgroundTransparency = 1
	flbl.TextColor3 = Color3.fromRGB(200, 255, 200)
	flbl.Font = Enum.Font.GothamBold
	flbl.TextSize = 16
	flbl.Text = string.format("TRAINING COMPLETE\n+1 %s  (%d/%d)", stat, points, MAX_PTS)
	flbl.Parent = flash

	-- Slide down
	TweenService:Create(flash, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, -130, 0, 10)}):Play()

	task.delay(2.5, function()
		TweenService:Create(flash, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
			{Position = UDim2.new(0.5, -130, 0, -70), BackgroundTransparency = 1}):Play()
		task.delay(0.25, function() flash:Destroy() end)
	end)
end

-- ── Remotes ───────────────────────────────────────────────────────

Remotes.TrainingStatUpdate.OnClientEvent:Connect(function(stats)
	slideIn()
	updateBars(stats)
end)

Remotes.TrainingComplete.OnClientEvent:Connect(function(stationId, stat, points)
	flashComplete(stationId, stat, points)
end)
