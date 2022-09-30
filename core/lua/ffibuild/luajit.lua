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
		local s = [=[
			local ffi = require("ffi")
			local lib = ffi.C
			ffi.cdef([[]=] .. header .. [=[]])
			local CLIB = setmetatable({}, {__index = function(_, k)
				local ok, val = pcall(function() return lib[k] end)
				if ok then
					return val
				end
			end})
		]=]
		s = s .. "library = " .. meta_data:BuildLuaFunctions("^lua_(.+)")
		s = s .. "library.L = " .. meta_data:BuildLuaFunctions("^luaL_(.+)")
		s = s .. "library.e = " .. meta_data:BuildLuaEnums("^LUA_(.+)", {"./src/lua.h"})
		s = s .. "return library\n"
		return s
	end,
	linux = [[
		FROM ubuntu:20.04
		
		ARG DEBIAN_FRONTEND=noninteractive
		ENV TZ=America/New_York

		RUN apt-get update 
		RUN apt-get install -y git make gcc 
	
		WORKDIR /src
		RUN git clone https://github.com/LuaJIT/LuaJIT --depth 1 . && git checkout v2.1
		RUN make -j32 CCDEBUG=-g XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT
	]],
	macos = [[
		git clone https://github.com/LuaJIT/LuaJIT --depth 1 . && git checkout v2.1
		
		export MACOSX_DEPLOYMENT_TARGET=11.0 && make -j32 CCDEBUG=-g XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT
	]],
}
ffibuild.Build(instructions)