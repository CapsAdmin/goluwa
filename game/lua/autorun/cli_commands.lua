commands.Add("extract_workshop=arg_line", function(url)
	local gma_path, info = assert(steam.DownloadWorkshop(url))
	local name = vfs.ReplaceIllegalPathSymbols(info.publishedfiledetails[1].title, true)

	local out = system.GetWorkingDirectory() .. name .. "/"

	vfs.Write(out .. "workshop_info.luadata", info)

	for _, path in ipairs(vfs.GetFilesRecursive(gma_path)) do
		vfs.Write(out .. vfs.AbsoluteToRelativePath(gma_path, path), vfs.Read(path))
	end
end)

commands.Add("workshop2dir=arg_line", function(dir)
	local cd = system.GetWorkingDirectory()

	if dir == "." then
		dir = ""
	end

	if not vfs.IsDirectory(cd .. dir) then
		vfs.CreateDirectory(cd .. dir, true)
		cd = cd .. dir .. "/"
	end

	if not vfs.IsFile(cd .. "addons.txt") then
		logn("create a file called addons.txt containing workshop links")
		return
	end

	for id in vfs.Read(cd .. "addons.txt"):gmatch("%?id=(%d+)") do
		local gma_path, info = assert(steam.DownloadWorkshop(id))
		for _, path in ipairs(vfs.GetFilesRecursive(gma_path)) do
			vfs.Write(cd .. vfs.AbsoluteToRelativePath(gma_path, path), vfs.Read(path))
		end
	end
end)

commands.Add("extract_pac3_vfs_json=arg_line", function(line)
	for _, file in ipairs(utility.CLIPathInputToTable(line, {"json"})) do
		local data = serializer.ReadFile("json", file)

		local compression = data.compression
		data.compression = nil

		for path, bytes in pairs(data) do
			local bin = bytes:split(" ")

			for i,v in ipairs(bin) do
				bin[i] = string.char(tonumber(v))
			end

			bin = table.concat(bin)

			if compression then
				logn("\tdecompressing ", path)
				bin = serializer.Decode("lzma", bin)
			end

			local path = system.GetWorkingDirectory() .. vfs.RemoveExtensionFromPath(vfs.GetFileNameFromPath(file)) .. "/" .. path

			vfs.Write(path, bin)
		end
	end
end)