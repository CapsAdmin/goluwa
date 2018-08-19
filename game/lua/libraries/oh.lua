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
			end

			syntax.char_types = char_types
		end

		syntax.operators = {
			["^"] = {10, 9},
			["%"] = {7, 7},
			["/"] = {7, 7},
			["*"] = {7, 7},
			["+"] = {6, 6},
			["-"] = {6, 6},
			[".."] = {5, 4},
			["<="] = {3, 3},
			["=="] = {3, 3},
			["~="] = {3, 3},
			["<"] = {3, 3},
			[">"] = {3, 3},
			[">="] = {3, 3},
			["and"] = {2, 2},
			["or"] = {1, 1},
			[">>"] = {-1, -1},
			["~U"] = {-1, -1},
			["#"] = {-1, -1},
			["not"] = {-1, -1},
			["<<"] = {-1, -1},
			["!="] = {-1, -1},
			["&"] = {-1, -1},
			["|"] = {-1, -1},
			["-U"] = {-1, -1},
		}

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

function META:GetToken(offset)
	local i = self.i + (offset or 0)
	local info = self.chunks[i]
	if not info then return end
	info.value = info.value or self.code:sub(info.start, info.stop)
	info.i = i
	return info
end

function META:GetLength()
	return #self.chunks
end

function META:Next()
	self.i = self.i + 1
end

function META:BalancedMatch(i, match, max)
	local balance = 0
	local start

	for i2 = i, max or #self.chunks do
		local token = self:GetToken(i2)

		if match[token.value] == true then
			start = start or i2
			balance = balance + 1
		elseif match[token.value] == false then
			balance = balance - 1
		end

		if balance == 0 and start then
			return start, i2
		end
	end
end

function META:MatchAssignment()
	local data = {}

	data.type = "assignment"
	data.indices = {}

	while true do
		local info = self:GetToken()
		self:Next()

		if info.value == "=" then
			break
		end

		if info.value ~= "," then
			if info.type ~= "letter" then
				self:CompileError("unexpected symbol " .. info.value, info.start, info.stop)
				break
			end

			table.insert(data.indices, {{type = "index", value = info}})
		end
	end

	data.expressions = {}

	while true do
		local tree, nxt = self:MatchExpression()

		table.insert(data.expressions, tree)

		if not nxt or nxt.value ~= "," then
			break
		end
	end

	self.i = self.i - 1

	return data
end

function META:MatchBody(stop)
	local tree = {}

	while true do
		local info = self:GetToken()
		self:Next()
		if not info then break end

		if type(stop) == "table" then
			if stop[info.value] then
				return tree
			end
		elseif type(stop) == "string" then
			if info.value == stop then
				return tree
			end
		end

		if info.value == "local" then
			local res = self:GetToken()

			if res.value == "function" then
				self:Next()

				local data = {}
				data.type = "function"
				data.arguments = {}
				data.name = self:GetToken().value
				data.is_local = true

				self:Next()

				while true do
					local tree, nxt = self:MatchExpression()

					if tree.value == ")" then
						break
					end

					table.insert(data.arguments, tree)

					if not nxt or nxt.value ~= "," then
						break
					end
				end

				self.i = self.i - 2

				data.body = self:MatchBody("end")

				table.insert(tree, data)
			else
				local data = self:MatchAssignment()
				data.is_local = true
				table.insert(tree, data)
			end
		elseif info.value == "return" then
			local data = {}
			data.type = "return"
			data.expression = self:MatchExpression()
			self.i = self.i - 1
			table.insert(tree, data)
		elseif info.value == "do" then
			local data = {}
			data.type = "do"
			data.body = self:MatchBody("end")
			table.insert(tree, data)
		elseif info.value == "if" then
			local data = {}
			data.type = "if"
			data.statements = {}

			self.i = self.i - 1

			local stop = false

			for i = 1, 100 do
				local token = self:GetToken()
				self:Next()

				if token.value == "end" then
					break
				end

				if token.value == "else" then
					local body = self:MatchBody("end")
					table.insert(data.statements, {
						body = body,
						token = token,
					})
					break
				end

				local expr = self:MatchExpression()
				local body = self:MatchBody({["else"] = true, ["elseif"] = true, ["end"] = true})

				self.i = self.i - 1

				table.insert(data.statements, {
					expr = expr,
					body = body,
					token = token,
				})
			end

			table.insert(tree, data)
		elseif info.value == "while" then
			local data = {}
			data.type = "while"

			data.expr = self:MatchExpression()
			data.body = self:MatchBody("end")
			table.insert(tree, data)
		elseif info.value == "for" then
			local data = {}
			data.type = "for"
			data.name = self:GetToken().value
			self:Next()

			-- =
			self:Next()

			data.val = self:MatchExpression()
			data.max = self:MatchExpression()
