local love=love
local lovemu=lovemu
local vfs=vfs
love.filesystem={}

local Identity="generic"
function love.filesystem.getAppdataDirectory()
	if lovemu.debug then print("RETURNING APPDATA DIRECTORY") end
	return R("%DATA%/lovemu/")
end

function love.filesystem.getLastModified(path)
	local attribs = vfs.GetAttributes(path)
	if lovemu.debug then print("CHECKING THE LAST MODIFIED DATE OF PATH "..path.."  RETURNED: "..tostring(attribs.modification or 0)) end
	return attribs.modification or 0
end

function love.filesystem.getSaveDirectory()
	if lovemu.debug then print("RETURNING SAVE DIRECTORY ") end
	return R("%DATA%/lovemu/")
end

function love.filesystem.getUserDirectory()
	if lovemu.debug then print("RETURNING USER DIRECTORY ") end
	return R("%DATA%/lovemu/")
end

function love.filesystem.getWorkingDirectory()
	if lovemu.debug then print("RETURNING WORKING DIRECTORY ") end
	return R("%DATA%/lovemu/")
end

function love.filesystem.exists(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if lovemu.debug then print("CHECKING IF FILE/FOLDER "..path.." EXISTS  RESULT: "..tostring(vfs.Exists(path))) end
	return vfs.Exists(path)
end

function love.filesystem.enumerate(path)
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if path:sub(#path,#path)~="/" or path:sub(#path,#path)~="/" then
		path=path.."/"
	end
	if lovemu.debug then print("ENUMERATING FOLDERS AND FILES ON PATH "..path) end
	table.print(vfs.Find(path))
	return vfs.Find(path)
end
love.filesystem.getDirectoryItems=love.filesystem.enumerate


function love.filesystem.init()
end

function love.filesystem.isDirectory(path)
	if lovemu.debug then print("CHECKING IF PATH "..path.." IS A DIRECTORY  RESULT: "..tostring(vfs.IsDir(path))) end
	return vfs.IsDir(path)
end

function love.filesystem.isFile(path)
	if lovemu.debug then print("CHECKING IF PATH "..path.." IS FILE  RESULT: " .. tostring(vfs.GetAttributes(path).mode == "file")) end
	return vfs.GetAttributes(path).mode == "file"
end

function love.filesystem.lines(path)
	if lovemu.debug then print("PARSING LINES OF FILE DATA IN PATH "..path) end
	local str=vfs.Read(path,"r") or ""
	return str,#str
end

function love.filesystem.load(path ,mode)
	if lovemu.debug then print("FILESYSTEM IS LOADING PATH "..path) end
	local func, err = vfs.loadfile(path, mode)
	
	if func then
		setfenv(func, getfenv(2))
	end
	
	return func, err
end

function love.filesystem.mkdir(path) --partial
	path = R("%DATA%/lovemu/" .. path)
	if lovemu.debug then print("MAKING FOLDER ON PATH "..path) end
	lfs.mkdir(path)
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
	if lovemu.debug then print("WRITING DATA ON "..path) end
	if path:sub(1,1)=="/" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	vfs.Write("lovemu/" .. path,data)
end

love.filesystem.createDirectory = love.filesystem.mkdir