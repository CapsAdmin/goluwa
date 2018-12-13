local lua, oh = ...
oh = oh or _G.oh
lua = lua or oh.lua

local table_remove = table.remove
local ipairs = ipairs

local META = {}
META.__index = META

function META:Whitespace(str, force)

	if self.config.preserve_whitespace and not force then return end

	if str == "?" then
		if self:GetPrevCharType() == "letter" or self:GetPrevCharType() == "number" then
			self:Emit(" ")
		end
	elseif str == "\t" then
		self:EmitIndent()
	elseif str == "\t+" then
		self:Indent()
	elseif str == "\t-" then
		self:Outdent()
	else
		self:Emit(str)
	end
end


function META:Emit(str)
	self.out[self.i] = str or ""
	self.i = self.i + 1
end

function META:Indent()
	self.level = self.level + 1
end

function META:Outdent()
	self.level = self.level - 1
end

function META:EmitIndent()
	self:Emit(("\t"):rep(self.level))
end

function META:GetPrevCharType()
	local prev = self.out[self.i - 1]
	return prev and lua.syntax.GetCharacterType(prev:sub(-1))
end

function META:EmitToken(v, translate)
	if v.whitespace then
		for _, data in ipairs(v.whitespace) do
			if data.type ~= "space" or self.config.preserve_whitespace then
				self:Emit(data.value)
			end
		end
	end

	if translate then
		if type(translate) == "table" then
			self:Emit(translate[v.value] or v.value)
		elseif translate ~= "" then
			self:Emit(translate)
		end
	else
		self:Emit(v.value)
	end
end

function META:Expression(v)
	if v.tokens["left("] then
		for __, v in ipairs(v.tokens["left("]) do
			self:EmitToken(v)
		end
	end

	if v.type == "operator" then
		if v.left then self:Expression(v.left) end
		self:Operator(v)
		if v.right then self:Expression(v.right) end
	elseif v.type == "function" then
		self:Function(v)
	elseif v.type == "table" then
		self:Table(v)
	elseif v.type == "unary" then
		self:Unary(v)
	elseif v.type == "value" then
		self:EmitToken(v.value)
	else
		error("unhandled token type " .. v.type)
	end

	if v.tokens["right)"] then
		for __, v in ipairs(v.tokens["right)"]) do
			self:EmitToken(v)
		end
	end

	if v.suffixes then
		for _, node in ipairs(v.suffixes) do
			if node.type == "index" then
				self:EmitToken(node.tokens["."])
				self:EmitToken(node.value.value)
			elseif node.type == "self_index" then
				self:EmitToken(node.tokens[":"])
				self:EmitToken(node.value.value)
			elseif node.type == "index_expression" then
				self:EmitToken(node.tokens["["])
				self:Expression(node.value)
				self:EmitToken(node.tokens["]"])
			elseif node.type == "call" then
				if node.tokens["call("] then
					self:EmitToken(node.tokens["call("])
				end
				self:ExpressionList(node.arguments)

				if node.tokens["call)"] then
					self:EmitToken(node.tokens["call)"])
				end
			end
		end
	end
end

function META:Operator(v)
	self:EmitToken(v.tokens.operator)
end

function META:Function(v)
	self:Whitespace("\t")

	if v.is_local then
		self:EmitToken(v.tokens["local"])
	end

	self:EmitToken(v.tokens["function"])
	self:Whitespace(" ")

	if v.value then
		self:Expression(v.value)
	end

	self:EmitToken(v.tokens["func("])self:ExpressionList(v.arguments)self:EmitToken(v.tokens["func)"])

	if v.return_types then
		for i,args in ipairs(v.return_types) do
			for i,v in ipairs(args) do
				self:Emit(" --[[")
				self:Emit(table.concat(v, ", "))
				self:Emit("]]")
			end
		end
	end

	self:Whitespace("\n")
		self:Whitespace("\t+")
			self:Block(v.block)
		self:Whitespace("\t-")
	self:Whitespace("\t")self:EmitToken(v.tokens["end"])
