local coverage = {}
_G.__COVERAGE = _G.__COVERAGE or {}
coverage.collected = {}
local nl = require("nattlua")

function coverage.Preprocess(code, key)
	local expressions = {}

	local function inject_call_expression(parser, node, start, stop)
		local call_expression = parser:ParseString(" Æ(" .. start .. "," .. stop .. ") ").statements[1].value

		if node.kind == "postfix_call" and not node.tokens["call("] then
			node.tokens["call("] = parser:NewToken("symbol", "(")
			node.tokens["call)"] = parser:NewToken("symbol", ")")
		end

		-- add comma to last expression since we're adding a new one
		call_expression.expressions[#call_expression.expressions].tokens[","] = parser:NewToken("symbol", ",")
		table.insert(call_expression.expressions, node)

		if node.right then call_expression.right = node.right end

		table.insert(expressions, node)
		-- to prevent start stop messing up from previous injections
		call_expression.code_start = node.code_start
		call_expression.code_stop = node.code_stop
		return call_expression
	end

	local compiler = nl.Compiler(
		code,
		"lol",
		{
			on_node = function(parser, node)
				if node.type == "statement" then
					if node.kind == "call_expression" then
						local start, stop = node:GetStartStop()
						node.value = inject_call_expression(parser, node.value, start, stop)
					end
				elseif node.type == "expression" then
					local start, stop = node:GetStartStop()

					if
						node.is_left_assignment or
						node.is_identifier or
						node:GetStatement().kind == "function" or
						(
							node.kind == "binary_operator" and
							(
								node.value.value == "." or
								node.value.value == ":"
							)
						)
						or
						(
							node.parent and
							node.parent.kind == "binary_operator" and
							(
								node.parent.value.value == "." or
								node.parent.value.value == ":"
							)
						)
					then
						return
					end

					return inject_call_expression(parser, node, start, stop)
				end
			end,
			skip_import = true,
		}
	)
	assert(compiler:Parse())
	local lua = compiler:Emit()
	lua = [[
local called = _G.__COVERAGE["]] .. key .. [["].called
local function Æ(start, stop, ...)
	local key = start..", "..stop
	called[key] = called[key] or {start, stop, 0}
	called[key][3] = called[key][3] + 1
	return ...
end
------------------------------------------------------
]] .. lua
	_G.__COVERAGE[key] = _G.__COVERAGE[key] or
		{called = {}, expressions = expressions, compiler = compiler, preprocesed = lua}
	return lua
end

function coverage.GetAll()
	return _G.__COVERAGE
end

local MASK = " "

function coverage.Collect(key)
	local data = _G.__COVERAGE[key]

	if not data then return end

	local called = data.called
	local expressions = data.expressions
	local compiler = data.compiler
	local original = compiler.Code:GetString()
	local buffer = {}

	for i = 1, #original do
		buffer[i] = original:sub(i, i)
	end

	local not_called = {}

	for _, exp in ipairs(expressions) do
		local start, stop = exp:GetStartStop()

		if not called[start .. ", " .. stop] then
			for i = start, stop do
				not_called[i] = true
			end
		end
	end

	for _, start_stop in pairs(called) do
		local start, stop, count = start_stop[1], start_stop[2], start_stop[3]
		buffer[start] = "--[[" .. count .. "]]" .. buffer[start]
	end

	return table.concat(buffer)
end

return coverage
