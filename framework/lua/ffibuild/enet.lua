ffibuild.Build(
	{
		name = "enet",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		c_source = [[#include "enet/enet.h"]],
		gcc_flags = "-I./include",
		linux = [[		
			FROM ubuntu:20.04
			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York
			RUN apt-get update

			RUN apt-get install -y git gcc automake libtool make

			WORKDIR /src
			RUN git clone https://github.com/lsalzman/enet.git --depth 1 .

			RUN autoreconf -vfi && ./configure --disable-dependency-tracking && make --jobs 32
		]],
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			meta_data.functions.enet_socketset_select.arguments[2] = ffibuild.CreateType("type", "void *")
			meta_data.functions.enet_socketset_select.arguments[3] = ffibuild.CreateType("type", "void *")
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^enet_")
				end,
				function(name)
					return name:find("^ENET_")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local s = [=[
				local ffi = require("ffi")
				local CLIB = assert(ffi.load("enet"))
				ffi.cdef([[]=] .. header .. [=[]])
			]=]
			s = s .. "local library = " .. meta_data:BuildLuaFunctions("^enet_(.+)", "foo_bar", "FooBar")
			s = s .. "library.e = " .. meta_data:BuildLuaEnums("^ENET_(.+)")
			s = s .. "library.clib = CLIB\n"
			s = s .. "return library\n"
			return s
		end,
	}
)