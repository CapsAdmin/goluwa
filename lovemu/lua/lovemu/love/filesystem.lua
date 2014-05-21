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
	path = R("%DATA%/lovemu/" .. path)
	lfs.mkdir(path)
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