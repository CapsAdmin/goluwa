local gmod = ... or _G.gmod

local engine = gmod.env.engine

function engine.ActiveGamemode()
	return gmod.current_gamemode.FolderName
end

function engine.CloseServer()
	warning("nope")
end

function engine.IsPlayingDemo() return false end
function engine.IsRecordingDemo() return false end