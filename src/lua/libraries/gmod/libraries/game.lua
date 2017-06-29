local gine = ... or _G.gine

local game = gine.env.game

function game.GetMap()
	return "gm_construct"
end

function game.GetIPAddress()
	return "0.0.0.0:27015"
end