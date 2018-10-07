local oh = ... or _G.oh

local table_remove = table.remove
local ipairs = ipairs

local META = {}
META.__index = META

function META:Whitespace(str, force)

	if self.code and not force then return end

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
	self.out[self.i] = str
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
	return prev and oh.syntax.char_types[prev:sub(-1)]
end

function META:Token(v, translate)
	if v.type == "string" and v.value:sub(1, 1) == "`" then
		local len = #v.value:match("^([`]+)")
		self:Emit("[")self:Emit(("="):rep(len))self:Emit("[")
		self:Emit(v.value:sub(len+1, -len-1))
		self:Emit("]")self:Emit(("="):rep(len))self:Emit("]")
	else
		if v.comments and v.whitespace_start then
			for _, comment in ipairs(v.comments) do
				if comment.value:sub(1, 2) == "/*" then
					self:Emit("--[====[" .. comment.value .. "]====]")
				elseif comment.value:sub(1, 2) == "//" then
					self:Emit("--" .. comment.value)
				elseif comment.type ~= "space" or self.code then
					self:Emit(comment.value)
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
end

function META:Expression(v)
	if v.tokens["left("] then
		for __, v in ipairs(v.tokens["left("]) do
			self:Token(v)
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
		self:Token(v.value)
	else
		error("unhandled token type " .. v.type)
	end

	if v.tokens["right)"] then
		for __, v in ipairs(v.tokens["right)"]) do
			self:Token(v)
		end
	end

	if v.calls then
		for i,v in ipairs(v.calls) do
			if v.type == "index_expression" then
				self:Token(v.tokens["["])
				self:Whitespace"("self:Expression(v.value)self:Whitespace")"
				self:Token(v.tokens["]"])
			elseif v.type == "call" then
				if v.tokens["call("] then self:Token(v.tokens["call("]) end
				self:CommaSeperated(v.arguments)
				if v.tokens["call)"] then self:Token(v.tokens["call)"]) end
			end
		end
	end
end

function META:Operator(v)
	if oh.syntax.operator_translate[v.value] then
		self:Token(v, oh.syntax.operator_translate[v.value])
	else
		self:Token(v.tokens.operator)
	end
end

function META:Function(v)
	if v.is_local then
		self:Whitespace"\t"self:Token(v.tokens["local"])self:Whitespace" "self:Token(v.tokens["function"])self:Whitespace" "self:Token(v.index_expression)
	else
		self:Token(v.tokens["function"])

		if v.index_expression then
			self:Whitespace" " self:Expression(v.index_expression)
		end
	end

	self:Token(v.tokens["func("])self:CommaSeperated(v.arguments)self:Token(v.tokens["func)"])self:Whitespace"\n"
		self:Whitespace"\t+"
			self:Block(v.block)
		self:Whitespace"\t-"
	self:Whitespace"\t"self:Token(v.tokens["end"])
end

function META:Table(v)
	if not v.children[1] then
		self:Token(v.tokens["{"])self:Token(v.tokens["}"])
	else
		self:Token(v.tokens["{"])self:Whitespace"\n"
			self:Whitespace"\t+"
			for i,v in ipairs(v.children) do
				self:Whitespace"\t"
				if v.type == "value" then
					self:Expression(v.value)
				elseif v.type == "key_value" then
					self:Expression(v.key) self:Token(v.tokens["="]) self:Expression(v.expression)
				elseif v.type == "expression_value" then
					self:Token(v.tokens["["])self:Whitespace"("self:Expression(v.key)self:Whitespace")" self:Token(v.tokens["]"]) self:Token(v.tokens["="]) self:Expression(v.expression)
				end
				if v.tokens[","] then
					self:Token(v.tokens[","])
				else
					self:Whitespace","
				end
				self:Whitespace"\n"
			end
			self:Whitespace"\t-"
		self:Whitespace"\t"self:Token(v.tokens["}"])
	end
end

function META:Unary(v)
	if oh.syntax.keywords[v.operator] then
		self:Token(v.tokens.operator, "")self:Whitespace("?", true)self:Emit(v.operator)self:Expression(v.expression)
	else
		if v.tokens["("] and v.tokens.operator.start > v.tokens["("].start then
			if v.tokens["("] then self:Token(v.tokens["("]) end
			self:Token(v.tokens.operator)
		else
			self:Token(v.tokens.operator)
			if v.tokens["("] then self:Token(v.tokens["("]) end
		end

		self:Expression(v.expression)

		if v.tokens[")"] then self:Token(v.tokens[")"]) end
	end
end