LOL = true
		data.body = self:MatchBody("end")
		LOL = false

			table.insert(tree, data)
		elseif info.type == "letter" then
			local names = {}
			local indices = {{type = "index", value = info}}

			while true do
				local info = self:GetToken()

				if not info then break end

				if info.value == "," then
					table.insert(names, indices)
					indices = {}
				end


				if info.type == "letter" then
					table.insert(indices, {type = "index", value = info})
				end

				if info.value == "[" then
					self:Next()
					table.insert(indices, {type = "expression", value = self:MatchExpression()})
					self.i = self.i - 2
				end

				if info.value == "=" then
					table.insert(names, indices)
					indices = {}

					local data = self:MatchAssignment()
					data.is_local = false
					data.indices = names
					table.insert(tree, data)
					break
				elseif info.value == "(" or info.value == ":" then

					local data = {}

					if info.value == ":" then
						data.self_call = true
						self:Next()
						table.insert(indices, {type = "index", value = self:GetToken()})
						self:Next()
					end

					data.type = "call"
					data.indices = indices
					data.arguments = {}

					self:Next()
					while true do
						local tree, nxt = self:MatchExpression()

						if tree.value == ")" then
							break
						end

						table.insert(data.arguments, tree)

						if not nxt or nxt.value ~= "," then
							break
						end
					end

					table.insert(tree, data)
					break
				end

				self:Next()
			end
		end
	end

	return tree
end

function META:MatchExpression(priority, bracket_match)
	priority = priority or 0
	local v = self:GetToken()
	self:Next()

	if v.value == "(" then
		v = self:MatchExpression(0, bracket_match or 0)
		if bracket_match then
			bracket_match = bracket_match + 1
		end
	elseif v.value == ")" then
		if bracket_match then
			bracket_match = bracket_match - 1
		end
	end

	if v.value == "-" or v.value == "#" or v.value == "not" then
		local obj, op = self:MatchExpression(unary_priority, bracket_match)
		v = {type = "unary", value = v.value, argument = obj}
		return v, op
	elseif v.value == "function" then
		self:Next()

		local arguments = {}

		while true do
			local tree, nxt = self:MatchExpression()

			table.insert(arguments, tree)

			if not nxt or nxt.value ~= "," then
				break
			end
		end

		v = {type = "function", arguments = arguments, body = self:MatchBody("end")}

		self:Next()

		return v
	end

	local op = self:GetToken()
	self:Next()

	if not op then
		return v
	end

	while (not bracket_match or bracket_match == 0) and oh.syntax.operators[op.value] and oh.syntax.operators[op.value][1] > priority do
		local v2, nextop = self:MatchExpression(oh.syntax.operators[op.value][2], bracket_match)

		v = {type = "operator", value = op.value, left = v, right = v2}

		if not nextop then
			return v
		end

		op = nextop
	end


	--[[if v and v.type == "letter" then
		local indices = {{type = "index", value = v}}

		while true do
			local info = self:GetToken()

			if not info then break end

			if info.type == "letter" then
				table.insert(indices, {type = "index", value = info})
			end

			if info.value == "[" then
				self:Next()
				table.insert(indices, {type = "expression", value = self:MatchExpression()})
				self.i = self.i - 2
			end

			if info.value == "(" then
				local data = {}
				data.type = "call"
				data.indices = indices
				data.arguments = {}

				self:Next()
				while true do
					local tree, nxt = self:MatchExpression()

					table.insert(data.arguments, tree)

					if not nxt or nxt.value ~= "," then
						break
					end
				end

				local op = self:GetToken()
				self:Next()

				return data, op
			end

			self:Next()
		end
	end]]

	return v, op
