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
	--log(str)
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

function META:Value2(v)
	local _ = self

	if v.type == "function" then
		if v["("] then _:Token(v["("]) else _:Emit("(") end
		_:Token(v["function"])_:Token(v["func("])_:CommaSeperated(v.arguments)_:Token(v["func)"])_:W"\n"
			_:W"\t+"
			self:Block(v.body)
			_:W"\t-"
		_:W"\t" _:Token(v["end"])
		if v[")"] then _:Token(v[")"]) else _:Emit(")") end
	elseif v.type == "table" then
		if v["("] then _:Token(v["("]) else _:Emit("(") end
		if not v.children[1] then
			_:Token(v["{"])_:Token(v["}"])
		else
			_:Token(v["{"])_:W"\n"
				_:W"\t+"
				for i,v in ipairs(v.children) do
					_:W"\t"
					if v.type == "value" then
						if v["("] then _:Token(v["("]) else _:Emit("(") end
						_:Value(v.value)
						if v[")"] then _:Token(v[")"]) else _:Emit(")") end
					elseif v.type == "assignment" then
						if v.expression_key then
							_:Token(v["["])_:W"("_:Value(v.indices[1])_:W")" _:Token(v["]"]) _:Token(v["="]) _:Value(v.expressions[1])
						else
							_:Value(v.indices[1]) _:Token(v["="]) _:Value(v.expressions[1])
						end
					end
					if v[","] then
						_:Token(v[","])
					else
						_:W","
					end
					_:W"\n"
				end
				_:W"\t-"
			_:W"\t"_:Token(v["}"])
		end
		if v[")"] then _:Token(v[")"]) else _:Emit(")") end
	elseif v.type == "index_call_expression" then
		self:IndexCallExpression(v.value)
	elseif v.type == "unary" then
		self:Unary(v)
	elseif v.type == "operator" and oh.syntax.operator_translate[v.value] then
		_:Token(v, oh.syntax.operator_translate[v.value])
	else
		_:Token(v)
	end
end

function META:Value(v)
	local _ = self
	if v.type == "operator" then
		self:Expression(v)
	elseif v.type == "unary" then
		self:Unary(v)
	else
		self:Value2(v)
	end
	self:Calls(v)
end

function META:Unary(v)
	local _ = self

	if oh.syntax.operator_function_transforms[v.value.value] then
		_:W("?", true)_:E(oh.syntax.operator_function_transforms[v.value.value]) _:E"("_:Value(v.argument)_:E")"
	elseif oh.syntax.operator_translate[v.value.value] then
		_:Token(v.value, "")_:W("?", true)_:Emit(oh.syntax.operator_translate[v.value.value])_:W("?", true)_:Value(v.argument)
	else
		if oh.syntax.keywords[v.value.value] then
			_:Token(v.value, "")_:W("?", true)_:Emit(v.value.value)_:Value(v.argument)
		else
			if v["("] and v.value.start > v["("].start then
				if v["("] then _:Token(v["("]) end
				_:Token(v.value)
			else
				_:Token(v.value)
				if v["("] then _:Token(v["("]) end
			end

			_:Value(v.argument)
			if v[")"] then _:Token(v[")"]) end
		end
	end
end

