local oh = {}

do
	local Tokenizer = require("lua_tokenizer")

	local syntax = {}

	syntax.space = {" ", "\n", "\r", "\t"}

	syntax.number = {}
	for i = 0, 9 do
		syntax.number[i+1] = tostring(i)
	end

	syntax.letter = {"_"}

	for i = string.byte("A"), string.byte("Z") do
		table.insert(syntax.letter, string.char(i))
	end

	for i = string.byte("a"), string.byte("z") do
		table.insert(syntax.letter, string.char(i))
	end

	syntax.symbol = {
		".", ",", "(", ")", "{", "}", "[", "]",
		"=", ":", ";", "::", "...", "-", "#",
		"not", "-", "<", ".", ">", "/", "^",
		"==", "<=", "..", "~=", "+", "*", "and",
		">=", "or", ":", "%", "\"", "'"
	}

	syntax.eof = {""}

	local ffi = require "ffi"
	local bit = require "bit"
	local band = bit.band
	local bor = bit.bor
	local rshift = bit.rshift
	local lshift = bit.lshift
	local math_floor = math.floor
	local string_char = string.char
	local UTF8_ACCEPT = 0
	local UTF8_REJECT = 12

	local utf8d = ffi.new("const uint8_t[364]", {
	  -- The first part of the table maps bytes to character classes that
	  -- to reduce the size of the transition table and create bitmasks.
	   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
	   7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
	   8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	  10,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3, 11,6,6,6,5,8,8,8,8,8,8,8,8,8,8,8,

	  -- The second part is a transition table that maps a combination
	  -- of a state of the automaton and a character class to a state.
	   0,12,24,36,60,96,84,12,12,12,48,72, 12,12,12,12,12,12,12,12,12,12,12,12,
	  12, 0,12,12,12,12,12, 0,12, 0,12,12, 12,24,12,12,12,12,12,24,12,24,12,12,
	  12,12,12,12,12,12,12,24,12,12,12,12, 12,24,12,12,12,12,12,12,12,24,12,12,
	  12,12,12,12,12,12,12,36,12,36,12,12, 12,36,12,12,12,12,12,36,12,36,12,12,
	  12,36,12,12,12,12,12,12,12,12,12,12,
	})

	local function totable(str)
		local state = UTF8_ACCEPT
		local codepoint = 0;
		local offset = 0;
		local ptr = ffi.cast("uint8_t *", str)

		local out = {}
		local out_i = 1

		for i = 0, #str - 1 do
			local byte = ptr[i]
			local ctype = utf8d[byte]

			if state ~= UTF8_ACCEPT then
				codepoint = bor(band(byte, 0x3f), lshift(codepoint, 6))
			else
				codepoint = band(rshift(0xff, ctype), byte)
			end

			state = utf8d[256 + state + ctype]

			if state == UTF8_ACCEPT then
				if codepoint > 0xffff then
					codepoint = lshift(((0xD7C0 + rshift(codepoint, 10)) - 0xD7C0), 10) +
					(0xDC00 + band(codepoint, 0x3ff)) - 0xDC00
				end

				if codepoint <= 127 then
					out[out_i] = string_char(codepoint)
				elseif codepoint < 2048 then
					out[out_i] = string_char(
						192 + math_floor(codepoint / 64),
						128 + (codepoint % 64)
					)
				elseif codepoint < 65536 then
					out[out_i] = string_char(
						224 + math_floor(codepoint / 4096),
						128 + (math_floor(codepoint / 64) % 64),
						128 + (codepoint % 64)
					)
				elseif codepoint < 2097152 then
					out[out_i] = string_char(
						240 + math_floor(codepoint / 262144),
						128 + (math_floor(codepoint / 4096) % 64),
						128 + (math_floor(codepoint / 64) % 64),
						128 + (codepoint % 64)
					)
				else
					out[out_i] = ""
				end

				out_i = out_i + 1
			end
		end
		return out
	end

	function oh.Tokenizer(code)
		local errors = {}

		local tbl = totable(code)
		local length = #tbl
		local table_concat = table.concat
		local tbl_cache = {}

		local self = Tokenizer({
			syntax = syntax,
			to_table = true,

			get_code_length = function()
				return length
			end,
			get_code_char = function(i)
				return tbl[i]
			end,
			get_code_char_range = function(start, stop)
				local length = stop-start
				if not tbl_cache[length] then
					 tbl_cache[length] = {}
				end
				local str = tbl_cache[length]

				local str_i = 1
				for i = start, stop do
					str[str_i] = tbl[i]
					str_i = str_i + 1
				end
				return table_concat(str)
			end,

			string_lower = function(s) if s then return s:lower() end end,
			string_sub = string.sub,

			char_fallback_type = "letter", -- This is needed for UTF8. Assume everything is a letter if it's not any of the other types.
			on_error = function(_, msg, start, stop)
				table.insert(errors, {msg = msg, start = start, stop = stop})
			end
		})

		self.errors = errors

		self:ResetState()

		return self
	end
end

