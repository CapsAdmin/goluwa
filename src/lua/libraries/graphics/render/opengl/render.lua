local ffi = require("ffi")
local gl = desire("opengl")

if not gl then return end

local render = ... or {}

include("debug.lua", render)
include("shader_program.lua", render)
include("shader_buffer.lua", render)
include("lock.lua", render)

function render._Initialize()
	if not gl then
		llog("cannot initialize")
		return
	end

	if not system.gl_context then
		error("a window must exist before the renderer can be initialized", 2)
	end

	llog("opengl version: %s", render.GetVersion())
	llog("glsl version: %s", render.GetShadingLanguageVersion())
	llog("vendor: %s", render.GetVendor())

	if render.GetVersion():find("OpenGL ES") then
		OPENGL_ES = true
	end

	local vendor = render.GetVendor():lower()
	if vendor:find("nvidia") then NVIDIA = true end
	if vendor:find("ati") then ATI = true end
	if vendor:find("amd") then AMD = true end
	if vendor:find("mesa") or vendor:find("open source technology center") or render.GetVersion():lower():find("mesa") then MESA = true end
	if vendor:find("intel") then INTEL = true end

	if DEBUG_OPENGL then
		render.EnableVerboseDebug(true)
	end

	if SRGB then
		gl.Enable("GL_FRAMEBUFFER_SRGB")
	end

	gl.Enable("GL_TEXTURE_CUBE_MAP_SEAMLESS")
	gl.Enable("GL_MULTISAMPLE")
	gl.Enable("GL_DEPTH_TEST")
	gl.Enable("GL_BLEND")

	local largest = ffi.new("GLfloat[1]")
	gl.GetFloatv("GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT", largest)
	render.max_anisotropy = largest[0]
end

function render.Shutdown()

end

function render.GetVersion()
	local str = gl.GetString("GL_VERSION")
	if str == nil then  return "?" end
	return ffi.string(str)
end

function render.GetShadingLanguageVersion()
	local str = gl.GetString("GL_SHADING_LANGUAGE_VERSION")
	if str == nil then  return "?" end
	return ffi.string(str)
end

function render.GetVendor()
	local str = gl.GetString("GL_VENDOR")
	if str == nil then  return "?" end
	return ffi.string(str)
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

	local A,B,C,D,E,F

	function render.SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)

		if src_color then
			if src_color == "alpha" then
				gl.BlendFuncSeparate(
					"GL_SRC_ALPHA", "GL_ONE_MINUS_SRC_ALPHA",
					"GL_ONE", "GL_ONE_MINUS_SRC_ALPHA"
				)
			elseif src_color == "multiplicative" then
				gl.BlendFuncSeparate(
					"GL_DST_COLOR", "GL_ZERO",
					"GL_DST_COLOR", "GL_ZERO"
				)
			elseif src_color == "premultiplied" then
				gl.BlendFuncSeparate(
					"GL_ONE", "GL_ONE_MINUS_SRC_ALPHA",
					"GL_ONE", "GL_ONE_MINUS_SRC_ALPHA"
				)
			elseif src_color == "additive" then
				gl.BlendFuncSeparate(
					"GL_SRC_ALPHA", "GL_ONE",
					"GL_SRC_ALPHA", "GL_ONE"
				)
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
		else
			gl.BlendFuncSeparate(
				"GL_ONE", "GL_ZERO",
				"GL_ONE", "GL_ZERO"
			)
		end

		A,B,C,D,E,F = src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha
	end

	function render.GetBlendMode()
		return A,B,C,D,E,F
	end

	utility.MakePushPopFunction(render, "BlendMode")
end

do
	local enabled = false

	function render._SetCullMode(mode)
		if mode == "none" then
			if enabled then
				gl.Disable("GL_CULL_FACE")
				enabled = false
			end
		else
			if not enabled then
				gl.Enable("GL_CULL_FACE")
				enabled = true
			end

			if mode == "front" then
				gl.CullFace("GL_FRONT")
			elseif mode == "back" then
				gl.CullFace("GL_BACK")
			elseif mode == "front_and_back" then
				gl.CullFace("GL_FRONT_AND_BACK")
			end
		end
	end
end

function render._SetDepth(b)
	if b then
		gl.Enable("GL_DEPTH_TEST")
		gl.DepthFunc("GL_LESS")
	else
		gl.Disable("GL_DEPTH_TEST")
		gl.DepthFunc("GL_ALWAYS")
	end
end

if system.IsOpenGLExtensionSupported("GL_ARB_texture_barrier") then
	function render.TextureBarrier()
		gl.TextureBarrier()
	end
end

do
	local translate = {
		samples_passed = gl.eGL_SAMPLES_PASSED,
		any_samples_passed = gl.e.GL_ANY_SAMPLES_PASSED,
		any_samples_passed_conservative = gl.e.GL_ANY_SAMPLES_PASSED_CONSERVATIVE,
		primitives_generated = gl.e.GL_PRIMITIVES_GENERATED,
		transform_feedback_primitives_written = gl.e.GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN,
		time_passed = gl.e.GL_TIME_ELAPSED,
	}

	local META = {}
	META.__index = META

	function META:Begin()
		gl.BeginQuery(self.type, self.id)
	end

	function META:End()
		gl.EndQuery(self.type)
	end

	function META:BeginConditional()
		gl.BeginConditionalRender(self.id, "GL_QUERY_NO_WAIT")
	end

	function META:EndConditional()
		gl.EndConditionalRender()
	end

	do
		local temp = ffi.new("GLuint[1]")
		function META:GetResult()
			gl.GetQueryObjectuiv(self.id, "GL_QUERY_RESULT_AVAILABLE", temp)
			if temp[0] == 1 then
				gl.GetQueryObjectuiv(self.id, "GL_QUERY_RESULT", temp)
				return temp[0]
			end
		end
	end

	function META:Delete()
		gl.DeleteQueries(1, ffi.new('GLuint[1]', self.id))
	end

	local ctype = ffi.typeof('struct { int id; uint16_t type; uint8_t ready; }')

	ffi.metatype(ctype, META)

	function render.CreateQuery(type)
		local temp = ffi.new("GLuint[1]")
		gl.GenQueries(1, temp)
		local self = ffi.new(ctype)
		self.id = temp[0]
		self.type = translate[type]
		return self
	end
end

function render.SetColorMask(r,g,b,a)
	gl.ColorMask(r,g,b,a)
end