local tostring = tostring
local ipairs = ipairs
local table = _G.table
local LString = require("nattlua.types.string").LString
local String = require("nattlua.types.string").String
local Any = require("nattlua.types.any").Any
local Tuple = require("nattlua.types.tuple").Tuple
local Union = require("nattlua.types.union").Union
local True = require("nattlua.types.symbol").True
local Boolean = require("nattlua.types.union").Boolean
local Symbol = require("nattlua.types.symbol").Symbol
local False = require("nattlua.types.symbol").False
local Nil = require("nattlua.types.symbol").Nil
local Number = require("nattlua.types.number").Number
local type_errors = require("nattlua.types.error_messages")

local function metatable_function(self, node, meta_method, l, r)
	meta_method = LString(meta_method)

	if r:GetMetaTable() or l:GetMetaTable() then
		local func = (
				l:GetMetaTable() and
				l:GetMetaTable():Get(meta_method)
			) or
			(
				r:GetMetaTable() and
				r:GetMetaTable():Get(meta_method)
			)

		if not func then return end

		if func.Type ~= "function" then return func end

		return self:Assert(self:Call(func, Tuple({l, r}), node)):Get(1)
	end
end

local function operator(self, node, l, r, op, meta_method)
	if op == ".." then
		if
			(
				l.Type == "string" and
				r.Type == "string"
			)
			or
			(
				l.Type == "number" and
				r.Type == "string"
			)
			or
			(
				l.Type == "number" and
				r.Type == "number"
			)
			or
			(
				l.Type == "string" and
				r.Type == "number"
			)
		then
			if l:IsLiteral() and r:IsLiteral() then
				return LString(l:GetData() .. r:GetData())
			end

			return String()
		end
	end

	if l:IsLiteral() and r:IsLiteral() then
		if l.Type == "number" and r.Type == "string" then
			local num = tonumber(r:GetData())

			if num then r = Number(num):SetLiteral(true) end
		elseif l.Type == "string" and r.Type == "number" then
			local num = tonumber(l:GetData())

			if num then l = Number(num):SetLiteral(true) end
		elseif l.Type == "string" and r.Type == "string" then
			local lnum = tonumber(l:GetData())
			local rnum = tonumber(r:GetData())

			if lnum and rnum then
				l = Number(lnum):SetLiteral(true)
				r = Number(rnum):SetLiteral(true)
			end
		end
	end

	if l.Type == "number" and r.Type == "number" then
		return l:ArithmeticOperator(r, op)
	else
		return metatable_function(self, node, meta_method, l, r)
	end

	return type_errors.binary(op, l, r)
end

