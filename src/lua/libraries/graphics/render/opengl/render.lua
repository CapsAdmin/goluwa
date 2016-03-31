local ffi = require("ffi")
local gl = desire("libopengl") -- OpenGL

if not gl then return end

local render = ... or {}

include("debug.lua", render)
include("framebuffer.lua", render)
include("vertex_buffer.lua", render)

function render._Initialize()
	if not gl then
		llog("cannot initialize : ", err)
	return end

	if not system.gl_context then error("a window must exist before the renderer can be initialized", 2) end

	llog("opengl version: %s", render.GetVersion())
	llog("glsl version: %s", render.GetShadingLanguageVersion())
	llog("vendor: %s", render.GetVendor())

	if render.GetVersion():find("OpenGL ES") then
		OPENGL_ES = true
	end

	do
		local vendor = render.GetVendor():lower()
		if vendor:find("nvidia") then NVIDIA = true end
		if vendor:find("ati") then ATI = true end
		if vendor:find("amd") then AMD = true end
		if vendor:find("mesa") or vendor:find("open source technology center") or render.GetVersion():lower():find("mesa") then MESA = true end
		if vendor:find("intel") then INTEL = true end
	end

	if SRGB then
		gl.Enable("GL_FRAMEBUFFER_SRGB")
	end

	gl.Enable("GL_TEXTURE_CUBE_MAP_SEAMLESS")
	gl.Enable("GL_MULTISAMPLE")
end

function render.Shutdown()

end

do -- shaders
	local status = ffi.new("GLint[1]")
	local shader_strings = ffi.new("const char * [1]")
	local log = ffi.new("char[1024]")

	function render.CreateGLSLShader(type, source)
		local shader = gl.CreateShader2("GL_" .. type:upper() .. "_SHADER")

		shader_strings[0] = ffi.cast("const char *", source)
		shader:Source(1, shader_strings, nil)
		shader:Compile()
		shader:Getiv("GL_COMPILE_STATUS", status)

		if status[0] == 0 then

			shader:GetInfoLog(1024, nil, log)
			shader:Delete()

			error(ffi.string(log), 2)
		end

		return shader
	end

	function render.CreateGLSLProgram(cb, ...)
		local shaders = {...}
		local program = gl.CreateProgram2()

		for _, shader in pairs(shaders) do
			program:AttachShader(shader.id)
		end

		cb(program)

		program:Link()

		program:Getiv("GL_LINK_STATUS", status)

		if status[0] == 0 then

			program:GetInfoLog(1024, nil, log)
			program:Delete()

			error(ffi.string(log), 2)
		end

		for _, shader in pairs(shaders) do
			program:DetachShader(shader.id)
			shader:Delete()
		end

		return program
	end
end

function render.Shutdown()

end

function render.GetVersion()
	return ffi.string(gl.GetString("GL_VERSION"))
end

function render.GetShadingLanguageVersion()
	return ffi.string(gl.GetString("GL_SHADING_LANGUAGE_VERSION"))
end

function render.GetVendor()
	return ffi.string(gl.GetString("GL_VENDOR"))
end

function render._SetScissor(x,y,w,h, sw,sh)
	gl.Scissor(x, sh - (y + h), w, h)
end

function render._SetViewport(x,y,w,h)
	gl.Viewport(x, y, w, h)
	gl.Scissor(x, y, w, h)
end

do
	local enums = {
		zero = gl.e.GL_ZERO,
		one = gl.e.GL_ONE,
		src_color = gl.e.GL_SRC_COLOR,
		one_minus_src_color = gl.e.GL_ONE_MINUS_SRC_COLOR,
		dst_color = gl.e.GL_DST_COLOR,
		one_minus_dst_color = gl.e.GL_ONE_MINUS_DST_COLOR,
		src_alpha = gl.e.GL_SRC_ALPHA,
		one_minus_src_alpha = gl.e.GL_ONE_MINUS_SRC_ALPHA,
		dst_alpha = gl.e.GL_DST_ALPHA,
		one_minus_dst_alpha = gl.e.GL_ONE_MINUS_DST_ALPHA,
		constant_color = gl.e.GL_CONSTANT_COLOR,
		one_minus_constant_color = gl.e.GL_ONE_MINUS_CONSTANT_COLOR,
		constant_alpha = gl.e.GL_CONSTANT_ALPHA,
		one_minus_constant_alpha = gl.e.GL_ONE_MINUS_CONSTANT_ALPHA,
		src_alpha_saturate = gl.e.GL_SRC_ALPHA_SATURATE,

		add = gl.e.GL_FUNC_ADD,
		sub = gl.e.GL_FUNC_SUBTRACT,
		reverse_sub = gl.e.GL_FUNC_REVERSE_SUBTRACT,
		min = gl.e.GL_MIN,
		max = gl.e.GL_MAX,
	}

	local enabled

	function render.SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)

		if src_color then
			if not enabled then
				gl.Enable("GL_BLEND")
				enabled = true
			end
		else
			if enabled then
				gl.Disable("GL_BLEND")
				enabled = false
			end
			return
		end

		if src_color == "alpha" then
			gl.BlendFuncSeparate(
				"GL_SRC_ALPHA", "GL_ONE_MINUS_SRC_ALPHA",
				"GL_ONE", "GL_ONE_MINUS_SRC_ALPHA"
			)
		elseif src_color == "multiplicative" then
			gl.BlendFunc("GL_DST_COLOR", "GL_ZERO")
		elseif src_color == "premultiplied" then
			gl.BlendFunc("GL_ONE", "GL_ONE_MINUS_SRC_ALPHA")
		elseif src_color == "additive" then
			gl.BlendFunc("GL_SRC_ALPHA", "GL_ONE")
		else
			src_color = enums[src_color or "src_alpha"]
			dst_color = enums[dst_color or "one_minus_src_alpha"]
			func_color = enums[func_color or "add"]

			src_alpha = enums[src_alpha] or src_color
			dst_alpha = enums[dst_alpha] or dst_color
			func_alpha = enums[func_alpha] or func_color

			gl.BlendFuncSeparate(src_color, dst_color, src_alpha, dst_alpha)
			gl.BlendEquationSeparate(func_color, func_alpha)
		end
	end
end

function render._SetCullMode(mode)
	if mode == "none" then
		gl.Disable("GL_CULL_FACE")
	else
		gl.Enable("GL_CULL_FACE")

		if mode == "front" then
			gl.CullFace("GL_FRONT")
		elseif mode == "back" then
			gl.CullFace("GL_BACK")
		elseif mode == "front_and_back" then
			gl.CullFace("GL_FRONT_AND_BACK")
		end
	end
end

function render._SetDepth(b)
	if b then
		gl.Enable("GL_DEPTH_TEST")
		gl.DepthMask(1)
		gl.DepthFunc("GL_LESS")
	else
		gl.Disable("GL_DEPTH_TEST")
		gl.DepthMask(0)
		--gl.DepthFunc("GL_ALWAYS")
	end
end