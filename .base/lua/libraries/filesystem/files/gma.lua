local vfs = (...) or _G.vfs

local function read_gma(file, full_path)

	local tree = utility.CreateTree("/")
	local done_directories = {}
	
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
		entry.directory = entry.full_path:match("(.+)/")
		entry.file_name = entry.full_path:match(".+/(.+)")
		
		tree:SetEntry(entry.directory, {path = entry.directory, is_dir = true, file_name = entry.directory:match(".+/(.+)")})
		
		for i = 0, 100 do
			local dir = utility.GetParentFolder(entry.directory, i)
			if dir == "" or done_directories[dir] then break end
			local file_name = dir:match(".+/(.+)") or dir
			
			if file_name:sub(-1) == "/" then
				file_name = file_name:sub(0, -2)
			end
	
			tree:SetEntry(dir, {path = dir, is_dir = true, file_name = file_name})
			done_directories[dir] = true
		end
		
		entry.archive_path = "os:" .. full_path
		entry.size = tonumber(file:ReadLongLong())
		entry.crc = file:ReadUnsignedLong()
		entry.offset = offset
		entry.file_number = file_number
		entry.is_file = true
		
		offset = offset + entry.size
		file_number = file_number + 1
		table.insert(info.entries, entry)
		
		tree:SetEntry(entry.full_path, entry)
	end

	info.file_block = file:GetPosition()
	
	for i,v in pairs(info.entries) do
		v.offset = v.offset + info.file_block
	end
		
	return tree
end

--read_gma(vfs.Open("os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.gma"), "os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.gma")
 
local cache = {}

local function get_file_tree(path)

	if cache[path] then
		return cache[path]
	end

	local file = assert(vfs.Open("os:" .. path))	
	local tree = read_gma(file, path)
		
	file:Close()
	
	cache[path] = tree
	
	return tree
end

local CONTEXT = {}

CONTEXT.Name = "gma"

local function split_path(path_info)
	local gma_path, relative = path_info.full_path:match("(.-%.gma)/(.*)")
	
	if not gma_path and not relative then
		error("not a valid gma path", 2)
	end
	
	return gma_path, relative
end

function CONTEXT:IsFile(path_info)
	local gma_path, relative = split_path(path_info)
	local tree = get_file_tree(gma_path)
	local entry = tree:GetEntry(relative)
	
	print(entry, gma_path, relative)
	
	if entry and entry.is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
		
	-- gma files are folders
	if path_info.folder_name:find("^.+%.gma$") then
	--	return true
	end

	local gma_path, relative = split_path(path_info)
	local tree = get_file_tree(gma_path)
	local entry = tree:GetEntry(relative)
	if entry and entry.is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local gma_path, relative = split_path(path_info)
	local tree = get_file_tree(gma_path)
						
	local out = {}
					
	for k, v in pairs(tree:GetChildren(relative:match("(.*)/"))) do
		if v.value then -- fix me!!
			table.insert(out, v.value.file_name)
		end
	end
	
	return out
end

function CONTEXT:Open(path_info, mode, ...)	
	local gma_path, relative = split_path(path_info)
	local tree = get_file_tree(gma_path)
	
	local file
		
	if self:GetMode() == "read" then
		local file_info = tree:GetEntry(relative)
		local file = assert(vfs.Open(file_info.archive_path))
		file:SetPosition(file_info.offset)		
		self.file = file
		self.position = 0
		self.file_info = file_info
	elseif self:GetMode() == "write" then
		error("not implemented")
	end
end

function CONTEXT:Write(str)
	--return self.file:Write(str)
end

function CONTEXT:Read(bytes)
	return self.file:Read(bytes)
end

function CONTEXT:WriteByte(byte)
	--self.file:WriteByte(byte)
end

function CONTEXT:ReadByte()					
	self.file:SetPosition(self.file_info.offset + self.position)
	local byte = self.file:ReadByte(1)	
	self.position = math.clamp(self.position + 1, 0, self.file_info.size)
	
	return byte
end

function CONTEXT:WriteBytes(str)
	--return self.file:WriteBytes(str)
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end
	bytes = math.min(bytes, self.file_info.size - self.position)

	self.file:SetPosition(self.file_info.offset + self.position)
	local str = self.file:ReadBytes(bytes)	
	self.position = math.clamp(self.position + bytes, 0, self.file_info.size)
	
	if str == "" then str = nil end
	
	return str
end

function CONTEXT:SetPosition(pos)
	if pos > self.file_info.size then error("position is larger than file size") end
	self.position = math.clamp(pos, 0, self.file_info.size)
end

function CONTEXT:GetPosition()
	return self.position
end

function CONTEXT:Close()
	self.file:Close()
	self:Remove()
end

function CONTEXT:GetSize()
	return self.file_info.size
end

vfs.RegisterFileSystem(CONTEXT)