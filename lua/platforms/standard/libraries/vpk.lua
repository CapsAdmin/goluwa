local vpk = {}

function vpk.ReadString(file)
	local buffer = {}

	while true do
		local char = file:read(1)
		if not char then print("HUH") return end
		if char == "\0" then break end
		buffer[#buffer + 1] = char
	end

	return table.concat(buffer)
end

function vpk.Open(path)
	check(path, "string")

	local file, error = vfs.GetFile(path .. "_dir.vpk", "rb")

	if not file then
		print("oh noes", error)
		return
	end

	local header = {}

	do
		local bytes = {file:read(12):byte(1, -1)}

		if #bytes ~= 12 then
			print("knurr")
			file:close()
			return
		end

		header.Signature = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
		header.Version = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8 + bytes[7] * 2 ^ 16 + bytes[8] * 2 ^ 24
		header.TreeLength = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
		header.HeaderLength = 12
	end

	if header.Signature ~= 0x55aa1234 then
		print("grr")
		file:close()
		return
	end

	if header.Version == 2 then
		header.HeaderLength = header.HeaderLength + 16

		do
			local bytes = {file:read(16):byte(1, -1)}

			if #bytes ~= 16 then
				print("fail")
				file:close()
				return
			end

			header.Unknown1 = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
			header.FooterLength = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8 + bytes[7] * 2 ^ 16 + bytes[8] * 2 ^ 24
			header.Unknown3 = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
			header.Unknown4 = bytes[13] * 2 ^ 0 + bytes[14] * 2 ^ 8 + bytes[15] * 2 ^ 16 + bytes[16] * 2 ^ 24
		end
	elseif header.Version ~= 1 then
		print("boing")
		file:close()
		return
	end

	local entries = {}
	local entries_count = 0

	local tree = {}
	local list = {}

	while true do
		local extension = vpk.ReadString(file)

		if not extension or extension == "" then
			break
		end

		extension = extension ~= " " and extension or ""
		tree[extension] = {}

		while true do
			local directory = vpk.ReadString(file)

			if not directory or directory == "" then
				break
			end

			directory = directory ~= " " and directory or ""
			tree[extension][directory] = {}

			while true do
				local name = vpk.ReadString(file)

				if not name or name == "" then
					break
				end

				name = name ~= " " and name or ""

				local entry = {}

				entry.Path = (directory ~= "" and (directory .. "/") or "") .. name .. (extension ~= "" and ("." .. extension) or "")

				do
					local bytes = {file:read(18):byte(1, -1)}

					if #bytes ~= 18 then
						print("heul")
						file:close()
						return
					end

					entry.CRC = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
					entry.PreloadOffset = file:seek()
					entry.PreloadBytes = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8
					entry.ArchiveIndex = bytes[7] * 2 ^ 0 + bytes[8] * 2 ^ 8
					entry.EntryOffset = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
					entry.EntryLength = bytes[13] * 2 ^ 0 + bytes[14] * 2 ^ 8 + bytes[15] * 2 ^ 16 + bytes[16] * 2 ^ 24

					if (bytes[17] * 2 ^ 0 + bytes[18] * 2 ^ 8) ~= 0xffff then
						print("what the")
						file:close()
						return
					end
				end

				file:seek("cur", entry.PreloadBytes)

				entries[entries_count * 6 + 1] = entry.ArchiveIndex
				entries[entries_count * 6 + 2] = entry.EntryOffset
				entries[entries_count * 6 + 3] = entry.EntryLength
				entries[entries_count * 6 + 4] = entry.PreloadOffset
				entries[entries_count * 6 + 5] = entry.PreloadBytes
				entries[entries_count * 6 + 6] = entry.CRC

				tree[extension][directory][name] = entries_count
				list[entry.Path] = entries_count

				entries_count = entries_count + 1
			end
		end
	end

	file:close()

	local self = {
		path = path,
		entries = entries,
		tree = tree,
		list = list
	}

	function self:Read(path)
		if not self.list[path] then return end
		return self:ReadByIndex(self.list[path])
	end

	function self:ReadByIndex(index)
		if index < 0 or index >= #self.entries / 6 then return end

		local archive = self.entries[index * 6 + 1]
		local offset = self.entries[index * 6 + 2]
		local length = self.entries[index * 6 + 3]
		local preload_offset = self.entries[index * 6 + 4]
		local preload_length = self.entries[index * 6 + 5]
		local checksum = self.entries[index * 6 + 6]

		if preload_length > 0 then
			print("PRELOAD EEK " .. preload_length)
		end

		local file = vfs.GetFile(string.format("%s_%.3d.vpk", self.path, archive), "rb")

		if not file then
			print("i expected more from you")
			return
		end

		file:seek("set", offset)
		local data = file:read(length)
		file:close()

		return data
	end

	return self
end

return vpk
