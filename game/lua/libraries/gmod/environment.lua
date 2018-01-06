local gine = ... or _G.gine

local env = {}
env._R = {}
env._G = env

gine.env = env

local data = runfile("lua/libraries/gmod/"..(CLIENT and "cl_" or SERVER and "sv_").."exported.lua")

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
	add_lib_copy("jit")

	env.table.insert = function(t,...) table.insert(t,...) return #t end
	env.debug.getregistry = function() return env._R end
	--env.debug.getinfo = function(...) local t = debug.getinfo(...) if t then t.short_src = t.source end return t end
	env.package = package

	for k in pairs(_OLD_G) do
		if type(_G[k]) == "function" then
			env[k] = _G[k]
		end
	end
end

do -- enums
	env.gine_enums = data.enums
	for enum_name, value in pairs(data.enums) do
		env[enum_name] = env[enum_name] or value
	end
end

-- global functions
for func_name, type in pairs(data.globals) do
	if type == "C" then
		env[func_name] = env[func_name] or function(...) logf(("glua NYI: %s(%s)\n"):format(func_name, table.concat(tostring_args(...), ","))) end
	end
end

-- metatables
for meta_name, functions in pairs(data.meta) do
	functions.__tostring = nil
	functions.__newindex = nil

	if not env._R[meta_name] then
		local META = {}
		META.MetaName = meta_name
		META.__index = META

		if functions.IsValid then
			function META:IsValid()
				if self.__removed then return false end
				return self.__obj and self.__obj:IsValid()
			end
		end

		if functions.Remove then
			function META:Remove()
				self.__removed = true
				event.Delay(0,function() prototype.SafeRemove(self.__obj) end)
			end
		end

		env._R[meta_name] = META
	end

	for func_name, type in pairs(functions) do
		if type == "C" then
			env._R[meta_name][func_name] = env._R[meta_name][func_name] or function(...) wlog("NYI: %s:%s(%s)", meta_name, func_name, table.concat(tostring_args(...), ","), 2) end
		end
	end

	gine.objects[meta_name] = gine.objects[meta_name] or {}
end

-- libraries
for lib_name, functions in pairs(data.functions) do
	env[lib_name] = env[lib_name] or {}

	for func_name, type in pairs(functions) do
		if type == "C" then
			env[lib_name][func_name] = env[lib_name][func_name] or function(...) wlog(("NYI: %s.%s(%s)"):format(lib_name, func_name, table.concat(tostring_args(...), ",")), 2) end
		end
	end
end

if gine.debug then
	for _, meta in pairs(env._R) do
		setmetatable(meta, {__newindex = function(s, k, v)
			if not k:startswith("__") then
				wlog("adding meta function that doesn't exist in glua: %s", k, 2)
			end
			rawset(s,k,v)
		end})
	end

	setmetatable(env, {__newindex = function(s, k, v)
		wlog("adding function that doesn't exist in glua: %s", k, 2)
		rawset(s,k,v)
	end})
end

function gine.GetMetaTable(name)
	return gine.env._R[name]
end

runfile("lua/libraries/gmod/libraries/*", gine)
runfile("lua/libraries/gmod/libraries/"..(CLIENT and "client" or SERVER and "server").."/*", gine)

for meta_name, functions in pairs(data.meta) do
	local meta = gine.GetMetaTable(meta_name)
	if functions["Is" .. meta_name] == "C" then
		meta["Is" .. meta_name] = function()
			return true
		end
	end
		for meta_name2 in pairs(data.meta) do
			if meta_name2 ~= meta_name then
				meta["Is" .. meta_name2] = function()
					return false
				end
			end
		end
end

if gine.debug then
	setmetatable(env)

	for _, meta in pairs(env._R) do
		setmetatable(meta)
	end
end

setmetatable(env, {__index = _G})
