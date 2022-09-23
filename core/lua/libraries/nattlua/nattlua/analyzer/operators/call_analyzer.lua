local ipairs = ipairs
local math = math
local ipairs = ipairs
local type = type
local math = math
local table = _G.table
local debug = debug
local Tuple = require("nattlua.types.tuple").Tuple
local Table = require("nattlua.types.table").Table
local Union = require("nattlua.types.union").Union
local Any = require("nattlua.types.any").Any
local Function = require("nattlua.types.function").Function
local LString = require("nattlua.types.string").LString
local LNumber = require("nattlua.types.number").LNumber
local Symbol = require("nattlua.types.symbol").Symbol
local type_errors = require("nattlua.types.error_messages")

local function should_expand(arg, contract)
	local b = arg.Type == "union"

	if contract.Type == "any" then b = false end

	if contract.Type == "union" then b = false end

	if arg.Type == "union" and contract.Type == "union" and contract:CanBeNil() then
		b = true
	end

	return b
end

local function unpack_union_tuples(obj, input)
	local input_signature = obj:GetInputSignature()
	local out = {}
	local lengths = {}
	local max = 1
	local ys = {}
	local arg_length = #input

	for i, val in ipairs(input) do
		if
			not obj:GetPreventInputArgumentExpansion() and
			should_expand(val, input_signature:Get(i))
		then
			lengths[i] = #val:GetData()
			max = max * lengths[i]
		else
			lengths[i] = 0
		end

		ys[i] = 1
	end

	for i = 1, max do
		local args = {}

		for i, val in ipairs(input) do
			if lengths[i] == 0 then
				args[i] = val
			else
				args[i] = val:GetData()[ys[i]]
			end
		end

		out[i] = args

		for i = arg_length, 2, -1 do
			if i == arg_length then ys[i] = ys[i] + 1 end

			if ys[i] > lengths[i] then
				ys[i] = 1
				ys[i - 1] = ys[i - 1] + 1
			end
		end
	end

	return out
end

return function(META)
	local ffi = jit and require("ffi") or nil

	function META:LuaTypesToTuple(tps)
		local tbl = {}

		for i, v in ipairs(tps) do
			if type(v) == "table" and v.Type ~= nil then
				tbl[i] = v
			else
				if type(v) == "function" then
					local func = Function()
					func:SetAnalyzerFunction(v)
					func:SetInputSignature(Tuple({}):AddRemainder(Tuple({Any()}):SetRepeat(math.huge)))
					func:SetOutputSignature(Tuple({}):AddRemainder(Tuple({Any()}):SetRepeat(math.huge)))
					func:SetLiteral(true)
					tbl[i] = func
				else
					local t = type(v)

					if t == "number" then
						tbl[i] = LNumber(v)
					elseif t == "string" then
						tbl[i] = LString(v)
					elseif t == "boolean" then
						tbl[i] = Symbol(v)
					elseif t == "table" then
						local tbl = Table()

						for _, val in ipairs(v) do
							tbl:Insert(val)
						end

						tbl:SetContract(tbl)
						return tbl
					elseif
						ffi and
						t == "cdata" and
						tostring(ffi.typeof(v)):sub(1, 10) == "ctype<uint" or
						tostring(ffi.typeof(v)):sub(1, 9) == "ctype<int"
					then
						tbl[i] = LNumber(v)
					else
						self:Print(t)
						error(debug.traceback("NYI " .. t))
					end
				end
			end
		end

		if tbl[1] and tbl[1].Type == "tuple" and #tbl == 1 then return tbl[1] end

		return Tuple(tbl)
	end

	function META:CallAnalyzerFunction(obj, input)
		local signature_arguments = obj:GetInputSignature()
		local output_signature = obj:GetOutputSignature()

		do
			local ok, reason, a, b, i = input:IsSubsetOfTuple(signature_arguments)

			if not ok then
				if not output_signature:IsEmpty() then
					if not a:IsLiteral() and b:IsLiteralArgument() and a.Type == b.Type then
						return output_signature:Copy()
					end
				end

				return type_errors.subset(a, b, {"argument #", i, " - ", reason})
			end
		end

		if self:IsTypesystem() then
			local ret = self:LuaTypesToTuple(
				{
					self:CallLuaTypeFunction(
						obj:GetAnalyzerFunction(),
						obj:GetScope() or self:GetScope(),
						input:UnpackWithoutExpansion()
					),
				}
			)
			return ret
		end

		local len = signature_arguments:GetLength()

		if len == math.huge and input:GetLength() == math.huge then
			len = math.max(signature_arguments:GetMinimumLength(), input:GetMinimumLength())
		end

		local tuples = {}

		for i, arguments in ipairs(unpack_union_tuples(obj, {input:Unpack(len)})) do
			tuples[i] = self:LuaTypesToTuple(
				{
					self:CallLuaTypeFunction(
						obj:GetAnalyzerFunction(),
						obj:GetScope() or self:GetScope(),
						table.unpack(arguments)
					),
				}
			)
		end

		local ret = Tuple({})

		for _, tuple in ipairs(tuples) do
			if tuple:GetUnpackable() or tuple:GetLength() == math.huge then
				return tuple
			end
		end

		for _, tuple in ipairs(tuples) do
			for i = 1, tuple:GetLength() do
				local v = tuple:Get(i)
				local existing = ret:Get(i)

				if existing then
					if existing.Type == "union" then
						existing:AddType(v)
					else
						ret:Set(i, Union({v, existing}))
					end
				else
					ret:Set(i, v)
				end
			end
		end

		if not output_signature:IsEmpty() then
			local ok, err = ret:IsSubsetOfTuple(output_signature)

			if not ok then return ok, err end
		end

		return ret
	end
end
