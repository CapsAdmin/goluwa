local vfs = (...) or _G.vfs

local fs = require("fs")

function vfs.MonitorFile(file_path, callback)
	check(file_path, "string")
	check(callback, "function")

	local last = vfs.GetLastModified(file_path)
	local first = true

	if last then
		event.Timer(file_path, 1, 0, function()
			local time = vfs.GetLastModified(file_path)
			if time then
				if first then first = nil return end
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

	event.Timer("vfs_monitor_everything", 0.1, 0, function()
		if GRAPHICS and window.IsFocused() then return end
		if profiler.IsBusy() then return end -- I already know this is slow so it's just in the way
		for path, data in pairs(vfs.GetLoadedLuaFiles()) do
			local info = fs.getattributes(path)

			if info then
				if not data.last_modified then
					data.last_modified = info.last_modified
				else
					if data.last_modified ~= info.last_modified then
						logn("reloading ", vfs.GetFileNameFromPath(path))
						_G.RELOAD = true
						include(path)
						_G.RELOAD = nil
						data.last_modified = info.last_modified
					end
				end
			end
		end
	end)
end