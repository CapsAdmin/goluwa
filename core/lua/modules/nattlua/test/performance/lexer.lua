local helpers = require("nattlua.other.helpers")
local util = require("examples.util")
local nl = require("nattlua")
local Code = require("nattlua.code").New
local code = nl.Compiler(
	assert(
		util.FetchCode(
			"examples/benchmarks/temp/10mb.lua",
			"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
		)
	),
	"10mb.lua"
)

--helpers.EnableJITDumper()
do
	-- should take around 1.2 seconds
	local tokens = util.Measure("code:Lex()", function()
		return assert(code:Lex()).Tokens
	end)
end

do
	local Lexer = require("nattlua.lexer").New
	local lexer = Lexer(
		Code(
			assert(
				util.FetchCode(
					"examples/benchmarks/temp/10mb.lua",
					"https://gist.githubusercontent.com/CapsAdmin/0bc3fce0624a72d83ff0667226511ecd/raw/b84b097b0382da524c4db36e644ee8948dd4fb20/10mb.lua"
				)
			),
			"10mb.lua"
		)
	)
	-- should take around 0.8 seconds
	local tokens = util.Measure("code:Lex()", function()
		while true do
			local type, start, stop, is_whitespace = lexer:ReadSimple()

			if type == "end_of_file" then break end
		end
	end)
end
