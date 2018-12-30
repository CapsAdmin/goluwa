local vfs = (...) or _G.vfs

function vfs.FindMixedCasePath(path)
	-- try all lower case first just in case
	if vfs.IsFile(path:lower()) then
		return path:lower()
	end

	local dir = ""
	for _, str in ipairs(path:split("/")) do
		for _, found in ipairs(vfs.Find(dir)) do
			if found:lower() == str:lower() then
				str = found
				dir = dir .. str .. "/"
				break
			end
		end
	end
	dir = dir:sub(0,-2)


	if #dir == #path then
		wlog("found mixed case path for %s: found %s", dir, path)
		return dir
	end

	wlog("tried to find mixed case path for %s but nothing was found", path, 2)
end

local fs = require("fs")

vfs.OSCreateDirectory = fs.createdir
vfs.OSGetAttributes = fs.getattributes

do
	vfs.SetWorkingDirectory = fs.setcd
	vfs.GetWorkingDirectory = fs.getcd

	if utility.MakePushPopFunction then
		utility.MakePushPopFunction(vfs, "WorkingDirectory")
	end
end

function vfs.Delete(path, ...)
	local abs_path = vfs.GetAbsolutePath(path, ...)

	if abs_path then
		local ok, err = os.remove(abs_path)

		return ok, err
	end

	local err = ("No such file or directory %q"):format(path)

	if CLI then
		error(err, 2)
	end

	return nil, err
end

function vfs.Rename(path, name, ...)
	local abs_path = vfs.GetAbsolutePath(path, ...)

	if abs_path then
		local dst = abs_path:match("(.+/)") .. name

		if WINDOWS then
			if vfs.IsFile(dst) then
				vfs.Delete(dst)
			end
		end

		local ok, err = os.rename(abs_path, dst)

		if not ok then
			if CLI then
				error(err, 2)
			else
				wlog(err)
			end
		end

		return ok, err
	end

	local err = ("No such file or directory %q"):format(path)

	if CLI then
		error(err, 2)
	end

	return nil, err
end

function vfs.CopyFile(from, to)
	local ok, err = vfs.CreateDirectoriesFromPath(vfs.GetFolderFromPath(to))
	if not ok then return ok, err end
	local content, err = vfs.Read(from)
	if not content then return content, err end
	return vfs.Write(to, content)
end

function vfs.CopyFileFileOnBoot(from, to)
	from = vfs.GetAbsolutePath(from)
	if not from then return nil, "source does not exist" end

	local ok, err = vfs.CreateDirectoriesFromPath(vfs.GetFolderFromPath(to:startswith("os:") and to or ("os:" .. to)))
	if not ok then
		return ok, err
	end

	if not vfs.GetAbsolutePath(vfs.GetFolderFromPath(to)) then
		return nil, "destination directory does not exist"
	end

	if vfs.IsFile(to) then
		local path = "shared/copy_binaries_instructions"
		local str = vfs.Read(path) or ""
		str = str .. from .. ";" .. to .. "\n"
		vfs.Write(path, str)
		return "deferred"
	end

	if not ok then return ok, err end
	local content, err = vfs.Read(from)
	if not content then return content, err end

	return vfs.Write(to, content)
end

function vfs.LinkFile(from, to)
	from = vfs.GetAbsolutePath(from)

	if not from then
		return nil, "source does not exist"
	end

	local dir = vfs.GetFolderFromPath(to)
	dir = R(dir)

	if not dir then
		return nil, "destination directory does not exist"
	end

	local to = dir .. vfs.GetFileNameFromPath(to)

	if UNIX then
		os.execute("ln -s '" .. from .. "' '" .. to .. "'")
	end
	if WINDOWS then
		os.execute("MKLINK /H '" .. to .. "' '" .. from .. "'")
	end
end

local function add_helper(name, func, mode, cb)
	vfs[name] = function(path, ...)
		if cb then cb(path, ...) end

		local file, err = vfs.Open(path, mode)

		if file then
			local args = {...}

			if event then
				local ret = {event.Call("VFSPre" .. name, path, ...)}
				if ret[1] ~= nil then
					for i,v in ipairs(args) do
						if ret[i] ~= nil then
							args[i] = ret[i]
						end
					end
				end
			end

			local res, err = file[func](file, unpack(args))

			file:Close()

			if res and event then
				local res, err = event.Call("VFSPost" .. name, path, res)
				if res ~= nil or err then
					if CLI then
						debug.trace()
						error(err, 2)
					end

					return res, err
				end
			end

			return res, err
		end

		if CLI then
			logn(path)
			error(err, 2)
		end

		return nil, err
	end
end

