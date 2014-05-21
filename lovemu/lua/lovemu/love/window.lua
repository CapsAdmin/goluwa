local love = (...) or _G.lovemu.love

love.window = {}

function love.window.setTitle(title)
	window.SetTitle(title)
end

function love.window.setCaption(title)
	window.SetTitle(title)
end

function love.window.getWidth()
	return window.GetSize().w
end

function love.window.getHeight()
	return window.GetSize().h
end

local vec = Vec2()

function love.window.setMode(x,y)
	vec.x = x
	vec.y = y
	window.SetSize(vec)
end