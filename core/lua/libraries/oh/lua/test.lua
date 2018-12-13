local oh = ... or _G.oh

local function transpile(ast)
    local self = runfile("lua_code_emitter.lua")({preserve_whitespace = true})
    local res = self:BuildCode(ast)
    local ok, err = loadstring(res)
    if not ok then
        log(err, "\n")
    end
    return res
end

local function tokenize(code, capture_whitespace)
    local self = runfile("tokenizer.lua")(code, function(_, msg, start, stop)
        log(oh.FormatError(code, "test", msg, start, stop))
    end, capture_whitespace)

    self:ResetState()

    return self:GetTokens()
end

local function parse(tokens, code)
    return runfile("parser.lua")(function(_, msg, start, stop)
        log(oh.FormatError(code, "test", msg, start, stop))
    end):BuildAST(tokens)
end

local dump_ast do
	local indent = 0
    function dump_ast(tbl, blacklist)
        if tbl.type == "value" and tbl.value.type and tbl.value.value then
            log(("\t"):rep(indent))
            log(tbl.value.type, ": ", tbl.value.value, "\n")
        else
            for k,v in pairs(tbl) do
                if type(v) ~= "table" then
                    log(("\t"):rep(indent))
                    log(k, " = ", tostring(v), "\n")
                end
            end

            for k,v in pairs(tbl) do
                if type(v) == "table" and k ~= "tokens" and k ~= "whitespace" then
                    if v.type == "value" and v.value.type and v.value.value then
                        log(("\t"):rep(indent))
                        log(k, ": [", v.value.type, ": ", tostring(v.value.value), "]\n")
                        if v.suffixes then
                            indent = indent + 1
                            log(("\t"):rep(indent))
                            log("suffixes", ":", "\n")
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
                        log(("\t"):rep(indent))
                        log(k, ":", "\n")
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
            log(code:usub(v.start, v.stop))
        end

        log("⸢" .. code:usub(v.start, v.stop) .. "⸥")
    end
end

local function transpile_fail_check(code)
    local ok = pcall(function() parse(tokenize(code), code) end) == false
    if not ok then
        print(code)
        print("shouldn't compile")
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
        log(code, " - OK!\n")
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
transpile_check"as()"
transpile_check"#a();;"
transpile_check"a();;"

assert(tokenize([[0xfFFF]])[1].value == "0xfFFF")
check_tokens_separated_by_space([[while true do end]])
check_tokens_separated_by_space([[if a == b and b + 4 and true or ( true and function ( ) end ) then :: foo :: end]])

do
    log("generating random tokens ...")
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
    log(" - OK! ", ("%0.3f"):format(#code/1024/1024), "Mb of lua code\n")
profiler.EasyStart()
    do
        log("tokenizing random tokens with capture_whitespace ...")
        local t = os.clock()
        local res = tokenize(code, true)
        local total = os.clock() - t
        log(" - OK! ", total, " seconds / ", #res, " tokens\n")
    end
profiler.EasyStop()

profiler.EasyStart()
    do
        log("tokenizing random tokens without capture_whitespace ...")
        local t = os.clock()
        local res = tokenize(code, false)
        local total = os.clock() - t 
        log(" - OK! ", total, " seconds / ", #res, " tokens\n")
    end
profiler.EasyStop()

    local function measure(code)
        collectgarbage()
        local res = code
 
        do
            log("tokenizing     ...", ("%0.3f"):format(#code/1024/1024), "Mb of lua code\n")
            local t = os.clock()
            res = tokenize(res)
            local total = os.clock() - t
            log(" - OK! ", total, " seconds / ", #res, " tokens\n")
        end

        do
            log("parsing        ...")
            local t = os.clock()
            res = parse(res, code)
            local total = os.clock() - t
            log(" - OK! ", total, " seconds\n")
        end

        do
            log("generating code...")
            local t = os.clock()
            res = transpile(res)
            local total = os.clock() - t
            log(" - OK! ", total, " seconds / ", ("%0.3f"):format(#res/1024/1024), "Mb of code\n")
        end
    end
end