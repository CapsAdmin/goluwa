local vfs = _G.vfs or {}

vfs.use_appdata = false
vfs.paths = vfs.paths or {}

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
local function logf(fmt, ...)
	if silence then return end
	if _G.logf then _G.logf(fmt, ...) return end
	print(fmt:format(...))
end

local function warning(...)
	if silence then return end
	logf("[vfs error] %s\n", ...)
end

function vfs.Silence(b)
	local old = silence
	silence = b
	return old == nil and b or old
end

do -- path utilities
	function vfs.ParseVariables(path)
		-- windows
		path = path:gsub("%%(.-)%%", getenv)
		path = path:gsub("%%", "")		
		path = path:gsub("%$%((.-)%)", getenv)
		
		-- linux
		path = path:gsub("%$%((.-)%)", "%1")
			
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
		
		local is_folder = vfs.IsDir(path)
		
		for k, v in ipairs(vfs.paths) do
		
			local file, err
			
			if type(v) == "table" then
				local handle, reason = v.callback("file", "open", v.root .. "/" .. path, ...)
				
				if handle then
					file = vfs.CreateDummyFile(handle, v)
				else	
					err = reason
				end
			else
				if path:sub(-1) == "/" then path = path:sub(0, -2) end
				
				local info = lfs.attributes(v .. "/" .. path)
				
				if info then
					path = v .. "/" .. path
					break
				end
			end
		end
			
		return vfs.FixPath(path)
	end
end

do -- mounting
	function vfs.Mount(path)
		
		if type(path) == "string" then
		
			path = vfs.ParseVariables(path)			
			
			if not vfs.IsDir(path) and vfs.Exists(path) and event.Call("VFSMountFile", path, true, path:match(".+%.(.+)")) then
				return
			end
			
			if is_absolute(path) and path:sub(-1) == "/" then
				path = path:sub(0, -2)
			end
				
			vfs.Unmount(path)

			if lfs.attributes(path, "mode") ~= "directory" then
				warning(string.format("Mount path %q does not exist (yet?)", path))
			end
			
			table.insert(vfs.paths, path)
		else
			check(path.id, "string")
			check(path.callback, "function")
			
			vfs.Unmount(path)
			
			table.insert(vfs.paths, path)
		end
		
		--local search_path = ";" .. path .. (WINDOWS and "?.dll" or "?")
		--package.cpath = package.cpath .. search_path
	end
		
		
	function vfs.Unmount(path)
		
		if type(path) == "string" then
			path = vfs.ParseVariables(path)
			
			if not vfs.IsDir(path) and vfs.Exists(path) and event.Call("VFSMountFile", path, false) then
				return
			end
			
			for k,v in pairs(vfs.paths) do
				if v == path then
					table.remove(vfs.paths, k)
				end
			end
		else
			check(path.id, "string")

			for k,v in pairs(vfs.paths) do
				if type(v) == "table" and v.id == path.id then
					table.remove(vfs.paths, k)
				end
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

do -- WIP	
	local META = {}
	META.__index = META

	function META:__tostring()
		return ("file (%p)"):format(self)
	end

	function META:write(...)
		local str = ""

		for i = 1, select("#", ...) do
			str = str .. tostring(select(i, ...))
		end

		return self.env.callback("file", "write", self.udata, str)
	end

	local function read(self, format)
		format = format or "*line"

		if type(format) == "number" then	
			return self.env.callback("file", "read", self.udata, "bytes", format)
		elseif format:sub(1, 2) == "*a" then
			return self.env.callback("file", "read", self.udata, "all")
		elseif format:sub(1, 2) == "*l" then
			return self.env.callback("file", "read", self.udata, "line")
		elseif format:sub(1, 2) == "*n" then
			return self.env.callback("file", "read", self.udata, "newline")
		end
	end

	function META:read(...)
		local args = {...}

		for k, v in ipairs(args) do
			args[k] = read(self, v) or nil
		end

		return unpack(args) or nil
	end

	function META:close()
		self.env.callback("file", "close", self.udata)
	end

	function META:flush()
		self.env.callback("file", "flush", self.udata)
	end

	function META:seek(whence, offset)
		whence = whence or "cur"
		offset = offset or 0

		return self.env.callback("file", "seek", self.udata, whence, offset)
	end

	function META:lines()
		return self.env.callback("file", "read", self.udata, "lines")
	end

	function META:setvbuf()
		self.env.callback("file", "read", self.udata, "setvbuf")
	end

	function vfs.CreateDummyFile(udata, env)
		mode = mode or "r"

		local self = setmetatable({}, META)
		
		self.udata = udata
		self.env = env
		self.__mode = mode

		return self
	end