local function emit_block_with_continue(self, data, repeat_expression)
	if data.has_continue and data.block[#data.block] and data.block[#data.block].type == "return" then
		local ret = table_remove(data.block)
		self:Block(data.block)

		self:Whitespace"\t"self:Token(ret["return"], "")self:Emit"do return"self:Whitespace("?", true)
		if ret.expressions then
			self:CommaSeperated(ret.expressions)
		end
		self:Whitespace("?", true)
		self:Emit("end")
	else
		self:Block(data.block)
	end

	if not repeat_expression and data.has_continue then
		self:Whitespace"\t"self:Emit"::continue__oh::"
	end
end

function META:Block(tree)
	for __, data in ipairs(tree) do
		if data.type == "if" then
			for i,v in ipairs(data.clauses) do
				self:Whitespace"\t"self:Token(v.tokens["if/else/elseif"]) if v.expr then self:Expression(v.expr) self:Whitespace" " self:Token(v.tokens["then"]) end self:Whitespace"\n"
					self:Whitespace"\t+"
						self:Block(v.block)
					self:Whitespace"\t-"
			end
			self:Whitespace"\t" self:Token(data.tokens["end"])
		elseif data.type == "goto" then
			self:Whitespace"\t" self:Token(data.tokens["goto"]) self:Whitespace" " self:Expression(data.label)
		elseif data.type == "goto_label" then
			self:Whitespace"\t" self:Token(data.tokens["::left"]) self:Expression(data.label) self:Token(data.tokens["::right"])
		elseif data.type == "while" then
			self:Whitespace"\t"self:Token(data.tokens["while"])self:Expression(data.expr)self:Whitespace"?"self:Token(data.tokens["do"])self:Whitespace"\n"
				self:Whitespace"\t+"
					emit_block_with_continue(self, data)
				self:Whitespace"\t-"
			self:Whitespace"\t"self:Token(data.tokens["end"])
		elseif data.type == "repeat" then
			if data.has_continue then
				self:Whitespace"\t"self:Token(data.tokens["repeat"], "while true do --[[repeat]]")self:Whitespace"\n"
					self:Whitespace"\t+"
						emit_block_with_continue(self, data, true)
					self:Whitespace"\t-"
				self:Whitespace"\t" self:Token(data.tokens["until"],"")
				self:Emit"if--[[until]](" self:Expression(data.expression) self:Emit")then break end" self:Emit"::continue__oh::end"
			else
				self:Whitespace"\t"self:Token(data.tokens["repeat"])self:Whitespace"\n"
					self:Whitespace"\t+"
						emit_block_with_continue(self, data)
					self:Whitespace"\t-"
				self:Whitespace"\t" self:Token(data.tokens["until"])self:Expression(data.expression)
			end
		elseif data.type == "break" then
			self:Whitespace"\t"self:Token(data.tokens["break"])
		elseif data.type == "return" then
			self:Whitespace"\t"self:Whitespace("?")self:Token(data.tokens["return"])

			if data.expressions then
				self:CommaSeperated(data.expressions)
			end
		elseif data.type == "continue" then
			self:Whitespace"\t"self:Whitespace"?" self:Token(data["continue"], "goto continue__oh")
		elseif data.type == "for" then
			self:Whitespace"\t"self:Token(data.tokens["for"])
			if data.iloop then
				self:Expression(data.name)self:Whitespace" " self:Token(data.tokens["="]) self:Whitespace" "self:Expression(data.val)self:Token(data.tokens[",1"])self:Whitespace" "self:Expression(data.max)

				if data.incr then
					self:Token(data.tokens[",2"])self:Whitespace" "self:Expression(data.incr)
				end
			else
				self:Whitespace"?"self:CommaSeperated(data.names)self:Whitespace"?"self:Token(data.tokens["in"])self:Whitespace"?"self:CommaSeperated(data.expressions)
			end

			self:Whitespace"?"self:Token(data.tokens["do"])self:Whitespace"\n"
				self:Whitespace"\t+"
					emit_block_with_continue(self, data)
				self:Whitespace"\t-"
			self:Whitespace"\t"self:Token(data.tokens["end"])

		elseif data.type == "do" then
			self:Whitespace"\t"self:Token(data.tokens["do"])self:Whitespace"\n"
				self:Whitespace"\t+"
					self:Block(data.block)
				self:Whitespace"\t-"
			self:Whitespace"\t"self:Token(data.tokens["end"])
		elseif data.type == "function" then
			self:Function(data)
		elseif data.type == "assignment" then
			self:Whitespace"\t" if data.is_local then self:Token(data.tokens["local"])self:Whitespace" " end

			for i,v in ipairs(data.left) do
				if data.is_local then
					self:Token(v.value)
				else
					self:Expression(v)
				end
				if data.left[2] and i ~= #data.left then
					self:Token(v.tokens[","])self:Whitespace" "
				end
			end

			if data.right then
				self:Whitespace" "self:Token(data.tokens["="])self:Whitespace" "

				for i,v in ipairs(data.right) do
					self:Expression(v)
					if data.right[2] and i ~= #data.right then
						self:Token(v.tokens[","])self:Whitespace" "
					end
				end
			end
		elseif data.type == "expression" then
			self:Expression(data.value)
		elseif data.type == "call" then
			self:Whitespace"\t"self:Expression(data.value)
		elseif data.type == "end_of_statement" then
			self:Token(data.tokens[";"])
		elseif data.type == "end_of_file" then
			self:Token(data.tokens["eof"])
		else
			error("unhandled value: " .. data.type)
		end

		self:Whitespace"\n"
	end
end

function META:CommaSeperated(tbl)
	for i = 1, #tbl do
		self:Expression(tbl[i])
		if i ~= #tbl then
			self:Token(tbl[i].tokens[","])
			self:Whitespace(" ")
		end
	end
end

function oh.BuildLuaCode(tree, code)
	local self = {}

	self.level = 0
	self.out = {}
	self.i = 1
	self.code = code

	setmetatable(self, META)

	self:Block(tree)

	return table.concat(self.out)
end

if RELOAD then
	oh.Test()
end