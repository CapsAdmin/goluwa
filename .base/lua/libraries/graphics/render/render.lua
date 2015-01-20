local gl = requirew("lj-opengl") -- OpenGL

if not gl then return end

local render = _G.render or {}

function render.Initialize()

	if not gl then 
		logn("cannot initialize render: ", err)
	return end
	
	if not render.context_created then error("a window must exist before the renderer can be initialized", 2) end

	logf("opengl version: %s\n", render.GetVersion())
	logf("opengl glsl version: %s\n", render.GetShadingLanguageVersion())
	logf("vendor: %s\n", render.GetVendor())
	
	if render.GetVersion():find("OpenGL ES") then
		OPENGL_ES = true
	end
	
	local vendor = render.GetVendor()
	
	if vendor:lower():find("nvidia") then
		NVIDIA = true
	elseif vendor:lower():find("ati") or vendor:lower():find("amd") then
		ATI = true
		-- AMD = true grr cpus
	end
		
	if render.debug then
		render.EnableDebug(true)
	end
	
	render.GenerateTextures()
	
	include("libraries/graphics/decoders/*")
	
	render.Uniform4f = gl.Uniform4f
	render.Uniform3f = gl.Uniform3f
	render.Uniform2f = gl.Uniform2f
	render.Uniform1f = gl.Uniform1f
	render.Uniform1i = gl.Uniform1i
	render.UniformMatrix4fv = gl.UniformMatrix4fv
	
	render.frame = 0
		
	gl.Enable(gl.e.GL_BLEND)
	gl.Enable(gl.e.GL_SCISSOR_TEST)
	
	gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE_MINUS_SRC_ALPHA)
	gl.Disable(gl.e.GL_DEPTH_TEST)
	
	if gl.DepthRangef then
		gl.DepthRangef(1, 0)
	end
	
	render.SetClearColor(0.25, 0.25, 0.25, 0.5)
	
	include("libraries/graphics/render/shader_builder.lua", render)
	
	event.Delay(function()
		event.Call("RenderContextInitialized")	
	end)
end

function render.Shutdown()
	
end

do -- shaders
	local status = ffi.new("GLint[1]")
	local shader_strings = ffi.new("const char * [1]")
	local log = ffi.new("char[1024]")

	function render.CreateGLShader(type, source)
		check(type, "number")
		check(source, "string")
		
		if not render.CheckSupport("CreateShader") then return 0 end
		
		local shader = gl.CreateShader(type)
		
		shader_strings[0] = ffi.cast("const char *", source)
		gl.ShaderSource(shader, 1, shader_strings, nil)
		gl.CompileShader(shader)
		gl.GetShaderiv(shader, gl.e.GL_COMPILE_STATUS, status)		

		if status[0] == 0 then			
		
			gl.GetShaderInfoLog(shader, 1024, nil, log)
			gl.DeleteShader(shader)
			
			error(ffi.string(log), 2)
		end

		return shader
	end

	function render.CreateGLProgram(cb, ...)	

		if not render.CheckSupport("CreateProgram") then return 0 end

		local shaders = {...}
		local program = gl.CreateProgram()
		
		for _, shader_id in pairs(shaders) do
			gl.AttachShader(program, shader_id)
		end
		
		cb(program)

		gl.LinkProgram(program)

		gl.GetProgramiv(program, gl.e.GL_LINK_STATUS, status)

		if status[0] == 0 then
		
			gl.GetProgramInfoLog(program, 1024, nil, log)
			gl.DeleteProgram(program)		
			
			error(ffi.string(log), 2)
		end
		
		for _, shader_id in pairs(shaders) do
			gl.DetachShader(program, shader_id)
			gl.DeleteShader(shader_id)
		end
		
		return program
	end

	do
		local last

		function render.UseProgram(id)
			if last ~= id then
				gl.UseProgram(id)
				last = id
				render.current_program = id
			end
		end
	end

	do
		local last

		function render.BindArrayBuffer(id)
			if last ~= id then
				gl.BindBuffer(gl.e.GL_ARRAY_BUFFER, id)
				last = id
			end
		end
	end
	
	do
		local last

		function render.BindVertexArray(id)
			if last ~= id then
				gl.BindVertexArray(id)
				last = id
				
				return true
			end
			
			return false
		end
	end
end

