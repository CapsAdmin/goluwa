local love=love
local lovemu=lovemu
local vfs=vfs

love.filesystem={}

love.filesystem.enumerate=vfs.Find
love.filesystem.exists=vfs.Find

local Identity="generic"
function love.filesystem.getAppdataDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."/"
end

function love.filesystem.getLastModified(path)
	return vfs.GetAttributes(path).modification or 0
end

function love.filesystem.getSaveDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."save/"
end

function love.filesystem.getUserDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."save/"
end

function love.filesystem.getWorkingDirectory()
	return e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."/"
end

function love.filesystem.enumerate(path)
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if path:sub(#path,#path)~="/" or path:sub(#path,#path)~="\\" then
		path=path.."/"
	end
	if not string.find(path,e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/") then
		path=e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."/"..path
	end
	return vfs.Find(path)
end


function love.filesystem.init()
end

function love.filesystem.isDirectory(path)
	return false
end

function love.filesystem.isFile(path)
	local exists=false
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if not string.find(path,e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/") then
		exists=vfs.Exists(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."/"..path)
	else
		exists=vfs.Exists(path)
	end
	return exists
end

function love.filesystem.lines(path)
	local str=vfs.Read("r") or ""
	return str,#str
end

function love.filesystem.load(path,mode)
	return vfs.GetFile(path,mode)
end

function love.filesystem.mkdir(path)
end

function love.filesystem.read(path)
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	local str=""
	if not string.find(path,e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/") then
		str=vfs.Read(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."/"..path,"r")
	else
		str=vfs.Read(path,"r")
	end
	return str
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

function love.filesystem.write(path,data)
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if not string.find(path,e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/") then
		vfs.Write(e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/data/"..Identity.."/"..path,data)
	else
		vfs.Write(path,data)
	end
end
