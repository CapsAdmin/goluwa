commands.Add("extract_pac3vfs_json", function(dir)
	dir = dir or ""

	if dir == "." then
		dir = ""
	end

	dir = vfs.FixPathSlashes(system.GetWorkingDirectory() .. dir)

	if not dir:endswith("/") then
		dir = dir .. "/"
	end

	if not vfs.IsDirectory(dir) then
		return false, "not a directory"
	end

	for _, file in pairs(vfs.Find(dir)) do
		if file:endswith(".json") then
			logn(file)
			local data = serializer.ReadFile("json", dir .. file)

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

				local path = dir .. file:sub(0, -6) .. "/" .. path

				logn("\twriting ", file, " (", utility.FormatFileSize(#bin), ")")

				vfs.CreateDirectoriesFromPath(path, true)
				vfs.Write(path, bin)
			end
		end
	end
end)