runfile("lua/libraries/oh/syntax.lua", oh)
oh.Parser = require("lua_parser")
runfile("lua/libraries/oh/lua_code_emitter.lua", oh)
runfile("lua/libraries/oh/test.lua", oh)

function oh.QuoteToken(str)
	return "⸢" .. str .. "⸥"
end

function oh.QuoteTokens(var)
	if type(var) == "string" then
		var = var:totable()
	end

	local str = ""
	for i, v in ipairs(var) do
		str = str .. oh.QuoteToken(v)

		if i == #var - 1 then
			str = str .. " or "
		elseif i ~= #var then
			str = str .. ", "
		end
	end
	return str
end

function oh.FormatError(code, path, msg, start, stop)
	local total_lines = code:count("\n")
	local line_number_length = #tostring(total_lines)

	local function tab2space(str)
		return str:gsub("\t", "    ")
	end

	local function line2str(i)
		return ("%i%s"):format(i, (" "):rep(line_number_length - #tostring(i)))
	end

	local context_size = 100
	local line_context_size = 1

	local length = (stop - start) + 1
	local before = code:sub(math.max(start - context_size, 0), stop - length)
	local middle = code:sub(start, stop)
	local after = code:sub(stop + 1, stop + context_size)

	local context_before, line_before = before:match("(.+\n)(.*)")
	local line_after, context_after = after:match("(.-)(\n.+)")

	if not line_before then
		context_before = before
		line_before = before
	end

	if not line_after then
		context_after = after
		line_after = after

		-- hmm
		if context_after == line_after then
			context_after = ""
		end
	end

	local current_line = code:sub(0, stop):count("\n") + 1
	local char_number = #line_before + 1

	line_before = tab2space(line_before)
	line_after = tab2space(line_after)
	middle = tab2space(middle)

	local out = ""
	out = out .. "error: " ..  msg:escape() .. "\n"
	out = out .. " " .. ("-"):rep(line_number_length + 1) .. "> " .. path .. ":" .. current_line .. ":" .. char_number .. "\n"

	if line_context_size > 0 then
		local lines = tab2space(context_before:sub(0, -2)):split("\n")
		if #lines ~= 1 or lines[1] ~= "" then
			for offset = math.max(#lines - line_context_size, 1), #lines do
				local str = lines[offset]
				--if str:trim() ~= "" then
					offset = offset - 1
					local line = current_line - (-offset + #lines)
					if line ~= 0 then
						out = out .. line2str(line) .. " | " .. str .. "\n"
					end
				--end
			end
		end
	end

	out = out .. line2str(current_line) .. " | " .. line_before .. middle .. line_after .. "\n"
	out = out .. (" "):rep(line_number_length) .. " |" .. (" "):rep(#line_before + 1) .. ("^"):rep(length) .. " " .. msg .. "\n"

	if line_context_size > 0 then
		local lines = tab2space(context_after:sub(2)):split("\n")
		if #lines ~= 1 or lines[1] ~= "" then
			for offset = 1, #lines do
				local str = lines[offset]
				--if str:trim() ~= "" then
					out = out .. line2str(current_line + offset) .. " | " .. str .. "\n"
				--end
				if offset >= line_context_size then break end
			end
		end
	end

	out = out:trim()

	return out
end

function oh.GetErrorsFormatted(error_table, code, path)
	if not error_table[1] then
		return ""
	end

	local errors = {}
	local max_width = 0

	for i, data in ipairs(error_table) do
		local msg = oh.FormatError(code, path, data.msg, data.start, data.stop)

		for _, line in ipairs(msg:split("\n")) do
			max_width = math.max(max_width, #line)
		end

		errors[i] = msg
	end

	local str = ""

	for _, msg in ipairs(errors) do
		str = str .. ("="):rep(max_width) .. "\n" .. msg .. "\n"
	end

	str = str .. ("="):rep(max_width) .. "\n"

	return str
end

function oh.DumpTokens(chunks, code)
	local out = {}

	for _, v in ipairs(chunks) do
		for _, v in ipairs(v.whitespace) do
			table.insert(out, code:usub(v.start, v.stop))
		end
		table.insert(out, oh.QuoteToken(code:usub(v.start, v.stop)))
	end

	return table.concat(out)
end

function oh.Transpile(code, path)
	local tokenizer = oh.Tokenizer(code, path)
	local parser = oh.Parser()
	local ast = parser:BuildAST(tokenizer:GetTokens())
	local output = oh.BuildLuaCode(ast, code)
	return output
end

function oh.loadstring(code, path)
	local ok, code = system.pcall(oh.Transpile, code, path)
	if not ok then return nil, code end
	local func, err = loadstring(code, path)

	if not func then
		local line = tonumber(err:match("%b[]:(%d+):"))
		local lines = code:split("\n")
		for i = -1, 1 do
			if lines[line + i] then
				err = err .. "\t" .. lines[line + i]
				if i == 0 then
					err = err .. " --<<< "
				end
				err = err .. "\n"
			end
		end

		return nil, err
	end

	return func
end

return oh
