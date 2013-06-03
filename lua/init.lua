-- enums
_E = {}
e = _E

_E.MMYY_PLATFORM = MMYY_PLATFORM or tostring(select(1, ...) or nil)

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
		
		-- print(T + 1) = print(os.clock() + 1)
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

Msg = Msg or print
MsgN = MsgN or print

local time = os.clock()
local gtime = time

MsgN("loading mmyy")

_E.USERNAME = tostring(os.getenv("USERNAME")):upper():gsub(" ", "_"):gsub("%p", "")
_G[e.USERNAME] = true

MsgN("username constant = " .. e.USERNAME)

_E.LUA_FOLDER = debug.getinfo(1).source:match("@(.+/)"):gsub("\\", "//")
_E.BASE_FOLDER = e.LUA_FOLDER:match("(.-)lua/")

MsgN("lua folder = " .. e.LUA_FOLDER)
MsgN("base folder = " .. e.BASE_FOLDER)

do -- makes require work from current directory like gmod's include
	local function load(path) 
		local func, err = loadfile(path) 
		
		if err and not err:find("No such file or directory") then 
			return nil, err
		end 
		
		return func 
	end
	
	local function try_relative(path, level)
		level = level or 4
		local func, err = load(path) -- utilities.lua
		
		if not func then
			local dir = debug.getinfo(level).source:match("@(.+/)") or ""
			func, err = load(dir .. path) -- *cd*path
			if not func then
				func, err = load(dir .. path .. ".lua") -- *cd*utilities.lua
				
				if not func then
					return nil, "could not find " .. path
				end
			end
		end
		
		return func, err
	end
	
	local function try_addons(path)
		if addons and addons.HandleLoader then
			path = "lua/" .. path
			for _, path in ipairs(addons.HandleLoader(path)) do
				local func, err = load(path)
				if func then
					return func, err
				end
			end
		end
		
		return nil, "could not find " .. path
	end
	
	local function try_find(path, func, level)
		level = level or 4
		
		if utilities and file then
			local pattern = utilities.GetFileNameFromPath(path)
			if pattern == "*" then
				if not file.FolderExists(path:sub(0, -3)) then
					local dir = debug.getinfo(level).source:match("@(.+)")
					dir = dir:gsub(e.BASE_FOLDER, "")
					dir = dir:match("(.+/)")					
					dir = dir:lower()
					path = path:gsub(dir, "")
					path = dir .. path
				end				
			
				return function(...) 
					for file_name in pairs(file.Find(path)) do
						func(e.BASE_FOLDER .. path:sub(0, -2) .. file_name, ...)
					end
				end
			end
		end
				
		return nil, "could not find " .. path
	end
	
	local function try_libraries(path)
		return load(e.LUA_FOLDER .. "platforms/standard/libraries/" .. path .. ".lua")
	end
	
	local function try_modules(path)
		return load(e.LUA_FOLDER .. "platforms/standard/libraries/" .. path .. ".lua")
	end
	
	table.insert(package.loaders, function(path)
		local func, err
		
		if not func then func, err = try_find(path, require) end
		if not func then func, err = try_relative(path) end
		if not func then func, err = try_libraries(path) end
		if not func then func, err = try_addons(path, require, 4) end
		
		return func, err
	end)
		
	function dofile(path, ...)
		local func, err
		
		if not func then func, err = try_find(path, _OLD_G.dofile, 3) end
		if not func then func, err = try_relative(path, 3) end
		if not func then func, err = try_libraries(path) end
		if not func then func, err = try_addons(path) end
		if not func then func, err = loadfile(path) end
	
		if not func then
			print(err)			
		else			
			local args = {pcall(func, ...)}
			
			if not args[1] then
				print(args[2])
			else
				return select(2, unpack(args))
			end
		end
	end
end

