-- Quest tracker HUD (right side) + Cecil dialog popup.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")
local QuestData = require(ReplicatedStorage.Modules.QuestData)

-- ── ScreenGui ────────────────────────────────────────────────────

local sg = Instance.new("ScreenGui")
sg.Name           = "QuestUI"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = playerGui

-- ── Quest Tracker Panel (right side) ─────────────────────────────

local tracker          = Instance.new("Frame")
tracker.Name           = "Tracker"
tracker.Size           = UDim2.new(0, 240, 0, 300)
tracker.Position       = UDim2.new(1, -258, 0, 200)
tracker.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
tracker.BackgroundTransparency = 0.35
tracker.BorderSizePixel = 0
tracker.Parent         = sg
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0,10); tc.Parent = tracker

local trackerTitle     = Instance.new("TextLabel")
trackerTitle.Size      = UDim2.new(1,0,0,28)
trackerTitle.Position  = UDim2.new(0,0,0,0)
trackerTitle.BackgroundColor3 = Color3.fromRGB(20,20,35)
trackerTitle.BackgroundTransparency = 0
trackerTitle.BorderSizePixel = 0
trackerTitle.TextColor3 = Color3.fromRGB(255,200,50)
trackerTitle.Font      = Enum.Font.GothamBold
trackerTitle.TextSize  = 13
trackerTitle.Text      = "ACTIVE QUESTS"
trackerTitle.Parent    = tracker
local ttc = Instance.new("UICorner"); ttc.CornerRadius = UDim.new(0,10); ttc.Parent = trackerTitle

local questList        = Instance.new("ScrollingFrame")
questList.Size         = UDim2.new(1,-8,1,-34)
questList.Position     = UDim2.new(0,4,0,30)
questList.BackgroundTransparency = 1
questList.BorderSizePixel = 0
questList.ScrollBarThickness = 4
questList.ScrollBarImageColor3 = Color3.fromRGB(255,200,50)
questList.CanvasSize   = UDim2.new(0,0,0,0)
questList.Parent       = tracker

local ql = Instance.new("UIListLayout")
ql.Padding        = UDim.new(0,6)
ql.SortOrder      = Enum.SortOrder.LayoutOrder
ql.Parent         = questList

-- Active quests store: { [questId] = { card, progressBars } }
local activeCards = {}

