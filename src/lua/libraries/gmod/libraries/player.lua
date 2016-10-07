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