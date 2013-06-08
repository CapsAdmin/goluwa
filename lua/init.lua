-- enums
_E = _E or {}
e = _E 

_E.PLATFORM = PLATFORM or tostring(select(1, ...) or nil)

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
		
	local log_file
	local buffer = {}
		
	function log(...)
		local args = tostring_args(...)
		if can_print(args) then
			
			if vfs then
				if not log_file then
					log_file = io.open(e.BASE_FOLDER .. "log.txt", "w")
					
					if buffer then
						for k,v in pairs(buffer) do
							log_file:write(unpack(v))
						end
						
						buffer = nil
					end
				end
				
				log_file:write(unpack(args))
			else
				table.insert(buffer, args)
			end
			
			io.write(unpack(args))
		end
	end
	
	function logn(...)
		local args = {...}
		table.insert(args, "\n")
		return log(unpack(args))
	end

	function logf(str, ...)
		logn(safeformat(str, ...))
	end

	function errorf(str, level, ...)
		error(string.format(str, level, ...))
	end

	function warning(verbosity, ...)
		local level = get_verbosity_level()
		
		-- if the level is below 0 always log
		if level < 0 then
			return log(...)
		end
		
		-- if verbosity is a string only show warnings log_debug_filter is set to
		if type(verbosity) == "string" and verbosity == get_debug_filter() then
			return log(...)
		end	
		
		-- otherwise check the verbosity level against the input	
		if level <= verbosity then
			return log(...)
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

_E.USERNAME = tostring(os.getenv("USERNAME")):upper():gsub(" ", "_"):gsub("%p", "")
_G[e.USERNAME] = true

log("\n\n")
log([[
 _ __ ___  _ __ ___  _   _ _   _ 
| '_ ` _ \| '_ ` _ \| | | | | | |
| | | | | | | | | | | |_| | |_| |
|_| |_| |_|_| |_| |_|\__, |\__, |
                     |___/ |___/ 
]])
logf("launched on %s", os.date())
logn("executed by " .. e.USERNAME)
log("\n\n")

do -- ffi
	ffi = require("ffi")
	_G[ffi.os:upper()] = true
	_G[ffi.arch:upper()] = true

	 -- ffi's cdef is so anti realtime
	if not ffi.already_defined then
		ffi.already_defined = {}
		
		old_ffi_cdef = old_ffi_cdef or ffi.cdef
		ffi.cdef = function(str, ...)
			local val = ffi.already_defined[str]
			
			if val then
				return val
			end
		
			ffi.already_defined[str] = str
			return old_ffi_cdef(str, ...)
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

do -- file system
	lfs = require("lfs")

	-- the base folder is always 3 paths up (bin/os/arch)
	_E.BASE_FOLDER = "../../../" 
	_E.ABSOLUTE_BASE_FOLDER = lfs.currentdir():gsub("\\", "/"):match("(.+/).-/.-/")

	-- this is ugly but it's because we haven't included the global extensions yet..
	_G.check = function() end
	vfs = dofile(_E.BASE_FOLDER .. "/lua/platforms/standard/libraries/vfs.lua")

	-- mount the base folders
	
	-- current dir
	vfs.Mount(lfs.currentdir())
	
	-- and 3 folders up
	vfs.Mount(e.BASE_FOLDER)
	
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

do -- include
	local base = lfs.currentdir()

	local include_stack = {}
	
	function include(path, ...)
		local dir, file = path:match("(.+/)(.+)")
		
		if not dir then
			dir = ""
			file = path
		end
				
		vfs.Silence(true)
		
		 
		local previous_dir = include_stack[#include_stack]		
		
		if previous_dir then
			dir = previous_dir .. dir
		end
		
		--logn("")
		--logn(("\t"):rep(#include_stack).."TRYING REL: ", dir .. file)
		
		local func, err = vfs.loadfile("lua/" .. dir .. file)
					
		if err then
			func, err = vfs.loadfile("lua/" .. path)
			
			if err then		
				func, err = vfs.loadfile(dir .. file)
				
				if err then
					func, err = loadfile(path)
					--logn(("\t"):rep(#include_stack).."TRYING ABS: ", dir .. file)
				end
			end
		end
		

		if func then 
			include_stack[#include_stack + 1] = dir
		
			--logn(("\t"):rep(#include_stack + 1).."FILE FOUND: ", file)
			--logn(("\t"):rep(#include_stack + 1).."DIR IS NOW: ", dir)
			--logn("")
			local res = {pcall(func, ...)}
			
			if not res[1] then
				logn(res[2])
			end
			
			include_stack[#include_stack] = nil
						 
			return select(2, unpack(res))
		end
		
		logn(path:sub(1) .. " " .. err)
		
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

-- meta
include(meta .. "function.lua")
include(meta .. "null.lua")

-- luasocket
luasocket = include(libraries .. "luasocket.lua") 
timer.Create("socket_think", 0,0, luasocket.Update)
event.AddListener("LuaClose", "luasocket", luasocket.Panic)

-- this should be used for xpcall
function OnError(msg)
	if event.Call("OnLuaError", msg) == false then return end
	
	logn("== LUA ERROR ==")
	
	for k, v in pairs(debug.traceback():explode("\n")) do
		local source, msg = v:match("(.+): in function (.+)")
		if source and msg then
			logn((k-1) .. "    " .. source:trim() or "nil")
			logn("     " .. msg:trim() or "nil")
			logn("")
		end
	end

	logn("")
	local source, _msg = msg:match("(.+): (.+)")
	if source then
		logn(source:trim())
		logn(_msg:trim())
	else
		logn(msg)
	end
	logn("")
end

addons.LoadAll()

include("platforms/".. e.PLATFORM .."/init.lua")

addons.AutorunAll(e.USERNAME)

if CREATED_ENV then
	mmyy.SetWindowTitle(TITLE)
	
	utilities.SafeRemove(ENV_SOCKET)
	
	ENV_SOCKET = luasocket.Client()

	ENV_SOCKET:Connect("localhost", PORT)	
	ENV_SOCKET:SetTimeout()
	
	ENV_SOCKET.OnReceive = function(self, line)		
		local func, msg = loadstring(line)

		if func then
			local ok, msg = pcall(func) 
			if not ok then
				logn("runtime error:", client, msg)
			end
		else
			logn("compile error:", client, msg)
		end
		
		timer.Simple(0, function() event.Call("OnConsoleEnvReceive", line) end)
	end 
end

vfs.MonitorEverything(true) 

event.Call("Initialized")