local function makeQuestCard(questDef, progressMap)
	local card             = Instance.new("Frame")
	card.Name              = questDef.id
	card.Size              = UDim2.new(1,0,0,0)  -- height auto-set
	card.AutomaticSize     = Enum.AutomaticSize.Y
	card.BackgroundColor3  = Color3.fromRGB(20,20,32)
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel   = 0
	card.Parent            = questList
	local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = card
	local cp = Instance.new("UIPadding"); cp.PaddingLeft = UDim.new(0,6); cp.PaddingRight = UDim.new(0,6)
	cp.PaddingTop = UDim.new(0,5); cp.PaddingBottom = UDim.new(0,6); cp.Parent = card

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size  = UDim2.new(1,0,0,16)
	titleLbl.BackgroundTransparency = 1
	titleLbl.TextColor3 = Color3.fromRGB(255,220,100)
	titleLbl.Font  = Enum.Font.GothamBold
	titleLbl.TextSize = 12
	titleLbl.Text  = questDef.name
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = card

	local bars = {}
	for i, obj in ipairs(questDef.objectives) do
		local cur = (progressMap and progressMap[obj.id]) or 0

		local descLbl = Instance.new("TextLabel")
		descLbl.Size  = UDim2.new(1,0,0,12)
		descLbl.Position = UDim2.new(0,0,0, 18 + (i-1)*26)
		descLbl.BackgroundTransparency = 1
		descLbl.TextColor3 = Color3.fromRGB(200,200,200)
		descLbl.Font  = Enum.Font.Gotham
		descLbl.TextSize = 11
		descLbl.Text  = obj.description
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.Parent = card

		local barBG = Instance.new("Frame")
		barBG.Size  = UDim2.new(1,0,0,8)
		barBG.Position = UDim2.new(0,0,0, 32 + (i-1)*26)
		barBG.BackgroundColor3 = Color3.fromRGB(40,40,60)
		barBG.BorderSizePixel = 0
		barBG.Parent = card
		local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = barBG

		local pct = math.clamp(cur / obj.required, 0, 1)
		local barFill = Instance.new("Frame")
		barFill.Name  = obj.id
		barFill.Size  = UDim2.new(pct,0,1,0)
		barFill.BackgroundColor3 = Color3.fromRGB(255,180,30)
		barFill.BorderSizePixel = 0
		barFill.Parent = barBG
		local bf = Instance.new("UICorner"); bf.CornerRadius = UDim.new(0,4); bf.Parent = barFill

		local numLbl = Instance.new("TextLabel")
		numLbl.Size  = UDim2.new(1,0,1,0)
		numLbl.BackgroundTransparency = 1
		numLbl.TextColor3 = Color3.fromRGB(255,255,255)
		numLbl.Font  = Enum.Font.Gotham
		numLbl.TextSize = 9
		numLbl.Text  = cur .. " / " .. obj.required
		numLbl.TextXAlignment = Enum.TextXAlignment.Center
		numLbl.Parent = barBG

		bars[obj.id] = { fill = barFill, num = numLbl, required = obj.required }
	end

	-- Set card height
	card.Size = UDim2.new(1,0,0, 22 + #questDef.objectives * 26)
	return card, bars
end

local function refreshCanvas()
	questList.CanvasSize = UDim2.new(0,0,0, ql.AbsoluteContentSize.Y + 10)
end

-- ── Cecil Dialog ──────────────────────────────────────────────────

local dialog          = Instance.new("Frame")
dialog.Name           = "CecilDialog"
dialog.Size           = UDim2.new(0, 480, 0, 340)
dialog.Position       = UDim2.new(0.5,-240,0.5,-170)
dialog.BackgroundColor3 = Color3.fromRGB(10,10,20)
dialog.BackgroundTransparency = 0.1
dialog.BorderSizePixel = 0
dialog.Visible        = false
dialog.Parent         = sg
local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0,12); dc.Parent = dialog

-- Header
local dHeader         = Instance.new("Frame")
dHeader.Size          = UDim2.new(1,0,0,50)
dHeader.BackgroundColor3 = Color3.fromRGB(15,15,30)
dHeader.BorderSizePixel = 0
dHeader.Parent        = dialog
local dhc = Instance.new("UICorner"); dhc.CornerRadius = UDim.new(0,12); dhc.Parent = dHeader

local npcName         = Instance.new("TextLabel")
npcName.Size          = UDim2.new(1,-20,1,0)
npcName.Position      = UDim2.new(0,14,0,0)
npcName.BackgroundTransparency = 1
npcName.TextColor3    = Color3.fromRGB(255,200,50)
npcName.Font          = Enum.Font.GothamBold
npcName.TextSize      = 17
npcName.Text          = "Cecil Stedman — GDA Director"
npcName.TextXAlignment = Enum.TextXAlignment.Left
npcName.Parent        = dHeader

local closeDialog     = Instance.new("TextButton")
closeDialog.Size      = UDim2.new(0,32,0,32)
closeDialog.Position  = UDim2.new(1,-42,0,9)
closeDialog.BackgroundColor3 = Color3.fromRGB(180,30,30)
closeDialog.TextColor3 = Color3.fromRGB(255,255,255)
closeDialog.Font      = Enum.Font.GothamBold
closeDialog.TextSize  = 16
closeDialog.Text      = "✕"
closeDialog.BorderSizePixel = 0
closeDialog.Parent    = dHeader
local clc = Instance.new("UICorner"); clc.CornerRadius = UDim.new(0,8); clc.Parent = closeDialog

