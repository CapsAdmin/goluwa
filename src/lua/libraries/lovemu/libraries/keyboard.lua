local love = ... or love

love.keyboard = {}

do
	local DELAY = 0.5
	local INTERVAL = 0.1

	function love.keyboard.getKeyRepeat() -- partial
		return DELAY, INTERVAL
	end

	function love.keyboard.setKeyRepeat(delay, interval) -- partial
		DELAY = delay
		INTERVAL = interval
	end
end

local keyboard_map = {
	lshift = "left_shift",
	rshift = "right_shift",
	lctrl = "left_control",
	rctrl = "right_control",
	lalt = "left_alt",
	ralt = "right_alt",
	space = "space",
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
	page_down = "page_down",
	page_up = "page_up",
	enter = "return",
}

local reverse_keyboard_map = {}

for k,v in pairs(keyboard_map) do
	reverse_keyboard_map[v] = k
end

function love.keyboard.isDown(key) --partial
	return input.IsKeyDown(reverse_keyboard_map[key] or key)
end

function love.keyboard.setTextInput(b)

end

local CURRENT_CHAR

event.AddListener("KeyInput","lovemu_keyboard",function(key, press)
	key = keyboard_map[key] or key

	if press then
		if love.keypressed then
			love.keypressed(key, CURRENT_CHAR) --partial
		end
	else
		if love.keyreleased then
			love.keyreleased(key)
		end
	end
end)

event.AddListener("CharInput","lovemu_keyboard",function(char)
	CURRENT_CHAR = char
	if love.textinput then
		love.textinput(char) --partial
	end
end)