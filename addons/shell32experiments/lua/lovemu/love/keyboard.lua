local love=love
local lovemu=lovemu
love.keyboard={}

local input=input

local keyboard_map={
	lshift="left_shift",
	rshift="right_shift",
	lctrl="left_control",
	rctrl="right_control",
	lalt="left_alt",
	ralt="right_alt",
	space=" ",
	escape="esc",
	kp_0="kp0",
	kp_1="kp1",
	kp_2="kp2",
	kp_3="kp3",
	kp_4="kp4",
	kp_5="kp5",
	kp_6="kp6",
	kp_7="kp7",
	kp_8="kp8",
	kp_9="kp9",
	kp_enter="kpenter",
	kp_add="kp+",
	kp_subtract="kp-",
	kp_divide="kp/",
	kp_multiply="kp*",
	kp_divide="kp/",
	kp_decimal="kp.",
	num_lock="numlock",
	page_down="page_down",
	page_up="page_up"
}

local keyboard_map = {}
for k,v in pairs(keyboard_map) do
	keyboard_map[v] = k
end

function love.keyboard.isDown(key) --partial
	return input.IsKeyDown(keyboard_map[key] or key)
end

local keyboard_map = {}
for k,v in pairs(keyboard_map) do
	keyboard_map[v] = k
end

event.AddListener("OnKeyInput","lovemu_keyboard",function(key,press) --partial
	if press then
		if love.keypressed then
			love.keypressed(keyboard_map[key] or key)
		end
	else
		if love.keyreleased then
			love.keyreleased(keyboard_map[key] or key)
		end
	end
end) 