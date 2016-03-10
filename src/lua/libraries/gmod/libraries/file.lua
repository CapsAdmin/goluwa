local gmod = ... or _G.gmod

local file = gmod.env.file

function file.Write(name, str)
	vfs.Write(name, str)
end

function file.Find(path, where)
	local files, folders = {}, {}

	path = path:gsub("%.", ".")
	path = path:gsub("%*", ".*")

	if where == "LUA" then
		for k,v in ipairs(vfs.Find("lua/" .. path, nil, true)) do
			if v:startswith(gmod.dir) then
				if vfs.IsDirectory(v) then
					table.insert(folders, v:match(".+/(.+)"))
				else
					table.insert(files, v:match(".+/(.+)"))
				end
			end
		end
	else
		for k,v in ipairs(vfs.Find(path, nil, true)) do
			if vfs.IsDirectory(v) then
				table.insert(folders, v:match(".+/(.+)"))
			else
				table.insert(files, v:match(".+/(.+)"))
			end
		end
	end

	return files, folders
end

function file.Read(path)
	return vfs.Read(path)
end