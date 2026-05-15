-- Guild / Warband UI. Press G or click button to open.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")

local currentGuild = nil

local sg=Instance.new("ScreenGui"); sg.Name="GuildUI"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=playerGui

-- ── Guild badge (top-left, below bloodline panel) ─────────────────

local badge          = Instance.new("Frame")
badge.Name           = "GuildBadge"
badge.Size           = UDim2.new(0,220,0,34)
badge.Position       = UDim2.new(0,18,0,106)
badge.BackgroundColor3=Color3.fromRGB(10,10,18)
badge.BackgroundTransparency=0.4; badge.BorderSizePixel=0; badge.Visible=false; badge.Parent=sg
local bac=Instance.new("UICorner"); bac.CornerRadius=UDim.new(0,8); bac.Parent=badge

local badgeLbl=Instance.new("TextLabel"); badgeLbl.Size=UDim2.new(1,-8,1,0)
badgeLbl.Position=UDim2.new(0,6,0,0); badgeLbl.BackgroundTransparency=1
badgeLbl.Font=Enum.Font.GothamBold; badgeLbl.TextSize=13
badgeLbl.TextXAlignment=Enum.TextXAlignment.Left; badgeLbl.Parent=badge

-- ── Open button ───────────────────────────────────────────────────

local openBtn=Instance.new("TextButton"); openBtn.Size=UDim2.new(0,90,0,36)
openBtn.Position=UDim2.new(1,-108,1,-142); openBtn.BackgroundColor3=Color3.fromRGB(30,30,40)
openBtn.TextColor3=Color3.fromRGB(255,150,80); openBtn.Font=Enum.Font.GothamBold
openBtn.TextSize=14; openBtn.Text="WARBAND [G]"; openBtn.BorderSizePixel=0; openBtn.Parent=sg
local obc=Instance.new("UICorner"); obc.CornerRadius=UDim.new(0,8); obc.Parent=openBtn

-- ── Main panel ────────────────────────────────────────────────────

local panel=Instance.new("Frame"); panel.Size=UDim2.new(0,460,0,480)
panel.Position=UDim2.new(0.5,-230,0.5,-240)
panel.BackgroundColor3=Color3.fromRGB(10,10,20); panel.BackgroundTransparency=0.08
panel.BorderSizePixel=0; panel.Visible=false; panel.Parent=sg
local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(0,12); pc.Parent=panel

-- Title bar
local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,48)
titleBar.BackgroundColor3=Color3.fromRGB(20,15,10); titleBar.BorderSizePixel=0; titleBar.Parent=panel
local tbc=Instance.new("UICorner"); tbc.CornerRadius=UDim.new(0,12); tbc.Parent=titleBar

local titleLbl=Instance.new("TextLabel"); titleLbl.Size=UDim2.new(1,-50,1,0)
titleLbl.Position=UDim2.new(0,16,0,0); titleLbl.BackgroundTransparency=1
titleLbl.TextColor3=Color3.fromRGB(255,150,80); titleLbl.Font=Enum.Font.GothamBold
titleLbl.TextSize=18; titleLbl.Text="WARBAND"; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar

local closeBtn=Instance.new("TextButton"); closeBtn.Size=UDim2.new(0,32,0,32)
closeBtn.Position=UDim2.new(1,-40,0,8); closeBtn.BackgroundColor3=Color3.fromRGB(180,30,30)
closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=16; closeBtn.Text="✕"; closeBtn.BorderSizePixel=0; closeBtn.Parent=titleBar
local cbc=Instance.new("UICorner"); cbc.CornerRadius=UDim.new(0,8); cbc.Parent=closeBtn

-- Content container (swaps between "my guild" and "create/join")
local content=Instance.new("Frame"); content.Size=UDim2.new(1,-16,1,-56)
content.Position=UDim2.new(0,8,0,52); content.BackgroundTransparency=1; content.Parent=panel

-- ── No-Guild view ─────────────────────────────────────────────────

local noGuild=Instance.new("Frame"); noGuild.Size=UDim2.new(1,0,1,0)
noGuild.BackgroundTransparency=1; noGuild.Parent=content

local function lbl(parent,text,size,pos,color,fsize)
	local l=Instance.new("TextLabel"); l.Size=size; l.Position=pos
	l.BackgroundTransparency=1; l.TextColor3=color or Color3.fromRGB(200,200,200)
	l.Font=Enum.Font.GothamBold; l.TextSize=fsize or 14; l.Text=text
	l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=parent; return l
end

lbl(noGuild,"Create a Warband",UDim2.new(1,0,0,22),UDim2.new(0,4,0,0),Color3.fromRGB(255,150,80),16)
lbl(noGuild,"Name:",UDim2.new(0,60,0,18),UDim2.new(0,4,0,30),Color3.fromRGB(180,180,180),13)

