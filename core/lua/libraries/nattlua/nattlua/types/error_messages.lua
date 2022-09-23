local table = _G.table
local type = _G.type
local ipairs = _G.ipairs
local errors = {
	subset = function(a--[[#: any]], b--[[#: any]], reason--[[#: string | List<|string|> | nil]])--[[#: false,string | {[number] = any | string}]]
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
		a_key--[[#: any]],
		b_key--[[#: any]],
		a--[[#: any]],
		b--[[#: any]],
		reason--[[#: string | List<|string|> | nil]]
	)--[[#: false,string | {[number] = any | string}]]
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
	missing = function(a--[[#: any]], b--[[#: any]], reason--[[#: string | nil]])--[[#: false,string | {[number] = any | string}]]
		local msg = {a, " has no field ", b, " because ", reason}
		return false, msg
	end,
	other = function(msg--[[#: {[number] = any | string} | string]])--[[#: false,string | {[number] = any | string}]]
		return false, msg
	end,
	type_mismatch = function(a--[[#: any]], b--[[#: any]])--[[#: false,string | {[number] = any | string}]]
		return false, {a, " is not the same type as ", b}
	end,
	value_mismatch = function(a--[[#: any]], b--[[#: any]])--[[#: false,string | {[number] = any | string}]]
		return false, {a, " is not the same value as ", b}
	end,
	operation = function(op--[[#: any]], obj--[[#: any]], subject--[[#: string]])--[[#: false,string | {[number] = any | string}]]
		return false, {"cannot ", op, " ", subject}
	end,
	numerically_indexed = function(obj--[[#: any]])--[[#: false,string | {[number] = any | string}]]
		return false, {obj, " is not numerically indexed"}
	end,
	binary = function(op--[[#: string]], l--[[#: any]], r--[[#: any]])--[[#: false,string | {[number] = any | string}]]
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
	prefix = function(op--[[#: string]], l--[[#: any]])--[[#: false,string | {[number] = any | string}]]
		return false, {op, " ", l, " is not a valid prefix operation"}
	end,
	postfix = function(op--[[#: string]], r--[[#: any]])--[[#: false,string | {[number] = any | string}]]
		return false, {op, " ", r, " is not a valid postfix operation"}
	end,
	literal = function(obj--[[#: any]], reason--[[#: string | nil]])--[[#: false,string | {[number] = any | string}]]
		local msg = {obj, " needs to be a literal"}

		if reason then
			table.insert(msg, " because ")
			table.insert(msg, reason)
		end

		return false, msg
	end,
	string_pattern = function(a--[[#: any]], b--[[#: any]])--[[#: false,string | {[number] = any | string}]]
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
return errors
