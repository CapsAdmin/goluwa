local vfs = (...) or _G.vfs

vfs.included_files = vfs.included_files or {}

local function store(path)
	local path = vfs.FixPath(path:lower())
	vfs.included_files[path] = lfs.attributes(path)
end

function loadfile(path, ...)		
	store(path)
	return _OLD_G.loadfile(path, ...)
end

function dofile(path, ...)
	store(path)		
	return _OLD_G.dofile(path, ...)
end
	
function vfs.GetLoadedLuaFiles()
	return vfs.included_files
end


function vfs.loadfile(path)
	check(path, "string")
	
	local full_path = vfs.GetAbsolutePath(path)
	
	if full_path then
		store(full_path)
		
		local res, err = vfs.Read(full_path)
		if not res then 
			return res, err, full_path 
		end
		
		local res, err = loadstring(res, "@" .. path) -- put @ in front of the path so it will be treated as such intenrally
		return res, err, full_path
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
	do -- full path
		table.insert(package.loaders, function(path)
			return vfs.loadfile(path)
		end)
		
		table.insert(package.loaders, function(path)
			return vfs.loadfile(path .. ".lua")
		end)
		
		table.insert(package.loaders, function(path)
			path = path:gsub("(.)%.(.)", "%1/%2")
			return vfs.loadfile(path .. ".lua")
		end)
		
		table.insert(package.loaders, function(path)
			path = path:gsub("(.+/)(.+)", function(a, str) return a .. str:gsub("(.)%.(.)", "%1/%2") end)
			return vfs.loadfile(path .. ".lua")
		end)
	end
		
	do -- relative path
		table.insert(package.loaders, function(path)
			return vfs.loadfile(dir .. path)
		end)
		
		table.insert(package.loaders, function(path)
			return vfs.loadfile(dir .. path .. ".lua")
		end)
					
		table.insert(package.loaders, function(path)
			path = path:gsub("(.)%.(.)", "%1/%2")
			return vfs.loadfile(dir .. path .. ".lua")
		end)
	end
		
	table.insert(package.loaders, function(path)
		return vfs.loadfile(dir .. path .. "/init.lua")
	end)
	
	table.insert(package.loaders, function(path)
		return vfs.loadfile(dir .. path .. "/"..path..".lua")
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
		path = path:gsub("\\", "/"):gsub("(%a)%.(%a)", "%1/%2")
		return vfs.loadfile(dir .. path .. "/" .. path ..  ".lua")
	end)
	
	table.insert(package.loaders, function(path)
		local c_name = "luaopen_" .. path:gsub("^.*%-", "", 1):gsub("%.", "_")
		path = R(dir .. "bin/" .. jit.os:lower() .. "/" .. jit.arch:lower() .. "/" .. path .. (jit.os == "Windows" and ".dll" or ".so")) or path
		return package.loadlib(path, c_name)
	end)
end	