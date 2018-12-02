local repl = _G.repl or {}

repl.buffer = repl.buffer or ""
repl.command_history = repl.command_history or serializer.ReadFile("luadata", "data/cmd_history.txt") or {}
for k,v in ipairs(repl.command_history) do
	if type(v) ~= "string" then
		repl.command_history = {}
		break
	end
end
repl.scroll_command_history = repl.scroll_command_history or 0

local terminal = system.GetTerminal()

function repl.RenderInput()
	local w,h = terminal.GetSize()
	local x,y = repl.GetCaretPosition()

	-- clear the input row
	repl.WriteStringToScreen(0, y, (" "):rep(w))

	repl.SetCaretPosition(0,y)
	repl.WriteStringToScreen(0, y, repl.buffer)
	repl.SetCaretPosition(x,y)
end

function repl.MoveCaret(ox, oy)
	local x, y = repl.GetCaretPosition()
	repl.SetCaretPosition(x + ox, y + oy)
end

if terminal.WriteStringToScreen then
	repl.WriteStringToScreen = terminal.WriteStringToScreen
else
	function repl.WriteStringToScreen(x, y, str)
		local x_,y_ = repl.GetCaretPosition()

		repl.SetCaretPosition(x,y)
		repl.Write(str)
		repl.SetCaretPosition(x_,y_)
	end
end

function repl.CharInput(str)
	local x, y = repl.GetCaretPosition()
	repl.buffer = repl.buffer:usub(0, x - 1) .. str .. repl.buffer:usub(x + str:ulen() - 1, -1)
	repl.MoveCaret(str:ulen(), 0)
	repl.RenderInput()
end

repl.caret_x = 0
repl.caret_y = 0

function repl.SetCaretPosition(x,y)
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

		terminal.EnableCaret(false)

		local str = table.concat(buf)
		table.clear(buf)

		repl.WriteNow(str)
		repl.SetCaretPositionReal(repl.caret_x, repl.caret_y)

		if repl.buffer ~= "" then
			repl.Write("\27[s\27[" .. repl.caret_y .. ";0f")
			do
				local buf = repl.buffer .. " "
				--repl.WriteStringToScreen(0, repl.caret_y, (" "):rep(buf:ulen() + 1))

				repl.StyledWrite(buf:usub(0, repl.caret_x-1), true)
				terminal.BackgroundColor(0.5, 0.5, 0.5)
				--repl.Write("\27[47m")
				repl.StyledWrite(buf:usub(repl.caret_x, repl.caret_x), true)
				--repl.SetBackgroundColor(0,0,0)
				repl.Write("\27[0m")
				repl.StyledWrite(buf:usub(repl.caret_x+1), true)
				repl.Write("\27[u")
			end

			local str = table.concat(buf)
			table.clear(buf)
			repl.WriteNow(str)
		end

		terminal.EnableCaret(true)
	end

	function terminal.OnWrite(str)
		if not repl.write_now then
			table.insert(buf, str)
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

	function repl.SetCaretPositionReal(x,y)
		repl.write_now = true
		terminal.SetCaretPosition(x,y)
		repl.write_now = false
	end

	function repl.GetTailPosition()
		local str = table.concat(buf)
		local y = str:count("\n") + repl.caret_y
		local x = (str:match(".+\n(.*)") or ""):ulen()

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

	local keywords = {
		"and", "break", "do", "else", "elseif", "end",
		"false", "for", "function", "if", "in", "local",
		"nil", "not", "or", "repeat", "return", "then",
		"true", "until", "while", "goto", "...",
	}
	local temp = {}
	for k,v in ipairs(keywords) do
		temp[v] = true
	end
	keywords = temp

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
		local r,g,b = hex:match("#?(..)(..)(..)")
		r = tonumber("0x" .. r)
		g = tonumber("0x" .. g)
		b = tonumber("0x" .. b)
		colors[key] = {r/255,g/255,b/255}
	end
	local last_color
	set_color = function(what)
		if what ~= last_color then
			if colors[what] then
				terminal.ForegroundColor(unpack(colors[what]))
				last_color = what
			else
				terminal.ForegroundColor(unpack(colors.letter))
				last_color = "letter"
			end
		end
	end

	function repl.ClearScreen()
		terminal.Clear()
	end

	function repl.NoColors(b)
		repl.no_color = b
	end

	function repl.StyledWrite(str, dont_move)
		local x,y, w,h
		if not dont_move then
			x,y = repl.GetCaretPosition()
			-- clear the input line and reset the caret position
			repl.WriteStringToScreen(0, y, (" "):rep(repl.buffer:ulen()))
			repl.SetCaretPositionReal(0,y)
			--repl.Write("\27[M")
		end

		if repl.no_color then
			repl.Write(str)
		else
			last_color = nil

			local tokenizer = oh.Tokenizer(str)

			while true do
				local type, start, stop, whitespace = tokenizer:ReadToken()

				for _, v in ipairs(whitespace) do
					if v.type == "line_comment" or v.type == "multiline_comment" then
						set_color("comment")
					end

					repl.Write(str:usub(v.start, v.stop))
				end

				local chunk = str:usub(start, stop)

				if type == "letter" and keywords[chunk]  then
						set_color("keyword")
					else
					set_color(type)
				end

				repl.Write(chunk)

				if type == "end_of_file" then break end
			end

			set_color("letter")
		end

		if not dont_move then
			local tx, ty = repl.GetTailPosition()
			repl.SetCaretPosition(x,ty)
			--repl.SetCaretPositionReal(tx,ty)
		--	repl.StyledWrite(repl.buffer, true)
		end
	end
