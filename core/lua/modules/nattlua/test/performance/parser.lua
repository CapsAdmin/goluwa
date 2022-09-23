local helpers = require("nattlua.other.helpers")
local nl = require("nattlua")
local util = require("examples.util")
local code = nl.Compiler(
	assert(
		util.FetchCode(
			"examples/benchmarks/temp/10mb.lua",
			"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
		)
	),
	"10mb.lua",
	{
		skip_import = true,
	}
)
local tokens = util.Measure("code:Lex()", function()
	return assert(code:Lex()).Tokens
end)
--require("nattlua.other.debug").EnableJITDumper()
local ast = util.Measure("code:Parse()", function()
	return assert(code:Parse()).SyntaxTree
end) -- should take around 1.2 seconds
