function vfs.loadfile(path)
	check(path, "string")
	
	local path = vfs.GetAbsolutePath(path)
	
	if path then
		local ok, err = loadfile(path)
		return ok, err, path
	end
	
	return false, "No such file or directory"
end

function vfs.dofile(path, ...)
	check(path, "string")
	
	local func, err = vfs.loadfile(path)
	
	if func then
		local ok, err = xpcall(func, system.OnError, ...)
		return ok, err, path
	end
	
	return func, err
end

-- although vfs will add a loader for each mount, the module folder has to be an exception for modules only
-- this loader should support more ways of loading than just adding ".lua"
function vfs.AddModuleDirectory(dir)
	table.insert(package.loaders, function(path)
		return vfs.loadfile(dir .. path)
	end)
	
	table.insert(package.loaders, function(path)
		return vfs.loadfile(dir .. path .. ".lua")
	end)
		
	table.insert(package.loaders, function(path)
		return vfs.loadfile(dir .. path .. "/init.lua")
	end)
	
	-- again but with . replaced with /	
	table.insert(package.loaders, function(path)
		path = path:gsub("\\", "/"):gsub("(%a)%.(%a)", "%1/%2")
		return vfs.loadfile(dir .. path .. ".lua")
	end)
		
	table.insert(package.loaders, function(path)
		path = path:gsub("\\", "/"):gsub("(%a)%.(%a)", "%1/%2")
		return vfs.loadfile(dir .. path .. "/init.lua")
	end)
	
	table.insert(package.loaders, function(path)
		local c_name = "luaopen_" .. path:gsub("^.*%-", "", 1):gsub("%.", "_")
		path = R(dir .. "bin/" .. ffi.os:lower() .. "/" .. ffi.arch:lower() .. "/" .. path .. (jit.os == "Windows" and ".dll" or ".so"))
		return package.loadlib(path, c_name)
	end)
end	