local vfs = _G.vfs or {}
vfs.use_appdata = false
vfs.mounted_paths = vfs.mounted_paths or {}

do -- mounting/links
	function vfs.Mount(where, to, userdata)
		to = to or ""

		if not vfs.IsDirectory(where) then
			llog("attempted to mount non existing directory ", where)
			return false
		end

		vfs.ClearCallCache()
		vfs.Unmount(where, to)
		local path_info_where = vfs.GetPathInfo(where, true)
		local path_info_to = vfs.GetPathInfo(to, true)

		if path_info_where.filesystem == "unknown" then
			for context, info in pairs(vfs.DescribePath(where, true)) do
				if info.is_folder then
					path_info_where.filesystem = context.Name
					where = context.Name .. ":" .. where
				end
			end
		end

		if to ~= "" and not path_info_to.filesystem then
			error("a filesystem has to be provided when mounting /to/ somewhere")
		end

		--llog("mounting ", path_info_where.full_path, " -> ", path_info_to.full_path)
		list.insert(
			vfs.mounted_paths,
			{
				where = path_info_where,
				to = path_info_to,
				full_where = where,
				full_to = to,
				userdata = userdata,
			}
		)
	end

	function vfs.Unmount(where, to)
		to = to or ""
		vfs.ClearCallCache()

		for i, v in ipairs(vfs.mounted_paths) do
			if v.full_where:lower() == where:lower() and v.full_to:lower() == to:lower() then
				list.remove(vfs.mounted_paths, i)
				return true
			end
		end

		return false
	end

	function vfs.GetMounts()
		local out = {}

		for _, v in ipairs(vfs.mounted_paths) do
			out[v.full_where] = v
		end

		return out
	end

	function vfs.TranslatePath(path, is_folder)
		local path_info = vfs.GetPathInfo(path, is_folder)
		local out = {}
		local out_i = 1

		if path_info.relative then
			for _, mount_info in ipairs(vfs.mounted_paths) do
				local where

				if path_info.full_path:sub(0, #mount_info.to.full_path) == mount_info.to.full_path then
					where = vfs.GetPathInfo(
						mount_info.where.filesystem .. ":" .. mount_info.where.full_path .. path_info.full_path:sub(#mount_info.to.full_path + 1),
						is_folder
					)
				elseif path_info.full_path ~= "/" then
					where = vfs.GetPathInfo(
						mount_info.where.filesystem .. ":" .. mount_info.where.full_path .. path_info.full_path,
						is_folder
					)
				else
					where = vfs.GetPathInfo(mount_info.where.filesystem .. ":" .. mount_info.to.full_path, is_folder)
				end

				if where then
					out[out_i] = {
						path_info = where,
						context = vfs.filesystems2[mount_info.where.filesystem],
						userdata = mount_info.userdata,
					}
					out_i = out_i + 1
				end
			end
		else
			local filesystems = vfs.GetFileSystems()

			if path_info.filesystem ~= "unknown" then
				filesystems = {vfs.GetFileSystem(path_info.filesystem)}
			end

			for _, context in ipairs(filesystems) do
				if
					(
						is_folder and
						context:IsFolder(path_info)
					) or
					(
						not is_folder and
						context:IsFile(path_info)
					)
				then
					out[out_i] = {path_info = path_info, context = context, userdata = path_info.userdata}
					out_i = out_i + 1
				elseif
					not is_folder and
					context:IsFolder({full_path = vfs.GetParentFolderFromPath(path_info.full_path)})
				then
					out[out_i] = {path_info = path_info, context = context, userdata = path_info.userdata}
					out_i = out_i + 1
				end
			end
		end

		return out
	end
end

do -- env vars/path preprocessing
	vfs.env_override = vfs.env_override or {}

	function vfs.GetEnv(key)
		local val = vfs.env_override[key]

		if type(val) == "function" then val = val() end

		return val or os.getenv(key)
	end

	function vfs.SetEnv(key, val)
		vfs.env_override[key] = val
	end

	function vfs.PreprocessPath(path)
		if path:find("%", nil, true) or path:find("$", nil, true) then
			-- windows
			path = path:gsub("%%(.-)%%", vfs.GetEnv)
			path = path:gsub("%%", "")
			path = path:gsub("%$%((.-)%)", vfs.GetEnv)
			-- linux
			path = path:gsub("%$%((.-)%)", "%1")
		end

		return path
	end
end

do -- file systems
	vfs.filesystems = vfs.filesystems or {}
	vfs.filesystems2 = vfs.filesystems2 or {}

	function vfs.RegisterFileSystem(META, is_base)
		META.TypeBase = "base"
		META.Position = META.Position or 0
		prototype.Register(META, "file_system", META.Name)

		if is_base then return end

		local context = prototype.CreateDerivedObject("file_system", META.Name)
		context.mounted_paths = {}

		for k, v in ipairs(vfs.filesystems) do
			if v.Name == META.Name then
				list.remove(vfs.filesystems, k)
				context.mounted_paths = v.mounted_paths

				break
			end
		end

		list.insert(vfs.filesystems, context)

		list.sort(vfs.filesystems, function(a, b)
			return a.Position < b.Position
		end)

		vfs.filesystems2[context.Name] = context
	end

	function vfs.GetFileSystems()
		return vfs.filesystems
	end

	function vfs.GetFileSystem(name)
		return vfs.filesystems2[name]
	end
end

do -- translate path to useful data
	function vfs.DescribePath(path, is_folder)
		local path_info = vfs.GetPathInfo(path, is_folder)
		local out = {}

		for _, context in ipairs(vfs.GetFileSystems()) do
			out[context] = {}

			if is_folder then
				out[context].is_folder = context:IsFolder(path_info)
			else
				out[context].is_folder = context:IsFolder(path_info)
				out[context].is_file = context:IsFile(path_info)
			end
		end

		return out
	end

	local function get_folders(self, typ)
		if typ == "full" then
			local folders = {}

			for i = 0, 100 do
				local folder = vfs.GetParentFolderFromPath(self.full_path, i)

				if folder == "" then break end

				list.insert(folders, 1, folder)
			end

			--list.remove(folders) -- remove the filename
			return folders
		else
			local folders = self.full_path:split("/")

			-- if the folder is something like "/foo/bar/" remove the first /
			if self.full_path:sub(1, 1) == "/" then list.remove(folders, 1) end

			list.remove(folders) -- remove the filename
			return folders
		end
	end

	local WINDOWS = _G.WINDOWS

	function vfs.IsPathAbsolute(path)
		if WINDOWS then return path:sub(2, 2) == ":" or path:sub(1, 2) == [[//]] end

		return path:sub(1, 1) == "/"
	end

	function vfs.GetPathInfo(path, is_folder)
		local out = {}
		local pos = path:find(":", 0, true)

		if pos then
			local filesystem = path:sub(0, pos - 1)

			if vfs.GetFileSystem(filesystem) then
				path = path:sub(pos + 1)
				out.filesystem = filesystem
			else
				out.filesystem = "unknown"
			end
		else
			out.filesystem = "unknown"
		end

		local relative = not vfs.IsPathAbsolute(path)

		if is_folder and not path:ends_with("/") then path = path .. "/" end

		out.full_path = path
		out.relative = relative
		out.GetFolders = get_folders
		return out
	end
end

function vfs.Open(path, mode, sub_mode)
	mode = mode or "read"
	local errors = {}
	local paths = vfs.TranslatePath(path)

	if #paths == 0 then list.insert(errors, path .. " does not exist") end

	for i, data in ipairs(paths) do
		local file = prototype.CreateDerivedObject("file_system", data.context.Name)
		file:SetMode(mode)
		local ok, err = file:Open(data.path_info)
		file.path_used = data.path_info.full_path

		if ok ~= false then
			if mode == "write" then vfs.ClearCallCache() end

			return file
		else
			file:Remove()
			local err = "\t" .. data.context.Name .. ": " .. err

			if errors[#errors] ~= err then list.insert(errors, err) end
		end
	end

	return false, "unable to open file: \n" .. list.concat(errors, "\n")
end

runfile("lua/libraries/filesystem/path_utilities.lua", vfs)
runfile("lua/libraries/filesystem/base_file.lua", vfs)
runfile("lua/libraries/filesystem/find.lua", vfs)
runfile("lua/libraries/filesystem/helpers.lua", vfs)
runfile("lua/libraries/filesystem/addons.lua", vfs)
runfile("lua/libraries/filesystem/lua_utilities.lua", vfs)
runfile("lua/libraries/filesystem/files/generic_archive.lua", vfs)
runfile("lua/libraries/filesystem/files/os.lua", vfs)

for _, context in ipairs(vfs.GetFileSystems()) do
	if context.VFSOpened then context:VFSOpened() end
end

return vfs