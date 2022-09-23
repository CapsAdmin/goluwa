--ANALYZE
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
local loadstring = require("nattlua.other.loadstring")

local function count(tbl--[[#: Table]])
	local i = 0

	for _ in pairs(tbl) do
		i = i + 1
	end

	return i
end

local tostringx

do
	local pretty_prints = {}
	pretty_prints.table = function(t--[[#: Table]])
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
	pretty_prints["function"] = function(self--[[#: Function]])
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

	function tostringx(val--[[#: any]])
		local t = type(val)
		local f = pretty_prints[t]

		if f then return f(val) end

		return tostring(val)
	end
end

local function getprettysource(level--[[#: number | Function]], append_line--[[#: boolean | nil]])
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

local function getparams(func--[[#: Function]])
	local params = {}

	for i = 1, math.huge do
		local key = debug.getlocal(func, i)

		if key then table.insert(params, key) else break end
	end

	return params
end

local function isarray(t--[[#: Table]])
	local i = 0

	for _ in pairs(t) do
		i = i + 1

		if t[i] == nil then return false end
	end

	return true
end

local env = {}
luadata.Types = {}
--[[#type luadata.Types = Map<|string, function=(any)>(string) | nil|>]]
local idx = function(var--[[#: any]])
	return var.LuaDataType
end

function luadata.Type(var--[[#: any]])
	local t = type(var)

	if t == "table" then
		local ok, res = pcall(idx, var)

		if ok and res then return res end
	end

	return t
end

--[[#local type Context = {tab = number, tab_limit = number, done = Table}]]

function luadata.ToString(var, context--[[#: nil | Context]])
	context = context or {tab = -1}
	local func = luadata.Types[luadata.Type(var)]

	if func then return func(var, context) end

	if luadata.Types.fallback then return luadata.Types.fallback(var, context) end
end

function luadata.FromString(str--[[#: string]])
	local func = assert(loadstring("return " .. str), "luadata")
	setfenv(func, env)
	return func()
end

function luadata.Encode(tbl--[[#: Table]])
	return luadata.ToString(tbl)
end

function luadata.Decode(str--[[#: string]])
	local func, err = loadstring("return {\n" .. str .. "\n}", "luadata")

	if not func then return func, err end

	setfenv(func, env)
	local ok, err = pcall(func)

	if not ok then return func, err end

	return err
end

function luadata.SetModifier(
	type--[[#: string]],
	callback--[[#: function=(any, Context)>(string)]],
	func--[[#: nil]],
	func_name--[[#: nil | string]]
)
	luadata.Types[type] = callback

	if func_name then env[func_name] = func end
end

luadata.SetModifier("cdata", function(var--[[#: any]])
	return tostring(var)
end)

luadata.SetModifier("number", function(var--[[#: number]])
	return ("%s"):format(var)
end)

luadata.SetModifier("string", function(var--[[#: string]])
	return ("%q"):format(var)
end)

luadata.SetModifier("boolean", function(var--[[#: boolean]])
	return var and "true" or "false"
end)

luadata.SetModifier("function", function(var--[[#: Function]])
	return (
		"function(%s) --[==[ptr: %p    src: %s]==] end"
	):format(table.concat(getparams(var), ", "), var, getprettysource(var, true))
end)

luadata.SetModifier("fallback", function(var--[[#: any]])
	return "--[==[  " .. tostringx(var) .. "  ]==]"
end)

luadata.SetModifier("table", function(tbl, context)
	local str--[[#: List<|string|>]] = {}

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
end