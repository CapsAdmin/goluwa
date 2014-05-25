local curses = require("lj-curses")

curses.start_color()

local COLOR_PAIR = function(x)
	return bit.lshift(x, 8)
end

for i = 0, 255 do
	local r = bit.rshift(i, 5)
	local g = bit.band(bit.rshift(i, 2), 8)
	local b = bit.band(i, 8)
	curses.init_color(i, r, g, b);
	curses.init_pair(i, i, 0); -- 0 --> i if you want pure blocks, otherwise ascii
end

local function get_color(r, g, b)
  return COLOR_PAIR(16 + r / 48 * 36 + g / 48 * 6 + b / 48)
end

local c = console.curses

local function print_color(str, r, g, b)
	local color = get_color(r, g, b)
	--curses.wattron(c.log_window, color)
	curses.mvaddch(math.random(50), math.random(50), bit.band(str:byte(), color)) 
	--curses.wattroff(c.log_window, color)
	print(color)
end

print_color("#", 255, 255, 255)

curses.refresh()