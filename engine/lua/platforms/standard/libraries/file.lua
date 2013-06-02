local file = require("lfs") or {}

file.base_dir = e.BASE_FOLDER

local function handle_path(path)
	if path:find("^%a:/") then
		return path
	end
	
	if path:sub(0, 1) == "!" then
		return lfs.currentdir() .. path:sub(2)
	end
	
	return file.base_dir .. path
end

local function SafeClose(fil)
	if fil and io.type(fil) == "file" then
		io.close(fil)
	end 
end

function file.Read(path, mode)
	check(path, "string")
	mode = mode or ""
	check(mode, "string")
	
	path = event.Call("HandleFileIOPath", path) or path
		
	local fil, msg
	
	if path == "stdout" then
		fil = io.stdout
	elseif path == "stdin" then
		fil = io.stdin
	else
		fil, err = io.open(handle_path(path), "r" .. mode)
	end

	if err then
		print(err)
		return fil, err
	end

	local content = fil:read("*a")
	SafeClose(fil)

	return content
end

function file.Write(path, content, mode)
	check(path, "string")
	mode = mode  or ""
	check(mode, "string")
	content = content and tostring(content) or ""
	
	path = event.Call("HandleFileIOPath", path) or path

	local fil, err
	
	if path == "stdout" then
		fil = io.stdout
	elseif path == "stdin" then
		fil = io.stdin
	else
		fil, err = io.open(handle_path(path), "w" .. mode)
	end
	
	if err and err:findsimple("No such file or directory") then
		file.CreateFoldersFromPath(path)
		fil, err = io.open(path, "w")
	end

	if fil and fil:write(content) then
		SafeClose(fil)
	end

	return fil, err
end

function file.Exists(path)
	check(path, "string")
	
	path = event.Call("HandleFileIOPath", path) or path
	
	local fil, msg = io.open(handle_path(path), "r")
	
	local bool = fil ~= nil

	SafeClose(fil)

	return bool
end

function file.Rename(path, new)
	check(path, "string")
	check(new, "string")
	
	path = event.Call("HandleFileIOPath", path) or path

	return os.rename(handle_path(path), new)
end

function file.Delete(path)
	check(path, "string") 
	
	path = event.Call("HandleFileIOPath", path) or path

	return os.remove(handle_path(path))
end

function file.CreateFoldersFromPath(path)
	local dirs = {}
	for i=0, 10 do
		local folder = utilities.GetParentFolder(path, i)
		if folder ~= "" then 
			table.insert(dirs, folder)
		else
			break
		end
	end
	for key, dir in ipairs(dirs) do
		if dir ~= "!/../" and dir ~= "!/" then
			file.mkdir(dir)
		end
	end
end

function file.Find(path)
	local out = {}
	
	local pattern = utilities.GetFileNameFromPath(path)

	if pattern == "" or pattern == "*" then
		pattern = "."
	else
		pattern = pattern:gsub("%*", ".-")
	end

	path = utilities.GeFolderFromPath(path)
	path = handle_path(path)
		
	for file_name in file.dir(path) do
		if file_name ~= "." and file_name ~= ".." and file_name:find(pattern) then
			out[file_name] = file.attributes(path .. file_name)
		end
	end

	return out
end

function file.FolderExists(path)
	check(path, "string")
	return file.Find(path .. "/*")[1] ~= nil
end

return file