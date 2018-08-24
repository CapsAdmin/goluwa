local oh = {}

runfile("parser/parser.lua", oh)
runfile("code_emitter.lua", oh)
runfile("test.lua", oh)

_G.oh = oh

return oh