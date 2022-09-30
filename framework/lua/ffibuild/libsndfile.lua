ffibuild.Build(
	{
		name = "sndfile",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		linux = [[
			FROM ubuntu:20.04

			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York

			RUN apt-get update
			RUN apt-get install -y autogen ninja-build libogg-dev libvorbis-dev libflac-dev libopus-dev libasound2-dev libsqlite3-dev libspeex-dev libmp3lame-dev libmpg123-dev cmake g++ python3
			RUN apt-get install -y git
		
			WORKDIR /src
			RUN git clone https://github.com/erikd/libsndfile.git --depth 1 .
			RUN mkdir out
			RUN cd out && cmake -DBUILD_SHARED_LIBS=ON -DENABLE_MPEG=ON .. && make --jobs 32
			RUN cd out && ldd libsndfile.so
			RUN cd out && mkdir deps
			RUN cd out && ldd libsndfile.so | awk 'NF == 4 { system("cp " $3 " deps/. ") }'
		]],
		c_source = [[
		#include "sndfile.h"
	]],
		gcc_flags = "-I./include",
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^sf_")
				end,
				function(name)
					return name:find("^SF")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			do
				local extra = {}

				for name, struct in pairs(meta_data.structs) do
					if name:find("^struct SF_") and not header:find(name) then
						list.insert(
							extra,
							{str = name .. struct:GetDeclaration(meta_data) .. ";\n", pos = struct.i}
						)
					end
				end

				list.sort(extra, function(a, b)
					return a.pos < b.pos
				end)

				local str = ""

				for i, v in ipairs(extra) do
					str = str .. v.str
				end

				header = header .. str
			end

			local s = [=[
				local ffi = require("ffi")
				local CLIB = assert(ffi.load("sndfile"))
				ffi.cdef([[]=] .. header .. [=[]])
			]=]
			s = s .. "library = " .. meta_data:BuildLuaFunctions("^sf_(.+)", "foo_bar", "FooBar")
			s = s .. "library.e = " .. meta_data:BuildLuaEnums("^SF[CMD]?_(.+)")
			s = s .. "library.clib = CLIB\n"
			s = s .. "return library\n"
			return s
		end,
	}
)