end


function META:CompileError(msg, start, stop)
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

	str = context_start .. str .. context_stop:sub(#content_after + 1)

	print(str)

	return nil, "\n" .. str
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
	log(self.code:sub(start+1))
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
		else
			if oh.syntax.keywords[v.value] then
				_" " _(v.value) _ " "
			else
				self:emit(v.value)
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
				_"\t"_"return "_:Expression(data.expression)
			elseif data.type == "for" then
				_"\t"_"for "_(data.name)_" = "_:Expression(data.val)_", "_:Expression(data.max)_" do"_"\n"
					_"\t+"
						_:Body(data.body)
					_"\t-"
				_"\t"_"end"
			elseif data.type == "do" then
				_"\t"_"do\n"
					_"\t+"
						_:Body(data.body)
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

				for i,v in ipairs(data.indices) do
					if i == 1 then
						_(v.value.value)
					elseif v.type == "expression" then
						_"["_:Value(v.value)_"]"
					else
						if data.self_call and i == #data.indices then
							_":"_(v.value.value)
						else
							_"."_(v.value.value)
						end
					end
				end

				_"("_:arguments(data.arguments)_")"
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
				return self:CompileError("unknown symbol >>" .. char .. "<< (" .. char:byte() .. ")", i, i)
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
						return self:CompileError("cannot find the end of multiline comment", i, i)
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
					return self:CompileError("cannot find the end of double quote", i, i)
				end

				add_token(self, "string", i, stop)

				i = stop
			elseif self.code:sub(i, i) == oh.syntax.literal_quote or is_literal_lua_string(self, i) then
				local stop

				if self.code:sub(i, i) == oh.syntax.literal_quote then
					stop = capture_literal_string(self, i)

					if not stop then
						return self:CompileError("cannot find the end of literal quote", i, i)
					end
				else
					local stop_, err = capture_literal_lua_string(self, i)
					if not stop_ and err then
						return self:CompileError("cannot find the end of literal quote: " .. err, i, i)
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
					return self:CompileError("cannot find the end of single quote", i, i)
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
								return self:CompileError("malformed number: pow character can only be used once")
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
								return self:CompileError("malformed number: invalid character '" .. char .. "'. only abcdef0123456789_ allowed after hex notation", i, offset)
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
								return self:CompileError("malformed number: only 01_ allowed after binary notation", i, offset)
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
								return self:CompileError("malformed number: invalid character '" .. char .. "'. only +-0123456789 allowed after exponent", i, offset)
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
									return self:CompileError("malformed number: invalid character '" .. char .. "'. only ule allowed after a number", i, offset)
								end
							elseif t == "space" or t == "symbol" then
								stop = offset - 1
								break
							elseif not found_dot and char == "." then
								found_dot = true
							else
								return self:CompileError("malformed number: invalid character '" .. char .. "'. this should never happen?", i, offset)
							end
						end


					end

					add_token(self, "number", i, stop)

					if not stop then
						return self:CompileError("malformed number: expected number after exponent", i, i)
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
					return self:CompileError("malformed letter: could not find end", i, i)
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

	]==]


	local tokens = oh.Tokenize(code)

	if tokens then
		tokens:Dump()
		logn()

		assert(loadstring(code))

		local str = oh.DumpAST(tokens:MatchBody())

		local func, err = loadstring(str, "")

		if func then
			print(func, err, string.dump(func) == string.dump(loadstring(code, "")))

			--utility.MeldDiff(jit.dumpbytecode(func), jit.dumpbytecode(loadstring(code, "")))
		else
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