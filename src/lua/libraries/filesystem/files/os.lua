local vfs = (...) or _G.vfs

local fs = require("fs")

if vfs.use_appdata then
	if WINDOWS then
		vfs.SetEnv("DATA", "os:%%APPDATA%%/.goluwa")
	end

	if LINUX then
		vfs.SetEnv("DATA", "os:%%HOME%%/.goluwa")
	end
else
	vfs.SetEnv("DATA", "os:" .. e.USERDATA_FOLDER)
end

vfs.SetEnv("ROOT", "os:" .. e.ROOT_FOLDER)
vfs.SetEnv("SRC", "os:" .. e.SRC_FOLDER)
vfs.SetEnv("BIN", "os:" .. e.BIN_FOLDER)

local CONTEXT = {}

CONTEXT.Name = "os"
CONTEXT.Position = 0

function CONTEXT:CreateFolder(path_info)
	if path_info.full_path:startswith(e.ROOT_FOLDER) then
		fs.createdir(path_info.full_path)
	end
end

function CONTEXT:GetFiles(path_info)
	if not self:IsFolder(path_info) then
		error(path_info.full_path .. " is not a valid folder", 2)
	end

	return fs.find(path_info.full_path, true)
end

function CONTEXT:IsFile(path_info)
	local info = fs.getattributes(path_info.full_path)
	return info and info.type ~= "directory"
end

function CONTEXT:IsFolder(path_info)
	local info = fs.getattributes(path_info.full_path:sub(0, -2))
	return info and info.type == "directory"
end

-- if CONTEXT:Open errors the virtual file system will assume
-- the file doesn't exist and will go to the next mounted context

local translate_mode = {
	read = "r",
	write = "w",
}

function CONTEXT:Open(path_info, ...)

	local mode = translate_mode[self:GetMode()]

	if not mode then
		error("mode not supported: " .. self:GetMode())
	end

	mode = mode .. "b" -- always open in binary

	self.file = assert(io.open(path_info.full_path, mode))
	self.attributes = fs.getattributes(path_info.full_path)
end

function CONTEXT:WriteBytes(str)
	return self.file:write(str)
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end

	return self.file:read(bytes)
end

function CONTEXT:ReadAll()
	return self:ReadBytes(math.huge)
end

function CONTEXT:SetPosition(pos)
	self.file:seek("set", pos)
end

function CONTEXT:GetPosition()
	return self.file:seek()
end

function CONTEXT:Close()
	self.file:close()
	self:Remove()
end

function CONTEXT:GetSize()
	return self.attributes.size
end

function CONTEXT:GetLastModified()
	return self.attributes.last_modified
end

function CONTEXT:GetLastAccessed()
	return self.attributes.last_accessed
end

function CONTEXT:Flush()
	self.file:flush()
end

vfs.RegisterFileSystem(CONTEXT)