local start_time = os.clock()

if not os.getenv("GOLUWA_CLI") then
	if os.getenv("GOLUWA_CLI_TIME") then
		io.write("[runfile] ", os.getenv("GOLUWA_CLI_TIME"), " seconds spent in ./goluwa", jit.os == "Windows" and ".cmd" or "", "\n")
	end

	if os.getenv("GOLUWA_BOOT_TIME") then
		io.write("[runfile] ", os.getenv("GOLUWA_BOOT_TIME"), " seconds spent in core/lua/boot.lua\n")
	end
end

os.setlocale("")
io.stdout:setvbuf("no")

do
	local ok, opt = pcall(require, "jit.opt")
	if ok then
		opt.start(
			"maxtrace=65535", -- 1000 1-65535: maximum number of traces in the cache
			"maxrecord=20000", -- 4000: maximum number of recorded IR instructions
			"maxirconst=2500", -- 500: maximum number of IR constants of a trace
			"maxside=100", -- 100: maximum number of side traces of a root trace
			"maxsnap=800", -- 500: maximum number of snapshots for a trace
			"minstitch=0", -- 0: minimum number of IR ins for a stitched trace.
			"hotloop=56", -- 56: number of iterations to detect a hot loop or hot call
			"hotexit=10", -- 10: number of taken exits to start a side trace
			"tryside=4", -- 4: number of attempts to compile a side trace
			"instunroll=500", -- 4: maximum unroll factor for instable loops
			"loopunroll=500", -- 15: maximum unroll factor for loop ops in side traces
			"callunroll=500", -- 3: maximum unroll factor for pseudo-recursive calls
			"recunroll=2", -- 2: minimum unroll factor for true recursion
			"maxmcode=8192", -- 512: maximum total size of all machine code areas in KBytes
			--jit.os == "x64" and "sizemcode=64" or "sizemcode=32", -- Size of each machine code area in KBytes (Windows: 64K)
			"+fold", -- Constant Folding, Simplifications and Reassociation
			"+cse", -- Common-Subexpression Elimination
			"+dce", -- Dead-Code Elimination
			"+narrow", -- Narrowing of numbers to integers
			"+loop", -- Loop Optimizations (code hoisting)
			"+fwd", -- Load Forwarding (L2L) and Store Forwarding (S2L)
			"+dse", -- Dead-Store Elimination
			"+abc", -- Array Bounds Check Elimination
			"+sink", -- Allocation/Store Sinking
			"+fuse" -- Fusion of operands into instructions
		)
	end
end

--loadfile("../../core/lua/modules/bytecode_cache.lua")()

local PROFILE_STARTUP = false

if PROFILE_STARTUP then
	local old = io.stdout
	io.stdout = {write = function(_, ...) io.write(...) end}
	require("jit.p").start("rplfvi1")
	io.stdout = old
end

-- put all c functions in a table so we can override them if needed
-- without doing the local oldfunc = print thing over and over again

if not _G._OLD_G then
	local _OLD_G = {}
	if pcall(require, "ffi") then
		_G.ffi = require("ffi")
	end

	for k,v in pairs(_G) do
		if k ~= "_G" then
			local t = type(v)
			if t == "function" then
				_OLD_G[k] = v
			elseif t == "table" then
				_OLD_G[k] = {}
				for k2, v2 in pairs(v) do
					if type(v2) == "function" then
						_OLD_G[k][k2] = v2
					end
				end
			end
		end
	end

	_G.ffi = nil
	_G._OLD_G = _OLD_G
end

local info = assert(debug.getinfo(1), "debug.getinfo(1) returns nothing")
local init_lua_path = info.source
local internal_addon_name = init_lua_path:match("^@.+/(.+)/lua/init.lua$") or "."

do -- constants
	if jit.os == "Windows" then
		_G.PLATFORM = "windows"
	elseif _G.GMOD == true then
		_G.PLATFORM = "gmod"
	else
		_G.PLATFORM = "unix"
	end

	-- enums table
	e = e or {}
	e.USERNAME = _G.USERNAME or tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
	e.INTERNAL_ADDON_NAME = internal_addon_name

	-- _G constants. should only contain you need to access a lot like if LINUX then
	_G[e.USERNAME:upper()] = true
	_G[jit.os:upper()] = true
	_G[jit.arch:upper()] = true

	_G.CLI = os.getenv("GOLUWA_CLI")
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
end

