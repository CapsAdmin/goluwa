local console = _G.console or {}

local ffi = require("ffi")

local start_symbols = {
	"%!",
	"%.",
	"%/",
	"",
}

local arg_types = {
	vec3 = Vec3,
	ang3 = Ang3,
	client = function(str)
		return NULL-- easylua.FindEntity(str) or NULL
	end,
	name = function(client)
		if client and client:IsValid() then
			return client:GetNick()
		end
	end,
}

if expression then
	arg_types.e = function(str)
		local _, res = assert(expression.Compile(str))
		return res()
	end
end

arg_types.v3 = arg_types.vec3
arg_types.a3 = arg_types.ang3
arg_types["@"] = arg_types.client
arg_types["#"] = arg_types.client


local capture_symbols = {
	["\""] = "\"",
	["'"] = "'",
	["("] = ")",
	["["] = "]",
	["`"] = "`",
	["´"] = "´",
}

local function allowed(udata, arg)
	return true
end

local result = ""

function console.StartCapture()
	result = ""

	log = function(str)
		result = result .. str
	end

	logn = function(str)
		result = result .. str .. "\n"
	end

end

function console.EndCapture()
	log = _OLD_G.log
	logn = _OLD_G.logn
	return result
end

function console.Capture(func, ...)
	console.StartCapture()
		func(...)
	return console.EndCapture()
end

function console.Exec(cfg)
	check(cfg, "string")

	local content = vfs.Read("cfg/"  .. cfg .. ".cfg")

	if content then
		console.RunString(content)
		return true
	end

	return false
end

