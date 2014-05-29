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

function vfs.Read(path, mode, ...)
	check(path, "string")
	
	mode = mode or "r"
	
	if mode == "b" then
		mode = "rb"
	end
	
	local file, err = vfs.Open(path, mode, ...)
	
	if file then			
		local data = file:read("*all")
		file:close()
		
		return data
	end
		
	return file, err
end

function vfs.Write(path, data, mode)
	check(path, "string")
	
	-- if it's a relative path default to the data folder
	if not vfs.IsPathAbsolute(path) and not path:find("%%.-%%") and not path:find("%$%(.-%)") then
		path = data_prefix .. path
	end
			
	if mode and not mode:find("w", nil, true) then
		mode = "w" .. mode
	else
		mode = "w"
	end
	
	path = vfs.ParseVariables(path)
	
	local file, err = vfs.Open(path, mode)
		
	if err and err:find("No such file or directory") then
		vfs.CreateFoldersFromPath(path)		
		return vfs.Write(path, data, mode)
	end
		
	if file then		
		local data = file:write(data)
		file:close()
		
		return true
	end
	
	return false, err
end

function vfs.Exists(path, ...)
	check(path, "string")
	local file = vfs.Open(path, ...)

	return file ~= false
end

function vfs.IsDir(path, ...)
	local attributes = vfs.GetAttributes(path, ...)
	return attributes and attributes.mode == "directory"
end

function vfs.GetAttributes(path, ...)
	check(path, "string")
	path = vfs.ParseVariables(path)
	
	if path:sub(-1) == "/" then
		-- lfs doesn't like / at the end of folders
		path = path:sub(0, -2)
	end
	
	if vfs.debug then
		logf("[VFS] requesting attributes on %q\n", path)
	end
		
	for k, v in ipairs(vfs.paths) do
		local info = v.callback("attributes", _path, ...)
		local _path = v.root .. "/" .. path
			
		if info then
			if vfs.debug then
				logf("[VFS] attributes found on [%s]%q\n", v.id, _path)
			end
		
			return info
		end
	end

	local info = lfs.attributes(path, ...)
	if info then
		
		if vfs.debug then
			logf("[VFS] attributes found on %q\n", path)
		end
	
		return info
	end
	
	return {}
end