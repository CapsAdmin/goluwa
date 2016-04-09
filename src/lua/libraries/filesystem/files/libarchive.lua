local vfs = (...) or _G.vfs
local ffi = require("ffi")
local archive = desire("libarchive")

local function open_archive(archive_path)
	local str = vfs.Read("os:" .. archive_path)
	local a = archive.ReadNew()

	archive.ReadSupportCompressionAll(a)
	archive.ReadSupportFormatAll(a)

	archive.ReadOpenMemory(a, str, #str)

	local err = archive.ErrorString(a)

	if err ~= nil then
		archive.ReadFree(a)
		error(ffi.string(err), 2)
	end

	return a
end

local function iterate_archive(a, ret_entry)
	return function()
		local entry = ffi.new("struct archive_entry * [1]")
		if archive.ReadNextHeader(a, entry) == archive.e.OK then
			return ffi.string(archive.EntryPathname(entry[0]))
		end
	end
end

local function iterate_archive2(a, ret_entry)
	return function()
		local entry = archive.EntryNew()
		if archive.ReadNextHeader2(a, entry) == archive.e.OK then
			return ffi.string(archive.EntryPathname(entry)), entry
		end
	end
end

local CONTEXT = {}

CONTEXT.Name = "libarchive"

local function split_path(path_info)
	local archive_path, relative

	if path_info.full_path:find("tar.gz", nil, true) then
		archive_path, relative = path_info.full_path:match("(.+%.tar%.gz)/(.*)")
	else
		archive_path, relative = path_info.full_path:match("(.+%..-)/(.*)")
	end

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

	local found = false

	for path in iterate_archive(a) do
		if path == relative then
			found = true
			break
		end
	end

	archive.ReadFree(a)

	return found
end

function CONTEXT:IsFolder(path_info)
	local archive_path, relative = split_path(path_info)
	local a = open_archive(archive_path)

	local found = false

	for path in iterate_archive(a) do
		if path:startswith(relative) then
			found = true
			break
		end
	end

	archive.ReadFree(a)

	return found
end

function CONTEXT:GetFiles(path_info)
	local archive_path, relative = split_path(path_info)

	local out = {}

	local dir = relative:match("(.*/).*")
	local a = open_archive(archive_path)

	local files = {}
	local done = {}

	for path in iterate_archive(a) do
		for i = 0, 10 do
			local dir = utility.GetParentFolder(path, i)
			if not done[dir] then
				done[dir] = true
				if dir ~= "" then
					table.insert(files, dir)
				end
			end
		end
		table.insert(files, path)
	end

	archive.ReadFree(a)

	-- really ugly logic: TODO
	-- this kind of logic messes up my head

	for i, path in ipairs(files) do
		if not dir then
			local path2 = path:match("^([^/]-)/$")
			if path2 then
				table.insert(out, path2)
			end
		else
			local dir2, name = path:match("^(.+/)(.+)")

			if dir == dir2 and name then
				if name:endswith("/") then
					name = name:sub(0, -2)
				end
				table.insert(out, name)
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

		for path, entry in iterate_archive2(a) do
			if path == relative then
				self.archive = a
				self.entry = entry
				return
			end
		end

		archive.ReadFree(a)
		error("file not found in archive")

	elseif self:GetMode() == "write" then
		error("not implemented")
	end
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end

	local data = ffi.new("uint8_t[?]", bytes)
	local size = archive.ReadData(self.archive, data, bytes)

	if size > 0 then
		return ffi.string(data, size)
	end
end

function CONTEXT:SetPosition(pos)
	archive.SeekData(self.archive, math.clamp(pos, 0, self:GetSize()), 0)
end

function CONTEXT:GetPosition()
	return archive.SeekData(self.archive, 0, 1)
end

function CONTEXT:Close()
	archive.ReadFree(self.archive)
	archive.EntryFree(self.entry)
	self:Remove()
end

function CONTEXT:GetSize()
	return tonumber(archive.EntrySize(self.entry))
end

function CONTEXT:GetLastModified()
	return tonumber(archive.EntryAtime(self.entry))
end

vfs.RegisterFileSystem(CONTEXT)
if RELOAD then
	for _, path in pairs(vfs.Find("/media/caps/ssd_840_120gb/goluwa/data/users/caps/temp_bsp.zip/materials/maps/", nil, nil, nil, nil, true)) do
		print(path.name, "!")
		--local file = vfs.Open(path.full_path)
		--print(file:GetSize())
	end
end