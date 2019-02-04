local lua, oh = ...
oh = oh or _G.oh
lua = lua or oh.lua

local table_insert = table.insert
local table_remove = table.remove

local META = {}
META.__index = META

function META:Node(t, val)
	local node = {}

	node.type = t
	node.tokens = {}

	if val then
		node.value = val
	end

	return node
end

function META:Error(msg, start, stop, level, offset)
	if not self.on_error then return end

	if type(start) == "table" then
		start = start.start
	end
	if type(stop) == "table" then
		stop = stop.stop
	end
	local tk = self:GetTokenOffset(offset or 0) or self.chunks[#self.chunks]
	start = start or tk.start
	stop = stop or tk.stop

	self:on_error(msg, start, stop)
end

function META:GetToken()
	return self.chunks[self.i] and self.chunks[self.i].type ~= "end_of_file" and self.chunks[self.i] or nil
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

do
	local function table_hasvalue(tbl, val)
		for k,v in ipairs(tbl) do
			if v == val then
				return k
			end
		end

		return false
	end

	function META:ReadExpectValues(values, start, stop)
		local tk = self:GetToken()
		if not tk then
			self:Error("expected " .. oh.QuoteTokens(values) .. ": reached end of code", start, stop)
		elseif not table_hasvalue(values, tk.value) then
			self:Error("expected " .. oh.QuoteTokens(values) .. " got " .. tk.value, start, stop)
		end
		self:Advance(1)
		return tk
	end
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

		local data = self:Node("value", token)
		table_insert(out, data)

		if not self:IsValue(",") then
			break
		end

		data.tokens[","] = self:ReadToken()
	end

	return out
end

function META:Table()
	local tree = self:Node("table")

	tree.children = {}
	tree.tokens["{"] = self:ReadExpectValue("{")

	for i = 1, self:GetLength() do
		local data

		if self:IsValue("}") then
			break
		elseif self:IsValue("[") then
			data = self:Node("table_expression_value")

			data.tokens["["] = self:ReadToken()
			data.key = self:Expression()
			data.tokens["]"] = self:ReadExpectValue("]")
			data.tokens["="] = self:ReadExpectValue("=")
			data.value = self:Expression()
			data.expression_key = true
		elseif self:IsType("letter") and self:GetTokenOffset(1).value == "=" then
			data = self:Node("table_key_value")

			data.key = self:Node("value", self:ReadToken())
			data.tokens["="] = self:ReadToken()
			data.value = self:Expression()
		else
			data = self:Node("table_index_value", self:Expression())
			data.key = i
			if not data.value then
				self:Error("expected expression got nothing")
			end
		end

		table_insert(tree.children, data)

		if self:IsValue("}") then
			break
		end

		if not self:IsValue(",") and not self:IsValue(";") then
			self:Error("expected ".. oh.QuoteTokens(",", ";", "}") .. " got " .. (self:GetToken().value or "no token"))
		end

		data.tokens[","] = self:ReadToken()
	end

	tree.tokens["}"] = self:ReadExpectValue("}")

	return tree
end

function META:Function(variant)
	local data = self:Node("function")
	data.tokens["function"] = self:ReadExpectValue("function")

	if variant == "simple_named" then
		data.value = self:Node("value", self:ReadExpectType("letter"))
	elseif variant == "expression_named" then
		data.value = self:Expression(0, true)
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

	if lua.syntax.IsUnaryOperator(token) then
		val = self:Node("unary")
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
		table_insert(val.tokens["left("], pleft)

		val.tokens["right)"] = val.tokens["right)"] or {}
		table_insert(val.tokens["right)"], self:ReadExpectValue(")"))

	elseif token.value == "function" then
		val = self:Function("anonymous")
	elseif lua.syntax.IsValue(token) or (token.type == "letter" and not lua.syntax.IsKeyword(token)) then
		val = self:Node("value", self:ReadToken())
	elseif token.value == "{" then
		val = self:Table()
	end

	token = self:GetToken()

	if token and (token.value == "." or token.value == ":" or token.value == "[" or token.value == "(" or token.value == "{" or token.type == "string") then
		local suffixes = {}

		for _ = 1, self:GetLength() do
			if not self:GetToken() then break end

			local data

			if self:IsValue(".") then
				data = self:Node("index")

				data.tokens["."] = self:ReadToken()
				data.value = self:Node("value", self:ReadExpectType("letter"))
			elseif self:IsValue(":") then
				data = self:Node("self_index")

				data.tokens[":"] = self:ReadToken()
				data.value = self:Node("value", self:ReadExpectType("letter"))
			elseif self:IsValue("[") then
				data = self:Node("index_expression")

				data.tokens["["] = self:ReadToken()
				data.value = self:Expression(0, stop_on_call)
				data.tokens["]"] = self:ReadExpectValue("]")
			elseif self:IsValue("(") then

				if stop_on_call then
					if suffixes[1] then
						val.suffixes = suffixes
					end
					return val
				end

				local start = self:GetToken()

				local pleft = self:ReadToken()
				data = self:Node("call")

				data.tokens["call("] = pleft
				data.arguments = self:ExpressionList()
				data.tokens["call)"] = self:ReadExpectValue(")", start)
			elseif self:IsValue("{") then
				data = self:Node("call")
				data.arguments = {self:Table()}
			elseif self:IsType"string" then
				data = self:Node("call")
				data.arguments = {self:Node("value", self:ReadToken())}
			else
				break
			end

			table_insert(suffixes, data)
		end

		if suffixes[1] then
			val.suffixes = suffixes
		end
	end

	if self:GetToken() then
		while self:GetToken() and lua.syntax.IsOperator(self:GetToken()) and lua.syntax.GetLeftOperatorPriority(self:GetToken()) > priority do

			local op = self:GetToken()
			local right_priority = lua.syntax.GetRightOperatorPriority(op)
			if not op or not right_priority then break end
			self:Advance(1)

			local right = self:Expression(right_priority, stop_on_call)
			local left = val

			val = self:Node("operator")
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

		if self:IsType("compiler_option") then
			data = self:Node("compiler_option")
			data.lua = self:ReadToken().value:sub(2)

			if data.lua:startswith("P:") then
				assert(loadstring("local self = ...;" .. data.lua:sub(3)))(self)
			end

		elseif self:IsValue("::") then
			data = self:Node("goto_label")

			data.tokens["::left"] = self:ReadToken()
			data.label = self:Node("value", self:ReadExpectType("letter"))
			data.tokens["::right"]  = self:ReadExpectValue("::")

		elseif self:IsValue("goto") then
			data = self:Node("goto")

			data.tokens["goto"] = self:ReadToken()
			data.label = self:Node("value", self:ReadExpectType("letter"))

		elseif self:IsValue("continue") then
			data = self:Node("continue")

			data.tokens["continue"] = self:ReadToken()

			out.has_continue = true

			if self.loop_stack[1] then
				self.loop_stack[#self.loop_stack].has_continue = true
			end

		elseif self:IsValue("repeat") then

			local token = self:GetToken()

			data = self:Node("repeat")
			data.tokens["repeat"] = self:ReadToken()

			table_insert(self.loop_stack, data)

			data.block = self:Block({["until"] = true})
			data.tokens["until"] = self:ReadExpectValue("until", token, token)
			data.condition = self:Expression()

			table_remove(self.loop_stack)
		elseif self:IsValue("local") then
			local local_token = self:ReadToken()

			if self:IsValue("function") then
				data = self:Function("simple_named")
				data.tokens["local"] = local_token
				data.is_local = true
			else
				data = self:Node("assignment")
				data.tokens["local"] = local_token
				data.is_local = true

				data.lvalues = self:NameList()

				data.tokens["="] = self:ReadIfValue("=")

				if data.tokens["="] then
					data.rvalues = self:ExpressionList()
				end
			end
		elseif self:IsValue("return") then
			data = self:Node("return")
			data.tokens["return"] = self:ReadToken()
			data.expressions = self:ExpressionList()
		elseif self:IsValue("break") then
			data = self:Node("break")

			data.tokens["break"] = self:ReadToken()
		elseif self:IsValue("do") then
			local token = self:GetToken()
			data = self:Node("do")

			data.tokens["do"] = self:ReadToken()
			data.block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", token, token)

			out.has_continue = data.block.has_continue
		elseif self:IsValue("if") then
			data = self:Node("if")

			data.clauses = {}

			local prev_token = self:GetToken()

			for _ = 1, self:GetLength() do

				if self:IsValue "end" then
					data.tokens["end"] = self:ReadToken()
					break
				end

				local clause = self:Node("clause")

				if self:IsValue("else") then
					clause.tokens["if/else/elseif"] = self:ReadToken()
					clause.block = self:Block({["end"] = true})
					clause.tokens["end"] = self:ReadExpectValue("end", prev_token, prev_token)
				else
					clause.tokens["if/else/elseif"] = self:ReadToken()
					clause.condition = self:Expression()
					clause.tokens["then"] = self:ReadExpectValue("then")
					clause.block = self:Block({["else"] = true, ["elseif"] = true, ["end"] = true})
					clause.tokens["end"] = self:ReadExpectValues({"else", "elseif", "end"}, prev_token, prev_token)
				end

				table_insert(data.clauses, clause)

				out.has_continue = data.clauses[#data.clauses].block.has_continue
				data.has_continue = out.has_continue

				prev_token = self:GetToken()

				self:Advance(-1) -- we want to read the else/elseif/end in the next iteration
			end
		elseif self:IsValue("while") then
			local token = self:GetToken()
			data = self:Node("while")

			data.tokens["while"] = self:ReadToken()
			data.expression = self:Expression()
			data.tokens["do"] = self:ReadExpectValue("do")

			table_insert(self.loop_stack, data)

			data.block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", token, token)
			table_remove(self.loop_stack)
		elseif self:IsValue("for") then
			local for_token = self:ReadToken()

			table_insert(self.loop_stack, data)

			local identifier = self:ReadExpectType("letter")

			if self:IsValue("=") then
				data = self:Node("for_i")
				data.identifier = self:Node("value", identifier)
				data.tokens["="] = self:ReadToken("=")
				data.expression = self:Expression()
				data.tokens[",1"] = self:ReadExpectValue(",")
				data.max = self:Expression()

				if self:IsValue(",") then
					data.tokens[",2"] = self:ReadToken()
					data.step = self:Expression()
				end

			else
				data = self:Node("for_kv")
				local name = self:Node("value", identifier)

				if self:IsValue(",") then
					name.tokens[","] = self:ReadToken()
					data.identifiers = self:NameList({name})
				else
					data.identifiers = {name}
				end

				data.tokens["in"] = self:ReadExpectValue("in")
				data.expressions = self:ExpressionList()
			end

			data.tokens["do"] = self:ReadExpectValue("do")
			data.tokens["for"] = for_token

			local block = self:Block({["end"] = true})
			data.tokens["end"] = self:ReadExpectValue("end", for_token, for_token)
			data.block = block

			table_remove(self.loop_stack)
		elseif self:IsValue("function") then
			data = self:Function("expression_named")
		elseif self:IsType("letter") or self:IsValue("(") then
			local start_token = self:GetToken()
			local expr = self:Expression()

			if self:IsValue("=") then
				data = self:Node("assignment")
				data.lvalues = {expr}
				data.tokens["="] = self:ReadToken()
				data.rvalues = self:ExpressionList()
			elseif self:IsValue(",") then
				data = self:Node("assignment")
				expr.tokens[","] = self:ReadToken()
				local list = self:ExpressionList()
				table_insert(list, 1, expr)
				data.lvalues = list
				data.tokens["="] = self:ReadExpectValue("=")
				data.rvalues = self:ExpressionList()
			elseif expr.suffixes and expr.suffixes[#expr.suffixes].type == "call" then
				data = self:Node("expression")
				data.value = expr
			else
				self:Error("unexpected " .. start_token.type, start_token)
			end
		elseif self:IsValue(";") then
			data = self:Node("end_of_statement")
			data.tokens[";"] = self:ReadToken()
		elseif self:IsType("end_of_file") then
			data = self:Node("end_of_file")
			data.tokens["end_of_file"] = self:ReadToken()
		elseif self:IsType("shebang") then
			data = self:Node("shebang")
			data.tokens["shebang"] = self:ReadToken()
		else
			self:Error("unexpected " .. self:GetToken().type)
		end

		table_insert(out, data)
	end

	return out
end


function META:BuildAST(tokens)
	self.chunks = tokens
	self.chunks_length = #tokens
	self.i = 1

	local ast = self:Block()

	-- HMMM
	if ast[#ast] and ast[#ast].type ~= "end_of_file" then
		local data = self:Node("end_of_file")
		data.tokens["end_of_file"] = tokens[#tokens]
		table.insert(ast, data)
	end

	return ast
end

return function(on_error)
	local self = setmetatable({}, META)

	self.on_error = on_error

	return self
end