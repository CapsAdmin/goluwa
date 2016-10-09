local gmod = ... or gmod
local system = gmod.env.system

function system.IsLinux()
	return true
end

function system.IsWindows()
	return false
end

function system.IsOSX()
	return false
end

function system.HasFocus()
	return window.IsFocused()
end

function system.GetCountry()
	return "NO"
end

function system.IsWindowed()
	return true
end

function system.SteamTime()
	return os.clock()
end

function system.AppTime()
	return os.clock()
end

function system.UpTime()
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
