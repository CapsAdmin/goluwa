-- Some things here are hardcoded for now.
-- When I'm happy with how things are I'll move general code to NattLua and make this more of a config
-- so you could just run something like nlc in the directory
local nl = require("nattlua")

local function GetFilesRecursively(dir, ext)
	ext = ext or ".lua"
	local f = assert(io.popen("find " .. dir))
	local lines = f:read("*all")
	local paths = {}

	for line in lines:gmatch("(.-)\n") do
		if line:sub(-4) == ext then table.insert(paths, line) end
	end

	return paths
end

local function read_file(path)
	local f = assert(io.open(path, "r"))
	local contents = f:read("*all")
	f:close()
	return contents
end

local function write_file(path, contents)
	local f = assert(io.open(path, "w"))
	f:write(contents)
	f:close()
end

local function file_exists(path)
	local f = io.open(path, "r")

	if f then f:close() end

	return f ~= nil
end

local function LintCodebase()
	local lua_files = GetFilesRecursively("./lua/", ".lua")
	local blacklist = {
		["./lua/entities/gmod_wire_expression2/core/custom/pac.lua"] = true,
	}
	local config = {
		preserve_whitespace = false,
		string_quote = "\"",
		no_semicolon = true,
		force_parenthesis = true,
		extra_indent = {
			StartStorableVars = {
				to = "EndStorableVars",
			},
			Start2D = {to = "End2D"},
			Start3D = {to = "End3D"},
			Start3D2D = {to = "End3D2D"},
			-- in case it's localized
			cam_Start2D = {to = "cam_End2D"},
			cam_Start3D = {to = "cam_End3D"},
			cam_Start3D2D = {to = "cam_End3D2D"},
			cam_Start = {to = "cam_End"},
			SetPropertyGroup = "toggle",
		},
	}

	for _, path in ipairs(lua_files) do
		if not blacklist[path] then
			local lua_code = read_file(path)
			local new_lua_code = assert(nl.Compiler(lua_code, "@" .. path, config)):Emit()

			if new_lua_code:sub(#new_lua_code, #new_lua_code) ~= "\n" then
				new_lua_code = new_lua_code .. "\n"
			end

			--assert(loadstring(new_lua_code, "@" .. path))
			write_file(path, new_lua_code)
		end
	end
end

if false then LintCodebase() end

local helpers = require("nattlua.other.helpers")
--helpers.EnableJITDumper()
local working_directory = "examples/projects/gmod/"
local files = {
	{
		path = "lua/autorun/client/myaddon.lua",
		env = {
			CLIENT = true,
			SERVER = false,
			MENU = false,
		},
	},
	{
		path = "lua/autorun/server/myaddon.lua",
		env = {
			CLIENT = false,
			SERVER = true,
			MENU = false,
		},
	},
	{
		path = "lua/autorun/myaddon.lua",
		env = {
			CLIENT = true,
			SERVER = true,
			MENU = false,
		},
	},
}

for _, info in ipairs(files) do
	local compiler = assert(
		nl.File(working_directory .. info.path, {
			working_directory = working_directory,
		})
	)
	local last_directory = working_directory

	function compiler:OnResolvePath(path)
		if file_exists(last_directory .. path) then
			path = last_directory .. path
		elseif file_exists(working_directory .. "lua/" .. path) then
			path = working_directory .. "lua/" .. path
		else
			path = working_directory .. path
		end

		last_directory = path:match("(.+/)")
		return path
	end

	compiler.Code.Buffer = [[
		]] .. (
			function()
				local s = ""

				for k, v in pairs(info.env) do
					s = s .. "type " .. k .. " = " .. tostring(v) .. "\n"
				end

				return s
			end
		)() .. [[

		import("~/nattlua/glua.nlua")

	]] .. compiler.Code.Buffer
	assert(compiler:Analyze())
end
