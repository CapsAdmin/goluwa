local vfs = (...) or _G.vfs
local lfs = require("lfs")

vfs.included_files = vfs.included_files or {}

local function store(path)
	local path = vfs.FixPath(path:lower())
	vfs.included_files[path] = lfs.attributes(path)
end

function loadfile(path, ...)		
	store(path)
	return _OLD_G.loadfile(path, ...)
end

function dofile(path, ...)
	store(path)		
	return _OLD_G.dofile(path, ...)
end
	
function vfs.GetLoadedLuaFiles()
	return vfs.included_files
end

function vfs.MonitorFile(file_path, callback)
	check(file_path, "string")
	check(callback, "function")

	local last = vfs.GetAttributes(file_path)
	
	if last then
		last = last.modification
		event.CreateTimer(file_path, 0, 0, function()
			local time = vfs.GetAttributes(file_path)
			if time then
				time = time.modification
				if last ~= time then
					logf("[vfs monitor] %s changed!\n", file_path)
					last = time
					return callback(file_path)
				end
			else
				logf("[vfs monitor] %s was removed\n", file_path)
				event.RemoveTimer(file_path)
			end
		end)
	else
		logf("[vfs monitor] %s was not found\n", file_path)
	end
end

function vfs.MonitorFileInclude(source, target)
	source = source or vfs.GetCurrentPath(3)
	target = target or source
	
	vfs.MonitorFile(source, function()
		event.Delay(0, function()
			dofile(target)
		end)
	end)
end

function vfs.MonitorEverything(b)
	if not b then
		event.RemoveTimer("vfs_monitor_everything")
		return
	end

	event.CreateTimer("vfs_monitor_everything", 0.1, 0, function()
		for path, data in pairs(vfs.GetLoadedLuaFiles()) do
			local info = lfs.attributes(path)
			
			if info then
				if not data.modification then
					data.modification = info.modification
				else 
					if data.modification ~= info.modification then
						logn("reloading ", vfs.GetFileNameFromPath(path))
						_G.RELOAD = true
						include(path) 
						_G.RELOAD = nil
						data.modification = info.modification
					end
				end			
			end
		end
	end)
end