ffibuild.Build({
	name = "libressl",
	url = "https://github.com/libressl-portable/portable.git",
	cmd = "./autogen.sh && ./configure && make",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),

	c_source = [[
        #include <tls.h>
    ]],

    gcc_flags = "-I./include",

    filter_library = function(path)
        if path:endswith("libtls") or path:endswith("libssl") or path:endswith("libcrypto") then
            return true
        end
    end,

    process_header = function(header)
		local meta_data = ffibuild.GetMetaData(header)
        meta_data.functions[""] = nil
        return meta_data:BuildMinimalHeader(function(s) return s:find("^tls_") end, function(s) return s:find("^TLS_") end, true, true)
	end,

    build_lua = function(header, meta_data)
        ffibuild.SetBuildName("tls")
        local lua = ffibuild.StartLibrary(header, "safe_clib_index")
        ffibuild.SetBuildName("libressl")
        lua = lua .. "CLIB = SAFE_INDEX(CLIB)"
        lua = lua .. "library = " .. meta_data:BuildFunctions(prefixes)
        lua = lua .. "library.e = " .. meta_data:BuildEnums(prefixes, {"./include/tls.h"})
        return ffibuild.EndLibrary(lua)
	end,
})