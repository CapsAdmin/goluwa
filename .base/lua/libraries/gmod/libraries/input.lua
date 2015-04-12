local gmod = ... or gmod
local input = gmod.env.input

function input.SetCursorPos(x, y) 
	window.SetMousePosition(Vec2(x, y))
end

function input.GetCursorPos()	
	return window.GetMousePosition():Unpack()
end

function input.IsShiftDown()
	return _G.input.IsKeyDown("left_shift") or _G.input.IsKeyDown("right_shift")
end