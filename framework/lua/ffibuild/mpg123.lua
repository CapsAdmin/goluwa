ffibuild.Build(
	{
		name = "lame",
		url = "svn://scm.orgis.org/mpg123/trunk",
		cmd = "autoreconf -iv && ./configure && make --jobs 32",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		c_source = [[#include "src/libmpg123/mpg123.h"]],
		gcc_flags = "-I./src/libmpg123",
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^mpg123_")
				end,
				function(name)
					return name:find("^MPG123_")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local lua = ffibuild.StartLibrary(header)
			lua = lua .. "library = " .. meta_data:BuildFunctions("^mpg123_(.+)", "foo_bar", "FooBar")
			lua = lua .. "library.e = " .. meta_data:BuildEnums("^MPG123_(.+)")
			return ffibuild.EndLibrary(lua)
		end,
	}
)