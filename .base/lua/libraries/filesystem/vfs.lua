local vfs2 = _G.vfs2 or {}

vfs2 = {}

vfs2.use_appdata = false
vfs2.paths = vfs2.paths or {}

local data_prefix = "%DATA%"
local data_prefix_pattern = data_prefix:gsub("(%p)", "%%%1")

local silence
local function logf(fmt, ...)
	if silence then return end
	if _G.logf then _G.logf(fmt, ...) return end
	print(fmt:format(...))
end

local function warning(...)
	if silence then return end
	logf("[vfs2 error] %s\n", ...)
end

function vfs2.Silence(b)
	local old = silence
	silence = b
	return old == nil and b or old
end

function vfs2.DebugPrint(fmt, ...)
	logf("[VFS] %s\n", fmt:format(...))
end

do -- mounting/links
	function vfs2.Mount(where, to)
		check(where, "string")
		to = to or ""

		vfs2.Unmount(where, to)
		
		local path_info_where = vfs2.GetPathInfo(where, true) 
		local path_info_to = vfs2.GetPathInfo(to, true)
				
		if to ~= "" and not path_info_to.filesystem then
			error("a filesystem has to be provided when mounting /to/ somewhere")
		end
				
		for i, context in ipairs(vfs2.GetFileSystems()) do
			context.mounted_paths = context.mounted_paths or {}
			if (path_info_to.filesystem == context.Name or path_info_to.filesystem == "unknown") then
				table.insert(context.mounted_paths, {where = path_info_where, to = path_info_to, full_where = where, full_to = to})
			end
		end
	end
		
	function vfs2.Unmount(where, to)
		check(where, "string")
		to = to or ""

		local path_info_where = vfs2.GetPathInfo(where, true) 
		local path_info_to = vfs2.GetPathInfo(to, true)
		
		for filesystem, context in pairs(vfs2.GetFileSystems()) do
			context.mounted_paths = context.mounted_paths or {}		
			for i, v in ipairs(context.mounted_paths) do
				if v.full_where == where and v.full_to == to and (path_info_where == filesystem or path_info_where.filesystem == "unknown") then
					table.remove(context.mounted_paths)
					break
				end
			end
		end
	end
	
	function vfs2.GetMounts()
		return vfs2.paths
	end

	function vfs2.TranslatePath(path, is_folder)
		local path_info = vfs2.GetPathInfo(path, is_folder)
		
		local out = {}
		
		local filesystems = vfs2.GetFileSystems()
		
		if path_info.filesystem ~= "unknown" then
			filesystems = {vfs2.GetFileSystem(path_info.filesystem)}
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
						where = vfs2.GetPathInfo(context.Name .. ":" .. mount_info.where.full_path .. path_info.full_path:sub(#mount_info.to.full_path+1), is_folder)
					else
						where = vfs2.GetPathInfo(context.Name .. ":" .. where.full_path .. path_info.full_path, is_folder)
					end
					
					table.insert(out, {path_info = where, context = context})
				end
			else
				table.insert(out, {path_info = path_info, context = context})
			end
		end
		
		return out
	end
end

do -- env vars/path preprocessing
	local env_override = {}
	
	function vfs2.GetEnv(key)
		local val = env_override[key]
		
		if type(val) == "function" then
			val = val()
		end
		
		return val or os.getenv(key)
	end
	
	function vfs2.SetEnv(key, val)
		env_override[key] = val
	end
	
	function vfs2.PreprocessPath(path)
		-- windows
		path = path:gsub("%%(.-)%%", vfs2.GetEnv)
		path = path:gsub("%%", "")		
		path = path:gsub("%$%((.-)%)", vfs2.GetEnv)
		
		-- linux
		path = path:gsub("%$%((.-)%)", "%1")
		
		return path
	end
end

do -- file systems
	vfs2.filesystems = vfs2.filesystems or {}
	
	function vfs2.RegisterFileSystem(META)
		META.TypeBase = "base"
		class.Register(META, "file_system", META.Name)
		
		for k,v in pairs(vfs2.filesystems) do
			if v.Name == META.Name then
				table.remove(vfs2.filesystems, k)
				break
			end
		end
		
		table.insert(vfs2.filesystems, class.Create("file_system", META.Name)) 
	end

	function vfs2.GetFileSystems()
		return vfs2.filesystems
	end
	
	function vfs2.GetFileSystem(name) 
		for i, v in ipairs(vfs2.filesystems) do
			if v.Name == name then
				return v
			end
		end
	end

	include("files/*", vfs2)

	for i, context in ipairs(vfs2.GetFileSystems()) do
		vfs2.mounted_paths = {}
		
		if context.VFSOpened then 
			context:VFSOpened()
		end	
	end
end

include("path_utilities.lua", vfs2)
include("base_file.lua", vfs2)
include("find.lua", vfs2)
include("helpers.lua", vfs2) 
include("async.lua", vfs2)
include("addons.lua", vfs2)
include("lua_utilities.lua", vfs2)

do -- translate path to useful data
	local function get_folders(self, typ, keep_last)
		if typ == "full" then
			local folders = {}
			
			for i = 0, 100 do
				local folder = vfs2.GetParentFolder(self.full_path, i)

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

	function vfs2.GetPathInfo(path, is_folder)
		local out = {}

		path = vfs2.PreprocessPath(path)
		path = vfs2.FixPath(path)

		out.filesystem = path:match("^(.-):")
		
		if vfs2.GetFileSystem(out.filesystem) then
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
	local path_info = vfs2.GetPathInfo(path, is_folder)
	
	if mode == "write" then
		if path_info.filesystem == "unknown" then
			-- default to userdata folder?
			error("tried to write to an unknown filesystem", 3)
		end
	end
end	

function vfs2.Open(path, mode, sub_mode)
	check(path, "string")
	mode = mode or "read"	
	check(sub_mode, "string", "nil")
	
	-- a filesystem must be provided when writing data
	-- since writing data in multiple locations at the same time
	-- would be confusing
	check_write_path(path)
	
	for i, data in ipairs(vfs2.TranslatePath(path)) do	
		local file = class.Create("file_system", data.context.Name)
		
		file:SetMode(mode)
		
		if file:PCall("Open", data.path_info) ~= false then
			return file
		end
	end

	return false, err or "no such file exists"
end
 
function vfs2.Test()

	if false then
		local info = vfs2.GetPathInfo("hello/yeah2", true)
		table.print(info)
		table.print(info:GetFolders())
		table.print(info:GetFolders("all"))
	end

	vfs2.debug = true

	local file = assert(vfs2.Open("memory:lol.wav", "write"))
	print(file:Write("LOL\n"))

	local file = assert(vfs2.Open("memory:lol.wav", "read"))
	print(file:ReadString(3))

	vfs2.CreateFolder("memory", "hello")
	vfs2.CreateFolder("memory", "hello/yeah1")
	vfs2.CreateFolder("memory", "hello/yeah2")
	local file = assert(vfs2.Open("memory:hello/lol.wav", "write"))
	file:Write("hello") 

	table.print(vfs2.Find("hello/"))
	---table.print(vfs2.GetFiles("."))

	local file = assert(vfs2.Open("G:/SteamLibrary/SteamApps/Common/GarrysMod/sourceengine/hl2_sound_vo_english_dir.vpk/sound/vo/npc/male01/abouttime02.wav"))

	table.print(vfs2.Find("G:/SteamLibrary/SteamApps/Common/GarrysMod/sourceengine/hl2_sound_vo_english_dir.vpk/sound/vo/"))

	local snd = audio.CreateSource(audio.Decode(file:ReadAll()))  
	table.print(snd.decode_info)

	vfs2.Mount("G:/SteamLibrary/SteamApps/Common/", "memory:hello/")
	vfs2.Mount("G:/SteamLibrary/", "hello/")
		
	local function compare_find(path)
		local asdf = vfs.Find(path)
		for k, v in pairs(vfs2.Find(path)) do
			if not table.hasvalue(asdf, v) then
				print(v)
			end
		end
	end
	
	compare_find("")
	compare_find("lua/")	

	table.print(vfs2.Find("hello/nexuiz/bin32/", true))
	
	for k, v in ipairs(vfs2.TranslatePath("lua/", true)) do print(v.path_info.full_path, v.context.Name) end
	
	local file = vfs2.Open("%DATA%/vfs_test", "write") 
	file:Write("yeah")
	file:Close()
end

if _G.vfs then
	for k, v in pairs(vfs.paths) do
		vfs2.Mount(v, "os:/")
	end
	
	_G.vfs2 = vfs2
	
	vfs2.debug = true

	vfs2.MountAddon("C:/goluwa/shell32/")
	table.print(vfs2.GetAllAddons())
	
	--local file = vfs2.Open("G:/SteamLibrary/SteamApps/common/Crysis Wars/Game/GameData.pak/Scripts/callbacks.txt", "read")
	--table.print(file:ReadAll():explode("\n"))
end

return vfs2