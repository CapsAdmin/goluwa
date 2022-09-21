local lua, oh = ...
oh = oh or _G.oh
lua = lua or oh.lua
local table_remove = table.remove
local ipairs = ipairs
local META = oh.BaseEmitter

function META:ExpressionFromSuffixes(node)
	local linear = {node.value}

	for _, suffix in ipairs(node.suffixes) do
		table.insert(linear, 1, suffix)
		table.insert(linear, 1, suffix)
	end

	local i = 1

	local function get_token()
		return linear[i]
	end

	local function binary()
		local val = {value = get_token()}
		i = i + 1

		while get_token() do
			local op = get_token()

			if not op then break end

			i = i + 1
			local right = binary()
			local left = val
			val = {}
			val.op = op
			val.left = left
			val.right = right
		end

		return val
	end

	return binary()
end

function META:Expression(v)
	if v.tokens["left("] then
		for __, v in ipairs(v.tokens["left("]) do
			self:EmitToken(v)
		end
	end

	if v.type == "operator" then
		local func_name = lua.syntax.GetFunctionForOperator(v.tokens["operator"])

		if v.tokens["operator"].value == "+" then
			func_name = "$O.add"
		elseif v.tokens["operator"].value == "-" then
			func_name = "$O.sub"
		elseif v.tokens["operator"].value == "*" then
			func_name = "$O.mul"
		elseif v.tokens["operator"].value == "/" then
			func_name = "$O.div"
		elseif v.tokens["operator"].value == "%" then
			func_name = "$O.mod"
		elseif v.tokens["operator"].value == "^" then
			func_name = "$O.pow"
		elseif v.tokens["operator"].value == ".." then
			func_name = "$O.concat"
		end

		if func_name then
			self:Emit(" " .. func_name .. "(")

			if v.left then self:Expression(v.left) end

			self:Emit(",")

			if v.right then self:Expression(v.right) end

			self:Emit(") ")
		else
			if v.left then self:Expression(v.left) end

			self:Operator(v)

			if v.right then self:Expression(v.right) end
		end
	elseif v.type == "function" then
		self:Function(v)
	elseif v.type == "table" then
		self:Table(v)
	elseif v.type == "unary" then
		self:Unary(v)
	elseif v.type == "value" then
		if v.value.value == "..." then
			self:EmitToken(v.value, "...args")
		elseif v.value.value == "nil" then
			self:EmitToken(v.value, "undefined")
		elseif v.suffixes then
			local exp = self:ExpressionFromSuffixes(v)

			local function go(node)
				if node.value then
					local node = node.value

					if node.type == "letter" then
						self:EmitToken(node)
					elseif node.type == "index_expression" then
						self:Expression(node.value)
					elseif node.type == "self_index" or node.type == "index" then
						self:Emit("\"")
						self:EmitToken(node.value.value)
						self:Emit("\"")

						if node.type == "self_index" then self.SELFINDEX = true end
					elseif node.type == "call" then
						self:ExpressionList(node.arguments)
					end

					return
				end

				if self.NEWINDEX then
					self.NEWINDEX = nil
					go(node.right)
					self:Emit(",")
					go(node.left)
				else
					self:Emit("$O.")
					self:Emit(node.op.type)
					self:Emit("(")
					go(node.right)
					self:Emit(",")
					go(node.left)
					self:Emit(")")
				end
			end

			go(exp)
		else
			self:EmitToken(v.value)
		end

		if v.data_type then --print(v)
		--self:Emit("--[[a]]")
		end
	else
		error("unhandled token type " .. v.type)
	end

	if v.tokens["right)"] then
		for __, v in ipairs(v.tokens["right)"]) do
			self:EmitToken(v)
		end
	end
end

function META:Operator(v)
	local translate

	if v.tokens.operator.value == "==" then
		translate = "==="
	elseif v.tokens.operator.value == "and" then
		translate = "&&"
	elseif v.tokens.operator.value == "or" then
		translate = "||"
	elseif v.tokens.operator.value == "~=" then
		translate = "!="
	end

	self:EmitToken(v.tokens.operator, translate)
end

