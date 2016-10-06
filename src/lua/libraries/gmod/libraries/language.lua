local gmod = ... or gmod
local language = gmod.env.language

function language.GetPhrase(key)
	return gmod.translation[key] or key
end

function language.Add(key, val)
	gmod.translation[key] = val:trim()
	gmod.translation2["#" .. key] = gmod.translation[key]
end