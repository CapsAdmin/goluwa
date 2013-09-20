console = _G.console or {}

local parent_window
local log_window
local line_window

local line = ""
local history = luadata.ReadFile("%DATA%/cmd_history.txt")
local scroll = 0

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

-- some helpers

local function gety()
	return curses.getcury(line_window)
end

local function getx()	
	return curses.getcurx(line_window)
end

local function move_cursor(x)
	curses.wmove(line_window, gety(), math.min(getx() + x, #line))
	curses.wrefresh(line_window)
end

local function set_cursor_pos(x)
	curses.wmove(line_window, 0, math.max(x, 0))
	curses.wrefresh(line_window)
end

function console.InsertChar(char)
	if #line == 0 then
		line = line .. char
	elseif subpos == #line then
		line = line .. char
	else
		line = line:sub(1, getx()) .. char .. line:sub(getx() + 1)
	end

	console.ClearInput(line)

	move_cursor(1)
end

function console.GetCurrentLine()
	return line
end

function console.InitializeCurses()
	if console.curses_init then return end
	
	curses.freeconsole()

	parent_window = curses.initscr()

	if WINDOWS then
		curses.resize_term(25,130)
	end

	if MORTEN then
		curses.start_color()
		
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
	end	

	log_window = curses.derwin(parent_window, curses.LINES, curses.COLS, 0, 0)
	line_window = curses.derwin(parent_window, 1, curses.COLS, curses.LINES - 1, 0)
				
	curses.cbreak()
	curses.noecho()

	curses.nodelay(line_window, 1)
	curses.keypad(line_window, 1)

	curses.scrollok(log_window, 1)

	curses.attron((2 ^ (8 + 13)) + 8 * 256)
	curses.mvprintw(curses.LINES - 2, 0, string.rep("-", curses.COLS))
		
	-- replace some functions
	
	if WINDOWS then
		ffi.cdef("void PDC_set_title(const char *);")
		
		system.SetWindowTitleRaw = curses.PDC_set_title
		system.SetWindowTitleRaw(system.GetWindowTitle())
	end

	function io.write(...)
		local str = table.concat({...}, "")
			
		curses.wprintw(log_window, str)
		curses.wrefresh(log_window)
	end

	for _, args in pairs(_G.LOG_BUFFER) do
		io.write(unpack(args))
	end

	_G.LOG_BUFFER = nil
		
	console.curses_init = true
end

console.InitializeCurses()

do -- colors

	local COLOR_PAIR
	
	if LINUX then
		COLOR_PAIR = function(x)
			return bit.lshift(x, 8)
		end
	end
	
	if WINDOWS then
		COLOR_PAIR = function(x)
			return bit.lshift(x, 24)
		end
	end

	local syntax = include("syntax.lua")

	function console.ColorPrint(str)
		local tokens = syntax.process(str)

		for i = 1, #tokens / 2 do
			local color, lexeme = tokens[1 + (i - 1) * 2 + 0], tokens[1 + (i - 1) * 2 + 1]
			local attr = COLOR_PAIR(color + 1)

			curses.wattron(line_window, attr)
			curses.waddstr(line_window, lexeme)
			curses.wattroff(line_window, attr)
		end
	end
end


function console.ClearInput(str)
	local y, x = gety(), getx()
	
	curses.wclear(line_window)
	
	if str then
		if MORTEN then
			console.ColorPrint(str)
		else
			curses.waddstr(line_window, str)
		end
		
		curses.wmove(line_window, y, x)
	else
		curses.wmove(line_window, y, 0)
	end
	
	curses.wrefresh(line_window)
end

function console.ClearWindow()
	curses.wclear(log_window)
	curses.wrefresh(log_window)
end


function console.GetActiveKey()
	local byte = curses.wgetch(line_window)
	
	if byte < 0 then return end
		
	local key = translate[byte] or ffi.string(curses.keyname(byte))
	if not key:find("KEY_") then key = nil end
	
	return key
end

function console.HandleKey(key)
	--[[if key == "KEY_NPAGE" then
		curses.wscrl(parent_window, -5)
	elseif key == "KEY_PPAGE" then
		curses.wscrl(parent_window, 5)
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
		console.InsertChar(" ")
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
			console.ClearInput()
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
		console.ClearInput()

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
			luadata.WriteFile("%DATA%/cmd_history.txt", history)

			scroll = 0
			current_table = _G
			in_function = false
			line = ""
			console.ClearInput()
		end
	end

	console.ClearInput(line)
end

function console.HandleChar(char)
	console.InsertChar(char)
end

event.AddListener("OnUpdate", "curses", function()
	local byte = curses.wgetch(line_window)

	if byte < 0 then return end
		
	local key = translate[byte] or ffi.string(curses.keyname(byte))
	if not key:find("KEY_") then key = nil end
			
	if key then					
		key = ffi.string(key)
			
		if event.Call("OnConsoleKeyPressed", key) == false then return end
		
		console.HandleKey(key)
	elseif byte < 256 then
		local char = string.char(byte)
		
		if event.Call("OnConsoleCharPressed", char) == false then return end
		
		console.HandleChar(char)
	end
end)

do -- input extensions
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