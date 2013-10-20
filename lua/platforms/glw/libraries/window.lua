window = {}

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
end

function window.Close()
	if window.wnd:IsValid() then
		window.wnd:Remove()
	end
end

function system.SetClipboard(str)
	if window.wnd:IsValid() then
		glfw.SetClipboardString(window.wnd.__ptr, str)
	end
end

function system.GetClipboard()
	if window.wnd:IsValid() then
		return ffi.string(glfw.GetClipboardString(window.wnd.__ptr))
	end
end