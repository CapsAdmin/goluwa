local oh = ... or _G.oh

local META = {}
META.__index = META

function META:Error(msg, start, stop)
	if type(start) == "table" then
		start = start.start
	end
	if type(stop) == "table" then
		stop = stop.stop
	end
	local tk = self:GetToken() or self.chunks[#self.chunks]
	start = start or tk.start
	stop = stop or tk.stop


	error(oh.FormatError(self.code, self.path, msg, start, stop))
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
		self:Error("expected " .. oh.QuoteToken(type) .. " reached end of code", start, stop)
	end
	if tk.type ~= type then
		self:Error("expected " .. oh.QuoteToken(type) .. " got " .. tk.type, start, stop)
	end
	self:Advance(1)
	return tk
end

function META:ReadExpectValue(value, start, stop, msg)
	local tk = self:GetToken()
	if not tk then
		self:Error("expected " .. oh.QuoteToken(value) .. ": reached end of code", start, stop)
	end
	if tk.value ~= value then
		self:Error("expected " .. oh.QuoteToken(value) .. ": got " .. tk.value, start, stop)
	end
	self:Advance(1)
	return tk
end

function META:ReadExpectValues(values, start, stop, msg)
	local tk = self:GetToken()
	if not tk then
		self:Error("expected " .. oh.QuoteTokens(values) .. ": reached end of code", start, stop)
	end
	if not table.hasvalue(values, tk.value) then
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

local table_insert = table.insert
local table_remove = table.remove

function META:ExpressionList()
	local out = {}
	for _ = 1, self:GetLength() do
		local exp = self:Expression()

		if not exp then return out end

		table_insert(out, exp)

		if not self:IsValue(",") then
			break
		end

		exp[","] = self:GetToken()

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

		local exp = self:ReadToken()

		if not exp then return out end

		exp[","] = self:GetToken()

		table_insert(out, exp)

		if not self:IsValue(",") then
			break
		end

		self:Advance(1)
	end

	return out
end


function META:Assignment(namelist)
	local start = self:GetToken()

	local left = namelist and self:NameList() or self:ExpressionList()
	local eqtoken = self:ReadIfValue("=")
	if eqtoken then
		return {type = "assignment", left = left, right = self:ExpressionList(), ["="] = eqtoken}
	else
		if left[2] or left[1].type ~= "index_call_expression" or left[1].type == "index_call_expression" and left[1].value[#left[1].value].type ~= "call" then
			self:Error("expected call got unexpected statment", start, start)
		end
		return {type = "assignment", left = left}
	end
end

function META:Table()
	local tree = {}
	tree.type = "table"
	tree.children = {}

	tree["{"] = self:ReadExpectValue("{")

	for _ = 1, self:GetLength() do
		local token = self:GetToken()
		if not token then break end

		local data

		if token.value == "}" then
			break
		elseif self:IsValue("=", 1) then
			data = {}
			data.type = "assignment"
			data.indices = {self:ReadToken()}
			data["="] = self:ReadToken()
			data.expressions = {self:Expression()}

		elseif token.value == "[" then
			data = {}
			data.type = "assignment"
			data["["] = token self:Advance(1)
			data.indices = {self:Expression()}
			data["]"] = self:ReadExpectValue("]")
			data["="] = self:ReadExpectValue("=")
			data.expressions = {self:Expression()}
			data.expression_key = true
		else
			data = {}
			data.type = "value"
			data.value = self:Expression()
		end

		table_insert(tree.children, data)

		if self:IsValue("}") then
			break
		end
		if not self:IsValue(",") and not self:IsValue(";") then
			self:Error("expected ".. oh.QuoteTokens(",", ";", "}") .. " got " .. self:GetToken().value)
		end

		data[","] = self:GetToken()

		self:Advance(1)
	end

	tree["}"] = self:ReadExpectValue("}")

	return tree
end

function META:IndexExpression(hm, simple_call)
	local out = {}

	for _ = 1, self:GetLength() do
		local token = self:ReadToken()

		if not token then break end

		if token.type == "letter" and not oh.syntax.keywords[token.value] then
			if _ > 1 and (self:IsType("letter", -2) or self:IsValue("]", -2) or self:IsValue("}", -2)) then
				self:Advance(-1)
				break
			end
			table_insert(out, {type = "index", operator = _ == 1 and {value = ""} or self:GetToken(-2), value = token})
		elseif token.value == "[" then
			local data = {type = "index_expression", value = self:Expression(), ["["] = token}
			table_insert(out, data)
			data["]"] = self:ReadExpectValue("]")
		elseif token.value == "(" then
			self:Advance(-1)

			if simple_call then break end

			while self:IsValue("(") do
				local pleft = self:ReadToken()
				local data = {type = "call", arguments = simple_call and self:NameList() or self:ExpressionList(), ["call("] = pleft}
				table_insert(out, data)
				data["call)"] = self:ReadExpectValue(")")
			end

			if self:IsType("letter") then
				break
			end
		elseif token.value == "{" then
			self:Advance(-1)
			table_insert(out, {type = "call", arguments = {self:Table()}})
		elseif token.type == "string" then
			table_insert(out, {type = "call", arguments = {token}})
			if self:IsType("letter") then
				break
			end
		elseif token.value ~= "." and token.value ~= ":" then
			self:Advance(-1)
			break
		end
	end

	return out
end

function META:Expression(priority)
	priority = priority or 0

	local val

	local token = self:GetToken()

	if not token then return end

	if oh.syntax.IsUnaryOperator(token) then
		local unary = self:ReadToken()
		local exp = self:Expression(math.huge)
		val = {type = "unary", value = unary, argument = exp}
	elseif self:ReadIfValue("(") then
		local pleft = self:GetToken(-1)
		val = self:Expression(0)
		local pright = self:ReadExpectValue(")")

		val["("] = pleft
		val[")"] = pright

		if self:IsValue(".") or self:IsValue(":") or self:IsValue("[") or self:IsValue("(") or self:IsValue("{") or self:IsType("string") then
			local right = self:IndexExpression(true)

			table_insert(right, 1, val)
			val = {type = "index_call_expression", value = right}
		end
	elseif oh.syntax.IsValue(token) then
		val = self:ReadToken()
	elseif token.value == ":" then
		val = {type = "index_call_expression", value = self:IndexExpression()}
	elseif token.value == "{" then
		val = self:Table()
	elseif token.value == "function" then
		local tkfunc = token
		self:Advance(1)
		local tkleft = self:ReadExpectValue("(")
		local arguments = self:NameList()
		local tkright = self:ReadExpectValue(")")
		local body = self:Block({["end"] = true})
		val = {type = "function", arguments = arguments, body = body, ["end"] = self:ReadExpectValue("end"), ["function"] = tkfunc, ["func("] = tkleft, ["func)"] = tkright}
	elseif token.type == "letter" and not oh.syntax.keywords[token.value] then
		val = {type = "index_call_expression", value = self:IndexExpression()}
	elseif token.value == ";" then
		self:Advance(1)
		return
	else
		return
	end

	local token = self:GetToken()

	if not token then return val end

	while oh.syntax.operators[token.value] and oh.syntax.operators[token.value][1] > priority do
		local op = self:GetToken()
		if not op or not oh.syntax.operators[op.value] then return val end
		self:Advance(1)
		val = {type = "operator", value = op, left = val, right = self:Expression(oh.syntax.operators[op.value][2])}
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

		if token.value == "::" then
			local data = {}
			data.type = "goto_label"
			data.left = token
			data.label = self:ReadExpectType("letter")
			table_insert(out, data)
			data.right = self:ReadExpectValue("::")
		elseif token.value == "goto" then
			local data = {}
			data.type = "goto"
			data["goto"] = token
			data.label = self:ReadExpectType("letter")
			table_insert(out, data)
		elseif token.value == "continue" then
			local data = {}
			data.type = "continue"
			data["continue"] = token
			table_insert(out, data)

			out.has_continue = true

			if self.loop_stack[1] then
				self.loop_stack[#self.loop_stack].has_continue = true
			end
		elseif token.value == "repeat" then
			local data = {}
			data.type = "repeat"
			data["repeat"] = token

			table_insert(self.loop_stack, data)

			data.body = self:Block({["until"] = true})
			data["until"] = self:ReadExpectValue("until", token, token)
			data.expr = self:Expression()
			table_insert(out, data)

			table_remove(self.loop_stack)
		elseif token.value == "local" then
			if self:GetToken().value == "function" then
				local data = {}
				data.type = "function"
				data["local"] = token
				data["function"] = self:ReadToken()
				data.is_local = true
				data.index_expression = self:ReadExpectType("letter")
				data["func("] = self:ReadExpectValue("(")
				data.arguments = self:NameList()
				data["func)"] = self:ReadExpectValue(")")
				data.body = self:Block({["end"] = true})
				data["end"] = self:ReadExpectValue("end", token, token)
				table_insert(out, data)
			else
				local data = self:Assignment(true)
				data.is_local = true
				data["local"] = token
				table_insert(out, data)
			end
		elseif token.value == "return" then
			local data = {}
			data.type = "return"
			data["return"] = token
			data.expressions = self:ExpressionList()
			table_insert(out, data)
		elseif token.value == "break" then
			local data = {}
			data.type = "break"
			data["break"] = token
			table_insert(out, data)
		elseif token.value == "do" then
			local data = {}
			data.type = "do"
			data["do"] = token
			data.body = self:Block({["end"] = true})
			data["end"] = self:ReadExpectValue("end", token, token)
			out.has_continue = data.body.has_continue
			table_insert(out, data)
		elseif token.value == "if" then
			local data = {}
			data.type = "if"
			data.statements = {}
			self:Advance(-1) -- we want to read the if in the upcoming loop

			local prev_token = token

			for _ = 1, self:GetLength() do
				local token = self:ReadToken()

				if token.value == "end" then
					data["end"] = token
					break
				end

				if token.value == "else" then
					table_insert(data.statements, {
						body = self:Block({["end"] = true}),
						["end"] = self:ReadExpectValue("end", prev_token, prev_token),
						["if/else/elseif"] = token,
					})
				else
					table_insert(data.statements, {
						["if/else/elseif"] = token,
						expr = self:Expression(),
						["then"] = self:ReadExpectValue("then"),
						body = self:Block({["else"] = true, ["elseif"] = true, ["end"] = true}),
						["end"] = self:ReadExpectValues({"else", "elseif", "end"}, prev_token, prev_token),
					})
				end

				out.has_continue = data.statements[#data.statements].body.has_continue
				data.has_continue = out.has_continue

				self:Advance(-1) -- we want to read the else/elseif/end in the next iteration

				prev_token = token
			end
			table_insert(out, data)
		elseif token.value == "while" then
			local data = {}

			data.type = "while"
			data["while"] = token
			data.expr = self:Expression()
			data["do"] = self:ReadExpectValue("do")

			table_insert(self.loop_stack, data)

			data.body = self:Block({["end"] = true})
			data["end"] = self:ReadExpectValue("end", token, token)

			table_insert(out, data)

			table.remove(self.loop_stack)
		elseif token.value == "for" then
			local data = {}
			data.type = "for"
			data["for"] = token

			table_insert(self.loop_stack, data)

			if self:GetToken(1).value == "=" then
				data.iloop = true
				data.name = self:ReadExpectType("letter")
				data["="] = self:ReadExpectValue("=")
				data.val = self:Expression()
				data[",1"] = self:ReadExpectValue(",")
				data.max = self:Expression()

				if self:IsValue(",") then
					data[",2"] = self:ReadToken()
					data.incr = self:Expression()
				end

				data["do"] = self:ReadExpectValue("do")
			else
				local names = self:NameList()

				data["in"] = self:ReadExpectValue("in")

				data.iloop = false
				data.names = names
				data.expressions = self:ExpressionList()
				data["do"] = self:ReadExpectValue("do")
			end

			local body = self:Block({["end"] = true})
			data["end"] = self:ReadExpectValue("end", token, token)
			data.body = body

			table_insert(out, data)

			table.remove(self.loop_stack)
		elseif token.value == "function" then
			local data = {}
			data.type = "function"
			data["function"] = token
			data.arguments = {}
			data.is_local = false
			data.index_expression = self:IndexExpression(true, true)
			data["func("] = self:ReadExpectValue("(")
			data.arguments = self:NameList()
			data["func)"] = self:ReadExpectValue(")")
			data.body = self:Block({["end"] = true})
			data["end"] = self:ReadExpectValue("end", token, token)

			table_insert(out, data)
		elseif token.value == "(" then
			local pleft = token
			local expr = self:Expression()
			local pright = self:ReadExpectValue(")")
			if
				not self:IsValue(".") and
				not self:IsValue(":") and
				not self:IsValue("[") and
				not self:IsValue("(") and
				not self:IsValue("{")
			then
				self:Error("expected "..oh.QuoteTokens({".", ":", "(", "{"}).." got " .. self:GetToken().value)
			end
			self:Advance(1)
			self:Advance(-1)

			local right = self:IndexExpression(true)
			expr["("] = pleft
			expr[")"] = pright
			table_insert(right, 1, expr)
			table_insert(out, {type = "index_call_expression", value = right})
		elseif token.type == "letter" then
			self:Advance(-1) -- we want to include the current letter in the loop
			table_insert(out, self:Assignment())
		elseif token.value == ";" then
			table_insert(out, {type = "end_of_statement", value = token})
		else
			self:Advance(-1)
			self:Error("unexpected token " .. oh.QuoteToken(token.value))
		end
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