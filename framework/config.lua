return {
	dependencies = "core",
	pre_load = function(info)
		local env_vars = {
			SERVER = false,
			CLIENT = true,
			GRAPHICS = true,
			SOUND = true,
			AUDIO_DEVICE = "default",
			DEBUG = false,
			WINDOW = true,
			WINDOW_IMPLEMENTATION = "sdl2",

			SRGB = true,
			NULL_OPENGL = false,
			BUILD_SHADER_OUTPUT = false,

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
				elseif val and val ~= "" then
					_G[key] = val
				elseif default then
					_G[key] = default
				end
			end
		end


		local str = os.getenv("GOLUWA_ARG_LINE") or ""

		if str:find("--cli ", nil, true) then
			CLI = true
			GRAPHICS = false
			SOUND = false
			WINDOW = false
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

		if LINUX then
			if (GRAPHICS or WINDOW) and not os.getenv("DISPLAY") then
				GRAPHICS = false
				WINDOW = false
				io.write("os.getenv('DISPLAY') is nil.\nsetting GRAPHICS and WINDOW to false.\n")
			end

			if SOUND and not vfs.IsDirectory("/proc/asound") and not os.getenv("DISPLAY") and not AUDIO_DEVICE then
				SOUND = false
				io.write("/proc/asound is not a directory and DISPLAY is not set, assuming no sound.\nsetting SOUND to false.\n")
			end
		end

		if CLI then
			info.load_callback()
		else
			vfs.FetchBniariesForAddon(info.name, function()
				info.load_callback()
			end)
		end
	end,
}