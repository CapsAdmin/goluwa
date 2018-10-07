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

META.W = META.Whitespace
META.E = META.Emit

function META:Value(v)
	local _ = self

	if v.type == "operator" then
		if oh.syntax.operator_translate[v.value] then
			_:Token(v, oh.syntax.operator_translate[v.value])
		else
			_:Token(v.tokens.operator)
		end
	else
		if v.tokens["("] then _:Token(v.tokens["("]) end

		if v.type == "function" then
			_:Token(v.tokens["function"])_:Token(v.tokens["func("])_:CommaSeperated(v.arguments)_:Token(v.tokens["func)"])_:W"\n"
				_:W"\t+"
				self:Block(v.block)
				_:W"\t-"
			_:W"\t" _:Token(v.tokens["end"])
		elseif v.type == "table" then
			if not v.children[1] then
				_:Token(v.tokens["{"])_:Token(v.tokens["}"])
			else
				_:Token(v.tokens["{"])_:W"\n"
					_:W"\t+"
					for i,v in ipairs(v.children) do
						_:W"\t"
						if v.type == "value" then
							_:Expression(v.value)
						elseif v.type == "assignment" then
							if v.expression_key then
								_:Token(v.tokens["["])_:W"("_:Expression(v.key)_:W")" _:Token(v.tokens["]"]) _:Token(v.tokens["="]) _:Expression(v.expression)
							else
								_:Value(v.key) _:Token(v.tokens["="]) _:Expression(v.expression)
							end
						end
						if v.tokens[","] then
							_:Token(v.tokens[","])
						else
							_:W","
						end
						_:W"\n"
					end
					_:W"\t-"
				_:W"\t"_:Token(v.tokens["}"])
			end
		elseif v.type == "unary" then
			self:Unary(v)
		elseif v.type == "value" then
			_:Token(v.value)
		else
			error("unhandled token type " .. v.type)
		end

		if v.tokens[")"] then _:Token(v.tokens[")"]) end
	end
end

function META:Unary(v)
	local _ = self

	if oh.syntax.operator_function_transforms[v.operator] then
		_:W("?", true)_:E(oh.syntax.operator_function_transforms[v.operator]) _:E"("_:Value(v.expression)_:E")"
	elseif oh.syntax.operator_translate[v.operator] then
		_:Token(v.tokens.operator, "")_:W("?", true)_:Emit(oh.syntax.operator_translate[v.operator])_:W("?", true)_:Value(v.expression)
	else
		if oh.syntax.keywords[v.operator] then
			_:Token(v.tokens.operator, "")_:W("?", true)_:Emit(v.operator)_:Expression(v.expression)
		else
			if v.tokens["("] and v.tokens.operator.start > v.tokens["("].start then
				if v.tokens["("] then _:Token(v.tokens["("]) end
				_:Token(v.tokens.operator)
			else
				_:Token(v.tokens.operator)
				if v.tokens["("] then _:Token(v.tokens["("]) end
			end


			_:Expression(v.expression)
			if v.tokens[")"] then _:Token(v.tokens[")"]) end
		end
	end
end

function META:Expression(v)
	local _ = self

	if v.left then
		if v.tokens["("] then _:Token(v.tokens["("]) end
		_:Expression(v.left)
	end

	_:Value(v)

	if v.right then
		_:Expression(v.right)
		if v.tokens[")"] then _:Token(v.tokens[")"]) end
	end

	if v.calls then
		local _ = self
		for i,v in ipairs(v.calls) do
			if v.type == "index_expression" then
				_:Token(v.tokens["["])
			end

			if v.type == "operator" then
				 _:Expression(v)
			elseif v.type == "index_expression" then
				_:W"("_:Expression(v.value)_:W")"
			elseif v.type == "call" then
				if v.tokens["call("] then _:Token(v.tokens["call("]) end
				_:CommaSeperated(v.arguments)
				if v.tokens["call)"] then _:Token(v.tokens["call)"]) end
			else
				if v.tokens["("] then _:Token(v.tokens["("]) end
				_:Value(v)
				if v.tokens[")"] then _:Token(v.tokens[")"]) end
			end

			if v.type == "index_expression" then
				_:Token(v.tokens["]"])
			end
		end
	end
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


