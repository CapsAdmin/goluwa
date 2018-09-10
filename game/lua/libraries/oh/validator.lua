local oh = ... or _G.oh

local env = {}

function oh.Validate(tree)
	for i, data in ipairs(tree) do
		if data.type == "assignment" then
			local node = env
			for _, data in ipairs(data.left[1].value) do
				if not node[data.value.value] then
					node[data.value.value] = {prev = node}
				end
				node = node[data.value.value]
			end
			for _, data in ipairs(data.right) do
				if data.type == "table" then
					local info = {}
					for i,v in ipairs(data.children) do
						info[v.indices[1].value] = v.expressions[1].type
					end
					table.insert(node, info)
				end
			end
		end
	end

	table.print(env)
end

--[[
local types = {
	string = true,
	number = true,
	table = true,
}

event.AddListener("OhReadExpression", "", function(self, token)
	if token.value == "new" then
		self:NextToken()
		return {type = "new"}
	end
	if types[token.value] then
		self:NextToken()
		local val = self:ReadExpression(0)
		val.type2 = token.value
		return val
	end
end)
event.AddListener("OhReadTable", "", function(self, token)
	if token.value == "function" then
		if self:GetToken(1).type == "letter" then
			self:NextToken()
			local data = {}
			data.type = "function"
			data.expression = self:ReadIndexExpression()
			data.body = self:ReadBody("end")
			data.self_function = true
			return data
		end
	end
	if types[token.value] then
		self:NextToken()

		local index = self:GetToken()

		if index.value == "function" then
			self:NextToken()
			local data = {}
			data.type = "function"
			data.expression = self:ReadIndexExpression()
			data.body = self:ReadBody("end")
			data.self_function = true
			data.type2 = token.value
			return data
		else
			self:NextToken()
			self:NextToken()

			local data = {}
			data.type = "assignment"
			data.expressions = {self:ReadExpression()}
			data.indices = {index}
			data.type2 = token.value

			return data
		end
	end
end)
event.AddListener("OhReadBody", "", function(self, token)
	if token.value == "type" then
		local typename = self:ReadToken()
		types[typename] = {}
		local data = self:ReadTable()
		types[typename] = data

		return {type = "newtype", name = typename, data = data}
	end
	if types[token.value] then
		if self:GetToken().value == "function" then
			self:NextToken()
			local data = {}
			data.type = "function"
			data.type2 = token.value
			data.expression = self:ReadIndexExpression()
			data.body = self:ReadBody("end")

			return data
		else
			local data = self:ReadAssignment()
			data.is_local = true
			data.type2 = token.value
			return data
		end
	end
end)
]]
if RELOAD then

	if false then
		oh.types.foo = {}
		oh.types.foo.__index = foo
		oh.types.typeinfo = {
			a = "number",
			b = "string",
			foo = "foo",
		}
		function oh.types.foo.foo(a, b)
			return a + b
		end

		oh.types.foo.test_number_a = function(self) end
		oh.types.foo.test_string_a = function(self) end

		test = oh.types.foo.new_ab()

		test.a = 5
		test.b = ""
		test.c = "" -- error
	end

	local code = [[

	type foo {
		number a = 2,
		string b = "",

		foo function foo(a, b)
			return a + b
		end,
	}

	function foo:test(string a)

	end

	function foo:test(number a)

	end

	test = new foo()

	test.a = 5
	test.b = ""
	test.c = "" -- should error

	number function test(number a or 1, number b or 2)
		return a + 3
	end

	w.test2("", false)
	]]

	local code = [[
		local test = {
			a = 1,
			b = "1",
		}

		test.a = 4
	]]

	oh.Validate(oh.Tokenize(code):ReadBody())
end