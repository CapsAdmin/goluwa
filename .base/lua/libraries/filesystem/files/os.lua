local vfs2 = (...) or _G.vfs2
local lfs = require("lfs")

if vfs2.use_appdata then
	if WINDOWS then
		vfs2.SetEnv("DATA", "os:%%APPDATA%%/.goluwa")
	end

	if LINUX then
		vfs2.SetEnv("DATA", "os:%%HOME%%/.goluwa")
	end 
else
	vfs2.SetEnv("DATA", "os:" .. e.USERDATA_FOLDER)
end

vfs2.SetEnv("ROOT", "os:" .. e.ROOT_FOLDER)
vfs2.SetEnv("BASE", "os:" .. e.BASE_FOLDER)
vfs2.SetEnv("BIN", function() return "os:" .. lfs.currentdir() end)

local CONTEXT = {}

CONTEXT.Name = "os"

function CONTEXT:CreateFolder(path_info)
	lfs.mkdir(path_info.full_path)
end

function CONTEXT:GetFiles(path_info)
	local out = {}
		
	for file_name in lfs.dir(path_info.full_path) do
		if file_name ~= "." and file_name ~= ".." then
			table.insert(out, file_name)
		end
	end
	
	return out
end

function CONTEXT:IsFile(path_info)
	local info = lfs.attributes(path_info.full_path)
	return info and info.mode ~= "directory"
end

function CONTEXT:IsFolder(path_info)
	local info = lfs.attributes(path_info.full_path)
	return info and info.mode == "directory"
end

-- if CONTEXT:Open errors the virtual file system will assume 
-- the file doesn't exist and will go to the next mounted context

local translate_mode = {
	read = "r",
	write = "w",
}

function CONTEXT:Open(path_info, ...)
	
	local mode = translate_mode[self:GetMode(mode)]
	
	if not mode then 
		error("mode not supported" .. mode)
	end
	
	mode = mode .. "b" -- always open in binary

	self.file = assert(io.open(path_info.full_path, mode)) 
	self.attributes = lfs.attributes(path_info.full_path)
end

function CONTEXT:WriteBytes(str)
	return self.file:write(str)
end

function CONTEXT:ReadBytes(bytes)
	return self.file:read(bytes)
end

function CONTEXT:WriteByte(byte)
	self:Write(string.char(byte))
end

function CONTEXT:ReadByte()
	return self:Read(1):byte()
end

function CONTEXT:SetPos(pos)
	self.file:seek("set", pos)
end

function CONTEXT:GetPos()
	return self.file:seek()
end

function CONTEXT:Close()
	self.file:close()
end

function CONTEXT:GetSize()
	return self.attributes.size
end

function CONTEXT:GetLastModified()
	return lfs.attributes(self.path).modification
end

function CONTEXT:GetLastAccessed()
	return lfs.attributes(self.path).access
end

vfs2.RegisterFileSystem(CONTEXT)