local love=love
local lovemu=lovemu
love.system={}

local ffi=ffi
local glfw=glfw
local window=window

function love.system.getClipboardText()
	return system.GetClipboard()
end

function love.system.setClipboardText(str)
	system.SetClipboard(str)
end