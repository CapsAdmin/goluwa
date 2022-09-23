local helpers = require("nattlua.other.helpers")
helpers.JITOptimize()
local nl = require("nattlua")
local util = require("examples.util")
local load = loadstring or load
local lua_code = assert(
	util.FetchCode(
		"examples/benchmarks/temp/10mb.lua",
		"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
	)
)
local sec = util.MeasureFunction(function()
	local compiler = nl.Compiler(lua_code, "10mb.lua")
	local tokens = util.Measure("compiler:Lex()", function()
		return assert(compiler:Lex()).Tokens
	end)
	local ast = util.Measure("compiler:Parse()", function()
		return assert(compiler:Parse()).SyntaxTree
	end)
	io.write("parsed a total of ", #tokens, " tokens\n")
	io.write("main block of tree contains ", #ast.statements, " statements\n")
end)
print("lexing and parsing took " .. sec .. " seconds")
