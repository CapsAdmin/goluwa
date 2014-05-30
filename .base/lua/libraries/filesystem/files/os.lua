local vfs = (...) or _G.vfs
local lfs = require("lfs")

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
	self.attributes = lfs.attributes(path)
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
	return self:Read(1):byte()
end

function CONTEXT:WriteBytes(str)
	return self.file:write(str)
end

function CONTEXT:ReadBytes(bytes)
	return self.file:read(bytes)
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

vfs.Register(CONTEXT)