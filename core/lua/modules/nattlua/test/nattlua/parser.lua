local nl = require("nattlua")

local function parse(code)
	return assert(assert(nl.Compiler(code)):Parse())
end

local function check(code, eq)
	local c = parse(code)
	local new_code = assert(c:Emit())
	equal(new_code, eq or code, 2)
	return new_code
end

test("empty code", function()
	check("")
end)

test("empty return statement", function()
	check("return true")
end)

test("do statement", function()
	check("do end")
	check("do do end end")
end)

test("while statement", function()
	check("while 1 do end")
end)

test("repeat until statement", function()
	check("repeat until 1")
end)

test("numeric for loop", function()
	check("for i = 1, 1 do end")
	check("for i = 1, 1, 1 do end")
end)

test("generic for loop", function()
	check("for k,v in a do end")
	check("for a,b,c,d,e,f,g in a do end")
	check("for a,b,c,d,e,f,g in a,b,c,d,e,f,g do end")
end)

test("function statements", function()
	check("function test() end")
	check("local function test() end")
	check("function foo.bar() end")
	check("function foo.bar.baz() end")
	check("function foo:bar() end")
	check("local test = function() end")
end)

test("call expressions", function()
	check("a()")
	check("a.b()")
	check("a.b.c()")
	check("a.b:c()")
	check("(function(b) return 1 end)(2)")
	check("foo.a.b.c[5](1)[2](3)")
	check("foo(1)'1'{1}[[1]][1]\"1\"")
	check("a=(foo.bar)()")
	check("lol({...})")
end)

test("if statements", function()
	check("if 1 then end")
	check("if 1 then else end")
	check("if 1 then elseif 2 then else end")
	check("if 1 then elseif 2 then elseif 3 then else end")
end)

test("local declarations", function()
	check("local a")
	check("local a = 1")
	check("local a = 1,2,3")
	check("local a,b,c = 1,2,3")
	check("local a,c = 1,2,3")
	check("local <const> c = 1")
end)

test("global declarations", function()
	check("a = 1")
	check("a = 1,2,3")
	check("a,b,c = 1,2,3")
	check("a,c = 1,2,3")
end)

test("object assignments", function()
	check("a[b] = a")
	check("(a)[b] = a")
	check("foo.bar.baz[b] = a")
	check("foo.bar.baz = a")
	check("foo.bar.baz = a")
end)

test("optional semicolons", function()
	check("local a = 1;")
	check("local a = 1;local a = 1")
	check("local a = 1;;;")
	check(";;foo 'testing syntax';;")
	check("#testse tseokt osektokseotk\nprint('ok')")
	check("do ;;; end\n; do ; a = 3; assert(a == 3) end;\n;")
end)

test("parenthesis", function()
	check("local a = (1)+(1)")
	check("local a = (1)+(((((1)))))")
	check("local a = 1 --[[a]];")
	check("local a = 1 --[=[a]=] + (1);")
	check("local a = (--[[1]](--[[2]](--[[3]](--[[4]]4))))")
	check("local a = 1 --[=[a]=] + (((1)));")
	check("a = (--[[a]]((-a)))")
end)

test("// binary operator", function()
	check("// lol\nprint(3 // (5 // 2))", "// lol\nprint(3/idiv/ (5/idiv/ 2)) ")
	check("local yes = 10\n// woo", "local yes = 10\n// woo")
	check("local yes = 10 // woo", "local yes = 10/idiv/ woo ")
end)

test("types", function()
	check(
		"syntax.SymbolCharacters --[[#: {[number] = string} ]]= {}",
		"syntax.SymbolCharacters = {}"
	)
	check("a: number = (lol as function=()>(number))()", "a = (lol)()")
	check("function foo(a: number): number end", "function foo(a) end")
	check("function foo:bar(a: number): number end", "function foo:bar(a) end")
	check("function foo.bar(a: number): number end", "function foo.bar(a) end")
	check("function foo<||> end", "--[[#function foo<||> end]]")
	check("local function foo<||> end", "--[[#local function foo<||> end]]")
	check("local analyzer function foo() end", "--[[#local analyzer function foo() end]]")
end)

test("teal", function()
	local check = function(code, eq)
		return check("£parser.TealCompat=true\n" .. code, eq)
	end
-- check("local function foo<T>(a: Foo<T>) end", "syntax.SymbolCharacters = {}")
end)

