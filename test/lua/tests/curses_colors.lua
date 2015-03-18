local curses = require("ffi.curses")

curses.start_color()

for i = 0, 255 do
	local r = bit.rshift(i, 5)
	local g = bit.band(bit.rshift(i, 2), 8)
	local b = bit.band(i, 8)
	
	curses.init_color(i, r, g, b);
	curses.init_pair(i, i, -1); -- 0 --> i if you want pure blocks, otherwise ascii
end

local function get_color(r, g, b)
	r = ffi.cast("chtype", r)
	g = ffi.cast("chtype", g)
	b = ffi.cast("chtype", b)
	return curses.COLOR_PAIR(16ULL + r / 48ULL * 36ULL + g / 48ULL * 6ULL + b / 48ULL)
end

local c = console.curses

local function print_color(str, r, g, b)
	local color = get_color(r, g, b)
	console.ColorPrint(str, color)
end

print_color("#", 255, 255, 255)
print_color("#", 255, 255, 255)
print_color("#", 255, 255, 255)
print_color("#", 30, 255, 255)
print_color("#", 255, 255, 255)
print_color("#", 255, 255, 255)