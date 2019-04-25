local function extract_single(id, dir)
	local gma_path, info = assert(steam.DownloadWorkshop(id))

	local directory_name =
		dir and (dir == "." and "" or (dir .. "/")) or
		vfs.ReplaceIllegalPathSymbols(info.publishedfiledetails[1].title, true) .. "/"

	local out = system.GetWorkingDirectory() .. directory_name
	vfs.Write(out .. "workshop_info.luadata", info)

	for _, path in ipairs(vfs.GetFilesRecursive(gma_path)) do
		vfs.Write(out .. vfs.AbsoluteToRelativePath(gma_path, path), vfs.Read(path))
	end
end

commands.Add("gmod-workshop-extract=string,string|nil", function(id, dir)
	extract_single(id, dir)
end)

commands.Add("gmod-workshop-extract-collection=string", function(id)
	if not tonumber(id) and not id:find("steamcommunity.com") then
		for id in assert(http.Download(id)):gmatch("id=(%d+)") do
			extract_single(id)
		end
	else
		for _, id in ipairs(assert(steam.DownloadWorkshopCollection(id))) do
			extract_single(id)
		end
	end
end)

do
	local function check_single(id, no_linenumbers, suspicious_only)
		local gma_path, info = assert(steam.DownloadWorkshop(id))
		logn("==============================", info.publishedfiledetails[1].title, "==============================")
		logn("http://steamcommunity.com/workshop/filedetails/?id=" .. info.publishedfiledetails[1].publishedfileid)

		local name = vfs.ReplaceIllegalPathSymbols(info.publishedfiledetails[1].title, true)

		if vfs.IsDirectory(gma_path .. "/lua") or vfs.IsDirectory(gma_path .. "/gamemodes") then
			gine.CheckDirectory(gma_path .. "/lua/", name, no_linenumbers, suspicious_only)
			gine.CheckDirectory(gma_path .. "/gamemodes/", name, no_linenumbers, suspicious_only)
		else
			logn("no lua or gamemode folder")
			table.print(vfs.Find(gma_path .. "/"))
		end

		logn("============================================================")
	end

	commands.Add("gmod-workshop-check-exploit=string,boolean,boolean[true]", function(id, no_linenumbers, suspicious_only)
		check_single(id, no_linenumbers, suspicious_only)
	end)

	commands.Add("gmod-workshop-check-exploit-collection=string,boolean,boolean[true]", function(id, no_linenumbers, suspicious_only)
		if not tonumber(id) and not id:find("steamcommunity.com") then
			for id in assert(http.Download(id)):gmatch("id=(%d+)") do
				check_single(id, no_linenumbers, suspicious_only)
			end
		else
			for _, id in ipairs(assert(steam.DownloadWorkshopCollection(id))) do
				check_single(id, no_linenumbers, suspicious_only)
			end
		end
	end)
end

commands.Add("gmod-workshop2dir=arg_line", function(dir)
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