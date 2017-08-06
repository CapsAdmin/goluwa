local render = (...) or _G.render

render.current_window = render.current_window or NULL

function render.SetWindow(window)
	render._SetWindow(window)
	render.current_window = window

	render.SetViewport(0, 0, window:GetSize():Unpack())
	render.SetScissor(0, 0, window:GetSize():Unpack())
end

function render.GetWindow()
	return render.current_window
end

utility.MakePushPopFunction(render, "Window")

function render.GetWidth()
	return render.current_window:GetSize().x
end

function render.GetHeight()
	return render.current_window:GetSize().y
end

function render.GetScreenSize()
	return render.current_window:GetSize()
end