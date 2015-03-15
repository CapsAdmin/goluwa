steam.MountSourceGame("gmod")
vfs.AddModuleDirectory(R"lua/includes/modules/")
vfs.AddModuleDirectory(R"lua/libraries/gmod/libraries/")

event.AddListener("PreLoadString", "gmod_preprocess", function(code, path)
	if not path:find("garrysmod", nil, true) then return end
		
	local code, data = utility.StripLuaCommentsAndStrings(code)
	
	code = code:gsub("&&", " and ")
	code = code:gsub("||", " or ")
	code = code:gsub("!=", " ~= ")
	code = code:gsub("!", "not ")
	code = code:gsub("/%*", "--[[")
	code = code:gsub("%*/", "]]")
	code = code:gsub("//", "--")
	
	code = utility.RestoreLuaCommentsAndStrings(code, data)
	
	if code:find("continue", nil, true) then
		local lex_setup = require("luajit-lang-toolkit.lexer")
		local reader = require("luajit-lang-toolkit.reader")
		
		local ls = lex_setup(reader.string(code), code)
		
		local stack = {}
		
		repeat
			ls:next()
			table.insert(stack, table.copy(ls))
		until ls.token == "TK_eof"
		
		for i, ls in ipairs(stack) do
			if ls.token == "TK_name" and ls.tokenval == "continue" then
				local start
				
				for i = i, 1, -1 do
					local v = stack[i]
					
					if v.token == "TK_do" then
						start = v
						start.stack_pos = i
						break
					end
				end
				
				local stop
				
				local balance = 0
				local found_start
				
				for i = start.stack_pos, #stack do
					local v = stack[i]
					
					if v.token == "TK_do" or v.token == "TK_then" or v.token == "TK_function" then
						balance = balance + 1
						found_start = true
					elseif v.token == "TK_end" then
						balance = balance - 1
					end
					
					if found_start and balance == 0 then
						stop = v
						break
					end
				end
				
				local lines = code:explode("\n")
				
				if not lines[stop.linenumber]:find("CONTINUE") then
					lines[stop.linenumber] = " ::CONTINUE:: ".. lines[stop.linenumber]
				end
				
				code = table.concat(lines, "\n")
			end
		end
	end
	
	local code, data = utility.StripLuaCommentsAndStrings(code)
	
	code = code:gsub("continue", " goto CONTINUE ")
	
	code = utility.RestoreLuaCommentsAndStrings(code, data)
	
	if path:find("includes/util/client.lua") then vfs.Write("gmod_out.lua", code) end
		
	
		
	return code
end)

local env = {}

env.Vector = Vec3
env.Angle = Ang3
env.module = function(name, _ENV)
	local tbl = {}
	
	if _ENV == package.seeall then
		_ENV = env
		setmetatable(tbl, {__index = _ENV})
	elseif _ENV then
		print(_ENV, "!?!??!?!")
	end
	
	if not tbl._NAME then
		tbl._NAME = name
		tbl._M = tbl
		tbl._PACKAGE = name:gsub("[^.]*$", "")
	end
	
	package.loaded[name] = tbl
	env[name] = tbl
	
	setfenv(2, tbl)
end

local function add_lib_copy(name)
	local lib = {}

	for k,v in pairs(_G[name]) do lib[k] = v end

	env[name] = lib
end

add_lib_copy("string")
add_lib_copy("math")
add_lib_copy("table")
add_lib_copy("coroutine")

include("libraries/gmod/globals.lua", env)
include("libraries/gmod/constants.lua", env)

for name in vfs.Iterate("lua/libraries/gmod/libraries/") do
	env[name:match("(.+)%.")] = include("libraries/gmod/libraries/" .. name)
end

do
	env.MetaTables = {}

	for name in vfs.Iterate("lua/libraries/gmod/meta/") do
		local meta = include("libraries/gmod/meta/" .. name)
		env.MetaTables[meta.Type] = meta
	end
	
	env.FindMetaTable = function(name) return env.MetaTables[name] end
end

setmetatable(env, {__index = _G})

event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
	if not path:find("garrysmod", nil, true) then return end
	
	setfenv(func, env)
end)

include("includes/init.lua")
