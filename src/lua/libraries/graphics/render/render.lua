local render = _G.render or {}

include("opengl/render.lua", render)
include("texture.lua", render)
include("texture_format.lua", render)
include("texture_decoder.lua", render)
include("framebuffer.lua", render)
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
	render._Initialize()

	include("lua/libraries/graphics/render/texture_decoders/*")

	render.frame = 0

	render.SetBlendMode("src_alpha", "one_minus_src_alpha")
	render.SetDepth(false)

	include("lua/libraries/graphics/render/shader_builder.lua", render)

	render.GenerateTextures()

	event.Call("RenderContextInitialized")
end

function render.Shutdown()

end

do
	local X,Y,W,H
	local last = Rect()

	function render.SetViewport(x, y, w, h)
		X,Y,W,H = x,y,w,h

		if last.x ~= x or last.y ~= y or last.w ~= w or last.h ~= h then
			render._SetViewport(x,y,w,h)

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
		table.insert(stack, {X or 0, Y or 0, W or render.GetWidth(), H or render.GetHeight()})

		render.SetViewport(x, y, w, h)
	end

	function render.PopViewport()
		local v = table.remove(stack)

		render.SetViewport(v[1], v[2], v[3], v[4])
	end
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
end

do
	local cull_mode
	local override_

	function render.SetCullMode(mode, override)
		if mode == cull_mode and override ~= true then return end
		if override_ and override ~= false then return end

		render._SetCullMode(mode)

		cull_mode = mode
		override_ = override
	end

	function render.GetCullMode()
		return cull_mode
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

render.SetGlobalShaderVariable("iResolution", function() return Vec3(render.gbuffer_size.x, render.gbuffer_size.y, render.gbuffer_size.x / render.gbuffer_size.y) end, "vec3")
render.SetGlobalShaderVariable("iGlobalTime", function() return system.GetElapsedTime() end, "float")
render.SetGlobalShaderVariable("iMouse", function() return Vec2(surface.GetMousePosition()) end, "float")
render.SetGlobalShaderVariable("iDate", function() return Color(os.date("%y"), os.date("%m"), os.date("%d"), os.date("%s")) end, "vec4")

return render