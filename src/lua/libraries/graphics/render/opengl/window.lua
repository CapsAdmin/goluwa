local render = ... or _G.render

local sdl = require("SDL2")

function render.PreWindowSetup(flags)
	table.insert(flags, "opengl")

	sdl.GL_SetAttribute(sdl.e.GL_DEPTH_SIZE, 0)

	-- workaround for srgb on intel mesa driver
	sdl.GL_SetAttribute(sdl.e.GL_ALPHA_SIZE, 1)
end

function render.PostWindowSetup(sdl_wnd)
	if not system.gl_context then
		sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MAJOR_VERSION, 3)
		sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MINOR_VERSION, 3)
		sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_PROFILE_MASK, sdl.e.GL_CONTEXT_PROFILE_CORE)

		if DEBUG_OPENGL then
			sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_FLAGS, sdl.e.GL_CONTEXT_DEBUG_FLAG)
		end
		--sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_PROFILE_MASK, sdl.e.GL_CONTEXT_PROFILE_COMPATIBILITY)

		local context = sdl.GL_CreateContext(sdl_wnd)

		if context == nil then
			error("sdl.GL_CreateContext failed: " .. ffi.string(sdl.GetError()), 2)
		end

		sdl.GL_MakeCurrent(sdl_wnd, context)

		local gl = require("opengl")

		-- this needs to be initialized once after a context has been created
		gl.GetProcAddress = sdl.GL_GetProcAddress

		gl.Initialize()

		if NULL_OPENGL then
			for k,v in pairs(gl) do
				if type(v) == "cdata" then
					gl[k] = function() return 0 end
				end
			end

			function gl.CheckNamedFramebufferStatus()
				return 36053
			end

			function gl.GetString()
				return nil
			end
		end

		system.gl_context = context
	end
end

function render._SetWindow(wnd)
	sdl.GL_MakeCurrent(wnd.sdl_wnd, system.gl_context)
end

function render.SwapBuffers(wnd)
	sdl.GL_SwapWindow(wnd.sdl_wnd)
end

function render.SwapInterval(b)
	sdl.GL_SetSwapInterval(b and 1 or 0)
end

do

	local cache = {}

	for k,v in pairs(_G) do
		if type(k) == "string" and type(v) == "boolean" and k:sub(1, 3)  == "GL_" then
			cache[k] = v
			if sdl.GL_ExtensionSupported(k) == 1 then
				logf("[graphics][opengl] extension %s was forced to %s\n", k, v)
			end
		end
	end

	function render.IsExtensionSupported(str)
		if cache[str] == nil then
			cache[str] = sdl.GL_ExtensionSupported(str) == 1
			if not cache[str] then
				local new
				if str:find("_ARB_", nil, true) then
					new = str:gsub("_ARB_", "_EXT_")
				elseif str:find("_EXT_", nil, true) then
					new = str:gsub("_EXT_", "_ARB_")
				end

				if new then
					local try = sdl.GL_ExtensionSupported(new) == 1
					cache[str] = try
					if try then
						logf("[graphics][opengl] requested extension %s which doesn't exist. using %s instead\n", str, new)
					end
				end
			end
			if not cache[str] then
				logf("[graphics][opengl] extension %s does not exist\n", str)
			end
		end
		return cache[str]
	end
end