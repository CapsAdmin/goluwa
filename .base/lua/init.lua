-- load normal lua modules from this directory
-- ROOT/.base/lua/modules/bin/linux/x64/foobar.so
package.cpath = package.cpath .. ";../../../lua/modules/bin/" .. jit.os:lower() .. "/" .. jit.arch:lower() .. "/?." .. (jit.os == "Windows" and "dll" or "so")

do -- check if this environment is compatible
	if not require("ffi") then
		error("goluwa requires luajit 2+ to run!")
	end
	
	if not require("lfs") then 
		error("unable to load lfs! are you sure the cd is ROOT/.base/bin/*OS*/*ARCH*/ and that ROOT/.base/lua/modules/bin/*OS*/*ARCH*/ ?")
	end
end

do -- constants
	-- if WINDOWS and X86 then blah blah end
	_G[jit.os:upper()] = true
	_G[jit.arch:upper()] = true

	-- enums table
	e = e or {}

	e.USERNAME = tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
	_G[e.USERNAME:upper()] = true
	
	if os.getenv("USE_SDL") == "1" and USE_SDL == nil then
		USE_SDL = true
	end
	
	if os.getenv("SERVER") == "1" and SERVER == nil then
		SERVER = true
	end
	
	if os.getenv("CLIENT") == "1" and CLIENT == nil then
		CLIENT = true
	end
	
	if os.getenv("DEBUG") == "1" and DEBUG == nil then
		DEBUG = true
	end

	if os.getenv("DISABLE_CURSES") == "1" and DISABLE_CURSES == nil then
		DISABLE_CURSES = true
	end
	
	-- assume client if nothing was provided
	if SERVER == nil and CLIENT == nil then
		CLIENT = true
	end
	
	-- this will be executed at the bottom of this file as for k,v in pairs(ARGS) do console.RunString(arg) end
	if os.getenv("ARGS") and not ARGS then
		local func, err = loadstring("return " .. os.getenv("ARGS"))
		if func then 
			local ok, tbl = pcall(func)
			
			ARGS = tbl
		else
			ARGS = err
		end
	end
end

if not DISABLE_CURSES then
	-- this will be replaced later on with logn
	_G.LOG_BUFFER = {}

	print = function(...) 
		local args =  {...}
		table.insert(args, "\n")
		table.insert(_G.LOG_BUFFER, args) 
	end
end

-- load and enable useful jit libraries to debug startup
if DEBUG then 

	-- need to do this in order for jit/v.lua and jit/dump.lua to load its required libraries properly
	table.insert(package.loaders, function(name)
		name = name:gsub("%.", "/")
		return loadfile("../../../lua/modules/" .. name .. ".lua")
	end)
	table.insert(package.loaders, function(name)
		name = name:gsub("%.", "/")
		return loadfile("../../../lua/modules/" .. name .. "/" .. name .. ".lua")
	end)	
	table.insert(package.loaders, function(name)
		name = name:gsub("%.", "/")
		return loadfile("../../../lua/modules/" .. name .. "/init.lua")
	end)
		
		local ok, err = pcall(function()
			jit.verbose = require("jit.v")
			jit.dump = require("jit.dump")
			jit.profiler = require("jit.p")
		end)
		
		if not ok then
			print("could not find extra jit libraries")
		end

		local base = "../../../../.userdata/" .. e.USERNAME:lower() .. "/logs/"
		
		jit.verbose.on(base .. "jit_verbose_output.txt")
			
	-- remove the loader we just made. it's made more properly later on
	table.remove(package.loaders, 1)
	table.remove(package.loaders, 1)
	table.remove(package.loaders, 1)
end

-- put all c functions in a table so we can override them if needed 
-- without doing the local oldfunc = print thing over and over again
if not _OLD_G then
	-- this will be replaced with utility.GetOldGLibrary() later on
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
	
	scan(_G, _OLD_G)
end

