local vfs = (...) or _G.vfs

function vfs.Delete(path, ...)
	check(path, "string")
	local abs_path = vfs.GetAbsolutePath(path, ...)
	
	if abs_path then
		local ok, err = os.remove(abs_path)
		
		if not ok and err then
			warning(err)
		end
	end
	
	local err = ("No such file or directory %q"):format(path)
	
	warning(err)
	
	return false, "No such file or directory"
end

local function add_helper(name, func, mode)
	vfs[name] = function(path, ...)
		check(path, "string")
		
		local file, err = vfs.Open(path, mode)
		
		if file then			
			local data = {file[func](file, ...)}
			
			file:Close()
			
			return unpack(data)
		end
			
		return file, err
	end
end

add_helper("Read", "ReadAll", "read")
add_helper("Write", "WriteBytes", "write")
add_helper("GetLastModified", "GetLastModified", "read")
add_helper("GetLastAccessed", "GetLastAccessed", "read")

function vfs.CreateFolder(path)
	check(path, "string")
	check_write_path(path, true)
	
	for i, data in ipairs(vfs.TranslatePath(path, true)) do	
		data.context:PCall("CreateFolder", data.path_info)
	end
end

function vfs.IsFolder(path)
	for i, data in ipairs(vfs.TranslatePath(path, true)) do
		if data.context:PCall("IsFolder", data.path_info) then
			return true
		end
	end
	
	return false
end

function vfs.IsFile(path)
	for i, data in ipairs(vfs.TranslatePath(path)) do	
		if data.context:PCall("IsFile", data.path_info) then
			return true
		end
	end
	
	return false
end

function vfs.Exists(path)
	return vfs.IsFolder(path) or vfs.IsFile(path)
end