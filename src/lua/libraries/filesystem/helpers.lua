local vfs = (...) or _G.vfs

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

local function add_helper(name, func, mode, cb)
	vfs[name] = function(path, ...)
		check(path, "string")

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
		for i, char in ipairs({--[['\\', '/', ]]':', '%*', '%?', '"', '<', '>', '|'}) do
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
		local fs = vfs.GetFileSystem("os")
		if fs then
			local dir = ""
			local base
			for folder in path:gmatch("(.-/)") do
				dir = dir .. folder
				base = base or vfs.GetAbsolutePath(dir)
				fs:CreateFolder({full_path = base .. dir:sub(#"data/"+1)})
			end
		end
	end
end)
add_helper("GetLastModified", "GetLastModified", "read")
add_helper("GetLastAccessed", "GetLastAccessed", "read")

function vfs.CreateFolder(path)
	check(path, "string")

	for i, data in ipairs(vfs.TranslatePath(path, true)) do
		data.context:PCall("CreateFolder", data.path_info)
	end
end

function vfs.CreateFolders(fs, path)
	local fs = vfs.GetFileSystem(fs)
	if fs then
		local folder_path = ""
		for folder in path:gmatch("(.-/)") do
			folder_path = folder_path .. folder
			fs:CreateFolder({full_path = folder_path})
		end
	end
end

function vfs.IsDirectory(path)
	if path == "" then return false end

	for i, data in ipairs(vfs.TranslatePath(path, true)) do
		if data.context:CacheCall("IsFolder", data.path_info) then
			return true
		end
	end

	return false
end

function vfs.IsFile(path)
	if path == "" then return false end

	for i, data in ipairs(vfs.TranslatePath(path)) do
		if data.context:CacheCall("IsFile", data.path_info) then
			return true
		end
	end

	return false
end

function vfs.Exists(path)
	return vfs.IsDirectory(path) or vfs.IsFile(path)
end