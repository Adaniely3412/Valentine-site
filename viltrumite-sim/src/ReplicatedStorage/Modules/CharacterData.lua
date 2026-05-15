local CharacterData = {}

-- All dialogue and lore grounded in the Invincible comic series (Robert Kirkman)
-- and the Prime Video animated adaptation.
-- Power levels are relative — Thragg is the series benchmark for raw Viltrumite peak.

CharacterData.Characters = {

	-- ── BOSSES ────────────────────────────────────────────────────────────────

	["Omni-Man"] = {
		displayName  = "Omni-Man / Nolan Grayson",
		powerLevel   = 800000,
		bloodline    = "Pure Viltrumite",
		health       = 50000,
		age          = "Over 2,000 years",
		isViltrumite = true,
		isBoss       = true,
		bossRank     = 3,
		faction      = "Viltrumite Empire",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush","EarthShatter","ThoraxStrike" },

		description = "Sent to Earth over two decades ago to prepare it for Viltrumite conquest. "
		           .. "Posed as Earth's greatest hero. Murdered the entire Guardians of the Globe "
		           .. "in cold blood. His son Mark eventually became the thing that made him question everything.",

		lore = "Nolan Grayson lived on Earth for over twenty years, married Debbie Grayson, "
		    .. "had a son, and watched superhero after superhero trust him with their lives. "
		    .. "He killed them all on the same night without hesitation — the Guardians of the "
		    .. "Globe, Earth's most powerful defenders, dismantled in minutes. The Viltrumite "
		    .. "Empire demanded it. Nolan was two thousand years old. He had subjugated hundreds "
		    .. "of worlds. Earth was supposed to be no different. "
		    .. "It was different. He just didn't know it yet.",

		dialogue = {
			spawn = {
				"Think about what you're doing. Really think.",
				"I've lived for two thousand years. You have no idea what you're walking into.",
				"Every hero on this planet trusted me. That should tell you something.",
				"I watched the Guardians die. I put them there myself. And I didn't flinch.",
			},
			combat = {
				"Is that everything you have?",
				"I've fought armies across a hundred worlds. You're not an army.",
				"You hit hard. You're still losing.",
				"Stop holding back. I'm not.",
				"I've seen better footwork from rookies on their first week.",
			},
			lowHP = {
				"Fine. You've earned the full version.",
				"I underestimated you. That hasn't happened in centuries.",
				"You're better than I expected. That genuinely surprises me.",
				"This isn't over. It's just getting interesting.",
			},
			victory = {
				"It didn't have to end this way. It rarely does.",
				"You fought well. Viltrumites would respect that. Barely.",
				"Earth isn't ready. It may never be.",
			},
			defeated = {
				"...This changes things. You changed things.",
				"Mark would have been proud of that hit.",
				"I've been alive two thousand years. And still... you surprised me.",
			},
		},

		rewards = { xp = 50000, title = "Defeated Omni-Man", cosmetic = "Omni-Man Costume" },
	},

	["Thragg"] = {
		displayName  = "Grand Regent Thragg",
		powerLevel   = 1200000,
		bloodline    = "Pure Viltrumite",
		health       = 80000,
		age          = "Over 3,000 years",
		isViltrumite = true,
		isBoss       = true,
		bossRank     = 5,
		faction      = "Viltrumite Empire",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush","EarthShatter","ThoraxStrike","SupremeOverdrive" },

		description = "Grand Regent of the Viltrumite Empire. The physically strongest Viltrumite "
		           .. "in recorded history. Carries a secret bloodline — descended directly from "
		           .. "Argall, the first king of Viltrum — that he kept hidden for thousands of years. "
		           .. "His final battle was fought in the sun. He lost.",

		lore = "Thragg's power is not merely training or genetics — it is the concentrated result "
		    .. "of Argall's royal bloodline, preserved in secret across millennia. Argall founded "
		    .. "the Viltrumite Empire and was executed when it outgrew him. The royal line was "
		    .. "supposed to die with him. Thragg is proof it didn't. He served as Grand Regent "
		    .. "for centuries, guiding the Empire's expansion across the galaxy, suppressing any "
		    .. "knowledge of his true heritage. When it was finally revealed, the Empire fractured. "
		    .. "In the end, it took Mark Grayson dragging him into the surface of the sun to finish him. "
		    .. "Even then, Thragg kept fighting.",

		dialogue = {
			spawn = {
				"The Empire does not yield. Not to time. Not to loss. Not to you.",
				"You stand before the Grand Regent of the Viltrumite Empire. Reconsider.",
				"I am the blood of Argall. Every world that exists bowed to that name.",
				"Three thousand years of warfare end with me standing. That will not change today.",
			},
			combat = {
				"Pathetic.",
				"That is the strength Earth offers? No wonder Nolan was ashamed of this planet.",
				"You tire. I do not tire.",
				"I have killed things that would make you weep to imagine.",
				"Faster. Hit harder. Or stop wasting my time.",
			},
			lowHP = {
				"Impossible. This is... impossible.",
				"I will not fall to a lesser being. I REFUSE.",
				"The blood of Argall does not bow.",
				"Even now... even here... I am not done.",
			},
			victory = {
				"As expected. As it has always been.",
				"The Empire endures. It always endures.",
				"Rest. You fought better than most. That is a compliment.",
			},
			defeated = {
				"*coughs blood* The line... of Argall... is not... finished.",
				"You burned alongside me. And still you stand. I... respect that.",
				"Mark Grayson... you are the only one... who deserved this.",
			},
		},

		rewards = { xp = 150000, powerLevel = 30000, title = "Grand Slayer", cosmetic = "Thragg Cape" },
	},

	["Conquest"] = {
		displayName  = "Conquest",
		powerLevel   = 950000,
		bloodline    = "Pure Viltrumite",
		health       = 60000,
		age          = "Over 4,000 years",
		isViltrumite = true,
		isBoss       = true,
		bossRank     = 4,
		faction      = "Viltrumite Empire",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush","EarthShatter","ThoraxStrike" },

		description = "One of the oldest and most battle-scarred Viltrumites in existence. "
		           .. "He has conquered over ten thousand worlds across four millennia. "
		           .. "He lost an eye and an arm in different battles. He considered both good fights.",

		lore = "Conquest does not consider death a meaningful concept. He has lost body parts, "
		    .. "had planets collapse on him, and been left for dead in the vacuum of space. "
		    .. "He always returns. His defining characteristic — the thing that separates him "
		    .. "from other Viltrumites — is that he genuinely enjoys it. Other warriors fight "
		    .. "for the Empire, for survival, for glory. Conquest fights because it is the most "
		    .. "fun he has ever had in four thousand years. His prosthetic arm is a trophy he "
		    .. "wears proudly. His eye patch is a conversation starter. "
		    .. "He fought Mark Grayson twice. The first time nearly killed Mark. "
		    .. "The second time, Mark won. Conquest died laughing.",

		dialogue = {
			spawn = {
				"I have conquered ten thousand worlds in four thousand years. What's one more?",
				"Your planet, your friends, your best shot — bring all of it. I want a real fight.",
				"This arm? I lost it on a moon that doesn't exist anymore. Good fight.",
				"Show me you're worth remembering. Most of you aren't.",
			},
			combat = {
				"COME ON! That's barely a warm-up!",
				"I lost this eye to someone twice your size. You've got a long way to go.",
				"Ha! You actually connected! I felt that!",
				"Better. BETTER. Don't stop now!",
				"You're going to have to do a lot worse than that to slow me down.",
			},
			lowHP = {
				"HA! NOW we're fighting! I was starting to get bored!",
				"Now THAT is what I came here for! AGAIN!",
				"I'm starting to enjoy this! Do your worst!",
				"You actually hurt me. I haven't said that in... centuries.",
			},
			victory = {
				"Another world. Another casualty. The Empire thanks you for your service.",
				"Fall. It's easier. I've seen it a thousand times.",
				"Don't be embarrassed. Most species last less than five minutes.",
			},
			defeated = {
				"*laughs* You actually did it. An actual, honest-to-gods warrior. Well done.",
				"Ha... four thousand years... and THIS is how it ends... not bad.",
				"Tell Invincible I said... he had good taste in allies.",
			},
		},

		rewards = { xp = 80000, title = "Conqueror's Bane", cosmetic = "Conquest Eye Patch" },
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

		description = "He has died more times than he can count. He always comes back. "
		           .. "A founding member of the Guardians of the Globe. Killed by Omni-Man "
		           .. "alongside every other Guardian. Came back. Fought Omni-Man again. "
		           .. "Lost again. Came back again. He is very tired of dying.",

		lore = "The Immortal was one of the original Guardians of the Globe — Earth's greatest "
		    .. "superhero team. Omni-Man murdered all of them in a single night, including The "
		    .. "Immortal. His decapitated body regenerated. He came back angrier than before. "
		    .. "He has watched empires rise and fall across what he believes are thousands of years. "
		    .. "He has died in wars, experiments, and superhero battles. Each time, his body knits "
		    .. "itself back together. He does not fully understand why. He has stopped trying to. "
		    .. "What keeps him going is simpler than any answer: the work isn't finished yet.",

		dialogue = {
			spawn = {
				"I've died more times than you've been alive. This doesn't frighten me.",
				"Nolan Grayson killed me. Came back. You can try your luck too.",
				"Every empire I've seen thought it would last forever. None of them did.",
				"You want to fight something that can't die? Let's find out what that costs you.",
			},
			combat = {
				"I've outlasted gods. Try harder.",
				"Pain is just memory. I've got a lot of both.",
				"I've beaten things you've never heard of. You're on the list now.",
				"Is that all? I've had longer fights with senators.",
			},
			lowHP = {
				"Kill me. I'll be back before you reach the door.",
				"This? This is Tuesday.",
				"I'll be back. I'm always back.",
				"You're good. Better than most. Still not enough.",
			},
			victory = {
				"It never ends. But neither do I.",
				"Rest. You put up a better fight than most.",
			},
			defeated = {
				"*chuckles* Good. That's a good hit. Give me ten minutes.",
				"I'll be back. I'm always back. Don't go far.",
			},
		},

		rewards = { xp = 30000, title = "Unkillable", cosmetic = "Immortal Beard" },
		respawnImmune = true,
	},

	-- ── ALLIED NPCs ───────────────────────────────────────────────────────────

	["Cecil Stedman"] = {
		displayName  = "Cecil Stedman",
		powerLevel   = 500,
		bloodline    = "Human",
		health       = 5000,
		isViltrumite = false,
		isBoss       = false,
		isNPC        = true,
		questGiver   = true,
		faction      = "GDA",
		moves        = {},

		description = "Director of the Global Defense Agency. No powers. No alien DNA. "
		           .. "Just intelligence, resources, and an absolute refusal to let Earth die — "
		           .. "no matter what he has to do to prevent it.",

		lore = "Cecil Stedman has been running the GDA since before most of Earth's superheroes "
		    .. "were born. He knew Omni-Man was a Viltrumite spy and said nothing, because he "
		    .. "calculated that Omni-Man was more useful as a defended asset than as a revealed "
		    .. "threat. He runs Reanimen programs — cybernetically reanimated corpses deployed "
		    .. "as weapons. He makes deals with villains when the math works out. He has authorized "
		    .. "experiments that would end careers and possibly lives if they became public. "
		    .. "He carries a scar from the night Nolan Grayson killed the Guardians. "
		    .. "Cecil was there. He survived. He did not let it make him sentimental.",

		dialogue = {
			interact = {
				"I need you mission-ready. Not good. Ready.",
				"Every move on this board has a cost. I've already calculated yours.",
				"I've kept this planet alive through things that would break most people. Don't test my patience.",
				"You're useful. That's the only reason we're having this conversation.",
				"Someone has to make the hard calls. I've been making them for thirty years.",
				"The Guardians of the Globe trusted Nolan Grayson. They're all dead now. Trust carefully.",
				"I don't do this because I enjoy it. I do it because no one else will.",
			},
		},
		quests = { "first_blood", "gda_contracts", "viltrumite_intel", "earth_defense",
		           "omni_man_problem", "conqueror", "thragg_end", "viltrumite_awakening", "supreme_being" },
	},

	["Mark Grayson"] = {
		displayName  = "Invincible / Mark Grayson",
		powerLevel   = 200000,
		bloodline    = "Half-Blood Viltrumite",
		health       = 20000,
		age          = "17 at first manifestation",
		isViltrumite = false,
		isBoss       = false,
		isNPC        = true,
		faction      = "Earth Defenders",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","SonicClap","ViltrumiteRush" },

		description = "Son of Omni-Man. His powers manifested at 17 — later than a pureblood "
		           .. "would. Still learning the difference between invulnerable and invincible. "
		           .. "Eventually becomes the strongest warrior on Earth.",

		lore = "Mark Grayson's powers came in at seventeen — late, even for a half-blood. "
		    .. "He chose the name Invincible himself. His father suggested something ending in "
		    .. "'-Man'. He still wishes he'd thought of a better name. "
		    .. "He watched his father beat him within inches of death and then fly away into space. "
		    .. "He went back to school the next week. He fought Conquest twice — barely survived "
		    .. "the first time, won the second with help from Eve. He fought Thragg in the sun "
		    .. "and won. His human upbringing didn't make him weaker. It gave him something "
		    .. "Viltrumites spent a thousand years breeding out of themselves: the ability to care "
		    .. "about what he was fighting for.",

		dialogue = {
			interact = {
				"I'm still figuring this out. But I'm getting there.",
				"My dad... I've made peace with what he was. Mostly.",
				"Being invincible doesn't mean you can't feel it. Trust me.",
				"I fought Conquest. Twice. I'm still not totally sure how I survived the first time.",
				"The name? I know. I should've picked something better.",
				"Sometimes the right move is the one that would get every other Viltrumite killed. That's the human half talking.",
			},
		},
	},

	["Atom Eve"] = {
		displayName     = "Atom Eve / Samantha Eve Wilkins",
		powerLevel      = 300000,
		bloodline       = "Enhanced Human",
		health          = 15000,
		isViltrumite    = false,
		isBoss          = false,
		isNPC           = true,
		faction         = "Earth Defenders",
		moves           = {},
		specialAbility  = "MatterManipulation",

		description = "Born in a government laboratory with the ability to rearrange "
		           .. "molecular structure of any non-living matter. One of the most "
		           .. "powerful beings on Earth, and the government spent years trying "
		           .. "to make sure no one knew she existed.",

		lore = "Samantha Eve Wilkins did not have a normal origin. Her embryo was genetically "
		    .. "modified in a GDA-adjacent lab — designed as a living weapon that could "
		    .. "reshape matter at will. The project panicked at what they'd created and "
		    .. "tried to shut it down. She was born anyway. Placed with adoptive parents "
		    .. "who believed she was their biological child. She grew up thinking her powers "
		    .. "were just hers, something she was born with. She was right. They were. "
		    .. "She can transmute any non-living substance into any other substance, "
		    .. "generate force fields, and fly by manipulating the air around her. "
		    .. "She later learned to heal living tissue, including herself. "
		    .. "The government considered her the most dangerous person on Earth. "
		    .. "She considered herself a hero. She was right about that too.",

		dialogue = {
			interact = {
				"Matter is just energy you haven't arranged correctly yet.",
				"I can change anything. Except people. That part I had to learn the hard way.",
				"The GDA knew what I was before I did. I try not to think about that.",
				"I used to think my powers were a gift. Now I think they're a responsibility. Same thing, actually.",
				"If you're fighting a Viltrumite, stay behind me and let me work.",
			},
		},
	},

	["Allen the Alien"] = {
		displayName  = "Allen the Alien",
		powerLevel   = 600000,
		bloodline    = "Enhanced Human",  -- gameplay classification; Allen is Unopan
		health       = 35000,
		isViltrumite = false,
		isBoss       = false,
		isNPC        = true,
		faction      = "Coalition of Planets",
		moves        = { "M1_1","M1_2","M1_3","M1_4","M1_5","ViltrumiteRush" },

		description = "Champion Evaluator for the Coalition of Planets, based on Talescria. "
		           .. "His species — the Unopan — regenerates exponentially stronger after "
		           .. "near-death experiences. Thragg nearly killed him. It was a mistake.",

		lore = "Allen was engineered by his species to be the Coalition's Champion Evaluator — "
		    .. "his job was literally to fly to planets and fight the local champion to see if "
		    .. "they were strong enough to stand against the Viltrumite Empire. He accidentally "
		    .. "went to the wrong planet for years (Earth instead of Urath) but considers it "
		    .. "a fortunate mistake. He's one of the most cheerful beings in the galaxy, "
		    .. "which is remarkable given that Grand Regent Thragg once beat him to the point "
		    .. "of clinical death. He recovered. He recovered stronger. He always recovers stronger. "
		    .. "When Unopans are near death, their biology compensates. The polite word is "
		    .. "'adaptation'. The accurate word is 'terrifying'. "
		    .. "Allen considers this a 'great evolutionary trait'. Everything is great with Allen.",

		dialogue = {
			interact = {
				"Hey! Great to see you! Things are going great!",
				"I've been to hundreds of planets. Earth is definitely in my top ten.",
				"Thragg almost killed me once. ALMOST. The important word is almost.",
				"When Unopans are near death, we come back much stronger. It's a fantastic system.",
				"The Coalition of Planets sends their regards. Also, their best warrior. That's me.",
				"I went to the wrong planet for three years by mistake. Still one of my better assignments.",
			},
		},
	},
}

-- ── Utility functions ──────────────────────────────────────────────────────

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
