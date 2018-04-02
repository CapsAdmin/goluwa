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
	return vfs.GetFileNameFromPath(str):match(".+%.(%w+)") or ""
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

local character_translation = {
	["\\"] = "⟍",
	[":"] = "⠅",
	["*"] = "✱",
	["?"] = "❔",
	["<"] = "ᐸ",
	[">"] = "𝈷",
	["|"] = "ᥣ",
	["~"] = "𝀈",
	["#"] = "⧣",
	["\""] = "‟",
	["^"] = "ᣔ",
}

function vfs.FixIllegalCharactersInPath(path, forward_slash)
	local out = path:gsub(".", character_translation)

	if forward_slash then
		out = out:gsub("/", "⟋")
	end

	return out
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
		local ok, err = vfs.CreateDirectory(path_info.filesystem ..":"..  folder, force)
		if not ok then
			return nil, err
		end
	end

	return true
end

function vfs.GetAbsolutePath(path, is_folder)
	if vfs.IsPathAbsolute(path) then
		if
			(is_folder == true and vfs.IsDirectory(path)) or
			(is_folder == false and vfs.IsFile(path)) or
			vfs.Exists(path)
		then
			return path
		end
	end

	for _, data in ipairs(vfs.TranslatePath(path, is_folder)) do
		if data.context:CacheCall("IsFile", data.path_info) or data.context:CacheCall("IsFolder", data.path_info) then
			return data.path_info.full_path
		end
	end
end