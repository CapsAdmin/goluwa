local vfs = (...) or _G.vfs
local lfs = require("lfs")

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
vfs.SetEnv("BASE", "os:" .. e.BASE_FOLDER)
vfs.SetEnv("BIN", function() return "os:" .. lfs.currentdir() end)

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

function CONTEXT:IsFile(path)
	local ext = path:match(".+%.(%a+)")
	local len = #ext
	return ext and not path:sub((#path-len)):find("/") and not path:sub((#path-len)):find("\\") --returns the file extension, could make it return bool if we wanted.
end

function CONTEXT:IsFolder(path)
	local ext = path:match(".+%.(%a+)")
	return not ext or not (path:sub((#path-#ext))):match(ext)
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
	self.attributes = lfs.attributes(path_info.full_path)
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
	self:Remove()
end

function CONTEXT:GetSize()
	return self.attributes.size
end

function CONTEXT:GetLastModified()
	return self.attributes.modification
end

function CONTEXT:GetLastAccessed()
	return self.attributes.access
end

vfs.RegisterFileSystem(CONTEXT)
