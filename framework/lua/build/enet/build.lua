package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

ffibuild.BuildSharedLibrary(
	"enet",
	"https://github.com/lsalzman/enet.git",
	"autoreconf -vfi && ./configure && make"
)

local header = ffibuild.BuildCHeader([[
#include "enet/enet.h"
]], "-I./repo/include")

local meta_data = ffibuild.GetMetaData(header)

meta_data.functions.enet_socketset_select.arguments[2] = ffibuild.CreateType("type", "void *")
meta_data.functions.enet_socketset_select.arguments[3] = ffibuild.CreateType("type", "void *")

local header = meta_data:BuildMinimalHeader(function(name) return name:find("^enet_") end, function(name) return name:find("^ENET_") end, true, true)

local lua = ffibuild.StartLibrary(header)

lua = lua .. "library = " .. meta_data:BuildFunctions("^enet_(.+)", "foo_bar", "FooBar")
lua = lua .. "library.e = " .. meta_data:BuildEnums("^ENET_(.+)")

ffibuild.EndLibrary(lua, header)