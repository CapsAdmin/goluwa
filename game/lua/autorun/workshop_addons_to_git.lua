commands.Add("workshop2git=arg_line", function(dir)
	local cd = system.GetWorkingDirectory()

	if dir == "." then dir = "" end

	if not vfs.IsDirectory(cd .. dir) then
		assert(vfs.CreateDirectory(cd .. dir, true))
		cd = cd .. dir .. "/"
	end

	if not vfs.IsDirectory(cd .. ".git") then
		local cd = cd:match("^.-:(.+)$")
		os.execute("git -C "..cd.." init")
	end

	if not vfs.IsFile(cd .. "addons.txt") then
		logn("create a file called addons.txt containing workshop links")
		return
	end

	if CLI then system.ForceMainLoop() end

	local ids = {}

	for id in vfs.Read(cd .. "addons.txt"):gmatch("%?id=(%d+)") do
		table.insert(ids, id)
	end

	local function download(id)
		if not id then
			if CLI then system.ShutDown() end
			return
		end

		steam.DownloadWorkshop(id, function(info, path)
			vfs.Search(path, nil, function(path)
				if vfs.IsDirectory(path) then return end

				local relative = path:match("^.-:.-/file.gma/(.+)$")

				logn(cd .. relative)

				vfs.CreateDirectoriesFromPath(cd .. relative, true)
				vfs.Write(cd .. relative, vfs.Read(path))
			end)

			download(table.remove(ids))
		end)
	end

	download(table.remove(ids))
end)