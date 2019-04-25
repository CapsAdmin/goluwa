local oh = {}

oh.utf8_tokenizer_config = runfile("utf8_tokenizer_config.lua", oh)
oh.CreateBaseTokenizer = runfile("base_tokenizer.lua", oh)
oh.SetupSyntax = runfile("setup_syntax.lua", oh)
oh.lua = runfile("lua/lua.lua", oh)

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

return oh
