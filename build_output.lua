#!/usr/local/bin/luajit
_G.BUNDLE = true
_G.IMPORTS = _G.IMPORTS or {}
IMPORTS['nattlua/definitions/utility.nlua'] = assert(loadstring([=======[ return function() 















































































 end ]=======], '@nattlua/definitions/utility.nlua'))()
IMPORTS['nattlua/definitions/attest.nlua'] = assert(loadstring([=======[ return function() 















_G.attest = attest end ]=======], '@nattlua/definitions/attest.nlua'))()
do local __M; IMPORTS["nattlua.other.loadstring"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local f = _G.loadstring or _G.load
return function(str, name)
	if _G.CompileString then
		local var = CompileString(str, name or "loadstring", false)

		if type(var) == "string" then return nil, var, 2 end

		return setfenv(var, getfenv(1))
	end

	return (f)(str, name)
end end ]=======], '@./nattlua/other/loadstring.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.table_new"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local table_new
local ok

if not _G.gmod then ok, table_new = pcall(require, "table.new") end

if not ok then
	table_new = function(size, records)
		return {}
	end
end

return table_new end ]=======], '@./nattlua/other/table_new.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.table_pool"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local pairs = _G.pairs
local table_new = IMPORTS['nattlua.other.table_new']("nattlua.other.table_new")
return function(alloc, size)
	local records = 0

	for _, _ in pairs(alloc()) do
		records = records + 1
	end

	local i
	local pool = table_new(size, records)

	local function refill()
		i = 1

		for i = 1, size do
			pool[i] = alloc()
		end
	end

	refill()
	return function()
		local tbl = pool[i]

		if not tbl then
			refill()
			tbl = pool[i]
		end

		i = i + 1
		return tbl
	end
end end ]=======], '@./nattlua/other/table_pool.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.quote"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local helpers = {}

function helpers.QuoteToken(str)
	return "❲" .. str .. "❳"
end

function helpers.QuoteTokens(var)
	local str = ""

	for i, v in ipairs(var) do
		str = str .. helpers.QuoteToken(v)

		if i == #var - 1 then
			str = str .. " or "
		elseif i ~= #var then
			str = str .. ", "
		end
	end

	return str
end

return helpers end ]=======], '@./nattlua/other/quote.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.class"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local class = {}

function class.CreateTemplate(type_name)
	local meta = {}
	meta.Type = type_name
	meta.__index = meta
	
	local blacklist = {}

	function meta.GetSet(tbl, name, default)
		blacklist[name] = true
		tbl[name] = default
		
		tbl["Set" .. name] = function(self, val)
			self[name] = val
			return self
		end
		tbl["Get" .. name] = function(self)
			return self[name]
		end
	end

	function meta.IsSet(tbl, name, default)
		blacklist[name] = true
		tbl[name] = default
		
		tbl["Set" .. name] = function(self, val)
			self[name] = val
			return self
		end
		tbl["Is" .. name] = function(self)
			return self[name]
		end
	end

	local function get_line()
		local info = debug.getinfo(3)
		return info and info.source:sub(2) .. ":" .. info.currentline
	end

	local done = {}

	function meta:DebugPropertyAccess()
		meta.__index = function(self, key)
			if meta[key] ~= nil then return meta[key] end

			if not blacklist[key] then
				local line = get_line()
				local hash = key .. "-" .. line

				if not done[hash] then
					print(key, get_line())
					done[hash] = true
				end
			end

			return rawget(self, key)
		end
		meta.__newindex = function(self, key, val)
			if not blacklist[key] then
				local line = get_line()
				local hash = key .. "-" .. line

				if not done[hash] then
					print(key, val, line)
					done[hash] = true
				end
			end

			rawset(self, key, val)
		end
	end

	return meta
end

return class end ]=======], '@./nattlua/other/class.lua'))())(...) return __M end end
IMPORTS['nattlua/lexer/token.lua'] = assert(loadstring([=======[ return function() local table_pool = IMPORTS['nattlua.other.table_pool']("nattlua.other.table_pool")
local quote_helper = IMPORTS['nattlua.other.quote']("nattlua.other.quote")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("token")
local setmetatable = _G.setmetatable






function META:GetRoot()
	if self.parent then return (self.parent):GetRoot() end

	return self
end

function META:__tostring()
	return "[token - " .. self.type .. " - " .. quote_helper.QuoteToken(self.value) .. "]"
end

function META:AddType(obj)
	self.inferred_types = self.inferred_types or {}
	table.insert(self.inferred_types, obj)
end

function META:GetTypes()
	return self.inferred_types or {}
end

function META:GetLastType()
	return self.inferred_types and self.inferred_types[#self.inferred_types]
end

local new_token = table_pool(
	function()
		local x = {
			type = "unknown",
			value = "",
			whitespace = false,
			start = 0,
			stop = 0,
		}
		return x
	end,
	3105585
)

function META.New(
	type,
	is_whitespace,
	start,
	stop
)
	local tk = new_token()
	tk.type = type
	tk.is_whitespace = is_whitespace
	tk.start = start
	tk.stop = stop
	setmetatable(tk, META)
	return tk
end

return META end ]=======], '@nattlua/lexer/token.lua'))()
do local __M; IMPORTS["nattlua.other.helpers"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) 

local math = _G.math
local table = _G.table
local quote = IMPORTS['nattlua.other.quote']("nattlua.other.quote")
local type = _G.type
local pairs = _G.pairs
local assert = _G.assert
local tonumber = _G.tonumber
local tostring = _G.tostring
local next = _G.next
local error = _G.error
local ipairs = _G.ipairs
local jit = _G.jit
local pcall = _G.pcall
local unpack = _G.unpack
local helpers = {}

function helpers.LinePositionToSubPosition(code, line, character)
	line = math.max(line, 1)
	character = math.max(character, 1)
	local line_pos = 1

	for i = 1, #code do
		local c = code:sub(i, i)

		if line_pos == line then
			local char_pos = 1

			for i = i, i + character do
				local c = code:sub(i, i)

				if char_pos == character then return i end

				char_pos = char_pos + 1
			end

			return i
		end

		if c == "\n" then line_pos = line_pos + 1 end
	end

	return #code
end

function helpers.SubPositionToLinePosition(code, start, stop)
	local line = 1
	local line_start = 1
	local line_stop = nil
	local within_start = 1
	local within_stop = #code
	local character_start = 1
	local character_stop = 1
	local line_pos = 1
	local char_pos = 1

	for i = 1, #code do
		local char = code:sub(i, i)

		if i == stop then
			line_stop = line
			character_stop = char_pos
		end

		if i == start then
			line_start = line
			within_start = line_pos
			character_start = char_pos
		end

		if char == "\n" then
			if line_stop then
				within_stop = i

				break
			end

			line = line + 1
			line_pos = i
			char_pos = 1
		else
			char_pos = char_pos + 1
		end
	end

	if line_start ~= line_stop then
		character_start = within_start
		character_stop = within_stop
	end

	return {
		character_start = character_start,
		character_stop = character_stop,
		line_start = line_start,
		line_stop = line_stop,
		sub_line_before = {within_start, start - 1},
		sub_line_after = {stop + 1, within_stop},
	}
end

do
	do
		-- TODO: wtf am i doing here?
		local args
		local fmt = function(str)
			local num = tonumber(str)

			if not num then error("invalid format argument " .. str) end

			if type(args[num]) == "table" then return quote.QuoteTokens(args[num]) end

			return quote.QuoteToken(args[num] or "?")
		end

		function helpers.FormatMessage(msg, ...)
			args = {...}
			msg = msg:gsub("$(%d)", fmt)
			return msg
		end
	end

	local function clamp(num, min, max)
		return math.min(math.max(num, min), max)
	end

	local function find_position_after_lines(str, line_count)
		local count = 0

		for i = 1, #str do
			local char = str:sub(i, i)

			if char == "\n" then count = count + 1 end

			if count >= line_count then return i - 1 end
		end

		return #str
	end

	local function split(self, separator)
		local tbl = {}
		local current_pos = 1

		for i = 1, #self do
			local start_pos, end_pos = self:find(separator, current_pos, true)

			if not start_pos or not end_pos then break end

			tbl[i] = self:sub(current_pos, start_pos - 1)
			current_pos = end_pos + 1
		end

		if current_pos > 1 then
			tbl[#tbl + 1] = self:sub(current_pos)
		else
			tbl[1] = self
		end

		return tbl
	end

	local function pad_left(str, len, char)
		if #str < len + 1 then return char:rep(len - #str + 1) .. str end

		return str
	end

	local function string_lengthsplit(str, len)
		if #str > len then
			local tbl = {}
			local max = math.floor(#str / len)

			for i = 0, max do
				local left = i * len + 1
				local right = (i * len) + len
				local res = str:sub(left, right)

				if res ~= "" then table.insert(tbl, res) end
			end

			return tbl
		end

		return {str}
	end

	local MAX_WIDTH = 127

	function helpers.BuildSourceCodePointMessage(
		lua_code,
		path,
		msg,
		start,
		stop,
		size
	)
		do
			local new_str = ""
			local pos = 1

			for i, chunk in ipairs(string_lengthsplit(lua_code, MAX_WIDTH)) do
				if pos < start and i > 1 then
					start = start + 1
				end

				if pos < stop and i > 1 then
					stop = stop + 1
				end

				new_str = new_str .. chunk .. "\n"
				pos = pos + #chunk
			end

			lua_code = new_str
		end

		size = size or 2
		start = clamp(start or 1, 1, #lua_code)
		stop = clamp(stop or 1, 1, #lua_code)
		local data = helpers.SubPositionToLinePosition(lua_code, start, stop)
		local code_before = lua_code:sub(1, data.sub_line_before[1] - 1) -- remove the newline
		local code_between = lua_code:sub(data.sub_line_before[1] + 1, data.sub_line_after[2] - 1)
		local code_after = lua_code:sub(data.sub_line_after[2] + 1, #lua_code) -- remove the newline
		code_before = code_before:reverse():sub(1, find_position_after_lines(code_before:reverse(), size)):reverse()
		code_after = code_after:sub(1, find_position_after_lines(code_after, size))
		local lines_before = split(code_before, "\n")
		local lines_between = split(code_between, "\n")
		local lines_after = split(code_after, "\n")
		local total_lines = #lines_before + #lines_between + #lines_after
		local number_length = #tostring(total_lines)
		local lines = {}
		local i = data.line_start - #lines_before

		for _, line in ipairs(lines_before) do
			table.insert(lines, pad_left(tostring(i), number_length, " ") .. " | " .. line)
			i = i + 1
		end

		for i2, line in ipairs(lines_between) do
			local prefix = pad_left(tostring(i), number_length, " ") .. " | "
			table.insert(lines, prefix .. line)

			if #lines_between > 1 then
				if i2 == 1 then
					-- first line or the only line
					local length_before = data.sub_line_before[2] - data.sub_line_before[1]
					local arrow_length = #line - length_before
					table.insert(lines, (" "):rep(#prefix + length_before) .. ("^"):rep(arrow_length))
				elseif i2 == #lines_between then
					-- last line
					local length_before = data.sub_line_after[2] - data.sub_line_after[1]
					local arrow_length = #line - length_before
					table.insert(lines, (" "):rep(#prefix) .. ("^"):rep(arrow_length))
				else
					-- lines between
					table.insert(lines, (" "):rep(#prefix) .. ("^"):rep(#line))
				end
			else
				-- one line
				local length_before = data.sub_line_before[2] - data.sub_line_before[1]
				local length_after = data.sub_line_after[2] - data.sub_line_after[1]
				local arrow_length = #line - length_before - length_after
				table.insert(lines, (" "):rep(#prefix + length_before) .. ("^"):rep(arrow_length))
			end

			i = i + 1
		end

		for _, line in ipairs(lines_after) do
			table.insert(lines, pad_left(tostring(i), number_length, " ") .. " | " .. line)
			i = i + 1
		end

		local longest_line = 0

		for _, line in ipairs(lines) do
			if #line > longest_line then longest_line = #line end
		end

		longest_line = math.min(longest_line, MAX_WIDTH)
		table.insert(
			lines,
			1,
			(" "):rep(number_length + 3) .. ("_"):rep(longest_line - number_length + 1)
		)
		table.insert(
			lines,
			(" "):rep(number_length + 3) .. ("-"):rep(longest_line - number_length + 1)
		)

		if path then
			if path:sub(1, 1) == "@" then path = path:sub(2) end

			local msg = path .. ":" .. data.line_start .. ":" .. data.character_start
			table.insert(lines, pad_left("->", number_length, " ") .. " | " .. msg)
		end

		table.insert(lines, pad_left("->", number_length, " ") .. " | " .. msg)
		local str = table.concat(lines, "\n")
		str = str:gsub("\t", " ")
		return str
	end
end

function helpers.JITOptimize()
	if not jit then return end

	jit.opt.start(
		"maxtrace=65535", -- 1000 1-65535: maximum number of traces in the cache
		"maxrecord=8000", -- 4000: maximum number of recorded IR instructions
		"maxirconst=8000", -- 500: maximum number of IR constants of a trace
		"maxside=5000", -- 100: maximum number of side traces of a root trace
		"maxsnap=500", -- 500: maximum number of snapshots for a trace
		"hotloop=56", -- 56: number of iterations to detect a hot loop or hot call
		"hotexit=50", -- 10: number of taken exits to start a side trace
		"tryside=4", -- 4: number of attempts to compile a side trace
		"instunroll=1000", -- 4: maximum unroll factor for instable loops
		"loopunroll=1000", -- 15: maximum unroll factor for loop ops in side traces
		"callunroll=1000", -- 3: maximum unroll factor for pseudo-recursive calls
		"recunroll=0", -- 2: minimum unroll factor for true recursion
		"maxmcode=" .. (512 * 64), -- 512: maximum total size of all machine code areas in KBytes
		--jit.os == "x64" and "sizemcode=64" or "sizemcode=32", -- Size of each machine code area in KBytes (Windows: 64K)
		"+fold", -- Constant Folding, Simplifications and Reassociation
		"+cse", -- Common-Subexpression Elimination
		"+dce", -- Dead-Code Elimination
		"+narrow", -- Narrowing of numbers to integers
		"+loop", -- Loop Optimizations (code hoisting)
		"+fwd", -- Load Forwarding (L2L) and Store Forwarding (S2L)
		"+dse", -- Dead-Store Elimination
		"+abc", -- Array Bounds Check Elimination
		"+sink", -- Allocation/Store Sinking
		"+fuse" -- Fusion of operands into instructions
	)

	if jit.version_num >= 20100 then
		jit.opt.start("minstitch=0") -- 0: minimum number of IR ins for a stitched trace.
	end
end

return helpers end ]=======], '@./nattlua/other/helpers.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.error_messages"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local table = _G.table
local type = _G.type
local ipairs = _G.ipairs
local errors = {
	subset = function(a, b, reason)
		local msg = {a, " is not a subset of ", b}

		if reason then
			table.insert(msg, " because ")

			if type(reason) == "table" then
				for i, v in ipairs(reason) do
					table.insert(msg, v)
				end
			else
				table.insert(msg, reason)
			end
		end

		return false, msg
	end,
	table_subset = function(
		a_key,
		b_key,
		a,
		b,
		reason
	)
		local msg = {"[", a_key, "]", a, " is not a subset of ", "[", b_key, "]", b}

		if reason then
			table.insert(msg, " because ")

			if type(reason) == "table" then
				for i, v in ipairs(reason) do
					table.insert(msg, v)
				end
			else
				table.insert(msg, reason)
			end
		end

		return false, msg
	end,
	missing = function(a, b, reason)
		local msg = {a, " has no field ", b, " because ", reason}
		return false, msg
	end,
	other = function(msg)
		return false, msg
	end,
	type_mismatch = function(a, b)
		return false, {a, " is not the same type as ", b}
	end,
	value_mismatch = function(a, b)
		return false, {a, " is not the same value as ", b}
	end,
	operation = function(op, obj, subject)
		return false, {"cannot ", op, " ", subject}
	end,
	numerically_indexed = function(obj)
		return false, {obj, " is not numerically indexed"}
	end,
	binary = function(op, l, r)
		return false,
		{
			l,
			" ",
			op,
			" ",
			r,
			" is not a valid binary operation",
		}
	end,
	prefix = function(op, l)
		return false, {op, " ", l, " is not a valid prefix operation"}
	end,
	postfix = function(op, r)
		return false, {op, " ", r, " is not a valid postfix operation"}
	end,
	literal = function(obj, reason)
		local msg = {obj, " needs to be a literal"}

		if reason then
			table.insert(msg, " because ")
			table.insert(msg, reason)
		end

		return false, msg
	end,
	string_pattern = function(a, b)
		return false,
		{
			"cannot find ",
			a,
			" in pattern \"",
			b:GetPatternContract(),
			"\"",
		}
	end,
}
return errors end ]=======], '@./nattlua/types/error_messages.lua'))())(...) return __M end end
IMPORTS['nattlua/types/base.lua'] = assert(loadstring([=======[ return function() local assert = _G.assert
local tostring = _G.tostring
local setmetatable = _G.setmetatable
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("base")







META:GetSet("AnalyzerEnvironment", nil)

function META.Equal(a, b) --error("nyi " .. a.Type .. " == " .. b.Type)
end

function META:CanBeNil()
	return false
end

META:GetSet("Data", nil)

function META:GetLuaType()
	local contract = self:GetContract()

	if
		contract and
		contract.TypeOverride and
		contract.TypeOverride.Type == "string" and
		contract.TypeOverride.Data
	then
		return contract.TypeOverride.Data
	end

	return self.TypeOverride and
		self.TypeOverride.Type == "string" and
		self.TypeOverride.Data or
		self.Type
end

do
	function META:IsUncertain()
		return self:IsTruthy() and self:IsFalsy()
	end

	function META:IsCertainlyFalse()
		return self:IsFalsy() and not self:IsTruthy()
	end

	function META:IsCertainlyTrue()
		return self:IsTruthy() and not self:IsFalsy()
	end

	function META:GetTruthy()
		if self:IsTruthy() then return self end

		return nil
	end

	function META:GetFalsy()
		if self:IsFalsy() then return self end

		return nil
	end

	META:IsSet("Falsy", false)
	META:IsSet("Truthy", false)
end

do
	function META:Copy()
		return self
	end

	function META:CopyInternalsFrom(obj)
		self:SetLiteral(obj:IsLiteral())
		self:SetContract(obj:GetContract())
		self:SetName(obj:GetName())
		self:SetMetaTable(obj:GetMetaTable())
		self:SetAnalyzerEnvironment(obj:GetAnalyzerEnvironment())
		self:SetTypeOverride(obj:GetTypeOverride())
		self:SetLiteralArgument(obj:IsLiteralArgument())
		self:SetReferenceArgument(obj:IsReferenceArgument())
	end
end

do -- token, expression and statement association
	META:GetSet("Upvalue", nil)
	META:GetSet("Node", nil)

	function META:SetNode(node, is_local)
		self.Node = node
		return self
	end
end

do -- comes from tbl.@Name = "my name"
	META:GetSet("Name", nil)

	function META:SetName(name)
		if name then assert(name:IsLiteral()) end

		self.Name = name
	end
end

do -- comes from tbl.@TypeOverride = "my name"
	META:GetSet("TypeOverride", nil)

	function META:SetTypeOverride(name)
		self.TypeOverride = name
	end
end

do
	
	META:GetSet("UniqueID", nil)
	local ref = 0

	function META:MakeUnique(b)
		if b then
			self.UniqueID = ref
			ref = ref + 1
		else
			self.UniqueID = nil
		end

		return self
	end

	function META:IsUnique()
		return self.UniqueID ~= nil
	end

	function META:DisableUniqueness()
		self.disabled_unique_id = self.UniqueID
		self.UniqueID = nil
	end

	function META:EnableUniqueness()
		self.UniqueID = self.disabled_unique_id
	end

	function META:GetHash()
		return self.UniqueID
	end

	function META.IsSameUniqueType(a, b)
		if a.UniqueID and not b.UniqueID then
			return type_errors.other({a, "is a unique type"})
		end

		if a.UniqueID ~= b.UniqueID then
			return type_errors.other({a, "is not the same unique type as ", a})
		end

		return true
	end
end

do
	META:IsSet("LiteralArgument", false)
	META:IsSet("ReferenceArgument", false)
end

do
	META:IsSet("Literal", false)

	function META:CopyLiteralness(obj)
		if obj:IsReferenceArgument() then
			self:SetLiteral(true)
			self:SetReferenceArgument(true)
		else
			self:SetLiteral(obj:IsLiteral())
		end
	end
end

do -- operators
	function META:Set(key, val)
		return type_errors.other(
			{
				"undefined set: ",
				self,
				"[",
				key,
				"] = ",
				val,
				" on type ",
				self.Type,
			}
		)
	end

	function META:Get(key)
		return type_errors.other(
			{
				"undefined get: ",
				self,
				"[",
				key,
				"] on type ",
				self.Type,
			}
		)
	end

	function META:PrefixOperator(op)
		return type_errors.other({"no operator ", op, " on ", self})
	end
end

do
	META:GetSet("Parent", nil)

	function META:SetParent(parent)
		if parent then
			if parent ~= self then self.Parent = parent end
		else
			self.Parent = nil
		end
	end

	function META:GetRoot()
		local parent = self
		local done = {}

		while true do
			if not parent.Parent or done[parent] then break end

			done[parent] = true
			parent = parent.Parent
		end

		return parent
	end
end

do -- contract
	function META:Seal()
		self:SetContract(self:GetContract() or self:Copy())
	end

	META:GetSet("Contract", nil)
end

do
	META:GetSet("MetaTable", nil)

	function META:GetMetaTable()
		local contract = self:GetContract()

		if contract and contract.MetaTable then return contract.MetaTable end

		return self.MetaTable
	end
end

function META:Widen()
	self:SetLiteral(false)
	return self
end

function META:GetFirstValue()
	-- for tuples, this would return the first value in the tuple
	return self
end

function META.LogicalComparison(l, r, op)
	return type_errors.binary(op, l, r)
end

function META.New()
	return setmetatable({}, META)
end --copy<|META|>.@Self
return META end ]=======], '@nattlua/types/base.lua'))()
do local __M; IMPORTS["nattlua.types.symbol"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local type = type
local tostring = tostring
local setmetatable = _G.setmetatable
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")



META.Type = "symbol"
META:GetSet("Data", nil)

function META.Equal(a, b)
	return a.Type == b.Type and a:GetData() == b:GetData()
end

function META.LogicalComparison(l, r, op)
	if op == "==" then
		if l:IsLiteral() and r:IsLiteral() then return l:GetData() == r:GetData() end

		return nil
	end

	return type_errors.binary(op, l, r)
end

function META:GetLuaType()
	return type(self:GetData())
end

function META:__tostring()
	return tostring(self:GetData())
end

function META:GetHash()
	return tostring(self.Data)
end

function META:Copy()
	local copy = self.New(self:GetData())
	copy:CopyInternalsFrom(self)
	return copy
end

function META:CanBeNil()
	return self:GetData() == nil
end

function META.IsSubsetOf(a, b)
	if b.Type == "tuple" then b = b:Get(1) end

	if b.Type == "any" then return true end

	if b.Type == "union" then return b:IsTargetSubsetOfChild(a) end

	if b.Type ~= "symbol" then return type_errors.type_mismatch(a, b) end

	local b = b

	if a:GetData() ~= b:GetData() then return type_errors.value_mismatch(a, b) end

	return true
end

function META:IsFalsy()
	return not self.Data
end

function META:IsTruthy()
	return not not self.Data
end

function META.New(data)
	local self = setmetatable(
		{
			Data = data,
			Falsy = false,
			Truthy = false,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
		},
		META
	)
	self:SetLiteral(true)
	return self
end

local Symbol = META.New
return {
	Symbol = Symbol,
	Nil = function()
		return Symbol(nil)
	end,
	True = function()
		return Symbol(true)
	end,
	False = function()
		return Symbol(false)
	end,
} end ]=======], '@./nattlua/types/symbol.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.number"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local math = math
local assert = assert
local error = _G.error
local tostring = _G.tostring
local tonumber = _G.tonumber
local setmetatable = _G.setmetatable
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local bit = _G.bit32 or _G.bit
local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")



META.Type = "number"
META:GetSet("Data", nil)


do -- TODO, operators is mutated below, need to use upvalue position when analyzing typed arguments
	local operators = {
		["-"] = function(l)
			return -l
		end,
		["~"] = function(l)
			return bit.bnot(l)
		end,
	}

	function META:PrefixOperator(op)
		if self:IsLiteral() then
			local num = self.New(operators[op](self:GetData())):SetLiteral(true)
			local max = self:GetMax()

			if max then num:SetMax(max:PrefixOperator(op)) end

			return num
		end

		return self.New(nil) -- hmm
	end
end

function META:Widen()
	self:SetLiteral(false)
	return self
end

function META:GetHash()
	if self:IsNan() then return nil end

	if self:IsLiteral() then
		if self.Max then
			local hash = self.Max:GetHash()

			if hash and self.Data then
				return "__@type@__" .. self.Type .. self.Data .. ".." .. hash
			end
		end

		return self.Data
	end

	local upvalue = self:GetUpvalue()

	if upvalue then
		return "__@type@__" .. upvalue:GetHash() .. "_" .. self.Type
	end

	return "__@type@__" .. self.Type .. ("_%p"):format(self)
end

function META.Equal(a, b)
	if a.Type ~= b.Type then return false end

	if b:IsLiteralArgument() and a:IsLiteralArgument() then return true end

	if b:IsLiteralArgument() and not a:IsLiteral() then return false end

	if not a:IsLiteral() and not b:IsLiteral() then return true end

	if a:IsLiteral() and b:IsLiteral() then
		if a:IsNan() and b:IsNan() then return true end

		return a:GetData() == b:GetData()
	end

	local a_max = a.Max
	local b_max = b.Max

	if a_max then if b_max then if a_max:Equal(b_max) then return true end end end

	if a_max or b_max then return false end

	if not a:IsLiteral() and not b:IsLiteral() then return true end

	return false
end

function META:CopyLiteralness(num)
	if num.Type == "number" and num:GetMax() then
		if self:IsSubsetOf(num) then
			if num:IsReferenceArgument() then
				self:SetLiteral(true)
				self:SetReferenceArgument(true)
			end

			self:SetData(num:GetData())
			self:SetMax(num:GetMax())
		end
	else
		if num:IsReferenceArgument() then
			self:SetLiteral(true)
			self:SetReferenceArgument(true)
		else
			self:SetLiteral(num:IsLiteral())
		end
	end
end

function META:Copy()
	local copy = self.New(self:GetData()):SetLiteral(self:IsLiteral())
	local max = self.Max

	if max then copy.Max = max:Copy() end

	copy:CopyInternalsFrom(self)
	return copy -- TODO: figure out inheritance
end

function META.IsSubsetOf(a, b)
	if b.Type == "tuple" then b = (b):Get(1) end

	if b.Type == "any" then return true end

	if b.Type == "union" then
		return (b):IsTargetSubsetOfChild(a)
	end

	if b.Type ~= "number" then return type_errors.type_mismatch(a, b) end

	if a:IsLiteralArgument() and b:IsLiteralArgument() then return true end

	if b:IsLiteralArgument() and not a:IsLiteral() then
		return type_errors.subset(a, b)
	end

	if a:IsLiteral() and b:IsLiteral() then
		local a_num = a:GetData()
		local b_num = b:GetData()

		-- compare against literals
		if a.Type == "number" and b.Type == "number" then
			if a:IsNan() and b:IsNan() then return true end
		end

		if a_num == b_num then return true end

		local max = b:GetMaxLiteral()

		if max then if a_num >= b_num and a_num <= max then return true end end

		return type_errors.subset(a, b)
	elseif a:GetData() == nil and b:GetData() == nil then
		-- number contains number
		return true
	elseif a:IsLiteral() and not b:IsLiteral() then
		-- 42 subset of number?
		return true
	elseif not a:IsLiteral() and b:IsLiteral() then
		-- number subset of 42 ?
		return type_errors.subset(a, b)
	end

	-- number == number
	return true
end

function META:IsNan()
	local n = self:GetData()
	return n ~= n
end

function META:__tostring()
	local n = self:GetData()
	local s

	if self:IsNan() then s = "nan" end

	s = tostring(n)

	if self:GetMax() then s = s .. ".." .. tostring(self:GetMax()) end

	if self:IsLiteral() then return s end

	if self:IsLiteralArgument() then return "literal number" end

	return "number"
end

META:GetSet("Max", nil)

function META:SetMax(val)
	local err

	if val.Type == "union" then
		val, err = (val):GetLargestNumber()

		if not val then return val, err end
	end

	if val.Type ~= "number" then
		return type_errors.other({"max must be a number, got ", val})
	end

	if val:IsLiteral() then
		self.Max = val
	else
		self:SetLiteral(false)
		self:SetData(nil)
		self.Max = nil
	end

	return self
end

function META:GetMaxLiteral()
	return self.Max and self.Max:GetData()
end

do
	local operators = {
		[">"] = function(a, b)
			return a > b
		end,
		["<"] = function(a, b)
			return a < b
		end,
		["<="] = function(a, b)
			return a <= b
		end,
		[">="] = function(a, b)
			return a >= b
		end,
	}

	local function compare(
		val,
		min,
		max,
		operator
	)
		local func = operators[operator]

		if func(min, val) and func(max, val) then
			return true
		elseif not func(min, val) and not func(max, val) then
			return false
		end

		return nil
	end

	function META.LogicalComparison(a, b, operator)
		if not a:IsLiteral() or not b:IsLiteral() then return nil end

		if operator == "==" then
			local a_val = a:GetData()
			local b_val = b:GetData()

			if b_val then
				local max = a:GetMax()
				local max = max and max:GetData()

				if max and a_val then
					if b_val >= a_val and b_val <= max then return nil end

					return false
				end
			end

			if a_val then
				local max = b:GetMax()
				local max = max and max:GetData()

				if max and b_val then
					if a_val >= b_val and a_val <= max then return nil end

					return false
				end
			end

			if a_val and b_val then return a_val == b_val end

			return nil
		end

		local a_val = a:GetData()
		local b_val = b:GetData()

		if a_val and b_val then
			local a_max = a:GetMaxLiteral()
			local b_max = b:GetMaxLiteral()

			if a_max then
				if b_max then
					local res_a = compare(b_val, a_val, b_max, operator)
					local res_b = not compare(a_val, b_val, a_max, operator)

					if res_a ~= nil and res_a == res_b then return res_a end

					return nil
				end
			end

			if a_max then
				local res = compare(b_val, a_val, a_max, operator)

				if res == nil then return nil end

				return res
			end

			if operators[operator] then return operators[operator](a_val, b_val) end
		else
			return nil
		end

		if operators[operator] then return nil end

		return type_errors.binary(operator, a, b)
	end

	function META.LogicalComparison2(a, b, operator)
		local a_min = a:GetData()
		local b_min = b:GetData()

		if not a_min then return nil end

		if not b_min then return nil end

		local a_max = a:GetMaxLiteral() or a_min
		local b_max = b:GetMaxLiteral() or b_min
		local a_min_res = nil
		local b_min_res = nil
		local a_max_res = nil
		local b_max_res = nil

		if operator == "<" then
			a_min_res = math.min(a_min, b_max)
			a_max_res = math.min(a_max, b_max - 1)
			b_min_res = math.max(a_min, b_max)
			b_max_res = math.max(a_max, b_max)
		end

		if operator == ">" then
			a_min_res = math.max(a_min, b_max + 1)
			a_max_res = math.max(a_max, b_max)
			b_min_res = math.min(a_min, b_max)
			b_max_res = math.min(a_max, b_max)
		end

		local a = META.New(a_min_res):SetLiteral(true):SetMax(META.New(a_max_res):SetLiteral(true))
		local b = META.New(b_min_res):SetLiteral(true):SetMax(META.New(b_max_res):SetLiteral(true))
		return a, b
	end
end

do
	local operators = {
		["+"] = function(l, r)
			return l + r
		end,
		["-"] = function(l, r)
			return l - r
		end,
		["*"] = function(l, r)
			return l * r
		end,
		["/"] = function(l, r)
			return l / r
		end,
		["/idiv/"] = function(l, r)
			return (math.modf(l / r))
		end,
		["%"] = function(l, r)
			return l % r
		end,
		["^"] = function(l, r)
			return l ^ r
		end,
		["&"] = function(l, r)
			return bit.band(l, r)
		end,
		["|"] = function(l, r)
			return bit.bor(l, r)
		end,
		["~"] = function(l, r)
			return bit.bxor(l, r)
		end,
		["<<"] = function(l, r)
			return bit.lshift(l, r)
		end,
		[">>"] = function(l, r)
			return bit.rshift(l, r)
		end,
	}

	function META.ArithmeticOperator(l, r, op)
		local func = operators[op]

		if l:IsLiteral() and r:IsLiteral() then
			local obj = META.New(func(l:GetData(), r:GetData())):SetLiteral(true)

			if r:GetMax() then
				obj:SetMax(l.ArithmeticOperator(l:GetMax() or l, r:GetMax(), op))
			end

			if l:GetMax() then
				obj:SetMax(l.ArithmeticOperator(l:GetMax(), r:GetMax() or r, op))
			end

			return obj
		end

		return META.New()
	end
end

function META.New(data)
	return setmetatable(
		{
			Data = data,
			Falsy = false,
			Truthy = true,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
		},
		META
	)
end

local function string_to_integer(str)
	return assert(loadstring("return " .. str))()
end

return {
	Number = META.New,
	LNumber = function(num)
		return META.New(num):SetLiteral(true)
	end,
	LNumberFromString = function(str)
		local num = tonumber(str)

		if not num then
			if str:sub(1, 2) == "0b" then
				num = tonumber(str:sub(3), 2)
			elseif str:lower():sub(-3) == "ull" then
				num = string_to_integer(str)
			elseif str:lower():sub(-2) == "ll" then
				num = string_to_integer(str)
			end
		end

		if not num then return nil end

		return META.New(num):SetLiteral(true)
	end,
	TNumber = TNumber,
} end ]=======], '@./nattlua/types/number.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.union"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local tostring = tostring
local setmetatable = _G.setmetatable
local table = _G.table
local ipairs = _G.ipairs
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local True = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").True
local False = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").False
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")



local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")






META.Type = "union"

function META:GetHash()
	return tostring(self)
end

function META.Equal(a, b)
	if a.suppress then return true end

	if b.Type ~= "union" and #a.Data == 1 and a.Data[1] then
		return a.Data[1]:Equal(b)
	end

	if a.Type ~= b.Type then return false end

	local b = b

	if a:IsEmpty() and b:IsEmpty() then return true end

	if #a.Data ~= #b.Data then return false end

	for i = 1, #a.Data do
		local ok = false
		local a = a.Data[i]

		for i = 1, #b.Data do
			local b = b.Data[i]
			a.suppress = true
			ok = a:Equal(b)
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

local sort = function(a, b)
	return a < b
end

function META:__tostring()
	if self.suppress then return "current_union" end

	local s = {}
	self.suppress = true

	for _, v in ipairs(self.Data) do
		table.insert(s, tostring(v))
	end

	if not s[1] then
		self.suppress = false
		return "|"
	end

	self.suppress = false
	table.sort(s, sort)
	return table.concat(s, " | ")
end

function META:AddType(e)
	if e.Type == "union" then
		for _, v in ipairs(e.Data) do
			self:AddType(v)
		end

		return self
	end

	for _, v in ipairs(self.Data) do
		if v:Equal(e) then
			if
				e.Type ~= "function" or
				e:GetContract() or
				(
					e:GetFunctionBodyNode() and
					(
						e:GetFunctionBodyNode() == v:GetFunctionBodyNode()
					)
				)
			then
				return self
			end
		end
	end

	if e.Type == "string" or e.Type == "number" then
		local sup = e

		for i = #self.Data, 1, -1 do
			local sub = self.Data[i] -- TODO, prove that the for loop will always yield TBaseType?
			if sub.Type == sup.Type then
				if sub:IsSubsetOf(sup) then table.remove(self.Data, i) end
			end
		end
	end

	table.insert(self.Data, e)
	return self
end

function META:GetData()
	return self.Data
end

function META:GetLength()
	return #self.Data
end

function META:RemoveType(e)
	if e.Type == "union" then
		for i, v in ipairs(e.Data) do
			self:RemoveType(v)
		end

		return self
	end

	for i, v in ipairs(self.Data) do
		if v:Equal(e) then
			table.remove(self.Data, i)

			break
		end
	end

	return self
end

function META:Clear()
	self.Data = {}
end

function META:HasTuples()
	for _, obj in ipairs(self.Data) do
		if obj.Type == "tuple" then return true end
	end

	return false
end

function META:GetAtIndex(i)
	assert(type(i) == "number")

	if not self:HasTuples() then return self end

	local val
	local errors = {}

	for _, obj in ipairs(self.Data) do
		if obj.Type == "tuple" then
			local found, err = obj:Get(i)

			if found then
				if val then val = self.New({val, found}) else val = found end
			else
				if val then val = self.New({val, Nil()}) else val = Nil() end

				table.insert(errors, err)
			end
		else
			if val then
				-- a non tuple in the union would be treated as a tuple with the value repeated
				val = self.New({val, obj})
			elseif i == 1 then
				val = obj
			else
				val = Nil()
			end
		end
	end

	if not val then return false, errors end

	return val
end

function META:Get(key)
	local errors = {}

	for _, obj in ipairs(self.Data) do
		local ok, reason = key:IsSubsetOf(obj)

		if ok then return obj end

		table.insert(errors, reason)
	end

	return type_errors.other(errors)
end

function META:IsEmpty()
	return self.Data[1] == nil
end

function META:GetTruthy()
	local copy = self:Copy()

	for _, obj in ipairs(self.Data) do
		if not obj:IsTruthy() then copy:RemoveType(obj) end
	end

	return copy
end

function META:GetFalsy()
	local copy = self:Copy()

	for _, obj in ipairs(self.Data) do
		if not obj:IsFalsy() then copy:RemoveType(obj) end
	end

	return copy
end

function META:IsType(typ)
	assert(type(typ) == "string")

	if self:IsEmpty() then return false end

	for _, obj in ipairs(self.Data) do
		if obj.Type ~= typ then return false end
	end

	return true
end

function META:IsTypeExceptNil(typ)
	assert(type(typ) == "string")

	if self:IsEmpty() then return false end

	for _, obj in ipairs(self.Data) do
		if obj.Type == "symbol" and obj.Data == nil then

		else
			if obj.Type ~= typ then return false end
		end
	end

	return true
end

function META:HasType(typ)
	assert(type(typ) == "string")
	return self:GetType(typ) ~= false
end

function META:CanBeNil()
	for _, obj in ipairs(self.Data) do
		if obj.Type == "symbol" and obj:GetData() == nil then return true end
	end

	return false
end

function META:GetType(typ)
	assert(type(typ) == "string")

	for _, obj in ipairs(self.Data) do
		if obj.Type == typ then return obj end
	end

	return false
end

function META:IsTargetSubsetOfChild(target)
	local errors = {}

	for _, obj in ipairs(self:GetData()) do
		local ok, reason = target:IsSubsetOf(obj)

		if ok then return true end

		table.insert(errors, reason)
	end

	return type_errors.subset(target, self, errors)
end

function META.IsSubsetOf(a, b)
	if b.Type == "tuple" then b = b:Get(1) end

	if b.Type ~= "union" then return a:IsSubsetOf(META.New({b})) end

	for _, a_val in ipairs(a.Data) do
		if a_val.Type == "any" then return true end
	end

	for _, b_val in ipairs(b.Data) do
		if b_val.Type == "any" then return true end
	end

	if a:IsEmpty() then return type_errors.subset(a, b, "union is empty") end

	for _, a_val in ipairs(a.Data) do
		local b_val, reason = b:Get(a_val)

		if not b_val then return type_errors.missing(b, a_val, reason) end

		local ok, reason = a_val:IsSubsetOf(b_val)

		if not ok then return type_errors.subset(a_val, b_val, reason) end
	end

	return true
end

function META:Union(union)
	assert(union.Type == "union")
	local copy = self:Copy()

	for _, e in ipairs(union.Data) do
		copy:AddType(e)
	end

	return copy
end

function META:Copy(map, copy_tables)
	map = map or {}
	local copy = META.New()
	map[self] = map[self] or copy

	for _, e in ipairs(self.Data) do
		if e.Type == "table" and not copy_tables then
			copy:AddType(e)
		else
			copy:AddType(e:Copy(map, copy_tables))
		end
	end

	copy:CopyInternalsFrom(self)
	return copy
end

function META:IsTruthy()
	for _, v in ipairs(self.Data) do
		if v:IsTruthy() then return true end
	end

	return false
end

function META:IsFalsy()
	for _, v in ipairs(self.Data) do
		if v:IsFalsy() then return true end
	end

	return false
end

function META:DisableFalsy()
	local found = {}

	for _, v in ipairs(self.Data) do
		if v:IsCertainlyFalse() then table.insert(found, v) end
	end

	for _, v in ipairs(found) do
		self:RemoveType(v)
	end

	self.falsy_disabled = found
	return self
end

function META:EnableFalsy()
	-- never called
	if not self.falsy_disabled then return end

	for _, v in ipairs(self.falsy_disabled) do
		self:AddType(v)
	end
end

function META:SetMax(val)
	-- never called
	local copy = self:Copy()

	for _, e in ipairs(copy.Data) do
		e:SetMax(val)
	end

	return copy
end

function META:IsLiteral()
	for _, obj in ipairs(self:GetData()) do
		if not obj:IsLiteral() then return false end
	end

	return true
end

function META:GetLargestNumber()
	-- never called
	if #self:GetData() == 0 then return type_errors.other({"union is empty"}) end

	local max = {}

	for _, obj in ipairs(self:GetData()) do
		if obj.Type ~= "number" then
			return type_errors.other({"union must contain numbers only", self})
		end

		if obj:IsLiteral() then table.insert(max, obj) else return obj end
	end

	table.sort(max, function(a, b)
		return a:GetData() > b:GetData()
	end)

	return max[1]
end

function META.New(data)
	local self = setmetatable(
		{
			Data = {},
			Falsy = false,
			Truthy = false,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
			suppress = false,
			falsy_disabled = nil,
		},
		META
	)

	if data then for _, v in ipairs(data) do
		self:AddType(v)
	end end

	return self
end

return {
	Union = META.New,
	Nilable = function(typ--[[: TBaseType]] )
		return META.New({typ, Nil()})
	end,
	Boolean = function()
		return META.New({True(), False()})
	end,
} end ]=======], '@./nattlua/types/union.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.context"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local current_analyzer = {}
local CONTEXT = {}

function CONTEXT:GetCurrentAnalyzer()
	return current_analyzer[1]
end

function CONTEXT:PushCurrentAnalyzer(b)
	table.insert(current_analyzer, 1, b)
end

function CONTEXT:PopCurrentAnalyzer()
	table.remove(current_analyzer, 1)
end

return CONTEXT end ]=======], '@./nattlua/analyzer/context.lua'))())(...) return __M end end
IMPORTS['nattlua/code.lua'] = assert(loadstring([=======[ return function() local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("code")



function META:GetString()
	return self.Buffer
end

function META:GetName()
	return self.Name
end

function META:GetByteSize()
	return #self.Buffer
end

function META:GetStringSlice(start, stop)
	return self.Buffer:sub(start, stop)
end

function META:IsStringSlice(start, stop, str)
	return self.Buffer:sub(start, stop) == str
end

function META:GetByte(pos)
	return self.Buffer:byte(pos) or 0
end

function META:FindNearest(str, start)
	local _, pos = self.Buffer:find(str, start, true)

	if not pos then return nil end

	return pos + 1
end

local function remove_bom_header(str)
	if str:sub(1, 2) == "\xFE\xFF" then
		return str:sub(3)
	elseif str:sub(1, 3) == "\xEF\xBB\xBF" then
		return str:sub(4)
	end

	return str
end

local function get_default_name()
	local info = debug.getinfo(3)

	if info then
		local parent_line = info.currentline
		local parent_name = info.source:sub(2)
		return parent_name .. ":" .. parent_line
	end

	return "unknown line : unknown name"
end

function META:BuildSourceCodePointMessage(
	msg,
	start,
	stop,
	size
)
	return helpers.BuildSourceCodePointMessage(self:GetString(), self:GetName(), msg, start, stop, size)
end

function META.New(lua_code, name)
	local self = setmetatable(
		{
			Buffer = remove_bom_header(lua_code),
			Name = name or get_default_name(),
		},
		META
	)
	return self
end

if jit then
	local ffi = require("ffi")
	ffi.cdef("int memcmp ( const void * ptr1, const void * ptr2, size_t num );")

	function META:IsStringSlice(start, stop, str)
		return (
				ffi.C.memcmp
			)((ffi.cast("unsigned char*", self.Buffer)) - 1 + start, str, #str) == 0
	end

	function META:GetByte(pos)
		return ffi.cast("unsigned char*", self.Buffer)[pos - 1]
	end
end


return META end ]=======], '@nattlua/code.lua'))()
IMPORTS['./nattlua/types/../parser/nodes.nlua'] = assert(loadstring([=======[ return function() 

























































return {
	ExpressionKind = ExpressionKind,
	StatementKind = StatementKind,
	Node = Node,
	statement = statement,
	expression = expression,
} end ]=======], '@./nattlua/types/../parser/nodes.nlua'))()
do local __M; IMPORTS["nattlua.types.string"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local tostring = tostring
local setmetatable = _G.setmetatable
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local Number = IMPORTS['nattlua.types.number']("nattlua.types.number").Number
local context = IMPORTS['nattlua.analyzer.context']("nattlua.analyzer.context")
local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")




META.Type = "string"


META:GetSet("Data", nil)
META:GetSet("PatternContract", nil)

function META.Equal(a, b)
	if a.Type ~= b.Type then return false end

	local b = b

	if a:IsLiteralArgument() and b:IsLiteralArgument() then return true end

	if b:IsLiteralArgument() and not a:IsLiteral() then return false end

	if a:IsLiteral() and b:IsLiteral() then return a:GetData() == b:GetData() end

	if not a:IsLiteral() and not b:IsLiteral() then return true end

	return false
end

function META:GetHash()
	if self:IsLiteral() then return self.Data end

	local upvalue = self:GetUpvalue()

	if upvalue then
		return "__@type@__" .. upvalue:GetHash() .. "_" .. self.Type
	end

	return "__@type@__" .. self.Type .. ("_%p"):format(self)
end

function META:Copy()
	local copy = self.New(self:GetData()):SetLiteral(self:IsLiteral())
	copy:SetPatternContract(self:GetPatternContract())
	copy:CopyInternalsFrom(self)
	return copy
end

function META.IsSubsetOf(A, B)
	if B.Type == "tuple" then B = B:Get(1) end

	if B.Type == "any" then return true end

	if B.Type == "union" then return B:IsTargetSubsetOfChild(A) end

	if B.Type ~= "string" then return type_errors.type_mismatch(A, B) end

	local B = B

	if A:IsLiteralArgument() and B:IsLiteralArgument() then return true end

	if B:IsLiteralArgument() and not A:IsLiteral() then
		return type_errors.subset(A, B)
	end

	if A:IsLiteral() and B:IsLiteral() and A:GetData() == B:GetData() then -- "A" subsetof "B"
		return true
	end

	if A:IsLiteral() and not B:IsLiteral() then -- "A" subsetof string
		return true
	end

	if not A:IsLiteral() and not B:IsLiteral() then -- string subsetof string
		return true
	end

	if B.PatternContract then
		local str = A:GetData()

		if not str then -- TODO: this is not correct, it should be :IsLiteral() but I have not yet decided this behavior yet
			return type_errors.literal(A)
		end

		if not str:find(B.PatternContract) then
			return type_errors.string_pattern(A, B)
		end

		return true
	end

	if A:IsLiteral() and B:IsLiteral() then
		return type_errors.value_mismatch(A, B)
	end

	return type_errors.subset(A, B)
end

function META:__tostring()
	if self.PatternContract then return "$\"" .. self.PatternContract .. "\"" end

	if self:IsLiteral() then
		local str = self:GetData()

		if str then return "\"" .. str .. "\"" end
	end

	if self:IsLiteralArgument() then return "literal string" end

	return "string"
end

function META.LogicalComparison(a, b, op)
	if op == ">" then
		if a:IsLiteral() and b:IsLiteral() then return a:GetData() > b:GetData() end

		return nil
	elseif op == "<" then
		if a:IsLiteral() and b:IsLiteral() then return a:GetData() < b:GetData() end

		return nil
	elseif op == "<=" then
		if a:IsLiteral() and b:IsLiteral() then return a:GetData() <= b:GetData() end

		return nil
	elseif op == ">=" then
		if a:IsLiteral() and b:IsLiteral() then return a:GetData() >= b:GetData() end

		return nil
	elseif op == "==" then
		if a:IsLiteral() and b:IsLiteral() then return a:GetData() == b:GetData() end

		return nil
	end

	return type_errors.binary(op, a, b)
end

function META:IsFalsy()
	return false
end

function META:IsTruthy()
	return true
end

function META:PrefixOperator(op)
	if op == "#" then
		local str = self:GetData()
		return Number(str and #str or nil):SetLiteral(self:IsLiteral())
	end
end

function META.New(data)
	local self = setmetatable(
		{
			Data = data,
			Falsy = false,
			Truthy = true,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
		},
		META
	)
	-- analyzer might be nil when strings are made outside of the analyzer, like during tests
	local analyzer = context:GetCurrentAnalyzer()

	if analyzer then
		self:SetMetaTable(analyzer:GetDefaultEnvironment("typesystem").string_metatable)
	end

	return self
end

return {
	String = META.New,
	LString = function(num)
		return META.New(num):SetLiteral(true)
	end,
	LStringNoMeta = function(data)
		return setmetatable(
			{
				Data = data,
				Falsy = false,
				Truthy = true,
				Literal = false,
				LiteralArgument = false,
				ReferenceArgument = false,
			},
			META
		):SetLiteral(true)
	end,
	NodeToString = function(node, is_local)
		return META.New(node.value.value):SetLiteral(true)
	end,
} end ]=======], '@./nattlua/types/string.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.any"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")



META.Type = "any"

function META:Get(key)
	return self
end

function META:Set(key, val)
	return true
end

function META:Copy()
	return self
end

function META.IsSubsetOf(A, B)
	return true
end

function META:__tostring()
	return "any"
end

function META:IsFalsy()
	return true
end

function META:IsTruthy()
	return true
end

function META.Equal(a, b)
	return a.Type == b.Type
end

function META.LogicalComparison(l, r, op)
	if op == "==" then return true -- TODO: should be nil (true | false)?
	end

	return type_errors.binary(op, l, r)
end

return {
	Any = function()
		return META.New()
	end,
} end ]=======], '@./nattlua/types/any.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.tuple"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local tostring = tostring
local table = _G.table
local math = math
local assert = assert
local debug = debug
local error = error
local setmetatable = _G.setmetatable
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local ipairs = _G.ipairs
local type = _G.type
local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")






META:GetSet("Data", nil)
META.Type = "tuple"
META:GetSet("Unpackable", false)

function META.Equal(a, b)
	if a.Type ~= b.Type then return false end

	if a.suppress then return true end

	if #a.Data ~= #b.Data then return false end

	for i = 1, #a.Data do
		local val = a.Data[i]
		a.suppress = true
		local ok = val:Equal(b.Data[i])
		a.suppress = false

		if not ok then return false end
	end

	return true
end

function META:__tostring()
	if self.suppress then return "current_tuple" end

	self.suppress = true
	local strings = {}

	for i, v in ipairs(self:GetData()) do
		strings[i] = tostring(v)
	end

	if self.Remainder then table.insert(strings, tostring(self.Remainder)) end

	local s = "("

	if #strings == 1 and strings[1] then
		s = s .. strings[1] .. ","
	else
		s = s .. table.concat(strings, ", ")
	end

	s = s .. ")"

	if self.Repeat then s = s .. "*" .. tostring(self.Repeat) end

	self.suppress = false
	return s
end

function META:Merge(tup)
	local src = self:GetData()
	local len = tup:GetMinimumLength()

	if len == 0 and tup:GetLength() ~= math.huge then len = tup:GetLength() end

	for i = 1, len do
		local a = self:Get(i)
		local b = tup:Get(i)

		if a then src[i] = Union({a, b}) elseif b then src[i] = b:Copy() end
	end

	self.Remainder = tup.Remainder or self.Remainder
	self.Repeat = tup.Repeat or self.Repeat
	return self
end

function META:Copy(map, copy_tables)
	map = map or {}
	local copy = self.New({})
	map[self] = map[self] or copy

	for i, v in ipairs(self:GetData()) do
		v = map[v] or v:Copy(map, copy_tables)
		map[v] = map[v] or v
		copy:Set(i, v)
	end

	if self.Remainder then copy.Remainder = self.Remainder:Copy(nil, copy_tables) end

	copy.Repeat = self.Repeat
	copy.Unpackable = self.Unpackable
	copy:CopyInternalsFrom(self)
	return copy
end

function META.IsSubsetOf(a, b, max_length)
	if a == b then return true end

	if a.suppress then return true end

	if a.Remainder then
		local t = a:Get(1)

		if t and t.Type == "any" and #a:GetData() == 0 then return true end
	end

	if b.Type == "union" then return b:IsTargetSubsetOfChild(a) end

	do
		local t = a:Get(1)

		if t and t.Type == "any" and b.Type == "tuple" and b:GetLength() == 0 then
			return true
		end
	end

	if b.Type == "any" then return true end

	if b.Type == "table" then
		if not b:IsNumericallyIndexed() then
			return type_errors.numerically_indexed(b)
		end
	end

	if b.Type ~= "tuple" then return type_errors.type_mismatch(a, b) end

	max_length = max_length or math.max(a:GetMinimumLength(), b:GetMinimumLength())

	for i = 1, max_length do
		local a_val, err = a:Get(i)

		if not a_val then return type_errors.subset(a, b, err) end

		local b_val, err = b:Get(i)

		if not b_val and a_val.Type == "any" then break end

		if not b_val then return type_errors.missing(b, i, err) end

		a.suppress = true
		local ok, reason = a_val:IsSubsetOf(b_val)
		a.suppress = false

		if not ok then return type_errors.subset(a_val, b_val, reason) end
	end

	return true
end

function META.IsSubsetOfTupleWithoutExpansion(a, b)
	for i, a_val in ipairs(a:GetData()) do
		local b_val = b:GetWithoutExpansion(i)
		local ok, err = a_val:IsSubsetOf(b_val)

		if not ok then return ok, err, a_val, b_val, i end
	end

	return true
end

function META.IsSubsetOfTuple(a, b)
	if a:Equal(b) then return true end

	for i = 1, math.max(a:GetMinimumLength(), b:GetMinimumLength()) do
		local a_val, a_err = a:Get(i)
		local b_val, b_err = b:Get(i)

		if b_val and b_val.Type == "union" then b_val, b_err = b_val:GetAtIndex(i) end

		if not a_val then
			if b_val and b_val.Type == "any" then
				a_val = Any()
			else
				return a_val, a_err, a_val or Nil(), b_val, i
			end
		end

		if not b_val then return b_val, b_err, a_val or Nil(), b_val, i end

		if b_val.Type == "tuple" then
			b_val = b_val:Get(1)

			if not b_val then break end
		end

		a_val = a_val or Nil()
		b_val = b_val or Nil()
		local ok, reason = a_val:IsSubsetOf(b_val)

		if not ok then return ok, reason, a_val, b_val, i end
	end

	return true
end

function META:HasTuples()
	for _, v in ipairs(self.Data) do
		if v.Type == "tuple" then return true end
	end

	if self.Remainder and self.Remainder.Type == "tuple" then return true end

	return false
end

function META:GetWithNumber(i)
	local val = self:GetData()[i]

	if not val and self.Repeat and i <= (#self:GetData() * self.Repeat) then
		return self:GetData()[((i - 1) % #self:GetData()) + 1]
	end

	if not val and self.Remainder then
		return self.Remainder:Get(i - #self:GetData())
	end

	if not val then
		local last = self:GetData()[#self:GetData()]

		if last and last.Type == "tuple" and (last.Repeat or last.Remainder) then
			return last:Get(i)
		end
	end

	if not val then
		return type_errors.other({"index ", tostring(i), " does not exist"})
	end

	return val
end

function META:Get(key)
	if type(key) == "number" then return self:GetWithNumber(key) end

	if key.Type == "union" then
		local union = Union()

		for _, v in ipairs(key:GetData()) do
			if key.Type == "number" then
				local val = (self):Get(v)
				union:AddType(val)
			end
		end

		return union
	end

	assert(key.Type == "number")

	if key:IsLiteral() then return self:GetWithNumber(key:GetData()) end
end

function META:GetWithoutExpansion(i)
	local val = self:GetData()[i]

	if not val then if self.Remainder then return self.Remainder end end

	if not val then return type_errors.other({"index ", i, " does not exist"}) end

	return val
end

function META:Set(i, val)
	if type(i) == "table" then
		i = i:GetData()
		return false, "expected number"
	end

	if val.Type == "tuple" and val:GetLength() == 1 then val = val:Get(1) end

	self.Data[i] = val

	if i > 32 then error("tuple too long", 2) end

	return true
end

function META:IsEmpty()
	-- never called
	return self:GetLength() == 0
end

function META:IsTruthy()
	local obj = self:Get(1)

	if obj then return obj:IsTruthy() end

	return false
end

function META:IsFalsy()
	local obj = self:Get(1)

	if obj then return obj:IsFalsy() end

	return false
end

function META:GetLength()
	if false then
		-- TODO: recursion
		return nil
	end

	if self.Remainder then return #self:GetData() + self.Remainder:GetLength() end

	if self.Repeat then return #self:GetData() * self.Repeat end

	return #self:GetData()
end

function META:GetMinimumLength()
	if self.Repeat == math.huge or self.Repeat == 0 then return 0 end

	local len = #self:GetData()
	local found_nil = false

	for i = #self:GetData(), 1, -1 do
		local obj = self:GetData()[i]

		if
			(
				obj.Type == "union" and
				obj:CanBeNil()
			) or
			(
				obj.Type == "symbol" and
				obj:GetData() == nil
			)
		then
			found_nil = true
			len = i - 1
		elseif found_nil then
			len = i

			break
		end
	end

	return len
end

function META:GetSafeLength(arguments)
	local len = self:GetLength()

	if len == math.huge or arguments:GetLength() == math.huge then
		return math.max(self:GetMinimumLength(), arguments:GetMinimumLength())
	end

	return len
end

function META:AddRemainder(obj)
	self.Remainder = obj
	return self
end

function META:SetRepeat(amt)
	self.Repeat = amt
	return self
end

function META:Unpack(length)
	length = length or self:GetLength()
	length = math.min(length, self:GetLength())
	assert(length ~= math.huge, "length must be finite")
	local out = {}
	local i = 1

	for _ = 1, length do
		out[i] = self:Get(i)
		i = i + 1
	end

	return table.unpack(out)
end

function META:UnpackWithoutExpansion()
	local tbl = {table.unpack(self.Data)}

	if self.Remainder then table.insert(tbl, self.Remainder) end

	return table.unpack(tbl)
end

function META:Slice(start, stop)
	-- TODO: not accurate yet
	start = start or 1
	stop = stop or #self:GetData()
	local copy = self:Copy()
	local data = {}

	for i = start, stop do
		table.insert(data, (self:GetData())[i])
	end

	copy:SetData(data)
	return copy
end

function META:GetFirstValue()
	if self.Remainder then return self.Remainder:GetFirstValue() end

	local first, err = self:Get(1)

	if not first then return first, err end

	if first.Type == "tuple" then return first:GetFirstValue() end

	return first
end

function META:Concat(tup)
	local start = self:GetLength()

	for i, v in ipairs(tup:GetData()) do
		self:Set(start + i, v)
	end

	return self
end

function META:SetTable(data)
	self.Data = {}

	for i, v in ipairs(data) do
		if
			i == #data and
			v.Type == "tuple" and
			not (
				v
			).Remainder and
			v ~= self
		then
			self:AddRemainder(v)
		else
			table.insert(self.Data, v)
		end
	end
end

function META.New(data)
	local self = setmetatable(
		{
			Data = {},
			Falsy = false,
			Truthy = false,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
			Unpackable = false,
			suppress = false,
		},
		META
	)

	if data then self:SetTable(data) end

	return self
end

return {
	Tuple = META.New,
	VarArg = function(t)
		local self = META.New({t})
		self:SetRepeat(math.huge)
		return self
	end,
	NormalizeTuples = function(types)
		local arguments

		if #types == 1 and types[1] and types[1].Type == "tuple" then
			arguments = types[1]
		else
			local temp = {}

			for i, v in ipairs(types) do
				if v.Type == "tuple" then
					if i == #types then
						table.insert(temp, v)
					else
						local obj = v:Get(1)

						if obj then table.insert(temp, obj) end
					end
				else
					table.insert(temp, v)
				end
			end

			arguments = META.New(temp)
		end

		return arguments
	end,
} end ]=======], '@./nattlua/types/tuple.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.shallow_copy"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local function shallow_copy(tbl)
	local copy = {}

	for i, val in ipairs(tbl) do
		copy[i] = val
	end

	return copy
end

return shallow_copy end ]=======], '@./nattlua/other/shallow_copy.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.mutation_solver"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local table = _G.table
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union

local function mutation_solver(mutations, scope, obj)
	do
		do
			for i = #mutations, 1, -1 do
				local mut_a = mutations[i]

				for i = i - 1, 1, -1 do
					local mut_b = mutations[i]

					if mut_a.scope == mut_b.scope then
						table.remove(mutations, i)

						break
					end
				end
			end
		end

		for i = #mutations, 1, -1 do
			local mut = mutations[i]

			if
				(
					scope:IsPartOfTestStatementAs(mut.scope) or
					(
						mut.from_tracking and
						not mut.scope:Contains(scope)
					)
				)
				and
				scope ~= mut.scope
			then
				table.remove(mutations, i)
			end
		end

		do
			for i = #mutations, 1, -1 do
				local mut = mutations[i]

				if mut.scope:IsElseConditionalScope() then
					while true do
						local mut = mutations[i]

						if not mut then break end

						if
							not mut.scope:IsPartOfTestStatementAs(scope) and
							not mut.scope:IsCertainFromScope(scope)
						then
							for i = i, 1, -1 do
								if mutations[i].scope:IsCertainFromScope(scope) then
									-- redudant mutation before else part of if statement
									table.remove(mutations, i)
								end
							end

							break
						end

						i = i - 1
					end

					break
				end
			end
		end

		do
			local test_scope_a = scope:FindFirstConditionalScope()

			if test_scope_a then
				for _, mut in ipairs(mutations) do
					if mut.scope ~= scope then
						local test_scope_b = mut.scope:FindFirstConditionalScope()

						if test_scope_b and test_scope_b ~= test_scope_a and obj.Type ~= "table" then
							if test_scope_a:TracksSameAs(test_scope_b, obj) then
								-- forcing scope certainty because this scope is using the same test condition
								mut.certain_override = true
							end
						end
					end
				end
			end
		end
	end

	if not mutations[1] then return end

	local union = Union({})

	if obj.Type == "upvalue" then union:SetUpvalue(obj) end

	for _, mut in ipairs(mutations) do
		local value = mut.value

		if value.Type == "union" and #value:GetData() == 1 then
			value = value:GetData()[1]
		end

		do
			local upvalues = mut.scope:GetTrackedUpvalues()

			if upvalues then
				for _, data in ipairs(upvalues) do
					local stack = data.stack

					if stack then
						local val

						if mut.scope:IsElseConditionalScope() then
							val = stack[#stack].falsy
						else
							val = stack[#stack].truthy
						end

						if val and (val.Type ~= "union" or not val:IsEmpty()) then
							union:RemoveType(val)
						end
					end
				end
			end
		end

		-- IsCertain isn't really accurate and seems to be used as a last resort in case the above logic doesn't work
		if mut.certain_override or mut.scope:IsCertainFromScope(scope) then
			union:Clear()
		end

		if
			union:Get(value) and
			value.Type ~= "any" and
			mutations[1].value.Type ~= "union" and
			mutations[1].value.Type ~= "function" and
			mutations[1].value.Type ~= "any"
		then
			union:RemoveType(mutations[1].value)
		end

		if _ == 1 and value.Type == "union" then
			union = value:Copy()

			if obj.Type == "upvalue" then union:SetUpvalue(obj) end
		else
			union:AddType(value)
		end
	end

	local value = union

	if #union:GetData() == 1 then
		value = union:GetData()[1]

		if obj.Type == "upvalue" then value:SetUpvalue(obj) end

		return value
	end

	local found_scope, data = scope:FindResponsibleConditionalScopeFromUpvalue(obj)

	if not found_scope or not data.stack then return value end

	local stack = data.stack

	if
		found_scope:IsElseConditionalScope() or
		(
			found_scope ~= scope and
			scope:IsPartOfTestStatementAs(found_scope)
		)
	then
		local union = stack[#stack].falsy

		if union:GetLength() == 0 then
			union = Union()

			for _, val in ipairs(stack) do
				union:AddType(val.falsy)
			end
		end

		if obj.Type == "upvalue" then union:SetUpvalue(obj) end

		return union
	end

	local union = Union()

	for _, val in ipairs(stack) do
		union:AddType(val.truthy)
	end

	if obj.Type == "upvalue" then union:SetUpvalue(obj) end

	return union
end

return mutation_solver end ]=======], '@./nattlua/analyzer/mutation_solver.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.table"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local setmetatable = _G.setmetatable
local table = _G.table
local ipairs = _G.ipairs
local tostring = _G.tostring
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local Number = IMPORTS['nattlua.types.number']("nattlua.types.number").Number
local LNumber = IMPORTS['nattlua.types.number']("nattlua.types.number").LNumber
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")
local context = IMPORTS['nattlua.analyzer.context']("nattlua.analyzer.context")
local shallow_copy = IMPORTS['nattlua.other.shallow_copy']("nattlua.other.shallow_copy")
local mutation_solver = IMPORTS['nattlua.analyzer.mutation_solver']("nattlua.analyzer.mutation_solver")
META.Type = "table"



META:GetSet("Data", nil)
META:GetSet("BaseTable", nil)
META:GetSet("ReferenceId", nil)
META:GetSet("Self", nil)
META:GetSet("Contracts", nil)
META:GetSet("CreationScope", nil)

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

function META.Equal(a, b)
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

function META:GetLength(analyzer)
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

function META:FollowsContract(contract)
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

function META.IsSubsetOf(a, b)
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

function META:ContainsAllKeysIn(contract)
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

function META:Delete(key)
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

function META:HasKey(key)
	return self:FindKeyValReverse(key)
end

function META:IsEmpty()
	if self:GetContract() then return false end

	return self:GetData()[1] == nil
end

function META:FindKeyVal(key)
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

function META:FindKeyValReverse(key)
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

function META:FindKeyValReverseEqual(key)
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

function META:Insert(val)
	self.size = self.size or LNumber(1)
	self:Set(self.size:Copy(), val)
	self.size:SetData(self.size:GetData() + 1)
end

function META:Set(key, val, no_delete)
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

function META:SetExplicit(key, val)
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

function META:Get(key)
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

function META:CoerceUntypedFunctions(from)
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

function META:Copy(map, copy_tables)
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

local function unpack_keyval(keyval)
	local key, val = keyval.key, keyval.val
	return key, val
end

function META.Extend(a, b)
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

function META.Union(a, b)
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

function META:PrefixOperator(op)
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

		if done[self] then return done[self] end

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

return {Table = META.New} end ]=======], '@./nattlua/types/table.lua'))())(...) return __M end end
IMPORTS['nattlua/definitions/lua/globals.nlua'] = assert(loadstring([=======[ return function() 
















_G.arg = _

























































function _G.LSX(
	tag,
	constructor,
	props,
	children
)
	local e = constructor and
		constructor(props, children) or
		{
			props = props,
			children = children,
		}
	e.tag = tag
	return e
end end ]=======], '@nattlua/definitions/lua/globals.nlua'))()
IMPORTS['nattlua/definitions/lua/io.nlua'] = assert(loadstring([=======[ return function() 










 end ]=======], '@nattlua/definitions/lua/io.nlua'))()
IMPORTS['nattlua/definitions/lua/luajit.nlua'] = assert(loadstring([=======[ return function() 

 end ]=======], '@nattlua/definitions/lua/luajit.nlua'))()
IMPORTS['nattlua/definitions/lua/debug.nlua'] = assert(loadstring([=======[ return function() 


 end ]=======], '@nattlua/definitions/lua/debug.nlua'))()
IMPORTS['nattlua/definitions/lua/package.nlua'] = assert(loadstring([=======[ return function()  end ]=======], '@nattlua/definitions/lua/package.nlua'))()
IMPORTS['nattlua/definitions/lua/bit.nlua'] = assert(loadstring([=======[ return function() 


do
	

	

	

	

	

	

	

	

	

	

	

	
end end ]=======], '@nattlua/definitions/lua/bit.nlua'))()
IMPORTS['nattlua/definitions/lua/table.nlua'] = assert(loadstring([=======[ return function() 















function table.destructure(tbl, fields, with_default)
	local out = {}

	for i, key in ipairs(fields) do
		out[i] = tbl[key]
	end

	if with_default then table.insert(out, 1, tbl) end

	return table.unpack(out)
end

function table.mergetables(tables)
	local out = {}

	for i, tbl in ipairs(tables) do
		for k, v in pairs(tbl) do
			out[k] = v
		end
	end

	return out
end

function table.spread(tbl)
	if not tbl then return nil end

	return table.unpack(tbl)
end end ]=======], '@nattlua/definitions/lua/table.nlua'))()
IMPORTS['nattlua/definitions/lua/string.nlua'] = assert(loadstring([=======[ return function() 

























 end ]=======], '@nattlua/definitions/lua/string.nlua'))()
IMPORTS['nattlua/definitions/lua/math.nlua'] = assert(loadstring([=======[ return function() 























 end ]=======], '@nattlua/definitions/lua/math.nlua'))()
IMPORTS['nattlua/definitions/lua/os.nlua'] = assert(loadstring([=======[ return function()  end ]=======], '@nattlua/definitions/lua/os.nlua'))()
IMPORTS['nattlua/definitions/lua/coroutine.nlua'] = assert(loadstring([=======[ return function() 







 end ]=======], '@nattlua/definitions/lua/coroutine.nlua'))()
do local __M; IMPORTS["nattlua.other.table_print"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local pairs = _G.pairs
local tostring = _G.tostring
local type = _G.type
local debug = _G.debug
local table = _G.table
local tonumber = _G.tonumber
local pcall = _G.pcall
local assert = _G.assert
local load = _G.load
local setfenv = _G.setfenv
local io = _G.io
local luadata = {}
local encode_table
local loadstring = IMPORTS['nattlua.other.loadstring']("nattlua.other.loadstring")

local function count(tbl)
	local i = 0

	for _ in pairs(tbl) do
		i = i + 1
	end

	return i
end

local tostringx

do
	local pretty_prints = {}
	pretty_prints.table = function(t)
		local str = tostring(t)
		str = str .. " [" .. count(t) .. " subtables]"
		-- guessing the location of a library
		local sources = {}

		for _, v in pairs(t) do
			if type(v) == "function" then
				local info = debug.getinfo(v)

				if info then
					local src = info.source
					sources[src] = (sources[src] or 0) + 1
				end
			end
		end

		local tmp = {}

		for k, v in pairs(sources) do
			table.insert(tmp, {k = k, v = v})
		end

		table.sort(tmp, function(a, b)
			return a.v > b.v
		end)

		if #tmp > 0 and tmp[1] then
			str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]"
		end

		return str
	end
	pretty_prints["function"] = function(self)
		if debug.getprettysource then
			return (
				"function[%p][%s](%s)"
			):format(
				self,
				debug.getprettysource(self, true),
				table.concat(debug.getparams(self), ", ")
			)
		end

		return tostring(self)
	end

	function tostringx(val)
		local t = type(val)
		local f = pretty_prints[t]

		if f then return f(val) end

		return tostring(val)
	end
end

local function getprettysource(level, append_line)
	local info = debug.getinfo(type(level) == "number" and (level + 1) or level)

	if info then
		if info.source == "=[C]" and type(level) == "number" then
			info = debug.getinfo(type(level) == "number" and (level + 2) or level)
		end
	end

	local pretty_source = "debug.getinfo = nil"

	if info then
		if info.source:sub(1, 1) == "@" then
			pretty_source = info.source:sub(2)

			if append_line then
				local line = info.currentline

				if line == -1 then line = info.linedefined end

				pretty_source = pretty_source .. ":" .. line
			end
		else
			pretty_source = info.source:sub(0, 25)

			if pretty_source ~= info.source then
				pretty_source = pretty_source .. "...(+" .. #info.source - #pretty_source .. " chars)"
			end

			if pretty_source == "=[C]" and jit.vmdef then
				local num = tonumber(tostring(info.func):match("#(%d+)") or "")

				if num then pretty_source = jit.vmdef.ffnames[num] end
			end
		end
	end

	return pretty_source
end

local function getparams(func)
	local params = {}

	for i = 1, math.huge do
		local key = debug.getlocal(func, i)

		if key then table.insert(params, key) else break end
	end

	return params
end

local function isarray(t)
	local i = 0

	for _ in pairs(t) do
		i = i + 1

		if t[i] == nil then return false end
	end

	return true
end

local env = {}
luadata.Types = {}

local idx = function(var)
	return var.LuaDataType
end

function luadata.Type(var)
	local t = type(var)

	if t == "table" then
		local ok, res = pcall(idx, var)

		if ok and res then return res end
	end

	return t
end



function luadata.ToString(var, context)
	context = context or {tab = -1}
	local func = luadata.Types[luadata.Type(var)]

	if func then return func(var, context) end

	if luadata.Types.fallback then return luadata.Types.fallback(var, context) end
end

function luadata.FromString(str)
	local func = assert(loadstring("return " .. str), "luadata")
	setfenv(func, env)
	return func()
end

function luadata.Encode(tbl)
	return luadata.ToString(tbl)
end

function luadata.Decode(str)
	local func, err = loadstring("return {\n" .. str .. "\n}", "luadata")

	if not func then return func, err end

	setfenv(func, env)
	local ok, err = pcall(func)

	if not ok then return func, err end

	return err
end

function luadata.SetModifier(
	type,
	callback,
	func,
	func_name
)
	luadata.Types[type] = callback

	if func_name then env[func_name] = func end
end

luadata.SetModifier("cdata", function(var)
	return tostring(var)
end)

luadata.SetModifier("number", function(var)
	return ("%s"):format(var)
end)

luadata.SetModifier("string", function(var)
	return ("%q"):format(var)
end)

luadata.SetModifier("boolean", function(var)
	return var and "true" or "false"
end)

luadata.SetModifier("function", function(var)
	return (
		"function(%s) --[==[ptr: %p    src: %s]==] end"
	):format(table.concat(getparams(var), ", "), var, getprettysource(var, true))
end)

luadata.SetModifier("fallback", function(var)
	return "--[==[  " .. tostringx(var) .. "  ]==]"
end)

luadata.SetModifier("table", function(tbl, context)
	local str = {}

	if context.tab_limit and context.tab >= context.tab_limit then
		return "{--[[ " .. tostringx(tbl) .. " (tab limit reached)]]}"
	end

	if context.done then
		if context.done[tbl] then
			return ("{--[=[%s already serialized]=]}"):format(tostring(tbl))
		end

		context.done[tbl] = true
	end

	context.tab = context.tab + 1

	if context.tab == 0 then str = {} else str = {"{\n"} end

	if isarray(tbl) then
		if #tbl == 0 then
			str = {"{"}
		else
			for i = 1, #tbl do
				str[#str + 1] = ("%s%s,\n"):format(("\t"):rep(context.tab), luadata.ToString(tbl[i], context))
			end
		end
	else
		for key, value in pairs(tbl) do
			value = luadata.ToString(value, context)

			if value then
				if type(key) == "string" and key:find("^[%w_]+$") and not tonumber(key) then
					str[#str + 1] = ("%s%s = %s,\n"):format(("\t"):rep(context.tab), key, value)
				else
					key = luadata.ToString(key, context)

					if key then
						str[#str + 1] = ("%s[%s] = %s,\n"):format(("\t"):rep(context.tab), key, value)
					end
				end
			end
		end
	end

	if context.tab == 0 then
		if str[1] == "{" then
			str[#str + 1] = "}" -- empty table
		else
			str[#str + 1] = "\n"
		end
	else
		if str[1] == "{" then
			str[#str + 1] = "}" -- empty table
		else
			str[#str + 1] = ("%s}"):format(("\t"):rep(context.tab - 1))
		end
	end

	context.tab = context.tab - 1
	return table.concat(str, "")
end)

return function(...)
	local tbl = {...}
	local max_level

	if
		type(tbl[1]) == "table" and
		type(tbl[2]) == "number" and
		type(tbl[3]) == "nil"
	then
		max_level = tbl[2]
		tbl[2] = nil
	end

	io.write(luadata.ToString(tbl, {tab = -1, tab_limit = max_level, done = {}}):sub(0, -2))
end end ]=======], '@./nattlua/other/table_print.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.cparser"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local pcall = _G.pcall
local type = _G.type
local getmetatable = _G.getmetatable
local tostring = _G.tostring
local pairs = _G.pairs
local assert = _G.assert
local setmetatable = _G.setmetatable
local ipairs = _G.ipairs
local error = _G.error
local print = _G.print
local load = _G.load
local math = _G.math
local tonumber = _G.tonumber
local rawget = _G.rawget
local os = _G.os
-- Copyright (c) Facebook, Inc. and its affiliates.
-- This source code is licensed under the MIT license found in the
-- LICENSE file in the root directory of this source tree.
--
-- Lua module to preprocess and parse C declarations.
-- (Leon Bottou, 2015)
-- standard libs
local string = _G.string
local coroutine = _G.coroutine
local table = _G.table
local io = _G.io
-- Lua 5.1 to 5.3 compatibility
local unpack = unpack or table.unpack
-- Debugging
local DEBUG = true

if DEBUG then pcall(require, "strict") end

-- luacheck: globals cparser
-- luacheck: ignore 43 4/ti 4/li
-- luacheck: ignore 212/.*_
-- luacheck: ignore 211/is[A-Z].* 211/Type
-- luacheck: ignore 542
---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- ALL UGLY HACKS SHOULD BE HERE
-- Sometimes we cannot find system include files but need to know at
-- least things about them. For instance, certain system include files
-- define alternate forms for keywords.
local knownIncludeQuirks = {}
knownIncludeQuirks["<complex.h>"] = { -- c99
	"#ifndef complex",
	"# define complex _Complex",
	"#endif",
}
knownIncludeQuirks["<stdbool.h>"] = { -- c99
	"#ifndef bool",
	"# define bool _Bool",
	"#endif",
}
knownIncludeQuirks["<stdalign.h>"] = { -- c11
	"#ifndef alignof",
	"# define alignof _Alignof",
	"#endif",
	"#ifndef alignas",
	"# define alignas _Alignas",
	"#endif",
}
knownIncludeQuirks["<stdnoreturn.h>"] = { -- c11
	"#ifndef noreturn",
	"# define noreturn _Noreturn",
	"#endif",
}
knownIncludeQuirks["<threads.h>"] = { -- c11
	"#ifndef thread_local",
	"# define thread_local _Thread_local",
	"#endif",
}
knownIncludeQuirks["<iso646.h>"] = { -- c++
	"#define and &&",
	"#define and_eq &=",
	"#define bitand &",
	"#define bitor |",
	"#define compl ~",
	"#define not !",
	"#define not_eq !=",
	"#define or ||",
	"#define or_eq |=",
	"#define xor ^",
	"#define xor_eq ^=",
}

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- TAGGED TABLES
-- Utilities to produce and print tagged tables.
-- The tag name is simply the contents of table key <tag>.
-- Function <newTag> returns a node constructor
--
-- Example:
--
-- > Foo = newTag('Foo')
-- > Bar = newTag('Bar')
--
-- > print( Foo{const=true,next=Bar{name="Hello"}} )
-- Foo{next=Bar{name="Hello"},const=true}
--
-- > print( Bar{name="hi!", Foo{1}, Foo{2}, Foo{3}} )
-- Bar{Foo{1},Foo{2},Foo{3},name="hi!"}
local function newTag(tag)
	-- the printing function
	local function tostr(self)
		local function str(x)
			if type(x) == "string" then
				return string.format("%q", x):gsub("\\\n", "\\n")
			elseif type(x) == "table" and not getmetatable(x) then
				return "{..}"
			else
				return tostring(x)
			end
		end

		local p = string.format("%s{", self.tag or "Node")
		local s = {}
		local seqlen = 0

		for i = 1, #self do
			if self[i] then seqlen = i else break end
		end

		for i = 1, seqlen do
			s[1 + #s] = str(self[i])
		end

		for k, v in pairs(self) do
			if type(k) == "number" then
				if k < 1 or k > seqlen then
					s[1 + #s] = string.format("[%s]=%s", k, str(v))
				end
			elseif type(k) ~= "string" then
				s.extra = true
			elseif k:find("^_") and type(v) == "table" then
				s[1 + #s] = string.format("%s={..}", k) -- hidden
			elseif k ~= "tag" then
				s[1 + #s] = string.format("%s=%s", k, str(v))
			end
		end

		if s.extra then s[1 + #s] = "..." end

		return p .. table.concat(s, ",") .. "}"
	end

	-- the constructor
	return function(t) -- must be followed by a table constructor
		t = t or {}
		assert(type(t) == "table")
		setmetatable(t, {__tostring = tostr})
		t.tag = tag
		return t
	end
end

-- hack to print any table: print(Node(nn))
local Node = newTag(nil) -- luacheck: ignore 211
---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- UTILITIES
-- Many functions below have an optional argument 'options' which is
-- simply an array of compiler-like options that are specified in the
-- toplevel call and passed to nearly all functions. Because it
-- provides a good communication channel across the code components,
-- many named fields are also used for multiple purposes. The
-- following function is called at the beginning of the user facing
-- functions to make a copy of the user provided option array and
-- setup some of these fields.
local function copyOptions(options)
	options = options or {}
	assert(type(options) == "table")
	local noptions = {}

	-- copy options
	for k, v in ipairs(options) do
		noptions[k] = v
	end

	-- copy user modifiable named fields
	noptions.sizeof = options.sizeof -- not used yet
	noptions.alignof = options.alignof -- not used yet
	-- create reversed hash
	noptions.hash = {}

	for i, v in ipairs(options) do
		noptions.hash[v] = i
	end

	-- compute dialect flags
	local dialect = "gnu99"

	for _, v in ipairs(options) do
		if v:find("^%-std=%s*[^%s]") then
			dialect = v:match("^%-std=%s*(.-)%s*$")
		end
	end

	noptions.dialect = dialect
	noptions.dialectGnu = dialect:find("^gnu")
	noptions.dialect99 = dialect:find("9[9x]$")
	noptions.dialect11 = dialect:find("1[1x]$")
	noptions.dialectAnsi = not noptions.dialectGnu
	noptions.dialectAnsi = noptions.dialectAnsi and not noptions.dialect99
	noptions.dialectAnsi = noptions.dialectAnsi and not noptions.dialect11
	-- return
	return noptions
end

-- This function tests whether a particular option has been given.
local function hasOption(options, opt)
	assert(options)
	assert(options.silent or options.hash)
	return options.hash and options.hash[opt]
end

-- Generic functions for error messages
local function xmessage(err, options, lineno, message, ...)
	local msg = string.format("cparser: (%s) ", lineno)
	msg = msg .. string.format(message, ...)

	if options.silent then
		if err == "error" then error(msg, 0) end
	else
		if err == "warning" and hasOption(options, "-Werror") then err = "error" end

		if err == "error" or not hasOption(options, "-w") then print(msg) end

		if err == "error" then error("cparser: aborted", 0) end
	end
end

local function xwarning(options, lineno, message, ...)
	xmessage("warning", options, lineno, message, ...)
end

local function xerror(options, lineno, message, ...)
	xmessage("error", options, lineno, message, ...)
end

local function xassert(cond, ...)
	if not cond then xerror(...) end
end

local function xdebug(lineno, message, ...)
	local msg = string.format("\t\t[%s] ", lineno)
	msg = msg .. string.format(message, ...)
	print(msg)
end

-- Nil-safe max
local function max(a, b)
	a = a or b
	b = b or a
	return a > b and a or b
end

-- Deep table comparison
-- (not very efficient, no loop detection)
local function tableCompare(a, b)
	if a == b then
		return true
	elseif type(a) == "table" and type(b) == "table" then
		for k, v in pairs(a) do
			if not tableCompare(v, b[k]) then return false end
		end

		for k, v in pairs(b) do
			if not tableCompare(a[k], v) then return false end
		end

		return true
	else
		return false
	end
end

-- Concatenate two possibly null arrays
local function tableAppend(a1, a2)
	if not a1 then
		return a2
	elseif not a2 then
		return a1
	else
		local a = {}

		for _, v in ipairs(a1) do
			a[1 + #a] = v
		end

		for _, v in ipairs(a2) do
			a[1 + #a] = v
		end

		return a
	end
end

-- Concatenate strings from table (skipping non-string content.)
local function tableConcat(a)
	local b = {}

	for _, v in ipairs(a) do
		if type(v) == "string" then b[1 + #b] = v end
	end

	return table.concat(b)
end

-- Evaluate a lua expression, return nil on error.
local function evalLuaExpression(s)
	assert(type(s) == "string")
	local f = load(string.gmatch(s, ".*"))

	local function r(status, ...)
		if status then return ... end
	end

	return r(pcall(f or error))
end

-- Bitwise manipulations
-- try lua53 operators otherwise revert to iterative version
local bit = evalLuaExpression([[
   local bit = {}
   function bit.bnot(a) return ~a end
   function bit.bor(a,b) return a | b end
   function bit.band(a,b) return a & b end
   function bit.bxor(a,b) return a ~ b end
   function bit.lshift(a,b) return a < 0 and b < 0 and ~((~a) << b) or a << b end
   return bit
]])

if not bit then
	local function bor(a, b)
		local r, c, d = 0, 1, -1

		while a > 0 or b > 0 or a < -1 or b < -1 do
			if a % 2 > 0 or b % 2 > 0 then r = r + c end

			a, b, c, d = math.floor(a / 2), math.floor(b / 2), c * 2, d * 2
		end

		if a < 0 or b < 0 then r = r + d end

		return r
	end

	bit = {}

	function bit.bnot(a)
		return -1 - a
	end

	function bit.bor(a, b)
		return bor(a, b)
	end

	function bit.band(a, b)
		return -1 - bor(-1 - a, -1 - b)
	end

	function bit.bxor(a, b)
		return bor(-1 - bor(a, -1 - b), -1 - bor(-1 - a, b))
	end

	function bit.lshift(a, b)
		return math.floor(a * 2 ^ b)
	end
end

-- Coroutine helpers.
-- This code uses many coroutines that yield lines or tokens.
-- All functions that can yield take an options table as first argument.
-- Wrap a coroutine f into an iterator
-- The options and all the extra arguments are passed
-- to the coroutine when it starts. Together with the
-- above calling convention, this lets us specify
-- coroutine pipelines (see example in function "cpp".)
local function wrap(options, f, ...)
	local function g(...)
		coroutine.yield(nil)
		f(...)
	end

	local c = coroutine.create(g)
	coroutine.resume(c, options, ...)

	local function r(s, ...)
		if not s then
			local m = ...
			error(m, 0)
		end

		return ...
	end

	return function()
		if coroutine.status(c) ~= "dead" then return r(coroutine.resume(c)) end
	end
end

-- Collect coroutine outputs into an array
-- The options and the extra arguments are passed to the coroutine.
local function callAndCollect(options, f, ...) -- Bell Labs nostalgia
	local collect = {}

	for s in wrap(options, f, ...) do
		collect[1 + #collect] = s
	end

	return collect
end

-- Yields all outputs from iterator iter.
-- Argument options is ignored.
local function yieldFromIterator(options_, iter)
	local function yes(v, ...)
		coroutine.yield(v, ...)
		return v
	end

	while yes(iter()) do

	end
end

-- Yields all values from array <arr>.
-- This function successively yields all values in the table.
-- Every yield is augmented with all extra arguments passed to the function.
-- Argument options is ignored.
local function yieldFromArray(options_, arr, ...)
	for _, v in ipairs(arr) do
		coroutine.yield(v, ...)
	end
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- INITIAL PREPROCESSING
-- A routine that pulls lines from a line iterator
-- and yields them together with a location
-- composed of the optional prefix, a colon, and a line number.
-- Argument options is ignored.
-- Lua provides good line iterators such as:
--   io.lines(filename) filedesc:lines()  str:gmatch("[^\n]+")
local function yieldLines(options_, lineIterator, prefix)
	prefix = prefix or ""
	assert(type(prefix) == "string")
	local n = 0

	for s in lineIterator do
		n = n + 1
		coroutine.yield(s, string.format("%s:%d", prefix, n))
	end
end

-- A routine that obtains lines from coroutine <lines>,
-- joins lines terminated by a backslash, and yield the
-- resulting lines. The coroutine is initialized with
-- argument <options> and all extra arguments.
-- Reference: https://gcc.gnu.org/onlinedocs/cpp/Initial-processing.html (3)
local function joinLines(options, lines, ...)
	local li = wrap(options, lines, ...)

	for s, n in li do
		while type(s) == "string" and s:find("\\%s*$") do
			local t = li() or ""
			s = s:gsub("\\%s*$", "") .. t
		end

		coroutine.yield(s, n)
	end
end

-- A routine that obtain lines from coroutine <lines>, eliminate the
-- comments and yields the resulting lines.  The coroutine is
-- initialized with argument <options> and all extra arguments.
-- Reference: https://gcc.gnu.org/onlinedocs/cpp/Initial-processing.html (4)
local function eliminateComments(options, lines, ...)
	local lineIterator = wrap(options, lines, ...)
	local s, n = lineIterator()

	while type(s) == "string" do
		local inString = false
		local q = s:find("[\'\"\\/]", 1)

		while q ~= nil do
			if hasOption(options, "-d:comments") then
				xdebug(n, "comment: [%s][%s] %s", s:sub(1, q - 1), s:sub(q), inString)
			end

			local c = s:byte(q)

			if inString then
				if c == 92 then -- \
					q = q + 1
				elseif c == inString then
					inString = false
				end
			else
				if c == 34 or c == 39 then -- " or '
					inString = c
				elseif c == 47 and s:byte(q + 1) == 47 then -- "//"
					s = s:sub(1, q - 1)
				elseif c == 47 and s:byte(q + 1) == 42 then -- "/*"
					local p = s:find("%*/", q + 2)

					if p ~= nil then
						s = s:sub(1, q - 1) .. " " .. s:sub(p + 2)
					else
						s = s:sub(1, q - 1)
						local ss, pp

						repeat
							ss = lineIterator()
							xassert(ss ~= nil, options, n, "Unterminated comment")
							pp = ss:find("%*/")						until pp

						s = s .. " " .. ss:sub(pp + 2)
					end
				end
			end

			q = s:find("[\'\"\\/]", q + 1)
		end

		coroutine.yield(s, n)
		s, n = lineIterator()
	end
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- TOKENIZER
local keywordTable = {
	------ Standard keywords
	"auto",
	"break",
	"case",
	"char",
	"const",
	"continue",
	"default",
	"do",
	"double",
	"else",
	"enum",
	"extern",
	"float",
	"for",
	"goto",
	"if",
	"int",
	"long",
	"register",
	"return",
	"short",
	"signed",
	"sizeof",
	"static",
	"struct",
	"switch",
	"typedef",
	"union",
	"unsigned",
	"void",
	"volatile",
	"while",
------ Nonstandard or dialect specific keywords do not belong here
------ because the main function of this table is to say which
------ identifiers cannot be variable names.
}
local punctuatorTable = {
	"+",
	"-",
	"*",
	"/",
	"%",
	"&",
	"|",
	"^",
	">>",
	"<<",
	"~",
	"=",
	"+=",
	"-=",
	"*=",
	"/=",
	"%=",
	"&=",
	"|=",
	"^=",
	">>=",
	"<<=",
	"(",
	")",
	"[",
	"]",
	"{",
	"}",
	"++",
	"--",
	"==",
	"!=",
	">=",
	"<=",
	">",
	"<",
	"&&",
	"||",
	"!",
	".",
	"->",
	"*",
	"&",
	"?",
	":",
	"::",
	"->*",
	".*",
	";",
	",",
	"#",
	"##",
	"...",
	"@",
	"\\", -- preprocessor stuff
}
local keywordHash = {}

for _, v in ipairs(keywordTable) do
	keywordHash[v] = true
end

local punctuatorHash = {}

for _, v in ipairs(punctuatorTable) do
	local l = v:len()
	local b = v:byte()
	punctuatorHash[v] = true
	punctuatorHash[b] = max(l, punctuatorHash[b])
end

-- The following functions test the types of the tokens returned by the tokenizer.
-- They should not be applied to arbitrary strings.
local function isSpace(tok)
	return type(tok) == "string" and tok:find("^%s") ~= nil
end

local function isNewline(tok) -- Subtype of space
	return type(tok) == "string" and tok:find("^\n") ~= nil
end

local function isNumber(tok)
	return type(tok) == "string" and tok:find("^[.0-9]") ~= nil
end

local function isString(tok)
	if type(tok) ~= "string" then return false end

	return tok:find("^[\'\"]") ~= nil
end

local function isHeaderName(tok)
	if type(tok) ~= "string" then return false end

	return tok:find("^\"") or tok:find("^<") and tok:find(">$")
end

local function isPunctuator(tok)
	return type(tok) == "string" and punctuatorHash[tok] ~= nil
end

local function isIdentifier(tok)
	return type(tok) == "string" and tok:find("^[A-Za-z_$]") ~= nil
end

local function isKeyword(tok) -- Subtype of identifier
	return keywordHash[tok] ~= nil
end

local function isName(tok) -- Subtype of identifier
	return isIdentifier(tok) and not keywordHash[tok]
end

-- Magic tokens are used to mark macro expansion boundaries (see expandMacros.)
local function isMagic(tok)
	return tok and type(tok) ~= "string"
end

local function isBlank(tok) -- Treats magic token as space.
	return isMagic(tok) or isSpace(tok)
end

-- The tokenizeLine() function takes a line, splits it into tokens,
-- and yields tokens and locations. The number tokens are the weird
-- preprocessor numbers defined by ansi c. The string tokens include
-- character constants and angle-bracket delimited strings occuring
-- after an include directive. Every line begins with a newline
-- token giving the proper indentation. All subsequent spaces
-- are reduced to a single space character.
local function tokenizeLine(options, s, n, notNewline)
	-- little optimization for multiline macros
	-- s may be an array of precomputed tokens
	if type(s) == "table" then return yieldFromArray(options, s, n) end

	-- normal operation
	assert(type(s) == "string")
	local p = s:find("[^%s]")

	-- produce a newline token
	if p and not notNewline then
		local r = "\n" .. s:sub(1, p - 1)
		coroutine.yield(r, n)
	end

	-- produce one token
	local function token()
		local b, l, r

		if hasOption(options, "-d:tokenize") then
			xdebug(n, "[%s][%s]", s:sub(1, p - 1), s:sub(p))
		end

		-- space
		l = s:find("[^%s]", p)

		if l == nil then
			return nil
		elseif l > p then
			p = l
			return " ", n
		end

		-- identifier
		r = s:match("^[a-zA-Z_$][a-zA-Z0-9_$]*", p)

		if r ~= nil then
			p = p + r:len()
			return r, n
		end

		-- preprocessor numbers
		r = s:match("^%.?[0-9][0-9a-zA-Z._]*", p)

		if r ~= nil then
			l = r:len()

			while r:find("[eEpP]$") and s:find("^[-+]", p + l) do
				r = r .. s:match("^[-+][0-9a-zA-Z._]*", p + l)
				l = r:len()
			end

			p = p + l
			return r, n
		end

		-- angle-delimited strings in include directives
		b = s:byte(p)

		if b == 60 and s:find("^%s*#%s*include") then
			r = s:match("^<[^>]+>", p)

			if r ~= nil then
				p = p + r:len()
				return r, n
			end
		end

		-- punctuator
		l = punctuatorHash[b]

		if l ~= nil then
			while l > 0 do
				r = s:sub(p, p + l - 1)

				if punctuatorHash[r] then
					p = p + l
					return r, n
				end

				l = l - 1
			end
		end

		-- string
		if b == 34 or b == 39 then -- quotes
			local q = p

			repeat
				q = s:find("[\'\"\\]", q + 1)
				l = s:byte(q)
				xassert(q ~= nil, options, n, "Unterminated string or character constant")

				if l == 92 then q = q + 1 end			until l == b

			r = s:sub(p, q)
			p = q + 1
			return r, n
		end

		-- other stuff (we prefer to signal an error here)
		xerror(options, n, "Unrecognized character (%s)", s:sub(p))
	end

	-- loop
	if p then for tok, tokn in token do
		coroutine.yield(tok, tokn)
	end end
end

-- Obtain lines from coroutine <lines>,
-- and yields their tokens. The coroutine is initialized with
-- argument <options> and all extra arguments.
local function tokenize(options, lines, ...)
	for s, n in wrap(options, lines, ...) do
		tokenizeLine(options, s, n)
	end
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- PREPROCESSING
-- Preprocessing is performed by two coroutines. The first one
-- processes all the preprocessor directives and yields the remaining
-- lines. The second one processes tokens from the remaining lines and
-- perform macro expansions. Both take a table of macro definitions as
-- argument. The first one writes into the table and the second one
-- reads from it.
--
-- Each macro definition is an array of tokens (for a single line
-- macro) or a table whose entry <"lines"> contains an array of arrays
-- of tokens (#defmacro). If the macro takes arguments, the entry
-- <"args"> contains a list of argument names. If the macro is
-- recursive (#defrecmacro), the entry <recursive> is set.
-- Alternatively, the macro definition may be a function called at
-- macro-expansion time. This provides for complicated situations.
-- forward declarations
local function expandMacros() end

local function processDirectives() end

-- Starting with the second coroutine which takes a token producing
-- coroutine and yields the preprocessed tokens. Argument macros is
-- the macro definition table.
-- The standard mandates that the result of a macro-expansion must be
-- scanned for further macro invocations whose argunent list possibly
-- consume tokens that follow the macro-expansion. This means that one
-- cannot recursively call expandMacros but one must prepend the
-- macro-expansion in front of the remaining tokens. The standard also
-- mandates that the result of any macro-expansion must be marked to
-- prevent recursive invocation of the macro that generated it,
-- whether when expanding macro arguments or expanding the macro
-- itself.  We achieve this by bracketing every macro-expansion with
-- magic tokens that track which macro definitions must be disabled.
-- These magic tokens are removed later in the coroutines
-- <filterSpaces> or <preprocessedLines>.
expandMacros = function(options, macros, tokens, ...)
	-- basic iterator
	local ti = wrap(options, tokens, ...)
	-- prepending tokens in front of the token stream
	local prepend = {}

	local function prependToken(s, n)
		table.insert(prepend, {s, n})
	end

	local function prependTokens(pti)
		local pos = 1 + #prepend

		for s, n in pti do
			table.insert(prepend, pos, {s, n})
		end
	end

	local ti = function()
		if #prepend > 0 then
			return unpack(table.remove(prepend))
		else
			return ti()
		end
	end
	-- iterator that handles magic tokens to update macro definition table
	local ti = function()
		local s, n = ti()

		while type(s) == "table" do
			if s.tag == "push" then
				local nmacros = {}
				setmetatable(nmacros, {__index = macros})

				if s.symb then nmacros[s.symb] = false end

				macros = nmacros
			elseif s.tag == "pop" then
				local mt = getmetatable(macros)

				if mt and mt.__index then macros = mt.__index end
			end

			coroutine.yield(s, n)
			s, n = ti()
		end

		return s, n
	end
	-- redefine ti() to ensure tok,n remain up-to-date
	local tok, n = ti()
	local ti = function()
		tok, n = ti()
		return tok, n
	end

	-- collect one macro arguments into an array
	-- stop when reaching a closing parenthesis or a comma
	local function collectArgument(ti, varargs)
		local count = 0
		local tokens = {}
		ti()

		while isSpace(tok) do
			tok = ti()
		end

		while tok do
			if tok == ")" and count == 0 then
				break
			elseif tok == ")" then
				count = count - 1
			elseif tok == "(" then
				count = count + 1
			elseif tok == "," and count == 0 and not varargs then
				break
			end

			if isSpace(tok) then tok = " " end

			tokens[1 + #tokens] = tok
			tok = ti()
		end

		if #tokens > 0 and isSpace(tokens[#tokens]) then tokens[#tokens] = nil end

		return tokens
	end

	-- collects all macro arguments
	local function collectArguments(ti, def, ntok, nn)
		local args = def.args
		local nargs = {[0] = {}}

		if #args == 0 then ti() end

		for _, name in ipairs(args) do
			if tok == ")" and name == "__VA_ARGS__" then
				nargs[0][name] = {negComma = true}
				nargs[name] = {negComma = true}
			else
				xassert(
					tok == "(" or tok == ",",
					options,
					nn,
					"not enough arguments for macro '%s'",
					ntok
				)
				local arg = collectArgument(ti, name == "__VA_ARGS__")
				nargs[0][name] = arg
				nargs[name] = callAndCollect(options, expandMacros, macros, yieldFromArray, arg, nn)
			end
		end

		if def.nva then -- named variadic argument (implies dialectGnu)
			nargs[def.nva] = nargs["__VA_ARGS__"]
			nargs[0][def.nva] = nargs[0]["__VA_ARGS__"]
		end

		xassert(tok, options, nn, "unterminated arguments for macro '%s'", ntok)
		xassert(tok == ")", options, nn, "too many arguments for macro '%s'", ntok)
		return nargs
	end

	-- coroutine that substitute the macro arguments
	-- and stringification and concatenation are handled here
	local function substituteArguments(options, def, nargs, n, inDirective)
		local uargs = nargs[0] or nargs -- unexpanded argument values
		if inDirective then nargs = uargs end -- use unexpanded arguments in directives
		-- prepare loop
		local i, j, k = 1, 1, 1

		while def[i] do
			if isBlank(def[i]) then
				-- copy blanks
				coroutine.yield(def[i], n)
			else
				-- positions j and k on next non-space tokens
				local function updateJandK()
					if j <= i then
						j = i

						repeat
							j = j + 1						until def[j] == nil or not isBlank(def[j])
					end

					if k <= j then
						k = j

						repeat
							k = k + 1						until def[k] == nil or not isBlank(def[k])
					end
				end

				updateJandK()

				-- alternatives
				if def[i] == "#" and def[j] and nargs[def[j]] then
					-- stringification (with the weird quoting rules)
					local v = {"\""}

					for _, t in ipairs(uargs[def[j]]) do
						if type(t) == "string" then
							if t:find("^%s+$") then t = " " end

							if t:find("^[\'\"]") then
								t = string.format("%q", t):sub(2, -2)
							end

							v[1 + #v] = t
						end
					end

					v[1 + #v] = "\""
					coroutine.yield(tableConcat(v), n)
					i = j
				elseif def.nva and def[i] == "," and def[j] == "##" and def[k] == def.nva then
					-- named variadic macro argument with ## to signal negative comma (gcc crap)
					if nargs[def.nva].negComma then i = i + 1 end

					while i < j do
						coroutine.yield(def[i], n)
						i = i + 1
					end
				elseif def[i] == "," and def[j] == "__VA_ARGS__" and def[k] == ")" then
					-- __VA_ARGS__ with implied negative comma semantics
					if nargs[def[j]].negComma then i = i + 1 end

					while i < j do
						coroutine.yield(def[i], n)
						i = i + 1
					end

					i = j - 1
				elseif def[j] == "##" and def[k] and not inDirective then
					-- concatenation
					local u = {}

					local function addToU(s)
						if nargs[s] then
							for _, v in ipairs(uargs[s]) do
								u[1 + #u] = v
							end
						else
							u[1 + #u] = s
						end
					end

					addToU(def[i])

					while def[j] == "##" and def[k] do
						addToU(def[k])
						i = k
						updateJandK()
					end

					tokenizeLine(options, tableConcat(u), n, true)
				elseif nargs[def[i]] then
					-- substitution
					yieldFromArray(options, nargs[def[i]], n)
				else
					-- copy
					coroutine.yield(def[i], n)
				end
			end

			i = i + 1
		end
	end

	-- main loop
	local newline, directive = true, false

	while tok ~= nil do
		-- detects Zpassed directives
		if newline and tok == "#" then
			newline, directive = false, true
		elseif not isBlank(tok) then
			newline = false
		elseif isNewline(tok) then
			newline, directive = true, false
		end

		-- process code
		local def = macros[tok]

		if not def or directive then
			-- not a macro
			coroutine.yield(tok, n)
		elseif type(def) == "function" then
			-- magic macro
			def(ti, tok, n)
		elseif def.args == nil then
			-- object-like macro
			prependToken({tag = "pop"}, n)
			prependTokens(wrap(options, substituteArguments, def, {}, n))
			prependToken({tag = "push", symb = tok}, n)
		else
			-- function-like macro
			local ntok, nn = tok, n
			local spc = false
			ti()

			if isSpace(tok) then
				spc = true
				ti()
			end

			if (tok ~= "(") then
				coroutine.yield(ntok, nn)

				if spc then coroutine.yield(" ", n) end

				if tok then prependToken(tok, n) end
			else
				local nargs = collectArguments(ti, def, ntok, nn)

				if def.lines == nil then
					-- single-line function-like macro
					prependToken({tag = "pop"}, n)
					prependTokens(wrap(options, substituteArguments, def, nargs, nn))
					prependToken({tag = "push", symb = ntok}, nn)
				else
					-- multi-line function-like macro
					local lines = def.lines

					-- a coroutine that yields the macro definition
					local function yieldMacroLines()
						local count = 0

						for i = 1, #lines, 2 do
							local ls, ln = lines[i], lines[i + 1]
							-- are we possibly in a cpp directive
							local dir = false

							if ls[2] and ls[2]:find("^#") then
								dir = isIdentifier(ls[3]) and ls[3] or ls[4]
							end

							if dir and nargs[dir] then
								dir = false -- leading stringification
							elseif dir == "defmacro" then
								count = count + 1 -- entering a multiline macto
							elseif dir == "endmacro" then
								count = count - 1 -- leaving a multiline macro
							end

							dir = dir or count > 0
							-- substitute
							ls = callAndCollect(
								options,
								substituteArguments,
								ls,
								nargs,
								ln,
								dir
							)
							-- compute lines (optimize speed by passing body lines as tokens)
							local j = 1

							while isBlank(ls[j]) do
								j = j + 1
							end

							if ls[j] and ls[j]:find("^#") then -- but not directives
								ls = ls[1]:sub(2) .. tableConcat(ls, nil, 2)
							end

							coroutine.yield(ls, ln)
						end
					end

					-- recursively reenters preprocessing subroutines in order to handle
					-- preprocessor directives located inside the macro expansion. As a result
					-- we cannot expand macro invocations that extend beyond the macro-expansion.
					local nmacros = {}
					setmetatable(nmacros, {__index = macros})

					if not def.recursive then nmacros[ntok] = false end

					if not def.recursive then
						coroutine.yield({tag = "push", symb = ntok})
					end

					expandMacros(
						options,
						nmacros,
						tokenize,
						processDirectives,
						nmacros,
						yieldMacroLines
					)

					if not def.recursive then coroutine.yield({tag = "pop"}) end
				end
			end
		end

		ti()
	end
end

-- Processing conditional directive requires evaluating conditions
-- This function takes an iterator on preprocessed expression tokens
-- and computes the value. This does not handle defined(X) expressions.
-- Optional argument resolver is a function that takes an indentifer
-- name and returns a value. Otherwise zero is assumed
local function evaluateCppExpression(options, tokenIterator, n, resolver)
	-- redefine token iterator to skip spaces and update tok
	local tok

	local function ti()
		repeat
			tok = tokenIterator()		until not isBlank(tok)

		return tok
	end

	-- operator tables
	local unaryOps = {
		["!"] = function(v)
			return v == 0 and 1 or 0
		end,
		["~"] = function(v)
			return bit.bnot(v)
		end,
		["+"] = function(v)
			return v
		end,
		["-"] = function(v)
			return -v
		end,
	}
	local binaryOps = {
		["*"] = function(a, b)
			return a * b
		end,
		["/"] = function(a, b)
			xassert(b ~= 0, options, n, "division by zero")
			return math.floor(a / b)
		end,
		["%"] = function(a, b)
			xassert(b ~= 0, options, n, "division by zero")
			return a % b
		end,
		["+"] = function(a, b)
			return a + b
		end,
		["-"] = function(a, b)
			return a - b
		end,
		[">>"] = function(a, b)
			return bit.lshift(a, -b)
		end,
		["<<"] = function(a, b)
			return bit.lshift(a, b)
		end,
		[">="] = function(a, b)
			return a >= b and 1 or 0
		end,
		["<="] = function(a, b)
			return a <= b and 1 or 0
		end,
		[">"] = function(a, b)
			return a > b and 1 or 0
		end,
		["<"] = function(a, b)
			return a < b and 1 or 0
		end,
		["=="] = function(a, b)
			return a == b and 1 or 0
		end,
		["!="] = function(a, b)
			return a ~= b and 1 or 0
		end,
		["&"] = function(a, b)
			return bit.band(a, b)
		end,
		["^"] = function(a, b)
			return bit.bxor(a, b)
		end,
		["|"] = function(a, b)
			return bit.bor(a, b)
		end,
		["&&"] = function(a, b)
			return (a ~= 0 and b ~= 0) and 1 or 0
		end,
		["||"] = function(a, b)
			return (a ~= 0 or b ~= 0) and 1 or 0
		end,
	}
	local binaryPrec = {
		["*"] = 1,
		["/"] = 1,
		["%"] = 1,
		["+"] = 2,
		["-"] = 2,
		[">>"] = 3,
		["<<"] = 3,
		[">="] = 4,
		["<="] = 4,
		["<"] = 4,
		[">"] = 4,
		["=="] = 5,
		["!="] = 5,
		["&"] = 6,
		["^"] = 7,
		["|"] = 8,
		["&&"] = 9,
		["||"] = 10,
	}

	-- forward
	local function evaluate() end

	-- unary operations
	local function evalUnary()
		if unaryOps[tok] then
			local op = unaryOps[tok]
			ti()
			return op(evalUnary())
		elseif tok == "(" then
			ti()
			local v = evaluate()
			xassert(tok == ")", options, n, "missing closing parenthesis")
			ti()
			return v
		elseif tok == "defined" then -- magic macro should have removed this
			xerror(options, n, "syntax error after <defined>")
		elseif isIdentifier(tok) then
			local v = type(resolver) == "function" and resolver(tok, ti)
			ti()
			return v or 0
		elseif isNumber(tok) then
			local v = tok:gsub("[ULul]+$", "")

			if v:find("^0[0-7]+$") then
				v = tonumber(v, 8) -- octal
			elseif v:find("^0[bB][01]+") then
				v = tonumber(v:sub(3), 2) -- binary
			else
				v = tonumber(v) -- lua does the rest
			end

			xassert(v and v == math.floor(v), options, n, "syntax error (invalid integer '%s')", tok)
			ti()
			return v
		elseif isString(tok) then
			local v = "\"\""

			if tok:find("^'") then -- interpret character constant as number
				v = evalLuaExpression(string.format("return string.byte(%s)", tok))
				xassert(type(v) == "number", options, n, "syntax error (invalid value '%s')", tok)
				ti()
			else
				while isString(tok) do
					xassert(tok:find("^\""), options, n, "syntax error (invalid value '%s')", tok)
					v = v:gsub("\"$", "") .. tok:gsub("^\"", "")
					ti()
				end
			end

			return v
		end

		xerror(options, n, "syntax error (invalid value '%s')", tok)
	end

	-- binary operations
	local function evalBinary(p)
		if p == 0 then
			return evalUnary()
		else
			local val = evalBinary(p - 1)

			while binaryPrec[tok] == p do
				local op = binaryOps[tok]
				ti()
				local oval = evalBinary(p - 1)
				xassert(
					p == 4 or p == 5 or type(val) == "number",
					options,
					n,
					"expression uses arithmetic operators on strings"
				)
				xassert(type(val) == type(oval), options, n, "expression compares numbers and strings")
				val = op(val, oval)
			end

			return val
		end
	end

	-- eval ternary conditonal
	local function evalTernary()
		local c = evalBinary(10)

		if tok ~= "?" then return c end

		ti()
		local v1 = evalBinary(10)
		xassert(tok == ":", options, n, "expecting ':' after '?'")
		ti()
		local v2 = evalBinary(10)

		if c == 0 then return v2 else return v1 end
	end

	-- actual definition of evaluate
	evaluate = function()
		return evalTernary()
	end
	-- main function
	ti()
	xassert(tok, options, n, "constant expression expected")
	local result = evaluate()

	if hasOption(options, "-d:eval") then xdebug(n, "eval %s", result) end

	-- warn about garbage when called from cpp (but not when called with resolver)
	while isBlank(tok) do
		ti()
	end

	xassert(resolver or not tok, options, n, "garbage after conditional expression")
	return result
end

-- Now dealing with the coroutine that processes all directives.
-- This coroutine obtains lines from coroutine <lines>,
-- processes all directives, and yields remaining lines
processDirectives = function(options, macros, lines, ...)
	local li = wrap(options, lines, ...)
	local s, n = li()
	-- redefine li to make sure vars s and n are up-to-date
	local li = function()
		s, n = li()
		return s, n
	end
	-- directives store their current token in these vars
	local dirtok, tok, spc
	-- forward declaration
	local processLine

	-- the captureTable mechanism communicates certain preprocessor
	-- events to the declaration parser in order to report them
	-- to the user (the parsing does not depend on this).
	-- if macros[1] is a table, the preprocessor will append
	-- records to this table for the parser to process.
	local function hasCaptureTable()
		local captable = rawget(macros, 1)
		return captable and type(captable) == "table" and captable
	end

	local function addToCaptureTable(record)
		local captable = hasCaptureTable()

		if captable and record then captable[1 + #captable] = record end
	end

	-- simple directives
	local function doIgnore()
		if hasOption(options, "-Zpass") then coroutine.yield(s, n) end
	end

	local function doError()
		xerror(options, n, "unexpected preprocessor directive #%s", dirtok)
	end

	local function doMessage()
		local msg = s:match("^%s*#+%s*[a-z]*%s+([^%s].*)")
		xmessage(dirtok, options, n, msg or ("#" .. dirtok))
	end

	-- undef
	local function doUndef(ti)
		ti()
		local nam = tok
		xassert(isIdentifier(nam), options, n, "symbol expected after #undef")

		if ti() then xwarning(options, n, "garbage after #undef directive") end

		if hasOption(options, "-d:defines") then xdebug(n, "undef %s", nam) end

		if hasCaptureTable() and macros[nam] and macros[nam].captured then
			addToCaptureTable({directive = "undef", name = nam, where = n})
		end

		macros[nam] = false -- false overrides inherited definitions
	end

	-- define
	local function getMacroArguments(ti)
		local args = {}
		local msg = "argument list in function-like macro"
		local nva = nil -- named variadic argument
		ti()

		while tok and tok ~= ")" do
			local nam = tok
			ti()

			if options.dialectGnu and isIdentifier(nam) and tok == "..." then
				nam, nva = tok, nam
				ti()
			end

			xassert(nam ~= "__VA_ARGS__", options, n, "name __VA_ARGS__ is not allowed here")
			xassert(
				tok == ")" or nam ~= "...",
				options,
				n,
				"ellipsis in argument list must appear last"
			)
			xassert(tok == ")" or tok == ",", options, n, "bad " .. msg)

			if tok == "," then ti() end

			if nam == "..." then nam = "__VA_ARGS__" end

			xassert(isIdentifier(nam), options, n, "bad " .. msg)
			args[1 + #args] = nam
		end

		xassert(tok == ")", options, n, "unterminated " .. msg)
		ti()
		return args, nva
	end

	local function doDefine(ti)
		xassert(isIdentifier(ti()), options, n, "symbol expected after #define")
		local nam, args, nva = tok, nil, nil

		-- collect arguments
		if ti() == "(" and not spc then args, nva = getMacroArguments(ti) end

		-- collect definition
		local def = {tok, args = args, nva = nva}

		while ti(true) do
			def[1 + #def] = tok
		end

		-- define macro
		if macros[nam] and not tableCompare(def, macros[nam]) then
			xwarning(options, n, "redefinition of preprocessor symbol '%s'", nam)
		end

		macros[nam] = def

		-- debug
		if hasOption(options, "-d:defines") then
			if args then
				args = "(" .. tableConcat(args, ",") .. ")"
			else
				args = ""
			end

			xdebug(n, "define %s%s = %s", nam, args, tableConcat(def, " "))
		end

		-- capture integer macro definitions
		if hasCaptureTable() and args == nil then
			local i = 0
			local v = callAndCollect(options, expandMacros, macros, yieldFromArray, def, n)

			local function ti()
				i = i + 1
				return v[i]
			end

			local ss, r = pcall(evaluateCppExpression, {silent = true}, ti, n, error)

			if ss and type(r) == "number" then
				def.captured = true
				addToCaptureTable(
					{
						directive = "define",
						name = nam,
						intval = r,
						where = n,
					}
				)
			end
		end
	end

	-- defmacro
	local function checkDirective(stop)
		xassert(s, options, n, "unterminated macro (missing #%s)", stop)
		local r = type(s) == "string" and s:match("^%s*#%s*([a-z]+)")

		if r == "endmacro" or r == "endif" then
			if s:find(r .. "%s*[^%s]") then
				xwarning(options, n, "garbage after #%s directive", r)
			end
		end

		return r
	end

	local function doMacroLines(lines, stop)
		while true do
			li()
			local ss = callAndCollect(options, tokenizeLine, s, n)

			if #ss > 0 then
				lines[1 + #lines] = ss
				lines[1 + #lines] = n
			end

			local r = checkDirective(stop)

			if r == "endmacro" or r == "endif" then
				xassert(
					r == stop,
					options,
					n,
					"unbalanced directives (got #%s instead of #%s)",
					r,
					stop
				)
				return r
			elseif r == "defmacro" then
				doMacroLines(lines, "endmacro")
			elseif r == "if" or r == "ifdef" or r == "ifndef" then
				doMacroLines(lines, "endif")
			end
		end
	end

	local function doDefmacro(ti)
		xassert(isIdentifier(ti()), options, n, "symbol expected after #defmacro")
		local nam, nn = tok, n
		xassert(ti() == "(", options, n, "argument list expected in #defmacro")
		local args, nva = getMacroArguments(ti)
		xassert(not tok, options, n, "garbage after argument list in #defmacro")
		-- collect definition
		local lines = {}
		local def = {
			args = args,
			nva = nva,
			lines = lines,
			recursive = (dirtok == "defrecursivemacro"),
		}
		doMacroLines(lines, "endmacro")
		lines[#lines] = nil
		lines[#lines] = nil

		if hasOption(options, "-d:directives") then
			xdebug(n, "directive: #endmacro")
		end

		if macros[nam] and not tableCompare(def, macros[nam]) then
			xwarning(options, n, "redefinition of preprocessor symbol '%s'", nam)
		end

		if hasOption(options, "-d:defines") then
			xdebug(nn, "defmacro %s(%s) =", nam, tableConcat(args, ","))

			for i = 1, #lines, 2 do
				xdebug(lines[i + 1], "\t%s", tableConcat(lines[i]):gsub("^\n", ""))
			end
		end

		macros[nam] = def
	end

	-- include
	local function doInclude(ti)
		-- get filename
		local pti = wrap(options, expandMacros, macros, yieldFromIterator, ti)
		local tok = pti()

		while isBlank(tok) do
			tok = pti()
		end

		if tok == "<" then -- computed include
			repeat
				local tok2 = pti()
				tok = tok .. tostring(tok2)			until tok2 == nil or tok2 == ">" or isNewline(tok2)

			tok = tok:gsub("%s>$", ">") -- gcc does this 
		end

		xassert(isHeaderName(tok), options, n, "malformed header name after #include")
		local ttok = pti()

		while isBlank(ttok) do
			ttok = pti()
		end

		if ttok then xwarning(options, n, "garbage after #include directive") end

		-- interpret filename
		local sys = tok:byte() == 60
		local min = dirtok == "include_next" and options.includedir or 0
		local fname = evalLuaExpression(string.format("return '%s'", tok:sub(2, -2)))
		local pname, fd, fdi

		for i, v in ipairs(options) do
			if v == "-I-" then
				sys = false
			elseif i > min and v:find("^%-I") and not sys then
				pname = v:match("^%-I%s*(.*)") .. "/" .. fname
				fdi, fd = i, io.open(pname, "r")

				if fd then break end
			end
		end

		if fd then
			-- include file
			if hasOption(options, "-d:include") then
				xdebug(n, "including %q", pname)
			end

			local savedfdi = options.includedir
			options.includedir = fdi -- saved index to implement include_next
			processDirectives(
				options,
				macros,
				eliminateComments,
				joinLines,
				yieldLines,
				fd:lines(),
				pname
			)
			options.includedir = savedfdi
		else
			-- include file not found
			if hasOption(options, "-Zpass") then
				coroutine.yield(string.format("#include %s", tok), n)
			else
				xwarning(options, n, "include directive (%s) was unresolved", tok)
			end

			-- quirks
			if knownIncludeQuirks[tok] then
				processDirectives(
					options,
					macros,
					eliminateComments,
					joinLines,
					yieldFromArray,
					knownIncludeQuirks[tok],
					n
				)
			end

			-- capture
			if hasCaptureTable() then
				addToCaptureTable({directive = "include", name = tok, where = n})
			end
		end
	end

	-- conditionals
	local function doConditionalBranch(execute)
		checkDirective("endif")

		while true do
			li()
			local r = checkDirective("endif")

			if r == "else" or r == "elif" or r == "endif" then
				return r
			elseif execute then
				processLine()
			elseif r == "if" or r == "ifdef" or r == "ifndef" then
				while doConditionalBranch(false) ~= "endif" do

				end
			end
		end
	end

	local function doConditional(result)
		local r = doConditionalBranch(result)

		if r == "elif" and not result then return processLine(true) end

		while r ~= "endif" do
			r = doConditionalBranch(not result)
		end

		if hasOption(options, "-d:directives") then
			xdebug(n, "directive: %s", s:gsub("^%s*", ""))
		end
	end

	local function doIfdef(ti)
		ti()
		xassert(isIdentifier(tok), options, n, "symbol expected after #%s", dirtok)
		local result = macros[tok]

		if ti() then xwarning(options, n, "garbage after #undef directive") end

		if dirtok == "ifndef" then result = not result end

		doConditional(result)
	end

	local function doIf(ti)
		-- magic macro for 'defined'
		local nmacros = {}
		setmetatable(nmacros, {__index = macros})
		nmacros["defined"] = function(ti)
			local tok, n = ti()

			if tok == "(" then
				tok = ti()

				if ti() ~= ")" then tok = nil end
			end

			if isIdentifier(tok) then
				coroutine.yield(macros[tok] and "1" or "0", n)
			else
				coroutine.yield("defined", n) -- error
			end
		end
		-- evaluate and branch
		local pti = wrap(options, expandMacros, nmacros, yieldFromIterator, ti)
		local result = evaluateCppExpression(options, pti, n)
		doConditional(result ~= 0)
	end

	-- table of directives
	local directives = {
		["else"] = doError,
		["elif"] = doError,
		["endif"] = doError,
		["pragma"] = doIgnore,
		["ident"] = doIgnore,
		["line"] = doIgnore,
		["error"] = doMessage,
		["warning"] = doMessage,
		["if"] = doIf,
		["ifdef"] = doIfdef,
		["ifndef"] = doIfdef,
		["define"] = doDefine,
		["undef"] = doUndef,
		["defmacro"] = doDefmacro,
		["defrecursivemacro"] = doDefmacro,
		["endmacro"] = doError,
		["include"] = doInclude,
		["include_next"] = doInclude,
	}
	-- process current line
	processLine = function(okElif)
		if type(s) == "table" then
			-- optimization for multiline macros:
			-- When s is an an array of precomputed tokens, code is assumed.
			coroutine.yield(s, n)
		elseif not s:find("^%s*#") then
			-- code
			coroutine.yield(s, n)
		elseif s:find("^%s*##") and hasOption(options, "-Zpass") then
			-- pass
			local ns = s:gsub("^(%s*)##", "%1#")
			coroutine.yield(ns, n)
		else
			if hasOption(options, "-d:directives") then
				xdebug(n, "directive: %s", s:gsub("^%s*", ""))
			end

			-- tokenize directive
			local ti = wrap(options, tokenizeLine, s, n)
			-- a token iterator that skips spaces unless told otherwise
			local ti = function(keepSpaces)
				tok = ti()
				spc = isSpace(tok)

				while not keepSpaces and isBlank(tok) do
					tok = ti()
					spc = spc or isSpace(tok)
				end

				return tok, n
			end
			-- start parsing directives
			ti()
			assert(tok == "#" or tok == "##")

			if tok == "##" then
				xwarning(options, n, "directive starts with ## without -Zpass")
			end

			dirtok = ti()

			if isIdentifier(tok) then
				local f = directives[dirtok]

				if okElif and dirtok == "elif" then f = doIf end

				xassert(f, options, n, "unrecognized preprocessor directive #%s", tok)
				f(ti)
			elseif tok ~= nil then
				xerror(options, n, "unrecognized preprocessor directive '#%s'", s:gsub("^%s*", ""))
			end
		end
	end

	-- main loop
	while s ~= nil do
		processLine()
		li()
	end
end

-- This function yields initialization lines
local function initialDefines(options)
	-- cpp-extracted definitions
	if hasOption(options, "-Zcppdef") then
		local fd = io.popen("cpp -dM < /dev/null", "r")
		yieldLines(options, fd:lines(), "<cppdef>")
		fd:close()
	end

	-- builtin definitions
	local sb = {"#define __CPARSER__ 1"}

	local function addDef(s, v)
		sb[1 + #sb] = string.format("#ifndef %s", s)
		sb[1 + #sb] = string.format("# define %s %s", s, v)
		sb[1 + #sb] = string.format("#endif")
	end

	addDef("__STDC__", "1")
	local stdc = "199409L"

	if options.dialect11 then stdc = "201112L" end

	if options.dialect99 then stdc = "199901L" end

	addDef("__STDC_VERSION__", stdc)

	if options.dialectGnu then
		addDef("__GNUC__", 4)
		addDef("__GNUC_MINOR__", 2)
	end

	yieldLines(options, wrap(options, yieldFromArray, sb), "<builtin>")
	-- command line definitions
	local sc = {}

	for _, v in ipairs(options) do
		local d

		if v:find("^%-D(.*)=") then
			d = v:gsub("^%-D%s*(.*)%s*=%s*(.-)%s*$", "#define %1 %2")
		elseif v:find("^%-D") then
			d = v:gsub("^%-D%s*(.-)%s*$", "#define %1 1")
		elseif v:find("^%-U") then
			d = v:gsub("^%-U%s*(.-)%s*$", "#undef %1")
		end

		if d then sc[1 + #sc] = d end
	end

	yieldLines(options, wrap(options, yieldFromArray, sc), "<cmdline>")
end

-- This function creates the initial macro directory
local function initialMacros(options)
	local macros = {}
	-- magic macros
	macros["__FILE__"] = function(_, _, n)
		local f

		if type(n) == "string" then f = n:match("^[^:]*") end

		coroutine.yield(string.format("%q", f or "<unknown>"), n)
	end
	macros["__LINE__"] = function(_, _, n)
		local d = n

		if type(d) == "string" then d = tonumber(d:match("%d*$")) end

		coroutine.yield(string.format("%d", d or 0), n)
	end
	macros["__DATE__"] = function(_, _, n)
		coroutine.yield(string.format("%q", os.date("%b %e %Y")), n)
	end
	macros["__TIME__"] = function(_, _, n)
		coroutine.yield(string.format("%q", os.date("%T")), n)
	end
	-- initial macros
	local li = wrap(options, processDirectives, macros, initialDefines)

	for _ in li do

	end

	-- return
	return macros
end

-- This function prepares a string containing the definition of the
-- macro named <name> in macro definition table <macros>, or nil if no
-- such definition exists.
local function macroToString(macros, name)
	local v = macros[name]

	if type(v) == "table" then
		local dir = "define"

		if v.recursive and v.lines then
			dir = "defrecursivemacro"
		elseif v.lines then
			dir = "defmacro"
		end

		local arr = {"#", dir, " ", name}

		if v.args then
			arr[1 + #arr] = "("

			for i, s in ipairs(v.args) do
				if i ~= 1 then arr[1 + #arr] = "," end

				if s == "__VA_ARGS__" then s = (v.nva or "") .. "..." end

				arr[1 + #arr] = s
			end

			arr[1 + #arr] = ") "
		else
			arr[1 + #arr] = " "
		end

		for _, s in ipairs(v) do
			arr[1 + #arr] = s
		end

		if v.lines then
			for i = 1, #v.lines, 2 do
				local vl = v.lines[i]
				arr[1 + #arr] = "\n"

				if type(vl) == "table" then vl = tableConcat(vl) end

				arr[1 + #arr] = vl:gsub("^%s?%s?", "  "):gsub("^\n", "")
			end

			arr[1 + #arr] = "\n"
			arr[1 + #arr] = "#endmacro"
		end

		return tableConcat(arr)
	end
end

-- This function dumps all macros to file descriptor outputfile
local function dumpMacros(macros, outputfile)
	outputfile = outputfile or io.output()
	assert(type(macros) == "table")
	assert(io.type(outputfile) == "file")

	for k, _ in pairs(macros) do
		local s = macroToString(macros, k)

		if s then outputfile:write(string.format("%s\n", s)) end
	end
end

-- A coroutine that filters out spaces, directives, and magic tokens
local function filterSpaces(options, tokens, ...)
	local ti = wrap(options, tokens, ...)
	local tok, n = ti()

	while tok do
		-- skip directives
		while isNewline(tok) do
			tok, n = ti()

			while isBlank(tok) do
				tok, n = ti()
			end

			if tok == "#" then
				while not isNewline(tok) do
					tok, n = ti()
				end
			end
		end

		-- output nonspaces
		if not isBlank(tok) then coroutine.yield(tok, n) end

		tok, n = ti()
	end
end

-- This function takes a line iterator and an optional location prefix.
-- It returns a token iterator for the preprocessed tokens
-- and a table of macro definitions.
local function cppTokenIterator(options, lines, prefix)
	options = copyOptions(options)
	prefix = prefix or ""
	assert(type(options) == "table")
	assert(type(lines) == "function")
	assert(type(prefix) == "string")
	local macros = initialMacros(options)
	local ti = wrap(
		options,
		filterSpaces,
		expandMacros,
		macros,
		tokenize,
		processDirectives,
		macros,
		eliminateComments,
		joinLines,
		yieldLines,
		lines,
		prefix
	)
	return ti, macros
end

-- A coroutine that reconstructs lines from the preprocessed tokens
local function preprocessedLines(options, tokens, ...)
	local ti = wrap(options, tokens, ...)
	local tok, n = ti()

	while tok do
		local curn = n
		local curl = {}

		if isNewline(tok) then
			curn = n
			curl[1 + #curl] = tok:sub(2)
			tok, n = ti()
		end

		while tok and not isNewline(tok) do
			if not isMagic(tok) then curl[1 + #curl] = tok end

			tok, n = ti()
		end

		coroutine.yield(table.concat(curl), curn)
	end
end

-- This function preprocesses file <filename>.
-- The optional argument <outputfile> specifies where to write the
-- preprocessed file and may be a string or a file descriptor.
-- The optional argument <options> contains an array of option strings.
-- Note that option "-Zpass" is added, unless the option "-Znopass" is present.
local function cpp(filename, outputfile, options)
	-- handle optional arguments
	options = copyOptions(options)
	outputfile = outputfile or "-"
	assert(type(filename) == "string")
	assert(type(options) == "table")
	local closeoutputfile = false

	if io.type(outputfile) ~= "file" then
		assert(type(outputfile) == "string")

		if outputfile == "-" then
			outputfile = io.output()
		else
			closeoutputfile = true
			outputfile = io.open(outputfile, "w")
		end
	end

	assert(io.type(outputfile) == "file")

	-- makes option -Zpass on by default
	if not hasOption(options, "-Znopass") then options.hash["-Zpass"] = true end

	-- prepare iterator
	local dM = hasOption(options, "-dM")
	local macros = initialMacros(options)
	local li = wrap(
		options,
		preprocessedLines,
		expandMacros,
		macros,
		tokenize,
		processDirectives,
		macros,
		eliminateComments,
		joinLines,
		yieldLines,
		io.lines(filename),
		filename
	)
	-- iterate, inserting line markers
	local lm = hasOption(options, "-Zpass") and "line" or ""
	local cf, cn

	for s, n in li do
		if not dM and s:find("[^%s]") then
			local xf, xn

			if type(n) == "number" then
				xn = n
			elseif type(n) == "string" then
				xf, xn = n:match("^([^:]*).-(%d*)$")
				xn = tonumber(xn)
			end

			if cf ~= xf or cn ~= xn then
				cf, cn = xf, xn
				outputfile:write(string.format("#%s %d %q\n", lm, cn, cf))
			end

			outputfile:write(s)
			outputfile:write("\n")
			cn = cn + 1
		end
	end

	if dM then dumpMacros(macros, outputfile) end

	if closeoutputfile then outputfile:close() end
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- PARSING DECLARATIONS
-- Simple tuples are constructed using "tuple=Pair{a,b}" and accessed
-- as tuple[1],tuple[2] etc.  Although this is named Pair, one can use
-- more than two args.
local Pair = newTag("Pair")
-- Types are represented by a series of tagged data structures.
-- Subfield <t> usually contains the base type or the function return
-- type.  Subfield <n> contains the name of the structure, union, or
-- enum.  Numerical indices are used for struct components and
-- function arguments. The construct Type{n=...} is used for named
-- types, including basic types, typedefs, and tagged struct, unions
-- or enums. When the named type has a better definition the hidden
-- field <_def> contains it. They should be constructed with function
-- namedType() because it is expected that there is only one copy of
-- each named type. The construct Qualified{t=...} is used to
-- represent const/volatile/restrict variants of the base type.
--
-- Examples
--   long int a                  Type{n="long int"}
--   int *a                      Pointer{t=Type{n="int"}}
--   const int *a                Pointer{t=Qualified{const=true,t=Type{n="int"}}}
--   int* const a                Qualified{const=true,t=Pointer{t=Type{n="int"}}}
--   void foo(int bar)           Function{Pair{Type{n="int"},"bar"},t=Type{n="void"}}}
--   int foo(void)               Function{t=Type{n="int"}}
--   int foo()                   Function{t=Type{n="int"},withoutProto=true}
local Type = newTag("Type")
local Qualified = newTag("Qualified")
local Pointer = newTag("Pointer")
local Array = newTag("Array")
local Enum = newTag("Enum")
local Struct = newTag("Struct")
local Union = newTag("Union")
local Function = newTag("Function")

-- This function creates a qualified variant of a type.
local function addQualifier(ty, q)
	assert(q == "const" or q == "volatile" or q == "restrict")

	if ty.Tag ~= "Qualified" then ty = Qualified({t = ty}) end

	ty[q] = true
	return ty
end

local function typeIs(ty, tag)
	assert(ty)

	if ty.tag == "Qualified" then ty = ty.t end

	return ty.tag == tag
end

-- This function compares two types. When optional argument <oki> is
-- not false and types t1 or t2 are incomplete, the function returns
-- true if the types are compatible: an unsized array matches a sized
-- array, a function type without prototype matches one with a
-- prototype. Furthermore, if oki is <1>, the function will patch type
-- <t1> to contain the complete information.
local function compareTypes(t1, t2, oki)
	if t1 == t2 then
		return t1
	elseif t1.tag == "Type" and t1._def then
		return compareTypes(t1._def, t2, oki)
	elseif t2.tag == "Type" and t2._def then
		return compareTypes(t1, t2._def, oki)
	elseif t1.tag == "Qualified" or t2.tag == "Qualified" then
		if t1.tag ~= "Qualified" then
			return compareTypes(Qualified({t = t1}), t2)
		elseif t2.tag ~= "Qualified" then
			return compareTypes(t1, Qualified({t = t2}))
		else
			if t1.const ~= t2.const then return false end

			if t1.volatile ~= t2.volatile then return false end

			if t1.restrict ~= t2.restrict then return false end

			if oki == 1 then t1.attr = tableAppend(t1.attr, t2.attr) end

			return compareTypes(t1.t, t2.t, oki)
		end
	elseif t1.tag ~= t2.tag then
		return false
	elseif t1.tag == "Pointer" then
		if t1.block ~= t2.block then return false end

		if t1.ref ~= t2.ref then return false end

		return compareTypes(t1.t, t2.t, oki)
	elseif t1.tag == "Array" then
		if compareTypes(t1.t, t2.t, oki) then
			if t1.size == t2.size then return true end

			if t1.size == nil or t2.size == nil then
				if oki == 1 and t1.size == nil then t1.size = t2.size end

				return oki
			end
		end
	elseif t1.tag == "Function" then
		if compareTypes(t1.t, t2.t, oki) then
			if oki == 1 then t1.attr = tableAppend(t1.attr, t2.attr) end

			if t1.withoutProto or t2.withoutProto then
				if t1.withoutProto and t2.withoutProto then return true end

				if oki == 1 and t1.withoutProto then
					for i = 1, #t2 do
						t1[i] = t2[i]
					end

					t1.withoutProto = nil
				end

				return oki
			elseif #t1 == #t2 then
				for i = 1, #t1 do
					if t1[i][1] == nil or t2[i][1] == nil then
						return t1[i].ellipsis and t2[i].ellipsis
					elseif not compareTypes(t1[i][1], t2[i][1], oki) then
						return false
					end
				end

				return true
			end
		end
	elseif t1.tag == "Enum" then
		return false
	elseif #t1 == #t2 then -- struct or union
		for i = 1, #t1 do
			if t1[i][2] ~= t2[i][2] then return false end

			if t1[i].bitfield ~= t2[i].bitfield then return false end

			if not compareTypes(t1[i][1], t2[i][1], oki) then return false end
		end

		if oki == 1 then t1.attr = tableAppend(t1.attr, t2.attr) end

		if t1.n == t2.n then return true end

		if t1.n == nil or t2.n == nil then
			if oki == 1 and t1.n == nil then t1.n = t2.n end

			return oki
		end
	end

	return false
end

-- Util
local function spaceNeededBetweenTokens(t1, t2)
	if not t1 or not t2 then return false end

	local it1 = isIdentifier(t1) or isNumber(t1)
	local it2 = isIdentifier(t2) or isNumber(t2)

	if it1 and it2 then return true end

	if it1 and not it2 or not it1 and it2 then return false end

	local z = callAndCollect({silent = true}, tokenizeLine, t1 .. t2, "internal", true)
	return z[1] ~= t1 or z[2] ~= t2
end

-- Constructs a string suitable for declaring a variable <nam> of type
-- <ty> in a C program. Argument <nam> defaults to "%s".
local function typeToString(ty, nam)
	nam = nam or "%s"
	assert(type(nam) == "string")

	local function parenthesize(nam)
		return "(" .. nam .. ")"
	end

	local function insertword(word, nam)
		if nam:find("^[A-Za-z0-9$_%%]") then nam = " " .. nam end

		return word .. nam
	end

	local function makelist(ty, sep)
		local s = ""

		for i = 1, #ty do
			if i > 1 then s = s .. sep end

			if ty[i].ellipsis then
				s = s .. "..."
			else
				s = s .. typeToString(ty[i][1], ty[i][2] or "")
			end

			if ty[i].bitfield then s = s .. ":" .. tostring(ty[i].bitfield) end
		end

		return s
	end

	local function initstr(arr)
		local s = {}

		for i = 1, #arr, 2 do
			if spaceNeededBetweenTokens(arr[i - 2], arr[i]) then s[1 + #s] = " " end

			s[1 + #s] = arr[i]
		end

		return table.concat(s)
	end

	local function insertqual(ty, nam)
		if ty and ty.attr then nam = insertword(initstr(ty.attr), nam) end

		if ty and ty.restrict then nam = insertword("restrict", nam) end

		if ty and ty.volatile then nam = insertword("volatile", nam) end

		if ty and ty.const then nam = insertword("const", nam) end

		if ty and ty.static then nam = insertword("static", nam) end

		return nam
	end

	-- main loop
	while true do
		local qty = nil

		while ty.tag == "Qualified" do
			qty = ty
			ty = ty.t
		end

		if qty and qty.static and ty.tag == "Pointer" then
			ty = Array({t = ty.t, size = qty.static})
		end

		if ty.tag == "Type" then
			return insertqual(qty, insertword(ty.n, nam))
		elseif ty.tag == "Pointer" then
			local star = (ty.block and "^") or (ty.ref and "&") or "*"
			nam = star .. insertqual(qty, nam)
			ty = ty.t
		elseif ty.tag == "Array" then
			local sz = ty.size or ""

			if nam:find("^[*^]") then nam = parenthesize(nam) end

			nam = nam .. "[" .. insertqual(qty, tostring(sz)) .. "]"
			ty = ty.t
		elseif ty.tag == "Function" then
			if nam:find("^[*^]") then nam = parenthesize(nam) end

			if #ty == 0 and ty.withoutProto then
				nam = nam .. "()"
			elseif #ty == 0 then
				nam = nam .. "(void)"
			else
				nam = nam .. "(" .. makelist(ty, ",") .. ")"
			end

			if ty.attr then nam = nam .. initstr(ty.attr) end

			if qty then nam = nam .. insertqual(qty, "") end

			ty = ty.t
		elseif ty.tag == "Enum" then
			local s = insertqual(qty, "enum")

			if ty.attr then s = s .. " " .. initstr(ty.attr) end

			if ty.n then s = s .. " " .. ty.n end

			s = s .. "{"

			for i = 1, #ty do
				if i > 1 then s = s .. "," end

				s = s .. ty[i][1]

				if ty[i][2] then s = s .. "=" .. tostring(ty[i][2]) end
			end

			return s .. "}" .. nam
		else
			local s = insertqual(qty, string.lower(ty.tag))

			if ty.attr then s = s .. " " .. initstr(ty.attr) end

			if ty.n then s = s .. " " .. ty.n end

			return s .. "{" .. makelist(ty, ";") .. ";}" .. nam
		end
	end
end

-- Tables Definition{} and Declaration{} represent variable and
-- constant definitions and declarations found in the code. Field
-- <where> is the location of the definition or declaration, field
-- <name> is the name of the variable or constant being defined, field
-- <type> contains the type, field <init> optionally contain the
-- initialization or the function body. Field <sclass> contains the
-- storage class such as <extern>, <static>, <auto>. Special storage
-- class '[enum]' is used to define enumeration constants.  Table
-- TypeDef{} represents type definitions and contains pretty much the
-- same fields. Note that storage class <typedef> is used for an
-- actual <typedef> and storage class <[typetag]> is used when the
-- type definition results from a tagged structure union or enum.
-- CppEvent{} is used to report captured cpp events.
local TypeDef = newTag("TypeDef")
local Definition = newTag("Definition")
local Declaration = newTag("Declaration")
local CppEvent = newTag("CppEvent")

local function declToString(action)
	local tag = action and action.tag

	if tag == "TypeDef" or tag == "Definition" or tag == "Declaration" then
		local n = (action.sclass == "[typetag]") and "" or action.name
		local s = typeToString(action.type, n)

		if action.type.inline then s = "inline" .. " " .. s end

		if action.sclass then s = action.sclass .. " " .. s end

		if action.intval then
			s = s .. " = " .. action.intval
		elseif action.init and typeIs(action.type, "Function") then
			s = s .. "{..}"
		elseif action.init then
			s = s .. "=.."
		end

		return s
	elseif tag == "CppEvent" then
		local s = nil

		if action.directive == "include" then
			s = string.format("#include %s", action.name)
		elseif action.directive == "define" then
			s = string.format("#define %s %s", action.name, action.intval)
		elseif action.directive == "undef" then
			s = string.format("#undef %s", action.name)
		end

		return s
	end
end

-- The symbol table is implemented by a table that contains Type{}
-- nodes for type definitions (possibly with a hidden <_def> field
-- pointing to the full definition), Definition{} or Declaration{]
-- nodes for all other names.
local function isTypeName(symtable, name)
	local ty = symtable[name]

	if ty and ty.tag == "Type" then return ty end

	return false
end

local function newScope(symtable)
	local newSymtable = {}
	setmetatable(newSymtable, {__index = symtable})
	return newSymtable
end

-- Returns an iterator that can look tokens ahead.
-- Calling it without arguments works like an ordinary iterator.
-- Calling it with argument 0 returns the current token.
-- Calling it with a positive argument look <arg> positions ahead.
-- Calling it with argument -1 pushes back the last token.
local function lookaheadTokenIterator(ti)
	local tok, n = ti()
	local fifo = {}
	return function(arg)
		if not arg then
			if fifo[1] then
				tok, n = unpack(fifo[1])
				table.remove(fifo, 1)
				return tok, n
			else
				tok, n = ti()
				return tok, n
			end
		elseif arg == 0 then
			return tok, n
		elseif arg == -1 then
			table.insert(fifo, 1, {tok, n})
			return tok, n
		else
			assert(type(arg) == "number" and arg > 0)

			while arg > #fifo do
				fifo[1 + #fifo] = {ti()}
			end

			return unpack(fifo[arg])
		end
	end
end

-- Evaluation of constant expression.
--   We avoid writing a complete expression parser by reusing the cpp
-- expression parser and either returning an integer (when we can
-- evaluate) or a string containing the expression (when we can't) or
-- nil (when we are sure this is not a number).  Array <arr> contains
-- tokens (odd indices) followed by location (even indices). Argument
-- <symtable> is the symbol table.
--   The alternative is to write a proper expression parse with
-- constant folding as well as providing means to evaluate the value
-- of the sizeof and alignof operators. This but might be needed if
-- one wants to compute struct layouts.
local function tryEvaluateConstantExpression(options, n, arr, symtable)
	-- array initializers never are constant integers
	if arr[1] == "{" then return nil, false end

	-- try direct evaluation
	local ari = -1

	local function ti(arg)
		if not arg then
			ari = ari + 2
			arg = 0
		end

		if arg < 0 and ari > -1 then
			ari = ari - 2
			arg = 1
		end

		return arr[ari + 2 * arg], arr[ari + 2 * arg + 1]
	end

	local function rsym(tok)
		local s = symtable and symtable[tok]
		xassert(
			s and type(s.intval) == "number",
			{silent = true},
			n,
			"symbol '%s' does not resolve to a constant integer",
			s
		)
		return s.intval
	end

	local ss, r = pcall(evaluateCppExpression, {silent = true}, ti, n, rsym)

	if ss and type(r) == "number" and not ti(0) then return r, true end

	if ss and type(r) ~= "number" and not ti(0) then return nil, false end

	-- just return an expression string
	local s = {}

	for i = 1, #arr, 2 do
		if spaceNeededBetweenTokens(arr[i - 2], arr[i]) then s[1 + #s] = " " end

		if isName(arr[i]) and symtable[arr[i]] and symtable[arr[i]].eval then
			s[1 + #s] = string.format("(%s)", symtable[arr[i]].eval)
		else
			s[1 + #s] = arr[i]
		end
	end

	s = table.concat(s)
	xwarning(
		options,
		n,
		"cparser cannot evaluate '%s' as an integer constant" .. " and is using the literal expression instead",
		s
	)
	return s, false
end

-- Specifier table.
--  This function return a table that categorize the meaning
-- of all the type specifier keywords.
local function getSpecifierTable(options)
	options.specifierTable = options.specifierTable or
		{
			typedef = "sclass",
			extern = "sclass",
			static = "sclass",
			auto = "sclass",
			register = "sclass",
			void = "type",
			char = "type",
			float = "type",
			int = "type",
			double = "type",
			short = "size",
			long = "size",
			signed = "sign",
			unsigned = "sign",
			const = "const",
			volatile = "volatile",
			struct = "struct",
			union = "struct",
			enum = "enum",
			__inline__ = "inline", -- gnu
			__asm__ = "attr", -- gnu
			__restrict__ = "restrict", -- gnu
			__attribute__ = "attr", -- gnu
			__extension__ = "extension", -- gnu
			__pragma = "attr", -- msvc
			__asm = "attr", -- msvc
			__declspec = "attr", -- msvc
			__restrict = "restrict", -- msvc
			__inline = "inline", -- msvc
			__forceinline = "inline", -- msvc
			__cdecl = "attr", -- msvc
			__fastcall = "attr", -- msvc
			__stdcall = "attr", -- msvc
			__based = "attr", -- msvc
			__int8 = "type", -- msvc
			__int16 = "type", -- msvc
			__int32 = "type", -- msvc
			__int64 = "type", -- msvc
			_Bool = not options.dialectAnsi and "type",
			restrict = not options.dialectAnsi and "restrict",
			_Complex = not options.dialectAnsi and "complex",
			_Imaginary = not options.dialectAnsi and "complex",
			_Atomic = not options.dialectAnsi and "atomic",
			inline = not options.dialectAnsi and "inline",
			_Pragma = not options.dialectAnsi and "attr",
			__thread = options.dialectGnu and "attr",
			asm = options.dialectGnu and "attr",
			_Alignas = options.dialect11 and "attr",
			_Noreturn = options.dialect11 and "attr",
			_Thread_local = options.dialect11 and "attr",
		}
	return options.specifierTable
end

-- This coroutine is the declaration parser
-- Argument <globals> is the global symbol table.
-- Argument <tokens> is a coroutine that yields program tokens.
local function parseDeclarations(options, globals, tokens, ...)
	-- see processMacroCaptures around the end of this function
	if type(options.macros) == "table" then options.macros[1] = {} end

	-- define a lookahead token iterator that also ensures that
	-- variables tok,n always contain the current token
	local ti = lookaheadTokenIterator(wrap(options, tokens, ...))
	local tok, n = ti(0)
	local ti = function(arg)
		if arg then return ti(arg) end

		tok, n = ti()
		-- print(string.format("*** [%s] (%s)",tok,n))
		return tok, n
	end

	-- this function is used to retrieve or construct Type{} nodes for
	-- named types. Since the Type constructor should not be used we
	-- override it with a function that calls assert(false)
	local function namedType(symtable, nam)
		local ty = symtable[nam]

		if ty and ty.tag == "Type" then
			return ty
		elseif ty and ty.tag ~= "Type" then
			local msg = " previous declaration at %s"

			if rawget(symtable, nam) then
				xerror(options, n, "type name '%s' conflicts with" .. msg, nam, ty.where)
			else
				xwarning(options, n, "type name '%s' shadows" .. msg, nam, ty.where)
			end
		end

		ty = Type({n = nam})
		symtable[nam] = ty
		return ty
	end

	local function Type()
		assert(false)
	end

	-- unique id generator
	local unique_int = 0

	local function unique()
		unique_int = unique_int + 1
		return string.format("%s_%05d", options.unique_prefix or "__anon", unique_int)
	end

	-- check that current token is one of the provided token strings
	local function check(s1, s2)
		if tok == s1 then return end

		if tok == s2 then return end

		if not s2 then
			xerror(options, n, "expecting '%s' but got '%s'", s1, tok)
		else
			xerror(
				options,
				n,
				"expecting '%s' or '%s' but got '%s'",
				s1,
				s2,
				tok
			)
		end
	end

	-- record tokens into array arr if non nil
	local function record(arr)
		if arr then
			arr[1 + #arr] = tok
			arr[1 + #arr] = n
		end
	end

	-- skip parenthesized expression stating on current token.
	-- return nil if current token is not a left delimiter.
	-- new current token immediately follow right delimiter.
	-- optionally record tokens into arr and return arr
	local function skipPar(arr)
		local dleft = {["("] = ")", ["{"] = "}", ["["] = "]"}
		local dright = {[")"] = 1, ["}"] = 1, ["]"] = 1}
		local stok = dleft[tok]

		if stok then
			local sn = n
			local ltok = tok
			record(arr)
			ti()

			while not dright[tok] do
				xassert(
					tok,
					options,
					sn,
					"no matching '%s' for this '%s'",
					stok,
					ltok
				)

				if dleft[tok] then
					skipPar(arr)
				else
					record(arr)
					ti()
				end
			end

			xassert(
				tok == stok,
				options,
				n,
				"expecting '%s' but got '%s'",
				tok,
				stok
			)
			record(arr)
			ti()
			return arr
		end
	end

	-- skip balanced tokens until reaching token s1 or s2 or s2.
	-- in addition s1 may be a table whose keys are the stop token.
	-- the new current token immediately follows the stop token.
	-- optionally records tokens into arr and returns arr.
	local function skipTo(arr, s1, s2, s3, s4)
		local sn = n

		while tok and tok ~= s1 and tok ~= s2 and tok ~= s3 and tok ~= s4 do
			if type(s1) == "table" and s1[tok] then break end

			if not skipPar(arr) then
				record(arr)
				ti()
			end
		end

		xassert(tok, options, sn, "unterminated expression")
		return arr
	end

	-- processDeclaration.
	-- Argument <where> is the file/line of the declaration.
	-- Argument <symtable> is the current symbol table.
	-- Argument <context> is 'global', 'param', 'local'
	local function processDeclaration(where, symtable, context, name, ty, sclass, init)
		local dcl

		-- handle type definitions
		if sclass == "typedef" or sclass == "[typetag]" then
			local nty = namedType(symtable, name)
			nty._def = ty
			symtable[name] = nty
			dcl = TypeDef(
				{
					name = name,
					type = ty,
					where = where,
					sclass = sclass,
				}
			)

			if context == "global" then coroutine.yield(dcl) end

			return
		end

		-- handle variable and constants
		if typeIs(ty, "Function") then
			if init then
				dcl = Definition(
					{
						name = name,
						type = ty,
						sclass = sclass,
						where = where,
						init = init,
					}
				)
			else
				dcl = Declaration(
					{
						name = name,
						type = ty,
						sclass = sclass,
						where = where,
					}
				)
			end
		else
			if
				sclass == "extern" or
				ty.const and
				not init and
				sclass ~= "[enum]" or
				ty.tag == "Array" and
				not ty.size and
				not init
			then
				xassert(not init, options, n, "extern declaration cannot have initializers")
				dcl = Declaration(
					{
						name = name,
						type = ty,
						sclass = sclass,
						where = where,
					}
				)
			else
				local v = ty.tag == "Qualified" and ty.const and init or nil

				if type(v) == "table" then
					v = tryEvaluateConstantExpression(options, where, init, symtable)
				elseif type(v) == "number" then -- happens when called from parseEnum
					init = {tostring(v), where}
				end

				dcl = Definition(
					{
						name = name,
						type = ty,
						sclass = sclass,
						where = where,
						init = init,
						intval = v,
					}
				)
			end
		end

		-- check for duplicate declaration
		local ddcl = dcl

		if dcl.tag ~= "TypeDef" then
			local odcl = symtable[name]
			local samescope = rawget(symtable, name)

			-- compare types
			if odcl and samescope then
				if
					dcl.tag == "Definition" and
					odcl.tag == "Definition" or
					not compareTypes(dcl.type, odcl.type, true)
				then
					xerror(
						options,
						where,
						"%s of symbol '%s' conflicts with earlier %s at %s",
						string.lower(dcl.tag),
						name,
						string.lower(odcl.tag),
						odcl.where
					)
				end

				if odcl.tag == "Definition" then
					ddcl = odcl
					compareTypes(ddcl.type, dcl.type, 1)
				else
					compareTypes(ddcl.type, odcl.type, 1)
				end
			end

			-- compare storage class
			if odcl and dcl.sclass ~= odcl.sclass then
				if dcl.sclass == "static" or samescope and odcl.sclass == "static" then
					xerror(options, n, "inconsistent linkage for '%s' (previous at %s)", name, odcl.where)
				end
			end

			-- install dcl in symtable and yield global declarations
			symtable[name] = ddcl

			if context == "global" then coroutine.yield(dcl) end
		end
	end

	-- forward declations of parsing functions
	local parseDeclaration
	local parseDeclarationSpecifiers
	local parseDeclarator, parsePrototype
	local parseEnum, parseStruct
	-- C declarations have a left part that contains a type
	-- and comma separated right parts that contain the variable
	-- name in expressions that mimic how one would use the
	-- variable to obtain the type specified by the left part.
	-- The left part is called a DeclarationSpecifier
	-- and the right parts are called Declarators.
	-- token classification table for speeding up type parsing
	local specifierTable = getSpecifierTable(options)

	-- appends attributes to table
	local function isAttribute()
		return specifierTable[tok] == "attr" or
			options.dialect11 and
			tok == "[" and
			ti(1) == "["
	end

	local function collectAttributes(arr)
		while isAttribute() do
			arr = arr or {}

			if tok ~= "[" then
				arr[1 + #arr] = tok
				arr[1 + #arr] = n
				ti()
			end

			if tok == "(" or tok == "[" then skipPar(arr) end
		end

		return arr
	end

	-- This function parses the left part and returns the type, and a table
	-- containing all the additional information we could collect, namely the
	-- presence of an inline keyword or the tokens associated with
	-- compiler-specific attribute syntax.
	parseDeclarationSpecifiers = function(symtable, context, abstract)
		local ty
		local nn = {}

		while true do
			local ltok = tok
			local p = specifierTable[tok]

			if isAttribute() then
				p = "attr"
				nn.attr = collectAttributes(nn.attr)
			elseif p == "enum" then
				p = "type"
				ty = parseEnum(symtable, context, abstract, nn)
			elseif p == "struct" then
				p = "type"
				ty = parseStruct(symtable, context, abstract, nn)
			elseif p then
				ti()
			elseif isName(tok) then
				local tt = isTypeName(symtable, tok)
				local yes = not nn.type and not nn.size and not nn.sign and not nn.complex

				if not tt then
					local tok1 = ti(1)
					local no = not abstract and tok1:find("^[;,[]")

					if yes and not no then -- assume this is a type name
						p = "type"
						ty = namedType(globals, tok)
						ti()
					end
				elseif yes or tt.tag ~= "Type" or tt._def then
					p = "type"
					ty = tt
					ti() -- beware redefinition of inferred types
				end
			end

			if not p then break end

			if p == "size" and ltok == "long" and nn[p] == "long" then
				nn[p] = "long long"
			elseif p == "attr" then

			-- nothing
			elseif p == "type" and nn[p] then
				xerror(options, n, "conflicting types '%s' and '%s'", nn[p], ltok)
			elseif nn[p] then
				xerror(options, n, "conflicting type specifiers '%s' and '%s'", nn[p], ltok)
			else
				nn[p] = ltok
			end
		end

		-- resolve multi-keyword type names
		if not nn.type then
			if nn.size or nn.sign then
				nn.type = "int"
			elseif nn.complex then
				xwarning(options, n, "_Complex used without a type, assuming 'double'")
				nn.type = "double"
			elseif nn.sclass then
				xwarning(options, n, "missing type specifier defaults to 'int'")
				nn.type = "int"
			else
				xerror(options, n, "missing type specifier")
			end
		end

		if nn.type == "char" then
			if nn.sign then
				nn.type = nn.sign .. " " .. nn.type
				nn.sign = nil
			end
		elseif nn.type == "int" then
			if nn.size then
				nn.type = nn.size .. " " .. nn.type
				nn.size = nil
			end

			if nn.sign then
				nn.type = nn.sign .. " " .. nn.type
				nn.sign = nil
			end
		elseif nn.type == "double" then
			if nn.size and nn.size:find("long") then
				nn.type = nn.size .. " " .. nn.type
				nn.size = nil
			end

			if nn.complex then
				nn.type = nn.complex .. " " .. nn.type
				nn.complex = nil
			end
		elseif nn.type == "float" then
			if nn.complex then
				nn.type = "_Complex " .. nn.type
				nn.complex = nil
			end
		elseif type(nn.type) == "string" and nn.type:find("^__int%d+$") then
			if nn.sign then
				nn.type = nn.sign .. " " .. nn.type
				nn.sign = nil
			end
		end

		if nn.atomic then
			nn.type = "_Atomic " .. nn.type
			nn.atomic = nil -- could be narrower
		end

		local msg = "qualifier '%s' cannot be applied to type '%s'"
		xassert(not nn.sign, options, n, msg, nn.sign, nn.type)
		xassert(not nn.size, options, n, msg, nn.size, nn.type)
		xassert(not nn.complex, options, n, msg, nn.complex, nn.type)
		xassert(not nn.atomic, options, n, msg, nn.atomic, nn.type)
		-- signal meaningless register storage classes
		local sclass = nn.sclass
		local smsg = "storage class '%s' is not appropriate in this context"

		if context == "global" then
			xassert(sclass ~= "register" and sclass ~= "auto", options, n, smsg, sclass)
		elseif context == "param" then
			xassert(
				sclass ~= "static" and sclass ~= "extern" and sclass ~= "typedef",
				options,
				n,
				smsg,
				sclass
			)
		end

		-- return
		if not ty then ty = namedType(globals, nn.type) end

		if nn.const then ty = addQualifier(ty, "const") end

		if nn.volatile then ty = addQualifier(ty, "volatile") end

		xassert(not nn.restrict, options, n, "qualifier '%s' is not adequate here", nn.restrict)
		return ty, nn
	end
	-- This function parse the right parts and returns the identifier
	-- name, its type, and a storage class. Its arguments are the
	-- outputs of the corresponding <parseDeclarationSpecifier> plus
	-- the same arguments as <parseDeclarationSpecifier>.
	parseDeclarator = function(ty, extra, symtable, context, abstract)
		-- because of the curious syntax of c types, it turns out that
		-- it is easier to construct the chain of types in reverse
		local attr = collectAttributes()
		local where = n
		local name

		local function parseRev()
			local ty = nil

			if isName(tok) then
				xassert(not name, options, n, "extraneous identifier '%s'", tok)
				name = tok
				ti()
			elseif tok == "*" or tok == "^" or tok == "&" then --pointer
				local block = tok == "^" or nil -- code blocks (apple)
				local ref = tok == "&" or nil -- reference type
				ti()
				local nt, pt

				while
					tok == "const" or
					tok == "volatile" or
					specifierTable[tok] == "restrict" or
					isAttribute(tok)
				do
					nt = nt or Qualified({})

					if isAttribute(tok) then
						nt.attr = collectAttributes(nt.attr)
					else
						nt[specifierTable[tok]] = true
						ti()
					end
				end

				pt = parseRev()

				if nt then
					nt.t = pt
					pt = nt
				end

				ty = Pointer({t = pt, block = block, ref = ref})
			elseif tok == "(" then
				ti()
				local p = specifierTable[tok] or isTypeName(tok) or isAttribute(tok) or tok == ")"

				if abstract and p then
					ty = parsePrototype(ty, symtable, context, abstract)
				else
					attr = collectAttributes(attr)
					ty = parseRev()
					check(")")
					ti()
				end
			elseif tok ~= "[" then
				return ty
			end

			attr = collectAttributes(attr)

			while tok == "(" or tok == "[" and ti(1) ~= "[" do
				if tok == "(" then
					ti()
					ty = parsePrototype(ty, symtable, context, abstract)
					check(")")
					ti()
					ty.attr = collectAttributes(ty.attr)
				elseif tok == "[" then -- array
					ti()
					xassert(
						ty == nil or ty.tag ~= "Function",
						options,
						n,
						"functions cannot return arrays (they can return pointers)"
					)
					local nt = nil

					while
						specifierTable[tok] == "restrict" or
						tok == "const" or
						tok == "volatile" or
						options.dialect99 and
						tok == "static"
					do
						xassert(
							ty == nil or ty.tag ~= "Array",
							options,
							n,
							"only the outer array indices can contain qualifiers"
						)
						xassert(
							tok ~= "static" or context == "param",
							options,
							n,
							"static array qualifiers are only permitted in prototypes"
						)
						nt = nt or Qualified({})
						nt[specifierTable[tok]] = true
						ti()
					end

					if tok == "]" then
						xassert(
							ty == nil or ty.tag ~= "Array",
							options,
							n,
							"only the outer array can be specified without a size"
						)
						ty = Array({t = ty})
						ti()
					else
						local size = skipTo({}, "]", ",", ";")
						local v = tryEvaluateConstantExpression(options, n, size, symtable)
						xassert(v, options, n, "syntax error in array size specification")
						xassert(type(v) ~= "number" or v >= 0, options, n, "invalid array size '%s'", v)
						check("]")
						ti()
						ty = Array({t = ty, size = v})
					end

					if nt then
						if nt.sclass then
							xassert(ty.size, options, n, "static in this context needs an array size")
							nt.static = ty.size
							nt.sclass = nil
						end

						nt.t = ty.t
						ty.t = nt
					end
				end
			end

			return ty
		end

		-- get reversed type and reverse it back
		local rty = parseRev()

		while rty do
			local nty = rty.t
			rty.t = ty
			ty = rty
			rty = nty

			-- syntax checks
			if ty.tag == "Pointer" and ty.block then
				xassert(
					ty.t and ty.t.tag == "Function",
					options,
					where,
					"invalid use of code block operator '^'"
				)
			end
		end

		attr = collectAttributes(attr)

		-- distribute inlines and attributes
		if extra.inline then
			local tt = ty

			while tt and tt.tag ~= "Function" do
				tt = tt.t
			end

			xassert(tt, options, where, "only functions can be declared inline")
			tt.inline = true
		end

		attr = tableAppend(extra.attr, attr)

		if attr then
			local tt = ty

			while tt.tag == "Pointer" do
				tt = tt.t
			end

			if tt ~= "Function" and tt ~= "Struct" and tt ~= "Union" then tt = nil end

			if tt == nil and ty == "Qualified" then tt = ty end

			if tt == nil then
				ty = Qualified({t = ty})
				tt = ty
			end

			if tt then tt.attr = attr end
		end

		-- return
		xassert(abstract or name, options, n, "an identifier was expected")
		return name, ty, extra.sclass
	end
	-- We are now ready to parse a declaration in the specified context
	parseDeclaration = function(symtable, context)
		-- parse declaration specifiers
		local where = n
		local lty, lextra = parseDeclarationSpecifiers(symtable, context, false)

		-- loop over declarators
		if
			isName(tok) or
			tok == "*" or
			tok == "&" or
			tok == "^" or
			tok == "(" or
			tok == "["
		then
			-- parse declarator
			local name, ty, sclass = parseDeclarator(lty, lextra, symtable, context, false)

			-- first declarator may be a function definition
			if context == "global" and name and typeIs(ty, "Function") and tok == "{" then
				local body = skipPar({})
				xassert(
					sclass ~= "typedef",
					options,
					where,
					"storage class %s is not adequate for a function definition",
					sclass
				)
				processDeclaration(where, symtable, context, name, ty, sclass, body)
				return
			end

			-- process declarators
			while true do
				if typeIs(ty, "Function") then
					if not where then error() end

					processDeclaration(where, symtable, context, name, ty, sclass)
				else
					local init

					if tok == "=" then
						xassert(sclass ~= "typedef", options, n, "a typedef cannot have an initializer")
						ti()
						init = skipTo({}, specifierTable, ";", ",")
					end

					processDeclaration(
						where,
						symtable,
						context,
						name,
						ty,
						sclass,
						init
					)
				end

				if tok ~= "," then break else ti() end

				where = n
				name, ty, sclass = parseDeclarator(lty, lextra, symtable, context, false)
			end
		else
			xassert(lextra.newtype, options, where, "empty declaration")
		end

		-- the end
		check(";")
		ti()
	end
	parsePrototype = function(rty, symtable, context_, abstract_)
		local nsymtable = newScope(symtable)
		local ty = Function({t = rty})
		local i = 0

		while tok ~= ")" do
			if tok == "..." then
				i = i + 1
				ty[i] = Pair({ellipsis = true})
				ti()
				check(")")
			else
				local lty, lextra = parseDeclarationSpecifiers(nsymtable, "param", true)
				local pname, pty = parseDeclarator(lty, lextra, nsymtable, "param", true)
				local sty = pty.tag == "Qualified" and pty.t or pty

				if sty.tag == "Type" and sty.n == "void" then
					xassert(
						i == 0 and not pname and tok == ")" and pty == sty,
						options,
						n,
						"void in function parameters must appear first and alone"
					)
					return ty
				else
					if pty.tag == "Array" then
						pty = Pointer({t = pty.t})
					elseif pty.tag == "Qualified" and pty.t.tag == "Array" then
						pty.t = Pointer({t = pty.t.t})
					end

					i = i + 1
					local def

					if tok == "=" then
						ti()
						def = skipTo({}, specifierTable, ";", ",")
					end

					ty[i] = Pair({pty, pname, defval = def})

					if tok == "," then ti() else check(",", ")") end
				end
			end
		end

		if i == 0 then ty.withoutProto = true end

		return ty
	end
	parseStruct = function(symtable, context, abstract_, nn)
		check("struct", "union")
		local kind = tok
		ti()
		nn.attr = collectAttributes(nn.attr)
		local ttag, tnam

		if isName(tok) then
			ttag = tok
			tnam = kind .. " " .. ttag
			nn.newtype = true
			ti()
		end

		nn.attr = collectAttributes(nn.attr)

		if ttag and tok ~= "{" then return namedType(symtable, tnam) end

		-- parse real struct definition
		local ty

		if kind == "struct" then
			ty = Struct({n = ttag})
		else
			ty = Union({n = ttag})
		end

		local where = n
		check("{")
		ti()

		while tok and tok ~= "}" do
			where = n
			local lty, lextra = parseDeclarationSpecifiers(symtable, context)
			xassert(
				lextra.sclass == nil,
				options,
				where,
				"storage class '%s' is not allowed here",
				lextra.sclass
			)

			if tok == ";" then -- anonymous member
				xassert(lty.tag == "Struct" or lty.tag == "Union", options, where, "empty declaration")
				ty[1 + #ty] = Pair({lty})
			else
				while true do
					if tok == ":" then
						ti() -- unnamed bitfield
						local size = skipTo({}, ",", ";")
						local v = tryEvaluateConstantExpression(options, where, size, symtable)
						xassert(v, options, where, "syntax error in bitfield specification")
						xassert(
							type(v) ~= "number" or v >= 0,
							options,
							where,
							"invalid anonymous bitfield size (%s)",
							v
						)
						ty[1 + #ty] = Pair({lty, bitfield = v})
					else
						local pname, pty = parseDeclarator(lty, lextra, symtable, context)

						if pty.tag == "Array" and not pty.size then
							xwarning(options, where, "unsized arrays are not allowed here (ignoring)")
						elseif pty.tag == "Function" then
							xerror(options, where, "member functions are not allowed in C")
						end

						if tok == ":" then
							ti()
							xassert(lty == pty, options, where, "bitfields must be of integral types")
							local size = skipTo({}, ",", ";")
							local v = tryEvaluateConstantExpression(options, where, size, symtable)
							xassert(v, options, where, "syntax error in bitfield specification")
							xassert(type(v) ~= "number" or v > 0, options, where, "invalid bitfield size (%s)", v)
							ty[1 + #ty] = Pair({pty, pname, bitfield = v})
						else
							ty[1 + #ty] = Pair({pty, pname})
						end
					end

					check(",", ";")

					if tok == "," then ti() else break end
				end
			end

			check(";", "}")

			if tok == ";" then ti() end
		end

		check("}")
		ti()
		ty.attr = collectAttributes(nn.attr)
		nn.attr = nil

		-- name anonymous structs or enums (avoiding anonymous unions)
		if not ttag and tok ~= ";" and hasOption(options, "-Ztag") then
			ttag = unique()
			tnam = kind .. " " .. ttag
			ty.n = ttag
		end

		-- change tagged type as newtype
		if ttag then
			nn.newtype = true
			processDeclaration(where, symtable, context, tnam, ty, "[typetag]")
			return namedType(symtable, tnam)
		else
			return ty
		end
	end
	parseEnum = function(symtable, context, abstract_, nn)
		local kind = tok
		ti()
		nn.attr = collectAttributes(nn.attr)
		local ttag, tnam

		if isName(tok) then
			ttag = tok
			tnam = kind .. " " .. ttag
			nn.newtype = true
			ti()
		end

		nn.attr = collectAttributes(nn.attr)

		if ttag and tok ~= "{" then return namedType(symtable, tnam) end

		-- parse real struct definition
		local i = 1
		local v, a = 0, 0
		local ty = Enum({n = ttag})
		local ity = Qualified({
			t = namedType(globals, "int"),
			const = true,
			_enum = ty,
		})
		local where = n
		check("{")
		ti()

		repeat
			local nam = tok
			local init
			xassert(isName(nam), options, n, "identifier expected, got '%s'", tok)
			collectAttributes(nil) -- parsed but lost for now
			if ti() == "=" then
				ti()
				init = skipTo({}, ",", "}")
				v = tryEvaluateConstantExpression(options, n, init, symtable)
				xassert(v, options, n, "invalid value for enum constant")
				a = 0
			end

			local x

			if type(v) == "number" then
				x = v + a
			elseif a > 0 then
				x = string.format("%d+(%s)", a, v)
			else
				x = v
			end

			ty[i] = Pair({nam, init and v})
			a = a + 1
			i = i + 1
			processDeclaration(n, symtable, context, nam, ity, "[enum]", x)

			if tok == "," then ti() else check(",", "}") end		until tok == nil or tok == "}"

		check("}")
		ti()
		ty.attr = collectAttributes(nn.attr)
		nn.attr = nil

		-- name anonymous structs or enums
		if not ttag and hasOption(options, "-Ztag") then
			ttag = unique()
			tnam = kind .. " " .. ttag
			ty.n = ttag
		end

		-- change tagged type as newtype
		nn.newtype = true

		if ttag then
			processDeclaration(where, symtable, context, tnam, ty, "[typetag]")
			return namedType(symtable, tnam)
		else
			return ty
		end
	end

	-- When macros[1] is a table, the preprocessor attempts to
	-- preprocess and evaluate the definition of object-like macros. If
	-- the evaluation is successful, it adds it to the table.
	local function processMacroCaptures()
		local macros = options.macros
		local captable = macros and macros[1]

		if type(captable) == "table" then
			for _, v in ipairs(captable) do
				coroutine.yield(CppEvent(v))
			end

			macros[1] = {}
		end
	end

	-- main
	if options.stringToType then
		-- this is used to implement stringToType
		local lty, lextra = parseDeclarationSpecifiers(globals, "stringToType", true)
		local pname, pty, psclass = parseDeclarator(lty, lextra, globals, "stringToType", true)

		while tok == ";" do
			ti()
		end

		xassert(
			not psclass,
			options,
			n,
			"storage class '%s' is not adequate in this context",
			psclass
		)
		xassert(not tok, options, n, "garbage after type declaration")
		return pty, pname
	else
		-- main loop
		while tok do
			while tok == ";" do
				ti()
			end

			processMacroCaptures()
			parseDeclaration(globals, "global")
			processMacroCaptures()
		end

		return globals
	end
end

-- converts a string into a type and possibly a variable name
local function stringToType(s)
	local options = {silent = true, stringToType = true}
	local src = "<" .. s .. ">"
	local ss, t, n = pcall(
		parseDeclarations,
		options,
		{},
		filterSpaces,
		tokenizeLine,
		s,
		src,
		true
	)

	if not ss then return nil end

	while t and t._def do
		t = t._def
	end

	return t, n
end

-- processes the typedef options <-Ttypename>
-- and create the initial symbol table.
local function initialSymbols(options)
	local symbols = {}

	for _, v in ipairs(options) do
		if v:find("^%-T") then
			local d = v:gsub("^%-T%s*(.-)%s*$")
			xassert(
				d and d:find("[A-Za-z_$][A-Za-z0-9_$]*"),
				options,
				"<commandline>",
				"option -T must be followed by a valid identifier"
			)
			symbols[d] = TypeDef({n = d})
		end
	end

	return symbols
end

-- this function return an iterator function that
-- successively returns actions as tagged tables
-- with tags TypeDef, VarDef, FuncDef, or Declaration.
local function declarationIterator(options, lines, prefix)
	options = copyOptions(options)
	prefix = prefix or ""
	local symbols = initialSymbols(options)
	local macros = initialMacros(options)
	assert(type(options) == "table")
	assert(type(lines) == "function")
	assert(type(prefix) == "string")
	assert(type(symbols) == "table")
	assert(type(macros) == "table")
	options.macros = macros
	options.symbols = symbols
	local di = wrap(
		options,
		parseDeclarations,
		symbols,
		filterSpaces,
		expandMacros,
		macros,
		tokenize,
		processDirectives,
		macros,
		eliminateComments,
		joinLines,
		yieldLines,
		lines,
		prefix
	)
	return di, symbols, macros
end

local function parse(filename, outputfile, options)
	-- handle optional arguments
	options = options or {}
	outputfile = outputfile or "-"
	assert(type(filename) == "string")
	assert(type(options) == "table")
	local closeoutputfile = false

	if io.type(outputfile) ~= "file" then
		assert(type(outputfile) == "string")

		if outputfile == "-" then
			outputfile = io.output()
		else
			closeoutputfile = true
			outputfile = io.open(outputfile, "w")
		end
	end

	assert(io.type(outputfile) == "file")
	-- go
	local li = declarationIterator(options, io.lines(filename), filename)
	outputfile:write("+--------------------------\n")

	for action in li do
		local s = declToString(action)
		outputfile:write(string.format("| %s\n", tostring(action)))

		if s then outputfile:write(string.format("| %s\n", s)) end

		outputfile:write("+--------------------------\n")
	end

	if closeoutputfile then outputfile:close() end
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
-- EXPORTS
local cparser = {}
cparser.cpp = cpp
cparser.cppTokenIterator = cppTokenIterator
cparser.macroToString = macroToString
cparser.parse = parse
cparser.declarationIterator = declarationIterator
cparser.typeToString = typeToString
cparser.stringToType = stringToType
cparser.declToString = declToString
cparser.parseString = function(cdecl, options, args)
	options = options or {}
	options.filename = options.filename or cdecl
	local out = {}
	options.silent = true
	local ok, err = pcall(function()
		local str = cdecl
		str = ""

		if args then
			for i, v in ipairs(args) do
				str = str .. "typedef void* $" .. i .. ";\n"
			end
		end

		local i = 1
		local temp = cdecl:gsub("%$", function()
			return "$" .. i .. "$"
		end)

		if options.typeof then
			str = str .. "typedef " .. temp .. " out;"
			str = str:gsub("%$(%[[%d]+%]) out;", function(x)
				return "$ out" .. x .. ";"
			end)
		elseif options.ffinew then
			str = str .. "extern " .. temp .. " out;"
			str = str:gsub("(%[[%d%?]+%]) out;", function(x)
				return " out" .. x .. ";"
			end)
			str = str:gsub("%[%?+%]", function(x)
				return "[" .. (args[1]:GetData() or 1) .. "]"
			end)
		else
			str = str .. temp
		end

		local tokens = {}

		for token in cppTokenIterator(options, (str .. "\n"):gmatch("(.-)\n"), options.filename) do
			table.insert(tokens, token)
		end

		local i = 0
		local iterator = function()
			i = i + 1
			return tokens[i]
		end

		for action in declarationIterator(options, iterator, options.filename) do
			table.insert(out, action)
		end
	end)

	if not ok then return ok, err end

	return out
end
return cparser end ]=======], '@./nattlua/other/cparser.lua'))())(...) return __M end end
IMPORTS['nattlua/definitions/typed_ffi.nlua'] = assert(loadstring([=======[ return function() 





















 end ]=======], '@nattlua/definitions/typed_ffi.nlua'))()
do local __M; IMPORTS["nattlua.compiler"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local io = io
local error = error
local xpcall = xpcall
local tostring = tostring
local table = _G.table
local assert = assert
local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
local debug = _G.debug
local BuildBaseEnvironment = IMPORTS['nattlua.runtime.base_environment']("nattlua.runtime.base_environment").BuildBaseEnvironment
local setmetatable = _G.setmetatable
local Code = IMPORTS['nattlua.code']("nattlua.code").New
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local Lexer = IMPORTS['nattlua.lexer']("nattlua.lexer").New
local Parser = IMPORTS['nattlua.parser']("nattlua.parser").New
local Analyzer = IMPORTS['nattlua.analyzer']("nattlua.analyzer").New
local Emitter = IMPORTS['nattlua.transpiler.emitter']("nattlua.transpiler.emitter").New
local META = class.CreateTemplate("compiler")



function META:GetCode()
	return self.Code
end

function META:__tostring()
	local str = ""

	if self.parent_name then
		str = str .. "[" .. self.parent_name .. ":" .. self.parent_line .. "] "
	end

	local lua_code = self.Code:GetString()
	local line = lua_code:match("(.-)\n")

	if line then str = str .. line .. "..." else str = str .. lua_code end

	return str
end

local repl = function()
	return "\nbecause "
end

function META:OnDiagnostic(code, msg, severity, start, stop, node, ...)
	local level = 0
	local t = 0
	msg = msg:gsub(" because ", repl)

	if t > 0 then msg = "\n" .. msg end

	if self.analyzer and self.analyzer.processing_deferred_calls then
		msg = "DEFERRED CALL: " .. msg
	end

	local msg = code:BuildSourceCodePointMessage(helpers.FormatMessage(msg, ...), start, stop)
	local msg2 = ""

	for line in (msg .. "\n"):gmatch("(.-)\n") do
		msg2 = msg2 .. (" "):rep(4 - level * 2) .. line .. "\n"
	end

	msg = msg2

	if severity == "error" then
		msg = "\x1b[0;31m" .. msg .. "\x1b[0m"
	elseif severity == "warning" then
		msg = "\x1b[0;33m" .. msg .. "\x1b[0m"
	end

	if not _G.TEST then io.write(msg) end

	if
		severity == "fatal" or
		(
			_G.TEST and
			severity == "error" and
			not _G.TEST_DISABLE_ERROR_PRINT
		)
		or
		self.debug
	then
		local level = 2

		if _G.TEST then
			for i = 1, math.huge do
				local info = debug.getinfo(i)

				if not info then break end

				if info.source:find("@test/nattlua", nil, true) then
					level = i

					break
				end
			end
		end

		error(msg, level)
	end
end

local function stack_trace()
	local s = ""

	for i = 2, 50 do
		local info = debug.getinfo(i)

		if not info then break end

		if info.source:sub(1, 1) == "@" then
			if info.name == "Error" or info.name == "OnDiagnostic" then

			else
				s = s .. info.source:sub(2) .. ":" .. info.currentline .. " - " .. (
						info.name or
						"?"
					) .. "\n"
			end
		end
	end

	return s
end

local traceback = function(self, obj, msg)
	if self.debug or _G.TEST then
		local ret = {
			xpcall(function()
				msg = msg or "no error"
				local s = msg .. "\n" .. stack_trace()

				if self.analyzer then s = s .. self.analyzer:DebugStateToString() end

				return s
			end, function(msg)
				return debug.traceback(tostring(msg))
			end),
		}

		if not ret[1] then return "error in error handling: " .. tostring(ret[2]) end

		return table.unpack(ret, 2)
	end

	return msg
end

function META:Lex()
	local lexer = self.Lexer(self:GetCode())
	lexer.name = self.name
	self.lexer = lexer
	lexer.OnError = function(lexer, code, msg, start, stop, ...)
		self:OnDiagnostic(code, msg, "fatal", start, stop, nil, ...)
	end
	local ok, tokens = xpcall(function()
		return lexer:GetTokens()
	end, function(msg)
		return traceback(self, lexer, msg)
	end)

	if not ok then return nil, tokens end

	self.Tokens = tokens
	return self
end

function META:Parse()
	if not self.Tokens then
		local ok, err = self:Lex()

		if not ok then return ok, err end
	end

	local parser = self.Parser(self.Tokens, self.Code, self.config)
	self.parser = parser
	parser.OnError = function(parser, code, msg, start, stop, ...)
		self:OnDiagnostic(code, msg, "fatal", start, stop, nil, ...)
	end

	if self.OnNode then
		parser.OnNode = function(_, node)
			self:OnNode(node)
		end
	end

	local ok, res = xpcall(function()
		return parser:ParseRootNode()
	end, function(msg)
		return traceback(self, parser, msg)
	end)

	if not ok then return nil, res end

	self.SyntaxTree = res
	return self
end

function META:SetEnvironments(runtime, typesystem)
	self.default_environment = {}
	self.default_environment.runtime = runtime
	self.default_environment.typesystem = typesystem
end

function META:Analyze(analyzer, ...)
	if not self.SyntaxTree then
		local ok, err = self:Parse()

		if not ok then
			assert(err)
			return ok, err
		end
	end

	local analyzer = analyzer or self.Analyzer()
	self.analyzer = analyzer
	analyzer.compiler = self
	analyzer.OnDiagnostic = function(analyzer, ...)
		self:OnDiagnostic(...)
	end

	if self.default_environment then
		analyzer:SetDefaultEnvironment(self.default_environment["runtime"], "runtime")
		analyzer:SetDefaultEnvironment(self.default_environment["typesystem"], "typesystem")
	elseif self.default_environment ~= false then
		local runtime_env, typesystem_env = BuildBaseEnvironment()
		analyzer:SetDefaultEnvironment(runtime_env, "runtime")
		analyzer:SetDefaultEnvironment(typesystem_env, "typesystem")
	end

	analyzer.ResolvePath = self.OnResolvePath
	local args = {...}
	local ok, res = xpcall(function()
		local res = analyzer:AnalyzeRootStatement(self.SyntaxTree, table.unpack(args))
		analyzer:AnalyzeUnreachableCode()

		if analyzer.OnFinish then analyzer:OnFinish() end

		return res
	end, function(msg)
		return traceback(self, analyzer, msg)
	end)
	self.AnalyzedResult = res

	if not ok then return nil, res end

	return self
end

function META:Emit(cfg)
	if not self.SyntaxTree then
		local ok, err = self:Parse()

		if not ok then return ok, err end
	end

	local emitter = self.Emitter(cfg or self.config)
	self.emitter = emitter
	return emitter:BuildCode(self.SyntaxTree)
end

function META.New(
	lua_code,
	name,
	config,
	level
)
	local info = debug.getinfo(level or 2)
	local parent_line = info and info.currentline or "unknown line"
	local parent_name = info and info.source:sub(2) or "unknown name"
	name = name or (parent_name .. ":" .. parent_line)
	return setmetatable(
		{
			Code = Code(lua_code, name),
			parent_line = parent_line,
			parent_name = parent_name,
			config = config,
			Lexer = Lexer,
			Parser = Parser,
			Analyzer = Analyzer,
			Emitter = Emitter,
		},
		META
	)
end

return META end ]=======], '@./nattlua/compiler.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.runtime.base_environment"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Table = IMPORTS['nattlua.types.table']("nattlua.types.table").Table
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local LStringNoMeta = IMPORTS['nattlua.types.string']("nattlua.types.string").LStringNoMeta

if not _G.IMPORTS then
	_G.IMPORTS = setmetatable(
		{},
		{
			__index = function(self, key)
				return function()
					return _G["req" .. "uire"](key)
				end
			end,
		}
	)
end

local function import_data(path)
	local f, err = io.open(path, "rb")

	if not f then return nil, err end

	local code = f:read("*all")
	f:close()

	if not code then return nil, path .. " empty file" end

	return code
end

local function load_definitions()
	local path = "nattlua/definitions/index.nlua"
	local config = {}
	config.file_path = config.file_path or path
	config.file_name = config.file_name or path
	config.comment_type_annotations = false
	-- import_data will be transformed on build and the local function will not be used
	-- we canot use the upvalue path here either since this happens at parse time
	local code = assert(IMPORTS['DATA_nattlua/definitions/index.nlua']("nattlua/definitions/index.nlua"))
	local Compiler = IMPORTS['nattlua.compiler']("nattlua.compiler").New
	return Compiler(code, "@" .. path, config)
end

return {
	BuildBaseEnvironment = function()
		local compiler = load_definitions()
		assert(compiler:Lex())
		assert(compiler:Parse())
		local runtime_env = Table()
		local typesystem_env = Table()
		typesystem_env.string_metatable = Table()
		compiler:SetEnvironments(runtime_env, typesystem_env)
		local base = compiler.Analyzer()
		assert(compiler:Analyze(base))
		typesystem_env.string_metatable:Set(
			LStringNoMeta("__index"),
			base:Assert(typesystem_env:Get(LStringNoMeta("string")))
		)
		return runtime_env, typesystem_env
	end,
} end ]=======], '@./nattlua/runtime/base_environment.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.code"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("code")



function META:GetString()
	return self.Buffer
end

function META:GetName()
	return self.Name
end

function META:GetByteSize()
	return #self.Buffer
end

function META:GetStringSlice(start, stop)
	return self.Buffer:sub(start, stop)
end

function META:IsStringSlice(start, stop, str)
	return self.Buffer:sub(start, stop) == str
end

function META:GetByte(pos)
	return self.Buffer:byte(pos) or 0
end

function META:FindNearest(str, start)
	local _, pos = self.Buffer:find(str, start, true)

	if not pos then return nil end

	return pos + 1
end

local function remove_bom_header(str)
	if str:sub(1, 2) == "\xFE\xFF" then
		return str:sub(3)
	elseif str:sub(1, 3) == "\xEF\xBB\xBF" then
		return str:sub(4)
	end

	return str
end

local function get_default_name()
	local info = debug.getinfo(3)

	if info then
		local parent_line = info.currentline
		local parent_name = info.source:sub(2)
		return parent_name .. ":" .. parent_line
	end

	return "unknown line : unknown name"
end

function META:BuildSourceCodePointMessage(
	msg,
	start,
	stop,
	size
)
	return helpers.BuildSourceCodePointMessage(self:GetString(), self:GetName(), msg, start, stop, size)
end

function META.New(lua_code, name)
	local self = setmetatable(
		{
			Buffer = remove_bom_header(lua_code),
			Name = name or get_default_name(),
		},
		META
	)
	return self
end

if jit then
	local ffi = require("ffi")
	ffi.cdef("int memcmp ( const void * ptr1, const void * ptr2, size_t num );")

	function META:IsStringSlice(start, stop, str)
		return (
				ffi.C.memcmp
			)((ffi.cast("unsigned char*", self.Buffer)) - 1 + start, str, #str) == 0
	end

	function META:GetByte(pos)
		return ffi.cast("unsigned char*", self.Buffer)[pos - 1]
	end
end


return META end ]=======], '@./nattlua/code.lua'))())(...) return __M end end
IMPORTS['./nattlua/lexer/token.lua'] = assert(loadstring([=======[ return function() local table_pool = IMPORTS['nattlua.other.table_pool']("nattlua.other.table_pool")
local quote_helper = IMPORTS['nattlua.other.quote']("nattlua.other.quote")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("token")
local setmetatable = _G.setmetatable






function META:GetRoot()
	if self.parent then return (self.parent):GetRoot() end

	return self
end

function META:__tostring()
	return "[token - " .. self.type .. " - " .. quote_helper.QuoteToken(self.value) .. "]"
end

function META:AddType(obj)
	self.inferred_types = self.inferred_types or {}
	table.insert(self.inferred_types, obj)
end

function META:GetTypes()
	return self.inferred_types or {}
end

function META:GetLastType()
	return self.inferred_types and self.inferred_types[#self.inferred_types]
end

local new_token = table_pool(
	function()
		local x = {
			type = "unknown",
			value = "",
			whitespace = false,
			start = 0,
			stop = 0,
		}
		return x
	end,
	3105585
)

function META.New(
	type,
	is_whitespace,
	start,
	stop
)
	local tk = new_token()
	tk.type = type
	tk.is_whitespace = is_whitespace
	tk.start = start
	tk.stop = stop
	setmetatable(tk, META)
	return tk
end

return META end ]=======], '@./nattlua/lexer/token.lua'))()
do local __M; IMPORTS["nattlua.other.reverse_escape_string"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local map = {
	["a"] = "\a",
	["b"] = "\b",
	["f"] = "\f",
	["n"] = "\n",
	["r"] = "\r",
	["t"] = "\t",
	["v"] = "\v",
	["\\"] = "\\",
	["\""] = "\"",
	["'"] = "'",
}
map["00"] = "\0"
map["0"] = "\0"
map["x00"] = "\0"

for i = 1, 255 do
	local char = string.char(i)
	map[("%i"):format(i)] = char
	map[("x%02x"):format(i)] = char
end

local is_number = {}

for i = 0, 9 do
	is_number[tostring(i)] = true
end

local bytemarkers = {{0x7FF, 192}, {0xFFFF, 224}, {0x1FFFFF, 240}}

local function unicode_escape(decimal)
	if decimal < 128 then return string.char(decimal) end

	local charbytes = {}

	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes + 1, 2, -1 do
				local mod = decimal % 64
				decimal = (decimal - mod) / 64
				charbytes[b] = string.char(128 + mod)
			end

			charbytes[1] = string.char(vals[2] + decimal)

			break
		end
	end

	return table.concat(charbytes)
end

local function reverse_escape_string(str)
	local pos = 1

	while true do
		local start, stop = str:find("\\", pos, true)

		if not start or not stop then break end

		local len = 2
		local char = str:sub(start + 1, stop + 1)

		if char == "u" then
			if str:sub(start + 2, stop + 2) == "{" then
				local len = 3

				while str:sub(start + len, stop + len) ~= "}" do
					len = len + 1
				end

				local hex = tonumber(str:sub(start + 3, stop + len - 1), 16)

				if hex then
					str = str:sub(1, start - 1) .. unicode_escape(hex) .. str:sub(stop + len + 1)
				end
			end
		else
			-- hex escape is always 3 characters
			if char == "x" then
				len = 4
				char = str:sub(start + 1, stop + len - 1):lower()
			elseif is_number[char] then
				-- byte escape can be between 1 and 3 characters
				len = 2

				if is_number[str:sub(start + 2, stop + 2)] then
					len = 3

					if is_number[str:sub(start + 3, stop + 3)] then len = 4 end
				end

				char = str:sub(start + 1, stop + len - 1)

				-- remove left zero padding
				if #char == 3 and char:sub(1, 1) == "0" then
					char = char:sub(2)

					if #char == 2 and char:sub(1, 1) == "0" then char = char:sub(2) end
				end
			end

			if map[char] then
				str = str:sub(1, start - 1) .. map[char] .. str:sub(stop + len)
			end
		end

		pos = pos + 1
	end

	return str
end

return reverse_escape_string end ]=======], '@./nattlua/other/reverse_escape_string.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.lexer.token"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local table_pool = IMPORTS['nattlua.other.table_pool']("nattlua.other.table_pool")
local quote_helper = IMPORTS['nattlua.other.quote']("nattlua.other.quote")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("token")
local setmetatable = _G.setmetatable






function META:GetRoot()
	if self.parent then return (self.parent):GetRoot() end

	return self
end

function META:__tostring()
	return "[token - " .. self.type .. " - " .. quote_helper.QuoteToken(self.value) .. "]"
end

function META:AddType(obj)
	self.inferred_types = self.inferred_types or {}
	table.insert(self.inferred_types, obj)
end

function META:GetTypes()
	return self.inferred_types or {}
end

function META:GetLastType()
	return self.inferred_types and self.inferred_types[#self.inferred_types]
end

local new_token = table_pool(
	function()
		local x = {
			type = "unknown",
			value = "",
			whitespace = false,
			start = 0,
			stop = 0,
		}
		return x
	end,
	3105585
)

function META.New(
	type,
	is_whitespace,
	start,
	stop
)
	local tk = new_token()
	tk.type = type
	tk.is_whitespace = is_whitespace
	tk.start = start
	tk.stop = stop
	setmetatable(tk, META)
	return tk
end

return META end ]=======], '@./nattlua/lexer/token.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.syntax.characters"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local characters = {}
local B = string.byte

function characters.IsNumber(c)
	return (c >= B("0") and c <= B("9"))
end

function characters.IsLetter(c)
	return (
			c >= B("a") and
			c <= B("z")
		)
		or
		(
			c >= B("A") and
			c <= B("Z")
		)
		or
		(
			c == B("_") or
			c == B("@")
			or
			c >= 127
		)
end

function characters.IsDuringLetter(c)
	return characters.IsLetter(c) or characters.IsNumber(c)
end

function characters.IsSpace(c)
	return c > 0 and c <= 32
end

function characters.IsSymbol(c)
	return c ~= B("_") and
		(
			(
				c >= B("!") and
				c <= B("/")
			)
			or
			(
				c >= B(":") and
				c <= B("?")
			)
			or
			(
				c >= B("[") and
				c <= B("`")
			)
			or
			(
				c >= B("{") and
				c <= B("~")
			)
		)
end

function characters.IsHex(c)
	return characters.IsNumber(c) or
		(
			c >= B("a") and
			c <= B("f")
		)
		or
		(
			c >= B("A") and
			c <= B("F")
		)
end

if jit then
	local ffi = require("ffi")

	for key, val in pairs(characters) do
		local map = ffi.new("char[256]")

		for i = 0, 255 do
			map[i] = val(i) and 1 or 0
		end

		characters[key] = function(c)
			return map[c] ~= 0
		end
	end
end

return characters end ]=======], '@./nattlua/syntax/characters.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.syntax"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local class = IMPORTS['nattlua.other.class']("nattlua.other.class")



local META = class.CreateTemplate("syntax")



function META.New()
	local self = setmetatable(
		{
			NumberAnnotations = {},
			BinaryOperatorInfo = {},
			Symbols = {},
			BinaryOperators = {},
			PrefixOperators = {},
			PostfixOperators = {},
			PrimaryBinaryOperators = {},
			SymbolCharacters = {},
			SymbolPairs = {},
			KeywordValues = {},
			Keywords = {},
			NonStandardKeywords = {},
			BinaryOperatorFunctionTranslate = {},
			PostfixOperatorFunctionTranslate = {},
			PrefixOperatorFunctionTranslate = {},
		},
		META
	)
	return self
end

local function has_value(tbl, value)
	for k, v in ipairs(tbl) do
		if v == value then return true end
	end

	return false
end

function META:AddSymbols(tbl)
	for _, symbol in pairs(tbl) do
		if symbol:find("%p") and not has_value(self.Symbols, symbol) then
			table.insert(self.Symbols, symbol)
		end
	end

	table.sort(self.Symbols, function(a, b)
		return #a > #b
	end)
end

function META:AddNumberAnnotations(tbl)
	for i, v in ipairs(tbl) do
		if not has_value(self.NumberAnnotations, v) then
			table.insert(self.NumberAnnotations, v)
		end
	end

	table.sort(self.NumberAnnotations, function(a, b)
		return #a > #b
	end)
end

function META:GetNumberAnnotations()
	return self.NumberAnnotations
end

function META:AddBinaryOperators(tbl)
	for priority, group in ipairs(tbl) do
		for _, token in ipairs(group) do
			local right = token:sub(1, 1) == "R"

			if right then token = token:sub(2) end

			if right then
				self.BinaryOperatorInfo[token] = {
					left_priority = priority + 1,
					right_priority = priority,
				}
			else
				self.BinaryOperatorInfo[token] = {
					left_priority = priority,
					right_priority = priority,
				}
			end

			self:AddSymbols({token})
			self.BinaryOperators[token] = true
		end
	end
end

function META:GetBinaryOperatorInfo(tk)
	return self.BinaryOperatorInfo[tk.value]
end

function META:AddPrefixOperators(tbl)
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.PrefixOperators[str] = true
	end
end

function META:IsPrefixOperator(token)
	return self.PrefixOperators[token.value]
end

function META:AddPostfixOperators(tbl)
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.PostfixOperators[str] = true
	end
end

function META:IsPostfixOperator(token)
	return self.PostfixOperators[token.value]
end

function META:AddPrimaryBinaryOperators(tbl)
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.PrimaryBinaryOperators[str] = true
	end
end

function META:IsPrimaryBinaryOperator(token)
	return self.PrimaryBinaryOperators[token.value]
end

function META:AddSymbolCharacters(tbl)
	local list = {}

	for _, val in ipairs(tbl) do
		if type(val) == "table" then
			table.insert(list, val[1])
			table.insert(list, val[2])
			self.SymbolPairs[val[1]] = val[2]
		else
			table.insert(list, val)
		end
	end

	self.SymbolCharacters = list
	self:AddSymbols(list)
end

function META:AddKeywords(tbl)
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.Keywords[str] = true
	end
end

function META:IsKeyword(token)
	return self.Keywords[token.value]
end

function META:AddKeywordValues(tbl)
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.Keywords[str] = true
		self.KeywordValues[str] = true
	end
end

function META:IsKeywordValue(token)
	return self.KeywordValues[token.value]
end

function META:AddNonStandardKeywords(tbl)
	self:AddSymbols(tbl)

	for _, str in ipairs(tbl) do
		self.NonStandardKeywords[str] = true
	end
end

function META:IsNonStandardKeyword(token)
	return self.NonStandardKeywords[token.value]
end

function META:GetSymbols()
	return self.Symbols
end

function META:AddBinaryOperatorFunctionTranslate(tbl)
	for k, v in pairs(tbl) do
		local a, b, c = v:match("(.-)A(.-)B(.*)")

		if a and b and c then
			self.BinaryOperatorFunctionTranslate[k] = {" " .. a, b, c .. " "}
		end
	end
end

function META:GetFunctionForBinaryOperator(token)
	return self.BinaryOperatorFunctionTranslate[token.value]
end

function META:AddPrefixOperatorFunctionTranslate(tbl)
	for k, v in pairs(tbl) do
		local a, b = v:match("^(.-)A(.-)$")

		if a and b then
			self.PrefixOperatorFunctionTranslate[k] = {" " .. a, b .. " "}
		end
	end
end

function META:GetFunctionForPrefixOperator(token)
	return self.PrefixOperatorFunctionTranslate[token.value]
end

function META:AddPostfixOperatorFunctionTranslate(tbl)
	for k, v in pairs(tbl) do
		local a, b = v:match("^(.-)A(.-)$")

		if a and b then
			self.PostfixOperatorFunctionTranslate[k] = {" " .. a, b .. " "}
		end
	end
end

function META:GetFunctionForPostfixOperator(token)
	return self.PostfixOperatorFunctionTranslate[token.value]
end

function META:IsValue(token)
	if token.type == "number" or token.type == "string" then return true end

	if self:IsKeywordValue(token) then return true end

	if self:IsKeyword(token) then return false end

	if token.type == "letter" then return true end

	return false
end

function META:GetTokenType(tk)
	if tk.type == "letter" and self:IsKeyword(tk) then
		return "keyword"
	elseif tk.type == "symbol" then
		if self:IsPrefixOperator(tk) then
			return "operator_prefix"
		elseif self:IsPostfixOperator(tk) then
			return "operator_postfix"
		elseif self:GetBinaryOperatorInfo(tk) then
			return "operator_binary"
		end
	end

	return tk.type
end

return META end ]=======], '@./nattlua/syntax.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.syntax.runtime"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Syntax = IMPORTS['nattlua.syntax']("nattlua.syntax").New
local runtime = Syntax()
runtime:AddSymbolCharacters(
	{
		",",
		";",
		"=",
		"::",
		{"(", ")"},
		{"{", "}"},
		{"[", "]"},
		{"\"", "\""},
		{"'", "'"},
		{"<|", "|>"},
	}
)
runtime:AddNumberAnnotations({
	"ull",
	"ll",
	"ul",
	"i",
})
runtime:AddKeywords(
	{
		"do",
		"end",
		"if",
		"then",
		"else",
		"elseif",
		"for",
		"in",
		"while",
		"repeat",
		"until",
		"break",
		"return",
		"local",
		"function",
		"and",
		"not",
		"or",
		-- these are just to make sure all code is covered by tests
		"ÆØÅ",
		"ÆØÅÆ",
	}
)
-- these are keywords, but can be used as names
runtime:AddNonStandardKeywords({"continue", "import", "literal", "ref", "mutable", "goto"})
runtime:AddKeywordValues({
	"...",
	"nil",
	"true",
	"false",
})
runtime:AddPrefixOperators({"-", "#", "not", "!", "~", "supertype"})
runtime:AddPostfixOperators(
	{
		-- these are just to make sure all code is covered by tests
		"++",
		"ÆØÅ",
		"ÆØÅÆ",
	}
)
runtime:AddBinaryOperators(
	{
		{"or", "||"},
		{"and", "&&"},
		{"<", ">", "<=", ">=", "~=", "==", "!="},
		{"|"},
		{"~"},
		{"&"},
		{"<<", ">>"},
		{"R.."}, -- right associative
		{"+", "-"},
		{"*", "/", "/idiv/", "%"},
		{"R^"}, -- right associative
	}
)
runtime:AddPrimaryBinaryOperators({
	".",
	":",
})
runtime:AddBinaryOperatorFunctionTranslate(
	{
		[">>"] = "bit.rshift(A, B)",
		["<<"] = "bit.lshift(A, B)",
		["|"] = "bit.bor(A, B)",
		["&"] = "bit.band(A, B)",
		["//"] = "math.floor(A / B)",
		["~"] = "bit.bxor(A, B)",
	}
)
runtime:AddPrefixOperatorFunctionTranslate({
	["~"] = "bit.bnot(A)",
})
runtime:AddPostfixOperatorFunctionTranslate({
	["++"] = "(A+1)",
	["ÆØÅ"] = "(A)",
	["ÆØÅÆ"] = "(A)",
})
return runtime end ]=======], '@./nattlua/syntax/runtime.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.lexer"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) 



local reverse_escape_string = IMPORTS['nattlua.other.reverse_escape_string']("nattlua.other.reverse_escape_string")
local Token = IMPORTS['nattlua.lexer.token']("nattlua.lexer.token").New
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local setmetatable = _G.setmetatable
local ipairs = _G.ipairs
local META = class.CreateTemplate("lexer")


local B = string.byte

function META:GetLength()
	return self.Code:GetByteSize()
end

function META:GetStringSlice(start, stop)
	return self.Code:GetStringSlice(start, stop)
end

function META:PeekByte(offset)
	offset = offset or 0
	return self.Code:GetByte(self.Position + offset)
end

function META:FindNearest(str)
	return self.Code:FindNearest(str, self.Position)
end

function META:ReadByte()
	local char = self:PeekByte()
	self.Position = self.Position + 1
	return char
end

function META:ResetState()
	self.Position = 1
end

function META:Advance(len)
	self.Position = self.Position + len
end

function META:SetPosition(i)
	self.Position = i
end

function META:GetPosition()
	return self.Position
end

function META:TheEnd()
	return self.Position > self:GetLength()
end

function META:IsString(str, offset)
	offset = offset or 0
	return self.Code:IsStringSlice(self.Position + offset, self.Position + offset + #str - 1, str)
end

function META:IsStringLower(str)
	return self.Code:GetStringSlice(self.Position, self.Position + #str - 1):lower() == str
end

function META:OnError(
	code,
	msg,
	start,
	stop
) end

function META:Error(msg, start, stop)
	self:OnError(self.Code, msg, start or self.Position, stop or self.Position)
end

function META:ReadShebang()
	if self.Position == 1 and self:IsString("#") then
		for _ = self.Position, self:GetLength() do
			self:Advance(1)

			if self:IsString("\n") then break end
		end

		return true
	end

	return false
end

function META:ReadEndOfFile()
	if self.Position > self:GetLength() then
		-- nothing to capture, but remaining whitespace will be added
		self:Advance(1)
		return true
	end

	return false
end

function META:ReadUnknown()
	self:Advance(1)
	return "unknown", false
end

function META:Read()
	return nil, nil
end

function META:ReadSimple()
	if self:ReadShebang() then return "shebang", false, 1, self.Position - 1 end

	local start = self.Position
	local type, is_whitespace = self:Read()

	if type == "discard" then return self:ReadSimple() end

	if not type then
		if self:ReadEndOfFile() then
			type = "end_of_file"
			is_whitespace = false
		end
	end

	if not type then type, is_whitespace = self:ReadUnknown() end

	is_whitespace = is_whitespace or false
	return type, is_whitespace, start, self.Position - 1
end

function META:NewToken(
	type,
	is_whitespace,
	start,
	stop
)
	return Token(type, is_whitespace, start, stop)
end

do
	function META:ReadToken()
		local type, is_whitespace, start, stop = self:ReadSimple() -- TODO: unpack not working
		local token = self:NewToken(type, is_whitespace, start, stop)
		token.value = self:GetStringSlice(token.start, token.stop)

		if token.type == "string" then
			if token.value:sub(1, 1) == [["]] or token.value:sub(1, 1) == [[']] then
				token.string_value = reverse_escape_string(token.value:sub(2, #token.value - 1))
			elseif token.value:sub(1, 1) == "[" then
				local start = token.value:find("[", 2, true)

				if not start then error("start not found") end

				token.string_value = token.value:sub(start + 1, -start - 1)
			end
		end

		return token
	end

	function META:ReadNonWhitespaceToken()
		local token = self:ReadToken()

		if not token.is_whitespace then
			token.whitespace = {}
			return token
		end

		local whitespace = {token}
		local whitespace_i = 2

		for i = self.Position, self:GetLength() + 1 do
			local token = self:ReadToken()

			if not token.is_whitespace then
				token.whitespace = whitespace
				return token
			end

			whitespace[whitespace_i] = token
			whitespace_i = whitespace_i + 1
		end
	end
end

function META:ReadFirstFromArray(strings)
	for _, str in ipairs(strings) do
		if self:IsString(str) then
			self:Advance(#str)
			return true
		end
	end

	return false
end

function META:ReadFirstLowercaseFromArray(strings)
	for _, str in ipairs(strings) do
		if self:IsStringLower(str) then
			self:Advance(#str)
			return true
		end
	end

	return false
end

function META:GetTokens()
	self:ResetState()
	local tokens = {}
	local tokens_i = 1

	for i = self.Position, self:GetLength() + 1 do
		local token = self:ReadNonWhitespaceToken()

		if not token then break end

		tokens[tokens_i] = token
		tokens_i = tokens_i + 1

		if token.type == "end_of_file" then break end
	end

	return tokens
end

function META.New(code)
	local self = setmetatable({
		Code = code,
		Position = 1,
	}, META)
	self:ResetState()
	return self
end

-- lua lexer
do
	

	

	
	local characters = IMPORTS['nattlua.syntax.characters']("nattlua.syntax.characters")
	local runtime_syntax = IMPORTS['nattlua.syntax.runtime']("nattlua.syntax.runtime")
	local helpers = IMPORTS['nattlua.other.quote']("nattlua.other.quote")

	local function ReadSpace(lexer)
		if characters.IsSpace(lexer:PeekByte()) then
			while not lexer:TheEnd() do
				lexer:Advance(1)

				if not characters.IsSpace(lexer:PeekByte()) then break end
			end

			return "space"
		end

		return false
	end

	local function ReadLetter(lexer)
		if not characters.IsLetter(lexer:PeekByte()) then return false end

		while not lexer:TheEnd() do
			lexer:Advance(1)

			if not characters.IsDuringLetter(lexer:PeekByte()) then break end
		end

		return "letter"
	end

	local function ReadMultilineCComment(lexer)
		if not lexer:IsString("/*") then return false end

		local start = lexer:GetPosition()
		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("*/") then
				lexer:Advance(2)
				return "multiline_comment"
			end

			lexer:Advance(1)
		end

		lexer:Error(
			"expected multiline c comment to end, reached end of code",
			start,
			start + 1
		)
		return false
	end

	local function ReadLineCComment(lexer)
		if not lexer:IsString("//") then return false end

		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("\n") then break end

			lexer:Advance(1)
		end

		return "line_comment"
	end

	local function ReadLineComment(lexer)
		if not lexer:IsString("--") then return false end

		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("\n") then break end

			lexer:Advance(1)
		end

		return "line_comment"
	end

	local function ReadMultilineComment(lexer)
		if
			not lexer:IsString("--[") or
			(
				not lexer:IsString("[", 3) and
				not lexer:IsString("=", 3)
			)
		then
			return false
		end

		local start = lexer:GetPosition()
		-- skip past the --[
		lexer:Advance(3)

		while lexer:IsString("=") do
			lexer:Advance(1)
		end

		if not lexer:IsString("[") then
			-- if we have an incomplete multiline comment, it's just a single line comment
			lexer:SetPosition(start)
			return ReadLineComment(lexer)
		end

		-- skip the last [
		lexer:Advance(1)
		local pos = lexer:FindNearest("]" .. string.rep("=", (lexer:GetPosition() - start) - 4) .. "]")

		if pos then
			lexer:SetPosition(pos)
			return "multiline_comment"
		end

		lexer:Error("expected multiline comment to end, reached end of code", start, start + 1)
		lexer:SetPosition(start + 2)
		return false
	end

	local function ReadInlineAnalyzerDebugCode(lexer)
		if not lexer:IsString("§") then return false end

		lexer:Advance(#"§")

		while not lexer:TheEnd() do
			if
				lexer:IsString("\n") or
				(
					lexer.comment_escape and
					lexer:IsString(lexer.comment_escape)
				)
			then
				break
			end

			lexer:Advance(1)
		end

		return "analyzer_debug_code"
	end

	local function ReadInlineParserDebugCode(lexer)
		if not lexer:IsString("£") then return false end

		lexer:Advance(#"£")

		while not lexer:TheEnd() do
			if
				lexer:IsString("\n") or
				(
					lexer.comment_escape and
					lexer:IsString(lexer.comment_escape)
				)
			then
				break
			end

			lexer:Advance(1)
		end

		return "parser_debug_code"
	end

	local function ReadNumberPowExponent(lexer, what)
		lexer:Advance(1)

		if lexer:IsString("+") or lexer:IsString("-") then
			lexer:Advance(1)

			if not characters.IsNumber(lexer:PeekByte()) then
				lexer:Error(
					"malformed " .. what .. " expected number, got " .. string.char(lexer:PeekByte()),
					lexer:GetPosition() - 2
				)
				return false
			end
		end

		while not lexer:TheEnd() do
			if not characters.IsNumber(lexer:PeekByte()) then break end

			lexer:Advance(1)
		end

		return true
	end

	local function ReadHexNumber(lexer)
		if
			not lexer:IsString("0") or
			(
				not lexer:IsString("x", 1) and
				not lexer:IsString("X", 1)
			)
		then
			return false
		end

		lexer:Advance(2)
		local has_dot = false

		while not lexer:TheEnd() do
			if lexer:IsString("_") then lexer:Advance(1) end

			if not has_dot and lexer:IsString(".") then
				-- 22..66 would be a number range
				-- so we have to return 22 only
				if lexer:IsString(".", 1) then break end

				has_dot = true
				lexer:Advance(1)
			end

			if characters.IsHex(lexer:PeekByte()) then
				lexer:Advance(1)
			else
				if characters.IsSpace(lexer:PeekByte()) or characters.IsSymbol(lexer:PeekByte()) then
					break
				end

				if lexer:IsString("p") or lexer:IsString("P") then
					if ReadNumberPowExponent(lexer, "pow") then break end
				end

				if lexer:ReadFirstLowercaseFromArray(runtime_syntax:GetNumberAnnotations()) then
					break
				end

				lexer:Error(
					"malformed hex number, got " .. string.char(lexer:PeekByte()),
					lexer:GetPosition() - 1,
					lexer:GetPosition()
				)
				return false
			end
		end

		return "number"
	end

	local function ReadBinaryNumber(lexer)
		if
			not lexer:IsString("0") or
			not (
				lexer:IsString("b", 1) and
				not lexer:IsString("B", 1)
			)
		then
			return false
		end

		-- skip past 0b
		lexer:Advance(2)

		while not lexer:TheEnd() do
			if lexer:IsString("_") then lexer:Advance(1) end

			if lexer:IsString("1") or lexer:IsString("0") then
				lexer:Advance(1)
			else
				if characters.IsSpace(lexer:PeekByte()) or characters.IsSymbol(lexer:PeekByte()) then
					break
				end

				if lexer:IsString("e") or lexer:IsString("E") then
					if ReadNumberPowExponent(lexer, "exponent") then break end
				end

				if lexer:ReadFirstLowercaseFromArray(runtime_syntax:GetNumberAnnotations()) then
					break
				end

				lexer:Error(
					"malformed binary number, got " .. string.char(lexer:PeekByte()),
					lexer:GetPosition() - 1,
					lexer:GetPosition()
				)
				return false
			end
		end

		return "number"
	end

	local function ReadDecimalNumber(lexer)
		if
			not characters.IsNumber(lexer:PeekByte()) and
			(
				not lexer:IsString(".") or
				not characters.IsNumber(lexer:PeekByte(1))
			)
		then
			return false
		end

		-- if we start with a dot
		-- .0
		local has_dot = false

		if lexer:IsString(".") then
			has_dot = true
			lexer:Advance(1)
		end

		while not lexer:TheEnd() do
			if lexer:IsString("_") then lexer:Advance(1) end

			if not has_dot and lexer:IsString(".") then
				-- 22..66 would be a number range
				-- so we have to return 22 only
				if lexer:IsString(".", 1) then break end

				has_dot = true
				lexer:Advance(1)
			end

			if characters.IsNumber(lexer:PeekByte()) then
				lexer:Advance(1)
			else
				if characters.IsSpace(lexer:PeekByte()) or characters.IsSymbol(lexer:PeekByte()) then
					break
				end

				if lexer:IsString("e") or lexer:IsString("E") then
					if ReadNumberPowExponent(lexer, "exponent") then break end
				end

				if lexer:ReadFirstLowercaseFromArray(runtime_syntax:GetNumberAnnotations()) then
					break
				end

				lexer:Error(
					"malformed number, got " .. string.char(lexer:PeekByte()) .. " in decimal notation",
					lexer:GetPosition() - 1,
					lexer:GetPosition()
				)
				return false
			end
		end

		return "number"
	end

	local function ReadMultilineString(lexer)
		if
			not lexer:IsString("[", 0) or
			(
				not lexer:IsString("[", 1) and
				not lexer:IsString("=", 1)
			)
		then
			return false
		end

		local start = lexer:GetPosition()
		lexer:Advance(1)

		if lexer:IsString("=") then
			while not lexer:TheEnd() do
				lexer:Advance(1)

				if not lexer:IsString("=") then break end
			end
		end

		if not lexer:IsString("[") then
			lexer:Error(
				"expected multiline string " .. helpers.QuoteToken(lexer:GetStringSlice(start, lexer:GetPosition() - 1) .. "[") .. " got " .. helpers.QuoteToken(lexer:GetStringSlice(start, lexer:GetPosition())),
				start,
				start + 1
			)
			return false
		end

		lexer:Advance(1)
		local closing = "]" .. string.rep("=", (lexer:GetPosition() - start) - 2) .. "]"
		local pos = lexer:FindNearest(closing)

		if pos then
			lexer:SetPosition(pos)
			return "string"
		end

		lexer:Error(
			"expected multiline string " .. helpers.QuoteToken(closing) .. " reached end of code",
			start,
			start + 1
		)
		return false
	end

	local ReadSingleQuoteString
	local ReadDoubleQuoteString

	do
		local B = string.byte
		local escape_character = B([[\]])

		local function build_string_reader(name, quote)
			return function(lexer)
				if not lexer:IsString(quote) then return false end

				local start = lexer:GetPosition()
				lexer:Advance(1)

				while not lexer:TheEnd() do
					local char = lexer:ReadByte()

					if char == escape_character then
						local char = lexer:ReadByte()

						if char == B("z") and not lexer:IsString(quote) then
							ReadSpace(lexer)
						end
					elseif char == B("\n") then
						lexer:Advance(-1)
						lexer:Error("expected " .. name:lower() .. " quote to end", start, lexer:GetPosition() - 1)
						return "string"
					elseif char == B(quote) then
						return "string"
					end
				end

				lexer:Error(
					"expected " .. name:lower() .. " quote to end: reached end of file",
					start,
					lexer:GetPosition() - 1
				)
				return "string"
			end
		end

		ReadDoubleQuoteString = build_string_reader("double", "\"")
		ReadSingleQuoteString = build_string_reader("single", "'")
	end

	local function ReadSymbol(lexer)
		if lexer:ReadFirstFromArray(runtime_syntax:GetSymbols()) then return "symbol" end

		return false
	end

	local function ReadCommentEscape(lexer)
		if lexer:IsString("--[[#") then
			lexer:Advance(5)
			lexer.comment_escape = "]]"
			return "comment_escape"
		elseif lexer:IsString("--[=[#") then
			lexer:Advance(6)
			lexer.comment_escape = "]=]"
			return "comment_escape"
		end

		return false
	end

	local function ReadRemainingCommentEscape(lexer)
		if lexer.comment_escape and lexer:IsString(lexer.comment_escape) then
			lexer:Advance(#lexer.comment_escape)
			lexer.comment_escape = nil
			return "comment_escape"
		end

		return false
	end

	function META:Read()
		if ReadRemainingCommentEscape(self) then return "discard", false end

		do
			local name = ReadSpace(self) or
				ReadCommentEscape(self) or
				ReadMultilineCComment(self) or
				ReadLineCComment(self) or
				ReadMultilineComment(self) or
				ReadLineComment(self)

			if name then return name, true end
		end

		do
			local name = ReadInlineAnalyzerDebugCode(self) or
				ReadInlineParserDebugCode(self) or
				ReadHexNumber(self) or
				ReadBinaryNumber(self) or
				ReadDecimalNumber(self) or
				ReadMultilineString(self) or
				ReadSingleQuoteString(self) or
				ReadDoubleQuoteString(self) or
				ReadLetter(self) or
				ReadSymbol(self)

			if name then return name, false end
		end
	end
end

return META end ]=======], '@./nattlua/lexer.lua'))())(...) return __M end end
IMPORTS['./nattlua/parser/nodes.nlua'] = assert(loadstring([=======[ return function() 

























































return {
	ExpressionKind = ExpressionKind,
	StatementKind = StatementKind,
	Node = Node,
	statement = statement,
	expression = expression,
} end ]=======], '@./nattlua/parser/nodes.nlua'))()
IMPORTS['./nattlua/parser/../parser/nodes.nlua'] = assert(loadstring([=======[ return function() 

























































return {
	ExpressionKind = ExpressionKind,
	StatementKind = StatementKind,
	Node = Node,
	statement = statement,
	expression = expression,
} end ]=======], '@./nattlua/parser/../parser/nodes.nlua'))()
IMPORTS['./nattlua/parser/../config.nlua'] = assert(loadstring([=======[ return function() 





return {
	LexerConfig = nil,
	ParserConfig = nil,
	AnalyzerConfig = nil,
	TranspilerConfig = nil,
	CompilerConfig = nil,
} end ]=======], '@./nattlua/parser/../config.nlua'))()
IMPORTS['nattlua/parser/nodes.nlua'] = assert(loadstring([=======[ return function() 

























































return {
	ExpressionKind = ExpressionKind,
	StatementKind = StatementKind,
	Node = Node,
	statement = statement,
	expression = expression,
} end ]=======], '@nattlua/parser/nodes.nlua'))()
do local __M; IMPORTS["nattlua.parser.node"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) 




local ipairs = _G.ipairs
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local type = _G.type
local table = _G.table
local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
local quote_helper = IMPORTS['nattlua.other.quote']("nattlua.other.quote")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("node")



function META.New(init)
	init.tokens = {}
	return setmetatable(init, META)
end

function META:__tostring()
	local str = "[" .. self.type .. " - " .. self.kind

	if self.type == "statement" then
		local lua_code = self.Code:GetString()
		local name = self.Code:GetName()

		if name:sub(-4) == ".lua" or name:sub(-5) == ".nlua" then
			local data = helpers.SubPositionToLinePosition(lua_code, self:GetStartStop())
			local name = name

			if name:sub(1, 1) == "@" then name = name:sub(2) end

			str = str .. " @ " .. name .. ":" .. data.line_start
		end
	elseif self.type == "expression" then
		if self.kind == "postfix_call" and self.Code then
			local lua_code = self.Code:GetString()
			local name = self.Code:GetName()

			if name and lua_code and (name:sub(-4) == ".lua" or name:sub(-5) == ".nlua") then
				local data = helpers.SubPositionToLinePosition(lua_code, self:GetStartStop())
				local name = name

				if name:sub(1, 1) == "@" then name = name:sub(2) end

				str = str .. " @ " .. name .. ":" .. data.line_start
			end
		else
			if self.value and type(self.value.value) == "string" then
				str = str .. " - " .. quote_helper.QuoteToken(self.value.value)
			end
		end
	end

	return str .. "]"
end

function META:Render(config)
	local emitter

	do
		
		

		if _G.IMPORTS then
			emitter = IMPORTS["nattlua.transpiler.emitter"]()
		else
			

			emitter = require("nattlua.transpiler.emitter")
		end
	end

	local em = emitter.New(config or {preserve_whitespace = false, no_newlines = true})

	if self.type == "expression" then
		em:EmitExpression(self)
	elseif self.type == "statement" then
		em:EmitStatement(self)
	end

	return em:Concat()
end

function META:GetStartStop()
	return self.code_start, self.code_stop
end

function META:GetStatement()
	if self.type == "statement" then return self end

	if self.parent then return self.parent:GetStatement() end

	return self
end

function META:GetRoot()
	if self.parent then return self.parent:GetRoot() end

	return self
end

function META:GetRootExpression()
	if self.parent and self.parent.type == "expression" then
		return self.parent:GetRootExpression()
	end

	return self
end

function META:GetLength()
	local start, stop = self:GetStartStop()

	if self.first_node then
		local start2, stop2 = self.first_node:GetStartStop()

		if start2 < start then start = start2 end

		if stop2 > stop then stop = stop2 end
	end

	return stop - start
end

function META:GetNodes()
	local statements = self.statements

	if self.kind == "if" then
		local flat = {}

		for _, statements in ipairs(assert(statements)) do
			for _, v in ipairs(statements) do
				table.insert(flat, v)
			end
		end

		return flat
	end

	return statements or {}
end

function META:HasNodes()
	return self.statements ~= nil
end

function META:AddType(obj)
	self.inferred_types = self.inferred_types or {}
	table.insert(self.inferred_types, obj)
end

function META:GetTypes()
	return self.inferred_types or {}
end

function META:GetLastType()
	return self.inferred_types and self.inferred_types[#self.inferred_types]
end

local function find_by_type(
	node,
	what,
	out
)
	out = out or {}

	for _, child in ipairs(node:GetNodes()) do
		if child.kind == what then
			table.insert(out, child)
		elseif child:GetNodes() then
			find_by_type(child, what, out)
		end
	end

	return out
end

function META:FindNodesByType(what)
	return find_by_type(self, what, {})
end

return META end ]=======], '@./nattlua/parser/node.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.parser.base"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) 








local CreateNode = IMPORTS['nattlua.parser.node']("nattlua.parser.node").New
local ipairs = _G.ipairs
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local type = _G.type
local table = _G.table
local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
local quote_helper = IMPORTS['nattlua.other.quote']("nattlua.other.quote")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local META = class.CreateTemplate("parser")




function META.New(
	tokens,
	code,
	config
)
	return setmetatable(
		{
			config = config or {},
			Code = code,
			nodes = {},
			current_statement = false,
			current_expression = false,
			environment_stack = {},
			root = false,
			i = 1,
			tokens = tokens,
		},
		META
	)
end

do
	function META:GetCurrentParserEnvironment()
		return self.environment_stack[#self.environment_stack] or "runtime"
	end

	function META:PushParserEnvironment(env)
		table.insert(self.environment_stack, env)
	end

	function META:PopParserEnvironment()
		table.remove(self.environment_stack)
	end
end

function META:StartNode(
	node_type,
	kind,
	start_node
)
	
	local code_start = start_node and start_node.code_start or assert(self:GetToken()).start
	local node = CreateNode(
		{
			type = node_type,
			kind = kind,
			Code = self.Code,
			code_start = code_start,
			code_stop = code_start,
			environment = self:GetCurrentParserEnvironment(),
			parent = self.nodes[#self.nodes],
		}
	)

	if node_type == "expression" then
		self.current_expression = node
	else
		self.current_statement = node
	end

	if self.OnNode then self:OnNode(node) end

	table.insert(self.nodes, node)
	return node
end

function META:EndNode(node)
	local prev = self:GetToken(-1)

	if prev then
		node.code_stop = prev.stop
	else
		local cur = self:GetToken()

		if cur then node.code_stop = cur.stop end
	end

	table.remove(self.nodes)

	if self.config.on_node then
		if
			self.suppress_on_node and
			node.type == "expression" and
			self.suppress_on_node.parent == self.nodes[#self.nodes]
		then
			table.insert(self.suppress_on_node.nodes, node)
		elseif self.config.on_node then
			local new_node = self.config.on_node(self, node)

			if new_node then
				node = new_node
				node.parent = self.nodes[#self.nodes]
			end
		end
	end

	return node
end

function META:SuppressOnNode()
	self.suppress_on_node = {parent = self.nodes[#self.nodes], nodes = {}}
end

function META:ReRunOnNode(nodes)
	if not self.suppress_on_node then return end

	for _, node_a in ipairs(self.suppress_on_node.nodes) do
		for i, node_b in ipairs(nodes) do
			if node_a == node_b and self.config.on_node then
				local new_node = self.config.on_node(self, node_a)

				if new_node then
					nodes[i] = new_node
					new_node.parent = self.nodes[#self.nodes]
				end
			end
		end
	end

	self.suppress_on_node = nil
end

function META:Error(
	msg,
	start_token,
	stop_token,
	...
)
	local tk = self:GetToken()
	local start = 0
	local stop = 0

	if start_token then
		start = start_token.start
	elseif tk then
		start = tk.start
	end

	if stop_token then stop = stop_token.stop elseif tk then stop = tk.stop end

	self:OnError(self.Code, msg, start, stop, ...)
end

function META:OnError(
	code,
	message,
	start,
	stop,
	...
) end

function META:GetToken(offset)
	return self.tokens[self.i + (offset or 0)]
end

function META:GetLength()
	return #self.tokens
end

function META:Advance(offset)
	self.i = self.i + offset
end

function META:IsValue(str, offset)
	local tk = self:GetToken(offset)

	if tk then return tk.value == str end
end

function META:IsType(token_type, offset)
	local tk = self:GetToken(offset)

	if tk then return tk.type == token_type end
end

function META:ParseToken()
	local tk = self:GetToken()

	if not tk then return nil end

	self:Advance(1)
	tk.parent = self.nodes[#self.nodes]
	return tk
end

function META:RemoveToken(i)
	local t = self.tokens[i]
	table.remove(self.tokens, i)
	return t
end

function META:AddTokens(tokens)
	local eof = table.remove(self.tokens)

	for i, token in ipairs(tokens) do
		if token.type == "end_of_file" then break end

		table.insert(self.tokens, self.i + i - 1, token)
	end

	table.insert(self.tokens, eof)
end

do
	local function error_expect(
		self,
		str,
		what,
		start,
		stop
	)
		local tk = self:GetToken()

		if not tk then
			self:Error("expected $1 $2: reached end of code", start, stop, what, str)
		else
			self:Error("expected $1 $2: got $3", start, stop, what, str, tk[what])
		end
	end

	function META:ExpectValue(str, error_start, error_stop)
		if not self:IsValue(str) then
			error_expect(self, str, "value", error_start, error_stop)
		end

		return self:ParseToken()
	end

	function META:ExpectValueTranslate(
		str,
		new_str,
		error_start,
		error_stop
	)
		if not self:IsValue(str) then
			error_expect(self, str, "value", error_start, error_stop)
		end

		local tk = self:ParseToken()
		tk.value = new_str
		return tk
	end

	function META:ExpectType(
		str,
		error_start,
		error_stop
	)
		if not self:IsType(str) then
			error_expect(self, str, "type", error_start, error_stop)
		end

		return self:ParseToken()
	end

	function META:NewToken(type, value)
		local tk = {}
		tk.type = type
		tk.is_whitespace = false
		tk.value = value
		return tk
	end
end

function META:ParseValues(
	values,
	start,
	stop
)
	local tk = self:GetToken()

	if not tk then
		self:Error("expected $1: reached end of code", start, stop, values)
		return
	end

	if not values[tk.value] then
		local array = {}

		for k in pairs(values) do
			table.insert(array, k)
		end

		self:Error("expected $1 got $2", start, stop, array, tk.type)
	end

	return self:ParseToken()
end

function META:ParseStatements(stop_token)
	local out = {}
	local i = 1

	for _ = 1, self:GetLength() do
		local tk = self:GetToken()

		if not tk then break end

		if stop_token and stop_token[tk.value] then break end

		local node = (self):ParseStatement()

		if not node then break end

		if node[1] then
			for _, v in ipairs(node) do
				out[i] = v
				i = i + 1
			end
		else
			out[i] = node
			i = i + 1
		end
	end

	return out
end

function META:ResolvePath(path)
	return path
end

function META:ParseMultipleValues(
	max,
	reader,
	a,
	b,
	c
)
	local out = {}

	for i = 1, max or self:GetLength() do
		local node = reader(self, a, b, c)

		if not node then break end

		out[i] = node

		if not self:IsValue(",") then break end

		(node.tokens)[","] = self:ExpectValue(",")
	end

	return out
end

return META end ]=======], '@./nattlua/parser/base.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.profiler2"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local logf = function(f, ...)
	io.write((f):format(...))
end
local wlog = print
local logn = print
local log = io.write
local ok, jit_profiler = pcall(require, "jit.profile")

if not ok then jit_profiler = nil end

local get_time = os.clock

local function read_file(path)
	local f, err = io.open(path)

	if not f then return nil, err end

	local s, err = f:read("*a")

	if not s then return nil, "empty file" end

	return s
end

local function math_round(num, idp)
	if idp and idp > 0 then
		local mult = 10 ^ idp
		return math.floor(num * mult + 0.5) / mult
	end

	return math.floor(num + 0.5)
end

local ok, jit_vmdef = pcall(require, "jit.vmdef")

if not ok then jit_vmdef = nil end

local ok, jit_util = pcall(require, "jit.util")

if not ok then jit_util = nil end

local utility = {}

function utility.TableToColumns(title, tbl, columns, check, sort_key)
	local top = {}

	for k, v in pairs(tbl) do
		if not check or check(v) then table.insert(top, {key = k, val = v}) end
	end

	if type(sort_key) == "function" then
		table.sort(top, function(a, b)
			return sort_key(a.val, b.val)
		end)
	else
		table.sort(top, function(a, b)
			return a.val[sort_key] > b.val[sort_key]
		end)
	end

	local max_lengths = {}
	local temp = {}

	for _, column in ipairs(top) do
		for key, data in ipairs(columns) do
			data.tostring = data.tostring or function(...)
				return ...
			end
			data.friendly = data.friendly or data.key
			max_lengths[data.key] = max_lengths[data.key] or 0
			local str = tostring(data.tostring(column.val[data.key], column.val, top))
			column.str = column.str or {}
			column.str[data.key] = str

			if #str > max_lengths[data.key] then max_lengths[data.key] = #str end

			temp[key] = data
		end
	end

	columns = temp
	local width = 0

	for _, v in pairs(columns) do
		if max_lengths[v.key] > #v.friendly then
			v.length = max_lengths[v.key]
		else
			v.length = #v.friendly + 1
		end

		width = width + #v.friendly + max_lengths[v.key] - 2
	end

	local out = " "
	out = out .. ("_"):rep(width - 1) .. "\n"
	out = out .. "|" .. (
			" "
		):rep(width / 2 - math.floor(#title / 2)) .. title .. (
			" "
		):rep(math.floor(width / 2) - #title + math.floor(#title / 2)) .. "|\n"
	out = out .. "|" .. ("_"):rep(width - 1) .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "| " .. v.friendly .. ": " .. (
				" "
			):rep(-#v.friendly + max_lengths[v.key] - 1) -- 2 = : + |
	end

	out = out .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "|" .. ("_"):rep(v.length + 2)
	end

	out = out .. "|\n"

	for _, v in ipairs(top) do
		for _, column in ipairs(columns) do
			out = out .. "| " .. v.str[column.key] .. (
					" "
				):rep(-#v.str[column.key] + column.length + 1)
		end

		out = out .. "|\n"
	end

	out = out .. "|"
	out = out .. ("_"):rep(width - 1) .. "|\n"
	return out
end

local function split(self, separator)
	local tbl = {}
	local current_pos = 1

	for i = 1, #self do
		local start_pos, end_pos = self:find(separator, current_pos, true)

		if not start_pos or not end_pos then break end

		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 then
		tbl[#tbl + 1] = self:sub(current_pos)
	else
		tbl[1] = self
	end

	return tbl
end

local function trim(self)
	local char = "%s*"
	local _, start = self:find(char, 0)
	local end_start, end_stop = self:reverse():find(char, 0)

	if start and end_start and end_stop then
		return self:sub(start + 1, (end_start - end_stop) - 2)
	elseif start then
		return self:sub(start + 1)
	elseif end_start and end_stop then
		return self:sub(0, (end_start - end_stop) - 2)
	end

	return self
end

local profiler = {}
profiler.data = {sections = {}, statistical = {}, trace_aborts = {}}
profiler.raw_data = {sections = {}, statistical = {}, trace_aborts = {}}
local blacklist = {
	["leaving loop in root trace"] = true,
	["error thrown or hook fed during recording"] = true,
	["too many spill slots"] = true,
}

local function trace_dump_callback(what, trace_id, func, pc, trace_error_id, trace_error_arg)
	if what == "abort" then
		local info = jit_util.funcinfo(func, pc)
		table.insert(profiler.raw_data.trace_aborts, {info, trace_error_id, trace_error_arg})
	end
end

local function parse_raw_trace_abort_data()
	local data = profiler.data.trace_aborts

	for _ = 1, #profiler.raw_data.trace_aborts do
		local args = table.remove(profiler.raw_data.trace_aborts)
		local info = args[1]
		local trace_error_id = args[2]
		local trace_error_arg = args[3]
		local reason = jit_vmdef.traceerr[trace_error_id]

		if not blacklist[reason] then
			if type(trace_error_arg) == "number" and reason:find("bytecode") then
				trace_error_arg = string.sub(jit_vmdef.bcnames, trace_error_arg * 6 + 1, trace_error_arg * 6 + 6)
				reason = reason:gsub("(%%d)", "%%s")
			end

			reason = reason:format(trace_error_arg)
			local path = info.source
			local line = info.currentline or info.linedefined
			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {}
			data[path][line][reason] = (data[path][line][reason] or 0) + 1
		end
	end
end

function profiler.EnableTraceAbortLogging(b--[[boolean]] )
	if b then
		jit.attach(
			function(...)
				local ok, err = xpcall(trace_dump_callback, error, ...)

				if not ok then
					logn(err)
					profiler.EnableTraceAbortLogging(false)
				end
			end,
			"trace"
		)
	else
		jit.attach(trace_dump_callback)
	end
end

local function parse_raw_statistical_data()
	local data = profiler.data.statistical

	for _ = 1, #profiler.raw_data.statistical do
		local args = table.remove(profiler.raw_data.statistical)
		local str, samples, vmstate = args[1], args[2], args[3]
		local children = {}

		for line in str:gmatch("(.-)\n") do
			local path, line_number = line:match("(.+):(%d+)")

			if not path and not line_number then
				line = line:gsub("%[builtin#(%d+)%]", function(x)
					return jit_vmdef.ffnames[tonumber(x)]
				end)
				table.insert(children, {name = line or -1, external_function = true})
			else
				table.insert(
					children,
					{path = path, line = tonumber(line_number) or -1, external_function = false}
				)
			end
		end

		local info = children[#children]
		table.remove(children, #children)
		local path = info.path or info.name
		local line = tonumber(info.line) or -1
		data[path] = data[path] or {}
		data[path][line] = data[path][line] or
			{
				total_time = 0,
				samples = 0,
				children = {},
				parents = {},
				ready = false,
				func_name = path,
				vmstate = vmstate,
			}
		data[path][line].samples = data[path][line].samples + samples
		data[path][line].start_time = data[path][line].start_time or get_time()
		local parent = data[path][line]

		for _, info in ipairs(children) do
			local path = info.path or info.name
			local line = tonumber(info.line) or -1
			data[path] = data[path] or {}
			data[path][line] = data[path][line] or
				{
					total_time = 0,
					samples = 0,
					children = {},
					parents = {},
					ready = false,
					func_name = path,
					vmstate = vmstate,
				}
			data[path][line].samples = data[path][line].samples + samples
			data[path][line].start_time = data[path][line].start_time or get_time()
			data[path][line].parents[tostring(parent)] = parent
			parent.children[tostring(data[path][line])] = data[path][line]
		--table.insert(data[path][line].parents, parent)
		--table.insert(parent.children, data[path][line])
		end
	end
end

local function statistical_callback(thread, samples, vmstate)
	local str = jit_profiler.dumpstack(thread, "pl\n", 1000)
	table.insert(profiler.raw_data.statistical, {str, samples, vmstate})
end

function profiler.EnableStatisticalProfiling(b)
	if not jit_profiler then
		wlog("jit profiler is not available")
		return
	end

	profiler.busy = b

	if b then
		jit_profiler.start("li0", function(...)
			local ok, err = pcall(statistical_callback, ...)

			if not ok then
				logn(err)
				profiler.EnableStatisticalProfiling(false)
			end
		end)
	else
		jit_profiler.stop()
	end
end

do
	local started = false

	function profiler.ToggleStatistical()
		if not started then
			profiler.EnableStatisticalProfiling(true)
			started = true
		else
			profiler.EnableStatisticalProfiling(false)
			profiler.PrintStatistical(0)
			started = false
			profiler.Restart()
		end
	end
end

function profiler.EasyStart()
	profiler.EnableStatisticalProfiling(true)
	profiler.EnableTraceAbortLogging(true)
end

function profiler.EasyStop()
	profiler.EnableTraceAbortLogging(false)
	profiler.EnableStatisticalProfiling(false)
	profiler.PrintTraceAborts(500)
	profiler.PrintStatistical(500)
	started = false
	profiler.Restart()
end

function profiler.Restart()
	profiler.data = {sections = {}, statistical = {}, trace_aborts = {}}
	profiler.raw_data = {sections = {}, statistical = {}, trace_aborts = {}}
end

do
	local stack = {}
	local enabled = false
	local i = 0

	function profiler.PushSection(section_name)
		if not enabled then return end

		local info = debug.getinfo(3)
		local start_time = get_time()
		table.insert(
			stack,
			{
				section_name = section_name,
				start_time = start_time,
				info = info,
				level = #stack,
			}
		)
	end

	function profiler.PopSection()
		if not enabled then return end

		local res = table.remove(stack)

		if res then
			local time = get_time() - res.start_time
			local path, line = res.info.source, res.info.currentline

			if type(res.section_name) == "string" then line = res.section_name end

			local data = profiler.data.sections
			data[path] = data[path] or {}
			data[path][line] = data[path][line] or
				{
					total_time = 0,
					samples = 0,
					name = res.section_name,
					section_name = res.section_name,
					instrumental = true,
					section = true,
				}
			data[path][line].total_time = data[path][line].total_time + time
			data[path][line].samples = data[path][line].samples + 1
			data[path][line].level = res.level
			data[path][line].start_time = res.start_time
			data[path][line].i = i
			i = i + 1
			return time
		end
	end

	function profiler.RemoveSection(name)
		profiler.data.sections[name] = nil
	end

	function profiler.EnableSectionProfiling(b, reset)
		enabled = b

		if reset then profiler.data.sections = {} end

		stack = {}
	end

	profiler.PushSection()
	profiler.PopSection()
end

do -- timer
	local stack = {}

	function profiler.StartTimer(str, ...)
		table.insert(stack, {str = str and str:format(...), level = #stack})
		local last = stack[#stack]
		last.time = get_time() -- just to make sure there's overhead with table.insert and whatnot
	end

	function profiler.StopTimer(no_print)
		local time = get_time()
		local data = table.remove(stack)
		local delta = time - data.time

		if not no_print then
			logf("%s%s: %1.22f\n", (" "):rep(data.level - 1), data.str, math_round(delta, 5))
		end

		return delta
	end

	function profiler.ToggleTimer(val)
		if started then
			started = false
			return profiler.StopTimer(val == true)
		else
			started = true
			return profiler.StartTimer(val)
		end
	end
end

function profiler.GetBenchmark(type, file, dump_line)
	local benchmark_time

	if profiler.start_time and profiler.stop_time then
		benchmark_time = profiler.stop_time - profiler.start_time
	end

	if type == "statistical" then parse_raw_statistical_data() end

	local out = {}

	for path, lines in pairs(profiler.data[type]) do
		if path:sub(1, 1) == "@" then path = path:sub(2) end

		if not file or path:find(file) then
			for line, data in pairs(lines) do
				line = tonumber(line) or line
				local name = "unknown(file not found)"
				local debug_info

				if data.func then
					debug_info = debug.getinfo(data.func)
					-- remove some useless fields
					debug_info.source = nil
					debug_info.short_src = nil
					debug_info.currentline = nil
					debug_info.func = nil
				end

				if dump_line then
					local content = read_file(path)

					if content then
						name = split(content, "\n")[line]

						if name then
							name = name:gsub("function ", "")
							name = trim(name)
						end
					end
				elseif data.func then
					name = ("%s(%s)"):format(data.func_name, table.concat(debug.getparams(data.func), ", "))
				else
					local full_path = path
					name = full_path .. ":" .. line
				end

				if data.section_name then
					data.section_name = data.section_name:match(".+lua/(.+)") or data.section_name
				end

				if name:find("\n", 1, true) then
					name = name:gsub("\n", "")
					name = name:sub(0, 50)
				end

				name = trim(name)
				data.path = path
				data.file_name = path:match(".+/(.+)%.") or path
				data.line = line
				data.name = name
				data.debug_info = debug_info
				data.ready = true

				if data.total_time then
					data.average_time = data.total_time / data.samples
				--data.total_time = data.average_time * data.samples
				end

				if benchmark_time then
					data.fraction_time = data.total_time / benchmark_time
				end

				data.start_time = data.start_time or 0
				data.samples = data.samples or 0
				data.sample_duration = get_time() - data.start_time
				data.times_called = data.samples
				table.insert(out, data)
			end
		end
	end

	return out
end

function profiler.PrintTraceAborts(min_samples)
	min_samples = min_samples or 500
	parse_raw_statistical_data()
	parse_raw_trace_abort_data()
	logn(
		"trace abort reasons for functions that were sampled by the profiler more than ",
		min_samples,
		" times:"
	)
	local blacklist = {
		["NYI: return to lower frame"] = true,
		["inner loop in root trace"] = true,
		["blacklisted"] = true,
	}

	for path, lines in pairs(profiler.data.trace_aborts) do
		path = path:sub(2)
		local s = profiler.data.statistical

		if s[path] or not next(s) then
			local full_path = path
			local temp = {}

			for line, reasons in pairs(lines) do
				if not next(s) or s[path][line] and s[path][line].samples > min_samples then
					local str = "unknown line"
					local content, err = read_file(path)

					if content then
						local lines = split(content, "\n")
						str = lines[line]
						str = "\"" .. trim(str) .. "\""
					else
						str = err
					end

					for reason, count in pairs(reasons) do
						if not blacklist[reason] then
							table.insert(temp, "\t\t" .. trim(reason) .. " (x" .. count .. ")")
							table.insert(temp, "\t\t\t" .. line .. ": " .. str)
						end
					end
				end
			end

			if #temp > 0 then
				logn("\t", full_path)
				logn(table.concat(temp, "\n"))
			end
		end
	end
end

function profiler.PrintSections()
	log(
		utility.TableToColumns(
			"sections",
			profiler.GetBenchmark("sections"),
			{
				{key = "times_called", friendly = "calls"},
				{
					key = "name",
					tostring = function(val, column)
						return ("    "):rep(column.level - 1) .. tostring(val)
					end,
				},
				{
					key = "average_time",
					friendly = "time",
					tostring = function(val)
						return math_round(val * 100 * 100, 3)
					end,
				},
			},
			function(a)
				return a.times_called > 50
			end,
			"i"
		)
	)
end

function profiler.PrintStatistical(min_samples)
	min_samples = min_samples or 100
	local tr = {
		N = "native",
		I = "interpreted",
		G = "garbage collector",
		J = "JIT compiler",
		C = "C",
	}
	log(
		utility.TableToColumns(
			"statistical",
			profiler.GetBenchmark("statistical"),
			{
				{key = "name"},
				{
					key = "times_called",
					friendly = "percent",
					tostring = function(val, column, columns)
						return math_round((val / columns[#columns].val.times_called) * 100, 2)
					end,
				},
				{
					key = "vmstate",
					tostring = function(str)
						return tr[str]
					end,
				},
				{
					key = "samples",
					tostring = function(val)
						return val
					end,
				},
			},
			function(a)
				return a.name and a.times_called > min_samples
			end,
			function(a, b)
				return a.times_called < b.times_called
			end
		)
	)
end

function profiler.StartInstrumental(file_filter, method)
	method = method or "cr"
	profiler.EnableSectionProfiling(true, true)
	profiler.busy = true
	local last_info

	debug.sethook(
		function(what, line)
			local info = debug.getinfo(2)

			if not file_filter or not info.source:find(file_filter, nil, true) then
				if what == "call" then
					if last_info and last_info.what == "C" then profiler.PopSection() end

					local name

					if info.what == "C" then
						name = info.name

						if not name then name = "" end

						local info = debug.getinfo(3)
						name = name .. " " .. info.source .. ":" .. info.currentline
					end

					profiler.PushSection(name)
				elseif what == "return" then
					profiler.PopSection()
				end
			end

			last_info = info
		end,
		method
	)

	profiler.start_time = get_time()
end

function profiler.StopInstrumental(file_filter, show_everything)
	profiler.EnableSectionProfiling(false)
	profiler.stop_time = get_time()
	profiler.busy = false
	debug.sethook()
	profiler.PopSection()
	log(
		utility.TableToColumns(
			"instrumental",
			profiler.GetBenchmark("sections"),
			{
				{key = "times_called", friendly = "calls"},
				{key = "name"},
				{
					key = "average_time",
					friendly = "time",
					tostring = function(val)
						return ("%f"):format(val)
					end,
				},
				{
					key = "total_time",
					friendly = "total time",
					tostring = function(val)
						return ("%f"):format(val)
					end,
				},
				{
					key = "fraction_time",
					friendly = "percent",
					tostring = function(val)
						return math_round(val * 100, 2)
					end,
				},
			},
			function(a)
				return show_everything or a.average_time > 0.5 or (file_filter or a.times_called > 100)
			end,
			function(a, b)
				return a.total_time < b.total_time
			end
		)
	)
end

do
	local started = false

	function profiler.ToggleInstrumental(file_filter, method)
		if file_filter == "" then file_filter = nil end

		if not started then
			profiler.StartInstrumental(file_filter, method)
			started = true
		else
			profiler.StopInstrumental(file_filter, true)
			started = false
		end
	end
end

function profiler.MeasureInstrumental(time, file_filter, show_everything)
	profiler.StartInstrumental(file_filter)

	event.Delay(time, function()
		profiler.StopInstrumental(file_filter, show_everything)
	end)
end

function profiler.DumpZerobraneProfileTree(min, filter)
	min = min or 1
	local huh = serializer.ReadFile("msgpack", "zerobrane_statistical.msgpack")
	local most_samples
	local path, root

	for k, v in pairs(huh) do
		most_samples = most_samples or v

		if v.samples >= most_samples.samples then
			most_samples = v
			path = k
			root = v
		end
	end

	local level = 0

	local function dump(path, node)
		local percent = math_round((node.samples / root.samples) * 100, 3)

		if percent > min then
			if not filter or path:find(filter) then
				logf("%s%s (%s) %s\n", ("\t"):rep(level), percent, node.samples, path)
			else
				logf("%s%s\n", ("\t"):rep(level), "...")
			end

			for path, child in pairs(node.children) do
				level = level + 1
				dump(path, child)
				level = level - 1
			end
		end
	end

	dump(path, root)
end

function profiler.IsBusy()
	return profiler.busy
end

local blacklist = {
	["NYI: return to lower frame"] = true,
	["inner loop in root trace"] = true,
	["leaving loop in root trace"] = true,
	["blacklisted"] = true,
	["too many spill slots"] = true,
	["down-recursion, restarting"] = true,
}

function profiler.EnableRealTimeTraceAbortLogging(b)
	if not jit.attach then
		wlog("jit profiler is not available")
		return
	end

	if b then
		local last_log

		jit.attach(
			function(what, trace_id, func, pc, trace_error_id, trace_error_arg)
				if what == "abort" then
					local info = jit_util.funcinfo(func, pc)
					local reason = jit_vmdef.traceerr[trace_error_id]

					if not blacklist[reason] then
						if type(trace_error_arg) == "number" and reason:find("bytecode") then
							trace_error_arg = string.sub(jit_vmdef.bcnames, trace_error_arg * 6 + 1, trace_error_arg * 6 + 6)
							reason = reason:gsub("(%%d)", "%%s")
						end

						reason = reason:format(trace_error_arg)
						local path = info.source
						local line = info.currentline or info.linedefined
						local content = read_file(path:sub(2)) or read_file(path:sub(2))
						local str

						if content then
							str = string.format(
								"%s:%s\n%s:--\t%s\n\n",
								path:sub(2),
								line,
								trim(split(content, "\n")[line]),
								reason
							)
						else
							str = string.format("%s:%s:\n\t%s\n\n", path, line, reason)
						end

						if str ~= last_log then
							log(str)
							last_log = str
						end
					end
				end
			end,
			"trace"
		)
	else
		jit.attach(function() end)
	end
end

local system_GetTime = get_time

function profiler.MeasureFunction(func, count, name, no_print)
	count = count or 1
	name = name or "measure result"
	local total_time = 0

	for _ = 1, count do
		local time = system_GetTime()
		jit.tracebarrier()
		func()
		jit.tracebarrier()
		total_time = total_time + system_GetTime() - time
	end

	if not no_print then
		logf("%s: average: %1.22f total: %f\n", name, total_time / count, total_time)
	end

	return total_time, func
end

function profiler.MeasureFunctions(tbl, count)
	local res = {}

	for name, func in pairs(tbl) do
		table.insert(res, {time = profiler.MeasureFunction(func, count, name, true), name = name})
	end

	table.sort(res, function(a, b)
		return a.time < b.time
	end)

	for i, v in ipairs(res) do
		logf("%s: average: %1.22f total: %f\n", v.name, v.time / count, v.time)
	end
end

function profiler.Compare(old, new, count)
	profiler.MeasureFunction(old, count, "OLD")
	profiler.MeasureFunction(new, count, "NEW")
end

profiler.Restart()
return profiler end ]=======], '@./nattlua/other/profiler2.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.profiler"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local profiler2 = IMPORTS['nattlua.other.profiler2']("nattlua.other.profiler2")
local profiler = {}
local should_run = true

if _G.ON_EDITOR_SAVE or not jit then should_run = false end

function profiler.Start()
	if not should_run then return end

	profiler2.EasyStart()
end

function profiler.Stop()
	if not should_run then return end

	profiler2.EasyStop()
end

function profiler.PushZone(name)
	if not should_run then return end

	profiler2.PushSection(name)
end

function profiler.PopZone()
	if not should_run then return end

	profiler2.PopSection()
end

return profiler end ]=======], '@./nattlua/other/profiler.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.syntax.typesystem"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Syntax = IMPORTS['nattlua.syntax']("nattlua.syntax").New
local typesystem = Syntax()
typesystem:AddSymbolCharacters(
	{
		",",
		";",
		"=",
		"::",
		{"(", ")"},
		{"{", "}"},
		{"[", "]"},
		{"\"", "\""},
		{"'", "'"},
		{"<|", "|>"},
	}
)
typesystem:AddNumberAnnotations({"ull", "ll", "ul", "i"})
typesystem:AddKeywords(
	{
		"do",
		"end",
		"if",
		"then",
		"else",
		"elseif",
		"for",
		"in",
		"while",
		"repeat",
		"until",
		"break",
		"return",
		"local",
		"function",
		"and",
		"not",
		"or",
		-- these are just to make sure all code is covered by tests
		"ÆØÅ",
		"ÆØÅÆ",
	}
)
-- these are keywords, but can be used as names
typesystem:AddNonStandardKeywords({
	"continue",
	"import",
	"literal",
	"ref",
	"analyzer",
	"mutable",
	"type",
})
typesystem:AddKeywordValues({
	"...",
	"nil",
	"true",
	"false",
})
typesystem:AddPrefixOperators({
	"-",
	"#",
	"not",
	"!",
	"~",
	"supertype",
})
typesystem:AddPostfixOperators(
	{ -- these are just to make sure all code is covered by tests
		"++",
		"ÆØÅ",
		"ÆØÅÆ",
	}
)
typesystem:AddBinaryOperators(
	{
		{"or", "||"},
		{"and", "&&"},
		{"<", ">", "<=", ">=", "~=", "==", "!="},
		{"|"},
		{"~"},
		{"&"},
		{"<<", ">>"},
		{"R.."}, -- right associative
		{"+", "-"},
		{"*", "/", "/idiv/", "%"},
		{"R^"}, -- right associative
	}
)
typesystem:AddPrimaryBinaryOperators({
	".",
	":",
})
typesystem:AddBinaryOperatorFunctionTranslate(
	{
		[">>"] = "bit.rshift(A, B)",
		["<<"] = "bit.lshift(A, B)",
		["|"] = "bit.bor(A, B)",
		["&"] = "bit.band(A, B)",
		["//"] = "math.floor(A / B)",
		["~"] = "bit.bxor(A, B)",
	}
)
typesystem:AddPrefixOperatorFunctionTranslate({
	["~"] = "bit.bnot(A)",
})
typesystem:AddPostfixOperatorFunctionTranslate({
	["++"] = "(A+1)",
	["ÆØÅ"] = "(A)",
	["ÆØÅÆ"] = "(A)",
})
typesystem:AddPrefixOperators(
	{
		"-",
		"#",
		"not",
		"~",
		"typeof",
		"$",
		"unique",
		"mutable",
		"ref",
		"literal",
		"supertype",
		"expand",
	}
)
typesystem:AddPrimaryBinaryOperators({"."})
typesystem:AddBinaryOperators(
	{
		{"or"},
		{"and"},
		{"extends"},
		{"subsetof"},
		{"supersetof"},
		{"<", ">", "<=", ">=", "~=", "=="},
		{"|"},
		{"~"},
		{"&"},
		{"<<", ">>"},
		{"R.."}, -- right associative
		{"+", "-"},
		{"*", "/", "/idiv/", "%"},
		{"R^"}, -- right associative
	}
)
return typesystem end ]=======], '@./nattlua/syntax/typesystem.lua'))())(...) return __M end end
IMPORTS['nattlua/parser/expressions.lua'] = assert(loadstring([=======[ return function(...) local META = ...
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local math_huge = math.huge
local runtime_syntax = IMPORTS['nattlua.syntax.runtime']("nattlua.syntax.runtime")
local typesystem_syntax = IMPORTS['nattlua.syntax.typesystem']("nattlua.syntax.typesystem")
local profiler = IMPORTS['nattlua.other.profiler']("nattlua.other.profiler")



function META:ParseAnalyzerFunctionExpression()
	if not (self:IsValue("analyzer") and self:IsValue("function", 1)) then return end

	local node = self:StartNode("expression", "analyzer_function")
	node.tokens["analyzer"] = self:ExpectValue("analyzer")
	node.tokens["function"] = self:ExpectValue("function")
	self:ParseAnalyzerFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseFunctionExpression()
	if not self:IsValue("function") then return end

	local node = self:StartNode("expression", "function")
	node.tokens["function"] = self:ExpectValue("function")
	self:ParseFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseIndexSubExpression(left_node)
	if not (self:IsValue(".") and self:IsType("letter", 1)) then return end

	local node = self:StartNode("expression", "binary_operator")
	node.value = self:ParseToken()
	node.right = self:ParseValueExpressionType("letter")
	node.left = left_node
	node = self:EndNode(node)
	return node
end

function META:IsCallExpression(offset)
	return self:IsValue("(", offset) or
		self:IsValue("<|", offset) or
		self:IsValue("{", offset) or
		self:IsType("string", offset) or
		(
			self:IsValue("!", offset) and
			self:IsValue("(", offset + 1)
		)
end

function META:ParseSelfCallSubExpression(left_node)
	if not (self:IsValue(":") and self:IsType("letter", 1) and self:IsCallExpression(2)) then
		return
	end

	local node = self:StartNode("expression", "binary_operator", left_node)
	node.value = self:ParseToken()
	node.right = self:ParseValueExpressionType("letter")
	node.left = left_node
	node = self:EndNode(node)
	return node
end

do -- typesystem
	function META:ParseParenthesisOrTupleTypeExpression()
		if not self:IsValue("(") then return end

		local pleft = self:ExpectValue("(")
		local node = self:ParseTypeExpression(0)

		if not node or self:IsValue(",") then
			local first_expression = node
			local node = self:StartNode("expression", "tuple", first_expression)

			if self:IsValue(",") then
				first_expression.tokens[","] = self:ExpectValue(",")
				node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			else
				node.expressions = {}
			end

			if first_expression then
				table.insert(node.expressions, 1, first_expression)
			end

			node.tokens["("] = pleft
			node.tokens[")"] = self:ExpectValue(")", pleft)
			node = self:EndNode(node)
			return node
		end

		node.tokens["("] = node.tokens["("] or {}
		table_insert(node.tokens["("], pleft)
		node.tokens[")"] = node.tokens[")"] or {}
		table_insert(node.tokens[")"], self:ExpectValue(")"))
		return node
	end

	function META:ParsePrefixOperatorTypeExpression()
		if not typesystem_syntax:IsPrefixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "prefix_operator")
		node.value = self:ParseToken()
		node.tokens[1] = node.value

		if node.value.value == "expand" then
			self:PushParserEnvironment("runtime")
		end

		node.right = self:ParseRuntimeExpression(math_huge)

		if node.value.value == "expand" then self:PopParserEnvironment() end

		node = self:EndNode(node)
		return node
	end

	function META:ParseValueTypeExpression()
		if not (self:IsValue("...") and self:IsType("letter", 1)) then return end

		local node = self:StartNode("expression", "vararg")
		node.tokens["..."] = self:ExpectValue("...")
		node.value = self:ParseTypeExpression(0)
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeSignatureFunctionArgument(expect_type)
		if self:IsValue(")") then return end

		if
			expect_type or
			(
				(
					self:IsType("letter") or
					self:IsValue("...")
				) and
				self:IsValue(":", 1)
			)
		then
			local identifier = self:ParseToken()
			local token = self:ExpectValue(":")
			local exp = self:ExpectTypeExpression(0)
			exp.tokens[":"] = token
			exp.identifier = identifier
			return exp
		end

		return self:ExpectTypeExpression(0)
	end

	function META:ParseFunctionSignatureExpression()
		if not (self:IsValue("function") and self:IsValue("=", 1)) then return end

		local node = self:StartNode("expression", "function_signature")
		node.tokens["function"] = self:ExpectValue("function")
		node.tokens["="] = self:ExpectValue("=")
		node.tokens["arguments("] = self:ExpectValue("(")
		node.identifiers = self:ParseMultipleValues(nil, self.ParseTypeSignatureFunctionArgument)
		node.tokens["arguments)"] = self:ExpectValue(")")
		node.tokens[">"] = self:ExpectValue(">")
		node.tokens["return("] = self:ExpectValue("(")
		node.return_types = self:ParseMultipleValues(nil, self.ParseTypeSignatureFunctionArgument)
		node.tokens["return)"] = self:ExpectValue(")")
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeFunctionExpression()
		if not (self:IsValue("function") and self:IsValue("<|", 1)) then return end

		local node = self:StartNode("expression", "type_function")
		node.tokens["function"] = self:ExpectValue("function")
		self:ParseTypeFunctionBody(node)
		node = self:EndNode(node)
		return node
	end

	function META:ParseKeywordValueTypeExpression()
		if not typesystem_syntax:IsValue(self:GetToken()) then return end

		local node = self:StartNode("expression", "value")
		node.value = self:ParseToken()
		node = self:EndNode(node)
		return node
	end

	do
		function META:read_type_table_entry(i)
			if self:IsValue("[") then
				local node = self:StartNode("sub_statement", "table_expression_value")
				node.tokens["["] = self:ExpectValue("[")
				node.key_expression = self:ParseTypeExpression(0)
				node.tokens["]"] = self:ExpectValue("]")
				node.tokens["="] = self:ExpectValue("=")
				node.value_expression = self:ParseTypeExpression(0)
				node = self:EndNode(node)
				return node
			elseif self:IsType("letter") and self:IsValue("=", 1) then
				local node = self:StartNode("sub_statement", "table_key_value")
				node.tokens["identifier"] = self:ExpectType("letter")
				node.tokens["="] = self:ExpectValue("=")
				node.value_expression = self:ParseTypeExpression(0)
				node = self:EndNode(node)
				return node
			end

			local node = self:StartNode("sub_statement", "table_index_value")
			local spread = self:read_table_spread()

			if spread then
				node.spread = spread
			else
				node.key = i
				node.value_expression = self:ParseTypeExpression(0)
			end

			node = self:EndNode(node)
			return node
		end

		function META:ParseTableTypeExpression()
			if not self:IsValue("{") then return end

			local tree = self:StartNode("expression", "type_table")
			tree.tokens["{"] = self:ExpectValue("{")
			tree.children = {}
			tree.tokens["separators"] = {}

			for i = 1, math_huge do
				if self:IsValue("}") then break end

				local entry = self:read_type_table_entry(i)

				if entry.spread then tree.spread = true end

				tree.children[i] = entry

				if not self:IsValue(",") and not self:IsValue(";") and not self:IsValue("}") then
					self:Error(
						"expected $1 got $2",
						nil,
						nil,
						{",", ";", "}"},
						(self:GetToken() and self:GetToken().value) or "no token"
					)

					break
				end

				if not self:IsValue("}") then
					tree.tokens["separators"][i] = self:ParseToken()
				end
			end

			tree.tokens["}"] = self:ExpectValue("}")
			tree = self:EndNode(tree)
			return tree
		end
	end

	function META:ParseStringTypeExpression()
		if not (self:IsType("$") and self:IsType("string", 1)) then return end

		local node = self:StartNode("expression", "type_string")
		node.tokens["$"] = self:ParseToken("...")
		node.value = self:ExpectType("string")
		return node
	end

	function META:ParseEmptyUnionTypeExpression()
		if not self:IsValue("|") then return end

		local node = self:StartNode("expression", "empty_union")
		node.tokens["|"] = self:ParseToken("|")
		node = self:EndNode(node)
		return node
	end

	function META:ParseAsSubExpression(node)
		if not self:IsValue("as") then return end

		node.tokens["as"] = self:ExpectValue("as")
		node.type_expression = self:ParseTypeExpression(0)
	end

	function META:ParsePostfixTypeOperatorSubExpression(left_node)
		if not typesystem_syntax:IsPostfixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "postfix_operator")
		node.value = self:ParseToken()
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeCallSubExpression(left_node, primary_node)
		if not self:IsCallExpression(0) then return end

		local node = self:StartNode("expression", "postfix_call")
		local start = self:GetToken()

		if self:IsValue("{") then
			node.expressions = {self:ParseTableTypeExpression()}
		elseif self:IsType("string") then
			node.expressions = {self:ParseValueExpressionToken()}
		elseif self:IsValue("<|") then
			node.tokens["call("] = self:ExpectValue("<|")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue("|>")
		else
			node.tokens["call("] = self:ExpectValue("(")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue(")")
		end

		if primary_node.kind == "value" then
			local name = primary_node.value.value

			if name == "import" then
				self:HandleImportExpression(node, name, node.expressions[1].value.string_value, start)
			elseif name == "import_data" then
				self:HandleImportDataExpression(node, node.expressions[1].value.string_value, start)
			end
		end

		node.left = left_node
		node.type_call = true
		node = self:EndNode(node)
		return node
	end

	function META:ParsePostfixTypeIndexExpressionSubExpression(left_node)
		if not self:IsValue("[") then return end

		local node = self:StartNode("expression", "postfix_expression_index")
		node.tokens["["] = self:ExpectValue("[")
		node.expression = self:ExpectTypeExpression(0)
		node.tokens["]"] = self:ExpectValue("]")
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseTypeSubExpression(node)
		for _ = 1, self:GetLength() do
			local left_node = node
			local found = self:ParseIndexSubExpression(left_node) or
				self:ParseSelfCallSubExpression(left_node) or
				self:ParsePostfixTypeOperatorSubExpression(left_node) or
				self:ParseTypeCallSubExpression(left_node, node) or
				self:ParsePostfixTypeIndexExpressionSubExpression(left_node) or
				self:ParseAsSubExpression(left_node)

			if not found then break end

			if left_node.value and left_node.value.value == ":" then
				found.parser_call = true
			end

			node = found
		end

		return node
	end

	function META:ParseTypeExpression(priority)
		if self.TealCompat then return self:ParseTealExpression(priority) end

		profiler.PushZone("ParseTypeExpression")
		self:PushParserEnvironment("typesystem")
		local node
		local force_upvalue

		if self:IsValue("^") then
			force_upvalue = true
			self:Advance(1)
		end

		node = self:ParseParenthesisOrTupleTypeExpression() or
			self:ParseEmptyUnionTypeExpression() or
			self:ParsePrefixOperatorTypeExpression() or
			self:ParseAnalyzerFunctionExpression() or -- shared
			self:ParseFunctionSignatureExpression() or
			self:ParseTypeFunctionExpression() or -- shared
			self:ParseFunctionExpression() or -- shared
			self:ParseValueTypeExpression() or
			self:ParseKeywordValueTypeExpression() or
			self:ParseTableTypeExpression() or
			self:ParseStringTypeExpression()
		local first = node

		if node then
			node = self:ParseTypeSubExpression(node)

			if
				first.kind == "value" and
				(
					first.value.type == "letter" or
					first.value.value == "..."
				)
			then
				first.standalone_letter = node
				first.force_upvalue = force_upvalue
			end
		end

		while
			typesystem_syntax:GetBinaryOperatorInfo(self:GetToken()) and
			typesystem_syntax:GetBinaryOperatorInfo(self:GetToken()).left_priority > priority
		do
			local left_node = node
			node = self:StartNode("expression", "binary_operator", left_node)
			node.value = self:ParseToken()
			node.left = left_node
			node.right = self:ParseTypeExpression(typesystem_syntax:GetBinaryOperatorInfo(node.value).right_priority)
			node = self:EndNode(node)
		end

		self:PopParserEnvironment()
		profiler.PopZone()
		return node
	end

	function META:IsTypeExpression()
		local token = self:GetToken()
		return not (
			not token or
			token.type == "end_of_file" or
			token.value == "}" or
			token.value == "," or
			token.value == "]" or
			(
				typesystem_syntax:IsKeyword(token) and
				not typesystem_syntax:IsPrefixOperator(token)
				and
				not typesystem_syntax:IsValue(token)
				and
				token.value ~= "function"
			)
		)
	end

	function META:ExpectTypeExpression(priority)
		if not self:IsTypeExpression() then
			local token = self:GetToken()
			self:Error(
				"expected beginning of expression, got $1",
				nil,
				nil,
				token and token.value ~= "" and token.value or token.type
			)
			return
		end

		return self:ParseTypeExpression(priority)
	end
end

do -- runtime
	local ParseTableExpression

	do
		function META:read_table_spread()
			if
				not (
					self:IsValue("...") and
					(
						self:IsType("letter", 1) or
						self:IsValue("{", 1) or
						self:IsValue("(", 1)
					)
				)
			then
				return
			end

			local node = self:StartNode("expression", "table_spread")
			node.tokens["..."] = self:ExpectValue("...")
			node.expression = self:ExpectRuntimeExpression()
			node = self:EndNode(node)
			return node
		end

		function META:read_table_entry(i)
			if self:IsValue("[") then
				local node = self:StartNode("sub_statement", "table_expression_value")
				node.tokens["["] = self:ExpectValue("[")
				node.key_expression = self:ExpectRuntimeExpression(0)
				node.tokens["]"] = self:ExpectValue("]")
				node.tokens["="] = self:ExpectValue("=")
				node.value_expression = self:ExpectRuntimeExpression(0)
				node = self:EndNode(node)
				return node
			elseif self:IsType("letter") and self:IsValue("=", 1) then
				local node = self:StartNode("sub_statement", "table_key_value")
				node.tokens["identifier"] = self:ExpectType("letter")
				node.tokens["="] = self:ExpectValue("=")
				local spread = self:read_table_spread()

				if spread then
					node.spread = spread
				else
					node.value_expression = self:ExpectRuntimeExpression()
				end

				node = self:EndNode(node)
				return node
			end

			local node = self:StartNode("sub_statement", "table_index_value")
			local spread = self:read_table_spread()

			if spread then
				node.spread = spread
			else
				node.value_expression = self:ExpectRuntimeExpression()
			end

			node.key = i
			node = self:EndNode(node)
			return node
		end

		function META:ParseTableExpression()
			if not self:IsValue("{") then return end

			local tree = self:StartNode("expression", "table")
			tree.tokens["{"] = self:ExpectValue("{")
			tree.children = {}
			tree.tokens["separators"] = {}

			for i = 1, self:GetLength() do
				if self:IsValue("}") then break end

				local entry = self:read_table_entry(i)

				if entry.kind == "table_index_value" then
					tree.is_array = true
				else
					tree.is_dictionary = true
				end

				if entry.spread then tree.spread = true end

				tree.children[i] = entry

				if not self:IsValue(",") and not self:IsValue(";") and not self:IsValue("}") then
					self:Error(
						"expected $1 got $2",
						nil,
						nil,
						{",", ";", "}"},
						(self:GetToken() and self:GetToken().value) or "no token"
					)

					break
				end

				if not self:IsValue("}") then
					tree.tokens["separators"][i] = self:ParseToken()
				end
			end

			tree.tokens["}"] = self:ExpectValue("}")
			tree = self:EndNode(tree)
			return tree
		end
	end

	function META:ParsePostfixOperatorSubExpression(left_node)
		if not runtime_syntax:IsPostfixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "postfix_operator")
		node.value = self:ParseToken()
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseCallSubExpression(left_node, primary_node)
		if not self:IsCallExpression(0) then return end

		if primary_node and primary_node.kind == "function" then
			if not primary_node.tokens[")"] then return end
		end

		local node = self:StartNode("expression", "postfix_call", left_node)
		local start = self:GetToken()

		if self:IsValue("{") then
			node.expressions = {self:ParseTableExpression()}
		elseif self:IsType("string") then
			node.expressions = {self:ParseValueExpressionToken()}
		elseif self:IsValue("<|") then
			node.tokens["call("] = self:ExpectValue("<|")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue("|>")
			node.type_call = true

			if self:IsValue("(") then
				local lparen = self:ExpectValue("(")
				local expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
				local rparen = self:ExpectValue(")")
				node.expressions_typesystem = node.expressions
				node.expressions = expressions
				node.tokens["call_typesystem("] = node.tokens["call("]
				node.tokens["call_typesystem)"] = node.tokens["call)"]
				node.tokens["call("] = lparen
				node.tokens["call)"] = rparen
			end
		elseif self:IsValue("!") then
			node.tokens["!"] = self:ExpectValue("!")
			node.tokens["call("] = self:ExpectValue("(")
			node.expressions = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
			node.tokens["call)"] = self:ExpectValue(")")
			node.type_call = true
		else
			node.tokens["call("] = self:ExpectValue("(")
			node.expressions = self:ParseMultipleValues(nil, self.ParseRuntimeExpression, 0)
			node.tokens["call)"] = self:ExpectValue(")")
		end

		if
			primary_node.kind == "value" and
			node.expressions[1] and
			node.expressions[1].value and
			node.expressions[1].value.string_value
		then
			local name = primary_node.value.value

			if
				name == "import" or
				name == "dofile" or
				name == "loadfile" or
				name == "require"
			then
				self:HandleImportExpression(node, name, node.expressions[1].value.string_value, start)
			elseif name == "import_data" then
				self:HandleImportDataExpression(node, node.expressions[1].value.string_value, start)
			end
		end

		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParsePostfixIndexExpressionSubExpression(left_node)
		if not self:IsValue("[") then return end

		local node = self:StartNode("expression", "postfix_expression_index")
		node.tokens["["] = self:ExpectValue("[")
		node.expression = self:ExpectRuntimeExpression()
		node.tokens["]"] = self:ExpectValue("]")
		node.left = left_node
		node = self:EndNode(node)
		return node
	end

	function META:ParseSubExpression(node)
		for _ = 1, self:GetLength() do
			local left_node = node

			if
				self:IsValue(":") and
				(
					not self:IsType("letter", 1) or
					not self:IsCallExpression(2)
				)
			then
				node.tokens[":"] = self:ExpectValue(":")
				node.type_expression = self:ExpectTypeExpression(0)
			elseif self:IsValue("as") then
				node.tokens["as"] = self:ExpectValue("as")
				node.type_expression = self:ExpectTypeExpression(0)
			elseif self:IsValue("is") then
				node.tokens["is"] = self:ExpectValue("is")
				node.type_expression = self:ExpectTypeExpression(0)
			end

			local found = self:ParseIndexSubExpression(left_node) or
				self:ParseSelfCallSubExpression(left_node) or
				self:ParseCallSubExpression(left_node, node) or
				self:ParsePostfixOperatorSubExpression(left_node) or
				self:ParsePostfixIndexExpressionSubExpression(left_node)

			if not found then break end

			if left_node.value and left_node.value.value == ":" then
				found.parser_call = true
			end

			node = found
		end

		return node
	end

	function META:ParsePrefixOperatorExpression()
		if not runtime_syntax:IsPrefixOperator(self:GetToken()) then return end

		local node = self:StartNode("expression", "prefix_operator")
		node.value = self:ParseToken()
		node.tokens[1] = node.value
		node.right = self:ExpectRuntimeExpression(math.huge)
		node = self:EndNode(node)
		return node
	end

	function META:ParseParenthesisExpression()
		if not self:IsValue("(") then return end

		local pleft = self:ExpectValue("(")
		local node = self:ExpectRuntimeExpression(0)
		node.tokens["("] = node.tokens["("] or {}
		table_insert(node.tokens["("], pleft)
		node.tokens[")"] = node.tokens[")"] or {}
		table_insert(node.tokens[")"], self:ExpectValue(")"))
		return node
	end

	function META:ParseValueExpression()
		if not runtime_syntax:IsValue(self:GetToken()) then return end

		return self:ParseValueExpressionToken()
	end

	local function resolve_import_path(self, path)
		local working_directory = self.config.working_directory or ""

		if path:sub(1, 1) == "~" then
			path = path:sub(2)

			if path:sub(1, 1) == "/" then path = path:sub(2) end
		elseif path:sub(1, 2) == "./" then
			working_directory = self.config.file_path and
				self.config.file_path:match("(.+/)") or
				working_directory
			path = path:sub(3)
		end

		return working_directory .. path
	end

	local function resolve_require_path(require_path)
		local paths = package.path .. ";"
		paths = paths .. "./?/init.lua;"
		require_path = require_path:gsub("%.", "/")

		for package_path in paths:gmatch("(.-);") do
			local lua_path = package_path:gsub("%?", require_path)
			local f = io.open(lua_path, "r")

			if f then
				f:close()
				return lua_path
			end
		end

		return nil
	end

	function META:HandleImportExpression(node, name, str, start)
		if self.config.skip_import then return end

		if self.dont_hoist_next_import then
			self.dont_hoist_next_import = nil
			return
		end

		local path

		if name == "require" then
			path = resolve_require_path(str)
		else
			path = resolve_import_path(self, str)
		end

		if not path then return end

		local dont_hoist_import = _G.dont_hoist_import and _G.dont_hoist_import > 0
		node.import_expression = true
		node.path = path
		local key = name == "require" and str or path
		local root_node = self.config.root_statement_override_data or
			self.config.root_statement_override or
			self.RootStatement
		root_node.imported = root_node.imported or {}
		local imported = root_node.imported
		node.key = key

		if imported[key] == nil then
			imported[key] = node
			local root, err = self:ParseFile(
				path,
				{
					root_statement_override_data = self.config.root_statement_override_data or self.RootStatement,
					root_statement_override = self.RootStatement,
					path = node.path,
					working_directory = self.config.working_directory,
					inline_require = not root_node.data_import,
					on_node = self.config.on_node,
					on_read_file = self.config.on_read_file,
				}
			)

			if not root then
				self:Error("error importing file: $1", start, start, err)
			end

			node.RootStatement = root
		else
			-- ugly way of dealing with recursive require
			node.RootStatement = imported[key]
		end

		if root_node.data_import and dont_hoist_import then
			root_node.imports = root_node.imports or {}
			table.insert(root_node.imports, node)
			return
		end

		if name == "require" and not self.config.inline_require then
			root_node.imports = root_node.imports or {}
			table.insert(root_node.imports, node)
			return
		end

		self.RootStatement.imports = self.RootStatement.imports or {}
		table.insert(self.RootStatement.imports, node)
	end

	function META:HandleImportDataExpression(node, path, start)
		if self.config.skip_import then return end

		node.import_expression = true
		node.path = resolve_import_path(self, path)
		self.imported = self.imported or {}
		local key = "DATA_" .. node.path
		node.key = key
		local root_node = self.config.root_statement_override_data or
			self.config.root_statement_override or
			self.RootStatement
		root_node.imported = root_node.imported or {}
		local imported = root_node.imported
		root_node.data_import = true
		local data
		local err

		if imported[key] == nil then
			imported[key] = node

			if node.path:sub(-4) == "lua" or node.path:sub(-5) ~= "nlua" then
				local root, err = self:ParseFile(
					node.path,
					{
						root_statement_override_data = self.config.root_statement_override_data or self.RootStatement,
						path = node.path,
						working_directory = self.config.working_directory,
						on_node = self.config.on_node,
						on_read_file = self.config.on_read_file,
					--inline_require = true,
					}
				)

				if not root then
					self:Error("error importing file: $1", start, start, err .. ": " .. node.path)
				end

				data = root:Render(
					{
						preserve_whitespace = false,
						comment_type_annotations = false,
						type_annotations = true,
						inside_data_import = true,
					}
				)
			else
				local f
				f, err = io.open(node.path, "rb")

				if f then
					data = f:read("*all")
					f:close()
				end
			end

			if not data then
				self:Error("error importing file: $1", start, start, err .. ": " .. node.path)
			end

			node.data = data
		else
			node.data = imported[key].data
		end

		if _G.dont_hoist_import and _G.dont_hoist_import > 0 then return end

		self.RootStatement.imports = self.RootStatement.imports or {}
		table.insert(self.RootStatement.imports, node)
		return node
	end

	function META:check_integer_division_operator(node)
		if node and not node.idiv_resolved then
			for i, token in ipairs(node.whitespace) do
				if token.value:find("\n", nil, true) then break end

				if token.type == "line_comment" and token.value:sub(1, 2) == "//" then
					table_remove(node.whitespace, i)
					local tokens = self:LexString("/idiv" .. token.value:sub(2))

					for _, token in ipairs(tokens) do
						self:check_integer_division_operator(token)
					end

					self:AddTokens(tokens)
					node.idiv_resolved = true

					break
				end
			end
		end
	end

	function META:ParseRuntimeExpression(priority)
		if self:GetCurrentParserEnvironment() == "typesystem" then
			return self:ParseTypeExpression(priority)
		end

		profiler.PushZone("ParseRuntimeExpression")
		priority = priority or 0
		local node = self:ParseParenthesisExpression() or
			self:ParsePrefixOperatorExpression() or
			self:ParseAnalyzerFunctionExpression() or
			self:ParseFunctionExpression() or
			self:ParseValueExpression() or
			self:ParseTableExpression()
		local first = node

		if node then
			node = self:ParseSubExpression(node)

			if
				first.kind == "value" and
				(
					first.value.type == "letter" or
					first.value.value == "..."
				)
			then
				first.standalone_letter = node
			end
		end

		self:check_integer_division_operator(self:GetToken())

		while
			(
				runtime_syntax:GetBinaryOperatorInfo(self:GetToken()) and
				not self:IsValue("=", 1)
			)
			and
			runtime_syntax:GetBinaryOperatorInfo(self:GetToken()).left_priority > priority
		do
			local left_node = node
			node = self:StartNode("expression", "binary_operator", left_node)
			node.value = self:ParseToken()
			node.left = left_node

			if node.left then node.left.parent = node end

			node.right = self:ExpectRuntimeExpression(runtime_syntax:GetBinaryOperatorInfo(node.value).right_priority)
			node = self:EndNode(node)

			if not node.right then
				local token = self:GetToken()
				self:Error(
					"expected right side to be an expression, got $1",
					nil,
					nil,
					token and token.value ~= "" and token.value or token.type
				)
				return
			end
		end

		if node then node.first_node = first end

		profiler.PopZone("ParseRuntimeExpression")
		return node
	end

	function META:IsRuntimeExpression()
		local token = self:GetToken()
		return not (
			token.type == "end_of_file" or
			token.value == "}" or
			token.value == "," or
			token.value == "]" or
			token.value == ")" or
			(
				(
					runtime_syntax:IsKeyword(token) or
					runtime_syntax:IsNonStandardKeyword(token)
				) and
				not runtime_syntax:IsPrefixOperator(token)
				and
				not runtime_syntax:IsValue(token)
				and
				token.value ~= "function"
			)
		)
	end

	function META:ExpectRuntimeExpression(priority)
		if not self:IsRuntimeExpression() then
			local token = self:GetToken()
			self:Error(
				"expected beginning of expression, got $1",
				nil,
				nil,
				token and token.value ~= "" and token.value or token.type
			)
			return
		end

		return self:ParseRuntimeExpression(priority)
	end
end end ]=======], '@nattlua/parser/expressions.lua'))()
IMPORTS['nattlua/parser/statements.lua'] = assert(loadstring([=======[ return function(...) local META = ...
local runtime_syntax = IMPORTS['nattlua.syntax.runtime']("nattlua.syntax.runtime")
local typesystem_syntax = IMPORTS['nattlua.syntax.typesystem']("nattlua.syntax.typesystem")

do -- destructure statement
	function META:IsDestructureStatement(offset)
		offset = offset or 0
		return (
				self:IsValue("{", offset + 0) and
				self:IsType("letter", offset + 1)
			) or
			(
				self:IsType("letter", offset + 0) and
				self:IsValue(",", offset + 1) and
				self:IsValue("{", offset + 2)
			)
	end

	function META:IsLocalDestructureAssignmentStatement()
		if self:IsValue("local") then
			if self:IsValue("type", 1) then return self:IsDestructureStatement(2) end

			return self:IsDestructureStatement(1)
		end
	end

	function META:ParseDestructureAssignmentStatement()
		if not self:IsDestructureStatement() then return end

		local node = self:StartNode("statement", "destructure_assignment")

		do
			if self:IsType("letter") then
				node.default = self:ParseValueExpressionToken()
				node.default_comma = self:ExpectValue(",")
			end

			node.tokens["{"] = self:ExpectValue("{")
			node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
			node.tokens["}"] = self:ExpectValue("}")
			node.tokens["="] = self:ExpectValue("=")
			node.right = self:ExpectRuntimeExpression(0)
		end

		node = self:EndNode(node)
		return node
	end

	function META:ParseLocalDestructureAssignmentStatement()
		if not self:IsLocalDestructureAssignmentStatement() then return end

		local node = self:StartNode("statement", "local_destructure_assignment")
		node.tokens["local"] = self:ExpectValue("local")

		if self:IsValue("type") then
			node.tokens["type"] = self:ExpectValue("type")
			node.environment = "typesystem"
		end

		do -- remaining
			if self:IsType("letter") then
				node.default = self:ParseValueExpressionToken()
				node.default_comma = self:ExpectValue(",")
			end

			node.tokens["{"] = self:ExpectValue("{")
			node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
			node.tokens["}"] = self:ExpectValue("}")
			node.tokens["="] = self:ExpectValue("=")
			node.right = self:ExpectRuntimeExpression(0)
		end

		node = self:EndNode(node)
		return node
	end
end

do
	function META:ParseFunctionNameIndex()
		if not runtime_syntax:IsValue(self:GetToken()) then return end

		local node = self:ParseValueExpressionToken()
		local first = node
		first.standalone_letter = node

		while self:IsValue(".") or self:IsValue(":") do
			local left = node
			local self_call = self:IsValue(":")
			node = self:StartNode("expression", "binary_operator")
			node.value = self:ParseToken()
			node.right = self:ParseValueExpressionType("letter")
			node.left = left
			node.right.self_call = self_call
			node.is_left_assignment = true
			node = self:EndNode(node)
		end

		return node
	end

	function META:ParseFunctionStatement()
		if not self:IsValue("function") then return end

		local node = self:StartNode("statement", "function")
		node.tokens["function"] = self:ExpectValue("function")
		node.expression = self:ParseFunctionNameIndex()

		if node.expression and node.expression.kind == "binary_operator" then
			node.self_call = node.expression.right.self_call
		end

		if self:IsValue("<|") then
			node.kind = "type_function"
			self:ParseTypeFunctionBody(node)
		else
			self:ParseFunctionBody(node)
		end

		node = self:EndNode(node)
		return node
	end

	function META:ParseAnalyzerFunctionStatement()
		if not (self:IsValue("analyzer") and self:IsValue("function", 1)) then return end

		local node = self:StartNode("statement", "analyzer_function")
		node.tokens["analyzer"] = self:ExpectValue("analyzer")
		node.tokens["function"] = self:ExpectValue("function")
		local force_upvalue

		if self:IsValue("^") then
			force_upvalue = true
			node.tokens["^"] = self:ParseToken()
		end

		node.expression = self:ParseFunctionNameIndex()

		do -- hacky
			if node.expression.left then
				node.expression.left.standalone_letter = node
				node.expression.left.force_upvalue = force_upvalue
			else
				node.expression.standalone_letter = node
				node.expression.force_upvalue = force_upvalue
			end

			if node.expression.value.value == ":" then node.self_call = true end
		end

		self:ParseAnalyzerFunctionBody(node, true)
		node = self:EndNode(node)
		return node
	end
end

function META:ParseLocalFunctionStatement()
	if not (self:IsValue("local") and self:IsValue("function", 1)) then return end

	local node = self:StartNode("statement", "local_function")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["function"] = self:ExpectValue("function")
	node.tokens["identifier"] = self:ExpectType("letter")
	self:ParseFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseLocalAnalyzerFunctionStatement()
	if
		not (
			self:IsValue("local") and
			self:IsValue("analyzer", 1) and
			self:IsValue("function", 2)
		)
	then
		return
	end

	local node = self:StartNode("statement", "local_analyzer_function")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["analyzer"] = self:ExpectValue("analyzer")
	node.tokens["function"] = self:ExpectValue("function")
	node.tokens["identifier"] = self:ExpectType("letter")
	self:ParseAnalyzerFunctionBody(node, true)
	node = self:EndNode(node)
	return node
end

function META:ParseLocalTypeFunctionStatement()
	if
		not (
			self:IsValue("local") and
			self:IsValue("function", 1) and
			(
				self:IsValue("<|", 3) or
				self:IsValue("!", 3)
			)
		)
	then
		return
	end

	local node = self:StartNode("statement", "local_type_function")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["function"] = self:ExpectValue("function")
	node.tokens["identifier"] = self:ExpectType("letter")
	self:ParseTypeFunctionBody(node)
	node = self:EndNode(node)
	return node
end

function META:ParseBreakStatement()
	if not self:IsValue("break") then return nil end

	local node = self:StartNode("statement", "break")
	node.tokens["break"] = self:ExpectValue("break")
	node = self:EndNode(node)
	return node
end

function META:ParseDoStatement()
	if not self:IsValue("do") then return nil end

	local node = self:StartNode("statement", "do")
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseGenericForStatement()
	if not self:IsValue("for") then return nil end

	local node = self:StartNode("statement", "generic_for")
	node.tokens["for"] = self:ExpectValue("for")
	node.identifiers = self:ParseMultipleValues(nil, self.ParseIdentifier)
	node.tokens["in"] = self:ExpectValue("in")
	node.expressions = self:ParseMultipleValues(math.huge, self.ExpectRuntimeExpression, 0)
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseGotoLabelStatement()
	if not self:IsValue("::") then return nil end

	local node = self:StartNode("statement", "goto_label")
	node.tokens["::"] = self:ExpectValue("::")
	node.tokens["identifier"] = self:ExpectType("letter")
	node.tokens["::"] = self:ExpectValue("::")
	node = self:EndNode(node)
	return node
end

function META:ParseGotoStatement()
	if not self:IsValue("goto") or not self:IsType("letter", 1) then return nil end

	local node = self:StartNode("statement", "goto")
	node.tokens["goto"] = self:ExpectValue("goto")
	node.tokens["identifier"] = self:ExpectType("letter")
	node = self:EndNode(node)
	return node
end

function META:ParseIfStatement()
	if not self:IsValue("if") then return nil end

	local node = self:StartNode("statement", "if")
	node.expressions = {}
	node.statements = {}
	node.tokens["if/else/elseif"] = {}
	node.tokens["then"] = {}

	for i = 1, self:GetLength() do
		local token

		if i == 1 then
			token = self:ExpectValue("if")
		else
			token = self:ParseValues({
				["else"] = true,
				["elseif"] = true,
				["end"] = true,
			})
		end

		if not token then return end -- TODO: what happens here? :End is never called
		node.tokens["if/else/elseif"][i] = token

		if token.value ~= "else" then
			node.expressions[i] = self:ExpectRuntimeExpression(0)
			node.tokens["then"][i] = self:ExpectValue("then")
		end

		node.statements[i] = self:ParseStatements({
			["end"] = true,
			["else"] = true,
			["elseif"] = true,
		})

		if self:IsValue("end") then break end
	end

	node.tokens["end"] = self:ExpectValue("end")
	node = self:EndNode(node)
	return node
end

function META:ParseLocalAssignmentStatement()
	if not self:IsValue("local") then return end

	local node = self:StartNode("statement", "local_assignment")
	node.tokens["local"] = self:ExpectValue("local")

	if self.TealCompat and self:IsValue(",", 1) then
		node.left = self:ParseMultipleValues(nil, self.ParseIdentifier, false)

		if self:IsValue(":") then
			self:Advance(1)
			local expressions = self:ParseMultipleValues(nil, self.ParseTealExpression, 0)

			for i, v in ipairs(node.left) do
				v.type_expression = expressions[i]
				v.tokens[":"] = self:NewToken("symbol", ":")
			end
		end
	else
		node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
	end

	if self:IsValue("=") then
		node.tokens["="] = self:ExpectValue("=")
		node.right = self:ParseMultipleValues(nil, self.ExpectRuntimeExpression, 0)
	end

	node = self:EndNode(node)
	return node
end

function META:ParseNumericForStatement()
	if not (self:IsValue("for") and self:IsValue("=", 2)) then return nil end

	local node = self:StartNode("statement", "numeric_for")
	node.tokens["for"] = self:ExpectValue("for")
	node.identifiers = self:ParseMultipleValues(1, self.ParseIdentifier)
	node.tokens["="] = self:ExpectValue("=")
	node.expressions = self:ParseMultipleValues(3, self.ExpectRuntimeExpression, 0)
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseRepeatStatement()
	if not self:IsValue("repeat") then return nil end

	local node = self:StartNode("statement", "repeat")
	node.tokens["repeat"] = self:ExpectValue("repeat")
	node.statements = self:ParseStatements({["until"] = true})
	node.tokens["until"] = self:ExpectValue("until")
	node.expression = self:ExpectRuntimeExpression()
	node = self:EndNode(node)
	return node
end

function META:ParseSemicolonStatement()
	if not self:IsValue(";") then return nil end

	local node = self:StartNode("statement", "semicolon")
	node.tokens[";"] = self:ExpectValue(";")
	node = self:EndNode(node)
	return node
end

function META:ParseReturnStatement()
	if not self:IsValue("return") then return nil end

	local node = self:StartNode("statement", "return")
	node.tokens["return"] = self:ExpectValue("return")
	node.expressions = self:ParseMultipleValues(nil, self.ParseRuntimeExpression, 0)
	node = self:EndNode(node)
	return node
end

function META:ParseWhileStatement()
	if not self:IsValue("while") then return nil end

	local node = self:StartNode("statement", "while")
	node.tokens["while"] = self:ExpectValue("while")
	node.expression = self:ExpectRuntimeExpression()
	node.tokens["do"] = self:ExpectValue("do")
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["do"])
	node = self:EndNode(node)
	return node
end

function META:ParseContinueStatement()
	if not self:IsValue("continue") then return nil end

	local node = self:StartNode("statement", "continue")
	node.tokens["continue"] = self:ExpectValue("continue")
	node = self:EndNode(node)
	return node
end

function META:ParseDebugCodeStatement()
	if self:IsType("analyzer_debug_code") then
		local node = self:StartNode("statement", "analyzer_debug_code")
		node.lua_code = self:ParseValueExpressionType("analyzer_debug_code")
		node = self:EndNode(node)
		return node
	elseif self:IsType("parser_debug_code") then
		local token = self:ExpectType("parser_debug_code")
		assert(loadstring("local parser = ...;" .. token.value:sub(3)))(self)
		local node = self:StartNode("statement", "parser_debug_code")
		local code = self:StartNode("expression", "value")
		code.value = token
		code = self:EndNode(code)
		node.lua_code = code
		node = self:EndNode(node)
		return node
	end
end

function META:ParseLocalTypeAssignmentStatement()
	if
		not (
			self:IsValue("local") and
			self:IsValue("type", 1) and
			runtime_syntax:GetTokenType(self:GetToken(2)) == "letter"
		)
	then
		return
	end

	local node = self:StartNode("statement", "local_assignment")
	node.tokens["local"] = self:ExpectValue("local")
	node.tokens["type"] = self:ExpectValue("type")
	node.left = self:ParseMultipleValues(nil, self.ParseIdentifier)
	node.environment = "typesystem"

	if self:IsValue("=") then
		node.tokens["="] = self:ExpectValue("=")
		self:PushParserEnvironment("typesystem")
		node.right = self:ParseMultipleValues(nil, self.ExpectTypeExpression, 0)
		self:PopParserEnvironment()
	end

	node = self:EndNode(node)
	return node
end

function META:ParseTypeAssignmentStatement()
	if not (self:IsValue("type") and (self:IsType("letter", 1) or self:IsValue("^", 1))) then
		return
	end

	local node = self:StartNode("statement", "assignment")
	node.tokens["type"] = self:ExpectValue("type")
	node.left = self:ParseMultipleValues(nil, self.ExpectTypeExpression, 0)
	node.environment = "typesystem"

	if self:IsValue("=") then
		node.tokens["="] = self:ExpectValue("=")
		self:PushParserEnvironment("typesystem")
		node.right = self:ParseMultipleValues(nil, self.ExpectTypeExpression, 0)
		self:PopParserEnvironment()
	end

	node = self:EndNode(node)
	return node
end

function META:ParseCallOrAssignmentStatement()
	local start = self:GetToken()
	self:SuppressOnNode()
	local left = self:ParseMultipleValues(math.huge, self.ExpectRuntimeExpression, 0)

	if
		(
			self:IsValue("+") or
			self:IsValue("-") or
			self:IsValue("*") or
			self:IsValue("/") or
			self:IsValue("%") or
			self:IsValue("^") or
			self:IsValue("..")
		) and
		self:IsValue("=", 1)
	then
		-- roblox compound assignment
		local op_token = self:ParseToken()
		local eq_token = self:ParseToken()
		local bop = self:StartNode("expression", "binary_operator")
		bop.left = left[1]
		bop.value = op_token
		bop.right = self:ExpectRuntimeExpression(0)
		self:EndNode(bop)
		local node = self:StartNode("statement", "assignment", left[1])
		node.tokens["="] = eq_token
		node.left = left

		for i, v in ipairs(node.left) do
			v.is_left_assignment = true
		end

		node.right = {bop}
		self:ReRunOnNode(node.left)
		node = self:EndNode(node)
		return node
	end

	if self:IsValue("=") then
		local node = self:StartNode("statement", "assignment", left[1])
		node.tokens["="] = self:ExpectValue("=")
		node.left = left

		for i, v in ipairs(node.left) do
			v.is_left_assignment = true
		end

		node.right = self:ParseMultipleValues(math.huge, self.ExpectRuntimeExpression, 0)
		self:ReRunOnNode(node.left)
		node = self:EndNode(node)
		return node
	end

	if left[1] and (left[1].kind == "postfix_call") and not left[2] then
		local node = self:StartNode("statement", "call_expression", left[1])
		node.value = left[1]
		node.tokens = left[1].tokens
		self:ReRunOnNode(left)
		node = self:EndNode(node)
		return node
	end

	self:Error(
		"expected assignment or call expression got $1 ($2)",
		start,
		self:GetToken(),
		self:GetToken().type,
		self:GetToken().value
	)
end end ]=======], '@nattlua/parser/statements.lua'))()
IMPORTS['nattlua/parser/teal.lua'] = assert(loadstring([=======[ return function(...) local META = ...





local runtime_syntax = IMPORTS['nattlua.syntax.runtime']("nattlua.syntax.runtime")
local typesystem_syntax = IMPORTS['nattlua.syntax.typesystem']("nattlua.syntax.typesystem")
local math_huge = math.huge
local profiler = IMPORTS['nattlua.other.profiler']("nattlua.other.profiler")

function META:ParseTealFunctionArgument(expect_type)
	if
		expect_type or
		(
			self:IsType("letter") or
			self:IsValue("...")
		) and
		self:IsValue(":", 1)
	then
		if self:IsValue("...") then
			local node = self:StartNode("expression", "vararg")
			node.tokens["..."] = self:ExpectValue("...")
			node.tokens[":"] = self:ExpectValue(":")
			node.value = self:ParseValueExpressionType("letter")
			node = self:EndNode(node)
			return node
		end

		local identifier = self:ParseToken()
		local token = self:ExpectValue(":")
		local exp = self:ParseTealExpression(0)
		exp.tokens[":"] = token
		exp.identifier = identifier
		return exp
	end

	return self:ParseTealExpression(0)
end

function META:ParseTealFunctionSignature()
	if not self:IsValue("function") then return nil end

	local node = self:StartNode("expression", "function_signature")
	node.tokens["function"] = self:ExpectValue("function")

	if self:IsValue("<") then
		node.tokens["<"] = self:ExpectValue("<")
		node.identifiers_typesystem = self:ParseMultipleValues(math_huge, self.ParseTealFunctionArgument, false)
		node.tokens[">"] = self:ExpectValue(">")
	end

	node.tokens["="] = self:NewToken("symbol", "=")
	node.tokens["arguments("] = self:ExpectValue("(")
	node.identifiers = self:ParseMultipleValues(nil, self.ParseTealFunctionArgument)
	node.tokens["arguments)"] = self:ExpectValue(")")
	node.tokens[">"] = self:NewToken("symbol", ">")
	node.tokens["return("] = self:NewToken("symbol", "(")

	if self:IsValue(":") then
		node.tokens[":"] = self:ExpectValue(":")
		node.return_types = self:ParseMultipleValues(nil, self.ParseTealExpression, 0)
	else
		node.tokens[":"] = self:NewToken("symbol", ":")
		node.return_types = {}
	end

	node.tokens["return)"] = self:NewToken("symbol", ")")
	node = self:EndNode(node)
	return node
end

function META:ParseTealKeywordValueExpression()
	local token = self:GetToken()

	if not token then return end

	if not typesystem_syntax:IsValue(token) then return end

	local node = self:StartNode("expression", "value")
	node.value = self:ParseToken()
	node = self:EndNode(node)
	return node
end

function META:ParseTealVarargExpression()
	if not self:IsType("letter") or not self:IsValue("...", 1) then return end

	local node = self:StartNode("expression", "vararg")
	node.value = self:ParseValueExpressionType("letter")
	node.tokens["..."] = self:ExpectValue("...")
	node = self:EndNode(node)
	return node
end

function META:ParseTealTable()
	if not self:IsValue("{") then return nil end

	local node = self:StartNode("expression", "type_table")
	node.tokens["{"] = self:ExpectValue("{")
	node.tokens["separators"] = {}
	node.children = {}

	if
		self:IsValue(":", 1) or
		self:IsValue("(") or
		(
			self:IsValue("{") and
			self:IsValue(":", 2) and
			self:IsValue(":", 5)
		)
	then
		local kv = self:StartNode("sub_statement", "table_expression_value")

		if self:IsValue("(") then
			kv.tokens["["] = self:ExpectValueTranslate("(", "[")
			kv.key_expression = self:ParseTealExpression(0)
			kv.tokens["]"] = self:ExpectValueTranslate(")", "]")
		elseif self:IsValue("{") then
			kv.tokens["["] = self:NewToken("symbol", "[")
			kv.key_expression = self:ParseTealTable()

			if self:IsValue("}") then
				kv = self:EndNode(kv)
				node.children = {kv}
				node.tokens["}"] = self:ExpectValue("}")
				node = self:EndNode(node)
				return node
			end

			kv.tokens["]"] = self:NewToken("symbol", "]")
		else
			kv.tokens["["] = self:NewToken("symbol", "[")
			kv.key_expression = self:ParseValueExpressionType("letter")
			kv.key_expression.standalone_letter = true
			kv.tokens["]"] = self:NewToken("symbol", "]")
		end

		kv.tokens["="] = self:ExpectValueTranslate(":", "=")
		kv.value_expression = self:ParseTealExpression(0)
		kv = self:EndNode(kv)
		node.children = {kv}
	else
		local i = 1

		while true do
			local kv = self:StartNode("sub_statement", "table_expression_value")
			kv.tokens["["] = self:NewToken("symbol", "[")
			local key = self:StartNode("expression", "value")
			key.value = self:NewToken("letter", "number")
			key.standalone_letter = key
			key = self:EndNode(key)
			kv.key_expression = key
			kv.tokens["]"] = self:NewToken("symbol", "]")
			kv.tokens["="] = self:NewToken("symbol", "=")
			kv.value_expression = self:ParseTealExpression(0)
			kv = self:EndNode(kv)
			table.insert(node.children, kv)

			if not self:IsValue(",") then
				if i > 1 then key.value = self:NewToken("number", tostring(i)) end

				break
			end

			key.value = self:NewToken("number", tostring(i))
			i = i + 1
			table.insert(node.tokens["separators"], self:ExpectValue(","))
		end
	end

	node.tokens["}"] = self:ExpectValue("}")
	node = self:EndNode(node)
	return node
end

function META:ParseTealTuple()
	if not self:IsValue("(") then return nil end

	local node = self:StartNode("expression", "tuple")
	node.tokens["("] = self:ExpectValue("(")
	node.expressions = self:ParseMultipleValues(nil, self.ParseTealExpression, 0)
	node.tokens[")"] = self:ExpectValue(")")
	node = self:EndNode(node)
	return node
end

function META:ParseTealCallSubExpression()
	if not self:IsValue("<") then return end

	local node = self:StartNode("expression", "postfix_call")
	node.tokens["call("] = self:ExpectValueTranslate("<", "<|")
	node.expressions = self:ParseMultipleValues(nil, self.ParseTealExpression, 0)
	node.tokens["call)"] = self:ExpectValueTranslate(">", "|>")
	node.type_call = true
	node = self:EndNode(node)
	return node
end

function META:ParseTealSubExpression(node)
	for _ = 1, self:GetLength() do
		local left_node = node
		local found = self:ParseIndexSubExpression() or
			--self:ParseSelfCallSubExpression() or
			--self:ParsePostfixTypeOperatorSubExpression() or
			self:ParseTealCallSubExpression() --or
		--self:ParsePostfixTypeIndexExpressionSubExpression() or
		--self:ParseAsSubExpression(left_node)
		if not found then break end

		found.left = left_node

		if left_node.value and left_node.value.value == ":" then
			found.parser_call = true
		end

		node = found
	end

	return node
end

function META:ParseTealExpression(priority)
	profiler.PushZone("ParseTealTypeExpression")
	self:PushParserEnvironment("typesystem")
	local node = self:ParseTealFunctionSignature() or
		self:ParseTealVarargExpression() or
		self:ParseTealKeywordValueExpression() or
		self:ParseTealTable() or
		self:ParseTealTuple()
	local first = node

	if node then
		node = self:ParseTealSubExpression(node)

		if
			first.kind == "value" and
			(
				first.value.type == "letter" or
				first.value.value == "..."
			)
		then
			first.standalone_letter = node
		end
	end

	if self.TealCompat and self:IsValue(">") then
		self:PopParserEnvironment()
		profiler.PopZone()
		return node
	end

	while
		typesystem_syntax:GetBinaryOperatorInfo(self:GetToken()) and
		typesystem_syntax:GetBinaryOperatorInfo(self:GetToken()).left_priority > priority
	do
		local left_node = node
		node = self:StartNode("expression", "binary_operator")
		node.value = self:ParseToken()
		node.left = left_node
		node.right = self:ParseTealExpression(typesystem_syntax:GetBinaryOperatorInfo(node.value).right_priority)
		node = self:EndNode(node)
	end

	self:PopParserEnvironment()
	profiler.PopZone()
	return node
end

function META:ParseTealAssignment()
	if not self:IsValue("type") or not self:IsType("letter", 1) then return nil end

	local kv = self:StartNode("statement", "assignment")
	kv.tokens["type"] = self:ExpectValue("type")
	kv.left = {self:ParseValueExpressionToken()}
	kv.tokens["="] = self:ExpectValue("=")
	kv.right = {self:ParseTealExpression(0)}
	kv = self:EndNode(kv)
	return kv
end

function META:ParseTealRecordKeyVal()
	if not self:IsType("letter") or not self:IsValue(":", 1) then return nil end

	local kv = self:StartNode("statement", "assignment")
	kv.tokens["type"] = self:NewToken("letter", "type")
	kv.left = {self:ParseValueExpressionToken()}
	kv.tokens["="] = self:ExpectValueTranslate(":", "=")
	kv.right = {self:ParseTealExpression(0)}
	return kv
end

function META:ParseTealRecordArray()
	if not self:IsValue("{") then return nil end

	local kv = self:StartNode("statement", "assignment")
	kv.tokens["type"] = self:ExpectValueTranslate("{", "type")
	kv.left = {self:ParseString("_G[number] = 1").statements[1].left[1]}
	kv.tokens["="] = self:NewToken("symbol", "=")
	kv.right = {self:ParseTealExpression(0)}
	self:Advance(1) -- }
	kv = self:EndNode(kv)
	return kv
end

function META:ParseTealRecordMetamethod()
	if
		not self:IsValue("metamethod") or
		not self:IsType("letter", 1)
		or
		not self:IsValue(":", 2)
	then
		return nil
	end

	local kv = self:StartNode("statement", "assignment")
	kv.tokens["type"] = self:ExpectValueTranslate("metamethod", "type")
	kv.left = {self:ParseValueExpressionToken()}
	kv.tokens["="] = self:ExpectValueTranslate(":", "=")
	kv.right = {self:ParseTealExpression(0)}
	return kv
end

local function ParseRecordBody(
	self,
	assignment
)
	local func

	if self:IsValue("<") then
		func = self:StartNode("statement", "local_type_function")
		func.tokens["local"] = self:NewToken("letter", "local")
		func.tokens["identifier"] = assignment.left[1].value
		func.tokens["function"] = self:NewToken("letter", "function")
		func.tokens["arguments("] = self:ExpectValueTranslate("<", "<|")
		func.identifiers = self:ParseMultipleValues(nil, self.ParseValueExpressionToken)
		func.tokens["arguments)"] = self:ExpectValueTranslate(">", "|>")
		func.statements = {}
	end

	local name = func and "__env" or assignment.left[1].value.value
	assignment.left[1].value = self:NewToken("letter", name)
	local tbl = self:StartNode("expression", "type_table")
	tbl.tokens["{"] = self:NewToken("symbol", "{")
	tbl.tokens["}"] = self:NewToken("symbol", "}")
	tbl.children = {}
	tbl = self:EndNode(tbl)
	assignment.right = {tbl}
	assignment = self:EndNode(assignment)
	local block = self:StartNode("statement", "do")
	block.tokens["do"] = self:NewToken("letter", "do")
	block.statements = {}
	table.insert(
		block.statements,
		self:ParseString("PushTypeEnvironment<|" .. name .. "|>").statements[1]
	)

	while true do
		local node = self:ParseTealEnumStatement() or
			self:ParseTealAssignment() or
			self:ParseTealRecord() or
			self:ParseTealRecordMetamethod() or
			self:ParseTealRecordKeyVal() or
			self:ParseTealRecordArray()

		if not node then break end

		if node[1] then
			for _, node in ipairs(node) do
				table.insert(block.statements, node)
			end
		else
			table.insert(block.statements, node)
		end
	end

	table.insert(block.statements, self:ParseString("PopTypeEnvironment<||>").statements[1])
	block.tokens["end"] = self:ExpectValue("end")
	block = self:EndNode(block)
	self:PopParserEnvironment("typesystem")

	if func then
		table.insert(func.statements, assignment)
		table.insert(func.statements, block)
		table.insert(func.statements, self:ParseString("return " .. name).statements[1])
		func.tokens["end"] = self:NewToken("letter", "end")
		func = self:EndNode(func)
		return func
	end

	return {assignment, block}
end

function META:ParseTealRecord()
	if not self:IsValue("record") or not self:IsType("letter", 1) then return nil end

	self:PushParserEnvironment("typesystem")
	local assignment = self:StartNode("statement", "assignment")
	assignment.tokens["type"] = self:ExpectValueTranslate("record", "type")
	assignment.tokens["="] = self:NewToken("symbol", "=")
	assignment.left = {self:ParseValueExpressionToken()}
	return ParseRecordBody(self, assignment)
end

function META:ParseLocalTealRecord()
	if
		not self:IsValue("local") or
		not self:IsValue("record", 1)
		or
		not self:IsType("letter", 2)
	then
		return nil
	end

	self:PushParserEnvironment("typesystem")
	local assignment = self:StartNode("statement", "local_assignment")
	assignment.tokens["local"] = self:ExpectValue("local")
	assignment.tokens["type"] = self:ExpectValueTranslate("record", "type")
	assignment.tokens["="] = self:NewToken("symbol", "=")
	assignment.left = {self:ParseValueExpressionToken()}
	return ParseRecordBody(self, assignment)
end

do
	local function ParseBody(
		self,
		assignment
	)
		assignment.tokens["type"] = self:ExpectValueTranslate("enum", "type")
		assignment.left = {self:ParseValueExpressionToken()}
		assignment.tokens["="] = self:NewToken("symbol", "=")
		local bnode = self:ParseValueExpressionType("string")

		while not self:IsValue("end") do
			local left = bnode
			bnode = self:StartNode("expression", "binary_operator")
			bnode.value = self:NewToken("symbol", "|")
			bnode.right = self:ParseValueExpressionType("string")
			bnode.left = left
			bnode = self:EndNode(bnode)
		end

		assignment.right = {bnode}
		self:ExpectValue("end")
	end

	function META:ParseTealEnumStatement()
		if not self:IsValue("enum") or not self:IsType("letter", 1) then return nil end

		self:PushParserEnvironment("typesystem")
		local assignment = self:StartNode("statement", "assignment")
		ParseBody(self, assignment)
		assignment = self:EndNode(assignment)
		self:PopParserEnvironment("typesystem")
		return assignment
	end

	function META:ParseLocalTealEnumStatement()
		if
			not self:IsValue("local") or
			not self:IsValue("enum", 1)
			or
			not self:IsType("letter", 2)
		then
			return nil
		end

		self:PushParserEnvironment("typesystem")
		local assignment = self:StartNode("statement", "local_assignment")
		assignment.tokens["local"] = self:ExpectValue("local")
		ParseBody(self, assignment)
		assignment = self:EndNode(assignment)
		self:PopParserEnvironment("typesystem")
		return assignment
	end
end end ]=======], '@nattlua/parser/teal.lua'))()
do local __M; IMPORTS["nattlua.parser"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local META = IMPORTS['nattlua.parser.base']("nattlua.parser.base")
local profiler = IMPORTS['nattlua.other.profiler']("nattlua.other.profiler")
local Code = IMPORTS['nattlua.code']("nattlua.code").New
local Lexer = IMPORTS['nattlua.lexer']("nattlua.lexer").New
local math = _G.math
local math_huge = math.huge
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local ipairs = _G.ipairs





function META:ParseIdentifier(expect_type)
	if not self:IsType("letter") and not self:IsValue("...") then return end

	local node = self:StartNode("expression", "value") -- as ValueExpression ]]
	node.is_identifier = true

	if self:IsValue("...") then
		node.value = self:ExpectValue("...")
	else
		node.value = self:ExpectType("letter")

		if self:IsValue("<") then
			node.tokens["<"] = self:ExpectValue("<")
			node.attribute = self:ExpectType("letter")
			node.tokens[">"] = self:ExpectValue(">")
		end
	end

	if expect_type ~= false then
		if self:IsValue(":") or expect_type then
			node.tokens[":"] = self:ExpectValue(":")
			node.type_expression = self:ExpectTypeExpression(0)
		end
	end

	node = self:EndNode(node)
	return node
end

function META:ParseValueExpressionToken(expect_value)
	local node = self:StartNode("expression", "value")
	node.value = expect_value and self:ExpectValue(expect_value) or self:ParseToken()
	node = self:EndNode(node)
	return node
end

function META:ParseValueExpressionType(expect_value)
	local node = self:StartNode("expression", "value")
	node.value = self:ExpectType(expect_value)
	node = self:EndNode(node)
	return node
end

function META:ParseFunctionBody(
	node
)
	if self.TealCompat then
		if self:IsValue("<") then
			node.tokens["arguments_typesystem("] = self:ExpectValue("<")
			node.identifiers_typesystem = self:ParseMultipleValues(nil, self.ParseIdentifier)
			node.tokens["arguments_typesystem)"] = self:ExpectValue(">")
		end
	end

	node.tokens["arguments("] = self:ExpectValue("(")
	node.identifiers = self:ParseMultipleValues(nil, self.ParseIdentifier)
	node.tokens["arguments)"] = self:ExpectValue(")", node.tokens["arguments("])

	if self:IsValue(":") then
		node.tokens["return:"] = self:ExpectValue(":")
		self:PushParserEnvironment("typesystem")
		node.return_types = self:ParseMultipleValues(nil, self.ParseTypeExpression, 0)
		self:PopParserEnvironment()
	end

	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", node.tokens["function"])
	return node
end

function META:ParseTypeFunctionBody(
	node
)
	if self:IsValue("!") then
		node.tokens["!"] = self:ExpectValue("!")
		node.tokens["arguments("] = self:ExpectValue("(")
		node.identifiers = self:ParseMultipleValues(nil, self.ParseIdentifier, true)

		if self:IsValue("...") then
			table_insert(node.identifiers, self:ParseValueExpressionToken("..."))
		end

		node.tokens["arguments)"] = self:ExpectValue(")")
	else
		node.tokens["arguments("] = self:ExpectValue("<|")
		node.identifiers = self:ParseMultipleValues(nil, self.ParseIdentifier, true)

		if self:IsValue("...") then
			table_insert(node.identifiers, self:ParseValueExpressionToken("..."))
		end

		node.tokens["arguments)"] = self:ExpectValue("|>", node.tokens["arguments("])

		if self:IsValue("(") then
			local lparen = self:ExpectValue("(")
			local identifiers = self:ParseMultipleValues(nil, self.ParseIdentifier, true)
			local rparen = self:ExpectValue(")")
			node.identifiers_typesystem = node.identifiers
			node.identifiers = identifiers
			node.tokens["arguments_typesystem("] = node.tokens["arguments("]
			node.tokens["arguments_typesystem)"] = node.tokens["arguments)"]
			node.tokens["arguments("] = lparen
			node.tokens["arguments)"] = rparen
		end
	end

	if self:IsValue(":") then
		node.tokens["return:"] = self:ExpectValue(":")
		self:PushParserEnvironment("typesystem")
		node.return_types = self:ParseMultipleValues(math.huge, self.ExpectTypeExpression, 0)
		self:PopParserEnvironment("typesystem")
	end

	if node.identifiers_typesystem then
		node.environment = "runtime"
		self:PushParserEnvironment("runtime")
	else
		node.environment = "typesystem"
		self:PushParserEnvironment("typesystem")
	end

	local start = self:GetToken()
	node.statements = self:ParseStatements({["end"] = true})
	node.tokens["end"] = self:ExpectValue("end", start, start)
	self:PopParserEnvironment()
	return node
end

function META:ParseTypeFunctionArgument(expect_type)
	if self:IsValue(")") then return end

	if self:IsValue("...") then return end

	if expect_type or self:IsType("letter") and self:IsValue(":", 1) then
		local identifier = self:ParseToken()
		local token = self:ExpectValue(":")
		local exp = self:ExpectTypeExpression(0)
		exp.tokens[":"] = token
		exp.identifier = identifier
		return exp
	end

	return self:ExpectTypeExpression(0)
end

function META:ParseAnalyzerFunctionBody(
	node,
	type_args
)
	self:PushParserEnvironment("runtime")
	node.tokens["arguments("] = self:ExpectValue("(")
	node.identifiers = self:ParseMultipleValues(math_huge, self.ParseTypeFunctionArgument, type_args)

	if self:IsValue("...") then
		local vararg = self:StartNode("expression", "value")
		vararg.value = self:ExpectValue("...")

		if self:IsValue(":") or type_args then
			vararg.tokens[":"] = self:ExpectValue(":")
			vararg.type_expression = self:ExpectTypeExpression(0)
		else
			if self:IsType("letter") then
				vararg.type_expression = self:ExpectTypeExpression(0)
			end
		end

		vararg = self:EndNode(vararg)
		table_insert(node.identifiers, vararg)
	end

	node.tokens["arguments)"] = self:ExpectValue(")", node.tokens["arguments("])

	if self:IsValue(":") then
		node.tokens["return:"] = self:ExpectValue(":")
		self:PushParserEnvironment("typesystem")
		node.return_types = self:ParseMultipleValues(math.huge, self.ParseTypeExpression, 0)
		self:PopParserEnvironment()
		local start = self:GetToken()
		_G.dont_hoist_import = (_G.dont_hoist_import or 0) + 1
		node.statements = self:ParseStatements({["end"] = true})
		_G.dont_hoist_import = (_G.dont_hoist_import or 0) - 1
		node.tokens["end"] = self:ExpectValue("end", start, start)
	elseif not self:IsValue(",") then
		local start = self:GetToken()
		_G.dont_hoist_import = (_G.dont_hoist_import or 0) + 1
		node.statements = self:ParseStatements({["end"] = true})
		_G.dont_hoist_import = (_G.dont_hoist_import or 0) - 1
		node.tokens["end"] = self:ExpectValue("end", start, start)
	end

	self:PopParserEnvironment()
	return node
end

assert(IMPORTS['nattlua/parser/expressions.lua'])(META)
assert(IMPORTS['nattlua/parser/statements.lua'])(META)
assert(IMPORTS['nattlua/parser/teal.lua'])(META)

function META:LexString(str, config)
	config = config or {}
	local code = Code(str, config.file_path)
	local lexer = Lexer(code, config)
	lexer.OnError = self.OnError
	local ok, tokens = xpcall(lexer.GetTokens, debug.traceback, lexer)

	if not ok then return nil, tokens end

	return tokens, code
end

function META:ParseString(str, config)
	local tokens, code = self:LexString(str, config)

	if not tokens then return nil, code end

	local parser = self.New(tokens, code, config)
	parser.OnError = self.OnError
	local ok, node = xpcall(parser.ParseRootNode, debug.traceback, parser)

	if not ok then return nil, node end

	node.lexer_tokens = tokens
	node.parser = parser
	node.code = code
	return node
end

local function read_file(self, path)
	local code = self.config.on_read_file and self.config.on_read_file(self, path)

	if code then return code end

	local f, err = io.open(path, "rb")

	if not f then return nil, err end

	local code = f:read("*a")
	f:close()

	if not code then return nil, "file is empty" end

	return code
end

function META:ParseFile(path, config)
	config = config or {}
	config.file_path = config.file_path or path
	config.file_name = config.file_name or path
	local code, err = read_file(self, path)

	if not code then return code, err end

	return self:ParseString(code, config)
end

local imported_index = nil

function META:ParseRootNode()
	local node = self:StartNode("statement", "root")
	self.RootStatement = self.config and self.config.root_statement_override or node
	local shebang

	if self:IsType("shebang") then
		shebang = self:StartNode("statement", "shebang")
		shebang.tokens["shebang"] = self:ExpectType("shebang")
		shebang = self:EndNode(shebang)
		node.tokens["shebang"] = shebang.tokens["shebang"]
	end

	local import_tree

	if self.config.emit_environment then
		if not imported_index then
			imported_index = true
			imported_index = self:ParseString([[import("nattlua/definitions/index.nlua")]])
		end

		if imported_index and imported_index ~= true then
			self.RootStatement.imports = self.RootStatement.imports or {}

			for _, import in ipairs(imported_index.imports) do
				table.insert(self.RootStatement.imports, import)
			end

			import_tree = imported_index
		end
	end

	node.statements = self:ParseStatements()

	if shebang then table.insert(node.statements, 1, shebang) end

	if import_tree then
		table.insert(node.statements, 1, import_tree.statements[1])
	end

	if self:IsType("end_of_file") then
		local eof = self:StartNode("statement", "end_of_file")
		eof.tokens["end_of_file"] = self.tokens[#self.tokens]
		eof = self:EndNode(eof)
		table.insert(node.statements, eof)
		node.tokens["eof"] = eof.tokens["end_of_file"]
	end

	node = self:EndNode(node)
	return node
end

function META:ParseStatement()
	if self:IsType("end_of_file") then return end

	profiler.PushZone("ReadStatement")
	local node = self:ParseDebugCodeStatement() or
		self:ParseReturnStatement() or
		self:ParseBreakStatement() or
		self:ParseContinueStatement() or
		self:ParseSemicolonStatement() or
		self:ParseGotoStatement() or
		self:ParseGotoLabelStatement() or
		self:ParseRepeatStatement() or
		self:ParseAnalyzerFunctionStatement() or
		self:ParseFunctionStatement() or
		self:ParseLocalTypeFunctionStatement() or
		self:ParseLocalFunctionStatement() or
		self:ParseLocalAnalyzerFunctionStatement() or
		self:ParseLocalTypeAssignmentStatement() or
		self:ParseLocalDestructureAssignmentStatement() or
		(
			self.TealCompat and
			self:ParseLocalTealRecord()
		)
		or
		(
			self.TealCompat and
			self:ParseLocalTealEnumStatement()
		)
		or
		self:ParseLocalAssignmentStatement() or
		self:ParseTypeAssignmentStatement() or
		self:ParseDoStatement() or
		self:ParseIfStatement() or
		self:ParseWhileStatement() or
		self:ParseNumericForStatement() or
		self:ParseGenericForStatement() or
		self:ParseDestructureAssignmentStatement() or
		self:ParseCallOrAssignmentStatement()
	profiler.PopZone()
	return node
end

return META end ]=======], '@./nattlua/parser.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.function"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local tostring = _G.tostring
local ipairs = _G.ipairs
local setmetatable = _G.setmetatable
local table = _G.table
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local VarArg = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").VarArg
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local META = IMPORTS['nattlua/types/base.lua']("nattlua/types/base.lua")





META.Type = "function"
META.Truthy = true
META.Falsy = false
META:IsSet("Called", false)
META:IsSet("ExplicitInputSignature", false)
META:IsSet("ExplicitOutputSignature", false)
META:GetSet("InputSignature", nil)
META:GetSet("OutputSignature", nil)
META:GetSet("FunctionBodyNode", nil)
META:GetSet("Scope", nil)
META:GetSet("UpvaluePosition", nil)
META:GetSet("InputIdentifiers", nil)
META:GetSet("AnalyzerFunction", nil)
META:IsSet("ArgumentsInferred", false)
META:GetSet("PreventInputArgumentExpansion", false)

function META:__tostring()
	return "function=" .. tostring(self:GetInputSignature()) .. ">" .. tostring(self:GetOutputSignature())
end

function META:__call(...)
	local f = self:GetAnalyzerFunction()

	if f then return f(...) end
end

function META.Equal(a, b)
	return a.Type == b.Type and
		a:GetInputSignature():Equal(b:GetInputSignature()) and
		a:GetOutputSignature():Equal(b:GetOutputSignature())
end

function META:Copy(map, copy_tables)
	map = map or {}
	local copy = self.New(
		self:GetInputSignature():Copy(map, copy_tables),
		self:GetOutputSignature():Copy(map, copy_tables)
	)
	map[self] = map[self] or copy
	copy:SetUpvaluePosition(self:GetUpvaluePosition())
	copy:SetAnalyzerFunction(self:GetAnalyzerFunction())
	copy:SetScope(self:GetScope())
	copy:SetLiteral(self:IsLiteral())
	copy:CopyInternalsFrom(self)
	copy:SetFunctionBodyNode(self:GetFunctionBodyNode())
	copy:SetInputIdentifiers(self:GetInputIdentifiers())
	copy:SetCalled(self:IsCalled())
	copy:SetExplicitInputSignature(self:IsExplicitInputSignature())
	copy:SetExplicitOutputSignature(self:IsExplicitOutputSignature())
	copy:SetArgumentsInferred(self:IsArgumentsInferred())
	copy:SetPreventInputArgumentExpansion(self:GetPreventInputArgumentExpansion())
	return copy
end

function META.IsSubsetOf(a, b)
	if b.Type == "tuple" then b = b:Get(1) end

	if b.Type == "union" then return b:IsTargetSubsetOfChild(a) end

	if b.Type == "any" then return true end

	if b.Type ~= "function" then return type_errors.type_mismatch(a, b) end

	local ok, reason = a:GetInputSignature():IsSubsetOf(b:GetInputSignature())

	if not ok then
		return type_errors.subset(a:GetInputSignature(), b:GetInputSignature(), reason)
	end

	local ok, reason = a:GetOutputSignature():IsSubsetOf(b:GetOutputSignature())

	if
		not ok and
		(
			(
				not b:IsCalled() and
				not b:IsExplicitOutputSignature()
			)
			or
			(
				not a:IsCalled() and
				not a:IsExplicitOutputSignature()
			)
		)
	then
		return true
	end

	if not ok then
		return type_errors.subset(a:GetOutputSignature(), b:GetOutputSignature(), reason)
	end

	return true
end

function META.IsCallbackSubsetOf(a, b)
	if b.Type == "tuple" then b = b:Get(1) end

	if b.Type == "union" then return b:IsTargetSubsetOfChild(a) end

	if b.Type == "any" then return true end

	if b.Type ~= "function" then return type_errors.type_mismatch(a, b) end

	local ok, reason = a:GetInputSignature():IsSubsetOf(b:GetInputSignature(), a:GetInputSignature():GetMinimumLength())

	if not ok then
		return type_errors.subset(a:GetInputSignature(), b:GetInputSignature(), reason)
	end

	local ok, reason = a:GetOutputSignature():IsSubsetOf(b:GetOutputSignature())

	if
		not ok and
		(
			(
				not b:IsCalled() and
				not b:IsExplicitOutputSignature()
			)
			or
			(
				not a:IsCalled() and
				not a:IsExplicitOutputSignature()
			)
		)
	then
		return true
	end

	if not ok then
		return type_errors.subset(a:GetOutputSignature(), b:GetOutputSignature(), reason)
	end

	return true
end

do
	function META:AddScope(arguments, return_result, scope)
		self.scopes = self.scopes or {}
		table.insert(
			self.scopes,
			{
				arguments = arguments,
				return_result = return_result,
				scope = scope,
			}
		)
	end

	function META:GetSideEffects()
		local out = {}

		for _, call_info in ipairs(self.scopes) do
			for _, val in ipairs(call_info.scope:GetDependencies()) do
				if (val.Type == "upvalue" and val:GetScope() or val.scope) ~= call_info.scope then
					table.insert(out, val)
				end
			end
		end

		return out
	end

	function META:GetCallCount()
		return #self.scopes
	end

	function META:IsPure()
		return #self:GetSideEffects() == 0
	end
end

function META:IsRefFunction()
	for i, v in ipairs(self:GetInputSignature():GetData()) do
		if v:IsReferenceArgument() then return true end
	end

	for i, v in ipairs(self:GetOutputSignature():GetData()) do
		if v:IsReferenceArgument() then return true end
	end

	return false
end

function META.New(input, output)
	local self = setmetatable(
		{
			Falsy = false,
			Truthy = true,
			Literal = false,
			LiteralArgument = false,
			ReferenceArgument = false,
			Called = false,
			ExplicitInputSignature = false,
			ExplicitOutputSignature = false,
			ArgumentsInferred = false,
			PreventInputArgumentExpansion = false,
			scopes = {},
			InputSignature = input,
			OutputSignature = output,
			suppress = false,
		},
		META
	)
	return self
end

return {
	Function = META.New,
	AnyFunction = function()
		return META.New(Tuple({VarArg(Any())}), Tuple({VarArg(Any())}))
	end,
	LuaTypeFunction = function(
		lua_function,
		arg,
		ret
	)
		local self = META.New(Tuple(arg), Tuple(ret))
		self:SetAnalyzerFunction(lua_function)
		return self
	end,
} end ]=======], '@./nattlua/types/function.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.types.types"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local types = {}

function types.Initialize()
	types.Table = IMPORTS['nattlua.types.table']("nattlua.types.table").Table
	types.Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
	types.Nilable = IMPORTS['nattlua.types.union']("nattlua.types.union").Nilable
	types.Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
	types.VarArg = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").VarArg
	types.Number = IMPORTS['nattlua.types.number']("nattlua.types.number").Number
	types.LNumber = IMPORTS['nattlua.types.number']("nattlua.types.number").LNumber
	types.Function = IMPORTS['nattlua.types.function']("nattlua.types.function").Function
	types.AnyFunction = IMPORTS['nattlua.types.function']("nattlua.types.function").AnyFunction
	types.LuaTypeFunction = IMPORTS['nattlua.types.function']("nattlua.types.function").LuaTypeFunction
	types.String = IMPORTS['nattlua.types.string']("nattlua.types.string").String
	types.LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
	types.Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
	types.Symbol = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Symbol
	types.Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
	types.True = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").True
	types.False = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").False
	types.Boolean = IMPORTS['nattlua.types.union']("nattlua.types.union").Boolean
end

return types end ]=======], '@./nattlua/types/types.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.base.upvalue"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local shallow_copy = IMPORTS['nattlua.other.shallow_copy']("nattlua.other.shallow_copy")
local mutation_solver = IMPORTS['nattlua.analyzer.mutation_solver']("nattlua.analyzer.mutation_solver")
local META = class.CreateTemplate("upvalue")
META:GetSet("Value")
META:GetSet("Hash")
META:GetSet("Key")
META:IsSet("Immutable")
META:GetSet("Node")
META:GetSet("Position")
META:GetSet("Shadow")
META:GetSet("Scope")
META:GetSet("Mutations")

function META:__tostring()
	return "[" .. tostring(self.key) .. ":" .. tostring(self.value) .. "]"
end

function META:SetValue(value)
	self.Value = value
	value:SetUpvalue(self)
end

do
	function META:GetMutatedValue(scope)
		self.Mutations = self.Mutations or {}
		return mutation_solver(shallow_copy(self.Mutations), scope, self)
	end

	function META:Mutate(val, scope, from_tracking)
		val:SetUpvalue(self)
		self.Mutations = self.Mutations or {}
		table.insert(self.Mutations, {scope = scope, value = val, from_tracking = from_tracking})

		if from_tracking then scope:AddTrackedObject(self) end
	end

	function META:ClearMutations()
		self.Mutations = nil
	end

	function META:HasMutations()
		return self.Mutations ~= nil
	end

	function META:ClearTrackedMutations()
		local mutations = self:GetMutations()

		for i = #mutations, 1, -1 do
			local mut = mutations[i]

			if mut.from_tracking then table.remove(mutations, i) end
		end
	end
end

local id = 0

function META.New(obj)
	local self = setmetatable({}, META)
	self:SetHash(tostring(id))
	id = id + 1
	self:SetValue(obj)
	return self
end

return META end ]=======], '@./nattlua/analyzer/base/upvalue.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.base.lexical_scope"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local pairs = pairs
local error = error
local tostring = tostring
local assert = assert
local setmetatable = setmetatable
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local table_insert = table.insert
local table = _G.table
local type = _G.type
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local Upvalue = IMPORTS['nattlua.analyzer.base.upvalue']("nattlua.analyzer.base.upvalue").New
local META = class.CreateTemplate("lexical_scope")

do
	function META:IsUncertain()
		return self:IsTruthy() and self:IsFalsy()
	end

	function META:IsCertain()
		return not self:IsUncertain()
	end

	function META:IsCertainlyFalse()
		return self:IsFalsy() and not self:IsTruthy()
	end

	function META:IsCertainlyTrue()
		return self:IsTruthy() and not self:IsFalsy()
	end

	META:IsSet("Falsy", false)
	META:IsSet("Truthy", false)
end

META:IsSet("ConditionalScope", false)
META:GetSet("Parent", nil)
META:GetSet("Children", nil)

function META:SetParent(parent)
	self.Parent = parent

	if parent then table_insert(parent:GetChildren(), self) end
end

function META:GetMemberInParents(what)
	local scope = self

	while true do
		if scope[what] then return scope[what], scope end

		scope = scope:GetParent()

		if not scope then break end
	end

	return nil
end

function META:AddTrackedObject(val)
	local scope = self:GetNearestFunctionScope()
	scope.TrackedObjects = scope.TrackedObjects or {}
	table.insert(scope.TrackedObjects, val)
end

function META:AddDependency(val)
	self.dependencies = self.dependencies or {}
	self.dependencies[val] = val
end

function META:GetDependencies()
	local out = {}

	if self.dependencies then
		for val in pairs(self.dependencies) do
			table.insert(out, val)
		end
	end

	return out
end

function META:FindUpvalue(key, env)
	if type(key) == "table" and key.Type == "string" and key:IsLiteral() then
		key = key:GetData()
	end

	local scope = self
	local prev_scope

	for _ = 1, 1000 do
		if not scope then return end

		local upvalue = scope.upvalues[env].map[key]

		if upvalue then
			local upvalue_position = prev_scope and prev_scope.upvalue_position

			if upvalue_position then
				if upvalue:GetPosition() >= upvalue_position then
					local upvalue = upvalue:GetShadow()

					while upvalue do
						if upvalue:GetPosition() <= upvalue_position then return upvalue end

						upvalue = upvalue:GetShadow()
					end
				end
			end

			return upvalue
		end

		prev_scope = scope
		scope = scope:GetParent()
	end

	error("this should never happen")
end

function META:CreateUpvalue(key, obj, env)
	local shadow

	if key ~= "..." and env == "runtime" then
		shadow = self.upvalues[env].map[key]
	end

	local upvalue = Upvalue(obj)
	upvalue:SetKey(key)
	upvalue:SetShadow(shadow)
	upvalue:SetPosition(#self.upvalues[env].list)
	upvalue:SetScope(self)
	table_insert(self.upvalues[env].list, upvalue)
	self.upvalues[env].map[key] = upvalue
	return upvalue
end

function META:GetUpvalues(type)
	return self.upvalues[type].list
end

function META:Copy()
	local copy = self.New()

	if self.upvalues.typesystem then
		for _, upvalue in ipairs(self.upvalues.typesystem.list) do
			copy:CreateUpvalue(upvalue.key, upvalue:GetValue(), "typesystem")
		end
	end

	if self.upvalues.runtime then
		for _, upvalue in ipairs(self.upvalues.runtime.list) do
			copy:CreateUpvalue(upvalue.key, upvalue:GetValue(), "runtime")
		end
	end

	copy.returns = self.returns
	copy:SetParent(self:GetParent())
	copy:SetConditionalScope(self:IsConditionalScope())
	return copy
end

META:GetSet("TrackedUpvalues")
META:GetSet("TrackedTables")

function META:TracksSameAs(scope, obj)
	local upvalues_a, tables_a = self:GetTrackedUpvalues(), self:GetTrackedTables()
	local upvalues_b, tables_b = scope:GetTrackedUpvalues(), scope:GetTrackedTables()

	if not upvalues_a or not upvalues_b then return false end

	if not tables_a or not tables_b then return false end

	for i, data_a in ipairs(upvalues_a) do
		for i, data_b in ipairs(upvalues_b) do
			if data_a.upvalue == data_b.upvalue then return true end
		end
	end

	for i, data_a in ipairs(tables_a) do
		for i, data_b in ipairs(tables_b) do
			if data_a.obj == data_b.obj and data_a.obj == obj then return true end
		end
	end

	return false
end

function META:FindResponsibleConditionalScopeFromUpvalue(upvalue)
	local scope = self

	while true do
		local upvalues = scope:GetTrackedUpvalues()

		if upvalues then
			for i, data in ipairs(upvalues) do
				if data.upvalue == upvalue then return scope, data end
			end
		end

		-- find in siblings too, if they have returned
		-- ideally when cloning a scope, the new scope should be 
		-- inside of the returned scope, then we wouldn't need this code
		for _, child in ipairs(scope:GetChildren()) do
			if child ~= scope and self:IsPartOfTestStatementAs(child) then
				local upvalues = child:GetTrackedUpvalues()

				if upvalues then
					for i, data in ipairs(upvalues) do
						if data.upvalue == upvalue then return child, data end
					end
				end
			end
		end

		scope = scope:GetParent()

		if not scope then return end
	end

	return nil
end

META:GetSet("PreviousConditionalSibling")
META:GetSet("NextConditionalSibling")
META:IsSet("ElseConditionalScope")
META:IsSet("LoopScope")

function META:SetStatement(statement)
	self.statement = statement
end

function META:SetLoopIteration(i)
	self.loop_iteration = i
end

function META:GetStatementType()
	return self.statement and self.statement.kind
end

function META.IsPartOfTestStatementAs(a, b)
	local yes = a:GetStatementType() == "if" and
		b:GetStatementType() == "if" and
		a.statement == b.statement

	if yes then
		local a_iteration = a:GetMemberInParents("loop_iteration")
		local b_iteration = b:GetMemberInParents("loop_iteration")
		return a_iteration == b_iteration
	end

	return yes
end

function META:FindFirstConditionalScope()
	local obj, scope = self:GetMemberInParents("ConditionalScope")
	return scope
end

function META:Contains(scope)
	if scope == self then return true end

	local parent = scope

	for i = 1, 1000 do
		if not parent then break end

		if parent == self then return true end

		parent = parent:GetParent()
	end

	return false
end

function META:GetRoot()
	local parent = self

	for i = 1, 1000 do
		if not parent:GetParent() then break end

		parent = parent:GetParent()
	end

	return parent
end

do
	function META:MakeFunctionScope(node)
		self.returns = {}
		self.node = node
	end

	function META:IsFunctionScope()
		return self.returns ~= nil
	end

	function META:CollectOutputSignatures(node, types)
		table.insert(self:GetNearestFunctionScope().returns, {node = node, types = types})
	end

	function META:DidCertainReturn()
		return self.certain_return ~= nil
	end

	function META:ClearCertainReturn()
		self.certain_return = nil
	end

	function META:CertainReturn()
		local scope = self

		while true do
			scope.certain_return = true

			if scope.returns then break end

			scope = scope:GetParent()

			if not scope then break end
		end
	end

	function META:UncertainReturn()
		self:GetNearestFunctionScope().uncertain_function_return = true
	end

	function META:GetNearestFunctionScope()
		local ok, scope = self:GetMemberInParents("returns")

		if ok then return scope end

		return self
	end

	function META:GetNearestLoopScope()
		local ok, scope = self:GetMemberInParents("LoopScope")

		if ok then return scope end

		return self
	end

	function META:GetOutputSignature()
		return self.returns
	end

	function META:ClearCertainOutputSignatures()
		self.returns = {}
	end

	function META:IsCertainFromScope(from)
		return not self:IsUncertainFromScope(from)
	end

	function META:IsUncertainFromScope(from)
		if from == self then return false end

		local scope = self

		if self:IsPartOfTestStatementAs(from) then return true end

		while true do
			if scope == from then break end

			if scope:IsFunctionScope() then
				if
					scope.node and
					scope.node:GetLastType() and
					scope.node:GetLastType().Type == "function" and
					not scope:Contains(from)
				then
					return not scope.node:GetLastType():IsCalled()
				end
			end

			if scope:IsTruthy() and scope:IsFalsy() then
				if scope:Contains(from) then return false end

				return true, scope
			end

			scope = scope:GetParent()

			if not scope then break end
		end

		return false
	end
end

function META:__tostring()
	local x = 1

	do
		local scope = self

		while scope:GetParent() do
			x = x + 1
			scope = scope:GetParent()
		end
	end

	local y = 1

	if self:GetParent() then
		for i, v in ipairs(self:GetParent():GetChildren()) do
			if v == self then
				y = i

				break
			end
		end
	end

	local s = "scope[" .. x .. "," .. y .. "]" .. "[" .. (
			self:IsUncertain() and
			"uncertain" or
			"certain"
		) .. "]"

	if self.node then s = s .. tostring(self.node) end

	return s
end

function META:DumpScope()
	local s = {}

	for i, v in ipairs(self.upvalues.runtime.list) do
		table.insert(s, "local " .. tostring(v.key) .. " = " .. tostring(v))
	end

	for i, v in ipairs(self.upvalues.typesystem.list) do
		table.insert(s, "local type " .. tostring(v.key) .. " = " .. tostring(v))
	end

	for i, v in ipairs(self:GetChildren()) do
		table.insert(s, "do\n" .. v:DumpScope() .. "\nend\n")
	end

	return table.concat(s, "\n")
end

local ref = 0

function META.New(parent, upvalue_position, obj)
	ref = ref + 1
	local scope = {
		obj = obj,
		ref = ref,
		Children = {},
		upvalue_position = upvalue_position,
		upvalues = {
			runtime = {
				list = {},
				map = {},
			},
			typesystem = {
				list = {},
				map = {},
			},
		},
	}
	setmetatable(scope, META)
	scope:SetParent(parent)
	return scope
end

return META end ]=======], '@./nattlua/analyzer/base/lexical_scope.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.base.scopes"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local type = type
local ipairs = ipairs
local tostring = tostring
local LexicalScope = IMPORTS['nattlua.analyzer.base.lexical_scope']("nattlua.analyzer.base.lexical_scope").New
local Table = IMPORTS['nattlua.types.table']("nattlua.types.table").Table
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local table = _G.table
return function(META)
	table.insert(META.OnInitialize, function(self)
		self.default_environment = {
			runtime = Table(),
			typesystem = Table(),
		}
		self.environments = {runtime = {}, typesystem = {}}
		self.scope_stack = {}
	end)

	function META:PushScope(scope)
		table.insert(self.scope_stack, self.scope)
		self.scope = scope
		return scope
	end

	function META:CreateAndPushFunctionScope(obj)
		return self:PushScope(LexicalScope(obj:GetScope() or self:GetScope(), obj:GetUpvaluePosition(), obj))
	end

	function META:CreateAndPushModuleScope()
		return self:PushScope(LexicalScope())
	end

	function META:CreateAndPushScope()
		return self:PushScope(LexicalScope(self:GetScope()))
	end

	function META:PopScope()
		local new = table.remove(self.scope_stack)
		local old = self.scope

		if new then self.scope = new end

		return old
	end

	function META:GetScope()
		return self.scope
	end

	function META:GetScopeStack()
		return self.scope_stack
	end

	function META:CloneCurrentScope()
		local scope_copy = self:GetScope():Copy(true)
		local g = self:GetGlobalEnvironment("runtime"):Copy()
		local last_node = self.environment_nodes[#self.environment_nodes]
		self:PopScope()
		self:PopGlobalEnvironment("runtime")
		scope_copy:SetParent(scope_copy:GetParent() or self:GetScope())
		self:PushGlobalEnvironment(last_node, g, "runtime")
		self:PushScope(scope_copy)

		for _, keyval in ipairs(g:GetData()) do
			self:MutateTable(g, keyval.key, keyval.val)
		end

		for _, upvalue in ipairs(scope_copy:GetUpvalues("runtime")) do
			self:MutateUpvalue(upvalue, upvalue:GetValue())
		end

		return scope_copy
	end

	function META:CreateLocalValue(key, obj, const)
		local upvalue = self:GetScope():CreateUpvalue(key, obj, self:GetCurrentAnalyzerEnvironment())
		self:MutateUpvalue(upvalue, obj)
		upvalue:SetImmutable(const)
		return upvalue
	end

	function META:FindLocalUpvalue(key, scope)
		scope = scope or self:GetScope()

		if not scope then return end

		return scope:FindUpvalue(key, self:GetCurrentAnalyzerEnvironment())
	end

	function META:GetLocalOrGlobalValue(key, scope)
		local upvalue = self:FindLocalUpvalue(key, scope)

		if upvalue then
			if self:IsRuntime() then
				return self:GetMutatedUpvalue(upvalue) or upvalue:GetValue()
			end

			return upvalue:GetValue()
		end

		-- look up in parent if not found
		if self:IsRuntime() then
			local g = self:GetGlobalEnvironment(self:GetCurrentAnalyzerEnvironment())
			local val, err = g:Get(key)

			if not val then
				self:PushAnalyzerEnvironment("typesystem")
				local val, err = self:GetLocalOrGlobalValue(key)
				self:PopAnalyzerEnvironment()
				return val, err
			end

			return self:IndexOperator(g, key)
		end

		return self:IndexOperator(self:GetGlobalEnvironment(self:GetCurrentAnalyzerEnvironment()), key)
	end

	function META:SetLocalOrGlobalValue(key, val, scope)
		local upvalue = self:FindLocalUpvalue(key, scope)

		if upvalue then
			if upvalue:IsImmutable() then
				return self:Error({"cannot assign to const variable ", key})
			end

			if not self:MutateUpvalue(upvalue, val) then upvalue:SetValue(val) end

			return upvalue
		end

		local g = self:GetGlobalEnvironment(self:GetCurrentAnalyzerEnvironment())

		if not g then
			self:FatalError("tried to set environment value outside of Push/Pop/Environment")
		end

		if self:IsRuntime() then self:Warning({"_G[\"", key, "\"] = ", val}) end

		self:Assert(self:NewIndexOperator(g, key, val))
		return val
	end

	do -- environment
		function META:SetEnvironmentOverride(node, obj, env)
			node.environments_override = node.environments_override or {}
			node.environments_override[env] = obj
		end

		function META:GetGlobalEnvironmentOverride(node, env)
			if node.environments_override then return node.environments_override[env] end
		end

		function META:SetDefaultEnvironment(obj, env)
			self.default_environment[env] = obj
		end

		function META:GetDefaultEnvironment(env)
			return self.default_environment[env]
		end

		function META:PushGlobalEnvironment(node, obj, env)
			table.insert(self.environments[env], 1, obj)
			node.environments = node.environments or {}
			node.environments[env] = obj
			self.environment_nodes = self.environment_nodes or {}
			table.insert(self.environment_nodes, 1, node)
		end

		function META:PopGlobalEnvironment(env)
			table.remove(self.environment_nodes, 1)
			table.remove(self.environments[env], 1)
		end

		function META:GetGlobalEnvironment(env)
			local g = self.environments[env][1] or self:GetDefaultEnvironment(env)

			if
				self.environment_nodes[1] and
				self.environment_nodes[1].environments_override and
				self.environment_nodes[1].environments_override[env]
			then
				g = self.environment_nodes[1].environments_override[env]
			end

			return g
		end
	end
end end ]=======], '@./nattlua/analyzer/base/scopes.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.base.error_handling"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local table = _G.table
local type = type
local ipairs = ipairs
local tostring = tostring
local io = io
local debug = debug
local error = error
local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
return function(META)
	

	table.insert(META.OnInitialize, function(self)
		self.diagnostics = {}
	end)

	function META:Assert(ok, err, ...)
		if ok == nil or ok == false then
			err = err or "assertion failed!"
			self:Error(err)
			return Any()
		end

		return ok, err, ...
	end

	function META:ErrorAssert(ok, err)
		if not ok then error(self:ErrorMessageToString(err or "assertion failed!")) end
	end

	function META:ErrorMessageToString(tbl)
		if type(tbl) == "string" then return tbl end

		local out = {}

		for i, v in ipairs(tbl) do
			if type(v) == "table" then
				if v.Type then
					table.insert(out, tostring(v))
				else
					table.insert(out, self:ErrorMessageToString(v))
				end
			else
				table.insert(out, tostring(v))
			end
		end

		return table.concat(out)
	end

	function META:ReportDiagnostic(
		msg,
		severity
	)
		if self.SuppressDiagnostics then return end

		local node = self.current_expression or self.current_statement

		if not msg or not severity then
			io.write("msg = ", tostring(msg), "\n")
			io.write("severity = ", tostring(severity), "\n")
			io.write(debug.traceback(), "\n")
			error("bad call to ReportDiagnostic")
		end

		local msg_str = self:ErrorMessageToString(msg)

		if
			self.expect_diagnostic and
			self.expect_diagnostic[1] and
			self.expect_diagnostic[1].severity == severity and
			msg_str:find(self.expect_diagnostic[1].msg)
		then
			table.remove(self.expect_diagnostic, 1)
			return
		end

		local key = msg_str .. "-" .. tostring(node) .. "-" .. "severity"
		self.diagnostics_map = self.diagnostics_map or {}

		if self.diagnostics_map[key] then return end

		self.diagnostics_map[key] = true
		severity = severity or "warning"
		local start, stop = node:GetStartStop()

		if self.OnDiagnostic and not self:IsTypeProtectedCall() then
			self:OnDiagnostic(node.Code, msg_str, severity, start, stop, node)
		end

		table.insert(
			self.diagnostics,
			{
				node = node,
				start = start,
				stop = stop,
				msg = msg_str,
				severity = severity,
				traceback = debug.traceback(),
				protected_call = self:IsTypeProtectedCall(),
			}
		)
	end

	function META:PushProtectedCall()
		self:PushContextRef("type_protected_call")
	end

	function META:PopProtectedCall()
		self:PopContextRef("type_protected_call")
	end

	function META:IsTypeProtectedCall()
		return self:GetContextRef("type_protected_call")
	end

	function META:Error(msg)
		return self:ReportDiagnostic(msg, "error")
	end

	function META:Warning(msg)
		return self:ReportDiagnostic(msg, "warning")
	end

	function META:FatalError(msg)
		error(msg, 2)
	end

	function META:GetDiagnostics()
		return self.diagnostics
	end
end end ]=======], '@./nattlua/analyzer/base/error_handling.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.base.base_analyzer"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local tonumber = tonumber
local ipairs = ipairs
local os = os
local print = print
local pairs = pairs
local setmetatable = setmetatable
local pcall = pcall
local tostring = tostring
local debug = debug
local io = io
local load = loadstring or load
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local context = IMPORTS['nattlua.analyzer.context']("nattlua.analyzer.context")
local table = _G.table
local math = _G.math
return function(META)
	IMPORTS['nattlua.analyzer.base.scopes']("nattlua.analyzer.base.scopes")(META)
	IMPORTS['nattlua.analyzer.base.error_handling']("nattlua.analyzer.base.error_handling")(META)

	function META:AnalyzeRootStatement(statement, a, b, c, d, e, f)
		context:PushCurrentAnalyzer(self)
		local argument_tuple = a and
			Tuple({a, b, c, d, e, f}) or
			Tuple({a, b, c, d, e, f}):AddRemainder(Tuple({Any()}):SetRepeat(math.huge))
		self:CreateAndPushModuleScope()
		self:PushGlobalEnvironment(statement, self:GetDefaultEnvironment("runtime"), "runtime")
		self:PushGlobalEnvironment(statement, self:GetDefaultEnvironment("typesystem"), "typesystem")
		local g = self:GetGlobalEnvironment("typesystem")
		g:Set(LString("_G"), g)
		self:PushAnalyzerEnvironment("runtime")
		self:CreateLocalValue("...", argument_tuple)
		local analyzed_return = self:AnalyzeStatementsAndCollectOutputSignatures(statement)
		self:PopAnalyzerEnvironment()
		self:PopGlobalEnvironment("runtime")
		self:PopGlobalEnvironment("typesystem")
		self:PopScope()
		context:PopCurrentAnalyzer()
		return analyzed_return
	end

	function META:AnalyzeExpressions(expressions)
		if not expressions then return end

		local out = {}

		for _, expression in ipairs(expressions) do
			local obj = self:AnalyzeExpression(expression)

			if obj and obj.Type == "tuple" and obj:GetLength() == 1 then
				obj = obj:Get(1)
			end

			table.insert(out, obj)
		end

		return out
	end

	do
		local function add_potential_self(tup)
			local tbl = tup:Get(1)

			if tbl and tbl.Type == "union" then tbl = tbl:GetType("table") end

			if not tbl then return tup end

			if tbl.Self then
				local self = tbl.Self
				local new_tup = Tuple({})

				for i, obj in ipairs(tup:GetData()) do
					if i == 1 then
						new_tup:Set(i, self)
					else
						new_tup:Set(i, obj)
					end
				end

				return new_tup
			elseif tbl.potential_self then
				local meta = tbl
				local self = tbl.potential_self:Copy()

				if self.Type == "union" then
					for _, obj in ipairs(self:GetData()) do
						obj:SetMetaTable(meta)
					end
				else
					self:SetMetaTable(meta)
				end

				local new_tup = Tuple({})

				for i, obj in ipairs(tup:GetData()) do
					if i == 1 then
						new_tup:Set(i, self)
					else
						new_tup:Set(i, obj)
					end
				end

				return new_tup
			end

			return tup
		end

		local function call(self, obj)
			-- use function's arguments in case they have been maniupulated (ie string.gsub)
			local arguments = obj:GetInputSignature():Copy()
			arguments = add_potential_self(arguments)

			for _, obj in ipairs(arguments:GetData()) do
				self:ClearObjectMutations(obj)
			end

			self:CreateAndPushFunctionScope(obj)
			self:Assert(self:Call(obj, arguments, obj:GetFunctionBodyNode()))
			self:PopScope()
		end

		function META:AddToUnreachableCodeAnalysis(obj)
			self.deferred_calls = self.deferred_calls or {}
			table.insert(self.deferred_calls, 1, obj)
		end

		function META:AnalyzeUnreachableCode()
			if not self.deferred_calls then return end

			context:PushCurrentAnalyzer(self)
			local total = #self.deferred_calls
			self.processing_deferred_calls = true
			local called_count = 0
			local done = {}

			for _, func in ipairs(self.deferred_calls) do
				if
					func:IsExplicitInputSignature() and
					not func:IsCalled()
					and
					not done[func]
				then
					call(self, func)
					called_count = called_count + 1
					done[func] = true
					func:SetCalled()
				end
			end

			for _, func in ipairs(self.deferred_calls) do
				if
					not func:IsExplicitInputSignature() and
					not func:IsCalled()
					and
					not done[func]
				then
					call(self, func)
					called_count = called_count + 1
					done[func] = true
					func:SetCalled()
				end
			end

			self.processing_deferred_calls = false
			self.deferred_calls = nil
			context:PopCurrentAnalyzer()
		end
	end

	do
		local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
		local loadstring = IMPORTS['nattlua.other.loadstring']("nattlua.other.loadstring")
		local locals = ""
		locals = locals .. "local bit=bit32 or _G.bit;"

		if _G.BUNDLE then
			locals = locals .. "local nl=IMPORTS[\"nattlua.init\"]();"
			locals = locals .. "local types=IMPORTS[\"nattlua.types.types\"]();"
			locals = locals .. "local context=IMPORTS[\"nattlua.analyzer.context\"]();"
		else
			locals = locals .. "local nl=require(\"nattlua.init\");"
			locals = locals .. "local types=require(\"nattlua.types.types\");"
			locals = locals .. "local context=require(\"nattlua.analyzer.context\");"
		end

		local globals = {
			"loadstring",
			"dofile",
			"gcinfo",
			"collectgarbage",
			"newproxy",
			"print",
			"_VERSION",
			"coroutine",
			"debug",
			"package",
			"os",
			"bit",
			"_G",
			"module",
			"require",
			"assert",
			"string",
			"arg",
			"jit",
			"math",
			"table",
			"io",
			"type",
			"next",
			"pairs",
			"ipairs",
			"getmetatable",
			"setmetatable",
			"getfenv",
			"setfenv",
			"rawget",
			"rawset",
			"rawequal",
			"unpack",
			"select",
			"tonumber",
			"tostring",
			"error",
			"pcall",
			"xpcall",
			"loadfile",
			"load",
		}

		for _, key in ipairs(globals) do
			locals = locals .. "local " .. tostring(key) .. "=_G." .. key .. ";"
		end

		local runtime_injection = [[
			local analyzer = assert(context:GetCurrentAnalyzer(), "no analyzer in context")
			local env = analyzer:GetScopeHelper(analyzer.function_scope)
		]]
		runtime_injection = runtime_injection:gsub("\n", ";")

		function META:CompileLuaAnalyzerDebugCode(code, node)
			local start, stop = code:find("^.-function %b()")

			if start and stop then
				local before_function = code:sub(1, stop)
				local after_function = code:sub(stop + 1, #code)
				code = before_function .. runtime_injection .. after_function
			else
				code = runtime_injection .. code
			end

			code = locals .. code
			-- append newlines so that potential line errors are correct
			local lua_code = node.Code:GetString()
			local line

			if lua_code then
				local start, stop = node:GetStartStop()
				line = helpers.SubPositionToLinePosition(lua_code, start, stop).line_start
				code = ("\n"):rep(line - 1) .. code
			end

			local func, err = loadstring(code, node.Code:GetName() .. ":" .. line)

			if not func then
				print("========================")
				print(func, err, node.Code:GetName(), code)
				print(node)
				print("=============NODE===========")

				for k, v in pairs(node) do
					print(k, v)
				end

				print("============TOKENS===========")

				for k, v in pairs(node.tokens) do
					print(k, v, v.value)
				end

				print("===============>=================")
				self:FatalError(err)
				return false, err
			end

			return func
		end

		function META:CallLuaTypeFunction(func, scope, ...)
			self.function_scope = scope
			local res = {pcall(func, ...)}
			local ok = table.remove(res, 1)

			if not ok then
				local msg = tostring(res[1])
				local name = debug.getinfo(func).source

				if name:sub(1, 1) == "@" then -- is this a name that is a location?
					local line, rest = msg:sub(#name):match("^:(%d+):(.+)") -- remove the file name and grab the line number
					if line then
						local f, err = io.open(name:sub(2), "r")

						if f then
							local code = f:read("*all")
							f:close()
							local start = helpers.LinePositionToSubPosition(code, tonumber(line), 0)
							local stop = start + #(code:sub(start):match("(.-)\n") or "") - 1
							msg = self.current_expression.Code:BuildSourceCodePointMessage(rest, start, stop)
						end
					end
				end

				local frame = self:GetCallStack()[1]

				if frame then
					self.current_expression = self:GetCallStack()[1].call_node
				end

				self:Error(msg)
			end

			if res[1] == nil then res[1] = Nil() end

			return table.unpack(res)
		end

		do
			local scope_meta = {}

			function scope_meta:__index(key)
				self.analyzer:PushAnalyzerEnvironment(self.env)
				local val = self.analyzer:GetLocalOrGlobalValue(LString(key), self.scope)
				self.analyzer:PopAnalyzerEnvironment()
				return val
			end

			function scope_meta:__newindex(key, val)
				self.analyzer:PushAnalyzerEnvironment(self.env)
				self.analyzer:SetLocalOrGlobalValue(LString(key), LString(val), self.scope)
				self.analyzer:PopAnalyzerEnvironment()
			end

			function META:GetScopeHelper(scope)
				scope.scope_helper = scope.scope_helper or
					{
						typesystem = setmetatable(
							{
								analyzer = self,
								scope = scope,
								env = "typesystem",
							},
							scope_meta
						),
						runtime = setmetatable({analyzer = self, scope = scope, env = "runtime"}, scope_meta),
					}
				return scope.scope_helper
			end

			function META:CallTypesystemUpvalue(name, a, b, c, d, e, f)
				-- this is very internal-ish code
				-- not sure what a nice interface for this really should be yet
				self:PushAnalyzerEnvironment("typesystem")
				local generics_func = self:GetLocalOrGlobalValue(name)
				assert(generics_func.Type == "function", "cannot find typesystem function " .. name:GetData())
				local argument_tuple = Tuple({a, b, c, d, e, f})
				local returned_tuple = assert(self:Call(generics_func, argument_tuple))
				self:PopAnalyzerEnvironment()
				return returned_tuple:Unpack()
			end
		end

		function META:TypeTraceback(from)
			local str = ""

			for i, v in ipairs(self:GetCallStack()) do
				if v.call_node and (not from or i > from) then
					local start, stop = v.call_node:GetStartStop()

					if start and stop then
						local part = self.compiler:GetCode():BuildSourceCodePointMessage("", start, stop, 1)
						str = str .. part .. "#" .. tostring(i) .. ": " .. self.compiler:GetCode():GetName()
					end
				end
			end

			return str
		end

		local function attempt_render(node)
			local s = ""
			local ok, err = xpcall(function()
				s = s .. node:Render()
			end, function(err)
				print(debug.traceback(err))
			end)

			if not ok then s = "* error in rendering statement * " end

			return s
		end

		function META:DebugStateToString()
			local s = ""

			if self.current_statement and self.current_statement.Render then
				s = s .. "======== statement =======\n"
				s = s .. attempt_render(self.current_statement)
				s = s .. "==========================\n"
			end

			if self.current_expression and self.current_expression.Render then
				s = s .. "======== expression =======\n"
				s = s .. attempt_render(self.current_expression)
				s = s .. "===========================\n"
			end

			pcall(function()
				s = s .. self:TypeTraceback()
			end)

			return s
		end

		function META:ResolvePath(path)
			return path
		end

		do
			function META:PushContextValue(key, value)
				self.context_values[key] = self.context_values[key] or {}
				table.insert(self.context_values[key], 1, value)
			end

			function META:GetContextValue(key, level)
				return self.context_values[key] and self.context_values[key][level or 1]
			end

			function META:PopContextValue(key)
				return table.remove(self.context_values[key], 1)
			end
		end

		do
			function META:PushContextRef(key)
				self.context_ref[key] = (self.context_ref[key] or 0) + 1
			end

			function META:GetContextRef(key)
				return self.context_ref[key] and self.context_ref[key] > 0
			end

			function META:PopContextRef(key)
				self.context_ref[key] = (self.context_ref[key] or 0) - 1
			end
		end

		do
			function META:GetCurrentAnalyzerEnvironment()
				return self:GetContextValue("analyzer_environment") or "runtime"
			end

			function META:PushAnalyzerEnvironment(env)
				self:PushContextValue("analyzer_environment", env)
			end

			function META:PopAnalyzerEnvironment()
				self:PopContextValue("analyzer_environment")
			end

			function META:IsTypesystem()
				return self:GetCurrentAnalyzerEnvironment() == "typesystem"
			end

			function META:IsRuntime()
				return self:GetCurrentAnalyzerEnvironment() == "runtime"
			end
		end

		do
			function META:IsInUncertainLoop(scope)
				scope = scope or self:GetScope():GetNearestLoopScope()
				return self:GetContextValue("uncertain_loop") == scope:GetNearestLoopScope()
			end

			function META:PushUncertainLoop(b)
				return self:PushContextValue("uncertain_loop", b and self:GetScope():GetNearestLoopScope())
			end

			function META:PopUncertainLoop()
				return self:PopContextValue("uncertain_loop")
			end
		end

		do
			function META:PushCurrentType(obj, type)
				self:PushContextValue("current_type_" .. type, obj)
			end

			function META:PopCurrentType(type)
				self:PopContextValue("current_type_" .. type)
			end

			function META:GetCurrentType(type, offset)
				return self:GetContextValue("current_type_" .. type, offset)
			end
		end
	end
end end ]=======], '@./nattlua/analyzer/base/base_analyzer.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.control_flow"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
-- this turns out to be really hard so I'm trying 
-- naive approaches while writing tests
return function(META)
	function META:AnalyzeStatements(statements)
		for _, statement in ipairs(statements) do
			self:AnalyzeStatement(statement)

			if self:DidCertainBreak() then break end

			if self._continue_ then return end

			if self:GetScope():DidCertainReturn() then
				self:GetScope():ClearCertainReturn()
				return
			end
		end

		if self:GetScope().uncertain_function_return == nil then
			self:GetScope().uncertain_function_return = false
		end

		if statements[1] then
			self:GetScope().missing_return = statements[#statements].kind ~= "return"
		else
			self:GetScope().missing_return = true
		end
	end

	function META:Break()
		local scope = self:GetScope()
		self.break_out_scope = scope
		self:ApplyMutationsAfterReturn(
			scope,
			scope:GetNearestFunctionScope(),
			true,
			scope:GetTrackedUpvalues(),
			scope:GetTrackedTables()
		)
	end

	function META:DidCertainBreak()
		return self.break_out_scope and self.break_out_scope:IsCertain()
	end

	function META:DidUncertainBreak()
		return self.break_out_scope and self.break_out_scope:IsUncertain()
	end

	function META:ClearBreak()
		self.break_out_scope = nil
	end

	function META:AnalyzeStatementsAndCollectOutputSignatures(statement)
		local scope = self:GetScope()
		scope:MakeFunctionScope(statement)
		self:AnalyzeStatements(statement.statements)

		if scope.missing_return and self:IsMaybeReachable() then
			self:Return(statement, {Nil()})
		end

		local union = Union({})

		for _, ret in ipairs(scope:GetOutputSignature()) do
			if #ret.types == 1 then
				union:AddType(ret.types[1])
			elseif #ret.types == 0 then
				local tup = Tuple({Nil()})
				union:AddType(tup)
			else
				local tup = Tuple(ret.types)
				union:AddType(tup)
			end
		end

		scope:ClearCertainOutputSignatures()

		if #union:GetData() == 1 then return union:GetData()[1] end

		return union
	end

	function META:ThrowSilentError(assert_expression)
		if assert_expression and assert_expression:IsCertainlyTrue() then return end

		for _, frame in ipairs(self:GetCallStack()) do
			local function_scope = frame.scope:GetNearestFunctionScope()

			if not assert_expression or assert_expression:IsCertainlyTrue() then
				function_scope.lua_silent_error = function_scope.lua_silent_error or {}
				table.insert(function_scope.lua_silent_error, 1, self:GetScope())
				frame.scope:UncertainReturn()
			end

			if assert_expression and assert_expression:IsTruthy() then
				-- track the assertion expression
				local upvalues

				if frame.scope:GetTrackedUpvalues() then
					upvalues = {}

					for _, a in ipairs(frame.scope:GetTrackedUpvalues()) do
						for _, b in ipairs(self:GetTrackedUpvalues()) do
							if a.upvalue == b.upvalue then table.insert(upvalues, a) end
						end
					end
				end

				local tables

				if frame.scope:GetTrackedTables() then
					tables = {}

					for _, a in ipairs(frame.scope:GetTrackedTables()) do
						for _, b in ipairs(self:GetTrackedTables()) do
							if a.obj == b.obj then table.insert(tables, a) end
						end
					end
				end

				self:ApplyMutationsAfterReturn(frame.scope, frame.scope, true, upvalues, tables)
				return
			end

			self:ApplyMutationsAfterReturn(
				frame.scope,
				function_scope,
				true,
				frame.scope:GetTrackedUpvalues(),
				frame.scope:GetTrackedTables()
			)
		end
	end

	function META:AssertError(obj, msg, level, no_report)
		-- track "if x then" which has no binary or prefix operators
		if obj.Type == "union" then
			self:TrackUpvalueUnion(obj, obj:GetTruthy(), obj:GetFalsy())
		else
			self:TrackUpvalue(obj)
		end

		self.lua_assert_error_thrown = {
			msg = msg,
			obj = obj,
		}

		if obj:IsTruthy() then
			self:GetScope():UncertainReturn()
		else
			self:GetScope():CertainReturn()
		end

		local old = {}

		for i, upvalue in ipairs(self:GetScope().upvalues.runtime.list) do
			old[i] = upvalue
		end

		self:ApplyMutationsAfterReturn(
			self:GetScope(),
			self:GetScope():GetNearestFunctionScope(),
			false,
			self:GetTrackedUpvalues(old),
			self:GetTrackedTables()
		)

		if not no_report then
			self.current_expression = self:GetCallFrame(level).call_node
			self:Error(msg)
		end
	end

	function META:ThrowError(msg, obj, level)
		self.lua_error_thrown = msg
		self.current_expression = self:GetCallFrame(level).call_node
		self:Error(msg)
	end

	function META:GetThrownErrorMessage()
		return self.lua_error_thrown or
			self.lua_assert_error_thrown and
			self.lua_assert_error_thrown.msg
	end

	function META:ClearError()
		self.lua_error_thrown = nil
		self.lua_assert_error_thrown = nil
	end

	function META:Return(node, types)
		local scope = self:GetScope()
		local function_scope = scope:GetNearestFunctionScope()

		if scope == function_scope then
			-- the root scope of the function when being called is definetly certain
			function_scope.uncertain_function_return = false
		elseif scope:IsUncertain() then
			function_scope.uncertain_function_return = true

			-- else always hits, so even if the else part is uncertain
			-- it does mean that this function at least returns something
			if scope:IsElseConditionalScope() then
				function_scope.uncertain_function_return = false
				function_scope:CertainReturn()
			end
		elseif function_scope.uncertain_function_return then
			function_scope.uncertain_function_return = false
		end

		local thrown = false

		if function_scope.lua_silent_error then
			local errored_scope = table.remove(function_scope.lua_silent_error)

			if
				errored_scope and
				self:GetScope():IsCertainFromScope(errored_scope) and
				errored_scope:IsCertain()
			then
				thrown = true
			end
		end

		if not thrown then
			scope:CollectOutputSignatures(node, types)
		else
			scope.throws = true
		end

		if scope:IsUncertain() then
			function_scope:UncertainReturn()
			scope:UncertainReturn()
		else
			function_scope:CertainReturn(self)
			scope:CertainReturn(self)
		end

		self:ApplyMutationsAfterReturn(scope, function_scope, true, scope:GetTrackedUpvalues(), scope:GetTrackedTables())
	end

	do
		function META:GetCallStack()
			return self.call_stack or {}
		end

		function META:GetCallFrame(level)
			local stack = self:GetCallStack()
			local frame = level and stack[#stack - level] or stack[#stack]
			return frame
		end

		function META:PushCallFrame(obj, call_node, not_recursive_call)
			-- setup and track the callstack to avoid infinite loops or callstacks that are too big
			self.call_stack = self.call_stack or {}

			if
				self:IsRuntime() and
				call_node and
				not not_recursive_call and
				not obj:IsRefFunction()
			then
				for _, v in ipairs(self.call_stack) do
					-- if the callnode is the same, we're doing some infinite recursion
					if v.call_node == call_node then
						if obj:IsExplicitOutputSignature() then
							-- so if we have explicit return types, just return those
							obj.recursively_called = obj:GetOutputSignature():Copy()
							return obj.recursively_called
						else
							-- if not we sadly have to resort to any
							-- TODO: error?
							obj.recursively_called = Tuple({}):AddRemainder(Tuple({Any()}):SetRepeat(math.huge))
							return obj.recursively_called
						end
					end
				end
			end

			table.insert(
				self.call_stack,
				1,
				{
					obj = obj,
					call_node = call_node,
					scope = self:GetScope(),
				}
			)
		--[[for i, frame in ipairs(self.call_stack) do
				print(("\t"):rep(i - 1) .. tostring(frame.call_node))
				print(("\t"):rep(i - 1) .. tostring(frame.obj:GetFunctionBodyNode() or frame.obj))
			end[[]] end

		function META:PopCallFrame()
			table.remove(self.call_stack, 1)
		end
	end

	function META:IsDefinetlyReachable()
		local scope = self:GetScope()
		local function_scope = scope:GetNearestFunctionScope()

		if not scope:IsCertain() then return false, "scope is uncertain" end

		if function_scope.uncertain_function_return == true then
			return false, "uncertain function return"
		end

		if function_scope.lua_silent_error then
			for _, scope in ipairs(function_scope.lua_silent_error) do
				if not scope:IsCertain() then
					return false, "parent function scope can throw an error"
				end
			end
		end

		for _, frame in ipairs(self:GetCallStack()) do
			local scope = frame.scope

			if not scope:IsCertain() then
				return false, "call stack scope is uncertain"
			end

			if scope.uncertain_function_return == true then
				return false, "call stack scope has uncertain function return"
			end
		end

		return true
	end

	function META:IsMaybeReachable()
		local scope = self:GetScope()
		local function_scope = scope:GetNearestFunctionScope()

		if function_scope.lua_silent_error then
			for _, scope in ipairs(function_scope.lua_silent_error) do
				if not scope:IsCertain() then return false end
			end
		end

		for _, frame in ipairs(self:GetCallStack()) do
			local parent_scope = frame.scope

			if parent_scope.uncertain_function_return then return true end

			if not parent_scope:IsCertain() and parent_scope:IsCertainFromScope(scope) then
				return false
			end
		end

		return true
	end

	function META:UncertainReturn()
		self.call_stack[1].scope:UncertainReturn()
	end

	function META:Print(...)
		local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
		local node = self.current_expression
		local start, stop = node:GetStartStop()

		do
			local node = self.current_statement
			local start2, stop2 = node:GetStartStop()

			if start2 > start then
				start = start2
				stop = stop2
			end
		end

		local str = {}

		for i = 1, select("#", ...) do
			str[i] = tostring(select(i, ...))
		end

		print(node.Code:BuildSourceCodePointMessage(table.concat(str, ", "), start, stop, 1))
	end

	function META:PushConditionalScope(statement, truthy, falsy)
		local scope = self:CreateAndPushScope()
		scope:SetConditionalScope(true)
		scope:SetStatement(statement)
		scope:SetTruthy(truthy)
		scope:SetFalsy(falsy)
		return scope
	end

	function META:ErrorAndCloneCurrentScope(err)
		self:Error(err)
		self:CloneCurrentScope()
		self:GetScope():SetConditionalScope(true)
	end

	function META:PopConditionalScope()
		self:PopScope()
	end
end end ]=======], '@./nattlua/analyzer/control_flow.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.mutation_tracking"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local table = _G.table
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local shallow_copy = IMPORTS['nattlua.other.shallow_copy']("nattlua.other.shallow_copy")
return function(META)
	function META:GetMutatedTableValue(tbl, key)
		if tbl.Type ~= "table" then return end

		return tbl:GetMutatedValue(key, self:GetScope())
	end

	function META:MutateTable(tbl, key, val, scope_override, from_tracking)
		if tbl.Type ~= "table" then return end

		local scope = scope_override or self:GetScope()

		if self:IsInUncertainLoop(scope) then
			if val.dont_widen then
				val = val:Copy()
			else
				val = val:Copy():Widen()
			end
		end

		tbl:Mutate(key, val, scope, from_tracking)
	end

	function META:GetMutatedUpvalue(upvalue)
		return upvalue:GetMutatedValue(self:GetScope())
	end

	function META:MutateUpvalue(upvalue, val, scope_override, from_tracking)
		local scope = scope_override or self:GetScope()

		if self:IsInUncertainLoop(scope) and upvalue:GetScope() then
			if val.dont_widen or scope:Contains(upvalue:GetScope()) then
				val = val:Copy()
			else
				val = val:Copy():Widen()
			end
		end

		upvalue:Mutate(val, scope, from_tracking)
	end

	function META:ClearObjectMutations(obj)
		if obj.Type ~= "table" and not obj.Type ~= "upvalue" then return end

		obj:ClearMutations()
	end

	function META:HasMutations(obj)
		if obj.Type ~= "table" and not obj.Type ~= "upvalue" then return false end

		return obj:HasMutations()
	end

	function META:ClearScopedTrackedObjects(scope)
		if scope.TrackedObjects then
			for _, obj in ipairs(scope.TrackedObjects) do
				if obj.Type == "upvalue" then
					obj:ClearTrackedMutations()
				elseif obj.mutations then
					for _, mutations in pairs(obj.mutations) do
						for i = #mutations, 1, -1 do
							local mut = mutations[i]

							if mut.from_tracking then table.remove(mutations, i) end
						end
					end
				end
			end
		end
	end

	do
		do
			function META:PushTruthyExpressionContext(b)
				self:PushContextValue("truthy_expression_context", b)
			end

			function META:PopTruthyExpressionContext()
				self:PopContextValue("truthy_expression_context")
			end

			function META:IsTruthyExpressionContext()
				return self:GetContextValue("truthy_expression_context") == true
			end
		end

		do
			function META:PushFalsyExpressionContext(b)
				self:PushContextValue("falsy_expression_context", b)
			end

			function META:PopFalsyExpressionContext()
				self:PopContextValue("falsy_expression_context")
			end

			function META:IsFalsyExpressionContext()
				return self:GetContextValue("falsy_expression_context") == true
			end
		end

		do
			function META:TrackUpvalue(obj)
				local upvalue = obj:GetUpvalue()

				if not upvalue then return end

				self.tracked_upvalues = self.tracked_upvalues or {}
				self.tracked_upvalues_done = self.tracked_upvalues_done or {}

				if not self.tracked_upvalues_done[upvalue] then
					table.insert(self.tracked_upvalues, upvalue)
					self.tracked_upvalues_done[upvalue] = true
				end
			end

			function META:TrackUpvalueUnion(obj, truthy_union, falsy_union, inverted)
				local upvalue = obj:GetUpvalue()

				if not upvalue then return end

				upvalue.tracked_stack = upvalue.tracked_stack or {}
				table.insert(
					upvalue.tracked_stack,
					{
						truthy = truthy_union,
						falsy = falsy_union,
						inverted = inverted,
					}
				)
				self:TrackUpvalue(obj)
			end

			function META:TrackUpvalueNonUnion(obj)
				local upvalue = obj:GetUpvalue()

				if not upvalue then return end

				self.tracked_upvalues = self.tracked_upvalues or {}
				self.tracked_upvalues_done = self.tracked_upvalues_done or {}

				if not self.tracked_upvalues_done[upvalue] then
					table.insert(self.tracked_upvalues, upvalue)
					self.tracked_upvalues_done[upvalue] = true
				end
			end

			function META:GetTrackedUpvalue(obj)
				local upvalue = obj:GetUpvalue()
				local stack = upvalue and upvalue.tracked_stack

				if not stack then return end

				if self:IsTruthyExpressionContext() then
					return stack[#stack].truthy:SetUpvalue(upvalue)
				elseif self:IsFalsyExpressionContext() then
					local union = stack[#stack].falsy

					if union:GetLength() == 0 then
						union = Union()

						for _, val in ipairs(stack) do
							union:AddType(val.falsy)
						end
					end

					union:SetUpvalue(upvalue)
					return union
				end
			end

			function META:GetTrackedUpvalues(old_upvalues)
				local upvalues = {}
				local translate = {}

				if old_upvalues then
					for i, upvalue in ipairs(self:GetScope().upvalues.runtime.list) do
						local old = old_upvalues[i]
						translate[old] = upvalue
						upvalue.tracked_stack = old.tracked_stack
					end
				end

				if self.tracked_upvalues then
					for _, upvalue in ipairs(self.tracked_upvalues) do
						local stack = upvalue.tracked_stack

						if old_upvalues then upvalue = translate[upvalue] end

						table.insert(upvalues, {upvalue = upvalue, stack = stack and shallow_copy(stack)})
					end
				end

				return upvalues
			end

			function META:ClearTrackedUpvalues()
				if self.tracked_upvalues then
					for _, upvalue in ipairs(self.tracked_upvalues) do
						upvalue.tracked_stack = nil
					end

					self.tracked_upvalues_done = nil
					self.tracked_upvalues = nil
				end
			end
		end

		do
			function META:TrackTableIndex(tbl, key, val)
				local hash = key:GetHash()

				if not hash then return end

				val.parent_table = tbl
				val.parent_key = key
				local truthy_union = val:GetTruthy()
				local falsy_union = val:GetFalsy()
				self:TrackTableIndexUnion(tbl, key, truthy_union, falsy_union, self.inverted_index_tracking, true)
			end

			function META:TrackTableIndexUnion(tbl, key, truthy_union, falsy_union, inverted, truthy_falsy)
				local hash = key:GetHash()

				if not hash then return end

				tbl.tracked_stack = tbl.tracked_stack or {}
				tbl.tracked_stack[hash] = tbl.tracked_stack[hash] or {}

				if falsy_union then
					falsy_union.parent_table = tbl
					falsy_union.parent_key = key
				end

				if truthy_union then
					truthy_union.parent_table = tbl
					truthy_union.parent_key = key
				end

				for i = #tbl.tracked_stack[hash], 1, -1 do
					local tracked = tbl.tracked_stack[hash][i]

					if tracked.truthy_falsy then
						table.remove(tbl.tracked_stack[hash], i)
					end
				end

				table.insert(
					tbl.tracked_stack[hash],
					{
						contract = tbl:GetContract(),
						key = key,
						truthy = truthy_union,
						falsy = falsy_union,
						inverted = inverted,
						truthy_falsy = truthy_falsy,
					}
				)
				self.tracked_tables = self.tracked_tables or {}
				self.tracked_tables_done = self.tracked_tables_done or {}

				if not self.tracked_tables_done[tbl] then
					table.insert(self.tracked_tables, tbl)
					self.tracked_tables_done[tbl] = true
				end
			end

			function META:GetTrackedTableWithKey(tbl, key)
				if not tbl.tracked_stack then return end

				local hash = key:GetHash()

				if not hash then return end

				local stack = tbl.tracked_stack[hash]

				if not stack then return end

				if self:IsTruthyExpressionContext() then
					return stack[#stack].truthy
				elseif self:IsFalsyExpressionContext() then
					return stack[#stack].falsy
				end
			end

			function META:GetTrackedTables()
				local tables = {}

				if self.tracked_tables then
					for _, tbl in ipairs(self.tracked_tables) do
						if tbl.tracked_stack then
							for _, stack in pairs(tbl.tracked_stack) do
								table.insert(
									tables,
									{
										obj = tbl,
										key = stack[#stack].key,
										stack = shallow_copy(stack),
									}
								)
							end
						end
					end
				end

				return tables
			end

			function META:ClearTrackedTables()
				if self.tracked_tables then
					for _, tbl in ipairs(self.tracked_tables) do
						tbl.tracked_stack = nil
					end

					self.tracked_tables_done = nil
					self.tracked_tables = nil
				end
			end
		end

		function META:ClearTracked()
			self:ClearTrackedUpvalues()
			self:ClearTrackedTables()
		end

		--[[
			local x: 1 | 2 | 3

			if x == 1 then
				assert(x == 1)
			end
		]] function META:ApplyMutationsInIf(upvalues, tables)
			if upvalues then
				for _, data in ipairs(upvalues) do
					if data.stack then
						local union = Union()

						for _, v in ipairs(data.stack) do
							if v.truthy then union:AddType(v.truthy) end
						end

						if not union:IsEmpty() then
							union:SetUpvalue(data.upvalue)
							self:MutateUpvalue(data.upvalue, union, nil, true)
						end
					end
				end
			end

			if tables then
				for _, data in ipairs(tables) do
					local union = Union()

					for _, v in ipairs(data.stack) do
						if v.truthy then union:AddType(v.truthy) end
					end

					if not union:IsEmpty() then
						self:MutateTable(data.obj, data.key, union, nil, true)
					end
				end
			end
		end

		--[[
			local x: 1 | 2 | 3

			if x == 1 then
			else
				-- we get the original value and remove the truthy values (x == 1) and end up with 2 | 3
				assert(x == 2 | 3)
			end
		]] function META:ApplyMutationsInIfElse(blocks)
			for i, block in ipairs(blocks) do
				if block.upvalues then
					for _, data in ipairs(block.upvalues) do
						if data.stack then
							local union = self:GetMutatedUpvalue(data.upvalue)

							if union.Type == "union" then
								for _, v in ipairs(data.stack) do
									union:RemoveType(v.truthy)
								end

								union:SetUpvalue(data.upvalue)
							end

							self:MutateUpvalue(data.upvalue, union, nil, true)
						end
					end
				end

				if block.tables then
					for _, data in ipairs(block.tables) do
						local union = self:GetMutatedTableValue(data.obj, data.key)

						if union then
							if union.Type == "union" then
								for _, v in ipairs(data.stack) do
									union:RemoveType(v.truthy)
								end
							end

							self:MutateTable(data.obj, data.key, union, nil, true)
						end
					end
				end
			end
		end

		--[[
			local x: 1 | 2 | 3

			if x == 1 then return end

			assert(x == 2 | 3)
		]] --[[
			local x: 1 | 2 | 3

			if x == 1 then else return end

			assert(x == 1)
		]] --[[
			local x: 1 | 2 | 3

			if x == 1 then error("!") end

			assert(x == 2 | 3)
		]] local function solve(data, scope, negate)
			local stack = data.stack

			if stack then
				local val

				if negate and not (scope:IsElseConditionalScope() or stack[#stack].inverted) then
					val = stack[#stack].falsy
				else
					val = stack[#stack].truthy
				end

				if val and (val.Type ~= "union" or not val:IsEmpty()) then
					if val.Type == "union" and #val:GetData() == 1 then
						val = val:GetData()[1]
					end

					return val
				end
			end
		end

		function META:ApplyMutationsAfterReturn(scope, scope_override, negate, upvalues, tables)
			if upvalues then
				for _, data in ipairs(upvalues) do
					local val = solve(data, scope, negate)

					if val then
						val:SetUpvalue(data.upvalue)
						self:MutateUpvalue(data.upvalue, val, scope_override, true)
					end
				end
			end

			if tables then
				for _, data in ipairs(tables) do
					local val = solve(data, scope, negate)

					if val then
						self:MutateTable(data.obj, data.key, val, scope_override, true)
					end
				end
			end
		end
	end
end end ]=======], '@./nattlua/analyzer/mutation_tracking.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.index"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
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
} end ]=======], '@./nattlua/analyzer/operators/index.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.newindex"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local tostring = tostring
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
return {
	NewIndex = function(META)
		function META:NewIndexOperator(obj, key, val)
			if obj.Type == "union" then
				-- local x: nil | {foo = true}
				-- log(x.foo) << error because nil cannot be indexed, to continue we have to remove nil from the union
				-- log(x.foo) << no error, because now x has no field nil
				local new_union = Union()
				local truthy_union = Union()
				local falsy_union = Union()

				for _, v in ipairs(obj:GetData()) do
					local ok, err = self:NewIndexOperator(v, key, val)

					if not ok then
						self:ErrorAndCloneCurrentScope(err or "invalid set error", obj)
						falsy_union:AddType(v)
					else
						truthy_union:AddType(v)
						new_union:AddType(v)
					end
				end

				truthy_union:SetUpvalue(obj:GetUpvalue())
				falsy_union:SetUpvalue(obj:GetUpvalue())
				return new_union
			end

			if
				val.Type == "function" and
				val:GetFunctionBodyNode() and
				val:GetFunctionBodyNode().self_call
			then
				local arg = val:GetInputSignature():Get(1)

				if arg and not arg:GetContract() and not arg.Self and not self:IsTypesystem() then
					val:SetCalled(true)
					val = val:Copy()
					val:SetCalled(nil)
					val:GetInputSignature():Set(1, Union({Any(), obj}))
					self:AddToUnreachableCodeAnalysis(val, val:GetInputSignature(), val:GetFunctionBodyNode(), true)
				end
			end

			if obj:GetMetaTable() then
				local func = obj:GetMetaTable():Get(LString("__newindex"))

				if func then
					if func.Type == "table" then return func:Set(key, val) end

					if func.Type == "function" then
						return self:Assert(self:Call(func, Tuple({obj, key, val}), self.current_statement))
					end
				end
			end

			if
				obj.Type == "table" and
				obj.argument_index and
				(
					not obj:GetContract() or
					not obj:GetContract().mutable
				)
				and
				not obj.mutable
			then
				if not obj:GetContract() then
					self:Warning(
						{
							"mutating function argument ",
							obj,
							" #",
							obj.argument_index,
							" without a contract",
						}
					)
				else
					self:Error(
						{
							"mutating function argument ",
							obj,
							" #",
							obj.argument_index,
							" with an immutable contract",
						}
					)
				end
			end

			local contract = obj:GetContract()

			if contract then
				if self:IsRuntime() then
					local existing
					local err

					if obj == contract then
						if obj.mutable and obj:GetMetaTable() and obj:GetMetaTable().Self == obj then
							return obj:SetExplicit(key, val)
						else
							existing = self:GetMutatedTableValue(obj, key)
						end
					else
						existing, err = contract:Get(key)
					end

					if existing then
						if val.Type == "function" and existing.Type == "function" then
							for i, v in ipairs(val:GetInputIdentifiers()) do
								if not existing:GetInputIdentifiers()[i] then
									self:Error("too many arguments")

									break
								end
							end

							val:SetInputSignature(existing:GetInputSignature())
							val:SetOutputSignature(existing:GetOutputSignature())
							val:SetExplicitOutputSignature(true)
							val:SetExplicitInputSignature(true)
							val:SetCalled(false)
						end

						local ok, err = val:IsSubsetOf(existing)

						if ok then
							if obj == contract then
								self:MutateTable(obj, key, val)
								return true
							end
						else
							self:Error(err)
						end
					elseif err then
						self:Error(err)
					end
				elseif self:IsTypesystem() then
					return obj:GetContract():SetExplicit(key, val)
				end
			end

			if self:IsTypesystem() then
				if obj.Type == "table" and (val.Type ~= "symbol" or val.Data ~= nil) then
					return obj:SetExplicit(key, val)
				else
					return obj:Set(key, val)
				end
			end

			self:MutateTable(obj, key, val)

			if not obj:GetContract() then return obj:Set(key, val, self:IsRuntime()) end

			return true
		end
	end,
} end ]=======], '@./nattlua/analyzer/operators/newindex.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.call_analyzer"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local math = math
local ipairs = ipairs
local type = type
local math = math
local table = _G.table
local debug = debug
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local Table = IMPORTS['nattlua.types.table']("nattlua.types.table").Table
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local Function = IMPORTS['nattlua.types.function']("nattlua.types.function").Function
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local LNumber = IMPORTS['nattlua.types.number']("nattlua.types.number").LNumber
local Symbol = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Symbol
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")

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
end end ]=======], '@./nattlua/analyzer/operators/call_analyzer.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.call_body"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local table = _G.table
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local Table = IMPORTS['nattlua.types.table']("nattlua.types.table").Table
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local Function = IMPORTS['nattlua.types.function']("nattlua.types.function").Function

local function mutate_type(self, i, arg, contract, arguments)
	local env = self:GetScope():GetNearestFunctionScope()
	env.mutated_types = env.mutated_types or {}
	arg:PushContract(contract)
	arg.argument_index = i
	arg.mutations = nil
	table.insert(env.mutated_types, {arg = arg, mutations = arg.mutations})
	arguments:Set(i, arg)
end

local function restore_mutated_types(self)
	local env = self:GetScope():GetNearestFunctionScope()

	if not env.mutated_types or not env.mutated_types[1] then return end

	for _, data in ipairs(env.mutated_types) do
		data.arg:PopContract()
		data.arg.argument_index = nil
		data.arg.mutations = data.mutations
		self:MutateUpvalue(data.arg:GetUpvalue(), data.arg)
	end

	env.mutated_types = {}
end

local function shrink_union_to_function_signature(obj)
	local arg = Tuple({})
	local ret = Tuple({})

	for _, func in ipairs(obj:GetData()) do
		if func.Type ~= "function" then return false end

		arg:Merge(func:GetInputSignature())
		ret:Merge(func:GetOutputSignature())
	end

	return Function(arg, ret)
end

local function check_argument_against_contract(arg, contract, i)
	local ok, reason

	if not arg then
		if contract:IsFalsy() then
			arg = Nil()
			ok = true
		else
			ok, reason = type_errors.other(
				{
					"argument #",
					i,
					" expected ",
					contract,
					" got nil",
				}
			)
		end
	elseif arg.Type == "table" and contract.Type == "table" then
		ok, reason = arg:FollowsContract(contract)
	else
		if arg.Type == "function" and contract.Type == "function" then
			ok, reason = arg:IsCallbackSubsetOf(contract)
		else
			ok, reason = arg:IsSubsetOf(contract)
		end
	end

	if not ok then
		return type_errors.other({"argument #", i, " ", arg, ": ", reason})
	end

	return true
end

local function check_input(self, obj, input)
	if not obj:IsExplicitInputSignature() then
		-- if this function is completely untyped we don't check any input
		return true
	end

	local function_node = obj:GetFunctionBodyNode()
	self:CreateAndPushFunctionScope(obj)
	self:PushAnalyzerEnvironment("typesystem")

	if
		function_node.kind == "local_type_function" or
		function_node.kind == "type_function"
	then
		if not function_node.identifiers_typesystem and obj:IsExplicitInputSignature() then
			-- if this is a type function we just do a simple check and arguments are passed as is
			local ok, reason, a, b, i

			if self:IsTypesystem() then
				ok, reason, a, b, i = input:IsSubsetOfTupleWithoutExpansion(obj:GetInputSignature())
			else
				ok, reason, a, b, i = input:IsSubsetOfTuple(obj:GetInputSignature())
			end

			self:PopAnalyzerEnvironment()
			self:PopScope()

			if not ok then
				return type_errors.subset(a, b, {"argument #", i, " - ", reason})
			end

			return ok, reason
		end

		if function_node.identifiers_typesystem then
			-- if this is a generics we setup the generic upvalues for the signature
			local call_expression = self:GetCallStack()[1].call_node

			for i, generic_upvalue in ipairs(function_node.identifiers_typesystem) do
				local generic_type = call_expression.expressions_typesystem and
					call_expression.expressions_typesystem[i] or
					generic_upvalue
				local T = self:AnalyzeExpression(generic_type)
				self:CreateLocalValue(generic_upvalue.value.value, T)
			end
		end
	end

	-- analyze the input signature to resolve generics and other types
	local function_node = obj:GetFunctionBodyNode()
	local input_signature = obj:GetInputSignature()
	local input_signature_length = input_signature:GetSafeLength(input)
	local signature_override = {}

	if function_node.identifiers[1] then
		-- analyze the type expressions
		-- function foo(a: >>number<<, b: >>string<<)
		-- against the input
		-- foo(1, "hello")
		for i = 1, input_signature_length do
			local node
			local identifier
			local type_expression

			if i == 1 and function_node.self_call then
				node = function_node
				identifier = "self"
				type_expression = function_node
			else
				local i = i

				if function_node.self_call then i = i - 1 end

				node = function_node.identifiers[i] or
					function_node.identifiers[#function_node.identifiers]
				identifier = node.value.value
				type_expression = node.type_expression
			end

			-- stem type so that we can allow
			-- function(x: foo<|x|>): nil
			self:CreateLocalValue(identifier, Any())
			local contract

			if identifier == "..." then
				contract = input_signature:GetWithoutExpansion(i)
			else
				contract = input_signature:Get(i)
			end

			local arg = input:Get(i)

			if not arg then
				arg = Nil()
				input:Set(i, arg)
			end

			if
				contract and
				contract:IsReferenceArgument() and
				(
					contract.Type ~= "function" or
					arg.Type ~= "function" or
					arg:IsArgumentsInferred()
				)
			then
				self:CreateLocalValue(identifier, arg)
				signature_override[i] = arg
				signature_override[i]:SetReferenceArgument(true)
				local ok, err = signature_override[i]:IsSubsetOf(contract)

				if not ok then
					self:PopAnalyzerEnvironment()
					self:PopScope()
					return type_errors.other({"argument #", i, " ", arg, ": ", err})
				end
			elseif type_expression then
				if function_node.self_call and i == 1 then
					signature_override[i] = input_signature:Get(1)
				else
					signature_override[i] = self:Assert(self:AnalyzeExpression(type_expression)):GetFirstValue()
				end

				self:CreateLocalValue(identifier, signature_override[i])
			end
		end
	end

	self:PopAnalyzerEnvironment()
	self:PopScope()

	do -- coerce untyped functions to contract callbacks
		for i = 1, input_signature_length do
			local arg = input:Get(i)

			if arg.Type == "function" then
				local func = arg

				if
					signature_override[i] and
					signature_override[i].Type == "union" and
					not signature_override[i]:IsReferenceArgument()
				then
					local merged = shrink_union_to_function_signature(signature_override[i])

					if merged then
						func:SetInputSignature(merged:GetInputSignature())
						func:SetOutputSignature(merged:GetOutputSignature())
						func:SetExplicitInputSignature(true)
						func:SetExplicitOutputSignature(true)
						func:SetCalled(false)
					end
				else
					if not func:IsExplicitInputSignature() then
						local contract = signature_override[i] or obj:GetInputSignature():Get(i)

						if contract then
							if contract.Type == "union" then
								local tup = Tuple({})

								for _, func in ipairs(contract:GetData()) do
									tup:Merge(func:GetInputSignature())
								end

								func:SetInputSignature(tup)
							elseif contract.Type == "function" then
								func:SetInputSignature(contract:GetInputSignature():Copy(nil, true)) -- force copy tables so we don't mutate the contract
							end

							func:SetCalled(false)
						end
					end

					if not func:IsExplicitOutputSignature() then
						local contract = signature_override[i] or obj:GetOutputSignature():Get(i)

						if contract then
							if contract.Type == "union" then
								local tup = Tuple({})

								for _, func in ipairs(contract:GetData()) do
									tup:Merge(func:GetOutputSignature())
								end

								func:SetOutputSignature(tup)
							elseif contract.Type == "function" then
								func:SetOutputSignature(contract:GetOutputSignature())
							end

							func:SetExplicitOutputSignature(true)
							func:SetCalled(false)
						end
					end
				end
			end
		end
	end

	-- finally check the input against the generated signature
	for i = 1, input_signature_length do
		local arg = input:Get(i)
		local contract = signature_override[i] or input_signature:Get(i)

		if contract.Type == "union" then
			local shrunk = shrink_union_to_function_signature(contract)

			if shrunk then contract = shrunk end
		end

		local ok, reason = check_argument_against_contract(arg, contract, i)

		if not ok then
			restore_mutated_types(self)
			return ok, reason
		end

		if
			arg and
			arg.Type == "table" and
			contract.Type == "table" and
			arg:GetUpvalue() and
			not contract:IsReferenceArgument()
		then
			mutate_type(self, i, arg, contract, input)
		elseif not contract:IsReferenceArgument() then
			local doit = true

			if contract.Type == "union" then
				local t = contract:GetType("table")

				if t and t.potential_self then doit = false end
			end

			if doit then
				-- if it's a ref argument we pass the incoming value
				local t = contract:Copy()
				t:SetContract(contract)
				input:Set(i, t)
			end
		end
	end

	return true
end

local function check_output(self, output, output_signature)
	if self:IsTypesystem() then
		-- in the typesystem we must not unpack tuples when checking
		local ok, reason, a, b, i = output:IsSubsetOfTupleWithoutExpansion(output_signature)

		if not ok then
			local _, err = type_errors.subset(a, b, {"return #", i, " '", b, "': ", reason})
			self:Error(err)
		end

		return
	end

	local original_contract = output_signature

	if
		output_signature:GetLength() == 1 and
		output_signature:Get(1).Type == "union" and
		output_signature:Get(1):HasType("tuple")
	then
		output_signature = output_signature:Get(1)
	end

	if
		output.Type == "tuple" and
		output:GetLength() == 1 and
		output:Get(1) and
		output:Get(1).Type == "union" and
		output:Get(1):HasType("tuple")
	then
		output = output:Get(1)
	end

	if output.Type == "union" then
		-- typically a function with mutliple uncertain returns
		for _, obj in ipairs(output:GetData()) do
			if obj.Type ~= "tuple" then
				-- if the function returns one value it's not in a tuple
				obj = Tuple({obj})
			end

			-- check each tuple in the union
			check_output(self, obj, original_contract)
		end
	else
		if output_signature.Type == "union" then
			local errors = {}

			for _, contract in ipairs(output_signature:GetData()) do
				local ok, reason = output:IsSubsetOfTuple(contract)

				if ok then
					-- something is ok then just return and don't report any errors found
					return
				else
					table.insert(errors, {contract = contract, reason = reason})
				end
			end

			for _, error in ipairs(errors) do
				self:Error(error.reason)
			end
		else
			if output.Type == "tuple" and output:GetLength() == 1 then
				local val = output:GetFirstValue()

				if val.Type == "union" and val:GetLength() == 0 then return end
			end

			local ok, reason, a, b, i = output:IsSubsetOfTuple(output_signature)

			if not ok then self:Error(reason) end
		end
	end
end

return function(META)
	function META:CallBodyFunction(obj, input)
		local function_node = obj:GetFunctionBodyNode()
		local is_type_function = function_node.kind == "local_type_function" or
			function_node.kind == "type_function"

		do
			local ok, err = check_input(self, obj, input)

			if not ok then return ok, err end
		end

		-- crawl the function with the new arguments
		-- return_result is either a union of tuples or a single tuple
		local scope = self:CreateAndPushFunctionScope(obj)
		function_node.scope = scope
		obj.scope = scope
		self:PushTruthyExpressionContext(false)
		self:PushFalsyExpressionContext(false)
		self:PushGlobalEnvironment(
			function_node,
			self:GetDefaultEnvironment(self:GetCurrentAnalyzerEnvironment()),
			self:GetCurrentAnalyzerEnvironment()
		)

		if function_node.self_call then
			self:CreateLocalValue("self", input:Get(1) or Nil())
		end

		-- first setup runtime generics type arguments if any
		if function_node.identifiers_typesystem then
			-- if this is a generics we setup the generic upvalues for the signature
			local call_expression = self:GetCallStack()[1].call_node

			for i, generic_upvalue in ipairs(function_node.identifiers_typesystem) do
				local generic_type = call_expression.expressions_typesystem and
					call_expression.expressions_typesystem[i] or
					nil

				if generic_type then
					local T = self:AnalyzeExpression(generic_type)
					self:CreateLocalValue(generic_upvalue.value.value, T)
				end
			end
		end

		-- then setup the runtime arguments
		for i, identifier in ipairs(function_node.identifiers) do
			local argi = function_node.self_call and (i + 1) or i

			if self:IsTypesystem() then
				self:CreateLocalValue(identifier.value.value, input:GetWithoutExpansion(argi))
			end

			if self:IsRuntime() then
				if identifier.value.value == "..." then
					self:CreateLocalValue(identifier.value.value, input:Slice(argi))
				else
					local val
					val = val or input:Get(argi)

					if not val then
						val = Nil()
						local arg = obj:GetInputSignature():Get(argi)

						if arg and arg:IsReferenceArgument() then
							val:SetReferenceArgument(true)
						end
					end

					self:CreateLocalValue(identifier.value.value, val)
				end
			end
		end

		-- if we have a return type we must also set this up for this call
		local output_signature = obj:IsExplicitOutputSignature() and obj:GetOutputSignature()

		if function_node.return_types then
			self:PushAnalyzerEnvironment("typesystem")
			output_signature = Tuple(self:AnalyzeExpressions(function_node.return_types))
			self:PopAnalyzerEnvironment()
		end

		if is_type_function then self:PushAnalyzerEnvironment("typesystem") end

		local output = self:AnalyzeStatementsAndCollectOutputSignatures(function_node)

		if is_type_function then self:PopAnalyzerEnvironment() end

		self:PopGlobalEnvironment(self:GetCurrentAnalyzerEnvironment())
		self:PopScope()
		self:PopFalsyExpressionContext()
		self:PopTruthyExpressionContext()
		self:ClearScopedTrackedObjects(scope)

		if output.Type ~= "tuple" then output = Tuple({output}) end

		restore_mutated_types(self)
		-- used for analyzing side effects
		obj:AddScope(input, output, scope)

		if not obj:IsExplicitInputSignature() then
			if not obj:IsArgumentsInferred() and function_node.identifiers then
				for i in ipairs(obj:GetInputSignature():GetData()) do
					if function_node.self_call then
						-- we don't count the actual self argument
						local node = function_node.identifiers[i + 1]

						if node and not node.type_expression then
							self:Warning("argument is untyped")
						end
					elseif
						function_node.identifiers[i] and
						not function_node.identifiers[i].type_expression
					then
						self:Warning("argument is untyped")
					end
				end
			end

			obj:GetInputSignature():Merge(input:Slice(1, obj:GetInputSignature():GetMinimumLength()))
		end

		do -- this is for the emitter
			if function_node.identifiers then
				for i, node in ipairs(function_node.identifiers) do
					node:AddType(obj:GetInputSignature():Get(i))
				end
			end

			function_node:AddType(obj)
		end

		if not output_signature then
			-- if there is no return type 
			if function_node.environment == "runtime" then
				local copy

				for i, v in ipairs(output:GetData()) do
					if v.Type == "table" and not v:GetContract() then
						copy = copy or output:Copy()
						local tbl = Table()

						for _, kv in ipairs(v:GetData()) do
							tbl:Set(kv.key, self:GetMutatedTableValue(v, kv.key))
						end

						copy:Set(i, tbl)
					end
				end

				obj:GetOutputSignature():Merge(copy or output)
			end

			return output
		end

		-- check against the function's return type
		check_output(self, output, output_signature)

		if function_node.environment == "typesystem" then return output end

		local contract = output_signature:Copy()

		for _, v in ipairs(contract:GetData()) do
			if v.Type == "table" then v:SetReferenceId(nil) end
		end

		-- if a return type is marked with ref, it will pass the ref value back to the caller
		-- a bit like generics
		for i, v in ipairs(output_signature:GetData()) do
			if v:IsReferenceArgument() then contract:Set(i, output:Get(i)) end
		end

		return contract
	end
end end ]=======], '@./nattlua/analyzer/operators/call_body.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.call_function_signature"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
return function(META)
	function META:CallFunctionSignature(obj, input)
		do
			local ok, reason, a, b, i = input:IsSubsetOfTuple(obj:GetInputSignature())

			if not ok then
				return type_errors.subset(a, b, {"argument #", i, " - ", reason})
			end
		end

		for i, arg in ipairs(input:GetData()) do
			if arg.Type == "table" and arg:GetAnalyzerEnvironment() == "runtime" then
				if self.config.external_mutation then
					self:Warning(
						{
							"argument #",
							i,
							" ",
							arg,
							" can be mutated by external call",
						}
					)
				end
			end
		end

		local ret = obj:GetOutputSignature():Copy()

		-- clear any reference id from the returned arguments
		for _, v in ipairs(ret:GetData()) do
			if v.Type == "table" then v:SetReferenceId(nil) end
		end

		return ret
	end
end end ]=======], '@./nattlua/analyzer/operators/call_function_signature.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.call"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
return {
	Call = function(META)
		IMPORTS['nattlua.analyzer.operators.call_analyzer']("nattlua.analyzer.operators.call_analyzer")(META)
		IMPORTS['nattlua.analyzer.operators.call_body']("nattlua.analyzer.operators.call_body")(META)
		IMPORTS['nattlua.analyzer.operators.call_function_signature']("nattlua.analyzer.operators.call_function_signature")(META)

		local function call_tuple(self, obj, input, call_node)
			return self:Call(obj:GetFirstValue(), input, call_node, true)
		end

		local function call_union(self, obj, input, call_node)
			if obj:IsEmpty() then return type_errors.operation("call", nil) end

			do
				-- make sure the union is callable, we pass the analyzer and 
				-- it will throw errors if the union contains something that is not callable
				-- however it will continue and just remove those values from the union
				local truthy_union = obj.New()

				for _, v in ipairs(obj.Data) do
					if v.Type ~= "function" and v.Type ~= "table" and v.Type ~= "any" then
						self:ErrorAndCloneCurrentScope(
							{
								"union ",
								obj,
								" contains uncallable object ",
								v,
							},
							obj
						)
					else
						truthy_union:AddType(v)
					end
				end

				truthy_union:SetUpvalue(obj:GetUpvalue())
				obj = truthy_union
			end

			local is_overload = true

			for _, obj in ipairs(obj.Data) do
				if obj.Type ~= "function" or obj:GetFunctionBodyNode() then
					is_overload = false

					break
				end
			end

			if is_overload then
				local errors = {}

				for _, obj in ipairs(obj.Data) do
					if
						obj.Type == "function" and
						input:GetLength() < obj:GetInputSignature():GetMinimumLength()
					then
						table.insert(
							errors,
							{
								"invalid amount of arguments: ",
								input,
								" ~= ",
								obj:GetInputSignature(),
							}
						)
					else
						local res, reason = self:Call(obj, input, call_node, true)

						if res then return res end

						table.insert(errors, reason)
					end
				end

				return type_errors.other(errors)
			end

			local new = Union({})

			for _, obj in ipairs(obj.Data) do
				local val = self:Assert(self:Call(obj, input, call_node, true))

				-- TODO
				if val.Type == "tuple" and val:GetLength() == 1 then
					val = val:Unpack(1)
				elseif val.Type == "union" and val:GetMinimumLength() == 1 then
					val = val:GetAtIndex(1)
				end

				new:AddType(val)
			end

			return Tuple({new})
		end

		local function call_table(self, obj, input, call_node)
			local __call = obj:GetMetaTable() and obj:GetMetaTable():Get(LString("__call"))

			if __call then
				local new_input = {obj}

				for _, v in ipairs(input:GetData()) do
					table.insert(new_input, v)
				end

				return self:Call(__call, Tuple(new_input), call_node, true)
			end

			return type_errors.other("table has no __call metamethod")
		end

		local function call_any(self, input)
			-- it's ok to call any types, it will just return any
			-- check arguments that can be mutated
			for _, arg in ipairs(input:GetData()) do
				if arg.Type == "table" and arg:GetAnalyzerEnvironment() == "runtime" then
					if arg:GetContract() then
						-- error if we call any with tables that have contracts
						-- since anything might happen to them in an any call
						self:Error(
							{
								"cannot mutate argument with contract ",
								arg:GetContract(),
							}
						)
					else
						-- if we pass a table without a contract to an any call, we add any to its key values
						for _, keyval in ipairs(arg:GetData()) do
							keyval.key = Union({Any(), keyval.key})
							keyval.val = Union({Any(), keyval.val})
						end
					end
				end
			end

			return Tuple({Tuple({}):AddRemainder(Tuple({Any()}):SetRepeat(math.huge))})
		end

		local function call_other(obj)
			return type_errors.other({
				"type ",
				obj.Type,
				": ",
				obj,
				" cannot be called",
			})
		end

		local function call_function(self, obj, input)
			-- mark the object as called so the unreachable code step won't call it
			obj:SetCalled(true)

			-- infer any uncalled functions in the arguments to get their return type
			for i, b in ipairs(input:GetData()) do
				if b.Type == "function" and not b:IsCalled() and not b:IsExplicitOutputSignature() then
					local a = obj:GetInputSignature():Get(i)

					if
						a and
						(
							(
								a.Type == "function" and
								not a:GetOutputSignature():IsSubsetOf(b:GetOutputSignature())
							)
							or
							not a:IsSubsetOf(b)
						)
					then
						local func = a

						if func.Type == "union" then func = a:GetType("function") end

						b:SetArgumentsInferred(true)

						-- TODO: callbacks with ref arguments should not be called
						-- mixed ref args make no sense, maybe ref should be a keyword for the function instead?
						if not b:IsRefFunction() and func then
							self:Assert(self:Call(b, func:GetInputSignature():Copy(nil, true)))
						end
					end
				end
			end

			if obj:GetAnalyzerFunction() then
				return self:CallAnalyzerFunction(obj, input)
			elseif obj:GetFunctionBodyNode() then
				return self:CallBodyFunction(obj, input)
			end

			return self:CallFunctionSignature(obj, input)
		end

		function META:Call(obj, input, call_node, not_recursive_call)
			if obj.Type == "tuple" then
				return call_tuple(self, obj, input, call_node)
			elseif obj.Type == "union" then
				return call_union(self, obj, input, call_node)
			elseif obj.Type == "table" then
				return call_table(self, obj, input, call_node)
			elseif obj.Type == "any" then
				return call_any(self, input)
			elseif obj.Type ~= "function" then
				return call_other(obj)
			end

			if
				self:IsRuntime() and
				obj:IsCalled() and
				not obj:IsRefFunction()
				and
				obj:GetFunctionBodyNode() and
				obj:GetFunctionBodyNode().environment == "runtime" and
				not obj:GetAnalyzerFunction()
				and
				obj:IsExplicitInputSignature()
			then
				if obj.scope and obj.scope.throws then
					self:GetScope():CertainReturn()
				end

				return obj:GetOutputSignature():Copy()
			end

			local ok, err = self:PushCallFrame(obj, call_node, not_recursive_call)

			if not ok == false then return ok, err end

			if ok then return ok end

			local ok, err = call_function(self, obj, input)
			self:PopCallFrame()
			return ok, err
		end
	end,
} end ]=======], '@./nattlua/analyzer/operators/call.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.destructure_assignment"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local tostring = tostring
local ipairs = ipairs
local NodeToString = IMPORTS['nattlua.types.string']("nattlua.types.string").NodeToString
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
return {
	AnalyzeDestructureAssignment = function(self, statement)
		local obj, err = self:AnalyzeExpression(statement.right)

		if obj.Type == "union" then obj = obj:GetData()[1] end

		if obj.Type == "tuple" then obj = obj:Get(1) end

		if obj.Type ~= "table" then
			self:Error("expected a table on the right hand side, got " .. tostring(obj.Type))
			return
		end

		if statement.default then
			if statement.kind == "local_destructure_assignment" then
				self:CreateLocalValue(statement.default.value.value, obj):SetNode(statement.default)
			elseif statement.kind == "destructure_assignment" then
				self:SetLocalOrGlobalValue(NodeToString(statement.default), obj)
			end
		end

		for _, node in ipairs(statement.left) do
			local obj = node.value and obj:Get(NodeToString(node))

			if not obj then
				if self:IsRuntime() then
					obj = Nil()
				else
					self:Error("field " .. tostring(node.value.value) .. " does not exist")
				end
			end

			if statement.kind == "local_destructure_assignment" then
				self:CreateLocalValue(node.value.value, obj):SetNode(node.value)
			elseif statement.kind == "destructure_assignment" then
				self:SetLocalOrGlobalValue(NodeToString(node), obj)
			end
		end
	end,
} end ]=======], '@./nattlua/analyzer/statements/destructure_assignment.lua'))())(...) return __M end end
IMPORTS['./nattlua/transpiler/../parser/nodes.nlua'] = assert(loadstring([=======[ return function() 

























































return {
	ExpressionKind = ExpressionKind,
	StatementKind = StatementKind,
	Node = Node,
	statement = statement,
	expression = expression,
} end ]=======], '@./nattlua/transpiler/../parser/nodes.nlua'))()
IMPORTS['./nattlua/transpiler/../config.nlua'] = assert(loadstring([=======[ return function() 





return {
	LexerConfig = nil,
	ParserConfig = nil,
	AnalyzerConfig = nil,
	TranspilerConfig = nil,
	CompilerConfig = nil,
} end ]=======], '@./nattlua/transpiler/../config.nlua'))()
do local __M; IMPORTS["nattlua.transpiler.emitter"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local runtime_syntax = IMPORTS['nattlua.syntax.runtime']("nattlua.syntax.runtime")
local characters = IMPORTS['nattlua.syntax.characters']("nattlua.syntax.characters")
local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local print = _G.print
local error = _G.error
local debug = _G.debug
local tostring = _G.tostring
local pairs = _G.pairs
local table = _G.table
local ipairs = _G.ipairs
local assert = _G.assert
local type = _G.type
local setmetatable = _G.setmetatable
local B = string.byte
local META = class.CreateTemplate("emitter")



local translate_binary = {
	["&&"] = "and",
	["||"] = "or",
	["!="] = "~=",
}
local translate_prefix = {
	["!"] = "not ",
}

do -- internal
	function META:Whitespace(str, force)
		if self.config.preserve_whitespace == nil and not force then return end

		if str == "\t" then
			if self.config.no_newlines then
				self:Emit(" ")
			else
				self:Emit(("\t"):rep(self.level))
				self.last_indent_index = #self.out
			end
		elseif str == " " then
			self:Emit(" ")
		elseif str == "\n" then
			self:Emit(self.config.no_newlines and " " or "\n")
			self.last_newline_index = #self.out
		else
			error("unknown whitespace " .. ("%q"):format(str))
		end
	end

	function META:Emit(str)
		if type(str) ~= "string" then
			error(debug.traceback("attempted to emit a non string " .. tostring(str)))
		end

		if str == "" then return end

		self.out[self.i] = str or ""
		self.i = self.i + 1
	end

	function META:EmitNonSpace(str)
		self:Emit(str)
		self.last_non_space_index = #self.out
	end

	function META:EmitSpace(str)
		self:Emit(str)
	end

	function META:Indent()
		self.level = self.level + 1
	end

	function META:Outdent()
		self.level = self.level - 1
	end

	function META:GetPrevChar()
		local prev = self.out[self.i - 1]
		local char = prev and prev:sub(-1)
		return char and char:byte() or 0
	end

	function META:EmitWhitespace(token)
		if self.config.preserve_whitespace == false and token.type == "space" then
			return
		end

		self:EmitToken(token)

		if token.type ~= "space" then
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	function META:EmitToken(node, translate)
		if
			self.config.extra_indent and
			self.config.preserve_whitespace == false and
			self.inside_call_expression
		then
			self.tracking_indents = self.tracking_indents or {}

			if type(self.config.extra_indent[node.value]) == "table" then
				self:Indent()
				local info = self.config.extra_indent[node.value]

				if type(info.to) == "table" then
					for to in pairs(info.to) do
						self.tracking_indents[to] = self.tracking_indents[to] or {}
						table.insert(self.tracking_indents[to], {info = info, level = self.level})
					end
				else
					self.tracking_indents[info.to] = self.tracking_indents[info.to] or {}
					table.insert(self.tracking_indents[info.to], {info = info, level = self.level})
				end
			elseif self.tracking_indents[node.value] then
				for _, info in ipairs(self.tracking_indents[node.value]) do
					if info.level == self.level or info.level == self.pre_toggle_level then
						self:Outdent()
						local info = self.tracking_indents[node.value]

						for key, val in pairs(self.tracking_indents) do
							if info == val.info then self.tracking_indents[key] = nil end
						end

						if self.out[self.last_indent_index] then
							self.out[self.last_indent_index] = self.out[self.last_indent_index]:sub(2)
						end

						if self.toggled_indents then
							self:Outdent()
							self.toggled_indents = {}

							if self.out[self.last_indent_index] then
								self.out[self.last_indent_index] = self.out[self.last_indent_index]:sub(2)
							end
						end

						break
					end
				end
			end

			if self.config.extra_indent[node.value] == "toggle" then
				self.toggled_indents = self.toggled_indents or {}

				if not self.toggled_indents[node.value] then
					self.toggled_indents[node.value] = true
					self.pre_toggle_level = self.level
					self:Indent()
				elseif self.toggled_indents[node.value] then
					if self.out[self.last_indent_index] then
						self.out[self.last_indent_index] = self.out[self.last_indent_index]:sub(2)
					end
				end
			end
		end

		if node.whitespace then
			if self.config.preserve_whitespace == false then
				for i, token in ipairs(node.whitespace) do
					if token.type == "line_comment" then
						local start = i

						for i = self.i - 1, 1, -1 do
							if not self.out[i]:find("^%s+") then
								local found_newline = false

								for i = start, 1, -1 do
									local token = node.whitespace[i]

									if token.value:find("\n") then
										found_newline = true

										break
									end
								end

								if not found_newline then
									self.i = i + 1
									self:Emit(" ")
								end

								break
							end
						end

						self:EmitToken(token)

						if node.whitespace[i + 1] then
							self:Whitespace("\n")
							self:Whitespace("\t")
						end
					elseif token.type == "multiline_comment" then
						self:EmitToken(token)
						self:Whitespace(" ")
					end
				end
			else
				for _, token in ipairs(node.whitespace) do
					if token.type ~= "comment_escape" then self:EmitWhitespace(token) end
				end
			end
		end

		if self.TranslateToken then
			translate = self:TranslateToken(node) or translate
		end

		if translate then
			if type(translate) == "table" then
				self:Emit(translate[node.value] or node.value)
			elseif type(translate) == "function" then
				self:Emit(translate(node.value))
			elseif translate ~= "" then
				self:Emit(translate)
			end
		else
			self:Emit(node.value)
		end

		if
			node.type ~= "line_comment" and
			node.type ~= "multiline_comment" and
			node.type ~= "space"
		then
			self.last_non_space_index = #self.out
		end
	end

	function META:Initialize()
		self.level = 0
		self.out = {}
		self.i = 1
	end

	function META:Concat()
		return table.concat(self.out)
	end

	do
		function META:PushLoop(node)
			self.loop_nodes = self.loop_nodes or {}
			table.insert(self.loop_nodes, node)
		end

		function META:PopLoop()
			local node = table.remove(self.loop_nodes)

			if node.on_pop then node:on_pop() end
		end

		function META:GetLoopNode()
			if self.loop_nodes then return self.loop_nodes[#self.loop_nodes] end

			return nil
		end
	end
end

do -- newline breaking
	do
		function META:PushForcedLineBreaking(b)
			self.force_newlines = self.force_newlines or {}
			table.insert(self.force_newlines, b)
		end

		function META:PopForcedLineBreaking()
			table.remove(self.force_newlines)
		end

		function META:IsLineBreaking()
			if self.force_newlines then return self.force_newlines[#self.force_newlines] end
		end
	end

	function META:ShouldLineBreakNode(node)
		if node.kind == "table" or node.kind == "type_table" then
			for _, exp in ipairs(node.children) do
				if exp.value_expression and exp.value_expression.kind == "function" then
					return true
				end
			end

			if #node.children > 0 and #node.children == #node.tokens["separators"] then
				return true
			end
		end

		if node.kind == "function" then return #node.statements > 1 end

		if node.kind == "if" then
			for i = 1, #node.statements do
				if #node.statements[i] > 1 then return true end
			end
		end

		return node:GetLength() > self.config.max_line_length
	end

	function META:EmitLineBreakableExpression(node)
		local newlines = self:ShouldLineBreakNode(node)

		if newlines then
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		else
			self:Whitespace(" ")
		end

		self:PushForcedLineBreaking(newlines)
		self:EmitExpression(node)
		self:PopForcedLineBreaking()

		if newlines then
			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		else
			self:Whitespace(" ")
		end
	end

	function META:EmitLineBreakableList(tbl, func)
		local newline = self:ShouldBreakExpressionList(tbl)
		self:PushForcedLineBreaking(newline)

		if newline then
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end

		func(self, tbl)

		if newline then
			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end

		self:PopForcedLineBreaking()
	end

	function META:EmitExpressionList(tbl)
		self:EmitNodeList(tbl, self.EmitExpression)
	end

	function META:EmitIdentifierList(tbl)
		self:EmitNodeList(tbl, self.EmitIdentifier)
	end
end

local function encapsulate_module(content, name, method)
	if method == "loadstring" then
		local len = 6

		content:gsub("%[[=]*%[", function(s)
			len = math.max(len, #s - 2)
		end)

		local eq = ("="):rep(len + 1)
		return "assert(loadstring([" .. eq .. "[ return " .. content .. " ]" .. eq .. "], '" .. name .. "'))()"
	end

	return content
end

function META:BuildCode(block)
	if block.imports then
		self.done = {}
		self:EmitNonSpace("_G.IMPORTS = _G.IMPORTS or {}\n")

		for i, node in ipairs(block.imports) do
			if not self.done[node.key] then
				if node.data then
					self:Emit(
						"IMPORTS['" .. node.key .. "'] = function() return [===" .. "===[ " .. node.data .. " ]===" .. "===] end\n"
					)
				else
					-- ugly way of dealing with recursive import
					local root = node.RootStatement

					if root and root.kind ~= "root" then root = root.RootStatement end

					if root then
						if node.left.value.value == "loadfile" then
							self:Emit(
								"IMPORTS['" .. node.key .. "'] = " .. encapsulate_module(
										"function(...) " .. root:Render(self.config or {}) .. " end",
										"@" .. node.path,
										self.config.module_encapsulation_method
									) .. "\n"
							)
						elseif node.left.value.value == "require" then
							self:Emit(
								"do local __M; IMPORTS[\"" .. node.key .. "\"] = function(...) __M = __M or (" .. encapsulate_module(
										"function(...) " .. root:Render(self.config or {}) .. " end",
										"@" .. node.path,
										self.config.module_encapsulation_method
									) .. ")(...) return __M end end\n"
							)
						elseif self.config.inside_data_import then
							self:Emit(
								"IMPORTS['" .. node.key .. "'] = function() " .. root:Render(self.config or {}) .. " end\n"
							)
						else
							self:Emit(
								"IMPORTS['" .. node.key .. "'] = " .. encapsulate_module(
										"function() " .. root:Render(self.config or {}) .. " end",
										"@" .. node.path,
										self.config.module_encapsulation_method
									) .. "\n"
							)
						end
					end
				end

				self.done[node.key] = true
			end
		end
	end

	self:EmitStatements(block.statements)
	return self:Concat()
end

function META:OptionalWhitespace()
	if self.config.preserve_whitespace == nil then return end

	if
		characters.IsLetter(self:GetPrevChar()) or
		characters.IsNumber(self:GetPrevChar())
	then
		self:EmitSpace(" ")
	end
end

do
	local function escape_string(str, quote)
		local new_str = {}

		for i = 1, #str do
			local c = str:sub(i, i)

			if c == quote then
				local escape_length = 0

				for i = i - 1, 1, -1 do
					if str:sub(i, i) == "\\" then
						escape_length = escape_length + 1
					else
						break
					end
				end

				if escape_length % 2 == 0 then
					new_str[i] = "\\" .. c
				else
					new_str[i] = c
				end
			else
				new_str[i] = c
			end
		end

		return table.concat(new_str)
	end

	function META:EmitStringToken(token)
		if self.config.string_quote then
			local current = token.value:sub(1, 1)
			local target = self.config.string_quote

			if current == "\"" or current == "'" then
				local contents = escape_string(token.value:sub(2, -2), target)
				self:EmitToken(token, target .. contents .. target)
				return
			end
		end

		local needs_space = token.value:sub(1, 1) == "[" and self:GetPrevChar() == B("[")

		if needs_space then self:Whitespace(" ") end

		self:EmitToken(token)

		if needs_space then self:Whitespace(" ") end
	end
end

function META:EmitNumberToken(token)
	self:EmitToken(token)
end

function META:EmitFunctionSignature(node)
	self:EmitToken(node.tokens["function"])
	self:EmitToken(node.tokens["="])
	self:EmitToken(node.tokens["arguments("])
	self:EmitLineBreakableList(node.identifiers, self.EmitIdentifierList)
	self:EmitToken(node.tokens["arguments)"])
	self:EmitToken(node.tokens[">"])
	self:EmitToken(node.tokens["return("])
	self:EmitLineBreakableList(node.return_types, self.EmitExpressionList)
	self:EmitToken(node.tokens["return)"])
end

function META:EmitExpression(node)
	local emitted_invalid_code = false
	local newlines = self:IsLineBreaking()

	if node.tokens["("] then
		for i = #node.tokens["("], 1, -1 do
			self:EmitToken(node.tokens["("][i])
		end

		if node.tokens["("] and newlines then
			self:Indent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	if node.kind == "binary_operator" then
		self:EmitBinaryOperator(node)
	elseif node.kind == "function" then
		self:EmitAnonymousFunction(node)
	elseif node.kind == "analyzer_function" then
		emitted_invalid_code = self:EmitInvalidLuaCode("EmitAnalyzerFunction", node)
	elseif node.kind == "table" then
		self:EmitTable(node)
	elseif node.kind == "prefix_operator" then
		self:EmitPrefixOperator(node)
	elseif node.kind == "postfix_operator" then
		self:EmitPostfixOperator(node)
	elseif node.kind == "postfix_call" then
		if node.import_expression then
			if not node.path or node.type_call then
				emitted_invalid_code = self:EmitInvalidLuaCode("EmitImportExpression", node)
			else
				self:EmitImportExpression(node)
			end
		elseif node.require_expression then
			self:EmitImportExpression(node)
		elseif node.expressions_typesystem then
			self:EmitCall(node)
		elseif node.type_call then
			emitted_invalid_code = self:EmitInvalidLuaCode("EmitCall", node)
		else
			self:EmitCall(node)
		end
	elseif node.kind == "postfix_expression_index" then
		self:EmitExpressionIndex(node)
	elseif node.kind == "value" then
		if node.tokens["is"] then
			self:EmitToken(node.value, tostring(node.result_is))
		else
			if node.value.type == "string" then
				self:EmitStringToken(node.value)
			elseif node.value.type == "number" then
				self:EmitNumberToken(node.value)
			else
				self:EmitToken(node.value)
			end
		end
	elseif node.kind == "require" then
		self:EmitRequireExpression(node)
	elseif node.kind == "type_table" then
		self:EmitTableType(node)
	elseif node.kind == "table_expression_value" then
		self:EmitTableExpressionValue(node)
	elseif node.kind == "table_key_value" then
		self:EmitTableKeyValue(node)
	elseif node.kind == "empty_union" then
		self:EmitEmptyUnion(node)
	elseif node.kind == "tuple" then
		self:EmitTuple(node)
	elseif node.kind == "type_function" then
		emitted_invalid_code = self:EmitInvalidLuaCode("EmitTypeFunction", node)
	elseif node.kind == "function_signature" then
		emitted_invalid_code = self:EmitInvalidLuaCode("EmitFunctionSignature", node)
	elseif node.kind == "vararg" then
		self:EmitVararg(node)
	else
		error("unhandled token type " .. node.kind)
	end

	if node.tokens[")"] and newlines then
		self:Outdent()
		self:Whitespace("\n")
		self:Whitespace("\t")
	end

	if not node.tokens[")"] then
		if self.config.type_annotations and node.tokens[":"] then
			self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
		end

		if self.config.type_annotations and node.tokens["as"] then
			self:EmitInvalidLuaCode("EmitAsAnnotationExpression", node)
		end
	else
		local colon_expression = false
		local as_expression = false

		for _, token in ipairs(node.tokens[")"]) do
			if not colon_expression then
				if
					self.config.type_annotations and
					node.tokens[":"] and
					node.tokens[":"].stop < token.start
				then
					self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
					colon_expression = true
				end
			end

			if not as_expression then
				if
					self.config.type_annotations and
					node.tokens["as"] and
					node.tokens["as"].stop < token.start
				then
					self:EmitInvalidLuaCode("EmitAsAnnotationExpression", node)
					as_expression = true
				end
			end

			self:EmitToken(token)
		end

		if not colon_expression then
			if self.config.type_annotations and node.tokens[":"] then
				self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
			end
		end

		if not as_expression then
			if self.config.type_annotations and node.tokens["as"] then
				self:EmitInvalidLuaCode("EmitAsAnnotationExpression", node)
			end
		end
	end

	if
		emitted_invalid_code and
		not self.is_call_expression and
		(
			self.config.comment_type_annotations or
			self.config.omit_invalid_code
		)
	then
		self:EmitNonSpace("nil")
	end
end

function META:EmitVarargTuple(node)
	self:Emit(tostring(node:GetLastType()))
end

function META:EmitExpressionIndex(node)
	self:EmitExpression(node.left)
	self:EmitToken(node.tokens["["])
	self:EmitExpression(node.expression)
	self:EmitToken(node.tokens["]"])
end

function META:EmitCall(node)
	local multiline_string = false

	if #node.expressions == 1 and node.expressions[1].kind == "value" then
		multiline_string = node.expressions[1].value.value:sub(1, 1) == "["
	end

	-- this will not work for calls with functions that contain statements
	self.inside_call_expression = true
	self:EmitExpression(node.left)

	if node.expressions_typesystem and not self.config.omit_invalid_code then
		local emitted = self:StartEmittingInvalidLuaCode()
		self:EmitToken(node.tokens["call_typesystem("])
		self:EmitExpressionList(node.expressions_typesystem)
		self:EmitToken(node.tokens["call_typesystem)"])
		self:StopEmittingInvalidLuaCode(emitted)
	end

	if node.tokens["call("] then
		self:EmitToken(node.tokens["call("])
	else
		if self.config.force_parenthesis and not multiline_string then
			self:EmitNonSpace("(")
		end
	end

	local newlines = self:ShouldBreakExpressionList(node.expressions)

	if multiline_string then newlines = false end

	local last = node.expressions[#node.expressions]

	if last and last.kind == "function" and #node.expressions < 4 then
		newlines = false
	end

	if node.tokens["call("] and newlines then
		self:Indent()
		self:Whitespace("\n")
		self:Whitespace("\t")
	end

	self:PushForcedLineBreaking(newlines)
	self:EmitExpressionList(node.expressions)
	self:PopForcedLineBreaking()

	if newlines then self:Outdent() end

	if node.tokens["call)"] then
		if newlines then
			self:Whitespace("\n")
			self:Whitespace("\t")
		end

		self:EmitToken(node.tokens["call)"])
	else
		if self.config.force_parenthesis and not multiline_string then
			if newlines then
				self:Whitespace("\n")
				self:Whitespace("\t")
			end

			self:EmitNonSpace(")")
		end
	end

	self.inside_call_expression = false
end

function META:EmitBinaryOperator(node)
	local func_chunks = node.environment == "runtime" and
		runtime_syntax:GetFunctionForBinaryOperator(node.value)

	if func_chunks then
		self:Emit(func_chunks[1])

		if node.left then self:EmitExpression(node.left) end

		self:Emit(func_chunks[2])

		if node.right then self:EmitExpression(node.right) end

		self:Emit(func_chunks[3])
		self.operator_transformed = true
	else
		if node.left then self:EmitExpression(node.left) end

		if node.value.value == "." or node.value.value == ":" then
			self:EmitToken(node.value)
		elseif
			node.value.value == "and" or
			node.value.value == "or" or
			node.value.value == "||" or
			node.value.value == "&&"
		then
			if self:IsLineBreaking() then
				if
					self:GetPrevChar() == B(")") and
					node.left.kind ~= "postfix_call" and
					(
						node.left.kind == "binary_operator" and
						node.left.right.kind ~= "postfix_call"
					)
				then
					self:Whitespace("\n")
					self:Whitespace("\t")
				else
					self:Whitespace(" ")
				end

				self:EmitToken(node.value, translate_binary[node.value.value])

				if node.right then
					self:Whitespace("\n")
					self:Whitespace("\t")
				end
			else
				self:Whitespace(" ")
				self:EmitToken(node.value, translate_binary[node.value.value])
				self:Whitespace(" ")
			end
		else
			self:Whitespace(" ")
			self:EmitToken(node.value, translate_binary[node.value.value])
			self:Whitespace(" ")
		end

		if node.right then self:EmitExpression(node.right) end
	end
end

do
	function META:EmitFunctionBody(node)
		if node.identifiers_typesystem and not self.config.omit_invalid_code then
			local emitted = self:StartEmittingInvalidLuaCode()
			self:EmitToken(node.tokens["arguments_typesystem("])
			self:EmitExpressionList(node.identifiers_typesystem)
			self:EmitToken(node.tokens["arguments_typesystem)"])
			self:StopEmittingInvalidLuaCode(emitted)
		end

		self:EmitToken(node.tokens["arguments("])
		self:EmitLineBreakableList(node.identifiers, self.EmitIdentifierList)
		self:EmitToken(node.tokens["arguments)"])
		self:EmitFunctionReturnAnnotation(node)

		if #node.statements == 0 then
			self:Whitespace(" ")
		else
			self:Whitespace("\n")
			self:EmitBlock(node.statements)
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	function META:EmitAnonymousFunction(node)
		self:EmitToken(node.tokens["function"])
		local distance = (node.tokens["end"].start - node.tokens["arguments)"].start)
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitLocalFunction(node)
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["identifier"])
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitLocalAnalyzerFunction(node)
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["analyzer"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["identifier"])
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitLocalTypeFunction(node)
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["identifier"])
		self:EmitFunctionBody(node, true)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitTypeFunction(node)
		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")

		if node.expression or node.identifier then
			self:EmitExpression(node.expression or node.identifier)
		end

		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitFunction(node)
		if node.tokens["local"] then
			self:EmitToken(node.tokens["local"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")
		self:EmitExpression(node.expression or node.identifier)
		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end

	function META:EmitAnalyzerFunctionStatement(node)
		if node.tokens["local"] then
			self:EmitToken(node.tokens["local"])
			self:Whitespace(" ")
		end

		if node.tokens["analyzer"] then
			self:EmitToken(node.tokens["analyzer"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"])
		self:Whitespace(" ")

		if node.tokens["^"] then self:EmitToken(node.tokens["^"]) end

		if node.expression or node.identifier then
			self:EmitExpression(node.expression or node.identifier)
		end

		self:EmitFunctionBody(node)
		self:EmitToken(node.tokens["end"])
	end
end

function META:EmitTableExpressionValue(node)
	self:EmitToken(node.tokens["["])
	self:EmitExpression(node.key_expression)
	self:EmitToken(node.tokens["]"])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["="])
	self:Whitespace(" ")
	self:EmitExpression(node.value_expression)
end

function META:EmitTableKeyValue(node)
	self:EmitToken(node.tokens["identifier"])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["="])
	self:Whitespace(" ")
	local break_binary = node.value_expression.kind == "binary_operator" and
		self:ShouldLineBreakNode(node.value_expression)

	if break_binary then self:Indent() end

	self:PushForcedLineBreaking(break_binary)
	self:EmitExpression(node.value_expression)
	self:PopForcedLineBreaking()

	if break_binary then self:Outdent() end
end

function META:EmitEmptyUnion(node)
	self:EmitToken(node.tokens["|"])
end

function META:EmitTuple(node)
	self:EmitToken(node.tokens["("])
	self:EmitExpressionList(node.expressions)

	if #node.expressions == 1 then
		if node.expressions[1].tokens[","] then
			self:EmitToken(node.expressions[1].tokens[","])
		end
	end

	self:EmitToken(node.tokens[")"])
end

function META:EmitVararg(node)
	self:EmitToken(node.tokens["..."])
	self:EmitExpression(node.value)
end

function META:EmitTable(tree)
	if tree.spread then
		if self.config.omit_invalid_code then
			self:EmitNonSpace("table.mergetables")
		end
	end

	local during_spread = false
	self:EmitToken(tree.tokens["{"])
	local newline = self:ShouldLineBreakNode(tree)

	if newline then
		self:Whitespace("\n")
		self:Indent()
	end

	if tree.children[1] then
		for i, node in ipairs(tree.children) do
			if newline then self:Whitespace("\t") end

			if node.kind == "table_index_value" then
				if node.spread then
					if not self.config.omit_invalid_code then
						self:EmitToken(node.spread.tokens["..."])
						self:EmitExpression(node.spread.expression)
					else
						if during_spread then
							self:EmitNonSpace("},")
							during_spread = false
						end

						self:EmitExpression(node.spread.expression)
					end
				else
					self:EmitExpression(node.value_expression)
				end
			elseif node.kind == "table_key_value" then
				if self.config.omit_invalid_code and tree.spread and not during_spread then
					during_spread = true
					self:EmitNonSpace("{")
				end

				self:EmitTableKeyValue(node)
			elseif node.kind == "table_expression_value" then
				self:EmitTableExpressionValue(node)
			end

			if tree.tokens["separators"][i] then
				self:EmitToken(tree.tokens["separators"][i])
			else
				if newline then self:EmitNonSpace(",") end
			end

			if newline then
				self:Whitespace("\n")
			else
				if i ~= #tree.children then self:Whitespace(" ") end
			end
		end
	end

	if during_spread then self:EmitNonSpace("}") end

	if newline then
		self:Outdent()
		self:Whitespace("\t")
	end

	self:EmitToken(tree.tokens["}"])
end

function META:EmitPrefixOperator(node)
	local func_chunks = node.environment == "runtime" and
		runtime_syntax:GetFunctionForPrefixOperator(node.value)

	if self.TranslatePrefixOperator then
		func_chunks = self:TranslatePrefixOperator(node) or func_chunks
	end

	if func_chunks then
		self:Emit(func_chunks[1])
		self:EmitExpression(node.right)
		self:Emit(func_chunks[2])
		self.operator_transformed = true
	else
		if
			runtime_syntax:IsKeyword(node.value) or
			runtime_syntax:IsNonStandardKeyword(node.value)
		then
			self:OptionalWhitespace()
			self:EmitToken(node.value, translate_prefix[node.value.value])
			self:OptionalWhitespace()
			self:EmitExpression(node.right)
		else
			self:EmitToken(node.value, translate_prefix[node.value.value])
			self:OptionalWhitespace()
			self:EmitExpression(node.right)
		end
	end
end

function META:EmitPostfixOperator(node)
	local func_chunks = node.environment == "runtime" and
		runtime_syntax:GetFunctionForPostfixOperator(node.value)
	-- no such thing as postfix operator in lua,
	-- so we have to assume that there's a translation
	assert(func_chunks)
	self:Emit(func_chunks[1])
	self:EmitExpression(node.left)
	self:Emit(func_chunks[2])
	self.operator_transformed = true
end

function META:EmitBlock(statements)
	self:PushForcedLineBreaking(false)
	self:Indent()
	self:EmitStatements(statements)
	self:Outdent()
	self:PopForcedLineBreaking()
end

function META:EmitIfStatement(node)
	local short = not self:ShouldLineBreakNode(node)

	for i = 1, #node.statements do
		if node.expressions[i] then
			if not short and i > 1 then
				self:Whitespace("\n")
				self:Whitespace("\t")
			end

			self:EmitToken(node.tokens["if/else/elseif"][i])
			self:EmitLineBreakableExpression(node.expressions[i])
			self:EmitToken(node.tokens["then"][i])
		elseif node.tokens["if/else/elseif"][i] then
			if not short then
				self:Whitespace("\n")
				self:Whitespace("\t")
			end

			self:EmitToken(node.tokens["if/else/elseif"][i])
		end

		if short then self:Whitespace(" ") else self:Whitespace("\n") end

		if #node.statements[i] == 1 and short then
			self:EmitStatement(node.statements[i][1])
		else
			self:EmitBlock(node.statements[i])
		end

		if short then self:Whitespace(" ") end
	end

	if not short then
		self:Whitespace("\n")
		self:Whitespace("\t")
	end

	self:EmitToken(node.tokens["end"])
end

function META:EmitGenericForStatement(node)
	self:EmitToken(node.tokens["for"])
	self:Whitespace(" ")
	self:EmitIdentifierList(node.identifiers)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["in"])
	self:Whitespace(" ")
	self:EmitExpressionList(node.expressions)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["do"])
	self:PushLoop(node)
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["end"])
end

function META:EmitNumericForStatement(node)
	self:EmitToken(node.tokens["for"])
	self:PushLoop(node)
	self:Whitespace(" ")
	self:EmitIdentifierList(node.identifiers)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["="])
	self:Whitespace(" ")
	self:EmitExpressionList(node.expressions)
	self:Whitespace(" ")
	self:EmitToken(node.tokens["do"])
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["end"])
end

function META:EmitWhileStatement(node)
	self:EmitToken(node.tokens["while"])
	self:EmitLineBreakableExpression(node.expression)
	self:EmitToken(node.tokens["do"])
	self:PushLoop(node)
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["end"])
end

function META:EmitRepeatStatement(node)
	self:EmitToken(node.tokens["repeat"])
	self:PushLoop(node)
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:PopLoop()
	self:EmitToken(node.tokens["until"])
	self:Whitespace(" ")
	self:EmitExpression(node.expression)
end

function META:EmitLabelStatement(node)
	self:EmitToken(node.tokens["::"])
	self:EmitToken(node.tokens["identifier"])
	self:EmitToken(node.tokens["::"])
end

function META:EmitGotoStatement(node)
	self:EmitToken(node.tokens["goto"])
	self:Whitespace(" ")
	self:EmitToken(node.tokens["identifier"])
end

function META:EmitBreakStatement(node)
	self:EmitToken(node.tokens["break"])
end

function META:EmitContinueStatement(node)
	local loop_node = self.config.transpile_extensions and self:GetLoopNode()

	if loop_node then
		self:EmitToken(node.tokens["continue"], "goto __CONTINUE__")
		loop_node.on_pop = function()
			self:EmitNonSpace("::__CONTINUE__::;")
		end
	else
		self:EmitToken(node.tokens["continue"])
	end
end

function META:EmitDoStatement(node)
	self:EmitToken(node.tokens["do"])
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\n")
	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"])
end

function META:EmitReturnStatement(node)
	self:EmitToken(node.tokens["return"])

	if node.expressions[1] then
		self:Whitespace(" ")
		self:PushForcedLineBreaking(self:ShouldLineBreakNode(node))
		self:EmitExpressionList(node.expressions)
		self:PopForcedLineBreaking()
	end
end

function META:EmitSemicolonStatement(node)
	if self.config.no_semicolon then
		self:EmitToken(node.tokens[";"], "")
	else
		self:EmitToken(node.tokens[";"])
	end
end

function META:EmitAssignment(node)
	if node.tokens["local"] then
		self:EmitToken(node.tokens["local"])
		self:Whitespace(" ")
	end

	if node.tokens["type"] then
		self:EmitToken(node.tokens["type"])
		self:Whitespace(" ")
	end

	if node.tokens["local"] then
		self:EmitIdentifierList(node.left)
	else
		self:EmitExpressionList(node.left)
	end

	if node.tokens["="] then
		self:Whitespace(" ")
		self:EmitToken(node.tokens["="])
		self:Whitespace(" ")
		self:PushForcedLineBreaking(self:ShouldBreakExpressionList(node.right))
		self:EmitExpressionList(node.right)
		self:PopForcedLineBreaking()
	end
end

function META:EmitStatement(node)
	if node.kind == "if" then
		self:EmitIfStatement(node)
	elseif node.kind == "goto" then
		self:EmitGotoStatement(node)
	elseif node.kind == "goto_label" then
		self:EmitLabelStatement(node)
	elseif node.kind == "while" then
		self:EmitWhileStatement(node)
	elseif node.kind == "repeat" then
		self:EmitRepeatStatement(node)
	elseif node.kind == "break" then
		self:EmitBreakStatement(node)
	elseif node.kind == "return" then
		self:EmitReturnStatement(node)
	elseif node.kind == "numeric_for" then
		self:EmitNumericForStatement(node)
	elseif node.kind == "generic_for" then
		self:EmitGenericForStatement(node)
	elseif node.kind == "do" then
		self:EmitDoStatement(node)
	elseif node.kind == "analyzer_function" then
		self:EmitInvalidLuaCode("EmitAnalyzerFunctionStatement", node)
	elseif node.kind == "function" then
		self:EmitFunction(node)
	elseif node.kind == "local_function" then
		self:EmitLocalFunction(node)
	elseif node.kind == "local_analyzer_function" then
		self:EmitInvalidLuaCode("EmitLocalAnalyzerFunction", node)
	elseif node.kind == "local_type_function" then
		if node.identifiers_typesystem then
			self:EmitLocalTypeFunction(node)
		else
			self:EmitInvalidLuaCode("EmitLocalTypeFunction", node)
		end
	elseif node.kind == "type_function" then
		self:EmitInvalidLuaCode("EmitTypeFunction", node)
	elseif
		node.kind == "destructure_assignment" or
		node.kind == "local_destructure_assignment"
	then
		if self.config.comment_type_annotations or node.environment == "typesystem" then
			self:EmitInvalidLuaCode("EmitDestructureAssignment", node)
		elseif self.config.transpile_extensions then
			self:EmitTranspiledDestructureAssignment(node)
		else
			self:EmitDestructureAssignment(node)
		end
	elseif node.kind == "assignment" or node.kind == "local_assignment" then
		if node.environment == "typesystem" and self.config.comment_type_annotations then
			self:EmitInvalidLuaCode("EmitAssignment", node)
		else
			self:EmitAssignment(node)

			if node.kind == "assignment" then self:Emit_ENVFromAssignment(node) end
		end
	elseif node.kind == "call_expression" then
		self.is_call_expression = true
		self:EmitExpression(node.value)
		self.is_call_expression = false
	elseif node.kind == "shebang" then
		self:EmitToken(node.tokens["shebang"])
	elseif node.kind == "continue" then
		self:EmitContinueStatement(node)
	elseif node.kind == "semicolon" then
		self:EmitSemicolonStatement(node)

		if self.config.preserve_whitespace == false then
			if self.out[self.i - 2] and self.out[self.i - 2] == "\n" then
				self.out[self.i - 2] = ""
			end
		end
	elseif node.kind == "end_of_file" then
		self:EmitToken(node.tokens["end_of_file"])
	elseif node.kind == "root" then
		self:BuildCode(node)
	elseif node.kind == "analyzer_debug_code" then
		self:EmitInvalidLuaCode("EmitExpression", node.lua_code)
	elseif node.kind == "parser_debug_code" then
		self:EmitInvalidLuaCode("EmitExpression", node.lua_code)
	elseif node.kind then
		error("unhandled statement: " .. node.kind)
	else
		for k, v in pairs(node) do
			print(k, v)
		end

		error("invalid statement: " .. tostring(node))
	end

	if self.OnEmitStatement then
		if node.kind ~= "end_of_file" then self:OnEmitStatement() end
	end
end

local function general_kind(self, node)
	if node.kind == "call_expression" then
		for i, v in ipairs(node.value.expressions) do
			if v.kind == "function" then return "other" end
		end
	end

	if
		node.kind == "call_expression" or
		node.kind == "local_assignment" or
		node.kind == "assignment" or
		node.kind == "return"
	then
		return "expression_statement"
	end

	return "other"
end

function META:EmitStatements(tbl)
	for i, node in ipairs(tbl) do
		if i > 1 and general_kind(self, node) == "other" and node.kind ~= "end_of_file" then
			self:Whitespace("\n")
		end

		self:Whitespace("\t")
		self:EmitStatement(node)

		if
			node.kind ~= "semicolon" and
			node.kind ~= "end_of_file" and
			tbl[i + 1] and
			tbl[i + 1].kind ~= "end_of_file"
		then
			self:Whitespace("\n")
		end

		if general_kind(self, node) == "other" then
			if tbl[i + 1] and general_kind(self, tbl[i + 1]) == "expression_statement" then
				self:Whitespace("\n")
			end
		end
	end
end

function META:ShouldBreakExpressionList(tbl)
	if self.config.preserve_whitespace == false then
		if #tbl == 0 then return false end

		local first_node = tbl[1]
		local last_node = tbl[#tbl]
		--first_node = first_node:GetStatement()
		--last_node = last_node:GetStatement()
		local start = first_node.code_start
		local stop = last_node.code_stop
		return (stop - start) > self.config.max_line_length
	end

	return false
end

function META:EmitNodeList(tbl, func)
	for i = 1, #tbl do
		self:PushForcedLineBreaking(self:ShouldLineBreakNode(tbl[i]))
		local break_binary = self:IsLineBreaking() and tbl[i].kind == "binary_operator"

		if break_binary then self:Indent() end

		func(self, tbl[i])

		if break_binary then self:Outdent() end

		self:PopForcedLineBreaking()

		if i ~= #tbl then
			self:EmitToken(tbl[i].tokens[","])

			if self:IsLineBreaking() then
				self:Whitespace("\n")
				self:Whitespace("\t")
			else
				self:Whitespace(" ")
			end
		end
	end
end

function META:HasTypeNotation(node)
	return node.type_expression or node:GetLastType() or node.return_types
end

function META:EmitFunctionReturnAnnotationExpression(node, analyzer_function)
	if node.tokens["return:"] then
		self:EmitToken(node.tokens["return:"])
	else
		self:EmitNonSpace(":")
	end

	self:Whitespace(" ")

	if node.return_types then
		for i, exp in ipairs(node.return_types) do
			self:EmitTypeExpression(exp)

			if i ~= #node.return_types then self:EmitToken(exp.tokens[","]) end
		end
	elseif node:GetLastType() and self.config.type_annotations ~= "explicit" then
		local str = {}
		-- this iterates the first return tuple
		local obj = node:GetLastType():GetContract() or node:GetLastType()

		if obj.Type == "function" then
			for i, v in ipairs(obj:GetOutputSignature():GetData()) do
				str[i] = tostring(v)
			end
		else
			str[1] = tostring(obj)
		end

		if str[1] then self:EmitNonSpace(table.concat(str, ", ")) end
	end
end

function META:EmitFunctionReturnAnnotation(node, analyzer_function)
	if not self.config.type_annotations then return end

	if self:HasTypeNotation(node) and node.tokens["return:"] then
		self:EmitInvalidLuaCode("EmitFunctionReturnAnnotationExpression", node, analyzer_function)
	end
end

function META:EmitAnnotationExpression(node)
	if node.type_expression then
		self:EmitTypeExpression(node.type_expression)
	elseif node:GetLastType() and self.config.type_annotations ~= "explicit" then
		self:Emit(tostring(node:GetLastType():GetContract() or node:GetLastType()))
	end
end

function META:EmitAsAnnotationExpression(node)
	self:OptionalWhitespace()
	self:Whitespace(" ")
	self:EmitToken(node.tokens["as"])
	self:Whitespace(" ")
	self:EmitAnnotationExpression(node)
end

function META:EmitColonAnnotationExpression(node)
	if node.tokens[":"] then
		self:EmitToken(node.tokens[":"])
	else
		self:EmitNonSpace(":")
	end

	self:Whitespace(" ")
	self:EmitAnnotationExpression(node)
end

function META:EmitAnnotation(node)
	if not self.config.type_annotations then return end

	if self:HasTypeNotation(node) and not node.tokens["as"] then
		self:EmitInvalidLuaCode("EmitColonAnnotationExpression", node)
	end
end

function META:EmitIdentifier(node)
	if node.identifier then
		self:EmitToken(node.identifier)

		if not self.config.omit_invalid_code then
			local ok = self:StartEmittingInvalidLuaCode()
			self:EmitToken(node.tokens[":"])
			self:Whitespace(" ")
			self:EmitTypeExpression(node)
			self:StopEmittingInvalidLuaCode(ok)
		end

		return
	end

	self:EmitExpression(node)
end

do -- types
	function META:EmitTypeBinaryOperator(node)
		if node.left then self:EmitTypeExpression(node.left) end

		if node.value.value == "." or node.value.value == ":" then
			self:EmitToken(node.value)
		else
			self:Whitespace(" ")
			self:EmitToken(node.value)
			self:Whitespace(" ")
		end

		if node.right then self:EmitTypeExpression(node.right) end
	end

	function META:EmitType(node)
		self:EmitToken(node.value)
		self:EmitAnnotation(node)
	end

	function META:EmitTableType(node)
		local tree = node
		self:EmitToken(tree.tokens["{"])
		local newline = self:ShouldLineBreakNode(tree)

		if newline then
			self:Indent()
			self:Whitespace("\n")
		end

		if tree.children[1] then
			for i, node in ipairs(tree.children) do
				if newline then self:Whitespace("\t") end

				if node.kind == "table_index_value" then
					if node.spread then
						self:EmitToken(node.spread.tokens["..."])
						self:EmitExpression(node.spread.expression)
					else
						self:EmitTypeExpression(node.value_expression)
					end
				elseif node.kind == "table_key_value" then
					self:EmitToken(node.tokens["identifier"])
					self:Whitespace(" ")
					self:EmitToken(node.tokens["="])
					self:Whitespace(" ")
					self:EmitTypeExpression(node.value_expression)
				elseif node.kind == "table_expression_value" then
					self:EmitToken(node.tokens["["])
					self:EmitTypeExpression(node.key_expression)
					self:EmitToken(node.tokens["]"])
					self:Whitespace(" ")
					self:EmitToken(node.tokens["="])
					self:Whitespace(" ")
					self:EmitTypeExpression(node.value_expression)
				end

				if tree.tokens["separators"][i] then
					self:EmitToken(tree.tokens["separators"][i])
				else
					if newline then self:EmitNonSpace(",") end
				end

				if newline then
					self:Whitespace("\n")
				else
					if i ~= #tree.children then self:Whitespace(" ") end
				end
			end
		end

		if newline then
			self:Outdent()
			self:Whitespace("\t")
		end

		self:EmitToken(tree.tokens["}"])
	end

	function META:EmitAnalyzerFunction(node)
		if node.tokens["analyzer"] then
			self:EmitToken(node.tokens["analyzer"])
			self:Whitespace(" ")
		end

		self:EmitToken(node.tokens["function"])

		if node.tokens["^"] then self:EmitToken(node.tokens["^"]) end

		self:EmitToken(node.tokens["arguments("])

		for i, exp in ipairs(node.identifiers) do
			if not self.config.type_annotations and node.statements then
				if exp.identifier then
					self:EmitToken(exp.identifier)
				else
					self:EmitTypeExpression(exp)
				end
			else
				if exp.identifier then
					self:EmitToken(exp.identifier)
					self:EmitToken(exp.tokens[":"])
					self:Whitespace(" ")
				end

				self:EmitTypeExpression(exp)
			end

			if i ~= #node.identifiers then
				if exp.tokens[","] then
					self:EmitToken(exp.tokens[","])
					self:Whitespace(" ")
				end
			end
		end

		self:EmitToken(node.tokens["arguments)"])

		if node.tokens[":"] then
			self:EmitToken(node.tokens[":"])
			self:Whitespace(" ")

			for i, exp in ipairs(node.return_types) do
				self:EmitTypeExpression(exp)

				if i ~= #node.return_types then
					self:EmitToken(exp.tokens[","])
					self:Whitespace(" ")
				end
			end
		end

		if node.statements then
			self:Whitespace("\n")
			self:EmitBlock(node.statements)
			self:Whitespace("\n")
			self:Whitespace("\t")
			self:EmitToken(node.tokens["end"])
		end
	end

	function META:EmitTypeExpression(node)
		if node.tokens["("] then
			for i = #node.tokens["("], 1, -1 do
				self:EmitToken(node.tokens["("][i])
			end
		end

		if node.kind == "binary_operator" then
			self:EmitTypeBinaryOperator(node)
		elseif node.kind == "analyzer_function" then
			self:EmitAnalyzerFunction(node)
		elseif node.kind == "table" then
			self:EmitTable(node)
		elseif node.kind == "prefix_operator" then
			self:EmitPrefixOperator(node)
		elseif node.kind == "postfix_operator" then
			self:EmitPostfixOperator(node)
		elseif node.kind == "postfix_call" then
			self:EmitCall(node)
		elseif node.kind == "postfix_expression_index" then
			self:EmitExpressionIndex(node)
		elseif node.kind == "value" then
			self:EmitToken(node.value)
		elseif node.kind == "type_table" then
			self:EmitTableType(node)
		elseif node.kind == "table_expression_value" then
			self:EmitTableExpressionValue(node)
		elseif node.kind == "table_key_value" then
			self:EmitTableKeyValue(node)
		elseif node.kind == "empty_union" then
			self:EmitEmptyUnion(node)
		elseif node.kind == "tuple" then
			self:EmitTuple(node)
		elseif node.kind == "type_function" then
			self:EmitTypeFunction(node)
		elseif node.kind == "function" then
			self:EmitAnonymousFunction(node)
		elseif node.kind == "function_signature" then
			self:EmitFunctionSignature(node)
		elseif node.kind == "vararg" then
			self:EmitVararg(node)
		else
			error("unhandled token type " .. node.kind)
		end

		if node.tokens["as"] then
			self:Whitespace(" ")
			self:EmitToken(node.tokens["as"])
			self:Whitespace(" ")
		end

		if node.type_expression then
			self:EmitTypeExpression(node.type_expression)
		end

		if node.tokens[")"] then
			for _, node in ipairs(node.tokens[")"]) do
				self:EmitToken(node)
			end
		end

		if node.tokens[")"] and newlines then
			self:Outdent()
			self:Whitespace("\n")
			self:Whitespace("\t")
		end
	end

	function META:StartEmittingInvalidLuaCode()
		local emitted = false

		if self.config.comment_type_annotations then
			if not self.during_comment_type or self.during_comment_type == 0 then
				self:EmitNonSpace("--[[#")
				emitted = #self.out
			end

			self.during_comment_type = self.during_comment_type or 0
			self.during_comment_type = self.during_comment_type + 1
		end

		return emitted
	end

	function META:StopEmittingInvalidLuaCode(emitted)
		if emitted then
			if self:GetPrevChar() == B("]") then self:Whitespace(" ") end

			local needs_escape = false

			for i = emitted, #self.out do
				local str = self.out[i]

				if str:find("]]", nil, true) then
					self.out[emitted] = "--[=[#"
					needs_escape = true

					break
				end
			end

			if needs_escape then
				self:EmitNonSpace("]=]")
			else
				self:EmitNonSpace("]]")
			end
		end

		if self.config.comment_type_annotations then
			self.during_comment_type = self.during_comment_type - 1
		end
	end

	function META:EmitInvalidLuaCode(func, ...)
		if self.config.omit_invalid_code then return true end

		local i = self.i
		local emitted = self:StartEmittingInvalidLuaCode()
		self[func](self, ...)
		self:StopEmittingInvalidLuaCode(emitted)

		if self.config.blank_invalid_code then
			for i = self.i, i, -1 do
				if self.out[i] then self.out[i] = self.out[i]:gsub("%S+", "") end
			end
		end

		return emitted
	end
end

do -- extra
	function META:EmitTranspiledDestructureAssignment(node)
		self:EmitToken(node.tokens["{"], "")

		if node.default then
			self:EmitToken(node.default.value)
			self:EmitToken(node.default_comma)
		end

		self:EmitToken(node.tokens["{"], "")
		self:Whitespace(" ")
		self:EmitIdentifierList(node.left)
		self:EmitToken(node.tokens["}"], "")
		self:Whitespace(" ")
		self:EmitToken(node.tokens["="])
		self:Whitespace(" ")
		self:EmitNonSpace("table.destructure(")
		self:EmitExpression(node.right)
		self:EmitNonSpace(",")
		self:EmitSpace(" ")
		self:EmitNonSpace("{")

		for i, v in ipairs(node.left) do
			self:EmitNonSpace("\"")
			self:Emit(v.value.value)
			self:EmitNonSpace("\"")

			if i ~= #node.left then
				self:EmitNonSpace(",")
				self:EmitSpace(" ")
			end
		end

		self:EmitNonSpace("}")

		if node.default then
			self:EmitNonSpace(",")
			self:EmitSpace(" ")
			self:EmitNonSpace("true")
		end

		self:EmitNonSpace(")")
	end

	function META:EmitDestructureAssignment(node)
		if node.tokens["local"] then self:EmitToken(node.tokens["local"]) end

		if node.tokens["type"] then
			self:Whitespace(" ")
			self:EmitToken(node.tokens["type"])
		end

		self:Whitespace(" ")
		self:EmitToken(node.tokens["{"])
		self:Whitespace(" ")
		self:EmitLineBreakableList(node.left, self.EmitIdentifierList)
		self:PopForcedLineBreaking()
		self:Whitespace(" ")
		self:EmitToken(node.tokens["}"])
		self:Whitespace(" ")
		self:EmitToken(node.tokens["="])
		self:Whitespace(" ")
		self:EmitExpression(node.right)
	end

	function META:Emit_ENVFromAssignment(node)
		for i, v in ipairs(node.left) do
			if v.kind == "value" and v.value.value == "_ENV" then
				if node.right[i] then
					local key = node.left[i]
					local val = node.right[i]
					self:EmitNonSpace(";setfenv(1, _ENV);")
				end
			end
		end
	end

	function META:EmitImportExpression(node)
		if not node.path then
			self:EmitToken(node.left.value)

			if node.tokens["call("] then
				self:EmitToken(node.tokens["call("])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace("(")
			end

			self:EmitExpressionList(node.expressions)

			if node.tokens["call)"] then
				self:EmitToken(node.tokens["call)"])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace(")")
			end

			return
		end

		if node.left.value.value == "loadfile" then
			self:EmitToken(node.left.value, "IMPORTS['" .. node.key .. "']")
		else
			self:EmitToken(node.left.value, "IMPORTS['" .. node.key .. "']")

			if node.tokens["call("] then
				self:EmitToken(node.tokens["call("])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace("(")
			end

			self:EmitExpressionList(node.expressions)

			if node.tokens["call)"] then
				self:EmitToken(node.tokens["call)"])
			elseif self.config.force_parenthesis then
				self:EmitNonSpace(")")
			end
		end
	end

	function META:EmitRequireExpression(node)
		self:EmitToken(node.tokens["require"])
		self:EmitToken(node.tokens["arguments("])
		self:EmitExpressionList(node.expressions)
		self:EmitToken(node.tokens["arguments)"])
	end
end

function META.New(config)
	local self = setmetatable({}, META)
	self.config = config or {}
	self.config.max_argument_length = self.config.max_argument_length or 5
	self.config.max_line_length = self.config.max_line_length or 80

	if self.config.comment_type_annotations == nil then
		self.config.comment_type_annotations = true
	end

	self:Initialize()
	return self
end

return META end ]=======], '@./nattlua/transpiler/emitter.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.function"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local tostring = tostring
local table = _G.table
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local Function = IMPORTS['nattlua.types.function']("nattlua.types.function").Function
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local VarArg = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").VarArg
local ipairs = _G.ipairs
local Emitter = IMPORTS['nattlua.transpiler.emitter']("nattlua.transpiler.emitter").New

local function analyze_arguments(self, node)
	local args = {}

	if node.self_call and node.expression then
		self:PushAnalyzerEnvironment("runtime")
		local val = self:AnalyzeExpression(node.expression.left):GetFirstValue()
		self:PopAnalyzerEnvironment()

		if val then
			if val:GetContract() or val.Self or self:IsTypesystem() then
				args[1] = val.Self or val
			else
				args[1] = Union({Any(), val})
			end

			self:CreateLocalValue("self", args[1]):SetNode(node.expression.left)
		end
	end

	if node.kind == "function" or node.kind == "local_function" then
		for i, key in ipairs(node.identifiers) do
			if node.self_call then i = i + 1 end

			-- stem type so that we can allow
			-- function(x: foo<|x|>): nil
			self:CreateLocalValue(key.value.value, Any()):SetNode(key)

			if key.type_expression then
				args[i] = self:Assert(self:AnalyzeExpression(key.type_expression)) or Any()
			elseif key.value.value == "..." then
				args[i] = VarArg(Any())
			else
				args[i] = Any()
			end

			self:CreateLocalValue(key.value.value, assert(args[i])):SetNode(key)
		end
	elseif
		node.kind == "analyzer_function" or
		node.kind == "local_analyzer_function" or
		node.kind == "local_type_function" or
		node.kind == "type_function" or
		node.kind == "function_signature"
	then
		if node.identifiers_typesystem then
			for i, generic_type in ipairs(node.identifiers_typesystem) do
				if generic_type.identifier and generic_type.identifier.value ~= "..." then
					self:CreateLocalValue(generic_type.identifier.value, self:AnalyzeExpression(generic_type):GetFirstValue()):SetNode(generic_type)
				elseif generic_type.type_expression then
					self:CreateLocalValue(generic_type.value.value, Any(), i):SetNode(generic_type)
				end
			end
		end

		for i, key in ipairs(node.identifiers) do
			if node.self_call then i = i + 1 end

			if key.identifier and key.identifier.value ~= "..." then
				args[i] = self:AnalyzeExpression(key):GetFirstValue()
				self:CreateLocalValue(key.identifier.value, args[i]):SetNode(key)
			elseif key.kind == "vararg" then
				args[i] = self:AnalyzeExpression(key)
			elseif key.type_expression then
				self:CreateLocalValue(key.value.value, Any(), i):SetNode(key)
				args[i] = self:AnalyzeExpression(key.type_expression)
			elseif key.kind == "value" then
				if not node.statements then
					local obj = self:AnalyzeExpression(key)

					if i == 1 and obj.Type == "tuple" and #node.identifiers == 1 then
						-- if we pass in a tuple we override the argument type
						-- function(mytuple): string
						return obj
					else
						local val = self:Assert(obj)

						-- in case the tuple is empty
						if val then args[i] = val end
					end
				else
					args[i] = Any()
				end
			else
				local obj = self:AnalyzeExpression(key)

				if i == 1 and obj.Type == "tuple" and #node.identifiers == 1 then
					-- if we pass in a tuple we override the argument type
					-- function(mytuple): string
					return obj
				else
					local val = self:Assert(obj)

					-- in case the tuple is empty
					if val then args[i] = val end
				end
			end
		end
	else
		self:FatalError("unhandled statement " .. tostring(node))
	end

	return Tuple(args)
end

local function analyze_return_types(self, node)
	local ret = {}

	if node.return_types then
		-- TODO:
		-- somethings up with function(): (a,b,c)
		-- when doing this vesrus function(): a,b,c
		-- the return tuple becomes a tuple inside a tuple
		for i, type_exp in ipairs(node.return_types) do
			local obj = self:AnalyzeExpression(type_exp)

			if i == 1 and obj.Type == "tuple" and #node.identifiers == 1 and not obj.Repeat then
				-- if we pass in a tuple, we want to override the return type
				-- function(): mytuple
				return obj
			else
				ret[i] = obj
			end
		end
	end

	return Tuple(ret)
end

local function has_explicit_arguments(node)
	if
		node.kind == "analyzer_function" or
		node.kind == "local_analyzer_function" or
		node.kind == "local_type_function" or
		node.kind == "type_function" or
		node.kind == "function_signature"
	then
		return true
	end

	if node.kind == "function" or node.kind == "local_function" then
		for i, key in ipairs(node.identifiers) do
			if key.type_expression then return true end
		end
	end

	return false
end

local function has_expicit_return_type(node)
	if node.return_types then return true end

	return false
end

return {
	AnalyzeFunction = function(self, node)
		local obj = Function()
		obj:SetUpvaluePosition(#self:GetScope():GetUpvalues("runtime"))
		obj:SetScope(self:GetScope())
		obj:SetInputIdentifiers(node.identifiers)
		self:PushCurrentType(obj, "function")
		self:CreateAndPushFunctionScope(obj)
		self:PushAnalyzerEnvironment("typesystem")
		obj:SetInputSignature(analyze_arguments(self, node))
		obj:SetOutputSignature(analyze_return_types(self, node))
		self:PopAnalyzerEnvironment()
		self:PopScope()
		self:PopCurrentType("function")

		if node.kind == "analyzer_function" or node.kind == "local_analyzer_function" then
			local em = Emitter({type_annotations = false})
			em:EmitFunctionBody(node)
			em:EmitToken(node.tokens["end"])
			obj:SetAnalyzerFunction(self:CompileLuaAnalyzerDebugCode("return function " .. em:Concat(), node)())
		end

		if node.statements then obj:SetFunctionBodyNode(node) end

		obj:SetExplicitInputSignature(has_explicit_arguments(node))
		obj:SetExplicitOutputSignature(has_expicit_return_type(node))

		if self:IsRuntime() then self:AddToUnreachableCodeAnalysis(obj) end

		return obj
	end,
} end ]=======], '@./nattlua/analyzer/expressions/function.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.function"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local AnalyzeFunction = IMPORTS['nattlua.analyzer.expressions.function']("nattlua.analyzer.expressions.function").AnalyzeFunction
local NodeToString = IMPORTS['nattlua.types.string']("nattlua.types.string").NodeToString
return {
	AnalyzeFunction = function(self, statement)
		if
			statement.kind == "local_function" or
			statement.kind == "local_analyzer_function" or
			statement.kind == "local_type_function"
		then
			self:PushAnalyzerEnvironment(statement.kind == "local_function" and "runtime" or "typesystem")
			self:CreateLocalValue(statement.tokens["identifier"].value, AnalyzeFunction(self, statement))
			self:PopAnalyzerEnvironment()
		elseif
			statement.kind == "function" or
			statement.kind == "analyzer_function" or
			statement.kind == "type_function"
		then
			local key = statement.expression
			self:PushAnalyzerEnvironment(statement.kind == "function" and "runtime" or "typesystem")

			if key.kind == "binary_operator" then
				local obj = self:AnalyzeExpression(key.left)
				local key = self:AnalyzeExpression(key.right)
				local val = AnalyzeFunction(self, statement)
				self:NewIndexOperator(obj, key, val)
			else
				self.current_expression = key
				local key = NodeToString(key)
				local val = AnalyzeFunction(self, statement)
				self:SetLocalOrGlobalValue(key, val)
			end

			self:PopAnalyzerEnvironment()
		else
			self:FatalError("unhandled statement: " .. statement.kind)
		end
	end,
} end ]=======], '@./nattlua/analyzer/statements/function.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.if"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union

local function contains_ref_argument(upvalues)
	for _, v in pairs(upvalues) do
		if v.upvalue:GetValue():IsReferenceArgument() or v.upvalue:GetValue().from_for_loop then
			return true
		end
	end

	return false
end

return {
	AnalyzeIf = function(self, statement)
		local prev_expression
		local blocks = {}

		for i, statements in ipairs(statement.statements) do
			if statement.expressions[i] then
				self.current_if_statement = statement
				local exp = statement.expressions[i]
				local no_operator_expression = exp.kind ~= "binary_operator" and
					exp.kind ~= "prefix_operator" or
					(
						exp.kind == "binary_operator" and
						exp.value.value == "."
					)

				if no_operator_expression then self:PushTruthyExpressionContext(true) end

				local obj = self:AnalyzeExpression(exp)
				self.current_expression = exp

				if no_operator_expression then self:PopTruthyExpressionContext() end

				if no_operator_expression then
					-- track "if x then" which has no binary or prefix operators
					if obj.Type == "union" then
						self:TrackUpvalueUnion(obj, obj:GetTruthy(), obj:GetFalsy())
					else
						self:TrackUpvalue(obj)
					end
				end

				self.current_if_statement = nil
				prev_expression = obj

				if obj:IsTruthy() then
					local upvalues = self:GetTrackedUpvalues()
					local tables = self:GetTrackedTables()
					self:ClearTracked()
					table.insert(
						blocks,
						{
							statements = statements,
							upvalues = upvalues,
							tables = tables,
							expression = obj,
						}
					)

					if obj:IsCertainlyTrue() and self:IsRuntime() then
						if not contains_ref_argument(upvalues) then
							self:Warning("if condition is always true")
						end
					end

					if not obj:IsFalsy() then break end
				end

				if obj:IsCertainlyFalse() and self:IsRuntime() then
					if not contains_ref_argument(self:GetTrackedUpvalues()) then
						self:Warning("if condition is always false")
					end
				end
			else
				if prev_expression:IsCertainlyFalse() and self:IsRuntime() then
					if not contains_ref_argument(self:GetTrackedUpvalues()) then
						self:Warning("else part of if condition is always true")
					end
				end

				if prev_expression:IsFalsy() then
					table.insert(
						blocks,
						{
							statements = statements,
							upvalues = blocks[#blocks] and blocks[#blocks].upvalues,
							tables = blocks[#blocks] and blocks[#blocks].tables,
							expression = prev_expression,
							is_else = true,
						}
					)
				end
			end
		end

		local last_scope

		for i, block in ipairs(blocks) do
			block.scope = self:GetScope()
			local scope = self:PushConditionalScope(statement, block.expression:IsTruthy(), block.expression:IsFalsy())

			if last_scope then
				last_scope:SetNextConditionalSibling(scope)
				scope:SetPreviousConditionalSibling(last_scope)
			end

			last_scope = scope
			scope:SetTrackedUpvalues(block.upvalues)
			scope:SetTrackedTables(block.tables)

			if block.is_else then
				scope:SetElseConditionalScope(true)
				self:ApplyMutationsInIfElse(blocks)
			else
				self:ApplyMutationsInIf(block.upvalues, block.tables)
			end

			self:AnalyzeStatements(block.statements)
			self:PopConditionalScope()
		end

		self:ClearTracked()
	end,
} end ]=======], '@./nattlua/analyzer/statements/if.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.do"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzeDo = function(self, statement)
		self:CreateAndPushScope()
		self:AnalyzeStatements(statement.statements)
		self:PopScope()
	end,
} end ]=======], '@./nattlua/analyzer/statements/do.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.generic_for"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local table = _G.table
local ipairs = ipairs
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local NormalizeTuples = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").NormalizeTuples
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
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
} end ]=======], '@./nattlua/analyzer/statements/generic_for.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.call_expression"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzeCall = function(self, statement)
		self:AnalyzeExpression(statement.value)
	end,
} end ]=======], '@./nattlua/analyzer/statements/call_expression.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.binary"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local tostring = tostring
local ipairs = ipairs
local table = _G.table
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local String = IMPORTS['nattlua.types.string']("nattlua.types.string").String
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local True = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").True
local Boolean = IMPORTS['nattlua.types.union']("nattlua.types.union").Boolean
local Symbol = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Symbol
local False = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").False
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local Number = IMPORTS['nattlua.types.number']("nattlua.types.number").Number
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")

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

local function logical_cmp_cast(val, err)
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

return {Binary = Binary} end ]=======], '@./nattlua/analyzer/operators/binary.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.numeric_for"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local math = math
local assert = assert
local True = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").True
local LNumber = IMPORTS['nattlua.types.number']("nattlua.types.number").LNumber
local False = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").False
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Binary = IMPORTS['nattlua.analyzer.operators.binary']("nattlua.analyzer.operators.binary").Binary

local function get_largest_number(obj)
	if obj:IsLiteral() then
		if obj.Type == "union" then
			local max = -math.huge

			for _, v in ipairs(obj:GetData()) do
				max = math.max(max, v:GetData())
			end

			return max
		end

		return obj:GetData()
	end
end

return {
	AnalyzeNumericFor = function(self, statement)
		local init = self:AnalyzeExpression(statement.expressions[1]):GetFirstValue()
		local max = self:AnalyzeExpression(statement.expressions[2]):GetFirstValue()
		local step = statement.expressions[3] and
			self:AnalyzeExpression(statement.expressions[3]):GetFirstValue() or
			nil

		if step then assert(step.Type == "number") end

		local literal_init = get_largest_number(init)
		local literal_max = get_largest_number(max)
		local literal_step = not step and 1 or get_largest_number(step)
		local condition = Union()

		if literal_init and literal_max then
			-- also check step
			condition:AddType(Binary(self, statement, init, max, "<="))
		else
			condition:AddType(True())
			condition:AddType(False())
		end

		self:PushConditionalScope(statement, condition:IsTruthy(), condition:IsFalsy())
		self:GetScope():SetLoopScope(true)

		if literal_init and literal_max and literal_step and literal_max < 1000 then
			for i = literal_init, literal_max, literal_step do
				self:PushConditionalScope(statement, condition:IsTruthy(), condition:IsFalsy())
				local i = LNumber(i)
				local brk = false
				local uncertain_break = self:DidUncertainBreak()

				if uncertain_break then
					self:PushUncertainLoop(true)
					i:SetLiteral(false)
					brk = true
				end

				i.from_for_loop = true
				self:CreateLocalValue(statement.identifiers[1].value.value, i)
				self:AnalyzeStatements(statement.statements)

				if self._continue_ then self._continue_ = nil end

				self:PopConditionalScope()

				if self:DidCertainBreak() then brk = true end

				if uncertain_break then self:PopUncertainLoop() end

				if brk then
					self:ClearBreak()

					break
				end
			end
		else
			if literal_init then
				init = LNumber(literal_init)
				init.dont_widen = true

				if max.Type == "number" or (max.Type == "union" and max:IsType("number")) then
					if not max:IsLiteral() then
						init:SetMax(LNumber(math.huge))
					else
						init:SetMax(max)
					end
				end
			else
				if
					init.Type == "number" and
					(
						max.Type == "number" or
						(
							max.Type == "union" and
							max:IsType("number")
						)
					)
				then
					init = self:Assert(init:SetMax(max))
				end

				if max.Type == "any" then init:SetLiteral(false) end
			end

			self:PushUncertainLoop(true)
			local range = self:Assert(init)
			self:CreateLocalValue(statement.identifiers[1].value.value, range)
			self:AnalyzeStatements(statement.statements)
			self:PopUncertainLoop()
		end

		self:PopConditionalScope()
	end,
} end ]=======], '@./nattlua/analyzer/statements/numeric_for.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.break"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzeBreak = function(self, statement)
		self:Break()
	end,
} end ]=======], '@./nattlua/analyzer/statements/break.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.continue"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzeContinue = function(self, statement)
		self._continue_ = true
	end,
} end ]=======], '@./nattlua/analyzer/statements/continue.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.repeat"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzeRepeat = function(self, statement)
		self:CreateAndPushScope()
		self:AnalyzeStatements(statement.statements)
		self:PopScope()
	end,
} end ]=======], '@./nattlua/analyzer/statements/repeat.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.return"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
return {
	AnalyzeReturn = function(self, statement)
		local ret = self:AnalyzeExpressions(statement.expressions)
		self:Return(statement, ret)
	end,
} end ]=======], '@./nattlua/analyzer/statements/return.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.analyzer_debug_code"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzeAnalyzerDebugCode = function(self, statement)
		local code = statement.lua_code.value.value:sub(3)
		self:CallLuaTypeFunction(self:CompileLuaAnalyzerDebugCode(code, statement.lua_code), self:GetScope())
	end,
} end ]=======], '@./nattlua/analyzer/statements/analyzer_debug_code.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.while"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzeWhile = function(self, statement)
		local obj = self:AnalyzeExpression(statement.expression)
		local upvalues = self:GetTrackedUpvalues()
		local tables = self:GetTrackedTables()
		self:ClearTracked()

		if obj:IsCertainlyFalse() then
			self:Warning("loop expression is always false")
		end

		if obj:IsTruthy() then
			self:ApplyMutationsInIf(upvalues, tables)

			for i = 1, 32 do
				self:PushConditionalScope(statement, obj:IsTruthy(), obj:IsFalsy())
				self:PushUncertainLoop(obj:IsTruthy() and obj:IsFalsy())
				self:GetScope():SetLoopScope(true)
				self:AnalyzeStatements(statement.statements)
				self:PopUncertainLoop()
				self:PopConditionalScope()

				if self:DidCertainBreak() or self:DidUncertainBreak() then
					self:ClearBreak()

					break
				end

				if self:GetScope():DidCertainReturn() then break end

				local obj = self:AnalyzeExpression(statement.expression)

				if obj:IsUncertain() or obj:IsFalsy() then break end

				if i == 32 and self:IsRuntime() then self:Warning("too many iterations") end
			end
		end
	end,
} end ]=======], '@./nattlua/analyzer/statements/while.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.statements.assignment"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local tostring = tostring
local table = _G.table
local NodeToString = IMPORTS['nattlua.types.string']("nattlua.types.string").NodeToString
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil

local function check_type_against_contract(val, contract)
	-- if the contract is unique / nominal, ie
	-- local a: Person = {name = "harald"}
	-- Person is not a subset of {name = "harald"} because
	-- Person is only equal to Person
	-- so we need to disable this check during assignment
	local skip_uniqueness = contract:IsUnique() and not val:IsUnique()

	if skip_uniqueness then contract:DisableUniqueness() end

	local ok, reason = val:IsSubsetOf(contract)

	if skip_uniqueness then
		contract:EnableUniqueness()
		val:SetUniqueID(contract:GetUniqueID())
	end

	if not ok then return ok, reason end

	-- make sure the table contains all the keys in the contract as well
	-- since {foo = true, bar = "harald"} 
	-- is technically a subset of 
	-- {foo = true, bar = "harald", baz = "jane"}
	if contract.Type == "table" and val.Type == "table" then
		return val:ContainsAllKeysIn(contract)
	end

	return true
end

return {
	AnalyzeAssignment = function(self, statement)
		local left = {}
		local right = {}

		-- first we evaluate the left hand side
		for left_pos, exp_key in ipairs(statement.left) do
			if exp_key.kind == "value" then
				-- local foo, bar = *
				left[left_pos] = NodeToString(exp_key, true)
			elseif exp_key.kind == "postfix_expression_index" then
				-- foo[bar] = *
				left[left_pos] = self:AnalyzeExpression(exp_key.expression)
			elseif exp_key.kind == "binary_operator" then
				-- foo.bar = *
				left[left_pos] = self:AnalyzeExpression(exp_key.right)
			else
				self:FatalError("unhandled assignment expression " .. tostring(exp_key:Render()))
			end
		end

		if statement.right then
			for right_pos, exp_val in ipairs(statement.right) do
				-- when "self" is looked up in the typesystem in analyzer:AnalyzeExpression, we refer left[right_pos]
				-- use context?
				self.left_assigned = left[right_pos]
				local obj = self:Assert(self:AnalyzeExpression(exp_val))
				self:ClearTracked()

				if obj.Type == "tuple" and obj:GetLength() == 1 then
					obj = obj:Get(1)
				end

				if obj.Type == "tuple" then
					if self:IsRuntime() then
						-- at runtime unpack the tuple
						for i = 1, #statement.left do
							local index = right_pos + i - 1
							right[index] = obj:Get(i)
						end
					end

					if self:IsTypesystem() then
						if obj:HasTuples() then
							-- if we have a tuple with, plainly unpack the tuple while preserving the tuples inside
							for i = 1, #statement.left do
								local index = right_pos + i - 1
								right[index] = obj:GetWithoutExpansion(i)
							end
						else
							-- otherwise plainly assign it
							right[right_pos] = obj
						end
					end
				elseif obj.Type == "union" then
					-- if the union is empty or has no tuples, just assign it
					if obj:IsEmpty() or not obj:HasTuples() then
						right[right_pos] = obj
					else
						for i = 1, #statement.left do
							-- unpack unions with tuples
							-- ⦗false, string, 2⦘ | ⦗true, 1⦘ at first index would be true | false
							local index = right_pos + i - 1
							right[index] = obj:GetAtIndex(index)
						end
					end
				else
					right[right_pos] = obj

					-- when the right side has a type expression, it's invoked using the as operator
					if exp_val.type_expression then obj:Seal() end
				end
			end

			-- cuts the last arguments
			-- local funciton test() return 1,2,3 end
			-- local a,b,c = test(), 1337
			-- a should be 1
			-- b should be 1337
			-- c should be nil
			local last = statement.right[#statement.right]

			if last.kind == "value" and last.value.value ~= "..." then
				for _ = 1, #right - #statement.right do
					table.remove(right, #right)
				end
			end
		end

		-- here we check the types
		for left_pos, exp_key in ipairs(statement.left) do
			local val = right[left_pos] or Nil()

			-- do we have a type expression? 
			-- local a: >>number<< = 1
			if exp_key.type_expression then
				self:PushAnalyzerEnvironment("typesystem")
				local contract = self:AnalyzeExpression(exp_key.type_expression)
				self:PopAnalyzerEnvironment()

				if right[left_pos] then
					local contract = contract

					if contract.Type == "tuple" and contract:GetLength() == 1 then
						contract = contract:Get(1)
					end

					-- we copy the literalness of the contract so that
					-- local a: number = 1
					-- becomes
					-- local a: number = number
					val:CopyLiteralness(contract)

					if val.Type == "table" and contract.Type == "table" then
						-- coerce any untyped functions based on contract
						val:CoerceUntypedFunctions(contract)
					end

					self.current_expression = exp_key
					self:Assert(check_type_against_contract(val, contract))
				else
					if contract.Type == "tuple" and contract:GetLength() == 1 then
						contract = contract:Get(1)
					end
				end

				-- we set a's contract to be number
				val:SetContract(contract)

				-- this is for "local a: number" without the right side being assigned
				if not right[left_pos] then
					-- make a copy of the contract and use it
					-- so the value can change independently from the contract
					val = contract:Copy()
					val:SetContract(contract)
				end
			end

			-- used by the emitter
			exp_key:AddType(val)
			val:SetAnalyzerEnvironment(self:GetCurrentAnalyzerEnvironment())

			-- if all is well, create or mutate the value
			if statement.kind == "local_assignment" then
				local immutable = false

				if exp_key.attribute then
					if exp_key.attribute.value == "const" then immutable = true end
				end

				-- local assignment: local a = 1
				self:CreateLocalValue(exp_key.value.value, val, immutable):SetNode(exp_key)
			elseif statement.kind == "assignment" then
				local key = left[left_pos]

				-- plain assignment: a = 1
				if exp_key.kind == "value" then
					if self:IsRuntime() then -- check for any previous upvalues
						local existing_value = self:GetLocalOrGlobalValue(key)
						local contract = existing_value and existing_value:GetContract()

						if contract then
							if contract.Type == "tuple" then
								contract = contract:GetFirstValue()
							end

							if contract then
								val:CopyLiteralness(contract)
								self:Assert(check_type_against_contract(val, contract))
								val:SetContract(contract)
							end
						end
					end

					local val = self:SetLocalOrGlobalValue(key, val)

					if val then
						-- this is used for tracking function dependencies
						if val.Type == "upvalue" then
							self:GetScope():AddDependency(val)
						else
							self:GetScope():AddDependency({key = key, val = val})
						end
					end
				else
					-- TODO: refactor out to mutation assignment?
					-- index assignment: foo[a] = 1
					local obj = self:AnalyzeExpression(exp_key.left)
					self:ClearTracked()

					if self:IsRuntime() then key = key:GetFirstValue() end

					self:Assert(self:NewIndexOperator(obj, key, val))
				end
			end
		end
	end,
} end ]=======], '@./nattlua/analyzer/statements/assignment.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.binary_operator"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local table = _G.table
local Binary = IMPORTS['nattlua.analyzer.operators.binary']("nattlua.analyzer.operators.binary").Binary
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local assert = _G.assert
return {
	AnalyzeBinaryOperator = function(self, node)
		return self:Assert(Binary(self, node))
	end,
} end ]=======], '@./nattlua/analyzer/expressions/binary_operator.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.prefix"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ipairs = ipairs
local error = error
local tostring = tostring
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local type_errors = IMPORTS['nattlua.types.error_messages']("nattlua.types.error_messages")
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local Boolean = IMPORTS['nattlua.types.union']("nattlua.types.union").Boolean
local False = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").False
local True = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").True
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple

local function metatable_function(self, meta_method, l, node)
	if l:GetMetaTable() then
		meta_method = LString(meta_method)
		local func = l:GetMetaTable():Get(meta_method)

		if func then return self:Assert(self:Call(func, Tuple({l}), node):Get(1)) end
	end
end

local function Prefix(self, node, r)
	local op = node.value.value
	self.current_expression = node

	if op == "not" then
		self.inverted_index_tracking = not self.inverted_index_tracking
	end

	if not r then
		r = self:AnalyzeExpression(node.right)

		if node.right.kind ~= "binary_operator" or node.right.value.value ~= "." then
			if r.Type ~= "union" then self:TrackUpvalue(r) end
		end
	end

	if op == "not" then self.inverted_index_tracking = nil end

	if op == "literal" then
		r:SetLiteralArgument(true)
		return r
	end

	if op == "ref" then
		r:SetReferenceArgument(true)
		return r
	end

	if r.Type == "tuple" then r = r:Get(1) or Nil() end

	if r.Type == "union" then
		local new_union = Union()
		local truthy_union = Union():SetUpvalue(r:GetUpvalue())
		local falsy_union = Union():SetUpvalue(r:GetUpvalue())

		for _, r in ipairs(r:GetData()) do
			local res, err = Prefix(self, node, r)

			if not res then
				self:ErrorAndCloneCurrentScope(err, r)
				falsy_union:AddType(r)
			else
				new_union:AddType(res)

				if res:IsTruthy() then truthy_union:AddType(r) end

				if res:IsFalsy() then falsy_union:AddType(r) end
			end
		end

		self:TrackUpvalueUnion(r, truthy_union, falsy_union)
		return new_union
	end

	if r.Type == "any" then return Any() end

	if self:IsTypesystem() then
		if op == "typeof" then
			self:PushAnalyzerEnvironment("runtime")
			local obj = self:AnalyzeExpression(node.right)
			self:PopAnalyzerEnvironment()

			if not obj then
				return type_errors.other("cannot find '" .. node.right:Render() .. "' in the current typesystem scope")
			end

			return obj:GetContract() or obj
		elseif op == "unique" then
			r:MakeUnique(true)
			return r
		elseif op == "mutable" then
			r.mutable = true
			return r
		elseif op == "$" then
			if r.Type ~= "string" then
				return type_errors.other("must evaluate to a string")
			end

			if not r:IsLiteral() then return type_errors.other("must be a literal") end

			r:SetPatternContract(r:GetData())
			return r
		end
	end

	if op == "-" then
		local res = metatable_function(self, "__unm", r, node)

		if res then return res end
	elseif op == "~" then
		local res = metatable_function(self, "__bxor", r, node)

		if res then return res end
	elseif op == "#" then
		local res = metatable_function(self, "__len", r, node)

		if res then return res end
	end

	if op == "not" or op == "!" then
		if r:IsTruthy() and r:IsFalsy() then
			return Boolean()
		elseif r:IsTruthy() then
			return False()
		elseif r:IsFalsy() then
			return True()
		end
	end

	if op == "-" or op == "~" or op == "#" then return r:PrefixOperator(op) end

	error(
		"unhandled prefix operator in " .. self:GetCurrentAnalyzerEnvironment() .. ": " .. op .. tostring(r)
	)
end

return {Prefix = Prefix} end ]=======], '@./nattlua/analyzer/operators/prefix.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.prefix_operator"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Prefix = IMPORTS['nattlua.analyzer.operators.prefix']("nattlua.analyzer.operators.prefix").Prefix
return {
	AnalyzePrefixOperator = function(self, node)
		return self:Assert(Prefix(self, node))
	end,
} end ]=======], '@./nattlua/analyzer/expressions/prefix_operator.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.operators.postfix"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Binary = IMPORTS['nattlua.analyzer.operators.binary']("nattlua.analyzer.operators.binary").Binary
local Node = IMPORTS['nattlua.parser.node']("nattlua.parser.node")
return {
	Postfix = function(self, node, r)
		local op = node.value.value

		if op == "++" then
			return Binary(self, setmetatable({value = {value = "+"}}, Node), r, r)
		end
	end,
} end ]=======], '@./nattlua/analyzer/operators/postfix.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.postfix_operator"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Postfix = IMPORTS['nattlua.analyzer.operators.postfix']("nattlua.analyzer.operators.postfix").Postfix
return {
	AnalyzePostfixOperator = function(self, node)
		return self:Assert(Postfix(self, node, self:AnalyzeExpression(node.left)))
	end,
} end ]=======], '@./nattlua/analyzer/expressions/postfix_operator.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.import"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
return {
	AnalyzeImport = function(self, node)
		-- ugly way of dealing with recursive import
		local root = node.RootStatement

		if root and root.kind ~= "root" then root = root.RootStatement end

		if root then
			return self:AnalyzeRootStatement(root)
		elseif node.data then
			return LString(node.data)
		end

		return Nil()
	end,
} end ]=======], '@./nattlua/analyzer/expressions/import.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.postfix_call"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local table = _G.table
local NormalizeTuples = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").NormalizeTuples
local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
local AnalyzeImport = IMPORTS['nattlua.analyzer.expressions.import']("nattlua.analyzer.expressions.import").AnalyzeImport
return {
	AnalyzePostfixCall = function(self, node)
		if
			node.import_expression and
			node.left.value.value ~= "dofile" and
			node.left.value.value ~= "loadfile"
		then
			return AnalyzeImport(self, node)
		end

		local is_type_call = node.type_call or
			node.left and
			(
				node.left.kind == "local_generics_type_function" or
				node.left.kind == "generics_type_function"
			)
		self:PushAnalyzerEnvironment(is_type_call and "typesystem" or "runtime")
		local callable = self:AnalyzeExpression(node.left)
		local self_arg

		if
			self.self_arg_stack and
			node.left.kind == "binary_operator" and
			node.left.value.value == ":"
		then
			self_arg = table.remove(self.self_arg_stack)
		end

		local types = self:AnalyzeExpressions(node.expressions)

		if self_arg then table.insert(types, 1, self_arg) end

		local arguments

		if self:IsTypesystem() then
			arguments = Tuple(types)
		else
			arguments = NormalizeTuples(types)
		end

		local ret, err = self:Call(callable, arguments, node)
		self.current_expression = node
		local returned_tuple

		if not ret then
			self:Error(err)

			if callable.Type == "function" and callable:IsExplicitOutputSignature() then
				returned_tuple = callable:GetOutputSignature():Copy()
			end
		else
			returned_tuple = ret
		end

		-- TUPLE UNPACK MESS
		if node.tokens["("] and node.tokens[")"] and returned_tuple.Type == "tuple" then
			returned_tuple = returned_tuple:Get(1)
		end

		if self:IsTypesystem() then
			if returned_tuple.Type == "tuple" and returned_tuple:GetLength() == 1 then
				returned_tuple = returned_tuple:Get(1)
			end
		end

		self:PopAnalyzerEnvironment()
		return returned_tuple
	end,
} end ]=======], '@./nattlua/analyzer/expressions/postfix_call.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.postfix_index"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) return {
	AnalyzePostfixIndex = function(self, node)
		return self:Assert(
			self:IndexOperator(
				self:AnalyzeExpression(node.left),
				self:AnalyzeExpression(node.expression):GetFirstValue()
			)
		)
	end,
} end ]=======], '@./nattlua/analyzer/expressions/postfix_index.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.table"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local tostring = tostring
local ipairs = ipairs
local LNumber = IMPORTS['nattlua.types.number']("nattlua.types.number").LNumber
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local Table = IMPORTS['nattlua.types.table']("nattlua.types.table").Table
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local table = _G.table
return {
	AnalyzeTable = function(self, tree)
		local tbl = Table():SetLiteral(self:IsTypesystem())

		if self:IsRuntime() then tbl:SetReferenceId(tostring(tbl:GetData())) end

		self:PushCurrentType(tbl, "table")
		tbl:SetCreationScope(self:GetScope())

		for i, node in ipairs(tree.children) do
			if node.kind == "table_key_value" then
				local key = LString(node.tokens["identifier"].value)
				local val = self:AnalyzeExpression(node.value_expression):GetFirstValue() or Nil()
				self:NewIndexOperator(tbl, key, val)
			elseif node.kind == "table_expression_value" then
				local key = self:AnalyzeExpression(node.key_expression):GetFirstValue()
				local val = self:AnalyzeExpression(node.value_expression):GetFirstValue()
				self:NewIndexOperator(tbl, key, val)
			elseif node.kind == "table_index_value" then
				if node.spread then
					local val = self:AnalyzeExpression(node.spread.expression):GetFirstValue()

					if val.Type == "table" then
						for _, kv in ipairs(val:GetData()) do
							local val = kv.val

							if val.Type == "union" and val:CanBeNil() then
								val = val:Copy():RemoveType(Nil())
							end

							if kv.key.Type == "number" then
								self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), val)
							else
								self:NewIndexOperator(tbl, kv.key, val)
							end
						end
					end
				else
					local obj = self:AnalyzeExpression(node.value_expression)

					if
						node.value_expression.kind ~= "value" or
						node.value_expression.value.value ~= "..."
					then
						obj = obj:GetFirstValue()
					end

					if obj.Type == "tuple" then
						if tree.children[i + 1] then
							self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), obj:Get(1))
						else
							for i = 1, obj:GetMinimumLength() do
								tbl:Set(LNumber(#tbl:GetData() + 1), obj:Get(i))
							end

							if obj.Remainder then
								local current_index = LNumber(#tbl:GetData() + 1)
								local max = LNumber(obj.Remainder:GetLength())
								self:NewIndexOperator(tbl, current_index:SetMax(max), obj.Remainder:Get(1))
							end
						end
					else
						if node.i then
							self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), LNumber(obj))
						elseif obj then
							self:NewIndexOperator(tbl, LNumber(tbl:GetLength(self):GetData() + 1), obj)
						end
					end
				end
			end

			self:ClearTracked()
		end

		self:PopCurrentType("table")
		return tbl
	end,
} end ]=======], '@./nattlua/analyzer/expressions/table.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.atomic_value"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local runtime_syntax = IMPORTS['nattlua.syntax.runtime']("nattlua.syntax.runtime")
local NodeToString = IMPORTS['nattlua.types.string']("nattlua.types.string").NodeToString
local LNumber = IMPORTS['nattlua.types.number']("nattlua.types.number").LNumber
local LNumberFromString = IMPORTS['nattlua.types.number']("nattlua.types.number").LNumberFromString
local Any = IMPORTS['nattlua.types.any']("nattlua.types.any").Any
local True = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").True
local False = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").False
local Nil = IMPORTS['nattlua.types.symbol']("nattlua.types.symbol").Nil
local LString = IMPORTS['nattlua.types.string']("nattlua.types.string").LString
local String = IMPORTS['nattlua.types.string']("nattlua.types.string").String
local Number = IMPORTS['nattlua.types.number']("nattlua.types.number").Number
local Boolean = IMPORTS['nattlua.types.union']("nattlua.types.union").Boolean
local table = _G.table

local function lookup_value(self, node)
	local errors = {}
	local key = NodeToString(node)
	local obj, err = self:GetLocalOrGlobalValue(key)

	if self:IsTypesystem() then
		-- we fallback to runtime if we can't find the value in the typesystem
		if not obj then
			table.insert(errors, err)
			self:PushAnalyzerEnvironment("runtime")
			obj, err = self:GetLocalOrGlobalValue(key)
			self:PopAnalyzerEnvironment("runtime")

			-- when in the typesystem we want to see the objects contract, not its runtime value
			if obj and obj:GetContract() then obj = obj:GetContract() end
		end

		if not obj then
			table.insert(errors, err)
			self:Error(errors)
			return Nil()
		end
	else
		if not obj or (obj.Type == "symbol" and obj:GetData() == nil) then
			self:PushAnalyzerEnvironment("typesystem")
			local objt, errt = self:GetLocalOrGlobalValue(key)
			self:PopAnalyzerEnvironment()

			if objt then obj, err = objt, errt end
		end

		if not obj then
			self:Warning(err)
			obj = Any()
		end
	end

	local obj = self:GetTrackedUpvalue(obj) or obj

	if obj:GetUpvalue() then self:GetScope():AddDependency(obj:GetUpvalue()) end

	return obj
end

local function is_primitive(val)
	return val == "string" or
		val == "number" or
		val == "boolean" or
		val == "true" or
		val == "false" or
		val == "nil"
end

return {
	AnalyzeAtomicValue = function(self, node)
		local value = node.value.value
		local type = runtime_syntax:GetTokenType(node.value)

		if type == "keyword" then
			if value == "nil" then
				return Nil()
			elseif value == "true" then
				return True()
			elseif value == "false" then
				return False()
			end
		elseif node.force_upvalue then
			return lookup_value(self, node)
		elseif value == "..." then
			return lookup_value(self, node)
		elseif type == "letter" and node.standalone_letter then
			-- standalone_letter means it's the first part of something, either >true<, >foo<.bar, >foo<()
			if self:IsTypesystem() then
				local current_table = self:GetCurrentType("table")

				if current_table then
					if value == "self" then
						return current_table
					elseif
						self.left_assigned and
						self.left_assigned:GetData() == value and
						not is_primitive(value)
					then
						return current_table
					end
				end

				if value == "any" then
					return Any()
				elseif value == "inf" then
					return LNumber(math.huge)
				elseif value == "nan" then
					return LNumber(math.abs(0 / 0))
				elseif value == "string" then
					return String()
				elseif value == "number" then
					return Number()
				elseif value == "boolean" then
					return Boolean()
				end
			end

			return lookup_value(self, node)
		elseif type == "number" then
			local num = LNumberFromString(value)

			if not num then
				self:Error("unable to convert " .. value .. " to number")
				num = Number()
			end

			return num
		elseif type == "string" then
			return LString(node.value.string_value)
		elseif type == "letter" then
			return LString(value)
		end

		self:FatalError("unhandled value type " .. type .. " " .. node:Render())
	end,
} end ]=======], '@./nattlua/analyzer/expressions/atomic_value.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.tuple"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local Tuple = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").Tuple
return {
	AnalyzeTuple = function(self, node)
		local tup = Tuple():SetUnpackable(true)
		self:PushCurrentType(tup, "tuple")
		tup:SetTable(self:AnalyzeExpressions(node.expressions))
		self:PopCurrentType("tuple")
		return tup
	end,
} end ]=======], '@./nattlua/analyzer/expressions/tuple.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer.expressions.vararg"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local VarArg = IMPORTS['nattlua.types.tuple']("nattlua.types.tuple").VarArg
return {
	AnalyzeVararg = function(self, node)
		return VarArg(self:AnalyzeExpression(node.value))
	end,
} end ]=======], '@./nattlua/analyzer/expressions/vararg.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.analyzer"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local class = IMPORTS['nattlua.other.class']("nattlua.other.class")
local profiler = IMPORTS['nattlua.other.profiler']("nattlua.other.profiler")
local tostring = tostring
local error = error
local setmetatable = setmetatable
local ipairs = ipairs
IMPORTS['nattlua.types.types']("nattlua.types.types").Initialize()
local META = class.CreateTemplate("analyzer")
META.OnInitialize = {}
IMPORTS['nattlua.analyzer.base.base_analyzer']("nattlua.analyzer.base.base_analyzer")(META)
IMPORTS['nattlua.analyzer.control_flow']("nattlua.analyzer.control_flow")(META)
IMPORTS['nattlua.analyzer.mutation_tracking']("nattlua.analyzer.mutation_tracking")(META)
IMPORTS['nattlua.analyzer.operators.index']("nattlua.analyzer.operators.index").Index(META)
IMPORTS['nattlua.analyzer.operators.newindex']("nattlua.analyzer.operators.newindex").NewIndex(META)
IMPORTS['nattlua.analyzer.operators.call']("nattlua.analyzer.operators.call").Call(META)

do
	local AnalyzeDestructureAssignment = IMPORTS['nattlua.analyzer.statements.destructure_assignment']("nattlua.analyzer.statements.destructure_assignment").AnalyzeDestructureAssignment
	local AnalyzeFunction = IMPORTS['nattlua.analyzer.statements.function']("nattlua.analyzer.statements.function").AnalyzeFunction
	local AnalyzeIf = IMPORTS['nattlua.analyzer.statements.if']("nattlua.analyzer.statements.if").AnalyzeIf
	local AnalyzeDo = IMPORTS['nattlua.analyzer.statements.do']("nattlua.analyzer.statements.do").AnalyzeDo
	local AnalyzeGenericFor = IMPORTS['nattlua.analyzer.statements.generic_for']("nattlua.analyzer.statements.generic_for").AnalyzeGenericFor
	local AnalyzeCall = IMPORTS['nattlua.analyzer.statements.call_expression']("nattlua.analyzer.statements.call_expression").AnalyzeCall
	local AnalyzeNumericFor = IMPORTS['nattlua.analyzer.statements.numeric_for']("nattlua.analyzer.statements.numeric_for").AnalyzeNumericFor
	local AnalyzeBreak = IMPORTS['nattlua.analyzer.statements.break']("nattlua.analyzer.statements.break").AnalyzeBreak
	local AnalyzeContinue = IMPORTS['nattlua.analyzer.statements.continue']("nattlua.analyzer.statements.continue").AnalyzeContinue
	local AnalyzeRepeat = IMPORTS['nattlua.analyzer.statements.repeat']("nattlua.analyzer.statements.repeat").AnalyzeRepeat
	local AnalyzeReturn = IMPORTS['nattlua.analyzer.statements.return']("nattlua.analyzer.statements.return").AnalyzeReturn
	local AnalyzeAnalyzerDebugCode = IMPORTS['nattlua.analyzer.statements.analyzer_debug_code']("nattlua.analyzer.statements.analyzer_debug_code").AnalyzeAnalyzerDebugCode
	local AnalyzeWhile = IMPORTS['nattlua.analyzer.statements.while']("nattlua.analyzer.statements.while").AnalyzeWhile
	local AnalyzeAssignment = IMPORTS['nattlua.analyzer.statements.assignment']("nattlua.analyzer.statements.assignment").AnalyzeAssignment

	function META:AnalyzeStatement(node)
		profiler.PushZone("AnalyzeStatement - " .. node.kind)
		self.current_statement = node
		self:PushAnalyzerEnvironment(node.environment or "runtime")

		if node.kind == "assignment" or node.kind == "local_assignment" then
			AnalyzeAssignment(self, node)
		elseif
			node.kind == "destructure_assignment" or
			node.kind == "local_destructure_assignment"
		then
			AnalyzeDestructureAssignment(self, node)
		elseif
			node.kind == "function" or
			node.kind == "type_function" or
			node.kind == "local_function" or
			node.kind == "local_type_function" or
			node.kind == "local_analyzer_function" or
			node.kind == "analyzer_function"
		then
			AnalyzeFunction(self, node)
		elseif node.kind == "if" then
			AnalyzeIf(self, node)
		elseif node.kind == "while" then
			AnalyzeWhile(self, node)
		elseif node.kind == "do" then
			AnalyzeDo(self, node)
		elseif node.kind == "repeat" then
			AnalyzeRepeat(self, node)
		elseif node.kind == "return" then
			AnalyzeReturn(self, node)
		elseif node.kind == "break" then
			AnalyzeBreak(self, node)
		elseif node.kind == "continue" then
			AnalyzeContinue(self, node)
		elseif node.kind == "call_expression" then
			AnalyzeCall(self, node)
		elseif node.kind == "generic_for" then
			AnalyzeGenericFor(self, node)
		elseif node.kind == "numeric_for" then
			AnalyzeNumericFor(self, node)
		elseif node.kind == "analyzer_debug_code" then
			AnalyzeAnalyzerDebugCode(self, node)
		elseif node.kind == "import" then

		elseif
			node.kind ~= "end_of_file" and
			node.kind ~= "semicolon" and
			node.kind ~= "shebang" and
			node.kind ~= "goto_label" and
			node.kind ~= "parser_debug_code" and
			node.kind ~= "goto"
		then
			self:FatalError("unhandled statement: " .. tostring(node))
		end

		node.scope = self:GetScope()
		self:PopAnalyzerEnvironment()
		profiler.PopZone()
	end
end

do
	local AnalyzeBinaryOperator = IMPORTS['nattlua.analyzer.expressions.binary_operator']("nattlua.analyzer.expressions.binary_operator").AnalyzeBinaryOperator
	local AnalyzePrefixOperator = IMPORTS['nattlua.analyzer.expressions.prefix_operator']("nattlua.analyzer.expressions.prefix_operator").AnalyzePrefixOperator
	local AnalyzePostfixOperator = IMPORTS['nattlua.analyzer.expressions.postfix_operator']("nattlua.analyzer.expressions.postfix_operator").AnalyzePostfixOperator
	local AnalyzePostfixCall = IMPORTS['nattlua.analyzer.expressions.postfix_call']("nattlua.analyzer.expressions.postfix_call").AnalyzePostfixCall
	local AnalyzePostfixIndex = IMPORTS['nattlua.analyzer.expressions.postfix_index']("nattlua.analyzer.expressions.postfix_index").AnalyzePostfixIndex
	local AnalyzeFunction = IMPORTS['nattlua.analyzer.expressions.function']("nattlua.analyzer.expressions.function").AnalyzeFunction
	local AnalyzeTable = IMPORTS['nattlua.analyzer.expressions.table']("nattlua.analyzer.expressions.table").AnalyzeTable
	local AnalyzeAtomicValue = IMPORTS['nattlua.analyzer.expressions.atomic_value']("nattlua.analyzer.expressions.atomic_value").AnalyzeAtomicValue
	local AnalyzeTuple = IMPORTS['nattlua.analyzer.expressions.tuple']("nattlua.analyzer.expressions.tuple").AnalyzeTuple
	local AnalyzeVararg = IMPORTS['nattlua.analyzer.expressions.vararg']("nattlua.analyzer.expressions.vararg").AnalyzeVararg
	local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union

	function META:AnalyzeExpression2(node)
		self.current_expression = node

		if node.kind == "value" then
			return AnalyzeAtomicValue(self, node)
		elseif node.kind == "vararg" then
			return AnalyzeVararg(self, node)
		elseif
			node.kind == "function" or
			node.kind == "analyzer_function" or
			node.kind == "type_function" or
			node.kind == "function_signature"
		then
			return AnalyzeFunction(self, node)
		elseif node.kind == "table" or node.kind == "type_table" then
			return AnalyzeTable(self, node)
		elseif node.kind == "binary_operator" then
			return AnalyzeBinaryOperator(self, node)
		elseif node.kind == "prefix_operator" then
			return AnalyzePrefixOperator(self, node)
		elseif node.kind == "postfix_operator" then
			return AnalyzePostfixOperator(self, node)
		elseif node.kind == "postfix_expression_index" then
			return AnalyzePostfixIndex(self, node)
		elseif node.kind == "postfix_call" then
			return AnalyzePostfixCall(self, node)
		elseif node.kind == "empty_union" then
			return Union({})
		elseif node.kind == "tuple" then
			return AnalyzeTuple(self, node)
		else
			self:FatalError("unhandled expression " .. node.kind)
		end
	end

	function META:AnalyzeTypeExpression(node, parent_obj)
		profiler.PushZone("AnalyzeTypeExpression - " .. node.kind)

		if not node.type_expression then return parent_obj end

		self:PushAnalyzerEnvironment("typesystem")
		local obj = self:AnalyzeExpression(node.type_expression)
		self:PopAnalyzerEnvironment()

		if obj.Type == "table" then
			if parent_obj.Type == "table" then
				parent_obj:SetContract(obj)
				return parent_obj
			elseif parent_obj.Type == "tuple" and parent_obj:GetLength() == 1 then
				local first = parent_obj:GetData()[1]

				if first.Type == "table" then
					first:SetContract(obj)
					return parent_obj
				end
			end
		end

		profiler.PopZone()
		return obj
	end

	function META:AnalyzeExpression(node)
		profiler.PushZone("AnalyzeExpression - " .. node.kind)
		local obj, err = self:AnalyzeExpression2(node)
		obj = self:AnalyzeTypeExpression(node, obj)
		node:AddType(obj or err)
		node.scope = self:GetScope()
		profiler.PopZone()
		return obj, err
	end
end

function META.New(config)
	config = config or {}
	local self = setmetatable({config = config}, META)

	for _, func in ipairs(META.OnInitialize) do
		func(self)
	end

	self.context_values = {}
	self.context_ref = {}
	return self
end

return META end ]=======], '@./nattlua/analyzer.lua'))())(...) return __M end end
IMPORTS['./nattlua/config.nlua'] = assert(loadstring([=======[ return function() 





return {
	LexerConfig = nil,
	ParserConfig = nil,
	AnalyzerConfig = nil,
	TranspilerConfig = nil,
	CompilerConfig = nil,
} end ]=======], '@./nattlua/config.nlua'))()
do local __M; IMPORTS["nattlua.init"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local nl = {}
local loadstring = IMPORTS['nattlua.other.loadstring']("nattlua.other.loadstring")
nl.Compiler = IMPORTS['nattlua.compiler']("nattlua.compiler").New

function nl.load(code, name, config)
	local obj = nl.Compiler(code, name, config)
	local code, err = obj:Emit()

	if not code then return nil, err end

	return loadstring(code, name)
end

function nl.loadfile(path, config)
	local obj = nl.File(path, config)
	local code, err = obj:Emit()

	if not code then return nil, err end

	return loadstring(code, path)
end

function nl.File(path, config)
	config = config or {}
	config.file_path = config.file_path or path
	config.file_name = config.file_name or path
	local f, err = io.open(path, "rb")

	if not f then return nil, err end

	local code = f:read("*all")
	f:close()

	if not code then return nil, path .. " empty file" end

	return nl.Compiler(code, "@" .. path, config)
end

return nl end ]=======], '@./nattlua/init.lua'))())(...) return __M end end
IMPORTS['nattlua/definitions/index.nlua'] = assert(loadstring([=======[ return function() IMPORTS['nattlua/definitions/utility.nlua']("./utility.nlua")
IMPORTS['nattlua/definitions/attest.nlua']("./attest.nlua")
IMPORTS['nattlua/definitions/lua/globals.nlua']("./lua/globals.nlua")
IMPORTS['nattlua/definitions/lua/io.nlua']("./lua/io.nlua")
IMPORTS['nattlua/definitions/lua/luajit.nlua']("./lua/luajit.nlua")
IMPORTS['nattlua/definitions/lua/debug.nlua']("./lua/debug.nlua")
IMPORTS['nattlua/definitions/lua/package.nlua']("./lua/package.nlua")
IMPORTS['nattlua/definitions/lua/bit.nlua']("./lua/bit.nlua")
IMPORTS['nattlua/definitions/lua/table.nlua']("./lua/table.nlua")
IMPORTS['nattlua/definitions/lua/string.nlua']("./lua/string.nlua")
IMPORTS['nattlua/definitions/lua/math.nlua']("./lua/math.nlua")
IMPORTS['nattlua/definitions/lua/os.nlua']("./lua/os.nlua")
IMPORTS['nattlua/definitions/lua/coroutine.nlua']("./lua/coroutine.nlua")
IMPORTS['nattlua/definitions/typed_ffi.nlua']("./typed_ffi.nlua") end ]=======], '@nattlua/definitions/index.nlua'))()
IMPORTS['DATA_nattlua/definitions/index.nlua'] = function() return [======[ _G.IMPORTS = _G.IMPORTS or {}
IMPORTS['nattlua/definitions/utility.nlua'] = function() type _ = any
type boolean = true | false
type integer = number
type Table = {[any] = any} | {}
type Function = function=(...any)>(...any)
type userdata = Table
type cdata = {[number] = any}
type cdata.@TypeOverride = "cdata"
type ctype = any
type thread = Table
type empty_function = function=(...)>(...any)

analyzer function NonLiteral(obj: any)
	if obj.Type == "symbol" and (obj:GetData() == true or obj:GetData() == false) then
		return types.Boolean()
	end

	if obj.Type == "number" or obj.Type == "string" then
		obj = obj:Copy()
		obj:SetLiteral(false)
		return obj
	end

	return obj
end

function List<|val: any|>
	return {[number] = val | nil}
end

function Map<|key: any, val: any|>
	return {[key] = val | nil}
end

function ErrorReturn<|...: ...any|>
	return (...,) | (nil, string)
end

analyzer function Widen(val: any)
	return val:Copy():Widen()
end

analyzer function return_type(func: Function, i: number | nil)
	local i = i and i:GetData() or nil
	return {func:GetOutputSignature():Slice(i, i)}
end

analyzer function set_return_type(func: Function, tup: any)
	func:SetOutputSignature(tup)
	func:SetExplicitOutputSignature(true)
	func:SetCalled(false)
end

analyzer function argument_type(func: Function, i: number | nil)
	local i = i and i:GetData() or nil
	return {func:GetInputSignature():Slice(i, i)}
end

analyzer function exclude(T: any, U: any)
	T = T:Copy()
	T:RemoveType(U)
	return T
end

analyzer function enum(tbl: Table)
	assert(tbl:IsLiteral())
	local union = types.Union()
	analyzer:PushAnalyzerEnvironment("typesystem")

	for _, keyval in ipairs(tbl:GetData()) do
		analyzer:SetLocalOrGlobalValue(keyval.key, keyval.val)
		union:AddType(keyval.val)
	end

	analyzer:PopAnalyzerEnvironment()
	union:SetLiteral(true)
	return union
end

analyzer function keysof(tbl: Table)
	local union = types.Union()

	if tbl.Type == "union" then
		for _, val in ipairs(tbl:GetData()) do
			if val.Type == "table" then
				for _, keyval in ipairs(tbl:GetData()) do
					union:AddType(keyval.key)
				end
			end
		end
	elseif tbl.Type == "table" then
		for _, keyval in ipairs(tbl:GetData()) do
			union:AddType(keyval.key)
		end
	end

	return union
end

analyzer function seal(tbl: Table)
	if tbl:GetContract() then return end

	for _, keyval in ipairs(tbl:GetData()) do
		if
			keyval.val.Type == "function" and
			keyval.val:GetInputSignature():Get(1).Type == "union"
		then
			local first_arg = keyval.val:GetInputSignature():Get(1)

			if first_arg:GetType(tbl) and first_arg:GetType(types.Any()) then
				keyval.val:GetInputSignature():Set(1, tbl)
			end
		end
	end

	tbl:SetContract(tbl)
end

function nilable<|tbl: {[string] = any}|>
	tbl = copy(tbl)

	for key, val in pairs(tbl) do
		tbl[key] = val | nil
	end

	return tbl
end

analyzer function copy(obj: any)
	local copy = obj:Copy()
	analyzer:ClearObjectMutations(copy)

	if copy.Type == "table" then copy:SetCreationScope(nil) end

	copy.potential_self = nil
	return copy
end

analyzer function UnionValues(values: any)
	if values.Type ~= "union" then values = types.Union({values}) end

	local i = 1
	return function()
		local value = values:GetData()[i]
		i = i + 1
		return value
	end
end

-- typescript utility functions
function Partial<|tbl: Table|>
	local copy = {}

	for key, val in pairs(tbl) do
		copy[key] = val | nil
	end

	return copy
end

function Required<|tbl: Table|>
	local copy = {}

	for key, val in pairs(tbl) do
		copy[key] = val ~ nil
	end

	return copy
end

-- this is more like a seal function as it allows you to modify the table
function Readonly<|tbl: Table|>
	local copy = {}

	for key, val in pairs(tbl) do
		copy[key] = val
	end

	copy.@Contract = copy
	return copy
end

function Record<|keys: string, tbl: Table|>
	local out = {}

	for value in UnionValues(keys) do
		out[value] = tbl
	end

	return out
end

function Pick<|tbl: Table, keys: string|>
	local out = {}

	for value in UnionValues(keys) do
		if tbl[value] == nil then
			error("missing key '" .. value .. "' in table", 2)
		end

		out[value] = tbl[value]
	end

	return out
end

analyzer function Delete(tbl: Table, key: string)
	local out = tbl:Copy()
	tbl:Delete(key)
	return out
end

function Omit<|tbl: Table, keys: string|>
	local out = copy<|tbl|>

	for value in UnionValues(keys) do
		if tbl[value] == nil then
			error("missing key '" .. value .. "' in table", 2)
		end

		Delete<|out, value|>
	end

	return out
end

function Exclude<|a: any, b: any|>
	return a ~ b
end

analyzer function Union(...: ...any)
	return types.Union({...})
end

function Extract<|a: any, b: any|>
	local out = Union<||>

	for aval in UnionValues(a) do
		for bval in UnionValues(b) do
			if aval < bval then out = out | aval end
		end
	end

	return out
end

analyzer function Parameters(func: Function)
	return {func:GetInputSignature():Copy():Unpack()}
end

analyzer function ReturnType(func: Function)
	return {func:GetOutputSignature():Copy():Unpack()}
end

function Uppercase<|val: ref string|>
	return val:upper()
end

function Lowercase<|val: ref string|>
	return val:lower()
end

function Capitalize<|val: ref string|>
	return val:sub(1, 1):upper() .. val:sub(2)
end

function Uncapitalize<|val: ref string|>
	return val:sub(1, 1):lower() .. val:sub(2)
end

analyzer function TypeName(val: any)
	return val.Type
end

analyzer function PushTypeEnvironment(obj: any)
	local tbl = types.Table()
	tbl:Set(types.LString("_G"), tbl)
	local g = analyzer:GetGlobalEnvironment("typesystem")
	tbl:Set(
		types.LString("__index"),
		types.LuaTypeFunction(
			function(self, key)
				local ok, err = obj:Get(key)

				if ok then return ok end

				local val, err = analyzer:IndexOperator(g, key)

				if val then return val end

				do
					analyzer.stem_types = analyzer.stem_types or {}
					analyzer.stem_types[key:GetData()] = types.Symbol("StemType-" .. tostring(key))
					return analyzer.stem_types[key:GetData()]
				end

				analyzer:Error(err)
				return types.Nil()
			end,
			{types.Any(), types.Any()},
			{}
		)
	)
	tbl:Set(
		types.LString("__newindex"),
		types.LuaTypeFunction(
			function(self, key, val)
				if analyzer.stem_types then
					local stem = analyzer.stem_types[key:GetData()]

					if stem then
						for k, v in pairs(stem) do
							stem[k] = nil
						end

						setmetatable(stem, getmetatable(val))

						for k, v in pairs(val) do
							stem[k] = v
						end
					end
				end

				return analyzer:Assert(obj:Set(key, val))
			end,
			{types.Any(), types.Any(), types.Any()},
			{}
		)
	)
	tbl:SetMetaTable(tbl)
	analyzer:PushGlobalEnvironment(analyzer.current_statement, tbl, "typesystem")
	analyzer:PushAnalyzerEnvironment("typesystem")
end

analyzer function PopTypeEnvironment()
	analyzer:PopAnalyzerEnvironment("typesystem")
	analyzer:PopGlobalEnvironment("typesystem")
end

analyzer function CurrentType(what: "table" | "tuple" | "function" | "union", level: literal nil | number)
	return analyzer:GetCurrentType(what:GetData(), level and level:GetData())
end end
IMPORTS['nattlua/definitions/attest.nlua'] = function() local type attest = {}

analyzer function attest.equal(A: any, B: any, level: nil | literal number)
	if not A:Equal(B) then
		analyzer:ThrowError(
			"expected " .. tostring(B) .. " got " .. tostring(A),
			level and level:GetData() or 2
		)
		return
	end

	return A
end

analyzer function attest.literal(A: any)
	analyzer:ErrorAssert(A:IsLiteral())
	return A
end

analyzer function attest.superset_of(A: any, B: any)
	analyzer:ErrorAssert(B:IsSubsetOf(A))
	return A
end

analyzer function attest.subset_of(A: any, B: any)
	analyzer:ErrorAssert(A:IsSubsetOf(B))
	return A
end

analyzer function attest.truthy(obj: any, err: string | nil)
	if obj:IsCertainlyTrue() then return obj end

	error(err and err:GetData() or "assertion failed")
end

analyzer function attest.expect_diagnostic(severity: "warning" | "error", msg: string)
	analyzer.expect_diagnostic = analyzer.expect_diagnostic or {}
	table.insert(analyzer.expect_diagnostic, {msg = msg:GetData(), severity = severity:GetData()})
end

analyzer function attest.pcall(callable: Function, ...: ...any)
	local diagnostics_index = #analyzer:GetDiagnostics()
	analyzer:PushProtectedCall()
	local tuple = analyzer:Assert(analyzer:Call(callable, types.Tuple({...})))
	analyzer:PopProtectedCall()
	local diagnostics = analyzer:GetDiagnostics()

	do
		local errors = {}

		for i = math.max(diagnostics_index, 1), #diagnostics do
			local d = diagnostics[i]
			local msg = analyzer.compiler:GetCode():BuildSourceCodePointMessage(d.msg, d.start, d.stop)
			table.insert(errors, msg)
		end

		if errors[1] then return false, table.concat(errors, "\n") end
	end

	return true, tuple:Unpack()
end

_G.attest = attest end
IMPORTS['nattlua/definitions/lua/globals.nlua'] = function() type @Name = "_G"
type setmetatable = function=(table: Table, metatable: Table | nil)>(Table)
type select = function=(index: number | string, ...)>(...)
type rawlen = function=(v: Table | string)>(number)
type unpack = function=(list: Table, i: number, j: number)>(...) | function=(list: Table, i: number)>(...) | function=(list: Table)>(...)
type require = function=(modname: string)>(any)
type rawset = function=(table: Table, index: any, value: any)>(Table)
type getmetatable = function=(object: any)>(Table | nil)
type type = function=(v: any)>(string)
type collectgarbage = function=(opt: string, arg: number)>(...) | function=(opt: string)>(...) | function=()>(...)
type getfenv = function=(f: empty_function | number)>(Table) | function=()>(Table)
type pairs = function=(t: Table)>(empty_function, Table, nil)
type rawequal = function=(v1: any, v2: any)>(boolean)
type loadfile = function=(filename: string, mode: string, env: Table)>(empty_function | nil, string | nil) | function=(filename: string, mode: string)>(empty_function | nil, string | nil) | function=(filename: string)>(empty_function | nil, string | nil) | function=()>(empty_function | nil, string | nil)
type dofile = function=(filename: string)>(...) | function=()>(...)
type ipairs = function=(t: Table)>(empty_function, Table, number)
type tonumber = function=(e: number | string, base: number | nil)>(number | nil)
_G.arg = _  as List<|any|>

analyzer function setfenv(val: Function, table: Table)
	if val and (val:IsLiteral() or val.Type == "function") then
		if val.Type == "number" then
			analyzer:SetEnvironmentOverride(analyzer.environment_nodes[val:GetData()], table, "runtime")
		elseif val:GetFunctionBodyNode() then
			analyzer:SetEnvironmentOverride(val:GetFunctionBodyNode(), table, "runtime")
		end
	end
end

analyzer function getfenv(func: Function | nil)
	if not func then return analyzer:GetDefaultEnvironment("typesystem") end

	return analyzer:GetGlobalEnvironmentOverride(func:GetFunctionBodyNode() or func, "runtime")
end

analyzer function type_print(...: ...any)
	print(...)
end

analyzer function print(...: ...any)
	print(...)
end

type tostring = function=(val: any)>(string)

analyzer function next(t: Map<|any, any|>, k: any)
	if t.Type == "any" then return types.Any(), types.Any() end

	if t:IsLiteral() then
		if k and not (k.Type == "symbol" and k:GetData() == nil) then
			for i, kv in ipairs(t:GetData()) do
				if kv.key:IsSubsetOf(k) then
					local kv = t:GetData()[i + 1]

					if kv then
						if not k:IsLiteral() then
							return type.Union({types.Nil(), kv.key}), type.Union({types.Nil(), kv.val})
						end

						return kv.key, kv.val
					end

					return nil
				end
			end
		else
			local kv = t:GetData() and t:GetData()[1]

			if kv then return kv.key, kv.val end
		end
	end

	if t.Type == "union" then t = t:GetData() else t = {t} end

	local k = types.Union()
	local v = types.Union()

	for _, t in ipairs(t) do
		if not t:GetData() then return types.Any(), types.Any() end

		for i, kv in ipairs(t:GetContract() and t:GetContract():GetData() or t:GetData()) do
			if kv.Type then
				k:AddType(types.Number())
				v:AddType(kv)
			else
				k:AddType(kv.key)
				v:AddType(kv.val)
			end
		end
	end

	return k, v
end

analyzer function pairs(tbl: Table)
	if tbl.Type == "table" and (tbl:HasLiteralKeys() or analyzer:IsTypesystem()) then
		local i = 1
		return function()
			local kv = tbl:GetData()[i]

			if not kv then return nil end

			i = i + 1
			local o = analyzer:GetMutatedTableValue(tbl, kv.key)
			return kv.key, o or kv.val
		end
	end

	analyzer:PushAnalyzerEnvironment("typesystem")
	local next = analyzer:GetLocalOrGlobalValue(types.LString("next"))
	analyzer:PopAnalyzerEnvironment()
	local k, v = analyzer:CallLuaTypeFunction(next:GetAnalyzerFunction(), analyzer:GetScope(), tbl)
	local done = false

	if v and v.Type == "union" then v:RemoveType(types.Symbol(nil)) end

	return function()
		if done then return nil end

		done = true
		return k, v
	end
end

analyzer function ipairs(tbl: {[number] = any} | {})
	if tbl:IsLiteral() then
		local i = 1
		return function(key, val)
			local kv = tbl:GetData()[i]

			if not kv then return nil end

			i = i + 1
			return kv.key, kv.val
		end
	end

	if tbl.Type == "table" and not tbl:IsNumericallyIndexed() then
		analyzer:Warning({tbl, " is not numerically indexed"})
		local done = false
		return function()
			if done then return nil end

			done = true
			return types.Any(), types.Any()
		end
	end

	analyzer:PushAnalyzerEnvironment("typesystem")
	local next = analyzer:GetLocalOrGlobalValue(types.LString("next"))
	analyzer:PopAnalyzerEnvironment()
	local k, v = analyzer:CallLuaTypeFunction(next:GetAnalyzerFunction(), analyzer:GetScope(), tbl)
	local done = false
	return function()
		if done then return nil end

		done = true

		-- v must never be nil here
		if v.Type == "union" then v = v:Copy():RemoveType(types.Symbol(nil)) end

		return k, v
	end
end

analyzer function require(name: string)
	if not name:IsLiteral() then return types.Any() end

	local str = name
	local base_environment = analyzer:GetDefaultEnvironment("typesystem")
	local val = base_environment:Get(str)

	if val then return val end

	local modules = {
		"table.new",
		"jit.util",
		"jit.opt",
	}

	for _, mod in ipairs(modules) do
		if str:GetData() == mod then
			local tbl

			for key in mod:gmatch("[^%.]+") do
				tbl = tbl or base_environment
				tbl = tbl:Get(types.LString(key))
			end

			-- in case it's not found
			-- TODO, add ability to configure the analyzer
			analyzer:Warning("module '" .. mod .. "' might not exist")
			return tbl
		end
	end

	if analyzer:GetLocalOrGlobalValue(str) then
		return analyzer:GetLocalOrGlobalValue(str)
	end

	if package.loaders then
		for i, searcher in ipairs(package.loaders) do
			local loader = searcher(str:GetData())

			if type(loader) == "function" then
				local path = debug.getinfo(loader).source

				if path:sub(1, 1) == "@" then
					local path = path:sub(2)

					if analyzer.loaded and analyzer.loaded[path] then
						return analyzer.loaded[path]
					end

					local compiler = IMPORTS['nattlua.init']("nattlua.init").File(analyzer:ResolvePath(path))
					assert(compiler:Lex())
					assert(compiler:Parse())
					local res = analyzer:AnalyzeRootStatement(compiler.SyntaxTree)
					analyzer.loaded = analyzer.loaded or {}
					analyzer.loaded[path] = res
					return res
				end
			end
		end
	end

	analyzer:Error("module '" .. str:GetData() .. "' not found")
	return types.Any
end

analyzer function type_error(str: string, level: number | nil)
	error(str:GetData(), level and level:GetData() or nil)
end

analyzer function load(code: string | function=()>(string | nil), chunk_name: string | nil)
	if not code:IsLiteral() or code.Type == "union" then
		return types.Tuple(
			{
				types.Union({types.Nil(), types.AnyFunction()}),
				types.Union({types.Nil(), types.String()}),
			}
		)
	end

	local str = code:GetData()
	local compiler = nl.Compiler(str, chunk_name and chunk_name:GetData() or nil)
	assert(compiler:Lex())
	assert(compiler:Parse())
	local f = types.Function()

	f:SetAnalyzerFunction(function(...)
		return analyzer:AnalyzeRootStatement(compiler.SyntaxTree, ...)
	end)

	f:SetInputSignature(types.VarArg(types.Any()))
	f:SetOutputSignature(types.VarArg(types.Any()))
	return f
end

type loadstring = load

analyzer function dofile(path: string)
	if not path:IsLiteral() then return types.Any() end

	local f = assert(io.open(path:GetData(), "rb"))
	local code = f:read("*all")
	f:close()
	local compiler = nl.Compiler(code, "@" .. path:GetData())
	assert(compiler:Lex())
	assert(compiler:Parse())
	return analyzer:AnalyzeRootStatement(compiler.SyntaxTree)
end

analyzer function loadfile(path: string)
	if not path:IsLiteral() then return types.Any() end

	local f = assert(io.open(path:GetData(), "rb"))
	local code = f:read("*all")
	f:close()
	local compiler = nl.Compiler(code, "@" .. path:GetData())
	assert(compiler:Lex())
	assert(compiler:Parse())
	local f = types.AnyFunction()

	f:SetAnalyzerFunction(function(a, b, c, d, e, f)
		return analyzer:AnalyzeRootStatement(compiler.SyntaxTree, a, b, c, d, e, f)
	end)

	return f
end

analyzer function rawset(tbl: {[any] = any} | {}, key: any, val: any)
	analyzer:Assert(tbl:Set(key, val, true))
end

analyzer function rawget(tbl: {[any] = any} | {}, key: any)
	local t, err = tbl:Get(key, true)

	if t then return t end
end

analyzer function assert(obj: any, msg: string | nil, level: number | nil)
	if not analyzer:IsDefinetlyReachable() then
		analyzer:ThrowSilentError(obj)

		if obj.Type == "union" then
			obj = obj:Copy()
			obj:DisableFalsy()
			return obj
		end

		return obj
	end

	if obj.Type == "union" then
		for _, tup in ipairs(obj:GetData()) do
			if tup.Type == "tuple" and tup:Get(1):IsTruthy() then return tup end
		end
	end

	if obj:IsTruthy() and not obj:IsFalsy() then
		if obj.Type == "union" then
			obj = obj:Copy()
			obj:DisableFalsy()
			return obj
		end
	end

	if obj:IsFalsy() then
		analyzer:AssertError(
			obj,
			msg and msg:GetData() or "assertion failed!",
			level and level:GetData() or nil,
			obj:IsTruthy()
		)

		if obj.Type == "union" then
			obj = obj:Copy()
			obj:DisableFalsy()
			return obj
		end
	end

	return obj
end

analyzer function error(msg: string, level: number | nil)
	if not analyzer:IsDefinetlyReachable() then
		analyzer:ThrowSilentError()
		return
	end

	if msg:IsLiteral() then
		analyzer:ThrowError(msg:GetData(), level and level:GetData() or nil)
	else
		analyzer:ThrowError("error thrown from expression " .. tostring(analyzer.current_expression))
	end
end

analyzer function type_error(msg: literal string, level: literal (number | nil))
	if analyzer.processing_deferred_calls then return end

	analyzer:ThrowError(msg:GetData(), level and level:GetData() or nil)
end

analyzer function pcall(callable: literal Function, ...: ...any): (boolean, ...any)
	local diagnostics_index = #analyzer:GetDiagnostics()
	analyzer:PushProtectedCall()
	local tuple = analyzer:Assert(analyzer:Call(callable, types.Tuple({...})))
	analyzer:PopProtectedCall()
	local diagnostics = analyzer:GetDiagnostics()

	do
		local errors = {}

		for i = math.max(diagnostics_index, 1), #diagnostics do
			local d = diagnostics[i]

			if d.severity == "error" then
				return types.Boolean(), types.Union({types.LString(d.msg), types.Any()})
			end
		end
	end

	if
		callable.Type ~= "function" or
		not callable:GetFunctionBodyNode()
		or
		not callable:GetFunctionBodyNode()
	then
		return types.Boolean(), tuple
	end

	return true, tuple
end

analyzer function xpcall(callable: literal Function, error_cb: function=(any)>(), ...: ...any): (boolean, ...any)
	local diagnostics_index = #analyzer:GetDiagnostics()
	analyzer:PushProtectedCall()
	local tuple = analyzer:Assert(analyzer:Call(callable, types.Tuple({...})))
	analyzer:PopProtectedCall()
	local diagnostics = analyzer:GetDiagnostics()

	do
		local errors = {}

		for i = math.max(diagnostics_index, 1), #diagnostics do
			local d = diagnostics[i]

			if d.severity == "error" then
				analyzer:Assert(analyzer:Call(callable, types.Union({types.LString(d.msg)})))
				return types.Boolean(), types.Union({types.LString(d.msg), types.Any()})
			end
		end
	end

	if
		callable.Type ~= "function" or
		not callable:GetFunctionBodyNode()
		or
		not callable:GetFunctionBodyNode()
	then
		return types.Boolean(), tuple
	end

	return true, tuple
end

analyzer function select(index: 1 .. inf | "#", ...: ...any)
	return select(index:GetData(), ...)
end

analyzer function type(obj: any)
	if obj.Type == "union" then
		analyzer.type_checked = obj
		local copy = types.Union()
		copy:SetUpvalue(obj:GetUpvalue())

		for _, v in ipairs(obj:GetData()) do
			if v.GetLuaType then copy:AddType(types.LString(v:GetLuaType())) end
		end

		return copy
	end

	if obj.Type == "any" then return types.String() end

	if obj.Type == "number" and type(obj.Data) == "cdata" then return "cdata" end

	if obj.GetLuaType then return obj:GetLuaType() end

	return types.String()
end

function MetaTableFunctions<|T: any|>
	return {
		__gc = function=(T)>(),
		__pairs = function=(T)>(function=(T)>(any, any)),
		__tostring = function=(T)>(string),
		__call = function=(T, ...any)>(...any),
		__index = function=(T, key: any)>(),
		__newindex = function=(T, key: any, value: any)>(),
		__len = function=(a: T)>(number),
		__unm = function=(a: T)>(any),
		__bnot = function=(a: T)>(any),
		__add = function=(a: T, b: any)>(any),
		__sub = function=(a: T, b: any)>(any),
		__mul = function=(a: T, b: any)>(any),
		__div = function=(a: T, b: any)>(any),
		__idiv = function=(a: T, b: any)>(any),
		__mod = function=(a: T, b: any)>(any),
		__pow = function=(a: T, b: any)>(any),
		__band = function=(a: T, b: any)>(any),
		__bor = function=(a: T, b: any)>(any),
		__bxor = function=(a: T, b: any)>(any),
		__shl = function=(a: T, b: any)>(any),
		__shr = function=(a: T, b: any)>(any),
		__concat = function=(a: T, b: any)>(any),
		__eq = function=(a: T, b: any)>(boolean),
		__lt = function=(a: T, b: any)>(boolean),
		__le = function=(a: T, b: any)>(boolean),
	}
end

analyzer function setmetatable(tbl: Table, meta: Table | nil)
	if not meta or meta.Type == "symbol" then
		tbl:SetMetaTable()
		return tbl
	end

	do
		local meta = tbl:GetMetaTable()

		if meta and meta:Get(types.LString("__metatable")) then
			analyzer:ThrowError("cannot change a protected metatable")
			return
		end
	end

	if meta.Type == "table" then
		if meta.Self then
			analyzer:Assert(tbl:FollowsContract(meta.Self))
			tbl:CopyLiteralness(meta.Self)
			tbl:SetContract(meta.Self)
			-- clear mutations so that when looking up values in the table they won't return their initial value
			analyzer:ClearObjectMutations(tbl)
		elseif analyzer:IsRuntime() then
			meta.potential_self = meta.potential_self or types.Union({})
			meta.potential_self:AddType(tbl)
		end

		tbl:SetMetaTable(meta)

		if analyzer:IsTypesystem() then return tbl end

		local metatable_functions = analyzer:CallTypesystemUpvalue(types.LString("MetaTableFunctions"), tbl)

		for _, kv in ipairs(metatable_functions:GetData()) do
			local a = kv.val
			local b = meta:Get(kv.key)

			if b and b.Type == "function" then
				local ok = analyzer:Assert(a:IsSubsetOf(b))

				if ok then

				--TODO: enrich callback types
				--b:SetOutputSignature(a:GetOutputSignature())
				--b:SetInputSignature(a:GetInputSignature())
				--b.arguments_inferred = true
				end
			end
		end
	end

	return tbl
end

analyzer function getmetatable(tbl: Table)
	local meta = tbl:GetMetaTable()

	if meta then
		local val = meta:Get(types.LString("__metatable"))

		if val then return val end

		return meta
	end

	return nil
end

analyzer function tostring(val: any)
	if val.Type == "function" then return "function: 0x000000000000" end

	if not val:IsLiteral() then return types.String() end

	if val.Type == "string" then return val end

	if val.Type == "table" then
		if val:GetMetaTable() then
			local func = val:GetMetaTable():Get(types.LString("__tostring"))

			if func then
				if func.Type == "function" then
					return analyzer:Assert(analyzer:Call(func, types.Tuple({val})))
				else
					return func
				end
			end
		end

		return tostring(val:GetData())
	end

	return tostring(val:GetData())
end

analyzer function tonumber(val: string | number, base: number | nil)
	if not val:IsLiteral() or base and not base:IsLiteral() then
		return types.Union({types.Nil(), types.Number()})
	end

	if val:IsLiteral() then
		base = base and base:IsLiteral() and base:GetData()
		return tonumber(val:GetData(), base)
	end

	return val
end

function _G.LSX(
	tag: string,
	constructor: function=(Table, Table)>(Table),
	props: Table,
	children: Table
)
	local e = constructor and
		constructor(props, children) or
		{
			props = props,
			children = children,
		}
	e.tag = tag
	return e
end end
IMPORTS['nattlua/definitions/lua/io.nlua'] = function() type io = {
	write = function=(...string)>(nil),
	flush = function=()>(boolean | nil, string | nil),
	read = function <|s: "*n" | "*a" | "*l" | number | nil|>
		if s == "*n" then return nil | number end

		return nil | string
	end,
	lines = function=()>(Function),
	setvbuf = function=(mode: string, size: number)>(boolean | nil, string | nil) | function=(mode: string)>(boolean | nil, string | nil),
	seek = function=(whence: string, offset: number)>(number | nil, string | nil) | function=(whence: string)>(number | nil, string | nil) | function=()>(number | nil, string | nil),
}
type File = {
	close = function=(self)>(boolean | nil, string, number | nil),
	write = function=(self, ...(number | string))>(self | nil, string | nil),
	flush = function=(self)>(boolean | nil, string | nil),
	read = function <|self: File, s: "*n" | "*a" | "*l" | number | nil|>
		if s == "*n" then return nil | number end

		return nil | string
	end,
	lines = function=(self)>(Function),
	setvbuf = function=(self, string, number)>(boolean | nil, string | nil) | function=(file: self, mode: string)>(boolean | nil, string | nil),
	seek = function=(self, string, number)>(number | nil, string | nil) | function=(file: self, whence: string)>(number | nil, string | nil) | function=(file: self)>(number | nil, string | nil),
}
type io.open = function=(string, string | nil)>(nil | File)
type io.popen = function=(string, string | nil)>(nil | File)
type io.output = function=()>(File)
type io.stdout = File
type io.stdin = File
type io.stderr = File

analyzer function io.type(obj: any)
	local flags = types.Union()
	flags:AddType(types.LString("file"))
	flags:AddType(types.LString("closed file"))
	print(("%p"):format(obj), ("%p"):format(env.typesystem.File))

	if false and obj:IsSubsetOf(env.typesystem.File) then return flags end

	flags:AddType(types.Nil())
	return flags
end

analyzer function io.write(...: ...string)
	for i, v in ipairs({...}) do
		if not v:IsLiteral() then return end
	end

	for i, v in ipairs({...}) do
		io.write(v:GetData())
	end
end end
IMPORTS['nattlua/definitions/lua/luajit.nlua'] = function() type ffi = {
	errno = function=(nil | number)>(number),
	os = "Windows" | "Linux" | "OSX" | "BSD" | "POSIX" | "Other",
	arch = "x86" | "x64" | "arm" | "ppc" | "ppcspe" | "mips",
	C = {},
	cdef = function=(string)>(nil),
	abi = function=(string)>(boolean),
	metatype = function=(ctype, Table)>(cdata),
	new = function=(string | ctype, number | nil, ...any)>(cdata),
	copy = function=(any, any, number | nil)>(nil),
	alignof = function=(ctype)>(number),
	cast = function=(ctype | string, cdata | string | number)>(cdata),
	typeof = function=(ctype, ...any)>(ctype),
	load = function=(string, boolean)>(userdata) | function=(string)>(userdata),
	sizeof = function=(ctype, number)>(number) | function=(ctype)>(number),
	string = function=(cdata, number | nil)>(string),
	gc = function=(ctype, empty_function)>(cdata),
	istype = function=(ctype, any)>(boolean),
	fill = function=(cdata, number, any)>(nil) | function=(cdata, len: number)>(nil),
	offsetof = function=(cdata, number)>(number),
}
type ffi.C.@Name = "FFI_C"
type jit = {
	os = ffi.os,
	arch = ffi.arch,
	attach = function=(empty_function, string)>(nil),
	flush = function=()>(nil),
	opt = {start = function=(...)>(nil)},
	tracebarrier = function=()>(nil),
	version_num = number,
	version = string,
	on = function=(empty_function | true, boolean | nil)>(nil),
	off = function=(empty_function | true, boolean | nil)>(nil),
	flush = function=(empty_function | true, boolean | nil)>(nil),
	status = function=()>(boolean, ...string),
	opt = {
		start = function=(...string)>(nil),
		stop = function=()>(nil),
	},
	util = {
		funcinfo = function=(empty_function, position: number | nil)>(
			{
				linedefined = number, -- as for debug.getinfo
				lastlinedefined = number, -- as for debug.getinfo
				params = number, -- the number of parameters the function takes
				stackslots = number, -- the number of stack slots the function's local variable use
				upvalues = number, -- the number of upvalues the function uses
				bytecodes = number, -- the number of bytecodes it the compiled function
				gcconsts = number, -- the number of garbage collectable constants
				nconsts = number, -- the number of lua_Number (double) constants
				children = boolean, -- Boolean representing whether the function creates closures
				currentline = number, -- as for debug.getinfo
				isvararg = boolean, -- if the function is a vararg function
				source = string, -- as for debug.getinfo
				loc = string, -- a string describing the source and currentline, like "<source>:<line>"
				ffid = number, -- the fast function id of the function (if it is one). In this case only upvalues above and addr below are valid
				addr = any, -- the address of the function (if it is not a Lua function). If it's a C function rather than a fast function, only upvalues above is valid*
			}
		),
	},
} end
IMPORTS['nattlua/definitions/lua/debug.nlua'] = function() type debug_getinfo = {
	name = string,
	namewhat = string,
	source = string,
	short_src = string,
	linedefined = number,
	lastlinedefined = number,
	what = string,
	currentline = number,
	istailcall = boolean,
	nups = number,
	nparams = number,
	isvararg = boolean,
	func = any,
	activelines = {[number] = boolean},
}
type debug = {
	sethook = function=(thread: thread, hook: empty_function, mask: string, count: number)>(nil) | function=(thread: thread, hook: empty_function, mask: string)>(nil) | function=(hook: empty_function, mask: string)>(nil),
	getregistry = function=()>(nil),
	traceback = function=(thread: thread, message: any, level: number)>(string) | function=(thread: thread, message: any)>(string) | function=(thread: thread)>(string) | function=()>(string),
	setlocal = function=(thread: thread, level: number, local_: number, value: any)>(string | nil) | function=(level: number, local_: number, value: any)>(string | nil),
	getinfo = function=(thread: thread, f: empty_function | number, what: nil | string)>(debug_getinfo | nil) | function=(thread: thread, f: empty_function | number, what: nil | string)>(debug_getinfo | nil) | function=(f: empty_function | number, what: nil | string)>(debug_getinfo | nil),
	upvalueid = function=(f: empty_function, n: number)>(userdata),
	setupvalue = function=(f: empty_function, up: number, value: any)>(string | nil),
	getlocal = function=(thread: thread, f: number | empty_function, local_: number)>(string | nil, any) | function=(f: number | empty_function, local_: number)>(string | nil, any),
	upvaluejoin = function=(f1: empty_function, n1: number, f2: empty_function, n2: number)>(nil),
	getupvalue = function=(f: empty_function, up: number)>(string | nil, any),
	getmetatable = function=(value: any)>(Table | nil),
	setmetatable = function=(value: any, Table: Table | nil)>(any),
	gethook = function=(thread: thread)>(empty_function, string, number) | function=()>(empty_function, string, number),
	getuservalue = function=(u: userdata)>(Table | nil),
	debug = function=()>(nil),
	getfenv = function=(o: any)>(Table),
	setfenv = function=(object: any, Table: Table)>(any),
	setuservalue = function=(udata: userdata, value: Table | nil)>(userdata),
}
type debug.getfenv = getfenv
type debug.setfenv = setfenv end
IMPORTS['nattlua/definitions/lua/package.nlua'] = function() type package = {
	searchpath = function=(name: string, path: string, sep: string, rep: string)>(string | nil, string | nil) | function=(name: string, path: string, sep: string)>(string | nil, string | nil) | function=(name: string, path: string)>(string | nil, string | nil),
	seeall = function=(module: Table)>(nil),
	loadlib = function=(libname: string, funcname: string)>(empty_function | nil),
	config = "/\n;\n?\n!\n-\n",
} end
IMPORTS['nattlua/definitions/lua/bit.nlua'] = function() type bit32 = {
	lrotate = function=(x: number, disp: number)>(number),
	bor = function=(...)>(number),
	rshift = function=(x: number, disp: number)>(number),
	band = function=(...)>(number),
	lshift = function=(x: number, disp: number)>(number),
	rrotate = function=(x: number, disp: number)>(number),
	replace = function=(n: number, v: number, field: number, width: number)>(number) | function=(n: number, v: number, field: number)>(number),
	bxor = function=(...)>(number),
	arshift = function=(x: number, disp: number)>(number),
	extract = function=(n: number, field: number, width: number)>(number) | function=(n: number, field: number)>(number),
	bnot = function=(x: number)>(number),
	btest = function=(...)>(boolean),
	tobit = function=(...)>(number),
}
type bit = bit32

do
	analyzer function bit.bor(...: ...number): number
		local out = {}

		for i, num in ipairs({...}) do
			if not num:IsLiteral() then return types.Number() end

			out[i] = num:GetData()
		end

		return bit.bor(table.unpack(out))
	end

	analyzer function bit.band(...: ...number): number
		local out = {}

		for i, num in ipairs({...}) do
			if not num:IsLiteral() then return types.Number() end

			out[i] = num:GetData()
		end

		return bit.band(table.unpack(out))
	end

	analyzer function bit.bxor(...: ...number): number
		local out = {}

		for i, num in ipairs({...}) do
			if not num:IsLiteral() then return types.Number() end

			out[i] = num:GetData()
		end

		return bit.bxor(table.unpack(out))
	end

	analyzer function bit.tobit(n: number): number
		if n:IsLiteral() then return bit.tobit(n:GetData()) end

		return types.Number()
	end

	analyzer function bit.bnot(n: number): number
		if n:IsLiteral() then return bit.bnot(n:GetData()) end

		return types.Number()
	end

	analyzer function bit.bswap(n: number): number
		if n:IsLiteral() then return bit.bswap(n:GetData()) end

		return types.Number()
	end

	analyzer function bit.tohex(x: number, n: nil | number): string
		if x:IsLiteral() then
			if n and n:IsLiteral() then return bit.tohex(x:GetData(), n:GetData()) end

			return bit.tohex(x:GetData())
		end

		return types.String()
	end

	analyzer function bit.lshift(x: number, n: number): number
		if x:IsLiteral() and n:IsLiteral() then
			return bit.lshift(x:GetData(), n:GetData())
		end

		return types.Number()
	end

	analyzer function bit.rshift(x: number, n: number): number
		if x:IsLiteral() and n:IsLiteral() then
			return bit.rshift(x:GetData(), n:GetData())
		end

		return types.Number()
	end

	analyzer function bit.arshift(x: number, n: number): number
		if x:IsLiteral() and n:IsLiteral() then
			return bit.arshift(x:GetData(), n:GetData())
		end

		return types.Number()
	end

	analyzer function bit.rol(x: number, n: number): number
		if x:IsLiteral() and n:IsLiteral() then
			return bit.rol(x:GetData(), n:GetData())
		end

		return types.Number()
	end

	analyzer function bit.ror(x: number, n: number): number
		if x:IsLiteral() and n:IsLiteral() then
			return bit.ror(x:GetData(), n:GetData())
		end

		return types.Number()
	end
end end
IMPORTS['nattlua/definitions/lua/table.nlua'] = function() type table = {
	maxn = function=(table: Table)>(number),
	move = function=(a1: Table, f: any, e: any, t: any, a2: Table)>(nil) | function=(a1: Table, f: any, e: any, t: any)>(nil),
	remove = function=(list: Table, pos: number)>(any) | function=(list: Table)>(any),
	sort = function=(list: Table, comp: empty_function)>(nil) | function=(list: Table)>(nil),
	unpack = function=(list: Table, i: number, j: number)>(...) | function=(list: Table, i: number)>(...) | function=(list: Table)>(...),
	insert = function=(list: Table, pos: number, value: any)>(nil) | function=(list: Table, value: any)>(nil),
	concat = function=(list: Table, sep: string, i: number, j: number)>(string) | function=(list: Table, sep: string, i: number)>(string) | function=(list: Table, sep: string)>(string) | function=(list: Table)>(string),
	pack = function=(...)>(Table),
	new = function=(number, number)>({[number] = any}),
}

analyzer function table.concat(tbl: List<|string|>, separator: string | nil)
	if not tbl:IsLiteral() then return types.String() end

	if
		separator and
		(
			separator.Type ~= "string" or
			not separator:IsLiteral()
		)
		and
		not separator.Type ~= "symbol" and
		separator:GetData() ~= nil
	then
		return types.String()
	end

	local out = {}

	for i, keyval in ipairs(tbl:GetData()) do
		if not keyval.val:IsLiteral() or keyval.val.Type == "union" then
			return types.String()
		end

		out[i] = keyval.val:GetData()
	end

	return table.concat(out, separator and separator:GetData() or nil)
end

analyzer function table.insert(tbl: List<|any|>, ...: ...any)
	if tbl.Type == "any" then return end

	local pos, val = ...

	if not val then
		val = pos
		pos = tbl:GetLength(analyzer)
	else
		pos = tbl:GetLength(analyzer)
	end

	local contract = tbl:GetContract()

	if contract then
		local values = contract:GetValueUnion()
		values:RemoveType(types.Nil())
		analyzer:Assert(val:IsSubsetOf(values))
	end

	if not tbl:HasLiteralKeys() then return end

	if pos and pos:IsLiteral() then
		pos:SetData(pos:GetData() + 1)
		local max = pos:GetMax()

		if max then max:SetData(max:GetData() + 1) end
	end

	if analyzer:IsInUncertainLoop() then pos:Widen() end

	assert(type(pos) ~= "number")
	analyzer:NewIndexOperator(tbl, pos, val)
end

analyzer function table.remove(tbl: List<|any|>, index: number | nil)
	if tbl:GetContract() then tbl = tbl:GetContract() end

	if not tbl:IsLiteral() then return tbl:Get(types.Number()) end

	if index and not index:IsLiteral() then return tbl:Get(types.Number()) end

	index = index or 1
	return table.remove(tbl:GetData(), index:GetData())
end

analyzer function table.sort(tbl: List<|any|>, func: nil | function=(a: any, b: any)>(boolean))
	local union = types.Union()

	if tbl.Type == "tuple" then
		for i, v in ipairs(tbl:GetData()) do
			union:AddType(v)
		end
	elseif tbl.Type == "table" then
		for i, v in ipairs(tbl:GetData()) do
			union:AddType(v.val)
		end
	end

	if func then
		func:GetInputSignature():GetData()[1] = union
		func:GetInputSignature():GetData()[2] = union
		func:SetArgumentsInferred(true)
	end

	if tbl:IsLiteral() then
		if func then
			table.sort(tbl:GetData(), function(a, b)
				local b = analyzer:Call(func, types.Tuple({a.val, b.val})):Get(1)

				if b:IsCertainlyTrue() or b:IsCertainlyFalse() then
					return b:IsCertainlyTrue()
				else
					analyzer:Error("cannot sort literal table with function that returns an uncertain boolean")
				end
			end)
		else
			table.sort(tbl:GetData(), function(a, b)
				return a.val:GetData() < b.val:GetData()
			end)
		end

		for i, kv in ipairs(tbl:GetData()) do
			kv.key = kv.key:SetData(i)
		end
	end
end

analyzer function table.getn(tbl: List<|any|>)
	return tbl:GetLength()
end

analyzer function table.unpack(tbl: List<|any|>)
	local t = {}

	for i = 1, 32 do
		local v = tbl:Get(types.LNumber(i))

		if not v then break end

		t[i] = v
	end

	return table.unpack(t)
end

type unpack = table.unpack

function table.destructure(tbl: Table, fields: List<|string|>, with_default: boolean | nil)
	local out = {}

	for i, key in ipairs(fields) do
		out[i] = tbl[key]
	end

	if with_default then table.insert(out, 1, tbl) end

	return table.unpack(out)
end

function table.mergetables(tables: List<|Table|>)
	local out = {}

	for i, tbl in ipairs(tables) do
		for k, v in pairs(tbl) do
			out[k] = v
		end
	end

	return out
end

function table.spread(tbl: nil | List<|any|>)
	if not tbl then return nil end

	return table.unpack(tbl)
end end
IMPORTS['nattlua/definitions/lua/string.nlua'] = function() type string = {
	find = function=(s: string, pattern: string, init: number | nil, plain: boolean | nil)>(number | nil, number | nil, ...string),
	len = function=(s: string)>(number),
	packsize = function=(fmt: string)>(number),
	match = function=(s: string, pattern: string, init: number | nil)>(...string),
	upper = function=(s: string)>(string),
	sub = function=(s: string, i: number, j: number)>(string) | function=(s: string, i: number)>(string),
	char = function=(...)>(string),
	rep = function=(s: string, n: number, sep: string)>(string) | function=(s: string, n: number)>(string),
	lower = function=(s: string)>(string),
	dump = function=(empty_function: empty_function)>(string),
	gmatch = function=(s: string, pattern: string)>(empty_function),
	reverse = function=(s: string)>(string),
	byte = function=(s: string, i: number | nil, j: number | nil)>(...number),
	unpack = function=(fmt: string, s: string, pos: number | nil)>(...any),
	gsub = function=(s: string, pattern: string, repl: string | Table | empty_function, n: number | nil)>(string, number),
	format = function=(string, ...any)>(string),
	pack = function=(fmt: string, ...any)>(string),
}

analyzer function ^string.reverse(str: literal string): string
	return str:GetData():reverse()
end

analyzer function ^string.rep(str: string, n: number, sep: nil | string)
	if str:IsLiteral() and n:IsLiteral() then
		if sep and sep:IsLiteral() then
			return types.LString(string.rep(str:GetData(), n:GetData(), sep:GetData()))
		end

		return types.LString(string.rep(str:GetData(), n:GetData()))
	end

	return types.String()
end

analyzer function ^string.char(...: ...number)
	local out = {}

	for i, num in ipairs({...}) do
		if num.Type ~= "number" or not num:IsLiteral() then return types.String() end

		out[i] = num:GetData()

		if out[i] < 0 or out[i] > 255 then error("out of range", 2) end
	end

	return string.char(table.unpack(out))
end

analyzer function ^string.format(s: string, ...: ...any)
	if not s:IsLiteral() then return types.String() end

	local ret = {...}

	for i, v in ipairs(ret) do
		if v:IsLiteral() then
			ret[i] = v:GetData()

			if v.Type == "function" then ret[i] = v.GetData end
		else
			return types.String()
		end
	end

	return string.format(s:GetData(), table.unpack(ret))
end

analyzer function ^string.gmatch(s: string, pattern: string)
	if s:IsLiteral() and pattern:IsLiteral() then
		local f = s:GetData():gmatch(pattern:GetData())
		local i = 1
		return function()
			local strings = {f()}

			if strings[1] then
				for i, v in ipairs(strings) do
					strings[i] = types.LString(v)
				end

				return types.Tuple(strings)
			end
		end
	end

	if pattern:IsLiteral() then
		local _, count = pattern:GetData():gsub("%b()", "")
		local done = false
		return function()
			if done then return end

			done = true
			return types.Tuple({types.String()}):SetRepeat(count)
		end
	end

	local done = false
	return function()
		if done then return end

		done = true
		return types.String()
	end
end

analyzer function ^string.lower(str: string)
	if str:IsLiteral() then return str:GetData():lower() end

	return types.String()
end

analyzer function ^string.upper(str: string)
	if str:IsLiteral() then return str:GetData():upper() end

	return types.String()
end

analyzer function ^string.sub(str: string, a: number, b: number | nil)
	if str:IsLiteral() and a:IsLiteral() then
		if b and b:IsLiteral() then
			return str:GetData():sub(a:GetData(), b:GetData())
		end

		return str:GetData():sub(a:GetData())
	end

	return types.String()
end

analyzer function ^string.byte(str: string, from: number | nil, to: number | nil)
	if str:IsLiteral() and not from and not to then
		return string.byte(str:GetData())
	end

	if str:IsLiteral() and from and from:IsLiteral() and not to then
		return string.byte(str:GetData(), from:GetData())
	end

	if str:IsLiteral() and from and from:IsLiteral() and to and to:IsLiteral() then
		return string.byte(str:GetData(), from:GetData(), to:GetData())
	end

	if from and from:IsLiteral() and to and to:IsLiteral() then
		return types.Tuple({}):AddRemainder(types.Tuple({types.Number()}):SetRepeat(to:GetData() - from:GetData() + 1))
	end

	return types.Tuple({}):AddRemainder(types.Tuple({types.Number()}):SetRepeat(math.huge))
end

analyzer function ^string.match(str: string, pattern: string, start_position: number | nil)
	str = str:IsLiteral() and str:GetData()
	pattern = pattern:IsLiteral() and pattern:GetData()
	start_position = start_position and
		start_position:IsLiteral() and
		start_position:GetData() or
		1

	if not str or not pattern then
		return types.Tuple({types.Union({types.String(), types.Nil()})}):SetRepeat(math.huge)
	end

	local res = {str:match(pattern, start_position)}

	for i, v in ipairs(res) do
		if type(v) == "string" then
			res[i] = types.LString(v)
		else
			res[i] = types.LNumber(v)
		end
	end

	return table.unpack(res)
end

analyzer function ^string.find(str: string, pattern: string, start_position: number | nil, no_pattern: boolean | nil)
	str = str:IsLiteral() and str:GetData()
	pattern = pattern:IsLiteral() and pattern:GetData()
	start_position = start_position and
		start_position:IsLiteral() and
		start_position:GetData() or
		1
	no_pattern = no_pattern and no_pattern:IsLiteral() and no_pattern:GetData() or false

	if not str or not pattern then
		return types.Tuple(
			{
				types.Union({types.Number(), types.Nil()}),
				types.Union({types.Number(), types.Nil()}),
				types.Union({types.String(), types.Nil()}),
			}
		)
	end

	local start, stop, found = str:find(pattern, start_position, no_pattern)

	if found then types.LString(found) end

	return start, stop, found
end

analyzer function ^string.len(str: string)
	if str:IsLiteral() then return types.LNumber(#str:GetData()) end

	return types.Number()
end

analyzer function ^string.gsub(
	str: string,
	pattern: string,
	replacement: (ref function=(...string)>((...string))) | string | {[string] = string},
	max_replacements: number | nil
)
	str = str:IsLiteral() and str:GetData()
	pattern = pattern:IsLiteral() and pattern:GetData()
	max_replacements = max_replacements and max_replacements:GetData()

	if str and pattern and replacement then
		if replacement.Type == "string" and replacement:IsLiteral() then
			return string.gsub(str, pattern, replacement:GetData(), max_replacements)
		elseif replacement.Type == "table" and replacement:IsLiteral() then
			local out = {}

			for _, kv in ipairs(replacement:GetData()) do
				if kv.key:IsLiteral() and kv.val:IsLiteral() then
					out[kv.key:GetData()] = kv.val:GetData()
				end
			end

			return string.gsub(str, pattern, out, max_replacements)
		elseif replacement.Type == "function" then
			if not replacement:IsExplicitInputSignature() then
				replacement:SetInputSignature(types.Tuple({types.String()}):SetRepeat(math.huge))
			end

			replacement:SetCalled(false)
			return string.gsub(
				str,
				pattern,
				function(...)
					local ret = analyzer:Assert(analyzer:Call(replacement, analyzer:LuaTypesToTuple({...})))
					local out = {}

					for _, val in ipairs(ret:GetData()) do
						if not val:IsLiteral() then return nil end

						table.insert(out, val:GetData())
					end

					return table.unpack(out)
				end,
				max_replacements
			)
		end
	end

	return types.String(), types.Number()
end end
IMPORTS['nattlua/definitions/lua/math.nlua'] = function() type math = {
	ceil = function=(x: number)>(number),
	tan = function=(x: number)>(number),
	log10 = function=(x: number)>(number),
	sinh = function=(x: number)>(number),
	ldexp = function=(m: number, e: number)>(number),
	tointeger = function=(x: number)>(number),
	cosh = function=(x: number)>(number),
	min = function=(x: number, ...)>(number),
	fmod = function=(x: number, y: number)>(number),
	exp = function=(x: number)>(number),
	random = function=(m: number, n: number)>(number) | function=(m: number)>(number) | function=()>(number),
	rad = function=(x: number)>(number),
	log = function=(x: number, base: number)>(number) | function=(x: number)>(number),
	cos = function=(x: number)>(number),
	randomseed = function=(x: number)>(nil),
	floor = function=(x: number)>(number),
	tanh = function=(x: number)>(number),
	max = function=(x: number, ...)>(number),
	pow = function=(x: number, y: number)>(number),
	ult = function=(m: number, n: number)>(boolean),
	acos = function=(x: number)>(number),
	type = function=(x: number)>(string),
	abs = function=(x: number)>(number),
	frexp = function=(x: number)>(number, number),
	deg = function=(x: number)>(number),
	modf = function=(x: number)>(number, number),
	atan2 = function=(y: number, x: number)>(number),
	asin = function=(x: number)>(number),
	atan = function=(x: number)>(number),
	sqrt = function=(x: number)>(number),
	sin = function=(x: number)>(number),
}
type math.huge = inf
type math.pi = 3.14159265358979323864338327950288
type math.maxinteger = 0x7FFFFFFFFFFFFFFF
type math.mininteger = 0x8000000000000000

analyzer function math.type(n: literal number): "float" | "integer" | "nil"
	return "float"
end

analyzer function math.sin(n: literal number): number
	return math.sin(n:GetData())
end

analyzer function math.abs(n: literal number): number
	return math.abs(n:GetData())
end

analyzer function math.cos(n: literal number): number
	return math.cos(n:GetData())
end

analyzer function math.ceil(n: literal number): number
	return math.ceil(n:GetData())
end

analyzer function math.floor(n: literal number): number
	return math.floor(n:GetData())
end

analyzer function math.min(...: ...number)
	local numbers = {}

	for i = 1, select("#", ...) do
		local obj = select(i, ...)

		if not obj:IsLiteral() then
			return types.Number()
		else
			numbers[i] = obj:GetData()
		end
	end

	return math.min(table.unpack(numbers))
end

analyzer function math.max(...: ...number)
	local numbers = {}

	for i = 1, select("#", ...) do
		local obj = select(i, ...)

		if not obj:IsLiteral() then
			return types.Number()
		else
			numbers[i] = obj:GetData()
		end
	end

	return math.max(table.unpack(numbers))
end

analyzer function math.random(n: nil | number, m: nil | number)
	if not analyzer.enable_random_functions then
		if n and n:IsLiteral() and m and m:IsLiteral() then
			return types.LNumber(n:GetData()):SetMax(m)
		end

		return types.Number()
	end

	if n and m then return math.random(n:GetData(), m:GetData()) end

	if n then return math.random(n and n:GetData()) end

	return math.random()
end

analyzer function math.randomseed(n: number)
	if not analyzer.enable_random_functions then return end

	return math.randomseed(n:GetData())
end end
IMPORTS['nattlua/definitions/lua/os.nlua'] = function() type os = {
	execute = function=(command: string)>(boolean | nil, string, number | nil) | function=()>(boolean | nil, string, number | nil),
	rename = function=(oldname: string, newname: string)>(boolean | nil, string, number | nil),
	getenv = function=(varname: string)>(string | nil),
	difftime = function=(t2: number, t1: number)>(number),
	exit = function=(code: boolean | number, close: boolean)>(nil) | function=(code: boolean | number)>(nil) | function=()>(nil),
	remove = function=(filename: string)>(boolean | nil, string, number | nil),
	setlocale = function=(local_e: string, category: string)>(string | nil) | function=(local_e: string)>(string | nil),
	date = function=(format: string, time: number)>(string | Table) | function=(format: string)>(string | Table) | function=()>(string | Table),
	time = function=(table: Table)>(number) | function=()>(number),
	clock = function=()>(number),
	tmpname = function=()>(string),
} end
IMPORTS['nattlua/definitions/lua/coroutine.nlua'] = function() type coroutine = {
	create = function=(empty_function)>(thread),
	close = function=(thread)>(boolean, string),
	isyieldable = function=()>(boolean),
	resume = function=(thread, ...)>(boolean, ...),
	running = function=()>(thread, boolean),
	status = function=(thread)>(string),
	wrap = function=(empty_function)>(empty_function),
	yield = function=(...)>(...),
}

analyzer function coroutine.yield(...: ...any)
	analyzer.yielded_results = {...}
end

analyzer function coroutine.resume(thread: any, ...: ...any)
	if thread.Type == "any" then
		-- TODO: thread is untyped, when inferred
		return types.Boolean()
	end

	if not thread.co_func then
		error(tostring(thread) .. " is not a thread!", 2)
	end

	analyzer:Call(thread.co_func, types.Tuple({...}))
	return types.Boolean()
end

analyzer function coroutine.create(func: Function, ...: ...any)
	local t = types.Table()
	t.co_func = func
	return t
end

analyzer function coroutine.wrap(cb: Function)
	return function(...)
		analyzer:Call(cb, types.Tuple({...}))
		local res = analyzer.yielded_results

		if res then
			analyzer.yielded_results = nil
			return table.unpack(res)
		end
	end
end end
IMPORTS['nattlua/definitions/typed_ffi.nlua'] = function() local analyzer function cast(node: any, args: any)
	local table_print = IMPORTS['nattlua.other.table_print']("nattlua.other.table_print")
	local cast = env.typesystem.cast

	local function cdata_metatable(from, const)
		local meta = types.Table()
		meta:Set(
			types.LString("__index"),
			types.LuaTypeFunction(
				function(self, key)
					-- i'm not really sure about this
					-- boxed luajit ctypes seem to just get the metatable from the ctype
					return analyzer:Assert(analyzer:IndexOperator(from, key))
				end,
				{types.Any(), types.Any()},
				{}
			)
		)

		if const then
			meta:Set(
				types.LString("__newindex"),
				types.LuaTypeFunction(
					function(self, key, value)
						error("attempt to write to constant location")
					end,
					{types.Any(), types.Any(), types.Any()},
					{}
				)
			)
		end

		meta:Set(
			types.LString("__add"),
			types.LuaTypeFunction(function(self, key)
				return self
			end, {types.Any(), types.Any()}, {})
		)
		meta:Set(
			types.LString("__sub"),
			types.LuaTypeFunction(function(self, key)
				return self
			end, {types.Any(), types.Any()}, {})
		)
		return meta
	end

	if node.tag == "Enum" then
		local tbl = types.Table()
		local keys = {}

		for i, node in ipairs(node) do
			local key = types.LString(node[1])
			local val = types.LNumber(node[2] or i - 1)
			tbl:Set(key, val)
			table.insert(keys, key)
		end

		local key_union = types.Union(keys)
		local meta = types.Table()
		meta:Set(
			types.LString("__call"),
			types.LuaTypeFunction(
				function(self, key)
					return analyzer:Assert(tbl:Get(key))
				end,
				{types.Any(), key_union},
				{}
			)
		)
		tbl:SetMetaTable(meta)
		tbl.is_enum = true
		return tbl
	elseif node.tag == "Struct" or node.tag == "Union" then
		local tbl = types.Table()

		if node.n then
			tbl.ffi_name = "struct " .. node.n
			analyzer.current_tables = analyzer.current_tables or {}
			table.insert(analyzer.current_tables, tbl)
		end

		for _, node in ipairs(node) do
			if node.tag == "Pair" then
				local key = types.LString(node[2])
				local val = cast(node[1], args)
				tbl:Set(key, val)
			else
				table_print(node)
				error("NYI: " .. node.tag)
			end
		end

		if node.n then table.remove(analyzer.current_tables) end

		return tbl
	elseif node.tag == "Function" then
		local arguments = {}

		for _, arg in ipairs(node) do
			if arg.ellipsis then
				table.insert(
					arguments,
					types.Tuple({}):AddRemainder(types.Tuple({types.Any()}):SetRepeat(math.huge))
				)
			else
				_G.FUNCTION_ARGUMENT = true
				local arg = cast(arg[1], args)
				_G.FUNCTION_ARGUMENT = nil
				table.insert(arguments, arg)
			end
		end

		local return_type

		if
			node.t.tag == "Pointer" and
			node.t.t.tag == "Qualified" and
			node.t.t.t.n == "char"
		then
			local ptr = types.Table()
			ptr:Set(types.Number(), types.Number())
			return_type = types.Union({ptr, types.Nil()})
		else
			return_type = cast(node.t, args)
		end

		local obj = types.Function(types.Tuple(arguments), types.Tuple({return_type}))
		return obj
	elseif node.tag == "Array" then
		local tbl = types.Table()
		-- todo node.size: array length
		_G.FUNCTION_ARGUMENT = true
		local t = cast(node.t, args)
		_G.FUNCTION_ARGUMENT = nil
		tbl:Set(types.Number(), t)
		local meta = cdata_metatable(tbl)
		tbl:SetContract(tbl)
		tbl:SetMetaTable(meta)
		return tbl
	elseif node.tag == "Type" then
		if
			node.n == "double" or
			node.n == "float" or
			node.n == "int8_t" or
			node.n == "uint8_t" or
			node.n == "int16_t" or
			node.n == "uint16_t" or
			node.n == "int32_t" or
			node.n == "uint32_t" or
			node.n == "char" or
			node.n == "signed char" or
			node.n == "unsigned char" or
			node.n == "short" or
			node.n == "short int" or
			node.n == "signed short" or
			node.n == "signed short int" or
			node.n == "unsigned short" or
			node.n == "unsigned short int" or
			node.n == "int" or
			node.n == "signed" or
			node.n == "signed int" or
			node.n == "unsigned" or
			node.n == "unsigned int" or
			node.n == "long" or
			node.n == "long int" or
			node.n == "signed long" or
			node.n == "signed long int" or
			node.n == "unsigned long" or
			node.n == "unsigned long int" or
			node.n == "float" or
			node.n == "double" or
			node.n == "long double" or
			node.n == "size_t" or
			node.n == "intptr_t" or
			node.n == "uintptr_t"
		then
			return types.Number()
		elseif
			node.n == "int64_t" or
			node.n == "uint64_t" or
			node.n == "long long" or
			node.n == "long long int" or
			node.n == "signed long long" or
			node.n == "signed long long int" or
			node.n == "unsigned long long" or
			node.n == "unsigned long long int"
		then
			return types.Number()
		elseif node.n == "bool" or node.n == "_Bool" then
			return types.Boolean()
		elseif node.n == "void" then
			return types.Nil()
		elseif node.n == "va_list" then
			return types.Tuple({}):AddRemainder(types.Tuple({types.Any()}):SetRepeat(math.huge))
		elseif node.n:find("%$%d+%$") then
			local val = table.remove(args, 1)

			if not val then error("unable to lookup type $ #" .. (#args + 1), 2) end

			return val
		elseif node.parent and node.parent.tag == "TypeDef" then
			if node.n:sub(1, 6) == "struct" then
				local name = node.n:sub(7)
				local tbl = types.Table()
				tbl:SetName(types.LString(name))
				return tbl
			end
		else
			local val = analyzer:IndexOperator(env.typesystem.ffi:Get(types.LString("C")), types.LString(node.n))

			if not val or val.Type == "symbol" and val:GetData() == nil then
				if analyzer.current_tables then
					local current_tbl = analyzer.current_tables[#analyzer.current_tables]

					if current_tbl and current_tbl.ffi_name == node.n then return current_tbl end
				end

				analyzer:Error("cannot find value " .. node.n)
				return types.Any()
			end

			return val
		end
	elseif node.tag == "Qualified" then
		return cast(node.t, args)
	elseif node.tag == "Pointer" then
		if node.t.tag == "Type" and node.t.n == "void" then return types.Any() end

		local ptr = types.Table()
		local ctype = cast(node.t, args)
		ptr:Set(types.Number(), ctype)
		local meta = cdata_metatable(ctype, node.t.const)
		ptr:SetMetaTable(meta)

		if node.t.tag == "Qualified" and node.t.t.n == "char" then
			ptr:Set(types.Number(), ctype)
			ptr:SetName(types.LString("const char*"))

			if _G.FUNCTION_ARGUMENT then
				return types.Union({ptr, types.String(), types.Nil()})
			end

			return ptr
		end

		if node.t.tag == "Type" and node.t.n:sub(1, 1) ~= "$" then
			ptr:SetName(types.LString(node.t.n .. "*"))
		end

		return types.Union({ptr, types.Nil()})
	else
		table_print(node)
		error("NYI: " .. node.tag)
	end
end

analyzer function ffi.sizeof(cdata: any, len: nil | number)
	if cdata.Type == "string" and cdata:IsLiteral() then
		assert(IMPORTS['nattlua.other.cparser']("nattlua.other.cparser").parseString(cdata:GetData(), {typeof = true}))
		local ffi = require("ffi")
		local ok, val = pcall(ffi.sizeof, cdata:GetData(), len and len:GetData() or nil)

		if ok then return val end
	end

	return types.Number()
end

analyzer function ffi.cdef(cdecl: string, ...: ...any)
	assert(cdecl:IsLiteral(), "cdecl must be a string literal")

	for _, ctype in ipairs(assert(IMPORTS['nattlua.other.cparser']("nattlua.other.cparser").parseString(cdecl:GetData(), {}, {...}))) do
		ctype.type.parent = ctype
		analyzer:NewIndexOperator(
			env.typesystem.ffi:Get(types.LString("C")),
			types.LString(ctype.name),
			env.typesystem.cast(ctype.type, {...})
		)
	end
end

§env.typesystem.ffi:Get(types.LString("cdef")):SetPreventInputArgumentExpansion(true)

analyzer function ffi.cast(cdecl: string, src: any)
	assert(cdecl:IsLiteral(), "cdecl must be a string literal")
	local declarations = assert(IMPORTS['nattlua.other.cparser']("nattlua.other.cparser").parseString(cdecl:GetData(), {typeof = true}))
	local ctype = env.typesystem.cast(declarations[#declarations].type)

	-- TODO, this tries to extract cdata from cdata | nil, since if we cast a valid pointer it cannot be invalid when returned
	if ctype.Type == "union" then
		for _, v in ipairs(ctype:GetData()) do
			if v.Type == "table" then
				ctype = v

				break
			end
		end
	end

	if ctype.Type == "any" then return ctype end

	local nilable_ctype = ctype:Copy()

	for _, keyval in ipairs(nilable_ctype:GetData()) do
		keyval.val = types.Nilable(keyval.val)
	end

	ctype:SetMetaTable(ctype)
	return ctype
end

analyzer function ffi.typeof(cdecl: string, ...: ...any)
	assert(cdecl:IsLiteral(), "c_declaration must be a string literal")
	local args = {...}

	if args[1] and args[1].Type == "tuple" then args = {args[1]:Unpack()} end

	local declarations = assert(IMPORTS['nattlua.other.cparser']("nattlua.other.cparser").parseString(cdecl:GetData(), {typeof = true}, args))
	local ctype = env.typesystem.cast(declarations[#declarations].type, args)

	-- TODO, this tries to extract cdata from cdata | nil, since if we cast a valid pointer it cannot be invalid when returned
	if ctype.Type == "union" then
		for _, v in ipairs(ctype:GetData()) do
			if v.Type == "table" then
				ctype = v

				break
			end
		end
	end

	if ctype.Type == "any" then return ctype end

	local nilable_ctype = ctype:Copy()

	if ctype.Type == "table" then
		for _, keyval in ipairs(nilable_ctype:GetData()) do
			keyval.val = types.Nilable(keyval.val)
		end
	end

	if ctype.is_enum and ctype:GetMetaTable() then return ctype end

	local old = ctype:GetContract()
	ctype:SetContract()
	ctype:Set(
		types.LString("__call"),
		types.LuaTypeFunction(
			function(self, init)
				if init then analyzer:Assert(init:IsSubsetOf(nilable_ctype)) end

				return self:Copy()
			end,
			{ctype, types.Nilable(nilable_ctype)},
			{ctype}
		)
	)
	ctype:SetMetaTable(ctype)
	ctype:SetContract(old)
	return ctype
end

§env.typesystem.ffi:Get(types.LString("typeof")):SetPreventInputArgumentExpansion(true)

analyzer function ffi.get_type(cdecl: string, ...: ...any)
	assert(cdecl:IsLiteral(), "c_declaration must be a string literal")
	local declarations = assert(IMPORTS['nattlua.other.cparser']("nattlua.other.cparser").parseString(cdecl:GetData(), {typeof = true}, {...}))
	local ctype = env.typesystem.cast(declarations[#declarations].type, {...})
	return ctype
end

analyzer function ffi.new(cdecl: any, ...: ...any)
	local declarations = assert(IMPORTS['nattlua.other.cparser']("nattlua.other.cparser").parseString(cdecl:GetData(), {ffinew = true}, {...}))
	local ctype = env.typesystem.cast(declarations[#declarations].type, {...})

	if ctype.is_enum then return ... end

	return ctype
end

analyzer function ffi.metatype(ctype: any, meta: any)
	local new = meta:Get(types.LString("__new"))

	if new then
		meta:Set(
			types.LString("__call"),
			types.LuaTypeFunction(
				function(self, ...)
					local val = analyzer:Assert(analyzer:Call(new, types.Tuple({ctype, ...}))):Unpack()

					if val.Type == "union" then
						for i, v in ipairs(val:GetData()) do
							if v.Type == "table" then v:SetMetaTable(meta) end
						end
					else
						val:SetMetaTable(meta)
					end

					return val
				end,
				new:GetInputSignature():GetData(),
				new:GetOutputSignature():GetData()
			)
		)
	end

	ctype:SetMetaTable(meta)
end

analyzer function ffi.load(lib: string)
	return env.typesystem.ffi:Get(types.LString("C"))
end

analyzer function ffi.gc(ctype: any, callback: Function)
	return ctype
end end
IMPORTS['nattlua/definitions/utility.nlua']("./utility.nlua")
IMPORTS['nattlua/definitions/attest.nlua']("./attest.nlua")
IMPORTS['nattlua/definitions/lua/globals.nlua']("./lua/globals.nlua")
IMPORTS['nattlua/definitions/lua/io.nlua']("./lua/io.nlua")
IMPORTS['nattlua/definitions/lua/luajit.nlua']("./lua/luajit.nlua")
IMPORTS['nattlua/definitions/lua/debug.nlua']("./lua/debug.nlua")
IMPORTS['nattlua/definitions/lua/package.nlua']("./lua/package.nlua")
IMPORTS['nattlua/definitions/lua/bit.nlua']("./lua/bit.nlua")
IMPORTS['nattlua/definitions/lua/table.nlua']("./lua/table.nlua")
IMPORTS['nattlua/definitions/lua/string.nlua']("./lua/string.nlua")
IMPORTS['nattlua/definitions/lua/math.nlua']("./lua/math.nlua")
IMPORTS['nattlua/definitions/lua/os.nlua']("./lua/os.nlua")
IMPORTS['nattlua/definitions/lua/coroutine.nlua']("./lua/coroutine.nlua")
IMPORTS['nattlua/definitions/typed_ffi.nlua']("./typed_ffi.nlua") ]======] end
do local __M; IMPORTS["language_server.server.ljsocket"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ffi = require("ffi")
local socket = {}
local e = {}

do
	
	local C --[[: ffi.C]] = ffi.C

	if ffi.os == "Windows" then C = assert(ffi.load("ws2_32")) end

	local M = {}

	local function generic_function(
		C_name,
		cdef,
		alias,
		size_error_handling
	)
		ffi.cdef(cdef)
		alias = alias or C_name
		local func_name = alias
		local func = C[C_name]

		if size_error_handling == false then
			socket[func_name] = func
		elseif size_error_handling then
			socket[func_name] = function(...)
				local len = func(...)

				if len < 0 then return nil, socket.lasterror() end

				return len
			end
		else
			socket[func_name] = function(...)
				local ret = func(...)

				if ret == 0 then return true end

				return nil, socket.lasterror()
			end
		end
	end

	ffi.cdef[[
        struct in_addr {
            uint32_t s_addr;
        };

        struct in6_addr {
            union {
                uint8_t u6_addr8[16];
                uint16_t u6_addr16[8];
                uint32_t u6_addr32[4];
            } u6_addr;
        };
    ]]

	-- https://www.cs.dartmouth.edu/~sergey/cs60/on-sockaddr-structs.txt
	if ffi.os == "OSX" then
		ffi.cdef[[
            struct sockaddr {
                uint8_t sa_len;
                uint8_t sa_family;
                char sa_data[14];
            };

            struct sockaddr_in {
                uint8_t sin_len;
                uint8_t sin_family;
                uint16_t sin_port;
                struct in_addr sin_addr;
                char sin_zero[8];
            };

            struct sockaddr_in6 {
                uint8_t sin6_len;
                uint8_t sin6_family;
                uint16_t sin6_port;
                uint32_t sin6_flowinfo;
                struct in6_addr sin6_addr;
                uint32_t sin6_scope_id;
            };
        ]]
	elseif ffi.os == "Windows" then
		ffi.cdef[[
            struct sockaddr {
                uint16_t sa_family;
                char sa_data[14];
            };

            struct sockaddr_in {
                int16_t sin_family;
                uint16_t sin_port;
                struct in_addr sin_addr;
                uint8_t sin_zero[8];
            };

            struct sockaddr_in6 {
                int16_t sin6_family;
                uint16_t sin6_port;
                uint32_t sin6_flowinfo;
                struct in6_addr sin6_addr;
                uint32_t sin6_scope_id;
            };
        ]]
	else -- posix
		ffi.cdef[[
            struct sockaddr {
                uint16_t sa_family;
                char sa_data[14];
            };

            struct sockaddr_in {
                uint16_t sin_family;
                uint16_t sin_port;
                struct in_addr sin_addr;
                char sin_zero[8];
            };

            struct sockaddr_in6 {
                uint16_t sin6_family;
                uint16_t sin6_port;
                uint32_t sin6_flowinfo;
                struct in6_addr sin6_addr;
                uint32_t sin6_scope_id;
            };
        ]]
	end

	if ffi.os == "Windows" then
		ffi.cdef[[
            typedef size_t SOCKET;

            struct addrinfo {
                int ai_flags;
                int ai_family;
                int ai_socktype;
                int ai_protocol;
                size_t ai_addrlen;
                char *ai_canonname;
                struct sockaddr *ai_addr;
                struct addrinfo *ai_next;
            };
        ]]
		socket.INVALID_SOCKET = ffi.new("SOCKET", -1)
	elseif ffi.os == "OSX" then
		ffi.cdef[[
            typedef int32_t SOCKET;

            struct addrinfo {
                int ai_flags;
                int ai_family;
                int ai_socktype;
                int ai_protocol;
                uint32_t ai_addrlen;
                char *ai_canonname;
                struct sockaddr *ai_addr;
                struct addrinfo *ai_next;
            };
        ]]
		socket.INVALID_SOCKET = -1
	else
		ffi.cdef[[
            typedef int32_t SOCKET;

            struct addrinfo {
                int ai_flags;
                int ai_family;
                int ai_socktype;
                int ai_protocol;
                uint32_t ai_addrlen;
                struct sockaddr *ai_addr;
                char *ai_canonname;
                struct addrinfo *ai_next;
            };
        ]]
		socket.INVALID_SOCKET = -1
	end

	assert(ffi.sizeof("struct sockaddr") == 16)
	assert(ffi.sizeof("struct sockaddr_in") == 16)

	if ffi.os == "Windows" then
		do
			ffi.cdef[[
                uint32_t GetLastError();
            ]]
			ffi.cdef[[
                uint32_t FormatMessageA(
                    uint32_t dwFlags,
                    const void* lpSource,
                    uint32_t dwMessageId,
                    uint32_t dwLanguageId,
                    char* lpBuffer,
                    uint32_t nSize,
                    va_list *Arguments
                );
            ]]
			local FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000
			local FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200
			local flags = bit.bor(FORMAT_MESSAGE_IGNORE_INSERTS, FORMAT_MESSAGE_FROM_SYSTEM)
			local cache = {}

			function socket.lasterror(num)
				num = num or ffi.C.GetLastError()

				if not cache[num] then
					local buffer = ffi.new("char[512]")
					local len = ffi.C.FormatMessageA(flags, nil, num, 0, buffer, ffi.sizeof(buffer), nil)
					cache[num] = ffi.string(buffer, len - 2)
				end

				return cache[num]
			end
		end

		do
			ffi.cdef[[int WSAStartup(uint16_t version, void *wsa_data);]]
			local wsa_data

			if jit.arch == "x64" then
				wsa_data = ffi.typeof([[struct {
                    uint16_t wVersion;
                    uint16_t wHighVersion;
                    unsigned short iMax_M;
                    unsigned short iMaxUdpDg;
                    char * lpVendorInfo;
                    char szDescription[257];
                    char szSystemStatus[129];
                }]])
			else
				wsa_data = ffi.typeof([[struct {
                    uint16_t wVersion;
                    uint16_t wHighVersion;
                    char szDescription[257];
                    char szSystemStatus[129];
                    unsigned short iMax_M;
                    unsigned short iMaxUdpDg;
                    char * lpVendorInfo;
                }]])
			end

			local function WORD(low, high)
				return bit.bor(low, bit.lshift(high, 8))
			end

			function socket.initialize()
				local data = wsa_data()

				if C.WSAStartup(WORD(2, 2), data) == 0 then return data end

				return nil, socket.lasterror()
			end
		end

		do
			ffi.cdef[[int WSACleanup();]]

			function socket.shutdown()
				if C.WSACleanup() == 0 then return true end

				return nil, socket.lasterror()
			end
		end

		if jit.arch ~= "x64" then -- xp or something
			ffi.cdef[[int WSAAddressToStringA(struct sockaddr *, unsigned long, void *, char *, unsigned long *);]]

			function socket.inet_ntop(family, pAddr, strptr, strlen)
				-- win XP: http://memset.wordpress.com/2010/10/09/inet_ntop-for-win32/
				local srcaddr = ffi.new("struct sockaddr_in")
				ffi.copy(srcaddr.sin_addr, pAddr, ffi.sizeof(srcaddr.sin_addr))
				srcaddr.sin_family = family
				local len = ffi.new("unsigned long[1]", strlen)
				C.WSAAddressToStringA(ffi.cast("struct sockaddr *", srcaddr), ffi.sizeof(srcaddr), nil, strptr, len)
				return strptr
			end
		end

		generic_function("closesocket", "int closesocket(SOCKET s);", "close")

		do
			ffi.cdef[[int ioctlsocket(SOCKET s, long cmd, unsigned long* argp);]]
			local IOCPARM_MASK = 0x7
			local IOC_IN = 0x80000000

			local function _IOW(x, y, t)
				return bit.bor(
					IOC_IN,
					bit.lshift(bit.band(ffi.sizeof(t), IOCPARM_MASK), 16),
					bit.lshift(x, 8),
					y
				)
			end

			local FIONBIO = _IOW(string.byte("f"), 126, "uint32_t") -- -2147195266 -- 2147772030ULL
			function socket.blocking(fd, b)
				local ret = C.ioctlsocket(fd, FIONBIO, ffi.new("int[1]", b and 0 or 1))

				if ret == 0 then return true end

				return nil, socket.lasterror()
			end
		end

		ffi.cdef[[
            struct pollfd {
                SOCKET fd;
                short events;
                short revents;
            };
            int WSAPoll(struct pollfd *fds, unsigned long int nfds, int timeout);
        ]]

		function socket.poll(fds, ndfs, timeout)
			local ret = C.WSAPoll(fds, ndfs, timeout)

			if ret < 0 then return nil, socket.lasterror() end

			return ret
		end
	else
		ffi.cdef[[
            struct pollfd {
                SOCKET fd;
                short events;
                short revents;
            };

            int poll(struct pollfd *fds, unsigned long nfds, int timeout);
        ]]

		do
			local cache = {}

			function socket.lasterror(num)
				num = num or ffi.errno()

				if not cache[num] then
					local err = ffi.string(ffi.C.strerror(num))
					cache[num] = err == "" and tostring(num) or err
				end

				return cache[num]
			end
		end

		generic_function("close", "int close(SOCKET s);")

		do
			ffi.cdef[[int fcntl(int, int, ...);]]
			local F_GETFL = 3
			local F_SETFL = 4
			local O_NONBLOCK = 04000

			if ffi.os == "OSX" then O_NONBLOCK = 0x0004 end

			function socket.blocking(fd, b)
				local flags = ffi.C.fcntl(fd, F_GETFL, 0)

				if flags < 0 then -- error
				return nil, socket.lasterror() end

				if b then
					flags = bit.band(flags, bit.bnot(O_NONBLOCK))
				else
					flags = bit.bor(flags, O_NONBLOCK)
				end

				local ret = ffi.C.fcntl(fd, F_SETFL, ffi.new("int", flags))

				if ret < 0 then return nil, socket.lasterror() end

				return true
			end
		end

		function socket.poll(fds, ndfs, timeout)
			local ret = C.poll(fds, ndfs, timeout)

			if ret < 0 then return nil, socket.lasterror() end

			return ret
		end
	end

	ffi.cdef[[
        char *strerror(int errnum);
        int getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res);
        int getnameinfo(const struct sockaddr* sa, uint32_t salen, char* host, size_t hostlen, char* serv, size_t servlen, int flags);
        void freeaddrinfo(struct addrinfo *ai);
        const char *gai_strerror(int errcode);
        char *inet_ntoa(struct in_addr in);
        uint16_t ntohs(uint16_t netshort);
    ]]

	function socket.getaddrinfo(node_name, service_name, hints, result)
		local ret = C.getaddrinfo(node_name, service_name, hints, result)

		if ret == 0 then return true end

		return nil, ffi.string(C.gai_strerror(ret))
	end

	function socket.getnameinfo(address, length, host, hostlen, serv, servlen, flags)
		local ret = C.getnameinfo(address, length, host, hostlen, serv, servlen, flags)

		if ret == 0 then return true end

		return nil, ffi.string(C.gai_strerror(ret))
	end

	do
		ffi.cdef[[const char *inet_ntop(int __af, const void *__cp, char *__buf, unsigned int __len);]]

		function socket.inet_ntop(family, addrinfo, strptr, strlen)
			if C.inet_ntop(family, addrinfo, strptr, strlen) == nil then
				return nil, socket.lasterror()
			end

			return strptr
		end
	end

	do
		ffi.cdef[[SOCKET socket(int af, int type, int protocol);]]

		--[[type C.socket = function(number, number, number): number]] function socket.create(af, type, protocol)
			local fd = C.socket(af, type, protocol)

			if fd <= 0 then return nil, socket.lasterror() end

			return fd
		end
	end

	generic_function("shutdown", "int shutdown(SOCKET s, int how);")
	generic_function(
		"setsockopt",
		"int setsockopt(SOCKET s, int level, int optname, const void* optval, uint32_t optlen);"
	)
	generic_function(
		"getsockopt",
		"int getsockopt(SOCKET s, int level, int optname, void *optval, uint32_t *optlen);"
	)
	generic_function("accept", "SOCKET accept(SOCKET s, struct sockaddr *, int *);", nil, false)
	generic_function("bind", "int bind(SOCKET s, const struct sockaddr* name, int namelen);")
	generic_function("connect", "int connect(SOCKET s, const struct sockaddr * name, int namelen);")
	generic_function("listen", "int listen(SOCKET s, int backlog);")
	generic_function("recv", "int recv(SOCKET s, char* buf, int len, int flags);", nil, true)
	generic_function(
		"recvfrom",
		"int recvfrom(SOCKET s, char* buf, int len, int flags, struct sockaddr *src_addr, unsigned int *addrlen);",
		nil,
		true
	)
	generic_function("send", "int send(SOCKET s, const char* buf, int len, int flags);", nil, true)
	generic_function(
		"sendto",
		"int sendto(SOCKET s, const char* buf, int len, int flags, const struct sockaddr* to, int tolen);",
		nil,
		true
	)
	generic_function("getpeername", "int getpeername(SOCKET s, struct sockaddr *, unsigned int *);")
	generic_function("getsockname", "int getsockname(SOCKET s, struct sockaddr *, unsigned int *);")
	socket.inet_ntoa = C.inet_ntoa
	socket.ntohs = C.ntohs

	function socket.poll(fd, events, revents) end

	e = {
		TCP_NODELAY = 1,
		TCP_MAXSEG = 2,
		TCP_CORK = 3,
		TCP_KEEPIDLE = 4,
		TCP_KEEPINTVL = 5,
		TCP_KEEPCNT = 6,
		TCP_SYNCNT = 7,
		TCP_LINGER2 = 8,
		TCP_DEFER_ACCEPT = 9,
		TCP_WINDOW_CLAMP = 10,
		TCP_INFO = 11,
		TCP_QUICKACK = 12,
		TCP_CONGESTION = 13,
		TCP_MD5SIG = 14,
		TCP_THIN_LINEAR_TIMEOUTS = 16,
		TCP_THIN_DUPACK = 17,
		TCP_USER_TIMEOUT = 18,
		TCP_REPAIR = 19,
		TCP_REPAIR_QUEUE = 20,
		TCP_QUEUE_SEQ = 21,
		TCP_REPAIR_OPTIONS = 22,
		TCP_FASTOPEN = 23,
		TCP_TIMESTAMP = 24,
		TCP_NOTSENT_LOWAT = 25,
		TCP_CC_INFO = 26,
		TCP_SAVE_SYN = 27,
		TCP_SAVED_SYN = 28,
		TCP_REPAIR_WINDOW = 29,
		TCP_FASTOPEN_CONNECT = 30,
		TCP_ULP = 31,
		TCP_MD5SIG_EXT = 32,
		TCP_FASTOPEN_KEY = 33,
		TCP_FASTOPEN_NO_COOKIE = 34,
		TCP_ZEROCOPY_RECEIVE = 35,
		TCP_INQ = 36,
		AF_INET = 2,
		AF_INET6 = 10,
		AF_UNSPEC = 0,
		AF_UNIX = 1,
		AF_AX25 = 3,
		AF_IPX = 4,
		AF_APPLETALK = 5,
		AF_NETROM = 6,
		AF_BRIDGE = 7,
		AF_AAL5 = 8,
		AF_X25 = 9,
		INET6_ADDRSTRLEN = 46,
		INET_ADDRSTRLEN = 16,
		SO_DEBUG = 1,
		SO_REUSEADDR = 2,
		SO_TYPE = 3,
		SO_ERROR = 4,
		SO_DONTROUTE = 5,
		SO_BROADCAST = 6,
		SO_SNDBUF = 7,
		SO_RCVBUF = 8,
		SO_SNDBUFFORCE = 32,
		SO_RCVBUFFORCE = 33,
		SO_KEEPALIVE = 9,
		SO_OOBINLINE = 10,
		SO_NO_CHECK = 11,
		SO_PRIORITY = 12,
		SO_LINGER = 13,
		SO_BSDCOMPAT = 14,
		SO_REUSEPORT = 15,
		SO_PASSCRED = 16,
		SO_PEERCRED = 17,
		SO_RCVLOWAT = 18,
		SO_SNDLOWAT = 19,
		SO_RCVTIMEO = 20,
		SO_SNDTIMEO = 21,
		SO_SECURITY_AUTHENTICATION = 22,
		SO_SECURITY_ENCRYPTION_TRANSPORT = 23,
		SO_SECURITY_ENCRYPTION_NETWORK = 24,
		SO_BINDTODEVICE = 25,
		SO_ATTACH_FILTER = 26,
		SO_DETACH_FILTER = 27,
		SO_GET_FILTER = 26,
		SO_PEERNAME = 28,
		SO_TIMESTAMP = 29,
		SO_ACCEPTCONN = 30,
		SO_PEERSEC = 31,
		SO_PASSSEC = 34,
		SO_TIMESTAMPNS = 35,
		SO_MARK = 36,
		SO_TIMESTAMPING = 37,
		SO_PROTOCOL = 38,
		SO_DOMAIN = 39,
		SO_RXQ_OVFL = 40,
		SO_WIFI_STATUS = 41,
		SO_PEEK_OFF = 42,
		SO_NOFCS = 43,
		SO_LOCK_FILTER = 44,
		SO_SELECT_ERR_QUEUE = 45,
		SO_BUSY_POLL = 46,
		SO_MAX_PACING_RATE = 47,
		SO_BPF_EXTENSIONS = 48,
		SO_INCOMING_CPU = 49,
		SO_ATTACH_BPF = 50,
		SO_DETACH_BPF = 27,
		SO_ATTACH_REUSEPORT_CBPF = 51,
		SO_ATTACH_REUSEPORT_EBPF = 52,
		SO_CNX_ADVICE = 53,
		SO_MEMINFO = 55,
		SO_INCOMING_NAPI_ID = 56,
		SO_COOKIE = 57,
		SO_PEERGROUPS = 59,
		SO_ZEROCOPY = 60,
		SO_TXTIME = 61,
		SOL_SOCKET = 1,
		SOL_TCP = 6,
		SOMAXCONN = 128,
		IPPROTO_IP = 0,
		IPPROTO_HOPOPTS = 0,
		IPPROTO_ICMP = 1,
		IPPROTO_IGMP = 2,
		IPPROTO_IPIP = 4,
		IPPROTO_TCP = 6,
		IPPROTO_EGP = 8,
		IPPROTO_PUP = 12,
		IPPROTO_UDP = 17,
		IPPROTO_IDP = 22,
		IPPROTO_TP = 29,
		IPPROTO_DCCP = 33,
		IPPROTO_IPV6 = 41,
		IPPROTO_ROUTING = 43,
		IPPROTO_FRAGMENT = 44,
		IPPROTO_RSVP = 46,
		IPPROTO_GRE = 47,
		IPPROTO_ESP = 50,
		IPPROTO_AH = 51,
		IPPROTO_ICMPV6 = 58,
		IPPROTO_NONE = 59,
		IPPROTO_DSTOPTS = 60,
		IPPROTO_MTP = 92,
		IPPROTO_ENCAP = 98,
		IPPROTO_PIM = 103,
		IPPROTO_COMP = 108,
		IPPROTO_SCTP = 132,
		IPPROTO_UDPLITE = 136,
		IPPROTO_RAW = 255,
		SOCK_STREAM = 1,
		SOCK_DGRAM = 2,
		SOCK_RAW = 3,
		SOCK_RDM = 4,
		SOCK_SEQPACKET = 5,
		SOCK_DCCP = 6,
		SOCK_PACKET = 10,
		SOCK_CLOEXEC = 02000000,
		SOCK_NONBLOCK = 04000,
		AI_PASSIVE = 0x00000001,
		AI_CANONNAME = 0x00000002,
		AI_NUMERICHOST = 0x00000004,
		AI_NUMERICSERV = 0x00000008,
		AI_ALL = 0x00000100,
		AI_ADDRCONFIG = 0x00000400,
		AI_V4MAPPED = 0x00000800,
		AI_NON_AUTHORITATIVE = 0x00004000,
		AI_SECURE = 0x00008000,
		AI_RETURN_PREFERRED_NAMES = 0x00010000,
		AI_FQDN = 0x00020000,
		AI_FILESERVER = 0x00040000,
		POLLIN = 0x0001,
		POLLPRI = 0x0002,
		POLLOUT = 0x0004,
		POLLRDNORM = 0x0040,
		POLLWRNORM = 0x0004,
		POLLRDBAND = 0x0080,
		POLLWRBAND = 0x0100,
		POLLEXTEND = 0x0200,
		POLLATTRIB = 0x0400,
		POLLNLINK = 0x0800,
		POLLWRITE = 0x1000,
		POLLERR = 0x0008,
		POLLHUP = 0x0010,
		POLLNVAL = 0x0020,
		MSG_OOB = 0x01,
		MSG_PEEK = 0x02,
		MSG_DONTROUTE = 0x04,
		MSG_CTRUNC = 0x08,
		MSG_PROXY = 0x10,
		MSG_TRUNC = 0x20,
		MSG_DONTWAIT = 0x40,
		MSG_EOR = 0x80,
		MSG_WAITALL = 0x100,
		MSG_FIN = 0x200,
		MSG_SYN = 0x400,
		MSG_CONFIRM = 0x800,
		MSG_RST = 0x1000,
		MSG_ERRQUEUE = 0x2000,
		MSG_NOSIGNAL = 0x4000,
		MSG_MORE = 0x8000,
		MSG_WAITFORONE = 0x10000,
		MSG_CMSG_CLOEXEC = 0x40000000,
	}

	if ffi.os == "Windows" then
		e.SO_SNDLOWAT = 4099
		e.SO_REUSEADDR = 4
		e.SO_KEEPALIVE = 8
		e.SOMAXCONN = 2147483647
		e.AF_INET6 = 23
		e.SO_RCVTIMEO = 4102
		e.SOL_SOCKET = 65535
		e.SO_LINGER = 128
		e.SO_OOBINLINE = 256
		e.POLLWRNORM = 16
		e.SO_ERROR = 4103
		e.SO_BROADCAST = 32
		e.SO_ACCEPTCONN = 2
		e.SO_RCVBUF = 4098
		e.SO_SNDTIMEO = 4101
		e.POLLIN = 768
		e.POLLPRI = 1024
		e.SO_TYPE = 4104
		e.POLLRDBAND = 512
		e.POLLWRBAND = 32
		e.SO_SNDBUF = 4097
		e.POLLNVAL = 4
		e.POLLHUP = 2
		e.POLLERR = 1
		e.POLLRDNORM = 256
		e.SO_DONTROUTE = 16
		e.SO_RCVLOWAT = 4100
	end

	if ffi.os == "OSX" then
		e.SOL_SOCKET = 0xffff
		e.SO_DEBUG = 0x0001
		e.SO_ACCEPTCONN = 0x0002
		e.SO_REUSEADDR = 0x0004
		e.SO_KEEPALIVE = 0x0008
		e.SO_DONTROUTE = 0x0010
		e.SO_BROADCAST = 0x0020
	end

	if socket.initialize then assert(socket.initialize()) end
end

local function capture_flags(what)
	local flags = {}
	local reverse = {}

	for k, v in pairs(e) do
		if k:sub(0, #what) == what then
			k = k:sub(#what + 1):lower()
			reverse[v] = k
			flags[k] = v
		end
	end

	return {
		lookup = flags,
		reverse = reverse,
		strict_reverse = function(key)
			if not key then
				error("invalid " .. what:sub(0, -2) .. " flag: nil")
				return
			end

			if not reverse[key] then
				error("invalid " .. what:sub(0, -2) .. " flag: " .. key, 2)
			end

			return reverse[key]
		end,
		strict_lookup = function(key)
			if not key then
				error("invalid " .. what:sub(0, -2) .. " flag: nil")
				return
			end

			if not flags[key] then
				error("invalid " .. what:sub(0, -2) .. " flag: " .. key, 2)
			end

			return flags[key]
		end,
	}
end

local SOCK = capture_flags("SOCK_")
local AF = capture_flags("AF_")
local IPPROTO = capture_flags("IPPROTO_")
local AI = capture_flags("AI_")
local SOL = capture_flags("SOL_")
local SO = capture_flags("SO_")
local TCP = capture_flags("TCP_")
local POLL = capture_flags("POLL")

local function table_to_flags(flags, valid_flags, operation)
	if type(flags) == "string" then flags = {flags} end

	operation = operation or bit.band
	local out = 0

	for k, v in pairs(flags) do
		local flag = valid_flags[v] or valid_flags[k]

		if not flag then error("invalid flag " .. tostring(v), 2) end

		out = operation(out, tonumber(flag))
	end

	return out
end

local function flags_to_table(flags, valid_flags, operation)
	if not flags then return valid_flags.default_valid_flag end

	operation = operation or bit.band
	local out = {}

	for k, v in pairs(valid_flags) do
		if operation(flags, v) > 0 then out[k] = true end
	end

	return out
end

local M = {}
local timeout_messages = {}
timeout_messages["Operation now in progress"] = true
timeout_messages["Resource temporarily unavailable"] = true
timeout_messages["A non-blocking socket operation could not be completed immediately."] = true

function M.poll(socket, flags, timeout)
	local pfd = ffi.new(
		"struct pollfd[1]",
		{
			{
				fd = socket.fd,
				events = table_to_flags(flags, POLL.lookup, bit.bor),
				revents = 0,
			},
		}
	)
	local ok, err = socket.poll(pfd, 1, timeout or 0)

	if not ok then return ok, err end

	return flags_to_table(pfd[0].revents, POLL.lookup, bit.bor), ok
end

local function addrinfo_get_ip(self)
	if self.addrinfo.ai_addr == nil then return nil end

	local str = ffi.new("char[256]")
	local addr = assert(
		socket.inet_ntop(AF.lookup[self.family], self.addrinfo.ai_addr.sa_data, str, ffi.sizeof(str))
	)
	return ffi.string(addr)
end

local function addrinfo_get_port(self)
	if self.addrinfo.ai_addr == nil then return nil end

	if self.family == "inet" then
		return ffi.cast("struct sockaddr_in*", self.addrinfo.ai_addr).sin_port
	elseif self.family == "inet6" then
		return ffi.cast("struct sockaddr_in6*", self.addrinfo.ai_addr).sin6_port
	end

	return nil, "unknown family " .. tostring(self.family)
end

local function addrinfo_to_table(res, host, service)
	local info = {}

	if res.ai_canonname ~= nil then
		info.canonical_name = ffi.string(res.ai_canonname)
	end

	info.host = host ~= "*" and host or nil
	info.service = service
	info.family = AF.reverse[res.ai_family]
	info.socket_type = SOCK.reverse[res.ai_socktype]
	info.protocol = IPPROTO.reverse[res.ai_protocol]
	info.flags = flags_to_table(res.ai_flags, AI.lookup, bit.band)
	info.addrinfo = res
	info.get_ip = addrinfo_get_ip
	info.get_port = addrinfo_get_port
	return info
end

function M.get_address_info(data)
	local hints

	if data.socket_type or data.protocol or data.flags or data.family then
		hints = ffi.new(
			"struct addrinfo",
			{
				ai_family = data.family and AF.strict_lookup(data.family) or nil,
				ai_socktype = data.socket_type and SOCK.strict_lookup(data.socket_type) or nil,
				ai_protocol = data.protocol and IPPROTO.strict_lookup(data.protocol) or nil,
				ai_flags = data.flags and table_to_flags(data.flags, AI.lookup, bit.bor) or nil,
			}
		)
	end

	local out = ffi.new("struct addrinfo*[1]")
	local ok, err = socket.getaddrinfo(
		data.host ~= "*" and data.host or nil,
		data.service and tostring(data.service) or nil,
		hints,
		out
	)

	if not ok then return ok, err end

	local tbl = {}
	local res = out[0]

	while res ~= nil do
		table.insert(tbl, addrinfo_to_table(res, data.host, data.service))
		res = res.ai_next
	end

	--ffi.C.freeaddrinfo(out[0])
	return tbl
end

function M.find_first_address(host, service, options)
	options = options or {}
	local info = {}
	info.host = host
	info.service = service
	info.family = options.family or "inet"
	info.socket_type = options.socket_type or "stream"
	info.protocol = options.protocol or "tcp"
	info.flags = options.flags

	if host == "*" then
		info.flags = info.flags or {}
		table.insert(info.flags, "passive")
	end

	local addrinfo, err = M.get_address_info(info)

	if not addrinfo then return nil, err end

	if not addrinfo[1] then
		return nil, "no addresses found (empty address info table)"
	end

	for _, v in ipairs(addrinfo) do
		if
			v.family == info.family and
			v.socket_type == info.socket_type and
			v.protocol == info.protocol
		then
			return v
		end
	end

	return addrinfo[1]
end

do
	local meta = {}
	meta.__index = meta

	function meta:__tostring()
		return string.format("socket[%s-%s-%s][%s]", self.family, self.socket_type, self.protocol, self.fd)
	end

	function M.create(family, socket_type, protocol)
		local fd, err = socket.create(
			AF.strict_lookup(family),
			SOCK.strict_lookup(socket_type),
			IPPROTO.strict_lookup(protocol)
		)

		if not fd then return fd, err end

		return setmetatable(
			{
				fd = fd,
				family = family,
				socket_type = socket_type,
				protocol = protocol,
				blocking = true,
			},
			meta
		)
	end

	function meta:close()
		if self.on_close then self:on_close() end

		return socket.close(self.fd)
	end

	function meta:set_blocking(b)
		local ok, err = socket.blocking(self.fd, b)

		if not ok then return ok, err end

		self.blocking = b
		return ok, err
	end

	function meta:set_option(key, val, level)
		level = level or "socket"

		if type(val) == "boolean" then
			val = ffi.new("int[1]", val and 1 or 0)
		elseif type(val) == "number" then
			val = ffi.new("int[1]", val)
		elseif type(val) ~= "cdata" then
			error("unknown value type: " .. type(val))
		end

		local env = SO

		if level == "tcp" then env = TCP end

		return socket.setsockopt(
			self.fd,
			SOL.strict_lookup(level),
			env.strict_lookup(key),
			ffi.cast("void *", val),
			ffi.sizeof(val)
		)
	end

	function meta:connect(host, service)
		local res

		if type(host) == "table" and host.addrinfo then
			res = host
		else
			local res_, err = M.find_first_address(
				host,
				service,
				{
					family = self.family,
					socket_type = self.socket_type,
					protocol = self.protocol,
				}
			)

			if not res_ then return res_, err end

			res = res_
		end

		local ok, err = socket.connect(self.fd, res.addrinfo.ai_addr, res.addrinfo.ai_addrlen)

		if not ok and not self.blocking then
			if timeout_messages[err] then
				self.timeout_connected = {host, service}
				return true
			end
		elseif self.on_connect then
			self:on_connect(host, service)
		end

		if not ok then return ok, err end

		return true
	end

	function meta:on_connect() end

	function meta:poll_connect()
		if self.on_connect and self.timeout_connected and self:is_connected() then
			local ok, err = self:on_connect(unpack(self.timeout_connected))
			self.timeout_connected = nil
			return ok, err
		end

		return nil, "timeout"
	end

	function meta:bind(host, service)
		if host == "*" then host = nil end

		if type(service) == "number" then service = tostring(service) end

		local res

		if type(host) == "table" and host.addrinfo then
			res = host
		else
			local res_, err = M.find_first_address(
				host,
				service,
				{
					family = self.family,
					socket_type = self.socket_type,
					protocol = self.protocol,
				}
			)

			if not res_ then return res_, err end

			res = res_
		end

		return socket.bind(self.fd, res.addrinfo.ai_addr, res.addrinfo.ai_addrlen)
	end

	function meta:listen(max_connections)
		max_connections = max_connections or e.SOMAXCONN
		return socket.listen(self.fd, max_connections)
	end

	function meta:accept()
		local address = ffi.new("struct sockaddr_in[1]")
		local fd, err = socket.accept(
			self.fd,
			ffi.cast("struct sockaddr *", address),
			ffi.new("unsigned int[1]", ffi.sizeof(address))
		)

		if fd ~= socket.INVALID_SOCKET then
			local client = setmetatable(
				{
					fd = fd,
					family = "unknown",
					socket_type = "unknown",
					protocol = "unknown",
					blocking = true,
				},
				meta
			)

			if self.debug then
				print(tostring(self), ": accept client: ", tostring(client))
			end

			return client
		end

		local err = socket.lasterror()

		if not self.blocking and timeout_messages[err] then
			return nil, "timeout"
		end

		if self.debug then print(tostring(self), ": accept error: ", err) end

		return nil, err
	end

	if ffi.os == "Windows" then
		function meta:is_connected()
			local ip, service = self:get_peer_name()
			local ip2, service2 = self:get_name()
			return ip ~= "0.0.0.0" and ip2 ~= "0.0.0.0" and service ~= 0 and service2 ~= 0
		end
	else
		function meta:is_connected()
			local ip, service = self:get_peer_name()
			local ip2, service2 = self:get_name()
			return ip and ip2 and service ~= 0 and service2 ~= 0
		end
	end

	function meta:get_peer_name()
		local data = ffi.new("struct sockaddr_in")
		local len = ffi.new("unsigned int[1]", ffi.sizeof(data))
		local ok, err = socket.getpeername(self.fd, ffi.cast("struct sockaddr *", data), len)

		if not ok then return ok, err end

		return ffi.string(socket.inet_ntoa(data.sin_addr)), socket.ntohs(data.sin_port)
	end

	function meta:get_name()
		local data = ffi.new("struct sockaddr_in")
		local len = ffi.new("unsigned int[1]", ffi.sizeof(data))
		local ok, err = socket.getsockname(self.fd, ffi.cast("struct sockaddr *", data), len)

		if not ok then return ok, err end

		return ffi.string(socket.inet_ntoa(data.sin_addr)), socket.ntohs(data.sin_port)
	end

	local default_flags = 0

	if ffi.os ~= "Windows" then default_flags = e.MSG_NOSIGNAL end

	function meta:send_to(addr, data, flags)
		return self:send(data, flags, addr)
	end

	function meta:send(data, flags, addr)
		flags = flags or default_flags

		if self.on_send then return self:on_send(data, flags) end

		local len, err

		if addr then
			len, err = socket.sendto(self.fd, data, #data, flags, addr.addrinfo.ai_addr, addr.addrinfo.ai_addrlen)
		else
			len, err = socket.send(self.fd, data, #data, flags)
		end

		if not len then
			if not self.blocking and timeout_messages[err] then
				return nil, "timeout"
			end

			return len, err
		end

		if len > 0 then return len end
	end

	function meta:receive_from(address, size, flags)
		local src_addr
		local src_addr_size

		if not address then
			src_addr = ffi.new("struct sockaddr_in[1]")
			src_addr_size = ffi.sizeof("struct sockaddr_in")
		else
			src_addr = address.addrinfo.ai_addr
			src_addr_size = address.addrinfo.ai_addrlen
		end

		return self:receive(size, flags, src_addr, src_addr_size)
	end

	function meta:receive(size, flags, src_address, address_len)
		size = size or 64000
		local buff = ffi.new("char[?]", size)

		if self.on_receive then return self:on_receive(buff, size, flags) end

		local len, err
		local len_res

		if src_address then
			len_res = ffi.new("int[1]", address_len)
			len, err = socket.recvfrom(
				self.fd,
				buff,
				ffi.sizeof(buff),
				flags or 0,
				ffi.cast("struct sockaddr *", src_address),
				len_res
			)
		else
			len, err = socket.recv(self.fd, buff, ffi.sizeof(buff), flags or 0)
		end

		if not len then
			if not self.blocking and timeout_messages[err] then
				return nil, "timeout"
			end

			if self.debug then print(tostring(self), " error: ", err) end

			return len, err
		end

		if len > 0 then
			if self.debug then print(tostring(self), ": received ", len, " bytes") end

			if src_address then
				return ffi.string(buff, len),
				{
					addrinfo = {
						ai_addr = ffi.cast("struct sockaddr *", src_address),
						ai_addrlen = len_res[0],
					},
					family = self.family,
					get_port = addrinfo_get_port,
					get_ip = addrinfo_get_ip,
				}
			end

			return ffi.string(buff, len)
		end

		if self.debug then print(tostring(self), ": closed") end

		return nil, "closed"
	end
end

function M.bind(host, service)
	local info, err = M.find_first_address(
		host,
		service,
		{
			family = "inet",
			socket_type = "stream",
			protocol = "tcp",
			flags = {"passive"},
		}
	)

	if not info then return info, err end

	local server, err = M.create(info.family, info.socket_type, info.protocol)

	if not server then return server, err end

	server:set_option("reuseaddr", 1)
	local ok, err = server:bind(info)

	if not ok then return ok, err end

	server:set_option("sndbuf", 65536)
	server:set_option("rcvbuf", 65536)
	return server
end

return M end ]=======], '@./language_server/server/ljsocket.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.base64"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) 
local base64 = {}
local extract = _G.bit32 and _G.bit32.extract -- Lua 5.2/Lua 5.3 in compatibility mode
if not extract then
	if _G.bit then -- LuaJIT
		local shl, shr, band = _G.bit.lshift, _G.bit.rshift, _G.bit.band
		extract = function(v, from, width)
			return band(shr(v, from), shl(1, width) - 1)
		end
	elseif _G._VERSION == "Lua 5.1" then
		extract = function(v, from, width)
			local w = 0
			local flag = 2 ^ from

			for i = 0, width - 1 do
				local flag2 = flag + flag

				if v % flag2 >= flag then w = w + 2 ^ i end

				flag = flag2
			end

			return w
		end
	else -- Lua 5.3+
		extract = load[[return function( v, from, width )
			return ( v >> from ) & ((1 << width) - 1)
		end]]()
	end
end

function base64.makeencoder(s62, s63, spad)
	local characters = {
		[0] = "A",
		"B",
		"C",
		"D",
		"E",
		"F",
		"G",
		"H",
		"I",
		"J",
		"K",
		"L",
		"M",
		"N",
		"O",
		"P",
		"Q",
		"R",
		"S",
		"T",
		"U",
		"V",
		"W",
		"X",
		"Y",
		"Z",
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
		"0",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		s62 or
		"+",
		s63 or
		"/",
		spad or
		"=",
	}
	local encoder = {}

	for b64code, char in pairs(characters) do
		encoder[b64code] = char:byte()
	end

	return encoder
end

function base64.makedecoder(s62, s63, spad)
	local decoder = {}

	for b64code, charcode in pairs(base64.makeencoder(s62, s63, spad)) do
		decoder[charcode] = b64code
	end

	return decoder
end

local DEFAULT_ENCODER = base64.makeencoder()
local DEFAULT_DECODER = base64.makedecoder()
local char, concat = string.char, table.concat

function base64.encode(
	str,
	encoder,
	usecaching
)
	encoder = encoder or DEFAULT_ENCODER
	local t, k, n = {}, 1, #str
	local lastn = n % 3
	local cache = {}

	for i = 1, n - lastn, 3 do
		local a, b, c = str:byte(i, i + 2)
		local v = a * 0x10000 + b * 0x100 + c
		local s

		if usecaching then
			s = cache[v]

			if not s then
				s = char(
					encoder[extract(v, 18, 6)],
					encoder[extract(v, 12, 6)],
					encoder[extract(v, 6, 6)],
					encoder[extract(v, 0, 6)]
				)
				cache[v] = s
			end
		else
			s = char(
				encoder[extract(v, 18, 6)],
				encoder[extract(v, 12, 6)],
				encoder[extract(v, 6, 6)],
				encoder[extract(v, 0, 6)]
			)
		end

		t[k] = s
		k = k + 1
	end

	if lastn == 2 then
		local a, b = str:byte(n - 1, n)
		local v = a * 0x10000 + b * 0x100
		t[k] = char(
			encoder[extract(v, 18, 6)],
			encoder[extract(v, 12, 6)],
			encoder[extract(v, 6, 6)],
			encoder[64]
		)
	elseif lastn == 1 then
		local v = str:byte(n) * 0x10000
		t[k] = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)], encoder[64], encoder[64])
	end

	return concat(t)
end

function base64.decode(
	b64,
	decoder,
	usecaching
)
	decoder = decoder or (DEFAULT_DECODER)
	local pattern = "[^%w%+%/%=]"

	if decoder then
		local s62, s63

		for charcode, b64code in pairs(decoder) do
			if b64code == 62 then
				s62 = charcode
			elseif b64code == 63 then
				s63 = charcode
			end
		end

		pattern = ("[^%%w%%%s%%%s%%=]"):format(char(s62), char(s63))
	end

	b64 = b64:gsub(pattern, "")
	local cache = usecaching and {}
	local t, k = {}, 1
	local n = #b64
	local padding = b64:sub(-2) == "==" and 2 or b64:sub(-1) == "=" and 1 or 0

	for i = 1, padding > 0 and n - 4 or n, 4 do
		local a, b, c, d = b64:byte(i, i + 3)
		local s

		if cache then
			local v0 = a * 0x1000000 + b * 0x10000 + c * 0x100 + d
			s = cache[v0]

			if not s then
				local v = decoder[a] * 0x40000 + decoder[b] * 0x1000 + decoder[c] * 0x40 + decoder[d]
				s = char(extract(v, 16, 8), extract(v, 8, 8), extract(v, 0, 8))
				cache[v0] = s
			end
		else
			local v = decoder[a] * 0x40000 + decoder[b] * 0x1000 + decoder[c] * 0x40 + decoder[d]
			s = char(extract(v, 16, 8), extract(v, 8, 8), extract(v, 0, 8))
		end

		t[k] = s
		k = k + 1
	end

	if padding == 1 then
		local a, b, c = b64:byte(n - 3, n - 1)
		local v = decoder[a] * 0x40000 + decoder[b] * 0x1000 + decoder[c] * 0x40
		t[k] = char(extract(v, 16, 8), extract(v, 8, 8))
	elseif padding == 2 then
		local a, b = b64:byte(n - 3, n - 2)
		local v = decoder[a] * 0x40000 + decoder[b] * 0x1000
		t[k] = char(extract(v, 16, 8))
	end

	return concat(t)
end

return base64 end ]=======], '@./nattlua/other/base64.lua'))())(...) return __M end end
do local __M; IMPORTS["language_server.server.lsp"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --DONT_ANALYZE
local Compiler = IMPORTS['nattlua.compiler']("nattlua.compiler").New
local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
local b64 = IMPORTS['nattlua.other.base64']("nattlua.other.base64")
local Union = IMPORTS['nattlua.types.union']("nattlua.types.union").Union
local Table = IMPORTS['nattlua.types.table']("nattlua.types.table").Table
local runtime_syntax = IMPORTS['nattlua.syntax.runtime']("nattlua.syntax.runtime")
local typesystem_syntax = IMPORTS['nattlua.syntax.typesystem']("nattlua.syntax.typesystem")
local lsp = {}
lsp.methods = {}
local TextDocumentSyncKind = {None = 0, Full = 1, Incremental = 2}
local DiagnosticSeverity = {
	error = 1,
	fatal = 1, -- from lexer and parser
	warning = 2,
	information = 3,
	hint = 4,
}
local SymbolKind = {
	File = 1,
	Module = 2,
	Namespace = 3,
	Package = 4,
	Class = 5,
	Method = 6,
	Property = 7,
	Field = 8,
	Constructor = 9,
	Enum = 10,
	Interface = 11,
	Function = 12,
	Variable = 13,
	Constant = 14,
	String = 15,
	Number = 16,
	Boolean = 17,
	Array = 18,
	Object = 19,
	Key = 20,
	Null = 21,
	EnumMember = 22,
	Struct = 23,
	Event = 24,
	Operator = 25,
	TypeParameter = 26,
}
local SemanticTokenTypes = {
	-- identifiers or reference
	"class", -- a class type. maybe META or Meta?
	"typeParameter", -- local type >foo< = true
	"parameter", -- function argument: function foo(>a<)
	"variable", -- a local or global variable.
	"property", -- a member property, member field, or member variable.
	"enumMember", -- an enumeration property, constant, or member. uppercase variables and global non tables? local FOO = true ?
	"event", --  an event property.
	"function", -- local or global function: local function >foo<
	"method", --  a member function or method: string.>bar<()
	"type", -- misc type
	-- tokens
	"comment", -- 
	"string", -- 
	"keyword", -- 
	"number", -- 
	"regexp", -- regular expression literal.
	"operator", --
	"decorator", -- decorator syntax, maybe for @Foo in tables, $ and §
	-- other identifiers or references
	"namespace", -- namespace, module, or package.
	"enum", -- 
	"interface", --
	"struct", -- 
	"decorator", -- decorators and annotations.
	"macro", --  a macro.
	"label", --  a label. ??
}
local SemanticTokenModifiers = {
	"declaration", -- For declarations of symbols.
	"definition", -- For definitions of symbols, for example, in header files.
	"readonly", -- For readonly variables and member fields (constants).
	"static", -- For class members (static members).
	"private", -- For class members (static members).
	"deprecated", -- For symbols that should no longer be used.
	"abstract", -- For types and member functions that are abstract.
	"async", -- For functions that are marked async.
	"modification", -- For variable references where the variable is assigned to.
	"documentation", -- For occurrences of symbols in documentation.
	"defaultLibrary", -- For symbols that are part of the standard library.
}

local function find_type_from_token(token)
	local found_parents = {}

	do
		local node = token.parent

		while node and node.parent do
			table.insert(found_parents, node)
			node = node.parent
		end
	end

	local scope

	for _, node in ipairs(found_parents) do
		if node.scope then
			scope = node.scope

			break
		end
	end

	local union = Union({})

	for _, node in ipairs(found_parents) do
		local found = false

		for _, obj in ipairs(node:GetTypes()) do
			if type(obj) ~= "table" then
				print("UH OH", obj, node, "BAD VALUE IN GET TYPES")
			else
				if obj.Type == "string" and obj:GetData() == token.value then

				else
					if obj.Type == "table" then obj = obj:GetMutatedFromScope(scope) end

					union:AddType(obj)
					found = true
				end
			end
		end

		if found then break end
	end

	if union:IsEmpty() then return nil, found_parents, scope end

	if union:GetLength() == 1 then
		return union:GetData()[1], found_parents, scope
	end

	return union, found_parents, scope
end

local function token_to_type_mod(token)
	if token.type == "symbol" and token.parent.kind == "function_signature" then
		return {[token] = {"keyword"}}
	end

	if
		runtime_syntax:IsNonStandardKeyword(token) or
		typesystem_syntax:IsNonStandardKeyword(token)
	then
		-- check if it's used in a statement, because foo.type should not highlight
		if token.parent and token.parent.type == "statement" then
			return {[token] = {"keyword"}}
		end
	end

	if runtime_syntax:IsKeywordValue(token) or typesystem_syntax:IsKeywordValue(token) then
		return {[token] = {"type"}}
	end

	if
		token.value == "." or
		token.value == ":" or
		token.value == "=" or
		token.value == "or" or
		token.value == "and" or
		token.value == "not"
	then
		return {[token] = {"operator"}}
	end

	if runtime_syntax:IsKeyword(token) or typesystem_syntax:IsKeyword(token) then
		return {[token] = {"keyword"}}
	end

	if
		runtime_syntax:GetTokenType(token):find("operator") or
		typesystem_syntax:GetTokenType(token):find("operator")
	then
		return {[token] = {"operator"}}
	end

	if token.type == "symbol" then return {[token] = {"keyword"}} end

	do
		local obj = find_type_from_token(token)

		if obj then
			local mods = {}

			if obj:IsLiteral() then table.insert(mods, "readonly") end

			if obj.Type == "union" then
				if obj:IsTypeExceptNil("number") then
					return {[token] = {"number", mods}}
				elseif obj:IsTypeExceptNil("string") then
					return {[token] = {"string", mods}}
				elseif obj:IsTypeExceptNil("symbol") then
					return {[token] = {"enumMember", mods}}
				end

				return {[token] = {"event"}}
			end

			if obj.Type == "number" then
				return {[token] = {"number", mods}}
			elseif obj.Type == "string" then
				return {[token] = {"string", mods}}
			elseif obj.Type == "tuple" or obj.Type == "symbol" then
				return {[token] = {"enumMember", mods}}
			elseif obj.Type == "any" then
				return {[token] = {"regexp", mods}}
			end

			if obj.Type == "function" then return {[token] = {"function", mods}} end

			local parent = obj:GetParent()

			if parent then
				if obj.Type == "function" then
					return {[token] = {"macro", mods}}
				else
					if obj.Type == "table" then return {[token] = {"class", mods}} end

					return {[token] = {"property", mods}}
				end
			end

			if obj.Type == "table" then return {[token] = {"class", mods}} end
		end
	end

	if token.type == "number" then
		return {[token] = {"number"}}
	elseif token.type == "string" then
		return {[token] = {"string"}}
	end

	if
		token.parent.kind == "value" and
		token.parent.parent.kind == "binary_operator" and
		(
			token.parent.parent.value and
			token.parent.parent.value.value == "." or
			token.parent.parent.value.value == ":"
		)
	then
		if token.value:sub(1, 1) == "@" then return {[token] = {"decorator"}} end
	end

	if token.type == "letter" and token.parent.kind:find("function", nil, true) then
		return {[token] = {"function"}}
	end

	if
		token.parent.kind == "value" and
		token.parent.parent.kind == "binary_operator" and
		(
			token.parent.parent.value and
			token.parent.parent.value.value == "." or
			token.parent.parent.value.value == ":"
		)
	then
		return {[token] = {"property"}}
	end

	if token.parent.kind == "table_key_value" then
		return {[token] = {"property"}}
	end

	if token.parent.standalone_letter then
		if token.parent.environment == "typesystem" then
			return {[token] = {"type"}}
		end

		if _G[token.value] then return {[token] = {"namespace"}} end

		return {[token] = {"variable"}}
	end

	if token.parent.is_identifier then
		if token.parent.environment == "typesystem" then
			return {[token] = {"typeParameter"}}
		end

		return {[token] = {"variable"}}
	end

	do
		return {[token] = {"comment"}}
	end
end

local working_directory

local function get_range(code, start, stop)
	local data = helpers.SubPositionToLinePosition(code:GetString(), start, stop)
	return {
		start = {
			line = data.line_start - 1,
			character = data.character_start - 1,
		},
		["end"] = {
			line = data.line_stop - 1,
			character = data.character_stop, -- not sure about this
		},
	}
end

local function find_token_from_line_character(
	tokens,
	code,
	line,
	char
)
	local sub_pos = helpers.LinePositionToSubPosition(code, line, char)

	for _, token in ipairs(tokens) do
		if sub_pos >= token.start and sub_pos <= token.stop then
			return token, helpers.SubPositionToLinePosition(code, token.start, token.stop)
		end
	end
end

local function find_token_from_line_character_range(
	tokens,
	code,
	lineStart,
	charStart,
	lineStop,
	charStop
)
	local sub_pos_start = helpers.LinePositionToSubPosition(code, lineStart, charStart)
	local sub_pos_stop = helpers.LinePositionToSubPosition(code, lineStop, charStop)
	local found = {}

	for _, token in ipairs(tokens) do
		if token.start >= sub_pos_start and token.stop <= sub_pos_stop then
			table.insert(found, token)
		end
	end

	return found
end

local function get_analyzer_config()
	

	local f, err = loadfile("./nlconfig.lua")
	local cfg = {}

	if f then cfg = f("get-analyzer-config") or cfg end

	if cfg.type_annotations == nil then cfg.type_annotations = true end

	return cfg
end

local function get_emitter_config()
	

	local f, err = loadfile("./nlconfig.lua")
	local cfg = {
		preserve_whitespace = false,
		string_quote = "\"",
		no_semicolon = true,
		comment_type_annotations = true,
		type_annotations = "explicit",
		force_parenthesis = true,
		skip_import = true,
	}

	if f then cfg = f("get-emitter-config") or cfg end

	return cfg
end

local BuildBaseEnvironment = IMPORTS['nattlua.runtime.base_environment']("nattlua.runtime.base_environment").BuildBaseEnvironment
local runtime_env, typesystem_env = BuildBaseEnvironment()
local cache = {}
local temp_files = {}

local function find_file(uri)
	return cache[uri]
end

local function find_temp_file(uri)
	return temp_files[uri]
end

local function store_temp_file(uri, content)
	print("storing ", uri, #content)
	temp_files[uri] = content
end

local function clear_temp_file(uri)
	print("clearing ", uri)
	temp_files[uri] = nil
end

local function recompile(uri)
	local cfg = get_analyzer_config()
	local entry_point = cfg.entry_point

	if not entry_point and uri then
		entry_point = uri:gsub(working_directory .. "/", "")
	end

	if not entry_point then return false end

	local responses = {}
	cfg.inline_require = false
	cfg.on_read_file = function(parser, path)
		responses[path] = responses[path] or
			{
				method = "textDocument/publishDiagnostics",
				params = {uri = working_directory .. "/" .. path, diagnostics = {}},
			}
		return find_temp_file(working_directory .. "/" .. path)
	end
	local compiler = Compiler([[return import("./]] .. entry_point .. [[")]], "file://" .. entry_point, cfg)
	compiler.debug = true
	compiler:SetEnvironments(runtime_env, typesystem_env)

	do
		function compiler:OnDiagnostic(code, msg, severity, start, stop, node, ...)
			local range = get_range(code, start, stop)

			if not range then return end

			local name = code:GetName()
			print("error: ", name, msg, severity, ...)
			responses[name] = responses[name] or
				{
					method = "textDocument/publishDiagnostics",
					params = {uri = working_directory .. "/" .. name, diagnostics = {}},
				}
			table.insert(
				responses[name].params.diagnostics,
				{
					severity = DiagnosticSeverity[severity],
					range = range,
					message = helpers.FormatMessage(msg, ...),
				}
			)
		end

		if compiler:Parse() then
			for _, root_node in ipairs(compiler.SyntaxTree.imports) do
				local root = root_node.RootStatement

				if root_node.RootStatement then
					if not root_node.RootStatement.parser then
						root = root_node.RootStatement.RootStatement
					end

					cache[working_directory .. "/" .. root.parser.config.file_path] = {tokens = root.lexer_tokens, code = root.code}
				end
			end

			local code = assert(io.open((cfg.working_directory or "") .. entry_point, "r")):read("*all")

			if
				code:find("-" .. "-ANALYZE", nil, true) or
				(
					uri and
					uri:find("%.nlua$")
				)
			then
				print("RECOMPILE")
				local ok, err = compiler:Analyze()

				if not ok then
					local name = compiler:GetCode():GetName()
					responses[name] = responses[name] or
						{
							method = "textDocument/publishDiagnostics",
							params = {uri = working_directory .. "/" .. name, diagnostics = {}},
						}
					table.insert(
						responses[name].params.diagnostics,
						{
							severity = DiagnosticSeverity["fatal"],
							range = get_range(compiler:GetCode(), 1, compiler:GetCode():GetByteSize()),
							message = err,
						}
					)
				end

				print(ok, err)
			end

			lsp.Call({method = "workspace/semanticTokens/refresh", params = {}})
		end

		for _, resp in pairs(responses) do
			lsp.Call(resp)
		end
	end

	return true
end

lsp.methods["initialize"] = function(params)
	working_directory = params.workspaceFolders[1].uri
	table.print(params)
	return {
		clientInfo = {name = "NattLua", version = "1.0"},
		capabilities = {
			textDocumentSync = {
				openClose = true,
				change = TextDocumentSyncKind.Full,
			},
			semanticTokensProvider = {
				legend = {
					tokenTypes = SemanticTokenTypes,
					tokenModifiers = SemanticTokenModifiers,
				},
				full = true,
				range = false,
			},
			hoverProvider = true,
			publishDiagnostics = {
				relatedInformation = true,
				tagSupport = {1, 2},
			},
			inlayHintProvider = {
				resolveProvider = true,
			},
			definitionProvider = true,
		-- for symbols like all functions within a file
		-- documentSymbolProvider = {label = "NattLua"},
		-- highlighting equal upvalues
		-- documentHighlightProvider = true, 
		--[[completionProvider = {
				resolveProvider = true,
				triggerCharacters = { ".", ":" },
			},
			signatureHelpProvider = {
				triggerCharacters = { "(" },
			},
			definitionProvider = true,
			referencesProvider = true,
			
			workspaceSymbolProvider = true,
			codeActionProvider = true,
			codeLensProvider = {
				resolveProvider = true,
			},
			documentFormattingProvider = true,
			documentRangeFormattingProvider = true,
			documentOnTypeFormattingProvider = {
				firstTriggerCharacter = "}",
				moreTriggerCharacter = { "end" },
			},
			renameProvider = true,
			]] },
	}
end
lsp.methods["initialized"] = function(params)
	recompile()
end
lsp.methods["nattlua/format"] = function(params)
	local config = get_emitter_config()
	config.comment_type_annotations = params.path:sub(-#".lua") == ".lua"
	config.transpile_extensions = params.path:sub(-#".lua") == ".lua"
	local compiler = Compiler(params.code, "@" .. params.path, config)
	local code, err = compiler:Emit()
	return {code = b64.encode(code)}
end
lsp.methods["nattlua/syntax"] = function(params)
	local data = require("nattlua.syntax.monarch_language")
	print("SENDING SYNTAX", #data)
	return {data = b64.encode(data)}
end
lsp.methods["shutdown"] = function(params)
	print("SHUTDOWN")
	table.print(params)
end

do -- semantic tokens
	local tokenTypeMap = {}
	local tokenModifiersMap = {}

	for i, v in ipairs(SemanticTokenTypes) do
		tokenTypeMap[v] = i - 1
	end

	for i, v in ipairs(SemanticTokenModifiers) do
		tokenModifiersMap[v] = i - 1
	end

	lsp.methods["textDocument/semanticTokens/range"] = function(params)
		print("SEMANTIC TOKENS RANGE")
		table.print(params)

		do
			return
		end

		local textDocument = params.textDocument
		local range = params
	end
	lsp.methods["textDocument/semanticTokens/full"] = function(params)
		local data = find_file(params.textDocument.uri)
		print("SEMANTIC TOKENS FULL REFRESH", data)

		if not data then return end

		local integers = {}
		local last_y = 0
		local last_x = 0
		local mods = {}

		for _, token in ipairs(data.tokens) do
			if token.type ~= "end_of_file" and token.parent then
				local modified_tokens = token_to_type_mod(token)

				if modified_tokens then
					for token, flags in pairs(modified_tokens) do
						mods[token] = flags
					end
				end
			end
		end

		for _, token in ipairs(data.tokens) do
			if mods[token] then
				local type, modifiers = unpack(mods[token])
				local data = helpers.SubPositionToLinePosition(data.code:GetString(), token.start, token.stop)
				local len = #token.value
				local y = (data.line_start - 1) - last_y
				local x = (data.character_start - 1) - last_x

				-- x is not relative when there's a new line
				if y ~= 0 then x = data.character_start - 1 end

				if type then
					if x < 0 or y < 0 then
						print(token)
						table.print(data)
						table.print({x = x, y = y, len = len, last_x = last_x, last_y = last_y})
						error("bad token")
					end

					table.insert(integers, y)
					table.insert(integers, x)
					table.insert(integers, len)
					assert(tokenTypeMap[type], "invalid type " .. type)
					table.insert(integers, tokenTypeMap[type])
					local result = 0

					if modifiers then
						for _, mod in ipairs(modifiers) do
							assert(tokenModifiersMap[mod], "invalid modifier " .. mod)
							result = bit.bor(result, bit.lshift(1, tokenModifiersMap[mod])) -- TODO, doesn't seem to be working
						end
					end

					table.insert(integers, result)
					last_y = data.line_start - 1
					last_x = data.character_start - 1
				end
			end
		end

		return {data = integers}
	end
end

lsp.methods["$/cancelRequest"] = function(params)
	do
		return
	end

	print("cancelRequest")
	table.print(params)
end
lsp.methods["workspace/didChangeConfiguration"] = function(params)
	print("configuration changed")
	table.print(params)
end
lsp.methods["textDocument/didOpen"] = function(params)
	store_temp_file(params.textDocument.uri, params.textDocument.text)
	recompile(params.textDocument.uri)
end
lsp.methods["textDocument/didClose"] = function(params)
	clear_temp_file(params.textDocument.uri)
end
lsp.methods["textDocument/didChange"] = function(params)
	store_temp_file(params.textDocument.uri, params.contentChanges[1].text)
	recompile(params.textDocument.uri)
end
lsp.methods["textDocument/didSave"] = function(params)
	clear_temp_file(params.textDocument.uri)
	recompile(params.textDocument.uri)
end

local function find_token(uri, text, line, character)
	local data = find_file(uri)

	if not data then return end

	local token, data = find_token_from_line_character(data.tokens, data.code:GetString(), line + 1, character + 1)
	return token, data
end

local function has_value(tbl, str)
	for _, v in ipairs(tbl) do
		if v == str then return true end
	end

	return false
end

local function find_parent(token, type, kind)
	local node = token.parent

	if not node then return nil end

	while node.parent do
		if node.type == type and node.kind == kind then return node end

		node = node.parent
	end

	return nil
end

local function find_nodes(tokens, type, kind)
	local nodes = {}
	local done = {}

	for _, token in ipairs(tokens) do
		local node = find_parent(token, type, kind)

		if node and not done[node] then
			table.insert(nodes, node)
			done[node] = true
		end
	end

	return nodes
end

lsp.methods["textDocument/inlayHint"] = function(params)
	print("INLAY REQUEST")
	local compiler = compile(params.textDocument.uri, params.textDocument.text)
	local tokens = find_token_from_line_character_range(
		compiler.Tokens,
		compiler.Code:GetString(),
		params.start.line - 1,
		params.start.character - 1,
		params["end"].line - 1,
		params["end"].character - 1
	)
	local hints = {}
	local assignments = find_nodes(tokens, "statement", "local_assignment")

	for _, assingment in ipairs(find_nodes(tokens, "statement", "assignment")) do
		table.insert(assignments, assingment)
	end

	for _, assignment in ipairs(assignments) do
		if assignment.environment == "runtime" then
			for i, left in ipairs(assignment.left) do
				if not left.tokens[":"] and assignment.right and assignment.right[i] then
					local types = left:GetTypes()

					if
						types and
						(
							assignment.right[i].kind ~= "value" or
							assignment.right[i].value.value.type == "letter"
						)
					then
						local data = helpers.SubPositionToLinePosition(compiler.Code:GetString(), left:GetStartStop())
						local label = tostring(Union(types))

						if #label > 20 then label = label:sub(1, 20) .. "..." end

						table.insert(
							hints,
							{
								label = ": " .. label,
								tooltip = tostring(Union(types)),
								position = {
									lineNumber = data.line_stop,
									column = data.character_stop + 1,
								},
								kind = 1, -- type
							}
						)
					end
				end
			end
		end
	end

	return hints
end
lsp.methods["textDocument/rename"] = function(params)
	do
		return
	end

	local token, data = find_token(
		params.textDocument.uri,
		params.textDocument.text,
		params.position.line,
		params.position.character
	)

	if not token or not data or not token.parent then return end

	local obj = find_type_from_token(token)
	local upvalue = obj:GetUpvalue()
	local changes = {}

	if upvalue and upvalue.mutations then
		for i, v in ipairs(upvalue.mutations) do
			local node = v.value:GetNode()

			if node then
				changes[params.textDocument.uri] = changes[params.textDocument.uri] or
					{
						textDocument = {
							version = nil,
						},
						edits = {},
					}
				local edits = changes[params.textDocument.uri].edits
				table.insert(
					edits,
					{
						range = get_range(node.Code, node:GetStartStop()),
						newText = params.newName,
					}
				)
			end
		end
	end

	return {
		changes = changes,
	}
end
lsp.methods["textDocument/definition"] = function(params)
	local token, data = find_token(
		params.textDocument.uri,
		params.textDocument.text,
		params.position.line,
		params.position.character
	)

	if not token or not data or not token.parent then return end

	local obj = find_type_from_token(token)

	if not obj or not obj:GetUpvalue() then return end

	local node = obj:GetUpvalue():GetNode()

	if not node then return end

	local data = find_file(params.textDocument.uri)
	return {
		uri = params.textDocument.uri,
		range = get_range(data.code, node:GetStartStop()),
	}
end
lsp.methods["textDocument/hover"] = function(params)
	local token, data = find_token(
		params.textDocument.uri,
		params.textDocument.text,
		params.position.line,
		params.position.character
	)

	if not token or not data or not token.parent then return end

	local markdown = ""

	local function add_line(str)
		markdown = markdown .. str .. "\n\n"
	end

	local function add_code(str)
		add_line("```lua\n" .. tostring(str) .. "\n```")
	end

	local obj, found_parents, scope = find_type_from_token(token)

	if obj then
		add_code(tostring(obj))
		local upvalue = obj:GetUpvalue()

		if upvalue then
			add_code(tostring(upvalue))

			if upvalue:HasMutations() then
				local code = ""

				for i, mutation in ipairs(upvalue.mutations) do
					code = code .. "-- " .. i .. "\n"
					code = code .. "\tvalue = " .. tostring(mutation.value) .. "\n"
					code = code .. "\tscope = " .. tostring(mutation.scope) .. "\n"
					code = code .. "\ttracking = " .. tostring(mutation.from_tracking) .. "\n"
				end

				add_code(code)
			end
		end
	end

	if found_parents[1] then
		local min, max = found_parents[1]:GetStartStop()

		if min then
			local temp = helpers.SubPositionToLinePosition(found_parents[1].Code:GetString(), min, max)

			if temp then data = temp end
		end
	end

	local limit = 5000

	for i = 1, #found_parents do
		local min, max = found_parents[i]:GetStartStop()
		add_code(tostring(found_parents[i]) .. " len=" .. tostring(max - min))
	end

	if scope then markdown = markdown .. "\n" .. tostring(scope) end

	if #markdown > limit then markdown = markdown:sub(0, limit) .. "\n```\n..." end

	markdown = markdown:gsub("\\", "BSLASH_")
	return {
		contents = markdown,
		range = {
			start = {
				line = data.line_start - 1,
				character = data.character_start - 1,
			},
			["end"] = {
				line = data.line_stop - 1,
				character = data.character_stop,
			},
		},
	}
end

do
	local MessageType = {error = 1, warning = 2, info = 3, log = 4}

	function lsp.ShowMessage(type, msg)
		lsp.Call(
			{
				method = "window/showMessage",
				params = {
					type = assert(MessageType[type]),
					message = msg,
				},
			}
		)
	end

	function lsp.LogMessage(type, msg)
		lsp.Call(
			{
				method = "window/logMessage",
				params = {
					type = assert(MessageType[type]),
					message = msg,
				},
			}
		)
	end
end

-- this can be overriden
function lsp.Call(params)
	if lsp.methods[params.method] then lsp.methods[params.method](params) end
end

return lsp end ]=======], '@./language_server/server/lsp.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.json"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local pairs = _G.pairs
local string = _G.string
local error = _G.error
local next = _G.next
local type = _G.type
local ipairs = _G.ipairs
local table = _G.table
local tostring = _G.tostring
local select = _G.select
local tonumber = _G.tonumber
local json = {}
-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------
local encode
local escape_char_map = {
	["\\"] = "\\\\",
	["\""] = "\\\"",
	["\b"] = "\\b",
	["\f"] = "\\f",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t",
}
local escape_char_map_inv = {["\\/"] = "/"}

for k, v in pairs(escape_char_map) do
	escape_char_map_inv[v] = k
end

local function escape_char(c)
	return escape_char_map[c] or string.format("\\u%04x", c:byte())
end

local function encode_nil(val, stack)
	return "null"
end

local function encode_table(val, stack)
	local res = {}
	stack = stack or {}

	-- Circular reference?
	if stack[val] then error("circular reference") end

	stack[val] = true

	if val[1] ~= nil or next(val) == nil then
		-- Treat as array -- check keys are valid and it is not sparse
		local n = 0

		for k in pairs(val) do
			if type(k) ~= "number" then
				error("invalid table: mixed or invalid key types")
			end

			n = n + 1
		end

		if n ~= #val then error("invalid table: sparse array") end

		-- Encode
		for i, v in ipairs(val) do
			table.insert(res, encode(v, stack))
		end

		stack[val] = nil
		return "[" .. table.concat(res, ",") .. "]"
	else
		-- Treat as an object
		for k, v in pairs(val) do
			if type(k) ~= "string" then
				error("invalid table: mixed or invalid key types")
			end

			table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
		end

		stack[val] = nil
		return "{" .. table.concat(res, ",") .. "}"
	end
end

local function encode_string(val, stack)
	return "\"" .. val:gsub("[%z\1-\31\"]", escape_char) .. "\""
end

local function encode_number(val, stack)
	-- Check for NaN, -inf and inf
	if val ~= val or val <= -math.huge or val >= math.huge then
		error("unexpected number value '" .. tostring(val) .. "'")
	end

	return string.format("%.14g", val)
end

json.null = {}

local function encode_null(val, stack)
	return "null"
end

local function encode_boolean(val, stack)
	return val and "true" or "false"
end

local type_func_map = {
	["nil"] = encode_nil,
	["table"] = encode_table,
	["string"] = encode_string,
	["number"] = encode_number,
	["boolean"] = encode_boolean,
}
encode = function(val, stack)
	if val == json.null then return encode_null(val, stack) end

	local t = type(val)
	local f = type_func_map[t]

	if f then return f(val, stack) end

	error("unexpected type '" .. t .. "'")
end

function json.encode(val)
	return (encode(val, {}))
end

-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------
local parse

local function create_set(...)
	local res = {}

	for i = 1, select("#", ...) do
		res[select(i, ...)] = true
	end

	return res
end

local space_chars = create_set(" ", "\t", "\r", "\n")
local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars = create_set("\\", "/", "\"", "b", "f", "n", "r", "t", "u")
local literals = create_set("true", "false", "null")
local literal_map = {
	["true"] = true,
	["false"] = false,
	["null"] = nil,
}

local function next_char(
	str,
	idx,
	set,
	negate
)
	for i = idx, #str do
		if set[str:sub(i, i)] ~= negate then return i end
	end

	return #str + 1
end

local function decode_error(str, idx, msg)
	local line_count = 1
	local col_count = 1

	for i = 1, idx - 1 do
		col_count = col_count + 1

		if str:sub(i, i) == "\n" then
			line_count = line_count + 1
			col_count = 1
		end
	end

	error(string.format("%s at line %d col %d", msg, line_count, col_count))
end

local function codepoint_to_utf8(n)
	-- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
	local f = math.floor

	if n <= 0x7f then
		return string.char(n)
	elseif n <= 0x7ff then
		return string.char(f(n / 64) + 192, n % 64 + 128)
	elseif n <= 0xffff then
		return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
	elseif n <= 0x10ffff then
		return string.char(
			f(n / 262144) + 240,
			f(n % 262144 / 4096) + 128,
			f(n % 4096 / 64) + 128,
			n % 64 + 128
		)
	end

	error(string.format("invalid unicode codepoint '%x'", n))
end

local function parse_unicode_escape(s)
	local n1 = tonumber(s:sub(3, 6), 16)

	if not n1 then error("failed to parse unicode escape") end

	local n2 = tonumber(s:sub(9, 12), 16)

	-- Surrogate pair?
	if n2 then
		return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
	else
		return codepoint_to_utf8(n1)
	end
end

local function parse_string(str, i)
	local has_unicode_escape = false
	local has_surrogate_escape = false
	local has_escape = false
	local last

	for j = i + 1, #str do
		local x = str:byte(j)

		if x < 32 then decode_error(str, j, "control character in string") end

		if last == 92 then -- "\\" (escape char)
			if x == 117 then -- "u" (unicode escape sequence)
				local hex = str:sub(j + 1, j + 5)

				if not hex:find("%x%x%x%x") then
					decode_error(str, j, "invalid unicode escape in string")
				end

				if hex:find("^[dD][89aAbB]") then
					has_surrogate_escape = true
				else
					has_unicode_escape = true
				end
			else
				local c = string.char(x)

				if not escape_chars[c] then
					decode_error(str, j, "invalid escape char '" .. c .. "' in string")
				end

				has_escape = true
			end

			last = nil
		elseif x == 34 then -- '"' (end of string)
			local s = str:sub(i + 1, j - 1)

			if has_surrogate_escape then
				s = s:gsub("\\u[dD][89aAbB]..\\u....", parse_unicode_escape)
			end

			if has_unicode_escape then s = s:gsub("\\u....", parse_unicode_escape) end

			if has_escape then s = s:gsub("\\.", escape_char_map_inv) end

			return s, j + 1
		else
			last = x
		end
	end

	decode_error(str, i, "expected closing quote for string")
end

local function parse_number(str, i)
	local x = next_char(str, i, delim_chars)
	local s = str:sub(i, x - 1)
	local n = tonumber(s)

	if not n then decode_error(str, i, "invalid number '" .. s .. "'") end

	return n, x
end

local function parse_literal(str, i)
	local x = next_char(str, i, delim_chars)
	local word = str:sub(i, x - 1)

	if not literals[word] then
		decode_error(str, i, "invalid literal '" .. word .. "'")
	end

	return literal_map[word], x
end

local function parse_array(str, i) -- TODO: fix List<|any|>
	local res = {}
	local n = 1
	i = i + 1

	while 1 do
		local x
		i = next_char(str, i, space_chars, true)

		-- Empty / end of array?
		if str:sub(i, i) == "]" then
			i = i + 1

			break
		end

		-- Read token
		x, i = parse(str, i)
		res[n] = x
		n = n + 1
		-- Next token
		i = next_char(str, i, space_chars, true)
		local chr = str:sub(i, i)
		i = i + 1

		if chr == "]" then break end

		if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
	end

	return res, i
end

local function parse_object(str, i)
	local res = {}
	i = i + 1

	while 1 do
		local key, val
		i = next_char(str, i, space_chars, true)

		-- Empty / end of object?
		if str:sub(i, i) == "}" then
			i = i + 1

			break
		end

		-- Read key
		if str:sub(i, i) ~= "\"" then
			decode_error(str, i, "expected string for key")
		end

		key, i = parse(str, i)
		-- Read ':' delimiter
		i = next_char(str, i, space_chars, true)

		if str:sub(i, i) ~= ":" then
			decode_error(str, i, "expected ':' after key")
		end

		i = next_char(str, i + 1, space_chars, true)
		-- Read value
		val, i = parse(str, i)
		-- Union
		res[key] = val
		-- Next token
		i = next_char(str, i, space_chars, true)
		local chr = str:sub(i, i)
		i = i + 1

		if chr == "}" then break end

		if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
	end

	return res, i
end

local char_func_map = {
	["\""] = parse_string,
	["0"] = parse_number,
	["1"] = parse_number,
	["2"] = parse_number,
	["3"] = parse_number,
	["4"] = parse_number,
	["5"] = parse_number,
	["6"] = parse_number,
	["7"] = parse_number,
	["8"] = parse_number,
	["9"] = parse_number,
	["-"] = parse_number,
	["t"] = parse_literal,
	["f"] = parse_literal,
	["n"] = parse_literal,
	["["] = parse_array,
	["{"] = parse_object,
}
parse = function(str, idx)
	local chr = str:sub(idx, idx)
	local f = char_func_map[chr]

	if f then return f(str, idx) end

	decode_error(str, idx, "unexpected character '" .. chr .. "'")
	return nil, -1
end

function json.decode(str)
	local res, idx = parse(str, next_char(str, 1, space_chars, true))
	idx = next_char(str, idx, space_chars, true)

	if idx <= #str then decode_error(str, idx, "trailing garbage") end

	return res
end

return json end ]=======], '@./nattlua/other/json.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.other.jsonrpc"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) --ANALYZE
local type = _G.type
local ipairs = _G.ipairs
local table = _G.table
local xpcall = _G.xpcall
local debug = _G.debug
local pcall = _G.pcall
local tonumber = _G.tonumber
local json = IMPORTS['nattlua.other.json']("nattlua.other.json")
local rpc_util = {}
local VERSION = "2.0"

local JSONRPC_ERRORS = {
	PARSE_ERROR = -32700, -- Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text.
	INVALID_REQUEST = -32600, -- The JSON sent is not a valid Request object.
	METHOD_NOT_FOUND = -32601, -- The method does not exist / is not available.
	INVALID_PARAMS = -32602, -- Invalid method parameter(s).
	INTERNAL_ERROR = -32603, -- Internal JSON-RPC error.
-- SERVER_ERROR = -32000 to -32099, -- , reserved for implementation-defined server-errors.
}

local function error_response(id, code, message)
	return {
		jsonrpc = VERSION,
		id = id,
		error = {
			code = code,
			message = message,
		},
	}
end

local function check_request(rpc)
	if rpc.jsonrpc ~= VERSION then
		return error_response(
			nil,
			JSONRPC_ERRORS.INVALID_REQUEST,
			"this server only accepts jsonrpc version " .. VERSION
		)
	end

	if type(rpc.method) ~= "string" then
		return error_response(nil, JSONRPC_ERRORS.INVALID_REQUEST, "method must be a string")
	end

	do
		local t = type(rpc.id)

		if t ~= "string" and t ~= "number" and t ~= "nil" then
			return error_response(
				nil,
				JSONRPC_ERRORS.INVALID_REQUEST,
				"id must be a string, number or undefined. got " .. t
			)
		end
	end
end

local function handle_rpc(
	rpc,
	is_array,
	methods,
	...
)
	if is_array then
		if not rpc[1] then
			return error_response(nil, JSONRPC_ERRORS.INVALID_REQUEST, "empty batch array request")
		end

		local array = {}

		for i, v in ipairs(rpc) do
			local response = handle_rpc(v, nil, methods, ...)

			if response then table.insert(array, response) end
		end

		if not array[1] then return end

		return array
	end

	local err = check_request(rpc)

	if err then return err end

	if not methods[rpc.method] then
		return error_response(rpc.id, JSONRPC_ERRORS.METHOD_NOT_FOUND, "Method " .. rpc.method .. " not found.")
	end

	local ok, res, err = xpcall(
		function(...)
			return methods[rpc.method](rpc.params, ...)
		end,
		function(err)
			return debug.traceback(err)
		end,
		...
	)

	if not ok then
		return error_response(rpc.id, JSONRPC_ERRORS.INTERNAL_ERROR, res)
	end

	-- notification has no response
	if not rpc.id then return end

	if not res then return error_response(rpc.id, err.code, err.message) end

	return {
		jsonrpc = rpc.jsonrpc,
		id = rpc.id,
		result = res,
	}
end

function rpc_util.ReceiveJSON(data, methods, ...)
	local ok, rpc = pcall(json.decode, data)

	if not ok then
		local err = rpc:match("^.+%.lua:%d+: (.+)")
		return error_response(nil, JSONRPC_ERRORS.PARSE_ERROR, err)
	end

	return handle_rpc(rpc, data:sub(1, 1) == "[", methods, ...)
end

function rpc_util.ReceiveHTTP(state, data)
	state.buffer = state.buffer or ""

	if data then state.buffer = state.buffer .. data end

	local buffer = state.buffer
	local header, rest = buffer:match("^(.-)\r\n\r\n(.*)$")

	if header then
		local length = header:match("Content%-Length: (%d+)")

		if length then
			length = tonumber(length)

			if rest and #rest >= length then
				local body = rest:sub(1, length)
				state.buffer = buffer:sub(#header + 4 + length + 1)
				return body
			end
		end
	end
end

return rpc_util end ]=======], '@./nattlua/other/jsonrpc.lua'))())(...) return __M end end
do local __M; IMPORTS["language_server.server.main"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local ffi = require("ffi")
local ljsocket = IMPORTS['language_server.server.ljsocket']("language_server.server.ljsocket")
local lsp = IMPORTS['language_server.server.lsp']("language_server.server.lsp")
local json = IMPORTS['nattlua.other.json']("nattlua.other.json")
local rpc_util = IMPORTS['nattlua.other.jsonrpc']("nattlua.other.jsonrpc")
return function(port)
	port = port or 1337
	_G.VSCODE_PLUGIN = true
	local server = {}
	server.methods = {}

	function server:OnError(msg)
		error(msg)
	end

	function server:OnReceiveBody(client, str)
		table.insert(
			self.responses,
			{
				client = client,
				thread = coroutine.create(function()
					local res = rpc_util.ReceiveJSON(str, self.methods, self, client)

					if res.error then table.print(res) end

					return res
				end),
			}
		)
	end

	function server:Respond(client, res)
		local encoded = json.encode(res)
		local msg = string.format("Content-Length: %d\r\n\r\n%s", #encoded, encoded)
		client:send(msg)
	end

	function server:GetClient()
		if self.client then return self.client end

		local client, err = self.socket:accept()

		if client then
			assert(client:set_blocking(false))
			client:set_option("nodelay", true, "tcp")
			client:set_option("cork", false, "tcp")
			self.client = client
		end

		return self.client
	end

	function server:Loop()
		self.responses = {}
		local socket = assert(ljsocket.create("inet", "stream", "tcp"))
		assert(socket:set_blocking(false))
		socket:set_option("nodelay", true, "tcp")
		socket:set_option("reuseaddr", true)
		assert(socket:bind("*", 0))
		assert(socket:listen())
		local address, port = socket:get_name()
		io.write("HOST: ", address, ":", port .. "\n")
		io.flush()
		self.socket = socket

		while true do
			ffi.C.usleep((1 / 30) * 1000000)
			local client = self:GetClient()

			if client then
				local chunk, err = client:receive()

				if err and err ~= "timeout" then print(client, chunk, err) end

				local body = rpc_util.ReceiveHTTP(client, chunk)

				if body then self:OnReceiveBody(client, body) end

				if not chunk then
					if err == "closed" then
						table.remove(clients, i)
					elseif err ~= "timeout" then
						table.remove(clients, i)
						client:close()
						print("error: ", err)
					end
				end

				for i = #self.responses, 1, -1 do
					local data = self.responses[i]
					local ok, msg = coroutine.resume(data.thread)

					if not ok then
						if msg ~= "suspended" then table.remove(self.responses, i) end
					else
						if type(msg) == "table" or msg == nil then
							self:Respond(data.client, msg or {})
							table.remove(self.responses, i)
						end
					end
				end
			end
		end
	end

	for k, v in pairs(lsp.methods) do
		server.methods[k] = v
	end

	function lsp.Call(params)
		server:Respond(assert(server:GetClient(), "no client connected yet?"), params)
	end

	ffi.cdef("int chdir(const char *filename); int usleep(unsigned int usec);")
	io.stdout:setvbuf("no")
	io.stderr:setvbuf("no")
	io.flush()
	server:Loop()
end end ]=======], '@./language_server/server/main.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua.cli"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) local nattlua = IMPORTS['nattlua.init']("nattlua.init")
local ARGS = _G.ARGS or {...}
local cmd = ARGS[1]

local function run_nlconfig()
	if not io.open("./nlconfig.lua") then
		io.write("No nlconfig.lua found.\n")
		return
	end

	assert(_G["load" .. "file"]("./nlconfig.lua"))(unpack(ARGS))
end

if cmd == "run" then
	if unpack(ARGS, 2) then
		local path = assert(unpack(ARGS, 2))
		local compiler = assert(nattlua.File(path))
		compiler:Analyze()
		assert(loadstring(compiler:Emit(), "@" .. path))(unpack(ARGS, 3))
	else
		run_nlconfig()
	end
elseif cmd == "check" then
	if unpack(ARGS, 2) then
		local path = assert(unpack(ARGS, 2))
		local compiler = assert(nattlua.File(path))
		assert(compiler:Analyze())
	else
		run_nlconfig()
	end
elseif cmd == "build" then
	if unpack(ARGS, 2) then
		local path_from = assert(unpack(ARGS, 2))
		local compiler = assert(nattlua.File(path_from))
		local path_to = assert(unpack(ARGS, 3))
		local f = assert(io.open(path_to, "w"))
		f:write(compiler:Emit())
		f:close()
	else
		run_nlconfig()
	end
elseif cmd == "language-server" then
	IMPORTS['language_server.server.main']("language_server.server.main")()
else
	run_nlconfig()
end end ]=======], '@./nattlua/cli.lua'))())(...) return __M end end
do local __M; IMPORTS["nattlua"] = function(...) __M = __M or (assert(loadstring([=======[ return function(...) if not table.unpack and _G.unpack then table.unpack = _G.unpack end

if not io or not io.write then
	io = io or {}

	if _G.gmod then
		io.write = function(...)
			for i = 1, select("#", ...) do
				MsgC(Color(255, 255, 255), select(i, ...))
			end
		end
	else
		io.write = print
	end
end

do -- these are just helpers for print debugging
	table.print = IMPORTS['nattlua.other.table_print']("nattlua.other.table_print")
	debug.trace = function(...)
		local level = 1

		while true do
			local info = debug.getinfo(level, "Sln")

			if (not info) then break end

			if (info.what) == "C" then
				io.write(string.format("\t%i: C function\t\"%s\"\n", level, info.name))
			else
				io.write(
					string.format("\t%i: \"%s\"\t%s:%d\n", level, info.name, info.short_src, info.currentline)
				)
			end

			level = level + 1
		end

		io.write("\n")
	end
-- local old = print; function print(...) old(debug.traceback()) end
end

local helpers = IMPORTS['nattlua.other.helpers']("nattlua.other.helpers")
helpers.JITOptimize()
--helpers.EnableJITDumper()
local m = IMPORTS['nattlua.init']("nattlua.init")

if _G.gmod then
	local pairs = pairs
	local getfenv = getfenv
	module("nattlua")
	local _G = getfenv(1)

	for k, v in pairs(m) do
		_G[k] = v
	end
end

local ARGS = _G.ARGS or {...}

if ARGS[1] and ARGS[1] ~= "nattlua" then IMPORTS['nattlua.cli']("nattlua.cli") end

return m end ]=======], '@./nattlua.lua'))())(...) return __M end end
IMPORTS['nattlua/definitions/index.nlua']("nattlua/definitions/index.nlua")
_G.ARGS = {...}

if _G.IMPORTS then
	for k, v in pairs(_G.IMPORTS) do
		if not k:find("/") then package.preload[k] = v end
	end

	package.preload.nattlua = package.preload["nattlua.init"]
end

return IMPORTS['nattlua']("nattlua")