function META:Expression(v)
	local _ = self

	local func = v.value and oh.syntax.operator_function_transforms[v.value.value]

	if func and v.type ~= "unary" then
		_:W("?", true)_:E(func) if v.left then _:E"(" _:Expression(v.left) end _:E"," if v.right then _:Expression(v.right) _:E")" end
		return
	end

	--[[if v.type == "operator" and v.value.value == "." then
		if not v["("] then _:E"(" else _:Token(v["("]) end
		if v.left then _:Expression(v.left) end
		if not v[")"] then _:E")" else _:Token(v[")"]) end

		if v.right.type == "letter" then
			_:Token(v.right, "") _:E"[\"" _:Emit(v.right.value) _:E"\"]"
		elseif v.right.type == "number" then
			_:Token(v.right, "") _:E"[" _:Emit(v.right.value) _:E"]"
		else
			_:Expression(v.right)
		end
	else]]
	if v["("] then _:Token(v["("]) end

	if v.left then
		--if not v["("] then _:E"(" end
		_:Expression(v.left)
	end

	_:W"?"

	if v.type == "operator" then
		if oh.syntax.operator_translate[v.value.value] then
			_:Token(v.value, oh.syntax.operator_translate[v.value.value])
		else
			_:Token(v.value)
		end
	else
		_:Value2(v)
	end

	if v.right then
		_:Expression(v.right)
		--if not v[")"] then _:E")" end
	end

	if v[")"] then _:Token(v[")"]) end
	--end

	self:Calls(v)
end

function META:Calls(v)
	if v.calls then
		local _ = self
		for i,v in ipairs(v.calls) do
			if v.type == "index_expression" then
				_:Token(v["["])
			end

			if v.type == "operator" then
				 _:Expression(v)
			elseif v.type == "index_expression" then
				_:W"("_:Value(v.value)_:W")"
			elseif v.type == "call" then
				if v["call("] then _:Token(v["call("]) end
				_:CommaSeperated(v.arguments)
				if v["call)"] then _:Token(v["call)"]) end
			else
				if v["("] then _:Token(v["("]) else _:Emit("(") end
				_:Value(v)
				if v[")"] then _:Token(v[")"]) else _:Emit(")") end
			end

			if v.type == "index_expression" then
				_:Token(v["]"])
			end
		end
	end
end

function META:GetPrevCharType()
	local prev = self.out[self.i - 1]
	return prev and oh.syntax.char_types[prev:sub(-1)]
end

