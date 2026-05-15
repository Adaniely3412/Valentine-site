local BloodlineData = {}

BloodlineData.Bloodlines = {
	["Pure Viltrumite"] = {
		rarity             = "Legendary",
		statMult           = 2.5,
		speedMult          = 2.5,
		durabilityMult     = 3.0,
		maxPowerLevel      = 2000000,
		regenRate          = 5,
		passives           = { "Invincible Durability", "Supersonic Flight", "Bone Crusher", "Rapid Regeneration" },
		auraColor          = Color3.fromRGB(255, 30, 30),
		description        = "The pinnacle of Viltrumite genetics. Nearly unstoppable.",
		startingPL         = 50000,
	},
	["Half-Blood Viltrumite"] = {
		rarity             = "Rare",
		statMult           = 1.7,
		speedMult          = 1.8,
		durabilityMult     = 1.9,
		maxPowerLevel      = 800000,
		regenRate          = 2,
		passives           = { "Viltrumite Heritage", "Enhanced Durability" },
		auraColor          = Color3.fromRGB(200, 80, 255),
		description        = "Carries Viltrumite blood. The power is dormant but growing.",
		startingPL         = 10000,
	},
	["Viltrumite Descendant"] = {
		rarity             = "Uncommon",
		statMult           = 1.3,
		speedMult          = 1.4,
		durabilityMult     = 1.3,
		maxPowerLevel      = 200000,
		regenRate          = 1,
		passives           = { "Ancient Blood" },
		auraColor          = Color3.fromRGB(100, 150, 255),
		description        = "A distant descendant of Viltrumite heritage.",
		startingPL         = 1000,
	},
	["Enhanced Human"] = {
		rarity             = "Uncommon",
		statMult           = 1.1,
		speedMult          = 1.2,
		durabilityMult     = 1.1,
		maxPowerLevel      = 50000,
		regenRate          = 0.5,
		passives           = { "Peak Human" },
		auraColor          = Color3.fromRGB(100, 255, 150),
		description        = "A human pushed beyond normal limits.",
		startingPL         = 100,
	},
	["Human"] = {
		rarity             = "Common",
		statMult           = 1.0,
		speedMult          = 1.0,
		durabilityMult     = 1.0,
		maxPowerLevel      = 10000,
		regenRate          = 0.3,
		passives           = {},
		auraColor          = Color3.fromRGB(200, 200, 200),
		description        = "An ordinary human. Every legend starts somewhere.",
		startingPL         = 0,
	},
}

function BloodlineData.Roll(weights)
	local total = 0
	for _, w in pairs(weights) do total = total + w end
	local roll = math.random(1, total)
	local cumulative = 0
	for bloodline, weight in pairs(weights) do
		cumulative = cumulative + weight
		if roll <= cumulative then return bloodline end
	end
	return "Human"
end

function BloodlineData.Get(name)
	return BloodlineData.Bloodlines[name] or BloodlineData.Bloodlines["Human"]
end

return BloodlineData
