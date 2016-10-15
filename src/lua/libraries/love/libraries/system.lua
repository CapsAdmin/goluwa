local love = ... or _G.love
local ENV = love._line_env

love.system = love.system or {}

function love.system.getClipboardText()
	return system.GetClipboard()
end

function love.system.setClipboardText(str)
	system.SetClipboard(str)
end

function love.system.openURL(url)
	system.OpenURL(url)
end

function love.system.getOS()
	return jit.os
end
