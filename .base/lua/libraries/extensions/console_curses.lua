local curses = require("ffi.curses")

console.history = console.history or {}
console.curses = console.curses or {}
local c = console.curses

if SERVER or not surface then
	-- the renderer might fail to load :( !
	local hack = false
	
	if not SERVER then
		SERVER = true
		hack = true
	end
	
	_G.surface = {}
	include("lua/libraries/graphics/surface/markup/markup.lua")	
	
	if hack then
		SERVER = nil
	end
end

local markup = surface.CreateMarkup()
markup:SetMultiline(false)
markup:SetFixedSize(14)

local history = serializer.ReadFile("luadata", "%DATA%/cmd_history.txt") or {}
local dirty = false
local hush

local USE_COLORS = (os.getenv("USE_COLORS") or "1") == "1"

local COLORPAIR_STATUS = 9

local char_translate = 
{
	[10] = "KEY_ENTER",
	[13] = "KEY_ENTER",
	[459] = "KEY_ENTER",
	[8] = "KEY_BACKSPACE",
	[127] = "CTL_BACKSPACE",
	[9] = "KEY_TAB",
	
	[25] = "KEY_UNDO",
	[26] = "KEY_UNDO",
	
	[3] = "KEY_COPY",
	
	["\27[1;5D"] = "CTL_LEFT",
	["\27[1;5C"] = "CTL_RIGHT",

	["\27\79\72"] = "KEY_HOME",
	["\27\79\70"] = "KEY_END",
	["\27\91\51\59\53\126"] = "CTL_DEL",

	KEY_SELECT = "KEY_HOME",
	KEY_FIND = "KEY_END",
	
	PADENTER = "KEY_ENTER",
}

local markup_translate = {
	KEY_BACKSPACE = "backspace",
	KEY_TAB = "tab",
	KEY_DC = "delete",
	KEY_HOME = "home",
	KEY_END = "end",
	KEY_ENTER = "enter",
	KEY_C = "c",
	KEY_X = "x",
	KEY_V = "v",
	KEY_A = "a",
	KEY_T = "t",
	KEY_UP = "up",
	KEY_DOWN = "down",
	
	KEY_SLEFT = "left",
	KEY_SRIGHT = "right",
		
	CTL_LEFT = "left",
	CTL_RIGHT = "right",
	
	KEY_LEFT = "left",
	KEY_RIGHT = "right",
	
	CTL_DEL = "delete",
	CTL_BACKSPACE = "backspace",
	
	KEY_PAGEUP = "page_up",
	KEY_PAGEDOWN = "page_down",
	KEY_LSHIFT = "left_shift",
	KEY_RSHIFT = "right_shift",
	KEY_RCONTROL = "right_control",
	KEY_LCONTROL = "left_control",
}

function console.InitializeCurses()
	local last_w = curses.COLS
	local last_h = curses.LINES

	event.CreateTimer("curses", 1/30, 0, function()
		local key = {}
		
		for i = 1, math.huge do
			local byte = curses.wgetch(c.input_window)
			
			if byte > 0 and byte < 255 then
				key[i] = utf8.char(byte)
			else
				if byte > 255 then
					key = ffi.string(curses.keyname(byte))
				else
					key = table.concat(key)
				end
				break
			end
		end
		
		if #key > 0 then
		
			-- super hacks
			for chars, key2 in pairs(char_translate) do
				if type(chars) == "string" then
					if key:sub(1, #chars) == chars then
						key = chars
					end
				end
			end

			key = char_translate[key] or char_translate[key:byte()] or key

			markup:SetControlDown(key:find("CTL_") ~= nil)
			markup:SetShiftDown(key:find("KEY_S") ~= nil)
		
			if (key:find("KEY_") or key:find("CTL_") or key:find("PAD")) and event.Call("ConsoleKeyInput", key) ~= false then									
				console.HandleKey(key)		
			elseif event.Call("ConsoleCharInput", key) ~= false then
				if key:byte(1) >= 32 then
					console.HandleChar(key)
				end
			end
			
			curses.wmove(c.input_window, 0, math.max(markup:GetCaretSubPosition()-1, 0))
			console.ClearInput(markup:GetText())
		end
		
		if last_w ~= curses.COLS or last_h ~= curses.LINES then
			console.Resize(curses.COLS, curses.LINES)
			last_w = curses.COLS
			last_h = curses.LINES
		end
		
		if dirty then
			curses.doupdate()
			dirty = false
		end
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
	
	if console.curses_init then	return end
	
	local pdcurses_for_real_windows = pcall(function() return curses.PDC_set_resize_limits end)
	
	if pdcurses_for_real_windows then
		curses.freeconsole()
	end

	c.parent_window = curses.initscr()
	
	if WINDOWS and pdcurses_for_real_windows then
		curses.resize_term(50, 150) 
	end

	curses.cbreak()
	curses.noecho()
	curses.raw()
	curses.noqiflush()
	
	c.log_window = curses.newwin(curses.LINES, curses.COLS, 0, 0)
	c.input_window = curses.newwin(1, curses.COLS, curses.LINES - 1, 0)
	
	curses.keypad(c.input_window, 1)
	curses.scrollok(c.log_window, 1)
	
	curses.halfdelay(0)
		
	curses.nodelay(c.status_window, 1)
	curses.nodelay(c.log_window, 1)
	curses.nodelay(c.input_window, 1)
	
	curses.notimeout(c.status_window, 1)
	curses.notimeout(c.log_window, 1)
	curses.notimeout(c.input_window, 1)
	
	if USE_COLORS then			
		curses.start_color()
		curses.use_default_colors()
	
		--[[if CAPS then
			for i = 1, 256 do
				local r = bit.rshift(i, 5)
				local g = bit.band(bit.rshift(i, 2), 8)
				local b = bit.band(i, 8)
				
				curses.init_color(i-1, r, g, b)
				curses.init_pair(i, i - 1, -1)
			end
		else]]
			for i = 1, 8 do
				curses.init_pair(i, i - 1, -1)
			end
		--end

		curses.init_pair(COLORPAIR_STATUS, curses.COLOR_RED, curses.COLOR_WHITE + curses.A_DIM * 2 ^ 8)
	end

	-- replace some functions
	
	if WINDOWS then
		ffi.cdef("void PDC_set_title(const char *);")
		
		console.SetTitleRaw = curses.PDC_set_title
		console.SetTitleRaw(console.GetTitle())
	else
		c.status_window = curses.newwin(8, 24, 0, curses.COLS - 24)
		curses.nodelay(c.status_window, 1)

		console.SetTitleRaw = console.ClearStatus
	end
	
	console.Resize(curses.COLS, curses.LINES)
		
	function io.write(...)
		local str = table.concat({...}, "")

		console.Print(str)
	end	
		
	local function override(file, prefix)
		local meta = getmetatable(file)
		if not meta then return file end
		local copy = {}
		for k, v in pairs(meta) do 
			if k == "write" then
				copy[k] = function(_, ...) 
					io.write(...)
					return v(file, prefix, ...)
				end 
			else
				copy[k] = function(_, ...) 
					return v(file, ...)
				end 
			end
		end
		copy.__index = copy
		return setmetatable({}, copy)
	end
	
	io.stderr = override(io.stderr, "io.stderr: ")
	io.stdout = override(io.stdout, "io.stdout: ")

	for _, line in ipairs(_G.LOG_BUFFER) do
		hush = true
		console.Print(line)
		hush = false
	end

	_G.LOG_BUFFER = nil
		
	console.curses_init = true
end

do
	local suppress_print = false

	function console.CanPrint(str)
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
end

function console.Print(str)
	if not console.CanPrint(str) then return end

	if not hush then
		_OLD_G.io.write(str)
	end
	
	str = str:gsub("\r", "\n")
	
	if str:count("\n") > 1 then
		for k,v in pairs(str:explode("\n")) do
			console.Print(v .. "\n")
		end
		
		return
	end
		
	if curses.COLS > 0 then
		local lines = str:lengthsplit(curses.COLS)
		if #lines > 2 then		
			for i, v in ipairs(lines) do
				console.Print(v)
			end
			return
		end
	end 

	if not debug.debugging then 
		table.insert(console.history, str)
	end
		
	console.SyntaxPrint(str, c.log_window)
	
	console.ScrollLogHistory(console.scroll_offset)
	
	if console.status_window then
		console.ClearStatus(console.last_status)
	end
end

function console.Clear()
	table.clear(console.history)
	curses.wclear(c.log_window)
	console.ScrollLogHistory(0)
	event.Call("ConsoleClear")
end

function console.Resize(w, h)
	curses.wresize(c.log_window, h - 1, w)
	curses.mvderwin(c.log_window, 0, 0)
	
	curses.wresize(c.input_window, 1, w)
	curses.mvderwin(c.input_window, h - 1, 0)
	
	curses.wresize(c.status_window, h / 3, w / 3 * 2)
	curses.mvderwin(c.status_window, 0, w - w / 3)

	console.ScrollLogHistory(0)
end

function console.ShutdownCurses()
	if console.curses_init then
		curses.endwin()	

		event.RemoveTimer("curses")
		event.RemoveListener("ConsoleKeyInput", "input")
		event.RemoveListener("ConsoleCharInput", "input")
		console.curses_init = nil
	end
end


local function get_color(r, g, b)
	r = ffi.cast("chtype", r)
	g = ffi.cast("chtype", g)
	b = ffi.cast("chtype", b)
	return curses.COLOR_PAIR(16ULL + r / 48ULL * 36ULL + g / 48ULL * 6ULL + b / 48ULL)
end


function console.ColorPrint(str, i, window)
	window = window or c.log_window

	local attr = curses.COLOR_PAIR(i)
	if USE_COLORS then curses.wattron(window, attr) end
	curses.waddstr(window, str)
	if USE_COLORS then curses.wattroff(window, attr) end
	
	curses.wnoutrefresh(window)
	dirty = true
end

do
	local syntax = _G.syntax or {}

	syntax.DEFAULT    = 1
	syntax.KEYWORD    = 2
	syntax.IDENTIFIER = 3
	syntax.STRING     = 4
	syntax.NUMBER     = 5
	syntax.OPERATOR   = 6

	syntax.patterns = {
		[2]  = "[%a_][%w_]*",
		[1]  = "\".-\"",
		[4]  = "0x[a-fA-F0-9]+",
		[5]  = "[%d]+%.?%d*e?%d*",
		[6]  = "[%+%-%*/%%%(%)%.,<>=:;{}%[%]]",
		[7]  = "//[^\n]*",
		[8]  = "/%*.-%*/",
		[9]  = "%-%-[^%[][^\n]*",
		[10] = "%-%-%[%[.-%]%]",
		[11] = "%[=-%[.-%]=-%]",
		[12] = "'.-'"
	}

	local COLOR_DEFAULT = -1

	syntax.colors = {
		curses.COLOR_RED,  --ColorBytes(255, 255, 255),
		curses.COLOR_CYAN, --ColorBytes(127, 159, 191),
		COLOR_DEFAULT, --ColorBytes(223, 223, 223),
		curses.COLOR_GREEN, --ColorBytes(191, 127, 127),
		curses.COLOR_GREEN, --ColorBytes(127, 191, 127),
		curses.COLOR_YELLOW, --ColorBytes(191, 191, 159),
		COLOR_DEFAULT, --ColorBytes(159, 159, 159),
		COLOR_DEFAULT, --ColorBytes(159, 159, 159),
		COLOR_DEFAULT, --ColorBytes(159, 159, 159),
		COLOR_DEFAULT, --ColorBytes(159, 159, 159),
		curses.COLOR_YELLOW, --ColorBytes(191, 159, 127),
		curses.COLOR_RED, --ColorBytes(191, 127, 127),
	}

	syntax.keywords = {
		["local"]    = true,
		["function"] = true,
		["return"]   = true,
		["break"]    = true,
		["continue"] = true,
		["end"]      = true,
		["if"]       = true,
		["not"]      = true,
		["while"]    = true,
		["for"]      = true,
		["repeat"]   = true,
		["until"]    = true,
		["do"]       = true,
		["then"]     = true,
		["true"]     = true,
		["false"]    = true,
		["nil"]      = true,
		["in"]       = true
	}

	function syntax.process(code)
	--	profiler.StartTimer("console syntax parse")
		local output, finds, types, a, b, c = {}, {}, {}, 0, 0, 0

		finds[1] = 0

		while b < #code do
			local temp = {}

			for k, v in pairs(syntax.patterns) do
				local aa, bb = code:find(v, b + 1)
				if aa then temp[#temp+1] = {k, aa, bb} end
			end

			if #temp == 0 then
				temp[#temp+1] = {1, b + 1, #code}
			end

			table.sort(temp, function(a, b) return (a[2] == b[2]) and (a[3] > b[3]) or (a[2] < b[2]) end)
			c, a, b = unpack(temp[1])

			finds[#finds+1] = a
			finds[#finds+1] = b

			types[#types+1] = c == 2 and (syntax.keywords[code:sub(a, b)] and 2 or 3) or c
		end

		finds[#finds + 1] = #code + 1

		for i = 1, #finds - 1 do
			local asdf = i % 2
			local sub = code:sub(finds[i + 0] + asdf, finds[i + 1] - asdf)

			output[#output+1] = asdf == 0 and syntax.colors[types[1 + (i - 2) / 2]] or -1
			output[#output+1] = sub
		end
		--profiler.StopTimer()
		
		return output
	end

	console.syntax = syntax
	function console.SyntaxPrint(str, window)
		window = window or c.log_window
		
		if USE_COLORS then
			local tokens = syntax.process(str)

			for i = 1, #tokens / 2 do
				local color, str = tokens[1 + (i - 1) * 2 + 0], tokens[1 + (i - 1) * 2 + 1]
				console.ColorPrint(str, color + 1, window)
			end
		else
			curses.waddstr(window, str)
		end
		
		curses.wnoutrefresh(window)
		dirty = true
	end
end

console.scroll_log_history = 0
console.scroll_offset = 0

function console.ScrollLogHistory(offset, skip_refresh)

	console.scroll_offset = math.max(offset, 0)
	
	if offset == 0 then
		console.scroll_log_history = #console.history
		offset = 1
		skip_refresh = true
	end
	
	curses.werase(c.log_window)

	local lines = curses.LINES-1
	local count = #console.history
	
	console.scroll_log_history = math.clamp(console.scroll_log_history - offset, 0, count - lines)
	
	for i = 1, lines  do
		local str = console.history[i + console.scroll_log_history] or ""
		
		console.SyntaxPrint(str)
	end
end

function console.GetCurrentText(offset)
	offset = offset or 0
	local out = {}
	local lines = curses.LINES-1
	local count = #console.history
	
	console.scroll_log_history = math.clamp(console.scroll_log_history - offset, 0, count - lines)
	
	for i = 1, lines  do
		local str = console.history[i + console.scroll_log_history] or ""
		
		out[i] = str
	end
	
	return table.concat(out, "")
end

function console.GetCurrentLine()
	return markup:GetText()
end

function console.GetActiveKey()
	local byte = curses.wgetch(c.input_window)
	
	if byte < 0 then return end
		
	local key = char_translate[byte] or ffi.string(curses.keyname(byte))
	if not key:find("KEY_") then key = nil end
	
	return key
end

function console.ClearInput(str)
	local y, x = curses.getcury(c.input_window), curses.getcurx(c.input_window)
	
	curses.werase(c.input_window)
	
	if str then
		console.SyntaxPrint(str, c.input_window)
	else
		x = 0
	end
	
	curses.wmove(c.input_window, y, x)	
	curses.wnoutrefresh(c.input_window)
	dirty = true
end

function console.ClearWindow()
	curses.werase(c.log_window)
end

console.last_status = ""

function console.ClearStatus(str)
	curses.werase(c.status_window)
	
	if USE_COLORS then 
		curses.wattron(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS))
		curses.wbkgdset(c.status_window, COLORPAIR_STATUS) 
	end
	
	curses.waddstr(c.status_window, (str:gsub("|", "\n")))
	
	if USE_COLORS then 
		curses.wattroff(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS)) 
	end
	
	curses.wnoutrefresh(c.status_window)
	dirty = true
	console.last_status = str
end

local function get_commands_for_autocomplete()
	local cmds = {}
	for k,v in pairs(console.GetCommands()) do 
		table.insert(cmds, k) 
	end
	return cmds
end

c.scroll_command_history = c.scroll_command_history or 0

function console.HandleKey(key)

	if key == "KEY_TAB" then
		local line = console.GetCurrentLine()
		local cmd, rest = line:match("(%S+)%s+(.+)")
		
		if not cmd then cmd = line:match("(%S+)") end
		
		if cmd and not rest then
			
			local found = autocomplete.Query("console", cmd, 1, get_commands_for_autocomplete())

			if found and found[1] then
				markup:SetText(found[1] .. " ")
				markup:SetCaretPosition(math.huge, 0)
			end
			return
		end
		
		if cmd and rest then
			local info = console.GetCommands()[cmd]
			if info and info.autocomplete then
				local data = console.ParseCommandArgs(line)
				local list = info.autocomplete(data.args[#data.args], data.args)
				if list then
					local found = autocomplete.Query("console_command_" .. cmd, data.args[#data.args], 1, list)
					if found then
						table.remove(data.args)
						
						if #data.args > 0 then
							found = "," .. found
						end
						
						markup:SetText(cmd .. " " .. table.concat(data.args, ",") .. found)
						markup:SetCaretPosition(math.huge, 0)
					end
				end
			end
		end	
	else
		autocomplete.Query("console", console.GetCurrentLine())
	end

	if key == "KEY_NPAGE" then
		console.ScrollLogHistory(-curses.LINES / 2)
	elseif key == "KEY_PPAGE" then
		console.ScrollLogHistory(curses.LINES / 2)
	end
				
	if key == "KEY_UP" then
		c.scroll_command_history = c.scroll_command_history - 1
		markup:SetText(history[c.scroll_command_history%#history+1])
		curses.wmove(c.input_window, 0, #markup:GetText())
	elseif key == "KEY_DOWN" then
		c.scroll_command_history = c.scroll_command_history + 1
		markup:SetText(history[c.scroll_command_history%#history+1])
		curses.wmove(c.input_window, 0, #markup:GetText())
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

			c.scroll_command_history = 0
			console.ClearInput()
			
			if event.Call("ConsoleLineEntered", line) ~= false then
				logn("> ", line)
				
				console.RunString(line, nil, nil, true)
			end
			
			c.in_function = false
			markup:SetText("")
		end
	end

	if markup_translate[key] then
		markup:OnKeyInput(markup_translate[key])
	end
end

function console.HandleChar(char)
	markup:OnCharInput(char)
end

if RELOAD then
	console.InitializeCurses()
	
	--console.Print(vfs.Read([[C:\goluwa\.base\lua\libraries\extensions\console_curses.lua]]))  
	--event.CreateTimer("lol", 1, 0, print)
end
