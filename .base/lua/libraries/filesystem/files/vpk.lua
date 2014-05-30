-- vpk reader by https://github.com/animorten

local function read_integer(file, byte_count)
	local str = file:read(byte_count)
	local num = 0
	
	for i = 1, byte_count do 
		num = (num*256) + str:byte(-i) 
	end
	
	return num
end

local function read_string(file)
	local buffer = {}

	for i = 1, math.huge do
		local char = file:read(1)

		if char == "\0" then
			break
		elseif not char then
			return
		end

		buffer[i] = char
	end

	return table.concat(buffer)
end

local function iterate_strings(file)
	return function()
		local value = read_string(file)
		return value ~= "" and value or nil
	end
end

local function read_header(file)
	local header = {}

	header.signature = read_integer(file, 4)
	header.version = read_integer(file, 4)
	header.tree_length = read_integer(file, 4)

	if not header.tree_length then
		return nil, "Unexpected end-of-file"
	end

	if header.signature ~= 0x55aa1234 then
		return nil, string.format("Invalid signature 0x%.8x", header.signature)
	end

	if header.version == 2 then
		header.unknown_1 = read_integer(file, 4)
		header.footer_length = read_integer(file, 4)
		header.unknown_3 = read_integer(file, 4)
		header.unknown_4 = read_integer(file, 4)

		if not header.unknown_4 then
			return nil, "Unexpected end-of-file"
		end
	elseif header.version ~= 1 then
		return nil, string.format("Invalid version %d", header.version)
	end

	return header, "Success"
end

local function read_entry(file, extension, directory, name)
	local entry = {}

	entry.path = (directory ~= " " and directory .. "/" or "") .. (name ~= " " and name or "") .. (extension ~= " " and "." .. extension or "")

	entry.crc = read_integer(file, 4)
	entry.preload_bytes = read_integer(file, 2)
	entry.archive_index = read_integer(file, 2)
	entry.entry_offset = read_integer(file, 4)
	entry.entry_length = read_integer(file, 4)
	entry.is_file = true
	
	local terminator = read_integer(file, 2)

	if not terminator then
		return nil, "Unexpected end-of-file"
	end

	if terminator ~= 0xffff then
		return nil, string.format("Invalid entry terminator 0x%.4x", terminator)
	end

	entry.preload_offset = file:seek()

	if file:seek("cur", entry.preload_bytes) ~= entry.preload_offset + entry.preload_bytes then
		return nil, "Skipping preload data failed"
	end

	return entry, "Success"
end

local function read_tree(file)
	local tree = {}
	local done_directories = {}

	for extension in iterate_strings(file) do
		for directory in iterate_strings(file) do
			for name in iterate_strings(file) do
				local entry, error_message = read_entry(file, extension, directory, name)

				if not entry then
					return nil, "Parsing entry failed: " .. error_message
				end

				tree[#tree + 1] = entry
			end
			tree[#tree + 1] = {path = directory, is_folder = true}
			
			for i = 0, 100 do
				local dir = vfs.GetParentFolder(directory, i)
				if dir == "" or done_directories[dir] then break end
				tree[#tree + 1] = {path = dir:sub(0, -2), is_folder = true}
				done_directories[dir] = true
			end
		end
	end

	return tree, "Success"
end

local function read_footer(file)
	local footer = {}
	return footer, "Success"
end

local function read_file(file)
	local self = {}
	local error_message

	self.header, error_message = read_header(file)

	if not self.header then
		return nil, "Failed parsing header: " .. error_message
	end

	self.tree, error_message = read_tree(file)

	if not self.tree then
		return nil, "Failed parsing tree: " .. error_message
	end

	if self.header.version == 2 then
		self.footer, error_message = read_footer()

		if not self.footer then
			return nil, "Failed parsing footer: " .. error_message
		end
	end

	return self, "Success"
end

local function read_vpk_dir(path)
	check(path, "string")
	
	local cache_path = "%DATA%/vpk_cache/" .. crypto.CRC32(path)
	
	if vfs.Exists(cache_path) then
		local str = vfs.Read(cache_path, "b")
		return serializer.Decode("luadata", str), "Success"
	end
	
	local file, error_message = io.open(path, "rb")

	if not file then
		return nil, "Failed opening VPK: " .. error_message
	end

	local self, error_message = read_file(file)
	file:close()

	if not self then
		return nil, "Failed parsing: " .. error_message
	end
	
	serializer.Encode("luadata", self, function(data, err)
		if data then
			logn("saved cache of vpk tree ", path)
			vfs.Write(cache_path, data)
		end
	end, 1000)

	return self, "Success"
end
 
local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "vpk"

local mounted = {}

local function mount(path)
	if mounted[path] then
		return mounted[path]
	end
	
	local vpk = assert(read_vpk_dir(path))

	vpk.paths = {}

	for k,v in pairs(vpk.tree) do
		if v.is_file then
			v.archive_path = path:gsub("_dir.vpk$", function(str) return ("_%03d.vpk"):format(v.archive_index) end)
		end
		vpk.paths[v.path] = v
	end
	
	mounted[path] = vpk
	
	return vpk
end

function CONTEXT:IsFile(path_info)
	local vpk_path, relative = path_info.full_path:match("(.-%.vpk)/(.+)")
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

	local vpk_path, relative = path_info.full_path:match("(.-%.vpk)/(.+)")
	local vpk = mount(vpk_path)

	if vpk.paths[relative] and vpk.paths[relative].is_folder then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	
	local out = {}
	
	local vpk_path, relative = path_info.full_path:match("(.-%.vpk)/(.+)")
	
	if vpk_path then
		local vpk = mount(vpk_path)
		
		relative = relative .. "."
		
		local dir = relative:match("(.+)/")
		
		for k, v in pairs(vpk.tree) do
			if v.path:find(relative) and v.path:match("(.+)/") == dir then
				table.insert(out, v.path:match(".+/(.+)") or v.path)
			end 
		end
	end
	
	return out
end

function CONTEXT:Open(path_info, mode, ...)	
	local vpk_path, relative = path_info.full_path:match("(.-%.vpk)/(.+)")
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

vfs.Register(CONTEXT)