local env_vars = {
	CLI = false,
	TMUX = false,
	PHYSICS = false,
}

for key, default in pairs(env_vars) do
	if _G[key] == nil then
		local val = os.getenv("GOLUWA_" .. key)
		if val == "0" then
			_G[key] = false
		elseif val == "1" then
			_G[key] = true
		elseif default then
			_G[key] = default
		end
	end
end

for k in pairs(env_vars) do
	if _G[k] == nil then
		_G[k] = false
	end
end

CREATED_ENV = false

if CLI or TMUX then
	GRAPHICS = false
	WINDOW = false
	CLIENT = false
	SERVER = false
	SOUND = false
	PHYSICS = false
end

return {
	dependencies = "framework",
}