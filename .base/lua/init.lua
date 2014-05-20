if system and system.Restart then system.Restart() return end 

DEBUG = true
USE_STRUNG = true

_G.ffi = require("ffi")

if not ffi then
	error("goluwa requires luajit 2+ to run!")
end

-- load normal lua modules from this directory
package.cpath = package.cpath .. ";../../../lua/modules/bin/" .. jit.os:lower() .. "/" .. jit.arch:lower() .. "/?." .. (jit.os == "Windows" and "dll" or "so")

_G.lfs = require("lfs")

if not lfs then 
	error("unable to load lfs! are you sure the cd is ROOT/.base/bin/*OS*/*ARCH*/ and that ROOT/.base/lua/modules/bin/*OS*/*ARCH*/ ?")
end

if true then -- workaround for when working directory is goluwa/ (like when running from zerobrane)	
	local dir = lfs.currentdir():gsub("\\", "/")
	if dir:find(".+goluwa$") then
		dir = dir .. "/.base/bin/" .. jit.os:lower() .. "/" .. jit.arch:lower()
	end
	lfs.chdir(dir)
end

_G[ffi.os:upper()] = true
_G[ffi.arch:upper()] = true

-- enums table
e = e or {}

e.USERNAME = tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
_G[e.USERNAME:upper()] = true

-- this will be replaced later on with logn
_G.LOG_BUFFER = {}
print = function(...) 
	local args =  {...}
	table.insert(args, "\n")
	table.insert(_G.LOG_BUFFER, args) 
end

