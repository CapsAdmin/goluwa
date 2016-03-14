local render = _G.render or {}

include("opengl/render.lua", render)

include("global_shader_code.lua", render)
include("generated_textures.lua", render)
include("camera.lua", render)
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
	render.InitializeInternal()

	include("lua/libraries/graphics/render/texture_decoders/*")

	render.frame = 0

	render.SetBlendMode("src_alpha", "one_minus_src_alpha")
	render.EnableDepth(false)

	render.SetClearColor(0.25, 0.25, 0.25, 0.5)

	include("lua/libraries/graphics/render/shader_builder.lua", render)

	render.GenerateTextures()

	event.Call("RenderContextInitialized")
end

do
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

return render