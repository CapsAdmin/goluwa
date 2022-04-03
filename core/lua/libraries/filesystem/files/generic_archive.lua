local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "generic_archive"

function CONTEXT:AddEntry(entry)
	self.tree.done_directories = self.tree.done_directories or {}

	local directory = entry.full_path:match("(.+)/")
	entry.file_name = entry.full_path:match(".+/(.+)")

	entry.size = tonumber(entry.size) or 0
	--entry.crc = entry.crc or 0
	entry.offset = tonumber(entry.offset) or 0
	entry.is_file = true

	local full_path = entry.full_path
	entry.full_path = nil

	self.tree:SetEntry(full_path, entry)
	self.tree:SetEntry(directory, {path = directory, is_dir = true, file_name = directory:match(".+/(.+)") or directory})

	for i = #directory, 1, -1 do
		local char = directory:sub(i, i)
		if char == "/" then
			local dir = directory:sub(0, i)
			if dir == "" or self.tree.done_directories[dir] then break end
			local file_name = dir:match(".+/(.+)") or dir

			if file_name:sub(-1) == "/" then
				file_name = file_name:sub(0, -2)
			end

			self.tree:SetEntry(dir, {path = dir, is_dir = true, file_name = file_name})
			self.tree.done_directories[dir] = true
		end
	end
end

--self:ParseArchive(vfs.Open("os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.gma"), "os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.gma")

local cache = table.weak()
local never

local modified_cache = {}

function CONTEXT:GetFileTree(path_info)
	if never then return false, "recursive call to GetFileTree" end

	local archive_path, relative = path_info.full_path:slice((self.NameEndsWith or "") .. "." .. self.Extension .. "/", 0, 1)

	if not archive_path then
		archive_path, relative = path_info.full_path:slice("." .. self.Extension .. "/", 0, 1)
	end

	if not archive_path then
		return false, "not a valid archive path"
	end

	if not modified_cache[archive_path] then
		never = true
		modified_cache[archive_path] = vfs.GetLastModified(archive_path) or ""
		never = false
	end

	local cache_key = archive_path .. modified_cache[archive_path]
	if cache[cache_key] then
		return cache[cache_key], relative, archive_path
	end

	if not vfs.IsFile(archive_path) then
		return false, "not a valid archive path"
	end

	local cache_path = "os:cache/archive/" .. crypto.CRC32(cache_key)
	if vfs.IsFile(cache_path) then
		never = true
		local tree_data, err, what = serializer.ReadFile("msgpack", cache_path)
		never = false

		if tree_data then
			local tree = utility.CreateTree("/", tree_data)
			cache[cache_key] = tree
			return cache[cache_key], relative, archive_path
		end
	end

	never = true
	local file, err = vfs.Open("os:" .. archive_path)
	never = false
	if not file then
		return false, err
	end

	if VERBOSE then
		llog("generating tree data cache for ", archive_path)
	end

	local tree = utility.CreateTree("/")
	self.tree = tree

	local ok, err = self:OnParseArchive(file, archive_path)

	self.tree.done_directories = nil

	file:Close()

	if not ok then
		return false, err
	end

	cache[cache_key] = tree

	utility.RunOnNextGarbageCollection(function()
		serializer.WriteFile("msgpack", cache_path, tree.tree)
	end)

	return tree, relative, archive_path
end

function CONTEXT:IsFile(path_info)
	local tree, relative, archive_path = self:GetFileTree(path_info)
	if not tree then return tree, relative end
	local entry, err = tree:GetEntry(relative)

	if entry and entry.is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
	local tree, relative, archive_path = self:GetFileTree(path_info)

	if relative == "" then return true end
	if not tree then return tree, relative end
	local entry = tree:GetEntry(relative)
	if entry and entry.is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local tree, relative, archive_path = self:GetFileTree(path_info)
	if not tree then return tree, relative end

	local children, err = tree:GetChildren(relative:match("(.*)/") or relative)

	if not children then return false, err end

	local out = {}
	for _, v in pairs(children) do
		if type(v) == "table" and v.v then -- fix me!!
			table.insert(out, v.v.file_name)
		end
	end

	return out
end

function CONTEXT:TranslateArchivePath(file_info)
	return file_info.archive_path
end

local cache = table.weak()

function CONTEXT:Open(path_info, mode, ...)
	if self:GetMode() == "read" then
		local tree, relative, archive_path = self:GetFileTree(path_info)
		if not tree then
			return false, relative
		end
		local file_info = tree:GetEntry(relative)
		if not file_info then
			return false, "file not found in archive"
		end

		if file_info.is_dir then
			return false, "file is a directory"
		end

		local archive_path = self:TranslateArchivePath(file_info, archive_path)
		local file, err = cache[archive_path] or vfs.Open(archive_path)

		cache[archive_path] = file

		if not file then
			return false, err
		end

		file:SetPosition(file_info.offset)
		self.position = 0
		self.file_info = file_info

		if file_info.preload_data then
			if file_info.size == #file_info.preload_data then
				self.data = file_info.preload_data
			else
				self.data = file_info.preload_data .. file:ReadBytes(file_info.size-#file_info.preload_data)
			end
			self.file = nil
		else
			self.file = file
		end

		return true
	elseif self:GetMode() == "write" then
		return false, "write mode not implemented"
	end

	return false, "read mode " .. self:GetMode() .. " not supported"
end

function CONTEXT:ReadByte()
	if self.file_info.preload_data then
		local char = self.data:sub(self.position+1, self.position+1)
		self.position = math.clamp(self.position + 1, 0, self.file_info.size)
		return char:byte()
	else
		self.file:SetPosition(self.file_info.offset + self.position)
		local char = self.file:ReadByte(1)
		self.position = math.clamp(self.position + 1, 0, self.file_info.size)
		return char
	end
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end

	if self.file_info.preload_data then
		local str = {}
		for i = 1, bytes do
			local byte = self:ReadByte()
			if not byte then return table.concat(str, "") end
			str[i] = string.char(byte)
		end
		return table.concat(str, "")
	else
		bytes = math.min(bytes, self.file_info.size - self.position)

		self.file:SetPosition(self.file_info.offset + self.position)
		local str = self.file:ReadBytes(bytes)
		self.position = math.clamp(self.position + bytes, 0, self.file_info.size)

		if str == "" then str = nil end

		return str
	end
end

function CONTEXT:SetPosition(pos)
	self.position = math.clamp(pos, 0, self.file_info.size)
end

function CONTEXT:GetPosition()
	return self.position
end

function CONTEXT:OnRemove()
	if self.file and self.file:IsValid() then
		self.file = nil -- just unref
	end
end

function CONTEXT:GetSize()
	return self.file_info.size
end

vfs.RegisterFileSystem(CONTEXT, true)