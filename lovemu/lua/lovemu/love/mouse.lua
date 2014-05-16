local love=love
local lovemu=lovemu
love.mouse={}

local input=input

function love.mouse.getPosition()
	return window.GetMousePos():Unpack()
end

function love.mouse.getX()
	return window.GetMousePos().x
end

function love.mouse.getY()
	return window.GetMousePos().y
end

local cursor_translate = {
	[e.IDC_ARROW] = "arrow",
	[e.IDC_IBEAM] = "ibeam",
	[e.IDC_WAIT] = "wait",
	[e.IDC_CROSS] = "cross",
	[e.IDC_UPARROW] = "uparrow",
	[e.IDC_SIZE] = "size",
	[e.IDC_ICON] = "icon",
	[e.IDC_SIZENWSE] = "sizenwse",
	[e.IDC_SIZENESW] = "sizenesw",
	[e.IDC_SIZEWE] = "sizewe",
	[e.IDC_SIZENS] = "sizens",
	[e.IDC_SIZEALL] = "sizeall",
	[e.IDC_NO] = "no",
	[e.IDC_HAND] = "hand",
	[e.IDC_APPSTARTING] = "appstarting",
	[e.IDC_HELP] = "help",
}

function love.mouse.newCursor()
	local obj = lovemu.NewObject("Cursor")
	
end

function love.mouse.getCursor()
	local obj = lovemu.NewObject("Cursor")
	obj.getType = function()
		return cursor_translate[system.GetCursor()]
	end
	return obj
end

function love.mouse.setCursor()
	--system.SetCursor()
end

function love.mouse.getSystemCursor()
	local obj = lovemu.NewObject("Cursor")
	obj.getType = function()
		return cursor_translate[system.GetCursor()]
	end
	return obj
end


local visible=false
function love.mouse.setVisible(bool)	--partial
	visible=bool
end

function love.mouse.getVisible(bool)	--partial
	return visible
end

local mouse_keymap={
	button_1="l",
	button_2="r",
	button_3="m",
	button_4="x1",
	button_5="x2"
}
function love.mouse.isDown(key)
	return input.IsMouseDown(mouse_keymap[key])
end

event.AddListener("OnMouseInput","lovemu_mouse",function(key,press)
	local x, y = window.GetMousePos():Unpack()

	key = mouse_keymap[key]
	if press then
		if love.mousepressed then
			love.mousepressed(x, y, key)
		end
	else
		if love.mousereleased then
			love.mousereleased(x, y, key)
		end
	end
end) 