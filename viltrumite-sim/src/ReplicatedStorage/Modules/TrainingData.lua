-- Training station definitions. Four stations, each improving a different stat.

local TrainingData = {}

-- Stat bonus applied per training point earned
TrainingData.BONUS_PER_POINT = {
	Strength  = 0.0010,   -- +0.10% damage per point
	Speed     = 0.05,     -- +0.05 walkSpeed per point
	Endurance = 2,        -- +2 MaxHealth per point
	Focus     = 0.0010,   -- +0.10% special damage per point
}

TrainingData.MAX_POINTS = 100   -- cap per stat

TrainingData.COOLDOWN = 120     -- seconds between training sessions at the same station

TrainingData.Stations = {
	{
		id          = "gravity_chamber",
		name        = "Gravity Chamber",
		stat        = "Strength",
		description = "Train under 100× gravity. Increases raw damage.",
		holdTime    = 5,
		plReward    = 80,
		position    = Vector3.new(36, 1.5, -80),
		color       = Color3.fromRGB(255, 80, 80),
		material    = Enum.Material.SmoothPlastic,
		size        = Vector3.new(10, 0.5, 10),
		wallColor   = Color3.fromRGB(120, 30, 30),
	},
	{
		id          = "speed_course",
		name        = "Speed Course",
		stat        = "Speed",
		description = "Sprint the lightning circuit. Increases movement speed.",
		holdTime    = 4,
		plReward    = 60,
		position    = Vector3.new(-116, 1.5, 120),
		color       = Color3.fromRGB(80, 200, 255),
		material    = Enum.Material.Neon,
		size        = Vector3.new(14, 0.4, 14),
		wallColor   = Color3.fromRGB(30, 80, 120),
	},
	{
		id          = "endurance_ring",
		name        = "Endurance Ring",
		stat        = "Endurance",
		description = "Survive punishment in the combat ring. Increases max health.",
		holdTime    = 6,
		plReward    = 70,
		position    = Vector3.new(120, 42.5, 55),
		color       = Color3.fromRGB(80, 255, 120),
		material    = Enum.Material.SmoothPlastic,
		size        = Vector3.new(12, 0.5, 12),
		wallColor   = Color3.fromRGB(20, 80, 40),
	},
	{
		id          = "meditation_dais",
		name        = "Meditation Dais",
		stat        = "Focus",
		description = "Meditate at the energy nexus. Increases special move power.",
		holdTime    = 8,
		plReward    = 40,
		position    = Vector3.new(0, 1.5, 0),
		color       = Color3.fromRGB(180, 100, 255),
		material    = Enum.Material.Neon,
		size        = Vector3.new(8, 0.6, 8),
		wallColor   = Color3.fromRGB(60, 20, 100),
	},
}

TrainingData.StationById = {}
for _, s in ipairs(TrainingData.Stations) do
	TrainingData.StationById[s.id] = s
end

return TrainingData
