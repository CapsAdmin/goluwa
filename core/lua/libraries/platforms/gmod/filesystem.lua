local file_Find = gmod.file.Find
local file_Exists = gmod.file.Exists
local file_Size = gmod.file.Size
local file_IsDir = gmod.file.IsDir
local file_CreateDir = gmod.file.CreateDir
local file_Time = gmod.file.Time
local GoluwaToGmodPath = GoluwaToGmodPath
local fs = {}
local dprint = function(...)
	if DEBUG then gmod.print("[goluwa] fs: ", ...) end
end
fs.find_cache = {}
fs.get_attributes_cache = {}

function fs.uncache(path)
	if path:sub(-1) == "/" then path = path:sub(0, -2) end

	dprint("uncaching " .. path)
	fs.find_cache[path:match("(.+/)")] = nil
	fs.get_attributes_cache[path] = nil
end

function fs.get_files(path)
	dprint("fs.get_files: ", path)

	if path:starts_with("/") then path = path:sub(2) end

	local original_path = path
	dprint("fs.get_files: is " .. path .. " cached?")

	if fs.find_cache[path] then
		dprint("yes!")
		return fs.find_cache[path]
	else
		dprint("no")
	end

	if path:sub(-1) == "/" then path = path .. "*" end

	local where = "GAME"

	if path:starts_with("data/") then
		path = path:sub(6)
		where = "DATA"
	end

	dprint("fs.get_files: file.Find(" .. path .. ", " .. where .. ")")
	local files, dirs = file_Find(path, where)
	dprint(files, dirs)

	if not files then return nil, "No such file or directory" end

	if where == "DATA" then
		for i, name in ipairs(files) do
			local new_name, count = name:gsub("%^", "%.")

			if count > 0 then files[i] = new_name:sub(0, -5) end
		end
	end

	table.add(files, dirs)
	dprint("found " .. #files .. " files and folders")
	fs.find_cache[original_path] = files
	dprint("fs.get_files: caching results for dir " .. path)
	return files
end

function fs.get_current_directory()
	dprint("fs.get_current_directory")
	return ""
end

function fs.set_current_directory(path)
	dprint("fs.set_current_directory: ", path)
end

function fs.create_directory(path)
	dprint("fs.create_directory: ", path)
	fs.uncache(path)
	local path, where = GoluwaToGmodPath(path)
	file_CreateDir(path, where)

	if file_IsDir(path, where) then return true end

	return nil, "file.IsDir returns false"
end

function fs.get_type(path)
	local path, where = GoluwaToGmodPath(path)

	if file_IsDir(path, where) then
		return "directory"
	elseif file_Exists(path, where) then
		return "file"
	end

	return nil
end

function fs.get_attributes(path)
	dprint("fs.get_attributes: ", path)
	local cache_key = path

	if cache_key:sub(-1) == "/" then cache_key = cache_key:sub(0, -2) end

	if fs.get_attributes_cache[cache_key] ~= nil then
		dprint("\twas cached")
		return fs.get_attributes_cache[cache_key]
	end

	local path, where = GoluwaToGmodPath(path)

	if file_Exists(path, where) then
		dprint("\tfile exists")
		local size = path == "" and 0 or file_Size(path, where)
		local time = file_Time(path, where)
		local type = file_IsDir(path, where) and "directory" or "file"
		dprint("\t", size)
		dprint("\t", time)
		dprint("\t", type)
		local res = {
			creation_time = time,
			last_accessed = time,
			last_modified = time,
			last_changed = time,
			size = size,
			type = type,
		}
		fs.get_attributes_cache[cache_key] = res
		return res
	else
		dprint("\t" .. path .. " " .. where .. " does not exist")
	end

	fs.get_attributes_cache[cache_key] = false
	return false
end

return fs