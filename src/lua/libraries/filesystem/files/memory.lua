do return end
local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "memory"

local file_tree = {is_folder = true}

function CONTEXT:VFSOpened()
	file_tree = serializer.ReadFile("luadata", "vfs_memory") or {}
end

function CONTEXT:VFSClosed()
	-- yeah right as if this is ever going to happen cleanly
	serializer.WriteFile("luadata", "vfs_memory", file_tree)
end

local function get_folder(path_info, remove_last)
	local next = file_tree

	local folders = path_info:GetFolders()

	-- when creating a folder the folder doesn't exist
	-- so remove it
	if remove_last then
		table.remove(folders)
	end

	for i, folder in ipairs(folders) do
		if not next[folder] then
			error("folder not found", 2)
		end
		next = next[folder]
	end

	return next
end

function CONTEXT:IsFile(path_info)
	local folder = get_folder(path_info, true)
	if folder and folder[path_info.file_name] and folder[path_info.file_name].is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
	local folder = get_folder(path_info, true)
	if folder and folder[path_info.folder_name] and folder[path_info.folder_name].is_folder then
		return true
	end
end

function CONTEXT:CreateFolder(path_info)
	local folder = get_folder(path_info, true)

	folder[path_info.folder_name] = folder[path_info.folder_name] or {
		is_folder = true,
	}

	event.DeferExecution(CONTEXT.VFSClosed, 0.5)
end

function CONTEXT:GetFiles(path_info)
	local out = {}

	for file_name, var in pairs(get_folder(path_info)) do
		if type(var) == "table" then
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

		file.buffer = packet.CreateBuffer()
		file.last_accessed = os.time()

		folder[path_info.file_name] = file
	end

	file.buffer:SetPosition(0)

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

function CONTEXT:SetPosition(pos)
	self.file.buffer:SetPosition(pos)
end

function CONTEXT:GetPosition()
	return self.file.buffer:GetPosition()
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

vfs.RegisterFileSystem(CONTEXT)