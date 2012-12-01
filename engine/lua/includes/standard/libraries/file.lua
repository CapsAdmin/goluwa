file = file or {}

local data_folder = BASE_FOLDER .. "data/"

local function SafeClose(fil)
	if fil and io.type(fil) == "file" then
		io.close(fil)
	end 
end

function file.Read(path, mode, root)
	check(path, "string")
	
	if not root and not (path:find("!", nil, true) or path:find(":", nil, true)) then
		path = data_folder .. path
	end

	local fil, err = io.open(path, "r" .. (mode or ""))

	if err then
		print(err)
		return fil, err
	end

	local content = fil:read("*a")
	SafeClose(fil)

	return content
end

function file.Rename(path, new, root)
	check(path, "string")
	check(new, "string")
	
	if not root and not (path:find("!", nil, true) or path:find(":", nil, true)) then
		path = data_folder .. path
		new = data_folder .. new
	end

	return os.rename(path, new)
end

function file.Delete(path, root)
	check(path, "string")
	
	if not root and not (path:find("!", nil, true) or path:find(":", nil, true)) then
		path = data_folder .. path 
	end

	return os.remove(path)
end

function file.Write(path, content, root, mode)
	check(path, "string")
	
	if not root and not (path:find("!", nil, true) or path:find(":", nil, true)) then
		path = data_folder .. path 
	end
	
	content = content and tostring(content) or ""

	local fil, err = io.open(path, "w" .. (mode or ""))
	
	if err and err:FindSimple("No such file or directory") then
		local dirs = {}
		for i=0, 10 do
			local folder = _G.path.GetParentFolder(path, i)
			if folder ~= "" then 
				table.insert(dirs, folder)
			else
				break
			end
		end
		for key, dir in ipairs(dirs) do
			if dir ~= "!/../" and dir ~= "!/" then
				lfs.mkdir(dir)
			end
		end
		fil, err = io.open(path, "w")
	end

	if fil and fil:write(content) then
		SafeClose(fil)
	end

	return fil, err
end

function file.Exists(path, root)
	check(path, "string")
	
	if not root and not (path:find("!", nil, true) or path:find(":", nil, true)) then
		path = data_folder .. path 
	end

	local fil, msg = io.open(BASE_FOLDER .. path, "r")
	local bool = fil ~= nil

	SafeClose(fil)

	return bool
end

function file.Find(path, root)
	lfs = lfs or require("lfs")
	local tbl = {}

	if not root and not (path:find("!", nil, true) or path:find(":", nil, true)) then
		path = data_folder .. path 
	end

	local pattern = _G.path.GetFilename(path)
	if pattern == "" or pattern == "*" then
		pattern = "."
	else
		pattern = pattern:gsub("%*", ".-")
	end

	path = _G.path.GetFolder(path)

	for key, val in lfs.dir(BASE_FOLDER .. path) do
		if key ~= "." and key ~= ".." and key:find(pattern) then
			tbl[key] = key
		end
	end

	return tbl
end

-- this is windows specific.. hmmm
function file.FolderExists(path, root)
	check(path, "string")

	if not root and not (path:find("!", nil, true) or path:find(":", nil, true)) then
		path = data_folder .. path 
	end
	
	return file.Exists(path .. "/NUL") ~= nil
end