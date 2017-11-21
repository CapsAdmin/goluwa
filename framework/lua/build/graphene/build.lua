package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.BuildSharedLibrary(
	"graphene",
	"https://github.com/ebassi/graphene.git",
	"./configure && make"
)

local header = ffibuild.BuildCHeader([[
	#include "graphene.h"
]], "-I./repo/src/")

local meta_data = ffibuild.GetMetaData(header)
local header = meta_data:BuildMinimalHeader(function(name) return name:find("^graphene_") end, function(name) return name:find("^GRAPHENE_") end, true, true)
local lua = ffibuild.StartLibrary(header, "metatables")

lua = lua .. "library = " .. meta_data:BuildFunctions("^graphene_(.+)", "foo_bar", "FooBar")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^GRAPHENE_(.+)", "repo/src/graphene.h")

local type_info = {
	--ray = 3,
	--triangle = 3*3,
	--plane = 4,
	vec3 = 3,
	--sphere = 3,
	--box = 4,
	quaternion = {0,0,0,1},
	--quad = 4,
	--point = 2,
	matrix = {0,0,0,1, 0,0,1,0, 0,1,0,0, 1,0,0,0,},
	euler = 3,
	vec2 = 2,
	vec4 = 4,
	--size = 2,
	point3d = 3,
	--frustum = 4,
	rect = 4,
}

local objects = {}

for _, type in pairs(meta_data.typedefs) do
    local type_name = type:GetBasicType():match("struct _graphene_(.+)_t")
    if type_name then
		objects[type_name] = {meta_name = type_name, declaration = type:GetDeclaration(meta_data), functions = {}}
        for func_name, func_info in pairs(meta_data:GetFunctionsStartingWithType(type)) do
			local friendly = func_name:match("graphene_" .. type_name .. "_(.+)")
			friendly = ffibuild.ChangeCase(friendly, "foo_bar", "FooBar")
			objects[type_name].functions[friendly] = func_info
        end
		objects[type_name].functions.__gc = objects[type_name].functions.Free -- use ffi.new
		objects[type_name].functions.__mul = objects[type_name].functions.Multiply
		objects[type_name].functions.__div = objects[type_name].functions.Divide
		objects[type_name].functions.__add = objects[type_name].functions.Add
		objects[type_name].functions.__sub = objects[type_name].functions.Subtract
		objects[type_name].functions.__unm = objects[type_name].functions.Negate
		objects[type_name].functions.__len = objects[type_name].functions.Length


		local friendly = ffibuild.ChangeCase(type_name, "foo_bar", "FooBar")

		if type_name == "point3d" then
			lua = lua .. "library.point3d = function(x,y,z) local s = library.Point3dAlloc() s:Init(x or 0, y or 0, z or 0) return s end\n"
		elseif objects[type_name].functions.InitFromFloat and type_info[type_name] then
			local default = type_info[type_name]
			if _G.type(default) == "number" then
				local tbl = {}
				for i = 1, default do
					tbl[i] = 0
				end
				default = tbl
			end
			lua = lua .. "local float_t = ffi.typeof('float["..#default.."]')\n"

			local args = {}
			for i = 1, #default do
				table.insert(args, "_" .. i)
			end

			local defaults = {}
			for i = 1, #default do
				defaults[i] = "_" .. i .. " or " .. default[i]
			end

			lua = lua .. "library." .. type_name .. " = function("..table.concat(args, ", ")..") local s = library."..friendly.."Alloc() s:InitFromFloat(float_t("..table.concat(defaults, ", ") ..")) return s end\n"
		else
			lua = lua .. "library." .. type_name .. " = library."..friendly.."Alloc\n"
		end
    end
end

for _, info in pairs(objects) do
	lua = lua .. meta_data:BuildLuaMetaTable(info.meta_name, info.declaration, info.functions, argument_translate, return_translate, nil, true)
end

ffibuild.EndLibrary(lua, header)
