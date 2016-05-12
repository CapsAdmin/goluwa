local vfs = (...) or _G.vfs
local ffi = require("ffi")
local archive = desire("libarchive")

local function iterate_archive(a)
	return function()
		local entry = archive.EntryNew()
		if archive.ReadNextHeader2(a, entry) == archive.e.OK then
			local str = ffi.string(archive.EntryPathname(entry))
			archive.EntryFree(entry)
			return str
		end
	end
end

local function iterate_archive2(a)
	return function()
		local entry = archive.EntryNew()
		if archive.ReadNextHeader2(a, entry) == archive.e.OK then
			return ffi.string(archive.EntryPathname(entry)), entry
		end
	end
end

local CONTEXT = {}

CONTEXT.Name = "libarchive"
CONTEXT.Position = math.huge

local function open_archive(path_info)

	local archive_path, relative

	if path_info.full_path:find("tar.gz", nil, true) then
		archive_path, relative = path_info.full_path:match("(.+%.tar%.gz)/(.*)")
	else
		archive_path, relative = path_info.full_path:match("(.+%..-)/(.*)")
	end

	if not archive_path and not relative then
		return false, "not a valid archive path"
	end

	if archive_path:endswith("/") then
		archive_path = archive_path:sub(0, -2)
	end

	if archive_path:endswith(".gma") then
		return false, "gma TODO"
	end

	local str = vfs.Read("os:" .. archive_path)
	if not str then return false, "archive is empty" end

	local a = archive.ReadNew()

	archive.ReadSupportCompressionAll(a)
	archive.ReadSupportFilterAll(a)
	archive.ReadSupportFormatAll(a)

	if archive.ReadOpenMemory(a, str, #str) ~= archive.e.OK then
		local err = archive.ErrorString(a)

		if err ~= nil then
			local err = ffi.string(err)
			archive.ReadFree(a)
			return false, err
		end

		return false, "archive.ReadOpenMemory failed"
	end

	return a, relative
end

function CONTEXT:IsFile(path_info)
	local a, relative = open_archive(path_info)
	if not a then return a, relative end

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
	local a, relative = open_archive(path_info)
	if not a then return a, relative end

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
	local a, relative = open_archive(path_info)
	if not a then return a, relative end

	local out = {}

	local dir = relative:match("(.*/).*")

	local files = {}
	local done = {}

	for path in iterate_archive(a) do
		for i = #path, 1, -1 do
			local char = path:sub(i, i)
			if char == "/" then
				local dir = path:sub(0, i)

				if not done[dir] then
					done[dir] = true
					if dir ~= "" then
						table.insert(files, dir)
					end
				end
			end
		end
		table.insert(files, path)
	end

	archive.ReadFree(a)

	-- really ugly logic: TODO
	-- this kind of logic messes up my head

	for _, path in ipairs(files) do
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
	if self:GetMode() == "read" then
		local a, relative = open_archive(path_info)
		if not a then return false, relative end

		for path, entry in iterate_archive2(a) do
			if path == relative then
				self.archive = a
				self.entry = entry
				return true
			end
		end

		archive.ReadFree(a)

		return false, "file not found in archive"
	elseif self:GetMode() == "write" then
		return false, "write mode not implemented"
	end
	return false, "read mode " .. self:GetMode() .. " not supported"
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

function CONTEXT:OnRemove()
	if self.archive ~= nil then
		archive.ReadFree(self.archive)
	end

	if self.entry ~= nil then
		archive.EntryFree(self.entry)
	end
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