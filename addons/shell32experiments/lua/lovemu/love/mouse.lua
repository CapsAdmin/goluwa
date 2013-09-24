local love=love
local lovemu=lovemu
love.mouse={}

local input=input

function love.mouse.getPosition()
	return window.GetMousePos():Unpack()
end

local visible=false
function love.mouse.setVisible(bool)	--partial
	visible=bool
end

function love.mouse.getVisible(bool)	--partial
	return visible
end

local mouse_keymap={
	l="mouse_1",
	r="mouse_2",
	m="mouse_3",
	x1="mouse_4",
	x2="mouse_5"
}
function love.mouse.isDown(key)
	return input.IsMouseDown(mouse_keymap[key])
end

local mouse_keymap = {}
for k,v in pairs(mouse_keymap) do
	mouse_keymap[v] = k
end

event.AddListener("OnMouseInput","lovemu_mouse",function(key,press)
	local x, y = window.GetMousePos():Unpack()

	if press then
		if love.mousepressed then
			love.mousepressed(x, y, mouse_keymap[key])
		end
	else
		if love.mousereleased then
			love.mousereleased(x, y, mouse_keymap[key])
		end
	end
end) 