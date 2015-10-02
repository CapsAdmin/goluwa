local vfs = _G.vfs or {}

vfs.use_appdata = false

local data_prefix = "%DATA%"
local data_prefix_pattern = data_prefix:gsub("(%p)", "%%%1")

function vfs.DebugPrint(fmt, ...)
	logf("[VFS] %s\n", fmt:format(...))
end

do -- mounting/links
	function vfs.Mount(where, to, userdata)
		check(where, "string")
		to = to or ""

		vfs.Unmount(where, to)

		---print(where, to)

		local path_info_where = vfs.GetPathInfo(where, true)
		local path_info_to = vfs.GetPathInfo(to, true)

		if to ~= "" and not path_info_to.filesystem then
			error("a filesystem has to be provided when mounting /to/ somewhere")
		end

		for i, context in ipairs(vfs.GetFileSystems()) do
			if path_info_to.filesystem == context.Name or path_info_to.filesystem == "unknown" then
				table.insert(context.mounted_paths, {
					where = path_info_where,
					to = path_info_to,
					full_where = where,
					full_to = to,
					userdata = userdata
				})
			end
		end
	end

	function vfs.Unmount(where, to)
		check(where, "string")
		to = to or ""

		local path_info_where = vfs.GetPathInfo(where, true)
		local path_info_to = vfs.GetPathInfo(to, true)
		for _, context in ipairs(vfs.GetFileSystems()) do
			for i, v in ipairs(context.mounted_paths) do
				if
					v.full_where:lower() == where:lower() and
					v.full_to:lower() == to:lower() and
					(path_info_where.filesystem == context.Name or path_info_to.filesystem == "unknown")
				then
					table.remove(context.mounted_paths, i)
					break
				end
			end
		end
	end

	function vfs.GetMounts()
		local out = {}
		for filesystem, context in ipairs(vfs.GetFileSystems()) do
			for i, v in ipairs(context.mounted_paths) do
				out[v.full_where] = v
			end
		end
		return out
	end

	function vfs.TranslatePath(path, is_folder)
		local path_info = vfs.GetPathInfo(path, is_folder)

		local out = {}

		local filesystems = vfs.GetFileSystems()

		if path_info.filesystem ~= "unknown" then
			filesystems = {vfs.GetFileSystem(path_info.filesystem)}
		end

		for i, context in ipairs(filesystems) do
			if path_info.relative then
				for i, mount_info in ipairs(context.mounted_paths) do
					local where = mount_info.where

					-- does the path match the start of the to path?
					if
						(mount_info.where.filesystem == "unknown" or mount_info.where.filesystem == context.Name) and
						path_info.full_path:sub(0, #mount_info.to.full_path) == mount_info.to.full_path
					then
						-- if so we need to prepend it to make a new "where" path
						where = vfs.GetPathInfo(context.Name .. ":" .. mount_info.where.full_path .. path_info.full_path:sub(#mount_info.to.full_path+1), is_folder)
					else
						where = vfs.GetPathInfo(context.Name .. ":" .. where.full_path .. path_info.full_path, is_folder)
					end

					table.insert(out, {path_info = where, context = context, userdata = mount_info.userdata})
				end
			else
				table.insert(out, {path_info = path_info, context = context})
			end
		end

		return out
	end
end

do -- env vars/path preprocessing
	vfs.env_override = vfs.env_override or {}

	function vfs.GetEnv(key)
		local val = vfs.env_override[key]

		if type(val) == "function" then
			val = val()
		end

		return val or os.getenv(key)
	end

	function vfs.SetEnv(key, val)
		vfs.env_override[key] = val
	end

	function vfs.PreprocessPath(path)
		-- windows
		path = path:gsub("%%(.-)%%", vfs.GetEnv)
		path = path:gsub("%%", "")
		path = path:gsub("%$%((.-)%)", vfs.GetEnv)

		-- linux
		path = path:gsub("%$%((.-)%)", "%1")

		return path
	end
end

do -- file systems
	vfs.filesystems = vfs.filesystems or {}

	function vfs.RegisterFileSystem(META, is_base)
		META.TypeBase = "base"
		prototype.Register(META, "file_system", META.Name)

		if is_base then return end

		local context = prototype.CreateDerivedObject("file_system", META.Name)
		context.mounted_paths = {}

		for k,v in ipairs(vfs.filesystems) do
			if v.Name == META.Name then
				table.remove(vfs.filesystems, k)
				context.mounted_paths = v.mounted_paths
				break
			end
		end

		table.insert(vfs.filesystems, context)
	end

	function vfs.GetFileSystems()
		return vfs.filesystems
	end

	function vfs.GetFileSystem(name)
		for i, v in ipairs(vfs.filesystems) do
			if v.Name == name then
				return v
			end
		end
	end

	include("files/*", vfs)

	for i, context in ipairs(vfs.GetFileSystems()) do
		if context.VFSOpened then
			context:VFSOpened()
		end
	end
end

do -- translate path to useful data
	local function get_folders(self, typ, keep_last)
		if typ == "full" then
			local folders = {}

			for i = 0, 100 do
				local folder = vfs.GetParentFolder(self.full_path, i)

				if folder == "" then
					break
				end

				table.insert(folders, 1, folder)
			end

			--table.remove(folders) -- remove the filename

			return folders
		else
			local folders = self.full_path:explode("/")

			-- if the folder is something like "/foo/bar/" remove the first /
			if self.full_path:sub(1,1) == "/" then
				table.remove(folders, 1)
			end

			table.remove(folders) -- remove the filename

			return folders
		end
	end

	function vfs.GetPathInfo(path, is_folder)
		local out = {}

		path = vfs.PreprocessPath(path)
		path = vfs.FixPath(path)

		out.filesystem = path:match("^(.-):")

		if vfs.GetFileSystem(out.filesystem) then
			path = path:gsub("^(.-:)", "")
		else
			out.filesystem = "unknown"
		end

		local relative = path:sub(1, 1) ~= "/"

		if WINDOWS then
			relative = path:sub(2, 2) ~= ":"
		end

		if is_folder and not path:endswith("/") then
			path = path .. "/"
		end

		out.file_name = path:match(".+/(.*)") or path
		out.folder_name = path:match(".+/(.+)/") or path:match(".+/(.+)") or path:match("(.+)/") or path
		out.full_path = path
		out.relative = relative

		out.GetFolders = get_folders

		return out
	end
end

local function check_write_path(path, is_folder)
	local path_info = vfs.GetPathInfo(path, is_folder)

	if mode == "write" then
		if path_info.filesystem == "unknown" then
			-- default to userdata folder?
			error("tried to write to an unknown filesystem", 3)
		end
	end
end

function vfs.Open(path, mode, sub_mode)
	check(path, "string")
	mode = mode or "read"
	check(sub_mode, "string", "nil")

	-- a filesystem must be provided when writing data
	-- since writing data in multiple locations at the same time
	-- would be confusing
	check_write_path(path)

	for i, data in ipairs(vfs.TranslatePath(path)) do
		local file = prototype.CreateDerivedObject("file_system", data.context.Name)
		file:SetMode(mode)

		if file:PCall("Open", data.path_info) ~= false then
			return file
		else
			file:Remove()
		end
	end

	return false, "no such file exists"
end

include("path_utilities.lua", vfs)
include("base_file.lua", vfs)
include("find.lua", vfs)
include("helpers.lua", vfs)
include("addons.lua", vfs)
include("lua_utilities.lua", vfs)

return vfs