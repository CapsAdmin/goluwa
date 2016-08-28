local render = _G.render or {}

include("debug.lua", render)
include("vertex_buffer.lua", render)
include("texture.lua", render)
include("texture_format.lua", render)
include("texture_decoder.lua", render)
include("framebuffer.lua", render)
include("global_shader_code.lua", render)
include("generated_textures.lua", render)
include("camera.lua", render)
include("window.lua", render)
include("scene.lua", render)
include("gbuffer.lua", render)
include("texture_atlas.lua", render)
include("mesh_builder.lua", render)
include("material.lua", render)
include("model_loader.lua", render)
include("shadow_map.lua", render)
include("sky.lua", render)
include("environment_probe.lua", render)
include("globals.lua", render)

function render.Initialize()
	include("lua/libraries/graphics/render/opengl/render.lua", render)

	render._Initialize()

	include("lua/libraries/graphics/render/texture_decoders/*")

	render.frame = 0

	render.SetBlendMode("src_alpha", "one_minus_src_alpha")

	include("lua/libraries/graphics/render/shader_builder.lua", render)

	render.GenerateTextures()

	event.Call("RenderContextInitialized")
end

function render.Shutdown()

end

do
	local X,Y,W,H = 0,0,1,1

	function render.SetViewport(x, y, w, h)
		if X ~= x or Y ~= y or W ~= w or H ~= h then
			render._SetViewport(x,y,w,h)

			render.camera_2d.Viewport.x = x
			render.camera_2d.Viewport.x = y
			render.camera_2d.Viewport.w = w
			render.camera_2d.Viewport.h = h
			render.camera_2d:Rebuild()
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
		--surface.SetScissor(x, y, w, h)

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
		return cull
	end

	function render.SetForcedCullMode(mode)
		force_ = mode
		render._SetCullMode(mode)
	end

	utility.MakePushPopFunction(render, "CullMode")
end

render.AddGlobalShaderCode([[
float random(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}]])

render.AddGlobalShaderCode([[
float random_temporal(vec2 co)
{
	return fract(sin(dot(co.xy * iGlobalTime,vec2(12.9898,78.233))) * 43758.5453);
}]])

render.AddGlobalShaderCode([[
vec2 get_noise2(vec2 uv)
{
	float x = random(uv);
	float y = random(uv*x);

	return vec2(x,y) * 2 - 1;
}]])

render.AddGlobalShaderCode([[
vec2 get_noise2_temporal(vec2 uv)
{
	float x = random(uv * iGlobalTime);
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
vec3 get_noise3_temporal(vec2 uv)
{
	float x = random(uv * iGlobalTime);
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
--render.SetGlobalShaderVariable("iMouse", function() return Vec2(surface.GetMousePosition()) end, "float")
--render.SetGlobalShaderVariable("iDate", function() return Color(os.date("%y"), os.date("%m"), os.date("%d"), os.date("%s")) end, "vec4")

return render