ffibuild.Build({
	name = "luasec",
	url = "https://github.com/brunoos/luasec.git",
	cmd = "make linux LUAPATH=/mingw64/include/lua5.1/ LIB_PATH='-L /mingw64/bin/' l:lua51.dll",
    force_rebuild = true,
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),
    translate_path = function(path)
        local name = vfs.RemoveExtensionFromPath(vfs.GetFileNameFromPath(path))
        if name == "unix" then
            return "lua/socket/core"
        elseif name == "serial" then
            return "lua/socket/serial"
        elseif name == "mime" then
            return "lua/mime/core"
        end
    end
})