local vfs = (...) or _G.vfs

local header = [[
	long signature = 0x55aa1234;
	long version;
	long tree_length;
		
	padding long unknown_1;
	long footer_length;
	padding long unknown_3;
	padding long unknown_4; 
]]

local entry = [[
	unsigned long crc;
	short preload_bytes;
	short archive_index;
	long entry_offset;
	long entry_length;
	short terminator;
	bufferpos preload_offset;
]]

local function read_vpk(file, full_path)
	local vpk = file:ReadStructure(header)

	local tree = utility.CreateTree("/")
	local done_directories = {}

	for extension in file:IterateStrings() do		
		for directory in file:IterateStrings() do
			for name in file:IterateStrings() do
			
				local entry = file:ReadStructure(entry)
				
				entry.is_file = true
				entry.archive_path = "os:" .. full_path:gsub("_dir.vpk$", function(str) return ("_%03d.vpk"):format(entry.archive_index) end)
				entry.file_name = name .. "." .. extension
				entry.directory = directory
				entry.full_path = directory .. "/" .. entry.file_name
				
				file:SetPos(file:GetPos() + entry.preload_bytes)
				
				if file:GetPos() ~= entry.preload_offset + entry.preload_bytes then	
					file:Close()
					error("grr")
				end
								
				tree:SetEntry(entry.full_path, entry)
			end
			
			directory = directory:lower()
			
			tree:SetEntry(directory, {path = directory, is_dir = true})
			
			for i = 0, 100 do
				local dir = utility.GetParentFolder(directory, i)
				if dir == "" or done_directories[dir] then break end
				dir = dir:lower()
				tree:SetEntry(dir, {path = dir, is_dir = true})
				done_directories[dir] = true
			end
		end
	end

	return tree
end
 
local cache = {}

local function get_file_tree(path)

	if cache[path] then
		return cache[path]
	end
	
	--local tree = serializer.ReadFile("msgpack", "vpk_cache/" .. crypto.CRC32(path)) or {}
	
	--if tree then
--		cache[path] = tree
		
	--	return tree
	--end
	
	local file = assert(vfs.Open("os:" .. path))	
	local tree = read_vpk(file, path)
		
	file:Close()
	
	cache[path] = tree
	
	--serializer.WriteFile("msgpack", "vpk_cache/" .. crypto.CRC32(path), tree.tree)
			
	return tree
end

LOL_CACHE = cache

local CONTEXT = {}

CONTEXT.Name = "vpk"

local function split_path(path_info)
	local vpk_path, relative = path_info.full_path:match("(.-%.vpk)/(.*)")
	
	if not vpk_path and not relative then
		error("not a valid vpk path", 2)
	end
	
	return vpk_path, relative
end

function CONTEXT:IsFile(path_info)
	local vpk_path, relative = split_path(path_info)
	local tree = get_file_tree(vpk_path)
	local entry = tree:GetEntry(relative)
	
	if entry and entry.is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
		
	-- vpk files are folders
	if path_info.folder_name:find("^.+%.vpk$") then
	--	return true
	end

	local vpk_path, relative = split_path(path_info)
	local tree = get_file_tree(vpk_path)
	local entry = tree:GetEntry(relative)
	if entry and entry.is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local vpk_path, relative = split_path(path_info)
	local tree = get_file_tree(vpk_path)
	
	local out = {}
					
	for k, v in pairs(tree:GetChildren(relative:match("(.*)/"))) do	
		if v.value then -- fix me!!
			table.insert(out, v.value.file_name)
		end
	end
	
	return out
end

function CONTEXT:Open(path_info, mode, ...)	
	local vpk_path, relative = split_path(path_info)
	local tree = get_file_tree(vpk_path)
	
	local file
		
	if self:GetMode() == "read" then
		local file_info = tree:GetEntry(relative)
		local file = assert(vfs.Open(file_info.archive_path))
		file:SetPos(file_info.entry_offset)		
		
		self.file = file
		self.position = 0
		self.file_info = file_info
	elseif self:GetMode() == "write" then
		error("not implemented")
	end
end

function CONTEXT:Write(str)
	return self.file:Write(str)
end

function CONTEXT:Read(bytes)
	return self.file:Read(bytes)
end

function CONTEXT:WriteByte(byte)
	self.file:WriteByte(byte)
end

function CONTEXT:ReadByte()					
	self.file:SetPos(self.file_info.entry_offset + self.position)
	local byte = self.file:ReadByte(1)	
	self.position = math.clamp(self.position + 1, 0, self.file_info.entry_length)
	
	return byte
end

function CONTEXT:WriteBytes(str)
	return self.file:WriteBytes(str)
end

function CONTEXT:ReadBytes(bytes)
	bytes = math.min(bytes, self.file_info.entry_length - self.position)

	self.file:SetPos(self.file_info.entry_offset + self.position)
	local str = self.file:ReadBytes(bytes)	
	self.position = math.clamp(self.position + bytes, 0, self.file_info.entry_length)
	
	if str == "" then str = nil end
	
	return str
end

function CONTEXT:SetPos(pos)
	self.position = math.clamp(pos, 0, self.file_info.entry_length)
end

function CONTEXT:GetPos()
	return self.position
end

function CONTEXT:Close()
	self.file:Close()
	self:Remove()
end

function CONTEXT:GetSize()
	return self.file_info.entry_length
end

vfs.RegisterFileSystem(CONTEXT)