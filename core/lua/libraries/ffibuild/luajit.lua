local repos = {
	--[[{
		author = "fsfod",
		url = "https://github.com/fsfod/LuaJIT",
		branch = "intrinsicpr",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
	},
	{
		author = "mike",
		url = "https://github.com/LuaJIT/LuaJIT",
		branch = "v2.1",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
	},]]
	{
		author = "lukego",
		url = "https://github.com/raptorjit/raptorjit",
		branch = "master",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
		bin = "raptorjit",
		pre_make = "reusevm"
	},
	{
		author = "softdevteam",
		url = "https://github.com/softdevteam/LuaJIT",
		branch = "master",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
		bin = "luajit",
	},
}

local parallel = ""

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

	local dir = e.CACHE_FOLDER .. "luajit_forks/" .. id

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
			patch_cmd = patch_cmd .. "git -C ./".. dir .. " apply " .. i .. ".patch;\n"
		end
	end

	local name = info.bin or "luajit"
	local commit = info.commit or "HEAD"

	local pre_make = ""
	if info.pre_make then
		pre_make = "make -C " .. dir .. " " .. info.pre_make .. ";\n"
	end


	local fetch = "if [ -d ./" .. dir .. " ]; then git -C ./" .. dir .. " pull; git -C ./" .. dir .. " checkout " .. commit .. "; else git clone -b " .. info.branch .. " " .. info.url .. " " .. dir .. " --depth 1; fi" .. "; "
	local build = patch_cmd .. pre_make .. "make -C " .. dir .. " " .. flags .. ";\n"

	if vfs.IsFile(e.BIN_FOLDER .. "luajit_" .. id) then
		build = ""
		fetch = ""
	end

	parallel = parallel ..
	"(\n" ..
		fetch ..
		build ..
		"cp " .. dir .. "/src/"..name.." "..e.BIN_FOLDER.."luajit_" .. id .. ";\n" ..
		"cp " .. dir .. "/src/lj.supp lj.supp;\n" ..
	"\n) &\n"
end

local url_filter = args

for _, info in pairs(repos) do
    if not url_filter or info.url:lower():find(url_filter) then
        build(info)
        build(info, {
            "LUA_USE_APICHECK",
            "LUAJIT_USE_GDBJIT",
            "CCDEBUG=-g",
        }, "debug")

        build(info, {
            "LUA_USE_APICHECK",
            "LUAJIT_USE_GDBJIT",
            "LUAJIT_USE_SYSMALLOC",
            "LUAJIT_USE_VALGRIND",
            "CCDEBUG=-g",
        }, "debug_memory")

        build(info, {
            "LUA_USE_APICHECK",
            "LUAJIT_USE_GDBJIT",
            "LUAJIT_USE_SYSMALLOC",
            "LUAJIT_USE_VALGRIND",
            "LUA_USE_ASSERT",
            "CCDEBUG=-g",
        }, "debug_memory_assert")
    end
end

os.execute(parallel .. " wait")
