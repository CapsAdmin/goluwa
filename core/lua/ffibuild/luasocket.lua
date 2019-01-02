ffibuild.Build({
	name = "luasocket",
	url = "https://github.com/CapsAdmin/luasocket.git",
	cmd = "make PLAT=linux SO_linux=dll LUAV=5.1 MYCFLAGS='-D LUAJIT' LUAINC=../../luajit/src LDFLAGS_linux='-L../../luajit/src -l:libluajit.a -O -shared -fpic -o'",
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