ffibuild.Build({
	name = "libsndfile",
	url = "https://github.com/erikd/libsndfile.git", -- --host=x86_64-w64-mingw32
	cmd = "./autogen.sh && ./configure && make",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),
	c_source = [[
		#include "sndfile.h"
	]],
	gcc_flags = "-I./src",
	process_header = function(header)
        local meta_data = ffibuild.GetMetaData(header)
        return meta_data:BuildMinimalHeader(function(name) return name:find("^sf_") end, function(name) return name:find("^SF") end, true, true)    
	end,

    build_lua = function(header, meta_data)
        do
            local extra = {}

            for name, struct in pairs(meta_data.structs) do
                if name:find("^struct SF_") and not header:find(name) then
                    table.insert(extra, {str = name .. struct:GetDeclaration(meta_data) .. ";\n", pos = struct.i})
                end
            end

            table.sort(extra, function(a, b) return a.pos < b.pos end)

            local str = ""

            for i,v in ipairs(extra) do
                str = str .. v.str
            end

            header = header .. str
        end

        local lua = ffibuild.StartLibrary(header)

        lua = lua .. "library = " .. meta_data:BuildFunctions("^sf_(.+)", "foo_bar", "FooBar")
        lua = lua .. "library.e = " .. meta_data:BuildEnums("^SF[CMD]?_(.+)")

        return ffibuild.EndLibrary(lua)
	end,
})