do -- load useful jit libraries	
	-- need to do this in order for jit/v.lua and jit/dump.lua to load its required libraries properly
	table.insert(package.loaders, function(name)
		name = name:gsub("%.", "/")
		return loadfile("../../../lua/modules/" .. name .. ".lua")
	end)
	
	pcall(function()
		jit.verbose = require("jit.v")
		jit.dump = require("jit.dump")
		jit.profiler = require("jit.p")
	end)
	
	if DEBUG then
		local base = "../../../../.userdata/" .. e.USERNAME:lower() .. "/logs/"
		if io.open(base) then
			jit.verbose.on(base .. "jit_verbose_output.txt")
		end
	end
		
	-- remove the loader we just made. it's made more properly later on
	table.remove(package.loaders, #package.loaders)
end

-- put all c functions in a table
if not _OLD_G then
	_R = debug.getregistry()
	
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

	-- this is ugly but it's because we haven't included the global extensions yet..
	_G.check = function() end
	vfs = dofile(e.ROOT_FOLDER .. ".base/lua/libraries/vfs.lua")

	-- mount the base folders
	
	-- current dir
	--vfs.Mount(lfs.currentdir())
	
	-- user dir
	vfs.Mount(e.USERDATA_FOLDER)
	
	vfs.Mount(e.BASE_FOLDER)
	
	-- a nice global for loading resources externally from current dir
	_G.R = vfs.GetAbsolutePath
	
	vfs.AddModuleDirectory("lua/modules/")
	vfs.AddModuleDirectory("lua/")
	
	-- replace require with the pure lua version (lua/procure/init.lua)
	_G.require = require("procure")	
	
	-- use strung
	if USE_STRUNG then
		local strung = require("strung")
		for k,v in pairs(strung) do if k ~= "gsub" then string[k] = v end end		
		USE_STRUNG = nil
	end
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
				local src = debug.getinfo(v).short_src
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

	local function safeformat(str, ...)
		local count = select(2, str:gsub("(%%)", ""))
		local copy = {}
		for i = 1, count do
			table.insert(copy, tostringx(select(i, ...)))
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
	
	local buffer = {}
	local last_line
	local count = 0
	local last_count_length = 0
		
	lfs.mkdir(base_log_dir)
		
	function log(...)
		local args = tostring_args(...)
		
		if vfs then						
			if not log_file then
				setlogfile()
			end
		
			local line = table.concat(args, "")
							
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
		else
			table.insert(buffer, args)
		end
		
		if log_files.console == log_file then
			io.write(unpack(args))
			if _G.LOG_BUFFER then
				table.insert(_G.LOG_BUFFER, args)
			end
		end
	end
	
	function logn(...)
		local args = {...}
		table.insert(args, "\n")
		log(unpack(args))
		return ...
	end
	
	function print(...)
		logn(table.concat(tostring_args(...), ",\t"))
		return ...
	end

	function logf(str, ...)
		log(safeformat(str, ...))
		return ...
	end

	function errorf(str, level, ...)
		error(safeformat(str, ...), level)
	end
end

logf("launched on %s\n", os.date())
logn("executed by " .. e.USERNAME, "\n")

do -- ffi
	_OLD_G.ffi_load = _OLD_G.ffi_load or ffi.load
	
	-- make ffi.load search using our file system
	ffi.load = function(path, ...)
		local ok, msg = pcall(_OLD_G.ffi_load, path, ...)
		
		if not ok then
			if vfs then
				for full_path in vfs.Iterate("bin/" .. ffi.os .. "/" .. ffi.arch .. "/" .. path, nil, true, nil, true) do
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
			
			error(msg, 2)
			
			return nil
		end
		
		return msg
	end
	
	ffi.cdef("void* malloc(size_t size); void free (void* ptr);")
	function ffi.malloc(t, size)
		local val = ffi.cast(t, ffi.gc(ffi.C.malloc(size), ffi.C.free))
		ffi.fill(val, size)
		return val
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
						
			if previous_dir then
				dir = previous_dir .. dir
			end
			
			if not vfs.IsDir(dir) then
				dir = "lua/" .. dir
			end
							
			for script in vfs.Iterate(dir, nil, true) do
				local func, err = loadfile(script)
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
			
			return
		end
		
		vfs.Silence(true)		
				
		-- try direct first
		local path = dir .. file
		local func, err = loadfile(path)
		
		if not func then		 
			local previous_dir = include_stack[#include_stack]		
						
			if previous_dir then
				dir = previous_dir .. dir
			end
					
			-- try first with the last directory
			-- once with lua prepended
			path = "lua/" .. dir .. file
			func, err = vfs.loadfile(path)
						
			if not_found(err) then
				path = dir .. file
				func, err = vfs.loadfile(path)
				
				-- and without the last directory
				-- once with lua prepended
				if not_found(err) then
					path = "lua/" .. source
					func, err = vfs.loadfile(path)	
					
					if not_found(err) then
						path = source
						func, err = loadfile(path)
					else
						path = source
					end
				end
			else
				path = dir .. file
			end
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
				vfs.Write("include.lua", table.concat(include_buffer, "\n"))
			end]]
			
			include_stack[#include_stack] = nil
						 
			return select(2, unpack(res))
		end		
		
		local path = console and console.GetVariable("editor_path")

		if path and path ~= "" then
			local source, line = err:match("(.+%.lua):(%d+)")
			if source and line then
				line = tonumber(line)
				
				if vfs.Exists(source) then
					path = path:gsub("%%LINE%%", line)
					path = path:gsub("%%PATH%%", source)
					os.execute(path)
				end
			end
		end
		
		logn(source:sub(1) .. " " .. err)
		
		vfs.Silence(false)
		
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
	structs = include("libraries/structs.lua") -- Vec3(x,y,z), Vec2(x,y), Ang3(p,y,r),  etc
	utf8 = include("libraries/utf8.lua") -- utf8 string library, also extends to string as utf8.len > string.ulen
	event = include("libraries/event.lua") goluwa = event.events -- event handler
	utilities = include("libraries/utilities.lua") -- more like i-dont-know-where-these-functions-go
	addons = include("libraries/addons.lua") -- addons are folders in root of goluwa
	class = include("libraries/class.lua") -- used by gui panels and entities
	
	-- serializing
	luadata = include("libraries/serializing/luadata.lua") -- like json but deals with the lua format instead
	crypto = include("libraries/serializing/crypto.lua")
	include("libraries/serializing/buffer.lua")
	msgpack = require("msgpack")
	json = require("json")

	timer = include("libraries/timer.lua")
	console = include("libraries/console.lua")
	input = include("libraries/input.lua")
	system = include("libraries/system.lua")
	profiler = include("libraries/profiler.lua")
	steam = include("libraries/steam.lua")
	cookies = include("libraries/cookies.lua")
	expression = include("libraries/expression.lua")
	autocomplete = include("libraries/autocomplete.lua")
	
	-- meta
	include("libraries/extensions/function.lua")
	include("libraries/null.lua")

	-- graphics
	render = include("libraries/graphics/render/render.lua") -- OpenGL abstraction
	surface = include("libraries/graphics/surface.lua") -- high level 2d rendering of the render library
	window = include("libraries/graphics/window.lua") -- high level window implementation
	video = include("libraries/graphics/video.lua") -- gif support (for now)
	include("libraries/graphics/particles.lua")
	include("libraries/graphics/markup.lua")	
	
	-- network
	sockets = include("libraries/network/sockets/sockets.lua") 
	intermsg = include("libraries/network/intermsg.lua") 			
	steamapi = include("libraries/network/steamapi.lua")
	message = include("libraries/network/message.lua") -- high level communication between server and client
	network = include("libraries/network/network.lua") -- high level implementation of sockets
	nvars = include("libraries/network/nvars.lua")
	players = include("libraries/network/players.lua")
			
	-- audio
	audio = include("libraries/audio/audio.lua") -- high level implementation of OpenAl
	chatsounds = include("libraries/audio/chatsounds.lua")
	
	entities = include("libraries/entities/entities.lua")
	easylua = include("libraries/entities/easylua.lua")
	
	include("libraries/extensions/vfs_vpk.lua") -- vpk support for _G.vfs
	include("libraries/extensions/console_curses.lua") -- high level implementation of curses extending _G.console	
end

console.CreateVariable("editor_path", system.FindFirstEditor(true, true) or "")

event.AddListener("OnUpdate", "sockets", sockets.Update)
event.AddListener("LuaClose", "sockets", sockets.Panic)

addons.LoadAll()

audio.Open()

if not ZEROBRANE then
  console.InitializeCurses()
end

steamapi.Initialize()
entities.LoadAllEntities()

addons.AutorunAll()
timer.clock = require("lj-glfw").GetTime

console.Exec("autoexec")

-- include single lua scripts in addons/
-- include(addons.Root .. "*")

addons.AutorunAll(e.USERNAME)

if CREATED_ENV then
	system.SetWindowTitle(TITLE)
	
	utilities.SafeRemove(ENV_SOCKET)
	
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
		
		timer.Delay(0, function() event.Call("OnConsoleEnvReceive", line) end)
	end 
end

if ARGS then
	
	for _, arg in pairs(ARGS) do
		print(console.RunString(tostring(arg)))
	end
	
	ARGS = nil
end

vfs.MonitorEverything(true)

include("main_loop.lua")