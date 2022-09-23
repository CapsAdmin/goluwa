local nl = require("nattlua")
local Table = require("nattlua.types.table").Table
local Union = require("nattlua.types.union").Union
local Tuple = require("nattlua.types.tuple").Tuple
local Number = require("nattlua.types.number").Number
local LNumber = require("nattlua.types.number").LNumber
local LString = require("nattlua.types.string").LString
local Function = require("nattlua.types.function").Function
local String = require("nattlua.types.string").String
local Any = require("nattlua.types.any").Any
local Symbol = require("nattlua.types.symbol").Symbol
local helpers = {}
helpers.Function = Function
helpers.Table = Table
helpers.Any = Any
helpers.Symbol = Symbol

do
	local function cast(...)
		local ret = {}

		for i = 1, select("#", ...) do
			local v = select(i, ...)
			local t = type(v)

			if t == "number" then
				ret[i] = LNumber(v)
			elseif t == "string" then
				ret[i] = LString(v)
			elseif t == "boolean" then
				ret[i] = Symbol(v)
			else
				ret[i] = v
			end
		end

		return ret
	end

	function helpers.Union(...)
		return Union(cast(...))
	end

	function helpers.Tuple(...)
		return Tuple(cast(...))
	end
end

function helpers.Number(n)
	return Number(n):SetLiteral(n ~= nil)
end

function helpers.String(n)
	return String(n):SetLiteral(n ~= nil)
end

do
	-- reuse an existing environment to speed up tests
	local BuildBaseEnvironment = require("nattlua.runtime.base_environment").BuildBaseEnvironment
	local runtime_env, typesystem_env = BuildBaseEnvironment()

	function helpers.RunCode(code, expect_error, expect_warning)
		local info = debug.getinfo(2)
		local name = info.source:match("(test/nattlua/.+)") or info.source

		if not _G.ON_EDITOR_SAVE then
			io.write(".")
			io.flush()
		end

		_G.TEST = true
		local compiler = nl.Compiler(code, nil, nil, 3)
		compiler:SetEnvironments(runtime_env:Copy(), typesystem_env)
		local ok, err = compiler:Analyze()
		_G.TEST = false

		if expect_warning then
			local str = ""

			for _, diagnostic in ipairs(compiler.analyzer.diagnostics) do
				if diagnostic.msg:find(expect_warning) then return compiler end

				str = str .. diagnostic.msg .. "\n"
			end

			if str == "" then error("expected warning, got\n\n\n" .. str, 3) end

			error("expected warning '" .. expect_warning .. "' got:\n>>\n" .. str .. "\n<<", 3)
		end

		if expect_error then
			if not err or err == "" then
				error(
					"expected error, got nothing\n\n\n[" .. tostring(ok) .. ", " .. tostring(err) .. "]",
					3
				)
			elseif type(expect_error) == "string" then
				if not err:find(expect_error) then
					error("expected error '" .. expect_error .. "' got:\n>>\n" .. err .. "\n<<", 3)
				end
			elseif type(expect_error) == "function" then
				local ok, msg = pcall(expect_error, err)

				if not ok then
					error("error did not pass: " .. msg .. "\n\nthe error message was:\n" .. err, 3)
				end
			else
				error("invalid expect_error argument", 3)
			end
		else
			if not ok then error(err, 3) end
		end

		return compiler.analyzer, compiler.SyntaxTree
	end
end

function helpers.Transpile(code)
	return helpers.RunCode(code):Emit({type_annotations = true})
end

function helpers.TableEqual(o1, o2, ignore_mt, callList)
	if o1 == o2 then return true end

	callList = callList or {}
	local o1Type = type(o1)
	local o2Type = type(o2)

	if o1Type ~= o2Type then return false end

	if o1Type ~= "table" then return false end

	-- add only when objects are tables, cache results
	local oComparisons = callList[o1]

	if not oComparisons then
		oComparisons = {}
		callList[o1] = oComparisons
	end

	-- false means that comparison is in progress
	oComparisons[o2] = false

	if not ignore_mt then
		local mt1 = getmetatable(o1)

		if mt1 and mt1.__eq then
			--compare using built in method
			return o1 == o2
		end
	end

	local keySet = {}

	for key1, value1 in pairs(o1) do
		local value2 = o2[key1]

		if value2 == nil then return false end

		local vComparisons = callList[value1]

		if not vComparisons or vComparisons[value2] == nil then
			if not helpers.TableEqual(value1, value2, ignore_mt, callList) then
				return false
			end
		end

		keySet[key1] = true
	end

	for key2, _ in pairs(o2) do
		if not keySet[key2] then return false end
	end

	-- comparison finished - objects are equal do not compare again
	oComparisons[o2] = true
	return true
end

return helpers
