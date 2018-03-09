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