function META:Function(v)
	self:Whitespace("\t")

	if v.is_local then
		self:EmitToken(v.tokens["local"], "let")
	else
		self:EmitToken(v.tokens["function"], "/*function*/")
	end

	--self:Whitespace(" ")
	if v.value then
		self.NEWINDEX = true
		self:Emit("$O.newindex(")
		self:Expression(v.value)
		self:Emit(",")
	end

	if v.is_local then self:Emit("=") end

	self:EmitToken(v.tokens["func("])

	if self.SELFINDEX then
		self.SELFINDEX = nil
		self:Emit("self")

		if v.arguments[1] then self:Emit(",") end
	end

	self:ExpressionList(v.arguments)
	self:EmitToken(v.tokens["func)"])
	self:Emit("=>")

	if v.return_types then
		for i, args in ipairs(v.return_types) do
			for i, v in ipairs(args) do
				self:Emit(" --[[")
				self:Emit(table.concat(v, ", "))
				self:Emit("]]")
			end
		end
	end

	self:Emit("{")
	self:Whitespace("\n")
	self:Whitespace("\t+")
	self:Block(v.block)
	self:Whitespace("\t-")
	self:Whitespace("\t")
	self:EmitToken(v.tokens["end"], "}")

	if v.value then self:Emit(")") end
end

function META:Table(v)
	if not v.children[1] then
		self:EmitToken(v.tokens["{"])
		self:EmitToken(v.tokens["}"])
	else
		local guess = "array"

		for i, v in ipairs(v.children) do
			if v.type == "table_index_value" or v.type == "table_expression_value" then
				guess = "array"
			else
				guess = "table"

				break
			end
		end

		if guess == "table" then
			self:EmitToken(v.tokens["{"])
		else
			self:EmitToken(v.tokens["{"], "[")
		end

		self:Whitespace("\n")
		self:Whitespace("\t+")

		for i, v in ipairs(v.children) do
			self:Whitespace("\t")

			if v.type == "table_index_value" then
				if guess == "table" then self:Emit(v.key .. ":") end

				self:Expression(v.value)
			elseif v.type == "table_key_value" then
				self:Expression(v.key)

				if v.tokens["="] then
					self:EmitToken(v.tokens["="], ":")
					self:Expression(v.value)
				else
					self:Emit(" = nil")
				end
			elseif v.type == "table_expression_value" then
				self:EmitToken(v.tokens["["])
				self:Whitespace("(")
				self:Expression(v.key)
				self:Whitespace(")")
				self:EmitToken(v.tokens["]"])
				self:EmitToken(v.tokens["="], ":")
				self:Expression(v.value)
			end

			if v.tokens[","] then
				self:EmitToken(v.tokens[","])
			else
				self:Whitespace(",")
			end

			self:Whitespace("\n")
		end

		self:Whitespace("\t-")
		self:Whitespace("\t")

		if guess == "table" then
			self:EmitToken(v.tokens["}"])
		else
			self:EmitToken(v.tokens["}"], "]")
		end
	end
end

function META:Unary(v)
	local func_name = lua.syntax.GetFunctionForUnaryOperator(v.tokens["operator"])

	if v.tokens["operator"].value == "#" then
		func_name = "$O.len"
	elseif v.tokens["operator"].value == "-" then
		func_name = "$O.unm"
	elseif v.tokens["operator"].value == "~" then
		func_name = "$O.bnot"
	end

	if func_name then
		self:Emit(" " .. func_name .. "(")
		self:Expression(v.expression)
		self:Emit(") ")
	else
		if lua.syntax.IsKeyword(v.operator) then
			self:EmitToken(v.tokens.operator, "")
			self:Whitespace("?", true)
			self:Emit(v.operator)
			self:Expression(v.expression)
		else
			if v.tokens["("] and v.tokens.operator.start > v.tokens["("].start then
				if v.tokens["("] then self:EmitToken(v.tokens["("]) end

				self:EmitToken(v.tokens.operator)
			else
				self:EmitToken(v.tokens.operator)

				if v.tokens["("] then self:EmitToken(v.tokens["("]) end
			end

			self:Expression(v.expression)

			if v.tokens[")"] then self:EmitToken(v.tokens[")"]) end
		end
	end
end

