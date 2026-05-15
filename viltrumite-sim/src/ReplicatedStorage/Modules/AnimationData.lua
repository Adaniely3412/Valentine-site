-- Animation asset IDs.
-- Replace placeholder IDs with your own uploaded animations from Roblox Studio.
-- Free starter packs: search "R6 Combat Animations" in the Toolbox.

local AnimationData = {}

-- Roblox default locomotion (these work out of the box on any R6 rig)
local DEFAULT = {
	Idle    = "rbxassetid://507766388",
	Walk    = "rbxassetid://507777826",
	Run     = "rbxassetid://507767714",
	Jump    = "rbxassetid://507765000",
	Fall    = "rbxassetid://507767968",
	Climb   = "rbxassetid://507770239",
}

-- Combat — replace with custom uploads for the real look
-- Placeholders reuse default locomotion so the game never errors.
AnimationData.Ids = {
	-- Locomotion
	Idle          = DEFAULT.Idle,
	Walk          = DEFAULT.Walk,
	Run           = DEFAULT.Run,
	Jump          = DEFAULT.Jump,
	Fall          = DEFAULT.Fall,

	-- M1 chain (use distinct animations once you have them)
	Jab           = DEFAULT.Run,
	Cross         = DEFAULT.Run,
	Hook          = DEFAULT.Run,
	Uppercut      = DEFAULT.Jump,
	FinisherSlam  = DEFAULT.Fall,

	-- Specials
	SonicClap        = DEFAULT.Jump,
	ViltrumiteRush   = DEFAULT.Run,
	EarthShatter     = DEFAULT.Fall,
	ThoraxStrike     = DEFAULT.Run,
	SupremeOverdrive = DEFAULT.Jump,

	-- Defensive
	Block         = DEFAULT.Idle,

	-- Hit reactions
	HitLight      = DEFAULT.Idle,
	HitHeavy      = DEFAULT.Jump,
	Ragdoll       = DEFAULT.Fall,
	GetUp         = DEFAULT.Jump,

	-- Flight
	FlyIdle       = DEFAULT.Fall,
	FlyForward    = DEFAULT.Run,
}

-- Priority tiers so combat overrides locomotion
AnimationData.Priority = {
	Idle         = Enum.AnimationPriority.Idle,
	Walk         = Enum.AnimationPriority.Movement,
	Run          = Enum.AnimationPriority.Movement,
	Jump         = Enum.AnimationPriority.Movement,
	Fall         = Enum.AnimationPriority.Movement,
	Jab          = Enum.AnimationPriority.Action,
	Cross        = Enum.AnimationPriority.Action,
	Hook         = Enum.AnimationPriority.Action,
	Uppercut     = Enum.AnimationPriority.Action,
	FinisherSlam = Enum.AnimationPriority.Action4,
	SonicClap    = Enum.AnimationPriority.Action4,
	ViltrumiteRush = Enum.AnimationPriority.Action4,
	EarthShatter = Enum.AnimationPriority.Action4,
	ThoraxStrike = Enum.AnimationPriority.Action4,
	SupremeOverdrive = Enum.AnimationPriority.Action4,
	Block        = Enum.AnimationPriority.Action,
	HitLight     = Enum.AnimationPriority.Action,
	HitHeavy     = Enum.AnimationPriority.Action4,
	Ragdoll      = Enum.AnimationPriority.Action4,
	FlyIdle      = Enum.AnimationPriority.Movement,
	FlyForward   = Enum.AnimationPriority.Movement,
}

function AnimationData.Get(name)
	return AnimationData.Ids[name], AnimationData.Priority[name]
end

return AnimationData
