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

function META:Error(msg, start, stop, level)
	if type(start) == "table" then
		start = start.start
	end
	if type(stop) == "table" then
		stop = stop.stop
	end
	local tk = self:GetToken() or self.chunks[#self.chunks]
	start = start or tk.start
	stop = stop or tk.stop

	if self.halt_on_error then
		error(oh.FormatError(self.code, self.path, msg, start, stop), level or 2)
	end

	table_insert(self.errors, print(oh.FormatError(self.code, self.path, msg, start, stop)))
end

function META:GetToken(offset)
	if offset then
		return self.chunks[self.i + offset]
	end

	return self.chunks[self.i]
end

function META:ReadToken()
	local tk = self:GetToken()
	self:Advance(1)
	return tk
end

function META:IsValue(str, offset)
	local tk = self:GetToken(offset)
	return tk and tk.value == str and tk
end

function META:IsType(str, offset)
	local tk = self:GetToken(offset)
	return tk and tk.type == str
end

function META:ReadIfValue(str, offset)
	local b = self:IsValue(str, offset)
	if b then
		self:Advance(1)
	end
	return b
end

function META:ReadExpectType(type, start, stop)
	local tk = self:GetToken()
	if not tk then
		self:Error("expected " .. oh.QuoteToken(type) .. " reached end of code", start, stop, 3)
	elseif tk.type ~= type then
		self:Error("expected " .. oh.QuoteToken(type) .. " got " .. tk.type, start, stop, 3)
	end
	self:Advance(1)
	return tk
end

function META:ReadExpectValue(value, start, stop)
	local tk = self:ReadToken()
	if not tk then
		self:Error("expected " .. oh.QuoteToken(value) .. ": reached end of code", start, stop, 3)
	elseif tk.value ~= value then
		self:Error("expected " .. oh.QuoteToken(value) .. ": got " .. tk.value, start, stop, 3)
	end
	return tk
end

function META:ReadExpectValues(values, start, stop)
	local tk = self:GetToken()
	if not tk then
		self:Error("expected " .. oh.QuoteTokens(values) .. ": reached end of code", start, stop)
	elseif not table.hasvalue(values, tk.value) then
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

		exp.tokens[","] = self:GetToken()

		self:Advance(1)
	end

	return out
end

function META:NameList()
	local out = {}
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

		data.tokens[","] = self:GetToken()

		self:Advance(1)
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
		elseif self:IsValue("=", 1) then
			data = Node("assignment")
			data.key = Node("value", self:ReadToken())
			data.tokens["="] = self:ReadToken()
			data.expression = self:Expression()

		elseif token.value == "[" then
			data = Node("assignment")

			data.tokens["["] = self:ReadToken()
			data.key = self:Expression()
			data.tokens["]"] = self:ReadExpectValue("]")
			data.tokens["="] = self:ReadExpectValue("=")
			data.expression = self:Expression()
			data.expression_key = true
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

		data.tokens[","] = self:GetToken()

		self:Advance(1)
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

	local val

	local token = self:GetToken()

	if not token then
		self:Error("attempted to read expression but reached end of code")
		return
	end

	if oh.syntax.IsUnaryOperator(token) then
		local token = self:ReadToken()
		val = Node("unary")
		val.tokens.operator = token
		val.operator = token.value
		val.expression = self:Expression(math.huge, stop_on_call)
	elseif self:ReadIfValue("(") then
		local pleft = self:GetToken(-1)
		val = self:Expression(0, stop_on_call)
		if not val then
			self:Error("empty parentheses group", token)
		end
		val.tokens["("] = pleft
		val.tokens[")"] = self:ReadExpectValue(")")
	elseif token.value == "function" then
		val = self:Function("anonymous")
	elseif oh.syntax.IsValue(token) or (token.type == "letter" and not oh.syntax.keywords[token.value]) then
		val = Node("value", self:ReadToken())
	elseif token.value == "{" then
		val = self:Table()
	end
	local token = self:GetToken()

	if token and (token.value == "[" or token.value == "(" or token.value == "{" or token.type == "string") then
		val.calls = {}

		for _ = 1, self:GetLength() do
			local token = self:ReadToken()

			if not token then break end

			if token.value == "[" then
				local data = Node("index_expression")

				data.tokens["["] = token
				data.value = self:Expression(0, stop_on_call)
				data.tokens["]"] = self:ReadExpectValue("]")

				table_insert(val.calls, data)
			elseif token.value == "(" then

				if stop_on_call then
					self:Advance(-1)
					return val
				end

				self:Advance(-1)

				local start = self:GetToken()

				while self:IsValue("(") do
					local pleft = self:ReadToken()
					local data = Node("call")

					data.tokens["call("] = pleft
					data.arguments = self:ExpressionList()
					data.tokens["call)"] = self:ReadExpectValue(")", start)

					table_insert(val.calls, data)
				end
			elseif token.value == "{" then
				self:Advance(-1)
				local data = Node("call")
				data.arguments = {self:Table()}
				table_insert(val.calls, data)
			elseif token.type == "string" then
				local data = Node("call")
				data.arguments = {Node("value", token)}
				table_insert(val.calls, data)
			else
				self:Advance(-1)
				break
			end

			if
				(not self:GetToken() or not oh.syntax.operators[self:GetToken().value]) and
				not (token.value == "[" or token.value == "(" or token.value == "{" or token.type == "string")
			then
				break
			end
		end
	end

	token = self:GetToken()

	if token then
		while oh.syntax.operators[token.value] and oh.syntax.operators[token.value][1] > priority do
			local op = self:GetToken()
			if not op or not oh.syntax.operators[op.value] then
				break
			end

			self:Advance(1)

			local right = self:Expression(oh.syntax.operators[op.value][2], stop_on_call)
			if not right then
				break
			end

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
		local token = self:ReadToken()

		if not token then break end

		if stop and stop[token.value] then
			self:Advance(-1)
			return out
		end

		local data

		if token.value == "::" then
			data = Node("goto_label")

			data.tokens["::left"] = token
			data.label = Node("value", self:ReadExpectType("letter"))
			data.tokens["::right"]  = self:ReadExpectValue("::")

		elseif token.value == "goto" then
			data = Node("goto")

			data.tokens["goto"] = token
			data.label = Node("value", self:ReadExpectType("letter"))

		elseif token.value == "continue" then
			data = Node("continue")

			data.tokens["continue"] = token

			out.has_continue = true

			if self.loop_stack[1] then
				self.loop_stack[#self.loop_stack].has_continue = true
			end

		elseif token.value == "repeat" then
			data = Node("repeat")
			data.tokens["repeat"] = token

			table_insert(self.loop_stack, data)

			data.block = self:Block({["until"] = true})
			data.tokens["until"] = self:ReadExpectValue("until", token, token)
			data.expression = self:Expression()

			table_remove(self.loop_stack)
		elseif token.value == "local" then
			if self:GetToken().value == "function" then
				data = self:Function("simple_named")
				data.tokens["local"] = token
				data.is_local = true
			else
				data = Node("assignment")
				data.tokens["local"] = token
				data.is_local = true
				data.left = self:NameList()

				data.tokens["="] = self:ReadIfValue("=")

				if data.tokens["="] then
					data.right = self:ExpressionList()
				end
			end
		elseif token.value == "return" then
			data = Node("return")
			data.tokens["return"] = token
			data.expressions = self:ExpressionList()
		elseif token.value == "break" then
			data = Node("break")

			data.tokens["break"] = token
		elseif token.value == "do" then
			data = Node("do")

			data.tokens["do"] = token
			data.block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", token, token)

			out.has_continue = data.block.has_continue
		elseif token.value == "if" then
			data = Node("if")

			data.clauses = {}
			self:Advance(-1) -- we want to read the if in the upcoming loop

			local prev_token = token

			for _ = 1, self:GetLength() do
				local token = self:ReadToken()

				if not token then break end

				if token.value == "end" then
					data.tokens["end"] = token
					break
				end

				local clause = Node("clause")

				if token.value == "else" then
					clause.block = self:Block({["end"] = true})
					clause.tokens["end"] = self:ReadExpectValue("end", prev_token, prev_token)
					clause.tokens["if/else/elseif"] = token
				else
					clause.tokens["if/else/elseif"] = token
					clause.expr = self:Expression()
					clause.tokens["then"] = self:ReadExpectValue("then")
					clause.block = self:Block({["else"] = true, ["elseif"] = true, ["end"] = true})
					clause.tokens["end"] = self:ReadExpectValues({"else", "elseif", "end"}, prev_token, prev_token)
				end

				table.insert(data.clauses, clause)

				out.has_continue = data.clauses[#data.clauses].block.has_continue
				data.has_continue = out.has_continue

				self:Advance(-1) -- we want to read the else/elseif/end in the next iteration

				prev_token = token
			end
		elseif token.value == "while" then
			data = Node("while")

			data.tokens["while"] = token
			data.expr = self:Expression()
			data.tokens["do"] = self:ReadExpectValue("do")

			table_insert(self.loop_stack, data)

			data.block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", token, token)
			table.remove(self.loop_stack)
		elseif token.value == "for" then
			data = Node("for")
			data.tokens["for"] = token

			table_insert(self.loop_stack, data)

			if self:GetToken(1).value == "=" then
				data.iloop = true

				data.name = Node("value", self:ReadExpectType("letter"))
				data.tokens["="] = self:ReadExpectValue("=")
				data.val = self:Expression()
				data.tokens[",1"] = self:ReadExpectValue(",")
				data.max = self:Expression()

				if self:IsValue(",") then
					data.tokens[",2"] = self:ReadToken()
					data.incr = self:Expression()
				end

				data.tokens["do"] = self:ReadExpectValue("do")
			else
				local names = self:NameList()
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
		elseif token.value == "function" then
			self:Advance(-1)
			data = self:Function("expression_named")
		elseif token.value == "(" then
			self:Advance(-1)
			data = Node("expression")
			data.value = self:Expression()
		elseif token.type == "letter" then
			self:Advance(-1) -- we want to include the current letter in the loop
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
		elseif token.value == ";" then
			data = Node("end_of_statement")
			data.tokens[";"] = token
		elseif token.type == "eof" then
			data = Node("end_of_file")
			data.tokens["eof"] = token
		else
			self:Advance(-1)
			self:Error("unexpected token " .. oh.QuoteToken(token.value))
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

	local self = {}

	setmetatable(self, META)

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