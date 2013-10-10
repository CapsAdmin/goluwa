local love=love
local lovemu=lovemu
love.window={}

local window=window

function love.window.setTitle(title)
	window.SetTitle(title)
end

local vec = Vec2()
function love.window.setMode(x,y)
	vec.x = x
	vec.y = y
	window.SetSize(vec)
end