local oh = ... or _G.oh
RELOAD = nil

local function transpile(ast, what)
	what = what or "lua"
	local self = runfile(what .. "_code_emitter.lua")({preserve_whitespace = true})
	local res = self:BuildCode(ast)
	local ok, err = loadstring(res)

	if not ok then return res, err end

	return res
end

local function tokenize(code, capture_whitespace)
	local self = runfile("tokenizer.lua")(
		code,
		function(_, msg, start, stop)
			log(oh.FormatError(code, "test", msg, start, stop))
		end,
		capture_whitespace
	)
	self:ResetState()
	return self:GetTokens()
end

local function parse(tokens, code, halt)
	return runfile("parser.lua")(function(_, msg, start, stop)
		error(oh.FormatError(code, "test", msg, start, stop))
	end):BuildAST(tokens)
end

local dump_ast

do
	local indent = 0

	local function type2string(val)
		if not val then return "any" end

		local str = ""

		for i, v in ipairs(val) do
			str = str .. v.value.value

			if i ~= #val then str = str .. "|" end

			if v.function_arguments then
				str = str .. "("

				for i, arg in ipairs(v.function_arguments) do
					str = str .. tostring(arg.value.value) .. ": " .. type2string(arg.data_type)

					if i ~= #v.function_arguments then str = str .. ", " end
				end

				str = str .. "): " .. type2string(v.function_return_type)
			end
		end

		return str
	end

	function dump_ast(tbl, blacklist)
		if tbl.type == "value" and tbl.value.type and tbl.value.value then
			log(("\t"):rep(indent))
			log(tbl.value.type, ": ", tbl.value.value, " as ", type2string(tbl.value.data_type), "\n")
		else
			for k, v in pairs(tbl) do
				if type(v) ~= "table" then
					log(("\t"):rep(indent))
					log(k, " = ", tostring(v), "\n")
				end
			end

			for k, v in pairs(tbl) do
				if type(v) == "table" and k ~= "tokens" and k ~= "whitespace" then
					if v.type == "value" and v.value.type and v.value.value then
						log(("\t"):rep(indent))
						log(
							k,
							": [",
							v.value.type,
							": ",
							tostring(v.value.value),
							" as ",
							type2string(v.data_type),
							"]\n"
						)

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

			for k, v in pairs(tbl) do
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

local function dump_tokens(tokens, code)
	for _, v in ipairs(tokens) do
		for _, v in ipairs(v.whitespace) do
			log(code:usub(v.start, v.stop))
		end

		log("⸢" .. code:usub(v.start, v.stop) .. "⸥")
	end
end

local function transpile_fail_check(code)
	local ok = pcall(function()
		parse(tokenize(code), code)
	end) == false

	if not ok then
		print(code)
		print("shouldn't compile")
	end
end

local function transpile_ok(code, path, lang)
	local tokens, ast, new_code, lua_err
	local ok = xpcall(function()
		tokens = tokenize(code)
		ast = parse(tokens, code)
		new_code, lua_err = transpile(ast, lang)
	end, function(err)
		print("===================================")
		print(debug.traceback(err))
		print(path or code)
		print("===================================")
	end)

	if ok then --log(new_code, " - OK!\n")
	return new_code, lua_err end
end

local function run_js(code, path)
	local tokens, ast, new_code, lua_err
	local ok = xpcall(function()
		tokens = tokenize(code)
		ast = parse(tokens, code)
		new_code, lua_err = transpile(ast, "js")
	end, function(err)
		print("===================================")
		print(debug.traceback(err))
		print(path or code)
		print("===================================")
	end)

	if ok then
		vfs.Write("temp/test.js", new_code)
		print(new_code)
		repl.OSExecute("node " .. R("temp/test.js"))
		return new_code, lua_err
	end
end

