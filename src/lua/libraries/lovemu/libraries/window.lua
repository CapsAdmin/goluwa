local love = ... or love

love.window = {}

function love.window.setTitle(title)
	window.SetTitle(title)
end

function love.window.setCaption(title)
	window.SetTitle(title)
end

function love.window.getWidth()
	return window.GetSize().x
end

function love.window.getHeight()
	return window.GetSize().y
end

function love.window.getDimensions()
	return window.GetSize():Unpack()
end

local vec = Vec2()

function love.window.setMode(x,y)
	vec.x = x
	vec.y = y
	window.SetSize(vec)
end

function love.window.getDesktopDimensions()
	return window.GetSize():Unpack()
end

function love.window.setIcon()

end

function love.window.getIcon()

end

function love.window.getFullscreenModes() --partial
	return {
		{width=720,height=480},
		{width=800,height=480},
		{width=800,height=600},
		{width=852,height=480},
		{width=1024,height=768},
		{width=1152,height=768},
		{width=1152,height=864},
		{width=1280,height=720},
		{width=1280,height=768},
		{width=1280,height=800},
		{width=1280,height=854},
		{width=1280,height=960},
		{width=1280,height=1024},
		{width=1365,height=768},
		{width=1366,height=768},
		{width=1400,height=1050},
		{width=1440,height=900},
		{width=1440,height=960},
		{width=1600,height=900},
		{width=1600,height=1200},
		{width=1680,height=1050},
		{width=1920,height=1080},
		{width=1920,height=1200},
		{width=2048,height=1536},
		{width=2560,height=1600},
		{width=2560,height=2048}
	}
end
