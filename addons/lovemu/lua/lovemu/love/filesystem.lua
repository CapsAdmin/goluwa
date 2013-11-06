local love=love
local lovemu=lovemu
local vfs=vfs

love.filesystem={}

local Identity="generic"
function love.filesystem.getAppdataDirectory()
	return ""
end

function love.filesystem.getLastModified(path)
	return vfs.GetAttributes(e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"..path).modification or 0
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
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	return vfs.Exists(e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"..path)
end

function love.filesystem.enumerate(path)
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	if path:sub(#path,#path)~="/" or path:sub(#path,#path)~="\\" then
		path=path.."/"
	end
	return vfs.Find(e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"..path)
end
love.filesystem.getDirectoryItems=love.filesystem.enumerate


function love.filesystem.init()
end

function love.filesystem.isDirectory(path)
	local isDir=false

	if string.sub(path,#path,#path)=="\\" or string.sub(path,#path,#path)=="/" then
		isDir=true
	else
		path=string.replace(path,"/","\\")
		folders=string.explode(path,"\\")
		folder_name=folders[#folders]
		local dir=e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"
		for i=1,#folders-1 do
			dir=dir..folders[i].."\\"
		end
		folders=vfs.Find(dir)
		
		if folders then
			local found=false
			for i=1,#folders do
				if folders[i]==folder_name then
					found=true
				end
			end
			if found then
				if vfs.Read(dir.."\\"..folder_name,"r")==false then
					isDir=true
				end
			end 
		end
	end
	
	return isDir
end

function love.filesystem.isFile(path)
	local exists=false
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	exists=vfs.Exists(e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"..path)
	return exists
end

function love.filesystem.lines(path)
	local str=vfs.Read(e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"..path,"r") or ""
	return str,#str
end

function love.filesystem.load(path,mode)
	return vfs.GetFile(path,mode)
end

function love.filesystem.mkdir(path) --partial
end

function love.filesystem.getDirectoryItems(path) --partial
end

function love.filesystem.read(path)
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	return vfs.Read(e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"..path,"r") or ""	 
end

function love.filesystem.remove(path)
	print("attempted to remove folder/file "..path)
end

function love.filesystem.setIdentity(name) --partial
end

function love.filesystem.write(path,data)
	if path:sub(1,1)=="\\" or path:sub(1,1)=="/" then
		path=path:sub(2,#path)
	end
	vfs.Write(e.ABSOLUTE_BASE_FOLDER.."addons\\lovemu\\lovers\\"..lovemu.demoname.."\\"..path,data)
end
