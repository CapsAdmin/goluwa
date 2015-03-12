do return end
local vfs = (...) or _G.vfs

local function read_bsa(file, full_path)

	local tree = utility.CreateTree("/")
	local done_directories = {}
	
	local header = file:ReadStructure([[
		string magic = BSA;
		unsigned int version;
		unsigned int offset = 36;
		unsigned int archive_flags; 
		unsigned int folder_count;
		unsigned int file_count;
		unsigned int folder_name_length;
		unsigned int file_name_length;
		unsigned int file_flags;
	]])

	local strings = {}

	do
		local strings_offset = header.offset + header.folder_count * 16 + (header.folder_count + header.folder_name_length + 16 * header.file_count)

		file:PushPosition(strings_offset)
			for i = 1, math.huge do
				if file:GetPosition() >= strings_offset + header.file_name_length then break end 
				strings[i] = file:ReadString()
			end
		file:PopPosition()
	end

	for i = 1, header.folder_count do
		local folder = file:ReadStructure([[
			unsigned longlong hash;
			unsigned int file_count;
			unsigned int offset;
		]])	
		
		folder.files = {}
			
		file:PushPosition(folder.offset - header.file_name_length + 1)
			local directory = file:ReadString():gsub("\\", "/") .. "/"
			
			tree:SetEntry(directory, {path = directory, is_dir = true, file_name = directory:match(".+/(.+)")})
			
			for i = 0, 100 do
				local dir = utility.GetParentFolder(directory, i)
				if dir == "" or done_directories[dir] then break end
				local file_name = dir:match(".+/(.+)") or dir
				
				if file_name:sub(-1) == "/" then
					file_name = file_name:sub(0, -2)
				end
		
				tree:SetEntry(dir, {path = dir, is_dir = true, file_name = file_name})
				done_directories[dir] = true
			end
			
			for j = 1, folder.file_count do
				local file = file:ReadStructure([[
					unsigned longlong hash;
					unsigned int entry_length;
					unsigned int entry_offset;
				]])
				
				local file_name = table.remove(strings, 1)
				local file_path = directory .. file_name
				
				file.archive_path = "os:" .. full_path
				file.file_name = file_name
				file.directory = directory
				file.full_path = file_path
				
				tree:SetEntry(file_path, file)
			end
		file:PopPosition()
	end
		
	return tree
end

--read_bsa(vfs.Open("os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.bsa"), "os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.bsa")
 
local cache = {}

local function get_file_tree(path)

	if cache[path] then
		return cache[path]
	end

	local file = assert(vfs.Open("os:" .. path))	
	local tree = read_bsa(file, path)
		
	file:Close()
	
	cache[path] = tree
	
	return tree
end

local CONTEXT = {}

CONTEXT.Name = "bsa"

local function split_path(path_info)
	local bsa_path, relative = path_info.full_path:match("(.-%.bsa)/(.*)")
	
	if not bsa_path and not relative then
		error("not a valid bsa path", 2)
	end
	
	return bsa_path, relative
end

function CONTEXT:IsFile(path_info)
	local bsa_path, relative = split_path(path_info)
	local tree = get_file_tree(bsa_path)
	local entry = tree:GetEntry(relative)
	
	if entry and entry.is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
		
	-- bsa files are folders
	if path_info.folder_name:find("^.+%.bsa$") then
	--	return true
	end

	local bsa_path, relative = split_path(path_info)
	local tree = get_file_tree(bsa_path)
	local entry = tree:GetEntry(relative)
	if entry and entry.is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local bsa_path, relative = split_path(path_info)
	local tree = get_file_tree(bsa_path)
						
	local out = {}
					
	for k, v in pairs(tree:GetChildren(relative:match("(.*)/"))) do
		if v.value then -- fix me!!
			table.insert(out, v.value.file_name)
		end
	end
	
	return out
end

function CONTEXT:Open(path_info, mode, ...)	
	local bsa_path, relative = split_path(path_info)
	local tree = get_file_tree(bsa_path)
	
	local file
		
	if self:GetMode() == "read" then
		local file_info = tree:GetEntry(relative)
		local file = assert(vfs.Open(file_info.archive_path))
		file:SetPosition(file_info.entry_offset)		
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
	self.file:SetPosition(self.file_info.entry_offset + self.position)
	local byte = self.file:ReadByte(1)	
	self.position = math.clamp(self.position + 1, 0, self.file_info.entry_length)
	
	return byte
end

function CONTEXT:WriteBytes(str)
	--return self.file:WriteBytes(str)
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