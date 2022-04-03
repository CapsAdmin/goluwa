local engine = gine.env.engine

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
	wlog("nope")
end

function engine.IsPlayingDemo() return false end
function engine.IsRecordingDemo() return false end

function engine.LightStyle() end

function engine.ServerFrameTime()
	return 1/33
end

function engine.GetGamemodes()
	return {
		{
			["maps"] = "",
			["title"] = "Base",
			["menusystem"] = false,
			["name"] = "base",
			["workshopid"] = "0",
		},
		{
			["maps"] = "^gm_|^gmod_|^phys_",
			["title"] = "Sandbox",
			["menusystem"] = true,
			["name"] = "sandbox",
			["workshopid"] = "0",
		},
		{
			["maps"] = "^ttt_",
			["title"] = "Trouble in Terrorist Town",
			["menusystem"] = true,
			["name"] = "terrortown",
			["workshopid"] = "0",
		},
	}
end