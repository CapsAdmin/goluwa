local vfs = _G.vfs or {}

local silence

local function warning(...)
	if silence then return end
	logf("[vfs error] %s", ...)
end

function vfs.Silence(b)
	silence = b
end

local function fix_path(path)
	if WINDOWS then
		path = path:gsub("%%(.-)%%", os.getenv)
		path = path:gsub("%%", "")		
	end
	
	if LINUX then
		path = path:gsub("%$%((.-)%)", os.getenv)
		
		-- uh
		path = path:gsub("%$", "")
		path = path:gsub("%(", "")
		path = path:gsub("%)", "")
	end
		
	return path:gsub("\\", "/")
end

vfs.paths = {}

function vfs.GetMounts()
	return vfs.paths
end

local loaders = {}

function vfs.Mount(path)
	check(path, "string")
	path = fix_path(path)
		
	vfs.Unmount(path)
		
	table.insert(vfs.paths, path)
	
	local function loader(path)
		return vfs.loadfile(path)
	end
	
	loaders[path] = loader
--	table.insert(package.loaders, loader)
end

function vfs.Unmount(path)
	check(path, "string")
	path = fix_path(path)
	
	for k,v in pairs(vfs.paths) do
		if v == path then
			table.remove(vfs.paths, k)
		end
	end
	
	for k,v in pairs(package.loaders) do
		if v == loaders[path] then
			table.remove(package.loaders, k)
		end
	end
end

function vfs.GetAttributes(path, ...)
	check(path, "string")
	path = fix_path(path)
	
	for k, v in ipairs(vfs.paths) do
		return lfs.attributes(v .. "/" .. path, ...)
	end
end

function vfs.GetAbsolutePath(path, ...)
	check(path, "string")
	path = fix_path(path)
	
	for k, v in ipairs(vfs.paths) do
		local file, err = io.open(v .. "/" .. path, ...)
		
		if file then
			file:close()
			return v .. "/" .. path
		end
	end
	
	return path
end

function vfs.GetFile(path, ...)
	check(path, "string")
	path = fix_path(path)
	
	for k, v in ipairs(vfs.paths) do	
		local file, err = io.open(v .. "/" .. path, ...)
		
		if err then
			warning(err)
		end
		
		if file then
			return file, err
		end
	end
	
	local file, err = io.open(path, ...)
	
	if err then
		warning(err)
	end
	
	if file then
		return file, err
	end
	
	return false, "No such file or directory"
end

function vfs.Read(path, ...)
	check(path, "string")
	
	local file, err = vfs.GetFile(path, ...)
	
	if file then
		local data = file:read("*a")
		file:close()
		return data
	end
	
	return file, err
end

function vfs.Exists(path, ...)
	check(path, "string")
	local file = vfs.GetFile(path, ...)

	return file ~= nil
end

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

local function create_folders_from_path(path)
	local dirs = {}
	
	for i = 0, 10 do
		local folder = utilities.GetParentFolder(path, i)
		if folder ~= "" then 
			table.insert(dirs, folder)
		else
			break
		end
	end
	
	for key, dir in ipairs(dirs) do
		lfs.mkdir(dir)
	end
end

function vfs.Write(path, data, mode)
	check(path, "string")
	path = fix_path(path)
	
	if mode and not mode:find("w", nil, true) then
		mode = mode .. "w"
	else
		mode = "w"
	end
	
	local file, err = vfs.GetFile(path, mode)
		
	if err and err:find("No such file or directory") then
		create_folders_from_path(path)
		return vfs.Write(path, data, mode)
	end
		
	if file then
		local data = file:write(data)
		file:close()
		
		return true
	end
	
	return false, err
end

function vfs.Find(path, invert, full_path, start, plain)
	check(path, "string")
	path = fix_path(path)
	
	if path:sub(-1) == "/" then
		path = path .. "."
	end
		
	local unique = {}
	local dir, pattern = path:match("(.+)/(.+)")
	
	if not dir then
		pattern = path
		dir = ""
	end

	for k, v in ipairs(vfs.paths) do
		-- fix me!! 
		-- on linux, an invalid path will error
		pcall(function()
		for i in lfs.dir(v .. "/" .. dir) do
			if i ~= "." and i ~= ".." then
				if full_path then
					i = v .. "/" .. dir .. "/" .. i
				end
				unique[i] = true
			end
		end
		end)
	end
	
	local list = {}
	
	for k, v in pairs(unique) do
		local found = k:lower():find(pattern, start, plain)
		
		if invert then
			found = not found
		end
		
		if found then
			list[#list + 1] = k
		end
	end

	table.sort(list) 

	return list
end

function vfs.Iterate(path, ...)
	check(path, "string")
	
	local dir = path:match("(.+/)") or ""
	local tbl = vfs.Find(path, ...)
	local i = 1
	
	return function()
		local val = tbl[i]
		
		i = i + 1
		
		if val then 
			return val, dir .. val
		end
	end
end

function vfs.loadfile(path)
	check(path, "string")
	
	local path = vfs.GetAbsolutePath(path)
	
	if path then
		return loadfile(path)
	end
	
	return false, "No such file or directory"
end

function vfs.dofile(path, ...)
	check(path, "string")
	
	local func, err = vfs.loadfile(path)
	
	if func then
		return pcall(func, ...)
	end
	
	return func, err
end

do -- file monitoring

	function vfs.MonitorFile(file_path, callback)
		check(file_path, "string")
		check(callback, "function")

		local last = vfs.GetAttributes(file_path)
		
		if last then
			last = last.modification
			timer.Create(file_path, 0, 0, function()
				local time = vfs.GetAttributes(file_path)
				if time then
					time = time.modification
					if last ~= time then
						logf("[vfs monitor] %s changed!", file_path)
						last = time
						return callback(file_path)
					end
				else
					logf("[vfs monitor] %s was removed", file_path)
					timer.Remove(file_path)
				end
			end)
		else
			logf("[vfs monitor] %s was not found", file_path)
		end
	end

	function vfs.MonitorFileInclude(source, target)
		source = source or utilities.GetCurrentPath(3)
		target = target or source
		
		vfs.MonitorFile(source, function()
			timer.Simple(0, function()
				dofile(target)
			end)
		end)
	end

	function vfs.MonitorEverything(b)
		if not b then
			timer.Remove("vfs_monitor_everything")
			return
		end

		local full_path = lfs.currentdir():gsub("\\", "/") .. "/" .. e.BASE_FOLDER
		local lua_files = {}

		local function scan(dir)
			-- fix me!! 
			-- on linux, an invalid path will error
			pcall(function()
			for path in lfs.dir(dir) do
				if path ~= "." and path ~= ".." then
					if utilities.GetExtensionFromPath(path) ~= "lua" then	
						scan(dir .. path .. "/")
					else
						table.insert(lua_files, {path = dir .. path})
					end
				end
			end
			end)
		end

		scan(full_path .. "lua/")
		scan(full_path .. "addons/")

		timer.Create("vfs_monitor_everything", 0.1, 0, function()
			for _, data in pairs(lua_files) do
				local info = lfs.attributes(data.path)
				
				if info then
					if not data.modification then
						data.modification = info.modification
					else 
						if data.modification ~= info.modification then
							logn("reloading ", utilities.GetFileNameFromPath(data.path))
							include(data.path) 
							data.modification = info.modification
						end
					end			
				end
			end
		end)
	end

end

return vfs
