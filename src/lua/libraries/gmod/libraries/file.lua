local gmod = ... or _G.gmod

local file = gmod.env.file

local search_paths = {
	GAME = "",
	LUA = "lua/",
	DATA = gmod.dir .. "data/",
	DOWNLOAD = gmod.dir .. "download/",
	MOD = gmod.dir,
	BASE_PATH = gmod.dir .. "../bin/",
}

function file.Open(path, how)
	if how:find("w") then
		warning("nyi file open write")
		return
	end

	local self = vfs.Open(path, how)

	if self then
		return gmod.WrapObject(self, "File")
	end
end


function file.Write(name, str)
	vfs.Write(search_paths.DATA .. name, str)
end

function file.Read(path, where)
	where = where or "DATA"
	return vfs.Read(search_paths[where] .. path)
end

function file.Find(path, where)
	local files, folders = {}, {}

	path = path:gsub("%.", ".")
	path = path:gsub("%*", ".*")

	if where == "LUA" then
		for k,v in ipairs(vfs.Find("lua/" .. path, true)) do
			if v:startswith(gmod.dir) then
				if vfs.IsDirectory(v) then
					table.insert(folders, v:match(".+/(.+)"))
				else
					table.insert(files, v:match(".+/(.+)"))
				end
			end
		end
	else
		for k,v in ipairs(vfs.Find(path, true)) do
			if vfs.IsDirectory(v) then
				table.insert(folders, v:match(".+/(.+)"))
			else
				table.insert(files, v:match(".+/(.+)"))
			end
		end
	end

	return files, folders
end

function file.Exists(path, where)
	where = where or "DATA"
	return vfs.Exists(search_paths[where] .. path)
end

function file.IsDir(path, where)
	where = where or "DATA"
	return vfs.IsDirectory(search_paths[where] .. path)
end

function file.Size(path, where)
	where = where or "DATA"
	local str = vfs.Read(search_paths[where] .. path)
	if str then
		return #str
	end
	return 0
end

function file.Time(path, where)
	where = where or "DATA"
	return vfs.GetLastModified(search_paths[where] .. path) or 0
end