local LString = require("nattlua.types.string").LString
local Nil = require("nattlua.types.symbol").Nil
local Tuple = require("nattlua.types.tuple").Tuple
local Union = require("nattlua.types.union").Union
local type_errors = require("nattlua.types.error_messages")
return {
	Index = function(META)
		function META:IndexOperator(obj, key)
			if obj.Type == "union" then
				local union = Union({})

				for _, obj in ipairs(obj.Data) do
					if obj.Type == "tuple" and obj:GetLength() == 1 then
						obj = obj:Get(1)
					end

					-- if we have a union with an empty table, don't do anything
					-- ie {[number] = string} | {}
					if obj.Type == "table" and obj:IsEmpty() then

					else
						local val, err = obj:Get(key)

						if not val then return val, err end

						union:AddType(val)
					end
				end

				return union
			end

			if obj.Type ~= "table" and obj.Type ~= "tuple" and (obj.Type ~= "string") then
				return obj:Get(key)
			end

			if obj:GetMetaTable() and (obj.Type ~= "table" or not obj:HasKey(key)) then
				local index = obj:GetMetaTable():Get(LString("__index"))

				if index then
					if index == obj then return obj:Get(key) end

					if
						index.Type == "table" and
						(
							(
								index:GetContract() or
								index
							):HasKey(key) or
							(
								index:GetMetaTable() and
								index:GetMetaTable():HasKey(LString("__index"))
							)
						)
					then
						return self:IndexOperator(index:GetContract() or index, key)
					end

					if index.Type == "function" then
						local real_obj = obj
						local obj, err = self:Call(index, Tuple({obj, key}), self.current_statement)

						if not obj then return obj, err end

						local val = obj:Get(1)

						if val and (val.Type ~= "symbol" or val:GetData() ~= nil) then
							if val.Type == "union" and val:CanBeNil() then
								val:RemoveType(Nil())
							end

							self:TrackTableIndex(real_obj, key, val)
							return val
						end
					end
				end
			end

			if self:IsTypesystem() then return obj:Get(key) end

			if obj.Type == "tuple" and obj:GetLength() == 1 then
				return self:IndexOperator(obj:Get(1), key)
			end

			if obj.Type == "string" then
				return type_errors.other("attempt to index a string value")
			end

			local tracked = self:GetTrackedTableWithKey(obj, key)

			if tracked then return tracked end

			local contract = obj:GetContract()

			if contract then
				local val, err = contract:Get(key)

				if not val then return val, err end

				if not obj.argument_index or contract:IsReferenceArgument() then
					local val = self:GetMutatedTableValue(obj, key)

					if val then
						if val.Type == "union" then val = val:Copy(nil, true) end

						if not val:GetContract() then val:SetContract(val) end

						self:TrackTableIndex(obj, key, val)
						return val
					end
				end

				if val.Type == "union" then val = val:Copy(nil, true) end

				--TODO: this seems wrong, but it's for deferred analysis maybe not clearing up muations?
				if self:HasMutations(obj) then
					local tracked = self:GetMutatedTableValue(obj, key)

					if tracked then
						self:TrackTableIndex(obj, key, tracked)
						return tracked
					end
				end

				self:TrackTableIndex(obj, key, val)
				return val
			end

			local val = self:GetMutatedTableValue(obj, key)

			if key:IsLiteral() then
				local found_key = obj:FindKeyValReverse(key)

				if found_key and not found_key.key:IsLiteral() then
					val = Union({Nil(), val})
				end
			end

			if val then
				self:TrackTableIndex(obj, key, val)
				return val
			end

			return Nil()
		end
	end,
}