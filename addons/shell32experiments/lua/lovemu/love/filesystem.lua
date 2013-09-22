local love=love
local vfs=vfs

love.filesystem={}

love.filesystem.enumerate=vfs.Find
love.filesystem.exists=vfs.Find

local Identity="generic"
function love.filesystem.getAppdataDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."data"
end

function love.filesystem.getLastModified(path)
	return vfs.GetAttributes(path).modification or 0
end

function love.filesystem.getSaveDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."data/saves/"
end

function love.filesystem.getUserDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."data/saves/"
end

function love.filesystem.getWorkingDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."data/saves/"
end

function love.filesystem.init()
end

function love.filesystem.isDirectory(path)
	return vfs.Exists(path)
end

function love.filesystem.isFile(path)
	return vfs.Exists(path)
end

function love.filesystem.lines(path)
	local str=vfs.Read("r") or ""
	return str,#str
end

function love.filesystem.load(path,mode)
	return vfs.GetFile(path,mode)
end

function love.filesystem.mkdir(path)
	lfs.mkdir(path)
end

function love.filesystem.read(path)
	local str=vfs.Read("r") or ""
	return str,#str
end

function love.filesystem.remove(path)
	print("attempted to remove folder/file "..path)
end

function love.filesystem.setIdentity(name)
	if not type(name)=="string" then
		Identity=""
	else
		Identity=name
	end
end