test("type comments", function()
	local tree = parse("function foo(str: string, idx: number, msg: string) end").SyntaxTree
	local func = tree.statements[1]
	assert(func.identifiers[1].type_expression)
	assert(func.identifiers[2].type_expression)
	assert(func.identifiers[3].type_expression)
	local tree = parse("function foo(str--[[#: string]], idx--[[#: number]], msg--[[#: string]]) end").SyntaxTree
	local func = tree.statements[1]
	assert(func.identifiers[1].type_expression)
	assert(func.identifiers[2].type_expression)
	assert(func.identifiers[3].type_expression)
end)

test("operator precedence", function()
	local function expand(node, tbl)
		if node.kind == "prefix_operator" or node.kind == "postfix_operator" then
			table.insert(tbl, node.value.value)
			table.insert(tbl, "(")
			expand(node.right or node.left, tbl)
			table.insert(tbl, ")")
			return tbl
		elseif node.kind:sub(1, #"postfix") == "postfix" then
			table.insert(tbl, node.kind:sub(#"postfix" + 2))
		elseif node.kind ~= "binary_operator" then
			table.insert(tbl, node:Render())
		else
			table.insert(tbl, node.value.value)
		end

		if node.left then
			table.insert(tbl, "(")
			expand(node.left, tbl)
		end

		if node.right then
			table.insert(tbl, ", ")
			expand(node.right, tbl)
			table.insert(tbl, ")")
		end

		if node.kind:sub(1, #"postfix") == "postfix" then
			local str = {""}

			for _, exp in ipairs(node.expressions or {node.expression}) do
				table.insert(str, exp:Render())
			end

			table.insert(tbl, table.concat(str, ", "))
			table.insert(tbl, ")")
		end

		return tbl
	end

	local function dump_precedence(expr)
		local list = expand(expr, {})
		local a = table.concat(list)
		return a
	end

	local function check(compiler, expect)
		-- turn the expression into a statement to make the code valid
		compiler.Code.Buffer = "a = " .. compiler.Code.Buffer
		local ast = assert(compiler:Parse()).SyntaxTree
		local expr = ast:FindNodesByType("assignment")[1].right[1]
		local res = dump_precedence(expr)

		if expect ~= res then
			io.write("EXPECT: " .. expect, "\n")
			io.write("GOT   : " .. res, "\n")
		end
	end

	check(nl.Compiler("-2 ^ 2"), "^(-(2), 2)")
	check(nl.Compiler("pcall(require, \"ffi\")"), "call(pcall, require, \"ffi\")")
	check(nl.Compiler("1 / #a"), "/(1, #(a))")
	check(
		nl.Compiler("jit.status and jit.status()"),
		"and(.(jit, status), call(.(jit, status)))"
	)
	check(nl.Compiler("a.b.c.d.e.f()"), "call(.(.(.(.(.(a, b), c), d), e), f))")
	check(nl.Compiler("(foo.bar())"), "call(.(foo, bar))")
	check(
		nl.Compiler[[-1^21+2+a(1,2,3)()[1]""++ ÆØÅ]],
		[[+(+(^(-(1), 21), 2), ÆØÅ(++(call(expression_index(call(call(a, 1, 2, 3)), 1), ""))))]]
	)
	check(nl.Compiler[[#{} - 2]], [[-(#({}), 2)]])
	check(
		nl.Compiler[[a or true and false or 4 or 5 and 5]],
		[[or(or(or(a, and(true, false)), 4), and(5, 5))]]
	)
end)

test("parser errors", function()
	local function check(tbl)
		for i, v in ipairs(tbl) do
			_G.TEST = true
			local ok, err = nl.load(v[1])
			_G.TEST = false

			if ok then
				io.write(tostring(ok), tostring(v[1]), "\n")
				error("expected error, but code compiled", 2)
			end

			if not err:find(v[2]) then
				io.write(err, "\n")
				io.write("~=", "\n")
				io.write(v[2], "\n")
				error("error does not match")
			end
		end
	end

	check(
		{
			{"a,b", "expected assignment or call expression"},
			{"local foo[123] = true", ".- expected assignment or call expression"},
			{
				"/clcret retprio inq tv5 howaw tv4aw exoaw",
				"expected assignment or call expression",
			},
			{"foo( “Hello World” )", "expected.-%).-got.-World”"},
			{
				"foo = {bar = until}, faz = true}",
				"expected beginning of expression, got.-until",
			},
			{"foo = {1, 2 3}", "expected.-,.-;.-}.-got.-3"},
			{"if foo = 5 then end", "expected.-then"},
			{"if foo == 5 end", "expected.-then.-got.-end"},
			{"if 0xWRONG then end", "malformed hex number, got W"},
			{"if true then", "expected.-elseif.-got.-end_of_file"},
			{"a = [[wa", "expected multiline string.-%]%].-reached end of code"},
			{"a = [=[wa", "expected multiline string.-%]=%].-reached end of code"},
			{"a = [=wa", "expected multiline string.-%[=%[.-got.-%[=w"},
			{"a = [=[wa]=", "expected multiline string.-%]=%].-reached end of code"},
			{"0xBEEFp+L", "malformed pow expected number, got L"},
			{"foo(())", "expected beginning of expression, got.+%)"},
			{"a = {", "expected beginning of expression.-end_of_file"},
			{"a = 0b1LOL01", "malformed binary number, got L"},
			{"a = 'aaaa", "expected single quote.-reached end of file"},
			{"a = 'aaaa \ndawd=1", "expected single quote"},
			{"foo = !", "expected beginning of expression.-end_of_file"},
			{"foo = then", "expected beginning of expression.-got.-then"},
			{"--[[aaaa", "expected multiline comment.-reached end of code"},
			{"--[[aaaa\na=1", "expected multiline comment.-reached end of code"},
			{"::1::", "expected.-letter.-got.-number"},
			{"::", "expected.-letter.-got.-end_of_file"},
			{"!!!!!!!!!!!", "expected.-got.-end_of_file"},
			{"do do end", "expected.-end.-got.-"},
			{"local a = 1 === 1", "expected assignment or call"},
			{"\n\n\nif $test then end", "expected.-then.-got.-$"},
			{"local x = <Text>foo</Text>", "expected.-string.-got.-letter.-$"},
			{"local x = <Text>1</Text>", "expected.-string.-got.-number.-$"},
		}
	)
end)

parse[[
    £ assert(#parser.nodes == 1)
    £ assert(parser.nodes[#parser.nodes + 1 - 1].kind == "root")
    
    do
        £ assert(parser.nodes[#parser.nodes + 1 - 1].kind == "do")
        £ assert(parser.nodes[#parser.nodes + 1 - 2].kind == "root")
        
        local function test()
            £ assert(parser.nodes[#parser.nodes + 1 - 1].kind == "local_function")
    
            local x = 1337
            £ parser.value = parser.current_expression
            £ assert(parser.value.kind == "value")
            £ assert(parser.value.parent.kind == "local_assignment")
            £ assert(parser.value.parent.parent.kind == "local_function")
        end
    end

    £ assert(#parser.nodes == 1)
    £ assert(parser.nodes[#parser.nodes + 1 - 1].kind == "root")
]]

do
	parse[==[
        --[[#£ _G.LOL=true]]
        £assert(_G.LOL)
        --[=[#£ _G.LOL=nil]=]
    ]==]
	assert(_G.LOL == nil)
end

parse[=[

	--[[#type integer = number]]
	for i, obj in ipairs(arguments) do
		args[i] = obj:GetData()[ys[i]]
	end
	
]=]
parse[=[

local x = <View style={styles.container} foo={1} bar={"aa"}/>

local x = <View>
	"hello world"
</View>

local x = <View>
	"hello world 12314 aowdk oawkd }"
</View>

local x = <View>
	<View>
		[[hello world 
		
		12314 aowdk oawkd]]
	</View>
	
</View>

local x = <View>
	<MaterialIcons style={styles.delete} name="delete" size={18} color='#fff'/>
	
</View>

local x = <Text>
	{props.index}
</Text>

local x = <View style={styles.container}>
	<View style={styles.indexContainer}>
		<Text style={styles.index}>
			{props.index}		
		</Text>
			
	</View>
	
</View>

local x = <View style={styles.container}>
	<Text1 style={styles.index}>
		{props.index}	
	</Text1>
	"lol" <Text2 style={styles.index}>
		{props.index}	
	</Text2>
</View>

local x = <View style={styles.container}>
	<View style={styles.indexContainer}>
		<Text style={styles.index}>
			{props.index}		
		</Text>
			
	</View>
	<View style={styles.taskContainer}>
		<Text style={styles.task}>
			{props.task}		
		</Text>
		<TouchableOpacity onPress={function()
			props.deleteTask()
		end}>
			<MaterialIcons style={styles.delete} name="delete" size={18} color='#fff'/>
					
		</TouchableOpacity>
			
	</View>
	
</View>
]=]