-- Quest scroll
local dScroll         = Instance.new("ScrollingFrame")
dScroll.Size          = UDim2.new(1,-16,1,-60)
dScroll.Position      = UDim2.new(0,8,0,56)
dScroll.BackgroundTransparency = 1
dScroll.BorderSizePixel = 0
dScroll.ScrollBarThickness = 5
dScroll.ScrollBarImageColor3 = Color3.fromRGB(255,200,50)
dScroll.CanvasSize    = UDim2.new(0,0,0,0)
dScroll.Parent        = dialog

local dList = Instance.new("UIListLayout")
dList.Padding  = UDim.new(0,8)
dList.SortOrder = Enum.SortOrder.LayoutOrder
dList.Parent   = dScroll

-- ── Remote listeners ─────────────────────────────────────────────

Remotes.QuestAssigned.OnClientEvent:Connect(function(questDef, progressMap)
	if activeCards[questDef.id] then return end
	local card, bars = makeQuestCard(questDef, progressMap)
	activeCards[questDef.id] = { card = card, bars = bars }
	refreshCanvas()
end)

Remotes.QuestProgress.OnClientEvent:Connect(function(questId, objId, current, required)
	local entry = activeCards[questId]
	if not entry then return end
	local bar = entry.bars[objId]
	if not bar then return end
	local pct = math.clamp(current / required, 0, 1)
	TweenService:Create(bar.fill, TweenInfo.new(0.3), { Size = UDim2.new(pct,0,1,0) }):Play()
	bar.num.Text = current .. " / " .. required
end)

Remotes.QuestCompleted.OnClientEvent:Connect(function(questDef)
	local entry = activeCards[questDef.id]
	if entry then
		-- Flash gold then fade out
		TweenService:Create(entry.card, TweenInfo.new(0.3),
			{ BackgroundColor3 = Color3.fromRGB(100,80,0) }):Play()
		task.delay(1.2, function()
			if entry.card and entry.card.Parent then
				TweenService:Create(entry.card, TweenInfo.new(0.4),
					{ BackgroundTransparency = 1 }):Play()
				task.delay(0.5, function()
					if entry.card then entry.card:Destroy() end
				end)
			end
		end)
		activeCards[questDef.id] = nil
	end
	-- Completion toast
	local rewards = questDef.rewards or {}
	local msg = "Quest Complete: " .. questDef.name
	if rewards.notification then msg = rewards.notification end
	local char = player.Character
	if char then char:SetAttribute("NotifMsg", msg) end
end)

