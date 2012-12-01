MMYY_PLATFORM = MMYY_PLATFORM or ({...})[1] or nil

local status, err = pcall(function()

Msg = Msg or print
MsgN = MsgN or print

USERNAME = tostring(os.getenv("USERNAME")):upper():gsub(" ", "_"):gsub("%p", "")
_G[USERNAME] = true

MsgN("")
MsgN("=========================================")
MsgN("=========== initializing mmyy ===========")
MsgN("============ using platform =============")
MsgN(MMYY_PLATFORM)
MsgN("")

local function GetSource(level)
	return debug.getinfo(level or 1).source:gsub("\\", "/"):sub(2):gsub("//", "/")
end

local function Folder(level)
	return (GetSource(level):match("(.*)/") or LUA_FOLDER) .. "/"
end

LUA_FOLDER = Folder()
BASE_FOLDER = LUA_FOLDER:match("(.-)lua/")

--[[BASE_FOLDER = BASE_FOLDER:gsub("/$", "")
LUA_FOLDER = LUA_FOLDER:gsub("/$", "")

print(BASE_FOLDER, LUA_FOLDER)]]

do -- virtual folders
	local virtual_folders = {BASE_FOLDER}

	function AddVirtualFolder(path)
		return table.insert(virtual_folders, path)
	end

	function GetVirtualFolders()
		return virtual_folders
	end

	function Path(path, external_request)
		if not file.Exists(path, true) then
			for idx, folder in pairs(GetVirtualFolders()) do
				if file.Exists(folder .. path, true) then
					return BASE_FOLDER .. folder .. path
				end
			end
		end

		return not external_request and path or nil
	end
end

local lib_name

local function load_module(path)
	path = path:gsub("!/", "")
	local func = package.loadlib(path, lib_name or "main")
	return func, ""
end

--[[local function loadfile(path)
	local fil, msg = io.open(path)
	--print(msg)
	if fil then
		local str = fil:read("*a")
		if hook then
			hook.Call("RunString", str)
		end
		var, msg = loadstring(str, path)
		fil:close()
	else
		var = nil
	end

	--print(msg)

	return var, msg
end]]

function _include(path, ...)

	local loader = loadfile

	if path:sub(-3) == "dll" then
		lib_name = ({...})[1]
		loader = load_module
	end

	local func, msg = loader(Folder(5) .. path)

	if not func and msg:find("No such file or directory") then
		func, msg = loader(Path("lua/" .. path))
		if not func and msg:find("No such file or directory") then
			func, msg = loader(Path(path))
		end
	end


	if func then
		--print("including: " .. path)

		return func
	else
		MsgN(msg)
	end
end

function include(path, ...)
	if hook then
		local args = {hook.Call("LuaInclude", path, ...)}
		if args[1] == false then
			return select(2, unpack(args))
		end
	end
	
	if path:sub(-2) == "/*" then
		local folder = path:sub(0, -3)
		local new_path = Folder(4) .. folder

		if not file.FolderExists(new_path, true) then
			new_path = Path("lua/" .. folder)
		end

		for file_name in lfs.dir(new_path .. "/") do
			if file_name:find("%.lua") then
				local func = _include(new_path .. "/" .. file_name)
				if type(func) == "function" then
					func(...)
				end
			end
		end
	elseif path:sub(0, 7) == "http://" then
		if http then
			local args = {...}
			http.Get(path, function(data)
				local func, err = loadstring(data.content)
				
				if func then
					return func(unpack(args))
				else
					print(err)
				end
			end)
		end
	else
		local func = _include(path, ...)
		if type(func) == "function" then
			return func(...)
		end
	end
end

real_require = real_require or require
function require(...)
	local args = {pcall(real_require, ...)}

	if not args[1] then
		print(args[2])
		return
	end

	table.remove(args, 1)

	return unpack(args)
end

if X64 then
	package.cpath = package.cpath .. ";" .. (LUA_FOLDER:gsub("!/.", "") .. "/includes/modules/x64/?.dll"):gsub("/", "\\")
	package.path = package.path .. ";" .. (LUA_FOLDER:gsub("!/.", "") .. "/includes/modules/x64/?.lua"):gsub("/", "\\")
else
	package.cpath = package.cpath .. ";" .. (LUA_FOLDER:gsub("!/.", "") .. "/includes/modules/x86/?.dll"):gsub("/", "\\")
	package.path = package.path .. ";" .. (LUA_FOLDER:gsub("!/.", "") .. "/includes/modules/x86/?.lua"):gsub("/", "\\")
end

table.insert(package.loaders, function(...)
	print(...)
end)

-- libraries
include("includes/standard/libraries/hook.lua")
include("includes/standard/libraries/_G.lua")

include("includes/standard/libraries/file.lua")
include("includes/standard/libraries/addons.lua")
include("includes/standard/libraries/util.lua")
include("includes/standard/libraries/class.lua")
include("includes/standard/libraries/debug.lua")
include("includes/standard/libraries/luadata.lua")
include("includes/standard/libraries/math.lua")
include("includes/standard/libraries/string.lua")
include("includes/standard/libraries/table.lua")
include("includes/standard/libraries/timer.lua")
include("includes/standard/libraries/sigh.lua")
include("includes/standard/libraries/luasocket.lua")
include("includes/standard/libraries/ffi.lua")
include("includes/standard/libraries/lpeg.lua")
include("includes/standard/libraries/base64.lua")
include("includes/standard/libraries/path.lua")
include("includes/standard/libraries/input.lua")
include("includes/standard/libraries/msgpack.lua")
include("includes/standard/libraries/filesystem.lua")

-- meta
include("includes/standard/meta/nil.lua")

include("includes/"..(MMYY_PLATFORM or "nil").."/init.lua")
addons.LoadAll()

addons.AutorunAll(USERNAME)

print("ran init.lua")
hook.Call("Initialized")

MsgN("=========================================")
MsgN("=========== mmyy initialized ============")
MsgN("=========================================")
MsgN("")

end)

if not status then
	MsgN(err)
end