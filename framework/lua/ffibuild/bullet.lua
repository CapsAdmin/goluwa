if render then
	os.execute("cd ../ffibuild/bullet/ && bash make.sh")
	os.execute("cp -f ../ffibuild/bullet/bullet.lua ./bullet.lua")
	return
end

package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

--ffibuild.Clone("https://github.com/bulletphysics/bullet3.git", "repo/bullet")
--ffibuild.Clone("https://github.com/AndresTraks/BulletSharpPInvoke.git", "repo/libbulletc")

--os.execute("mkdir -p repo/libbulletc/libbulletc/build")
--os.execute("cd repo/libbulletc/libbulletc/build && cmake .. && make")
--os.execute("cp repo/libbulletc/libbulletc/build/libbulletc.so .")

ffibuild.lib_name = "bullet"

local header = ffibuild.ProcessSourceFileGCC([[
	#include "bulletc.h"

]], "-I./repo/libbulletc/libbulletc/src/")

io.writefile("lol.c", header)

local meta_data = ffibuild.GetMetaData(header)

local objects = {}

for key, tbl in pairs(meta_data.functions) do
	if key:sub(1, 2) == "bt" then
		local t = key:match("^(.+)_[^_]+$")
		if t then
			objects[t] = objects[t] or {ctors = {}, functions = {}}
		else
--			print(key)
		end
	else
	--	print(key)
	end
end

do
	local temp = {}
	for k,v in pairs(objects) do
		v.name = k
		table.insert(temp, v)
	end
	table.sort(temp, function(a, b) return #a.name > #b.name end)

	objects = temp
end

local done = {}

for _, info in ipairs(objects) do
	for key, tbl in pairs(meta_data.functions) do
		if not done[key] and key:sub(1, #info.name) == info.name then
			if key:find("_new", nil, true) then
				table.insert(info.ctors, key)
				done[key] = true
			else
				local friendly = key:sub(#info.name+2)
				if friendly == "" then friendly = key end
				table.insert(info.functions, {func = key, friendly = ffibuild.ChangeCase(friendly, "fooBar", "FooBar")})
				done[key] = true
			end
		end
	end
end

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^bt%u") end, function(name) return name:find("^bt%u") end, true, true)

local lua = ffibuild.StartLibrary(header)

local ffi = require("ffi")
local clib = ffi.load("./libbullet.so")
ffi.cdef(header)
lua = lua .. "library = " .. meta_data:BuildFunctions("^bt(%u.+)", nil, nil, nil, function(name)
	local ok, err = pcall(function() return clib[name] end)
	if not pcall(function() return clib[name] end) then
		return false
	end
end)
lua = lua .. "library.e = " .. meta_data:BuildEnums("^bt(%u.+)")

lua = lua .. "library.metatables = {}\n"

local inheritance = {
	btDiscreteDynamicsWorld = "btDynamicsWorld",
	btDynamicsWorld = "btCollisionWorld",

	btRigidBody = "btCollisionObject",

	btBoxShape = "btConvexInternalShape",
	btSphereShape = "btConvexInternalShape",
	btConvexInternalShape = "btConvexShape",
	btConvexShape = "btCollisionShape",
}

do
	collectgarbage()

	for _, info in ipairs(objects) do
		local s = ""

		s = s .. "do -- " .. info.name .. "\n"
		s = s .. "\tlocal META = {}\n"
		s = s .. "\tlibrary.metatables."..info.name.." = META\n"

		if inheritance[info.name] then
			s = s .. "\tfunction META:__index(k)\n"

				s = s .. "\t\tlocal v\n\n"

				s = s .. "\t\tv = META[k]\n"
				s = s .. "\t\tif v ~= nil then\n"
					s = s .. "\t\t\treturn v\n"
				s = s .. "\t\tend\n"

				s = s .. "\t\tv = library.metatables."..inheritance[info.name]..".__index(self, k)\n"
				s = s .. "\t\tif v ~= nil then\n"
					s = s .. "\t\t\treturn v\n"
				s = s .. "\t\tend\n"

			s = s .. "\tend\n"
		else
			s = s .. "\tMETA.__index = function(s, k) return META[k] end\n"
		end

		for i, func_name in ipairs(info.ctors) do
			if i == 1 then i = "" end
			s = s .. "\tfunction library.Create" .. info.name:sub(3) .. i .. "(...)\n"
			s = s .. "\t\tlocal self = setmetatable({}, META)\n"
			s = s .. "\t\tself.ptr = CLIB."..func_name.."(...)\n"
			s = s .. "\t\treturn self\n"
			s = s .. "\tend\n"
		end

		for k,v in ipairs(info.functions) do
			s = s .. "\tfunction META:" .. v.friendly .. "(...)\n"
			s = s .. "\t\treturn CLIB." .. v.func .. "(self.ptr, ...)\n"
			s = s .. "\tend\n"
		end

		s = s .. "end\n"

		lua = lua .. s
	end
end

ffibuild.EndLibrary(lua, header)
