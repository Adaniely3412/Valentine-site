-- Guild / Warband system. Guilds persist across sessions via DataStore.
-- Max 10 members. Guild faction aligns with Viltrumite Empire or Earth Defenders.

local GuildService = {}

local Players           = game:GetService("Players")
local DataStoreService  = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuildStore = DataStoreService:GetDataStore("GuildData_v1")
local STORE_KEY  = "AllGuilds"

local guilds    = {}  -- { [guildName] = guildObject }
local playerGuild = {} -- { [userId] = guildName }

local function R() return ReplicatedStorage:WaitForChild("Remotes", 10) end

-- ── Persistence ───────────────────────────────────────────────────

local function loadGuilds()
	local ok, data = pcall(function() return GuildStore:GetAsync(STORE_KEY) end)
	if ok and data then
		guilds = data
	end
end

local function saveGuilds()
	pcall(function() GuildStore:SetAsync(STORE_KEY, guilds) end)
end

loadGuilds()

-- ── Helpers ───────────────────────────────────────────────────────

local function fireGuildMembers(guildName, remoteName, ...)
	local guild = guilds[guildName]
	if not guild then return end
	local remotes = R()
	for _, uid in ipairs(guild.members) do
		local p = Players:GetPlayerByUserId(uid)
		if p then
			local ev = remotes:FindFirstChild(remoteName)
			if ev then ev:FireClient(p, ...) end
		end
	end
end

local function countOnlineMembers(guildName)
	local guild = guilds[guildName]
	if not guild then return 0 end
	local count = 0
	for _, uid in ipairs(guild.members) do
		if Players:GetPlayerByUserId(uid) then count += 1 end
	end
	return count
end

-- ── Public API ────────────────────────────────────────────────────

function GuildService.Create(player, guildName, faction)
	-- Validate
	if playerGuild[player.UserId] then
		R().ShowNotification:FireClient(player, "Leave your current warband first.", "error")
		return false
	end
	if guilds[guildName] then
		R().ShowNotification:FireClient(player, "Warband name already taken.", "error")
		return false
	end
	if #guildName < 3 or #guildName > 24 then
		R().ShowNotification:FireClient(player, "Name must be 3-24 characters.", "error")
		return false
	end
	local validFactions = { ["Viltrumite Empire"]=true, ["Earth Defenders"]=true }
	if not validFactions[faction] then
		R().ShowNotification:FireClient(player, "Invalid faction.", "error")
		return false
	end

	guilds[guildName] = {
		name           = guildName,
		faction        = faction,
		leader         = player.UserId,
		members        = { player.UserId },
		conquestScore  = 0,
		created        = os.time(),
	}
	playerGuild[player.UserId] = guildName

	-- Apply faction to character
	local char = player.Character
	if char then char:SetAttribute("Faction", faction) end

	saveGuilds()
	R().GuildCreated:FireAllClients(guilds[guildName])
	R().GuildJoined:FireClient(player, guilds[guildName])
	R().ShowNotification:FireClient(player, "Warband '" .. guildName .. "' created!", "success")
	return true
end

function GuildService.Join(player, guildName)
	if playerGuild[player.UserId] then
		R().ShowNotification:FireClient(player, "Leave your current warband first.", "error")
		return false
	end
	local guild = guilds[guildName]
	if not guild then
		R().ShowNotification:FireClient(player, "Warband not found.", "error")
		return false
	end
	if #guild.members >= 10 then
		R().ShowNotification:FireClient(player, "Warband is full (10/10).", "error")
		return false
	end

	table.insert(guild.members, player.UserId)
	playerGuild[player.UserId] = guildName

	local char = player.Character
	if char then char:SetAttribute("Faction", guild.faction) end

	saveGuilds()
	fireGuildMembers(guildName, "GuildInfo", guild)
	R().GuildJoined:FireClient(player, guild)
	R().ShowNotification:FireClient(player, "Joined warband '" .. guildName .. "'!", "success")
	return true
end

function GuildService.Leave(player)
	local guildName = playerGuild[player.UserId]
	if not guildName then
		R().ShowNotification:FireClient(player, "You're not in a warband.", "error")
		return
	end
	local guild = guilds[guildName]
	if not guild then
		playerGuild[player.UserId] = nil
		return
	end

	-- Remove from members
	for i, uid in ipairs(guild.members) do
		if uid == player.UserId then
			table.remove(guild.members, i)
			break
		end
	end
	playerGuild[player.UserId] = nil

	-- If leader left, transfer to next member or disband
	if guild.leader == player.UserId then
		if #guild.members > 0 then
			guild.leader = guild.members[1]
			local newLeader = Players:GetPlayerByUserId(guild.leader)
			if newLeader then
				R().ShowNotification:FireClient(newLeader, "You are now the warband leader.", "info")
			end
		else
			guilds[guildName] = nil
			R().GuildDisbanded:FireAllClients(guildName)
		end
	end

	saveGuilds()
	R().GuildLeft:FireClient(player, guildName)
	if guilds[guildName] then
		fireGuildMembers(guildName, "GuildInfo", guilds[guildName])
	end
end

function GuildService.GetPlayerGuild(player)
	local name = playerGuild[player.UserId]
	return name and guilds[name]
end

function GuildService.GetAll()
	-- Return sorted by conquestScore
	local list = {}
	for _, g in pairs(guilds) do table.insert(list, g) end
	table.sort(list, function(a, b) return (a.conquestScore or 0) > (b.conquestScore or 0) end)
	return list
end

function GuildService.AddConquestScore(guildName, amount)
	if guilds[guildName] then
		guilds[guildName].conquestScore = (guilds[guildName].conquestScore or 0) + amount
	end
end

-- Restore guild membership for returning players
function GuildService.OnPlayerAdded(player)
	for name, guild in pairs(guilds) do
		for _, uid in ipairs(guild.members) do
			if uid == player.UserId then
				playerGuild[player.UserId] = name
				local char = player.Character
				if char then char:SetAttribute("Faction", guild.faction) end
				task.delay(2, function()
					if player and player.Parent then
						R().GuildJoined:FireClient(player, guild)
					end
				end)
				return
			end
		end
	end
end

function GuildService.OnPlayerRemoving(player)
	playerGuild[player.UserId] = nil
end

return GuildService