do -- commands
	console.AddedCommands = console.AddedCommands or {}

	function console.AddCommand(cmd, callback, help, autocomplete)
		cmd = cmd:lower()

		console.AddedCommands[cmd] = {callback = callback, help = help, autocomplete = autocomplete}
	end

	function console.AddAutocomplete(cmd, callback)
		cmd = cmd:lower()

		if console.AddedCommands[cmd] then
			console.AddedCommands[cmd].autocomplete = callback
		end
	end

	function console.AddHelp(cmd, str)
		cmd = cmd:lower()

		if console.AddedCommands[cmd] then
			console.AddedCommands[cmd].help = str
		end
	end

	function console.RemoveCommand(cmd)
		cmd = cmd:lower()

		console.AddedCommands[cmd] = nil
	end

	function console.GetCommands()
		return console.AddedCommands
	end

	local function call(data, line, ...)
		local a, b, c = system.pcall(data, line, ...)

		if a and b ~= nil then
			return b, c
		end

		return a, b
	end

	local function call_command(cmd, line, ...)
		cmd = cmd:lower()

		local data = console.AddedCommands[cmd]

		if data then
			local ok, reason = call(data.callback, line, ...)
			 if not ok then
				logn("failed to execute command ", cmd, "!")
				logn(reason)

				local help = console.AddedCommands[cmd].help

				if help then
					if type(help) == "function" then
						help()
					else
						logn(help)
					end
				end
			end

			return ok, reason
		end
	end

	function console.RunCommand(cmd, ...)
		return call_command(cmd, table.concat({...}, ","), ...)
	end

	do -- arg parsing
		local function parse_args(arg_line)
			if not arg_line or arg_line:trim() == "" then return {} end

			local chars = arg_line:utotable()

			local args = {}
			local capture = {}
			local escape  = false

			local in_capture = false

			for _, char in ipairs(chars) do
				if escape then
					table.insert(capture, char)
					escape = false
				else
					if in_capture then
						if char == in_capture then
							in_capture = false
						end

						table.insert(capture, char)
					else
						if char == "," then
							table.insert(args, table.concat(capture, ""):trim())
							table.clear(capture)
						else
							table.insert(capture, char)

							if capture_symbols[char] then
								in_capture = capture_symbols[char]
							end

							if char == "\\" then
								escape = true
							end
						end
					end
				end
			end

			table.insert(args, table.concat(capture, ""):trim())

			for i, str in ipairs(args) do
				if tonumber(str) then
					args[i] = tonumber(str)
				else
					local cmd, rest = str:match("^(.+)%((.+)%)$")

					if not cmd then
						local t = str:sub(1,1):charclass()
						if t then
							cmd, rest = str:match("^("..t.."+)(.+)$")
						end
					end

					if cmd then
						cmd = cmd:trim():lower()
						if arg_types[cmd] then

							if capture_symbols[rest:sub(1,1)] then
								rest = rest:sub(2, -2)
							end

							args[i] = {cmd = cmd, args = parse_args(rest), line = str}
						end
					end
				end
			end

			return args
		end

		local function parse_line(line)
			for _, v in ipairs(start_symbols) do
				local start, rest = line:match("^(" .. v .. ")(.+)")
				if start then
					local cmd, rest_ = rest:match("^(%S+)%s+(.+)$")
					if not cmd then
						return v, rest:trim()
					else
						return v, cmd, rest_
					end
				end
			end
		end

		local function execute_args(args, udata)
			local errors = {}

			for i, arg in ipairs(args) do
				if type(arg) == "table" then

					local ok, res = execute_args(arg.args, udata)

					if not ok then
						table.insert(errors, res)
					end

					if arg_types[arg.cmd] and allowed(udata, arg) then
						local ok, res = pcall(arg_types[arg.cmd], unpack(arg.args))

						if ok then
							args[i] = res
						else
							table.insert(errors, ("%q: %s"):format(arg.line, res))
						end
					end
				end
			end

			if #errors > 0 then
				return nil, table.concat(errors, "\n")
			end

			return true
		end

		function console.IsValidCommand(line)
			local symbol, cmd, rest = parse_line(line)
			return console.AddedCommands[cmd] ~= nil, symbol and symbol:sub(2,2)
		end

		function console.ParseCommandArgs(line)
			local symbol, cmd, rest = parse_line(line)

			local data = {args = parse_args(rest), line = rest or "", cmd = cmd, symbol = symbol}

			local ok, err = execute_args(data.args)
			if not ok then return nil, err end
			return data
		end
	end

	function console.RunString(line, skip_lua, skip_split, log_error)
		if not skip_split and line:find("\n") then
			for line in (line .. "\n"):gmatch("(.-)\n") do
				console.RunString(line, skip_lua, skip_split, log_error)
			end
			return
		end

		local data, err = console.ParseCommandArgs(line)

		if data then
			if console.AddedCommands[data.cmd] then
				return call_command(data.cmd, data.line, unpack(data.args))
			end

			if not skip_lua then
				return console.RunLua(line, log_error)
			end
		end

		if log_error and err then
			logn(err)
		end
	end

	console.run_lua_environment = {}

	function console.SetLuaEnvironmentVariable(key, var)
		console.run_lua_environment[key] = var
	end

	function console.RunLua(line, log_error, env_name)
		console.SetLuaEnvironmentVariable("copy", window.SetClipboard)
		console.SetLuaEnvironmentVariable("gl", desire("graphics.ffi.opengl"))
		console.SetLuaEnvironmentVariable("findo", prototype.FindObject)
		local lua = ""

		for k in pairs(console.run_lua_environment) do
			lua = lua .. ("local %s = console.run_lua_environment.%s;"):format(k, k)
		end

		lua = lua .. line

		local func, err = loadstring(lua, env_name or line)

		if log_error and not func then
			logn(err)
			return func, err
		end

		if not func then return func, err end

		local ret = {system.pcall(func)}

		if log_error and not ret[1] then
			if ret[2] then logn(ret[2]) end
			return unpack(ret)
		end

		return unpack(ret)
	end
end

