local vfs2 = (...) or _G.vfs2

function vfs2.GeFolderFromPath(str)
	return str:match("(.+/).+") or ""
end

function vfs2.GetParentFolder(str, level)
	return str:match("(.*/)" .. (level == 0 and "" or (".*/"):rep(level or 1))) or ""
end

function vfs2.GetFolderNameFromPath(str)
	if str:sub(#str, #str) == "/" then
		str = str:sub(0, #str - 1)
	end
	return str:match(".+/(.+)") or ""
end

function vfs2.GetFileNameFromPath(str)
	return str:match(".+/(.+)") or ""
end

function vfs2.GetExtensionFromPath(str)
	return str:match(".+%.(%a+)")
end

function vfs2.GetFolderFromPath(self)
	return self:match("(.*)/") .. "/"
end

function vfs2.GetFileFromPath(self)
	return self:match(".*/(.*)")
end

function vfs2.IsPathAbsolute(path)
	if LINUX then
		return path:sub(1,1) == "/"
	end
	
	if WINDOWS then
		return path:sub(1, 2):find("%a:") ~= nil
	end
	
end
function vfs2.ParseVariables(path)
	-- windows
	path = path:gsub("%%(.-)%%", vfs2.GetEnv)
	path = path:gsub("%%", "")		
	path = path:gsub("%$%((.-)%)", vfs2.GetEnv)
	
	-- linux
	path = path:gsub("%$%((.-)%)", "%1")
		
	return vfs2.FixPath(path)
end

function vfs2.FixPath(path)
	return (path:gsub("\\", "/"):gsub("(/+)", "/"))
end
	
function vfs2.CreateFoldersFromPath(filesystem, path)
	check(filesystem, "string")
	check(path, "string")
	
	if not vfs2.GetFileSystem(filesystem) then
		error("unknown filesystem " .. filesystem, 2)
	end
	
	local path_info = vfs2.GetPathInfo(path)
	local folders = path_info:GetFolders("full")
	
	local max = #folders
	
	for i = 1, #folders - 1 do
		local folder = folders[i]
		
		vfs2.CreateFolder(filesystem, folder)
	end
end

function vfs2.GetAbsolutePath(path, is_folder)
	check(path, "string")
	
	for i, data in ipairs(vfs2.TranslatePath(path, is_folder)) do	
		if data.context:PCall("IsFile", data.path_info) or data.context:PCall("IsFolder", data.path_info) then
			return data.path_info.full_path
		end
	end
end