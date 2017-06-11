local gine = ... or _G.gine

local function insert(chars, i, what)
	local left_space = chars[i - 1] and chars[i - 1]:find("[%s%p]")
	local right_space = chars[i + 1] and chars[i + 1]:find("[%s%p]")

	if left_space and right_space then
		chars[i] = what
	elseif left_space and not right_space then
		chars[i] = what .. " "
	elseif not left_space and right_space then
		chars[i] =  " " .. what
	elseif not left_space and not right_space then
		chars[i] =  " " .. what .. " "
	end
end

function gine.PreprocessLua(code, add_newlines)
	if code:count("\n") == 0 and code:count("\r") > 0 then
		code = code:gsub("\r", "\n")
	end

	local in_string
	local in_comment

	local multiline_comment_invalid_char_count = 0
	local multiline_comment_start_pos

	local multiline_open = false
	local in_multiline

	local chars = ("   " .. code .. "   "):totable()

	for i = 1, #chars do

		if chars[i] == "\\" then
			chars[i] = "\\" .. chars[i + 1]
			chars[i + 1] = ""
		end

		if not in_string and not in_comment and not in_multiline then
			if (chars[i] == "/" and chars[i + 1] == "/") or (chars[i] == "-" and chars[i + 1] == "-") then
				chars[i] = "-"
				chars[i + 1] = "-"
				in_comment = "line"
			elseif chars[i] == "/" and chars[i + 1] == "*" then
				chars[i] = ""
				chars[i + 1] = "--[EQUAL["
				in_comment = "c_multiline"

				multiline_comment_start_pos = i + 1
				multiline_comment_invalid_char_count = 0
			end
		end

		if not in_string and not in_comment and not in_multiline then
			if chars[i] == "'" or chars[i] == '"' then
				in_string = chars[i]
			end
		elseif in_string then
			-- \\\"
			-- \\"
			-- TODO: my head hurts
			--if chars[i - 1] ~= "\\" or chars[i - 2] == "\\" or chars[i - 3] ~= "\\" then
				if (chars[i] == "'" or chars[i] == '"') and chars[i] == in_string then
					in_string = nil
				end
			--end
		end

		if in_comment then
			if in_comment == "line" and not in_multiline then
				if chars[i] == "\n" then
					in_comment = nil
				end
			elseif in_comment == "c_multiline" then
				if chars[i] == "]" then
					multiline_comment_invalid_char_count = multiline_comment_invalid_char_count + 1
				end
				if chars[i] == "*" and chars[i + 1] == "/" then
					in_comment = nil
					chars[i] = ""
					chars[i + 1] = "]EQUAL]"

					local eq = ("="):rep(multiline_comment_invalid_char_count)
					chars[i + 1] = chars[i + 1]:gsub("EQUAL", eq)
					chars[multiline_comment_start_pos] = chars[multiline_comment_start_pos]:gsub("EQUAL", eq)
				end
			end
		end

		if in_multiline then
			if multiline_open then
				if chars[i] == "=" then
					in_multiline = in_multiline + 1
				elseif chars[i] == "[" then
					multiline_open = false
				end
			elseif chars[i] == "]" then
				local ok = true
				for offset = 1, in_multiline do
					if chars[i + offset] ~= "=" then
						ok = false
					end
				end
				if ok and (in_multiline ~= 0 or chars[i + 1] == "]") then
					in_multiline = nil
					in_comment = nil
				end
			end
		end

		if not in_string and not in_comment and not in_multiline or in_comment == "line" then
			if chars[i] == "[" and (chars[i + 1] == "=" or chars[i + 1] == "[") then
				multiline_open = true
				in_multiline = 0
				if in_comment == "line" and chars[i - 1] == "-" and chars[i - 2] == "-" then
					in_comment = nil

					-- ---[[ comment comment
					if chars[i - 3] == "-" then
						multiline_open = false
						in_multiline = nil
					end
				end
			end
		end

		if not in_string and not in_comment and not in_multiline then
			if chars[i] == "!" and chars[i + 1] == "=" then
				table.remove(chars, i)
				chars[i] = "~="
			elseif chars[i] == "&" and chars[i + 1] == "&" then
				table.remove(chars, i)
				insert(chars, i, "and")
			elseif chars[i] == "|" and chars[i + 1] == "|" then
				table.remove(chars, i)
				insert(chars, i, "or")
			elseif chars[i] == "!" then
				insert(chars, i, "not")
			end
		end
	end

	local code = table.concat(chars):sub(4, -4)

	if code:wholeword("continue") and not loadstring(code) then

		local lex_setup = require("lang.lexer")
		local reader = require("lang.reader")

		local ls = lex_setup(reader.string(code), code)

		local stack = {}

		repeat
			ls:next()
			table.insert(stack, table.copy(ls))
		until ls.token == "TK_eof"

		local found_continue = false
		local lines = code:split("\n")

		for i, ls in ipairs(stack) do
			if ls.token == "TK_name" and ls.tokenval == "continue" then
				found_continue = true
				local start
				local balance = 0

				for i = i, 1, -1 do
					local v = stack[i]

					if v.token == "TK_end" or v.token == "TK_until" then
						balance = balance - 1
					end

					if balance < 0 then
						if v.token == "TK_do" or v.token == "TK_if" or v.token == "TK_for" or v.token == "TK_function" or v.token == "TK_repeat" then
							balance = balance + 1
						end
					else
						if balance == 0 and v.token == "TK_do" or v.token == "TK_repeat" then
							start = v
							start.stack_pos = i
							break
						end
					end
				end

				if not start then
					error("unable to find start of loop")
				end

				local stop

				local balance = 0
				local in_function = false
				local in_loop = false
				local return_token

				for i = start.stack_pos, #stack do
					local v = stack[i]

					if v.token == "TK_do" or v.token == "TK_if" or v.token == "TK_function" or v.token == "TK_repeat" then
						balance = balance + 1

						if v.token == "TK_function" then
							in_function = balance
						end

						if v.token == "TK_do" or v.token == "TK_repeat" then
							if i ~= start.stack_pos then
								in_loop = balance
							end
						end
					elseif v.token == "TK_end" or v.token == "TK_until" then

						if v.token == "TK_end" and in_function == balance then
							in_function = false
						end

						if (v.token == "TK_end" or v.token == "TK_until") and in_loop == balance then
							in_loop = false
						end

						balance = balance - 1
					end

					if v.token == "TK_return" or v.token == "TK_break" then
						if not in_function and not in_loop then
							return_token = v
						end
					end

					if balance == 0 then
						stop = v
						break
					end
				end

				if not stop then
					error("unable to find stop of loop")
				end

				lines[ls.linenumber] = lines[ls.linenumber]:gsub("continue", "goto CONTINUE")

				if return_token and not return_token.fixed then
					local space = " "

					for i = return_token.linenumber - 1, 1, -1 do
						if lines[i]:trim() ~= "" then
							space = lines[i]
							break
						end
					end

					space = space:match("^(%s*)") or " "
					lines[return_token.linenumber] = space .. "do ".. lines[return_token.linenumber]:trim() .. " end"
					return_token.fixed = true
				end

				if stop and not stop.fixed then
					local space = " "

					for i = stop.linenumber - 1, 1, -1 do
						if lines[i]:trim() ~= "" then
							space = lines[i]
							break
						end
					end

					space = space:match("^(%s*)") or " "

					lines[stop.linenumber] = space .. "::CONTINUE::" .. (add_newlines and "\n" or "") .. lines[stop.linenumber]

					stop.fixed = true
				end
			end
		end

		code = table.concat(lines, "\n")

		if not found_continue then
			error("unable to find continue keyword")
		end
	end

	code = code:gsub("DEFINE_BASECLASS", "local BaseClass = baseclass.Get")

	return code
end

event.AddListener("PreLoadString", "glua_preprocess", function(code, path)
	if path:lower():find("steamapps/common/garrysmod/garrysmod/", nil, true) or path:find("%.gma") then
		if not code:find("DEFINE_BASECLASS", nil, true) and loadstring(code) then return code end

		local ok, msg = pcall(gine.PreprocessLua, code)

		if not ok then
			logn(msg)
			return
		end

		code = msg

		if not loadstring(code) then vfs.Write("glua_preprocess_error.lua", code) end

		return code
	end
end)
