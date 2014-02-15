local vfs = _G.vfs or {}

vfs.use_appdata = false

vfs.vars = 
{
	DATA = e.USERDATA_FOLDER,
	ROOT = e.ROOT_FOLDER,
	BASE = e.BASE_FOLDER,
	BIN = lfs.currentdir,
}

if vfs.use_appdata then
	if WINDOWS then
		vars.DATA = "%%APPDATA%%/.asdfml"
	end

	if LINUX then
		vars.DATA =  "%%HOME%%/.asdfml"
	end 
end

vfs.delimiter = WINDOWS and "\\" or "/"

vfs.paths = {}

local function getenv(key)
	local val = vfs.vars[key]
	
	if type(val) == "function" then
		val = val()
	end
	
	return val or os.getenv(key)
end

local function has_prefix(path)
	return path:find("%%.-%%") or path:find("%$%(.-%)")
end

local function is_absolute(path)
	if LINUX then
		return path:sub(1,1) == "/"
	end
	
	if WINDOWS then
		return path:sub(1, 2):find("%a:") ~= nil
	end
end

local data_prefix = "%DATA%"
local data_prefix_pattern = data_prefix:gsub("(%p)", "%%%1")


local silence

local function warning(...)
	if silence or not logf then return end
	logf("[vfs error] %s", ...)
end

function vfs.Silence(b)
	silence = b
end

do -- path utilities
	function vfs.ParseVariables(path)
		-- windows
		path = path:gsub("%%(.-)%%", getenv)
		path = path:gsub("%%", "")		
		path = path:gsub("%$%((.-)%)", getenv)
		
		-- linux
		path = path:gsub("%$", "")
		path = path:gsub("%(", "")
		path = path:gsub("%)", "")
			
		return vfs.FixPath(path)
	end

	function vfs.FixPath(path)
		return (path:gsub("\\", "/"):gsub("(/+)", "/"))
	end
		
	function vfs.CreateFoldersFromPath(path)
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
	
	function vfs.GetAbsolutePath(path, ...)
		check(path, "string")

		path = vfs.ParseVariables(path)
		
		local is_folder = path:sub(-1) == "/"
		
		if is_folder then
			path = path .. "NUL"
		end
		
		for k, v in ipairs(vfs.paths) do
			local file, err = io.open(v .. "/" .. path, ...)
			
			if file then
				file:close()
				
				if is_folder then
					path = path:sub(0,-4)
				end
				
				path = v .. "/" .. path
				break
			end
		end
			
		return vfs.FixPath(path)
	end
end

do -- mounting
	function vfs.Mount(path)
		check(path, "string")
		path = vfs.ParseVariables(path)
			
		
		if is_absolute(path) and path:sub(-1) == "/" then
			path = path:sub(0, -2)
		end
			
		vfs.Unmount(path)

		if lfs.attributes(path, "mode") ~= "directory" then
			warning(string.format("Mount path %q does not exist (yet?)", path))
		end
			
		table.insert(vfs.paths, path)
		
		--local search_path = ";" .. path .. (WINDOWS and "?.dll" or "?")
		--package.cpath = package.cpath .. search_path
	end
		
		
	function vfs.Unmount(path)
		check(path, "string")
		path = vfs.ParseVariables(path)
		
		for k,v in pairs(vfs.paths) do
			if v == path then
				table.remove(vfs.paths, k)
			end
		end
		
		--local search_path = ";" .. path .. (WINDOWS and "?.dll" or "?")
		--local startpos, endpos = package.cpath:find(search_path, nil, true)
		--if startpos and endpos then
		--	package.cpath = package.cpath:sub(0, startpos-1) .. package.cpath:sub(endpos+1)
		--end
	end

	function vfs.GetMounts()
		return vfs.paths
	end
end

do -- generic

	function vfs.GetFile(path, mode, ...)
		check(path, "string")
		path = vfs.ParseVariables(path)
				
		local file, err = io.open(path, mode, ...)

		if not file then
			for k, v in ipairs(vfs.paths) do	
				file, err = io.open(v .. "/" .. path, mode, ...)
				
				if err then
					warning(err)
				end
				
				if file then
					path = v .. "/" .. path
					break
				end
			end
		end
		
		if file then
			if vfs.debug then
				logf("[VFS] file access mode %s %q", mode, path)
			end
			
			return file, err
		end
		
		return false, err or "No such file or directory"
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

	function vfs.Read(path, mode, ...)
		check(path, "string")
		
		mode = mode or "r"
		
		if mode == "b" then
			mode = "rb"
		end
		
		local file, err = vfs.GetFile(path, mode, ...)
		
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
		if not is_absolute(path) and not has_prefix(path) then
			path = data_prefix .. path
		end
				
		if mode and not mode:find("w", nil, true) then
			mode = "w" .. mode
		else
			mode = "w"
		end
		
		path = vfs.ParseVariables(path)
		
		local file, err = vfs.GetFile(path, mode)
			
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
		local file = vfs.GetFile(path, ...)

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
			
		for k, v in ipairs(vfs.paths) do
			local info = lfs.attributes(v .. "/" .. path, ...)
			if info then
				return info
			end
		end

		local info = lfs.attributes(path, ...)
		if info then
			return info
		end
		
		return {}
	end
