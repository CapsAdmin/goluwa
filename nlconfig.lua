local nl = require("nattlua")
local cmd = ...
local config = {
	preserve_whitespace = false,
	string_quote = "\"",
	no_semicolon = true,
	comment_type_annotations = true,
	type_annotations = "explicit",
	force_parenthesis = true,
	skip_import = true,
}

local function read_file(path)
	local f = assert(io.open(path, "r"))
	local content = f:read("*all")
	f:close()
	return content
end

local function write_file(path, content)
	local f = assert(io.open(path, "w"))
	f:write(content)
	f:close()
end

local function get_files_recursive(dir, ext)
	local f = assert(io.popen("find " .. dir))
	local lines = f:read("*all")
	local paths = {}

	for line in lines:gmatch("(.-)\n") do
		for _, ext in ipairs(ext) do
			if line:sub(-#ext) == ext then table.insert(paths, line) end
		end
	end

	return paths
end

if cmd == "format" then
	local allowed = {"core", "framework", "engine", "game"}

	for _, directory in ipairs(allowed) do
		for _, path in ipairs(get_files_recursive("./" .. directory, {".lua", ".nlua"})) do
			if not path:find("libraries/nattlua", nil, true) then
				local code = read_file(path)
				local Compiler = require("nattlua.compiler").New
				local compiler = Compiler(code, "@" .. path, config)
				local code = assert(compiler:Emit())
				write_file(path, code)
			end
		end
	end
end