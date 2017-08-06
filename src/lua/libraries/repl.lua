local repl = _G.repl or {}

local curses = desire("curses")

if not curses then return end

local ffi = require("ffi")

local log_history = {}
repl.curses = repl.curses or {}
repl.input_height = 1
repl.max_lines = 10000

local c = repl.curses
local command_history = serializer.ReadFile("luadata", "data/cmd_history.txt") or {}
local dirty = false

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
	[22] = "KEY_PASTE",

	[4] = "KEY_DC",
	[23] = "CTL_BACKSPACE",
	[5] = "KEY_END",
	[2] = "KEY_LEFT",
	[6] = "KEY_RIGHT",

	["kRIT5"] = "CTL_RIGHT",
	["kLFT5"] = "CTL_LEFT",

	["\27[1;5D"] = "CTL_LEFT",
	["\27[1;5C"] = "CTL_RIGHT",

	["\27[D"] = "CTL_LEFT",
	["\27[C"] = "CTL_RIGHT",

	["\27\79\72"] = "KEY_HOME",
	["\27\79\70"] = "KEY_END",
	["\27\91\51\59\53\126"] = "CTL_DEL",
	["kDC5"] = "CTL_DEL",

	KEY_SELECT = "KEY_HOME",
	KEY_FIND = "KEY_END",

	PADENTER = "KEY_ENTER",
	KEY_NPAGE = "KEY_PAGEDOWN",
	KEY_PPAGE = "KEY_PAGEUP",
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
	CTL_ENTER = "enter",

	KEY_PAGEUP = "page_up",
	KEY_PAGEDOWN = "page_down",
	KEY_LSHIFT = "left_shift",
	KEY_RSHIFT = "right_shift",
	KEY_RCONTROL = "right_control",
	KEY_LCONTROL = "left_control",
}