local function emit_block_with_continue(self, data, repeat_expression)
	if
		data.has_continue and
		data.block[#data.block] and
		data.block[#data.block].type == "return"
	then
		local ret = table_remove(data.block)
		self:Block(data.block)
		self:Whitespace("\t")
		self:EmitToken(ret["return"], "")
		self:Emit("do return")
		self:Whitespace("?", true)

		if ret.expressions then self:ExpressionList(ret.expressions) end

		self:Whitespace("?", true)
		self:Emit("end")
	else
		self:Block(data.block)
	end

	if not repeat_expression and data.has_continue then
		self:Whitespace("\t")
		self:Emit("::continue__oh::")
	end
end

function META:Block(block)
	for __, data in ipairs(block.statements) do
		if data.type == "if" then
			for i, v in ipairs(data.clauses) do
				self:Whitespace("\t")

				if v.tokens["if/else/elseif"].value == "if" then
					self:EmitToken(v.tokens["if/else/elseif"])
				elseif v.tokens["if/else/elseif"].value == "elseif" then
					self:EmitToken(v.tokens["if/else/elseif"], "} else if")
				else
					self:EmitToken(v.tokens["if/else/elseif"], "} else {")
				end

				if v.condition then
					self:Emit("(")
					self:Expression(v.condition)
					self:Emit(")")
					self:Whitespace(" ")
					self:EmitToken(v.tokens["then"], "{")
				end

				self:Whitespace("\n")
				self:Whitespace("\t+")
				self:Block(v.block)
				self:Whitespace("\t-")

				if v.tokens["end"] then self:EmitToken(v.tokens["end"], "}") end
			end
		elseif data.type == "goto" then
			self:Whitespace("\t")
			self:EmitToken(data.tokens["goto"])
			self:Whitespace(" ")
			self:Expression(data.label)
		elseif data.type == "goto_label" then
			self:Whitespace("\t")
			self:EmitToken(data.tokens["::left"])
			self:Expression(data.label)
			self:EmitToken(data.tokens["::right"])
		elseif data.type == "while" then
			self:Whitespace("\t")
			self:EmitToken(data.tokens["while"])
			self:Expression(data.expression)
			self:Whitespace("?")
			self:EmitToken(data.tokens["do"])
			self:Whitespace("\n")
			self:Whitespace("\t+")
			emit_block_with_continue(self, data)
			self:Whitespace("\t-")
			self:Whitespace("\t")
			self:EmitToken(data.tokens["end"])
		elseif data.type == "repeat" then
			if data.has_continue then
				self:Whitespace("\t")
				self:EmitToken(data.tokens["repeat"], "while true do --[[repeat]]")
				self:Whitespace("\n")
				self:Whitespace("\t+")
				emit_block_with_continue(self, data, true)
				self:Whitespace("\t-")
				self:Whitespace("\t")
				self:EmitToken(data.tokens["until"], "")
				self:Emit("if--[[until]](")
				self:Expression(data.condition)
				self:Emit(")then break end")
				self:Emit("::continue__oh::end")
			else
				self:Whitespace("\t")
				self:EmitToken(data.tokens["repeat"])
				self:Whitespace("\n")
				self:Whitespace("\t+")
				emit_block_with_continue(self, data)
				self:Whitespace("\t-")
				self:Whitespace("\t")
				self:EmitToken(data.tokens["until"])
				self:Expression(data.condition)
			end
		elseif data.type == "break" then
			self:Whitespace("\t")
			self:EmitToken(data.tokens["break"])
		elseif data.type == "return" then
			self:Whitespace("\t")
			self:Whitespace("?")
			self:EmitToken(data.tokens["return"])
			self:Emit(" ")

			if data.expressions then self:ExpressionList(data.expressions) end
		elseif data.type == "continue" then
			self:Whitespace("\t")
			self:Whitespace("?")
			self:EmitToken(data.tokens["continue"], "goto continue__oh")
		elseif data.type == "for_i" or data.type == "for_kv" then
			self:Whitespace("\t")
			self:EmitToken(data.tokens["for"])

			if data.type == "for_i" then
				self:Emit("(let")
				self:EmitToken(data.identifier.value)
				self:Whitespace(" ")
				self:EmitToken(data.tokens["="])
				self:Whitespace(" ")
				self:Expression(data.expression)
				self:EmitToken(data.tokens[",1"], ";")
				self:Whitespace(" ")
				self:Emit("i <=")
				self:Expression(data.max)

				if data.step then
					self:EmitToken(data.tokens[",2"])
					self:Whitespace(" ")
					self:Expression(data.step)
				else
					self:Emit("; i++")
				end

				self:Emit(")")
			else
				self:Emit("(let [")
				self:Whitespace("?")
				self:ExpressionList(data.identifiers)
				self:Emit("]")
				self:Whitespace("?")
				self:EmitToken(data.tokens["in"], "of")
				self:Whitespace("?")
				self:ExpressionList(data.expressions)
				self:Emit(")")
			end

			self:Whitespace("?")
			self:EmitToken(data.tokens["do"], "{")
			self:Whitespace("\n")
			self:Whitespace("\t+")
			emit_block_with_continue(self, data)
			self:Whitespace("\t-")
			self:Whitespace("\t")
			self:EmitToken(data.tokens["end"], "}")
		elseif data.type == "do" then
			self:Whitespace("\t")
			self:EmitToken(data.tokens["do"], "{")
			self:Whitespace("\n")
			self:Whitespace("\t+")
			self:Block(data.block)
			self:Whitespace("\t-")
			self:Whitespace("\t")
			self:EmitToken(data.tokens["end"], "}")
		elseif data.type == "assignment" then
			self:Whitespace("\t")

			if data.is_local then
				self:EmitToken(data.tokens["local"], "let")
				self:Whitespace(" ")
			end

			if not data.is_local then  end

			for i, v in ipairs(data.lvalues) do
				if data.is_local then
					self:EmitToken(v.value)
				else
					self.NEWINDEX = true
					self:EmitToken(v.value, "$O.newindex(")
					self:Expression(v)
				end

				if data.lvalues[2] and i ~= #data.lvalues then
					self:EmitToken(v.tokens[","])
					self:Whitespace(" ")
				end

				if v.value_type then
					self:Emit(" --[[")
					self:Emit(table.concat(v.value_type, ", "))
					self:Emit("]]")
				end
			end

			if data.rvalues then
				self:Whitespace(" ")
				self:EmitToken(data.tokens["="], not data.is_local and "," or nil)
				self:Whitespace(" ")

				for i, v in ipairs(data.rvalues) do
					self:Expression(v)

					if data.rvalues[2] and i ~= #data.rvalues then
						self:EmitToken(v.tokens[","])
						self:Whitespace(" ")
					end
				end
			else
				self:Emit(", undefined")
			end

			if not data.is_local then self:Emit(")") end

			self.NEWINDEX = false
			self:Emit(";")
		elseif data.type == "function" then
			self:Function(data)
		elseif data.type == "expression" then
			self:Expression(data.value)
		elseif data.type == "call" then
			self:Whitespace("\t")
			self:Expression(data.value)
		elseif data.type == "end_of_statement" then
			self:EmitToken(data.tokens[";"])
		elseif data.type == "end_of_file" then
			self:EmitToken(data.tokens["end_of_file"])
		elseif data.type == "shebang" then
			self:EmitToken(data.tokens["shebang"])
		elseif data.type == "interface" then
			self:Emit("-- interface TODO")
		elseif data.type == "compiler$Otion" then
			self:Emit("--" .. data.lua)

			if data.lua:startswith("E:") then
				assert(loadstring("local self = ...;" .. data.lua:sub(3)))(self)
			end
		else
			error("unhandled value: " .. data.type)
		end

		self:Whitespace("\n")
	end
end

function META:ExpressionList(tbl)
	for i = 1, #tbl do
		self:Expression(tbl[i])

		if i ~= #tbl then
			self:EmitToken(tbl[i].tokens[","])
			self:Whitespace(" ")
		end
	end
end

if RELOAD then
	RELOAD = nil
	runfile("lua/libraries/oh/oh.lua")
	runfile("lua/libraries/oh/lua/test.lua")
	return
end

return function(config)
	local self = setmetatable({}, META)
	self.config = config
	return self
end