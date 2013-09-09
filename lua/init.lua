-- enums
_G.ffi = require("ffi")

_G[ffi.os:upper()] = true
_G[ffi.arch:upper()] = true

_E = _E or {}
e = _E 

_E.PLATFORM = PLATFORM or tostring(select(1, ...) or nil)
_E.USERNAME = tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
_G[e.USERNAME:upper()] = true

_G.LOG_BUFFER = {}
print = function(...) 
	local args =  {...}
	table.insert(args, "\n")
	table.insert(_G.LOG_BUFFER, args) 
end

do -- helper constants	
	_G._F = {}
	
	local _F = _F
	local _G = _G
	local META = {}
	
	local val
	function META:__index(key)
		val = _F[key]
		
		if type(val) == "function" then
			return val()
		end
	end
	
	setmetatable(_G, META)
		
	do -- example
		_F["T"] = os.clock
		
		-- logn(T + 1) = logn(os.clock() + 1)
	end
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
			elseif t == "function" then
				store[key] = val
			end
		end
	end
	
	scan(_G, _OLD_G)
end

do -- file system
	lfs = require("lfs")

	-- the base folder is always 3 paths up (bin/os/arch)
	_E.BASE_FOLDER = "../../../" 
	_E.ABSOLUTE_BASE_FOLDER = lfs.currentdir():gsub("\\", "/"):match("(.+/).-/.-/")
	
	-- the user folders
	_E.USERDATA_FOLDER = _E.BASE_FOLDER .. "userdata/"
	_E.USER_FOLDER = _E.USERDATA_FOLDER .. _E.USERNAME:lower() .. "/"
	
	-- create them
	lfs.mkdir(_E.USERDATA_FOLDER)
	lfs.mkdir(_E.USER_FOLDER)

	-- this is ugly but it's because we haven't included the global extensions yet..
	_G.check = function() end
	vfs = dofile(_E.BASE_FOLDER .. "/lua/platforms/standard/libraries/vfs.lua")

	-- mount the base folders
	
	-- current dir
	vfs.Mount(lfs.currentdir())
	
	-- user dir
	vfs.Mount(e.USER_FOLDER)
	
	-- and 3 folders up
	vfs.Mount(e.ABSOLUTE_BASE_FOLDER)
	
	-- a nice global for loading resources externally from current dir
	R = vfs.GetAbsolutePath

	-- although vfs will add a loader for each mount, the module folder has to be an exception for modules only
	-- this loader should support more ways of loading than just adding ".lua"
	table.insert(package.loaders, function(path)
		local func = vfs.loadfile("lua/modules/" .. path)
		
		if not func then
			func = vfs.loadfile("lua/modules/" .. path .. ".lua")
		end
		
		return func
	end)
end

do -- logging	
	local pretty_prints = {}
	
	pretty_prints.table = function(t)
		local str = tostring(t)
				
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
		local t = type(val)
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
	
	local base_log_dir = _E.USER_FOLDER .. "logs/"
	
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
		error(safeformat(str, level, ...))
	end

	function warning(verbosity, ...)
		local level = get_verbosity_level()
				
		-- if verbosity is a string only show warnings log_debug_filter is set to
		if type(verbosity) == "string" then
			if verbosity == get_debug_filter() then
				return log(...)
			end
		else
			-- if the level is below 0 always log
			if level < 0 then
				return log(...)
			end
		
			-- otherwise check the verbosity level against the input	
			if level <= verbosity then
				return log(...)
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