do
	local vsync = 0
	
	function render.SetVSync(b)
		if gl.SwapIntervalEXT and not (NVIDIA and X64 and WINDOWS) then
			gl.SwapIntervalEXT(b == true and 1 or b == "adaptive" and -1 or 0)
		elseif window and window.IsOpen() then
			window.SwapInterval(b and 1 or 0) -- works on linux
		end
		vsync = b
	end

	function render.GetVSync(b)
		return vsync
	end
end
 
function render.Shutdown()	

end

function render.GetVersion()		
	return ffi.string(gl.GetString(gl.e.GL_VERSION))
end

function render.GetShadingLanguageVersion()		
	return ffi.string(gl.GetString(gl.e.GL_SHADING_LANGUAGE_VERSION))
end

function render.GetVendor()		
	return ffi.string(gl.GetString(gl.e.GL_VENDOR))
end

function render.CheckSupport(func)
	if not gl[func] then
		logf("%s: the function gl.%s does not exist\n", debug.getinfo(2).func:name(), func)
		return false
	end
	
	return true
end

function render.SetClearColor(r,g,b,a)
	gl.ClearColor(r,g,b, a or 1)
end

function render.Clear(flag, ...)
	flag = flag or gl.e.GL_COLOR_BUFFER_BIT
	gl.Clear(bit.bor(flag, ...))
end

do
	local X, Y, W, H = 0, 0, 0, 0
	
	function render.SetScissor(x,y,w,h)
		--render.ScissorRect(x,y,w,h)  
		--surface.SetScissor(x, y, w, h)

		local sw, sh = render.GetScreenSize():Unpack()
		
		x = x or 0
		y = y or 0
		w = w or sw
		h = h or sh
		
		gl.Scissor(x, sh - (y + h), w, h)
		
		X = x
		Y = y
		W = w
		H = h
	end

	function render.GetScissor()
		return X,Y,W,H
	end
end

do
	local MODE = "alpha"

	function render.SetBlendMode(mode)		
		if mode == "alpha" then
			gl.AlphaFunc(gl.e.GL_GEQUAL, 0)
			
			gl.BlendFuncSeparate(	
				gl.e.GL_SRC_ALPHA, gl.e.GL_ONE_MINUS_SRC_ALPHA, 
				gl.e.GL_ONE, gl.e.GL_ONE_MINUS_SRC_ALPHA
			)
		elseif mode == "multiplicative" then
			gl.BlendFunc(gl.e.GL_DST_COLOR, gl.e.GL_ZERO)
		elseif mode == "premultiplied" then
			gl.BlendFunc(gl.e.GL_ONE, gl.e.GL_ONE_MINUS_SRC_ALPHA)
		elseif mode == "additive" then
			gl.BlendFunc(gl.e.GL_SRC_ALPHA, gl.e.GL_ONE)
		else
			gl.BlendFunc(gl.e.GL_ONE, gl.e.GL_ZERO)
		end
		
		MODE = mode
	end
	
	function render.GetBlendMode()
		return MODE
	end
end

do 
	local enums = gl and {
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
	} or {}

	function render.SetBlendMode2(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)
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

do	
	local cull_mode = "front"

	function render.SetCullMode(mode)
		
		if mode == "none" then
			gl.Disable(gl.e.GL_CULL_FACE)
		else
			gl.Enable(gl.e.GL_CULL_FACE)
		end
	
		if mode == "front" then
			gl.CullFace(gl.e.GL_FRONT)
		elseif mode == "back" then
			gl.CullFace(gl.e.GL_BACK)
		elseif mode == "front_and_back" then
			gl.CullFace(gl.e.GL_FRONT_AND_BACK)
		end
		
		cull_mode = mode
	end

	function render.GetCullMode()
		return cull_mode
	end
end

do
	local data = ffi.new("float[3]")

	function render.ReadPixels(x, y, w, h)
		w = w or 1
		h = h or 1
		
		gl.ReadPixels(x, y, w, h, gl.e.GL_RGBA, gl.e.GL_FLOAT, data)
			
		return data[0], data[1], data[2], data[3]
	end
end

if RELOAD then return end

include("enum_translate.lua", render)
include("generated_textures.lua", render)
include("matrices.lua", render)
include("scene.lua", render)
include("texture.lua", render)
include("framebuffer.lua", render)
include("gbuffer.lua", render)
include("vertex_buffer.lua", render)
include("texture_atlas.lua", render)
include("mesh_builder.lua", render)

if USE_SDL then
	include("sdl_window.lua", render)
else
	include("glfw_window.lua", render)
end

include("cvars.lua", render)
include("globals.lua", render)
include("debug.lua", render)

return render