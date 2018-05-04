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
runfile("index_buffer.lua", render)
runfile("vertex_buffer.lua", render)
runfile("texture.lua", render)
runfile("framebuffer.lua", render)
runfile("texture_decoders/*", render)
runfile("shader_builder.lua", render)
runfile("state.lua", render)

function render.GetDir()
	local dir = "lua/libraries/graphics/render/"

	if PLATFORM == "gmod" then
		dir = dir .. "gmod/"
	elseif OPENGL then
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

	if PLATFORM ~= "gmod" then
		runfile(render.GetDir() .. "window_sdl.lua", render)
	end
end

function render.Shutdown()

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
	return gl_FragCoord.xy / _G.gbuffer_size;
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
