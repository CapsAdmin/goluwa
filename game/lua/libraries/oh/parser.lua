local oh = ... or _G.oh

local META = {}
META.__index = META

local table_insert = table.insert
local table_remove = table.remove

local function Node(t, val)
	local node = {}

	node.type = t
	node.tokens = {}

	if val then
		node.value = val
	end

	return node
end

function META:Error(msg, start, stop, level, offset)
	if type(start) == "table" then
		start = start.start
	end
	if type(stop) == "table" then
		stop = stop.stop
	end
	local tk = self:GetTokenOffset(offset or 0) or self.chunks[#self.chunks]
	start = start or tk.start
	stop = stop or tk.stop

	if self.halt_on_error then
		error(oh.FormatError(self.code, self.path, msg, start, stop), level or 2)
	end

	table_insert(self.errors, print(oh.FormatError(self.code, self.path, msg, start, stop)))
end

function META:GetToken()
	return self.chunks[self.i]
end

function META:GetTokenOffset(offset)
	return self.chunks[self.i + offset]
end

function META:ReadToken()
	local tk = self:GetToken()
	self:Advance(1)
	return tk
end

function META:IsValue(str)
	return self.chunks[self.i] and self.chunks[self.i].value == str and self.chunks[self.i]
end

function META:IsType(str)
	local tk = self:GetToken()
	return tk and tk.type == str
end

function META:ReadIfValue(str)
	local b = self:IsValue(str)
	if b then
		self:Advance(1)
	end
	return b
end

function META:ReadExpectType(type, start, stop)
	local tk = self:GetToken()
	if not tk then
		self:Error("expected " .. oh.QuoteToken(type) .. " reached end of code", start, stop, 3, -1)
	elseif tk.type ~= type then
		self:Error("expected " .. oh.QuoteToken(type) .. " got " .. oh.QuoteToken(tk.type), start, stop, 3, -1)
	end
	self:Advance(1)
	return tk
end

function META:ReadExpectValue(value, start, stop)
	local tk = self:ReadToken()
	if not tk then
		self:Error("expected " .. oh.QuoteToken(value) .. ": reached end of code", start, stop, 3, -1)
	elseif tk.value ~= value then
		self:Error("expected " .. oh.QuoteToken(value) .. ": got " .. oh.QuoteToken(tk.value), start, stop, 3, -1)
	end
	return tk
end

function META:ReadExpectValues(values, start, stop)
	local tk = self:GetToken()
	if not tk then
		self:Error("expected " .. oh.QuoteTokens(values) .. ": reached end of code", start, stop)
	elseif not table.hasvaluei(values, tk.value) then
		self:Error("expected " .. oh.QuoteTokens(values) .. " got " .. tk.value, start, stop)
	end
	self:Advance(1)
	return tk
end

function META:GetLength()
	return self.chunks_length
end

function META:Advance(offset)
	self.i = self.i + offset
end

function META:ExpressionList()
	local out = {}
	for _ = 1, self:GetLength() do
		local exp = self:Expression()

		if not exp then return out end

		table_insert(out, exp)

		if not self:IsValue(",") then
			break
		end

		exp.tokens[","] = self:ReadToken()
	end

	return out
end

function META:NameList(out)
	out = out or {}
	for _ = 1, self:GetLength() do
		if not self:IsType("letter") and not self:IsValue("...") then
			break
		end

		local token = self:ReadToken()

		if not token then return out end

		local data = Node("value", token)
		table_insert(out, data)

		if not self:IsValue(",") then
			break
		end

		data.tokens[","] = self:ReadToken()
	end

	return out
end

function META:Table()
	local tree = Node("table")
	tree.children = {}
	tree.tokens["{"] = self:ReadExpectValue("{")

	for _ = 1, self:GetLength() do
		local token = self:GetToken()
		if not token then break end

		local data

		if token.value == "}" then
			break
		elseif token.value == "[" then
			data = Node("expression_value")

			data.tokens["["] = self:ReadToken()
			data.key = self:Expression()
			data.tokens["]"] = self:ReadExpectValue("]")
			data.tokens["="] = self:ReadExpectValue("=")
			data.expression = self:Expression()
			data.expression_key = true
		elseif token.type == "letter" then
			data = Node("key_value")

			data.key = Node("value", self:ReadToken())
			data.tokens["="] = self:ReadToken()
			data.expression = self:Expression()
		else
			data = Node("value", self:Expression())
		end

		table_insert(tree.children, data)

		if self:IsValue("}") then
			break
		end

		if not self:IsValue(",") and not self:IsValue(";") then
			self:Error("expected ".. oh.QuoteTokens(",", ";", "}") .. " got " .. self:GetToken().value)
		end

		data.tokens[","] = self:ReadToken()
	end

	tree.tokens["}"] = self:ReadExpectValue("}")

	return tree
end

function META:Function(variant)
	local data = Node("function")
	data.tokens["function"] = self:ReadExpectValue("function")
	if variant == "simple_named" then
		data.index_expression = self:ReadExpectType("letter")
	elseif variant == "expression_named" then
		data.index_expression = self:Expression(0, true)
	end
	local start = self:GetToken()

	data.tokens["func("] = self:ReadExpectValue("(")
	data.arguments = self:NameList()
	data.tokens["func)"] = self:ReadExpectValue(")", start, start)
	data.block = self:Block({["end"] = true})
	data.tokens["end"] = self:ReadExpectValue("end")
	return data
end

function META:Expression(priority, stop_on_call)
	priority = priority or 0

	local token = self:GetToken()

	if not token then
		self:Error("attempted to read expression but reached end of code")
		return
	end

	local val

	if oh.syntax.IsUnaryOperator(token) then
		val = Node("unary")
		val.tokens.operator = self:ReadToken()
		val.operator = val.tokens.operator.value
		val.expression = self:Expression(math.huge, stop_on_call)
	elseif self:IsValue("(") then
		local pleft = self:ReadToken()
		val = self:Expression(0, stop_on_call)
		if not val then
			self:Error("empty parentheses group", token)
		end

		val.tokens["left("] = val.tokens["left("] or {}
		table.insert(val.tokens["left("], pleft)

		val.tokens["right)"] = val.tokens["right)"] or {}
		table.insert(val.tokens["right)"], self:ReadExpectValue(")"))

	elseif token.value == "function" then
		val = self:Function("anonymous")
	elseif oh.syntax.IsValue(token) or (token.type == "letter" and not oh.syntax.keywords[token.value]) then
		val = Node("value", self:ReadToken())
	elseif token.value == "{" then
		val = self:Table()
	end

	token = self:GetToken()

	if token and (token.value == "[" or token.value == "(" or token.value == "{" or token.type == "string") then
		val.calls = {}

		for _ = 1, self:GetLength() do
			if not self:GetToken() then break end

			if self:IsValue("[") then
				local data = Node("index_expression")

				data.tokens["["] = self:ReadToken()
				data.value = self:Expression(0, stop_on_call)
				data.tokens["]"] = self:ReadExpectValue("]")

				table_insert(val.calls, data)
			elseif self:IsValue("(") then

				if stop_on_call then
					return val
				end

				local start = self:GetToken()

				while self:IsValue("(") do
					local pleft = self:ReadToken()
					local data = Node("call")

					data.tokens["call("] = pleft
					data.arguments = self:ExpressionList()
					data.tokens["call)"] = self:ReadExpectValue(")", start)

					table_insert(val.calls, data)
				end
			elseif self:IsValue("{") then
				local data = Node("call")
				data.arguments = {self:Table()}
				table_insert(val.calls, data)
			elseif self:IsType"string" then
				local data = Node("call")
				data.arguments = {Node("value", self:ReadToken())}
				table_insert(val.calls, data)
			else
				break
			end
		end
	end

	token = self:GetToken()

	if token then
		while oh.syntax.operators[token.value] and oh.syntax.operators[token.value][1] > priority do
			local op = self:GetToken()
			if not op or not oh.syntax.operators[op.value] then break end
			self:Advance(1)

			local right = self:Expression(oh.syntax.operators[op.value][2], stop_on_call)
			local left = val

			val = Node("operator")
			val.operator = op.value
			val.tokens.operator = op
			val.left = left
			val.right = right
		end
	end

	return val
end

function META:Block(stop)
	self.loop_stack = self.loop_stack or {}

	local out = {}

	for _ = 1, self:GetLength() do
		if not self:GetToken() or stop and stop[self:GetToken().value] then
			break
		end

		local data

		if self:IsValue("::") then
			data = Node("goto_label")

			data.tokens["::left"] = self:ReadToken()
			data.label = Node("value", self:ReadExpectType("letter"))
			data.tokens["::right"]  = self:ReadExpectValue("::")

		elseif self:IsValue("goto") then
			data = Node("goto")

			data.tokens["goto"] = self:ReadToken()
			data.label = Node("value", self:ReadExpectType("letter"))

		elseif self:IsValue("continue") then
			data = Node("continue")

			data.tokens["continue"] = self:ReadToken()

			out.has_continue = true

			if self.loop_stack[1] then
				self.loop_stack[#self.loop_stack].has_continue = true
			end

		elseif self:IsValue("repeat") then

			local token = self:GetToken()

			data = Node("repeat")
			data.tokens["repeat"] = self:ReadToken()

			table_insert(self.loop_stack, data)

			data.block = self:Block({["until"] = true})
			data.tokens["until"] = self:ReadExpectValue("until", token, token)
			data.expression = self:Expression()

			table_remove(self.loop_stack)
		elseif self:IsValue("local") then
			local local_ = self:ReadToken()

			data = Node("assignment")
			data.tokens["local"] = local_
			data.is_local = true

			if self:IsValue("function") then
				data.sub_type = "function"
				data.value = self:Function("simple_named")
			else
				data.left = self:NameList()

				data.tokens["="] = self:ReadIfValue("=")

				if data.tokens["="] then
					data.right = self:ExpressionList()
				end
			end
		elseif self:IsValue("return") then
			data = Node("return")
			data.tokens["return"] = self:ReadToken()
			data.expressions = self:ExpressionList()
		elseif self:IsValue("break") then
			data = Node("break")

			data.tokens["break"] = self:ReadToken()
		elseif self:IsValue("do") then
			local token = self:GetToken()
			data = Node("do")

			data.tokens["do"] = self:ReadToken()
			data.block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", token, token)

			out.has_continue = data.block.has_continue
		elseif self:IsValue("if") then
			data = Node("if")

			data.clauses = {}

			local prev_token = self:GetToken()

			for _ = 1, self:GetLength() do

				if self:IsValue "end" then
					data.tokens["end"] = self:ReadToken()
					break
				end

				local clause = Node("clause")

				if self:IsValue("else") then
					clause.tokens["if/else/elseif"] = self:ReadToken()
					clause.block = self:Block({["end"] = true})
					clause.tokens["end"] = self:ReadExpectValue("end", prev_token, prev_token)
				else
					clause.tokens["if/else/elseif"] = self:ReadToken()
					clause.expr = self:Expression()
					clause.tokens["then"] = self:ReadExpectValue("then")
					clause.block = self:Block({["else"] = true, ["elseif"] = true, ["end"] = true})
					clause.tokens["end"] = self:ReadExpectValues({"else", "elseif", "end"}, prev_token, prev_token)
				end

				table.insert(data.clauses, clause)

				out.has_continue = data.clauses[#data.clauses].block.has_continue
				data.has_continue = out.has_continue

				prev_token = self:GetToken()

				self:Advance(-1) -- we want to read the else/elseif/end in the next iteration
			end
		elseif self:IsValue("while") then
			local token = self:GetToken()
			data = Node("while")

			data.tokens["while"] = self:ReadToken()
			data.expr = self:Expression()
			data.tokens["do"] = self:ReadExpectValue("do")

			table_insert(self.loop_stack, data)

			data.block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", token, token)
			table.remove(self.loop_stack)
		elseif self:IsValue("for") then
			local token = self:GetToken()
			data = Node("for")
			data.tokens["for"] = self:ReadToken()

			table_insert(self.loop_stack, data)

			local identifier = self:ReadExpectType("letter")

			if self:IsValue("=") then
				data.iloop = true
				data.name = Node("value", identifier)
				data.tokens["="] = self:ReadToken("=")
				data.val = self:Expression()
				data.tokens[",1"] = self:ReadExpectValue(",")
				data.max = self:Expression()

				if self:IsValue(",") then
					data.tokens[",2"] = self:ReadToken()
					data.incr = self:Expression()
				end

				data.tokens["do"] = self:ReadExpectValue("do")
			elseif self:IsValue(",") then
				local name = Node("value", identifier)
				name.tokens[","] = self:ReadToken()
				local names = self:NameList({name})

				data.tokens["in"] = self:ReadExpectValue("in")
				data.iloop = false
				data.names = names
				data.expressions = self:ExpressionList()
				data.tokens["do"] = self:ReadExpectValue("do")
			end

			local block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", token, token)
			data.block = block

			table.remove(self.loop_stack)
		elseif self:IsValue("function") then
			data = Node("assignment")
			data.sub_type = "function"
			data.value = self:Function("expression_named")
		elseif self:IsValue("(") then
			data = Node("expression")
			data.value = self:Expression()
		elseif self:IsType("letter") then
			local expr = self:Expression()

			if self:IsValue("=") then
				data = Node("assignment")
				data.left = {expr}
				data.tokens["="] = self:ReadToken()
				data.right = self:ExpressionList()
			elseif self:IsValue(",") then
				data = Node("assignment")
				expr.tokens[","] = self:ReadToken()
				local list = self:ExpressionList()
				table_insert(list, 1, expr)
				data.left = list
				data.tokens["="] = self:ReadExpectValue("=")
				data.right = self:ExpressionList()
			else
				data = Node("expression")
				data.value = expr
			end
		elseif self:IsValue(";") then
			data = Node("end_of_statement")
			data.tokens[";"] = self:ReadToken()
		elseif self:IsType("end_of_file") then
			data = Node("end_of_file")
			data.tokens["eof"] = self:ReadToken()
		elseif self:IsType("shebang") then
			data = Node("shebang")
			data.tokens["shebang"] = self:ReadToken()
		else
			self:Error("unexpected token " .. self:GetToken().type .. " " .. oh.QuoteToken(self:GetToken().value))
		end

		table_insert(out, data)
	end

	return out
end


function META:GetAST()
	return self:Block()
end

function oh.Parser(tokens, code, path, halt_on_error)
	if halt_on_error == nil then
		halt_on_error = true
	end

	local self = setmetatable({}, META)

	self.chunks = tokens
	self.chunks_length = #tokens
	self.code = code
	self.path = path or "?"

	self.halt_on_error = halt_on_error
	self.errors = {}

	self.i = 1

	return self
end

if RELOAD then
	runfile("lua/libraries/oh/test.lua")
end