do -- file system
	lfs = require("lfs")

	-- the root folder is always 4 paths up (.base/bin/os/arch)
	e.ROOT_FOLDER = lfs.currentdir():gsub("\\", "/"):match("(.+/)" .. (".-/"):rep(4 - 1))
	
	e.BASE_FOLDER = lfs.currentdir():gsub("\\", "/"):match("(.+/)" .. (".-/"):rep(3 - 1))
	
	-- the userdata folder
	e.USERDATA_FOLDER = e.ROOT_FOLDER .. ".userdata/" .. e.USERNAME:lower() .. "/"
	
	-- create them
	lfs.mkdir(e.ROOT_FOLDER .. ".userdata/")
	lfs.mkdir(e.USERDATA_FOLDER)

	do -- this is ugly but it's because we haven't included the global extensions yet..
		_G.check = function() end
		
		include = function() end
		
		ffi = require("ffi")

		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/globals.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/debug.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/string.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/extensions/table.lua")
		prototype = dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/prototype.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/get_is_set.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/base_object.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/null.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/prototype/templates/buffer.lua")
		utility = dofile(e.ROOT_FOLDER .. ".base/lua/libraries/utilities/utility.lua")
		
		vfs = dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/vfs.lua")
		
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/path_utilities.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/base_file.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/find.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/helpers.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/async.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/lua_utilities.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/addons.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/monitoring.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/files/os.lua")
		dofile(e.ROOT_FOLDER .. ".base/lua/libraries/filesystem/files/vpk.lua")

		vfs.IsDir = vfs.IsFolder
	end
	
	-- mount the /userdata/*username*/ folder
	vfs.Mount(e.USERDATA_FOLDER, "data")
	
	-- mount the /.base folder
	vfs.MountAddon(e.BASE_FOLDER)
	
	-- a nice global for loading resources externally from current dir
	-- 
	_G.R = vfs.GetAbsolutePath
	
	vfs.AddModuleDirectory("lua/modules/")
	vfs.AddModuleDirectory("lua/")
	
	-- replace require with the pure lua version (lua/procure/init.lua)
	-- this is needed for the file system
	_G.require = require("procure")
	
end

