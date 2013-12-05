local love=love
local lovemu=lovemu
local vfs=vfs

love.filesystem={}

local Identity="generic"
function love.filesystem.getAppdataDirectory()
	return ""
end

function love.filesystem.getLastModified(path)
	local attribs = vfs.GetAttributes(path)
	return attribs and attribs.modification or 0
end

function love.filesystem.getSaveDirectory()
	return ""
end

function love.filesystem.getUserDirectory()
	return ""
end

function love.filesystem.getWorkingDirectory()
	return ""
end

function love.filesystem.exists(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	return vfs.Exists(path)
end

function love.filesystem.enumerate(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if path:sub(#path,#path)~="/" or path:sub(#path,#path)~="/" then
		path=path.."/"
	end
	
	return vfs.Find(path)
end
love.filesystem.getDirectoryItems=love.filesystem.enumerate


function love.filesystem.init()
end

function love.filesystem.isDirectory(path)
	return vfs.IsDir(path)
end

function love.filesystem.isFile(path)
	return vfs.GetAttributes(path).mode == "file"
end

function love.filesystem.lines(path)
	local str=vfs.Read(path,"r") or ""
	return str,#str
end

function love.filesystem.load(path ,mode)
	local func, err = vfs.loadfile(path, mode)
	
	if func then
		setfenv(func, getfenv(2))
	end
	
	return func, err
end

function love.filesystem.mkdir(path) --partial
end

function love.filesystem.getDirectoryItems(path) --partial
end

function love.filesystem.read(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	return vfs.Read(path,"r") or ""	 
end

function love.filesystem.remove(path)
	print("attempted to remove folder/file "..path)
end

function love.filesystem.setIdentity(name) --partial
end

function love.filesystem.write(path,data)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	vfs.Write(path,data)
end
