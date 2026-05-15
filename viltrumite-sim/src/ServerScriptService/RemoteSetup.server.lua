-- Creates all RemoteEvents / RemoteFunctions before any other server script needs them.
-- Must run before Main.server.lua — Roblox executes Scripts in ServerScriptService alphabetically,
-- so "RemoteSetup" sorts before most names. Rename to "AARemoteSetup" if load order ever breaks.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = Instance.new("Folder")
Remotes.Name  = "Remotes"
Remotes.Parent = ReplicatedStorage

local function event(name)
	local e      = Instance.new("RemoteEvent")
	e.Name       = name
	e.Parent     = Remotes
end

local function fn(name)
	local f      = Instance.new("RemoteFunction")
	f.Name       = name
	f.Parent     = Remotes
end

-- Combat
event("CombatHit")           -- client → server : register M1 hit
event("CombatBlock")         -- client → server : toggle block
event("UseMove")             -- client → server : fire special
event("HitEffect")           -- server → all    : play gore/sfx on target
event("Ragdoll")             -- server → all    : enable/disable ragdoll
event("ScreenShake")         -- server → near   : shake intensity

-- Flight
event("FlightToggle")        -- client → server : request toggle
event("FlightUpdate")        -- client → server : send current velocity
event("FlightStateChanged")  -- server → client : confirm new state

-- Progression
event("StatsUpdated")        -- server → client : stat snapshot
event("PowerLevelUp")        -- server → client : PL milestone
event("BloodlineAssigned")   -- server → client : bloodline roll result
event("XPGained")            -- server → client : XP amount popup

-- Conquest
event("ZoneCapture")         -- server → all    : zone changed hands
event("ZoneProgress")        -- server → all    : capture % tick
event("ScoreUpdate")         -- server → all    : team score table
event("ConquestWin")         -- server → all    : game over, winner

-- UI
event("ShowNotification")    -- server → client : toast message
event("ShowDialogue")        -- server → client : NPC speech
event("BossSpawned")         -- server → all    : boss appeared
event("BossDefeated")        -- server → all    : boss killed

-- Boss
event("BossHealthUpdate")    -- server → all    : boss HP changed
event("BossMove")            -- server → all    : boss using a move (effects)

-- Quests
event("QuestAssigned")       -- server → client : new quest active
event("QuestProgress")       -- server → client : objective updated
event("QuestCompleted")      -- server → client : quest finished + rewards
event("OpenQuestDialog")     -- server → client : open Cecil dialog
event("AcceptQuest")         -- client → server : player accepts quest

-- Leaderboard
event("LeaderboardUpdate")   -- server → all    : global top-10 data
event("SessionBoard")        -- server → client : current session ranking
event("GetLeaderboard")      -- client → server : request refresh
event("GetSessionBoard")     -- client → server : request session board

-- Guilds
event("GuildCreated")        -- server → all    : new guild announced
event("GuildJoined")         -- server → client : you joined a guild
event("GuildLeft")           -- server → client : you left your guild
event("GuildInfo")           -- server → members: guild data updated
event("GuildDisbanded")      -- server → all    : guild disbanded
event("CreateGuild")         -- client → server : create request
event("JoinGuild")           -- client → server : join request
event("LeaveGuild")          -- client → server : leave request

-- Animation / Sound
event("PlayAnimation")       -- server → all    : play anim on a character
event("PlaySound")           -- server → all    : play sound at position

-- Cosmetics
event("CostumeChanged")      -- server → all    : player changed costume
event("EquipCosmetic")       -- client → server : equip a cosmetic

-- Destruction
event("CraterCreated")       -- server → all    : crater visual at position

-- Functions
fn("GetPlayerData")          -- client → server : initial data fetch
fn("RollBloodline")          -- client → server : reroll (if permitted)
fn("GetOwnedCosmetics")      -- client → server : fetch unlock status

print("[RemoteSetup] All remotes created.")
