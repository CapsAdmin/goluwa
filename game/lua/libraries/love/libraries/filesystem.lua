local love = ... or _G.love
local ENV = love._line_env
love.filesystem = love.filesystem or {}
ENV.filesystem_identity = ENV.filesystem_identity or "none"

function love.filesystem.getAppdataDirectory()
	return R("data/love/" .. ENV.filesystem_identity .. "/")
end

function love.filesystem.getSaveDirectory()
	return R("data/love/" .. ENV.filesystem_identity .. "/")
end

function love.filesystem.getUserDirectory()
	return R("data/love/" .. ENV.filesystem_identity .. "/")
end

function love.filesystem.getWorkingDirectory()
	return R("data/love/" .. ENV.filesystem_identity .. "/")
end

function love.filesystem.getLastModified(path)
	return vfs.GetLastModified("data/love/" .. ENV.filesystem_identity .. "/" .. path) or
		vfs.GetLastModified(path)
end

function love.filesystem.enumerate(path)
	if path:sub(-1) ~= "/" then path = path .. "/" end

	if vfs.IsDirectory("data/love/" .. ENV.filesystem_identity .. "/" .. path) then
		return vfs.Find("data/love/" .. ENV.filesystem_identity .. "/" .. path)
	end

	return vfs.Find(path)
end

love.filesystem.getDirectoryItems = love.filesystem.enumerate

function love.filesystem.init() end

function love.filesystem.isDirectory(path)
	return vfs.IsDirectory("data/love/" .. ENV.filesystem_identity .. "/" .. path) or
		vfs.IsDirectory(path)
end

function love.filesystem.isFile(path)
	return vfs.IsFile("data/love/" .. ENV.filesystem_identity .. "/" .. path) or
		vfs.IsFile(path)
end

function love.filesystem.exists(path)
	return vfs.Exists("data/love/" .. ENV.filesystem_identity .. "/" .. path) or
		vfs.Exists(path)
end

function love.filesystem.lines(path)
	local file = vfs.Open("data/love/" .. ENV.filesystem_identity .. "/" .. path)

	if not file then file = vfs.Open(path) end

	if file then return file:Lines() end

	return function() end
end

function love.filesystem.load(path)
	local func, err

	if line.Type(path) == "FileData" then
		func, err = loadstring(path:getString())
	else
		func, err = vfs.LoadFile("data/love/" .. ENV.filesystem_identity .. "/" .. path, mode)

		if not func then func, err = vfs.LoadFile(path) end
	end

	if func then setfenv(func, getfenv(2)) end

	return func, err
end

function love.filesystem.mkdir(path)
	vfs.CreateDirectoriesFromPath("os:data/love/" .. ENV.filesystem_identity .. "/" .. path)
	return true
end

love.filesystem.createDirectory = love.filesystem.mkdir

function love.filesystem.read(path, size)
	local file = vfs.Open("data/love/" .. ENV.filesystem_identity .. "/" .. path)

	if not file then file = vfs.Open(path) end

	if file then
		local str = file:ReadBytes(size or math.huge)

		if str then return str, #str else return "", 0 end
	end
end

function love.filesystem.remove(path)
	wlog("attempted to remove folder/file " .. path)
end

function love.filesystem.setIdentity(name)
	vfs.CreateDirectoriesFromPath("os:data/love/" .. name .. "/")
	ENV.filesystem_identity = name
	vfs.Mount(love.filesystem.getUserDirectory())
end

function love.filesystem.getIdentity()
	return ENV.filesystem_identity
end

function love.filesystem.write(path, data)
	vfs.Write("data/love/" .. ENV.filesystem_identity .. "/" .. path, data)
	return true
end

function love.filesystem.isFused()
	return false
end

function love.filesystem.mount(from, to)
	if not vfs.IsDirectory("data/love/" .. ENV.filesystem_identity .. "/" .. from) then
		vfs.Mount(from, "data/love/" .. ENV.filesystem_identity .. "/" .. to)
		return vfs.IsDirectory(from)
	else
		vfs.Mount(
			"data/love/" .. ENV.filesystem_identity .. "/" .. from,
			"data/love/" .. ENV.filesystem_identity .. "/" .. to
		)
		return true
	end
end

function love.filesystem.unmount(from)
	vfs.Unmount("data/love/" .. ENV.filesystem_identity .. "/" .. from)
end

function love.filesystem.append(name, data, size) end

function love.filesystem.setSymlinksEnabled() end

do -- File object
	local File = line.TypeTemplate("File")

	function File:close()
		if not self.file then return end

		self.file:Close()
	end

	function File:eof()
		if not self.file then return 0 end

		return self.file:TheEnd() ~= nil
	end

	function File:setBuffer(mode, size)
		if self.file then return false, "file not opened" end

		self.file:setvbuf(mode == "none" and "no" or mode, size)
		self.mode = mode
		self.size = size
	end

	function File:getBuffer()
		return self.mode, self.size
	end

	function File:getMode()
		return self.mode
	end

	function File:getFilename()
		if self.dropped then
			return self.path
		else
			return self.path:match(".+/(.+)")
		end
	end

	function File:getSize()
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
		if not bytes then
			local size = self.file:GetSize()
			local str = self.file:ReadAll()
			return str, size
		end

		local str = self.file:ReadBytes(bytes)
		return str, #str
	end

	function File:write(data, size)
		if line.Type(data) == "string" then
			self.file:WriteBytes(data)
			return true
		elseif line.Type(data) == "Data" then
			line.ErrorNotSupported("Data not supported")
		end
	end

	function File:open(mode)
		if mode == "w" then mode = "write" end

		if mode == "r" then mode = "read" end

		llog("file open ", self.path, " ", mode)
		local path = self.path

		if mode == "w" then
			path = "data/love/" .. ENV.filesystem_identity .. "/" .. self.path
		end

		self.file = assert(vfs.Open(path, mode))
		self.mode = mode
	end

	function love.filesystem.newFile(path, mode)
		local self = line.CreateObject("File")
		self.path = path

		if mode then self:open(mode) end

		return self
	end

	line.RegisterType(File)
end

do -- FileData object
	local FileData = line.TypeTemplate("FileData")
	local ffi = require("ffi")

	function FileData:getPointer()
		local ptr = ffi.new("uint8_t[?]", #self.contents)
		ffi.copy(ptr, self.contents, #self.contents)
		return ptr
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

		local self = line.CreateObject("FileData")
		self.contents = contents
		self.filename, self.ext = name:match("(.+)%.(.+)")
		return self
	end

	line.RegisterType(FileData)
end

event.AddListener("LoveNewIndex", "line_filesystem", function(love, key, val)
	if key == "filedropped" then
		if val then
			event.AddListener("WindowDrop", "line_filedropped", function(wnd, path)
				if love.filedropped then
					local file = love.filesystem.newFile(path)
					file.dropped = true
					love.filedropped(file)
				end
			end)
		else
			event.AddListener("WindowDrop", "line_filedropped")
		end
	end
end)