local love = ... or love

love.filesystem = {}

local IDENTITY = "none"

function love.filesystem.getAppdataDirectory()
	return R("data/lovemu/" .. IDENTITY)
end

function love.filesystem.getSaveDirectory()
	return R("data/lovemu/" .. IDENTITY)
end

function love.filesystem.getUserDirectory()
	return R("data/lovemu/" .. IDENTITY)
end

function love.filesystem.getWorkingDirectory()
	return R("data/lovemu/" .. IDENTITY)
end

function love.filesystem.getLastModified(path)
	return vfs.GetLastModified("data/lovemu/" .. IDENTITY .. "/" .. path) or vfs.GetLastModified(path)
end

function love.filesystem.exists(path)
	return vfs.Exists("data/lovemu/" .. IDENTITY .. "/" .. path) or vfs.Exists(path)
end

function love.filesystem.enumerate(path)
	if path:sub(-1) ~= "/" then
		path = path .. "/"
	end

	return vfs.Find(path)
end

love.filesystem.getDirectoryItems = love.filesystem.enumerate

function love.filesystem.init() -- partial

end

function love.filesystem.isDirectory(path)
	return vfs.IsDir("data/lovemu/" .. IDENTITY .. "/" .. path) or vfs.IsDir(path)
end

function love.filesystem.isFile(path)
	return vfs.IsFile("data/lovemu/" .. IDENTITY .. "/" .. path) or vfs.IsFile(path)
end

function love.filesystem.lines(path)
	local file = assert(vfs.Open("data/lovemu/" .. IDENTITY .. "/" .. path))

	if ok then
		return ok:Lines()
	end

	local file = assert(vfs.Open("data/lovemu/" .. IDENTITY .. "/" .. path))

	return file:Lines()
end

function love.filesystem.load(path, mode)
	mode = mode or "read"

	local func, err

	if lovemu.Type(path) == "FileData" then
		func, err = loadstring(path:getString())
	else
		func, err = vfs.loadfile("data/lovemu/" .. IDENTITY .. "/" .. path, mode)
	end

	if func then
		setfenv(func, getfenv(2))
	elseif mode == "read" then
		func, err = vfs.loadfile(path, mode)

		if func then
			setfenv(func, getfenv(2))
		end
	end

	return func, err
end

function love.filesystem.mkdir(path) --partial
	fs.createdir(R("data/") .. "lovemu/")
	fs.createdir(R("data/lovemu/") .. IDENTITY .. "/")

	local ok, err = fs.createdir(R("data/lovemu/" .. IDENTITY .. "/") .. path)

	if not ok and err:find("File exist") then
		return true
	end

	return ok
end

love.filesystem.createDirectory = love.filesystem.mkdir

function love.filesystem.read(path)
	return vfs.Read("data/lovemu/" .. IDENTITY .. "/" .. path) or vfs.Read(path) or ""
end

function love.filesystem.remove(path) --partial
	warning("attempted to remove folder/file ", path)
end

function love.filesystem.setIdentity(name) --partial
	fs.createdir(R("data/") .. "lovemu/")
	fs.createdir(R("data/lovemu/") .. name .. "/")

	IDENTITY = name
end

function love.filesystem.getIdentity()
	return IDENTITY
end

function love.filesystem.write(path, data)
	vfs.Write("data/lovemu/" .. IDENTITY .. "/" .. path, data)
	return true
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
		self.file:Close()
	end

	function File:eof()
		if not self.file then return 0 end
		return self.file:TheEnd() ~= nil
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
		return self.file:Lines()
	end

	function File:read(bytes)
		local str = self.file:ReadBytes(bytes)
		return str, #str
	end

	function File:write(data, size) -- partial
		if lovemu.Type(data) == "string" then
			self.file:WriteBytes(data)
			return true
		elseif lovemu.Type(data) == "Data" then
			lovemu.ErrorNotSupported("Data not supported")
		end
	end

	function File:open(mode)
		if mode == "w" then mode = "write" end
		if mode == "r" then mode = "read" end

		logn("[lovemu] file open ", self.path, " ", mode)
		local path = self.path

		if mode == "w" then
			path = "data/lovemu/" .. IDENTITY .. "/" .. self.path
		end

		self.file = assert(vfs.Open(path, mode))
		self.mode = mode
	end

	function love.filesystem.newFile(path, mode)
		local self = lovemu.CreateObject(File)
		self.path = path

		if mode then
			self:open(mode)
		end

		return self
	end
end


do -- FileData object
	local FileData = {}

	FileData.Type = "FileData"

	function FileData:getPointer()
		return ffi.cast("uint8_t *", self.contents)
	end

	function FileData:getSize()
		return #self.contents
	end

	function FileData:getString()
		return self.contents
	end

	function FileData:getExtension()
		return self.ext
	end

	function FileData:getFilename()
		return self.filename
	end

	function love.filesystem.newFileData(contents, name, decoder)
		if name then
			love.filesystem.write(name, contents)
		else
			contents = love.filesystem.read(name)
		end

		local self = lovemu.CreateObject(FileData)

		self.contents = contents
		self.filename, self.ext = name:match("(.+)%.(.+)")

		return self
	end
end