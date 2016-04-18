local render = (...) or _G.render

do -- current window
	system.current_window = system.current_window or NULL

	function render.SetWindow(window)
		window:MakeContextCurrent()

		system.current_window = window

		_G.window.wnd = window

		render.SetViewport(0, 0, window:GetSize():Unpack())
	end

	function render.GetWindow()
		return system.current_window
	end

	utility.MakePushPopFunction(render, "Window", render.SetWindow, render.GetWindow)

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

pvars.Setup("render_accum", 0)
local deferred = pvars.Setup("render_deferred", true, "whether or not deferred rendering is enabled.")

function render.DrawScene(skip_2d)
	render.GetScreenFrameBuffer():Begin()

	if deferred:Get() and render.IsGBufferReady() then
		render.DrawGBuffer()
	else
		render.SetDepth(true)
		render.SetBlendMode("alpha")
		render.Draw3DScene("models")
	end

	if not skip_2d then
		surface.Start()

		surface.SetColor(1,1,1,1)
		render.SetDepth(false)
		render.SetBlendMode("alpha")
		render.SetShaderOverride()

		if deferred:Get() and render.IsGBufferReady() then
			if menu and menu.IsVisible() then
				surface.PushHSV(1,0,1)
			end

			surface.SetTexture(render.GetFinalGBufferTexture())
			surface.DrawRect(0, 0, surface.GetSize())

			if menu and menu.IsVisible() then
				surface.PopHSV()
			end

			if render.debug then
				render.DrawGBufferDebugOverlay()
			end
		end

		event.Call("Draw2D", system.GetFrameTime())

		surface.End()

		event.Call("PostDrawScene")
	end

	render.GetScreenFrameBuffer():End()
end