do return end
local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "bethesda archive"
CONTEXT.Extension = "bsa"
CONTEXT.Base = "generic_archive"

function CONTEXT:OnParseArchive(file, archive_path)
	local header = file:ReadStructure([[
		string magic = BSA;
		unsigned int version;
		unsigned int offset = 36;
		unsigned int archive_flags;
		unsigned int folder_count;
		unsigned int file_count;
		unsigned int folder_name_length;
		unsigned int file_name_length;
		unsigned int file_flags;
	]])

	local strings = {}

	do
		local strings_offset = header.offset + header.folder_count * 16 + (header.folder_count + header.folder_name_length + 16 * header.file_count)

		file:PushPosition(strings_offset)
			for i = 1, math.huge do
				if file:GetPosition() >= strings_offset + header.file_name_length then break end
				strings[i] = file:ReadString()
			end
		file:PopPosition()
	end

	for i = 1, header.folder_count do
		local folder = file:ReadStructure([[
			unsigned longlong hash;
			unsigned int file_count;
			unsigned int offset;
		]])

		folder.files = {}

		file:PushPosition(folder.offset - header.file_name_length + 1)
			local directory = file:ReadString():gsub("\\", "/") .. "/"
			for j = 1, folder.file_count do
				local file = file:ReadStructure([[
					unsigned longlong hash;
					unsigned int entry_length;
					unsigned int entry_offset;
				]])

				local file_name = table.remove(strings, 1)
				local file_path = directory .. file_name

				file.archive_path = "os:" .. archive_path
				file.file_name = file_name
				file.full_path = file_path

				self:AddEntry(entry)
			end
		file:PopPosition()
	end
end

vfs.RegisterFileSystem(CONTEXT)