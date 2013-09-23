love.system={}

function love.system.getClipboardText()
	return ffi.string(glfw.GetClipboardString(glw.window.__ptr))
end

function love.system.setClipboardText(str)
	glfw.SetClipboardString(glw.window.__ptr,str)
end