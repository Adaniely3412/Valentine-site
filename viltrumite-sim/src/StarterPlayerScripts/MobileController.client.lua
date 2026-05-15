-- On-screen touch buttons for mobile players.
-- Only activates when UserInputService.TouchEnabled is true (mobile/tablet).
-- Fires MobileInput BindableEvents that CombatController and FlightController listen to.

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not UserInputService.TouchEnabled then return end

local MobileInput = require(ReplicatedStorage.Modules.MobileInput)

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui")
sg.Name = "MobileControls"; sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = playerGui

-- ── Layout helpers ────────────────────────────────────────────────

local function makeButton(parent, text, color, size, pos, zIndex)
	local btn = Instance.new("ImageButton")
	btn.Size = size or UDim2.new(0, 70, 0, 70)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.25
	btn.BorderSizePixel = 0
	btn.ZIndex = zIndex or 2
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.Text = text
	lbl.ZIndex = zIndex and (zIndex+1) or 3
	lbl.Parent = btn

	return btn
end

local function flash(btn)
	local orig = btn.BackgroundTransparency
	btn.BackgroundTransparency = 0
	task.delay(0.1, function() btn.BackgroundTransparency = orig end)
end

-- ── Right-side action buttons ─────────────────────────────────────
-- Layout (bottom-right cluster):
--   [FLY]
--   [E] [R]
--   [F] [G]
--   [T]
--   [ATK] [BLK]

local rPad = Instance.new("Frame")
rPad.Name = "RightPad"
rPad.Size = UDim2.new(0, 156, 0, 320)
rPad.Position = UDim2.new(1, -164, 1, -336)
rPad.BackgroundTransparency = 1
rPad.Parent = sg

-- Attack (big, bottom-right)
local atkBtn = makeButton(rPad, "ATK", Color3.fromRGB(220,60,60),
	UDim2.new(0,80,0,80), UDim2.new(1,-84,1,-84))
atkBtn.MouseButton1Down:Connect(function()
	flash(atkBtn); MobileInput.M1:Fire()
end)
atkBtn.TouchTap:Connect(function()
	flash(atkBtn); MobileInput.M1:Fire()
end)

-- Block
local blkBtn = makeButton(rPad, "BLK", Color3.fromRGB(60,60,200),
	UDim2.new(0,68,0,68), UDim2.new(0,0,1,-72))
local blocking = false
blkBtn.MouseButton1Down:Connect(function()
	blocking = true; MobileInput.Block:Fire(true)
	blkBtn.BackgroundTransparency = 0
end)
blkBtn.MouseButton1Up:Connect(function()
	blocking = false; MobileInput.Block:Fire(false)
	blkBtn.BackgroundTransparency = 0.25
end)
blkBtn.TouchLongPress:Connect(function(_, state)
	if state == Enum.UserInputState.Begin then
		blocking = true; MobileInput.Block:Fire(true)
		blkBtn.BackgroundTransparency = 0
	else
		blocking = false; MobileInput.Block:Fire(false)
		blkBtn.BackgroundTransparency = 0.25
	end
end)

-- Flight toggle
local flyBtn = makeButton(rPad, "FLY", Color3.fromRGB(80,160,255),
	UDim2.new(0,68,0,50), UDim2.new(1,-72,0,0))
flyBtn.MouseButton1Click:Connect(function()
	flash(flyBtn); MobileInput.FlightToggle:Fire()
end)
flyBtn.TouchTap:Connect(function()
	flash(flyBtn); MobileInput.FlightToggle:Fire()
end)

-- Sprint toggle (double-tap FLY or separate button)
local sprintBtn = makeButton(rPad, "SPRINT", Color3.fromRGB(50,120,220),
	UDim2.new(0,68,0,40), UDim2.new(0,0,0,0))
local sprinting = false
sprintBtn.MouseButton1Down:Connect(function()
	sprinting = not sprinting
	MobileInput.FlightSprint:Fire(sprinting)
	sprintBtn.BackgroundTransparency = sprinting and 0 or 0.25
end)
sprintBtn.TouchTap:Connect(function()
	sprinting = not sprinting
	MobileInput.FlightSprint:Fire(sprinting)
	sprintBtn.BackgroundTransparency = sprinting and 0 or 0.25
end)

