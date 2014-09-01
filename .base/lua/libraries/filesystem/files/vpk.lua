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
	long crc;
	short preload_bytes;
	short archive_index;
	long entry_offset;
	long entry_length;
	short terminator;
	bufferpos preload_offset;
]]

local function read_vpk(file)
	local vpk = file:ReadStructure(header)

	vpk.entries = {}
	local done_directories = {}

	for extension in file:IterateStrings() do		
		for directory in file:IterateStrings() do
			for name in file:IterateStrings() do
			
				local entry = file:ReadStructure(entry)
				
				entry.directory = directory
				entry.name = name
				entry.extension = extension
				entry.path = directory .. "/" .. name .. "." .. extension
				entry.is_file = true
				
				file:SetPos(file:GetPos() + entry.preload_bytes)
								
				if file:GetPos() ~= entry.preload_offset + entry.preload_bytes then	
					file:Close()
					error("grr")
				end
				
				table.insert(vpk.entries, entry)
			end
			
			table.insert(vpk.entries, {path = directory, is_dir = true})
			
			for i = 0, 100 do
				local dir = utilities.GetParentFolder(directory, i)
				if dir == "" or done_directories[dir] then break end
				table.insert(vpk.entries, {path = dir, is_dir = true})
				done_directories[dir] = true
			end
		end
	end

	return vpk
end

local cache = {}

local function get_file_tree(path)

	if cache[path] then
		return cache[path]
	end
	
	local file = assert(vfs.Open("os:" .. path))
	
	local vpk = read_vpk(file)

	vpk.paths = {}
	
	for i, v in ipairs(vpk.entries) do
		if v.is_file then
			v.archive_path = "os:" .. path:gsub("_dir.vpk$", function(str) return ("_%03d.vpk"):format(v.archive_index) end)
		end
		
		v.path = v.path:lower()
		
		vpk.paths[v.path] = v
	end
	
	file:Close()
	
	cache[path] = vpk
		
	return vpk
end

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
	
	local vpk = get_file_tree(vpk_path)

	if vpk.paths[relative] and vpk.paths[relative].is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
		
	-- vpk files are folders
	if path_info.folder_name:find("^.+%.vpk$") then
		return true
	end

	local vpk_path, relative = split_path(path_info)
	local vpk = get_file_tree(vpk_path)
	
	if vpk.paths[relative] and vpk.paths[relative].is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local vpk_path, relative = split_path(path_info)
	local vpk = get_file_tree(vpk_path)
	
	local out = {}	
	local dir = relative:match("(.*/)")
	local done = {}
	
	for i, v in ipairs(vpk.entries) do
		local path = v.path
		if path:find(relative, nil, true) and (not dir or path:match("(.*/).") == dir) then
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
	local vpk_path, relative = split_path(path_info)
	local vpk = get_file_tree(vpk_path)
	
	local file
		
	if self:GetMode() == "read" then
		local file_info = vpk.paths[relative]
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