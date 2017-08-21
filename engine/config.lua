local env_vars = {
	SERVER = false,
	CLIENT = true,
	GRAPHICS = true,
	SOUND = true,
	DEBUG = false,
	CURSES = true,
	SOCKETS = true,
	SRGB = true,
	LOOP = true,
	WINDOW = true,
	NULL_OPENGL = false,
	PHYSICS = false,
	DISABLE_CULLING = false,
	DEBUG_OPENGL = false,
	BUILD_SHADER_OUTPUT = false,
	CLI = false,
	TMUX = false,
	VERBOSE_STARTUP = true,

	OPENGL = true,
	VULKAN = false,
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

if os.getenv("CODEXL") == "1" or os.getenv("MESA_DEBUG") == "1" then
	EXTERNAL_DEBUGGER = true
end

if LINUX then
	WINDOWS = false
end

if WINDOWS then
	LINUX = false
end

for k in pairs(env_vars) do
	if _G[k] == nil then
		_G[k] = false
	end
end

if EXTERNAL_DEBUGGER == nil then
	EXTERNAL_DEBUGGER = false
end

RELOAD = false
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
	LOOP = false
	CURSES = false
	VERBOSE_STARTUP = false
end

if TMUX then
	_G.USERNAME = "tmux"
end

if LINUX and (GRAPHICS or WINDOW) and not os.getenv("DISPLAY") then
	GRAPHICS = false
	WINDOW = false
	io.write("os.getenv('DISPLAY') is nil.\nsetting GRAPHICS and WINDOW to false.\n")
end
