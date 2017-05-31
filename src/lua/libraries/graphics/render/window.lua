local render = (...) or _G.render

system.current_window = system.current_window or NULL

function render.SetWindow(window)
	render._SetWindow(window)

	system.current_window = window

	_G.window.wnd = window

	render.SetViewport(0, 0, window:GetSize():Unpack())
	render.SetScissor(0, 0, window:GetSize():Unpack())
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