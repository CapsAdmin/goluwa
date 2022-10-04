_G.TEST = (os.getenv("GOLUWA_ARG_LINE") or ""):find("test", nil, true)

pcall(function()
	local f = io.open(os.getenv("HOME") .. "/.goluwa.lua", "r")

	if f then
		local lua = f:read("*all")
		assert(loadstring(lua))()
		f:close()
	end
end)

if TEST then
	jit.off(true, true)
	local call_count = {}

	debug.sethook(
		function(event, line)
			if event == "call" then
				local info = debug.getinfo(2, "f")
				call_count[info.func] = (call_count[info.func] or 0) + 1
			end
		end,
		"c"
	)

	_G.FUNC_CALLS = call_count
end

local start_time = os.clock()

if (os.getenv("GOLUWA_ARG_LINE") or ""):find("--verbose", nil, true) or TEST then
	_G.VERBOSE = true
end

local OS = jit and jit.os:lower() or "unknown"
local ARCH = jit and jit.arch:lower() or "unknown"

if pcall(require, "jit.opt") then
	jit.opt.start(
		"maxtrace=65535", -- 1000 1-65535: maximum number of traces in the cache
		"maxrecord=20000", -- 4000: maximum number of recorded IR instructions
		"maxirconst=500", -- 500: maximum number of IR constants of a trace
		"maxside=100", -- 100: maximum number of side traces of a root trace
		"maxsnap=800", -- 500: maximum number of snapshots for a trace
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

	if jit.version_num >= 20100 then
		jit.opt.start("minstitch=0") -- 0: minimum number of IR ins for a stitched trace.
	end
end

--loadfile("core/lua/modules/bytecode_cache.lua")()
-- put all c functions in a table so we can override them if needed
-- without doing the local oldfunc = print thing over and over again
if not _G._OLD_G then
	local _OLD_G = {}

	if pcall(require, "ffi") then _G.ffi = require("ffi") end

	for k, v in pairs(_G) do
		if k ~= "_G" then
			local t = type(v)

			if t == "function" then
				_OLD_G[k] = v
			elseif t == "table" then
				_OLD_G[k] = {}

				for k2, v2 in pairs(v) do
					if type(v2) == "function" then _OLD_G[k][k2] = v2 end
				end
			end
		end
	end

	_G.ffi = nil
	_G._OLD_G = _OLD_G
end

do -- constants
	-- enums table
	e = e or {}
	e.USERNAME = _G.USERNAME or
		tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
	e.INTERNAL_ADDON_NAME = "core"
	e.ROOT_FOLDER = "./"

	if pcall(require, "ffi") then
		local ffi = require("ffi")
		pcall(ffi.load, "pthread")

		if OS == "windows" then
			ffi.cdef("unsigned long GetCurrentDirectoryA(unsigned long, char *);")
			local buffer = ffi.new("char[260]")
			local length = ffi.C.GetCurrentDirectoryA(260, buffer)
			e.ROOT_FOLDER = ffi.string(buffer, length):gsub("\\", "/") .. "/"
		else
			ffi.cdef("char *strerror(int)")
			ffi.cdef("char *realpath(const char *, char *);")
			local resolved_name = ffi.new("char[?]", 256)
			local ret = ffi.C.realpath("./", resolved_name)

			if ret == nil then
				local num = ffi.errno()
				local err = ffi.string(ffi.C.strerror(num))
				err = err == "" and tostring(num) or err
				print("realpath failed: " .. err)
				print("defaulting to ./")
				e.ROOT_FOLDER = ""
			else
				e.ROOT_FOLDER = ffi.string(ret) .. "/"
			end
		end
	end

	e.BIN_FOLDER = e.ROOT_FOLDER .. (os.getenv("GOLUWA_BINARY_DIR") or "core/bin/linux_x64/") .. "/"
	e.CORE_FOLDER = e.ROOT_FOLDER .. e.INTERNAL_ADDON_NAME .. "/"
	e.STORAGE_FOLDER = e.ROOT_FOLDER .. "storage/"
	e.USERDATA_FOLDER = e.STORAGE_FOLDER .. "userdata/" .. e.USERNAME:lower() .. "/"
	e.SHARED_FOLDER = e.STORAGE_FOLDER .. "shared/"
	e.CACHE_FOLDER = e.STORAGE_FOLDER .. "cache/"
	e.TEMP_FOLDER = e.STORAGE_FOLDER .. "temp/"
	e.BIN_PATH = "bin/" .. OS .. "_" .. ARCH .. "/"
	-- _G constants. should only contain you need to access a lot like if LINUX then
	_G[e.USERNAME:upper()] = true
	_G[OS:upper()] = true
	_G[ARCH:upper()] = true

	if not _G.PLATFORM then
		if OS == "windows" then
			_G.PLATFORM = "windows"
		elseif OS == "linux" or OS == "osx" or OS == "bsd" then
			_G.PLATFORM = "unix"
			_G.UNIX = true
		else
			_G.PLATFORM = "unknown"
		end
	end
end

_G.runfile = function(path, ...)
	return assert(loadfile(e.ROOT_FOLDER .. e.INTERNAL_ADDON_NAME .. "/" .. path))(...)
end
runfile("lua/libraries/extensions/globals.lua")
_G.list = runfile("lua/libraries/list.lua")

do
	local fs

	if PLATFORM == "unix" then
		fs = runfile("lua/libraries/platforms/unix/filesystem.lua")
	elseif PLATFORM == "windows" then
		fs = runfile("lua/libraries/platforms/windows/filesystem.lua")
	elseif PLATFORM == "gmod" then
		fs = runfile("lua/libraries/platforms/gmod/filesystem.lua")
	elseif PLATFORM == "unknown" then
		fs = runfile("lua/libraries/platforms/unknown/filesystem.lua")
	end

	package.loaded.fs = fs
	fs.create_directory(e.STORAGE_FOLDER)
	fs.create_directory(e.STORAGE_FOLDER .. "/userdata/")
	fs.create_directory(e.USERDATA_FOLDER)
	fs.create_directory(e.CACHE_FOLDER)
	fs.create_directory(e.SHARED_FOLDER)
	fs.create_directory(e.TEMP_FOLDER)
	_G.fs = fs
end

-- standard library extensions
runfile("lua/libraries/extensions/gc_proxy_hack.lua")

do
	local logfile = runfile("lua/libraries/logging.lua")
	_G.logf_nospam = logfile.LogFormatNoSpam
	_G.logn_nospam = logfile.LogNewlineNoSpam
	_G.vprint = logfile.VariablePrint
	_G.wlog = logfile.WarningLog
	_G.llog = logfile.LibraryLog
	_G.log = logfile.Log
	_G.logn = logfile.LogNewline
	_G.print = logfile.Print
	_G.errorf = logfile.ErrorFormat
	_G.logf = logfile.LogFormat
	_G.logfile = logfile
end

runfile("lua/libraries/extensions/debug.lua")
runfile("lua/libraries/extensions/string.lua")
runfile("lua/libraries/extensions/string_format.lua")
runfile("lua/libraries/extensions/table.lua")
runfile("lua/libraries/extensions/os.lua")
runfile("lua/libraries/extensions/ffi.lua")
runfile("lua/libraries/extensions/math.lua")

do
	_G.utility = runfile("lua/libraries/utility/utility.lua")
	runfile("lua/libraries/utility/convert.lua")
	runfile("lua/libraries/utility/formating.lua")
	runfile("lua/libraries/utility/lz4_compress.lua")
	runfile("lua/libraries/utility/random.lua")
	runfile("lua/libraries/utility/runtime_debug.lua")
end

runfile("lua/libraries/extensions/fs.lua")
_G.prototype = runfile("lua/libraries/prototype/prototype.lua")

do
	vfs = runfile("lua/libraries/filesystem/vfs.lua")
	vfs.Mount("os:" .. e.STORAGE_FOLDER) -- mount the storage folder to allow requiring files from bin/*
	vfs.Mount("os:" .. e.USERDATA_FOLDER, "os:data") -- mount "ROOT/data/users/*username*/" to "/data/"
	vfs.Mount("os:" .. e.CACHE_FOLDER, "os:cache")
	vfs.Mount("os:" .. e.SHARED_FOLDER, "os:shared")
	vfs.MountAddon("os:" .. e.CORE_FOLDER) -- mount "ROOT/"..e.INTERNAL_ADDON_NAME to "/"
	vfs.GetAddonInfo(e.INTERNAL_ADDON_NAME).dependencies = {e.INTERNAL_ADDON_NAME} -- prevent init.lua from running later on again
	vfs.GetAddonInfo(e.INTERNAL_ADDON_NAME).startup = nil -- prevent init.lua from running later on again
	vfs.AddModuleDirectory("lua/modules/")
	vfs.AddModuleDirectory("bin/shared/")
	vfs.AddModuleDirectory(e.BIN_PATH .. "lua")
end

if desire("ffi") then _G.require("ffi").load = vfs.FFILoadLibrary end

_G.require = vfs.Require
_G.runfile = function(...)
	local ret = list.pack(vfs.RunFile(...))

	-- not very ideal
	if ret[1] == false and type(ret[2]) == "string" then error(ret[2], 2) end

	return list.unpack(ret)
end
_G.R = vfs.GetAbsolutePath -- a nice global for loading resources externally from current dir
package.loaded.bit32 = bit
-- libraries
runfile("lua/libraries/datatypes/buffer.lua")
runfile("lua/libraries/datatypes/tree.lua")
_G.bytepack = runfile("lua/libraries/bytepack.lua") -- string.pack lua implementation
_G.crypto = runfile("lua/libraries/crypto.lua") -- base64 and other hash functions
_G.serializer = runfile("lua/libraries/serializer.lua") -- for serializing lua data in different formats
_G.system = runfile("lua/libraries/system.lua") -- os and luajit related functions like creating windows or changing jit options
_G.event = runfile("lua/libraries/event.lua") -- event handler
_G.timer = runfile("lua/libraries/timer.lua") -- timer
_G.utf8 = runfile("lua/libraries/utf8.lua") -- utf8 string library, also extends to string as utf8.len > string.ulen
_G.profiler = runfile("lua/libraries/profiler.lua")
_G.tasks = runfile("!lua/libraries/tasks.lua") -- high level coroutine library
_G.threads = runfile("!lua/libraries/threads.lua")

if profiler then
	_G.P = profiler.ToggleTimer
	_G.I = profiler.ToggleInstrumental
	_G.S = profiler.ToggleStatistical
	_G.LOOM = profiler.ToggleLoom
end

do -- nattlua
	-- not very nice..
	fs.PushWorkingDirectory(e.CORE_FOLDER .. "lua/modules/nattlua")
	_G.nl = require("nattlua.init")
	_G.nl.Lexer = require("nattlua.lexer").New
	_G.nl.Code = require("nattlua.code").New
	_G.nl.runtime_syntax = require("nattlua.syntax.runtime")
	_G.nl.typesystem_syntax = require("nattlua.syntax.typesystem")
	fs.PopWorkingDirectory()

	event.AddListener("PreLoadString", "nattlua", function(code, path)
		if not path:ends_with(".nlua") then return end

		local ok, err = nl.Compiler(code, "@" .. path):Emit({transpile_extensions = true})
		-- event listeners look for a value, not nil
		return ok or false, err
	end)
end

_G.repl = runfile("lua/libraries/repl.lua")
_G.ffibuild = runfile("lua/libraries/ffibuild.lua") -- used to build binaries
_G.callback = runfile("lua/libraries/callback.lua") -- promise-like library
_G.resource = runfile("lua/libraries/resource.lua") -- used for downloading resources with resource.Download("http://..."):Then(function(path) end)
_G.sockets = runfile("lua/libraries/sockets/sockets.lua")
_G.http = runfile("lua/libraries/http.lua")
_G.test = runfile("lua/libraries/test.lua")

if not TEST and not os.getenv("GOLUWA_ARG_LINE"):starts_with("build") then
	local ok, err = pcall(repl.Start)

	if not ok then logn(err) end
end

-- tries to load all addons
-- some might not load depending on its info.lua file.
-- for instance: "load = CAPSADMIN ~= nil," will make it load
-- only if the CAPSADMIN constant is not nil.
-- this will skip the src folder though
vfs.MountAddons(e.ROOT_FOLDER)

-- this needs to be ran after addons have been mounted as it looks for vmdef.lua and other lua files in binary directories
if jit then runfile("lua/libraries/extensions/jit.lua") end

e.BOOT_TIME = tonumber(os.getenv("GOLUWA_BOOT_TIME")) or -1
e.INIT_TIME = os.clock() - start_time
e.BOOTIME = os.clock()

if VERBOSE then
	logn("[runfile] ", e.BOOT_TIME, " seconds spent in core/lua/boot.lua")
	logn("[runfile] ", os.clock() - start_time, " seconds spent in core/lua/init.lua")
end

if os.getenv("GOLUWA_ARG_LINE"):starts_with("build") then
	local what = os.getenv("GOLUWA_ARG_LINE"):sub(7)

	if what == "*" then
		for _, filename in ipairs(vfs.Find("lua/ffibuild/")) do
			runfile("lua/ffibuild/" .. filename)
		end
	else
		runfile("lua/ffibuild/" .. what .. ".lua")
	end

	os.realexit(os.exitcode)
end

-- this can be overriden later, but by default we limit the fps to 30
event.AddListener("FrameEnd", "fps_limit", function()
	system.Sleep(1 / 30)
end)

event.AddListener("MainLoopStart", function()
	vfs.AutorunAddons()
	-- load everything in goluwa/*/lua/autorun/*USERNAME*/*
	vfs.AutorunAddons(e.USERNAME .. "/")
	system.ExecuteArgs()
end)

vfs.WatchLuaFiles2(true)

-- call goluwa/*/lua/init.lua if it exists
vfs.InitAddons(function()
	event.Call("Initialize")

	if VERBOSE then
		logn("[runfile] total init time took ", os.clock() - start_time, " seconds to execute")
		logn(
			"[runfile] ",
			vfs.total_loadfile_time,
			" seconds of that time was overhead spent in loading compiling scripts"
		)
	end

	event.Call("MainLoopStart")
	event.Call("MainLoopStart")
end)

vfs.FetchBniariesForAddon("core")

if TEST then
	debug.sethook()
	local lst = {}

	for func, count in pairs(FUNC_CALLS) do
		list.insert(lst, {func = func, count = count})
	end

	list.sort(lst, function(a, b)
		return a.count > b.count
	end)

	local max = 30
	logn("========= TOP " .. max .. " CALLED FUNCTIONS =========")

	for i = 1, max do
		logn(debug.get_pretty_source(lst[i].func, true), " = ", lst[i].count)
	end

	logn("===========================================")
	logn("===============RUNNING TESTS===============")
	local failed = false

	for _, path in ipairs(vfs.GetFilesRecursive("lua/test/")) do
		test.start(path)
		runfile(path)
		test.stop()

		if test.failed then failed = true end
	end

	logn("===========================================")

	if failed then system.ShutDown(1) end

	system.ShutDown(0)
	return
end

local last_time = 0
local i = 0

while system.run == true do
	local time = system.GetTime()
	local dt = time - (last_time or 0)
	system.SetFrameTime(dt)
	system.SetFrameNumber(i)
	system.SetElapsedTime(system.GetElapsedTime() + dt)
	event.Call("Update", dt)
	system.SetInternalFrameTime(system.GetTime() - time)
	i = i + 1
	last_time = time
	event.Call("FrameEnd")
end

repl.Stop()
event.Call("MainLoopStop")
event.Call("MainLoopStop")
event.Call("ShutDown")
collectgarbage()
collectgarbage() -- https://stackoverflow.com/questions/28320213/why-do-we-need-to-call-luas-collectgarbage-twice
os.realexit(os.exitcode)