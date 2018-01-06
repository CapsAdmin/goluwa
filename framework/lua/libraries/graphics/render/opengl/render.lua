local ffi = require("ffi")
local gl = system.GetFFIBuildLibrary("opengl")

if not gl then return end

local render = ... or {}

runfile("debug.lua", render)
runfile("shader_program.lua", render)
runfile("shader_buffer.lua", render)
runfile("lock.lua", render)
runfile("index_buffer.lua", render)
runfile("vertex_buffer.lua", render)
runfile("texture.lua", render)
runfile("framebuffer.lua", render)

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

	if DEBUG_OPENGL and not EXTERNAL_DEBUGGER then
		render.SetDebug(true)
	end

	if SRGB then
		gl.Enable("GL_FRAMEBUFFER_SRGB")
	end

	gl.Enable("GL_TEXTURE_CUBE_MAP_SEAMLESS")
	gl.Enable("GL_MULTISAMPLE")
	gl.Enable("GL_BLEND")

	if render.IsExtensionSupported("GL_EXT_texture_filter_anisotropic") then
		local largest = ffi.new("GLfloat[1]")
		gl.GetFloatv("GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT", largest)
		render.max_anisotropy = largest[0]
	end
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

do
	local enabled = false
	function render._SetScissor(x,y,w,h, sw,sh)
		if not x then
			if enabled == true then
				gl.Disable("GL_SCISSOR_TEST")
				enabled = false
			end
		else
			if enabled == false then
				gl.Enable("GL_SCISSOR_TEST")
				enabled = true
			end
			gl.Scissor(x, sh - (y + h), w, h)
		end
	end
end

function render._SetViewport(x,y,w,h)
	gl.Viewport(x, y, w, h)
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

	if gl.BlendFuncSeparate ~= nil then
		local BlendFunc = utility.GenerateCheckLastFunction(gl.BlendFuncSeparate, 4)
		local BlendEquation = utility.GenerateCheckLastFunction(gl.BlendEquationSeparate, 2)

		function render._SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)
			BlendFunc(enums[src_color], enums[dst_color], enums[src_alpha], enums[dst_alpha])
			BlendEquation(enums[func_color], enums[func_alpha])
		end
	else
		local BlendFunc = utility.GenerateCheckLastFunction(gl.BlendFunc, 2)
		local BlendEquation = gl.BlendEquation and utility.GenerateCheckLastFunction(gl.BlendEquation, 1)

		function render._SetBlendMode(src_color, dst_color, func_color)
			BlendFunc(src_color, enums[dst_color])
			if BlendEquation then BlendEquation(enums[func_color]) end
		end
	end
end

do
	local CullFace = utility.GenerateCheckLastFunction(gl.CullFace, 1)

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
				CullFace("GL_FRONT")
			elseif mode == "back" then
				CullFace("GL_BACK")
			elseif mode == "front_and_back" then
				CullFace("GL_FRONT_AND_BACK")
			end
		end
	end
end

do
	local last_enable
	local last_func

	function render._SetDepth(b)
		if b then
			if last_enable ~= b then
				gl.Enable("GL_DEPTH_TEST")
				last_enable = b
			end
			if last_func ~= "GL_LESS" then
				gl.DepthFunc("GL_LESS")
				last_func = "GL_LESS"
			end
		else
			if last_enable ~= b then
				gl.Disable("GL_DEPTH_TEST")
				last_enable = b
			end
			if last_func ~= "GL_ALWAYS" then
				gl.DepthFunc("GL_ALWAYS")
				last_func = "GL_ALWAYS"
			end
		end
	end

end

if render.IsExtensionSupported("GL_ARB_texture_barrier") then
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

function render.SetDepthMask(d)
	gl.DepthMask(d)
end

do -- stencil
	do
		local enabled = false

		function render.SetStencil(b)
			if b then
				gl.Enable("GL_STENCIL_TEST")
			else
				gl.Disable("GL_STENCIL_TEST")
			end

			enabled = b
		end

		function render.GetStencil()
			return enabled
		end

	end

	do
		local translate = {
			never = "GL_NEVER",
			less = "GL_LESS",
			less_or_equal = "GL_LEQUAL",
			lessequal = "GL_LEQUAL",
			lequal = "GL_LEQUAL",
			greater = "GL_GREATER",
			greater_or_equal = "GL_GEQUAL",
			greaterequal = "GL_GEQUAL",
			gequal = "GL_GEQUAL",
			equal = "GL_EQUAL",
			not_equal = "GL_NOTEQUAL",
			notequal = "GL_NOTEQUAL",
			always = "GL_ALWAYS",
		}

		function render.StencilFunction(func, ref, mask)
			gl.StencilFunc(translate[func], ref, mask or 0xFF)
		end

	end

	do
		local translate = {
			keep = "GL_KEEP",
			zero = "GL_ZERO",
			replace = "GL_REPLACE",
			increase = "GL_INCR",
			increment = "GL_INCR",
			incr = "GL_INCR",
			increase_wrap = "GL_INCR_WRAP",
			incrementwrap = "GL_INCR_WRAP",
			incrsat = "GL_INCR_WRAP",
			decrease = "GL_DECR",
			decrement = "GL_DECR",
			decr = "GL_DECR",
			decrease_wrap = "GL_DECR_WRAP",
			decrementwrap = "GL_DECR_WRAP",
			decrsat = "GL_DECR_WRAP",
			invert = "GL_INVERT",
		}

		function render.StencilOperation(sfail, dpfail, dppass)
			gl.StencilOp(translate[sfail], translate[dpfail], translate[dppass])
		end
	end

	function render.StencilMask(mask)
		gl.StencilMask(mask)
	end
end
