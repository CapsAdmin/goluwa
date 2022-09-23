local table = _G.table
local ipairs = ipairs
local Tuple = require("nattlua.types.tuple").Tuple
local NormalizeTuples = require("nattlua.types.tuple").NormalizeTuples
local Union = require("nattlua.types.union").Union
local Nil = require("nattlua.types.symbol").Nil
return {
	AnalyzeGenericFor = function(self, statement)
		local args = self:AnalyzeExpressions(statement.expressions)
		local callable_iterator = table.remove(args, 1)

		if not callable_iterator then return end

		if callable_iterator.Type == "tuple" then
			callable_iterator = callable_iterator:Get(1)

			if not callable_iterator then return end
		end

		local returned_key = nil
		local one_loop = callable_iterator and callable_iterator.Type == "any"
		local uncertain_break = nil

		for i = 1, 1000 do
			local values = self:Assert(self:Call(callable_iterator, Tuple(args), statement.expressions[1]))

			if values.Type == "tuple" and values:GetLength() == 1 then
				values = values:Get(1)
			end

			if values.Type == "union" then
				local tup = Tuple({})
				local max_length = 0

				for i, v in ipairs(values:GetData()) do
					if v.Type == "tuple" and v:GetLength() > max_length then
						max_length = v:GetLength()
					end
				end

				if max_length ~= math.huge then
					for i = 1, max_length do
						tup:Set(i, values:GetAtIndex(i))
					end

					values = tup
				end
			end

			if values.Type ~= "tuple" then values = Tuple({values}) end

			if
				not values:Get(1) or
				values:Get(1).Type == "symbol" and
				values:Get(1):GetData() == nil
			then
				break
			end

			if i == 1 then
				returned_key = values:Get(1)

				if not returned_key:IsLiteral() then
					returned_key = Union({Nil(), returned_key})
				end

				self:PushConditionalScope(statement, returned_key:IsTruthy(), returned_key:IsFalsy())
				self:PushUncertainLoop(false)
			end

			local brk = false

			for i, identifier in ipairs(statement.identifiers) do
				local obj = self:Assert(values:Get(i))

				if obj.Type == "union" then obj:RemoveType(Nil()) end

				if uncertain_break then
					obj:SetLiteral(false)
					brk = true
				end

				obj.from_for_loop = true
				self:CreateLocalValue(identifier.value.value, obj)
				identifier:AddType(obj)
			end

			self:CreateAndPushScope():SetLoopIteration(i)
			self:AnalyzeStatements(statement.statements)
			self:PopScope()

			if self._continue_ then self._continue_ = nil end

			if self:DidCertainBreak() then
				brk = true
				self:ClearBreak()
			elseif self:DidUncertainBreak() then
				uncertain_break = true
				self:ClearBreak()
			end

			if i == (self.max_iterations or 1000) and self:IsRuntime() then
				self:Error("too many iterations")
			end

			assert(values.Type == "tuple")
			table.insert(values:GetData(), 1, args[1])
			args = values:GetData()

			if one_loop then break end

			if brk then break end
		end

		if returned_key then
			self:PopConditionalScope()
			self:PopUncertainLoop()
		end
	end,
}