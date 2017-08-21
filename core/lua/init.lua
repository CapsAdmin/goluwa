os.setlocale("")
io.stdout:setvbuf("no")

local info = assert(debug.getinfo(1), "debug.getinfo(1) returns nothing")
local init_lua_path = info.source
local internal_addon_name = assert(init_lua_path:match(".+/(.+)/lua/init.lua"), "could not find internal addon name from " .. init_lua_path)

do -- constants
	-- enums table for
	e = e or {}
	e.USERNAME = _G.USERNAME or tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
	e.INTERNAL_ADDON_NAME = internal_addon_name

	-- _G constants. should only contain you need to access a lot like if LINUX then
	_G[e.USERNAME:upper()] = true
	_G[jit.os:upper()] = true
	_G[jit.arch:upper()] = true
end

do
	-- force lookup modules in current directory rather than system
	if WINDOWS then
		package.cpath = "./?.dll"
	elseif OSX then
		package.cpath = "./?.dylib;./?.so"
	else
		package.cpath = "./?.so"
	end

	package.path = "./?.lua"

	-- force current directory
	local path = debug.getinfo(1).source

	if path:sub(1, 1) == "@" and pcall(require, ffi) then
		local ffi = require("ffi")

		path = path:gsub("\\", "/")

		local dir = path:match("@(.+/)"..e.INTERNAL_ADDON_NAME.."/lua/init.lua$")

		if dir then
			dir = dir .. "data/bin/" .. ffi.os .. "_" .. ffi.arch .. "/"
			dir = dir:lower()

			if WINDOWS then
				ffi.cdef("int SetCurrentDirectoryA(const char *);")
				ffi.C.SetCurrentDirectoryA(dir)
			else
				ffi.cdef("int chdir(const char *);")
				ffi.C.chdir(dir)
			end
		end
	end
end

-- put all c functions in a table so we can override them if needed
-- without doing the local oldfunc = print thing over and over again
do
	_OLD_G = {}
	local done = {[_G] = true}

	local function scan(tbl, store)
		for key, val in pairs(tbl) do
			local t = type(val)

			if t == "table" and not done[val] and val ~= store then
				store[key] = store[key] or {}
				done[val] = true
				scan(val, store[key])
			else
				store[key] = val
			end
		end
	end
	if pcall(require, "ffi") then
		_G.ffi = require("ffi")
	end
	scan(_G, _OLD_G)
	_G.ffi = nil
end

do
	-- this is required because fs needs winapi and syscall
	table.insert(package.loaders, function(name) name = name:gsub("%.", "/") return loadfile("../../../"..e.INTERNAL_ADDON_NAME.."/lua/modules/" .. name .. ".lua") end)
	table.insert(package.loaders, function(name) name = name:gsub("%.", "/") return loadfile("../../../"..e.INTERNAL_ADDON_NAME.."/lua/modules/" .. name .. "/init.lua") end)
	local fs = dofile("../../../"..e.INTERNAL_ADDON_NAME.."/lua/libraries/fs.lua")
	package.loaded.fs = fs
	-- remove the temporary added loaders from top because we do it properly later on
	table.remove(package.loaders)
	table.remove(package.loaders)

	-- create constants

	e.BIN_FOLDER = fs.getcd():gsub("\\", "/") .. "/"
	e.ROOT_FOLDER = e.BIN_FOLDER:match("(.+/)" .. (".-/"):rep(3)) -- the root folder is always 3 directories up (data/bin/os_arch)
	e.SRC_FOLDER = e.ROOT_FOLDER .. e.INTERNAL_ADDON_NAME .. "/"
	e.DATA_FOLDER = e.ROOT_FOLDER .. "data/"
	e.USERDATA_FOLDER = e.DATA_FOLDER .. "users/" .. e.USERNAME:lower() .. "/"

	fs.createdir(e.DATA_FOLDER)
	fs.createdir(e.DATA_FOLDER .. "users/")
	fs.createdir(e.USERDATA_FOLDER)
end

-- some of the lua files ran below use check and include which don't exist yet
_G.check = function() end
_G.runfile = function() end
_G.system = false
_G.event = false

local temp_runfile = function(path) return dofile(e.SRC_FOLDER .. path) end

-- standard library extensions
temp_runfile("lua/libraries/extensions/jit.lua")
temp_runfile("lua/libraries/extensions/globals.lua")
temp_runfile("lua/libraries/extensions/debug.lua")
temp_runfile("lua/libraries/extensions/string.lua")
temp_runfile("lua/libraries/extensions/table.lua")
temp_runfile("lua/libraries/extensions/os.lua")
temp_runfile("lua/libraries/extensions/ffi.lua")
temp_runfile("lua/libraries/extensions/math.lua")

