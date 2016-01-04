local ffi = require("ffi")
local gl = desire("graphics.ffi.opengl") -- OpenGL

if not gl then return end

local render = _G.render or {}

function render.Initialize()
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

	include("lua/libraries/graphics/render/texture_decoders/*")

	render.frame = 0

	render.SetBlendMode("src_alpha", "one_minus_src_alpha")
	render.EnableDepth(false)

	render.SetClearColor(0.25, 0.25, 0.25, 0.5)

	include("lua/libraries/graphics/render/shader_builder.lua", render)

	render.GenerateTextures()

	event.Call("RenderContextInitialized")
end

function render.Shutdown()

end

do
	render.global_shader_variables = render.global_shader_variables or {}

	function render.SetGlobalShaderVariable(key, val, type)
		render.global_shader_variables[key] = {[type] = val, global_variable = true}
	end

	render.global_shader_code = render.global_shader_code or {}

	function render.AddGlobalShaderCode(glsl_code, function_name, pos)
		if glsl_code:endswith(".brdf") then
			local str = vfs.Read(glsl_code)
			local shader_name = glsl_code:match(".+/(.+)%.brdf")
			
			local parameters = str:match("::begin parameters(.+)::end parameters")
			local code = str:match("::begin shader(.+)::end shader")
			
			local arg_line = {}
			
			for _, line in pairs(parameters:explode("\n")) do
				local type, name, max, min, default = unpack(line:explode(" "))
				if type and name then
					if type == "color" then type = "vec3" end
					table.insert(arg_line, type .. " " .. name)
				end
			end
			
			code = code:replace(
				"vec3 BRDF( vec3 L, vec3 V, vec3 N, vec3 X, vec3 Y )",
				"vec3 "..shader_name.."_brdf( vec3 L, vec3 V, vec3 N, vec3 X, vec3 Y, " .. table.concat(arg_line, ", ") .. " )"
			)
			
			glsl_code = code
			function_name = shader_name
		end
		
		if not function_name then
			function_name = glsl_code:match("%s([a-zA-Z0-9_]-)%(")
		end
		for i,v in ipairs(render.global_shader_code) do
			if v.function_name == function_name then
				table.remove(render.global_shader_code, i)
				break
			end
		end
		
		if pos then
			table.insert(render.global_shader_code, pos, {code = glsl_code, function_name = function_name})
		else
			table.insert(render.global_shader_code, {code = glsl_code, function_name = function_name})
		end
	end

	function render.GetGlobalShaderCode(code)

		local done = {}
		local out = {}
		
		local function add_code(code)			
			for _, info in ipairs(render.global_shader_code) do
				if code:find(info.function_name, nil, true) then
					if not done[info.function_name] then
						table.insert(out, 1, info.code)
						done[info.function_name] = true
						add_code(info.code)
					end
				end
			end
		end
		
		add_code(code)

		return table.concat(out, "\n\n")
	end

	render.AddGlobalShaderCode([[
		vec3 rgb2hsv(vec3 c)
		{
			vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
			vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}
	]])

	render.AddGlobalShaderCode([[
		vec3 hsv2rgb(vec3 c)
		{
			vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}
	]])
end

do -- shaders
	local status = ffi.new("GLint[1]")
	local shader_strings = ffi.new("const char * [1]")
	local log = ffi.new("char[1024]")

	function render.CreateGLShader(type, source)
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

	function render.CreateGLProgram(cb, ...)
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

do
	local vsync = 0

	if WINDOWS then
		function render.SetVSync(b)
			gl.SwapIntervalEXT(b == true and 1 or b == "adaptive" and -1 or 0)
			vsync = b
		end
	else
		function render.SetVSync(b)
			if window and window.IsOpen() then
				window.SwapInterval(b) -- works on linux
			end
			vsync = b
		end
	end

	function render.GetVSync(b)
		return vsync
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

do
	local R,G,B,A = 0,0,0,1

	function render.SetClearColor(r,g,b,a)
		R = r
		G = g
		B = b
		A = a or 1

		gl.ClearColor(R,G,B,A)
	end

	function render.GetClearColor()
		return R,G,B,A
	end
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
	local X,Y,W,H

	local last = Rect()

	function render.SetViewport(x, y, w, h)
		X,Y,W,H = x,y,w,h

		if last.x ~= x or last.y ~= y or last.w ~= w or last.h ~= h then
			gl.Viewport(x, y, w, h)
			gl.Scissor(x, y, w, h)

			render.camera_2d.Viewport.w = w
			render.camera_2d.Viewport.h = h
			render.camera_2d:Rebuild()

			last.x = x
			last.y = y
			last.w = w
			last.h = h
		end
	end

	function render.GetViewport()
		return x,y,w,h
	end

	local stack = {}

	function render.PushViewport(x, y, w, h)
		table.insert(stack, {X or 0,Y or 0,W or render.GetWidth(),H or render.GetHeight()})

		render.SetViewport(x, y, w, h)
	end

	function render.PopViewport()
		local v = table.remove(stack)

		render.SetViewport(v[1], v[2], v[3], v[4])
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

do
	local cull_mode
	local override_

	function render.SetCullMode(mode, override)
		if mode == cull_mode and override ~= true then return end
		if override_ and override ~= false then return end

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

		cull_mode = mode
		override_ = override
	end

	function render.GetCullMode()
		return cull_mode
	end
end

do
	local enabled = false

	function render.EnableDepth(b)
		local prev = enabled
		enabled = b

		if b then
			gl.Enable("GL_DEPTH_TEST")
			gl.DepthMask(1)
			gl.DepthFunc("GL_LESS")
		else
			gl.Disable("GL_DEPTH_TEST")
			gl.DepthMask(0)
			--gl.DepthFunc("GL_ALWAYS")
		end

		return prev
	end
end

-- shadertoy

--[[
Shader Inputs
uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iGlobalTime;           // shader playback time (in seconds)
uniform float     iChannelTime[4];       // channel playback time (in seconds)
uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube
uniform vec4      iDate;                 // (year, month, day, time in seconds)
uniform float     iSampleRate;           // sound sample rate (i.e., 44100)]]

render.SetGlobalShaderVariable("iResolution", function() return Vec3(render.gbuffer_size.w, render.gbuffer_size.h, render.gbuffer_size.w / render.gbuffer_size.h) end, "vec3")
render.SetGlobalShaderVariable("iGlobalTime", function() return system.GetElapsedTime() end, "float")
render.SetGlobalShaderVariable("iMouse", function() return Vec2(surface.GetMousePosition()) end, "float")
render.SetGlobalShaderVariable("iDate", function() return Color(os.date("%y"), os.date("%m"), os.date("%d"), os.date("%s")) end, "vec4")

if RELOAD then return end

include("generated_textures.lua", render)
include("camera.lua", render)
include("scene.lua", render)
include("texture.lua", render)
include("framebuffer.lua", render)
include("gbuffer.lua", render)
include("vertex_buffer.lua", render)
include("texture_atlas.lua", render)
include("mesh_builder.lua", render)
include("material.lua", render)
include("model_loader.lua", render)
include("shadow_map.lua", render)
include("sky.lua", render)
include("environment_probe.lua", render)
include("debug.lua", render)
include("globals.lua", render)

return render