-- Row 1 specials: SonicClap (E), ViltrumiteRush (R)
local eBtn = makeButton(rPad, "E\nSONIC", Color3.fromRGB(255,180,30),
	UDim2.new(0,68,0,58), UDim2.new(0,0,0,54))
local rBtn = makeButton(rPad, "R\nRUSH",  Color3.fromRGB(255,100,0),
	UDim2.new(0,68,0,58), UDim2.new(1,-72,0,54))

-- Row 2: EarthShatter (F), ThoraxStrike (G)
local fBtn = makeButton(rPad, "F\nEARTH", Color3.fromRGB(120,60,200),
	UDim2.new(0,68,0,58), UDim2.new(0,0,0,118))
local gBtn = makeButton(rPad, "G\nGRAB",  Color3.fromRGB(200,30,30),
	UDim2.new(0,68,0,58), UDim2.new(1,-72,0,118))

-- Row 3: SupremeOverdrive (T)
local tBtn = makeButton(rPad, "T\nOVERDRIVE", Color3.fromRGB(200,0,200),
	UDim2.new(0,140,0,48), UDim2.new(0,8,0,182))

-- Wire specials
local specials = {
	{btn=eBtn, event="SonicClap"},
	{btn=rBtn, event="ViltrumiteRush"},
	{btn=fBtn, event="EarthShatter"},
	{btn=gBtn, event="ThoraxStrike"},
	{btn=tBtn, event="SupremeOverdrive"},
}
for _, s in ipairs(specials) do
	s.btn.MouseButton1Click:Connect(function()
		flash(s.btn); MobileInput[s.event]:Fire()
	end)
	s.btn.TouchTap:Connect(function()
		flash(s.btn); MobileInput[s.event]:Fire()
	end)
end

-- ── Left virtual joystick (flight direction) ──────────────────────
-- Only shows while flying; pans to give direction input

local joystickOuter = Instance.new("Frame")
joystickOuter.Name = "JoystickOuter"
joystickOuter.Size = UDim2.new(0, 120, 0, 120)
joystickOuter.Position = UDim2.new(0, 20, 1, -148)
joystickOuter.BackgroundColor3 = Color3.fromRGB(255,255,255)
joystickOuter.BackgroundTransparency = 0.75
joystickOuter.BorderSizePixel = 0
joystickOuter.Visible = false
joystickOuter.Parent = sg
local joc = Instance.new("UICorner"); joc.CornerRadius = UDim.new(0.5,0); joc.Parent = joystickOuter

local joystickInner = Instance.new("Frame")
joystickInner.Size = UDim2.new(0,50,0,50)
joystickInner.Position = UDim2.new(0.5,-25,0.5,-25)
joystickInner.BackgroundColor3 = Color3.fromRGB(200,200,255)
joystickInner.BackgroundTransparency = 0.4
joystickInner.BorderSizePixel = 0
joystickInner.Parent = joystickOuter
local jic = Instance.new("UICorner"); jic.CornerRadius = UDim.new(0.5,0); jic.Parent = joystickInner

-- Track flying state
local isFlying = false
local function updateJoystickVisibility(flying)
	isFlying = flying
	joystickOuter.Visible = flying
end

-- Watch FlightStateChanged remote (fired by server)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
Remotes.FlightStateChanged.OnClientEvent:Connect(function(state)
	updateJoystickVisibility(state)
end)

-- Joystick drag
local dragging = false
local dragInput  = nil
local outerCenter = nil

joystickOuter.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragInput = input
		local pos = joystickOuter.AbsolutePosition
		outerCenter = Vector2.new(pos.X + 60, pos.Y + 60)
	end
end)

joystickOuter.InputEnded:Connect(function(input)
	if input == dragInput then
		dragging = false
		dragInput = nil
		joystickInner.Position = UDim2.new(0.5,-25,0.5,-25)
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and dragInput and input.UserInputType == Enum.UserInputType.Touch then
		if outerCenter then
			local tp = input.Position
			local delta = Vector2.new(tp.X - outerCenter.X, tp.Y - outerCenter.Y)
			local maxR  = 35
			if delta.Magnitude > maxR then
				delta = delta.Unit * maxR
			end
			joystickInner.Position = UDim2.new(0.5, delta.X - 25, 0.5, delta.Y - 25)
		end
	end
end)
