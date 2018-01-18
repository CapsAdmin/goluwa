local env_vars = {
	SERVER = false,
	CLIENT = true,
	GRAPHICS = true,
	SOUND = true,
	DEBUG = false,
	SOCKETS = true,
	WINDOW = true,

	SRGB = true,
	NULL_OPENGL = false,
	BUILD_SHADER_OUTPUT = false,
	DEBUG_OPENGL = false,

	PHYSICS = false,

	OPENGL = true,
	VULKAN = false,
}

if jit.tracebarrier then
	SOCKETS = false
end

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

if CLI then
	GRAPHICS = false
	WINDOW = false
	SOUND = false
	CLIENT = false
	NETWORK = false
end

RELOAD = false
CREATED_ENV = false

if LINUX and (GRAPHICS or WINDOW) and not os.getenv("DISPLAY") then
	GRAPHICS = false
	WINDOW = false
	io.write("os.getenv('DISPLAY') is nil.\nsetting GRAPHICS and WINDOW to false.\n")
end

return {
	dependencies = "core",
}