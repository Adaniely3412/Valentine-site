local BloodlineData = {}

-- Lore notes are displayed in the bloodline reveal UI and Cecil's intel briefings.
-- All facts sourced from the Invincible comic / Prime Video series canon.

BloodlineData.Bloodlines = {

	["Pure Viltrumite"] = {
		rarity         = "Legendary",
		statMult       = 2.5,
		speedMult      = 2.5,
		durabilityMult = 3.0,
		maxPowerLevel  = 2000000,
		regenRate      = 5,
		passives       = { "Invincible Durability", "Supersonic Flight", "Bone Crusher", "Rapid Regeneration" },
		auraColor      = Color3.fromRGB(255, 30, 30),
		startingPL     = 50000,

		description = "The pinnacle of Viltrumite genetics. Nearly unstoppable in any environment.",
		lore = "Viltrumites spent over a thousand years in a brutal civil war and a near-extinction "
		    .. "event called the Scourge — a viral weapon engineered to kill only those with "
		    .. "Viltrumite DNA. Fewer than 50 pure-blooded Viltrumites survived. Each one is a "
		    .. "product of millennia of selective warfare: only the strongest ever reproduced. "
		    .. "Their bones are harder than diamond, their cells regenerate at a rate that makes "
		    .. "mortal wounds temporary inconveniences, and at full speed they approach the "
		    .. "sound barrier on foot and light speed in the vacuum of space.",
		weakness = "High-frequency resonant sound disrupts the Viltrumite inner ear, causing disorientation and loss of flight. The Scourge Virus remains lethal to any with pure Viltrumite heritage.",
	},

	["Half-Blood Viltrumite"] = {
		rarity         = "Rare",
		statMult       = 1.7,
		speedMult      = 1.8,
		durabilityMult = 1.9,
		maxPowerLevel  = 800000,
		regenRate      = 2,
		passives       = { "Viltrumite Heritage", "Enhanced Durability" },
		auraColor      = Color3.fromRGB(200, 80, 255),
		startingPL     = 10000,

		description = "Carries Viltrumite blood. The power is there — it just needs time to surface.",
		lore = "When a Viltrumite reproduces with another species, the child inherits the recessive "
		    .. "Viltrumite gene complex. Powers tend to manifest later than in a pureblood — "
		    .. "sometimes not until adolescence — but the genetic ceiling is far higher than any "
		    .. "natural species. The most famous Half-Blood is Mark Grayson, son of Nolan Grayson "
		    .. "(Omni-Man), whose human upbringing and Viltrumite potential made him one of "
		    .. "Earth's greatest defenders and eventually its most powerful warrior. "
		    .. "The human half does not dilute the power — it tempers it with something "
		    .. "Viltrumites historically lacked: restraint.",
		weakness = "Slower power development in youth. Heightened emotional sensitivity compared to purebloods, which Viltrumites consider a tactical liability.",
	},

	["Viltrumite Descendant"] = {
		rarity         = "Uncommon",
		statMult       = 1.3,
		speedMult      = 1.4,
		durabilityMult = 1.3,
		maxPowerLevel  = 200000,
		regenRate      = 1,
		passives       = { "Ancient Blood" },
		auraColor      = Color3.fromRGB(100, 150, 255),
		startingPL     = 1000,

		description = "A distant descendant of Viltrumite heritage. The blood has thinned, but never fully diluted.",
		lore = "Over generations, Viltrumite DNA integrated into countless species across conquered "
		    .. "planets. On Earth, a small percentage of humans carry dormant Viltrumite sequences "
		    .. "from ancient contact events — encounters never acknowledged in any official record. "
		    .. "A Viltrumite Descendant is stronger, faster, and more durable than a peak human, "
		    .. "though they will never reach the raw ceiling of a pureblood without extraordinary "
		    .. "training and willpower. The GDA classifies them as Tier-3 enhanced, requiring "
		    .. "monitoring but not containment.",
		weakness = "Ancient Blood passive (+15% XP-to-PL conversion) can backfire — rapid growth without proper conditioning risks physiological instability.",
	},

	["Enhanced Human"] = {
		rarity         = "Uncommon",
		statMult       = 1.1,
		speedMult      = 1.2,
		durabilityMult = 1.1,
		maxPowerLevel  = 50000,
		regenRate      = 0.5,
		passives       = { "Peak Human" },
		auraColor      = Color3.fromRGB(100, 255, 150),
		startingPL     = 100,

		description = "A human pushed past natural limits — by science, accident, or sheer refusal to quit.",
		lore = "Not every Earth defender has alien DNA. Some, like Atom Eve (Samantha Eve Wilkins), "
		    .. "were genetically engineered in government programs — embryos altered before birth, "
		    .. "parents never told. Others survived exposure to energy sources or experimental "
		    .. "treatments that reactivated dormant human potential. Cecil Stedman's GDA funded "
		    .. "several such projects, most of which the public will never know about. "
		    .. "Enhanced Humans hit a lower ceiling than Viltrumite-blooded individuals, "
		    .. "but their adaptability and ingenuity make them unpredictable opponents — "
		    .. "something pure Viltrumites consistently underestimate.",
		weakness = "Hard biological ceiling on raw power. No innate regeneration beyond accelerated natural healing.",
	},

	["Human"] = {
		rarity         = "Common",
		statMult       = 1.0,
		speedMult      = 1.0,
		durabilityMult = 1.0,
		maxPowerLevel  = 10000,
		regenRate      = 0.3,
		passives       = {},
		auraColor      = Color3.fromRGB(200, 200, 200),
		startingPL     = 0,

		description = "An ordinary human being. Every legend in this universe started exactly here.",
		lore = "Cecil Stedman is human. He has no powers, no alien DNA, no secret super-serum. "
		    .. "He runs the Global Defense Agency, outwits Viltrumite generals, and has kept "
		    .. "Earth alive against threats that should have annihilated it three times over. "
		    .. "Humans have something no Viltrumite was bred to understand: the ability to "
		    .. "work together, adapt fast, and fight for something other than personal glory. "
		    .. "The Viltrumite Empire dismissed humanity as a primitive species not worth the "
		    .. "cost of conquest. That assessment has not aged well.",
		weakness = "No innate combat enhancements. Relies entirely on training, intelligence, and power level growth through combat and discipline.",
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
