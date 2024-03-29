ffibuild.Build(
	{
		name = "freetype",
		linux = [[
			FROM ubuntu:20.04
			ARG DEBIAN_FRONTEND=noninteractive
			ENV TZ=America/New_York
			RUN apt-get update
			RUN apt-get install -y git make cmake libx11-dev libpng-dev zlib1g-dev libbz2-dev libharfbuzz-dev tree libbrotli-dev

			WORKDIR /src
			RUN git clone git://git.sv.nongnu.org/freetype/freetype2.git --depth 1 .
			RUN mkdir build && cd build && cmake .. -DBUILD_SHARED_LIBS=1 && make --jobs 32

		]],
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		strip_undefined_symbols = true,
		c_source = [[
		#include <ft2build.h>

		typedef struct _FT_Glyph_Class {} FT_Glyph_Class;

		#include FT_CONFIG_CONFIG_H
		#include FT_LZW_H
		#include FT_CONFIG_STANDARD_LIBRARY_H
		#include FT_BZIP2_H
		#include FT_CONFIG_OPTIONS_H
		#include FT_WINFONTS_H
		#include FT_CONFIG_MODULES_H
		#include FT_GLYPH_H
		#include FT_FREETYPE_H
		#include FT_BITMAP_H
		#include FT_ERRORS_H
		#include FT_BBOX_H
		#include FT_MODULE_ERRORS_H
		#include FT_CACHE_H
		#include FT_SYSTEM_H
		#include FT_CACHE_IMAGE_H
		#include FT_IMAGE_H
		#include FT_CACHE_SMALL_BITMAPS_H
		#include FT_TYPES_H
		#include FT_CACHE_CHARMAP_H
		#include FT_LIST_H
		//#include FT_MAC_H
		#include FT_OUTLINE_H
		#include FT_BDF_H
		#include FT_MULTIPLE_MASTERS_H
		#include FT_SIZES_H
		#include FT_SFNT_NAMES_H
		#include FT_MODULE_H
		#include FT_OPENTYPE_VALIDATE_H
		#include FT_RENDER_H
		#include FT_GX_VALIDATE_H
		#include FT_AUTOHINTER_H
		#include FT_PFR_H
		#include FT_CFF_DRIVER_H
		#include FT_STROKER_H
		#include FT_TRUETYPE_DRIVER_H
		#include FT_SYNTHESIS_H
		#include FT_TYPE1_TABLES_H
		#include FT_FONT_FORMATS_H
		#include FT_TRUETYPE_IDS_H
		#include FT_TRIGONOMETRY_H
		#include FT_TRUETYPE_TABLES_H
		#include FT_LCD_FILTER_H
		#include FT_TRUETYPE_TAGS_H
		#include FT_UNPATENTED_HINTING_H
		#include FT_INCREMENTAL_H
		#include FT_CID_H
		#include FT_GASP_H
		#include FT_GZIP_H
		#include FT_ADVANCES_H
	]],
		gcc_flags = "-I./include",
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^FT_")
				end,
				function(name)
					return name:find("^FT_") or name:find("^BDF_")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local s = [=[
				local ffi = require("ffi")
				local CLIB = assert(ffi.load("freetype"))
				ffi.cdef([[]=] .. header .. [=[]])
			]=]
			s = s .. "local library = " .. meta_data:BuildLuaFunctions("^FT_(.+)", "Foo_Bar", "FooBar")
			s = s .. "library.e = " .. meta_data:BuildLuaEnums("^FT_(.+)")
			s = s .. "local error_code_to_str = {\n"

			for _, enums in pairs(meta_data.global_enums) do
				for _, enum in ipairs(enums.enums) do
					local err = enum.key:match("^FT_Err_(.+)")

					if err then
						err = err:gsub("_", " "):lower()
						s = s .. "\t[" .. enum.val .. "] = \"" .. err .. "\",\n"
					end
				end
			end

			s = s .. "}\n"
			s = s .. "function library.ErrorCodeToString(code) return error_code_to_str[code] end\n"
			s = s .. "library.clib = CLIB\n"
			s = s .. "return library\n"
			return s
		end,
	}
)