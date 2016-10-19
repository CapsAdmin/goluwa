package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower()

local vector_patch = {[==[diff --git a/src/lib_ffi.c b/src/lib_ffi.c
index 2fb3a32..b6ec45a 100644
--- a/src/lib_ffi.c
+++ b/src/lib_ffi.c
@@ -825,8 +825,6 @@ LJLIB_CF(ffi_load)
   return 1;
 }

-#include <intrin.h>
-
 static MSize getcdvecsz(CTState *cts, CType *ct)
 {
   if(ctype_ispointer(ct->info) && !ctype_isvector(ct->info)){
@@ -844,7 +842,7 @@ static MSize getcdvecsz(CTState *cts, CType *ct)

 LJLIB_CF(ffi_vtest)	LJLIB_REC(.)
 {
-  CTState *cts = ctype_cts(L);
+  /*CTState *cts = ctype_cts(L);
   GCcdata *cd1 = ffi_checkcdata(L, 1);
   GCcdata *cd2 = ffi_checkcdata(L, 2);
   CType *ct1 = ctype_raw(cts, cd1->ctypeid);
@@ -868,13 +866,14 @@ LJLIB_CF(ffi_vtest)	LJLIB_REC(.)
   if (vecsz == 16) {
     result = _mm_testz_si128(_mm_loadu_si128((__m128i*)v1), _mm_loadu_si128((__m128i*)v2));
   } else {
-    result = _mm256_testz_si256(_mm256_castps_si256(_mm256_loadu_ps((float*)v1)),
+    result = _mm256_testz_si256(_mm256_castps_si256(_mm256_loadu_ps((float*)v1)),
                                 _mm256_castps_si256(_mm256_loadu_ps((float*)v2)));
   }

   setboolV(&G(L)->tmptv2, !result);
   setboolV(L->top++, !result);
-  return 1;
+  return 1;*/
+  return 0;
 }

 LJLIB_PUSH(top-4) LJLIB_SET(C)
diff --git a/src/lj_cdata.c b/src/lj_cdata.c
index a5b9d1d..4da8b1b 100644
--- a/src/lj_cdata.c
+++ b/src/lj_cdata.c
@@ -13,7 +13,6 @@
 #include "lj_ctype.h"
 #include "lj_cconv.h"
 #include "lj_cdata.h"
-#include <intrin.h>

 /* -- C data allocation --------------------------------------------------- */

@@ -60,7 +59,7 @@ GCcdata *LJ_VECTORCALL lj_cdata_newv128(lua_State *L, CTypeID id, __m128 v)
 GCcdata *LJ_VECTORCALL lj_cdata_newv256(lua_State *L, CTypeID id, __m256 v)
 {
   GCcdata *cd = lj_cdata_newv(L, id, 32, 5);
-  _mm256_storeu_ps((float*)cdataptr(cd), v);
+  //_mm256_storeu_ps((float*)cdataptr(cd), v);
   return cd;
 }

diff --git a/src/lj_def.h b/src/lj_def.h
index 4c9ab4c..eefc4ff 100644
--- a/src/lj_def.h
+++ b/src/lj_def.h
@@ -320,7 +320,7 @@ static LJ_AINLINE uint32_t lj_getu32(const void *v)
 #define LJ_FASTCALL
 #endif
 #ifndef LJ_VECTORCALL
-#define LJ_VECTORCALL __vectorcall
+#define LJ_VECTORCALL
 #endif
 #ifndef LJ_NORET
 #define LJ_NORET
]==]}

local repos = {
	{
		author = "mike",
		url = "https://github.com/LuaJIT/LuaJIT",
		branch = "v2.1",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
	},
	{
		author = "mike",
		url = "https://github.com/LuaJIT/LuaJIT",
		branch = "v2.1",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"}
	},
	{
		url = "https://github.com/fsfod/LuaJIT",
		branch = "intrinsicpr",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"}
	},
	{
		url = "https://github.com/fsfod/LuaJIT",
		branch = "vectors",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"},
		patches = vector_patch,
	},
	{
		url = "https://github.com/fsfod/LuaJIT",
		branch = "gcarena",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"},
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "newgc",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT", "LUAJIT_ENABLE_GC64"}
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "newgc",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"}
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "newgc",
	},
}

local function execute(str)
	os.execute(str)
	print("=================")
	print(str)
	print("=================")
end

local function build_flags(tbl)
	local flags = ""
	for _, flag in ipairs(tbl) do
		if flag:find("^LUA") then
			flag = "XCFLAGS+=-D" .. flag
		end

		flags = flags .. flag .. " "
	end
	return flags
end

local function build(info, extra_flags, extra_id)
	local id = info.id or (info.author or info.url:match(".+/(.+)/")) .. "-" .. info.branch

	if extra_id then
		id = id .. "_" .. extra_id
	end

	if info.flags then
		for _, flag in ipairs(info.flags) do
			id = id .. "_" .. flag:gsub("LUAJIT_", ""):gsub("LUA", ""):gsub("ENABLE_", "")
		end
	end

	id = id:lower()

	local dir = "repo/" .. id

	local flags = ""

	if info.flags then
		flags = build_flags(info.flags)
	end

	if extra_flags then
		flags = flags .. build_flags(extra_flags)
	end

	local patch_cmd = ""

	if info.patches then
		for i, patch in ipairs(info.patches) do
			os.execute("mkdir -p " .. dir)
			local f = assert(io.open(dir .. "/" .. i .. ".patch", "wb"))
			f:write(patch)
			f:close()
			patch_cmd = patch_cmd .. "git -C ./".. dir .. " apply " .. i .. ".patch; "
		end
	end

	execute(
		"(" ..
			"if [ -d ./" .. dir .. " ]; then git -C ./" .. dir .. " pull; else git clone -b " .. info.branch .. " " .. info.url .. " " .. dir .. " --depth 1; fi" .. "; " ..
			patch_cmd ..
			"make -C " .. dir .. " " .. flags .. "; " ..
			"cp " .. dir .. "/src/luajit \"" .. bin_dir .. "/luajit_" .. id .. "\"" ..
		") &"
	)
end

for _, info in pairs(repos) do
	build(info)
	build(info, {"LUAJIT_USE_GDBJIT", "CCDEBUG=-g", "CCOPT=-fomit-frame-pointer"}, "debug")
	build(info, {"LUAJIT_USE_GDBJIT", "LUA_USE_ASSERT", "CCDEBUG=-g", "CCOPT=-fomit-frame-pointer"}, "debug-assert")
end
