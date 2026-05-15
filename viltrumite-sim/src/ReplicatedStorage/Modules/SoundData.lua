-- Sound asset IDs.
-- All IDs below are from Roblox's free audio library (public domain / free-to-use).
-- Verify availability in Studio: open Toolbox → Audio → search by ID.

local SoundData = {}

SoundData.Ids = {
	-- Punches
	Punch_Light    = "rbxassetid://131188392",
	Punch_Medium   = "rbxassetid://131188392",
	Punch_Heavy    = "rbxassetid://131071735",
	Punch_Finisher = "rbxassetid://131071735",

	-- Special moves
	SonicClap      = "rbxassetid://362252261",  -- loud whoosh/boom
	SonicBoom      = "rbxassetid://152840862",
	EarthShatter   = "rbxassetid://157878578",
	BoneCrunch     = "rbxassetid://131071735",
	UltimateImpact = "rbxassetid://157878578",

	-- Block / parry
	Block          = "rbxassetid://131071735",
	PerfectParry   = "rbxassetid://362252261",

	-- Flight
	FlightLoop     = "rbxassetid://154687104",  -- wind loop
	SonicTrail     = "rbxassetid://154687104",

	-- UI / progression
	PowerUp        = "rbxassetid://362252261",
	BloodlineReveal = "rbxassetid://362252261",
	ConquestCapture = "rbxassetid://157878578",
	ConquestWin    = "rbxassetid://157878578",

	-- Boss
	BossRoar       = "rbxassetid://157878578",
	BossSpawn      = "rbxassetid://362252261",
	BossDefeated   = "rbxassetid://157878578",

	-- Destruction
	CraterImpact   = "rbxassetid://157878578",
	DebrisRumble   = "rbxassetid://154687104",
}

SoundData.Volumes = {
	Punch_Light    = 0.6,
	Punch_Medium   = 0.8,
	Punch_Heavy    = 1.0,
	Punch_Finisher = 1.2,
	SonicClap      = 1.5,
	SonicBoom      = 1.3,
	EarthShatter   = 2.0,
	BoneCrunch     = 1.0,
	UltimateImpact = 2.0,
	Block          = 0.7,
	PerfectParry   = 1.0,
	FlightLoop     = 0.4,
	PowerUp        = 1.0,
	BossRoar       = 2.0,
	CraterImpact   = 2.0,
}

SoundData.RolloffScale = {
	Punch_Light    = 20,
	Punch_Heavy    = 40,
	SonicClap      = 80,
	SonicBoom      = 100,
	EarthShatter   = 150,
	BossRoar       = 200,
	CraterImpact   = 150,
	FlightLoop     = 30,
}

function SoundData.Get(name)
	return SoundData.Ids[name], SoundData.Volumes[name] or 1.0, SoundData.RolloffScale[name] or 40
end

return SoundData