add_helper("Read", "ReadAll", "read")
add_helper("Write", "WriteBytes", "write", function(path, content, on_change)
	path = path:gsub("(.+/)(.+)", function(folder, file_name)
		for _, char in ipairs({--[['\\', '/', ]]':', '%*', '%?', '"', '<', '>', '|'}) do
			file_name = file_name:gsub(char, "_il" .. char:byte() .. "_")
		end
		return folder .. file_name
	end)

	if type(on_change) == "function" and vfs.MonitorFile then
		vfs.MonitorFile(path, function(file_path)
			on_change(vfs.Read(file_path), file_path)
		end)
		on_change(content)
	end


	local found = false
	local fs = vfs.GetFileSystem("os")
	if fs then
		for _, dir in ipairs({"data", "cache", "shared"}) do
			if path:startswith(dir.."/") or path:startswith("os:"..dir.."/") then

				if path:startswith("os:") then
					path = path:sub(4)
				end

				path = path:sub(#(dir.."/") + 1)

				local base = e.USERDATA_FOLDER

				if dir == "cache" then
					base = e.STORAGE_FOLDER .. "data/cache/"
				elseif dir == "shared" then
					base = e.STORAGE_FOLDER .. "data/shared/"
				end

				local dir = ""
				for folder in path:gmatch("(.-/)") do
					dir = dir .. folder
					fs:CreateFolder({full_path = base .. dir})
				end

				found = true
				break
			end
		end
	end

	if not found then
		if CLI then
			vfs.CreateDirectoriesFromPath(path, true)
		end
	end
end)

add_helper("GetLastModified", "GetLastModified", "read")
add_helper("GetLastAccessed", "GetLastAccessed", "read")
add_helper("GetSize", "GetSize", "read")

function vfs.CreateDirectory(path, force)
	if vfs.IsDirectory(path) then return true end

	local path_info = vfs.GetPathInfo(path, true)
	local dir_name = vfs.GetFolderNameFromPath(path_info.full_path) or path_info.full_path

	local parent_dir = vfs.GetParentFolderFromPath(path_info.full_path)
	local full_path = vfs.GetAbsolutePath(parent_dir, true)

	if not full_path then return nil, "directory " .. parent_dir .. " does not exist" end

	local path_info = vfs.GetPathInfo(path_info.filesystem .. ":" .. full_path)

	if path_info.filesystem == "unknown" then
		return nil, "filesystem must be explicit when creating directories"
	end

	path_info.full_path = path_info.full_path .. dir_name .. "/"

	return vfs.GetFileSystem(path_info.filesystem):CreateFolder(path_info, force)
end

function vfs.IsDirectory(path)
	if path == "" then return false end

	for _, data in ipairs(vfs.TranslatePath(path, true)) do
		if data.context:CacheCall("IsFolder", data.path_info) then
			return true
		end
	end

	return false
end

function vfs.IsFile(path)
	if path == "" then return false end

	for _, data in ipairs(vfs.TranslatePath(path)) do
		if data.context:CacheCall("IsFile", data.path_info) then
			return true
		end
	end

	return false
end

function vfs.IsFolderValid(path)
	if path == "" then return false, "path is nothing" end

	local path, err = vfs.GetAbsolutePath(path)
	if not path then
		return false, err
	end

	local path_info = vfs.GetPathInfo(path, true)

	local errors = ""

	for _, context in ipairs(vfs.GetFileSystems()) do
		if context:IsArchive(path_info) then
			local ok, err = context:IsFolderValid(path_info)

			if ok then
				return true
			end

			if err then
				errors = errors .. err .. "\n"
			end
		end
	end

	return false, errors
end

function vfs.Exists(path)
	return vfs.IsDirectory(path) or vfs.IsFile(path)
end

function vfs.WatchLuaFiles(b)
	if not fs.watch then logn("fs.watch not implemented") return end

	if not b then
		event.RemoveListener("Update", "vfs_watch_lua_files")
		return
	end

	local watchers = {}
	for i, path in ipairs(vfs.GetFilesRecursive("lua/", {"lua"})) do
		if not path:endswith("core/lua/boot.lua") then
			table.insert(watchers, {path = path, watcher = fs.watch(R(path))})
		end
	end

	local next_check = 0

	event.AddListener("Update", "vfs_watch_lua_files", function()
		local time = system.GetElapsedTime()

		if time > next_check then
			for _, data in ipairs(watchers) do
				local res = data.watcher:Read()
				if res then
					res.path = data.path
					if event.Call("LuaFileChanged", res) == nil then
						if res.flags.close_write then
							logn("reloading " .. data.path)
							_G.RELOAD = true
							system.pcall(runfile, data.path)
							_G.RELOAD = nil
						end
					end
				end
			end
			next_check = time + 1/5
		end
	end)
end

function vfs.WatchLuaFiles2(b)
	if not b then
		event.RemoveListener("Update", "vfs_watch_lua_files")
		return
	end

	local paths = {}
	for i, path in ipairs(vfs.GetFilesRecursive("lua/", {"lua"})) do
		if not path:endswith("core/lua/boot.lua") then
			table.insert(paths, {path = R(path)})
		end
	end

	local next_check = 0

	event.AddListener("Update", "vfs_watch_lua_files", function()
		local time = system.GetElapsedTime()

		if time > next_check then
			if WINDOW and window.IsFocused() then return end
			if profiler.IsBusy() then return end -- I already know this is slow so it's just in the way

			for i, data in ipairs(paths) do
				local info = fs.getattributes(data.path)

				if info then
					if not data.last_modified then
						data.last_modified = info.last_modified
					else
						if data.last_modified ~= info.last_modified then
							llog("reloading %s", vfs.GetFileNameFromPath(data.path))
							_G.RELOAD = true
							system.pcall(runfile, data.path)
							_G.RELOAD = nil
							data.last_modified = info.last_modified
						end
					end
				end
			end
			next_check = time + 1/5
		end
	end)
end