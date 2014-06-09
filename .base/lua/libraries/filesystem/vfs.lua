local vfs2 = _G.vfs2 or {}

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

function vfs2.Mount(where, to)
	check(where, "string")
	to = to or ""

	vfs2.Unmount(where, to)
	
	local path_info_where = vfs2.GetPathInfo(where, true) 
	local path_info_to = vfs2.GetPathInfo(to, true)
	
	if to ~= "" and not path_info_to.filesystem then
		error("a filesystem has to be provided when mounting /to/ somewhere")
	end
	
	for filesystem, context in pairs(vfs2.GetRegisteredFileSystems()) do
		context.mounted_paths = context.mounted_paths or {}
		if path_info_where.filesystem == filesystem or path_info_where.filesystem == "unknown" then
			table.insert(context.mounted_paths, {where = path_info_where, to = path_info_to, full_where = where, full_to = to})
		end
	end
end
	
function vfs2.Unmount(where, to)
	check(where, "string")
	to = to or ""

	local path_info_where = vfs2.GetPathInfo(where, true) 
	local path_info_to = vfs2.GetPathInfo(to, true)
	
	for filesystem, context in pairs(vfs2.GetRegisteredFileSystems()) do
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

function vfs2.Register(META)
	META.TypeBase = "base"
	class.Register(META, "file", META.Name)
end

function vfs2.GetRegisteredFileSystems()
	return class.GetAll("file")
end

function vfs2.GetFileSystem(name)
	return vfs2.GetRegisteredFileSystems()[name]
end

include("path_utilities.lua", vfs2)
include("base_file.lua", vfs2)
include("files/*", vfs2)

for filesystem, context in pairs(vfs2.GetRegisteredFileSystems()) do
	vfs2.mounted_paths = {}
	
	if context.VFSOpened then 
		context:VFSOpened()
	end	
end

do	
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

		path = vfs2.FixPath(path)
		
		if is_folder and not path:endswith("/") then
			path = path .. "/"
		end
	
		out.filesystem = path:match("^(.-):")
		
		if vfs2.GetRegisteredFileSystems()[out.filesystem] then
			path = path:gsub("^(.-:)", "")
		else
			out.filesystem = "unknown"
		end
			
		out.file_name = path:match(".+/(.*)") or path
		out.folder_name = path:match(".+/(.+)/") or path:match(".+/(.+)") or path:match("(.+)/") or path
		out.full_path = path
		
		out.GetFolders = get_folders
				
		return out
	end
	
	function vfs2.PrependPathInfo(path_info_a, path_info_b)
	
		if path_info_a.full_path == "" then
			return path_info_b
		end
		
		local path_info_b = table.copy(path_info_b)
	
		local path = vfs2.FixPath(path_info_a.full_path .. path_info_b.full_path)
		path_info_b.full_path = path
		path_info_b.folder_name = path:match(".+/(.+)/") or path:match(".+/(.+)") or path:match("(.+)/") or path
		
		return path_info_b
	end
end

function vfs2.Open(path, mode, sub_mode)
	check(path, "string")
	mode = mode or "read"	
	check(sub_mode, "string", "nil")
	
	local path_info = vfs2.GetPathInfo(path)
	local filesystems
	
	if mode == "write" then
		if path_info.filesystem == "unknown" then
			error("tried to write to an unknown filesystem", 2)
		end
		
		filesystems = {[path_info.filesystem] = true}
	else
		filesystems = vfs2.GetRegisteredFileSystems()
	end
	
	for filesystem in pairs(filesystems) do	
		local file = class.Create("file", filesystem)
		file:SetMode(mode)
		
		local ok, err = pcall(file.Open, file, path_info)
		
		if vfs2.debug and not ok then
			vfs2.DebugPrint("%s: error opening file: %s", filesystem, err)
		end
		
		if ok then
			return file
		end
	end

	return false, err or "no such file exists"
end

function vfs2.CreateFolder(filesystem, folder)
	check(filesystem, "string")
	check(folder, "string")
	
	local context = vfs2.GetFileSystem(filesystem)
	
	if not context then
		error("unknown filesystem " .. filesystem, 2)
	end
	
	local path_info = vfs2.GetPathInfo(folder, true)
	
	for i, folder in ipairs(path_info:GetFolders("full", true)) do
		context:CreateFolder(vfs2.GetPathInfo(folder))
	end
end

do
	local function get_files(context, filesystem, path_info, out, info, full_path)
		local ok, found = pcall(context.GetFiles, context, path_info)
		
		if vfs2.debug and not ok then
			vfs2.DebugPrint("%s: error getting files: %s", filesystem, found)
		end
		
		if ok then	
			for i, v in pairs(found) do
				if full_path then
					v = filesystem .. ":" .. path_info.full_path .. v
				end
				
				if info then
					table.insert(out, {
						name = v, 
						filesystem = filesystem,
						full_path = filesystem .. ":" .. path_info.full_path .. v,
					})
				else
					table.insert(out, v)
				end
			end
		end
	end

	function vfs2.GetFiles(path, info, full_path)
		local path_info = vfs2.GetPathInfo(path, true)
		
		local out = {}
		
		for filesystem, context in pairs(vfs2.GetRegisteredFileSystems()) do	
			-- get files normally first
			get_files(context, filesystem, path_info, out, info, full_path)
			
			-- then check if there's any mounted "to" paths
			for i, mount_info in ipairs(context.mounted_paths) do
				local where = mount_info.where
				
				if mount_info.to.full_path ~= "" then
					if -- does the path match the start of the to path?
						(
							mount_info.where.filesystem == "unknown" or 
							mount_info.where.filesystem == filesystem
						) and
						path_info.full_path:sub(0, #mount_info.to.full_path) == mount_info.to.full_path 
					then	
						-- if so we need to prepend it to make a new "where" path
						where = vfs2.GetPathInfo(filesystem .. ":" .. mount_info.where.full_path .. path_info.full_path:sub(#mount_info.to.full_path+1), true)
						get_files(context, filesystem, where, out, info, full_path)
					end
				else
					get_files(context, filesystem, where, out, info, full_path)
				end
			end
		end
		
		return out
	end
end
 
vfs2.Mount("", "")

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

table.print(vfs2.GetFiles("hello/"))
---table.print(vfs2.GetFiles("."))

local file = assert(vfs2.Open("G:/SteamLibrary/SteamApps/Common/GarrysMod/sourceengine/hl2_sound_vo_english_dir.vpk/sound/vo/npc/male01/abouttime02.wav"))

table.print(vfs2.GetFiles("G:/SteamLibrary/SteamApps/Common/GarrysMod/sourceengine/hl2_sound_vo_english_dir.vpk/sound/vo/"))

local snd = audio.CreateSource(audio.Decode(file:ReadAll()))  
table.print(snd.decode_info)

vfs2.Mount("G:/SteamLibrary/SteamApps/Common/", "memory:hello/")
vfs2.Mount("G:/SteamLibrary/", "hello/")

table.print(vfs2.GetFiles("hello/nexuiz/bin32/", true))

_G.vfs2 = vfs2

return vfs2