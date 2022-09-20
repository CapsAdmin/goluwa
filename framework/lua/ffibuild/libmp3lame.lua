ffibuild.Build(
	{
		name = "lame",
		url = "https://svn.code.sf.net/p/lame/svn/trunk/lame",
		cmd = "./configure && make --jobs 32",
		addon = vfs.GetAddonFromPath(SCRIPT_PATH),
		c_source = [[#include "lame.h"]],
		gcc_flags = "-I./include",
		process_header = function(header)
			local meta_data = ffibuild.GetMetaData(header)
			return meta_data:BuildMinimalHeader(
				function(name)
					return name:find("^lame_")
				end,
				function(name)
					return name:find("^LAME_")
				end,
				true,
				true
			)
		end,
		build_lua = function(header, meta_data)
			local lua = ffibuild.StartLibrary(header)
			lua = lua .. "library = " .. meta_data:BuildFunctions("^lame_(.+)", "foo_bar", "FooBar")
			lua = lua .. "library.e = " .. meta_data:BuildEnums("^LAME_(.+)")
			return ffibuild.EndLibrary(lua)
		end,
	}
)