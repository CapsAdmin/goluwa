-- whats the point

local cookies = _G.cookies or {}

function cookies.Set(key, value)
	if not cookies.current then
		cookies.Reload()
	end

	serializer.SetKeyValueInFile("luadata", "cookies.txt", key, value)

	cookies.current[key] = value
end

function cookies.Get(key, def)
	if not cookies.current then
		cookies.Reload()
	end

	return cookies.current[key] or def
end

function cookies.Reload()
	cookies.current = serializer.ReadFile("luadata", "cookies.txt") or {}
end

return cookies