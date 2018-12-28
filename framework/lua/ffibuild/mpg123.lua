package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

os.setenv("NIXPKGS_ALLOW_BROKEN", "1")

local header = ffibuild.NixBuild({
	package_name = "mpg123",
  --  library_name = "libmp3lame",
	src = [[
        #include "mpg123.h"
    ]]
})

local meta_data = ffibuild.GetMetaData(header)

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^mpg123_") end, function(name) return name:find("^MPG123_") end, true, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^mpg123_(.+)", "foo_bar", "FooBar")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^MPG123_(.+)")

ffibuild.EndLibrary(lua, header)
