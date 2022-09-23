local setmetatable = _G.setmetatable
local table = _G.table
local ipairs = _G.ipairs
local tostring = _G.tostring
local Union = require("nattlua.types.union").Union
local Nil = require("nattlua.types.symbol").Nil
local Number = require("nattlua.types.number").Number
local LNumber = require("nattlua.types.number").LNumber
local LString = require("nattlua.types.string").LString
local Tuple = require("nattlua.types.tuple").Tuple
local type_errors = require("nattlua.types.error_messages")
local META = dofile("nattlua/types/base.lua")
local context = require("nattlua.analyzer.context")
local shallow_copy = require("nattlua.other.shallow_copy")
local mutation_solver = require("nattlua.analyzer.mutation_solver")
META.Type = "table"
--[[#type META.@Name = "TTable"]]
--[[#type TTable = META.@Self]]
--[[#local type TBaseType = META.TBaseType]]
META:GetSet("Data", nil--[[# as List<|{key = TBaseType, val = TBaseType}|>]])
META:GetSet("BaseTable", nil--[[# as TTable | nil]])
META:GetSet("ReferenceId", nil--[[# as string | nil]])
META:GetSet("Self", nil--[[# as nil | TTable]])
META:GetSet("Contracts", nil--[[# as List<|TTable|>]])
META:GetSet("CreationScope", nil--[[# as any]])

function META:GetName()
	if not self.Name then
		local meta = self:GetMetaTable()

		if meta and meta ~= self then return meta:GetName() end
	end

	return self.Name
end

function META:SetSelf(tbl)
	tbl:SetMetaTable(self)
	tbl.mutable = true
	tbl:SetContract(tbl)
	self.Self = tbl
end

function META.Equal(a--[[#: TBaseType]], b--[[#: TBaseType]])
	if a.Type ~= b.Type then return false end

	if a:IsUnique() then return a:GetUniqueID() == b:GetUniqueID() end

	if a:GetContract() and a:GetContract().Name then
		if not b:GetContract() or not b:GetContract().Name then
			a.suppress = false
			return false
		end

		-- never called
		a.suppress = false
		return a:GetContract().Name:GetData() == b:GetContract().Name:GetData()
	end

	if a.Name then
		a.suppress = false

		if not b.Name then return false end

		return a.Name:GetData() == b.Name:GetData()
	end

	if a.suppress then return true end

	local adata = a:GetData()
	local bdata = b:GetData()

	if #adata ~= #bdata then return false end

	for i = 1, #adata do
		local akv = adata[i]
		local ok = false

		for i = 1, #bdata do
			local bkv = bdata[i]
			a.suppress = true
			ok = akv.key:Equal(bkv.key) and akv.val:Equal(bkv.val)
			a.suppress = false

			if ok then break end
		end

		if not ok then
			a.suppress = false
			return false
		end
	end

	return true
end

local level = 0

function META:__tostring()
	if self.suppress then return "current_table" end

	self.suppress = true

	if self:GetContract() and self:GetContract().Name then -- never called
		self.suppress = nil
		return self:GetContract().Name:GetData()
	end

	if self.Name then
		self.suppress = nil
		return self.Name:GetData()
	end

	local meta = self:GetMetaTable()

	if meta then
		local func = meta:Get(LString("__tostring"))

		if func then
			local analyzer = context:GetCurrentAnalyzer()

			if analyzer then
				local str = analyzer:Call(func, Tuple({self})):GetFirstValue()

				if str and str:IsLiteral() then return str:GetData() end
			end
		end
	end

	local s = {}
	level = level + 1
	local indent = ("\t"):rep(level)

	if #self:GetData() <= 1 then indent = " " end

	local contract = self:GetContract()

	if contract and contract.Type == "table" and contract ~= self then
		for i, keyval in ipairs(contract:GetData()) do
			local key, val = tostring(self:GetData()[i] and self:GetData()[i].key or "nil"),
			tostring(self:GetData()[i] and self:GetData()[i].val or "nil")
			local tkey, tval = tostring(keyval.key), tostring(keyval.val)

			if key == tkey then
				s[i] = indent .. "[" .. key .. "]"
			else
				s[i] = indent .. "[" .. key .. " as " .. tkey .. "]"
			end

			if val == tval then
				s[i] = s[i] .. " = " .. val
			else
				s[i] = s[i] .. " = " .. val .. " as " .. tval
			end
		end
	else
		for i, keyval in ipairs(self:GetData()) do
			local key, val = tostring(keyval.key), tostring(keyval.val)
			s[i] = indent .. "[" .. key .. "]" .. " = " .. val
		end
	end

	level = level - 1
	self.suppress = false

	if #self:GetData() <= 1 then return "{" .. table.concat(s, ",") .. " }" end

	return "{\n" .. table.concat(s, ",\n") .. "\n" .. ("\t"):rep(level) .. "}"
end

function META:GetLength(analyzer--[[#: any]])
	local contract = self:GetContract()

	if contract and contract ~= self then return contract:GetLength(analyzer) end

	local len = 0

	for _, kv in ipairs(self:GetData()) do
		if analyzer and analyzer:HasMutations(self) then
			local val = analyzer:GetMutatedTableValue(self, kv.key)

			if val then
				if val.Type == "union" and val:CanBeNil() then
					return Number(len):SetLiteral(true):SetMax(Number(len + 1):SetLiteral(true))
				end

				if val.Type == "symbol" and val:GetData() == nil then
					return Number(len):SetLiteral(true)
				end
			end
		end

		if kv.key.Type == "number" then
			if kv.key:IsLiteral() then
				-- TODO: not very accurate
				if kv.key:GetMax() then return kv.key end

				if len + 1 == kv.key:GetData() then
					len = kv.key:GetData()
				else
					break
				end
			else
				return kv.key
			end
		end
	end

	return Number(len):SetLiteral(true)
end

function META:FollowsContract(contract--[[#: TTable]])
	if self:GetContract() == contract then return true end

	do -- todo
		-- i don't think this belongs here
		if not self:GetData()[1] then
			local can_be_empty = true
			contract.suppress = true

			for _, keyval in ipairs(contract:GetData()) do
				if not keyval.val:CanBeNil() then
					can_be_empty = false

					break
				end
			end

			contract.suppress = false

			if can_be_empty then return true end
		end
	end

	for _, keyval in ipairs(contract:GetData()) do
		local res, err = self:FindKeyVal(keyval.key)

		if not res and self:GetMetaTable() then
			res, err = self:GetMetaTable():FindKeyVal(keyval.key)
		end

		if not keyval.val:CanBeNil() then
			if not res then return res, err end

			local ok, err = res.val:IsSubsetOf(keyval.val)

			if not ok then
				return type_errors.other(
					{
						"the key ",
						res.key,
						" is not a subset of ",
						keyval.key,
						" because ",
						err,
					}
				)
			end
		end
	end

	for _, keyval in ipairs(self:GetData()) do
		local res, err = contract:FindKeyValReverse(keyval.key)

		if not keyval.val:CanBeNil() then
			if not res then return res, err end

			local ok, err = keyval.val:IsSubsetOf(res.val)

			if not ok then
				return type_errors.other(
					{
						"the key ",
						keyval.key,
						" is not a subset of ",
						res.val,
						" because ",
						err,
					}
				)
			end
		end
	end

	return true
end

function META.IsSubsetOf(a--[[#: TBaseType]], b--[[#: TBaseType]])
	if a.suppress then return true, "suppressed" end

	if b.Type == "tuple" then b = b:Get(1) end

	if b.Type == "any" then return true, "b is any " end

	local ok, err = a:IsSameUniqueType(b)

	if not ok then return ok, err end

	if a == b then return true, "same type" end

	if b.Type == "table" then
		if b:GetMetaTable() and b:GetMetaTable() == a then
			return true, "same metatable"
		end

		--if b:GetSelf() and b:GetSelf():Equal(a) then return true end
		local can_be_empty = true
		a.suppress = true

		for _, keyval in ipairs(b:GetData()) do
			if not keyval.val:CanBeNil() then
				can_be_empty = false

				break
			end
		end

		a.suppress = false

		if
			not a:GetData()[1] and
			(
				not a:GetContract() or
				not a:GetContract():GetData()[1]
			)
		then
			if can_be_empty then
				return true, "can be empty"
			else
				return type_errors.subset(a, b)
			end
		end

		for _, akeyval in ipairs(a:GetData()) do
			local bkeyval, reason = b:FindKeyValReverse(akeyval.key)

			if not akeyval.val:CanBeNil() then
				if not bkeyval then
					if a.BaseTable and a.BaseTable == b then
						bkeyval = akeyval
					else
						return bkeyval, reason
					end
				end

				a.suppress = true
				local ok, err = akeyval.val:IsSubsetOf(bkeyval.val)
				a.suppress = false

				if not ok then
					return type_errors.table_subset(akeyval.key, bkeyval.key, akeyval.val, bkeyval.val, err)
				end
			end
		end

		return true, "all is equal"
	elseif b.Type == "union" then
		local u = Union({a})
		local ok, err = u:IsSubsetOf(b)
		return ok, err or "is subset of b"
	end

	return type_errors.subset(a, b)
end

function META:ContainsAllKeysIn(contract--[[#: TTable]])
	for _, keyval in ipairs(contract:GetData()) do
		if keyval.key:IsLiteral() then
			local ok, err = self:FindKeyVal(keyval.key)

			if not ok then
				if
					(
						keyval.val.Type == "symbol" and
						keyval.val:GetData() == nil
					)
					or
					(
						keyval.val.Type == "union" and
						keyval.val:CanBeNil()
					)
				then
					return true
				end

				return type_errors.other({keyval.key, " is missing from ", contract})
			end
		end
	end

	return true
end

function META:Delete(key--[[#: TBaseType]])
	local data = self:GetData()

	for i = #data, 1, -1 do
		local keyval = data[i]

		if key:Equal(keyval.key) then
			keyval.val:SetParent()
			keyval.key:SetParent()
			table.remove(self:GetData(), i)
		end
	end

	return true
end

function META:GetKeyUnion()
	-- never called
	local union = Union()

	for _, keyval in ipairs(self:GetData()) do
		union:AddType(keyval.key:Copy())
	end

	return union
end

function META:GetValueUnion()
	local union = Union()

	for _, keyval in ipairs(self:GetData()) do
		union:AddType(keyval.val:Copy())
	end

	return union
end

function META:HasKey(key--[[#: TBaseType]])
	return self:FindKeyValReverse(key)
end

function META:IsEmpty()
	if self:GetContract() then return false end

	return self:GetData()[1] == nil
end

function META:FindKeyVal(key--[[#: TBaseType]])
	local reasons = {}

	for _, keyval in ipairs(self:GetData()) do
		local ok, reason = keyval.key:IsSubsetOf(key)

		if ok then return keyval end

		table.insert(reasons, reason)
	end

	if not reasons[1] then
		local ok, reason = type_errors.missing(self, key, "table is empty")
		reasons[1] = reason
	end

	return type_errors.missing(self, key, reasons)
end

function META:FindKeyValReverse(key--[[#: TBaseType]])
	local reasons = {}

	for _, keyval in ipairs(self:GetData()) do
		local ok, reason = key:Equal(keyval.key)

		if ok then return keyval end
	end

	for _, keyval in ipairs(self:GetData()) do
		local ok, reason = key:IsSubsetOf(keyval.key)

		if ok then return keyval end

		table.insert(reasons, reason)
	end

	if self.BaseTable then
		local ok, reason = self.BaseTable:FindKeyValReverse(key)

		if ok then return ok end

		table.insert(reasons, reason)
	end

	if not reasons[1] then
		local ok, reason = type_errors.missing(self, key, "table is empty")
		reasons[1] = reason
	end

	return type_errors.missing(self, key, reasons)
end

function META:FindKeyValReverseEqual(key--[[#: TBaseType]])
	local reasons = {}

	for _, keyval in ipairs(self:GetData()) do
		local ok, reason = key:Equal(keyval.key)

		if ok then return keyval end

		table.insert(reasons, reason)
	end

	if not reasons[1] then
		local ok, reason = type_errors.missing(self, key, "table is empty")
		reasons[1] = reason
	end

	return type_errors.missing(self, key, reasons)
end

function META:Insert(val--[[#: TBaseType]])
	self.size = self.size or LNumber(1)
	self:Set(self.size:Copy(), val)
	self.size:SetData(self.size:GetData() + 1)
end

function META:Set(key--[[#: TBaseType]], val--[[#: TBaseType | nil]], no_delete--[[#: boolean | nil]])
	if key.Type == "string" and key:IsLiteral() and key:GetData():sub(1, 1) == "@" then
		if
			context:GetCurrentAnalyzer() and
			context:GetCurrentAnalyzer():GetCurrentAnalyzerEnvironment() == "typesystem"
		then
			self["Set" .. key:GetData():sub(2)](self, val)
			return true
		end
	end

	if key.Type == "symbol" and key:GetData() == nil then
		return type_errors.other("key is nil")
	end

	if key.Type == "number" and key:IsNan() then
		return type_errors.other("key is nan")
	end

	-- delete entry
	if not no_delete and not self:GetContract() then
		if (not val or (val.Type == "symbol" and val:GetData() == nil)) then
			return self:Delete(key)
		end
	end

	if self:GetContract() and self:GetContract().Type == "table" then -- TODO
		local keyval, reason = self:GetContract():FindKeyValReverse(key)

		if not keyval then return keyval, reason end

		local keyval, reason = val:IsSubsetOf(keyval.val)

		if not keyval then return keyval, reason end
	end

	-- if the key exists, check if we can replace it and maybe the value
	local keyval, reason = self:FindKeyValReverse(key)

	if not keyval then
		val:SetParent(self)
		key:SetParent(self)
		table.insert(self.Data, {key = key, val = val})
	else
		if keyval.key:IsLiteral() and keyval.key:Equal(key) then
			keyval.val = val
		else
			keyval.val = Union({keyval.val, val})
		end
	end

	return true
end

function META:SetExplicit(key--[[#: TBaseType]], val--[[#: TBaseType]])
	if key.Type == "string" and key:IsLiteral() and key:GetData():sub(1, 1) == "@" then
		local key = "Set" .. key:GetData():sub(2)

		if not self[key] then
			return type_errors.other("no such function on table: " .. key)
		end

		self[key](self, val)
		return true
	end

	if key.Type == "symbol" and key:GetData() == nil then
		return type_errors.other("key is nil")
	end

	-- if the key exists, check if we can replace it and maybe the value
	local keyval, reason = self:FindKeyValReverseEqual(key)

	if not keyval then
		val:SetParent(self)
		key:SetParent(self)
		table.insert(self.Data, {key = key, val = val})
	else
		if keyval.key:IsLiteral() and keyval.key:Equal(key) then
			keyval.val = val
		else
			keyval.val = Union({keyval.val, val})
		end
	end

	return true
end

function META:Get(key--[[#: TBaseType]])
	if key.Type == "string" and key:IsLiteral() and key:GetData():sub(1, 1) == "@" then
		if
			context:GetCurrentAnalyzer() and
			context:GetCurrentAnalyzer():GetCurrentAnalyzerEnvironment() == "typesystem"
		then
			local val = assert(self["Get" .. key:GetData():sub(2)], key:GetData() .. " is not a function")(self)

			if not val then
				return type_errors.other("missing value on table " .. key:GetData())
			end

			return val
		end
	end

	if key.Type == "union" then
		if key:IsEmpty() then return type_errors.other("union key is empty") end

		local union = Union({})
		local errors = {}

		for _, k in ipairs(key:GetData()) do
			local obj, reason = self:Get(k)

			if obj then
				union:AddType(obj)
			else
				table.insert(errors, reason)
			end
		end

		if union:GetLength() == 0 then return type_errors.other(errors) end

		return union
	end

	if (key.Type == "string" or key.Type == "number") and not key:IsLiteral() then
		local union = Union({Nil()})
		local found_non_literal = false

		for _, keyval in ipairs(self:GetData()) do
			if keyval.key.Type == "union" then
				for _, ukey in ipairs(keyval.key:GetData()) do
					if ukey:IsSubsetOf(key) then union:AddType(keyval.val) end
				end
			elseif keyval.key.Type == key.Type or keyval.key.Type == "any" then
				if keyval.key:IsLiteral() then
					union:AddType(keyval.val)
				else
					found_non_literal = true

					break
				end
			end
		end

		if not found_non_literal then return union end
	end

	local keyval, reason = self:FindKeyValReverse(key)

	if keyval then return keyval.val end

	if not keyval and self:GetContract() then
		local keyval, reason = self:GetContract():FindKeyValReverse(key)

		if keyval then return keyval.val end

		return type_errors.other(reason)
	end

	return type_errors.other(reason)
end

function META:IsNumericallyIndexed()
	for _, keyval in ipairs(self:GetData()) do
		if keyval.key.Type ~= "number" then return false end
	end

	return true
end

function META:CopyLiteralness(from)
	if self.suppress then return end

	assert(from.Type == "table" or from.Type == "any" or from.Type == "union")

	if from.Type == "any" then return end

	if not from:GetData() then return false end

	if self:Equal(from) then return true end

	if from.Type == "table" then
		for _, keyval_from in ipairs(from:GetData()) do
			local keyval, reason = self:FindKeyVal(keyval_from.key)

			if not keyval then return type_errors.other(reason) end

			if keyval_from.key.Type == "table" then
				self.suppress = true
				keyval.key:CopyLiteralness(keyval_from.key) -- TODO: never called
				self.suppress = false
			else
				keyval.key:CopyLiteralness(keyval_from.key)
			end

			if keyval_from.val.Type == "table" then
				self.suppress = true
				keyval.val:CopyLiteralness(keyval_from.val)
				self.suppress = false
			else
				keyval.val:CopyLiteralness(keyval_from.val)
			end
		end
	end

	return true
end

function META:CoerceUntypedFunctions(from--[[#: TTable]])
	assert(from.Type == "table")

	for _, kv in ipairs(self:GetData()) do
		local kv_from, reason = from:FindKeyValReverse(kv.key)

		if kv.val.Type == "function" and kv_from.val.Type == "function" then
			kv.val:SetInputSignature(kv_from.val:GetInputSignature())
			kv.val:SetOutputSignature(kv_from.val:GetOutputSignature())
			kv.val:SetExplicitOutputSignature(true)
			kv.val:SetExplicitInputSignature(true)
			kv.val:SetCalled(false)
		end
	end
end

function META:Copy(map--[[#: Map<|any, any|> | nil]], copy_tables--[[#: nil | boolean]])
	map = map or {}
	local copy = META.New()
	map[self] = map[self] or copy

	for i, keyval in ipairs(self:GetData()) do
		local k, v = keyval.key, keyval.val
		k = map[keyval.key] or k:Copy(map, copy_tables)
		map[keyval.key] = map[keyval.key] or k
		v = map[keyval.val] or v:Copy(map, copy_tables)
		map[keyval.val] = map[keyval.val] or v
		copy:GetData()[i] = {key = k, val = v}
	end

	copy:CopyInternalsFrom(self)
	copy.potential_self = self.potential_self
	copy.mutable = self.mutable
	copy:SetLiteral(self:IsLiteral())
	copy.mutations = self.mutations
	copy:SetCreationScope(self:GetCreationScope())
	copy.BaseTable = self.BaseTable

	--[[
		
		copy.argument_index = self.argument_index
		copy.parent = self.parent
		copy.reference_id = self.reference_id
		]] if self.Self then copy:SetSelf(self.Self:Copy()) end

	if self.MetaTable then copy:SetMetaTable(self.MetaTable) end

	return copy
end

function META:GetContract()
	return self.Contracts[#self.Contracts] or self.Contract
end

function META:PushContract(contract)
	table.insert(self.Contracts, contract)
end

function META:PopContract()
	table.remove(self.Contracts)
end

--[[#type META.@Self.suppress = boolean]]

function META:HasLiteralKeys()
	if self.suppress then return true end

	local contract = self:GetContract()

	if contract and contract ~= self and not contract:HasLiteralKeys() then
		return false
	end

	for _, v in ipairs(self:GetData()) do
		if
			v.val ~= self and
			v.key ~= self and
			v.val.Type ~= "function" and
			v.key.Type ~= "function"
		then
			self.suppress = true
			local ok, reason = v.key:IsLiteral()
			self.suppress = false

			if not ok then
				return type_errors.other(
					{
						"the key ",
						v.key,
						" is not a literal because ",
						reason,
					}
				)
			end
		end
	end

	return true
end

function META:IsLiteral()
	if self.suppress then return true end

	if self:GetContract() then return false end

	for _, v in ipairs(self:GetData()) do
		if
			v.val ~= self and
			v.key ~= self and
			v.val.Type ~= "function" and
			v.key.Type ~= "function"
		then
			if v.key.Type == "union" then
				return false,
				type_errors.other(
					{
						"the value ",
						v.val,
						" is not a literal because it's a union",
					}
				)
			end

			self.suppress = true
			local ok, reason = v.key:IsLiteral()
			self.suppress = false

			if not ok then
				return type_errors.other(
					{
						"the key ",
						v.key,
						" is not a literal because ",
						reason,
					}
				)
			end

			if v.val.Type == "union" then
				return false,
				type_errors.other(
					{
						"the value ",
						v.val,
						" is not a literal because it's a union",
					}
				)
			end

			self.suppress = true
			local ok, reason = v.val:IsLiteral()
			self.suppress = false

			if not ok then
				return type_errors.other(
					{
						"the value ",
						v.val,
						" is not a literal because ",
						reason,
					}
				)
			end
		end
	end

	return true
end

function META:IsFalsy()
	return false
end

function META:IsTruthy()
	return true
end

local function unpack_keyval(keyval--[[#: ref {key = any, val = any}]])
	local key, val = keyval.key, keyval.val
	return key, val
end

function META.Extend(a--[[#: TTable]], b--[[#: TTable]])
	assert(b.Type == "table")
	local map = {}

	if a:GetContract() then
		if a == a:GetContract() then
			a:SetContract()
			a = a:Copy()
			a:SetContract(a)
		end

		a = a:GetContract()
	else
		a = a:Copy(map)
	end

	map[b] = a
	b = b:Copy(map)

	for _, keyval in ipairs(b:GetData()) do
		local ok, reason = a:SetExplicit(unpack_keyval(keyval))

		if not ok then return ok, reason end
	end

	return a
end

function META.Union(a--[[#: TTable]], b--[[#: TTable]])
	assert(b.Type == "table")
	local copy = META.New()

	for _, keyval in ipairs(a:GetData()) do
		copy:Set(unpack_keyval(keyval))
	end

	for _, keyval in ipairs(b:GetData()) do
		copy:Set(unpack_keyval(keyval))
	end

	return copy
end

function META:PrefixOperator(op--[[#: "#"]])
	if op == "#" then
		local keys = (self:GetContract() or self):GetData()

		if #keys == 1 and keys[1].key and keys[1].key.Type == "number" then
			return keys[1].key:Copy()
		end

		return self:GetLength():SetLiteral(self:IsLiteral())
	end
end

function META.LogicalComparison(l, r, op, env)
	if op == "==" then
		if env == "runtime" then
			if l:GetReferenceId() and r:GetReferenceId() then
				return l:GetReferenceId() == r:GetReferenceId()
			end

			return nil
		elseif env == "typesystem" then
			return l:IsSubsetOf(r) and r:IsSubsetOf(l)
		end
	end

	return type_errors.binary(op, l, r)
end

do
	local function initialize_table_mutation_tracker(tbl, scope, key, hash)
		tbl.mutations = tbl.mutations or {}
		tbl.mutations[hash] = tbl.mutations[hash] or {}

		if tbl.mutations[hash][1] == nil then
			if tbl.Type == "table" then
				-- initialize the table mutations with an existing value or nil
				local val = (tbl:GetContract() or tbl):Get(key) or Nil()

				if
					tbl:GetCreationScope() and
					not scope:IsCertainFromScope(tbl:GetCreationScope())
				then
					scope = tbl:GetCreationScope()
				end

				table.insert(tbl.mutations[hash], {scope = scope, value = val, contract = tbl:GetContract(), key = key})
			end
		end
	end

	function META:GetMutatedValue(key, scope)
		local hash = key:GetHash() or key:GetUpvalue() and key:GetUpvalue():GetKey()

		if not hash then return end

		initialize_table_mutation_tracker(self, scope, key, hash)
		return mutation_solver(shallow_copy(self.mutations[hash]), scope, self)
	end

	function META:Mutate(key, val, scope, from_tracking)
		local hash = key:GetHash() or key:GetUpvalue() and key:GetUpvalue():GetKey()

		if not hash then return end

		initialize_table_mutation_tracker(self, scope, key, hash)
		table.insert(self.mutations[hash], {scope = scope, value = val, from_tracking = from_tracking, key = key})

		if from_tracking then scope:AddTrackedObject(self) end
	end

	function META:ClearMutations()
		self.mutations = nil
	end

	function META:HasMutations()
		return self.mutations ~= nil
	end

	function META:GetMutatedFromScope(scope, done)
		if not self.mutations then return self end

		done = done or {}
		local out = META.New()

		if done[self] then
			return done[self]
		end

		done[self] = out

		for hash, mutations in pairs(self.mutations) do
			for _, mutation in ipairs(mutations) do
				local key = mutation.key
				local val = self:GetMutatedValue(key, scope)

				if done[val] then break end

				if val.Type == "union" then
					local union = Union()

					for _, val in ipairs(val:GetData()) do
						if val.Type == "table" then
							union:AddType(val:GetMutatedFromScope(scope, done))
						else
							union:AddType(val)
						end
					end

					out:Set(key, union)
				elseif val.Type == "table" then
					out:Set(key, val:GetMutatedFromScope(scope, done))
				else
					out:Set(key, val)
				end

				break
			end
		end

		return out
	end
end

function META.New()
	return setmetatable(
		{
			Data = {},
			Contracts = {},
			Falsy = false,
			Truthy = false,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
			suppress = false,
		},
		META
	)
end

return {Table = META.New}