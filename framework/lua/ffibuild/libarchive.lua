ffibuild.Build({
	name = "libarchive",
	url = "https://github.com/libarchive/libarchive.git",
	cmd = "cmake . && make",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),

	c_source = [[
		#include "archive.h"
		#include "archive_entry.h"
	]],
	gcc_flags = "-I./libarchive",
	strip_undefined_symbols = true,
	process_header = function(header)
		local meta_data = ffibuild.GetMetaData(header)

		meta_data.functions.archive_entry_acl_next_w = nil

		return meta_data:BuildMinimalHeader(function(name) return name:find("^archive_") end, function(name) return name:find("^ARCHIVE_") end, true, true)
	end,

	build_lua = function(header, meta_data)
		local lua = ffibuild.StartLibrary(header)
		lua = lua .. "library = " .. meta_data:BuildFunctions("^archive_(.+)", "foo_bar", "FooBar")
		lua = lua .. "library.e = " .. meta_data:BuildEnums("^ARCHIVE_(.+)", "./libarchive/archive.h", "ARCHIVE_")
		return ffibuild.EndLibrary(lua)
	end,
})