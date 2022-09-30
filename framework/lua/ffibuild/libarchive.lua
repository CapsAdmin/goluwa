--[[
	ubuntu dependencies

	https://github.com/libarchive/libarchive/blob/master/.github/workflows/ci.yml#L54

]] ffibuild.Build(
	{
		name = "libarchive",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		linux = [[
			FROM ubuntu:20.04

			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York
			RUN apt-get update

			# https://github.com/libarchive/libarchive/blob/master/.github/workflows/ci.yml
			RUN apt-get install -y \
				autoconf \
				automake \
				bsdmainutils \
				build-essential \
				cmake \
				ghostscript \ 
				git \
				groff \
				libssl-dev \
				libacl1-dev \
				libbz2-dev \
				liblzma-dev \
				liblz4-dev \
				libzstd-dev \
				lzop \
				pkg-config \
				zip \
				zlib1g-dev \
				libtool

			WORKDIR /src

			RUN git clone https://github.com/libarchive/libarchive.git --depth 1 .
			
			RUN mkdir out && cd out && cmake .. && make --jobs 16
		]],
		c_source = [[
		#include "archive.h"
		#include "archive_entry.h"
	]],
		gcc_flags = "-I./libarchive",
		strip_undefined_symbols = true,
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			table.print(meta_data)
			meta_data.structs["struct timespec"] = nil
			meta_data.structs["struct stat"] = nil
			meta_data.structs["struct _IO_marker"] = nil
			meta_data.structs["struct _IO_FILE"] = nil
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^archive_")
				end,
				function(name)
					return name:find("^ARCHIVE_")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local s = [=[
				local ffi = require("ffi")
				local lib = assert(ffi.load("libarchive"))
				ffi.cdef([[]=] .. header .. [=[]])
				local CLIB = setmetatable({}, {__index = function(_, k)
					local ok, val = pcall(function() return lib[k] end)
					if ok then
						return val
					end
				end})
			]=]
			s = s .. "library = " .. meta_data:BuildLuaFunctions("^archive_(.+)", "foo_bar", "FooBar")
			s = s .. "library.e = " .. meta_data:BuildLuaEnums("^ARCHIVE_(.+)", "./libarchive/archive.h", "ARCHIVE_")
			s = s .. "library.clib = CLIB\n"
			s = s .. "return library\n"
			return s
		end,
	}
)