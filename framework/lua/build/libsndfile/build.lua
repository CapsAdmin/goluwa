package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local header = ffibuild.NixBuild({
	name = "libsndfile",
	libname = "libsndfile",
	src = [[
	#include "sndfile.h"
]]})

local meta_data = ffibuild.GetMetaData(header)
local header = meta_data:BuildMinimalHeader(function(name) return name:find("^sf_") end, function(name) return name:find("^SF") end, true, true)

do
    local extra = {}

    for name, struct in pairs(meta_data.structs) do
        if name:find("^struct SF_") and not header:find(name) then
            table.insert(extra, {str = name .. struct:GetDeclaration(meta_data) .. ";\n", pos = struct.i})
        end
    end

    table.sort(extra, function(a, b) return a.pos < b.pos end)

    local str = ""

    for i,v in ipairs(extra) do
        str = str .. v.str
    end

    header = header .. str
end

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^sf_(.+)", "foo_bar", "FooBar")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^SF[CMD]?_(.+)")

ffibuild.EndLibrary(lua, header)
