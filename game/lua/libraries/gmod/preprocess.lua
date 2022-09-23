local gine = ... or _G.gine
local char_class = "[" .. string.buildclass("%p", "%s", function(char)
		if char == "_" then return false end
	end) .. "]"

local function insert(chars, i, what)
	local left_space = chars[i - 1] and chars[i - 1]:find(char_class)
	local right_space = chars[i + 1] and chars[i + 1]:find(char_class)

	if left_space and right_space then
		chars[i] = what
	elseif left_space and not right_space then
		chars[i] = what .. " "
	elseif not left_space and right_space then
		chars[i] = " " .. what
	elseif not left_space and not right_space then
		chars[i] = " " .. what .. " "
	end
end

function gine.PreprocessLua(code, add_newlines)
	if not code:find("DEFINE_BASECLASS", nil, true) and loadstring(code) then
		return code
	end

	if not code:find("\n", nil, true) and code:find("\r", nil, true) then
		code = code:gsub("\r", "\n")
	end

	local in_string
	local in_comment
	local multiline_comment_invalid_char_count = 0
	local multiline_comment_start_pos
	local multiline_open = false
	local in_multiline
	local chars = ("   " .. code .. "   "):to_list()

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
			if chars[i] == "'" or chars[i] == "\"" then in_string = chars[i] end
		elseif in_string then
			-- \\\"
			-- \\"
			-- TODO: my head hurts
			--if chars[i - 1] ~= "\\" or chars[i - 2] == "\\" or chars[i - 3] ~= "\\" then
			if (chars[i] == "'" or chars[i] == "\"") and chars[i] == in_string then
				in_string = nil
			end
		--end
		end

		if in_comment then
			if in_comment == "line" and not in_multiline then
				if chars[i] == "\n" then in_comment = nil end
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
					if chars[i + offset] ~= "=" then ok = false end
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
				list.remove(chars, i)
				chars[i] = "~="
			elseif chars[i] == "&" and chars[i + 1] == "&" then
				list.remove(chars, i)
				insert(chars, i, "and")
			elseif chars[i] == "|" and chars[i + 1] == "|" then
				list.remove(chars, i)
				insert(chars, i, "or")
			elseif chars[i] == "!" then
				insert(chars, i, "not")
			end
		end
	end

	local code = list.concat(chars):sub(4, -4)

	if code:whole_word("continue") and not loadstring(code) then
		local tokens = {}
		local CONTINUE_LABEL = "CONTINUE"

		while code:find("::" .. CONTINUE_LABEL .. "::", nil, true) do
			CONTINUE_LABEL = CONTINUE_LABEL .. "_" .. tostring(math.random(1, 1000000))
		end

		local ls = require("lang.lexer")(require("lang.reader").string(code), code)

		for i = 1, math.huge do
			ls:next()
			tokens[i] = {token = ls.token, tokenval = ls.tokenval, linenumber = ls.linenumber}

			if ls.token == "TK_eof" then break end
		end

		local found_continue = false
		local lines = code:split("\n")

		for i, token in ipairs(tokens) do
			if token.token == "TK_name" and token.tokenval == "continue" then
				found_continue = true
				local start_token
				local stop_token
				local return_token
				local balance = 0

				for i = i, 1, -1 do
					local val = tokens[i]

					if val.token == "TK_end" or val.token == "TK_until" then
						balance = balance - 1
					end

					if balance < 0 then
						if
							val.token == "TK_do" or
							val.token == "TK_if" or
							val.token == "TK_for" or
							val.token == "TK_function" or
							val.token == "TK_repeat"
						then
							balance = balance + 1
						end
					else
						if balance == 0 and val.token == "TK_do" or val.token == "TK_repeat" then
							start_token = val
							start_token.stack_pos = i

							break
						end
					end
				end

				if not start_token then error("unable to find start of loop") end

				local balance = 0
				local in_function = false
				local in_loop = false

				for i = start_token.stack_pos, #tokens do
					local token = tokens[i]

					if
						token.token == "TK_do" or
						token.token == "TK_if" or
						token.token == "TK_function" or
						token.token == "TK_repeat"
					then
						balance = balance + 1

						if token.token == "TK_function" then in_function = balance end

						if token.token == "TK_do" or token.token == "TK_repeat" then
							if i ~= start_token.stack_pos then in_loop = balance end
						end
					elseif token.token == "TK_end" or token.token == "TK_until" then
						if token.token == "TK_end" and in_function == balance then
							in_function = false
						end

						if (token.token == "TK_end" or token.token == "TK_until") and in_loop == balance then
							in_loop = false
						end

						balance = balance - 1
					end

					if token.token == "TK_return" or token.token == "TK_break" then
						if not in_function and not in_loop then return_token = token end
					end

					if balance == 0 then
						stop_token = token

						break
					end
				end

				if not stop_token then error("unable to find stop of loop") end

				lines[token.linenumber] = lines[token.linenumber]:gsub("continue", "goto " .. CONTINUE_LABEL)

				if return_token and not return_token.fixed then
					local space = " "

					for i = return_token.linenumber - 1, 1, -1 do
						if lines[i]:trim() ~= "" then
							space = lines[i]

							break
						end
					end

					space = space:match("^(%s*)") or " "
					lines[return_token.linenumber] = space .. "do " .. lines[return_token.linenumber]:trim() .. " end"
					return_token.fixed = true
				end

				if stop_token and not stop_token.fixed then
					local space = " "

					for i = stop_token.linenumber - 1, 1, -1 do
						if lines[i]:trim() ~= "" then
							space = lines[i]

							break
						end
					end

					space = space:match("^(%s*)") or " "
					lines[stop_token.linenumber] = space .. "::" .. CONTINUE_LABEL .. "::" .. (
							add_newlines and
							"\n" or
							""
						) .. lines[stop_token.linenumber]
					stop_token.fixed = true
				end
			end
		end

		if not found_continue then error("unable to find continue keyword") end

		code = list.concat(lines, "\n")
	end

	code = code:gsub("DEFINE_BASECLASS", "local BaseClass = baseclass.Get")
	return code
end