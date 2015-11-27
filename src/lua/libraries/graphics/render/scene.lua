local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

do -- current window
	system.current_window = system.current_window or NULL

	function render.SetWindow(window)
		window:MakeContextCurrent()

		system.current_window = window

		_G.window.wnd = window

		local w, h = window:GetSize():Unpack()
		render.w = w
		render.h = h

		render.SetViewport(0, 0, w, h)
	end

	function render.GetWindow()
		return system.current_window
	end

	utility.MakePushPopFunction(render, "Window", render.SetWindow, render.GetWindow, reset)

	function render.GetWidth()
		if system.current_window:IsValid() then
			return system.current_window:GetSize().x
		end

		return 0
	end

	function render.GetHeight()
		if system.current_window:IsValid() then
			return system.current_window:GetSize().y
		end

		return 0
	end

	function render.GetScreenSize()
		return Vec2(render.GetWidth(), render.GetHeight())
	end
end

render.scene_3d = render.scene_3d or {}

function render.Draw3DScene(what, dist)
	--[[local cam_pos = render.camera_3d:GetPosition()

	table.sort(render.scene_3d, function(a, b)
		return
			a:GetComponent("transform"):GetPosition():Distance(cam_pos) <
			b:GetComponent("transform"):GetPosition():Distance(cam_pos)

	end)]]

	for i, model in ipairs(render.scene_3d) do
		model:Draw(what, dist)
	end
end

console.CreateVariable("render_accum", 0)
local deferred = console.CreateVariable("render_deferred", true, "whether or not deferred rendering is enabled.")

render.vertex_draw_count = 0
render.draw_call_count = 0

function render.DrawScene(skip_2d)
	render.vertex_draw_count = 0
	render.draw_call_count = 0

	--render.GetScreenFrameBuffer():Clear()
	render.GetScreenFrameBuffer():Bind()

	if deferred:Get() and render.IsGBufferReady() then
		render.DrawGBuffer()
	else
		render.EnableDepth(true)
		render.SetBlendMode("alpha")

		render.Draw3DScene("models")
	end

	if not skip_2d then
		render.EnableDepth(false)
		render.SetBlendMode("alpha")

		event.Call("Draw2D", system.GetFrameTime())

		event.Call("PostDrawScene")
	end

	render.vertices_drawn = render.vertex_draw_count
	render.draw_calls = render.draw_call_count
end