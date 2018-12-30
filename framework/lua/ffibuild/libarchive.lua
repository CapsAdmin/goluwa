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

	process_header = function(header)
		local meta_data = ffibuild.GetMetaData(header)

		meta_data.functions.archive_entry_acl_next_w = nil
		meta_data.functions.archive_write_open_FILE.arguments[2] = ffibuild.CreateType("type", "void *")
		meta_data.functions.archive_read_open_FILE.arguments[2] = ffibuild.CreateType("type", "void *")
		meta_data.functions.archive_entry_copy_stat.arguments[2] = ffibuild.CreateType("type", "void *")
		meta_data.functions.archive_read_disk_entry_from_file.arguments[4] = ffibuild.CreateType("type", "const void *")
		meta_data.functions.archive_entry_stat.return_type = ffibuild.CreateType("type", "void *")

		return meta_data:BuildMinimalHeader(function(name) return name:find("^archive_") end, function(name) return name:find("^ARCHIVE_") end, true, true)
	end,

	build_lua = function(header, meta_data)
		local lua = ffibuild.StartLibrary(header)
		lua = lua .. "library = " .. meta_data:BuildFunctions("^archive_(.+)", "foo_bar", "FooBar")
		lua = lua .. "library.e = " .. meta_data:BuildEnums("^ARCHIVE_(.+)", "./libarchive/archive.h", "ARCHIVE_")
		return ffibuild.EndLibrary(lua)
	end,
})