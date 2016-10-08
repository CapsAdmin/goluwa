local gmod = ... or _G.gmod

local player = gmod.env.player

function player.GetAll()
	local out = {}
	local i = 1

	for _, ent in pairs(gmod.objects.Player) do
		if ent:IsValid() then
			table.insert(out, ent)
		end
	end

	return out
end

function player.GetHumans()
	local out = {}
	local i = 1

	for _, ent in pairs(gmod.objects.Player) do
		if not ent.__obj:IsBot() then
			if ent:IsValid() then
				table.insert(out, ent)
			end
		end
	end

	return out
end

function player.GetBots()
	local out = {}
	local i = 1

	for _, ent in pairs(gmod.objects.Player) do
		if ent.__obj:IsBot() then
			table.insert(out, ent)
		end
	end

	return out
end

player.GetHumans = player.GetAll
function player.GetBots() return {} end

function player.GetByUniqueID(id)
	for _, ply in ipairs(player.GetAll()) do
		if ply:UniqueID() == id then
			return ply
		end
	end
end

function player.GetBySteamID(id)
	for _, ply in ipairs(player.GetAll()) do
		if ply:SteamID() == id then
			return ply
		end
	end
end

function player.GetBySteamID64(id)
	for _, ply in ipairs(player.GetAll()) do
		if ply:SteamID64() == id then
			return ply
		end
	end
end

function player.CreateNextBot(name)
	local client = clients.CreateBot()
	client:SetNick(name)
	return gmod.WrapObject(cllient, "Player")
end