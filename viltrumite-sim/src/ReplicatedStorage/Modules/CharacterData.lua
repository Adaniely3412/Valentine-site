local CharacterData = {}

CharacterData.Characters = {

	["Omni-Man"] = {
		displayName  = "Omni-Man / Nolan Grayson",
		powerLevel   = 800000,
		bloodline    = "Pure Viltrumite",
		health       = 50000,
		isViltrumite = true,
		isBoss       = true,
		bossRank     = 3,
		faction      = "Viltrumite Empire",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush","EarthShatter","ThoraxStrike" },
		description  = "The greatest superhero on Earth. Or so everyone thought.",
		dialogue = {
			spawn    = { "Think, Mark. Think about what you're doing.", "I gave everything for this planet.", "You want to fight me? After all I've taught you?" },
			combat   = { "Is that all you've got?", "You call that a hit?", "I've fought armies, boy." },
			lowHP    = { "Fine. You've earned this.", "I underestimated you.", "You're stronger than I thought." },
			victory  = { "It didn't have to be this way.", "This is for the Empire." },
			defeated = { "This... changes things.", "Impressive. Truly." },
		},
		rewards = { xp = 50000, title = "Defeated Omni-Man", cosmetic = "Omni-Man Mustache" },
	},

	["Thragg"] = {
		displayName  = "Grand Regent Thragg",
		powerLevel   = 1200000,
		bloodline    = "Pure Viltrumite",
		health       = 80000,
		isViltrumite = true,
		isBoss       = true,
		bossRank     = 5,
		faction      = "Viltrumite Empire",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush","EarthShatter","ThoraxStrike","SupremeOverdrive" },
		description  = "Grand Regent of the Viltrumite Empire. Undefeated in recorded combat.",
		dialogue = {
			spawn    = { "The Empire does not yield.", "You dare challenge me?", "Your species is beneath me." },
			combat   = { "Pathetic.", "This is the strength of Earth?", "You tire me." },
			lowHP    = { "Impossible.", "This cannot be.", "I will not fall to a lesser being." },
			victory  = { "As expected.", "The Empire endures." },
			defeated = { "*coughs blood* The line of Argall... runs strong." },
		},
		rewards = { xp = 150000, title = "Grand Slayer", cosmetic = "Thragg Cape" },
	},

	["Conquest"] = {
		displayName  = "Conquest",
		powerLevel   = 950000,
		bloodline    = "Pure Viltrumite",
		health       = 60000,
		isViltrumite = true,
		isBoss       = true,
		bossRank     = 4,
		faction      = "Viltrumite Empire",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush","EarthShatter","ThoraxStrike" },
		description  = "A seasoned Viltrumite warrior. One eye. Built like a nightmare.",
		dialogue = {
			spawn    = { "I've conquered a thousand worlds.", "Your pain will be brief. Or not.", "Show me you're worth my time." },
			combat   = { "Come on then!", "I've lost limbs before.", "That barely tickled." },
			lowHP    = { "Ha! Good hit!", "I'm starting to enjoy this.", "Now THAT is a fight!" },
			victory  = { "Another world, another casualty.", "Fall. It's easier." },
			defeated = { "*laughs* You actually did it. Well done, warrior." },
		},
		rewards = { xp = 80000, title = "Conqueror's Bane", cosmetic = "Conquest Eye Patch" },
	},

	["Cecil Stedman"] = {
		displayName  = "Cecil Stedman",
		powerLevel   = 500,
		bloodline    = "Human",
		health       = 5000,
		isViltrumite = false,
		isBoss       = false,
		isNPC        = true,
		faction      = "GDA",
		moves        = {},
		description  = "Director of the Global Defense Agency. Never underestimate him.",
		dialogue = {
			interact = { "We have a situation.", "Every move is calculated, kid.", "I do what's necessary." },
		},
		questGiver = true,
		quests = { "Viltrumite Intel", "GDA Contracts", "Earth's Last Defense" },
	},

	["Mark Grayson"] = {
		displayName  = "Invincible / Mark Grayson",
		powerLevel   = 200000,
		bloodline    = "Half-Blood Viltrumite",
		health       = 20000,
		isViltrumite = false,
		isBoss       = false,
		isNPC        = true,
		faction      = "Earth Defenders",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush" },
		description  = "Son of Omni-Man. Still learning what he's capable of.",
		dialogue = {
			interact = { "I'm still figuring this out.", "My dad... I don't want to be like him.", "Let's do this." },
		},
	},

	["Atom Eve"] = {
		displayName     = "Atom Eve",
		powerLevel      = 300000,
		bloodline       = "Enhanced Human",
		health          = 15000,
		isViltrumite    = false,
		isBoss          = false,
		isNPC           = true,
		faction         = "Earth Defenders",
		moves           = {},
		description     = "Matter manipulator. One of the most powerful heroes on Earth.",
		specialAbility  = "MatterManipulation",
		dialogue = {
			interact = { "Matter is just energy you haven't shaped yet.", "I can help.", "Stay behind me." },
		},
	},

	["Allen the Alien"] = {
		displayName  = "Allen the Alien",
		powerLevel   = 600000,
		bloodline    = "Enhanced Human",
		health       = 35000,
		isViltrumite = false,
		isBoss       = false,
		isNPC        = true,
		faction      = "Coalition of Planets",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","ViltrumiteRush" },
		description  = "Coalition evaluator. Gets stronger with every injury.",
		dialogue = {
			interact = { "Hey! Invincible!", "I keep getting stronger. It's great.", "The Coalition sends their regards." },
		},
	},

	["Immortal"] = {
		displayName  = "The Immortal",
		powerLevel   = 400000,
		bloodline    = "Enhanced Human",
		health       = 30000,
		isViltrumite = false,
		isBoss       = true,
		bossRank     = 2,
		faction      = "Earth Defenders",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush" },
		description  = "He cannot die. Lincoln's secret. America's longest grudge.",
		dialogue = {
			spawn    = { "I've died before. Didn't take.", "You're in for a very long fight." },
			combat   = { "I've beaten gods.", "Pain is just memory." },
			lowHP    = { "I'll be back.", "Kill me. I dare you." },
			defeated = { "*respawns in 10 seconds*" },
		},
		rewards = { xp = 30000, title = "Unkillable", cosmetic = "Immortal Beard" },
		respawnImmune = true,
	},
}

function CharacterData.Get(name)
	return CharacterData.Characters[name]
end

function CharacterData.GetBosses()
	local out = {}
	for name, data in pairs(CharacterData.Characters) do
		if data.isBoss then out[name] = data end
	end
	return out
end

function CharacterData.GetByFaction(faction)
	local out = {}
	for name, data in pairs(CharacterData.Characters) do
		if data.faction == faction then out[name] = data end
	end
	return out
end

return CharacterData
