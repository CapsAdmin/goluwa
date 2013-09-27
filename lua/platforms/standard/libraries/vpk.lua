local vpk = {}

function vpk.Read(path)
	check(path, "string")

	local file, error_message = io.open(path, "rb")

	if not file then
		return nil, "Failed opening VPK: " .. error_message
	end

	local self, error_message = vpk.ReadFile(file)
	file:close()

	if not self then
		return nil, "Failed parsing: " .. error_message
	end

	return self, "Success"
end

function vpk.ReadFile(file)
	local self = {}
	local error_message

	self.header, error_message = vpk.ReadHeader(file)

	if not self.header then
		return nil, "Failed parsing header: " .. error_message
	end

	self.tree, error_message = vpk.ReadTree(file)

	if not self.tree then
		return nil, "Failed parsing tree: " .. error_message
	end

	if self.header.Version == 2 then
		self.footer, error_message = vpk.ReadFooter()

		if not self.footer then
			return nil, "Failed parsing footer: " .. error_message
		end
	end

	return self, "Success"
end

function vpk.ReadHeader(file)
	local header = {}

	header.Signature = vpk.ReadInteger(file, 4)
	header.Version = vpk.ReadInteger(file, 4)
	header.TreeLength = vpk.ReadInteger(file, 4)

	if not header.TreeLength then
		return nil, "Unexpected end-of-file"
	end

	if header.Signature ~= 0x55aa1234 then
		return nil, string.format("Invalid signature 0x%.8x", header.Signature)
	end

	if header.Version == 2 then
		header.Unknown1 = vpk.ReadInteger(file, 4)
		header.FooterLength = vpk.ReadInteger(file, 4)
		header.Unknown3 = vpk.ReadInteger(file, 4)
		header.Unknown4 = vpk.ReadInteger(file, 4)

		if not header.Unknown4 then
			return nil, "Unexpected end-of-file"
		end
	elseif header.Version ~= 1 then
		return nil, string.format("Invalid version %d", header.Version)
	end

	return header, "Success"
end

function vpk.ReadTree(file)
	local tree = {}

	for extension in vpk.IterateStrings(file) do
		for directory in vpk.IterateStrings(file) do
			for name in vpk.IterateStrings(file) do
				local entry, error_message = vpk.ReadEntry(file, extension, directory, name)

				if not entry then
					return nil, "Parsing entry failed: " .. error_message
				end

				tree[#tree + 1] = entry
			end
		end
	end

	return tree, "Success"
end

function vpk.ReadFooter(file)
	local footer = {}
	return footer, "Success"
end

function vpk.ReadEntry(file, extension, directory, name)
	local entry = {}

	entry.Path = (directory ~= " " and directory .. "/" or "") .. (name ~= " " and name or "") .. (extension ~= " " and "." .. extension or "")

	entry.CRC = vpk.ReadInteger(file, 4)
	entry.PreloadBytes = vpk.ReadInteger(file, 2)
	entry.ArchiveIndex = vpk.ReadInteger(file, 2)
	entry.EntryOffset = vpk.ReadInteger(file, 4)
	entry.EntryLength = vpk.ReadInteger(file, 4)
	entry.Terminator = vpk.ReadInteger(file, 2)

	if not entry.Terminator then
		return nil, "Unexpected end-of-file"
	end

	if entry.Terminator ~= 0xffff then
		return nil, string.format("Invalid entry terminator 0x%.4x", entry.Terminator)
	end

	entry.PreloadOffset = file:seek()

	if file:seek("cur", entry.PreloadBytes) ~= entry.PreloadOffset + entry.PreloadBytes then
		return nil, "Skipping preload data failed"
	end

	return entry, "Success"
end

function vpk.IterateStrings(file)
	return function()
		local value = vpk.ReadString(file)
		return value ~= "" and value or nil
	end
end

function vpk.ReadString(file)
	local buffer = {}

	while true do
		local char = file:read(1)

		if char == "\0" then
			break
		elseif not char then
			return
		end

		buffer[#buffer + 1] = char
	end

	return table.concat(buffer)
end

function vpk.ReadInteger(file, byte_count)
	local bytes = {file:read(byte_count):byte(1, -1)}

	if #bytes < byte_count then
		return
	end

	local result = 0

	for i = 1, #bytes do
		result = result + bytes[i] * 2 ^ ((i - 1) * 8)
	end

	return result
end

return vpk
