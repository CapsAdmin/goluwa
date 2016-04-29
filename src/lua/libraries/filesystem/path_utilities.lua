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
	return str:sub(-(str):reverse():find("/", 0, true) + 1)
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

function vfs.CreateFoldersFromPath(filesystem, path)
	check(filesystem, "string")
	check(path, "string")

	if not vfs.GetFileSystem(filesystem) then
		error("unknown filesystem " .. filesystem, 2)
	end

	local path_info = vfs.GetPathInfo(path)
	local folders = path_info:GetFolders("full")

	for i = 1, #folders - 1 do
		local folder = folders[i]

		vfs.CreateFolder(filesystem ..":"..  folder)
	end
end

function vfs.GetAbsolutePath(path, is_folder)
	for _, data in ipairs(vfs.TranslatePath(path, is_folder)) do
		if data.context:CacheCall("IsFile", data.path_info) or data.context:CacheCall("IsFolder", data.path_info) then
			return data.path_info.full_path
		end
	end
end