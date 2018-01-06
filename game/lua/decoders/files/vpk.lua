local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "valve package"
CONTEXT.NameEndsWith = "_dir"
CONTEXT.Extension = "vpk"
CONTEXT.Base = "generic_archive"

function CONTEXT:OnParseArchive(file, archive_path)
	file:ReadStructure([[
		long signature = 0x55aa1234;
		long version;
		long tree_length;

		padding long unknown_1;
		long footer_length;
		padding long unknown_3;
		padding long unknown_4;
	]])

	while true do
		local extension = file:ReadString()
		if extension == nil or extension == "" then
			break
		end

		while true do
			local directory = file:ReadString()
			if directory == nil or directory == "" then
				break
			end

			while true do
				local name = file:ReadString()
				if name == nil or name == "" then
					break
				end

				local entry = file:ReadStructure([[
					unsigned long crc;
					unsigned short preload_length;
					unsigned short archive_index;
					unsigned long offset;
					unsigned long size;
					unsigned short terminator;
					bufferpos preload_offset;
				]])

				entry.file_name = name .. "." .. extension
				entry.file_name = entry.file_name
				entry.full_path = directory .. "/" .. entry.file_name

				if entry.archive_index == 0x7FFF then
					entry.size = entry.preload_length
					entry.offset = entry.preload_offset
				end

				entry.preload_data = file:ReadBytes(entry.preload_length)
				entry.size = entry.size + entry.preload_length

				-- remove these because we don't need them and they will take up memory and blow up the size of the cache
				entry.preload_offset = nil
				entry.preload_length = nil
				entry.terminator = nil
				entry.crc = nil

				self:AddEntry(entry)
			end
		end
	end
	return true
end


function CONTEXT:TranslateArchivePath(file_info, archive_path)
	if not file_info.archive_index or file_info.archive_index == 0x7FFF then
		return "os:" .. archive_path
	end

	return "os:" .. archive_path:gsub("_dir.vpk$", function() return ("_%03d.vpk"):format(file_info.archive_index) end)
end

vfs.RegisterFileSystem(CONTEXT)