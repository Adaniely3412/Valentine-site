-- Cosmetic Shop UI — opened via button in the HUD.
-- Shows all costumes with unlock status; lets players equip owned ones.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes      = ReplicatedStorage:WaitForChild("Remotes")
local CosmeticData = require(ReplicatedStorage.Modules.CosmeticData)

local ownedMap = {}   -- [costumeName] = bool
local currentEquipped = "Default"

-- ── Fetch ownership from server ───────────────────────────────────
local GetOwnedCosmetics = Remotes:WaitForChild("GetOwnedCosmetics")
task.spawn(function()
	task.wait(1.5)
	local ok, result = pcall(function()
		return GetOwnedCosmetics:InvokeServer()
	end)
	if ok and result then ownedMap = result end
end)

-- ── ScreenGui ────────────────────────────────────────────────────

local sg = Instance.new("ScreenGui")
sg.Name           = "CosmeticShop"
sg.ResetOnSpawn   = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = playerGui

-- ── Shop button (bottom-right) ────────────────────────────────────

local shopBtn         = Instance.new("TextButton")
shopBtn.Name          = "ShopButton"
shopBtn.Size          = UDim2.new(0, 90, 0, 36)
shopBtn.Position      = UDim2.new(1, -108, 1, -58)
shopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
shopBtn.TextColor3    = Color3.fromRGB(255, 200, 50)
shopBtn.Font          = Enum.Font.GothamBold
shopBtn.TextSize      = 15
shopBtn.Text          = "WARDROBE"
shopBtn.BorderSizePixel = 0
shopBtn.Parent        = sg

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = shopBtn

-- ── Main shop panel ───────────────────────────────────────────────

local panel           = Instance.new("Frame")
panel.Name            = "ShopPanel"
panel.Size            = UDim2.new(0, 560, 0, 440)
panel.Position        = UDim2.new(0.5, -280, 0.5, -220)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Visible         = false
panel.Parent          = sg

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

-- Title bar
local titleBar           = Instance.new("Frame")
titleBar.Size            = UDim2.new(1, 0, 0, 46)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent          = panel
local titleCorner = Instance.new("UICorner"); titleCorner.CornerRadius = UDim.new(0,12); titleCorner.Parent = titleBar

local titleLabel           = Instance.new("TextLabel")
titleLabel.Size            = UDim2.new(1, -60, 1, 0)
titleLabel.Position        = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3      = Color3.fromRGB(255, 200, 50)
titleLabel.Font            = Enum.Font.GothamBold
titleLabel.TextSize        = 18
titleLabel.Text            = "WARDROBE"
titleLabel.TextXAlignment  = Enum.TextXAlignment.Left
titleLabel.Parent          = titleBar

-- Close button
local closeBtn            = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 34, 0, 34)
closeBtn.Position         = UDim2.new(1, -42, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 18
closeBtn.Text             = "✕"
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = titleBar
local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0,8); closeCorner.Parent = closeBtn

-- Scroll frame for costume grid
local scroll              = Instance.new("ScrollingFrame")
scroll.Size               = UDim2.new(1, -20, 1, -56)
scroll.Position           = UDim2.new(0, 10, 0, 52)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel    = 0
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 50)
scroll.CanvasSize         = UDim2.new(0, 0, 0, 0)  -- auto-set below
scroll.Parent             = panel

local grid = Instance.new("UIGridLayout")
grid.CellSize    = UDim2.new(0, 158, 0, 180)
grid.CellPadding = UDim2.new(0, 10, 0, 10)
grid.SortOrder   = Enum.SortOrder.LayoutOrder
grid.Parent      = scroll

-- ── Build costume cards ───────────────────────────────────────────

