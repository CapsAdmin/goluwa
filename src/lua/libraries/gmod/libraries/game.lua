local gmod = ... or _G.gmod

local game = gmod.env.game

function game.AddParticles() end
function game.AddDecal() end

function game.GetMap() return "gm_construct" end

function game.MaxPlayers() return 32 end
function game.SinglePlayer() return false end
function game.StartTime() return system.GetElapsedTime() end