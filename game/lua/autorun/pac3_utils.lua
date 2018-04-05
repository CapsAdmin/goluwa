commands.Add("extract_workshop=arg_line", function(url)
	if CLI then system.ForceMainLoop() end
	steam.DownloadWorkshop(url:match("id=(%d+)"), function(info, path)
		local ok, err = pcall(function()
			local root = path
			local name = vfs.FixIllegalCharactersInPath(info.response.publishedfiledetails[1].title, true)

			local outdir = system.GetWorkingDirectory() .. name .. "/"
			logn("writing to ", outdir)

			logn("writing ",outdir,"workshop_info.lua")
			assert(vfs.CreateDirectoriesFromPath(outdir .. "workshop_info.lua", true))
			assert(serializer.WriteFile("luadata", outdir .. "workshop_info.lua", info.response))

			vfs.Search(path, nil, function(path)
				if not vfs.IsDirectory(path) then
					local relative = path:match("^.-:(.+)$")
					relative = relative:sub(#root + 2)
					logn("extracting ", relative)

					assert(vfs.CreateDirectoriesFromPath(outdir .. relative, true))
					assert(vfs.Write(outdir .. relative, vfs.Read(path)))
				end
			end)
		end)
		if not ok then print(err) end
		if CLI then system.ShutDown() end
	end)
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

			logn("\twriting ", file, " (", utility.FormatFileSize(#bin), ")")

			vfs.CreateDirectoriesFromPath(path, true)
			vfs.Write(path, bin)
		end
	end
end)