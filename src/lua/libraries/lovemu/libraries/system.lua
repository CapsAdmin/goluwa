local love = ... or love

love.system = {}

function love.system.getClipboardText()
	return system.GetClipboard()
end

function love.system.setClipboardText(str)
	system.SetClipboard(str)
end

function love.system.openURL(url)
	logn("love.system.openURL(",url,")")
end