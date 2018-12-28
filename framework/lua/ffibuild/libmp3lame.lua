package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

os.setenv("NIXPKGS_ALLOW_BROKEN", "1")

local header = ffibuild.NixBuild({
	package_name = "lame",
    library_name = "libmp3lame",
	src = [[
        #include "lame/lame.h"
    ]]
})

local meta_data = ffibuild.GetMetaData(header)

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^lame_") end, function(name) return name:find("^LAME_") end, true, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^lame_(.+)", "foo_bar", "FooBar")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^LAME_(.+)")

ffibuild.EndLibrary(lua, header)
