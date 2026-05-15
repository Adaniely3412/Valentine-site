local QuestData = {}

-- Objective types:
--   hits       → land N hits total
--   kills      → kill N players or bosses
--   defeat_boss → defeat a specific boss (target = name or nil for any)
--   reach_pl   → reach a power level threshold
--   hold_zones → hold N conquest zones simultaneously (checked on capture events)

QuestData.Quests = {
	first_blood = {
		id          = "first_blood",
		name        = "First Blood",
		description = "The world is at war. Prove you belong on the battlefield.",
		giver       = "Cecil Stedman",
		dialogue    = "I need to know you're combat-ready. Show me.",
		objectives  = {
			{ id="hits", type="hits", required=10, description="Land 10 hits" },
		},
		rewards     = { xp=5000, notification="Cecil: Not bad. You're ready for more." },
		prereqs     = {},
		next        = "gda_contracts",
	},

	gda_contracts = {
		id          = "gda_contracts",
		name        = "GDA Contracts",
		description = "Viltrumite sightings confirmed. Take one of them out.",
		giver       = "Cecil Stedman",
		dialogue    = "There's a Viltrumite in our backyard. I need it handled. Now.",
		objectives  = {
			{ id="boss_kill", type="defeat_boss", target=nil, required=1, description="Defeat any Boss" },
		},
		rewards     = { xp=20000, costume="GDA Agent Suit", notification="Cecil: Impressive. The GDA has use for someone like you." },
		prereqs     = { "first_blood" },
		next        = "viltrumite_intel",
	},

	viltrumite_intel = {
		id          = "viltrumite_intel",
		name        = "Viltrumite Intel",
		description = "Grow stronger. We need you at your absolute best.",
		giver       = "Cecil Stedman",
		dialogue    = "Power level isn't everything. But when fighting Viltrumites, it really, really helps.",
		objectives  = {
			{ id="pl_10k", type="reach_pl", required=10000, description="Reach Power Level 10,000" },
		},
		rewards     = { xp=30000, powerLevel=2000, title="Rising Warrior", notification="Cecil: Now we're in business." },
		prereqs     = { "gda_contracts" },
		next        = "earth_defense",
	},

	earth_defense = {
		id          = "earth_defense",
		name        = "Earth's Last Defense",
		description = "Show the Viltrumite Empire that Earth won't be conquered without a fight.",
		giver       = "Cecil Stedman",
		dialogue    = "I need all three strategic zones under our control. Simultaneously. Make it happen.",
		objectives  = {
			{ id="zones", type="hold_zones", required=3, description="Control all 3 conquest zones" },
		},
		rewards     = { xp=50000, powerLevel=5000, title="Earth's Champion", notification="Cecil: Earth is in good hands." },
		prereqs     = { "viltrumite_intel" },
		next        = "omni_man_problem",
	},

	omni_man_problem = {
		id          = "omni_man_problem",
		name        = "The Omni-Man Problem",
		description = "Nolan Grayson. The greatest hero Earth ever had. Now our biggest threat.",
		giver       = "Cecil Stedman",
		dialogue    = "He's stronger than anything we've faced. I don't care how you do it. Stop him.",
		objectives  = {
			{ id="kill_omni", type="defeat_boss", target="Omni-Man", required=1, description="Defeat Omni-Man" },
		},
		rewards     = { xp=80000, costume="Omni-Man Costume", title="Defeated Omni-Man", notification="Cecil: Impossible. But here we are." },
		prereqs     = { "earth_defense" },
		next        = "conqueror",
	},

	conqueror = {
		id          = "conqueror",
		name        = "Conqueror",
		description = "Conquest has made landfall on Earth. Stop him before he tears this planet apart.",
		giver       = "Cecil Stedman",
		dialogue    = "He's beaten entire civilisations. You're up. Don't embarrass me.",
		objectives  = {
			{ id="kill_conquest", type="defeat_boss", target="Conquest", required=1, description="Defeat Conquest" },
		},
		rewards     = { xp=100000, title="Conqueror's Bane", notification="Cecil: Even Conquest couldn't stop you." },
		prereqs     = { "omni_man_problem" },
		next        = "thragg_end",
	},

	thragg_end = {
		id          = "thragg_end",
		name        = "Thragg's End",
		description = "Grand Regent Thragg. The strongest Viltrumite who ever lived.",
		giver       = "Cecil Stedman",
		dialogue    = "Kill Thragg and the Empire fractures. This is the mission that ends the war.",
		objectives  = {
			{ id="kill_thragg", type="defeat_boss", target="Thragg", required=1, description="Defeat Grand Regent Thragg" },
		},
		rewards     = { xp=200000, powerLevel=20000, title="Grand Slayer", costume="Thragg Cape", notification="Cecil: The Empire is broken." },
		prereqs     = { "conqueror" },
		next        = "viltrumite_awakening",
	},

	viltrumite_awakening = {
		id          = "viltrumite_awakening",
		name        = "Viltrumite Awakening",
		description = "Reach the power level of a true, pure-blooded Viltrumite.",
		giver       = "Cecil Stedman",
		dialogue    = "100,000 power level. That's the threshold. Cross it.",
		objectives  = {
			{ id="pl_100k", type="reach_pl", required=100000, description="Reach Power Level 100,000" },
		},
		rewards     = { xp=50000, costume="Viltrumite Battle Armor", title="True Viltrumite", notification="Cecil: You're no longer human. Not sure if that's good or bad." },
		prereqs     = { "thragg_end" },
		next        = "supreme_being",
	},

	supreme_being = {
		id          = "supreme_being",
		name        = "Supreme Being",
		description = "One million. Pure Viltrumite. The absolute pinnacle of power.",
		giver       = "Cecil Stedman",
		dialogue    = "If you hit 1,000,000... I genuinely don't know what you become.",
		objectives  = {
			{ id="pl_1m", type="reach_pl", required=1000000, description="Reach Power Level 1,000,000" },
		},
		rewards     = { xp=0, title="Supreme Viltrumite", costume="Pure White Viltrumite", notification="Cecil: ...I have no words." },
		prereqs     = { "viltrumite_awakening" },
		next        = nil,
	},
}

-- Returns quests whose prerequisites are met and that are not yet completed.
function QuestData.GetAvailable(completedSet)
	local out = {}
	for id, q in pairs(QuestData.Quests) do
		if completedSet[id] then continue end
		local prereqOk = true
		for _, pid in ipairs(q.prereqs) do
			if not completedSet[pid] then prereqOk = false; break end
		end
		if prereqOk then table.insert(out, q) end
	end
	return out
end

function QuestData.Get(id)
	return QuestData.Quests[id]
end

return QuestData