local nameBox=Instance.new("TextBox"); nameBox.Size=UDim2.new(1,-70,0,32)
nameBox.Position=UDim2.new(0,68,0,26); nameBox.BackgroundColor3=Color3.fromRGB(25,25,40)
nameBox.BorderSizePixel=0; nameBox.TextColor3=Color3.fromRGB(255,255,255)
nameBox.PlaceholderText="Warband name (3-24 chars)"; nameBox.Font=Enum.Font.Gotham
nameBox.TextSize=13; nameBox.ClearTextOnFocus=false; nameBox.Parent=noGuild
local nbc=Instance.new("UICorner"); nbc.CornerRadius=UDim.new(0,8); nbc.Parent=nameBox

lbl(noGuild,"Faction:",UDim2.new(0,70,0,18),UDim2.new(0,4,0,68),Color3.fromRGB(180,180,180),13)

local factionToggle="Viltrumite Empire"
local factionBtn=Instance.new("TextButton"); factionBtn.Size=UDim2.new(1,-70,0,32)
factionBtn.Position=UDim2.new(0,78,0,64); factionBtn.BackgroundColor3=Color3.fromRGB(180,30,30)
factionBtn.TextColor3=Color3.fromRGB(255,255,255); factionBtn.Font=Enum.Font.GothamBold
factionBtn.TextSize=13; factionBtn.Text="VILTRUMITE EMPIRE"; factionBtn.BorderSizePixel=0; factionBtn.Parent=noGuild
local fbc=Instance.new("UICorner"); fbc.CornerRadius=UDim.new(0,8); fbc.Parent=factionBtn
factionBtn.MouseButton1Click:Connect(function()
	if factionToggle=="Viltrumite Empire" then
		factionToggle="Earth Defenders"
		factionBtn.Text="EARTH DEFENDERS"; factionBtn.BackgroundColor3=Color3.fromRGB(30,80,200)
	else
		factionToggle="Viltrumite Empire"
		factionBtn.Text="VILTRUMITE EMPIRE"; factionBtn.BackgroundColor3=Color3.fromRGB(180,30,30)
	end
end)

local createBtn=Instance.new("TextButton"); createBtn.Size=UDim2.new(1,0,0,36)
createBtn.Position=UDim2.new(0,0,0,106); createBtn.BackgroundColor3=Color3.fromRGB(50,150,50)
createBtn.TextColor3=Color3.fromRGB(255,255,255); createBtn.Font=Enum.Font.GothamBold
createBtn.TextSize=14; createBtn.Text="CREATE WARBAND"; createBtn.BorderSizePixel=0; createBtn.Parent=noGuild
local crbc=Instance.new("UICorner"); crbc.CornerRadius=UDim.new(0,8); crbc.Parent=createBtn
createBtn.MouseButton1Click:Connect(function()
	local name=nameBox.Text
	if #name<3 then return end
	Remotes.CreateGuild:FireServer(name,factionToggle)
end)

-- Divider
lbl(noGuild,"── or join an existing warband ──",UDim2.new(1,0,0,16),UDim2.new(0,0,0,152),Color3.fromRGB(120,120,120),12)
lbl(noGuild,"Name:",UDim2.new(0,60,0,18),UDim2.new(0,4,0,176),Color3.fromRGB(180,180,180),13)

local joinBox=Instance.new("TextBox"); joinBox.Size=UDim2.new(1,-70,0,32)
joinBox.Position=UDim2.new(0,68,0,172); joinBox.BackgroundColor3=Color3.fromRGB(25,25,40)
joinBox.BorderSizePixel=0; joinBox.TextColor3=Color3.fromRGB(255,255,255)
joinBox.PlaceholderText="Enter warband name"; joinBox.Font=Enum.Font.Gotham
joinBox.TextSize=13; joinBox.ClearTextOnFocus=false; joinBox.Parent=noGuild
local jbc=Instance.new("UICorner"); jbc.CornerRadius=UDim.new(0,8); jbc.Parent=joinBox

local joinBtn=Instance.new("TextButton"); joinBtn.Size=UDim2.new(1,0,0,36)
joinBtn.Position=UDim2.new(0,0,0,214); joinBtn.BackgroundColor3=Color3.fromRGB(50,80,180)
joinBtn.TextColor3=Color3.fromRGB(255,255,255); joinBtn.Font=Enum.Font.GothamBold
joinBtn.TextSize=14; joinBtn.Text="JOIN WARBAND"; joinBtn.BorderSizePixel=0; joinBtn.Parent=noGuild
local jrbc=Instance.new("UICorner"); jrbc.CornerRadius=UDim.new(0,8); jrbc.Parent=joinBtn
joinBtn.MouseButton1Click:Connect(function()
	local name=joinBox.Text
	if #name<3 then return end
	Remotes.JoinGuild:FireServer(name)
end)

-- ── My-Guild view ─────────────────────────────────────────────────

local myGuild=Instance.new("Frame"); myGuild.Size=UDim2.new(1,0,1,0)
myGuild.BackgroundTransparency=1; myGuild.Visible=false; myGuild.Parent=content