Remotes.OpenQuestDialog.OnClientEvent:Connect(function(available, active, completed)
	-- Clear old dialog items
	for _, c in ipairs(dScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local totalHeight = 0

	-- Active quests header
	if #active > 0 then
		local h = Instance.new("TextLabel")
		h.Size = UDim2.new(1,0,0,22); h.BackgroundTransparency=1
		h.TextColor3=Color3.fromRGB(255,200,50); h.Font=Enum.Font.GothamBold
		h.TextSize=13; h.Text="ACTIVE QUESTS"; h.TextXAlignment=Enum.TextXAlignment.Left; h.Parent=dScroll
		totalHeight += 30
		for _, entry in ipairs(active) do
			local q   = entry.quest
			local row = Instance.new("Frame")
			row.Size  = UDim2.new(1,0,0,54)
			row.BackgroundColor3 = Color3.fromRGB(20,20,35)
			row.BorderSizePixel = 0; row.Parent = dScroll
			local rc = Instance.new("UICorner"); rc.CornerRadius=UDim.new(0,8); rc.Parent=row
			local rl = Instance.new("TextLabel"); rl.Size=UDim2.new(1,-12,0,18)
			rl.Position=UDim2.new(0,8,0,6); rl.BackgroundTransparency=1
			rl.TextColor3=Color3.fromRGB(255,220,100); rl.Font=Enum.Font.GothamBold
			rl.TextSize=13; rl.Text=q.name; rl.TextXAlignment=Enum.TextXAlignment.Left; rl.Parent=row
			local rd = Instance.new("TextLabel"); rd.Size=UDim2.new(1,-12,0,28)
			rd.Position=UDim2.new(0,8,0,24); rd.BackgroundTransparency=1
			rd.TextColor3=Color3.fromRGB(180,180,180); rd.Font=Enum.Font.Gotham
			rd.TextSize=11; rd.Text=q.dialogue; rd.TextWrapped=true
			rd.TextXAlignment=Enum.TextXAlignment.Left; rd.Parent=row
			totalHeight += 62
		end
	end

	-- Available quests
	if #available > 0 then
		local h2 = Instance.new("TextLabel")
		h2.Size = UDim2.new(1,0,0,22); h2.BackgroundTransparency=1
		h2.TextColor3=Color3.fromRGB(100,220,100); h2.Font=Enum.Font.GothamBold
		h2.TextSize=13; h2.Text="AVAILABLE QUESTS"; h2.TextXAlignment=Enum.TextXAlignment.Left; h2.Parent=dScroll
		totalHeight += 30
		for _, q in ipairs(available) do
			local row = Instance.new("Frame")
			row.Size  = UDim2.new(1,0,0,72)
			row.BackgroundColor3 = Color3.fromRGB(18,28,18)
			row.BorderSizePixel = 0; row.Parent = dScroll
			local rc = Instance.new("UICorner"); rc.CornerRadius=UDim.new(0,8); rc.Parent=row
			local rn = Instance.new("TextLabel"); rn.Size=UDim2.new(1,-110,0,18)
			rn.Position=UDim2.new(0,8,0,6); rn.BackgroundTransparency=1
			rn.TextColor3=Color3.fromRGB(100,255,100); rn.Font=Enum.Font.GothamBold
			rn.TextSize=13; rn.Text=q.name; rn.TextXAlignment=Enum.TextXAlignment.Left; rn.Parent=row
			local rd2 = Instance.new("TextLabel"); rd2.Size=UDim2.new(1,-12,0,30)
			rd2.Position=UDim2.new(0,8,0,24); rd2.BackgroundTransparency=1
			rd2.TextColor3=Color3.fromRGB(160,160,160); rd2.Font=Enum.Font.Gotham
			rd2.TextSize=11; rd2.Text=q.dialogue; rd2.TextWrapped=true
			rd2.TextXAlignment=Enum.TextXAlignment.Left; rd2.Parent=row
			-- Accept button
			local ab = Instance.new("TextButton")
			ab.Size = UDim2.new(0,90,0,26)
			ab.Position = UDim2.new(1,-98,0,6)
			ab.BackgroundColor3 = Color3.fromRGB(50,150,50)
			ab.TextColor3 = Color3.fromRGB(255,255,255)
			ab.Font = Enum.Font.GothamBold; ab.TextSize=12; ab.Text="ACCEPT"
			ab.BorderSizePixel=0; ab.Parent=row
			local abc = Instance.new("UICorner"); abc.CornerRadius=UDim.new(0,6); abc.Parent=ab
			ab.MouseButton1Click:Connect(function()
				Remotes.AcceptQuest:FireServer(q.id)
				dialog.Visible = false
			end)
			totalHeight += 80
		end
	end

	if #available == 0 and #active == 0 then
		local none = Instance.new("TextLabel"); none.Size=UDim2.new(1,0,0,40)
		none.BackgroundTransparency=1; none.TextColor3=Color3.fromRGB(150,150,150)
		none.Font=Enum.Font.Gotham; none.TextSize=14; none.Text="No quests available."
		none.Parent=dScroll; totalHeight=50
	end

	dScroll.CanvasSize = UDim2.new(0,0,0,totalHeight)
	dialog.Visible = true
end)

closeDialog.MouseButton1Click:Connect(function()
	dialog.Visible = false
end)
