package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower()

local corsix_patches = {
[[diff --git a/src/lj_record.c b/src/lj_record.c
index 76699a9..b2bc721 100644
--- a/src/lj_record.c
+++ b/src/lj_record.c
@@ -1765,6 +1765,10 @@ static void rec_varg(jit_State *J, BCReg dst, ptrdiff_t nresults)
   int32_t numparams = J->pt->numparams;
   ptrdiff_t nvararg = frame_delta(J->L->base-1) - numparams - 1 - LJ_FR2;
   lua_assert(frame_isvarg(J->L->base-1));
+#if LJ_FR2
+  if (dst > J->maxslot)
+    J->base[dst-1] = 0;
+#endif
   if (J->framedepth > 0) {  /* Simple case: varargs defined on-trace. */
     ptrdiff_t i;
     if (nvararg < 0) nvararg = 0;
]],
[[diff --git a/src/lj_target_x86.h b/src/lj_target_x86.h
index d542959..4757f5a 100644
--- a/src/lj_target_x86.h
+++ b/src/lj_target_x86.h
@@ -31,7 +31,7 @@ enum {
   FPRDEF(RIDENUM)              /* Floating-point registers (FPRs). */
   RID_MAX,
   RID_MRM = RID_MAX,           /* Pseudo-id for ModRM operand. */
-  RID_RIP = RID_MAX+1,         /* Pseudo-id for RIP (x64 only). */
+  RID_RIP = RID_MAX+5,         /* Pseudo-id for RIP (x64 only). */

   /* Calling conventions. */
   RID_SP = RID_ESP,
]]
}

local repos = {
	{
		author = "mike",
		url = "https://github.com/LuaJIT/LuaJIT",
		branch = "master",
	},
	{
		author = "mike",
		url = "https://github.com/LuaJIT/LuaJIT",
		branch = "v2.1",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"}
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "x64",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
		patches = corsix_patches,
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "newgc",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
		patches = corsix_patches,
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "newgc",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"}
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
			os.execute("mkdir -r " .. dir)
			local f = io.open(dir .. "/" .. i .. ".patch", "wb")
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
	build(info, {"LUAJIT_USE_GDBJIT", "CCDEBUG=-g"}, "debug")
	build(info, {"LUAJIT_USE_GDBJIT", "LUA_USE_ASSERT", "CCDEBUG=-g"}, "debug-assert")
end