local guildNameLbl=lbl(myGuild,"",UDim2.new(1,0,0,26),UDim2.new(0,0,0,0),Color3.fromRGB(255,150,80),20)
local guildFacLbl=lbl(myGuild,"",UDim2.new(1,0,0,18),UDim2.new(0,0,0,28),Color3.fromRGB(200,200,200),13)
local guildScoreLbl=lbl(myGuild,"",UDim2.new(1,0,0,16),UDim2.new(0,0,0,48),Color3.fromRGB(255,200,50),13)

lbl(myGuild,"Members:",UDim2.new(1,0,0,16),UDim2.new(0,0,0,70),Color3.fromRGB(180,180,180),13)
local memberList=Instance.new("Frame"); memberList.Size=UDim2.new(1,0,0,200)
memberList.Position=UDim2.new(0,0,0,90); memberList.BackgroundTransparency=1; memberList.Parent=myGuild
local ml=Instance.new("UIListLayout"); ml.Padding=UDim.new(0,4); ml.Parent=memberList

local leaveBtn=Instance.new("TextButton"); leaveBtn.Size=UDim2.new(1,0,0,36)
leaveBtn.Position=UDim2.new(0,0,1,-40); leaveBtn.BackgroundColor3=Color3.fromRGB(150,30,30)
leaveBtn.TextColor3=Color3.fromRGB(255,255,255); leaveBtn.Font=Enum.Font.GothamBold
leaveBtn.TextSize=14; leaveBtn.Text="LEAVE WARBAND"; leaveBtn.BorderSizePixel=0; leaveBtn.Parent=myGuild
local lrbc=Instance.new("UICorner"); lrbc.CornerRadius=UDim.new(0,8); lrbc.Parent=leaveBtn
leaveBtn.MouseButton1Click:Connect(function()
	Remotes.LeaveGuild:FireServer()
end)

local function showMyGuild(guildData)
	noGuild.Visible=false; myGuild.Visible=true
	guildNameLbl.Text=guildData.name
	guildFacLbl.Text=guildData.faction
	guildFacLbl.TextColor3=guildData.faction=="Viltrumite Empire"
		and Color3.fromRGB(255,80,80) or Color3.fromRGB(80,150,255)
	guildScoreLbl.Text="Conquest Score: "..math.floor(guildData.conquestScore or 0)
	-- Members
	for _,c in ipairs(memberList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for i,uid in ipairs(guildData.members) do
		local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,30)
		row.BackgroundColor3=Color3.fromRGB(20,20,35); row.BorderSizePixel=0; row.Parent=memberList
		local rrc=Instance.new("UICorner"); rrc.CornerRadius=UDim.new(0,6); rrc.Parent=row
		local ml2=Instance.new("TextLabel"); ml2.Size=UDim2.new(1,-50,1,0)
		ml2.Position=UDim2.new(0,10,0,0); ml2.BackgroundTransparency=1
		ml2.TextColor3=uid==player.UserId and Color3.fromRGB(255,220,100) or Color3.fromRGB(200,200,200)
		ml2.Font=Enum.Font.GothamBold; ml2.TextSize=12
		ml2.Text= (uid==guildData.leader and "[Leader] " or "") .. tostring(uid)
		ml2.TextXAlignment=Enum.TextXAlignment.Left; ml2.Parent=row
	end
	-- Badge
	badge.Visible=true
	badgeLbl.Text="["..guildData.faction:sub(1,1).."] "..guildData.name
	badgeLbl.TextColor3=guildData.faction=="Viltrumite Empire"
		and Color3.fromRGB(255,100,100) or Color3.fromRGB(100,160,255)
end

local function showNoGuild()
	myGuild.Visible=false; noGuild.Visible=true
	badge.Visible=false; currentGuild=nil
end

-- ── Toggle ────────────────────────────────────────────────────────

local isOpen=false
local function toggle()
	isOpen=not isOpen
	if isOpen then
		panel.Visible=true
		panel.Size=UDim2.new(0,20,0,20); panel.Position=UDim2.new(0.5,-10,0.5,-10)
		TweenService:Create(panel,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
			{Size=UDim2.new(0,460,0,480),Position=UDim2.new(0.5,-230,0.5,-240)}):Play()
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
	if input.KeyCode==Enum.KeyCode.H then toggle() end  -- H for Horde/warband (G conflicts with ThoraxStrike)
end)

-- ── Remotes ───────────────────────────────────────────────────────

Remotes.GuildJoined.OnClientEvent:Connect(function(guildData)
	currentGuild=guildData; showMyGuild(guildData)
end)
Remotes.GuildLeft.OnClientEvent:Connect(function()
	showNoGuild()
end)
Remotes.GuildInfo.OnClientEvent:Connect(function(guildData)
	if currentGuild and guildData.name==currentGuild.name then
		currentGuild=guildData; showMyGuild(guildData)
	end
end)
Remotes.GuildDisbanded.OnClientEvent:Connect(function(guildName)
	if currentGuild and currentGuild.name==guildName then showNoGuild() end
end)
