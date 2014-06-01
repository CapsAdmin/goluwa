local curses = require("lj-curses")

console.history = console.history or {}
console.curses = console.curses or {}
local c = console.curses

local markup = Markup()
markup:SetMultiline(false)
markup:SetFixedSize(14)

local history = serializer.ReadFile("luadata", "%DATA%/cmd_history.txt")

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
			key = char_translate[key] or char_translate[key:byte()] or key

			markup:SetControlDown(key:find("CTL_") ~= nil)
			markup:SetShiftDown(key:find("KEY_S") ~= nil)
		
			if (key:find("KEY_") or key:find("CTL_") or key:find("PAD")) and event.Call("ConsoleKeyInput", key) ~= false then									
				console.HandleKey(key)		
			elseif event.Call("ConsoleCharInput", key) ~= false then
				console.HandleChar(key)
			end
			
			curses.wmove(c.input_window, 0, math.max(markup:GetCaretSubPos()-1, 0))
			console.ClearInput(markup:GetText())
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

	curses.freeconsole()

	c.parent_window = curses.initscr()
	
	if WINDOWS then
		curses.PDC_set_resize_limits(1, 1000, 1, 1000)
		curses.resize_term(50,150) 
	end

	curses.cbreak()
	curses.noecho()
	curses.raw()
	
	c.log_window = curses.derwin(c.parent_window, curses.LINES - 2, curses.COLS, 1, 0)
	c.input_window = curses.derwin(c.parent_window, 1, curses.COLS, curses.LINES - 1, 0)
	
	curses.keypad(c.input_window, 1)
	curses.scrollok(c.log_window, 1)
		
	curses.nodelay(c.log_window, 1)
	curses.nodelay(c.input_window, 1)
	
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
	
	if false and WINDOWS then
		ffi.cdef("void PDC_set_title(const char *);")
		
		console.SetTitleRaw = curses.PDC_set_title
		console.SetTitleRaw(console.GetTitle())
	else
		c.status_window = curses.derwin(c.parent_window, 1, curses.COLS, 0, 0)
		curses.nodelay(c.status_window, 1)

		console.SetTitleRaw = console.ClearStatus
	end
	
	do
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
		
		local function fix(str)
			do return str end
			if WINDOWS and #str > max_length then
				for k,v in pairs(split_by_length(str, max_length)) do
					for line in v:gmatch("(.-)\n") do
						io.write(line)
					end
				end
				return
			end
			
			str = str:gsub("\r", "\\r")
			str = str:gsub("\t", "    ")
			str = str:gsub("%%", "%%%%")
			
			return str
		end
		
		function io.write(...)
			local str = table.concat({...}, "")

			if not can_print(str) then return end
						
			if str:count("\n") > 1 then
				for line in str:gmatch("(.-\n)") do
					io.write(line)
				end
				return
			end

			str = fix(str)
			
			if not debug.debugging then 
				table.insert(console.history, str)
			end
				
			console.SyntaxPrint(str, c.log_window)
			console.ScrollLogHistory(0) 
			
			curses.wrefresh(c.log_window)
		end
	end

	for _, args in pairs(_G.LOG_BUFFER) do
		io.write(unpack(args))
	end

	_G.LOG_BUFFER = nil
		
	console.curses_init = true
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
	
--	if CAPS then
--		i = get_color(math.random(255), math.random(255), math.random(255))
--	end

	setlogfile("asdf")
	log(str)
	setlogfile()
	
	local attr = curses.COLOR_PAIR(i)
	if USE_COLORS then curses.wattron(window, attr) end
	curses.waddstr(window, str)
	if USE_COLORS then curses.wattroff(window, attr) end
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
		curses.COLOR_RED,  --Color(255, 255, 255),
		curses.COLOR_CYAN, --Color(127, 159, 191),
		COLOR_DEFAULT, --Color(223, 223, 223),
		curses.COLOR_GREEN, --Color(191, 127, 127),
		curses.COLOR_GREEN, --Color(127, 191, 127),
		curses.COLOR_YELLOW, --Color(191, 191, 159),
		COLOR_DEFAULT, --Color(159, 159, 159),
		COLOR_DEFAULT, --Color(159, 159, 159),
		COLOR_DEFAULT, --Color(159, 159, 159),
		COLOR_DEFAULT, --Color(159, 159, 159),
		curses.COLOR_YELLOW, --Color(191, 159, 127),
		curses.COLOR_RED, --Color(191, 127, 127),
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

		return output
	end

	_G.syntax = _G.syntax or syntax

	function console.SyntaxPrint(str, window)
		window = window or c.log_window
		
		local tokens = syntax.process(str)

		for i = 1, #tokens / 2 do
			local color, str = tokens[1 + (i - 1) * 2 + 0], tokens[1 + (i - 1) * 2 + 1]
			if USE_COLORS then
				console.ColorPrint(str, color + 1, window)
			else
				curses.waddstr(window, str)
			end
		end
	end
end

console.scroll_log_history = 0 

function console.ScrollLogHistory(offset)
	if offset == 0 then 
		console.scroll_log_history = #console.history
	return end
	
	curses.werase(c.log_window)
	
	local lines = curses.LINES-1
	local count = #console.history
	
	console.scroll_log_history = math.clamp(console.scroll_log_history - offset, -2, count - lines)
	
	for i = 1, lines  do
		local str = console.history[i + console.scroll_log_history] or ""
		
		console.SyntaxPrint(str)
	end
	
	curses.wrefresh(c.log_window)
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
	
	curses.wrefresh(c.input_window)
end

function console.ClearWindow()
	curses.werase(c.log_window)
	curses.wrefresh(c.log_window)
end

function console.ClearStatus(str)
	curses.werase(c.status_window)
	if USE_COLORS then curses.wattron(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS)) end
	if USE_COLORS then curses.wbkgdset(c.status_window, COLORPAIR_STATUS) end
	curses.waddstr(c.status_window, str)
	if USE_COLORS then curses.wattroff(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS)) end
	curses.wrefresh(c.status_window)
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

			if found then
				markup:SetText(found .. " ")
				markup:SetCaretPos(math.huge, 0)
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
						markup:SetCaretPos(math.huge, 0)
					end
				end
			end
		end	
	else
		autocomplete.Query("console", console.GetCurrentLine())
	end

	if key == "KEY_NPAGE" then
		console.ScrollLogHistory(-1)
	elseif key == "KEY_PPAGE" then
		console.ScrollLogHistory(1)
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
				
				local res, err = console.RunString(line)

				if not res then
					logn(err)
				end
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
end
