local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "memory"

local file_tree = {is_folder = true}

function CONTEXT:VFSOpened()
	file_tree = serializer.ReadFile("luadata", "vfs_memory")
	
	logn("memory tree loaded")
end

function CONTEXT:VFSClosed()
	-- yeah right as if this is ever going to happen cleanly
	serializer.WriteFile("luadata", "vfs_memory", file_tree)
	
	logn("memory tree saved")
end

local function get_folder(path_info)
	
	local next = file_tree
	local folders = path_info:GetFolders()
	local max = #folders
	
	for i = 1, #folders do
		local folder = folders[i]
		
		if not next[folder] then
			error("folder not found", 2)
		end
		
		next = next[folder]
	end
	
	return next
end

function CONTEXT:CreateFolder(path_info)
	local folder = get_folder(path_info)
	folder[path_info.folder_name] = {
		is_folder = true,
	}
end

function CONTEXT:GetFiles(path_info)
	local out = {}
	
	for file_name, var in pairs(get_folder(path_info)) do
		if type(var) == "table" and var.is_file then
			table.insert(out, file_name)
		end
	end
	
	return out
end

function CONTEXT:GetFolders(path_info)
	local out = {}
	
	for file_name, var in pairs(get_folder(path_info)) do
		if type(var) == "table" and var.is_folder then
			table.insert(out, file_name)
		end
	end
	
	return out
end

function CONTEXT:Open(path_info, mode, ...)
	local file
	
	if self:GetMode() == "read" then
		local folder = get_folder(path_info)
		file = folder[path_info.file_name]
		file.last_accessed = os.time()
		
	elseif self:GetMode() == "write" then
		local folder = get_folder(path_info)
		
		file = folder[path_info.file_name] or {
			is_file = true,
			data = "",
		}
		
		file.buffer = Buffer(file.data)
		file.last_accessed = os.time()
		
		folder[path_info.file_name] = file
	end
	
	file.buffer:SetPos(0)
	
	self.file = file
end

local function save_file(self)
	self.file.data = self.file.buffer:GetString()
end

function CONTEXT:Write(str)
	
	-- save 0.5 seconds after a write
	event.DeferExecution(CONTEXT.VFSClosed, 0.5)
	event.DeferExecution(save_file, 0.1, self)
	
	self.file.last_modified = os.time()
	return self.file.buffer:WriteBytes(str)
end

function CONTEXT:Read(bytes)
	self.file.last_accessed = os.time()
	return self.file.buffer:ReadBytes(bytes)
end

function CONTEXT:WriteByte(byte)
	self.file.buffer:WriteByte(byte)
end

function CONTEXT:ReadByte()
	return self.file.buffer:ReadByte()
end

function CONTEXT:SetPos(pos)
	self.file.buffer:SetPos(pos)
end

function CONTEXT:GetPos()
	return self.file.buffer:GetPos()
end

function CONTEXT:Close()
	-- hmm
end

function CONTEXT:GetSize()
	return self.file.buffer:GetSize()
end

function CONTEXT:GetLastModified()
	return self.file.last_modified
end

function CONTEXT:GetLastAccessed()
	return self.file.last_accessed
end

vfs.Register(CONTEXT)