end

do -- file finding

	function vfs.Find(path, invert, full_path, start, plain, dont_sort)
		check(path, "string")
		path = vfs.ParseVariables(path)
		
		-- if the path ends just with an "/"
		-- make it behave like /*
		if path:sub(-1) == "/" then
			path = path .. "."
		end
		
		local dir, pattern = path:match("(.+)/(.+)")
		
		-- if there is no pattern after "/"
		-- the path itself becomes the pattern and 
		-- plain search is used
		if not dir then
			pattern = path
			dir = ""
			plain = true
		end
		
		if path == "." or path == "/." or path == "" then
			pattern = "."
			plain = false
			dir = ""
		end
		
		local unique = {}
		
		if is_absolute(path) then
			pcall(function()
				for file_name in lfs.dir(dir) do
					if file_name ~= "." and file_name ~= ".." then
						if full_path then
							file_name = dir .. "/" .. file_name
						end
						unique[file_name] = true
					end
				end
			end)
		else
			for _, full_dir in ipairs(vfs.paths) do
				-- fix me!! 
				-- on linux, an invalid path will error
							
				pcall(function()
				for file_name in lfs.dir(full_dir .. "/" .. dir) do
					if file_name ~= "." and file_name ~= ".." then
						if full_path then
							file_name = full_dir .. "/" .. dir .. "/" .. file_name
						end
						unique[file_name] = true
					end
				end
				end)
			end
		end
				
		if not next(unique) then
			return unique
		end	
		
		local list = {}
		
		for path in pairs(unique) do
			local found = path:lower():find(pattern, start, plain)
			
			if invert then
				found = not found
			end
			
			if found then
				list[#list + 1] = vfs.FixPath(path)
			end
		end

		if not dont_sort then
			table.sort(list)
		end

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

	function vfs.Traverse(path, callback, level)
		level = level or 1

		local attributes = vfs.GetAttributes(path)

		if attributes then
			callback(path, attributes, level)

			if attributes.mode == "directory" then
				for child in vfs.Iterate(path) do
					if child ~= "." and child ~= ".." then
						vfs.Traverse(path .. "/" .. child, callback, level + 1)
					end
				end
			end
		end
	end

	do 
		local out
		local function search(path, ext)		
			for _,v in pairs(vfs.Find(path)) do
				if ext and v:sub(-#ext) == ext then
					table.insert(out, path .. v)
				elseif not ext then
					table.insert(out, path .. v)
				end
				
				search(path .. v .. "/", ext)
			end
		end

		function vfs.Search(path, ext)
			out = {}
			search(path, ext)
			return out
		end
	end
end

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
		local ok, err = xpcall(func, mmyy.OnError, ...)
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
end	

do -- async reading
	vfs.async_readers = {
		file = function(path, callback, mbps)
			local file = vfs.GetFile(path, "rb")
			if file then
				local content = {}
				mbps = mbps / 2
				timer.Thinker(function()
					-- in case mbps is higher than the file size
					for i = 1, 2 do
						local str = file:read(1048576 * mbps) -- 5 mb per tick
						if str then
							content[#content + 1] = str
						else
							callback(table.concat(content))
							return false
						end
					end
				end, 1, true, true)
				return true				
			end
		end,
		luasocket = function(path, callback, mbps)	
			if luasocket.Download(path, callback) then
				return true
			end
		end,
	}

	function vfs.ReadAsync(path, callback, mbps)
		check(path, "string")
		check(callback, "function")
		check(mbps, "nil", "number")
		mbps = mbps or 1
		
		for name, func in pairs(vfs.async_readers) do
			if func(path, callback, mbps) then
				return true
			end
		end 
		
		return false
	end
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
			timer.Delay(0, function()
				dofile(target)
			end)
		end)
	end

	function vfs.MonitorEverything(b)
		if not b then
			timer.Remove("vfs_monitor_everything")
			return
		end

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

		scan(e.ROOT_FOLDER)

		timer.Create("vfs_monitor_everything", 0.5, 0, function()
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
