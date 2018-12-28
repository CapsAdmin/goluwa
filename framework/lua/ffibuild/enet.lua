ffibuild.Build({
	name = "enet",
	url = "https://github.com/lsalzman/enet.git",
	cmd = "autoreconf -vfi && ./configure && make",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),

	c_source = [[#include "enet/enet.h"]],
	gcc_flags = "-I./include",

	process_header = function(header)
		local meta_data = ffibuild.GetMetaData(header)

		meta_data.functions.enet_socketset_select.arguments[2] = ffibuild.CreateType("type", "void *")
		meta_data.functions.enet_socketset_select.arguments[3] = ffibuild.CreateType("type", "void *")

		return meta_data:BuildMinimalHeader(function(name) return name:find("^enet_") end, function(name) return name:find("^ENET_") end, true, true)
	end,

	build_lua = function(header, meta_data)
		local lua = ffibuild.StartLibrary(header)
		lua = lua .. "library = " .. meta_data:BuildFunctions("^enet_(.+)", "foo_bar", "FooBar")
		lua = lua .. "library.e = " .. meta_data:BuildEnums("^ENET_(.+)")
		return ffibuild.EndLibrary(lua)
	end,
})