local vfs = (...) or _G.vfs

local fs = require("fs")

local ffi = require("ffi")

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
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	if not self:IsFolder(path_info) then
		return false, "not a directory"
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

	if not mode then return false, "mode not supported" end

	self.file = fs.open(path_info.full_path, mode .. "b")

	if self.file == nil then
		return false, "unable to open file: " .. ffi.strerror()
	end

	self.attributes = fs.getattributes(path_info.full_path)
end

function CONTEXT:WriteBytes(str)
	return fs.write(str, 1, #str, self.file)
end

local ctype = ffi.typeof("uint8_t[?]")
local ffi_string = ffi.string

-- without this cache thing loading gm_construct takes 30 sec opposed to 15
local cache = utility.CreateWeakTable()

function CONTEXT:ReadBytes(bytes)
	bytes = math.min(bytes, self.attributes.size)

	local buff = cache[bytes] or ctype(bytes)

	cache[bytes] = buff

	local len = fs.read(buff, bytes, 1, self.file)

	if len > 0 or fs.eof(self.file) == 1 then
		return ffi_string(buff, bytes)
	end
end

function CONTEXT:ReadAll()
	return self:ReadBytes(math.huge)
end

function CONTEXT:SetPosition(pos)
	fs.seek(self.file, pos, 0)
end

function CONTEXT:GetPosition()
	return fs.tell(self.file)
end

function CONTEXT:OnRemove()
	if self.file ~= nil then
		fs.close(self.file)
	end
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
	--self.file:flush()
end

vfs.RegisterFileSystem(CONTEXT)