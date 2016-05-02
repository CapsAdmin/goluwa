local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "generic_archive"

function CONTEXT:AddEntry(entry)
	self.tree.done_directories = self.tree.done_directories or {}

	entry.directory = entry.full_path:match("(.+)/")
	entry.file_name = entry.full_path:match(".+/(.+)")

	entry.size = tonumber(entry.size) or 0
	entry.crc = entry.crc or 0
	entry.offset = tonumber(entry.offset) or 0
	entry.is_file = true

	self.tree:SetEntry(entry.full_path, entry)
	self.tree:SetEntry(entry.directory, {path = entry.directory, is_dir = true, file_name = entry.directory:match(".+/(.+)")})

	for i = #entry.directory, 1, -1 do
		local char = entry.directory:sub(i, i)
		if char == "/" then
			local dir = entry.directory:sub(0, i)
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

local cache = {}
local never

vfs.generic_archive_cache = cache

function CONTEXT:GetFileTree(path)
	if cache[path] then
		return cache[path]
	end

	if never then error("grr") end

	never = true
	local cache_path = "os:data/archive_cache/" .. crypto.CRC32(path)
	local tree_data = serializer.ReadFile("msgpack", cache_path)
	never = false

	if tree_data then
		local tree = utility.CreateTree("/", tree_data)
		cache[path] = tree
		return cache[path]
	end

	local file = assert(vfs.Open("os:" .. path))
	local tree = utility.CreateTree("/")
	self.tree = tree
	self:OnParseArchive(file, path)
	file:Close()

	cache[path] = tree

	event.Delay(math.random(), function()
		serializer.WriteFile("msgpack", cache_path, nil, tree.tree)
	end)

	return tree
end

function CONTEXT:SplitPath(path_info)
	local archive_path, relative = path_info.full_path:match("(.-%."..self.Extension..")/(.*)")

	if not archive_path and not relative then
		error("not a valid archive path", 2)
	end

	return archive_path, relative
end

function CONTEXT:IsFile(path_info)
	local archive_path, relative = self:SplitPath(path_info)
	local tree = self:GetFileTree(archive_path)
	local entry = tree:GetEntry(relative)

	if entry and entry.is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
	local archive_path, relative = self:SplitPath(path_info)
	local tree = self:GetFileTree(archive_path)
	local entry = tree:GetEntry(relative)
	if entry and entry.is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local archive_path, relative = self:SplitPath(path_info)
	local tree = self:GetFileTree(archive_path)

	local out = {}

	for _, v in pairs(tree:GetChildren(relative:match("(.*)/"))) do
		if v.value then -- fix me!!
			table.insert(out, v.value.file_name)
		end
	end

	return out
end

function CONTEXT:TranslateArchivePath(file_info)
	return file_info.archive_path
end

function CONTEXT:Open(path_info, mode, ...)
	local archive_path, relative = self:SplitPath(path_info)
	local tree = self:GetFileTree(archive_path)

	if self:GetMode() == "read" then
		local file_info = tree:GetEntry(relative)
		local file = assert(vfs.Open(self:TranslateArchivePath(file_info, archive_path)))
		file:SetPosition(file_info.offset)
		self.position = 0
		self.file_info = file_info

		if file_info.preload_data then
			self.data = file_info.preload_data .. file:ReadBytes(file_info.size-#file_info.preload_data)
			file:Close()
		else
			self.file = file
		end
	elseif self:GetMode() == "write" then
		error("not implemented")
	end
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
	if pos > self.file_info.size then error("position is larger than file size") end
	self.position = math.clamp(pos, 0, self.file_info.size)
end

function CONTEXT:GetPosition()
	return self.position
end

function CONTEXT:Close()
	if self.file and self.file:IsValid() then self.file:Close() end
	self:Remove()
end

function CONTEXT:GetSize()
	return self.file_info.size
end

vfs.RegisterFileSystem(CONTEXT, true)