do -- module loading from lua/modules/*platform*/*architecture*/?
	local os = jit.os:lower()
	local arch = jit.arch:lower()
	local ext = 
	{
		windows = ".dll",
		linux = ".so",
	}
		
	local dir = ";" .. e.LUA_FOLDER .. "modules/" .. os .. "/" .. arch .. "/"
	package.cpath = (package.cpath or "") .. dir .. "?" .. (ext[os] or "")
	
	package.path = (package.path or "") .. dir .. "?.lua"
	package.path = package.path .. dir .. "?/init.lua"
	
	package.path = package.path .. ";" .. e.LUA_FOLDER .. "modules/?.lua"
	package.path = package.path .. ";" .. e.LUA_FOLDER .. "modules/?/init.lua"
end

-- library extensions
dofile("platforms/standard/extensions/globals.lua")
dofile("platforms/standard/extensions/debug.lua")
dofile("platforms/standard/extensions/math.lua")
dofile("platforms/standard/extensions/string.lua")
dofile("platforms/standard/extensions/table.lua")
dofile("platforms/standard/extensions/os.lua")

-- meta additions/extensions
dofile("platforms/standard/meta/function.lua")

-- extra libraries
ffi = require("ffi")
_G[ffi.os:upper()] = true
_G[ffi.arch:upper()] = true

do -- ffi's cdef is so anti realtime
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
end

event = dofile("event")
utilities = dofile("utilities")
dofile("null")
file = dofile("file")
addons = dofile("addons")
class = dofile("class")
luadata = dofile("luadata")
timer = dofile("timer")
sigh = dofile("sigh")
base64 = dofile("base64")
input = dofile("input")
msgpack = dofile("msgpack")
json = dofile("json")

-- luasocket
dofile("platforms/standard/libraries/luasocket/socket.lua")
dofile("platforms/standard/libraries/luasocket/mime.lua")

luasocket = dofile("luasocket") 
intermsg = dofile("intermsg") 
mmyy = dofile("mmyy")
timer.Create("socket_think", 0,0, luasocket.Update)
event.AddListener("LuaClose", "luasocket", luasocket.Panic)
--

Path = function(path)

	-- try relative
	local dir = (debug.getinfo(2).source:match("@(.+/)") or ""):gsub(e.BASE_FOLDER, "") -- remove bin32 folder since the file lib handles that
	local new_path = dir .. path
	if file.Exists(new_path) then
		return event.Call("HandleEnginePath", new_path) or new_path -- ask if the path needs to be redirected, such as the root being somewhere else
	end
		
	-- try addons instead	
	if addons and addons.HandleLoader then
		for _, path in ipairs(addons.HandleLoader(path)) do
			local new_path = path:gsub(e.BASE_FOLDER, "")
			if file.Exists(new_path) then
				local val = event.Call("HandleEnginePath", new_path)
				if val then
					return val
				end
			end
		end
	end
	
	-- return default if not found	
	return path
end

-- this should be used for xpcall
function OnError(msg)
	if event.Call("OnLuaError", msg) == false then return end
	
	print("== LUA ERROR ==")
	
	for k, v in pairs(debug.traceback():explode("\n")) do
		local source, msg = v:match("(.+): in function (.+)")
		if source and msg then
			print((k-1) .. "    " .. source:trim() or "nil")
			print("     " .. msg:trim() or "nil")
			print("")
		end
	end
	

	print("")
	local source, _msg = msg:match("(.+): (.+)")
	if source then
		print(source:trim())
		print(_msg:trim())
	else
		print(msg)
	end
	print("")
end

MsgN("mmyy loaded (took " .. (os.clock() - time) .. " ms)")

local time = os.clock()
MsgN("loading platform " .. e.MMYY_PLATFORM)
dofile("platforms/".. e.MMYY_PLATFORM .."/init.lua")
MsgN("sucessfully loaded platform " .. e.MMYY_PLATFORM .. " (took " .. (os.clock() - time) .. " ms)")


local time = os.clock()
MsgN("loading addons")
	addons.LoadAll()
	addons.AutorunAll(e.USERNAME)
MsgN("sucessfully loaded addons (took " .. (os.clock() - time) .. " ms)")

MsgN("sucessfully initialized (took " .. (os.clock() - gtime) .. " ms)")


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
				print("runtime error:", client, msg)
			end
		else
			print("compile error:", client, msg)
		end
		
		timer.Simple(0.1, function() event.Call("OnConsoleEnvReceive", line) end)
	end
end

event.Call("Initialized")