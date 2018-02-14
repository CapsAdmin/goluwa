local file_Find = gmod.file.Find
local file_Exists = gmod.file.Exists
local file_Size = gmod.file.Size
local file_IsDir = gmod.file.IsDir
local file_CreateDir = gmod.file.CreateDir
local file_Time = gmod.file.Time
local GoluwaToGmodPath = GoluwaToGmodPath

local fs = {}

local dprint = function(...) if DEBUG then gmod.print("[goluwa] fs: ", ...) end end

fs.find_cache = {}
fs.get_attributes_cache = {}

function fs.uncache(path)
	dprint("uncaching " .. path)
	fs.find_cache[path:match("(.+/)")] = nil
	fs.get_attributes_cache[path] = nil
end

function fs.find(path)
	dprint("fs.find: ", path)

	if path:startswith("/") then
		path = path:sub(2)
	end

	local original_path = path

	dprint("fs.find: is " .. path .. " cached?")

	if fs.find_cache[path] then
		dprint("yes!")
		return fs.find_cache[path]
	end

	if path:endswith("/") then
		path = path .. "*"
	end

	local where = "GAME"

	if path:startswith("data/") then
		path = path:sub(6)
		where = "DATA"
	end

	local out

	local files, dirs = file_Find(path, where)

	if files then
		if where == "DATA" then
			for i, name in ipairs(files) do
				local new_name, count = name:gsub("%^", "%.")

				if count > 0 then
					files[i] = new_name:sub(0, -5)
				end
			end
		end

		out = table.add(files, dirs)
	end

	fs.find_cache[original_path] = out
	dprint("fs.find: caching results for dir " .. path)

	return out or {}
end

function fs.getcd()
	dprint("fs.getcd")
	return ""
end

function fs.setcd(path)
	dprint("fs.setcd: ", path)
end

function fs.createdir(path)
	dprint("fs.createdir: ", path)

	local path, where = GoluwaToGmodPath(path)

	file_CreateDir(path, where)
end

function fs.getattributes(path)
	dprint("fs.getattributes: ", path)
	local original_path = path

	if fs.get_attributes_cache[path] ~= nil then
		return fs.get_attributes_cache[path]
	end

	local path, where = GoluwaToGmodPath(path)

	if file_Exists(path, where) then
		local size = file_Size(path, where)
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

		fs.get_attributes_cache[original_path] = res

		return res
	else
		dprint("\t" .. path .. " " .. where .. " does not exist")
	end

	fs.get_attributes_cache[original_path] = false

	return false
end

return fs