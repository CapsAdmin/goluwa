local vfs = (...) or _G.vfs
local CONTEXT = {}
CONTEXT.Name = "gmod addon archive"
CONTEXT.Extension = "gma"
CONTEXT.Base = "generic_archive"
CONTEXT.Position = 5

function CONTEXT:OnParseArchive(file, archive_path)
	if not archive_path:endswith(".gma") then
		return false, "archive path does not end with .gma"
	end

	local info = {}

	if file:ReadBytes(4) ~= "GMAD" then return false, "not a gmad archive" end

	info.format_version = file:ReadByte()
	info.steamid = file:ReadUnsignedLongLong()
	info.timestamp = file:ReadUnsignedLongLong()
	local junk = file:ReadString()

	repeat
	
	until file:ReadByte() ~= 0

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
		file:ReadUnsignedLong()
		entry.offset = offset
		entry.file_number = file_number
		offset = offset + entry.size
		file_number = file_number + 1
		table.insert(info.entries, entry)
		self:AddEntry(entry)
	end

	info.file_block = tonumber(file:GetPosition())

	for _, v in pairs(info.entries) do
		v.offset = v.offset + info.file_block
	end

	return true
end

vfs.RegisterFileSystem(CONTEXT)