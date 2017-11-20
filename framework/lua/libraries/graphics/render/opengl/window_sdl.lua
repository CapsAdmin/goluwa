local render = ... or _G.render

local sdl = require("SDL2")
local ffi = require("ffi")

function render.PreWindowSetup(flags)
	table.insert(flags, "opengl")

	sdl.GL_SetAttribute(sdl.e.GL_DEPTH_SIZE, 16)
	sdl.GL_SetAttribute(sdl.e.GL_STENCIL_SIZE, 8)

	-- workaround for srgb on intel mesa driver
	sdl.GL_SetAttribute(sdl.e.GL_ALPHA_SIZE, 1)
end

local attempts = {
	{
		version = 4.6,
		profile_mask = "core",
	},
	{
		version = 4.5,
		profile_mask = "core",
	},
	{
		version = 4.0,
		profile_mask = "core",
	},
	{
		version = 3.3,
		profile_mask = "core",
	},
	{
		version = 3.2,
		profile_mask = "core",
	},
	{
		profile_mask = "core",
	},
}

function render.PostWindowSetup(sdl_wnd)
	if not system.gl_context then

		local context
		local errors = ""

		for _, attempt in ipairs(attempts) do
			sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_PROFILE_MASK, sdl.e["GL_CONTEXT_PROFILE_" .. attempt.profile_mask:upper()])

			if DEBUG_OPENGL then
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_FLAGS, sdl.e.GL_CONTEXT_DEBUG_FLAG)
			end

			if attempt.version then
				local major, minor = math.modf(attempt.version)
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MAJOR_VERSION, major)
				sdl.GL_SetAttribute(sdl.e.GL_CONTEXT_MINOR_VERSION, minor * 10)
			end

			context = sdl.GL_CreateContext(sdl_wnd)

			if context ~= nil then
				llog("successfully created OpenGL context ", attempt.version or "??", " ", attempt.profile_mask)
				break
			else
				local err = ffi.string(sdl.GetError())
				llog("could not requested OpenGL ", attempt.version or "??", " ", attempt.profile_mask, ": ", err)
				errors = errors .. err .. "\n"
			end
		end

		if context == nil then
			error("sdl.GL_CreateContext failed: " .. errors, 2)
		end

		local gl = require("opengl")
		gl.GetProcAddress = sdl.GL_GetProcAddress
		gl.Initialize()

		sdl.GL_MakeCurrent(sdl_wnd, context)

		if not render.IsExtensionSupported("GL_ARB_direct_state_access") and not render.IsExtensionSupported("GL_EXT_direct_state_access") then
			_G.GL_ARB_direct_state_access = false
		end

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

do
	local last

	function render.SwapInterval(b)
		if last ~= b then
			sdl.GL_SetSwapInterval(b and 1 or 0)
			last = b
		end
	end
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