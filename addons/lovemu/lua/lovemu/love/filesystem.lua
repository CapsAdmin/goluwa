local love=love
local lovemu=lovemu
local vfs=vfs
love.filesystem={}

local Identity="generic"
function love.filesystem.getAppdataDirectory()
	print("RETURNING APPDATA DIRECTORY")
	return R("%DATA%/lovemu/")
end

function love.filesystem.getLastModified(path)
	print("CHECKING THE LAST MODIFIED DATE OF PATH "..path)
	local attribs = vfs.GetAttributes(path)
	return attribs and attribs.modification or 0
end

function love.filesystem.getSaveDirectory()
	print("RETURNING SAVE DIRECTORY ")
	return R("%DATA%/lovemu/")
end

function love.filesystem.getUserDirectory()
	print("RETURNING USER DIRECTORY ")
	return R("%DATA%/lovemu/")
end

function love.filesystem.getWorkingDirectory()
	print("RETURNING WORKING DIRECTORY ")
	return R("%DATA%/lovemu/")
end

function love.filesystem.exists(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	print("CHECKING IF FILE/FOLDER "..path.." EXISTS  RESULT: "..tostring(vfs.Exists(path)))
	return vfs.Exists(path)
end

function love.filesystem.enumerate(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if path:sub(#path,#path)~="/" or path:sub(#path,#path)~="/" then
		path=path.."/"
	end
	print("ENUMERATING FOLDERS AND FILES ON PATH "..path)
	table.print(vfs.Find(path))
	return vfs.Find(path)
end
love.filesystem.getDirectoryItems=love.filesystem.enumerate


function love.filesystem.init()
end

function love.filesystem.isDirectory(path)
	print("CHECKING IF PATH "..path.." IS A DIRECTORY  RESULT: "..tostring(vfs.IsDir(path)))
	return vfs.IsDir(path)
end

function love.filesystem.isFile(path)
	print("CHECKING IF PATH "..path.." IS FILE")
	return vfs.GetAttributes(path).mode == "file"
end

function love.filesystem.lines(path)
	print("PARSING LINES OF FILE DATA IN PATH "..path)
	local str=vfs.Read(path,"r") or ""
	return str,#str
end

function love.filesystem.load(path ,mode)
	print("FILESYSTEM IS LOADING PATH "..path)
	local func, err = vfs.loadfile(path, mode)
	
	if func then
		setfenv(func, getfenv(2))
	end
	
	return func, err
end

function love.filesystem.mkdir(path) --partial
	print("MAKING FOLDER ON PATH "..path)
	lfs.mkdir(R("%DATA%/lovemu/", path))
end

function love.filesystem.getDirectoryItems(path) --partial
end

function love.filesystem.read(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	return vfs.Read(path) or ""	 
end

function love.filesystem.remove(path)
	print("attempted to remove folder/file "..path)
end

function love.filesystem.setIdentity(name) --partial
	print("SETTING FS IDENTITY TO "..name)
end

function love.filesystem.write(path,data)
	print("WRITING DATA ON "..path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	vfs.Write("lovemu/" .. path,data)
end
print("FILE SYSTEM LOADED!")