function META:IndexCallExpression(data)
	local _ = self
	for i,v in ipairs(data) do
		if v.type == "index_expression" then
			_:Token(v["["])
		end

		if v.type == "operator" then
			 _:Expression(v)
		elseif v.type == "index" then
			_:Token(v.operator)_:Token(v.value)
		elseif v.type == "index_expression" then
			_:W"("_:Value(v.value)_:W")"
		elseif v.type == "call" then
			if v["call("] then _:Token(v["call("]) end
			_:CommaSeperated(v.arguments)
			if v["call)"] then _:Token(v["call)"]) end
		else
			if v["("] then _:Token(v["("]) else _:Emit("(") end
			_:Value(v)
			if v[")"] then _:Token(v[")"]) else _:Emit(")") end
		end

		if v.type == "index_expression" then
			_:Token(v["]"])
		end
	end
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

	if data.has_continue and data.body[#data.body] and data.body[#data.body].type == "return" then
		local ret = table_remove(data.body)
		_:Block(data.body)

		_:W"\t"_:Token(ret["return"], "")_:E"do return"_:W("?", true)
		if ret.expressions then
			_:CommaSeperated(ret.expressions)
		end
		_:W("?", true)
		_:E("end")
	else
		_:Block(data.body)
	end

	if not repeat_expression and data.has_continue then
		_:W"\t"_:E"::continue__oh::"
	end
end

function META:Block(tree)
	local _ = self
	for __, data in ipairs(tree) do
		if data.type == "if" then
			for i,v in ipairs(data.statements) do
				_:W"\t"_:Token(v["if/else/elseif"]) if v.expr then _:Expression(v.expr) _:W" " _:Token(v["then"]) end _:W"\n"
					_:W"\t+"
						self:Block(v.body)
					_:W"\t-"
			end
			_:W"\t" _:Token(data["end"])
		elseif data.type == "goto" then
			_:W"\t" _:Token(data["goto"]) _:W" " _:Value(data.label)
		elseif data.type == "goto_label" then
			_:W"\t" _:Token(data.left) _:Value(data.label) _:Token(data.right)
		elseif data.type == "while" then
			_:W"\t"_:Token(data["while"])_:Expression(data.expr)_:W"?"_:Token(data["do"])_:W"\n"
				_:W"\t+"
					emit_block_with_continue(self, data)
				_:W"\t-"
			_:W"\t"_:Token(data["end"])
		elseif data.type == "repeat" then
			if data.has_continue then
				_:W"\t"_:Token(data["repeat"], "while true do --[[repeat]]")_:W"\n"
					_:W"\t+"
						emit_block_with_continue(self, data, true)
					_:W"\t-"
				_:W"\t" _:Token(data["until"],"")
				_:E"if--[[until]](" _:Expression(data.expr) _:E")then break end" _:E"::continue__oh::end"
			else
				_:W"\t"_:Token(data["repeat"])_:W"\n"
					_:W"\t+"
						emit_block_with_continue(self, data)
					_:W"\t-"
				_:W"\t" _:Token(data["until"])_:Expression(data.expr)
			end
		elseif data.type == "break" then
			_:W"\t"_:Token(data["break"])
		elseif data.type == "return" then
			_:W"\t"_:W("?")_:Token(data["return"])

			if data.expressions then
				_:CommaSeperated(data.expressions)
			end
		elseif data.type == "continue" then
			_:W"\t"_:W"?" _:Token(data["continue"], "goto continue__oh")
		elseif data.type == "for" then
			_:W"\t"_:Token(data["for"])
			if data.iloop then
				_:Expression(data.name)_:W" " _:Token(data["="]) _:W" "_:Expression(data.val)_:Token(data[",1"])_:W" "_:Expression(data.max)

				if data.incr then
					_:Token(data[",2"])_:W" "_:Expression(data.incr)
				end
			else
				_:W"?"_:CommaSeperated(data.names)_:W"?"_:Token(data["in"])_:W"?"_:CommaSeperated(data.expressions)
			end

			_:W"?"_:Token(data["do"])_:W"\n"
				_:W"\t+"
					emit_block_with_continue(self, data)
				_:W"\t-"
			_:W"\t"_:Token(data["end"])

		elseif data.type == "do" then
			_:W"\t"_:Token(data["do"])_:W"\n"
				_:W"\t+"
					_:Block(data.body)
				_:W"\t-"
			_:W"\t"_:Token(data["end"])
		elseif data.type == "function" then
			if data.is_local then
				_:W"\t"_:Token(data["local"])_:W" "_:Token(data["function"])_:W" "_:Token(data.index_expression)
			else
				_:W"\t"_:Token(data["function"])_:W" " _:Expression(data.index_expression)
			end
			_:Token(data["func("])_:CommaSeperated(data.arguments)_:Token(data["func)"])_:W"\n"
				_:W"\t+"
					self:Block(data.body)
				_:W"\t-"
			_:W"\t"_:Token(data["end"])
		elseif data.type == "assignment" then
			_:W"\t" if data.is_local then _:Token(data["local"])_:W" " end

			for i,v in ipairs(data.left) do
				if data.is_local then
					_:Token(v)
				else
					_:Expression(v)
				end
				if data.left[2] and i ~= #data.left then
					_:Token(v[","])_:W" "
				end
			end

			if data.right then
				_:W" "_:Token(data["="])_:W" "

				for i,v in ipairs(data.right) do
					_:Expression(v)
					if data.right[2] and i ~= #data.right then
						_:Token(v[","])_:W" "
					end
				end
			end
		elseif data.type == "index_call_expression" then
			self:IndexCallExpression(data.value)
		elseif data.type == "expression" then
			self:Expression(data.value)
		elseif data.type == "call" then
			_:W"\t"_:Expression(data.value)
		elseif data.type == "end_of_statement" then
			_:Token(data.value)
		else
			error("unhandled value: " .. data.type)
		end

		_:W"\n"
	end
end

function META:CommaSeperated(tbl)
	--for i,v2 in ipairs(tbl) do
	for i = 1, #tbl do
		self:Expression(tbl[i])
		if i ~= #tbl then
			self:Token(tbl[i][","])
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