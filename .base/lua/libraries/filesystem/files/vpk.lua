local vfs2 = (...) or _G.vfs2

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
	local buffer = Buffer(file)

	local vpk = buffer:ReadStructure(header)

	vpk.entries = {}
	local done_directories = {}

	for extension in buffer:IterateStrings() do		
		for directory in buffer:IterateStrings() do
			for name in buffer:IterateStrings() do
			
				local entry = buffer:ReadStructure(entry)
				
				entry.directory = directory
				entry.name = name
				entry.extension = extension
				entry.path = directory .. "/" .. name .. "." .. extension
				entry.is_file = true
								
				if buffer:SetPos(buffer:GetPos() + entry.preload_bytes) ~= entry.preload_offset + entry.preload_bytes then
					print("grr")
				end
				
				table.insert(vpk.entries, entry)
			end
			
			table.insert(vpk.entries, {path = directory .. "/", is_dir = true})
			
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

local CONTEXT = {}

CONTEXT.Name = "vpk"

local mounted = {}
local files = {}

local function mount(path)

	if mounted[path] then
		return mounted[path]
	end
	
	local file = assert(io.open(path, "rb"))
	
	local vpk = read_vpk(file)

	vpk.paths = {}

	for k,v in pairs(vpk.entries) do
		if v.is_file then
			v.archive_path = path:gsub("_dir.vpk$", function(str) return ("_%03d.vpk"):format(v.archive_index) end)
		end
		vpk.paths[v.path] = v
	end
	
	mounted[path] = vpk
	
	return vpk
end

local function split_path(path_info)
	local vpk_path, relative = path_info.full_path:match("(.-%.vpk)/(.+)")
	
	if not vpk_path and not relative then
		error("not a valid vpk path", 2)
	end
	
	return vpk_path, relative
end

function CONTEXT:IsFile(path_info)
	local vpk_path, relative = split_path(path_info)
	
	local vpk = mount(vpk_path)

	if vpk.paths[relative] and vpk.paths[relative].is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
	
	-- vpk files are folders
	if path_info.full_path:find("^.+%.vpk$") then
		return true
	end

	local vpk_path, relative = split_path(path_info)
	local vpk = mount(vpk_path)
	
	if vpk.paths[relative] and vpk.paths[relative].is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local vpk_path, relative = split_path(path_info)
	
	local out = {}
	
	local vpk = mount(vpk_path)
	
	relative = relative .. "."
	
	local dir = relative:match("(.+)/")
	
	for k, v in pairs(vpk.entries) do
		if v.path:find(relative) and v.path:match("(.+)/") == dir then
			table.insert(out, v.path:match(".+/(.+)") or v.path)
		end 
	end
	
	return out
end

function CONTEXT:Open(path_info, mode, ...)	
	local vpk_path, relative = split_path(path_info)
	local vpk = mount(vpk_path)
	
	local file
		
	if self:GetMode() == "read" then
		local file_info = vpk.paths[relative]
		local file = assert(io.open(file_info.archive_path, "rb"))
		file:seek("set", file_info.entry_offset)		
		
		self.file = file
		self.position = 0
		self.file_info = file_info
	elseif self:GetMode() == "write" then
		error("not implemented")
	end
end

function CONTEXT:Write(str)
	return self.file:write(str)
end

function CONTEXT:Read(bytes)
	return self.file:read(bytes)
end

function CONTEXT:WriteByte(byte)
	self:Write(string.char(byte))
end

function CONTEXT:ReadByte()					
	self.file:seek("set", self.file_info.entry_offset + self.position)
	local char = self.file:read(1)	
	self.position = math.clamp(self.position + 1, 0, self.file_info.entry_length)
	
	return char and char:byte() or nil
end

function CONTEXT:WriteBytes(str)
	return self.file:write(str)
end

function CONTEXT:ReadBytes(bytes)
	bytes = math.min(bytes, self.file_info.entry_length - self.position)

	self.file:seek("set", self.file_info.entry_offset + self.position)
	local str = self.file:read(bytes)
	
	self.position = math.clamp(self.position + bytes, 0, self.file_info.entry_length)
	
	if str ==  "" then 
		content = nil 
	end
	
	return str
end

function CONTEXT:SetPos(pos)
	self.position = math.clamp(pos, 0, self.file_info.entry_length)
end

function CONTEXT:GetPos()
	return self.position
end

function CONTEXT:Close()
	self.file:close()
end

function CONTEXT:GetSize()
	return self.file_info.entry_length
end

vfs2.RegisterFileSystem(CONTEXT)