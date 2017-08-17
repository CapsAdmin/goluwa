local love = ... or _G.love
local ENV = love._line_env

love.keyboard = love.keyboard or {}

function love.keyboard.getKeyRepeat()
	return ENV.keyboard_delay or 0.5, ENV.keyboard_interval or 0.1
end

function love.keyboard.setKeyRepeat(delay, interval)
	ENV.keyboard_delay = delay
	ENV.keyboard_interval = interval
end

local keyboard_map = {
	lshift = "left_shift",
	rshift = "right_shift",
	lctrl = "left_control",
	rctrl = "right_control",
	lalt = "left_alt",
	ralt = "right_alt",
	space = " ",
	escape = "esc",
	kp_0 = "kp0",
	kp_1 = "kp1",
	kp_2 = "kp2",
	kp_3 = "kp3",
	kp_4 = "kp4",
	kp_5 = "kp5",
	kp_6 = "kp6",
	kp_7 = "kp7",
	kp_8 = "kp8",
	kp_9 = "kp9",
	kp_enter = "kpenter",
	kp_add = "kp+",
	kp_subtract = "kp-",
	kp_divide = "kp/",
	kp_multiply = "kp*",
	kp_decimal = "kp.",
	num_lock = "numlock",
	enter = "return",
}

local reverse_keyboard_map = {}

for k,v in pairs(keyboard_map) do
	reverse_keyboard_map[v] = k
end

function love.keyboard.isDown(key)
	return input.IsKeyDown(reverse_keyboard_map[key] or key)
end

function love.keyboard.setTextInput(b)

end

event.AddListener("LoveNewIndex", "line_keyboard", function(love, key, val)
	if key == "keypressed" or key == "keyreleased" then
		if val then
			local char_hack

			event.AddListener("KeyInput", "line", function(key, press)
				key = keyboard_map[key] or key

				if press then
					line.CallEvent("keypressed", key, char_hack)
				else
					line.CallEvent("keyreleased", key)
				end
			end)

			event.AddListener("CharInput", "line", function(char)
				char_hack = char

				line.CallEvent("textinput", char)
			end)
		else
			event.RemoveListener("CharInput", "line")
			event.RemoveListener("KeyInput", "line")
		end
	end
end)