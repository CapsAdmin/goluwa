local helpers = require("nattlua.other.helpers")
helpers.JITOptimize()
local util = require("examples.util")
local lua_code = assert(
	util.FetchCode(
		"examples/benchmarks/temp/10mb.lua",
		"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
	)
)
util.LoadGithub("franko/luajit-lang-toolkit/master/lang/reader.lua", "lang.reader")
util.LoadGithub("franko/luajit-lang-toolkit/master/lang/id_generator.lua", "lang.id_generator")
util.LoadGithub("franko/luajit-lang-toolkit/master/lang/lua_ast.lua", "lang.lua_ast")
util.LoadGithub("franko/luajit-lang-toolkit/master/lang/lexer.lua", "lang.lexer")
util.LoadGithub("franko/luajit-lang-toolkit/master/lang/operator.lua", "lang.operator")
util.LoadGithub("franko/luajit-lang-toolkit/master/lang/parser.lua", "lang.parser")
util.LoadGithub(
	"franko/luajit-lang-toolkit/master/lang/luacode_generator.lua",
	"lang.luacode_generator"
)

local function lang_toolkit_error(msg)
	if string.sub(msg, 1, 9) == "LLT-ERROR" then
		return false, "luajit-lang-toolkit: " .. string.sub(msg, 10)
	else
		error(msg)
	end
end

local lex_setup = require("lang.lexer")
local parse = require("lang.parser")
local lua_ast = require("lang.lua_ast")
local reader = require("lang.reader")
local generator = require("lang.luacode_generator")
local sec = util.MeasureFunction(function()
	local ls = lex_setup(reader.string(lua_code), "10mb")
	local ast_builder = lua_ast.New()

	util.Measure("luajit langtools lex and parse", function()
		local parse_success, ast_tree = pcall(parse, ast_builder, ls)

		if not parse_success then return lang_toolkit_error(ast_tree) end

		local success, luacode = pcall(generator, ast_tree, filename)

		if not success then return lang_toolkit_error(luacode) end
	end)
end)
print("lexing and parsing took " .. sec .. " seconds")
