local vfs = (...) or _G.vfs

vfs.files_ran_ = vfs.files_ran_ or {}

local function store_run_file_path(path)
	vfs.files_ran = nil
	table.insert(vfs.files_ran_, path)
end


function loadfile(path, ...)
	store_run_file_path(path)
	return _OLD_G.loadfile(path, ...)
end

function dofile(path, ...)
	store_run_file_path(path)
	return _OLD_G.dofile(path, ...)
end

do
	local first = true
	local resolved = {}

	function vfs.GetLoadedLuaFiles()
		if not vfs.files_ran then
			vfs.files_ran = {}
			for _, path in ipairs(vfs.files_ran_) do
				local full_path = vfs.GetAbsolutePath(path, false) or path
				vfs.files_ran[full_path] = vfs.OSGetAttributes(full_path)
			end
		end

		return vfs.files_ran
	end
end

function vfs.LoadFile(path, chunkname)
	local full_path = vfs.GetAbsolutePath(path, false)

	if full_path then
		if event then full_path = event.Call("PreLoadFile", full_path) or full_path end

		local res, err = vfs.Read(full_path)

		if not res and not err then
			res = ""
		end

		if not res then
			return res, err, full_path
		end

		if event then res = event.Call("PreLoadString", res, full_path) or res end

		-- prepend "@" in front of the path so it will be treated as a lua file and not a string by lua internally
		-- for nicer error messages and debug

		if vfs.modify_chunkname then
			chunkname = vfs.modify_chunkname(full_path)
		end

		res, err = loadstring(res, chunkname or "@" .. full_path:replace(e.ROOT_FOLDER, ""))

		if event and res then res = event.Call("PostLoadString", res, full_path) or res end

		store_run_file_path(full_path)

		return res, err, full_path
	end

	return nil, path .. ": No such file or directory"
end

function vfs.DoFile(path, ...)
	return assert(vfs.LoadFile(path))(...)
end

