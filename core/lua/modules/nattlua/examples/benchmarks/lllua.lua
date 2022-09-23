local util = require("examples.util")
local helpers = require("nattlua.other.helpers")
helpers.JITOptimize()
--helpers.EnableJITDumper()
util.LoadGithub("GitSparTV/LLLua/master/src/lexer/tokens.lua", "lexer.tokens")
util.LoadGithub("GitSparTV/LLLua/master/src/lexer/chars.lua", "lexer.chars")
util.LoadGithub("GitSparTV/LLLua/master/src/lexer/init.lua", "lllua-lexer")
local Lexer = require("lllua-lexer")
local lua_code = assert(
	util.FetchCode(
		"examples/benchmarks/temp/10mb.lua",
		"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
	)
)
local lex = Lexer.Setup(lua_code)
local EOF = -1

util.Measure("LexerSetup", function()
	while lex.c ~= EOF do
		Lexer.Next(lex)
	end
end)
