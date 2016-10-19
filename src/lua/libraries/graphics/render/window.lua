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

function render.DrawScene(dt)
	render.GetScreenFrameBuffer():Begin()

	if render3d.IsGBufferReady() then
		render3d.DrawGBuffer()
	end

	if render2d.IsReady() then
		render2d.Start()
		render2d.SetColor(1,1,1,1)
		render.SetCullMode("none")

		render.SetDepth(false)
		render.SetBlendMode("alpha")
		render.SetShaderOverride()

		if render3d.IsGBufferReady() then
			if menu and menu.IsVisible() then
				render2d.PushHSV(1,0,1)
			end

			render2d.SetTexture(render3d.GetFinalGBufferTexture())
			render2d.DrawRect(0, 0, render2d.GetSize())

			if menu and menu.IsVisible() then
				render2d.PopHSV()
			end

			if render3d.debug then
				render3d.DrawGBufferDebugOverlay()
			end
		end

		event.Call("PreDrawGUI", dt)
		event.Call("DrawGUI", dt)
		event.Call("PostDrawGUI", dt)

		render2d.End()

		event.Call("PostDrawScene")
	end

	render.GetScreenFrameBuffer():End()
end