local function buildCard(costumeName, costumeInfo)
	local card             = Instance.new("Frame")
	card.Name              = costumeName
	card.BackgroundColor3  = Color3.fromRGB(22, 22, 32)
	card.BorderSizePixel   = 0
	card.LayoutOrder       = costumeInfo.rarity == "Legendary" and 1 or
	                         costumeInfo.rarity == "Epic"      and 2 or
	                         costumeInfo.rarity == "Rare"      and 3 or 4
	card.Parent            = scroll

	local cardCorner = Instance.new("UICorner"); cardCorner.CornerRadius = UDim.new(0,10); cardCorner.Parent = card

	-- Color swatch preview
	local swatch           = Instance.new("Frame")
	swatch.Size            = UDim2.new(1, -16, 0, 78)
	swatch.Position        = UDim2.new(0, 8, 0, 8)
	swatch.BackgroundColor3 = BrickColor.new(costumeInfo.bodyColor.torso).Color
	swatch.BorderSizePixel = 0
	swatch.Parent          = card
	local swatchCorner = Instance.new("UICorner"); swatchCorner.CornerRadius = UDim.new(0,8); swatchCorner.Parent = swatch

	-- Rarity stripe
	local stripe            = Instance.new("Frame")
	stripe.Size             = UDim2.new(1, 0, 0, 3)
	stripe.Position         = UDim2.new(0, 0, 1, -3)
	stripe.BackgroundColor3 = CosmeticData.RarityColors[costumeInfo.rarity] or Color3.fromRGB(200,200,200)
	stripe.BorderSizePixel  = 0
	stripe.Parent           = swatch

	-- Costume name
	local nameLabel           = Instance.new("TextLabel")
	nameLabel.Size            = UDim2.new(1, -8, 0, 20)
	nameLabel.Position        = UDim2.new(0, 4, 0, 90)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3      = Color3.fromRGB(255, 255, 255)
	nameLabel.Font            = Enum.Font.GothamBold
	nameLabel.TextSize        = 12
	nameLabel.Text            = costumeInfo.displayName
	nameLabel.TextWrapped     = true
	nameLabel.TextXAlignment  = Enum.TextXAlignment.Left
	nameLabel.Parent          = card

	-- Rarity label
	local rarityLabel          = Instance.new("TextLabel")
	rarityLabel.Size           = UDim2.new(1, -8, 0, 14)
	rarityLabel.Position       = UDim2.new(0, 4, 0, 112)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.TextColor3     = CosmeticData.RarityColors[costumeInfo.rarity] or Color3.fromRGB(200,200,200)
	rarityLabel.Font           = Enum.Font.GothamBold
	rarityLabel.TextSize       = 11
	rarityLabel.Text           = costumeInfo.rarity:upper()
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.Parent         = card

	-- Equip / locked button
	local equipBtn            = Instance.new("TextButton")
	equipBtn.Name             = "EquipBtn"
	equipBtn.Size             = UDim2.new(1, -16, 0, 28)
	equipBtn.Position         = UDim2.new(0, 8, 0, 144)
	equipBtn.BorderSizePixel  = 0
	equipBtn.Font             = Enum.Font.GothamBold
	equipBtn.TextSize         = 13
	equipBtn.Parent           = card
	local eCorner = Instance.new("UICorner"); eCorner.CornerRadius = UDim.new(0,6); eCorner.Parent = equipBtn

	local function refreshCard()
		local owned    = ownedMap[costumeName] or false
		local equipped = currentEquipped == costumeName
		if equipped then
			equipBtn.Text             = "EQUIPPED"
			equipBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
			equipBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
			equipBtn.Active           = false
			card.BackgroundColor3     = Color3.fromRGB(28, 38, 28)
		elseif owned then
			equipBtn.Text             = "EQUIP"
			equipBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
			equipBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
			equipBtn.Active           = true
			card.BackgroundColor3     = Color3.fromRGB(22, 22, 32)
		else
			equipBtn.Text             = "LOCKED"
			equipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			equipBtn.TextColor3       = Color3.fromRGB(150, 150, 150)
			equipBtn.Active           = false
			card.BackgroundColor3     = Color3.fromRGB(18, 18, 24)
		end
	end

	refreshCard()

	equipBtn.MouseButton1Click:Connect(function()
		if not (ownedMap[costumeName] or false) then return end
		currentEquipped = costumeName
		Remotes.EquipCosmetic:FireServer(costumeName)
		-- Refresh all cards
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then
				local btn = child:FindFirstChild("EquipBtn")
				if btn then
					local TweenService2 = TweenService
					-- trigger refresh by re-calling per card
				end
			end
		end
		refreshCard()
		-- Re-refresh siblings
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") and child.Name ~= costumeName then
				local btn = child:FindFirstChild("EquipBtn")
				if btn then
					local cn = child.Name
					local info = CosmeticData.Get(cn)
					if info then
						local ownedSib = ownedMap[cn] or false
						if cn == currentEquipped then
							btn.Text             = "EQUIPPED"
							btn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
							child.BackgroundColor3 = Color3.fromRGB(28,38,28)
						elseif ownedSib then
							btn.Text             = "EQUIP"
							btn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
							child.BackgroundColor3 = Color3.fromRGB(22,22,32)
						end
					end
				end
			end
		end
	end)

	return card
end

-- Populate cards
local ORDER = { "Legendary", "Epic", "Rare", "Uncommon", "Common" }
local sorted = {}
for name, info in pairs(CosmeticData.Costumes) do
	table.insert(sorted, { name = name, info = info })
end
table.sort(sorted, function(a, b)
	local ai, bi = 99, 99
	for i, r in ipairs(ORDER) do
		if a.info.rarity == r then ai = i end
		if b.info.rarity == r then bi = i end
	end
	return ai < bi
end)
for _, entry in ipairs(sorted) do
	buildCard(entry.name, entry.info)
end

-- Set canvas height
local rows = math.ceil(#sorted / 3)
scroll.CanvasSize = UDim2.new(0, 0, 0, rows * 190 + 10)

-- ── Toggle shop ───────────────────────────────────────────────────

local shopOpen = false

local function toggleShop()
	shopOpen = not shopOpen
	if shopOpen then
		-- Refresh ownership
		task.spawn(function()
			local ok, result = pcall(function()
				return GetOwnedCosmetics:InvokeServer()
			end)
			if ok and result then
				ownedMap = result
			end
		end)
		panel.Visible = true
		panel.Size    = UDim2.new(0, 20, 0, 20)
		panel.Position = UDim2.new(0.5, -10, 0.5, -10)
		TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0,560,0,440), Position = UDim2.new(0.5,-280,0.5,-220) }):Play()
	else
		TweenService:Create(panel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Size = UDim2.new(0,20,0,20), Position = UDim2.new(0.5,-10,0.5,-10) }):Play()
		task.delay(0.16, function() panel.Visible = false end)
	end
end

shopBtn.MouseButton1Click:Connect(toggleShop)
closeBtn.MouseButton1Click:Connect(toggleShop)

-- Update costume state from server
Remotes.CostumeChanged.OnClientEvent:Connect(function(changedPlayer, costumeName)
	if changedPlayer == player then
		currentEquipped = costumeName
	end
end)
