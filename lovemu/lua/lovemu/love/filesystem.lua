local love = (...) or _G.lovemu.love

love.filesystem = {}

function love.filesystem.getAppdataDirectory()
	return R("%DATA%/lovemu/")
end

function love.filesystem.getLastModified(path)
	local attribs = vfs.GetAttributes(path)
	return attribs.modification or 0
end

function love.filesystem.getSaveDirectory()
	return R("%DATA%/lovemu/")
end

function love.filesystem.getUserDirectory()
	return R("%DATA%/lovemu/")
end

function love.filesystem.getWorkingDirectory()
	return R("%DATA%/lovemu/")
end

function love.filesystem.exists(path)
	return vfs.Exists(path)
end

function love.filesystem.enumerate(path)
	return vfs.Find(path)
end

love.filesystem.getDirectoryItems = love.filesystem.enumerate

function love.filesystem.init() -- partial

end

function love.filesystem.isDirectory(path)
	return vfs.IsDir(path)
end

function love.filesystem.isFile(path)
	return vfs.GetAttributes(path).mode == "file"
end

function love.filesystem.lines(path)
	return io.lines(vfs.GetFile(path))
end

function love.filesystem.load(path ,mode)
	local func, err = vfs.loadfile(path, mode)
	
	if func then
		setfenv(func, getfenv(2))
	end
	
	return func, err
end

function love.filesystem.mkdir(path) --partial
	lfs.mkdir(R("%DATA%/lovemu/" .. path))
end

love.filesystem.createDirectory = love.filesystem.mkdir

function love.filesystem.read(path)
	return vfs.Read(path) or ""	 
end

function love.filesystem.remove(path) --partial
	logn("[lovemu] attempted to remove folder/file ", path)
end

function love.filesystem.setIdentity(name) --partial
	
end

function love.filesystem.write(path, data)
	vfs.Write("lovemu/" .. path, data)
end

function love.filesystem.isFused() -- partial
	return false
end

function love.filesystem.mount() --partial

end

function love.filesystem.unmount() --partial

end

function love.filesystem.append(name, data, size) -- partial
	
end

do -- File object
	local File = {}
	
	File.Type = "File"
	
	function File:close()
		if not self.file then return end
		self.file:close()
	end
	
	function File:eof()
		if not self.file then return 0 end
		return self.file:seek() ~= nil
	end
	
	do
		local MODE
		local SIZE
		
		function File:setBuffer(mode, size)
			if self.file then return false, "file not opened" end
			
			self.file:setvbuf(mode == "none" and "no" or mode, size)
			
			MODE = mode 
			SIZE = size			
		end
		
		function File:getBuffer()
			return MODE, SIZE
		end
	end
	
	function File:getMode()
		return self.mode
	end
	
	function File:getSize() -- partial
		return 10
	end
	
	function File:isOpen()
		return self.file ~= nil
	end
	
	function File:lines()
		if not self.file then return function() end end
		return self.file:lines()
	end
	
	function File:read(bytes)
		local str = self.file:read(bytes)
		return str, #str
	end

	function File:write(data, size) -- partial
		if lovemu.Type(data) == "string" then
			self.file:write(data)
			return true
		elseif lovemu.Type(data) == "Data" then
			lovemu.ThrowNotSupportedError("Data not supported")
		end
	end
	
	function love.filesystem.newFile(file_name, mode)	
		local self = lovemu.CreateObject(File)
		
		self.file = vfs.GetFile(file_name, mode)
		self.mode = mode
		
		return self
	end
end