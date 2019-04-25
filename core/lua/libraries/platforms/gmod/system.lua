local system = ... or _G.system
local ffi = require("ffi")

function system.OpenURL(url)
	gmod.gui.OpenURL(url)
end

function system.Sleep(ms)

end

local SysTime = gmod.SysTime
function system.GetTime()
	return SysTime()
end

function system.SetConsoleTitleRaw(str)

end

function system.FindFirstTextEditor(os_execute, with_args)

end

function system.SetSharedLibraryPath(path)

end

function system.GetSharedLibraryPath()
	return ""
end

function system._OSCommandExists(cmd)
	return false
end