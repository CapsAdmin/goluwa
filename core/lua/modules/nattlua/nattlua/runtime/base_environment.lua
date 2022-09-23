local Table = require("nattlua.types.table").Table
local Nil = require("nattlua.types.symbol").Nil
local LStringNoMeta = require("nattlua.types.string").LStringNoMeta

if not _G.IMPORTS then
	_G.IMPORTS = setmetatable(
		{},
		{
			__index = function(self, key)
				return function()
					return _G["req" .. "uire"](key)
				end
			end,
		}
	)
end

local function import_data(path)
	local f, err = io.open(path, "rb")

	if not f then return nil, err end

	local code = f:read("*all")
	f:close()

	if not code then return nil, path .. " empty file" end

	return code
end

local function load_definitions()
	local path = "nattlua/definitions/index.nlua"
	local config = {}
	config.file_path = config.file_path or path
	config.file_name = config.file_name or path
	config.comment_type_annotations = false
	-- import_data will be transformed on build and the local function will not be used
	-- we canot use the upvalue path here either since this happens at parse time
	local code = assert(import_data("nattlua/definitions/index.nlua"))
	local Compiler = require("nattlua.compiler").New
	return Compiler(code, "@" .. path, config)
end

return {
	BuildBaseEnvironment = function()
		local compiler = load_definitions()
		assert(compiler:Lex())
		assert(compiler:Parse())
		local runtime_env = Table()
		local typesystem_env = Table()
		typesystem_env.string_metatable = Table()
		compiler:SetEnvironments(runtime_env, typesystem_env)
		local base = compiler.Analyzer()
		assert(compiler:Analyze(base))
		typesystem_env.string_metatable:Set(
			LStringNoMeta("__index"),
			base:Assert(typesystem_env:Get(LStringNoMeta("string")))
		)
		return runtime_env, typesystem_env
	end,
}