end

function META:Table(v)
	if not v.children[1] then
		self:EmitToken(v.tokens["{"])self:EmitToken(v.tokens["}"])
	else
		self:EmitToken(v.tokens["{"])self:Whitespace("\n")
			self:Whitespace("\t+")
			for i,v in ipairs(v.children) do
				self:Whitespace("\t")
				if v.type == "table_index_value" then
					self:Expression(v.value)
				elseif v.type == "table_key_value" then
					self:Expression(v.key)
					self:EmitToken(v.tokens["="])
					self:Expression(v.value)
				elseif v.type == "table_expression_value" then

					self:EmitToken(v.tokens["["])
					self:Whitespace("(")
					self:Expression(v.key)
					self:Whitespace(")")
					self:EmitToken(v.tokens["]"])

					self:EmitToken(v.tokens["="])

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
		self:Whitespace("\t")self:EmitToken(v.tokens["}"])
	end
end

function META:Unary(v)
	if lua.syntax.IsKeyword(v.operator) then
		self:EmitToken(v.tokens.operator, "")self:Whitespace("?", true)self:Emit(v.operator)self:Expression(v.expression)
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

local function emit_block_with_continue(self, data, repeat_expression)
	if data.has_continue and data.block[#data.block] and data.block[#data.block].type == "return" then
		local ret = table_remove(data.block)
		self:Block(data.block)

		self:Whitespace("\t")self:EmitToken(ret["return"], "")self:Emit("do return")self:Whitespace("?", true)
		if ret.expressions then
			self:ExpressionList(ret.expressions)
		end
		self:Whitespace("?", true)
		self:Emit("end")
	else
		self:Block(data.block)
	end

	if not repeat_expression and data.has_continue then
		self:Whitespace("\t")self:Emit("::continue__oh::")
	end
end

function META:BuildCode(ast)
	self.level = 0
	self.out = {}
	self.i = 1

	self:Block(ast)

	return table.concat(self.out)
end

function META:Block(tree)
	for __, data in ipairs(tree) do
		if data.type == "if" then
			for i,v in ipairs(data.clauses) do
				self:Whitespace("\t")self:EmitToken(v.tokens["if/else/elseif"]) if v.condition then self:Expression(v.condition) self:Whitespace(" ") self:EmitToken(v.tokens["then"]) end self:Whitespace("\n")
				self:Whitespace("\t+")
					self:Block(v.block)
				self:Whitespace("\t-")
			end
			self:Whitespace("\t") self:EmitToken(data.tokens["end"])
		elseif data.type == "goto" then
			self:Whitespace("\t") self:EmitToken(data.tokens["goto"]) self:Whitespace(" ") self:Expression(data.label)
		elseif data.type == "goto_label" then
			self:Whitespace("\t") self:EmitToken(data.tokens["::left"]) self:Expression(data.label) self:EmitToken(data.tokens["::right"])
		elseif data.type == "while" then
			self:Whitespace("\t")self:EmitToken(data.tokens["while"])self:Expression(data.expression)self:Whitespace("?")self:EmitToken(data.tokens["do"])self:Whitespace("\n")
				self:Whitespace("\t+")
					emit_block_with_continue(self, data)
				self:Whitespace("\t-")
			self:Whitespace("\t")self:EmitToken(data.tokens["end"])
		elseif data.type == "repeat" then
			if data.has_continue then
				self:Whitespace("\t")self:EmitToken(data.tokens["repeat"], "while true do --[[repeat]]")self:Whitespace("\n")
					self:Whitespace("\t+")
						emit_block_with_continue(self, data, true)
					self:Whitespace("\t-")
				self:Whitespace("\t") self:EmitToken(data.tokens["until"],"")
				self:Emit("if--[[until]](") self:Expression(data.expression) self:Emit(")then break end") self:Emit("::continue__oh::end")
			else
				self:Whitespace("\t")self:EmitToken(data.tokens["repeat"])self:Whitespace("\n")
					self:Whitespace("\t+")
						emit_block_with_continue(self, data)
					self:Whitespace("\t-")
				self:Whitespace("\t") self:EmitToken(data.tokens["until"])self:Expression(data.condition)
			end
		elseif data.type == "break" then
			self:Whitespace("\t")self:EmitToken(data.tokens["break"])
		elseif data.type == "return" then
			self:Whitespace("\t")self:Whitespace("?")self:EmitToken(data.tokens["return"])

			if data.expressions then
				self:ExpressionList(data.expressions)
			end
		elseif data.type == "continue" then
			self:Whitespace("\t")self:Whitespace("?") self:EmitToken(data["continue"], "goto continue__oh")
		elseif data.type == "for_i" or data.type == "for_kv" then
			self:Whitespace("\t")self:EmitToken(data.tokens["for"])
			if data.type == "for_i" then
				self:EmitToken(data.identifier.value)self:Whitespace(" ") self:EmitToken(data.tokens["="]) self:Whitespace(" ")self:Expression(data.expression)self:EmitToken(data.tokens[",1"])self:Whitespace(" ")self:Expression(data.max)

				if data.step then
					self:EmitToken(data.tokens[",2"])self:Whitespace(" ")self:Expression(data.step)
				end
			else
				self:Whitespace("?")
				self:ExpressionList(data.identifiers)
				self:Whitespace("?")
				self:EmitToken(data.tokens["in"])
				self:Whitespace("?")
				self:ExpressionList(data.expressions)
			end

			self:Whitespace("?")self:EmitToken(data.tokens["do"])self:Whitespace("\n")
				self:Whitespace("\t+")
					emit_block_with_continue(self, data)
				self:Whitespace("\t-")
			self:Whitespace("\t")self:EmitToken(data.tokens["end"])

		elseif data.type == "do" then
			self:Whitespace("\t")self:EmitToken(data.tokens["do"])self:Whitespace("\n")
				self:Whitespace("\t+")
					self:Block(data.block)
				self:Whitespace("\t-")
			self:Whitespace("\t")self:EmitToken(data.tokens["end"])
		elseif data.type == "assignment" then
			self:Whitespace("\t") if data.is_local then self:EmitToken(data.tokens["local"])self:Whitespace(" ") end

			for i,v in ipairs(data.lvalues) do
				if data.is_local then
					self:EmitToken(v.value)
				else
					self:Expression(v)
				end
				if data.lvalues[2] and i ~= #data.lvalues then
					self:EmitToken(v.tokens[","])self:Whitespace(" ")
				end

				if v.value_type then
					self:Emit(" --[[")
					self:Emit(table.concat(v.value_type, ", "))
					self:Emit("]]")
				end
			end

			if data.rvalues then
				self:Whitespace(" ")self:EmitToken(data.tokens["="])self:Whitespace(" ")

				for i,v in ipairs(data.rvalues) do
					self:Expression(v)

					if data.rvalues[2] and i ~= #data.rvalues then
						self:EmitToken(v.tokens[","])self:Whitespace(" ")
					end
				end
			end
		elseif data.type == "function" then
			self:Function(data)
		elseif data.type == "expression" then
			self:Expression(data.value)
		elseif data.type == "call" then
			self:Whitespace("\t")self:Expression(data.value)
		elseif data.type == "end_of_statement" then
			self:EmitToken(data.tokens[";"])
		elseif data.type == "end_of_file" then
			self:EmitToken(data.tokens["end_of_file"])
		elseif data.type == "shebang" then
			self:EmitToken(data.tokens["shebang"])
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

return function(config)
	local self = setmetatable({}, META)
	self.config = config
	return self
end