end

local function find_next_word(buffer, x, dir)
    local str = dir == "left" and buffer:usub(0, x-1):reverse() or buffer:usub(x+1, -1)

    if str:find("^%s", 0) then
        return str:find("%S")
    elseif str:find("^%p", 0) then
        return str:find("%P", 0) or str:find("^%p+$", 0)
    end

    return str:find("%s", 0) or str:find("%p", 0) or str:ulen() + 1
end

function repl.KeyPressed(key)
	local x, y = repl.GetCaretPosition()
	local w, h = terminal.GetSize()

	if key == "enter" then
		local str = repl.buffer
		repl.buffer = ""

	--	repl.WriteStringToScreen(0, y, (" "):rep(w))
		repl.WriteStringToScreen(0, y, (" "):rep(utf8.length(str)))
		repl.SetCaretPositionReal(0,y)
		repl.StyledWrite("> " .. str, true)
		repl.Flush()
		repl.WriteNow("\n")
		repl.SetCaretPosition(0,y+1)
		repl.Flush()

		if str == "detach" and os.getenv("GOLUWA_TMUX") then
			_OLD_G.os.execute("tmux detach")
		elseif str == "clear" then
			repl.ClearScreen()
			repl.SetCaretPosition(0,0)
		elseif str:startswith("exit") then
			system.ShutDown(tonumber(str:match("exit (%d+)")) or 0)
		elseif str ~= "" then
			if commands and commands.RunString then
				commands.RunString(str)
			else
				local ok, err = pcall(function()
				local func, err = loadstring(str)
				if func then
					local func, res = system.pcall(func)
					if not func then
						--res = res:match("^.-:%d+:%s+(.+)")

						set_color("error")
						logn(res)
						set_color("letter")
					end
				else
					local tokenizer = oh.Tokenizer(str)
					local tokens = tokenizer:GetTokens()
					local parser = oh.Parser(tokens)
					local ast = parser:BuildAST(tokens)

					local function print_errors(errors, only_first)
						for _, v in ipairs(errors) do
							set_color("error")
							repl.Write((" "):rep(v.start + 1) .. ("^"):rep(v.stop - v.start + 1))
							set_color("letter")
							repl.StyledWrite(" " ..  v.msg)
							repl.Write("\n")
							if only_first then break end
						end
					end

					print_errors(tokenizer.errors)
					print_errors(parser.errors, true)
					--print(oh.GetErrorsFormatted(parser.errors, str, ""))


					--err = err:match("^.-:%d+:%s+(.+)")
					--set_color("error")
					--repl.Write(err .. "\n")
					--set_color("letter")
				end
				end)
				if not ok then repl.Write(err .. "\n") end
			end
		end
		local x,y = repl.GetTailPosition()
		repl.Flush()
		repl.SetCaretPosition(x,y)
		repl.Flush()

		-- write the buffer

		for i, str in ipairs(repl.command_history) do
			if str == buffer then
				table.remove(repl.command_history, i)
			end
		end

		table.insert(repl.command_history, str)
		serializer.WriteFile("luadata", "data/cmd_history.txt", repl.command_history)
		repl.scroll_command_history = 0
	elseif key == "delete" then
		repl.buffer = repl.buffer:usub(0, x-1) .. repl.buffer:usub(x+1, -1)
	elseif key == "up" or key == "down" then
		if key == "up" then
			repl.scroll_command_history = repl.scroll_command_history - 1
		else
			repl.scroll_command_history = repl.scroll_command_history + 1
		end
		local str = repl.command_history[repl.scroll_command_history%#repl.command_history+1]
		if str then
			repl.buffer = str
			repl.SetCaretPosition(repl.buffer:ulen() + 1, y)
		end
	elseif key == "left" then
		repl.MoveCaret(-1, 0)
	elseif key == "right" then
		repl.MoveCaret(1, 0)
	elseif key == "home" then
		repl.SetCaretPosition(1, y)
	elseif key == "end" then
		repl.SetCaretPosition(repl.buffer:ulen() + 1, y)
	elseif key == "ctrl_right" then
		local offset = find_next_word(repl.buffer, x, "right")
		if offset then
			repl.MoveCaret(offset + 1, 0)
		end
	elseif key == "ctrl_left" then
		local offset = find_next_word(repl.buffer, x, "left")

		if offset then
			repl.MoveCaret(-offset + 1, 0)
		end
	elseif key == "backspace" then
		repl.buffer = repl.buffer:usub(0, math.max(x - 2, 0)) .. repl.buffer:usub(x, -1)
		repl.MoveCaret(-1, 0)
	elseif key == "ctrl_backspace" then
		local offset = find_next_word(repl.buffer, x, "left")
		if offset then
			repl.buffer = repl.buffer:usub(0, x - offset) .. repl.buffer:usub(x, -1)
			repl.SetCaretPosition(x - offset + 1, y)
		end
	elseif key == "ctrl_delete" then
		local offset = find_next_word(repl.buffer, x, "right")

		if offset then
			repl.buffer = repl.buffer:usub(0, x - 1) .. repl.buffer:usub(x + offset, -1)
		end
	elseif key ~= "ctrl_c" then
		llog("unhandled key %s", key)
	end

	if key == "ctrl_c" then
		local str = repl.buffer
		repl.buffer = ""

	--	repl.WriteStringToScreen(0, y, (" "):rep(w))
		repl.WriteStringToScreen(0, y, (" "):rep(utf8.length(str)))
		repl.SetCaretPositionReal(0,y)
		repl.StyledWrite("> " .. str, true)
		repl.Flush()
		repl.WriteNow("\n")
		repl.SetCaretPosition(0,y+1)
		repl.Flush()

		if repl.ctrl_c_exit then
			if repl.ctrl_c_exit > system.GetTime() then
				system.ShutDown(0)
			else
				repl.ctrl_c_exit = nil
			end
		else
			repl.ctrl_c_exit = system.GetTime() + 0.5

			local x,y = repl.GetCaretPosition()

			repl.WriteNow("ctrl+c again to exit\n")
			repl.SetCaretPosition(0,y+1)
			repl.Flush()
		end
	else
		repl.ctrl_c_exit = nil
	end

	local x, y = repl.GetCaretPosition()
	x = math.min(x, repl.buffer:ulen() + 1)
	repl.SetCaretPosition(x, y)

	repl.RenderInput()
	repl.Flush()

	return true
end

function repl.Start()
	terminal.Initialize()
	repl.caret_x, repl.caret_y = terminal.GetCaretPosition()
	repl.started = true

end

function repl.Stop()
	terminal.Shutdown()
	repl.started = false
end

function repl.Update()
	if not repl.started then error("repl not initialized") end
	--if math.random() > 0.99 then print(os.clock()) end

	local what, arg = terminal.ReadEvent()

	if what then
		if what == "string" then
			repl.CharInput(arg)
		else
			repl.KeyPressed(what)
		end
	end
end

function repl.OSExecute(...)
	repl.Flush()
	repl.Stop()
	local ok, res = pcall(_OLD_G.os.execute, ...)
	repl.Start()
	if not ok then error(res, 2) end
	return res
end

local next_update = 0

function repl.UpdateNow()
	next_update = 0
end

event.AddListener("Update", "repl", function()
	local ok, err = system.pcall(repl.Update)

	if not ok then
		repl.Stop()
		system.OnError(str)
		event.RemoveListener("Update", "repl")
	end

	local time = system.GetElapsedTime()

	if next_update < time then
		repl.Flush()
		next_update = time + 1/30
	end
end)


if os.getenv("GOLUWA_TMUX") then
	os.remove(R("shared/") .. "tmux_log.txt")
	os.execute("ln -s " .. getlogpath() .. " " .. R("shared/") .. "tmux_log.txt")
end


return repl