do
	local fs = loadfile("../../"..e.INTERNAL_ADDON_NAME.."/lua/libraries/platforms/"..PLATFORM.."/filesystem.lua")()
	package.loaded.fs = fs

	-- create constants
	e.BIN_FOLDER = fs.getcd():gsub("\\", "/") .. "/"
	e.ROOT_FOLDER = e.BIN_FOLDER:match("(.+/)" .. (".-/"):rep(2)) -- the root folder is always 2 directories up (data/os_arch)
	e.CORE_FOLDER = e.ROOT_FOLDER .. e.INTERNAL_ADDON_NAME .. "/"
	e.DATA_FOLDER = e.ROOT_FOLDER .. "data/"
	e.USERDATA_FOLDER = e.DATA_FOLDER .. "users/" .. e.USERNAME:lower() .. "/"
end

_G.runfile = function(path, ...) return loadfile(e.CORE_FOLDER .. path)(...) end

-- standard library extensions
runfile("lua/libraries/extensions/jit.lua")
runfile("lua/libraries/extensions/globals.lua")
runfile("lua/libraries/extensions/debug.lua")
runfile("lua/libraries/extensions/string.lua")
runfile("lua/libraries/extensions/table.lua")
runfile("lua/libraries/extensions/os.lua")
runfile("lua/libraries/extensions/ffi.lua")
runfile("lua/libraries/extensions/math.lua")

utility = runfile("lua/libraries/utility.lua")
prototype = runfile("lua/libraries/prototype/prototype.lua")
vfs = runfile("lua/libraries/filesystem/vfs.lua")

vfs.Mount("os:" .. e.USERDATA_FOLDER, "os:data") -- mount "ROOT/data/users/*username*/" to "/data/"
vfs.MountAddon("os:" .. e.CORE_FOLDER) -- mount "ROOT/"..e.INTERNAL_ADDON_NAME to "/"
vfs.GetAddonInfo(e.INTERNAL_ADDON_NAME).dependencies = {e.INTERNAL_ADDON_NAME} -- prevent init.lua from running later on again
vfs.GetAddonInfo(e.INTERNAL_ADDON_NAME).startup = nil -- prevent init.lua from running later on again

vfs.AddModuleDirectory("lua/modules/")

_G.runfile = vfs.RunFile
_G.R = vfs.GetAbsolutePath -- a nice global for loading resources externally from current dir

-- libraries
crypto = runfile("lua/libraries/crypto.lua") -- base64 and other hash functions
serializer = runfile("lua/libraries/serializer.lua") -- for serializing lua data in different formats
system = runfile("lua/libraries/system.lua") -- os and luajit related functions like creating windows or changing jit options
event = runfile("lua/libraries/event.lua") -- event handler
utf8 = runfile("lua/libraries/utf8.lua") -- utf8 string library, also extends to string as utf8.len > string.ulen
profiler = runfile("lua/libraries/profiler.lua") -- for profiling

if THREAD then return end

-- tries to load all addons
-- some might not load depending on its info.lua file.
-- for instance: "load = CAPSADMIN ~= nil," will make it load
-- only if the CAPSADMIN constant is not nil.
-- this will skip the src folder though
vfs.MountAddons(e.ROOT_FOLDER)

if not CLI then
	logn("[runfile] ", os.clock() - start_time," seconds spent in core/lua/init.lua")
end


do -- autorun
	-- call goluwa/*/lua/init.lua if it exists
	vfs.InitAddons()

	-- load everything in goluwa/*/lua/autorun/*
	vfs.AutorunAddons()

	-- load everything in goluwa/*/lua/autorun/*USERNAME*/*
	vfs.AutorunAddons(e.USERNAME .. "/")
end

e.CLI_TIME = tonumber(os.getenv("GOLUWA_CLI_TIME")) or -1
e.BOOT_TIME = tonumber(os.getenv("GOLUWA_BOOT_TIME")) or -1
e.INIT_TIME = os.clock() - start_time
e.BOOTIME = os.clock()

event.Call("Initialize")

if not CLI then
	logn("[runfile] total init time took ", os.clock() - start_time, " seconds to execute")
end
system.MainLoop()

event.Call("ShutDown")
collectgarbage()
collectgarbage() -- https://stackoverflow.com/questions/28320213/why-do-we-need-to-call-luas-collectgarbage-twice
os.realexit(os.exitcode)
