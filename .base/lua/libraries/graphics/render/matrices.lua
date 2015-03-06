local gl = require("libraries.ffi.opengl") -- OpenGL
local render = (...) or _G.render

function render.PushWorldMatrixEx(...)
	return render.camera_2d:PushWorldEx(...)
end

function render.PushWorldMatrix(...)
	return render.camera_2d:PushWorld(...)
end

function render.PopWorldMatrix(...)
	return render.camera_2d:PopWorld(...)
end

-- world matrix helper functions
function render.Translate(x, y, z)
	render.camera_2d:TranslateWorld(x, y, z)
end

function render.Rotate(a, x, y, z)
	render.camera_2d:RotateWorld(a, x, y, z)
end

function render.Scale(x, y, z)
	render.camera_2d:ScaleWorld(x, y, z)
end

function render.LoadIdentity()
	render.camera_2d:LoadIdentityWorld()
end	

function render.SetWorldMatrix(mat)
	render.camera_2d:SetWorld(mat)
end

render.AddGlobalShaderCode([[
float get_depth(vec2 uv) 
{
	return (2.0 * g_cam_nearz) / (g_cam_farz + g_cam_nearz - texture(tex_depth, uv).r * (g_cam_farz - g_cam_nearz));
}]], "get_noise")

-- lol

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

render.SetGlobalShaderVariable("g_screen_size", function() return Vec2(surface.GetSize()) end, "vec2")
render.SetGlobalShaderVariable("iResolution", function() return Vec2(render.camera.w, render.camera.h, render.camera.ratio) end, "vec3")
render.SetGlobalShaderVariable("iGlobalTime", function() return system.GetElapsedTime() end, "float")
render.SetGlobalShaderVariable("iMouse", function() return Vec2(surface.GetMousePosition()) end, "float")
render.SetGlobalShaderVariable("iDate", function() return Color(os.date("%y"), os.date("%m"), os.date("%d"), os.date("%s")) end, "vec4")
