
-- rename calls to something more sane
-- keywords, for in pairs will make in an identifer

local function string_trim(self, char)
	if char then
		char = char:patternsafe() .. "*"
	else
		char = "%s*"
	end

	local _, start = self:find(char, 0)
	local end_start, end_stop = self:reverse():find(char, 0)

	if start and end_start then
		return self:sub(start + 1, (end_start - end_stop) - 2)
	elseif start then
		return self:sub(start + 1)
	elseif end_start then
		return self:sub(0, (end_start - end_stop) - 2)
	end

	return self
end

local function string_split(self, separator, plain_search)
	if separator == nil or separator == "" then
		return self:totable()
	end

	if plain_search == nil then
		plain_search = true
	end

	local tbl = {}
	local current_pos = 1

	for i = 1, #self do
		local start_pos, end_pos = self:find(separator, current_pos, plain_search)
		if not start_pos then break end
		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 then
		tbl[#tbl + 1] = self:sub(current_pos)
	else
		tbl[1] = self
	end

	return tbl
end


local function string_count(self, what, plain)
	if plain == nil then plain = true end

	local count = 0
	local current_pos = 1

	for _ = 1, #self do
		local start_pos, end_pos = self:find(what, current_pos, plain)
		if not start_pos then break end
		count = count + 1
		current_pos = end_pos + 1
	end
	return count
end


local function format_error(code, path, msg, start, stop)
	local total_lines = string_count(code, "\n")
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

	local current_line = string_count(code:sub(0, stop), "\n") + 1
	local char_number = #line_before + 1

	line_before = tab2space(line_before)
	line_after = tab2space(line_after)
	middle = tab2space(middle)

	local out = ""
	out = out .. "error: " ..  msg .. "\n"
	out = out .. " " .. ("-"):rep(line_number_length + 1) .. "> " .. path .. ":" .. current_line .. ":" .. char_number .. "\n"

	if line_context_size > 0 then
		local lines = string_split(tab2space(context_before:sub(0, -2)), "\n")
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
		local lines = string_split(tab2space(context_after:sub(2)), "\n")
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

	out = string_trim(out)

	return out
end

local function transpile(ast)
    local self = require("lua_code_emitter")({preserve_whitespace = true})
    local res = self:BuildCode(ast)
    local ok, err = loadstring(res)
    if not ok then
        io.write(err, "\n")
    end
    return res
end

local function tokenize(code)
    local self = require("lua.tokenizer")(code, function(_, msg, start, stop)
        io.write(format_error(code, "test", msg, start, stop))
    end)

    self:ResetState()

    return self:GetTokens()
end

local function parse(tokens, code)
    return require("lua.parser")(function(_, msg, start, stop)
        io.write(format_error(code, "test", msg, start, stop))
    end):BuildAST(tokens)
end

local dump_ast do
	local indent = 0
    function dump_ast(tbl, blacklist)
        if tbl.type == "value" and tbl.value.type and tbl.value.value then
            io.write(("\t"):rep(indent))
            io.write(tbl.value.type, ": ", tbl.value.value, "\n")
        else
            for k,v in pairs(tbl) do
                if type(v) ~= "table" then
                    io.write(("\t"):rep(indent))
                    io.write(k, " = ", tostring(v), "\n")
                end
            end

            for k,v in pairs(tbl) do
                if type(v) == "table" and k ~= "tokens" and k ~= "whitespace" then
                    if v.type == "value" and v.value.type and v.value.value then
                        io.write(("\t"):rep(indent))
                        io.write(k, ": [", v.value.type, ": ", tostring(v.value.value), "]\n")
                        if v.suffixes then
                            indent = indent + 1
                            io.write(("\t"):rep(indent))
                            io.write("suffixes", ":", "\n")
                            dump_ast(v.suffixes, blacklist)
                            indent = indent - 1
                        end
                    end
                end
            end

            for k,v in pairs(tbl) do
                if type(v) == "table" and k ~= "tokens" and k ~= "whitespace" then
                    if v.type == "value" and v.value.type and v.value.value then

                    else
                        io.write(("\t"):rep(indent))
                        io.write(k, ":", "\n")
                        indent = indent + 1
                        dump_ast(v, blacklist)
                        indent = indent - 1
                    end
                end
            end
        end
	end
end

local function dump_tokens(tokens)
    for _, v in ipairs(tokens) do
        for _, v in ipairs(v.whitespace) do
            io.write(code:usub(v.start, v.stop))
        end

        io.write("⸢" .. code:usub(v.start, v.stop) .. "⸥")
    end
end

local function transpile_check(code)
    local tokens, ast, new_code

    local ok = xpcall(function()
        tokens = tokenize(code)
        ast = parse(tokens, code)
        new_code = transpile(ast)
    end, function(err)
        print("===================================")
        print(debug.traceback(err))
        print(code)
        print("===================================")
    end)

    if ok and code ~= new_code then
        print("===================================")
        print("transpiled output doesn't match:")
        print("FROM:")
        print(code)
        print("TO:")
        print(new_code)
        print("===================================")

        dump_ast(ast)
        for i,v in ipairs(tokens) do
            print("[" .. i .. "][" .. v.type .. "]: " .. v.value)
        end

        ok = false
    end

    if ok then
        io.write(code, " - OK!\n")
    end

    return ok
end

local function check_tokens_separated_by_space(code)
    local tokens = tokenize(code)
    local i = 1
    for expected in code:gmatch("(%S+)") do
        if tokens[i].type == "unknown" then
            error("token " .. tokens[i].value .. " is unknown")
        end

        if tokens[i].value ~= expected then
            error("token " .. tokens[i].value .. " does not match " .. expected)
        end

        i = i + 1
    end
end


transpile_check"foo = bar"
transpile_check"foo--[[]].--[[]]bar--[[]]:--[[]]test--[[]](--[[]]1--[[]]--[[]],2--[[]])--------[[]]--[[]]--[[]]"
transpile_check"function foo.testadw() end"
transpile_check"asdf.a.b.c[5](1)[2](3)"
transpile_check"while true do end"
transpile_check"for i = 1, 10, 2 do end"
transpile_check"local a,b,c = 1,2,3"
transpile_check"local a = 1\nlocal b = 2\nlocal c = 3"
transpile_check"function test.foo() end"
transpile_check"local function test() end"
transpile_check"local a = {foo = true, c = {'bar'}}"
transpile_check"for k,v,b in pairs() do end"
transpile_check"for k in pairs do end"
transpile_check"foo()"
transpile_check"if true then print(1) elseif false then print(2) else print(3) end"
transpile_check"a.b = 1"
transpile_check"local a,b,c = 1,2,3"
transpile_check"repeat until false"
transpile_check"return true"
transpile_check"while true do break end"
transpile_check"do end"
transpile_check"local function test() end"
transpile_check"function test() end"
transpile_check"goto test ::test::"
transpile_check"#shebang wadawd\nfoo = bar"
transpile_check"local a,b,c = 1 + (2 + 3) + v()()"
transpile_check"(function() end)(1,2,3)"
transpile_check"(function() end)(1,2,3){4}'5'"
transpile_check"(function() end)(1,2,3);(function() end)(1,2,3)"
transpile_check"local tbl = {a; b; c,d,e,f}"

assert(tokenize([[0xfFFF]])[1].value == "0xfFFF")
check_tokens_separated_by_space([[while true do end]])
check_tokens_separated_by_space([[if a == b and b + 4 and true or ( true and function ( ) end ) then :: foo :: end]])


do
    io.write("generating random tokens ...")
    local tokens = {
        ",", "=", ".", "(", ")", "end", ":", "function", "self", "then", "}", "{", "[", "]",
        "local", "if", "return", "ffi", "tbl", "1", "cast", "i", "0", "==",
        "META", "library", "CLIB", "or", "do", "v", "..", "+", "for", "type", "-", "x",
        "str", "s", "data", "y", "and", "in", "true", "info", "steamworks", "val", "not",
        "table", "2", "name", "path", "#", "...", "nil", "new", "key", "render", "ipairs",
        "else", "false", "e", "b", "elseif", "*", "id", "math", "a", "size", "lib", "pos",
        "gine", "vfs", "insert", "buffer", "~=", "t", "k", "out", "table_only",
        "flags", "gl", "render2d", "_", "/", "4", "env", "chunk", ";", "Color", "3",
        "pairs", "line", "format", "count", "0xFFFF", "0b10101", "10.52032", "0.123123"
    }

    local whitespace_tokens = {
        " ",
        "\t",
        "\n\t \n",
        "\n",
        "\n\t   ",
        "--[[aaaaaa]]",
        "--[[\n\n]]--what\n",
    }

    local code = {}
    local total = 1000000
    local whitespace_count = 0

    for i = 1, total do
        math.randomseed(i)

        if math.random() < 0.5 then
            if math.random() < 0.25 then
                code[i] = tostring(math.random()*100000000000000)
            else
                code[i] = "\"" .. tokens[math.random(1, #tokens)] .. "\""
            end
        else
            code[i] = " " .. tokens[math.random(1, #tokens)] .. " "
        end

        if math.random() > 0.75 then
            code[i] = code[i] .. whitespace_tokens[math.random(1, #whitespace_tokens)]:rep(math.random(1,4))
            whitespace_count = whitespace_count + 1
        end
    end

    local code = table.concat(code)
    io.write(" - OK! ", ("%0.3f"):format(#code/1024/1024), "Mb of lua code\n")

    do
        io.write("tokenizing random tokens ...")
        local t = os.clock()
        local res = tokenize(code)
        local total = os.clock() - t
        io.write(" - OK! ", total, " seconds / ", #res, " tokens\n")
    end


    local function measure(code)
        collectgarbage()
        local res = code

        do
            io.write("tokenizing     ...", ("%0.3f"):format(#code/1024/1024), "Mb of lua code\n")
            local t = os.clock()
            res = tokenize(res)
            local total = os.clock() - t
            io.write(" - OK! ", total, " seconds / ", #res, " tokens\n")
        end

        do
            io.write("parsing        ...")
            local t = os.clock()
            res = parse(res, code)
            local total = os.clock() - t
            io.write(" - OK! ", total, " seconds\n")
        end

        do
            io.write("generating code...")
            local t = os.clock()
            res = transpile(res)
            local total = os.clock() - t
            io.write(" - OK! ", total, " seconds / ", ("%0.3f"):format(#res/1024/1024), "Mb of code\n")
        end
    end
end