local repl = _G.repl or {}
repl.buffer = repl.buffer or ""
repl.command_history = repl.command_history or
	serializer.ReadFile("luadata", "data/cmd_history.txt") or
	{}

for k, v in ipairs(repl.command_history) do
	if type(v) ~= "string" then
		repl.command_history = {}

		break
	end
end

repl.scroll_command_history = repl.scroll_command_history or 0
local terminal = system.GetTerminal()

function repl.RenderInput()
	local w, h = terminal.GetSize()
	local x, y = repl.GetCaretPosition()
	-- clear the input row
	repl.WriteStringToScreen(0, y, (" "):rep(w))
	repl.SetCaretPosition(0, y)
	repl.WriteStringToScreen(0, y, repl.buffer)
	repl.SetCaretPosition(x, y)
end

function repl.MoveCaret(ox, oy)
	local x, y = repl.GetCaretPosition()
	repl.SetCaretPosition(x + ox, y + oy)
end

if terminal.WriteStringToScreen then
	repl.WriteStringToScreen = terminal.WriteStringToScreen
else
	function repl.WriteStringToScreen(x, y, str)
		local x_, y_ = repl.GetCaretPosition()
		repl.SetCaretPosition(x, y)
		repl.Write(str)
		repl.SetCaretPosition(x_, y_)
	end
end

function repl.CharInput(str)
	event.Call("ReplCharInput", str)

	for _, str in ipairs(str:utf8_to_list()) do
		local x, y = repl.GetCaretPosition()
		repl.buffer = repl.buffer:utf8_sub(0, x - 1) .. str .. repl.buffer:utf8_sub(x + str:utf8_length() - 1, -1)
		repl.MoveCaret(str:utf8_length(), 0)
		repl.RenderInput()
	end

	repl.Flush()
end

function repl.SetConsoleTitle(str)
	if WINDOW and window.IsOpen() then return window.SetTitle(str) end

	return terminal.SetTitle(str)
end

repl.caret_x = 0
repl.caret_y = 0

function repl.SetCaretPosition(x, y)
	repl.caret_x = math.max(x, 1)
	repl.caret_y = math.max(y, 1)
end

function repl.GetCaretPosition()
	return repl.caret_x, repl.caret_y
end

