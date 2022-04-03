local instructions = {
addon = vfs.GetAddonFromPath(SCRIPT_PATH),
c_source = [[
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
]],

gcc_flags = "-I./src",

process_header = function(header)
	local meta_data = ffibuild.GetMetaData(header)
	return meta_data:BuildMinimalHeader(function(s) return s:find("^lua") end, function(s) return s:find("^LUA") end, true, true)
end,

build_lua = function(header, meta_data)
	local lua = ffibuild.StartLibrary(header, "safe_clib_index", "ffi.C")
	lua = lua .. "CLIB = SAFE_INDEX(CLIB)"
	lua = lua .. "library = " .. meta_data:BuildFunctions("^lua_(.+)")
	lua = lua .. "library.L = " .. meta_data:BuildFunctions("^luaL_(.+)")
	lua = lua .. "library.e = " .. meta_data:BuildEnums("^LUA_(.+)", {"./src/lua.h"})
	print(lua)
	return ffibuild.EndLibrary(lua)
end,
}

local instructions = table.copy(instructions)
instructions.name = "luajit"
instructions.url = "https://github.com/LuaJIT/LuaJIT/tree/v2.1.git"
instructions.cmd = "make amalg CCDEBUG=-g XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT MACOSX_DEPLOYMENT_TARGET=10.6"
instructions.clean = "make clean"

ffibuild.Build(instructions)