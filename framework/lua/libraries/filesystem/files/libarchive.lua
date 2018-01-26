local archive = system.GetFFIBuildLibrary("libarchive")

if not archive then return end

local vfs = (...) or _G.vfs
local ffi = require("ffi")

local CONTEXT = {}

CONTEXT.Name = "libarchive"
CONTEXT.Position = math.huge

local function get_error(a)
	local buff = archive.ErrorString(a)
	if buff ~= nil then
		return ffi.string(buff)
	end
	debug.trace()
	return "error string is null?"
end

CONTEXT.archive_cache = CONTEXT.archive_cache or table.weak()

local function iterate_archive(data)
	if CONTEXT.archive_cache[data.archive_path] and CONTEXT.archive_cache[data.archive_path].files[1] then
		return CONTEXT.archive_cache[data.archive_path].files
	end

	local entry = archive.EntryNew()

	local tbl = CONTEXT.archive_cache[data.archive_path].files
	local tbl2 = CONTEXT.archive_cache[data.archive_path].files2

	local code

	for i = 1, math.huge do
		code = archive.ReadNextHeader2(data.archive, entry)
		if code ~= archive.e.OK then break end
		local path = ffi.string(archive.EntryPathname(entry))
		tbl[i] = path
		tbl2[path] = true
	end

	archive.EntryFree(entry)

	if code ~= archive.e.EOF then
		return false, get_error(data.archive)
	end

	return tbl
end

local cache = table.weak()

local function split_path(path_info)
	if cache[path_info.full_path] then
		return cache[path_info.full_path][1], cache[path_info.full_path][2]
	end

	local archive_path, relative

	if path_info.full_path:find("tar.gz", nil, true) then
		archive_path, relative = path_info.full_path:match("(.+%.tar%.gz)/(.*)")
	else
		archive_path, relative = path_info.full_path:match("(.+%..-)/(.*)")
	end

	if not archive_path and not relative then
		archive_path, relative = false, "not a valid archive path"
	else
		if archive_path:endswith("/") then
			archive_path = archive_path:sub(0, -2)
		end

		if archive_path:endswith(".gma") or archive_path:endswith(".vpk") then
			archive_path, relative = false, "TODO"
		end
	end

	cache[path_info.full_path] = {archive_path, relative}

	return archive_path, relative
end

local function open_archive(path_info, skip_cache)
	local archive_path, relative = split_path(path_info)
	if not archive_path then return archive_path, relative end

	local str

	if CONTEXT.archive_cache[archive_path] then
		str = CONTEXT.archive_cache[archive_path].str
	else
		str = vfs.Read("os:" .. archive_path)
	end

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

		archive.ReadFree(a)
		return false, "archive.ReadOpenMemory failed"
	end

	local data = setmetatable({archive = a, relative = relative, str = str, archive_path = archive_path}, {__gc = function()
		archive.ReadFree(a)
	end})

	CONTEXT.archive_cache[archive_path] = CONTEXT.archive_cache[archive_path] or {str = str, files = {}, files2 = {}}

	return data
end

local function contains_file(path_info)
	local archive_path, relative = split_path(path_info)
	if not archive_path then return archive_path, relative end

	if CONTEXT.archive_cache[archive_path] and CONTEXT.archive_cache[archive_path].files[1] then
		return CONTEXT.archive_cache[archive_path].files2[relative]
	end

	local data, err = open_archive(path_info)
	if not data then return data, err end

	local files, err = iterate_archive(data)
	if not files then return files, err end

	for _, path in ipairs(files) do
		if path == data.relative then
			return true
		end
	end
end

function CONTEXT:IsFile(path_info)
	return contains_file(path_info)
end

function CONTEXT:IsFolder(path_info)
	local data, err = open_archive(path_info)
	if not data then return data, err end

	local found = false

	local files, err = iterate_archive(data)
	if not files then return files, err end

	for _, path in ipairs(files) do
		if path:startswith(data.relative) then
			found = true
			break
		end
	end

	return found
end

function CONTEXT:IsArchive(path_info)
	if open_archive(path_info) then
		return true
	end
end

function CONTEXT:IsFolderValid(path_info)
	local data, err = open_archive(path_info)
	if not data then return data, err end

	local files, err = iterate_archive(data)
	if not files then return files, err end

	return true
end

function CONTEXT:GetFiles(path_info)
	local data, err = open_archive(path_info)

	if not data then return data, err end

	local out = {}

	local dir = data.relative:match("(.*/).*")

	local files = {}
	local done = {}

	local files_, err = iterate_archive(data)
	if not files_ then return files_, err end

	for _, path in ipairs(files_) do
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

	-- really ugly logic: TODO
	-- this kind of logic messes up my head

	for _, path in ipairs(files) do
		if not dir then
			local path2 = path:match("^([^/]-)/$") or path:match("^([^/]-)$")
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
		local data, err = open_archive(path_info)
		if not data then return data, err end

		while true do
			local entry = archive.EntryNew()
			if archive.ReadNextHeader2(data.archive, entry) == archive.e.OK then
				if ffi.string(archive.EntryPathname(entry)) == data.relative then
					self.archive = data.archive
					self.entry = entry
					self.ref = data

					if archive.SeekData(self.archive, 0, 1) < 0 then
						self.content = self:ReadBytes(math.huge)
						if not self.content then
							return false, "unable to read content"
						end
						self.size = #self.content
						self.position = 0
					end

					return true
				end
			else
				archive.EntryFree(entry)
				break
			end
			archive.EntryFree(entry)
		end

		return false, "file not found in archive"
	elseif self:GetMode() == "write" then
		return false, "write mode not implemented"
	end
	return false, "read mode " .. self:GetMode() .. " not supported"
end

function CONTEXT:ReadByte()
	if self.content then
		local char = self.content:sub(self.position+1, self.position+1)
		self.position = math.clamp(self.position + 1, 0, self.size)
		return char:byte()
	else
		local char = self:ReadBytes(1)
		if char then
			return char:byte()
		end
	end
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end

	if self.content then
		local str = {}
		for i = 1, bytes do
			local byte = self:ReadByte()
			if not byte then break end
			str[i] = string.char(byte)
		end

		local out = table.concat(str, "")

		if out ~= "" then
			return out
		end
	else
		local data = ffi.new("uint8_t[?]", bytes)
		local size = archive.ReadData(self.archive, data, bytes)

		if size > 0 then
			return ffi.string(data, size)
		elseif size < 0 then
			if size ~= -30 then -- eof error
				local err = archive.ErrorString(self.archive)
				if err ~= nil then
					wlog(ffi.string(err))
				end
			end
		end
	end
end

function CONTEXT:SetPosition(pos)
	if self.content then
		self.position = math.clamp(pos, 0, self.size)
	else
		if archive.SeekData(self.archive, math.clamp(pos, 0, self:GetSize()), 0) ~= archive.e.OK then
			local err = archive.ErrorString(self.archive)
			if err ~= nil then
				wlog(ffi.string(err))
			end
		end
	end
end

function CONTEXT:GetPosition()
	if self.content then
		return self.position
	else
		local pos = archive.SeekData(self.archive, 0, 1)
		if pos < 0 then
			local err = archive.ErrorString(self.archive)
			if err ~= nil then
				wlog(ffi.string(err))
			end
			return pos
		end
		return pos
	end
end

function CONTEXT:OnRemove()
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