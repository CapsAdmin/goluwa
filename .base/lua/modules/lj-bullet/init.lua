local header = require("lj-bullet.header.lua")
local lib = ffi.load("bullet")

ffi.cdef(header)

local functions = {}
local objects = {}

for def in header:gmatch("(.-)\n") do
	local t = def:match("_wrap_(.-)_")
	local func = def:match("(_wrap.-) ")
	if t == "new" then
		local name = def:match("(.-) %*_wrap")
		objects[name] = objects[name] or {ctors = {}, dtors = {}, functions = {}}
		
		table.insert(objects[name].ctors, func)
	elseif t == "delete" then
		local name = def:match("_wrap_delete_(.-) ")
		objects[name] = objects[name] or {ctors = {}, dtors = {}, functions = {}}
		
		table.insert(objects[name].dtors, func)		
	end
end

for def in header:gmatch("(.-)\n") do
	local t = def:match("_wrap_(.-)_")
	
	if t and t ~= "new" and t ~= "delete" then
		local func = def:match("(_wrap.-) ")
		local name = t
		if objects[name] then
			local func_name = def:match("_wrap_".. name .. "_(.+) %(")
			objects[name].functions[func_name] = func
		else
			local name = def:match("_wrap_(.-) ")
			functions[name] = func
		end
	end
end  

local bullet = {}

for name, data in pairs(objects) do 
	local nice_name = name:match("bt(.+)") or name:match("C(.+)")

	local META = {}
	META.__index = function(...) print(...) end
	
	META.Type = nice_name
	
	function META:__tostring()
		return ("bullet: %s[%p]"):format(nice_name, self)
	end
	
	function META:Remove(...)
		lib[data.dtors[1]](...)
		utilities.MakeNULL(self)
	end
	
	for _, func in pairs(data.functions) do
		local nice_name = func:match(".+"..name.."_(.+)")
		nice_name = nice_name:sub(1, 1):upper() .. nice_name:sub(2)
		
		nice_name = nice_name:gsub("__SWIG_", "_overload")
				
		META[nice_name] = function(self, ...)
			return lib[func](self, ...)
		end
	end
	
	for i, func in pairs(data.ctors) do
		if i == 1 then i = "" end
		bullet["Create" .. nice_name .. i] = function(...)
			local ptr = lib[func](...)
			ffi.metatype(ptr, META)
			
			return ptr
		end
	end
end

--[[
for name, func in pairs(functions) do
	name = name:gsub("__SWIG_", "_overload")
	 
	
	
	print(name) 
end]]      
 
local config = ffi.cast("btCollisionConfiguration *", bullet.CreateDefaultCollisionConfiguration2())
local dispatcher = ffi.cast("btDispatcher *", bullet.CreateCollisionDispatcher(config))
local broadphase = bullet.CreateBroadphaseInterface()
local solver = ffi.cast("btConstraintSolver *", bullet.CreateSequentialImpulseConstraintSolver())

local world = ffi.cast("btDynamicsWorld *", bullet.CreateDiscreteDynamicsWorld(dispatcher, broadphase, solver, config))
print(world:SetGravity())
--world:SetGravity(bullet.CreateVector32(0, -10, 0))
 
return bullet