-- include some of prototype as required by vfs
utility = {CreateWeakTable = function() return setmetatable({}, {__mode = "kv"}) end}

prototype = temp_runfile("lua/libraries/prototype/prototype.lua")
temp_runfile("lua/libraries/prototype/get_is_set.lua")
temp_runfile("lua/libraries/prototype/base_object.lua")
temp_runfile("lua/libraries/prototype/null.lua")


-- include some of vfs so we can setup and mount the filesystem
vfs = temp_runfile("lua/libraries/filesystem/vfs.lua")
temp_runfile("lua/libraries/filesystem/path_utilities.lua")
temp_runfile("lua/libraries/filesystem/base_file.lua")
temp_runfile("lua/libraries/filesystem/find.lua")
temp_runfile("lua/libraries/filesystem/helpers.lua")
temp_runfile("lua/libraries/filesystem/lua_utilities.lua")
temp_runfile("lua/libraries/filesystem/addons.lua")
temp_runfile("lua/libraries/filesystem/files/os.lua")

vfs.Mount("os:" .. e.USERDATA_FOLDER, "data") -- mount "ROOT/data/users/*username*/" to "/data/"
vfs.Mount("os:" .. e.BIN_FOLDER, "bin") -- mount "ROOT/data/bin" to "/bin/"
vfs.MountAddon("os:" .. e.SRC_FOLDER) -- mount "ROOT/"..e.INTERNAL_ADDON_NAME to "/"
vfs.GetAddonInfo(e.INTERNAL_ADDON_NAME).startup = nil -- prevent init.lua from running later on again

-- this will just make require("bit32") will have an early exit
package.preload.bit32 = function() error("we're luajit") end

vfs.AddModuleDirectory("lua/modules/")
vfs.AddModuleDirectory("lua/libraries/")

do -- full path
	vfs.AddPackageLoader(function(path)
		return vfs.LoadFile(path)
	end)

	vfs.AddPackageLoader(function(path)
		return vfs.LoadFile(path .. ".lua")
	end)

	vfs.AddPackageLoader(function(path)
		path = path:gsub("(.)%.(.)", "%1/%2")
		return vfs.LoadFile(path .. ".lua")
	end)

	vfs.AddPackageLoader(function(path)
		path = path:gsub("(.+/)(.+)", function(a, str) return a .. str:gsub("(.)%.(.)", "%1/%2") end)
		return vfs.LoadFile(path .. ".lua")
	end)
end

_G.runfile = function(...) local ret = {vfs.RunFile(...)} if not ret[1] and ret[2] then wlog(ret[2], 2) end return unpack(ret) end
_G.R = vfs.GetAbsolutePath -- a nice global for loading resources externally from current dir
_G.require = runfile("lua/libraries/require.lua") -- replace require with the pure lua version
_G.module = _G.require.module

-- now we can use runfile properly

-- libraries
prototype = runfile("lua/libraries/prototype/prototype.lua") -- handles classes, objects, etc

crypto = runfile("lua/libraries/crypto.lua") -- base64 and other hash functions
serializer = runfile("lua/libraries/serializer.lua") -- for serializing lua data in different formats

system = runfile("lua/libraries/system.lua") -- os and luajit related functions like creating windows or changing jit options
utility = runfile("lua/libraries/utilities/utility.lua") -- misc functions i don't know where to put

event = runfile("lua/libraries/event.lua") -- event handler

utf8 = runfile("lua/libraries/utf8.lua") -- utf8 string library, also extends to string as utf8.len > string.ulen
vfs = runfile("lua/libraries/filesystem/vfs.lua") -- include the filesystem again so it will include all the details such as zip file reading

-- tries to load all addons
-- some might not load depending on its info.lua file.
-- for instance: "load = CAPSADMIN ~= nil," will make it load
-- only if the CAPSADMIN constant is not nil.
-- this will skip the src folder though
vfs.MountAddons(e.ROOT_FOLDER)

system._CheckCreatedEnv()

do -- autorun
	-- call goluwa/*/lua/init.lua if it exists
	vfs.InitAddons()

	-- load everything in goluwa/*/lua/autorun/*
	vfs.AutorunAddons()

	-- load everything in goluwa/*/lua/autorun/*USERNAME*/*
	vfs.AutorunAddons(e.USERNAME .. "/")
end

event.Call("Initialize")
if system.MainLoop then
	system.MainLoop()
end
event.Call("ShutDown")
os.realexit(os.exitcode)
