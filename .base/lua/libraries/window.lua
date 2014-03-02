window = _G.window or {}

window.wnd = window.wnd or NULL

setmetatable(window, {
	__index = function(s, key)
		if s.wnd:IsValid() and s.wnd[key] then
			return function(...)
				return s.wnd[key](s.wnd, ...)
			end
		end
	end,
})

function window.Open(...)  
	if window.wnd:IsValid() then return end
	
	local wnd = render.CreateWindow(...)
	
	window.wnd = wnd
	
	event.Call("WindowOpened", wnd)
end

function window.IsOpen()
	return window.wnd:IsValid()
end

function window.Close()
	if window.wnd:IsValid() then
		window.wnd:Remove()
	end
end

function system.SetClipboard(str)
	if window.wnd:IsValid() then
		if sdl then
			sdl.SetClipboardText(str)
		else
			glfw.SetClipboardString(window.wnd.__ptr, str)
		end
	end
end

function system.GetClipboard()
	if window.wnd:IsValid() then
		if sdl then
			ffi.string(sdl.GetClipboardText(str))
		else
			return ffi.string(glfw.GetClipboardString(window.wnd.__ptr))
		end
	end
end