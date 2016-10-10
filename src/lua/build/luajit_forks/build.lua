package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local bin_dir = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower()

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
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"}
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "newgc",
		flags = {"LUAJIT_ENABLE_GC64", "LUAJIT_ENABLE_LUA52COMPAT"}
	},
	{
		url = "https://github.com/corsix/LuaJIT",
		branch = "newgc",
		flags = {"LUAJIT_ENABLE_LUA52COMPAT"}
	},
}

local function execute(str)
	print("os.execute: " .. str)
	os.execute(str)
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

	execute(
		"(" ..
			"if [ -d ./" .. dir .. " ]; then git -C ./" .. dir .. " pull; else git clone -b " .. info.branch .. " " .. info.url .. " " .. dir .. " --depth 1; fi" .. "; " ..
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
