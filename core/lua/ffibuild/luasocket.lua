ffibuild.Build({
	name = "luasocket",
	url = "https://github.com/diegonhab/luasocket.git",
	cmd = "make PLAT=mingw MYCFLAGS='-I /mingw64/include/lua5.1 -L /mingw64/bin/' LUALIB_mingw='/mingw64/bin/lua51.dll'",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),
    translate_path = function(path)
        local name = vfs.RemoveExtensionFromPath(vfs.GetFileNameFromPath(path))
        if name:startswith("unix") or name:startswith("socket") then
            return "lua/socket/core"
        elseif name == "serial" then
            return "lua/socket/serial"
        elseif name:startswith("mime") then
            return "lua/mime/core"
        end
    end,
    patches = {[[
diff --git a/src/makefile b/src/makefile
index 1ed3f4f..3a590d2 100644
--- a/src/makefile
+++ b/src/makefile
@@ -213,7 +213,7 @@ SOCKET_solaris=usocket.o
 SO_mingw=dll
 O_mingw=o
 CC_mingw=gcc
-DEF_mingw= -DLUASOCKET_INET_PTON -DLUASOCKET_$(DEBUG) \
+DEF_mingw= -DLUASOCKET_$(DEBUG) \
        -DWINVER=0x0501 -DLUASOCKET_API='__declspec(dllexport)' \
        -DMIME_API='__declspec(dllexport)'
 CFLAGS_mingw= -I$(LUAINC) $(DEF) -Wall -O2 -fno-common \
]]},
})