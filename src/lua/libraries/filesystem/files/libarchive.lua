do return end
local vfs = (...) or _G.vfs

local archive = require("ffi.libarchive")
local ffi = require("ffi")

local function open_archive(archive_path)
	local str = vfs.Read("os:" .. archive_path)

	local a = archive.read_new()
	archive.read_support_compression_all(a)
	archive.read_support_format_all(a)

	archive.read_open_memory(a, str, #str)

	local err = archive.error_string(a)
	if err then
		error(ffi.string(err), 2)
	end
	return a
end

local function iterate_archive(a)
	return function()
		local entry = archive.entry_new()
		if archive.read_next_header2(a, entry) == 0 then
			local cstr = archive.entry_pathname(entry)
			return ffi.string(cstr), entry
		end
	end
end

local function close_archive(a)
	archive.read_finish(a)
end


local CONTEXT = {}

CONTEXT.Name = "libarchive"

local function split_path(path_info)
	local archive_path, relative = path_info.full_path:match("(.+%..-)/(.*)")

	if not archive_path and not relative then
		error("not a valid archive path", 2)
	end

	if archive_path:endswith("/") then
		archive_path = archive_path:sub(0, -2)
	end

	return archive_path, relative
end

function CONTEXT:IsFile(path_info)
	local archive_path, relative = split_path(path_info)
	local a = open_archive(archive_path)

	for path in iterate_archive(a) do
		if path == relative then
			close_archive(a)
			return true
		end
	end

	close_archive(a)
end

function CONTEXT:IsFolder(path_info)
	local archive_path, relative = split_path(path_info)
	local a = open_archive(archive_path)

	for path in iterate_archive(a) do
		if path:find(relative, nil, true) then
			close_archive(a)
			return true
		end
	end

	close_archive(a)

	return false
end

function CONTEXT:GetFiles(path_info)
	local archive_path, relative = split_path(path_info)
	local out = {}

	local dir = relative:match("(.*/)")
	local a = open_archive(archive_path)

	local files = {}
	local done = {}

	for path in iterate_archive(a) do
		for i = 0, 10 do
			local dir = utility.GetParentFolder(path, i)
			if not done[dir] then
				done[dir] = true
				table.insert(files, dir)
			end
		end
		table.insert(files, path)
	end

	close_archive(a)

	local done = {}

	for path in ipairs(files) do
		if path:find(relative, nil, true) and (not dir or path:match("(.*/)") == dir) then
			-- path is just . so it needs to be handled a bit different

			if not dir then
				if not done[path] then
					path = path:match("(.-)/") or path
					table.insert(out, path)
					done[path] = true
				end
			else
				table.insert(out, path:match(".+/(.+)") or path)
			end
		end
	end


	return out
end

function CONTEXT:Open(path_info, mode, ...)
	local archive_path, relative = split_path(path_info)
	local file

	if self:GetMode() == "read" then
		local a = open_archive(archive_path)

		local found = false
		for path, entry in iterate_archive(a) do
			if path == relative then
				self.archive = a
				self.entry = entry
				return
			end
		end

		close_archive(a)
		error("file not found in archive")

	elseif self:GetMode() == "write" then
		error("not implemented")
	end
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end

	local data = ffi.new("uint8_t[?]", bytes)
	local size = archive.read_data(self.archive, data, bytes)

	if size > 0 then
		return ffi.string(data, size)
	end
end

function CONTEXT:SetPosition(pos)
	archive.seek_data(self.archive, math.clamp(pos, 0, self:GetSize()), 0)
end

function CONTEXT:GetPosition()
	return archive.seek_data(self.archive, 0, 1)
end

function CONTEXT:Close()
	close_archive(self.archive)
	self:Remove()
end

function CONTEXT:GetSize()
	return tonumber(archive.entry_size(self.entry))
end

function CONTEXT:GetLastModified()
	return tonumber(archive.entry_atime(self.entry))
end

vfs.RegisterFileSystem(CONTEXT)

if RELOAD then
	table.print(vfs.Find("/home/caps/Downloads/steamworks_sdk_135.zip/sdk/"))
end