local nl = require("nattlua")
local runtime_syntax = require("nattlua.syntax.runtime")

local function tokenize(code)
	return assert(nl.Compiler(code):Lex()).Tokens
end

local function parse(code)
	return assert(nl.Compiler(code):Parse()).Tokens
end

local function one_token(tokens)
	assert(#tokens, 2)
	equal(tokens[2] and tokens[2].type, "end_of_file", 2)
	return tokens[1]
end

test("smoke", function()
	equal(tokenize("")[1].type, "end_of_file")
	equal(one_token(tokenize("a")).type, "letter")
	equal(one_token(tokenize("1")).type, "number")
	equal(one_token(tokenize("(")).type, "symbol")
end)

test("shebang", function()
	equal(tokenize("#foo\nlocal lol = 1")[1].type, "shebang")
end)

test("single quote string", function()
	equal(one_token(tokenize("'1'")).type, "string")
end)

test("double quote string", function()
	equal(one_token(tokenize("\"1\"")).type, "string")
end)

test("z escaped string", function()
	equal(one_token(tokenize("\"a\\z\na\"")).type, "string")
end)

test("number..number", function()
	local tokens = tokenize("1..20")
	equal(#tokens, 4)
end)

test("comment escape", function()
	local i
	local tokens

	local function check(what)
		equal(tokens[i].value, what)
		i = i + 1
	end

	tokens = tokenize("a--[[#1]]--[[#1]]a--[[#1]]")
	i = 1
	check("a")
	check("1")
	check("1")
	check("a")
	check("1")
	check("")
	tokens = tokenize("function foo(str--[[#: string]], idx--[[#: number]], msg--[[#: string]]) end")
	i = 1
	check("function")
	check("foo")
	check("(")
	check("str")
	check(":")
	check("string")
	check(",")
	check("idx")
	check(":")
	check("number")
	check(",")
	check("msg")
	check(":")
	check("string")
	check(")")
	check("end")
end)

test("multiline comments", function()
	equal(#parse("--[[foo]]"), 1)
	equal(#parse("--[=[foo]=]"), 1)
	equal(#parse("--[==[foo]==]"), 1)
	equal(#parse("--[=======[foo]=======]"), 1)
	equal(#parse("--[=TESTSUITE\n-- utilities\nlocal ops = {}\n--]=]"), 6)
	equal(
		#parse(
			"foo--[[]].--[[]]bar--[[]]:--[==[]==]test--[[]](--[=[]=]1--[[]]--[[]],2--[[]])--------[[]]--[[]]--[===[]]"
		),
		11
	)
end)

test("unicode", function()
	equal(6, #tokenize("🐵=😍+🙅"))
	equal(5, #tokenize("foo(･✿ヾ╲｡◕‿◕｡╱✿･ﾟ)"))
	equal(
		5,
		#tokenize(
			"foo(ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็ด้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็็้้้้้้้้็็็็็้้้้้็็็็)"
		)
	)
end)

test("glua", function()
	equal(one_token(tokenize("/**/foo")).type, "letter")
	equal(one_token(tokenize("/*B*/foo")).type, "letter")
	equal(one_token(tokenize("/*-----*/foo")).type, "letter")
	equal(one_token(tokenize("--asdafsadw\nfoo--awsad asd")).type, "letter")
	equal(runtime_syntax:IsPrefixOperator(tokenize("!a")[1]), true)
	equal(runtime_syntax:GetBinaryOperatorInfo(tokenize("a != 1")[2]) ~= nil, true)
	equal(runtime_syntax:GetBinaryOperatorInfo(tokenize("a && b")[2]) ~= nil, true)
	equal(runtime_syntax:GetBinaryOperatorInfo(tokenize("a || b")[2]) ~= nil, true)
end)

do
	math.randomseed(os.time())

	local function gen_all_passes(out, prefix, parts, psign, powers)
		local passes = {}

		for _, p in ipairs(parts) do
			table.insert(passes, p)
		end

		for _, p in ipairs(parts) do
			table.insert(passes, "." .. p)
		end

		for _, a in ipairs(parts) do
			for _, b in ipairs(parts) do
				table.insert(passes, a .. "." .. b)
			end
		end

		for _, a in ipairs(passes) do
			table.insert(out, prefix .. a)

			for _, b in ipairs(powers) do
				table.insert(out, prefix .. a .. psign .. b)
				table.insert(out, prefix .. a .. psign .. "-" .. b)
				table.insert(out, prefix .. a .. psign .. "+" .. b)
			end
		end
	end

	local dec = "0123456789"
	local hex = "0123456789abcdefABCDEF"

	local function r(l, min, max)
		local out = {}

		for _ = 1, math.random(max - min + 1) + min - 1 do
			local x = math.random(#l)
			table.insert(out, l:sub(x, x))
		end

		return table.concat(out)
	end

	local decs = {"0", "0" .. r(dec, 1, 3), "1", r(dec, 1, 3)}
	local hexs = {"0", "0" .. r(hex, 1, 3), "1", r(hex, 1, 3)}
	local passes = {}
	gen_all_passes(passes, "", decs, "e", decs)
	gen_all_passes(passes, "", decs, "E", decs)
	gen_all_passes(passes, "0x", hexs, "p", decs)
	gen_all_passes(passes, "0x", hexs, "P", decs)
	gen_all_passes(passes, "0X", hexs, "p", decs)
	gen_all_passes(passes, "0X", hexs, "P", decs)

	test("valid literals", function()
		local code = {}

		for i, p in ipairs(passes) do
			table.insert(code, "local x" .. i .. " = " .. p)
		end

		local input = table.concat(code, "\n")
		-- make sure the amount of tokens
		local compiler = assert(nl.Compiler(input):Lex())
		equal(#compiler.Tokens, #code * 4 + 1)

		-- make sure all the tokens are numbers
		for i = 1, #compiler.Tokens - 1, 4 do
			equal("number", compiler.Tokens[i + 3].type)
		end
	end)
end
