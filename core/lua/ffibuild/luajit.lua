local bin_dir = e.ROOT_FOLDER .. vfs.GetAddonFromPath(SCRIPT_PATH) .. "/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower()

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
	{
		author = "lukego",
		url = "https://github.com/raptorjit/raptorjit",
		branch = "master",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"},
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

	local dir = R"temp/" .. "ffibuild/luajit/" .. id

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
