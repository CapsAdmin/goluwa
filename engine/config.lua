local env_vars = {
	CURSES = true,
	SRGB = true,
	NULL_OPENGL = false,
	DISABLE_CULLING = false,
	CLI = false,
	TMUX = false,
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

if CLI then
	CURSES = false
	VERBOSE_STARTUP = false
end

if TMUX then
	_G.USERNAME = "tmux"
end

return {
	dependencies = "framework",
}