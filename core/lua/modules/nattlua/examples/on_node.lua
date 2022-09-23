local nl = require("nattlua")
local nodes = {}
local lua = assert(
	nl.File(
		"build_output.lua",
		{
			on_node = function(parser, node)
				print(node:Render())
			end,
		}
	):Parse()
)