local function transpile_check(code)
	local tokens, ast, new_code, lua_err
	local ok = xpcall(function()
		tokens = tokenize(code)
		ast = parse(tokens, code)
		new_code, lua_err = transpile(ast)
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

		--table.print(ast)
		for i, v in ipairs(tokens) do
			print("[" .. i .. "][" .. v.type .. "]: " .. v.value)
		end

		ok = false
	end

	if ok then --log(code, " - OK!\n")
	end

	return ok, new_code
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

local function print_ast(code)
	local tokens = tokenize(code)
	dump_ast(parse(tokens, code, true))
end

local function LinkTokensWithAST(tokens, ast)
	-- if it quacks like a node, it is a node
	local function walk(node, parent)
		if node.tokens then
			for _, token in pairs(node.tokens) do
				token.ast_node = node
			end

			node.parent = parent

			for key, val in pairs(node) do
				if type(val) == "table" and key ~= "ast_node" and key ~= "parent" then
					walk(val, node)
				end
			end

			if type(node.value) == "table" then node.value.ast_node = node end
		end
	end

	for k, v in ipairs(ast) do
		walk(v, ast)
	end
end

if false then
	local code = "local a = 1"
	local tokens = tokenize(code)
	local ast = parse(tokens, code, true)
	LinkTokensWithAST(tokens, ast)

	for k, v in ipairs(tokens) do
		print(v.value)

		if v.value == "a" then table.print(v) end
	end
end

print("============TEST============")
transpile_ok("print(<lol> </lol>)")
transpile_ok("print(<lol><a></a></lol>)")
transpile_ok("print(<lol lol=1></lol>)")
--transpile_check("a=(foo.bar)")
--transpile_check("a=(foo.bar)()")
transpile_ok("@T:FOOBARRRR=true")

if FOOBARRRR == true then  else error("compile test failed") end

FOOBARRRR = nil
transpile_ok("@P:FOOBARRRR=true")

if FOOBARRRR == true then  else error("compile test failed") end

FOOBARRRR = nil
transpile_ok("@E:FOOBARRRR=true")

if FOOBARRRR == true then  else error("compile test failed") end

FOOBARRRR = nil
transpile_ok("for i = 1, 10 do continue end")
transpile_ok("for i = 1, 10 do if lol then continue end end")
transpile_ok("repeat if lol then continue end until uhoh")
transpile_ok("while true do if false then continue end end")
transpile_ok("local a: foo|bar = 1 as foo")
transpile_ok("local a: foo|bar = 1")
transpile_ok("local test: __add(a: number, b: number): number = function() end")
transpile_ok("local a: FOO|baz = (1 + 1 + adawdad) as fool")
transpile_ok("function test(a: FOO|baz) return 1 + 2 as lol + adawdad as fool end")
transpile_ok("interface foo { foo: bar, lol, lol:foo = 1 }")
transpile_ok("tbl = {a = foo:asdf(), bar:LOL(), foo: a}")
transpile_check("local a = 1;")
transpile_check("local a,b,c")
transpile_check("local a,b,c = 1,2,3")
transpile_check("local a,c = 1,2,3")
transpile_check("local a = 1,2,3")
transpile_check("local a")
transpile_check("local a = -c+1")
transpile_check("local a = c")
transpile_check("(a)[b] = c")
transpile_check("local a = {[1+2+3] = 2}")
transpile_check("foo = bar")
transpile_check(
	"foo--[[]].--[[]]bar--[[]]:--[[]]test--[[]](--[[]]1--[[]]--[[]],2--[[]])--------[[]]--[[]]--[[]]"
)
transpile_check("function foo.testadw() end")
transpile_check("asdf.a.b.c[5](1)[2](3)")
transpile_check("while true do end")
transpile_check("for i = 1, 10, 2 do end")
transpile_check("local a,b,c = 1,2,3")
transpile_check("local a = 1\nlocal b = 2\nlocal c = 3")
transpile_check("function test.foo() end")
transpile_check("local function test() end")
transpile_check("local a = {foo = true, c = {'bar'}}")
transpile_check("for k,v,b in pairs() do end")
transpile_check("for k in pairs do end")
transpile_check("foo()")
transpile_check("if true then print(1) elseif false then print(2) else print(3) end")
transpile_check("a.b = 1")
transpile_check("local a,b,c = 1,2,3")
transpile_check("repeat until false")
transpile_check("return true")
transpile_check("while true do break end")
transpile_check("do end")
transpile_check("local function test() end")
transpile_check("function test() end")
transpile_check("goto test ::test::")
transpile_check("#!shebang wadawd\nfoo = bar")
transpile_check("local a,b,c = 1 + (2 + 3) + v()()")
transpile_check("(function() end)(1,2,3)")
transpile_check("(function() end)(1,2,3){4}'5'")
transpile_check("(function() end)(1,2,3);(function() end)(1,2,3)")
transpile_check("local tbl = {a; b; c,d,e,f}")
transpile_check("aslk()")
transpile_check("a = #a();;")
transpile_check("a();;")
transpile_check("a();;")
transpile_check("🐵=😍+🙅")
transpile_check("print(･✿ヾ╲｡◕‿◕｡╱✿･ﾟ)")
transpile_check("print(･✿ヾ╲｡◕‿◕｡╱✿･ﾟ)")
transpile_check(
	"print(ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็)"
)
transpile_check("function global(...) end")
transpile_check("local function printf(fmt, ...) end")
transpile_check("local function printf(fmt, ...) end")
transpile_check("self.IconWidth, self.IconHeight = spritesheet.GetIconSize( icon )")
transpile_check("st, tok = LexLua(src)")
transpile_check("if not self.Emitter then return end")
transpile_check("if !self.Emitter && Aadw || then return end")
transpile_check("tbl = {a = foo:asdf(), bar:LOL()}")
transpile_check("foo = 1 // bar")
transpile_check("foo = 1 /* bar */")
transpile_check("foo = 1 /* bar */")
--transpile_check("if (player:IsValid()) then end")
--transpile_check("if ( IsValid( tr.Entity ) ) then end")
--transpile_check("local foo = (1+(2+(foo:bar())))")
--transpile_check("RunConsoleCommand ('hostname', (table.Random (hostname)))")
assert(tokenize([[0xfFFF]])[1].value == "0xfFFF")
check_tokens_separated_by_space([[while true do end]])
check_tokens_separated_by_space([[if a == b and b + 4 and true or ( true and function ( ) end ) then :: foo :: end]])

if false then
	print("CODE COVERAGE")
	local covered = utility.StopMonitorCoverage()
	local code = vfs.Read("lua/libraries/oh/lua/parser.lua")

	for i, line in ipairs(code:split("\n")) do
		if not line:find("gmod_wire_expression2/core/custom") then
			if not covered[i] then print(line) else print("") end
		end
	end
end

if false then
	for _, path in ipairs(
		vfs.GetFilesRecursive(e.ROOT_FOLDER .. "metastruct_addons/addons/merged/lua/", {".lua"})
	) do
		print("testing " .. path .. "...")
		local code = vfs.Read(path)

		if code then
			if code:startswith("\xEF\xBB\xBF") then code = code:sub(3) end

			local code2, err = transpile_ok(code, path)

			if code2 and code2 ~= code then
				print(path .. " differs!")
				local name = vfs.GetFileNameFromPath(path)
				vfs.Write("data/compare/" .. name .. crypto.CRC32(path) .. "/original.lua", code)
				vfs.Write("data/compare/" .. name .. crypto.CRC32(path) .. "/new.lua", code2)
				vfs.Write(
					"data/compare/" .. name .. crypto.CRC32(path) .. "/meld.sh",
					[[
                    meld original.lua new.lua
                ]]
				)

				if err then print("error: " .. err) end
			else
				print(code2 == code, err)
			end
		else
			print("unable to read " .. path)
		end
	end
end

if false then
	log("generating random tokens ...")
	local tokens = {
		",",
		"=",
		".",
		"(",
		")",
		"end",
		":",
		"function",
		"self",
		"then",
		"}",
		"{",
		"[",
		"]",
		"local",
		"if",
		"return",
		"ffi",
		"tbl",
		"1",
		"cast",
		"i",
		"0",
		"==",
		"META",
		"library",
		"CLIB",
		"or",
		"do",
		"v",
		"..",
		"+",
		"for",
		"type",
		"-",
		"x",
		"str",
		"s",
		"data",
		"y",
		"and",
		"in",
		"true",
		"info",
		"steamworks",
		"val",
		"not",
		"table",
		"2",
		"name",
		"path",
		"#",
		"...",
		"nil",
		"new",
		"key",
		"render",
		"ipairs",
		"else",
		"false",
		"e",
		"b",
		"elseif",
		"*",
		"id",
		"math",
		"a",
		"size",
		"lib",
		"pos",
		"gine",
		"vfs",
		"insert",
		"buffer",
		"~=",
		"t",
		"k",
		"out",
		"table_only",
		"flags",
		"gl",
		"render2d",
		"_",
		"/",
		"4",
		"env",
		"chunk",
		";",
		"Color",
		"3",
		"pairs",
		"line",
		"format",
		"count",
		"0xFFFF",
		"0b10101",
		"10.52032",
		"0.123123",
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
	local total = 100000
	local whitespace_count = 0

	for i = 1, total do
		math.randomseed(i)

		if math.random() < 0.5 then
			if math.random() < 0.25 then
				code[i] = tostring(math.random() * 100000000000000)
			else
				code[i] = "\"" .. tokens[math.random(1, #tokens)] .. "\""
			end
		else
			code[i] = " " .. tokens[math.random(1, #tokens)] .. " "
		end

		if math.random() > 0.75 then
			code[i] = code[i] .. whitespace_tokens[math.random(1, #whitespace_tokens)]:rep(math.random(1, 4))
			whitespace_count = whitespace_count + 1
		end
	end

	local code = table.concat(code)
	log(" - OK! ", ("%0.3f"):format(#code / 1024 / 1024), "Mb of lua code\n")

	do
		log("tokenizing random tokens with capture_whitespace ...")
		local t = os.clock()
		local res = tokenize(code, true)
		local total = os.clock() - t
		log(" - OK! ", total, " seconds / ", #res, " tokens\n")
	end

	do
		log("tokenizing random tokens without capture_whitespace ...")
		local t = os.clock()
		local res = tokenize(code, false)
		local total = os.clock() - t
		log(" - OK! ", total, " seconds / ", #res, " tokens\n")
	end

	local function measure(code)
		collectgarbage()
		local res = code

		do
			log("tokenizing     ...", ("%0.3f"):format(#code / 1024 / 1024), "Mb of lua code\n")
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
			log(
				" - OK! ",
				total,
				" seconds / ",
				("%0.3f"):format(#res / 1024 / 1024),
				"Mb of code\n"
			)
		end
	end
end

print("============TEST COMPLETE============")