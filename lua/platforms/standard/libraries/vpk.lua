local vpk = _G.vpk or {debug = false}

function vpk.Trace(format, ...)
	print("[VPK] " .. string.format(format, ...))
end

function vpk.Open(path)
	check(path, "string")

	local file, error = vfs.GetFile(path .. "_dir.vpk", "rb")

	if not file then
		vpk.Trace("Failed opening %q", path)
		return
	end

	local header = {}

	do
		local bytes = {file:read(12):byte(1, -1)}

		if #bytes ~= 12 then
			vpk.Trace("Failed reading header")
			file:close()
			return
		end

		header.Signature = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
		header.Version = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8 + bytes[7] * 2 ^ 16 + bytes[8] * 2 ^ 24
		header.TreeLength = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
		header.HeaderLength = 12
	end

	if header.Signature ~= 0x55aa1234 then
		vpk.Trace("Invalid signature in header")
		file:close()
		return
	end

	if header.Version == 2 then
		header.HeaderLength = header.HeaderLength + 16

		do
			local bytes = {file:read(16):byte(1, -1)}

			if #bytes ~= 16 then
				vpk.Trace("Failed reading extended header")
				file:close()
				return
			end

			header.Unknown1 = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
			header.FooterLength = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8 + bytes[7] * 2 ^ 16 + bytes[8] * 2 ^ 24
			header.Unknown3 = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
			header.Unknown4 = bytes[13] * 2 ^ 0 + bytes[14] * 2 ^ 8 + bytes[15] * 2 ^ 16 + bytes[16] * 2 ^ 24
		end
	elseif header.Version ~= 1 then
		vpk.Trace("Invalid version %d", header.Version)
		file:close()
		return
	end

	local function read_string()
		local buffer = {}

		while true do
			local char = file:read(1)

			if char == "\0" then -- Finished reading string
				break
			elseif not char then -- Probably EOF
				return
			end

			buffer[#buffer + 1] = char
		end

		return table.concat(buffer)
	end

	local lookup = {}
	local entries = {}
	local entries_count = 0

	while true do
		local extension = read_string()

		if not extension or extension == "" then
			break
		end

		while true do
			local directory = read_string()

			if not directory or directory == "" then
				break
			end

			while true do
				local name = read_string()

				if not name or name == "" then
					break
				end

				local entry = {}
				entry.Path = (directory ~= " " and (directory .. "/") or "") .. (name ~= " " and name or "") .. (extension ~= " " and ("." .. extension) or "")

				do
					local bytes = {file:read(18):byte(1, -1)}

					if #bytes ~= 18 then
						vpk.Trace("Failed reading directory entry")
						file:close()
						return
					end

					entry.CRC = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
					entry.PreloadOffset = file:seek()
					entry.PreloadBytes = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8
					entry.ArchiveIndex = bytes[7] * 2 ^ 0 + bytes[8] * 2 ^ 8
					entry.EntryOffset = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
					entry.EntryLength = bytes[13] * 2 ^ 0 + bytes[14] * 2 ^ 8 + bytes[15] * 2 ^ 16 + bytes[16] * 2 ^ 24
					entry.Terminator = bytes[17] * 2 ^ 0 + bytes[18] * 2 ^ 8

					if entry.Terminator ~= 0xffff then
						vpk.Trace("Invalid directory entry terminator 0x%.4x", entry.Terminator)
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

				lookup[entry.Path] = entries_count

				entries_count = entries_count + 1
			end
		end
	end

	file:close()

	local self = {
		path = path,
		entries = entries,
		lookup = lookup
	}

	function self:Size(path)
		local index = self.lookup[path]
		return index and self:SizeByIndex(index) or nil
	end

	function self:SizeByIndex(index)
		if index < 0 or index >= #self.entries / 6 then return end
		return self.entries[index * 6 + 5] + self.entries[index * 6 + 3]
	end

	function self:Read(path)
		local index = self.lookup[path]
		return index and self:ReadByIndex(index) or nil
	end

	function self:ReadByIndex(index)
		if index < 0 or index >= #self.entries / 6 then
			return
		end

		local archive = self.entries[index * 6 + 1]
		local offset = self.entries[index * 6 + 2]
		local length = self.entries[index * 6 + 3]
		local preload_offset = self.entries[index * 6 + 4]
		local preload_length = self.entries[index * 6 + 5]
		local checksum = self.entries[index * 6 + 6]

		local file_path = string.format("%s_%.3d.vpk", self.path, archive)
		local file = vfs.GetFile(file_path, "rb")

		if not file then
			vpk.Trace("Failed opening %q", file_path)
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
