if CLI then
	event.AddListener("VFSPreWrite", "log_write", function(path, data)
		if
			path:starts_with("data/") or
			vfs.GetPathInfo(path).full_path:starts_with(e.STORAGE_FOLDER)
		then
			return
		end

		if path:starts_with(system.GetWorkingDirectory()) then
			path = path:sub(#system.GetWorkingDirectory() + 1)
		end

		logn("[vfs] writing ", path, " - ", utility.FormatFileSize(#data))
	end)
end