do
	local buf = {}

	function repl.Flush()
		if not buf[1] then return end

		if repl.move_caret_to_tail then
			local tx, ty = repl.GetTailPosition()
			repl.SetCaretPosition(repl.move_caret_to_tail, ty)
			repl.move_caret_to_tail = nil
		end

		terminal.EnableCaret(false)
		local str = list.concat(buf)
		list.clear(buf)
		repl.SetCaretPositionReal(0, repl.caret_y)
		repl.WriteNow((" "):rep(repl.buffer:utf8_length() + 1))
		repl.SetCaretPositionReal(0, repl.caret_y - 1)
		repl.WriteNow(str)
		repl.SetCaretPositionReal(repl.caret_x, repl.caret_y)

		if repl.buffer ~= "" then
			repl.Write("\27[s\27[" .. repl.caret_y .. ";0f")

			do
				local buf = repl.buffer .. " "
				--repl.WriteStringToScreen(0, repl.caret_y, (" "):rep(100))
				repl.StyledWrite(buf:utf8_sub(0, repl.caret_x - 1), true, true)
				terminal.BackgroundColor(0.5, 0.5, 0.5)
				--repl.Write("\27[47m")
				repl.StyledWrite(buf:utf8_sub(repl.caret_x, repl.caret_x), true, true)
				--repl.SetBackgroundColor(0,0,0)
				repl.Write("\27[0m")
				repl.StyledWrite(buf:utf8_sub(repl.caret_x + 1), true, true)
				repl.Write("\27[u")
			end

			local str = list.concat(buf)
			list.clear(buf)
			repl.WriteNow(str)
		end

		terminal.EnableCaret(true)
	end

	function terminal.OnWrite(str)
		if not repl.write_now then
			list.insert(buf, str)
			return false
		end

		terminal.Write(str)
	end

	function repl.Write(str)
		terminal.Write(str)
	end

	function repl.WriteNow(str)
		repl.write_now = true
		terminal.Write(str)
		repl.write_now = false
	end

	function repl.SetCaretPositionReal(x, y)
		repl.write_now = true
		terminal.SetCaretPosition(x, y)
		repl.write_now = false
	end

	function repl.GetTailPosition()
		local tbl = list.concat(buf):split("\n")
		local y = #tbl + repl.caret_y - 1
		local x = tbl[#tbl]:utf8_length()
		return x, y
	end
end

local set_color

do
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

	local colors = {
		comment = "#8e8e8e",
		number = "#4453da",
		letter = "#d6d6d6",
		symbol = "#da4453",
		error = "#da4453",
		keyword = "#2980b9",
		string = "#27ae60",
		unknown = "#da4453",
	}

	for key, hex in pairs(colors) do
		local r, g, b = hex:match("#?(..)(..)(..)")
		r = tonumber("0x" .. r)
		g = tonumber("0x" .. g)
		b = tonumber("0x" .. b)
		colors[key] = {r, g, b}
	end

	local last_color
	set_color = function(what)
		if not colors[what] then what = "letter" end

		if what ~= last_color then
			local c = colors[what]
			terminal.ForegroundColorFast(c[1], c[2], c[3])
			last_color = what
		end
	end

	function repl.ClearScreen()
		terminal.Clear()
	end

	function repl.NoColors(b)
		repl.no_color = b
	end

	local table_concatrange = list.concat_range
	local oh = oh

	function repl.StyledWrite(str, dont_move)
		local x, y

		if not dont_move then x, y = repl.GetCaretPosition() end

		if repl.no_color then
			repl.Write(str)
		else
			last_color = nil
			local code = nl.Code(str, "repl")
			local tokens = nl.Lexer(code):GetTokens()

			for _, token in ipairs(tokens) do
				for _, v in ipairs(token.whitespace) do
					if v.type == "line_comment" or v.type == "multiline_comment" then
						set_color("comment")
					end

					repl.Write(v.value)
				end

				if
					type == "letter" and
					nl.runtime_syntax:IsKeyword(token) or
					nl.typesystem_syntax:IsKeyword(token) or
					nl.runtime_syntax:IsNonStandardKeyword(token) or
					nl.typesystem_syntax:IsNonStandardKeyword(token) or
					nl.runtime_syntax:IsKeywordValue(token) or
					nl.typesystem_syntax:IsKeywordValue(token)
				then
					set_color("keyword")
				else
					set_color(token.type)
				end

				repl.Write(token.value)

				if type == "end_of_file" then break end
			end
		--set_color("letter")
		end

		if not dont_move then repl.move_caret_to_tail = x end
	end
end

local function find_next_word(buffer, x, dir)
	local str = dir == "left" and
		buffer:utf8_sub(0, x - 1):reverse() or
		buffer:utf8_sub(x + 1, -1)

	if str:find("^%s", 0) then
		return str:find("%S")
	elseif str:find("^%p", 0) then
		return str:find("%P", 0) or str:find("^%p+$", 0)
	end

	return str:find("%s", 0) or str:find("%p", 0) or str:utf8_length() + 1
end

function repl.InputLua(str)
	local ok, err = xpcall(function()
		local compiler = nl.Compiler(str, "repl")

		function compiler:OnDiagnostic(code, msg, severity, start, stop, node, ...)
			set_color("error")
			repl.Write((" "):rep(start + 1) .. ("^"):rep(stop - start + 1))
			set_color("letter")
			repl.StyledWrite(" " .. msg .. "\n")
		end

		print(compiler)
		local code = compiler:Emit()
		repl.Echo(code)
		local func, err = loadstring(code)

		if func then
			local func, res = system.pcall(func)

			if not func then
				--res = res:match("^.-:%d+:%s+(.+)")
				set_color("error")
				logn(res)
				set_color("letter")
			end
		elseif #tokenizer.errors == 0 and #parser.errors == 0 then
			set_color("letter")
			repl.Write("transpiled output loadstring error: ")
			set_color("error")
			repl.Write(err:match("%]:%d+: (.+)"))
			repl.Write("\n")
		end
	end, function(error)
		repl.Echo(str)
		set_color("error")
		repl.Write(error)
		repl.Write("\n")
		print(debug.traceback())
	end)
end

function repl.Echo(str)
	local x, y = repl.GetCaretPosition()
	local w, h = terminal.GetSize()
	repl.WriteStringToScreen(0, y, (" "):rep(w))
	repl.WriteStringToScreen(0, y, (" "):rep(utf8.length(str)))
	repl.StyledWrite("> " .. str .. "\n", true)
	repl.SetCaretPosition(0, y + 1)
	repl.Flush()
end

function repl.KeyPressed(key)
	local x, y = repl.GetCaretPosition()
	local w, h = terminal.GetSize()
	event.Call("ReplCharInput", key)

	if key == "enter" then
		local str = repl.buffer
		repl.buffer = ""

		--	repl.WriteStringToScreen(0, y, (" "):rep(w))
		if str == "detach" and os.getenv("GOLUWA_TMUX") then
			repl.Echo(str)
			_OLD_G.os.execute("tmux detach")
		elseif str == "clear" then
			repl.Echo(str)
			repl.ClearScreen()
			repl.SetCaretPosition(0, 0)
		elseif str:starts_with("exit") then
			repl.Echo(str)
			system.ShutDown(tonumber(str:match("exit (%d+)")) or 0)
		elseif str ~= "" then
			if commands and commands.RunString then
				repl.Echo(str)
				commands.RunString(str)
			else
				repl.InputLua(str)
			end
		end

		local x, y = repl.GetTailPosition()
		repl.Flush()
		repl.SetCaretPosition(x, y)
		repl.Flush()

		-- write the buffer
		for i, str in ipairs(repl.command_history) do
			if str == buffer then list.remove(repl.command_history, i) end
		end

		list.insert(repl.command_history, str)
		serializer.WriteFile("luadata", "data/cmd_history.txt", repl.command_history)
		repl.scroll_command_history = 0
	elseif key == "delete" then
		repl.buffer = repl.buffer:utf8_sub(0, x - 1) .. repl.buffer:utf8_sub(x + 1, -1)
	elseif key == "up" or key == "down" then
		if key == "up" then
			repl.scroll_command_history = repl.scroll_command_history - 1
		else
			repl.scroll_command_history = repl.scroll_command_history + 1
		end

		local str = repl.command_history[repl.scroll_command_history % #repl.command_history + 1]

		if str then
			repl.buffer = str
			repl.SetCaretPosition(repl.buffer:utf8_length() + 1, y)
		end
	elseif key == "left" then
		repl.MoveCaret(-1, 0)
	elseif key == "right" then
		repl.MoveCaret(1, 0)
	elseif key == "home" then
		repl.SetCaretPosition(1, y)
	elseif key == "end" then
		repl.SetCaretPosition(repl.buffer:utf8_length() + 1, y)
	elseif key == "ctrl_right" then
		local offset = find_next_word(repl.buffer, x, "right")

		if offset then repl.MoveCaret(offset + 1, 0) end
	elseif key == "ctrl_left" then
		local offset = find_next_word(repl.buffer, x, "left")

		if offset then repl.MoveCaret(-offset + 1, 0) end
	elseif key == "backspace" then
		repl.buffer = repl.buffer:utf8_sub(0, math.max(x - 2, 0)) .. repl.buffer:utf8_sub(x, -1)
		repl.MoveCaret(-1, 0)
	elseif key == "ctrl_backspace" then
		local offset = find_next_word(repl.buffer, x, "left")

		if offset then
			repl.buffer = repl.buffer:utf8_sub(0, x - offset) .. repl.buffer:utf8_sub(x, -1)
			repl.SetCaretPosition(x - offset + 1, y)
		end
	elseif key == "ctrl_delete" then
		local offset = find_next_word(repl.buffer, x, "right")

		if offset then
			repl.buffer = repl.buffer:utf8_sub(0, x - 1) .. repl.buffer:utf8_sub(x + offset, -1)
		end
	elseif key == "cmd_backspace" then
		repl.buffer = ""
	elseif key ~= "ctrl_c" then
		llog("unhandled key %s", key)
	end

	if key == "ctrl_c" then
		local str = repl.buffer
		repl.buffer = ""
		--	repl.WriteStringToScreen(0, y, (" "):rep(w))
		repl.WriteStringToScreen(0, y, (" "):rep(utf8.length(str)))
		repl.SetCaretPositionReal(0, y)
		repl.StyledWrite("> " .. str, true)
		repl.Flush()
		repl.WriteNow("\n")
		repl.SetCaretPosition(0, y + 1)
		repl.Flush()

		if repl.ctrl_c_exit then
			if repl.ctrl_c_exit > system.GetTime() then
				if os.getenv("GOLUWA_TMUX") then
					_OLD_G.os.execute("tmux detach")
				else
					system.ShutDown(0)
				end
			else
				repl.ctrl_c_exit = nil
			end
		else
			repl.ctrl_c_exit = system.GetTime() + 0.5
			local x, y = repl.GetCaretPosition()

			if os.getenv("GOLUWA_TMUX") then
				repl.WriteNow("ctrl+c again to detach\n")
			else
				repl.WriteNow("ctrl+c again to exit\n")
			end

			repl.SetCaretPosition(0, y + 1)
			repl.Flush()
		end
	else
		repl.ctrl_c_exit = nil
	end

	local x, y = repl.GetCaretPosition()
	x = math.min(x, repl.buffer:utf8_length() + 1)
	repl.SetCaretPosition(x, y)
	repl.RenderInput()
	repl.Flush()
	return true
end

function repl.Start()
	terminal.Initialize()
	repl.caret_x, repl.caret_y = terminal.GetCaretPosition()
	repl.started = true

	do
		local last_report = 0
		local last_downloaded = 0

		event.AddListener("DownloadChunkReceived", "downprog_title", function(client, data, current_length, header)
			if WINDOW and window.IsOpen() then return e.EVENT_DESTROY end

			if not header["content-length"] then return end

			if current_length == header["content-length"] then return end

			if last_report < system.GetElapsedTime() then
				system.SetConsoleTitle(
					client.url .. " progress: " .. math.round((current_length / header["content-length"]) * 100, 3) .. "%" .. " speed: " .. utility.FormatFileSize(current_length - last_downloaded),
					client.url
				)
				last_downloaded = current_length
				last_report = system.GetElapsedTime() + 4
			end
		end)

		event.AddListener("DownloadStop", "downprog_title", function(client, data, msg)
			if WINDOW and window.IsOpen() then return e.EVENT_DESTROY end

			system.SetConsoleTitle(nil, client.url)
		end)
	end
end

function repl.Stop()
	repl.Flush()
	terminal.Shutdown()
	repl.started = false
end

function repl.Update()
	if not repl.started then error("repl not initialized") end

	--if math.random() > 0.99 then print(os.clock()) end
	if repl.move_caret_to_tail then
		local tx, ty = repl.GetTailPosition()
		repl.SetCaretPosition(repl.move_caret_to_tail, ty)
		repl.move_caret_to_tail = nil
	end

	local events = terminal.ReadEvents()

	while events[1] do
		local what, arg = unpack(list.remove(events, 1))

		if what == "string" and arg:ends_with("__ENTERHACK__") then
			repl.CharInput(arg:sub(0, -#"__ENTERHACK__" - 1))
			repl.KeyPressed("enter")
			return
		end

		if what == "string" then
			repl.CharInput(arg)
		else
			repl.KeyPressed(what)
		end
	end
end

function repl.OSExecute(...)
	if not repl.started then return os.execute(...) end

	repl.Flush()
	repl.Stop()
	local ok, res, a, b = pcall(_OLD_G.os.execute, ...)
	repl.Start()

	if not ok then error(res, 2) end

	return res, a, b
end

local next_update = 0

function repl.UpdateNow()
	next_update = 0
end

function repl.IsFocused()
	if os.getenv("GOLUWA_TMUX") then
		local pipe, err = io.popen("tmux ls")

		if pipe then
			local str = pipe:read("*all")
			pipe:close()

			for _, line in ipairs(str:split("\n")) do
				if line:find("goluwa", nil, true) and line:ends_with("(attached)") then
					return true
				end
			end
		end

		return false
	end

	return true
end

event.AddListener("Update", "repl", function()
	if not repl.started then
		event.RemoveListener("Update", "repl")
		return
	end

	local ok, err = system.pcall(repl.Update)

	if not ok then
		repl.Stop()
		system.OnError(str)
		event.RemoveListener("Update", "repl")
	end

	local time = system.GetElapsedTime()

	if next_update < time then
		repl.Flush()
		next_update = time + 1 / 30
	end
end)

if os.getenv("GOLUWA_TMUX") then
	os.remove(R("shared/") .. "tmux_log.txt")
	os.execute(
		"ln -s " .. logfile.GetOutputPath("console") .. " " .. R("shared/") .. "tmux_log.txt"
	)
end

return repl