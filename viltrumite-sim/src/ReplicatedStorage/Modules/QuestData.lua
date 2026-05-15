local QuestData = {}

-- Objective types:
--   hits        → land N hits total
--   kills       → kill N players or bosses
--   defeat_boss → defeat a specific boss (target = name or nil for any)
--   reach_pl    → reach a power level threshold
--   hold_zones  → hold N conquest zones simultaneously (checked on capture events)
--
-- All Cecil dialogue written to reflect his canon characterization:
-- cold, calculating, morally unambiguous, genuinely trying to save Earth —
-- by any means necessary.

QuestData.Quests = {

	-- ─────────────────────────────────────────────────────────────────────────
	first_blood = {
		id          = "first_blood",
		name        = "First Blood",
		description = "The Viltrumite Empire has scouts on Earth. "
		           .. "The GDA needs to know you're more than a theory.",
		giver       = "Cecil Stedman",
		dialogue    = "I don't run a training program. I run a defense agency. "
		           .. "The difference is I need results, not potential. "
		           .. "Prove you can land hits on something that hits back. "
		           .. "Ten contacts. Don't come back until it's done.",
		objectives  = {
			{ id="hits", type="hits", required=10, description="Land 10 hits in combat" },
		},
		rewards     = { xp=5000, notification="Cecil: Not bad. You're on the list. That matters more than you think." },
		prereqs     = {},
		next        = "gda_contracts",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	gda_contracts = {
		id          = "gda_contracts",
		name        = "GDA Contracts",
		description = "The Guardians of the Globe are gone. Omni-Man killed them all. "
		           .. "Earth has exactly one active tier-one defensive resource. "
		           .. "That's you. Try to remember that.",
		giver       = "Cecil Stedman",
		dialogue    = "A few months ago I watched Nolan Grayson murder every member of the "
		           .. "Guardians of the Globe in one night. Red Rush. War Woman. Darkwing. "
		           .. "The Immortal — twice, technically. All of them. Gone. "
		           .. "I've rebuilt some things. Not enough. There's a Viltrumite-class "
		           .. "threat active right now. I need it put down. That's what you're for.",
		objectives  = {
			{ id="boss_kill", type="defeat_boss", target=nil, required=1, description="Defeat any Boss" },
		},
		rewards     = { xp=20000, cosmetic="GDA Agent Suit", notification="Cecil: Good work. The GDA has a file on you now. You want that to say 'asset', not 'liability'." },
		prereqs     = { "first_blood" },
		next        = "viltrumite_intel",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	viltrumite_intel = {
		id          = "viltrumite_intel",
		name        = "Viltrumite Intel",
		description = "The Viltrumite Empire spent over a thousand years in a civil war "
		           .. "that killed most of their own population. The survivors are the "
		           .. "strongest beings in the galaxy. You need to be in their weight class.",
		giver       = "Cecil Stedman",
		dialogue    = "Here's what I know about Viltrumites: their Empire spent centuries "
		           .. "culling their own weak. Killed half their species in internal conflict "
		           .. "before the Scourge Virus took most of what was left. Fewer than fifty "
		           .. "pure-blooded Viltrumites alive in the entire universe right now. "
		           .. "Each one is a product of a thousand years of selecting for lethality. "
		           .. "Power level isn't a vanity metric. It's the only measure that means "
		           .. "anything when you're standing in front of one of them. Get to 10,000. "
		           .. "That's not the finish line. That's the starting point.",
		objectives  = {
			{ id="pl_10k", type="reach_pl", required=10000, description="Reach Power Level 10,000" },
		},
		rewards     = { xp=30000, powerLevel=2000, title="Rising Warrior",
		                notification="Cecil: 10,000. You're no longer a liability. You're almost an asset." },
		prereqs     = { "gda_contracts" },
		next        = "earth_defense",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	earth_defense = {
		id          = "earth_defense",
		name        = "Earth's Last Line",
		description = "Three strategic zones. The Grayson Residence, the GDA HQ, and the "
		           .. "Viltrum Outpost. Control all three simultaneously. "
		           .. "The Empire doesn't leave gaps. Neither do we.",
		giver       = "Cecil Stedman",
		dialogue    = "The Viltrumite Empire doesn't conquer planets by being subtle. "
		           .. "They identify strategic infrastructure, eliminate defenders, and move in. "
		           .. "We have three priority zones the moment any Viltrumite force lands on Earth: "
		           .. "the Grayson Residence — yes, Nolan's old house, it's a known Viltrumite "
		           .. "contact point — the GDA headquarters, and the Viltrum Outpost they've "
		           .. "already established. Hold all three simultaneously. "
		           .. "If you can't do that, we've already lost.",
		objectives  = {
			{ id="zones", type="hold_zones", required=3, description="Control all 3 conquest zones at once" },
		},
		rewards     = { xp=50000, powerLevel=5000, title="Earth's Champion",
		                notification="Cecil: All three zones. I didn't think you'd pull it off. I was wrong. That doesn't happen often." },
		prereqs     = { "viltrumite_intel" },
		next        = "omni_man_problem",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	omni_man_problem = {
		id          = "omni_man_problem",
		name        = "The Omni-Man Problem",
		description = "Nolan Grayson lived on Earth for over twenty years. "
		           .. "We trusted him with everything. He murdered the Guardians of the Globe. "
		           .. "He nearly killed his own son. He is a Viltrumite agent and he has to be stopped.",
		giver       = "Cecil Stedman",
		dialogue    = "Nolan Grayson. Code name Omni-Man. Over two thousand years old. "
		           .. "He spent twenty years building trust on this planet. Teaching at schools. "
		           .. "Saving people from burning buildings. Raising a son. And then one night he "
		           .. "walked into a room with the Guardians of the Globe — people who called him "
		           .. "a friend — and he killed every single one of them. "
		           .. "He beat his own son within an inch of his life and flew away into space "
		           .. "rather than finish it. I don't know if that means he has limits or if he "
		           .. "just made a tactical calculation. Either way, he's a Viltrumite. "
		           .. "He's coming back. You need to be ready when he does.",
		objectives  = {
			{ id="kill_omni", type="defeat_boss", target="Omni-Man", required=1, description="Defeat Omni-Man" },
		},
		rewards     = { xp=80000, cosmetic="Omni-Man Costume", title="Defeated Omni-Man",
		                notification="Cecil: Nolan Grayson. Two thousand years old. And you put him down. I genuinely didn't have that in my projections." },
		prereqs     = { "earth_defense" },
		next        = "conqueror",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	conqueror = {
		id          = "conqueror",
		name        = "The Conqueror Arrives",
		description = "Conquest has made landfall. He has personally subjugated over "
		           .. "ten thousand worlds across four thousand years. "
		           .. "He genuinely enjoys this. That makes him more dangerous, not less.",
		giver       = "Cecil Stedman",
		dialogue    = "Name's Conquest. One of the Viltrumite Empire's most senior field warriors. "
		           .. "He's been doing this for four thousand years — and he's not tired of it. "
		           .. "That's what makes him different from Nolan. Nolan had limits. Complicated "
		           .. "ones, but limits. Conquest doesn't. He lost an eye on one planet, an arm on "
		           .. "another, and considers both fights fond memories. He fought Mark Grayson — "
		           .. "Invincible — and nearly killed him. Left him bleeding in a crater. "
		           .. "He's here now. On Earth. I need you to stop him before he tears this "
		           .. "planet down to the bedrock because he thinks it's a good workout.",
		objectives  = {
			{ id="kill_conquest", type="defeat_boss", target="Conquest", required=1, description="Defeat Conquest" },
		},
		rewards     = { xp=100000, title="Conqueror's Bane",
		                notification="Cecil: Conquest. Four thousand years, ten thousand worlds. You ended his run. That's not nothing." },
		prereqs     = { "omni_man_problem" },
		next        = "thragg_end",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	thragg_end = {
		id          = "thragg_end",
		name        = "Thragg's End",
		description = "Grand Regent Thragg. The strongest Viltrumite in recorded history. "
		           .. "Carries the secret bloodline of Argall, the first king of Viltrum. "
		           .. "Kill him and the Empire loses its spine. That's the mission.",
		giver       = "Cecil Stedman",
		dialogue    = "Thragg. Grand Regent of the Viltrumite Empire. Three thousand years old. "
		           .. "Every intelligence asset I have says he is the single most physically "
		           .. "powerful individual in the known galaxy. We recently learned he carries "
		           .. "a secret — he is a direct descendant of Argall, the original Viltrumite "
		           .. "king. He kept that hidden for centuries because even among Viltrumites, "
		           .. "that bloodline represents something they can't control. "
		           .. "The Empire is already fracturing. The Scourge Virus. The war losses. "
		           .. "Fewer than fifty of them left, total. Kill Thragg and the Empire has "
		           .. "no center to hold. This is the mission that ends the war. "
		           .. "Mark Grayson did it in a star. You'll have to find your own way.",
		objectives  = {
			{ id="kill_thragg", type="defeat_boss", target="Thragg", required=1, description="Defeat Grand Regent Thragg" },
		},
		rewards     = { xp=200000, powerLevel=20000, title="Grand Slayer", cosmetic="Thragg Cape",
		                notification="Cecil: Thragg. Grand Regent. Blood of Argall. Three thousand years. ...You actually did it. The Empire is broken." },
		prereqs     = { "conqueror" },
		next        = "viltrumite_awakening",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	viltrumite_awakening = {
		id          = "viltrumite_awakening",
		name        = "Viltrumite Awakening",
		description = "The Scourge Virus killed most Viltrumites. The civil war killed the rest. "
		           .. "The fifty who survived are the strongest organisms ever produced by natural "
		           .. "selection. 100,000 power level is the threshold where you enter their tier. "
		           .. "Cross it.",
		giver       = "Cecil Stedman",
		dialogue    = "The Viltrumite Scourge. A biological weapon engineered specifically to kill "
		           .. "Viltrumite DNA. Most of their species died within a generation. "
		           .. "The ones who survived were genetically resistant — the absolute peak of "
		           .. "what their species could produce. A hundred thousand power level is "
		           .. "where GDA modeling puts the floor of that range. "
		           .. "Get there. I need to know this planet has someone in that weight class "
		           .. "who isn't going to defect to the Empire or die on a Tuesday.",
		objectives  = {
			{ id="pl_100k", type="reach_pl", required=100000, description="Reach Power Level 100,000" },
		},
		rewards     = { xp=50000, cosmetic="Viltrumite Battle Armor", title="True Viltrumite",
		                notification="Cecil: 100,000. You're not human anymore. Not sure that's good or bad. It's useful, and that's what matters." },
		prereqs     = { "thragg_end" },
		next        = "supreme_being",
	},

	-- ─────────────────────────────────────────────────────────────────────────
	supreme_being = {
		id          = "supreme_being",
		name        = "Supreme Being",
		description = "Mark Grayson fought Grand Regent Thragg inside a star and won. "
		           .. "That is the benchmark. One million power level. "
		           .. "If you reach it, you're in that conversation.",
		giver       = "Cecil Stedman",
		dialogue    = "Mark Grayson — Invincible — dragged Thragg into the surface of the sun. "
		           .. "Both of them burning. Both of them regenerating. Both of them still fighting "
		           .. "while their bodies were being incinerated at fifteen million degrees Celsius. "
		           .. "Mark survived. Thragg didn't. That fight happened at power levels "
		           .. "neither of them could have reached at the start. Growth matters. "
		           .. "One million is the number that puts you in that territory. "
		           .. "I can't run projections on what you become after that. "
		           .. "I genuinely don't have the data for it. Neither does anyone else.",
		objectives  = {
			{ id="pl_1m", type="reach_pl", required=1000000, description="Reach Power Level 1,000,000" },
		},
		rewards     = { xp=0, title="Supreme Viltrumite", cosmetic="Pure White Viltrumite",
		                notification="Cecil: One million. You and Mark Grayson are the only two names I'd put on that list. I'll let you decide what that means." },
		prereqs     = { "viltrumite_awakening" },
		next        = nil,
	},
}

-- ── Utility functions ──────────────────────────────────────────────────────

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
