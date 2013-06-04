local vfs = {}

local silence

local function warning(...)
	if silence then return end
	printf("[vfs error] %s", ...)
end

function vfs.Silence(b)
	silence = b
end

local function fix_path(path)
	return path:gsub("\\", "/"):lower()
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
	
	return false, "was not found in any mounted folders"
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
	
	local err = ("file not found %q"):format(path)
	
	warning(err)
	
	return false, err
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
	end
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
		for i in lfs.dir(v .. dir) do
			if i ~= "." and i ~= ".." then
				if full_path then
					i = v .. dir .. "/" .. i
				end
				unique[i] = true
			end
		end
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

function vfs.loadfile(path, ...)
	check(path, "string")
	
	local script, err = vfs.Read(path, ...)
	
	if script then
		return loadstring(script)
	end
	
	return script, err
end

function vfs.dofile(path, ...)
	check(path, "string")
	
	local func, err = vfs.loadfile(path)
	
	if func then
		return pcall(func, ...)
	end
	
	return func, err
end

return vfs
