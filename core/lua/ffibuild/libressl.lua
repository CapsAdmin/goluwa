ffibuild.Build(
	{
		name = "libtls",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		linux = [[
			FROM ubuntu:20.04

			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York

			RUN apt-get update 
			
			RUN apt-get install -y git make gcc 

			RUN apt-get install -y autogen autoconf automake libtool perl

			WORKDIR /src
			RUN git clone https://github.com/libressl-portable/portable.git --depth 1 .
			RUN ./autogen.sh && ./configure && make -j32
		]],
		gcc_flags = "-I./include",
		c_source = [[
			#include <tls.h>
		]],
		filter_library = function(path)
			if
				path:ends_with("libtls") or
				path:ends_with("libssl") or
				path:ends_with("libcrypto")
			then
				return true
			end
		end,
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			meta_data.functions[""] = nil
			return meta_data:BuildMinimalHeader(
				function(s)
					return s:find("^tls_")
				end,
				function(s)
					return s:find("^TLS_")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local s = [=[
				local ffi = require("ffi")
				local lib = assert(ffi.load("tls"))
				ffi.cdef([[]=] .. header .. [=[]])
				local CLIB = setmetatable({}, {__index = function(_, k)
					local ok, val = pcall(function() return lib[k] end)
					if ok then
						return val
					end
				end})
			]=]
			s = s .. "library = " .. meta_data:BuildLuaFunctions("^tls_(.+)")
			s = s .. "library.e = " .. meta_data:BuildLuaEnums("^TLS_(.+)", {"./include/tls.h"})
			s = s .. "library.clib = CLIB\n"
			s = s .. "return library\n"
			return s
		end,
	}
)