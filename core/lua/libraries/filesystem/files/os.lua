local vfs = (...) or _G.vfs

local fs = require("fs")
local ffi = require("ffi")

local CONTEXT = {}

CONTEXT.Name = "os"
CONTEXT.Position = 0

function CONTEXT:CreateFolder(path_info, force)
	if force or path_info.full_path:startswith(e.DATA_FOLDER) or path_info.full_path:startswith(e.USERDATA_FOLDER) or path_info.full_path:startswith(e.ROOT_FOLDER) then
		if self:IsFolder(path_info) then return true end

		if force then
			if not CLI then
				llog("creating directory: ", path_info.full_path)
			end
		end

		local path = path_info.full_path
		--if path:endswith("/") then path = path:sub(0, -2) end
		local ok, err = fs.createdir(path)
		vfs.ClearCallCache()
		return ok, err
	end
	return false, "directory does not start from goluwa"
end

function CONTEXT:GetFiles(path_info)
	if not self:IsFolder(path_info) then
		return false, "not a directory"
	end

	return fs.find(path_info.full_path)
end

function CONTEXT:IsFile(path_info)
	local info = fs.getattributes(path_info.full_path)
	return info and info.type ~= "directory"
end

function CONTEXT:IsFolder(path_info)
	if path_info.full_path:endswith("/") then
		local info = fs.getattributes(path_info.full_path:sub(0, -2))
		return info and info.type == "directory"
	end
end

function CONTEXT:ReadAll()
	return self:ReadBytes(math.huge)
end

if fs.open then

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
	local math_min = math.min
	-- without this cache thing loading gm_construct takes 30 sec opposed to 15
	local cache = {}

	for i = 1, 32 do
		cache[i] = ctype(i)
	end

	function CONTEXT:ReadBytes(bytes)
		bytes = math_min(bytes, self.attributes.size)

		local buff = bytes > 32 and ctype(bytes) or cache[bytes]

		if self.memory then
			local mem_pos_start = math_min(tonumber(self.mem_pos), self.attributes.size)
			local mem_pos_stop = math_min(tonumber(mem_pos_start + bytes), self.attributes.size)

			local i = 0
			for mem_i = mem_pos_start, mem_pos_stop-1 do
				buff[i] = self.memory[mem_i]
				i = i + 1
			end

			self.mem_pos = self.mem_pos + bytes

			return ffi.string(buff, bytes)
		else
			local len = fs.read(buff, bytes, 1, self.file)

			if len > 0 or fs.eof(self.file) == 1 then
				return ffi_string(buff, bytes)
			end
		end
	end

	function CONTEXT:LoadToMemory()
		local bytes = self:GetSize()
		local buffer = ctype(bytes)
		local len = fs.read(buffer, bytes, 1, self.file)
		self.memory = buffer
		self:SetPosition(ffi.new("uint64_t", 0))
		self:OnRemove()
	end

	function CONTEXT:SetPosition(pos)
		if self.memory then
			self.mem_pos = pos
		else
			fs.seek(self.file, pos, 0)
		end
	end

	function CONTEXT:GetPosition()
		if self.memory then
			return self.mem_pos
		else
			return fs.tell(self.file)
		end
	end

	function CONTEXT:OnRemove()
		if self.file ~= nil then
			fs.close(self.file)
			self.file = nil
		end
	end
else
	local translate_mode = {
		read = "r",
		write = "w",
	}

	function CONTEXT:Open(path_info, ...)
		local mode = translate_mode[self:GetMode()]

		if not mode then return false, "mode not supported" end

		local f, err = io.open(path_info.full_path, mode .. "b")

		self.file = f

		if self.file == nil then
			return false, "unable to open file: " .. err
		end

		self.attributes = fs.getattributes(path_info.full_path)
	end

	function CONTEXT:WriteBytes(str)
		return self.file:write(str)
	end

	function CONTEXT:ReadBytes(bytes)
		bytes = math.min(bytes, self.attributes.size)

		return self.file:read(bytes)
	end

	function CONTEXT:SetPosition(pos)
		self.file:seek("set", pos)
	end

	function CONTEXT:GetPosition()
		return self.file:seek("cur")
	end

	function CONTEXT:OnRemove()
		if self.file ~= nil then
			self.file:close()
			self.file = nil
		end
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