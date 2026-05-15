-- Global and session leaderboard. Press L or click the button to open.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")

local sg = Instance.new("ScreenGui")
sg.Name = "LeaderboardUI"; sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.Parent = playerGui

-- ── Open button ───────────────────────────────────────────────────

local openBtn           = Instance.new("TextButton")
openBtn.Size            = UDim2.new(0,90,0,36)
openBtn.Position        = UDim2.new(1,-108,1,-100)
openBtn.BackgroundColor3 = Color3.fromRGB(30,30,40)
openBtn.TextColor3      = Color3.fromRGB(200,200,255)
openBtn.Font            = Enum.Font.GothamBold
openBtn.TextSize        = 14; openBtn.Text = "RANKS [L]"
openBtn.BorderSizePixel = 0; openBtn.Parent = sg
local obc = Instance.new("UICorner"); obc.CornerRadius=UDim.new(0,8); obc.Parent=openBtn

-- ── Panel ─────────────────────────────────────────────────────────

local panel           = Instance.new("Frame")
panel.Size            = UDim2.new(0,480,0,420)
panel.Position        = UDim2.new(0.5,-240,0.5,-210)
panel.BackgroundColor3 = Color3.fromRGB(10,10,20)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0; panel.Visible = false; panel.Parent = sg
local pc = Instance.new("UICorner"); pc.CornerRadius=UDim.new(0,12); pc.Parent=panel

-- Title bar
local titleBar          = Instance.new("Frame")
titleBar.Size           = UDim2.new(1,0,0,48)
titleBar.BackgroundColor3 = Color3.fromRGB(18,18,35)
titleBar.BorderSizePixel=0; titleBar.Parent=panel
local tbc = Instance.new("UICorner"); tbc.CornerRadius=UDim.new(0,12); tbc.Parent=titleBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size=UDim2.new(1,-50,1,0); titleLbl.Position=UDim2.new(0,16,0,0)
titleLbl.BackgroundTransparency=1; titleLbl.TextColor3=Color3.fromRGB(200,200,255)
titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=18; titleLbl.Text="LEADERBOARD"
titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,32,0,32); closeBtn.Position=UDim2.new(1,-40,0,8)
closeBtn.BackgroundColor3=Color3.fromRGB(180,30,30); closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=16; closeBtn.Text="✕"
closeBtn.BorderSizePixel=0; closeBtn.Parent=titleBar
local cbc=Instance.new("UICorner"); cbc.CornerRadius=UDim.new(0,8); cbc.Parent=closeBtn

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size=UDim2.new(1,-16,0,34); tabBar.Position=UDim2.new(0,8,0,52)
tabBar.BackgroundTransparency=1; tabBar.Parent=panel

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.Padding=UDim.new(0,6); tabLayout.Parent=tabBar

local TABS = { "Power Level", "Kills", "Session" }
local tabBtns = {}
local activeTab = "Power Level"

-- Content area
local content = Instance.new("ScrollingFrame")
content.Size=UDim2.new(1,-16,1,-100); content.Position=UDim2.new(0,8,0,94)
content.BackgroundTransparency=1; content.BorderSizePixel=0
content.ScrollBarThickness=5; content.ScrollBarImageColor3=Color3.fromRGB(200,200,255)
content.CanvasSize=UDim2.new(0,0,0,0); content.Parent=panel

local contentLayout=Instance.new("UIListLayout"); contentLayout.Padding=UDim.new(0,4); contentLayout.Parent=content

-- Leaderboard data cache
local cachedData = { ["Power Level"]={}, Kills={}, Session={} }

-- ── Row builder ───────────────────────────────────────────────────

local RANK_COLORS = {
	Color3.fromRGB(255,200,50),   -- 1st gold
	Color3.fromRGB(200,200,200),  -- 2nd silver
	Color3.fromRGB(200,120,50),   -- 3rd bronze
}

