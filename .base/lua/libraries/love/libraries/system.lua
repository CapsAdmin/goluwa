local love = love or ...

love.system = {}

function love.system.getClipboardText()
	return system.GetClipboard()
end

function love.system.setClipboardText(str)
	system.SetClipboard(str)
end