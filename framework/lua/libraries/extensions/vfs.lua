local fs = require("fs")

function vfs.MonitorFile(file_path, callback)
	local last = vfs.GetLastModified(file_path)
	local first = true

	if last then
		event.Timer(file_path, 1, 0, function()
			local time = vfs.GetLastModified(file_path)
			if time then
				if first then first = nil return end
				if last ~= time then
					llog("%s changed!", file_path)
					last = time
					return callback(file_path)
				end
			else
				llog("%s was removed", file_path)
				event.RemoveTimer(file_path)
			end
		end)
	else
		llog("%s was not found", file_path)
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

