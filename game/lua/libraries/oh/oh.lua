local oh = {}

if RELOAD then
	RELOAD = false
end
runfile("parser/parser.lua", oh)
runfile("code_emitter.lua", oh)
runfile("test.lua", oh)

_G.oh = oh

oh.Test()

return oh