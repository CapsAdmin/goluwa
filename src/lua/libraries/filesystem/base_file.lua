local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "base"

prototype.GetSet(CONTEXT, "Mode", "read")

function CONTEXT:PCall(name, a,b,c,d)
	local ok,a,b,c,d = pcall(self[name], self, a,b,c,d)
	if vfs.debug and not ok then
		vfs.DebugPrint("%s: error calling %s: %s", self.Name or "", name, a)
		return false
	end

	if ok then
		return a,b,d,c
	end

	return false
end

do
	local cache = vfs.call_cache or {}
	local last_framenumber = 0

	function vfs.ClearCallCache()
		table.clear(cache)
	end

	function CONTEXT:CacheCall(func_name, path_info)
		if system then
			local frame_number = system.GetFrameNumber()
			if frame_number ~= last_framenumber then
				vfs.ClearCallCache()
				last_framenumber = frame_number
			end
		end

		cache[func_name] = cache[func_name] or {}
		cache[func_name][self.Name] = cache[func_name][self.Name] or {}

		if cache[func_name][self.Name][path_info.full_path] == nil then
			cache[func_name][self.Name][path_info.full_path] = self:PCall(func_name, path_info)
		end

		return cache[func_name][self.Name][path_info.full_path]
	end

	vfs.call_cache = cache
end

function CONTEXT:Write(str)
	return self:WriteBytes(str)
end

function CONTEXT:Read(bytes)
	return self:ReadBytes(bytes)
end

function CONTEXT:Lines()
	local temp = {}
	return function()
		while not self:TheEnd() do
			local char = self:ReadChar()

			if char == "\n" then
				local str = table.concat(temp)
				table.clear(temp)
				return str
			else
				table.insert(temp, char)
			end
		end
	end
end

function CONTEXT:ReadByte()
	local str = self:ReadBytes(1)
	if str then
		return str:byte()
	end
end

function CONTEXT:WriteByte(byte)
	self:WriteBytes(string.char(byte))
end

function CONTEXT:GetFiles(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:IsFile(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:IsFolder(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:CreateFolder(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:Open(path, mode, ...)
	error(self.Name .. ": not implemented")
end

function CONTEXT:SetPosition(pos)
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetPosition()
	error(self.Name .. ": not implemented")
end

function CONTEXT:Close()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetSize()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetLastModified()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetLastAccessed()
	error(self.Name .. ": not implemented")
end

function CONTEXT:Flush()
	error(self.Name .. ": not implemented")
end

include("lua/libraries/templates/buffer.lua", CONTEXT)

prototype.Register(CONTEXT, "file_system", CONTEXT.Name)