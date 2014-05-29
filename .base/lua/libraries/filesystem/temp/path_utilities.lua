function vfs.GeFolderFromPath(str)
	return str:match("(.+/).+") or ""
end

function vfs.GetParentFolder(str, level)
	return str:match("(.*/)" .. (level == 0 and "" or (".*/"):rep(level or 1))) or ""
end

function vfs.GetFolderNameFromPath(str)
	if str:sub(#str, #str) == "/" then
		str = str:sub(0, #str - 1)
	end
	return str:match(".+/(.+)") or ""
end

function vfs.GetFileNameFromPath(str)
	return str:match(".+/(.+)") or ""
end

function vfs.GetExtensionFromPath(str)
	return str:match(".+%.(%a+)")
end

function vfs.GetFolderFromPath(self)
	return self:match("(.*)/") .. "/"
end

function vfs.GetFileFromPath(self)
	return self:match(".*/(.*)")
end

do
	local env_override = 
	{
		DATA = e.USERDATA_FOLDER,
		ROOT = e.ROOT_FOLDER,
		BASE = e.BASE_FOLDER,
		BIN = lfs.currentdir,
	}

	if vfs.use_appdata then
		if WINDOWS then
			vars.DATA = "%%APPDATA%%/.goluwa"
		end

		if LINUX then
			vars.DATA =  "%%HOME%%/.goluwa"
		end 
	end
	
	function vfs.GetEnv(key)
		local val = env_override[key]
		
		if type(val) == "function" then
			val = val()
		end
		
		return val or os.getenv(key)
	end
	
	function vfs.SetEnv(key, val)
		env_override[key] = val
	end
end

function vfs.IsPathAbsolute(path)
	if LINUX then
		return path:sub(1,1) == "/"
	end
	
	if WINDOWS then
		return path:sub(1, 2):find("%a:") ~= nil
	end
	
end
function vfs.ParseVariables(path)
	-- windows
	path = path:gsub("%%(.-)%%", vfs.GetEnv)
	path = path:gsub("%%", "")		
	path = path:gsub("%$%((.-)%)", vfs.GetEnv)
	
	-- linux
	path = path:gsub("%$%((.-)%)", "%1")
		
	return vfs.FixPath(path)
end

function vfs.FixPath(path)
	return (path:gsub("\\", "/"):gsub("(/+)", "/"))
end
	
function vfs.CreateFoldersFromPath(path)
	local dirs = {}
	
	for i = 0, 10 do
		local folder = vfs.GetParentFolder(path, i)
		if folder ~= "" then 
			table.insert(dirs, folder)
		else
			break
		end
	end
	
	for key, dir in ipairs(dirs) do
		lfs.mkdir(dir)
	end
end

function vfs.GetAbsolutePath(path, ...)
	check(path, "string")

	path = vfs.ParseVariables(path)

	for k, v in ipairs(vfs.paths) do
		if v.callback("file", "exists", v.root .. "/" .. path, ...) then
			return vfs.FixPath(v.root .. "/" .. path)
		end
	end
end