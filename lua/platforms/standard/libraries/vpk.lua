vpk = vpk or {}
local vpk = vpk

function vpk.Find(path)
	check(path, "string")

	local file, error = vfs.GetFile(path, "rb")

	if not file then
		print("oh noes", error)
		return
	end

	local info = {
		header = {}
	}

	do
		local bytes = {file:read(12):byte(1, -1)}

		if #bytes ~= 12 then
			print("knurr")
			file:close()
			return
		end

		info.header.Signature = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
		info.header.Version = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8 + bytes[7] * 2 ^ 16 + bytes[8] * 2 ^ 24
		info.header.TreeLength = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
		info.header.HeaderLength = 12
	end

	if info.header.Signature ~= 0x55aa1234 then
		print("grr")
		file:close()
		return
	end

	if info.header.Version == 2 then
		info.header.HeaderLength = info.header.HeaderLength + 16

		do
			local bytes = {file:read(16):byte(1, -1)}

			if #bytes ~= 16 then
				print("fail")
				file:close()
				return
			end

			info.header.Unknown1 = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
			info.header.FooterLength = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8 + bytes[7] * 2 ^ 16 + bytes[8] * 2 ^ 24
			info.header.Unknown3 = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
			info.header.Unknown4 = bytes[13] * 2 ^ 0 + bytes[14] * 2 ^ 8 + bytes[15] * 2 ^ 16 + bytes[16] * 2 ^ 24
		end
	elseif info.header.Version ~= 1 then
		print("boing")
		file:close()
		return
	end

	local files = {}

	-- super slow
	local function read_string()
		local buffer = ""

		while true do
			local char = file:read(1)
			if not char then print("HUH") return end
			if char == "\0" then break end
			buffer = buffer .. char
		end

		return buffer
	end

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

				local fileinfo = {}
				fileinfo.Path = directory .. "/" .. name .. (extension == " " and "" or "." .. extension)

				do
					local bytes = {file:read(18):byte(1, -1)}
					
					if #bytes ~= 18 then
						print("heul")
						file:close()
						return
					end

					fileinfo.CRC = bytes[1] * 2 ^ 0 + bytes[2] * 2 ^ 8 + bytes[3] * 2 ^ 16 + bytes[4] * 2 ^ 24
					fileinfo.PreloadBytes = bytes[5] * 2 ^ 0 + bytes[6] * 2 ^ 8
					fileinfo.ArchiveIndex = bytes[7] * 2 ^ 0 + bytes[8] * 2 ^ 8
					fileinfo.EntryOffset = bytes[9] * 2 ^ 0 + bytes[10] * 2 ^ 8 + bytes[11] * 2 ^ 16 + bytes[12] * 2 ^ 24
					fileinfo.EntryLength = bytes[13] * 2 ^ 0 + bytes[14] * 2 ^ 8 + bytes[15] * 2 ^ 16 + bytes[16] * 2 ^ 24
					fileinfo.Terminator = bytes[17] * 2 ^ 0 + bytes[18] * 2 ^ 8
				end

				file:read(fileinfo.PreloadBytes)
				files[#files + 1] = fileinfo.Path
			end
		end
	end

	file:close()

	return files, info
end
