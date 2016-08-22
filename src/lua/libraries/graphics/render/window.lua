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

	utility.MakePushPopFunction(render, "Window")

	function render.GetWidth()
		return system.current_window:GetSize().x
	end

	function render.GetHeight()
		return system.current_window:GetSize().y
	end

	function render.GetScreenSize()
		return system.current_window:GetSize()
	end
end

function render.DrawScene(skip_2d)
	render.GetScreenFrameBuffer():Begin()

	if render.IsGBufferReady() then
		render.DrawGBuffer()
	end

	if not skip_2d and surface.IsReady() then
		surface.Start()

		surface.SetColor(1,1,1,1)
		render.SetDepth(false)
		render.SetBlendMode("alpha")
		render.SetShaderOverride()

		if render.IsGBufferReady() then
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