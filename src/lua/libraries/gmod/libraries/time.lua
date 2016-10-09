function gmod.env.system.SteamTime()
	return os.clock()
end

function gmod.env.system.AppTime()
	return os.clock()
end

function gmod.env.system.UpTime()
	return os.clock()
end

function gmod.env.RealTime()
	return _G.system.GetElapsedTime()
end

function gmod.env.FrameNumber()
	return tonumber(_G.system.GetFrameNumber())
end

function gmod.env.FrameTime()
	return _G.system.GetFrameTime()
end

function gmod.env.VGUIFrameTime()
	return _G.system.GetElapsedTime()
end

function gmod.env.CurTime()  --system.GetServerTime()
	return _G.system.GetElapsedTime()
end

function gmod.env.SysTime()  --system.GetServerTime()
	return _G.system.GetTime()
end

function gmod.env.engine.TickInterval()
	return 0.33
end

function gmod.env.game.StartTime()
	return system.GetElapsedTime()
end
