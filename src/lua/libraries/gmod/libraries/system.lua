local gmod = ... or gmod
local gmod_system = gmod.env.system

function gmod_system.IsLinux()
	return true
end

function gmod_system.IsWindows()
	return false
end

function gmod_system.IsOSX()
	return false
end

function gmod_system.HasFocus()
	return window.IsFocused()
end

function gmod_system.GetCountry()
	return "NO"
end

function gmod_system.IsWindowed()
	return true
end

function gmod_system.SteamTime()
	return os.clock()
end

function gmod_system.AppTime()
	return os.clock()
end

function gmod_system.UpTime()
	return os.clock()
end