local oh = ... or _G.oh

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
	elseif v.type == "index_call_expression" then
		self:IndexExpression(v.value)
	elseif v.type == "unary" then
		if oh.syntax.keywords[v.value] then
			_" "_(v.value)_" "_:Expression(v.argument)
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

	_"(" if v.left then _:Expression(v.left) end _:Value2(v) if v.right then _:Expression(v.right) end _")"
end

function META:IndexExpression(data)
	local _ = self

	for i,v in ipairs(data) do
		if v.type == "index" then
			_(v.operator.value)_(v.value.value)
		elseif v.type == "index_expression" then
			_"["_:Value(v.value)_"]"
		elseif v.type == "call" then
			_"("_:arguments(v.arguments)_")"
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
		elseif data.type == "while" then
			_"\t"_"while "_:Expression(data.expr)_" do"_"\n"
				_"\t+"
					self:Body(data.body)
				_"\t-"
			_"\t"_"end"
		elseif data.type == "break" then
			_"\t"_"break"
		elseif data.type == "return" then
			if data.expressions then
				_"\t"_"return "_:arguments(data.expressions)
			else
				_"\t"_"return "
			end
		elseif data.type == "for" then
			if data.iloop then
				_"\t"_"for "_:Expression(data.name)_" = "_:Expression(data.val)_", "_:Expression(data.max)_" do"_"\n"
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
		elseif data.type == "function" then
			local call = table.remove(data.expression.value, #data.expression.value)


			_"\t"_("local ", not not data.is_local)_"function"_" "_:IndexExpression(data.expression.value)
			_"("

			local arg_line = {}

			for i,v in ipairs(call.arguments) do

				if v.left then
					local cur = v.left
					while cur.left do
						cur = cur.left
					end
					_(cur.value[1].value.value)
					table.insert(arg_line, cur.value[1].value)
				else
					_:Value(v)
					table.insert(arg_line, v)
				end


				if i ~= #call.arguments then
					_", "
				end
			end

			_")"

			for i,v in ipairs(call.arguments) do
				_:Value(arg_line[i]) _" = " _:Expression(v) _";"
			end

			_"\n"
				_"\t+"
					self:Body(data.body)
				_"\t-"
			_"\t"_"end"
		elseif data.type == "assignment" then
			_"\t"_("local ", not not data.is_local)

			for i,v in ipairs(data.left) do
				_:Value(v)
				if data.left[2] and i ~= #data.left then
					_", "
				end
			end

			_" = "

			for i,v in ipairs(data.right) do
				_:Expression(v)
				if data.right[2] and i ~= #data.right then
					_", "
				end
			end
		elseif data.type == "call" then
			_"\t"_:Expression(data.value)
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
	--log(str)
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

if RELOAD then
	oh.Test()
end