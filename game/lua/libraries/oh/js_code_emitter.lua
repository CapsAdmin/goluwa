local oh = ... or _G.oh

local table_remove = table.remove
local ipairs = ipairs

local tbl = {
	["elseif"] = "else if",
	["and"] = "&&",
	["or"] = "||",
	["not"] = "!",
	[".."] = "+",
	["nil"] = "undefined"
}

local function TRANSLATE(val)
	return tbl[val] or val
end

local META = {}
META.__index = META

function META:Value2(v)
	local _ = self
	if v.type == "function" then
		_"function("_:CommaSeperated(v.arguments)_"){\n"
			_"\t+"
			self:Body(v.body)
			_"\t-"
		_"}"
	elseif v.type == "table" then


			local is_array = true
			for i,v in ipairs(v.children) do
				if v.indices then
					is_array = false
					break
				end
			end

			if is_array then
				_"[\n"
				_"\t+"
				for i,v in ipairs(v.children) do
					_"\t"_:Value(v.value)_",\n"
				end
				_"\t-"
				_"\t"_"]"
			else
				_"{\n"
				_"\t+"
				for i,v in ipairs(v.children) do
					_"\t"
					if v.type == "value" then
						_(i)_": "_:Value(v.value)
					elseif v.type == "assignment" then
						if v.expression_key then
							_"[("_:Value(v.indices[1])_")]"_": " _:Value(v.expressions[1])
						else
							_:Value(v.indices[1]) _": " _:Value(v.expressions[1])
						end
					end
					_",\n"
				end
				_"\t-"
				_"\t"_"}"
			end
	elseif v.type == "index_call_expression" then
		self:IndexExpression(v.value)
	elseif v.type == "unary" then
		self:Unary(v)
	elseif v.type == "operator" and oh.syntax.operator_translate[v.value] then
		_(oh.syntax.operator_translate[v.value])
	else
		_(v.value)
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
	_"("
	local func = oh.syntax.operator_function_transforms[v.value]
	if func then
		_(func) _"("_:Value(v.argument)_")"
	elseif oh.syntax.operator_translate[v.value] then
		_(oh.syntax.operator_translate[v.value])_:EmitSpaceIf()_:Value(v.argument)
	elseif oh.syntax.keywords[v.value] then
		_(v.value)_:EmitSpaceIf()_:Value(v.argument)
	else
		_(v.value)_:Value(v.argument)
	end
	_")"
end

function META:Expression(v)
	local _ = self

	local func = oh.syntax.operator_function_transforms[v.value]

	if func and v.type ~= "unary" then
		_:EmitSpaceIf()
		_(func) if v.left then _"(" _:Expression(v.left) end _", " if v.right then _:Expression(v.right) _")" end
		return
	end

	if v.left then
		_"("
		_:Expression(v.left)
		_" "
	end

	_:EmitSpaceIf()
	_:Value2(v)

	if v.right then
		_" "
		_:Expression(v.right)
		_")"
	end
end

function META:GetPrevCharType()
	return self.out[self.i - 1] and self.out[self.i - 1] and oh.syntax.char_types[self.out[self.i - 1]:sub(1, 1)]
end

function META:EmitSpaceIf(typ)
	if self:GetPrevCharType() == "letter" or self:GetPrevCharType() == "number" then
		self:Emit(" ")
	end
end

function META:IndexExpression(data, stop_i)
	local _ = self

	local self_call = false

	for i,v in ipairs(data) do
		if stop_i == i then break end

		if v.type == "operator" then
			_"(" _:Expression(v) _")"
		elseif v.type == "index" then
			if v.operator.value == ":" then
				_(".")_(v.value.value)
				self_call = i
			else
				_(v.operator.value)_(v.value.value)
			end
		elseif v.type == "index_expression" then
			_"[("_:Value(v.value)_")]"
		elseif v.type == "call" then
			if self_call then
				_"("
				self:IndexExpression(data, self_call)
				if v.arguments[1] then
					_", "
					_:CommaSeperated(v.arguments)
				end
				_")"
			else
				_"("_:CommaSeperated(v.arguments)_")"
			end
		else
			_"("_:Value(v)_")"
		end
	end
	return self_call
end

