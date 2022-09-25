local instructions = {
	name = "luajit",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),
	c_source = [[
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
]],
	gcc_flags = "-I./src",
	process_header = function(header)
		local meta_data = ffibuild.GetMetaData(header)
		return meta_data:BuildMinimalHeader(
			function(s)
				return s:find("^lua")
			end,
			function(s)
				return s:find("^LUA")
			end,
			true,
			true
		)
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
	dockerfile = [[
		FROM ubuntu:20.04

		ARG DEBIAN_FRONTEND=noninteractive
		ENV TZ=America/New_York

		RUN apt-get update 
		
		RUN apt-get install -y git make gcc 
	
		WORKDIR /src
		RUN git clone https://github.com/LuaJIT/LuaJIT --depth 1 . && git checkout v2.1
		RUN make -j32 CCDEBUG=-g XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT
	]]
}

ffibuild.DockerBuild(instructions)