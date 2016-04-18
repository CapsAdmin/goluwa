local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "gmod addon archive"
CONTEXT.Extension = "gma"
CONTEXT.Base = "generic_archive"
CONTEXT.Position = 5

function CONTEXT:OnParseArchive(file, archive_path)
	local info = {}

	assert(file:ReadBytes(4) == "GMAD")

	info.format_version = file:ReadByte()
	info.steamid = file:ReadUnsignedLongLong()
	info.timestamp = file:ReadUnsignedLongLong()

	local junk = file:ReadString()
	repeat until file:ReadByte() ~= 0
	file:Advance(-1)

	info.name = file:ReadString()
	info.desc = file:ReadString()
	info.author = file:ReadString()
	file:ReadInt()

	info.entries = {}

	local file_number = 1
	local offset = 0

	while file:ReadInt() ~= 0 do
		local entry = {}

		entry.full_path = file:ReadString()
		entry.archive_path = "os:" .. archive_path
		entry.size = tonumber(file:ReadLongLong())
		entry.crc = file:ReadUnsignedLong()
		entry.offset = offset
		entry.file_number = file_number

		offset = offset + entry.size
		file_number = file_number + 1
		table.insert(info.entries, entry)

		self:AddEntry(entry)
	end

	info.file_block = file:GetPosition()

	for i,v in pairs(info.entries) do
		v.offset = v.offset + info.file_block
	end

	return tree
end

vfs.RegisterFileSystem(CONTEXT)