log("\n\n")
log([[
 _ __ ___  _ __ ___  _   _ _   _ 
| '_ ` _ \| '_ ` _ \| | | | | | |
| | | | | | | | | | | |_| | |_| |
|_| |_| |_|_| |_| |_|\__, |\__, |
                     |___/ |___/ 
]])
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
	
	-- ffi's cdef is so anti realtime
	if not ffi.already_defined then
		ffi.already_defined = {}
		
		_OLD_G.ffi_cdef = _OLD_G.ffi_cdef or ffi.cdef
		ffi.cdef = function(str, ...)
			local val = ffi.already_defined[str]
			
			if val then
				return val
			end
		
			ffi.already_defined[str] = str
			return _OLD_G.ffi_cdef(str, ...)
		end
			
		ffi.already_defined_metatypes = {}
			
		old_ffi_metatype = old_ffi_metatype or ffi.metatype
		ffi.metatype = function(str, ...)
			local res = ffi.already_defined_metatypes[str] or old_ffi_metatype(str, ...)			
			
			ffi.already_defined_metatypes[str] = res
			
			return res
		end
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
		local dir, file = source:match("(.+/)(.+)")
		
		if not dir then
			dir = ""
			file = source
		end
				
		vfs.Silence(true)
		
		 
		local previous_dir = include_stack[#include_stack]		
		
		if previous_dir then
			dir = previous_dir .. dir
		end
		
		--logn("")
		--logn(("\t"):rep(#include_stack).."TRYING REL: ", dir .. file)
		
		local func, err = vfs.loadfile("lua/" .. dir .. file)
					
		if not_found(err) then
			func, err = vfs.loadfile("lua/" .. source)
			
			if not_found(err) then
				func, err = vfs.loadfile(dir .. file)
				
				if not_found(err) then
					func, err = loadfile(source)
					--logn(("\t"):rep(#include_stack).."TRYING ABS: ", dir .. file)
				end
			end
		end
		

		if func then 
			include_stack[#include_stack + 1] = dir
		
			--logn(("\t"):rep(#include_stack + 1).."FILE FOUND: ", file)
			--logn(("\t"):rep(#include_stack + 1).."DIR IS NOW: ", dir)
			--logn("")
			local res = {xpcall(func, OnError or (function() end), ...)}
			
			if not res[1] then
				logn(res[2])
			end
			
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

local standard = "platforms/standard/"
local extensions = standard .. "extensions/"
local libraries = standard .. "libraries/"
local meta = standard .. "meta/"

-- library extensions
include(extensions .. "globals.lua")
include(extensions .. "debug.lua")
include(extensions .. "math.lua")
include(extensions .. "string.lua")
include(extensions .. "table.lua")
include(extensions .. "os.lua")

-- libraries
structs = include(libraries .. "structs.lua")

for script in vfs.Iterate("lua/structs/", nil, true) do
	dofile(script)
end

event = include(libraries .. "event.lua")
utilities = include(libraries .. "utilities.lua")
addons = include(libraries .. "addons.lua")
class = include(libraries .. "class.lua")
luadata = include(libraries .. "luadata.lua")
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

-- meta
include(meta .. "function.lua")
include(meta .. "null.lua")

-- luasocket
luasocket = include(libraries .. "luasocket.lua") 
timer.Create("socket_think", 0,0, luasocket.Update)
event.AddListener("LuaClose", "luasocket", luasocket.Panic)

-- this should be used for xpcall
function OnError(msg)
	if LINUX and msg == "interrupted!\n" then return end
	
	if event.Call("OnLuaError", msg) == false then return end
	
	logn("STACK TRACE:")
	logn("{")
	
	local base_folder = e.BASE_FOLDER:gsub("%p", "%%%1")
	local data = {}
		
	for level = 3, math.huge do
		local info = debug.getinfo(level)
		if info then
			if info.currentline >= 0 then			
				local args = {}
				
				for arg = 1, info.nparams do
					local key, val = debug.getlocal(level, arg)
					val = luadata.ToString(val)
					table.insert(args, ("%s = %s"):format(key, val))
				end
				
				info.arg_line = table.concat(args, ", ")
				
				local source = info.short_src or ""
				source = source:gsub(base_folder, ""):trim()
				info.source = source
				info.name = info.name or "unknown"
				
				table.insert(data, info)
			end
		else
			break
		end
    end
	
	local function resize_field(tbl, field)
		local length = 0
		
		for _, info in pairs(tbl) do
			local str = tostring(info[field])
			if str then
				if #str > length then
					length = #str
				end
				info[field] = str
			end
		end
		
		for _, info in pairs(tbl) do
			local str = info[field]
			if str then				
				local diff = length - #str
				
				if diff > 0 then
					info[field] = str .. (" "):rep(diff)
				end
			end
		end
	end
	
	table.insert(data, {currentline = "LINE:", source = "SOURCE:", name = "FUNCTION:", arg_line = " ARGUMENTS "})
	
	resize_field(data, "currentline")
	resize_field(data, "source")
	resize_field(data, "name")
	
	for _, info in npairs(data) do
		logf("  %s   %s   %s(%s)", info.currentline, info.source, info.name, info.arg_line)
	end

	logn("}")
	local source, _msg = msg:match("(.+): (.+)")
	
	
	if source then
		source = source:trim()
		
		local path = console.GetVariable("error_app")
		
		if path and path ~= "" then
			local lua_script, line
			
			-- this should be replaced with some sort of configuration
			-- gl.lua never shows anything useful but the level above does..			
			if source:find("gl%.lua") then
				local info = debug.getinfo(4)
				lua_script = info.short_src
				line = info.currentline
			else
				lua_script, line = source:match("(.+%.lua):(.+)")
			end
						
			if lua_script and line then
				line = tonumber(line)
				
				if line and vfs.Exists(lua_script) then
					path = path:gsub("%%LINE%%", line)
					path = path:gsub("%%PATH%%", lua_script)
					print(path)
					os.execute(path)
				end
			end
		end
		
		logn(source)
		logn(_msg:trim())
	else
		logn(msg)
	end
	
	logn("")
end

console.CreateVariable("error_app", "")

console.Exec("autoexec")

addons.LoadAll()

include("platforms/".. e.PLATFORM .."/init.lua")

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
			local ok, msg = xpcall(func, OnError) 
			if not ok then
				logn("runtime error:", client, msg)
			end
		else
			logn("compile error:", client, msg)
		end
		
		timer.Simple(0, function() event.Call("OnConsoleEnvReceive", line) end)
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