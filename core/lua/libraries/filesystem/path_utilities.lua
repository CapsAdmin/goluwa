local vfs = (...) or _G.vfs

function vfs.GetParentFolderFromPath(str, level)
	level = level or 1
	for i = #str, 1, -1 do
		local char = str:sub(i, i)
		if char == "/" then
			level = level - 1
		end
		if level == -1 then
			return str:sub(0, i)
		end
	end
	return ""
end

function vfs.GetFolderNameFromPath(str)
	if str:sub(#str, #str) == "/" then
		str = str:sub(0, #str - 1)
	end
	return str:match(".+/(.+)") or str:match(".+/(.+)/") or str:match(".+/(.+)") or str:match("(.+)/")
end

function vfs.GetFileNameFromPath(str)
	local pos = (str):reverse():find("/", 0, true)
	return pos and str:sub(-pos + 1) or str
end

function vfs.RemoveExtensionFromPath(str)
	return str:match("(.+)%..+") or str
end

function vfs.GetExtensionFromPath(str)
	return vfs.GetFileNameFromPath(str):match(".+%.(%a+)")
end

function vfs.GetFolderFromPath(str)
	return str:match("(.*)/") .. "/"
end

function vfs.GetFileFromPath(str)
	return str:match(".*/(.*)")
end

function vfs.IsPathAbsolutePath(path)
	if LINUX then
		return path:sub(1,1) == "/"
	end

	if WINDOWS then
		return path:sub(1, 2):find("%a:") ~= nil
	end

end
function vfs.ParsePathVariables(path)
	-- windows
	path = path:gsub("%%(.-)%%", vfs.GetEnv)
	path = path:gsub("%%", "")
	path = path:gsub("%$%((.-)%)", vfs.GetEnv)

	-- linux
	path = path:gsub("%$%((.-)%)", "%1")

	return path
end

local illegal_characters = {
	[":"] = "_semicolon_",
	["*"] = "_star_",
	["?"] = "_questionmark_",
	["<"] = "_less_than_",
	[">"] = "_greater_than_",
	["|"] = "_line_",
}

function vfs.FixIllegalCharactersInPath(path)
	for k,v in pairs(illegal_characters) do
		path = path:gsub("%"..k, v)
	end
	return path
end

function vfs.FixPathSlashes(path)
	return (path:gsub("\\", "/"):gsub("(/+)", "/"))
end

function vfs.CreateDirectoriesFromPath(path, force)
	local path_info = vfs.GetPathInfo(path, true)
	local folders = path_info:GetFolders("full")

	local max = #folders

	if not path:endswith("/") then
		max = max - 1
	end

	for i = 1, max do
		local folder = folders[i]
		vfs.CreateDirectory(path_info.filesystem ..":"..  folder, force)
	end
end

function vfs.GetAbsolutePath(path, is_folder)
	if vfs.IsPathAbsolute(path) and ((is_folder and vfs.IsDirectory(path)) or vfs.Exists(path)) then
		return path
	end

	for _, data in ipairs(vfs.TranslatePath(path, is_folder)) do
		if data.context:CacheCall("IsFile", data.path_info) or data.context:CacheCall("IsFolder", data.path_info) then
			return data.path_info.full_path
		end
	end
end