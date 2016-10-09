local gmod = ... or _G.gmod

function gmod.PreprocessLua(code, debug)
	local in_string
	local in_comment

	local multiline_open = false
	local in_multiline

	local chars = ("   " .. code .. "   "):totable()

	for i = 1, #chars do

		if chars[i] == "\\" then
			chars[i] = "\\" .. chars[i + 1]
			chars[i + 1] = ""
		end

		if debug then
			log(in_string and "S" or in_comment and "C" or in_multiline and "M" or chars[i] == "\n" and "\n" or chars[i])
		end

		if not in_string and not in_comment and not in_multiline then
			if (chars[i] == "/" and chars[i + 1] == "/") or (chars[i] == "-" and chars[i + 1] == "-") then
				chars[i] = "-"
				chars[i + 1] = "-"
				in_comment = "line"
			elseif chars[i] == "/" and chars[i + 1] == "*" then
				chars[i] = ""
				chars[i + 1] = "--[=======["
				in_comment = "c_multiline"
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
				if chars[i] == "*" and chars[i + 1] == "/" then
					in_comment = nil
					chars[i] = ""
					chars[i + 1] = "]=======]"
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
				chars[i] = ""
				chars[i + 1] = " ~= "
			elseif chars[i] == "&" and chars[i + 1] == "&" then
				chars[i] = ""
				chars[i + 1] = " and "
			elseif chars[i] == "|" and chars[i + 1] == "|" then
				chars[i] = ""
				chars[i + 1] = " or "
			elseif chars[i] == "!" then
				chars[i] = " not "
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

		for i, ls in ipairs(stack) do
			if ls.token == "TK_name" and ls.tokenval == "continue" then
				local start

				for i = i, 1, -1 do
					local v = stack[i]

					if v.token == "TK_do" then
						start = v
						start.stack_pos = i
						break
					end
				end

				if not start then
					error("unable to find start of loop")
				end


				local stop

				local balance = 0
				local return_token

				for i = start.stack_pos, #stack do
					local v = stack[i]

					if v.token == "TK_do" or v.token == "TK_if" or v.token == "TK_function" then
						balance = balance + 1
					elseif v.token == "TK_end" then
						balance = balance - 1
					end

					if stack[i].token == "TK_return" or stack[i].token == "TK_break" then
						return_token = stack[i]
					end

					if balance == 0 then
						stop = v
						break
					end
				end

				if not stop then
					error("unable to find stop of loop")
				end

				local lines = code:split("\n")

				lines[ls.linenumber] = lines[ls.linenumber]:gsub("continue", "goto CONTINUE")

				if return_token and not return_token.fixed then
					lines[return_token.linenumber] = " do ".. lines[return_token.linenumber] .. " end "
					return_token.fixed = true
				end

				if stop and not stop.fixed then
					lines[stop.linenumber] = " ::CONTINUE:: ".. lines[stop.linenumber]
					stop.fixed = true
				end
				code = table.concat(lines, "\n")

			end
		end
	end

	code = code:gsub("DEFINE_BASECLASS", "local BaseClass = baseclass.Get")

	return code
end

event.AddListener("PreLoadString", "gmod_preprocess", function(code, path)
	if path:lower():find("steamapps/common/garrysmod/garrysmod/", nil, true) or path:find("%.gma") then
		if not code:find("DEFINE_BASECLASS", nil, true) and loadstring(code) then return code end

		local ok, msg = pcall(gmod.PreprocessLua, code)

		if not ok then
			logn(msg)
			return
		end

		code = msg

		if not loadstring(code) then vfs.Write("gmod_preprocess_error.lua", code) end

		return code
	end
end)