do -- console vars
	console.cvar_file_name = "%DATA%/cvars.txt"
	console.variable_objects = console.variable_objects or {}

	-- what's the use?
	do -- cvar meta
		local META = prototype.CreateTemplate("cvar")

		function META:Get()
			if not console.vars then
				console.ReloadVariables()
			end

			return console.vars[self.name]
		end

		function META:GetHelp() return self.help end
		function META:GetCallback() return self.callback end
		function META:GetDefault() return self.def end

		function META:Set(var)
			console.SetVariable(self.name, var)
		end

		prototype.Register(META)
	end

	function console.ReloadVariables()
		console.vars = serializer.ReadFile("luadata", console.cvar_file_name) or {}
	end

	local luadata = serializer.GetLibrary("luadata")

	function console.CreateVariable(name, def, callback, help)
		if not console.vars then console.ReloadVariables() end

		if console.vars[name] == nil then
			console.vars[name] = def
		end

		local T = type(def)

		local func = function(line, value)
			if value == nil then
				if console.vars[name] ~= nil then
					value = console.vars[name]
				end

				if value == nil then
					value = def
				end

				if T == "string" then
					value = ("%q"):format(value)
				end

				logf("%s = %s (default = %s)\n", name, luadata.ToString(value), luadata.ToString(def))
				local help = console.GetCommands()[name].help
				if help then
					if type(help) == "function" then
						help()
					else
						logn(help)
					end
				end
			else
				if T ~= "string" then
					value = luadata.FromString(value)
				end

				if value == nil then
					value = def
				end

				console.SetVariable(name, value)

				if type(callback) == "function" then
					callback(value)
				end

				logf("%s = %s (%s)\n", name, value, typex(value))
			end

		end

		if type(callback) == "string" then
			help = callback
		end

		console.AddCommand(name, func, help)

		if type(callback) == "function" then
			event.Delay(function()
				callback(console.GetVariable(name))
			end)
		end

		console.variable_objects[name] = prototype.CreateObject("cvar", {name = name, def = def, help = help, callback = callback})

		return console.GetVariableObject(name)
	end

	function console.GetVariableObject(name)
		return console.variable_objects[name]
	end

	function console.IsVariableAdded(var)
		return console.AddedCommands and console.AddedCommands[var] ~= nil
	end

	function console.GetVariable(var, def)
		if not console.vars then console.ReloadVariables() end

		if console.vars[var] == nil then
			return def
		end

		return console.vars[var]
	end

	function console.SetVariable(name, value)
		if not console.vars then console.ReloadVariables() end

		console.vars[name] = value
		serializer.SetKeyValueInFile("luadata", console.cvar_file_name, name, value)
	end
end


do -- title
	if not console.SetTitleRaw then
		local set_title

		if WINDOWS then
			ffi.cdef("int SetConsoleTitleA(const char* blah);")

			set_title = function(str)
				return ffi.C.SetConsoleTitleA(str)
			end
		end

		if not CURSES then
			set_title = function()
				-- hmmm
			end
		elseif LINUX then
			local iowrite = _OLD_G.io.write
			set_title = function(str)
				return iowrite and iowrite('\27]0;', str, '\7') or nil
			end
		end

		console.SetTitleRaw = set_title
	end

	local titles = {}
	local str = ""
	local last_title

	local lasttbl = {}

	function console.SetTitle(title, id)
		local time = os.clock()

		if not lasttbl[id] or lasttbl[id] < time then
			if id then
				titles[id] = title
				str = "| "
				for _, v in pairs(titles) do
					str = str ..  v .. " | "
				end
				if str ~= last_title then
					console.SetTitleRaw(str)
				end
			else
				str = title
				if str ~= last_title then
					console.SetTitleRaw(title)
				end
			end
			last_title = str
			lasttbl[id] = os.clock() + 0.05
		end
	end

	function console.GetTitle()
		return str
	end
end

do -- for fun
	console.cmd = setmetatable(
		{},
		{
			__index = function(self, key)
				key = key:lower()

				-- lua commands
				if console.AddedCommands[key] then
					return function(...)
						console.RunCommand(key, ...)
					end
				end

				-- lua cvars
				local tbl = console.vars

				if not console.vars then
					console.ReloadVariables()
				end

				if tbl[key] then
					return tbl[key]
				end
			end,

			__newindex = function(self, key, val)
				key = key:lower()

				console.RunString(key .. " " .. val, true)
			end
		}
	)
end

console.AddCommand("help", function(line)
	local info = console.GetCommands()[line]
	if info then
		if not info.help then
			logn("\tno help was found for ", line)
			logf("\ttype %q to go to this function\n", "source " .. line)
			logn("\tdebug info:")
			logn("\t\targuments\t=\t", table.concat(debug.getparams(info.callback), ", "))
			logn("\t\tfunction\t=\t", tostring(info.callback))
		else
			if type(info.help) == "function" then
				info.help()
			else
				logn(info.help)
			end
		end
	end
end)

