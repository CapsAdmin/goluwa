local oh = ... or _G.oh

local table_remove = table.remove
local ipairs = ipairs

local META = {}
META.__index = META

function META:Value2(v)
	local _ = self
	if v.type == "function" then
		_"(function("_:CommaSeperated(v.arguments)_")\n"
			_"\t+"
			self:Body(v.body)
			_"\t-"
		_"\nend)"
	elseif v.type == "table" then
		_"{\n"
			_"\t+"
			for i,v in ipairs(v.children) do
				_"\t"
				if v.type == "value" then
					_:Value(v.value)
				elseif v.type == "assignment" then
					if v.expression_key then
						_"[ "_:Value(v.indices[1])_" ] "_" = " _:Value(v.expressions[1])
					else
						_:Value(v.indices[1]) _" = " _:Value(v.expressions[1])
					end
				end
				_",\n"
			end
			_"\t-"
		_"\t"_"}"
	elseif v.type == "index_call_expression" then
		self:IndexExpression(v.value)
	elseif v.type == "unary" then
		self:Unary(v)
	else
		if v.type == "operator" and oh.syntax.operator_translate[v.value] then
			_" "_(oh.syntax.operator_translate[v.value])_" "
		elseif oh.syntax.keywords[v.value] or v.type == "number" then
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
		self:Unary(v)
	else
		self:Value2(v)
	end
end

function META:Unary(v)
	local _ = self

	local func = oh.syntax.operator_function_transforms[v.value]
	if func then
		_" "_(func) _"("_:Value(v.argument)_") "
	elseif oh.syntax.operator_translate[v.value] then
		_" "_(oh.syntax.operator_translate[v.value])_" "_:Value(v.argument)
	elseif oh.syntax.keywords[v.value] then
		_" "_(v.value)_" "_:Value(v.argument)
	else
		_" "_(v.value)_:Value(v.argument)
	end
end

function META:Expression(v)
	local _ = self

	local func = oh.syntax.operator_function_transforms[v.value]
	if func and v.type ~= "unary" then
		_(func) if v.left then _"(" _:Expression(v.left) end _" , " if v.right then _:Expression(v.right) _")" end
		return
	end

	if v.left then _"(" _:Expression(v.left) end _:Value2(v) if v.right then _:Expression(v.right) _")" end
end

function META:IndexExpression(data)
	local _ = self

	for i,v in ipairs(data) do
		if v.type == "operator" then
			_"(" _:Expression(v) _")"
		elseif v.type == "index" then
			_(v.operator.value)_(v.value.value)
		elseif v.type == "index_expression" then
			_"[ "_:Value(v.value)_" ]"
		elseif v.type == "call" then
			_"("_:CommaSeperated(v.arguments)_")"
		else
			_"("_:Value(v)_")"
		end
	end
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
		elseif data.type == "goto" then
			_"\t" _"goto " _:Value(data.label)
		elseif data.type == "goto_label" then
			_"\t" _"::" _:Value(data.label) _"::"
		elseif data.type == "while" then
			_"\t"_"while "_:Expression(data.expr)_" do"_"\n"
				_"\t+"
					self:Body(data.body)
				_"\t-"
			_"\t"_"end"
		elseif data.type == "repeat" then
			_"\t"_"repeat"_"\n"
				_"\t+"
					self:Body(data.body)
				_"\t-"
			_"\t" _"until "_:Expression(data.expr)
		elseif data.type == "break" then
			_"\t"_"break"
		elseif data.type == "return" then
			if data.expressions then
				_"\t"_"return "_:CommaSeperated(data.expressions)
			else
				_"\t"_"return "
			end
		elseif data.type == "continue" then
			_"\t"_"goto __continue__"
		elseif data.type == "for" then
			if data.iloop then
				_"\t"_"for "_:Expression(data.name)_" = "_:Expression(data.val)_", "_:Expression(data.max)

				if data.incr then
					_", "_:Expression(data.incr)
				end

				_" do"_"\n"
			else
				_"\t"_"for "_:CommaSeperated(data.names)_" in "_:CommaSeperated(data.expressions)_" do"_"\n"
			end

			_"\t+"

				if data.has_continue and data.body[#data.body] and data.body[#data.body].type == "return" then
					local ret = table_remove(data.body)
					_:Body(data.body)
					_"\t"_"do"

					if ret.expressions then
						_" return "_:CommaSeperated(ret.expressions)
					else
						_" return "
					end
					_" end"
					_"\n"
				else
					_:Body(data.body)
				end

				if data.has_continue then
					_"\t"_"::__continue__::\n"
				end
			_"\t-"

			_"\t"_"end"

		elseif data.type == "do" then
			_"\t"_"do\n"
				_"\t+"
					_:Body(data.body)
				_"\t-"
			_"\t"_"end"
		elseif data.type == "function" then
			if data.is_local then
				_"\t"_"local function " _:Value(data.index_expression)_"("_:CommaSeperated(data.arguments)_")"_"\n"
					_"\t+"
						self:Body(data.body)
					_"\t-"
				_"\t"_"end"
			else
				_"\t"_"function " _:IndexExpression(data.index_expression)_"("_:CommaSeperated(data.arguments)_")"_"\n"
					_"\t+"
						self:Body(data.body)
					_"\t-"
				_"\t"_"end"
			end
		elseif data.type == "assignment" then
			_"\t" if data.is_local then _("local ") end

			for i,v in ipairs(data.left) do
				_:Value(v)
				if data.left[2] and i ~= #data.left then
					_", "
				end
			end

			if data.right then
				_" = "

				for i,v in ipairs(data.right) do
					_:Expression(v)
					if data.right[2] and i ~= #data.right then
						_", "
					end
				end
			end
		elseif data.type == "index_call_expression" then
			self:IndexExpression(data.value)
		elseif data.type == "call" then
			if data.value then
				_"\t"_:Expression(data.value)
			end
		end

		_"\n"
	end
end

META.__call = function(self, str, b)
	if str == "\t" then
		self:EmitIndent()
	elseif str == "\t+" then
		self:Indent()
	elseif str == "\t-" then
		self:Outdent()
	else
		self:Emit(str)
	end
end

function META:CommaSeperated(tbl)
	--for i,v2 in ipairs(tbl) do
	for i = 1, #tbl do
		self:Value(tbl[i])
		if i ~= #tbl then
			self:Emit(", ")
		end
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

function oh.DumpAST(tree)
	local self = {}

	self.level = 0
	self.out = {}
	self.i = 1

	setmetatable(self, META)

	self:Body(tree)

	return table.concat(self.out)
end