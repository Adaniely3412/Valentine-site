local CosmeticData = {}

-- bodyColor fields map to BrickColor names applied to character parts
CosmeticData.Costumes = {
	["Default"] = {
		displayName  = "Default",
		rarity       = "Common",
		unlockMethod = "default",
		bodyColor    = { torso = "Medium stone grey", limbs = "Medium stone grey", head = "Pastel orange" },
		description  = "Standard issue.",
	},
	["Invincible Suit"] = {
		displayName  = "Invincible Suit",
		rarity       = "Rare",
		unlockMethod = "default",
		bodyColor    = { torso = "Bright blue", limbs = "Bright blue", head = "Pastel orange" },
		description  = "Blue and yellow. Classic.",
	},
	["Viltrumite Battle Armor"] = {
		displayName  = "Viltrumite Battle Armor",
		rarity       = "Rare",
		unlockMethod = { type = "powerLevel", value = 100000 },
		bodyColor    = { torso = "Crimson", limbs = "Dark red", head = "Pastel orange" },
		description  = "Reach PL 100,000 to unlock.",
	},
	["Omni-Man Costume"] = {
		displayName  = "Omni-Man Costume",
		rarity       = "Epic",
		unlockMethod = { type = "title", value = "Defeated Omni-Man" },
		bodyColor    = { torso = "Bright green", limbs = "Bright green", head = "Pastel orange" },
		description  = "Defeat Omni-Man to earn this.",
	},
	["Thragg Cape"] = {
		displayName  = "Thragg Cape",
		rarity       = "Legendary",
		unlockMethod = { type = "title", value = "Grand Slayer" },
		bodyColor    = { torso = "Dark red", limbs = "Crimson", head = "Pastel orange" },
		description  = "Defeat Grand Regent Thragg.",
	},
	["Conquest Eye Patch"] = {
		displayName  = "Conquest Eye Patch",
		rarity       = "Epic",
		unlockMethod = { type = "title", value = "Conqueror's Bane" },
		bodyColor    = { torso = "Dark orange", limbs = "Earth orange", head = "Pastel orange" },
		description  = "Defeat Conquest.",
	},
	["GDA Agent Suit"] = {
		displayName  = "GDA Agent Suit",
		rarity       = "Uncommon",
		unlockMethod = "default",
		bodyColor    = { torso = "Dark stone grey", limbs = "Black", head = "Pastel orange" },
		description  = "Cecil approves.",
	},
	["Pure White Viltrumite"] = {
		displayName  = "Pure White Viltrumite",
		rarity       = "Legendary",
		unlockMethod = { type = "powerLevel", value = 1000000 },
		bodyColor    = { torso = "White", limbs = "White", head = "Pastel orange" },
		description  = "Reach Pure Viltrumite tier.",
	},
}

CosmeticData.RarityColors = {
	Common    = Color3.fromRGB(200, 200, 200),
	Uncommon  = Color3.fromRGB(100, 220, 100),
	Rare      = Color3.fromRGB(100, 150, 255),
	Epic      = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 200, 50),
}

function CosmeticData.IsUnlocked(costumeName, playerData)
	local c = CosmeticData.Costumes[costumeName]
	if not c then return false end
	if c.unlockMethod == "default" then return true end
	if type(c.unlockMethod) == "table" then
		local m = c.unlockMethod
		if m.type == "powerLevel" then
			return (playerData.powerLevel or 0) >= m.value
		elseif m.type == "title" then
			for _, t in ipairs(playerData.titles or {}) do
				if t == m.value then return true end
			end
			return false
		end
	end
	return false
end

function CosmeticData.Get(name)
	return CosmeticData.Costumes[name]
end

return CosmeticData