if CURSES then
	local curses = require("ffi.curses")

	local log_history = console.GetLogHistory and console.GetLogHistory() or {}
	console.curses = console.curses or {}
	console.input_height = 1
	console.max_lines = 10000

	local c = console.curses
	local command_history = serializer.ReadFile("luadata", "%DATA%/cmd_history.txt") or {}
	local hush
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

		["kRIT5"] = "CTL_RIGHT",
		["kLFT5"] = "CTL_LEFT",
		["\27[1;5D"] = "CTL_LEFT",
		["\27[1;5C"] = "CTL_RIGHT",

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

	function console.InitializeCurses()
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

		c.markup = surface.CreateMarkup()
		c.markup:SetFixedSize(14)

		console.SetInputHeight(console.input_height)

		local last_w = curses.COLS
		local last_h = curses.LINES

		event.Timer("curses", 1/30, 0, function()
			if GRAPHICS and (window.IsFocused() and not dirty) then return end

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
				for chars in pairs(char_translate) do
					if type(chars) == "string" then
						if key:sub(1, #chars) == chars then
							key = chars
						end
					end
				end

				local temp = char_translate[key] or char_translate[key:byte()]

				if temp then
					key = temp
				--elseif #key > 1 and not (key:find("KEY_") or key:find("CTL_") or key:find("PAD")) then
					--logn("unknown key pressed: ", key)
					--return
				end

				c.markup:SetControlDown(key:find("CTL_") ~= nil)
				c.markup:SetShiftDown(key:find("KEY_S") ~= nil)

				if (key:find("KEY_") or key:find("CTL_") or key:find("PAD")) and event.Call("ConsoleKeyInput", key) ~= false then
					console.HandleKey(key)
				elseif event.Call("ConsoleCharInput", key) ~= false then
					if key:byte(1) >= 32 then
						console.HandleChar(key)
					end
				end

				console.SetInputText(c.markup:GetText())
			end

			if last_w ~= curses.COLS or last_h ~= curses.LINES then
				console.SetSize(curses.COLS, curses.LINES)
				last_w = curses.COLS
				last_h = curses.LINES
			end

			if dirty then
				curses.doupdate()
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

		curses.initscr() -- init curses

		if WINDOWS and pdcurses_for_real_windows then
			curses.resize_term(50, 150)
		end

		curses.raw() -- raw input, disables ctrl-c and such
		curses.noecho()

		c.log_window = curses.newpad(console.max_lines, curses.COLS)

		c.input_window = curses.newwin(1, curses.COLS, curses.LINES - 1, 0)
		curses.keypad(c.input_window, 1) -- enable arrows and other keys
		curses.nodelay(c.input_window, 1) -- don't wait for input

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

			console.SetTitleRaw = curses.PDC_set_title
			console.SetTitleRaw(console.GetTitle())
		else
			curses.init_pair(COLORPAIR_STATUS, curses.COLOR_RED, curses.COLOR_WHITE + curses.A_DIM * 2 ^ 8)
			c.status_window = curses.newwin(1, curses.COLS, 0, 0)

			console.SetTitleRaw = console.SetStatusText
		end

		console.SetSize(curses.COLS, curses.LINES)

		console.curses_init = true
	end

	do
		c.y = c.y or 0
		c.x = c.x or 0

		function console.SetScroll(y, x)
			c.y = y or c.y
			c.x = x or c.x

			c.y = math.clamp(c.y, 0, math.max(curses.getcury(c.log_window) - curses.LINES + console.input_height + 1, 0))

			curses.pnoutrefresh(c.log_window, c.y, c.x,    1,0,curses.LINES-console.input_height-1,curses.COLS)
			dirty = true
		end

		function console.GetScroll()
			return c.y, c.x
		end
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

		console.SyntaxPrint(str, c.log_window)

		table.insert(log_history, str)

		console.SetScroll(math.huge,0)
	end

	function console.ColorPrint(str, color, window)
		window = window or c.log_window

		--local r,g,b = 255,255,255
		--local attr = curses.COLOR_PAIR(16+r/48*36+g/48*6+b/48)
		local attr = curses.COLOR_PAIR(color + 1)
		curses.wattron(window, attr)
		curses.waddstr(window, str)
		curses.wattroff(window, attr)

		curses.wnoutrefresh(window)
		dirty = true

		console.SetScroll()
	end

	function console.Clear()
		table.clear(log_history)
		curses.wclear(c.log_window)
		console.SetScroll()
		event.Call("ConsoleClear")
	end

	function console.SetInputHeight(h)
		h = math.max(h or 1, 1)

		local resize = h ~= console.input_height

		console.input_height = h

		if resize then
			console.SetSize(curses.COLS, curses.LINES)
		end
	end

	function console.GetInputHeight()
		return console.input_height
	end

	function console.SetSize(w, h)
		w = w or curses.COLS
		h = h or curses.LINES

		curses.wresize(c.log_window, console.max_lines, w)
		curses.werase(c.log_window)

		for _, v in pairs(log_history) do
			console.SyntaxPrint(v, c.log_window)
		end

		if c.status_window then
			curses.mvwin(c.status_window, 0, 0)
			curses.wresize(c.status_window, 1, w)
			curses.wnoutrefresh(c.status_window)
		end

		curses.wresize(c.input_window, console.input_height, w)
		curses.mvwin(c.input_window, h - console.input_height, 0)
		curses.wnoutrefresh(c.input_window)

		dirty = true
	end

	function console.GetSize()
		return curses.COLS, curses.LINES
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

	event.AddListener("ShutDown", console.ShutdownCurses)

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

		function console.SyntaxPrint(str, window)
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

				console.ColorPrint(str, color, window)
			end
		end
	end

	function console.GetActiveKey()
		local byte = curses.wgetch(c.input_window)

		if byte < 0 then return end

		local key = char_translate[byte] or ffi.string(curses.keyname(byte))
		if not key:find("KEY_") then key = nil end

		return key
	end

	function console.SetInputText(str)
		if str then
			local lines = str:count("\n")

			console.SetInputHeight(lines)
		end

		curses.werase(c.input_window)

		if str then
			str = str:gsub("\t", " ")
			console.SyntaxPrint(str, c.input_window)
		end

		local y = c.markup:GetCaretPosition().y
		local x = c.markup:GetCaretPosition().x

		curses.wmove(c.input_window, y-1, x)

		curses.wnoutrefresh(c.input_window)
		dirty = true
	end

	function console.GetTextInput()
		return c.markup:GetText()
	end

	do
		local last_status = ""

		function console.SetStatusText(str)
			curses.werase(c.status_window)

			curses.wattron(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS))
			curses.wbkgdset(c.status_window, COLORPAIR_STATUS)
			curses.waddstr(c.status_window, str)
			curses.wattroff(c.status_window, curses.COLOR_PAIR(COLORPAIR_STATUS))

			curses.mvwin(c.status_window, 0, (curses.COLS / 2) - (#str / 2))

			curses.wnoutrefresh(c.status_window)
			dirty = true
			last_status = str
		end

		function console.GetStatusText()
			return last_status
		end
	end

	local function get_commands_for_autocomplete()
		local cmds = {}
		for k in pairs(console.GetCommands()) do
			table.insert(cmds, k)
		end
		return cmds
	end

	c.scroll_command_history = c.scroll_command_history or 0

	local last_key

	function console.HandleKey(key)

		if key == "KEY_PAGEUP" then
			console.SetScroll(console.GetScroll() - curses.LINES / 2)
		elseif key == "KEY_PAGEDOWN" then
			console.SetScroll(console.GetScroll() + curses.LINES / 2)
		end

		if key == "KEY_PASTE" then
			c.markup:Paste(window.GetClipboard())
		elseif key == "KEY_COPY" then
			window.SetClipboard(c.markup:GetText())
		end

		if key == "KEY_TAB" then
			local line = console.GetTextInput()
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

							c.markup:SetText(cmd .. " " .. table.concat(data.args, ",") .. found)
							c.markup:SetCaretPosition(math.huge, 0)
						end
					end
				end
			end
		else
			autocomplete.Query("console", console.GetTextInput())
		end

		if console.input_height == 1 or c.markup:GetText() == "" then
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


		if key == "KEY_ENTER" and last_key ~= "CTL_ENTER" then
			console.SetInputText()
			local line = c.markup:GetText()

			if line ~= "" then
				for key, str in pairs(command_history) do
					if str == line then
						table.remove(command_history, key)
					end
				end

				table.insert(command_history, line)
				serializer.WriteFile("luadata", "%DATA%/cmd_history.txt", command_history)

				c.scroll_command_history = 0
				console.SetInputText()

				if event.Call("ConsoleLineEntered", line) ~= false then
					logn("> ", line)

					console.RunString(line, nil, nil, true)
				end

				c.in_function = false
				c.markup:SetText("")
			end
		end

		if markup_translate[key] then
			c.markup:OnKeyInput(markup_translate[key])
		end

		last_key = key
	end

	function console.HandleChar(char)
		c.markup:OnCharInput(char)
	end

	if RELOAD then
		console.InitializeCurses()
	end

end

return console