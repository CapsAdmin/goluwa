local helpers = require("nattlua.other.helpers")
helpers.JITOptimize()
local util = require("examples.util")
local lua_code = assert(
	util.FetchCode(
		"examples/benchmarks/temp/10mb.lua",
		"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
	)
)
local tl = util.LoadGithub("teal-language/tl/master/tl.lua", "tl")
local sec = util.MeasureFunction(function()
	local tokens
	local ast

	util.Measure("tl.lex()", function()
		tokens = assert(tl.lex(lua_code))
	end)

	util.Measure("tl.parse_program()", function()
		ast = assert(tl.parse_program(tokens))
	end)
end)
print("lexing and parsing took " .. sec .. " seconds")