end

do -- generic

	function vfs.GetFile(path, mode, ...)
		check(path, "string")
		path = vfs.ParseVariables(path)
		
		mode = mode or "r"
		
		if not mode:find("r") and not mode:find("w") then 
			mode = "r" .. mode 
		end
		
		local file, err = io.open(path, mode, ...)

		if not file then
			
			for k, v in ipairs(vfs.paths) do
				if type(v) == "table" then
					local handle, reason = v.callback("file", "open", v.root .. "/" .. path, mode, ...)
				
					if handle then
						file = vfs.CreateDummyFile(handle, v)
						path = v.root .. "/" .. path
					else	
						err = reason
					end
				else
					file, err = io.open(v .. "/" .. path, mode, ...)
					if file then
						path = v .. "/" .. path
					end
				end
				
			
				if err then
					warning(err)
				end
				
				if file then
					break
				end
			end
					
			if not file and mode and mode:find("w") then
				vfs.CreateFoldersFromPath(path)		
				return vfs.GetFile(path, mode)
			end
		end
		
		if file then
			if vfs.debug then
				logf("[VFS] file access mode %s %q\n", mode, path)
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
		
		if vfs.debug then
			logf("[VFS] requesting attributes on %q\n", path)
		end
			
		for k, v in ipairs(vfs.paths) do
			local info
			local _path
			
			if type(v) == "table" then
				_path = v.root .. "/" .. path
				info = v.callback("attributes", _path, ...)
			else
				_path = v .. "/" .. path
				info = lfs.attributes(_path, ...)
			end
			
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
			
				local files = {}
			
				if type(full_dir) == "table" then
					local res = full_dir.callback("find", full_dir.root .. "/" .. dir)

					if res then
						for i, file_name in pairs(res) do
							table.insert(files, file_name)
						end
					end
					
					for _, path in pairs(files) do
						if full_path then
							path = full_dir.root .. "/" .. dir .. "/" .. path
						end
						unique[path] = true
					end
				else					
					-- fix me!! 
					-- on linux, an invalid path will error
								
					pcall(function()
						for file_name in lfs.dir(full_dir .. "/" .. dir) do
							if file_name ~= "." and file_name ~= ".." then
								table.insert(files, file_name)
							end
						end
					end)
					
					for _, path in pairs(files) do
						if full_path then
							path = full_dir .. "/" .. dir .. "/" .. path
						end
						unique[path] = true
					end
				end
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
		local function search(path, ext, callback)		
			for _,v in pairs(vfs.Find(path)) do
				if not ext or v:endswith(ext) then
					if callback and callback(path .. v) ~= nil then
						return
					end
					
					table.insert(out, path .. v)
				end
				
				if vfs.GetAttributes(path .. v).mode == "directory" then
					search(path .. v .. "/", ext, callback)
				end
			end
		end

		function vfs.Search(path, ext, callback)
			out = {}
			search(path, ext, callback)
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
	
	table.insert(package.loaders, function(path)
		return vfs.loadfile(dir .. path .. "/" .. path .. ".lua")
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

do -- async reading
	local queue = {}

	vfs.async_readers = {
		file = function(path, mbps, context)
			local file = vfs.GetFile(path, "rb")
			if file then
				local content = {}
				mbps = mbps / 2
				event.CreateThinker(function()
					-- in case mbps is higher than the file size
					for i = 1, 2 do
						local str = file:read(1048576 * mbps)
						if str then
							content[#content + 1] = str
						else
							queue[path].callback(table.concat(content))
							return false
						end
					end
				end, 1, true, true)
				return true				
			end
		end,
		sockets = function(path, mbps, context)
		
		
			-- for font names only
			if context:find("font") and not path:find("%p") then			
				local cache_path = "fonts/" .. path .. ".woff"
				
				if vfs.Exists(cache_path) then
					return vfs.ReadAsync(cache_path, queue[path].callback, mbps, context, "file")
				else
					if sockets.Download("http://fonts.googleapis.com/css?family=" .. path:gsub("%s", "+"), 
						function(data)
							local url = data:match("url%((.-)%)")
							local format = data:match("format%('(.-)'%)")
							sockets.Download(url, function(data) 
								vfs.Write("fonts/" .. path .. "." .. format, data, "b")				
								queue[path].callback(data)
							end)
						end)
					then
						return true
					end
				end
			end
			
			local ext = path:match(".+(%.%a+)") or ".dat"
			local cache_path = "download_cache/" .. crypto.CRC32(path) .. ext
			if vfs.Exists(cache_path) then
				return vfs.ReadAsync(cache_path, queue[path].callback, mbps, context, "file")
			else
				if sockets.Download(path, function(data) 
						vfs.Write(cache_path, data, "b")			
						queue[path].callback(data)
					end) 
				then
					return true
				end
			end
		end,
	}
	
	local cache = {}
		
	function vfs.ReadAsync(path, callback, mbps, context, reader)
		check(path, "string")
		check(callback, "function")
		check(mbps, "nil", "number")
		mbps = mbps or 1
		
		if vfs.debug then
			logf("[VFS] vfs.ReadAsync(%q)\n", path)
		end
		
		if cache[path] then
			callback(cache[path])
			return true
		end
			
		-- if it's already being downloaded, append the callback to the current download
		if queue[path] then
			local old = queue[path].callback
			queue[path].callback = function(data)
				callback(data)
				old(data)
				queue[path] = nil
			end
			return
		end
				
		queue[path] = {callback = function(data)
			cache[path] = data
			callback(data)
			queue[path] = nil
		end}
					
		for name, func in pairs(vfs.async_readers) do
			if (not reader or reader == name) and func(path, mbps, context or "none") then
				return true
			end
		end 
		
		queue[path] = nil
		
		return false
	end
end

do -- file monitoring
	local included = {}
	
	local function store(path)
		local path = vfs.FixPath(path:lower())
		included[path] = lfs.attributes(path)
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
		return included
	end

	function vfs.MonitorFile(file_path, callback)
		check(file_path, "string")
		check(callback, "function")

		local last = vfs.GetAttributes(file_path)
		
		if last then
			last = last.modification
			event.CreateTimer(file_path, 0, 0, function()
				local time = vfs.GetAttributes(file_path)
				if time then
					time = time.modification
					if last ~= time then
						logf("[vfs monitor] %s changed!\n", file_path)
						last = time
						return callback(file_path)
					end
				else
					logf("[vfs monitor] %s was removed\n", file_path)
					event.RemoveTimer(file_path)
				end
			end)
		else
			logf("[vfs monitor] %s was not found\n", file_path)
		end
	end

	function vfs.MonitorFileInclude(source, target)
		source = source or utilities.GetCurrentPath(3)
		target = target or source
		
		vfs.MonitorFile(source, function()
			event.Delay(0, function()
				dofile(target)
			end)
		end)
	end

	function vfs.MonitorEverything(b)
		if not b then
			event.RemoveTimer("vfs_monitor_everything")
			return
		end

		event.CreateTimer("vfs_monitor_everything", 0.1, 0, function()
			for path, data in pairs(vfs.GetLoadedLuaFiles()) do
				local info = lfs.attributes(path)
				
				if info then
					if not data.modification then
						data.modification = info.modification
					else 
						if data.modification ~= info.modification then
							logn("reloading ", utilities.GetFileNameFromPath(path))
							_G.RELOAD = true
							include(path) 
							_G.RELOAD = nil
							data.modification = info.modification
						end
					end			
				end
			end
		end)
	end

end

return vfs
