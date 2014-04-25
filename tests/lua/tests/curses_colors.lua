timer.Delay(0.1 , function()

	local COLOR_BLACK = 0
	local COLOR_RED = 1
	local COLOR_GREEN = 2
	local COLOR_YELLOW = 3
	local COLOR_BLUE = 4
	local COLOR_MAGENTA = 5
	local COLOR_CYAN = 6
	local COLOR_WHITE = 7

	local COLOR_PAIR = function(x)
		return bit.lshift(x, 8)
	end

	curses.start_color()

	for i = 0, 7 do
		curses.init_pair(i, COLOR_BLACK, i)
	end

	for i = 0, 7 do
		curses.wattron(console.curses.log_window, COLOR_PAIR(i))
		curses.wprintw(console.curses.log_window, "#")
		curses.wattroff(console.curses.log_window, COLOR_PAIR(i))
	end 

	curses.wrefresh(console.curses.log_window)

end)