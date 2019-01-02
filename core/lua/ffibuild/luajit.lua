ffibuild.Build({
	name = "luajit",
	url = "https://github.com/LuaJIT/LuaJIT/tree/v2.1.git",
	cmd = "make HOST_SYS=Windows HOST_MSYS=mingw TARGET_SYS=Windows BUILDMODE=static amalg XCFLAGS+=-DLUAJIT_ENABLE_GC64 XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT ",
	addon = vfs.GetAddonFromPath(SCRIPT_PATH),

})