function META:Body(tree)
	local _ = self
	for __, data in ipairs(tree) do
		if data.type == "if" then
			for i,v in ipairs(data.statements) do
				_"\t"_(v.token.value) if v.expr then _"(" _:Expression(v.expr) _")" end _"{" _"\n"
					_"\t+"
						self:Body(v.body)
					_"\t-"
				_"\t" _"} "
			end
		elseif data.type == "goto" then
			_"\t" _"continue " _:Value(data.label)
		elseif data.type == "goto_label" then
			_"\t" _:Value(data.label)_":"
		elseif data.type == "while" then
			_"\t"_"while("_:Expression(data.expr)_:EmitSpaceIf()_"){"_"\n"
				_"\t+"
					self:Body(data.body)
				_"\t-"
			_"\t"_"}"
		elseif data.type == "repeat" then
			_"\t"_"repeat"_"\n"
				_"\t+"
					self:Body(data.body)
				_"\t-"
			_"\t" _"until"_:Expression(data.expr)
		elseif data.type == "break" then
			_"\t"_"break"
		elseif data.type == "return" then
			if data.expressions then
				_"\t"_"return"_:CommaSeperated(data.expressions)
			else
				_"\t"_"return"
			end
		elseif data.type == "continue" then
			_"\t"_"continue"
		elseif data.type == "for" then
			if data.iloop then
				_"\t"_"for(let "_:Value(data.name)_" = "_:Expression(data.val)_"; " _:Value(data.name) _" < " _:Expression(data.max)

				if data.incr then
					_"; " _:Value(data.name) _" = " _:Value(data.name) _" + " _:Expression(data.incr)
				else
					_"; " _:Value(data.name) _"++"
				end

				_")"

				_"{"_"\n"
			else
				_"\t"_"for"_:EmitSpaceIf()_:CommaSeperated(data.names)_:EmitSpaceIf()_"in"_:CommaSeperated(data.expressions)_:EmitSpaceIf()_"do"_"\n"
			end

			_"\t+"

				if data.has_continue and data.body[#data.body] and data.body[#data.body].type == "return" then
					local ret = table_remove(data.body)
					_:Body(data.body)
					_"\t"_"{"

					if ret.expressions then
						_"return"_:CommaSeperated(ret.expressions)
					else
						_"return"
					end
					_:EmitSpaceIf()
					_"}"
					_"\n"
				else
					_:Body(data.body)
				end

				if data.has_continue then
					_"\t"_"continue\n"
				end
			_"\t-"

			_"\t"_"}"

		elseif data.type == "do" then
			_"\t"_"(function() {\n"
				_"\t+"
					_:Body(data.body)
				_"\t-"
			_"\t"_"})();"
		elseif data.type == "function" then
			if data.is_local then
				_"\t" _:Value(data.index_expression)_" = function ("_:CommaSeperated(data.arguments)_") {"_"\n"
					_"\t+"
						self:Body(data.body)
					_"\t-"
				_"\t"_"}"
			else
				_"\t"local self_call = _:IndexExpression(data.index_expression)_" = function("
				if self_call then
					_"self"
					if data.arguments[1] then
						_", "
					end
				end
				_:CommaSeperated(data.arguments)_") {"_"\n"
					_"\t+"
						self:Body(data.body)
					_"\t-"
				_"\t"_"}"
			end
		elseif data.type == "assignment" then
			for i,v in ipairs(data.left) do
				_"\t" if data.is_local then _"let " end
				_:Value(v)
				if data.right and data.right[i] then
					_" = " _:Expression(data.right[i])
				end
				_"\n"
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
	self:EmitSpaceIf()
	for i = 1, #tbl do
		self:Value(tbl[i])
		if i ~= #tbl then
			self:Emit(", ")
		end
	end
end

function META:Emit(str)
	self.out[self.i] = TRANSLATE(str)
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

function oh.BuildJSCode(tree)
	local self = {}

	self.level = 0
	self.out = {}
	self.i = 1

	setmetatable(self, META)

	self:Body(tree)

	return table.concat(self.out)
end

if RELOAD then
	local path = "/home/caps/goluwa/capsadmin/lua/syntax_test.lua"
	local code = vfs.Read(path)

	local code = [===[
		local print = console.log
		local lol = {
			bar = function(self, a)
				console.log(self .. " " .. a)
			end
		}
		lol.foo = "bar"
		function lol:test(a,b,c)
			for i = 1, b do
				if i == 3 then
					continue
				end
				console.log(i)
			end

			console.log(self.foo)

			self.asdf = true
		end

		lol:test(1,5)

		lol:bar(888)

		console.log(lol.asdf)

		local a,b,c = 1,2,3
		local arr = {1,2,true,4}

		for i = 0, 4 do
			print(arr[i] .. " array")
		end

		arr.foo = true

		print(arr.foo, "?!?!?!")

		while true do break end

		if nil then print ("true") else print ("false") end
		if 0 then print ("true") else print ("false") end
		if "" then print ("true") else print ("false") end
		if false then print ("true") else print ("false") end
	]===]


	local tokens = oh.Tokenize(code, path)
	local ast = tokens:Block()
	local output = oh.BuildJSCode(ast)

	print(output)
	vfs.Write("test.js", output)
	os.execute("node " .. R"test.js")

	--local code = oh.Transpile(vfs.Read"main.lua")
	--print(loadstring(code))
end