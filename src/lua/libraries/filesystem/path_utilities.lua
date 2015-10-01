local vfs = (...) or _G.vfs

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

function vfs.FixPath(path)
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

	local max = #folders

	for i = 1, #folders - 1 do
		local folder = folders[i]

		vfs.CreateFolder(filesystem ..":"..  folder)
	end
end

function vfs.GetAbsolutePath(path, is_folder)
	--check(path, "string")

	for i, data in ipairs(vfs.TranslatePath(path, is_folder)) do
		if data.context:PCall("IsFile", data.path_info) or data.context:PCall("IsFolder", data.path_info) then
			return data.path_info.full_path
		end
	end
end