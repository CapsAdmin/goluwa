local oh = ... or _G.oh

function oh.Validate(ast, code, path)

	-- format error for tonumber({})
	-- not sure where to look for tokens

	local validate_block
	local validate_expression
	local scope = {}

	scope.tostring = {
		arguments = {
			{value_type = {"any"}}
		},
		return_types = {
			{"string"}
		},
	}
	scope.print = {
		arguments = {
			{value_type = {"any"}}
		},
		return_types = {
			{"nil"}
		},
	}
	scope.tonumber = {
		arguments = {
			{value_type = {"number", "string"}}
		},
		return_types = {
			{"nil", "number"}
		},
	}

	local function type_compatible(a, b)
		if table.hasvalue(a, "any") or table.hasvalue(a, "b") then
			return true
		end

		for _, a2 in ipairs(a) do
			for _,b2 in ipairs(b) do
				if a2 == b2 then
					return true
				end
			end
		end
		return false
	end

	local function flatten(expr, out)
		if expr.left then
			flatten(expr.left, out)
		end
		if expr.type == "letter" then
			table.insert(out, expr.value)
		elseif expr.type == "operator" then
			table.insert(out, expr.operator)
		elseif expr.type == "value" then
			table.insert(out, expr.value.value)
		end
		if expr.right then
			flatten(expr.right, out)
		end
	end

	local function get_key(expr)
		local out = {}
		flatten(expr, out)
		return table.concat(out)
	end

	local function get_variable(expr)
		local key = get_key(expr)
		local value = scope[key]
		if not value then
			print("undeclared variable!")
		end
		return value
	end

	local function token2type(node)
		if not node then
			return {"any"}
		end

		if node.value_type then
			return node.value_type
		end

		if node.return_types then
			return node.return_types[1]
		end

		if node.type == "value" then
			if node.value.type == "letter" then
				if node.value.value:find("num", nil, true) then
					return {"number"}
				elseif node.value.value:find("str", nil, true) then
					return {"string"}
				elseif node.value.value == "true" or node.value.value == "false" then
					return {"boolean"}
				elseif node.value.value == "nil" then
					return {"nil"}
				end
				return {"any"}
			end

			return {node.value.type}
		end

		return {node.type}
	end

	local function check(node)
		if node.type == "expression" then
			local func = get_variable(node.value)
			if func then
				for index_i, node in ipairs(node.value.calls) do
					if node.type == "call" then
						for i, arg in ipairs(func.value.arguments) do
							local expected = token2type(arg)
							local got
							local error_start
							local error_stop

							if node.arguments[i] then
								local val = node.arguments[i]
								if val.calls then

								elseif val.type == "index_expression" then
									got = token2type(get_variable(val.value))
									error_start = val[1].value.value.start or -1
									error_stop = val[1].value.value.stop or -1
								elseif val.type == "table" then
									got = {val.type}
									error_start = val["{"].start
									error_stop = val["}"].stop
								else
									got = token2type(get_variable(val.value))
									error_start = val.value.start or -1
									error_stop = val.value.stop or -1
								end
							else
								got = {"nil"}
								error_start = node["call("].start
								error_stop = node["call)"].stop
							end

							if not type_compatible(expected, got) then
								print(oh.FormatError(code, path, "expected " .. table.concat(expected, "|") .. " to argument #" .. i .. " got " .. table.concat(got, "|"), error_start, error_stop))
							end
						end
						break -- handle return
					end
				end
			end
		end
	end

	local function get_type(var)
		if var.type == "value" and var.value.type == "letter" then
			local var = get_variable(var)
			if var then
				return var.value_type or  {"error"}
			end
			return {"error"}
		end
		return token2type(var)
	end

	function validate_expression(expr)
		local left_type, right_type

		if not expr.left or not expr.right then
			check(expr)
			local t = get_type(expr)
			return t, t
		end

		if expr.left.type == "operator" then
			left_type = validate_expression(expr.left)
		else
			left_type = get_type(expr.left)
		end

		if expr.right.type == "operator" then
			right_type = validate_expression(expr.right)
		else
			right_type = get_type(expr.right)
		end
		if not right_type then
			table.print(expr.right.value, 1)
		end

		if not type_compatible(left_type, right_type) then
			print(oh.FormatError(
				code, path,
				table.concat(left_type, "|") .. " " .. expr.operator .. " " .. table.concat(right_type, "|"),
				expr.left.value.start or expr.left.right.start or expr.left.right.value.start,
				expr.right.stop or expr.right.value.stop
			))
		end

		return left_type, right_type
	end

	function validate_block(block)
		local return_types = {}

		for _, node in ipairs(block) do
			if node.type == "assignment" then
				if node.sub_type == "function" then
					for _, arg in ipairs(node.value.arguments) do
						arg.value_type = token2type(arg)
						scope[get_key(arg)] = arg
					end
					node.value.return_types = validate_block(node.value.block)
					scope[get_key(node.value.index_expression)] = node
				else
					for i, val in ipairs(node.left) do
						node.right[i].value_type = validate_expression(node.right[i])
						val.value_type = node.right[i].value_type
						scope[get_key(val)] = node.right[i]
					end
				end
			elseif node.type == "if" then
				for _, clause in ipairs(node.clauses) do
					table.add(return_types, validate_block(clause.block))
				end
			elseif node.type == "for" then
				table.add(return_types, validate_block(node.block))
			elseif node.type == "expression" then
				validate_expression(node)
			elseif node.type == "return" then
				if node.expressions then
					local args = {}
					for i, expr in ipairs(node.expressions) do
						local a, b = validate_expression(expr)
						if type_compatible(a, b) then
							args[i] = a
						else
							args[i] = {"any"}
						end
					end
					table.insert(return_types, args)
				end
			end
		end

		return return_types
	end


	validate_block(ast)
end


if RELOAD then
	runfile("lua/libraries/oh/test.lua")
end