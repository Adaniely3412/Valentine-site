local Config = {}

Config.VERSION = "0.1.0"

-- ── Lore context ──────────────────────────────────────────────────────────
-- Power Level (PL) tiers are calibrated against known Invincible canon benchmarks:
--   Nolan Grayson (Omni-Man) : ~800,000  (experienced Viltrumite, 2,000+ years)
--   Conquest                 : ~950,000  (elite field commander, 4,000+ years)
--   Grand Regent Thragg      : ~1,200,000 (strongest Viltrumite, blood of Argall)
--   Mark Grayson peak        : ~1,000,000+ (Half-Blood who reached and exceeded his father)
-- Tier names reflect the GDA classification system used internally by Cecil Stedman.

Config.TIERS = {
	{ name = "Civilian",            minPL = 0,       color = Color3.fromRGB(200, 200, 200) },
	{ name = "GDA Recruit",         minPL = 1000,    color = Color3.fromRGB(150, 220, 150) },
	{ name = "Enhanced Operative",  minPL = 5000,    color = Color3.fromRGB(100, 200, 255) },
	{ name = "Viltrumite-Class",    minPL = 20000,   color = Color3.fromRGB(200, 100, 255) },
	{ name = "Viltrumite Elite",    minPL = 100000,  color = Color3.fromRGB(255, 80,  80)  },
	{ name = "Imperial Grade",      minPL = 500000,  color = Color3.fromRGB(255, 200, 0)   },
	{ name = "Blood of Argall",     minPL = 1000000, color = Color3.fromRGB(255, 50,  50)  },
}

-- Combat
Config.BASE_HEALTH        = 100
Config.BASE_DAMAGE        = 10
Config.COMBO_WINDOW       = 0.65
Config.MAX_COMBO          = 5
Config.PARRY_WINDOW       = 0.2
Config.HITSTUN_DURATION   = 0.4

-- Flight
Config.BASE_FLIGHT_SPEED  = 80
Config.SPRINT_MULTIPLIER  = 3.0
Config.FLIGHT_ACCELERATION = 0.15
Config.MIN_FLIGHT_PL      = 1000

-- Progression
Config.XP_PER_KILL        = 500
Config.XP_PER_HIT         = 10
Config.XP_MULTIPLIER      = 1.0

-- Conquest
-- Zones are named after real Invincible locations:
--   Grayson Residence — Nolan and Debbie's home; a known Viltrumite contact point per GDA intel
--   GDA HQ            — The Global Defense Agency's command center; Cecil's operational base
--   Viltrum Outpost   — Advance staging position established by Viltrumite scouts on Earth
Config.ZONE_CAPTURE_TIME  = 30
Config.ZONE_SCORE_RATE    = 1
Config.WIN_SCORE          = 500
Config.ZONE_NAMES         = { "Grayson Residence", "GDA HQ", "Viltrum Outpost" }

-- DataStore
Config.DATASTORE_KEY      = "ViltrumiteData_v1"
Config.SAVE_INTERVAL      = 60

Config.BLOODLINE_WEIGHTS  = {
	["Pure Viltrumite"]       = 3,
	["Half-Blood Viltrumite"] = 10,
	["Viltrumite Descendant"] = 22,
	["Enhanced Human"]        = 30,
	["Human"]                 = 35,
}

return Config