do -- runfile
	local filerun_stack = vfs.filerun_stack or {}
	vfs.filerun_stack = filerun_stack

	function vfs.PushToFileRunStack(path)
		table.insert(filerun_stack, path)
	end

	function vfs.PopFromFileRunStack()
		table.remove(filerun_stack)
	end

	function vfs.GetFileRunStack()
		return filerun_stack
	end

	local function not_found(err)
		return
			err and
			(
				err:find("No such file or directory", nil, true) or
				err:find("Invalid argument", nil, true)
			)
	end

	local system_pcall = true

	function vfs.RunFile(source, ...)

		if type(source) == "table" then
			system_pcall = false
			local ok, err
			local errors = {}
			for _, path in ipairs(source) do
				ok, err = vfs.RunFile(path)
				if ok == false then
					table.insert(errors, err .. ": " .. path)
				else
					return ok
				end
			end
			system_pcall = true

			if ok == false then
				err = table.concat(errors, "\n")
			else
				ok = true
				err = nil
			end

			return ok, err
		end

		if source:startswith("!") then
			source = source:sub(2)
			if filerun_stack[#filerun_stack] then
				source = filerun_stack[#filerun_stack]:match("(.+/).-/") .. source
			end
		end

		local dir, file = source:match("(.+/)(.+)")

		if not dir then
			dir = ""
			file = source
		end

		if file == "*" then
			local previous_dir = filerun_stack[#filerun_stack]
			local original_dir = dir

			if previous_dir then
				dir = previous_dir .. dir
			end

			if not vfs.IsDirectory(dir) then
				dir = original_dir
			end

			for script in vfs.Iterate(dir .. ".+%.lua", true) do
				local func, err, full_path = vfs.LoadFile(script)

				if func then
					vfs.PushToFileRunStack(full_path:match("(.+/)") or dir)

					_G.FILE_PATH = full_path
					_G.FILE_NAME = full_path:match(".*/(.+)%.") or full_path
					_G.FILE_EXTENSION = full_path:match(".*/.+%.(.+)")

					if VERBOSE and utility and utility.PushTimeWarning then
						utility.PushTimeWarning()
					end

					local ok, err

					if system_pcall and system and system.pcall then
						ok, err = system.pcall(func, ...)
					else
						ok, err = pcall(func, ...)
					end

					if VERBOSE and utility and utility.PushTimeWarning then
						utility.PopTimeWarning(full_path, 0.01)
					end

					_G.FILE_NAME = nil
					_G.FILE_PATH = nil
					_G.FILE_EXTENSION = nil

					if not ok then logn(err) end

					vfs.PopFromFileRunStack()
				end

				if not func then
					logn(err)
				end
			end

			return
		end

		local previous_dir = filerun_stack[#filerun_stack]

		if previous_dir then
			dir = previous_dir .. dir
		end

		local full_path
		local err
		local func
		local path = source

		if vfs.IsPathAbsolute(path) then
			func, err, full_path = vfs.LoadFile(path)
		else
			if path:startswith("lua/") then
				func, err, full_path = vfs.LoadFile(path)
			end

			if not func then
				-- try first with the last directory
				-- once with lua prepended
				path = dir .. file
				func, err, full_path = vfs.LoadFile(path)

				if not_found(err) then

					if path ~= dir .. file then
						path = dir .. file
						func, err, full_path = vfs.LoadFile(path)
					end

					-- and without the last directory
					-- once with lua prepended
					if not_found(err) then
						path = source
						func, err, full_path = vfs.LoadFile(path)
					end
				end
			end
		end

		if func then
			dir = path:match("(.+/)(.+)")

			if not full_path:startswith(e.ROOT_FOLDER) then
				vfs.PushWorkingDirectory(dir)
			end

			vfs.PushToFileRunStack(dir)

			_G.FILE_PATH = full_path
			_G.FILE_NAME = full_path:match(".*/(.+)%.") or full_path
			_G.FILE_EXTENSION = full_path:match(".*/.+%.(.+)")

			if full_path:find(e.ROOT_FOLDER, nil, true) then
				utility.PushTimeWarning()
			end

			local res
			if system_pcall and system and system.pcall then
				res = {system.pcall(func, ...)}
			else
				res = {pcall(func, ...)}
			end

			if VERBOSE and full_path:find(e.ROOT_FOLDER, nil, true) then
				utility.PopTimeWarning(full_path:gsub(e.ROOT_FOLDER, ""), 0.025, "[runfile]")
			end

			_G.FILE_PATH = nil
			_G.FILE_NAME = nil
			_G.FILE_EXTENSION = nil

			if not res[1] then
				logn(res[2])
			end

			vfs.PopFromFileRunStack()

			if not full_path:startswith(e.ROOT_FOLDER) then
				vfs.PopWorkingDirectory(dir)
			end

			return select(2, unpack(res))
		end

		if system_pcall and full_path then
			err = err or "no error"

			logn(source:sub(1) .. " " .. err)

			debug.openscript(full_path, err:match(":(%d+)"))
		end

		return false, err
	end
end

vfs.module_directories = {}

function vfs.Require(name, ...)
	if _G.RELOAD and name then
		package.loaded[name] = nil
	end

	local ret = {pcall(_OLD_G.require, name, ...)}
	if ret[1] then
		return unpack(ret, 2)
	end

	local done = {}
	local errors = {}
	for _, dir in ipairs(vfs.module_directories) do
		for _, data in ipairs(vfs.TranslatePath(dir, true)) do
			vfs.PushWorkingDirectory(data.path_info.full_path)

			local ret = {pcall(_OLD_G.require, name, ...)}

			vfs.PopWorkingDirectory()

			if ret[1] then
				return unpack(ret, 2)
			else
				if not done[ret[2]] then
					table.insert(errors, ret[2])
					done[ret[2]] = true
				end
			end
		end
	end
	error(table.concat(errors, "\n\n"), 2)
end

function vfs.AddModuleDirectory(dir)
	table.insert(vfs.module_directories, dir)
end

local ffi = desire("ffi")

if ffi then
	local where = {
		"bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
		"lua/modules/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
	}

	local function warn_pcall(func, ...)
		local res = {pcall(func, ...)}
		if not res[1] then
			logn(res[2]:trim())
		end

		return unpack(res, 2)
	end

	local function handle_windows_symbols(path, clib, err, ...)
		if WINDOWS and clib then
			return setmetatable({}, {
				__index = function(s, k)
					if k == "Type" then return "ffi" end
					local ok, msg = pcall(function() return clib[k] end)
					if not ok then
						if  msg:find("cannot resolve symbol", nil, true)  then
							logf("[%s] could not find function %q in shared library\n", path, msg:match("cannot resolve symbol '(.-)': "))
							return nil
						else
							error(msg, 2)
						end
					end
					return msg
				end,
				__newindex = clib,
			})
		end
		return clib, err, ...
	end

	local function indent_error(str)
		local last_line
		str = "\n" .. str .. "\n"
		str = str:gsub("(.-\n)", function(line)
			line = "\t" .. line:trim() .. "\n"
			if line == last_line then
				return ""
			end
			last_line = line
			return line
		end)
		str= str:gsub("\n\n", "\n")
		return str
	end

	-- make ffi.load search using our file system
	function vfs.FFILoadLibrary(path, ...)
		local args = {pcall(_OLD_G.ffi.load, path, ...)}

		if WINDOWS and not args[1] then
			args = {pcall(_OLD_G.ffi.load, "lib" .. path, ...)}
		end
		if not args[1] then
			if vfs and system and system.SetSharedLibraryPath then
				for _, where in ipairs(where) do
					for _, full_path in ipairs(vfs.GetFiles({path = where, filter = path, filter_plain = true, full_path = true})) do
						-- look first in the vfs' bin directories
						local old = system.GetSharedLibraryPath()
						system.SetSharedLibraryPath(full_path:match("(.+/)"))
						args = {pcall(_OLD_G.ffi.load, full_path, ...)}
						system.SetSharedLibraryPath(old)

						if args[1] then
							return handle_windows_symbols(path, select(2, unpack(args)))
						end

						args[2] = args[2] .. "\n" .. system.GetLibraryDependencies(full_path)

						-- if not try the default OS specific dll directories
						args = {pcall(_OLD_G.ffi.load, full_path, ...)}
						if args[1] then
							return handle_windows_symbols(path, select(2, unpack(args)))
						end

						args[2] = args[2] .. "\n" .. system.GetLibraryDependencies(full_path)
					end
				end

				error(indent_error(args[2]), 2)
			end
		end

		return handle_windows_symbols(path, args[2])
	end
end