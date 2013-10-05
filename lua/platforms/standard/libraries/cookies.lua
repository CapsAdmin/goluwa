-- whats the point

local cookies = {}

function cookies.Set(key, value)
	if not cookies.current then	
		cookies.Reload() 
	end
	
	luadata.SetKeyValueInFile("cookies.txt", key, value)

	cookies.current[key] = value
end

function cookies.Get(key, def)
	if not cookies.current then	
		cookies.Reload() 
	end

	return cookies.current[key] or def
end

function cookies.Reload()
	cookies.current = luadata.ReadFile("cookies.txt")
end

return cookies