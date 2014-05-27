local curses = require("lj-curses")

console.history = console.history or {}
console.curses = console.curses or {}
local c = console.curses

local markup = Markup()
markup:SetMultiline(false)
markup:SetFixedSize(14)

c.scroll = c.scroll or 0
c.current_table = c.current_table or G
c.table_scroll = c.table_scroll or 0

local history = serializer.ReadFile("luadata", "%DATA%/cmd_history.txt")

local translate = 
{
	[10] = "KEY_ENTER",
	[459] = "KEY_ENTER",
	[8] = "KEY_BACKSPACE",
	[127] = "CTL_BACKSPACE",
	PADENTER = "KEY_ENTER",
}

local A_DIM = 2 ^ 12
local A_BOLD = 2 ^ 13
local A_STANDOUT = 2 ^ 8

local COLOR_BLACK = 0
local COLOR_RED = 1
local COLOR_GREEN = 2
local COLOR_YELLOW = 3
local COLOR_BLUE = 4
local COLOR_MAGENTA = 5
local COLOR_CYAN = 6
local COLOR_WHITE = 7

local COLORPAIR_STATUS = 9

-- some helpers

local function gety()
	return curses.getcury(c.input_window)
end

local function getx()	
	return curses.getcurx(c.input_window)
end

local function move_cursor(x)
	curses.wmove(c.input_window, gety(), math.min(getx() + x, #c.line))
	curses.wrefresh(c.input_window)
end

local function set_cursor_pos(x)
	curses.wmove(c.input_window, 0, math.max(x, 0))
	curses.wrefresh(c.input_window)
end

function console.InsertChar(char)
	markup:OnCharInput(char)
end

function console.GetCurrentLine()
	return markup:GetText()
end
 
function console.InitializeCurses()
	event.CreateTimer("curses", 0, 0, function()
		local byte = curses.wgetch(c.input_window)

		if byte < 0 then return end
			
		local key = translate[byte] or ffi.string(curses.keyname(byte))
		
		key = translate[key] or key
		
		markup:SetControlDown(key == "CTL_LEFT" or key == "CTL_RIGHT" or key == "CTL_DEL" or key == "CTL_BACKSPACE")
		markup:SetShiftDown(key == "KEY_SLEFT" or key == "KEY_SRIGHT")
						
		if key:find("KEY_") or key:find("CTL_") then					
			key = ffi.string(key)
				
			if event.Call("ConsoleKeyInput", key) == false then return end
			
			console.HandleKey(key)		
		elseif byte >= 32 then
			local char = utf8.char(byte)
			
			if event.Call("ConsoleCharInput", char) == false then return end
			
			if char == "\t" then char = "    " end
					
			console.HandleChar(char)
		end
		
		set_cursor_pos(markup:GetCaretSubPos()-1)	
		console.ClearInput(markup:GetText())
	end)
	 
	do -- input extensions
		local trigger = input.SetupInputEvent("ConsoleKey")

		event.AddListener("ConsoleKeyInput", "input", function(key)
			local ret = trigger(key, true)
			
			-- :(
			event.Delay(0, function() trigger(key, false) end)
			
			return ret
		end)

		local trigger = input.SetupInputEvent("ConsoleChar")

		event.AddListener("ConsoleCharInput", "input", function(char)
			local ret = trigger(char, true)
			
			-- :(
			event.Delay(0, function() trigger(char, false) end)
			
			return ret
		end)
	end

	if console.curses_init then return end
	
	curses.freeconsole()

	curses.initscr()
	c.parent_window = curses.stdscr

	if WINDOWS then
		curses.PDC_set_resize_limits(20, 20, 500, 500)
		curses.resize_term(50,150)
		curses.fixterm()
	end
	
	c.status_window = curses.derwin(c.parent_window, 1, curses.COLS, 0, 0)
	c.log_window = curses.derwin(c.parent_window, curses.LINES - 2, curses.COLS, 1, 0)
	c.input_window = curses.derwin(c.parent_window, 1, curses.COLS, curses.LINES - 1, 0)
	
	curses.cbreak()
	curses.noecho()
	curses.keypad(c.parent_window, true)

	curses.nodelay(c.input_window, 1)
	curses.keypad(c.input_window, 1)

	curses.attron((2 ^ (8 + 13)) + 8 * 256)
	curses.scrollok(c.log_window, 1)
	
	curses.start_color()
	curses.use_default_colors()

	for i = 1, 8 do
		curses.init_pair(i, i - 1, -1)
	end

	curses.init_pair(COLORPAIR_STATUS, COLOR_RED, COLOR_WHITE + A_DIM * 2 ^ 8)

	-- replace some functions
	
	if WINDOWS then
		ffi.cdef("void PDC_set_title(const char *);")
		
		system.SetWindowTitleRaw = curses.PDC_set_title
		system.SetWindowTitleRaw(system.GetWindowTitle())
	end

	do
		local function split_by_length(str, len)
			if #str > len then
				local tbl = {}
				
				local max = math.floor(#str/len)
				local leftover = #str - (max * len)
				
				for i = 0, max do
					
					local left = i * len
					local right = (i * len) + len
							
					table.insert(tbl, str:usub(left, right))
				end
				
				return tbl
			end
			
			return {str}
		end

		local max_length = 256
		local suppress_print = false

		local function can_print(str)
			if suppress_print then return end
			
			if event then 
				suppress_print = true
				
				if event.Call("ConsolePrint", str) == false then
					suppress_print = false
					return false
				end
				
				suppress_print = false
			end
			
			return true
		end
		
		local bad = "["
		
		for i = 1, 32 do
			if 
				i ~= ("\n"):byte() and
				i ~= ("\t"):byte() and
				i ~= (" "):byte()
			then
				bad = bad .. string.char(i)
			end
		end
		
		bad = bad .. "]"
		
		function io.write(...)
			local str = table.concat({...}, "")
			str = str:gsub("\r", "\\r")

			if not can_print(str) then return end
						
			if str:count("\n") > 1 then
				for line in str:gmatch("(.-\n)") do
					io.write(line)
				end
				return
			end
		
			if WINDOWS and #str > max_length then
				for k,v in pairs(split_by_length(str, max_length)) do
					for line in v:gmatch("(.-)\n") do
						io.write(line)
					end
				end
				return
			end
			
			if not debug.debugging then 
				table.insert(console.history, str)
			end
			
			str = str:gsub("%%", "%%%%")
		

			--curses.wprintw(c.log_window, str)
			console.ColorPrint(str, c.log_window)
			curses.wrefresh(c.log_window)
			if console.Scroll then console.Scroll(0) end
		end
	end

	for _, args in pairs(_G.LOG_BUFFER) do
		io.write(unpack(args))
	end

	_G.LOG_BUFFER = nil
		
	console.curses_init = true
end

do -- colors
	local syntax = include("libraries/syntax.lua")

	function console.ColorPrint(str, window)
		window = window or c.input_window
		local tokens = syntax.process(str)

		for i = 1, #tokens / 2 do
			local color, lexeme = tokens[1 + (i - 1) * 2 + 0], tokens[1 + (i - 1) * 2 + 1]
			local attr = curses.COLOR_PAIR(color + 1)

			if WINDOWS then
				curses.waddstr(window, lexeme)
			else
				curses.wattron(window, attr)
				curses.waddstr(window, lexeme)
				curses.wattroff(window, attr)
			end
		end
	end
	
	function console.Color(i, str)		
		curses.wattron(c.log_window, curses.COLOR_PAIR(i))
		io.write(str)
		curses.wattroff(c.log_window, curses.COLOR_PAIR(i))
	end
end

console.scroll_index = 0 

function console.Scroll(offset)
	if offset == 0 then 
		console.scroll_index = #console.history
	return end
	
	curses.werase(c.log_window)
	
	local lines = curses.LINES-1
	local count = #console.history
	
	console.scroll_index = math.clamp(console.scroll_index - offset, -2, count - lines)
	
	for i = 1, lines  do
		local str = console.history[i + console.scroll_index] or ""
		
		curses.wprintw(c.log_window, str)
	end
	
	curses.wrefresh(c.log_window)
end

function console.ClearInput(str)
	local y, x = gety(), getx()
	
	curses.werase(c.input_window)
	
	if str then
		if WINDOWS then
			curses.waddstr(c.input_window, str)
		else
			console.ColorPrint(str)
		end
		
		curses.wmove(c.input_window, y, x)
	else
		curses.wmove(c.input_window, y, 0)
	end
	
	curses.wrefresh(c.input_window)
end

function console.ClearWindow()
	curses.werase(c.log_window)
	curses.wrefresh(c.log_window)
end

function console.ClearStatus(str)
	curses.werase(c.status_window)
	curses.wattron(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS))
	curses.wbkgdset(c.status_window, COLORPAIR_STATUS)
	curses.waddstr(c.status_window, str)
	curses.wattroff(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS))
	curses.wrefresh(c.status_window)
end

function console.GetActiveKey()
	local byte = curses.wgetch(c.input_window)
	
	if byte < 0 then return end
		
	local key = translate[byte] or ffi.string(curses.keyname(byte))
	if not key:find("KEY_") then key = nil end
	
	return key
end

local markup_translate = {
	["KEY_BACKSPACE"] = "backspace",
	["KEY_TAB"] = "tab",
	["KEY_DC"] = "delete",
	["KEY_HOME"] = "home",
	["KEY_END"] = "end",
	["KEY_TAB"] = "tab",
	["KEY_ENTER"] = "enter",
	["KEY_C"] = "c",
	["KEY_X"] = "x",
	["KEY_V"] = "v",
	["KEY_A"] = "a",
	["KEY_T"] = "t",
	["KEY_UP"] = "up",
	["KEY_DOWN"] = "down",
	
	["KEY_SLEFT"] = "left",
	["KEY_SRIGHT"] = "right",
		
	["CTL_LEFT"] = "left",
	["CTL_RIGHT"] = "right",
	
	["KEY_LEFT"] = "left",
	["KEY_RIGHT"] = "right",
	
	["CTL_DEL"] = "delete",
	["CTL_BACKSPACE"] = "backspace",
	
	["KEY_PAGEUP"] = "page_up",
	["KEY_PAGEDOWN"] = "page_down",
	["KEY_LSHIFT"] = "left_shift",
	["KEY_RSHIFT"] = "right_shift",
	["KEY_RCONTROL"] = "right_control",
	["KEY_LCONTROL"] = "left_control",
}

function console.HandleKey(key)
	if key == "KEY_NPAGE" then
		console.Scroll(-1)
	elseif key == "KEY_PPAGE" then
		console.Scroll(1)
	end
				
	if key == "KEY_UP" then
		c.scroll = c.scroll - 1
		markup:SetText(history[c.scroll%#history+1])
		set_cursor_pos(#markup:GetText())
	elseif key == "KEY_DOWN" then
		c.scroll = c.scroll + 1
		markup:SetText(history[c.scroll%#history+1])
		set_cursor_pos(#markup:GetText())
	end

	-- enter
	if key == "KEY_ENTER" then
		console.ClearInput()
		local line = markup:GetText()
		
		if line ~= "" then			
			for key, str in pairs(history) do
				if str == line then
					table.remove(history, key)
				end
			end
			
			table.insert(history, line)
			serializer.WriteFile("luadata", "%DATA%/cmd_history.txt", history)

			c.scroll = 0
			console.ClearInput()
			
			if event.Call("ConsoleLineEntered", line) ~= false then
				logn("> ", line)
				
				local res, err = console.RunString(line)

				if not res then
					logn(err)
				end
			end
			
			c.current_table = _G
			c.in_function = false
			markup:SetText("")
		end
	end
				
	if markup_translate[key] then
		markup:OnKeyInput(markup_translate[key])
	end
end

function console.HandleChar(char)
	console.InsertChar(char)
end
