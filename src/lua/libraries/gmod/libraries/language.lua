local gmod = ... or gmod
local language = gmod.env.language

function language.GetPhrase(key)
	return gmod.translation[key] or key
end