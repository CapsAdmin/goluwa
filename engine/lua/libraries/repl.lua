local repl = _G.repl or {}

local curses = desire("curses")

if not curses then return end

local ffi = require("ffi")

local log_history = {}
repl.curses = repl.curses or {}
repl.input_height = 1
repl.max_lines = 10000
local pixel_window_size = Vec2(32,32)

repl.curses.log_window = curses.stdscr -- temporary

local c = repl.curses
local command_history = serializer.ReadFile("luadata", "data/cmd_history.txt") or {}
local dirty = false

local COLORPAIR_STATUS = 9

local char_translate =
{
	[1] = "CTL_A",
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

	CTL_A = "home",
	CTL_E = "end",
	CTL_P = "up",
	CTL_N = "down",
	CTL_F = "right",
	CTL_B = "left",
	CTL_D = "delete",
	CTL_H = "backspace",
}

function repl.Initialize()
	if not gfx or not gfx.CreateMarkup then
		-- the renderer might fail to load :( !
		local hack = false

		if not SERVER then
			SERVER = true
			hack = true
		end

		_G.gfx = _G.gfx or {}
		_G.gfx.GetDefaultFont = _G.gfx.GetDefaultFont or function() end
		runfile(e.ROOT_FOLDER .. "/engine/lua/libraries/graphics/gfx/markup.lua")

		if hack then
			SERVER = false
		end
	end

	if not gfx.CreateMarkup then
		wlog("unable to initialize curses because gfx.CreateMarkup doesn't exist")
		return
	end

	c.markup = gfx.CreateMarkup(nil, true)
	c.markup:SetFixedSize(14)
	c.markup:SetEditable(true)
	c.markup:Invalidate()

	repl.SetInputHeight(repl.input_height)

	local last_w = curses.COLS
	local last_h = curses.LINES

	local want_shutdown = false

	function repl.Update()
		if GRAPHICS and (window.IsFocused() and not dirty) then return end

		local chars = {}
		local key

		for i = 1, math.huge do
			local byte = c.input_window:getch()
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
					local char1, char2 = c.input_window:getch(), c.input_window:getch()
					if char1 > 0 and char2 > 0 then
						local str = string.char(byte, char1, char2)
						if char_translate[str] then
							key = char_translate[str]
							break
						end
					end
					curses.ungetch(char2)
					curses.ungetch(char1)
				elseif (byte > 32 or string.char(byte):find("%s")) and byte < 256 then
					table.insert(chars, string.char(byte))
				else
					llog("unhandled byte " .. byte .. " returned by c.input_window:getch()")
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

			if key == "KEY_COPY" then
				if repl.GetTextInput() == "" then
					if want_shutdown then
						system.ShutDown()
					else
						logn("ctrl c again to shutdown")
						want_shutdown = true
					end
				else
					logn(repl.GetTextInput(), "^C")
					c.markup:Clear()
					repl.SetInputText()
					return
				end
			else
				want_shutdown = false
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

	if repl.curses_init then return end

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
	c.input_window:keypad(1) -- enable arrows and other keys

	if TMUX then
		-- in tmux mode let curses do the blocking for better input
		c.input_window:timeout((1/30) * 1000)
	else
		c.input_window:nodelay(1) -- don't wait for input
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

	event.AddListener("ShutDown", function() repl.Shutdown() end)

	if WINDOW then
		window.Minimize()
	end

	repl.curses_init = true

	function os.execute(str)
		repl.Shutdown()
		_OLD_G.os.execute("clear")
		local code = _OLD_G.os.execute(str)
		repl.Initialize()
		return code
	end
end

function repl.GetPixelCanvas()
	c.pixel_window = c.pixel_window or curses.subpad(c.log_window, curses.COLS, curses.LINES, 0,0)
	repl.pixel_canvas = repl.pixel_canvas or require("drawille").new()
	return repl.pixel_canvas
end

function repl.ShowPixelCanvas()
	c.pixel_window:erase()
	repl.pixel_canvas:cframe(curses, c.pixel_window)
	c.pixel_window:prefresh(0,0,0,0, 32,64)
	curses.doupdate()
	curses.refresh()
end

do
	c.y = c.y or 0
	c.x = c.x or 0

	function repl.SetScroll(y, x)
		c.y = y or c.y
		c.x = x or c.x

		c.y = math.clamp(c.y, 0, math.max(c.log_window:getcury() - curses.LINES + repl.input_height + 1, 0))

		c.log_window:pnoutrefresh(c.y, c.x,    1,0,curses.LINES-repl.input_height-1,curses.COLS)
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

	window:attron(attr)
	window:addstr(str)
	window:attroff(attr)

	window:noutrefresh()
	dirty = true

	repl.SetScroll()
end

function repl.Clear()
	table.clear(log_history)
	c.log_window:clear()
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

	c.log_window:resize(repl.max_lines, w)
	c.log_window:erase()

	for _, v in pairs(log_history) do
		repl.SyntaxPrint(v, c.log_window)
	end

	if c.status_window then
		c.status_window:mvin(0, 0)
		c.status_window:resize(1, w)
		c.status_window:noutrefresh()
	end

	if c.pixel_window then
		pixel_window_size = Vec2(w/4, h/4)
		c.pixel_window:resize(64,64)
	end

	c.input_window:resize(repl.input_height, w)
	c.input_window:mvin(h - repl.input_height, 0)
	c.input_window:noutrefresh()

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
	local byte = c.input_window:getch()

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

	c.input_window:erase()

	if str then
		str = str:gsub("\t", " ")
		repl.SyntaxPrint(str, c.input_window)
	end

	local pos = c.markup:GetCaretPosition()

	c.input_window:move(pos.y-1, pos.x)

	c.input_window:noutrefresh()
	dirty = true
end

function repl.GetTextInput()
	return c.markup:GetText()
end

do
	local last_status = ""

	function repl.SetStatusText(str)
		c.status_window:erase()

		local attr = curses.COLOR_PAIR(COLORPAIR_STATUS)
		c.status_window:attron(attr)
		c.status_window:bkgdset(attr)
		c.status_window:addstr(str)
		c.status_window:attroff(attr)

		--c.status_window:mvin(0, (curses.COLS / 2) - (#str / 2))

		c.status_window:noutrefresh()

		-- this prevents the cursor from going up in the title bar (??)
		local pos = c.markup:GetCaretPosition()

    	c.input_window:move(pos.y-1, pos.x)
    	c.input_window:noutrefresh()

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
		_OLD_G.os.execute("tmux detach")
	end)
end

return repl