local function logical_cmp_cast(val--[[#: boolean | nil]], err--[[#: string | nil]])
	if err then return val, err end

	if val == nil then
		return Boolean()
	elseif val == true then
		return True()
	elseif val == false then
		return False()
	end
end

local function Binary(self, node, l, r, op)
	op = op or node.value.value
	local cur_union

	if op == "|" and self:IsTypesystem() then
		cur_union = Union()
		self:PushCurrentType(cur_union, "union")
	end

	if not l and not r then
		if node.value.value == "and" then
			l = self:AnalyzeExpression(node.left)

			if l:IsCertainlyFalse() then
				r = Nil()
			else
				-- if a and a.foo then
				-- ^ no binary operator means that it was just checked simply if it was truthy
				if node.left.kind ~= "binary_operator" or node.left.value.value ~= "." then
					if l.Type == "union" then
						self:TrackUpvalueUnion(l, l:GetTruthy(), l:GetFalsy())
					else
						self:TrackUpvalue(l)
					end
				end

				-- right hand side of and is the "true" part
				self:PushTruthyExpressionContext(true)
				r = self:AnalyzeExpression(node.right)
				self:PopTruthyExpressionContext()

				if node.right.kind ~= "binary_operator" or node.right.value.value ~= "." then
					if r.Type == "union" then
						self:TrackUpvalueUnion(r, r:GetTruthy(), r:GetFalsy())
					else
						self:TrackUpvalue(r)
					end
				end
			end
		elseif node.value.value == "or" then
			self:PushFalsyExpressionContext(true)
			l = self:AnalyzeExpression(node.left)
			self:PopFalsyExpressionContext()

			if l:IsCertainlyFalse() then
				self:PushFalsyExpressionContext(true)
				r = self:AnalyzeExpression(node.right)
				self:PopFalsyExpressionContext()
			elseif l:IsCertainlyTrue() then
				r = Nil()
			else
				-- right hand side of or is the "false" part
				self:PushFalsyExpressionContext(true)
				r = self:AnalyzeExpression(node.right)
				self:PopFalsyExpressionContext()
			end
		else
			l = self:AnalyzeExpression(node.left)
			r = self:AnalyzeExpression(node.right)
		end

		self:TrackUpvalueNonUnion(l)
		self:TrackUpvalueNonUnion(r)

		-- TODO: more elegant way of dealing with self?
		if op == ":" then
			self.self_arg_stack = self.self_arg_stack or {}
			table.insert(self.self_arg_stack, l)
		end
	end

	if cur_union then self:PopCurrentType("union") end

	if self:IsTypesystem() then
		if op == "|" then
			cur_union:AddType(l)
			cur_union:AddType(r)
			return cur_union
		elseif op == "==" then
			return l:Equal(r) and True() or False()
		elseif op == "~" then
			if l.Type == "union" then return l:RemoveType(r) end

			return l
		elseif op == "&" or op == "extends" then
			if l.Type ~= "table" then
				return false, "type " .. tostring(l) .. " cannot be extended"
			end

			return l:Extend(r)
		elseif op == ".." then
			if l.Type == "tuple" and r.Type == "tuple" then
				return l:Copy():Concat(r)
			elseif l.Type == "string" and r.Type == "string" then
				if l:IsLiteral() and r:IsLiteral() then
					return LString(l:GetData() .. r:GetData())
				end

				return type_errors.binary(op, l, r)
			elseif l.Type == "number" and r.Type == "number" then
				return l:Copy():SetMax(r)
			end
		elseif op == "*" then
			if l.Type == "tuple" and r.Type == "number" and r:IsLiteral() then
				return l:Copy():SetRepeat(r:GetData())
			end
		elseif op == ">" or op == "supersetof" then
			return Symbol((r:IsSubsetOf(l)))
		elseif op == "<" or op == "subsetof" then
			return Symbol((l:IsSubsetOf(r)))
		elseif op == "+" then
			if l.Type == "table" and r.Type == "table" then return l:Union(r) end
		end
	end

	-- adding two tuples at runtime in lua will basically do this
	if self:IsRuntime() then
		if l.Type == "tuple" then l = self:Assert(l:GetFirstValue()) end

		if r.Type == "tuple" then r = self:Assert(r:GetFirstValue()) end
	end

	do -- union unpacking
		local original_l = l
		local original_r = r

		-- normalize l and r to be both unions to reduce complexity
		if l.Type ~= "union" and r.Type == "union" then l = Union({l}) end

		if l.Type == "union" and r.Type ~= "union" then r = Union({r}) end

		if l.Type == "union" and r.Type == "union" then
			local new_union = Union()
			local truthy_union = Union():SetUpvalue(l:GetUpvalue())
			local falsy_union = Union():SetUpvalue(l:GetUpvalue())
			truthy_union.left_source = l
			truthy_union.right_source = r
			falsy_union.left_source = l
			falsy_union.right_source = r
			new_union.left_source = l
			new_union.right_source = r

			if op == "~=" then self.inverted_index_tracking = true end

			local type_checked = self.type_checked

			-- the return value from type(x)
			if type_checked then self.type_checked = nil end

			for _, l in ipairs(l:GetData()) do
				for _, r in ipairs(r:GetData()) do
					local res, err = Binary(self, node, l, r, op)

					if not res then
						self:ErrorAndCloneCurrentScope(err, l) -- TODO, only left side?
					else
						if res:IsTruthy() then
							if type_checked then
								for _, t in ipairs(type_checked:GetData()) do
									if t.GetLuaType and t:GetLuaType() == l:GetData() then
										truthy_union:AddType(t)
									end
								end
							else
								truthy_union:AddType(l)
							end
						end

						if res:IsFalsy() then
							if type_checked then
								for _, t in ipairs(type_checked:GetData()) do
									if t.GetLuaType and t:GetLuaType() == l:GetData() then
										falsy_union:AddType(t)
									end
								end
							else
								falsy_union:AddType(l)
							end
						end

						new_union:AddType(res)
					end
				end
			end

			if op == "~=" then self.inverted_index_tracking = nil end

			if op ~= "or" and op ~= "and" then
				local parent_table = l.parent_table or type_checked and type_checked.parent_table
				local parent_key = l.parent_key or type_checked and type_checked.parent_key

				if parent_table then
					self:TrackTableIndexUnion(parent_table, parent_key, truthy_union, falsy_union)
				elseif l.Type == "union" then
					for _, l in ipairs(l:GetData()) do
						if l.parent_table then
							self:TrackTableIndexUnion(l.parent_table, l.parent_key, truthy_union, falsy_union)
						end
					end
				end

				if (op == "==" or op == "~=") and l.left_source and l.right_source then
					local key = l.right_source
					local union = l.left_source
					local expected = r
					local truthy_union = Union():SetUpvalue(l:GetUpvalue())
					local falsy_union = Union():SetUpvalue(l:GetUpvalue())

					for k, v in ipairs(union.Data) do
						local val = v:Get(key)

						if val then
							local res = Binary(self, node, val, expected, op)

							if res:IsTruthy() then truthy_union:AddType(v) end

							if res:IsFalsy() then falsy_union:AddType(v) end
						end
					end

					if not truthy_union:IsEmpty() or not falsy_union:IsEmpty() then
						self:TrackUpvalueUnion(union, truthy_union, falsy_union, op == "~=")
						return new_union
					end
				end

				if
					node.parent.kind == "binary_operator" and
					(
						node.parent.value.value == "==" or
						node.parent.value.value == "~="
					)
				then

				else
					self:TrackUpvalueUnion(l, truthy_union, falsy_union, op == "~=")
				end

				self:TrackUpvalueUnion(r, truthy_union, falsy_union, op == "~=")
			end

			return new_union
		end
	end

	if l.Type == "any" or r.Type == "any" then return Any() end

	do -- arithmetic operators
		if op == "." or op == ":" then
			return self:IndexOperator(l, r)
		elseif op == "+" then
			local val = operator(self, node, l, r, op, "__add")

			if val then return val end
		elseif op == "-" then
			local val = operator(self, node, l, r, op, "__sub")

			if val then return val end
		elseif op == "*" then
			local val = operator(self, node, l, r, op, "__mul")

			if val then return val end
		elseif op == "/" then
			local val = operator(self, node, l, r, op, "__div")

			if val then return val end
		elseif op == "/idiv/" then
			local val = operator(self, node, l, r, op, "__idiv")

			if val then return val end
		elseif op == "%" then
			local val = operator(self, node, l, r, op, "__mod")

			if val then return val end
		elseif op == "^" then
			local val = operator(self, node, l, r, op, "__pow")

			if val then return val end
		elseif op == "&" then
			local val = operator(self, node, l, r, op, "__band")

			if val then return val end
		elseif op == "|" then
			local val = operator(self, node, l, r, op, "__bor")

			if val then return val end
		elseif op == "~" then
			local val = operator(self, node, l, r, op, "__bxor")

			if val then return val end
		elseif op == "<<" then
			local val = operator(self, node, l, r, op, "__lshift")

			if val then return val end
		elseif op == ">>" then
			local val = operator(self, node, l, r, op, "__rshift")

			if val then return val end
		elseif op == ".." then
			local val = operator(self, node, l, r, op, "__concat")

			if val then return val end
		end
	end

	do -- logical operators
		if op == "==" then
			local res = metatable_function(self, node, "__eq", l, r)

			if res then return res end

			if l:IsLiteral() and l == r then return True() end

			if l.Type ~= r.Type then return False() end

			return logical_cmp_cast(l.LogicalComparison(l, r, op, self:GetCurrentAnalyzerEnvironment()))
		elseif op == "~=" or op == "!=" then
			local res = metatable_function(self, node, "__eq", l, r)

			if res then
				if res:IsLiteral() then res:SetData(not res:GetData()) end

				return res
			end

			if l.Type ~= r.Type then return True() end

			local val, err = l.LogicalComparison(l, r, "==", self:GetCurrentAnalyzerEnvironment())

			if val ~= nil then val = not val end

			return logical_cmp_cast(val, err)
		elseif op == "<" then
			local res = metatable_function(self, node, "__lt", l, r)

			if res then return res end

			return logical_cmp_cast(l.LogicalComparison(l, r, op))
		elseif op == "<=" then
			local res = metatable_function(self, node, "__le", l, r)

			if res then return res end

			return logical_cmp_cast(l.LogicalComparison(l, r, op))
		elseif op == ">" then
			local res = metatable_function(self, node, "__lt", l, r)

			if res then return res end

			return logical_cmp_cast(l.LogicalComparison(l, r, op))
		elseif op == ">=" then
			local res = metatable_function(self, node, "__le", l, r)

			if res then return res end

			return logical_cmp_cast(l.LogicalComparison(l, r, op))
		elseif op == "or" or op == "||" then
			-- boolean or boolean
			if l:IsUncertain() or r:IsUncertain() then return Union({l, r}) end

			-- true or boolean
			if l:IsTruthy() then return l:Copy() end

			-- false or true
			if r:IsTruthy() then return r:Copy() end

			return r:Copy()
		elseif op == "and" or op == "&&" then
			-- true and false
			if l:IsTruthy() and r:IsFalsy() then
				if l:IsFalsy() or r:IsTruthy() then return Union({l, r}) end

				return r:Copy()
			end

			-- false and true
			if l:IsFalsy() and r:IsTruthy() then
				if l:IsTruthy() or r:IsFalsy() then return Union({l, r}) end

				return l:Copy()
			end

			-- true and true
			if l:IsTruthy() and r:IsTruthy() then
				if l:IsFalsy() and r:IsFalsy() then return Union({l, r}) end

				return r:Copy()
			else
				-- false and false
				if l:IsTruthy() and r:IsTruthy() then return Union({l, r}) end

				return l:Copy()
			end
		end
	end

	return type_errors.binary(op, l, r)
end

return {Binary = Binary}