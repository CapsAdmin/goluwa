local love=love
local lovemu=lovemu
love.system={}

local ffi=ffi
local glfw=glfw
local window=window

function love.system.getClipboardText()
	return ffi.string(glfw.GetClipboardString(window.render_window.__ptr))
end

function love.system.setClipboardText(str)
	glfw.SetClipboardString(window.render_window.__ptr,str)
end