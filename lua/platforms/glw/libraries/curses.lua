ffi.cdef[[		
	typedef struct {} WINDOW;
	
	WINDOW *initscr();
	void timeout(int delay);
	int wtimeout(WINDOW *win, int delay);
	void halfdelay(int delay);
	void cbreak();
	void nocbreak();
	void noecho();
	int getch();
	int wgetch(WINDOW *win);

	int idlok(WINDOW *win, bool bf);
	int leaveok(WINDOW *win, bool bf);
	int keypad(WINDOW *win, bool bf);
	int scrollok(WINDOW *win, bool bf);

	int nodelay(WINDOW *win, bool b);
	int notimeout(WINDOW *win, bool b);
	WINDOW *derwin(WINDOW*, int nlines, int ncols, int begin_y, int begin_x);
	int wrefresh(WINDOW *win);
	int refresh();
	int box(WINDOW *win, int, int);
	int werase(WINDOW *win);
	int wclear(WINDOW *win);
	int hline(const char *, int);
	int COLS;
	int LINES;
	const char *killchar();
	void keypad(WINDOW*, bool);
	const char *keyname(int c);
	int waddstr(WINDOW *win, const char *chstr);
	int wmove(WINDOW *win, int y, int x);
	int resize_term(int y, int x);
	int setscrreg(int top, int bot);
	
	int getcury(WINDOW *win);
	int getcurx(WINDOW *win);

	WINDOW* stdscr;
	int printw(const char* format, ...);
	int wprintw(WINDOW*, const char* format, ...);
	int mvprintw(int y, int x, const char* format, ...);
	int wscrl(WINDOW*, int);
	int start_color();
	bool has_colors();
	bool can_change_color();
	int attron(int);
	int attroff(int);
	int wattron(WINDOW*, int);
	int wattroff(WINDOW*, int);
	int init_pair(int, int, int);
	int use_default_colors();
]]

if _E.CURSES_INIT then return end

local function COLOR_PAIR(x)
	return bit.lshift(x, 32)
end

local lib

if LINUX then
	lib = "ncursesw"
end

if WINDOWS then
	lib = "pdcurses"
	
	ffi.cdef("int FreeConsole();")
	ffi.C.FreeConsole()
end

local curses = ffi.load(lib)
local parent = curses.initscr()
curses.start_color()

if WINDOWS then
	curses.resize_term(25,130)
end

local log_window = curses.derwin(parent, curses.LINES, curses.COLS, 0, 0)
local line_window = curses.derwin(parent, 1, curses.COLS, curses.LINES - 1, 0)
local function gety()
	return curses.getcury(line_window)
end

local function getx()	
	return curses.getcurx(line_window)
end

local COLOR_BLACK = 0
local COLOR_RED = 1
local COLOR_GREEN = 2
local COLOR_YELLOW = 3
local COLOR_BLUE = 4
local COLOR_MAGENTA = 5
local COLOR_CYAN = 6
local COLOR_WHITE = 7

for i = 1, 8 do
	curses.init_pair(i, i - 1, COLOR_BLACK)
end

curses.cbreak()
curses.noecho()

curses.nodelay(line_window, 1)
curses.keypad(line_window, 1)

curses.scrollok(log_window, 1)

curses.attron((2 ^ (8 + 13)) + 8 * 256)
curses.mvprintw(curses.LINES - 2, 0, string.rep("-", curses.COLS))

if WINDOWS then
	ffi.cdef("void PDC_set_title(const char *);")
	
	system.SetWindowTitleRaw = curses.PDC_set_title
	system.SetWindowTitleRaw(system.GetWindowTitle())
end