local function emit_block_with_continue(self, data, repeat_expression)
	local _ = self

	if data.has_continue and data.block[#data.block] and data.block[#data.block].type == "return" then
		local ret = table_remove(data.block)
		_:Block(data.block)

		_:W"\t"_:Token(ret["return"], "")_:E"do return"_:W("?", true)
		if ret.expressions then
			_:CommaSeperated(ret.expressions)
		end
		_:W("?", true)
		_:E("end")
	else
		_:Block(data.block)
	end

	if not repeat_expression and data.has_continue then
		_:W"\t"_:E"::continue__oh::"
	end
end

function META:Block(tree)
	local _ = self
	for __, data in ipairs(tree) do
		if data.type == "if" then
			for i,v in ipairs(data.clauses) do
				_:W"\t"_:Token(v.tokens["if/else/elseif"]) if v.expr then _:Expression(v.expr) _:W" " _:Token(v.tokens["then"]) end _:W"\n"
					_:W"\t+"
						self:Block(v.block)
					_:W"\t-"
			end
			_:W"\t" _:Token(data.tokens["end"])
		elseif data.type == "goto" then
			_:W"\t" _:Token(data.tokens["goto"]) _:W" " _:Value(data.label)
		elseif data.type == "goto_label" then
			_:W"\t" _:Token(data.tokens["::left"]) _:Value(data.label) _:Token(data.tokens["::right"])
		elseif data.type == "while" then
			_:W"\t"_:Token(data.tokens["while"])_:Expression(data.expr)_:W"?"_:Token(data.tokens["do"])_:W"\n"
				_:W"\t+"
					emit_block_with_continue(self, data)
				_:W"\t-"
			_:W"\t"_:Token(data.tokens["end"])
		elseif data.type == "repeat" then
			if data.has_continue then
				_:W"\t"_:Token(data.tokens["repeat"], "while true do --[[repeat]]")_:W"\n"
					_:W"\t+"
						emit_block_with_continue(self, data, true)
					_:W"\t-"
				_:W"\t" _:Token(data.tokens["until"],"")
				_:E"if--[[until]](" _:Expression(data.expression) _:E")then break end" _:E"::continue__oh::end"
			else
				_:W"\t"_:Token(data.tokens["repeat"])_:W"\n"
					_:W"\t+"
						emit_block_with_continue(self, data)
					_:W"\t-"
				_:W"\t" _:Token(data.tokens["until"])_:Expression(data.expression)
			end
		elseif data.type == "break" then
			_:W"\t"_:Token(data.tokens["break"])
		elseif data.type == "return" then
			_:W"\t"_:W("?")_:Token(data.tokens["return"])

			if data.expressions then
				_:CommaSeperated(data.expressions)
			end
		elseif data.type == "continue" then
			_:W"\t"_:W"?" _:Token(data["continue"], "goto continue__oh")
		elseif data.type == "for" then
			_:W"\t"_:Token(data.tokens["for"])
			if data.iloop then
				_:Expression(data.name)_:W" " _:Token(data.tokens["="]) _:W" "_:Expression(data.val)_:Token(data.tokens[",1"])_:W" "_:Expression(data.max)

				if data.incr then
					_:Token(data.tokens[",2"])_:W" "_:Expression(data.incr)
				end
			else
				_:W"?"_:CommaSeperated(data.names)_:W"?"_:Token(data.tokens["in"])_:W"?"_:CommaSeperated(data.expressions)
			end

			_:W"?"_:Token(data.tokens["do"])_:W"\n"
				_:W"\t+"
					emit_block_with_continue(self, data)
				_:W"\t-"
			_:W"\t"_:Token(data.tokens["end"])

		elseif data.type == "do" then
			_:W"\t"_:Token(data.tokens["do"])_:W"\n"
				_:W"\t+"
					_:Block(data.block)
				_:W"\t-"
			_:W"\t"_:Token(data.tokens["end"])
		elseif data.type == "function" then
			if data.is_local then
				_:W"\t"_:Token(data.tokens["local"])_:W" "_:Token(data.tokens["function"])_:W" "_:Token(data.index_expression)
			else
				_:W"\t"_:Token(data.tokens["function"])_:W" " _:Expression(data.index_expression)
			end
			_:Token(data.tokens["func("])_:CommaSeperated(data.arguments)_:Token(data.tokens["func)"])_:W"\n"
				_:W"\t+"
					self:Block(data.block)
				_:W"\t-"
			_:W"\t"_:Token(data.tokens["end"])
		elseif data.type == "assignment" then
			_:W"\t" if data.is_local then _:Token(data.tokens["local"])_:W" " end

			for i,v in ipairs(data.left) do
				if data.is_local then
					_:Token(v.value)
				else
					_:Expression(v)
				end
				if data.left[2] and i ~= #data.left then
					_:Token(v.tokens[","])_:W" "
				end
			end

			if data.right then
				_:W" "_:Token(data.tokens["="])_:W" "

				for i,v in ipairs(data.right) do
					_:Expression(v)
					if data.right[2] and i ~= #data.right then
						_:Token(v.tokens[","])_:W" "
					end
				end
			end
		elseif data.type == "expression" then
			self:Expression(data.value)
		elseif data.type == "call" then
			_:W"\t"_:Expression(data.value)
		elseif data.type == "end_of_statement" then
			_:Token(data.tokens[";"])
		elseif data.type == "end_of_file" then
			_:Token(data.tokens["eof"])
		else
			error("unhandled value: " .. data.type)
		end

		_:W"\n"
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