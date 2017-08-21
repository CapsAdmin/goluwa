function gine.env.system.SteamTime()
	return os.clock()
end

function gine.env.system.AppTime()
	return os.clock()
end

function gine.env.system.UpTime()
	return os.clock()
end

function gine.env.RealTime()
	return _G.system.GetElapsedTime()
end

function gine.env.FrameNumber()
	return tonumber(_G.system.GetFrameNumber())
end

function gine.env.FrameTime()
	return _G.system.GetFrameTime()
end

function gine.env.VGUIFrameTime()
	return _G.system.GetElapsedTime()
end

function gine.env.CurTime()  --system.GetServerTime()
	return _G.system.GetElapsedTime()
end

function gine.env.SysTime()  --system.GetServerTime()
	return _G.system.GetTime()
end

function gine.env.engine.TickInterval()
	return 0.33
end

function gine.env.game.StartTime()
	return system.GetElapsedTime()
end
