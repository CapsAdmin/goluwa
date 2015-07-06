local cdef = vfs.Read("bullet_cdef")

if not cdef then
	cdef = {
		"typedef float btScalar;",	
	}

	for path in vfs.Iterate([[C:\goluwa\bin_src\bullet3\BulletSharpPInvoke\libbulletc\src\.]], nil, true) do
		if path:endswith(".h") then
			for line in vfs.Read(path):gmatch("EXPORT ([^\n]-;)") do
				table.insert(cdef, line:trim())
			end
		end
	end

	cdef = table.concat(cdef, "\n")
end

for i = 1, 500 do
	local ok, err = pcall(ffi.real_cdef, cdef)
	
	if not ok then		
		local t = err:match("expected near '(.-)'")
		if t then
			cdef = "typedef void* " .. t .. "; //" .. err .. "\n" .. cdef
		else
			print(err, "!!!")
			break
		end
	else
		print("success!")
		break
	end
	
	vfs.Write("bullet_cdef", cdef)
end


local lines = cdef:explode("\n")
local objects = {}

for i, line in ipairs(lines) do
	if line:find("(", nil, true) then
		if line:find("_new[%d?]%(") then
			local cfunc = line:match("(%S+)%(")
			local object_name = cfunc:match("bt(.-)_new") or cfunc:match("(.-)_new")
			
			objects[object_name] = objects[object_name] or {constructors = {}, functions = {}}
			
			table.insert(objects[object_name].constructors, {
				cfunc = cfunc,
				line = line,
			})
			
			local type = "bt" .. object_name
			
			for i, line in ipairs(lines) do
				if line:find(type .. "_", nil, true) and not line:find("_new", nil, true) then
					local cfunc = line:match(".+%s(bt.-_.+)%(")
					
					if cfunc and cfunc:match("(.+)_") == type then
						
						local function_name = cfunc:match(".+_(.+)")
						function_name = function_name:gsub("^(.)", string.upper)
						function_name = function_name:match("(.+)%d$") or function_name
						
						objects[object_name].functions[function_name] = objects[object_name].functions[function_name] or {}
						
						table.insert(objects[object_name].functions[function_name], {
							cfunc = cfunc,
							line = line,
						})
					end
				end
			end
		end
	end
end

local out = {}

local a = function(line) table.insert(out, line) end

a("ffi.cdef([[")
a(cdef)
a("]])")

a("local lib = ffi.load('libbulletc')")
a("local bullet = {}")

for name, info in pairs(objects) do
	a("do -- " .. name)
	
		a("\tlocal META = {}")
		a("\tMETA.__index = META")
		
		for k,v in pairs(info.functions) do
		a("\tfunction META:" .. k .. "(...)")
			a("\t\tlib." .. v[1].cfunc .. "(self.__ptr, ...)")
		a("\tend")
		end
	
		a("\tfunction bullet.Create" .. name .. "(...)")
			a("\t\treturn setmetatable({__ptr = lib."..info.constructors[1].cfunc.."(...)}, META)")
		a("\tend")
	
	a("end")
end

a("return bullet")

vfs.Write([[C:\goluwa\goluwa\src\lua\libraries\physics\ffi\bullet\init.lua]], table.concat(out, "\n"))