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
	short preload_length;
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
			directory = directory:lower()
			
			for name in file:IterateStrings() do
			
				local entry = file:ReadStructure(entry)
				
				entry.is_file = true
				entry.file_name = name .. "." .. extension
				entry.file_name = entry.file_name:lower()

				if entry.archive_index == 0x7FFF then
					entry.entry_length = entry.preload_length
					entry.entry_offset = entry.preload_offset
				end
			
				file:SetPosition(file:GetPosition() + entry.preload_length)
				
				if file:GetPosition() ~= entry.preload_offset + entry.preload_length then	
					file:Close()
				end
				
				-- remove these because we don't need them and they will take up memory and blow up the size of the cache
				entry.preload_offset = nil
				entry.preload_length = nil
				entry.terminator = nil
				entry.crc = nil

				tree:SetEntry(directory .. "/" .. entry.file_name, entry)
			end

			tree:SetEntry(directory, {path = directory, is_dir = true, file_name = directory:match(".+/(.+)")})
			
			for i = 0, 100 do
				local dir = utility.GetParentFolder(directory, i)
				if dir == "" or done_directories[dir] then break end
				dir = dir:lower()
				local file_name = dir:match(".+/(.+)") or dir
				
				if file_name:sub(-1) == "/" then
					file_name = file_name:sub(0, -2)
				end
			
				tree:SetEntry(dir, {path = dir, is_dir = true, file_name = file_name})
				done_directories[dir] = true
			end
		end
	end

	return tree
end
 
local cache = {}

local never

local function get_file_tree(path)
	if cache[path] then
		return cache[path]
	end

	if never then error("grr") end
	
	never = true
	local cache_path = "data/vpk_cache/" .. crypto.CRC32(path)
	local tree_data = serializer.ReadFile("msgpack", cache_path)
	never = false
	
	if tree_data then
		cache[path] = utility.CreateTree("/", tree_data)
		return cache[path]
	end

	local file = assert(vfs.Open("os:" .. path))	
	local tree = read_vpk(file, path)
	file:Close()
	
	cache[path] = tree
	
	event.Delay(math.random(), function()
		serializer.WriteFile("msgpack", cache_path, tree.tree)
	end)
	
	return tree
end

local CONTEXT = {}

CONTEXT.Name = "vpk"

local function split_path(path_info)
	local vpk_path, relative = path_info.full_path:match("(.-%.vpk)/(.*)")
	
	if not vpk_path or not relative then
		error("not a valid vpk path", 2)
	end
	
	relative = relative:lower()
	
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
		
		local archive_path
		
		if file_info.archive_index == 0x7FFF then
			archive_path = "os:" .. vpk_path
		else
			archive_path = "os:" .. vpk_path:gsub("_dir.vpk$", function(str) return ("_%03d.vpk"):format(file_info.archive_index) end)
		end		
		
		local file = assert(vfs.Open(archive_path))
		file:SetPosition(file_info.entry_offset)		
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
	self.file:SetPosition(self.file_info.entry_offset + self.position)
	local byte = self.file:ReadByte(1)	
	self.position = math.clamp(self.position + 1, 0, self.file_info.entry_length)
	
	return byte
end

function CONTEXT:WriteBytes(str)
	return self.file:WriteBytes(str)
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end
	bytes = math.min(bytes, self.file_info.entry_length - self.position)

	self.file:SetPosition(self.file_info.entry_offset + self.position)
	local str = self.file:ReadBytes(bytes)	
	self.position = math.clamp(self.position + bytes, 0, self.file_info.entry_length)
	
	if str == "" then str = nil end
	
	return str
end

function CONTEXT:SetPosition(pos)
	if pos > self.file_info.entry_length then error("position is larger than file size") end
	self.position = math.clamp(pos, 0, self.file_info.entry_length)
end

function CONTEXT:GetPosition()
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