local function split_by_length(str, len)
	if #str > len then
		local tbl = {}
		
		local max = math.floor(#str/len)
		local leftover = #str - (max * len)
		
		for i = 0, max do
			
			local left = i * len
			local right = (i * len) + len
					
			table.insert(tbl, str:sub(left, right))
		end
		
		return tbl
	end
	
	return {str}
end

local max_length = 256

function io.write(...)
	local str = table.concat({...}, "")
		
	curses.wprintw(log_window, str)
	curses.wrefresh(log_window)
end

for _, args in pairs(_G.LOG_BUFFER) do
	io.write(unpack(args))
end

_G.LOG_BUFFER = nil

local syntax

if MORTEN then 
	syntax = include("syntax.lua")
end

_E.CURSES_INIT = true

local function get_char()
	return curses.wgetch(line_window)
end

local function clear(str)
	local y, x = gety(), getx()
	
	curses.wclear(line_window)
	
	if str then
	
		if syntax then
			local tokens = syntax.process(str)

			for i = 1, #tokens / 2 do
				local color, lexeme = tokens[1 + (i - 1) * 2 + 0], tokens[1 + (i - 1) * 2 + 1]
				local attr = COLOR_PAIR(color + 1)
				
				print("color pair = ", attr)
				
				curses.wattron(line_window, attr)
				curses.waddstr(line_window, lexeme)
				curses.wattroff(line_window, attr)
			end
		end

		curses.waddstr(line_window, str)
		curses.wmove(line_window, y, x)
	else
		curses.wmove(line_window, y, 0)
	end
	
	curses.wrefresh(line_window)
end

local function get_key_name(num)
	return curses.keyname(num)
end

local function load_history()
	return luadata.ReadFile("%DATA%/cmd_history.txt")
end

local function save_history(tbl)
	return luadata.WriteFile("%DATA%/cmd_history.txt", tbl)
end

local line = ""
local history = load_history()
local scroll = 0

local function move_cursor(x)
	curses.wmove(line_window, gety(), math.min(getx() + x, #line))
	curses.wrefresh(line_window)
end

local function set_cursor_pos(x)
	curses.wmove(line_window, 0, math.max(x, 0))
	curses.wrefresh(line_window)
end

local function insert_char(char)
	if #line == 0 then
		line = line .. char
	elseif subpos == #line then
		line = line .. char
	else
		line = line:sub(1, getx()) .. char .. line:sub(getx() + 1)
	end

	clear(line)

	move_cursor(1)
end

local current_table = _G
local table_scroll = 0
local in_function

local translate = 
{
	[32] = "KEY_SPACE",
	[9] = "KEY_TAB",
	[10] = "KEY_ENTER",
	[459] = "KEY_ENTER",
	[8] = "KEY_BACKSPACE",
	[127] = "KEY_BACKSPACE",
	
	-- this is bad, fix me!!!
	[443] = "KEY_CTRL_LEFT",
	[444] = "KEY_CTRL_RIGHT",
	[527] = "KEY_CTRL_DELETE",
	[127] = "KEY_CTRL_BACKSPACE",
}

event.AddListener("OnUpdate", "curses", function()
	local byte = get_char()
	
	if byte < 0 then return end
		
	local key = translate[byte] or ffi.string(get_key_name(byte))
	if not key:find("KEY_") then key = nil end
			
	if key then					
		key = ffi.string(key)
			
		if event.Call("OnConsoleKeyPressed", key) == false then return end
		
		--[[if key == "KEY_NPAGE" then
			curses.wscrl(parent, -5)
		elseif key == "KEY_PPAGE" then
			curses.wscrl(parent, 5)
		end]]
		
		if key == "KEY_UP" then
			scroll = scroll - 1
			line = history[scroll%#history+1] or line
			set_cursor_pos(#line)
		elseif key == "KEY_DOWN" then
			scroll = scroll + 1
			line = history[scroll%#history+1] or line
			set_cursor_pos(#line)
		end

		if key == "KEY_LEFT" then
			 move_cursor(-1)
		elseif key == "KEY_CTRL_LEFT" then
			set_cursor_pos((select(2, line:sub(1, getx()+1):find(".+[^%p%s]")) or 1) - 2)
		elseif key == "KEY_RIGHT" then
			 move_cursor(1)
		elseif key == "KEY_CTRL_RIGHT" then
			local pos = (select(2, line:find("[%s%p].-[^%p%s]", getx()+1)) or 1) - 1
			if pos < getx() then
				pos = #line
			end
			set_cursor_pos(pos)
		end

		if key == "KEY_HOME" then
			set_cursor_pos(0)
		elseif key == "KEY_END" then
			set_cursor_pos(#line)
		end

		-- space
		if key == "KEY_SPACE" then
			insert_char(" ")
		end

		-- tab
		if key == "KEY_TAB" then
			local start, stop, last_word = line:find("([_%a%d]-)$")
			if last_word then
				local pattern = "^" .. last_word
								
				if (not line:find("%(") or not line:find("%)")) and not line:find("logn") then
					in_function = false
				end
								
				if not in_function then
					current_table = line:explode(".")
											
					local tbl = _G
					
					for k,v in pairs(current_table) do
						if type(tbl[v]) == "table" then
							tbl = tbl[v]
						else
							break
						end
					end
					
					current_table = tbl or _G						
				end
				
				if in_function then
					local start = line:match("(.+%.)")
					if start then
						local tbl = {}
						
						for k,v in pairs(current_table) do
							table.insert(tbl, {k=k,v=v})
						end
						
						if #tbl > 0 then
							table.sort(tbl, function(a, b) return a.k > b.k end)
							table_scroll = table_scroll + 1
							
							local data = tbl[table_scroll%#tbl + 1]
							
							if type(data.v) == "function" then
								line = start .. data.k .. "()"
								set_cursor_pos(#line)
								move_cursor(-1)
								in_function = true
							else
								line = "logn(" .. start .. data.k .. ")"
								set_cursor_pos(#line)
								move_cursor(-1)
							end
						end
					end
				else						
					for k,v in pairs(current_table) do
						k = tostring(k)
						
						if k:find(pattern) then
							line = line:sub(0, start-1) .. k
							if type(v) == "table" then 
								current_table = v 
								line = line .. "."
								set_cursor_pos(#line)
							elseif type(v) == "function" then
								line = line .. "()"
								set_cursor_pos(#line)
								move_cursor(-1)
								in_function = true
							else
								line = "logn(" .. line .. ")"
							end
							break
						end
					end
				end
			end
		end

		-- backspace
		if key == "KEY_BACKSPACE" or (key == "KEY_CTRL_BACKSPACE" and jit.os == "Linux") then
			if getx() > 0 then
				local char = line:sub(1, getx())
				
				if char == "." then
					current_table = previous_table
				end
				
				line = line:sub(1, getx() - 1) .. line:sub(getx() + 1)
				move_cursor(-1)
			else
				clear()
			end
		elseif key == "KEY_CTRL_BACKSPACE" then
			local pos = (select(2, line:sub(1, getx()):find(".*[%s%p].-[^%p%s]")) or 1) - 1
			line = line:sub(1, pos) .. line:sub(getx() + 1)
			set_cursor_pos(pos - 1)
		elseif key == "KEY_DC" then
			line = line:sub(1, getx()) .. line:sub(getx() + 2)			
		elseif key == "KEY_CTRL_DELETE" then
			local pos = (select(2, line:find("[%s%p].-[^%p%s]", getx()+1)) or #line + 1) - 1
			line = line:sub(1, getx()) .. line:sub(pos + 1)
		end
			
		-- enter
		if key == "KEY_ENTER" then
			clear()

			if line ~= "" then
				if event.Call("OnLineEntered", line) ~= false then
					logn("> ", line)
					
					local res, err = console.RunString(line)

					if not res then
						logn(err)
					end
				end
				
				for key, str in pairs(history) do
					if str == line then
						table.remove(history, key)
					end
				end
				
				table.insert(history, line)
				save_history(history)

				scroll = 0
				current_table = _G
				in_function = false
				line = ""
				clear()
			end
		end

		clear(line)
	elseif byte < 256 then
		local char = string.char(byte)
		
		if event.Call("OnConsoleCharPressed", char) == false then return end
		
		insert_char(char)
	end
end)

do -- curses keys
	local trigger = input.SetupInputEvent("ConsoleKey")

	event.AddListener("OnConsoleKeyPressed", "input", function(key)
		local ret = trigger(key, true)
		
		-- :(
		timer.Simple(0, function() trigger(key, false) end)
		
		return ret
	end)

	local trigger = input.SetupInputEvent("ConsoleChar")

	event.AddListener("OnConsoleCharPressed", "input", function(char)
		local ret = trigger(char, true)
		
		-- :(
		timer.Simple(0, function() trigger(char, false) end)
		
		return ret
	end)
end

_G.curses = {
	GetActiveKey = function()
		local byte = get_char()
		
		if byte < 0 then return end
			
		local key = translate[byte] or ffi.string(get_key_name(byte))
		if not key:find("KEY_") then key = nil end
		
		return key
	end,
	
	Clear = function()
		curses.wclear(log_window)
		curses.wrefresh(log_window)
	end,
	
	ColorPrint = function(str)
		if syntax then
			local tokens = syntax.process(str)

			for i = 1, #tokens / 2 do
				local color, lexeme = tokens[1 + (i - 1) * 2 + 0], tokens[1 + (i - 1) * 2 + 1]
				local attr = COLOR_PAIR(color + 1)

				curses.wattron(log_window, attr)
				curses.waddstr(log_window, lexeme)
				curses.wattroff(log_window, attr)
			end
		end
	end
}

