local vfs2 = (...) or _G.vfs2

function vfs2.Delete(path, ...)
	check(path, "string")
	local abs_path = vfs2.GetAbsolutePath(path, ...)
	
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

function vfs2.Read(path)
	check(path, "string")
	
	local file, err = vfs2.Open(path, "read")
	
	if file then			
		local data = file:ReadAll("*all")
		
		file:Close()
		
		return data
	end
		
	return file, err
end

function vfs2.Write(path, data)
	check(path, "string")
	
	local file, err = vfs2.Open(path, "write")
	
	if file then			
		local data = file:WriteBytes(data)
		
		file:Close()
		
		return data
	end
		
	return file, err
end

function vfs2.CreateFolder(path)
	check(path, "string")
	check_write_path(path, true)
	
	for i, data in ipairs(vfs2.TranslatePath(path, true)) do	
		data.context:PCall("CreateFolder", data.path_info)
	end
end

function vfs2.IsFolder(path)
	for i, data in ipairs(vfs2.TranslatePath(path, true)) do	
		if data.context:PCall("IsFolder", vfs2.GetPathInfo(path, true)) then
			return true
		end
	end
	
	return false
end

function vfs2.IsFile(path)
	for i, data in ipairs(vfs2.TranslatePath(path)) do	
		if data.context:PCall("IsFile", vfs2.GetPathInfo(path)) then
			return true
		end
	end
	
	return false
end

function vfs2.Exists(path)
	return vfs2.IsFolder(path) or vfs2.IsFile(path)
end