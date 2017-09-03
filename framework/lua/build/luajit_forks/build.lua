local args = ...

package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower()

local repos = {
	{
		author = "mike",
		url = "https://github.com/LuaJIT/LuaJIT",
		branch = "v2.1",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"},
	},
	{
		url = "https://github.com/fsfod/LuaJIT",
		branch = "intrinsicpr",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"}
	},
	{
		url = "https://github.com/fsfod/LuaJIT",
		branch = "gcarena",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"},
	},
	{
		url = "https://github.com/fsfod/LuaJIT",
		branch = "stringbuffer",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"},
	},
	{
		author = "lukego",
		url = "https://github.com/raptorjit/raptorjit",
		branch = "master",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"},
		bin = "raptorjit",
		commit = "d3e36e7920c641410dfcdf1fc6c10069fd3192a6",
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

	local name = info.bin or "luajit"
	local commit = info.commit or "HEAD"

	execute(
		"(" ..
			"if [ -d ./" .. dir .. " ]; then git -C ./" .. dir .. " pull; git -C ./" .. dir .. " checkout " .. commit .. "; else git clone -b " .. info.branch .. " " .. info.url .. " " .. dir .. " --depth 1; fi" .. "; " ..
			patch_cmd ..
			"make -C " .. dir .. " " .. flags .. "; " ..
			"cp " .. dir .. "/src/"..name.." \"" .. bin_dir .. "/luajit_" .. id .. "\"" ..
		") &"
	)
end

local url_filter = args

for _, info in pairs(repos) do
	if not url_filter or info.url:lower():find(url_filter) then
		build(info)
		build(info, {"LUA_USE_APICHECK", "LUAJIT_USE_GDBJIT", "CCDEBUG=-g", "CCOPT=-fomit-frame-pointer"}, "debug")
		build(info, {"LUA_USE_APICHECK", "LUAJIT_USE_GDBJIT", "LUA_USE_ASSERT", "CCDEBUG=-g", "CCOPT=-fomit-frame-pointer"}, "debug-assert")
	end
end
