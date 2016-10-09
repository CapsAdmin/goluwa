local input = gmod.env.input
local lib = _G.input

function input.SetCursorPos(x, y)
	window.SetMousePosition(Vec2(x, y))
end

function input.GetCursorPos()
	return window.GetMousePosition():Unpack()
end

function input.IsShiftDown()
	return lib.IsKeyDown("left_shift") or lib.IsKeyDown("right_shift")
end

function input.IsMouseDown(code)
	return lib.IsMouseDown(gmod.GetMouseCode(code, true))
end

function input.IsKeyDown(code)
	return lib.IsKeyDown(gmod.GetKeyCode(code, true))
end

function input.GetKeyName(code)
	return gmod.GetKeyCode(code, true)
end


local b
function input.StartKeyTrapping()
	b = true
end

function input.IsKeyTrapping()
	return b
end

function input.CheckKeyTrapping()

end

function input.StopKeyTrapping()
	b = false
end