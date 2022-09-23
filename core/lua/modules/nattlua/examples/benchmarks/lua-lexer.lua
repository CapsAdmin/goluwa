local helpers = require("nattlua.other.helpers")
helpers.JITOptimize()
local util = require("examples.util")
local Code = require("nattlua.code").New
local lua_code = assert(
	util.FetchCode(
		"examples/benchmarks/temp/10mb.lua",
		"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
	)
)
local Lexer = util.LoadGithub("LoganDark/lua-lexer/master/lexer.lua", "lua-lexer")
local sec = util.MeasureFunction(function()
	util.Measure("Lexer(lua_code)", function()
		tokens = Lexer(Code(lua_code, "examples/benchmarks/temp/10mb.lua"))
	end)
end)
print("lexing only took " .. sec .. " seconds")
