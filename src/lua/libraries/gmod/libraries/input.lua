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

do
	local translate = {
		[gmod.env.MOUSE_LEFT] = button_1,
		[gmod.env.MOUSE_RIGHT] = button_2,
		[gmod.env.MOUSE_MIDDLE] = button_3,
		[gmod.env.MOUSE_4] = button_4,
		[gmod.env.MOUSE_5] = button_5,
		[gmod.env.MOUSE_WHEEL_UP] = mwheel_up,
		[gmod.env.MOUSE_WHEEL_DOWN] = mwheel_down,
	}

	function input.IsMouseDown(code)
		return input.IsMouseDown(translate[code])
	end
end

do
	local translate = {}

	for k,v in pairs(gmod.env) do
		if k:startswith("KEY_") then
			translate[v] = k:match("KEY_(.+)"):lower()
		end
	end

	function input.IsKeyDown(code)
		return input.IsKeyDown(translate[code])
	end

	function input.GetKeyName(code)
		return translate[code]
	end
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