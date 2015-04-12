local gmod = ... or _G.gmod

local engine = gmod.env.engine

function engine.ActiveGamemode()
	return gmod.current_gamemode.FolderName
end

function engine.GetAddons()
	return {}
end

function engine.GetGames()
	return {
		{
			depot = 220,
			title = "Half-Life 2",
			owned = true,
			folder = "hl2",
			mounted = true,
			installed = true,
		},
		{
			depot = 240,
			title = "Counter-Strike",
			owned = false,
			folder = "cstrike",
			mounted = false,
			installed = false,
		},
		--[[{
			depot = 300,
			title = "Day of Defeat",
			owned = false,
			folder = dod,
			mounted = false,
			installed = false,
		},]]
		{
			depot = 440,
			title = "Team Fortress 2",
			owned = true,
			folder = "tf",
			mounted = true,
			installed = true,
		},
	}
end

function engine.CloseServer()
	warning("nope")
end

function engine.IsPlayingDemo() return false end
function engine.IsRecordingDemo() return false end