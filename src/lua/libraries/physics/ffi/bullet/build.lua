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
			cdef = "typedef struct {} " .. t .. ";\n" .. cdef
		else
			print(err, "!!!")
			break
		end
	else
		print("success!")
		break
	end
end

vfs.Write("bullet_cdef", cdef)

local lines = cdef:explode("\n")
local objects = {}

for i, line in ipairs(lines) do
	if line:find("(", nil, true) then
		if line:find("_new%d%(") or line:find("_new(", nil, true) then

			local cfunc = line:match("(%S+)%(")
			local object_name = cfunc:match("bt(.-)_new") or cfunc:match("(.-)_new")
			local ctype = line:match("(.-)%*"):trim()

			objects[object_name] = objects[object_name] or {constructors = {}, functions = {}, ctype = ctype}

			local function_name = object_name .. (cfunc:match(".+(%d)") or "")

			objects[object_name].constructors["Create" .. function_name] = {
				cfunc = cfunc,
				line = line,
			}
		end
	end
end

for name, info in pairs(objects) do
	local type = "bt" .. name

	for i, line in ipairs(lines) do
		if line:find(type .. "_", nil, true) and not line:find("_new", nil, true) then
			local cfunc = line:match(".+%s(bt.-_.+)%(")

			if cfunc and cfunc:match("(.+)_") == type then

				local function_name = cfunc:match(".+_(.+)")
				function_name = function_name:gsub("^(.)", string.upper)

				info.functions[function_name] = {
					cfunc = cfunc,
					line = line,
				}
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

		for name, info in pairs(info.functions) do
			a("\tfunction META:" .. name .. "(...)")
				a("\t\treturn lib." .. info.cfunc .. "(self, ...)")
			a("\tend")
		end

		a("\tffi.metatype('"..info.ctype.."', META)")

		for name, info in pairs(info.constructors) do
			a("\tfunction bullet." .. name .. "(...)")
				a("\t\treturn lib."..info.cfunc.."(...)")
			a("\tend")
		end

	a("end")
end

a("return bullet")

vfs.Write([[C:\goluwa\goluwa\src\lua\libraries\physics\ffi\bullet\init.lua]], table.concat(out, "\n"))