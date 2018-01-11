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

	return false, ("No such file or directory %q"):format(path)
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
			wlog(err)
		end

		return ok, err
	end

	local err = ("No such file or directory %q"):format(path)
	wlog(err)
	return false, err
end

local function add_helper(name, func, mode, cb)
	vfs[name] = function(path, ...)
		if cb then cb(path, ...) end

		local file, err = vfs.Open(path, mode)

		if file then
			local data = {file[func](file, ...)}

			file:Close()

			return unpack(data)
		end

		return file, err
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

	if on_change then
		vfs.MonitorFile(path, function(file_path)
			on_change(vfs.Read(file_path), file_path)
		end)
		on_change(content)
	end

	if path:startswith("os:") then
		path = path:sub(4)
	end

	if path:startswith("data/") then
		path = path:sub(#"data/" + 1)

		local fs = vfs.GetFileSystem("os")

		if fs then
			local base = e.USERDATA_FOLDER
			local dir = ""
			for folder in path:gmatch("(.-/)") do
				dir = dir .. folder
				fs:CreateFolder({full_path = base .. dir})
			end
		end
	end
end)
add_helper("GetLastModified", "GetLastModified", "read")
add_helper("GetLastAccessed", "GetLastAccessed", "read")
add_helper("GetSize", "GetSize", "read")

function vfs.CreateDirectory(path, force)
	if vfs.IsDirectory(path) then return end

	local path_info = vfs.GetPathInfo(path, true)
	local dir_name = vfs.GetFolderNameFromPath(path_info.full_path) or path_info.full_path

	local parent_dir = vfs.GetParentFolderFromPath(path_info.full_path)
	local full_path = vfs.GetAbsolutePath(parent_dir, true)

	if not full_path then return false, "directory " .. parent_dir .. " does not exist" end

	local path_info = vfs.GetPathInfo(path_info.filesystem .. ":" .. full_path)

	if path_info.filesystem == "unknown" then
		return false, "filesystem must be explicit when creating directories"
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