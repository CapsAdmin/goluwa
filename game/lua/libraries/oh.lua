local oh = {}

do
	local syntax = {}

	do -- syntax rules
		syntax.quote = "\""
		syntax.literal_quote = "`"
		syntax.escape_character = "\\"
		syntax.comment = "--"

		do
			local char_types = {}

			do -- space
				char_types[""] = "space"
				char_types[" "] = "space"
				char_types["\n"] = "space"
				char_types["\r"] = "space"
				char_types["\t"] = "space"
			end

			do -- numbers
				for i = 0, 9 do
					char_types[tostring(i)] = "number"
				end
			end

			do -- letters
				char_types["_"] = "letter"

				for i = string.byte("A"), string.byte("z") do
					char_types[string.char(i)] = "letter"
				end
			end

			do -- symbols
				char_types["."] = "symbol"
				char_types[","] = "symbol"
				char_types["("] = "symbol"
				char_types[")"] = "symbol"
				char_types["{"] = "symbol"
				char_types["}"] = "symbol"
				char_types["["] = "symbol"
				char_types["]"] = "symbol"
				char_types["="] = "symbol"
				char_types[":"] = "symbol"
				char_types[";"] = "symbol"
				char_types["`"] = "symbol"
				char_types["'"] = "symbol"
				char_types["\""] = "symbol"
				char_types["~"] = "symbol" -- op
			end

			syntax.char_types = char_types
		end

		syntax.unary_operators = {
			["+"] = true,
			["-"] = true,
			["#"] = true,
			["not"] = true,
		}

		syntax.operators = {
			["^"] = -9,
			["%"] = 7,
			["/"] = 7,
			["*"] = 7,
			["+"] = 6,
			["-"] = 6,
			[".."] = 5,
			["<="] = 3,
			["=="] = 3,
			["~="] = 3,
			["<"] = 3,
			[">"] = 3,
			[">="] = 3,
			["and"] = 2,
			["or"] = 1,
			[">>"] = -1,
			["#"] = -1,
			["not"] = -1,
			["<<"] = -1,
			["!="] = -1,
			["&"] = -1,
			["|"] = -1,
		}

		for i,v in pairs(syntax.operators) do
			if v < 0 then
				syntax.operators[i] = {-v + 1, -v}
			else
				syntax.operators[i] = {v, v}
			end
		end

		syntax.keywords = {
			"and", "break", "do", "else", "elseif", "end",
			"false", "for", "function", "if", "in", "local",
			"nil", "not", "or", "repeat", "return", "then",
			"true", "until", "while", "goto",
		}
		for k,v in pairs(syntax.keywords) do
			syntax.keywords[v] = v
		end

		syntax.keyword_values = {
			"nil",
			"true",
			"false",
		}
		for k,v in pairs(syntax.keyword_values) do
			syntax.keyword_values[v] = v
		end

		do
			local symbols = {"..."}
			local done = {}
			for k,v in pairs(syntax.char_types) do
				if v == "symbol" and not done[k] then
					table.insert(symbols, k)
					done[k] = true
				end
			end
			for k,v in pairs(syntax.operators) do
				if not done[k] then
					table.insert(symbols, k)
					done[k] = true
				end
			end
			table.sort(symbols, function(a, b) return #a > #b end)
			syntax.symbols = symbols

			local longest_symbol = 0
			local lookup = {}
			for k,v in ipairs(symbols) do
				lookup[v] = true
				longest_symbol = math.max(longest_symbol, #v)
				if #v == 1 then
					syntax.char_types[v] = "symbol"
				end
			end
			syntax.longest_symbol = longest_symbol
			syntax.symbols_lookup = lookup
		end
	end

	oh.syntax = syntax
end

local META = {}
META.__index = META

local token_meta = {__tostring = function(s)
	return "token['" .. s.value .. "'][" .. s.i .. "]"
end}

function META:GetToken(offset)
	local i = self.i + (offset or 0)
	local info = self.chunks[i]
	if not info then return end
	info.value = info.value or self.code:sub(info.start, info.stop)
	info.i = i
	setmetatable(info, token_meta)
	return info
end

function META:ReadToken()
	local tk = self:GetToken()
	self:NextToken()
	return tk
end

function META:CheckTokenValue(tk, value, level)
	if tk.value ~= value then
		self:Error("expected " .. value .. " got " .. tk.value, nil,nil,level or 3)
	end
end

function META:CheckTokenType(tk, type)
	if tk.type ~= type then
		self:Error("expected " .. type .. " got " .. tk.type, nil,nil,level or 3)
	end
end

function META:ReadExpectType(type)
	local tk = self:GetToken()
	self:CheckTokenType(tk, type, 4)
	self:NextToken()
	return tk
end

function META:ReadExpectValue(value)
	local tk = self:GetToken()
	self:CheckTokenValue(tk, value, 4)
	self:NextToken()
	return tk
end

function META:GetLength()
	return #self.chunks
end

function META:NextToken()
	self.i = self.i + 1
end

function META:Back()
	self.i = self.i - 1
end

function META:ReadAssignment()
	local data = {}

	data.type = "assignment"
	data.indices = {}

	while true do
		local info = self:GetToken()
		self:NextToken()

		if info.value == "=" then
			break
		end

		if info.value ~= "," then
			if info.type ~= "letter" then
				self:Error("unexpected symbol " .. info.value, info.start, info.stop)
				break
			end

			table.insert(data.indices, {{type = "index", value = info}})
		end
	end

	data.expressions = self:ReadExpressions()

	return data
end

function META:ReadArgumentDefintion()
	local out = {}
	self:ReadExpectValue("(")

	if self:GetToken().value == ")" then
		return out
	end

	while true do
		local token = self:ReadExpectType("letter")

		table.insert(out, token)

		if self:GetToken().value == ")" then
			return out
		end

		self:ReadExpectValue(",")
	end
	return out
end

function META:ReadVariableLookup(stop, in_expression)
	local out = {}

	for _ = 1, self:GetLength() do
		local info = self:GetToken()

		if not info then return out end

		if stop and stop[info.value] or oh.syntax.keywords[info.value] then
			return out
		end

		if info.type == "letter" then
			if out[1] and self:GetToken(-1).type == "letter" then
				return out
			end

			table.insert(out, {type = "index", value = info})

		elseif info.value == "[" then
			self:NextToken()
			table.insert(out, {type = "expression", value = self:ReadExpression()})
			self:CheckTokenValue(self:GetToken(), "]")
		elseif info.value ~= "." then
			return out
		end

		self:NextToken()
	end

	return out
end

function META:ReadExpressions()
	local tbl = {}

	while true do
		local val = self:ReadExpression()
		local nxt = self:GetToken()

		table.insert(tbl, val)

		if not nxt or nxt.value ~= "," then
			break
		end

		self:NextToken()
	end

	return tbl
end

function META:ReadBody(stop)
	if type(stop) == "string" then
		stop = {[stop] = true}
	end

	local tree = {}

	for _ = 1, self:GetLength() do
		local token = self:ReadToken()

		if not token then break end

		if stop and stop[token.value] then
			return tree
		end

		if token.value == "local" then
			if self:GetToken().value == "function" then
				self:NextToken()
				local data = {}
				data.type = "function"
				data.name = self:ReadExpectType("letter").value
				data.is_local = true
				data.arguments = self:ReadArgumentDefintion()
				data.body = self:ReadBody("end")
				table.insert(tree, data)
			else
				local data = self:ReadAssignment()
				data.is_local = true
				table.insert(tree, data)
			end
		elseif token.value == "return" then
			local data = {}
			data.type = "return"
			data.expression = self:ReadExpression()
			table.insert(tree, data)
		elseif token.value == "do" then
			local data = {}
			data.type = "do"
			data.body = self:ReadBody("end")
			table.insert(tree, data)
		elseif token.value == "if" then
			local data = {}
			data.type = "if"
			data.statements = {}
			self:Back() -- we want to read the if in the upcoming loop

			for _ = 1, self:GetLength() do
				local token = self:ReadToken()

				if token.value == "end" then
					break
				end

				if token.value == "else" then
					table.insert(data.statements, {
						body = self:ReadBody("end"),
						token = token,
					})
				else
					local expr = self:ReadExpression()

					self:ReadExpectValue("then")
					table.insert(data.statements, {
						expr = expr,
						body = self:ReadBody({["else"] = true, ["elseif"] = true, ["end"] = true}, true),
						token = token,
					})
				end

				self:Back() -- we want to read the else/elseif/end in the next iteration
			end
			table.insert(tree, data)
		elseif token.value == "while" then
			local data = {}
			data.type = "while"
			data.expr = self:ReadExpression()
			self:ReadExpectValue("do")
			data.body = self:ReadBody("end")
			table.insert(tree, data)
		elseif token.value == "for" then
			local data = {}
			data.type = "for"

			if self:GetToken(1).value == "=" then
				data.iloop = true
				data.name = self:ReadExpectType("letter").value
				self:ReadExpectValue("=")
				data.val = self:ReadExpression()
				self:ReadExpectValue(",")
				data.max = self:ReadExpression()
				self:ReadExpectValue("do")
				data.body = self:ReadBody("end")
				table.insert(tree, data)
			else
				data.iloop = false
				local names = {}

				while true do
					local token = self:ReadToken()

					if not token or token.value == "in" then
						break
					end

					if token.value ~= "," then
						table.insert(names, token)
					end
				end

				data.names = names
				data.expression = self:ReadExpression()
				self:ReadExpectValue("do")
				data.body = self:ReadBody("end")

				table.insert(tree, data)
			end
		elseif token.value == "function" then
			local indices = {}
			local data = {}
			data.type = "function2"
			data.arguments = {}
			data.indices = indices
			data.is_local = false

			for i = 1, 10 do
				local info = self:GetToken()

				if not info or info.value == "(" then break end

				if info.type == "letter" then
					table.insert(indices, {type = "index", value = info})
				end

				if info.value == "[" then
					self:NextToken()
					table.insert(indices, {type = "expression", value = self:ReadExpression()})
					self.i = self.i - 2
				end

				if info.value == ":" then
					data.self_call = true
				end

				self:NextToken()
			end

			self:NextToken()

			while true do
				local token = self:ReadToken()

				if not token or token.value == ")" then
					break
				end

				if token.value ~= "," then
					table.insert(data.arguments, token)
				end
			end

			data.body = self:ReadBody("end")

			table.insert(tree, data)
		elseif token.type == "letter" then
			self:Back() -- we want to include the current letter in the loop

			local names = {}

			for _ = 1, self:GetLength() do
				table.insert(names, self:ReadVariableLookup({[","] = true, ["="] = true, ["("] = true, [":"] = true}))

				local token = self:ReadToken()

				if token then
					if token.value == "=" then

						local data = {}
						data.type = "assignment"
						data.is_local = false
						data.indices = names
						data.expressions = self:ReadExpressions()
						table.insert(tree, data)

						break
					elseif token.value == "(" or token.value == ":" then
						local data = {}
						data.type = "call"

						if token.value == ":" then
							data.self_call = true
							table.insert(names[#names], {type = "index", value = self:ReadExpectType("letter")})
							self:ReadExpectValue("(")
						end

						data.indices = names
						data.calls = {}

						self:Back() -- step back to (

						while self:GetToken() and self:ReadToken().value == "(" do
							table.insert(data.calls, self:ReadExpressions())
							self:ReadExpectValue(")")
						end

						self:Back()

						table.insert(tree, data)
						break
					end
				end
			end
		end
	end

	return tree
end

function META:ReadTable()
	local tree = {}
	tree.type = "table"
	tree.children = {}

	self:ReadExpectValue("{")

	while true do
		local token = self:GetToken()
		if not token then return tree end

		if token.value == "}" then
			self:NextToken()
			return tree
		elseif self:GetToken(1) and self:GetToken(1).value == "=" then
			local index = self:GetToken()
			self:NextToken()
			self:NextToken()

			local data = {}
			data.type = "assignment"
			data.expressions = {self:ReadExpression()}
			data.indices = {index}

			table.insert(tree.children, data)
		elseif token.value == "[" then
			self:NextToken()
			local val = self:ReadExpression()
			self:ReadExpectValue("]")
			self:ReadExpectValue("=")

			local data = {}
			data.type = "assignment"
			data.expressions = {self:ReadExpression()}
			data.indices = {val}
			data.expression_key = true
			table.insert(tree.children, data)
		else
			local data = {}
			data.type = "value"
			data.value =  self:ReadExpression()
			table.insert(tree.children, data)
		end

		if self:GetToken().value == "}" then
			self:Back()
		else
			self:CheckTokenValue(self:GetToken(), ",")
		end

		self:NextToken()
	end

	return tree
end

local test = {}
test["("] = true
test[")"] = true
test[":"] = true
for k,v in pairs(oh.syntax.operators) do
	test[k] = true
end

function META:ReadExpression(priority)
	priority = priority or 0

	local val

	local token = self:GetToken()

	if not token then return end

	if oh.syntax.unary_operators[token.value] then
		local op = self:ReadToken()
		val = {type = "unary", value = op.value, argument = self:ReadExpression(0)}
	elseif token.value == "(" then
		self:NextToken()
		val = self:ReadExpression(0)
		self:ReadExpectValue(")")
	elseif token.type == "number" or token.type == "string" or oh.syntax.keyword_values[token.value] then
		val = self:ReadToken()
	elseif token.value == "{" then
		val = self:ReadTable()
	elseif token.value == "function" then
		self:NextToken()

		local arguments = {}

		self:ReadExpectValue("(")

		while true do
			local token = self:ReadToken()

			if not token or token.value == ")" then
				break
			end

			if token.type == "letter" then
				table.insert(arguments, token)
			elseif token.value ~= "," then
				break
			end
		end
		val = {type = "function", arguments = arguments, body = self:ReadBody("end")}

	elseif token.type == "letter" and not oh.syntax.keywords[token.value] then
		val = {}

		for _ = 1, self:GetLength() do
			local info = self:GetToken()

			if not info then break end

			if test[info.value] then
				break
			end

			if info.type == "letter" then
				if
					val[1] and self:GetToken(-1).type == "letter" or
					(oh.syntax.keywords[info.value] and not oh.syntax.operators[info.value])
				then
					break
				end

				table.insert(val, {type = "index", value = info})
			elseif info.value == "[" then
				self:NextToken()
				table.insert(val, {type = "expression", value = self:ReadExpression()})
				self:CheckTokenValue(self:GetToken(), "]")
			elseif info.value ~= "." then
				break
			end

			self:NextToken()
		end

		local token = self:GetToken()

		if token and (token.value == "(" or token.value == ":") then
			self:NextToken()

			local data = {}
			data.type = "call"
			data.indices = val

			if token.value == ":" then
				data.self_call = true
				table.insert(val[#val], {type = "index", value = self:ReadExpectType("letter")})
				self:ReadExpectValue("(")
			end

			data.calls = {}

			self:Back() -- step back to (

			while self:GetToken() and self:ReadToken().value == "(" do
				table.insert(data.calls, self:ReadExpressions())
				self:ReadExpectValue(")")
			end

			self:Back()

			if self:GetToken().value == "." then
				self:Error("index after call is not yet supported")
			end

			val = data
		else
			val = {type = "variable", indices = val}
		end
	else
		return val
	end

	local token = self:GetToken()

	if not token then return val end

	while oh.syntax.operators[token.value] and oh.syntax.operators[token.value][1] > priority do
		local op = self:GetToken()
		if not op or not oh.syntax.operators[op.value] then return val end
		self:NextToken()
		val = {type = "operator", value = op.value, left = val, right = self:ReadExpression(oh.syntax.operators[op.value][2])}
	end

	return val
end

function META:Error(msg, start, stop, level)
	start = start or self:GetToken().start
	stop = stop or self:GetToken().stop
	offset = offset or 0

	local context_start = self.code:sub(math.max(start - 50, 2), start - 1)
	local context_stop = self.code:sub(stop, stop + 50)

	context_start = context_start:gsub("\t", " ")
	context_stop = context_stop:gsub("\t", " ")

	local content_before = #(context_start:reverse():match("(.-)\n") or context_start)
	local content_after = (context_stop:match("(.-)\n") or "")

	local len = math.abs(stop - start)
	local str = (len > 0 and self.code:sub(start, stop - 1) or "") .. content_after .. "\n"

	str = str .. (" "):rep(content_before) .. ("_"):rep(len) .. "^" .. ("_"):rep(#content_after - 1) .. " " .. msg .. "\n"



	str = "\n" .. context_start .. str .. context_stop:sub(#content_after + 1)

	error(str, level or 2)
end

function META:Dump()
	local start = 0
	for _,v in ipairs(self.chunks) do
		log(
			self.code:sub(start+1, v.start-1),
			"⸢", self.code:sub(v.start, v.stop), "⸥"
		)
		start = v.stop
	end
	log("⸢", self.code:sub(start+1), "⸥")
end

do
	local META = {}
	META.__index = META

	function META:Value2(v)
		local _ = self
		if v.type == "function" then
			self.suppress_indention = true
			_"(function("_:arguments(v.arguments)_")" self:Body(v.body, true) _"end)"
			self.suppress_indention = false
		elseif v.type == "table" then
			_"{\n"
				_"\t+"
				for i,v in ipairs(v.children) do
					_"\t"
					if v.type == "value" then
						_:Value(v.value)
					elseif v.type == "assignment" then
						if v.expression_key then
							_"["_:Value(v.indices[1])_"]" _" = " _:Value(v.expressions[1])
						else
							_:Value(v.indices[1]) _" = " _:Value(v.expressions[1])
						end
					end
					_",\n"
				end
				_"\t-"
			_"\t"_"}"
		elseif v.type == "variable" then
			for i,v in ipairs(v.indices) do
				if i == 1 then
					_(v.value.value)
				elseif v.type == "expression" then
					_"["_:Value(v.value)_"]"
				else
					_"."_(v.value.value)
				end
			end
		elseif v.type == "call" then
			for i,v2 in ipairs(v.indices) do
				if i == 1 then
					_(v2.value.value)
				elseif v2.type == "expression" then
					_"["_:Value(v2.value)_"]"
				else
					if v.self_call and i == #v.indices then
						_":"_(v2.value.value)
					else
						_"."_(v2.value.value)
					end
				end
			end
			for _i, v2 in ipairs(v.calls) do
				_"("_:arguments(v2)_")"
			end
		elseif v.type == "unary" then
			if oh.syntax.keywords[v.value] then
				_(v.value)_" "_:Expression(v.argument)
			else
				_(v.value)_:Expression(v.argument)
			end
		else
			if oh.syntax.keywords[v.value] then
				_" "_(v.value)_" "
			else
				_(v.value)
			end
		end
	end

	function META:Value(v)
		local _ = self
		if v.type == "operator" then
			self:Expression(v)
		elseif v.type == "unary" then
			_(v.value)_:Expression(v.argument)
		else
			self:Value2(v)
		end
	end

	function META:Expression(v)
		local _ = self

		if v.left then _"(" _:Expression(v.left) end _:Value2(v) if v.right then _:Expression(v.right) _")" end
	end

	function META:Body(tree)
		local _ = self
		for __, data in ipairs(tree) do
			if data.type == "if" then
				for i,v in ipairs(data.statements) do
					_"\t"_(v.token.value)_" " if v.expr then _:Expression(v.expr) _" then" end _"\n"
						_"\t+"
							self:Body(v.body)
						_"\t-"
				end
				_"\t" _"end"
			elseif data.type == "while" then
				_"\t"_"while "_:Expression(data.expr)_" do"_"\n"
					_"\t+"
						self:Body(data.body)
					_"\t-"
				_"\t"_"end"
			elseif data.type == "return" then
				if data.expression then
					_"\t"_"return "_:Expression(data.expression)
				else
					_"\t"_"return "
				end
			elseif data.type == "for" then
				if data.iloop then
					_"\t"_"for "_(data.name)_" = "_:Expression(data.val)_", "_:Expression(data.max)_" do"_"\n"
						_"\t+"
							_:Body(data.body)
						_"\t-"
					_"\t"_"end"
				else
					_"\t"_"for "_:arguments(data.names)_" in "_:Expression(data.expression)_" do"_"\n"
						_"\t+"
							_:Body(data.body)
						_"\t-"
					_"\t"_"end"
				end
			elseif data.type == "do" then
				_"\t"_"do\n"
					_"\t+"
						_:Body(data.body)
					_"\t-"
				_"\t"_"end"
			elseif data.type == "function2" then
				_"\t"_"function"_" "
					for i,v in ipairs(data.indices) do
						if i == 1 then
							_(v.value.value)
						elseif v.type == "expression" then
							_"["_:Value(v.value)_"]"
						elseif data.self_call and i == #data.indices then
							_":"_(v.value.value)
						else
							_"."_(v.value.value)
						end
					end
				_"("_:arguments(data.arguments)_")"_"\n"
					_"\t+"
						self:Body(data.body)
					_"\t-"
				_"\t"_"end"
			elseif data.type == "function" then
				_"\t"_("local ", not not data.is_local)_"function"_" "_(data.name)_"("_:arguments(data.arguments)_")"_"\n"
					_"\t+"
						self:Body(data.body)
					_"\t-"
				_"\t"_"end"
			elseif data.type == "assignment" then
				_"\t"_("local ", not not data.is_local)

				for i2,v2 in ipairs(data.indices) do
					for i,v in ipairs(v2) do
						if i == 1 then
							_(v.value.value)
						elseif v.type == "expression" then
							_"["_:Value(v.value)_"]"
						else
							_"."_(v.value.value)
						end
					end
					if i2 ~= #data.indices then
						_", "
					end
				end

				_" = "_:arguments(data.expressions)
			elseif data.type == "call" then
				_"\t"

				for i2,v2 in ipairs(data.indices) do
					for i,v in ipairs(v2) do
						if i == 1 then
							_(v.value.value)
						elseif v.type == "expression" then
							_"["_:Value(v.value)_"]"
						else
							if data.self_call and i == #v2 then
								_":"_(v.value.value)
							else
								_"."_(v.value.value)
							end
						end
					end
				end

				for _i, v2 in ipairs(data.calls) do
					_"("_:arguments(v2)_")"
				end
			end

			_"\n"
		end
	end

	META.__call = function(self, str, b)
		if b == false then return end

		if self.suppress_indention and (str == "\n" or str == "\t") then
			self:emit(" ")
			return
		end

		if str == "\t" then
			self:emitindent()
		elseif str == "\t+" then
			self:indent()
		elseif str == "\t-" then
			self:outdent()
		else
			self:emit(str)
		end
	end

	function META:arguments(tbl)
		for i,v2 in ipairs(tbl) do
			self:Value(v2)
			if i ~= #tbl then
				self:emit(", ")
			end
		end
	end

	function META:emit(str)
		assert(type(str) == "string")
		self.out[self.i] = str
		self.i = self.i + 1
		log(str)
	end

	function META:indent()
		self.level = self.level + 1
	end

	function META:outdent()
		self.level = self.level - 1
	end

	function META:emitindent()
		self:emit(string.rep("\t", self.level))
	end

	function oh.DumpAST(tree)
		local self = {}

		self.level = 0
		self.out = {}
		self.i = 1

		setmetatable(self, META)

		self:Body(tree)

		return table.concat(self.out)
	end
end

do -- tokenizer
	local function string_escape(self, i)
		if self.string_escape then
			self.string_escape = false
			return true
		end

		if self.code:sub(i, i) == oh.syntax.escape_character then
			self.string_escape = true
		end
	end

	local function add_token(self, type, start, stop)
		self.chunks[self.chunks_i] = {
			type = type,
			--value = self.code:sub(start, stop),
			start = start,
			stop = stop,
		}
		self.chunks_i = self.chunks_i + 1
	end

	local function capture_literal_string(self, i)
		local length = 0

		for offset = 0, 32 do
			if self.code:sub(i + offset, i + offset) ~= oh.syntax.literal_quote then
				length = offset
				break
			end
		end

		local stop

		local count = 0
		for i = i + length, #self.code do
			local c = self.code:sub(i, i)

			if not string_escape(self, i) then
				if c == oh.syntax.literal_quote then
					count = count + 1
				else
					count = 0
				end

				if count == length then
					stop = i
					break
				end
			end
		end

		return stop
	end

	local function is_literal_lua_string(self, i)
		return
			self.code:sub(i, i) == "[" and
			(
				self.code:sub(i+1, i+1) == "[" or
				self.code:sub(i+1, i+1) == "="
			)
	end

	local function capture_literal_lua_string(self, i)
		local stop
		local length = 0

		local start = i

		for i = start, #self.code do
			local c = self.code:sub(i, i)
			if
				(c == "[" and i == start) or
				(c == "=" and length > 0)
			then
				length = length + 1
			elseif length > 0 and c == "[" then
				length = length + 1
				break
			end
		end

		if length < 2 then return nil end

		for i = i + length, #self.code do
			local c = self.code:sub(i, i)

			if c == "]" then
				local length = length
				for i2 = i, i + length do
					local c = self.code:sub(i2, i2)
					if c == "]" or c == "=" then
						length = length - 1
					elseif length == 0 then
						stop = i2 - 1
						break
					end
				end
				if stop then break end
			end
		end

		if not stop then
			return nil, "strange string"
		end

		return stop
	end

	function META:Tokenize()
		local i = 1
		for _ = 1, self.code_length + 1 do
			local char = self.code:sub(i, i)
			local t = oh.syntax.char_types[char]

			if i == 1 and char == "#" then
				local stop = self.code_length
				for i = 1, self.code_length do
					local c = self.code:sub(i, i)

					if c == "\n" then
						stop = i+1
						break
					end
				end

				add_token(self, "shebang", i, stop)

				i = stop
			end

			if not t then
				self:Error("unknown symbol >>" .. char .. "<< (" .. char:byte() .. ")", i, i)
			end

			self.char = char
			self.char_type = t

			if self.code:sub(i, i + #oh.syntax.comment - 1) == oh.syntax.comment then
				i = i + #oh.syntax.comment

				if self.code:sub(i, i) == oh.syntax.literal_quote or is_literal_lua_string(self, i) then
					local stop

					if self.code:sub(i, i) == oh.syntax.literal_quote then
						stop = capture_literal_string(self, i)
					else
						stop = capture_literal_lua_string(self, i)
					end

					if not stop then
						self:Error("cannot find the end of multiline comment", i, i)
					end

					add_token(self, "comment", i - #oh.syntax.comment, stop)

					i = stop
				else
					local stop

					for i = i + 1, self.code_length do
						local c = self.code:sub(i, i)

						if c == "\n" or i == self.code_length then
							stop = i - 1
							break
						end
					end

					add_token(self, "comment", i - #oh.syntax.comment, stop)

					i = stop
				end
			elseif char == oh.syntax.quote then
				local stop

				for i = i + 1, self.code_length do
					local c = self.code:sub(i, i)

					if not string_escape(self, i) then
						if c == oh.syntax.quote then
							stop = i
							break
						end
					end
				end

				if not stop then
					self:Error("cannot find the end of double quote", i, i)
				end

				add_token(self, "string", i, stop)

				i = stop
			elseif self.code:sub(i, i) == oh.syntax.literal_quote or is_literal_lua_string(self, i) then
				local stop

				if self.code:sub(i, i) == oh.syntax.literal_quote then
					stop = capture_literal_string(self, i)

					if not stop then
						self:Error("cannot find the end of literal quote", i, i)
					end
				else
					local stop_, err = capture_literal_lua_string(self, i)
					if not stop_ and err then
						self:Error("cannot find the end of literal quote: " .. err, i, i)
					end
					stop = stop_
				end

				if stop then
					add_token(self, "string", i, stop)

					i = stop
				end
			elseif char == "'" then
				local stop

				for i = i + 1, self.code_length do
					local c = self.code:sub(i, i)

					if not string_escape(self, i) then
						if c == "'" then
							stop = i
							break
						end
					end
				end

				if not stop then
					self:Error("cannot find the end of single quote", i, i)
				end

				add_token(self, "string", i, stop)

				i = stop
			elseif t == "number" and self.last_type ~= "letter" then
				if self.code:sub(i + 1, i + 1):lower() == "x" then
					local stop

					local pow = false
					for offset = i + 2, i + 64 do
						local char = self.code:sub(offset, offset):lower()
						local t = oh.syntax.char_types[char]

						if (char:lower() == "u" or char:lower() == "l") and self.code:sub(offset+1, offset+1):lower() == "l" then
							if self.code:sub(offset+2, offset+2):lower() == "l" then
								stop = offset + 2
							else
								stop = offset + 1
							end

							local char = self.code:sub(stop+1, stop+1)
							local t = oh.syntax.char_types[char]

							if t == "space" or t == "symbol" then
								break
							end
						end

						if char == "p" then
							if not pow then
								pow = true
							else
								self:Error("malformed number: pow character can only be used once")
							end
						end

						if
							not (
								t == "number" or
								char == "a" or
								char == "b" or
								char == "c" or
								char == "d" or
								char == "e" or
								char == "f" or
								char == "p" or
								char == "_"
							)
						then
							if not t or t == "space" or t == "symbol" then
								stop = offset - 1
								break
							elseif char == "symbol" or t == "letter" then
								self:Error("malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation", i, offset)
							end
						end


					end

					add_token(self, "number", i, stop)

					i = stop
				elseif self.code:sub(i + 1, i + 1):lower() == "b" then
					local stop

					for offset = i + 2, i + 64 do
						local char = self.code:sub(offset, offset):lower()
						local t = oh.syntax.char_types[char]

						if char ~= "1" and char ~= "0" and char ~= "_" then
							if not t or t == "space" or t == "symbol" then
								stop = offset - 1
								break
							elseif char == "symbol" or t == "letter" or (char ~= "0" and char ~= "1") then
								self:Error("malformed number: only 01_ allowed after binary notation", i, offset)
							end
						end
					end

					add_token(self, "number", i, stop)

					i = stop
				else
					local stop

					local found_dot = false
					local exponent = false

					for offset = i, self.code_length+1 do
						local char = self.code:sub(offset, offset)
						local t = oh.syntax.char_types[char]

						if exponent then
							if char ~= "-" and char ~= "+" and t ~= "number" then
								self:Error("malformed number: invalid character '" .. char .. "'. only +-0123456789 allowed after exponent", i, offset)
							elseif char ~= "-" and char ~= "+" then
								exponent = false
							end
						elseif t ~= "number" then
							if t == "letter" then
								if char:lower() == "e" then
									exponent = true
								elseif char == "_" or (char:lower() == "u" or char:lower() == "l") and self.code:sub(offset+1, offset+1):lower() == "l" then
									if self.code:sub(offset+2, offset+2):lower() == "l" then
										stop = offset + 2
									else
										stop = offset + 1
									end

									local char = self.code:sub(stop+1, stop+1)
									local t = oh.syntax.char_types[char]

									if t == "space" or t == "symbol" then
										break
									end
								else
									self:Error("malformed number: invalid character '" .. char .. "'. only ule allowed after a number", i, offset)
								end
							elseif t == "space" or t == "symbol" then
								stop = offset - 1
								break
							elseif not found_dot and char == "." then
								found_dot = true
							else
								self:Error("malformed number: invalid character '" .. char .. "'. this should never happen?", i, offset)
							end
						end


					end

					add_token(self, "number", i, stop)

					if not stop then
						self:Error("malformed number: expected number after exponent", i, i)
					end

					i = stop
				end
			elseif t == "letter" then
				local stop

				local last_type

				for offset = i, i + 256 do
					local char = self.code:sub(offset, offset)
					local t = oh.syntax.char_types[char]

					if t ~= "letter" and (t ~= "number" and last_type == "letter") then
						stop = offset - 1
						break
					else
						t = "letter"
					end

					last_type = t
				end

				if not stop then
					self:Error("malformed letter: could not find end", i, i)
				end

				add_token(self, "letter", i, stop)

				i = stop
			elseif t == "symbol" then
				for i2 = oh.syntax.longest_symbol - 1, 0, -1 do
					if oh.syntax.symbols_lookup[self.code:sub(i, i+i2)] then
						add_token(self, "symbol", i, i+i2)
						i = i + i2
						break
					end
				end
			end

			self.last_type = t

			i = i + 1
		end
	end
end

function oh.Tokenize(code)
	local self = {}

	setmetatable(self, META)

	self.code = code
	self.code_length = #code

	self.chunks = {}
	self.chunks_i = 1
	self.i = 1

	self:Tokenize()

	return self
end

function oh.TestLuajitLangToolkit(code)
	local ls = require("lang.lexer")(require("lang.reader").string(code), code)
	local parse = require('lang.parser')
	local lua_ast = require('lang.lua-ast')
	local ast_builder = lua_ast.New()
	local parse_success, ast_tree = pcall(parse, ast_builder, ls)

	for _, data in ipairs(ast_tree.body) do
		log("local ")
		for i, v in ipairs(data.names) do
			log(v.name)
			if i ~= #data.names then
				log(", ")
			end
		end
		log(" = ")
		for i, v in ipairs(data.expressions) do
			if v.kind == "BinaryExpression" then
				local function dump(v)
					local lol = false
					if v.left then
						log("(")
						dump(v.left)
					end
					if lol then
						log(",")
					else
						log(v.value or v.operator or v.name)
					end
					if v.right then
						dump(v.right)
						log(")")
					end
				end
				dump(v)
			else
				log(v.value)
			end

			if i ~= #data.expressions then
				log(", ")
			end
		end
		logn()
	end
end


commands.Add("tokenize=arg_line", function(str)
	oh.DumpTokens(oh.Tokenize(str))
end)

if RELOAD then
	local code = [==[

	]==] code = [==[

	local a = a+i < b/2+1
	local b = 5+x^2*8
	local a = (1+2)+(3+4)

	local a = a+i < b/2+1
	local b = 5+x^2*8
	local a =a < y and y <= z
	local a =-x^2
	local a =x^y^z
	local a = 5+x^2*8
	local a = x < y and x*x or y*y
	local a = 1+2+3+4
	local a = (1+2)+(3+4)
	local a = (1+(2)+(3)+4)
	local a = (1+(2+3)+4)
	local a,b,c = 1,3+2^3,(3+2)^3
	local a = 5+(1+2+3+4)

	local b = function(a,b,c) local awd = awd*5 end

	local function test()
		local a = b
		lol = true
		adwawd = ad
		a,b,c=e,f,g
	end

	do
		local a = 1
		do
			local a = 2

			local function asdf()
				for i = 1, 10 do
					local i = i + 2
					if i < 5 then
						local a = 1
					elseif i > 5 then
						local a = 2
					elseif i > 1 then
						local a = 2
					else
						local a = 4
					end
				end


				local i = 0

				while (function(foo) local foo = foo + bar return foo end) or 1 do
					i = i + 1
					if i > 10 then

					end
				end
			end
		end
	end

		foo.bar[1+2]["3"][four].five = 1
		a = 1
		b = 2
		foo.bar[1+2]["3"][four].waddwa(a,b,c + 2 + 1 + 22+2 +2)


		a.lol,b,c = 1,2,3
		lol:foo(awdadwwad, awdwadaw, adadw, 2+11+231+23+1+23)

		while true do
			local a = 1
			if true then a = 1 elseif true then b= 2 elseif true and false then c = 3 end
			local a = 2
			asad(adawd+123,21235,325,235,253)
		end
		if true then
			a = 1
		elseif true then
			b= 2
		elseif true and false then
			c = 3
		end


		a = 0b101010

		b = {1,2,3, foo = true, [asd] = true, lol = {1,2,3}}
		b.a = 1
		b.test = function() end

		function b:test()

		end


	b.test = {1}

	function b:test()
	end

	b["asdawd"].wad = function(a,b,c)
	end


		b.A = {function() end,1,2,true,false,2+4+5}
		function b:B()
		end
		b.C = function() end
		function b:D()
		end
		b["E"].F= function(a,b,c) a = 1
		end

		local a = {a}
		b = 1

	local function test(a)
		return 1+2+a*b+d/c
	end

	if 1+2 > 3 then
		a = 4
	elseif false and 32 then
		a = 23
	elseif true and asd then
		a = 7
	else
		a = 10
	end

	if 1+5 then
		asdawd = true
	else
		asdawd = true
	end

	if 1203 then
		asdawd = true
	end

	while true do

	end

	for _ = 1, 10 do
		print(i  + 4)
	end

		foo.bar[1+2]["3"][four].five = 1
		foo.bar[1+2]["3"][four].waddwa:waawd(a,b,c + 2 + 1 + 22+2 +2)
		a.b,c.d,e,f = lol(), asdf(), asas(),1
		a,b,c,d = 1,2,3,4

		foo.bar[1+2]["3"][four].waddwa:waawd(a + function() end, b, c + 2 + 1 + 22+2 +2)

		local a = function(a,b,c) end + 1 + aawd.awdawd(1,2,3) * 1 ^ -2

		local a = 2+1<1/aawd.aw:dw(1,2,3)+1
		local b = 2+1<1/2+1

		local a =a < y and y <= z

		local a =a < y and y <= z
		local a =-x^2

		local a,b,c = 1,2,3
		local a = a+1*2*2,2
		local function test()
			local a = b
			lol = true
			return a+1
		end
		local a = 1
		local b = function() end + 1
		function lol()

		end

		local a = b
		c,d = d
		local a, b = 1, 2, function() end + 1
		local function asdf()
			a, b = 2, 3
			local lol = 2
			for i = 1, 10 do

			end
		end

		local foo = A < B or C > D
		b = a
		b = true

		foo.bar[1+2]["3"][four].five = 1

		b = {1,2,3, foo = true, [asd] = true, lol = {1,2,3}}

		b = {a = 1, [asd] = true, a = 1, b = {a = 1, [asd] = true, a = 1}}

		x={ 1 }
		x[2] = x
		x[x] = 3
		x[3]={ 'indirect recursion', [x]=x }
		y = { x, x }

		x.y = y
		assert (y[1] == y[2])
		s = serialize (x)
		z = loadstring (s)()
		assert (z.y[1] == z.y[2])
		local _={ }
		_[1]={ "indirect recursion" }
		_[2]={ false, false }
		_[3]={ 1, false, _[1], ["y"] = _[2] }
		_[3][2] = _[3]
		_[1][_[3]] = _[3]
		_[3][_[3]] = 3
		_[2][1] = _[3]
		_[2][2] = _[3]
		x={ 1 }
		x[2] = x
		x[x] = 3
		x[3]={ 'indirect recursion', [x]=x }
		y = { x, x }
		x.y = y
		assert (y[1] == y[2])
		s = serialize (x)
		z = loadstring (s)()


		assert (z.y[1] == z.y[2])
		local _={ }
		_[1]={ "indirect recursion" }
		_[2]={ false, false }
		_[3]={ 1, false, _[1], ["y"] = _[2] }
		_[3][2] = _[3]
		_[1][_[3]] = _[3]
		_[3][_[3]] = 3
		_[2][1] = _[3]
		_[2][2] = _[3]


		z = loadstring(1)(2)(3)(4)(5)

		local _={ }


		z = loadstring
		assert(z.y[1] == z.y[2])
		z = loadstring(1)(2)(3)(4)(5)

		lol[3]={
		1,
		false,
		_[1],
		["y"] = _[2]
		}

		assert (z.y[1] == z.y[2])
		local _={ }
		_[1]={ "indirect recursion" }
		_[2]={ false, false }
		_[3]={ 1, false, _[1], ["y"] = _[2] }
		_[3][2] = _[3]
		_[1][_[3]] = _[3]
		_[3][_[3]] = 3
		_[2][1] = _[3]
		_[2][2] = _[3]


		z = loadstring(1)(2)(3)(4)(5)

		local _={ }


		z = loadstring
		assert(z.y[1] == z.y[2])
		z = loadstring(1)(2)(3)(4)(5)


				z = loadstring(1)(2)(3)(4)(5)

		local _={ }


		z = loadstring
		assert(z.y[1] == z.y[2])
		z = loadstring(1)(2)(3)(4)(5)

		foo.bar[1+2]["3"][four].five = 1
		x={ 1 }

			do -- numbers
				for i = 0, 9 do
					char_types[tostring(i)] = "number"
				end
			end

			do -- letters
				char_types["_"] = "letter"

				for i = string.byte("A"), string.byte("z") do
					char_types[string.char(i)] = "letter"
				end
			end

			insert(data, {})
	]==] --[==[
	]==]

	--code = vfs.Read("/home/caps/goluwa/game/lua/libraries/oh.lua")

	local tokens = oh.Tokenize(code)

	if tokens then
		tokens:Dump()
		logn()

		print(loadstring(code))
		print("=============================")
		local str = oh.DumpAST(tokens:ReadBody())

		local func, err = loadstring(str, "")

		if func then
			print(func, err, string.dump(func) == string.dump(loadstring(code, "")))

			--utility.MeldDiff(jit.dumpbytecode(func), jit.dumpbytecode(loadstring(code, "")))
		else
			print("=============================")
			local line = tonumber(err:match("%b[]:(%d+):"))
			local lines = str:split("\n")
			for i = -1, 1 do
				log(lines[line + i])
				if i == 0 then
					log(" --<<< ", err)
				end
				logn()
			end
		end
	end
end

return oh