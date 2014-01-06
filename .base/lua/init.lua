DEBUG = true
_G.ffi = require("ffi")

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

do
	-- load useful jit libraries
	
	-- need to do this in order for jit/v.lua and jit/dump.lua to load its required libraries properly
	table.insert(package.loaders, function(name)
		name = name:gsub("%.", "/")
		return loadfile("../../../lua/modules/" .. name .. ".lua")
	end)
	
	jit.v = require("jit.v")
	jit.dump = require("jit.dump")
	jit.p = require("jit.p")

	if DEBUG then
		local base = "../../../../.userdata/" .. e.USERNAME:lower() .. "/logs/"
		jit.v.on(base .. "jit_verbose_output.txt")
		--jit.dump.on(nil, base .. "jit_dump_output.txt")
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
	
	-- straight loading
	vfs.AddModuleDirectory("")
	
	-- replace require with the pure lua version (lua/procure/init.lua)
	_G.require = require("procure")	
	
	-- use strung
	if USE_STRUNG then
		_G.strung = require("strung")
		_G.strung.install()
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
		
	local function get_verbosity_level()
		return console and console.GetVariable("log_verbosity", 0) or 0
	end
	
	local function get_debug_filter()
		return console and console.GetVariable("log_debug_filter", "") or ""
	end	
	
	local suppress_print = false

	local function can_print(args)
		if suppress_print then return end
		
		if event then 
			suppress_print = true
			
			if event.Call("ConsolePrint", table.concat(args, ", ")) == false then
				suppress_print = false
				return false
			end
			
			suppress_print = false
		end
		
		return true
	end
	
	local base_log_dir = e.USERDATA_FOLDER .. "logs/"
	
	local log_files = {}
	local log_file
	
	function setlogfile(name)
		name = name or "console"
		
		if not log_files[name] then
			local file = io.open(base_log_dir .. name .. "_" .. jit.os:lower() .. ".txt", "w")
			
			if buffer then
				for k,v in pairs(buffer) do
					file:write(unpack(v))
				end
				
				buffer = nil
			end
			
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
		if can_print(args) then
			
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
	end
	
	function logn(...)
		local args = {...}
		table.insert(args, "\n")
		return log(unpack(args))
	end
	
	function print(...)
		logn(table.concat(tostring_args(...), ",\t"))
	end

	function logf(str, ...)
		logn(safeformat(str, ...))
	end

	function errorf(str, level, ...)
		error(safeformat(str, ...), level)
	end

	function warning(verbosity, format, ...)
		local level = get_verbosity_level()
				
		-- if verbosity is a string only show warnings log_debug_filter is set to
		if type(verbosity) == "string" then
			if verbosity == get_debug_filter() then
				return logf(format, ...)
			end
		else
			-- if the level is below 0 always log
			if level < 0 then
				return log(format, ...)
			end
		
			-- otherwise check the verbosity level against the input	
			if level <= verbosity then
				return log(format, ...)
			end
		end
	end	
	
	do
		local last = {}
	
		function nospam_printf(str, ...)
			local str = string.format(str, tostring_args(...))
			local t = os.clock()
			
			if not last[str] or last[str] < t then
				logn(str)
				last[str] = t + 3
			end
		end
		
		function nospam_print(...)
			nospam_printf(("%s "):rep(select("#", ...)), ...)
		end
	end
end

logf("launched on %s", os.date())
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
					system.SetDLLDirectory(full_path:match("(.+/)"))
					local ok, msg = pcall(_OLD_G.ffi_load, full_path, ...)
					system.SetDLLDirectory()
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
	
	local function not_found(err)
		return 
			err and 
			(
				err:find("No such file or directory", nil, true) or 
				err:find("Invalid argument", nil, true)
			)
	end
	
	function include(source, ...)
		
		if vfs and source:sub(-1) == "*" then
			for script in vfs.Iterate("lua/" .. source:sub(0,-2) .. ".lua", nil, true) do
				local func, err = loadfile(script)
				
				if func then
					local ok, err = xpcall(func, mmyy and mmyy.OnError or (function() end), ...)
					
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
	
		local dir, file = source:match("(.+/)(.+)")
		
		if not dir then
			dir = ""
			file = source
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
					end
				end
			end		
		end
		
		if func then
			dir = path:match("(.+/)(.+)")
			include_stack[#include_stack + 1] = dir
					
			local res = {xpcall(func, mmyy and mmyy.OnError or (function() end), ...)}
			
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
		
		local path = console and console.GetVariable("error_app")

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

do
	local status, crypto = pcall(require, "crypto")
	_G.crypto = crypto
end

local extensions = "libraries/extensions/"
local libraries = "libraries/"
local meta = "meta/"

-- library extensions
include(extensions .. "globals.lua")
include(extensions .. "debug.lua")
include(extensions .. "math.lua")
include(extensions .. "string.lua")
include(extensions .. "table.lua")
include(extensions .. "os.lua")

-- libraries
structs = include(libraries .. "structs.lua")

include("libraries/structs/*")

utf8 = include(libraries .. "utf8.lua")
event = include(libraries .. "event.lua")
utilities = include(libraries .. "utilities.lua")
addons = include(libraries .. "addons.lua")
class = include(libraries .. "class.lua")
luadata = include(libraries .. "luadata.lua")
von = include(libraries .. "von.lua")
timer = include(libraries .. "timer.lua")
sigh = include(libraries .. "sigh.lua")
base64 = include(libraries .. "base64.lua")
input = include(libraries .. "input.lua")
msgpack = include(libraries .. "msgpack.lua")
json = include(libraries .. "json.lua")
console = include(libraries .. "console.lua")
mmyy = include(libraries .. "mmyy.lua")
system = include(libraries .. "system.lua")
lcpp = include(libraries .. "lcpp.lua")
profiler = include(libraries .. "profiler.lua")
steam = include(libraries .. "steam.lua")
steamapi = include(libraries .. "steamapi.lua")
cookies = include(libraries .. "cookies.lua")
lpeg = include(libraries .. "lulpeg.lua")

-- meta
include(meta .. "function.lua")
include(meta .. "null.lua")

-- luasocket
do 
	luasocket = include(libraries .. "luasocket.lua") 
	intermsg = include(libraries .. "intermsg.lua") 
	timer.Create("socket_think", 0.1, 0, luasocket.Update)
	event.AddListener("LuaClose", "luasocket", luasocket.Panic)
end

console.CreateVariable("error_app", "")

addons.LoadAll()
steamapi.Initialize()

include("lua/goluwa/init.lua")

console.Exec("autoexec")

-- include single lua scripts in addons/
--include(addons.Root .. "*")

addons.AutorunAll(e.USERNAME)

if CREATED_ENV then
	system.SetWindowTitle(TITLE)
	
	utilities.SafeRemove(ENV_SOCKET)
	
	ENV_SOCKET = luasocket.Client()

	ENV_SOCKET:Connect("localhost", PORT)	
	ENV_SOCKET:SetTimeout()
	
	ENV_SOCKET.OnReceive = function(self, line)		
		local func, msg = loadstring(line)

		if func then
			local ok, msg = xpcall(func, mmyy.OnError) 
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
	local line = table.concat(ARGS, " "):trim()
	
	if line ~= "" then
		console.RunString(line)
	end
	
	ARGS = nil
end

vfs.MonitorEverything(true) 

event.Call("Initialized")