do -- logging	
	local pretty_prints = {}
	
	pretty_prints.table = function(t)
		local str = tostring(t) or "nil"
				
		str = str .. " [" .. table.count(t) .. " subtables]"
		
		-- guessing the location of a library
		local sources = {}
		
		for k,v in pairs(t) do	
			if type(v) == "function" then
				local src = debug.getinfo(v).source
				sources[src] = (sources[src] or 0) + 1
			end
		end
		
		local tmp = {}
		
		for k,v in pairs(sources) do
			table.insert(tmp, {k=k,v=v})
		end
		
		table.sort(tmp, function(a,b) return a.v > b.v end)
		
		if #tmp > 0 then 
			str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]"
		end		
		
		return str
	end
	
	local function tostringx(val)
		local t = (typex or type)(val)
		
		return pretty_prints[t] and pretty_prints[t](val) or tostring(val)
	end

	local function tostring_args(...)
		local copy = {}
		
		for i = 1, select("#", ...) do
			table.insert(copy, tostringx(select(i, ...)))
		end
		
		return copy
	end

	local function formatx(str, ...)		
		local copy = {}
		local i = 1
		
		for arg in str:gmatch("%%(.)") do
			arg = arg:lower()
			
			if arg == "s" then
				table.insert(copy, tostringx(select(i, ...)))
			else
				table.insert(copy, (select(i, ...)))
			end
				
			i = i + 1
		end
		
		return string.format(str, unpack(copy))
	end
	
	local base_log_dir = e.USERDATA_FOLDER .. "logs/"
	
	local log_files = {}
	local log_file
	
	function setlogfile(name)
		name = name or "console"
		
		if not log_files[name] then
			local file = io.open(base_log_dir .. name .. "_" .. jit.os:lower() .. ".txt", "w")
		
			log_files[name] = file			
		end
		
		log_file = log_files[name]
	end
	
	function getlogfile(name)
		name = name or "console" 
		
		return log_files[name]
	end
	
	local last_line
	local count = 0
	local last_count_length = 0
		
	lfs.mkdir(base_log_dir)
		
	local function raw_log(args, sep, append)	
		local line = table.concat(args, sep)
	
		if append then
			line = line .. append
		end
	
		if vfs then						
			if not log_file then
				setlogfile()
			end
							
			if line == last_line then
				if count > 0 then
					local count_str = ("[%i x] "):format(count)
					log_file:seek("cur", -#line-1-last_count_length)
					log_file:write(count_str, line)
					last_count_length = #count_str
				end
				count = count + 1
			else
				log_file:write(line)
				count = 0
				last_count_length = 0
			end
			
			log_file:flush()
			
			last_line = line
		end
		
		if log_files.console == log_file then
			
			if console and console.Print then
				console.Print(line)
			else
				io.write(line)
			end
			
			if _G.LOG_BUFFER then
				table.insert(_G.LOG_BUFFER, args)
			end
		end
	end
		
	function log(...)
		raw_log(tostring_args(...), "")
	end
	
	function logn(...)
		raw_log(tostring_args(...), "", "\n")
		return ...
	end
	
	function print(...)
		raw_log(tostring_args(...), ",\t", "\n")
		return ...
	end

	function logf(str, ...)
		log(formatx(str, ...))
		return ...
	end

	function errorf(str, level, ...)
		error(formatx(str, ...), level)
	end
end

logf("launched on %s by %s as %s\n", os.date(), e.USERNAME, CLIENT and "client" or "server")

do -- ffi
	_G.ffi = require("ffi")

	_OLD_G.ffi_load = _OLD_G.ffi_load or ffi.load
	
	local ffi_new = ffi.new
	
	function ffi.debug_gc(b)
		if b then
			ffi.new = ffi.new_dbg_gc
		else
			ffi.new = ffi_new
		end
	end
	
	function ffi.new_dbg_gc(...)
		local obj = ffi_new(...)
		ffi.gc(obj, function(...) logn("ffi debug gc: ", ...) end)
		return obj
	end

	local where = {
		"bin/" .. ffi.os .. "/" .. ffi.arch .. "/",
		"lua/modules/bin/" .. ffi.os .. "/" .. ffi.arch .. "/",
	}
		
	-- make ffi.load search using our file system
	ffi.load = function(path, ...)
		local ok, msg = pcall(_OLD_G.ffi_load, path, ...)
		
		if not ok and system and system.SetSharedLibraryPath then
			if vfs then
				for _, where in ipairs(where) do
					for full_path in vfs.Iterate(where .. path, nil, true, nil, true) do
						-- look first in the vfs' bin directories
						local old = system.GetSharedLibraryPath()
						system.SetSharedLibraryPath(full_path:match("(.+/)"))
						local ok, msg = pcall(_OLD_G.ffi_load, full_path, ...)
						system.SetSharedLibraryPath(old)
						
						if ok then
							return msg
						end
						
						-- if not try the default OS specific dll directories
						local ok, msg = pcall(_OLD_G.ffi_load, full_path, ...)
						if ok then
							return msg
						end
					end			
				end
			end
			
			error(msg, 2)
			
			return nil
		end
		
		return msg
	end
	
	ffi.cdef("void* malloc(size_t size); void free(void* ptr);")
	
	function ffi.malloc(t, size)			
		size = size * ffi.sizeof(t)
	
		return ffi.cast(t .. "*", ffi.gc(ffi.C.malloc(size), ffi.C.free))
	end
	
	local function warn_pcall(func, ...)
		local res = {pcall(func, ...)}
		if not res[1] then
			logn(res[2])
		end
		
		return unpack(res, 2)
	end
	
	-- ffi's cdef is so anti realtime
	local cdef = ffi.cdef
	ffi.cdef = function(str, ...)
		return warn_pcall(cdef, str, ...)
	end
	
	local metatype = ffi.metatype
	ffi.metatype = function(str, ...)
		return warn_pcall(metatype, str, ...)
	end
end

do -- include
	local base = lfs.currentdir()

	local include_stack = {}
	
	function vfs.PushToIncludeStack(path)
		include_stack[#include_stack + 1] = path
	end
	
	function vfs.PopFromIncludeStack()
		include_stack[#include_stack] = nil
	end
	
	local function not_found(err)
		return 
			err and 
			(
				err:find("No such file or directory", nil, true) or 
				err:find("Invalid argument", nil, true)
			)
	end
	
	function include(source, ...)
			
		local dir, file = source:match("(.+/)(.+)")
		
		if not dir then
			dir = ""
			file = source
		end
		
		if vfs and file == "*" then
			local previous_dir = include_stack[#include_stack]		
			local original_dir = dir
			
			if previous_dir then
				dir = previous_dir .. dir
			end
						
			if not vfs.IsDir(dir) then
				dir = "lua/" .. dir
			end

			if not vfs.IsDir(dir) then
				dir = "lua/" .. original_dir
			end
			
			for script in vfs.Iterate(dir, nil, true) do
				if script:find("%.lua") then
					local func, err = vfs.loadfile(script)
					
					if func then
						local ok, err = xpcall(func, system and system.OnError or logn, ...)

						if not ok then
							logn(err)
						end
					end
					
					if not func then
						logn(err)
					end
				end
			end
			
			return
		end
						
		-- try direct first
		local loaded_path = source
			
		local previous_dir = include_stack[#include_stack]		
					
		if previous_dir then
			dir = previous_dir .. dir
		end
				
		-- try first with the last directory
		-- once with lua prepended
		local path = "lua/" .. dir .. file
		func, err = vfs.loadfile(path)
					
		if not_found(err) then
			path = dir .. file
			func, err = vfs.loadfile(path)
			
			-- and without the last directory
			-- once with lua prepended
			if not_found(err) then
				path = "lua/" .. source
				func, err = vfs.loadfile(path)	
				
				-- try the absolute path given
				if not_found(err) then
					path = source
					func, err = vfs.loadfile(loaded_path)
				else
					path = source
				end
			end
		else
			path = dir .. file
		end
		
		if func then
			dir = path:match("(.+/)(.+)")
			include_stack[#include_stack + 1] = dir
					
			local res = {xpcall(func, system and system.OnError or logn, ...)}
			
			if not res[1] then
				logn(res[2])
			end
			
			--[[if res and CAPSADMIN then
				local lua, err = vfs.Read(path)
				if not include_buffer then 
					include_buffer = {}
					local lua = vfs.Read(e.ROOT_FOLDER .. "lua/init.lua")
					table.insert(include_buffer, "do")
					table.insert(include_buffer, lua)
					table.insert(include_buffer, "end")
				end
				table.insert(include_buffer, "do")
				table.insert(include_buffer, lua)
				table.insert(include_buffer, "end")
				vfs.Write("data/include.lua", table.concat(include_buffer, "\n"))
			end]]
			
			include_stack[#include_stack] = nil
						 
			return select(2, unpack(res))
		end		
		
		err = err or "no error"
		
		logn(source:sub(1) .. " " .. err)
		
		debug.openscript("lua/" .. path, err:match(":(%d+)"))
						
		return false, err
	end
end

do -- libraries
	-- standard library extensions
	include("libraries/extensions/globals.lua")
	include("libraries/extensions/debug.lua")
	include("libraries/extensions/math.lua")
	include("libraries/extensions/string.lua")
	include("libraries/extensions/table.lua")
	include("libraries/extensions/os.lua")

	-- libraries
	prototype = include("libraries/prototype/prototype.lua")
	structs = include("libraries/structs.lua") -- Vec3(x,y,z), Vec2(x,y), Ang3(p,y,r),  etc
	utf8 = include("libraries/utf8.lua") -- utf8 string library, also extends to string as utf8.len > string.ulen
	event = include("libraries/event.lua") goluwa = event.events -- event handler
	utility = include("libraries/utilities/utility.lua") -- more like i-dont-know-where-these-functions-go
	crypto = include("libraries/crypto.lua")

	-- serializing
	serializer = include("libraries/serializing/serializer.lua")

	system = include("libraries/system.lua")
	console = include("libraries/console.lua")
	profiler = include("libraries/profiler.lua")
	cookies = include("libraries/cookies.lua")
	expression = include("libraries/expression.lua")
	autocomplete = include("libraries/autocomplete.lua")
	input = include("libraries/input.lua")
	
	-- meta
	include("libraries/extensions/function.lua")
		
	if CLIENT then

		-- graphics
		render = include("libraries/graphics/render/render.lua") -- OpenGL abstraction

		surface = include("libraries/graphics/surface/surface.lua") -- high level 2d rendering of the render library
		window = include("libraries/graphics/window.lua") -- high level window implementation
		video = include("libraries/graphics/video.lua") -- gif support (for now)
		include("libraries/graphics/particles.lua")
		
		if not SCITE then
			window.Open()
		end
		
		-- audio
		audio = include("libraries/audio/audio.lua") -- high level implementation of OpenAl
		chatsounds = include("libraries/audio/chatsounds.lua")
	end

	-- network
	sockets = include("libraries/network/sockets/sockets.lua") -- luasocket wrapper mostly for web stuff
	enet = include("libraries/network/enet.lua") -- low level udp library
	
	network = include("libraries/network/network.lua") -- high level implementation of enet
	packet = include("libraries/network/packet.lua") -- medium (?) level communication between server and client
	message = include("libraries/network/message.lua") -- high level communication between server and client
	
	nvars = include("libraries/network/nvars.lua") -- variable synchronization between server and client
	clients = include("libraries/network/clients.lua") -- high level wrapper for a connected client
	chat = include("libraries/network/chat.lua") -- chat, duh!

	-- other
	entities = include("libraries/entities/entities.lua") -- entity component system
	physics = include("libraries/entities/physics.lua") -- bullet physics
	steam = include("libraries/steam/steam.lua")

	if not DISABLE_CURSES then
		include("libraries/extensions/console_curses.lua") -- high level implementation of curses extending _G.console	
	end

	if CLIENT then
		gui = include("gui/init.lua")
	end
	
	-- include the filesystem again so it will include all the details such as zip file reading
	include("libraries/filesystem/vfs.lua")
end

console.CreateVariable("editor_path", system.FindFirstEditor(true, true) or "")

sockets.Initialize()

if audio then
	audio.Initialize()
end

if not ZEROBRANE and not DISABLE_CURSES then
	console.InitializeCurses()
end

--steam.InitializeWebAPI()

if CLIENT then
	clients.local_client = clients.Create("unconnected")
end

do -- addons
	-- tries to load all addons 
	-- some might not load depending on its info.lua file.
	-- for instance: "load = CAPSADMIN ~= nil," will make it load
	-- only if the CAPSADMIN constant is not nil.

	for folder in vfs.Iterate(e.ROOT_FOLDER, nil, true) do
		if not folder:endswith(".git") then
			vfs.MountAddon(folder .. "/")
		end
	end
		
	-- load everything in lua/autorun/*
	vfs.AutorunAddons()
	
	-- load everything in lua/autorun/*USERNAME*/*
	vfs.AutorunAddons(e.USERNAME)

	if CLIENT then
		-- load everything in lua/autorun/client/*
		vfs.AutorunAddons("client/")
	end

	if SERVER then
		-- load everything in lua/autorun/server/*
		vfs.AutorunAddons("server/")
	end

	-- execute /.userdata/*USERNAME*/cfg/autoexec.lua
	console.Exec("autoexec")
end

if CREATED_ENV then
	console.SetTitle(TITLE, "env")
	
	utility.SafeRemove(ENV_SOCKET)
	
	ENV_SOCKET = sockets.CreateClient()

	ENV_SOCKET:Connect("localhost", PORT)	
	ENV_SOCKET:SetTimeout()
	
	ENV_SOCKET.OnReceive = function(self, line)		
		local func, msg = loadstring(line)

		if func then
			local ok, msg = xpcall(func, system.OnError) 
			if not ok then
				logn("runtime error:", client, msg)
			end
		else
			logn("compile error:", client, msg)
		end
		
		event.Delay(0, function() event.Call("ConsoleEnvReceive", line) end)
	end 
end

vfs.MonitorEverything(true)

do -- execute args
	if type(ARGS) == "table" then	
		for _, arg in pairs(ARGS) do
			print(console.RunString(tostring(arg)))
		end	
	elseif type(ARGS) == "string" then
		logn("failed to execute ARGS: ", ARGS)
	end

	ARGS = nil
end

include("main_loop.lua")
