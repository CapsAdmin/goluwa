local gmod = ... or _G.gmod

gmod.env = {}

local env = gmod.env
env._R = {}

local data = include("exported.lua")
local globals = data.functions._G

data.functions._G = nil

do -- copy standard libraries
	local function add_lib_copy(name)
		local lib = {}

		for k,v in pairs(_G[name]) do lib[k] = v end

		env[name] = lib
	end

	add_lib_copy("string")
	add_lib_copy("math")
	add_lib_copy("table")
	add_lib_copy("coroutine")
	add_lib_copy("debug")
	add_lib_copy("bit")
	add_lib_copy("io")
	add_lib_copy("os")
end

do -- enums
	for enum_name, value in pairs(data.enums) do
		env[enum_name] = env[enum_name] or value
	end
	
	include("libraries/gmod/enums.lua", env, gmod)
end

do -- libraries
	for lib_name, functions in pairs(data.functions) do
		env[lib_name] = env[lib_name] or {}
		
		for func_name in pairs(functions) do
			env[lib_name][func_name] = env[lib_name][func_name] or function(...) logf("%s.%s(%s)\n", lib_name, func_name, table.concat(tostring_args(...), ",")) error("NYI", 2) end
		end
	end
	
	for file_name in vfs.Iterate("lua/libraries/gmod/libraries/") do
		local lib_name = file_name:match("(.+)%.")
		
		env[lib_name] = env[lib_name] or {}
		
		include("libraries/gmod/libraries/" .. file_name, env[lib_name], env, gmod)
	end
end

do -- global functions
	for func_name in pairs(globals) do
		env[func_name] = env[func_name] or function(...) logf("%s(%s)\n", func_name, table.concat(tostring_args(...), ",")) error("NYI", 2) end
	end
	
	include("libraries/gmod/globals.lua", env, gmod)
end

do -- metatables
	for meta_name, functions in pairs(data.meta) do
		env._R[meta_name] = env._R[meta_name] or {}
		for func_name in pairs(functions) do
			env._R[meta_name][func_name] = env._R[meta_name][func_name] or function(...) logf("%s:%s(%s)\n", meta_name, func_name, table.concat(tostring_args(...), ",")) error("NYI", 2) end
		end	
	end
	
	for file_name in vfs.Iterate("lua/libraries/gmod/meta/") do
		local meta_name = file_name:match("(.+)%.")
		
		env._R[meta_name] = env._R[meta_name] or {}
		env._R[meta_name].MetaName = env._R[meta_name].MetaName or meta_name
		
		include("libraries/gmod/meta/" .. file_name, env._R[meta_name], env, gmod)
	end
end

setmetatable(env, {__index = _G})