local vfs2 = (...) or _G.vfs2

local lfs = require("lfs")

function vfs2.MonitorFile(file_path, callback)
	check(file_path, "string")
	check(callback, "function")

	local last = vfs2.GetAttributes(file_path)
	
	if last then
		last = last.modification
		event.CreateTimer(file_path, 0, 0, function()
			local time = vfs2.GetAttributes(file_path)
			if time then
				time = time.modification
				if last ~= time then
					logf("[vfs2 monitor] %s changed!\n", file_path)
					last = time
					return callback(file_path)
				end
			else
				logf("[vfs2 monitor] %s was removed\n", file_path)
				event.RemoveTimer(file_path)
			end
		end)
	else
		logf("[vfs2 monitor] %s was not found\n", file_path)
	end
end

function vfs2.MonitorFileInclude(source, target)
	source = source or vfs2.GetCurrentPath(3)
	target = target or source
	
	vfs2.MonitorFile(source, function()
		event.Delay(0, function()
			dofile(target)
		end)
	end)
end

function vfs2.MonitorEverything(b)
	if not b then
		event.RemoveTimer("vfs_monitor_everything")
		return
	end

	event.CreateTimer("vfs_monitor_everything", 0.1, 0, function()
		for path, data in pairs(vfs2.GetLoadedLuaFiles()) do
			local info = lfs.attributes(path)
			
			if info then
				if not data.modification then
					data.modification = info.modification
				else 
					if data.modification ~= info.modification then
						logn("reloading ", vfs2.GetFileNameFromPath(path))
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