function repl.Initialize()
	if SERVER or not gfx then
		-- the renderer might fail to load :( !
		local hack = false

		if not SERVER then
			SERVER = true
			hack = true
		end

		_G.gfx = {GetDefaultFont = function() end}
		runfile("lua/libraries/graphics/gfx/markup.lua")

		if hack then
			SERVER = false
		end
	end

	c.markup = gfx.CreateMarkup(nil, true)
	c.markup:SetFixedSize(14)
	c.markup:SetEditable(true)

	repl.SetInputHeight(repl.input_height)

	local last_w = curses.COLS
	local last_h = curses.LINES

	function repl.Update()
		if GRAPHICS and (window.IsFocused() and not dirty) then return end

		local chars = {}
		local key

		for i = 1, math.huge do
			local byte = curses.wgetch(c.input_window)
			if byte == -1 then break end

			if curses.has_key(byte) then
				key = ffi.string(curses.keyname(byte))
				if char_translate[key] then
					key = char_translate[key]
				end
				break
			else
				if char_translate[byte] then
					key = char_translate[byte]
					break
				elseif byte == 27 then
					local char1, char2 = curses.wgetch(c.input_window), curses.wgetch(c.input_window)
					if char1 > 0 and char2 > 0 then
						local str = string.char(byte, char1, char2)
						if char_translate[str] then
							key = char_translate[str]
							break
						end
					end
					curses.ungetch(char2)
					curses.ungetch(char1)
				elseif byte > 32 or string.char(byte):find("%s") then
					table.insert(chars, utf8.char(byte))
				end
			end
		end

		if chars[1] then
			chars = table.concat(chars)
			if event.Call("ReplCharInput", chars) ~= false then
				repl.HandleChar(chars)
				repl.SetInputText(c.markup:GetText())
			end
		end

		if key then

			if TMUX and key == "KEY_DC" then
				os.execute("tmux detach")
				return
			end

			c.markup:SetControlDown(key:find("CTL_") ~= nil)
			c.markup:SetShiftDown(key:find("KEY_S") ~= nil)

			if (key:find("KEY_") or key:find("CTL_") or key:find("PAD")) and event.Call("ReplKeyInput", key) ~= false then
				repl.HandleKey(key)
				repl.SetInputText(c.markup:GetText())
			end
		end

		if last_w ~= curses.COLS or last_h ~= curses.LINES then
			repl.SetSize(curses.COLS, curses.LINES)
			last_w = curses.COLS
			last_h = curses.LINES
		end

		if dirty then
			curses.doupdate()
		end
	end

	if TMUX then
		event.AddListener("Update", "curses", repl.Update)
	else
		event.Timer("curses", 1/30, 0, repl.Update)
	end

	do -- input extensions
		local trigger = input.SetupInputEvent("ReplKey")

		event.AddListener("ReplKeyInput", "input", function(key)
			local ret = trigger(key, true)

			-- :(
			event.Delay(0, function() trigger(key, false) end)

			return ret
		end)

		local trigger = input.SetupInputEvent("ReplChar")

		event.AddListener("ReplCharInput", "input", function(char)
			local ret = trigger(char, true)

			-- :(
			event.Delay(0, function() trigger(char, false) end)

			return ret
		end)
	end

	if repl.curses_init then	return end

	local pdcurses_for_real_windows = pcall(function() return curses.PDC_set_resize_limits end)

	if pdcurses_for_real_windows then
		curses.freeconsole()
	end

	curses.initscr() -- init curses

	if WINDOWS and pdcurses_for_real_windows then
		curses.resize_term(50, 150)
	end

	curses.raw() -- raw input, disables ctrl-c and such
	curses.noecho()

	c.log_window = curses.newpad(repl.max_lines, curses.COLS)

	c.input_window = curses.newwin(1, curses.COLS, curses.LINES - 1, 0)
	curses.keypad(c.input_window, 1) -- enable arrows and other keys

	if TMUX then
		curses.wtimeout(c.input_window, (1/30) * 1000) -- don't wait for input
	else
		curses.nodelay(c.input_window, 1) -- don't wait for input
	end
	--curses.timeout((1/30) * 1000) -- don't wait for input

	curses.start_color()
	curses.use_default_colors()
	--[[for i = 0, curses.COLORS-1 do
		local r = bit.rshift(i, 5)
		local g = bit.band(bit.rshift(i, 2), 0x7)
		local b = bit.band(i, 0x7)
		curses.init_color(i, r,g,b)
		curses.init_pair(i+1, i, -1)
	end]]

	for i = 0, curses.COLORS-1 do
		curses.init_pair(i+1, i, -1)
	end

	-- replace some functions

	if WINDOWS then
		ffi.cdef("void PDC_set_title(const char *);")

		system.SetConsoleTitleRaw = curses.PDC_set_title
		system.SetConsoleTitleRaw(system.GetConsoleTitle())
	else
		curses.init_pair(COLORPAIR_STATUS, curses.COLOR_RED, curses.COLOR_WHITE + curses.A_DIM * 2 ^ 8)
		c.status_window = curses.newwin(1, curses.COLS, 0, 0)

		system.SetConsoleTitleRaw = repl.SetStatusText
	end

	repl.SetSize(curses.COLS, curses.LINES)

	event.AddListener("ShutDown", repl.Shutdown)

	repl.curses_init = true
end

do
	c.y = c.y or 0
	c.x = c.x or 0

	function repl.SetScroll(y, x)
		c.y = y or c.y
		c.x = x or c.x

		c.y = math.clamp(c.y, 0, math.max(curses.getcury(c.log_window) - curses.LINES + repl.input_height + 1, 0))

		curses.pnoutrefresh(c.log_window, c.y, c.x,    1,0,curses.LINES-repl.input_height-1,curses.COLS)
		dirty = true
	end

	function repl.GetScroll()
		return c.y, c.x
	end
end

do
	local suppress_print = false

	function repl.CanPrint(str)
		if suppress_print then return end

		if event then
			suppress_print = true

			if event.Call("ReplPrint", str) == false then
				suppress_print = false
				return false
			end

			suppress_print = false
		end

		return true
	end
end

function repl.Print(str)
	if not repl.CanPrint(str) then return end

	repl.SyntaxPrint(str, c.log_window)

	table.insert(log_history, str)

	repl.SetScroll(math.huge,0)
end

function repl.ColorPrint(str, color, window)
	window = window or c.log_window

	--local r,g,b = 255,255,255
	--local attr = curses.COLOR_PAIR(16+r/48*36+g/48*6+b/48)
	local attr = curses.COLOR_PAIR(color + 1)
	curses.wattron(window, attr)
	curses.waddstr(window, str)
	curses.wattroff(window, attr)

	curses.wnoutrefresh(window)
	dirty = true

	repl.SetScroll()
end

function repl.Clear()
	table.clear(log_history)
	curses.wclear(c.log_window)
	repl.SetScroll()
	event.Call("ReplClear")
end

commands.Add("clear", repl.Clear)

function repl.SetInputHeight(h)
	h = math.max(h or 1, 1)

	local resize = h ~= repl.input_height

	repl.input_height = h

	if resize then
		repl.SetSize(curses.COLS, curses.LINES)
	end
end

function repl.GetInputHeight()
	return repl.input_height
end

function repl.SetSize(w, h)
	w = w or curses.COLS
	h = h or curses.LINES

	curses.wresize(c.log_window, repl.max_lines, w)
	curses.werase(c.log_window)

	for _, v in pairs(log_history) do
		repl.SyntaxPrint(v, c.log_window)
	end

	if c.status_window then
		curses.mvwin(c.status_window, 0, 0)
		curses.wresize(c.status_window, 1, w)
		curses.wnoutrefresh(c.status_window)
	end

	curses.wresize(c.input_window, repl.input_height, w)
	curses.mvwin(c.input_window, h - repl.input_height, 0)
	curses.wnoutrefresh(c.input_window)

	dirty = true
end

function repl.GetSize()
	return curses.COLS, curses.LINES
end

function repl.Shutdown()
	if repl.curses_init then
		curses.endwin()

		event.RemoveTimer("curses")
		event.RemoveListener("ReplKeyInput", "input")
		event.RemoveListener("ReplCharInput", "input")
		repl.curses_init = nil
	end
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
		{2, "[%a_][%w_]*"},
		{1, "\".-\""},
		{4, "0x[a-fA-F0-9]+"},
		{5, "[%d]+%.?%d*e?%d*"},
		{6, "[%+%-%*/%%%(%)%.,<>=:;{}%[%]]"},
		{7, "//[^\n]*"},
		{8, "/%*.-%*/"},
		{9, "%-%-[^%[][^\n]*"},
		{10, "%-%-%[%[.-%]%]"},
		{11, "%[=-%[.-%]=-%]"},
		{12, "'.-'"},
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

	function repl.SyntaxPrint(str, window)
		window = window or c.log_window

		str = str:gsub("\t", "    ")

		--	profiler.StartTimer("console syntax parse")
		local output, finds, types, a, b, c = {}, {}, {}, 0, 0, 0

		finds[1] = 0

		while b < #str do
			local temp = {}

			for _, v in ipairs(syntax.patterns) do
				local aa, bb = str:find(v[2], b + 1)
				if aa then temp[#temp+1] = {v[1], aa, bb} end
			end

			if #temp == 0 then
				temp[#temp+1] = {1, b + 1, #str}
			end

			table.sort(temp, function(a, b) return (a[2] == b[2]) and (a[3] > b[3]) or (a[2] < b[2]) end)
			c, a, b = unpack(temp[1])

			finds[#finds+1] = a
			finds[#finds+1] = b

			types[#types+1] = c == 2 and (syntax.keywords[str:sub(a, b)] and 2 or 3) or c
		end

		finds[#finds + 1] = #str + 1

		for i = 1, #finds - 1 do
			local asdf = i % 2
			local sub = str:sub(finds[i + 0] + asdf, finds[i + 1] - asdf)

			output[#output+1] = asdf == 0 and syntax.colors[types[1 + (i - 2) / 2]] or -1
			output[#output+1] = sub
		end

		for i = 1, #output / 2 do
			local color, str = output[1 + (i - 1) * 2 + 0], output[1 + (i - 1) * 2 + 1]

			repl.ColorPrint(str, color, window)
		end
	end
end

function repl.GetActiveKey()
	local byte = curses.wgetch(c.input_window)

	if byte < 0 then return end

	local key = char_translate[byte] or ffi.string(curses.keyname(byte))
	if not key:find("KEY_") then key = nil end

	return key
end

function repl.SetInputText(str)
	if str then
		local lines = str:count("\n")

		repl.SetInputHeight(lines)
	end

	curses.werase(c.input_window)

	if str then
		str = str:gsub("\t", " ")
		repl.SyntaxPrint(str, c.input_window)
	end

	local pos = c.markup:GetCaretPosition()

	curses.wmove(c.input_window, pos.y-1, pos.x)

	curses.wnoutrefresh(c.input_window)
	dirty = true
end

function repl.GetTextInput()
	return c.markup:GetText()
end

do
	local last_status = ""

	function repl.SetStatusText(str)
		curses.werase(c.status_window)

		local attr = curses.COLOR_PAIR(COLORPAIR_STATUS)
		curses.wattron(c.status_window, attr)
		curses.wbkgdset(c.status_window, attr)
		curses.waddstr(c.status_window, str)
		curses.wattroff(c.status_window, attr)

		curses.mvwin(c.status_window, 0, (curses.COLS / 2) - (#str / 2))

		curses.wnoutrefresh(c.status_window)

		-- this prevents the cursor from going up in the title bar (??)
		local pos = c.markup:GetCaretPosition()
		curses.wmove(c.input_window, pos.y-1, pos.x)
		curses.wnoutrefresh(c.input_window)

		dirty = true
		last_status = str
	end

	function repl.GetStatusText()
		return last_status
	end
end

local function get_commands_for_autocomplete()
	local cmds = {}
	for k,v in pairs(commands.GetCommands()) do
		for k,v in ipairs(v.aliases) do
			table.insert(cmds, v)
		end
	end
	return cmds
end

c.scroll_command_history = c.scroll_command_history or 0

local last_key

function repl.HandleKey(key)

	if key == "KEY_PAGEUP" then
		repl.SetScroll(repl.GetScroll() - curses.LINES / 2)
	elseif key == "KEY_PAGEDOWN" then
		repl.SetScroll(repl.GetScroll() + curses.LINES / 2)
	end

	if window then
		if key == "KEY_PASTE" then
			c.markup:Paste(window.GetClipboard())
		elseif key == "KEY_COPY" then
			window.SetClipboard(c.markup:GetText())
		end
	end

	if key == "KEY_TAB" then
		local line = repl.GetTextInput()
		local cmd, rest = line:match("(%S+)%s+(.+)")

		if not cmd then cmd = line:match("(%S+)") end

		if cmd and not rest then

			local found = autocomplete.Query("console", cmd, 1, get_commands_for_autocomplete())

			if found and found[1] then
				c.markup:SetText(found[1] .. " ")
				c.markup:SetCaretPosition(math.huge, 0)
			end
			return
		end

		if cmd and rest then
			local info = commands.FindCommand(cmd)
			if info and info.autocomplete then
				local _,_,_,args = commands.ParseString(line)
				if args then
					local list = info.autocomplete(args[#args], args)
					if list then
						local found = autocomplete.Query("console_command_" .. cmd, args[#args], 1, list)
						if found then
							table.remove(args)

							if #args > 0 then
								found = "," .. found
							end

							c.markup:SetText(cmd .. " " .. table.concat(args, ",") .. found)
							c.markup:SetCaretPosition(math.huge, 0)
						end
					end
				end
			end
		end
	else
		autocomplete.Query("console", repl.GetTextInput())
	end

	if repl.input_height == 1 or c.markup:GetText() == "" then
		if key == "KEY_UP" then
			c.scroll_command_history = c.scroll_command_history - 1
			c.markup:SetText(command_history[c.scroll_command_history%#command_history+1])
			c.markup:SetCaretPosition(math.huge, 0)
		elseif key == "KEY_DOWN" then
			c.scroll_command_history = c.scroll_command_history + 1
			c.markup:SetText(command_history[c.scroll_command_history%#command_history+1])
			c.markup:SetCaretPosition(math.huge, 0)
		end
	end


	if key == "KEY_ENTER" then
		local line = c.markup:GetText()
		c.markup:Clear()

		repl.SetInputText()

		if line ~= "" then
			for key, str in pairs(command_history) do
				if str == line then
					table.remove(command_history, key)
				end
			end

			table.insert(command_history, line)
			serializer.WriteFile("luadata", "data/cmd_history.txt", command_history)

			c.scroll_command_history = 0

			if event.Call("ReplLineEntered", line) ~= false then
				logn("> ", line)

				commands.RunString(line, nil, nil, true)
			end

			c.in_function = false
		end
		return
	end

	if markup_translate[key] then
		c.markup:OnKeyInput(markup_translate[key])
	end

	last_key = key
end

function repl.HandleChar(char)
	c.markup:OnCharInput(char)
end

if RELOAD then
	repl.Initialize()
end

if TMUX then
	commands.Add("detach", function()
		os.execute("tmux detach")
	end)
end

return repl
