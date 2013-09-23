love.mouse={}

function love.mouse.getPosition()
	return input.GetMousePos():Unpack()
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
	local x, y = input.GetMousePos():Unpack()

	if press then
		love.mousepressed(x, y, mouse_keymap[key])
	else
		love.mousereleased(x, y, mouse_keymap[key])
	end
end) 