local function buildRow(rank, name, value, isPlayer)
	local row = Instance.new("Frame")
	row.Size  = UDim2.new(1,0,0,38)
	row.BackgroundColor3 = isPlayer
		and Color3.fromRGB(30,30,60)
		or  Color3.fromRGB(18,18,30)
	row.BackgroundTransparency = isPlayer and 0 or 0.2
	row.BorderSizePixel = 0; row.Parent = content
	local rc=Instance.new("UICorner"); rc.CornerRadius=UDim.new(0,8); rc.Parent=row

	local rankLbl=Instance.new("TextLabel"); rankLbl.Size=UDim2.new(0,38,1,0)
	rankLbl.BackgroundTransparency=1; rankLbl.TextColor3=RANK_COLORS[rank] or Color3.fromRGB(180,180,180)
	rankLbl.Font=Enum.Font.GothamBlack; rankLbl.TextSize=16; rankLbl.Text="#"..rank; rankLbl.Parent=row

	local nameLbl=Instance.new("TextLabel"); nameLbl.Size=UDim2.new(1,-130,1,0)
	nameLbl.Position=UDim2.new(0,40,0,0); nameLbl.BackgroundTransparency=1
	nameLbl.TextColor3=Color3.fromRGB(255,255,255); nameLbl.Font=Enum.Font.GothamBold
	nameLbl.TextSize=14; nameLbl.Text=name; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.Parent=row

	local valLbl=Instance.new("TextLabel"); valLbl.Size=UDim2.new(0,120,1,0)
	valLbl.Position=UDim2.new(1,-124,0,0); valLbl.BackgroundTransparency=1
	local formatted = value >= 1e6 and string.format("%.2fM",value/1e6)
		or value >= 1e3 and string.format("%.1fK",value/1e3)
		or tostring(value)
	valLbl.TextColor3=RANK_COLORS[rank] or Color3.fromRGB(200,200,200)
	valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=14; valLbl.Text=formatted
	valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=row

	return row
end

local function refreshContent()
	for _, c in ipairs(content:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local rows = cachedData[activeTab] or {}
	for i, row in ipairs(rows) do
		local isMe = row.name == player.DisplayName or row.name == player.Name
		buildRow(i, row.name, row.value or row.powerLevel or row.kills or 0, isMe)
	end
	content.CanvasSize = UDim2.new(0,0,0, #rows*42+10)
end

-- ── Tabs ──────────────────────────────────────────────────────────

for _, tabName in ipairs(TABS) do
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(0,140,1,0); btn.BackgroundColor3=Color3.fromRGB(25,25,45)
	btn.BorderSizePixel=0; btn.TextColor3=Color3.fromRGB(180,180,220)
	btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.Text=tabName:upper()
	btn.Parent=tabBar
	local btc=Instance.new("UICorner"); btc.CornerRadius=UDim.new(0,8); btc.Parent=btn
	tabBtns[tabName]=btn

	btn.MouseButton1Click:Connect(function()
		activeTab=tabName
		for n,b in pairs(tabBtns) do
			b.BackgroundColor3 = n==tabName
				and Color3.fromRGB(60,60,120)
				or  Color3.fromRGB(25,25,45)
			b.TextColor3 = n==tabName
				and Color3.fromRGB(255,255,255)
				or  Color3.fromRGB(180,180,220)
		end
		if tabName=="Session" then
			Remotes.GetSessionBoard:FireServer()
		end
		refreshContent()
	end)
end
-- Activate default
tabBtns["Power Level"].BackgroundColor3=Color3.fromRGB(60,60,120)
tabBtns["Power Level"].TextColor3=Color3.fromRGB(255,255,255)

-- ── Toggle ────────────────────────────────────────────────────────

local isOpen = false
local function toggle()
	isOpen = not isOpen
	if isOpen then
		panel.Visible=true
		panel.Size=UDim2.new(0,20,0,20); panel.Position=UDim2.new(0.5,-10,0.5,-10)
		TweenService:Create(panel,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
			{Size=UDim2.new(0,480,0,420),Position=UDim2.new(0.5,-240,0.5,-210)}):Play()
		Remotes.GetLeaderboard:FireServer()
	else
		TweenService:Create(panel,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
			{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0.5,-10,0.5,-10)}):Play()
		task.delay(0.16,function() panel.Visible=false end)
	end
end

openBtn.MouseButton1Click:Connect(toggle)
closeBtn.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode==Enum.KeyCode.L then toggle() end
end)

-- ── Remotes ───────────────────────────────────────────────────────

Remotes.LeaderboardUpdate.OnClientEvent:Connect(function(data)
	if data.powerLevel then
		cachedData["Power Level"]={}
		for _,r in ipairs(data.powerLevel) do
			table.insert(cachedData["Power Level"],{name=r.name,value=r.value})
		end
	end
	if data.kills then
		cachedData["Kills"]={}
		for _,r in ipairs(data.kills) do
			table.insert(cachedData["Kills"],{name=r.name,value=r.value})
		end
	end
	if isOpen then refreshContent() end
end)

Remotes.SessionBoard.OnClientEvent:Connect(function(rows)
	cachedData["Session"]={}
	for _,r in ipairs(rows) do
		table.insert(cachedData["Session"],{name=r.name,value=r.powerLevel,kills=r.kills})
	end
	if isOpen and activeTab=="Session" then refreshContent() end
end)
