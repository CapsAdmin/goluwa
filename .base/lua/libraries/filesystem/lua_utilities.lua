local vfs = (...) or _G.vfs

vfs.included_files = vfs.included_files or {}

local function store(path)
	local path = vfs.FixPath(path)
	vfs.included_files[path] = fs.getattributes(path)
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
		
		-- prepend "@" in front of the path so it will be treated as a lua file and not a string by lua internally
		-- for nicer error messages and debug
		if event then res = event.Call("PreLoadString", res, full_path) or res end
		local res, err = loadstring(res, "@" .. path) 
		if event and res then res = event.Call("PostLoadString", res, full_path) or res end
				
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

do -- include
	local base = fs.getcd()

	local include_stack = {}
	
	function vfs.PushToIncludeStack(path)
		table.insert(include_stack, path)
	end
	
	function vfs.PopFromIncludeStack()
		local path = include_stack[#include_stack]
		table.remove(include_stack)
	end
	
	function vfs.GetIncludeStack()
		return include_stack
	end
	
	local function not_found(err)
		return 
			err and 
			(
				err:find("No such file or directory", nil, true) or 
				err:find("Invalid argument", nil, true)
			)
	end
	
	function vfs.include(source, ...)
		
		local dir, file = source:match("(.+/)(.+)")
		
		if not dir then
			dir = ""
			file = source
		end
		
		if vfs and file == "*" then
			local previous_dir = include_stack[#include_stack]		
			local original_dir = dir
			
			if previous_dir then
				dir = previous_dir .. dir
			end
			
			if not vfs.IsDir(dir) then
				dir = original_dir
			end			
						
			for script in vfs.Iterate(dir, nil, true) do
				if script:find("%.lua") then
					local func, err, full_path = vfs.loadfile(script)
					
					if func then
						vfs.PushToIncludeStack(dir)

						_G.FILE_PATH = full_path
						_G.FILE_NAME = full_path:match(".*/(.+)%.") or full_path
						_G.FILE_EXTENSION = full_path:match(".*/.+%.(.+)")
						local ok, err = xpcall(func, system and system.OnError or logn, ...)
						_G.FILE_NAME = nil
						_G.FILE_PATH = nil
						_G.FILE_EXTENSION = nil
						
						if not ok then logn(err) end
						
						vfs.PopFromIncludeStack()
					end
					
					if not func then
						logn(err)
					end
				end
			end
			
			return
		end
		
		-- try direct first
		local loaded_path = source
			
		local previous_dir = include_stack[#include_stack]		
					
		if previous_dir then
			dir = previous_dir .. dir
		end
		
		-- try first with the last directory
		-- once with lua prepended
		local path = dir .. file
		local full_path
		func, err, full_path = vfs.loadfile(path)

		if not_found(err) then
			path = dir .. file
			func, err, full_path = vfs.loadfile(path)
			
			-- and without the last directory
			-- once with lua prepended
			if not_found(err) then
				path = source
				func, err, full_path = vfs.loadfile(path)	
				
				-- try the absolute path given
				if not_found(err) then
					path = source
					func, err, full_path = vfs.loadfile(loaded_path)
				else
					path = source
				end
			end
		else
			path = dir .. file
		end
		
		if func then
			dir = path:match("(.+/)(.+)")
			vfs.PushToIncludeStack(dir)
			
			
			_G.FILE_PATH = full_path
			_G.FILE_NAME = full_path:match(".*/(.+)%.") or full_path
			_G.FILE_EXTENSION = full_path:match(".*/.+%.(.+)")
			local res = {xpcall(func, system and system.OnError or logn, ...)}
			_G.FILE_PATH = nil
			_G.FILE_NAME = nil
			_G.FILE_EXTENSION = nil
			
			if not res[1] then
				logn(res[2])
			end
			
			vfs.PopFromIncludeStack()
						 
			return select(2, unpack(res))
		end		
		
		err = err or "no error"
		
		logn(source:sub(1) .. " " .. err)
		
		debug.openscript("lua/" .. path, err:match(":(%d+)"))
						
		return false, err
	end
end

include = vfs.include

-- although vfs will add a loader for each mount, the module folder has to be an exception for modules only
-- this loader should support more ways of loading than just adding ".lua"
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

function vfs.AddModuleDirectory(dir)		
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
end	