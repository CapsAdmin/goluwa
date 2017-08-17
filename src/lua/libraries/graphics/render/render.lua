local render = _G.render or {}

runfile("texture_format.lua", render)
runfile("texture_decoder.lua", render)
runfile("global_shader_code.lua", render)
runfile("generated_textures.lua", render)
runfile("window.lua", render)
runfile("texture_atlas.lua", render)
runfile("material.lua", render)
runfile("camera.lua", render)
runfile("globals.lua", render)
runfile("shader_variables.lua", render)
runfile("vertex_buffer.lua", render)
runfile("texture.lua", render)
runfile("framebuffer.lua", render)
runfile("texture_decoders/*", render)
runfile("shader_builder.lua", render)

function render.GetDir()
	local dir = "lua/libraries/graphics/render/"

	if OPENGL then
		dir = dir .. "opengl/"
	elseif VULKAN then
		dir = dir .. "vulkan/"
	else
		dir = dir .. "null/"
	end

	return dir
end

function render.Initialize(wnd)
	runfile(render.GetDir() .. "render.lua", render)
	render.SetWindow(wnd)

	render._Initialize(wnd)
	render.GenerateTextures()
end

do
	function render.PreWindowSetup()

	end

	function render.PostWindowSetup(ptr)

	end

	runfile(render.GetDir() .. "window_sdl.lua", render)
end

function render.Shutdown()

end

do
	local X,Y,W,H = 0,0,1,1

	function render.SetViewport(x, y, w, h)
		if X ~= x or Y ~= y or W ~= w or H ~= h then
			render._SetViewport(x,y,w,h)

			camera.camera_2d.Viewport.x = x
			camera.camera_2d.Viewport.x = y
			camera.camera_2d.Viewport.w = w
			camera.camera_2d.Viewport.h = h
			camera.camera_2d:Rebuild()
			X,Y,W,H = x,y,w,h
		end
	end

	function render.GetViewport()
		return X,Y,W,H
	end

	utility.MakePushPopFunction(render, "Viewport")
end

do
	local enabled = false

	function render.SetDepth(b)
		enabled = b
		render._SetDepth(b)
	end

	function render.GetDepth()
		return enabled
	end

	utility.MakePushPopFunction(render, "Depth")
end

do
	local X, Y, W, H = 0, 0, 0, 0

	function render.SetScissor(x,y,w,h)
		--render.ScissorRect(x,y,w,h)
		--render2d.SetScissor(x, y, w, h)

		local sw, sh = render.GetScreenSize():Unpack()

		x = x or 0
		y = y or 0
		w = w or sw
		h = h or sh

		render._SetScissor(x,y,w,h, sw,sh)

		X = x
		Y = y
		W = w
		H = h
	end

	function render.GetScissor()
		return X,Y,W,H
	end

	utility.MakePushPopFunction(render, "Scissor")
end

do
	local cull_
	local force_

	function render.SetCullMode(mode)
		cull_ = mode
		render._SetCullMode(force_ or mode)
	end

	function render.GetCullMode()
		return cull_
	end

	function render.SetForcedCullMode(mode)
		force_ = mode
		render._SetCullMode(mode)
	end

	utility.MakePushPopFunction(render, "CullMode")
end

do
	local presets = {
		none = {
			src_color = "one",
			dst_color = "zero",
			func_color = "add",
			src_alpha = "one",
			dst_alpha = "zero",
			func_alpha = "add",
		},
		alpha = {
			src_color = "src_alpha",
			dst_color = "one_minus_src_alpha",
			func_color = "add",
			src_alpha = "one",
			dst_alpha = "one_minus_src_alpha",
			func_alpha = "add",
		},
		multiplicative = {
			src_color = "dst_color",
			dst_color = "zero",
			func_color = "add",
			src_alpha = "dst_color",
			dst_alpha = "zero",
			func_alpha = "add",
		},
		premultiplied = {
			src_color = "one",
			dst_color = "one_src_minus_alpha",
			func_color = "add",
			src_alpha = "one",
			dst_alpha = "one_src_minus_alpha",
			func_alpha = "add",
		},
		additive = {
			src_color = "src_alpha",
			dst_color = "one",
			func_color = "add",
			src_alpha = "src_alpha",
			dst_alpha = "one",
			func_alpha = "add",
		},
	}

	local current

	function render.SetPresetBlendMode(name)
		local preset = presets[name] or presets.none

		render.SetBlendMode(
			preset.src_color,
			preset.dst_color,
			preset.func_color,

			preset.src_alpha,
			preset.dst_alpha,
			preset.func_alpha
		)

		current = name
	end

	function render.GetPresetBlendMode()
		return current
	end

	utility.MakePushPopFunction(render, "PresetBlendMode")

	do
		local A,B,C,D,E,F

		function render.SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)
			if not dst_color then
				return render.SetPresetBlendMode(src_color)
			end

			src_color = src_color or "src_alpha"
			dst_color = dst_color or "one_minus_src_alpha"
			func_color = func_color or "add"

			src_alpha = src_alpha or src_color
			dst_alpha = dst_alpha or dst_color
			func_alpha = func_alpha or func_color

			render._SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)

			A, B, C, D, E, F = src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha
		end

		function render.GetBlendMode()
			return A, B, C, D, E, F
		end

		utility.MakePushPopFunction(render, "BlendMode")
	end
end

function render.TextureBarrier()

end

render.AddGlobalShaderCode([[
float random(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}]])

render.AddGlobalShaderCode([[
vec2 get_noise2(vec2 uv)
{
	float x = random(uv);
	float y = random(uv*x);

	return vec2(x,y) * 2 - 1;
}]])

render.AddGlobalShaderCode([[
vec3 get_noise3(vec2 uv)
{
	float x = random(uv);
	float y = random(uv*x);
	float z = random(uv*y);

	return vec3(x,y,z) * 2 - 1;
}]])

render.AddGlobalShaderCode([[
vec4 get_noise(vec2 uv)
{
	return texture(g_noise_texture, uv);
}]])

render.AddGlobalShaderCode([[
vec2 get_screen_uv()
{
	return gl_FragCoord.xy / g_gbuffer_size;
}]])


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

--render.SetGlobalShaderVariable("iResolution", function() return Vec3(render.GetGBufferSize().x, render.GetGBufferSize().y, render.GetGBufferSize().x / render.GetGBufferSize().y) end, "vec3")
--render.SetGlobalShaderVariable("iGlobalTime", function() return system.GetElapsedTime() end, "float")
--render.SetGlobalShaderVariable("iMouse", function() return Vec2(gfx.GetMousePosition()) end, "float")
--render.SetGlobalShaderVariable("iDate", function() return Color(os.date("%y"), os.date("%m"), os.date("%d"), os.date("%s")) end, "vec4")

return render