local gmod = ... or _G.gmod

local player = gmod.env.player

function player.GetAll()
	local out = {}
	local i = 1

	for obj, ent in pairs(gmod.objects.Player) do
		table.insert(out, ent)
	end

	return out
end