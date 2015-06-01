local gmod = ... or gmod
local debug = gmod.env.debug

function debug.getregistry()
	return gmod.env._R
end