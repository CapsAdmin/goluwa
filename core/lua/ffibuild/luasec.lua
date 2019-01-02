ffibuild.Build({
	name = "luasec",
	url = "https://github.com/brunoos/luasec.git",
	cmd = "make linux CFLAGS='-I../../luajit/src -fpic -I.' LDFLAGS='-L../../luajit/src -L../../luasocket/src -L./luasocket -l:libluajit.a'",
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