MMYY_PLATFORM = MMYY_PLATFORM or select(1, ...) or nil

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

LUA_FOLDER = debug.getinfo(1).source:match("@(.+/)"):gsub("\\", "//")
BASE_FOLDER = LUA_FOLDER:match("(.-)lua/")

do -- makes require work from current directory like gmod's require
	local function load(path) local func, err = loadfile(path) if err and not err:find("No such file or directory") then error(err, 4) end return func end
	
	local function try_relative(path)
		local func = load(path) -- utilities.lua
		
		if not func then
			local dir = debug.getinfo(4).source:match("@(.+/)") or ""
			func = load(dir .. path) -- *cd*path
			if not func then
				func = load(dir .. path .. ".lua") -- *cd*utilities.lua
			end
		end
		
		return func
	end
	
	local function try_addons(path)
		if addons and addons.HandleLoader then
			for _, path in ipairs(addons.HandleLoader(path)) do
				local func = load(path)
				if func then
					return func
				end
			end
		end
	end
	
	local function try_find(path)
		if utilities and file then
			local pattern = utilities.GetFileNameFromPath(path)
			
			if pattern == "*" then
				if not file.FolderExists(path:sub(0, -3)) then
					local dir = debug.getinfo(4).source:match("@../(.+/)") or ""
					path = dir .. path
				end
			
				return function() 
					for file_name in pairs(file.Find(path)) do	
						require(BASE_FOLDER .. path:sub(0, -2) .. file_name)
					end
				end
			end
		end
	end
	
	local function try_libraries(path)
		return load(LUA_FOLDER .. "platforms/standard/libraries/" .. path .. ".lua")
	end
	
	table.insert(package.loaders, function(path)
		return try_find(path) or try_relative(path) or try_libraries(path) or try_addons(path)
	end)
end

do -- module loading from lua/modules/*platform*/*architecture*/?
	local os = jit.os:lower()
	local arch = jit.arch:lower()
	local ext = 
	{
		windows = ".dll",
		linux = ".so",
	}
		
	package.cpath = package.cpath .. ";" ..LUA_FOLDER .. "modules\\" .. os .. "\\" .. arch .. "\\" .. "?" .. (ext[os] or "")
end

-- library extensions
require("platforms/standard/libraries/globals.lua")
require("platforms/standard/libraries/debug.lua")
require("platforms/standard/libraries/math.lua")
require("platforms/standard/libraries/string.lua")
require("platforms/standard/libraries/table.lua")

-- extra libraries
ffi = require("ffi")
events = require("events")
utilities = require("utilities")
file = require("file")
addons = require("addons")
class = require("class")
luadata = require("luadata")
timer = require("timer")
sigh = require("sigh")
luasocket = require("luasocket")
lpeg = require("lpeg")
base64 = require("base64")
input = require("input")
msgpack = require("msgpack")

require("null")

require("platforms/"..(MMYY_PLATFORM or "nil").."/init.lua")
addons.LoadAll()
addons.AutorunAll(USERNAME)

print("ran init.lua")
events.Call("Initialized")

MsgN("=========================================")
MsgN("=========== mmyy initialized ============")
MsgN("=========================================")
MsgN("")