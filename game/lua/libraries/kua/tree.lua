local kua = ... or _G.kua or {}

if not kua.GetTokens then
	runfile("tokenizer.lua", kua)
end

local function balanced_match(tokens, i, match, max)
	local balance = 0
	local start

	for i2 = i, max or #tokens do
		local token = tokens[i2]

		if match[token.value] == true then
			start = start or i2
			balance = balance + 1
		elseif match[token.value] == false then
			balance = balance - 1
		end

		if balance == 0 and start then
			return start, i2
		end
	end
end

local binop = {
    ['+']  = 6 * 256 + 6, ['-']  = 6 * 256 + 6, ['*'] = 7 * 256 + 7, ['/'] = 7 * 256 + 7, ['%'] = 7 * 256 + 7,
    ['^']  = 10* 256 + 9, ['..'] = 5 * 256 + 4, -- POW CONCAT (right associative)
    ['=='] = 3 * 256 + 3, ['~='] = 3 * 256 + 3,
    ['<']  = 3 * 256 + 3, ['>='] = 3 * 256 + 3, ['>'] = 3 * 256 + 3, ['<='] = 3 * 256 + 3,
    ['and']= 2 * 256 + 2, ['or'] = 1 * 256 + 1,
}

local unary_priority = 8

-- Pseudo priority of a simple identifier. Should be higher than any
-- others operator's priority.
local ident_priority = 16

local function is_binop(op)
    return binop[op]
end

local function left_priority(op)
    return bit.rshift(binop[op], 8)
end

local function right_priority(op)
    return bit.band(binop[op], 0xff)
end

for k,v in pairs(kua.syntax.is_operator) do
	kua.syntax.is_operator[k] = {
		left = binop[k] and left_priority(k) or -1,
		right = binop[k] and right_priority(k) or -1,
	}
end

local operator = {
    is_binop       = is_binop,
    left_priority  = left_priority,
    right_priority = right_priority,
    unary_priority = unary_priority,
    ident_priority = ident_priority,
}

function kua.GetTree(tokens)

	local tree = {}
	tree.children = {}

	local i = 1

	while true do
		local info = tokens:GetToken(i)
		if not info then break end

		if info.value == "local" then

			local res = tokens:GetToken(i + 1)

			if
				res.type ~= "letter" or
				(
					kua.syntax.keywords[res.value] and
					res.value ~= "function"
				)
			then
				return compile_error(tokens, "name expected", res.start, res.start)
			end

			if res.value ~= "function" then
				local data = {}
				data.type = "assignment"
				data.is_local = true

				data.names = {}

				for offset = i + 1, math.huge do
					local info = tokens:GetToken(offset)

					if info.value == "=" then
						i = offset
						break
					end

					if info.type ~= "letter" then
						compile_error(tokens, "unexpected symbol " .. info.value, info.start, info.stop)
						break
					end

					if info.value ~= "," then
						table.insert(data.names, info)
					end
				end

				data.expressions = {}

				local found = 1

				for offset = i + 1, math.huge do
					local token = tokens:GetToken(offset)

					if not token then break end

					if info.value == ";" then
						i = offset
						break
					end

					if token.value == "," then
						found = found + 1
					else
						data.expressions[found]  = data.expressions[found] or {}

						local t = data.expressions[found]

						if
						token.value ~= ")" and token.value ~= "(" and (
							(kua.syntax.is_operator[token.value] and t[#t] and kua.syntax.is_operator[t[#t].value]) or
							(not kua.syntax.is_operator[token.value] and t[#t] and not kua.syntax.is_operator[t[#t].value] and t[#t].value ~= "(" and t[#t].value ~= ")")
						)

						then

							if token.type ~= "letter" then
								return compile_error(tokens, "unexpected end of declaration", token.start, token.stop)
							end

							i = offset - 1
							break
						end

						table.insert(data.expressions[found], token)
					end
				end

				for i, declaration in ipairs(data.expressions) do
					if declaration[2] then
						local function ugh(limit, tokens)
							local i = 1
							local function match(limit, tokens)
								local v = tokens[i]

								if v.value == "(" then
									local start, stop = balanced_match(tokens, i, {["("] = true, [")"] = false})
									local temp = {}
									for i = start+1, stop-1 do
										table.insert(temp, tokens[i])
									end
									v = ugh(0, temp)
									i = stop
								end

								i = i  + 1

								if v.value == "-" or v.value == "#" or v.value == "not" then
									v = {type = "unary", value = v.value, argument = match(unary_priority, tokens)}
								end

								local op = tokens[i]
								if not op then
									return v
								end

								i = i + 1

								while is_binop(op.value) and operator.left_priority(op.value) > limit do
									local v2, nextop = match(operator.right_priority(op.value), tokens)

									v = {type = "operator", value = op.value, left = v, right = v2}

									if not nextop then
										return v
									end

									op = nextop
								end

								return v, op
							end
							return match(limit, tokens)
						end

						data.expressions[1] = ugh(0, declaration)
					else
						data.expressions[i] = declaration[1]
					end
				end

				table.insert(tree, data)

				log("local ")
				for i, v in ipairs(data.names) do
					log(v.value)
					if i ~= #data.names then
						log(", ")
					end
				end
				log(" = ")

				local function dump(v)
					if v.left then
						log("(")
						dump(v.left)
					end
					log(v.value)
					if v.right then
						dump(v.right)
						log(")")
					end
				end

				for i, v in ipairs(data.expressions) do
					if v.type == "operator" then
						dump(v)
					elseif v.type == "unary" then
						log(v.value)
						dump(v.argument)
					else
						log(v.value)
					end

					if i ~= #data.expressions then
						log(", ")
					end
				end
				logn()
			end
		end

		i = i + 1
	end

	return tree
end

local code = [==[

local a = a+i < b/2+1
local a = 5+x^2*8
local a =a < y and y <= z
local a =-x^2
local a =x^y^z
local a = 5+x^2*8
local a = x < y and x*x or y*y
local a = 1+2+3+4
local a = (1+2)+(3+4)
local a = (1+(2)+(3)+4)
local a = (1+(2+3)+4)
local a = 2
]==]

local tokens = kua.Tokenize(code)

if tokens then
	kua.DumpTokens(tokens)
	kua.GetTree(tokens)
end

print("===========")
local ls = require("lang.lexer")(require("lang.reader").string(code), code)
local parse = require('lang.parser')
local lua_ast = require('lang.lua-ast')
local ast_builder = lua_ast.New()
local parse_success, ast_tree = pcall(parse, ast_builder, ls)

for _, data in ipairs(ast_tree.body) do
	log("local ")
	for i, v in ipairs(data.names) do
		log(v.name)
		if i ~= #data.names then
			log(", ")
		end
	end
	log(" = ")
	for i, v in ipairs(data.expressions) do
		if v.kind == "BinaryExpression" then
			local function dump(v)
				local lol = false
				if v.left then
					log("(")
					dump(v.left)
				end
				if lol then
					log(",")
				else
					log(v.value or v.operator or v.name)
				end
				if v.right then
					dump(v.right)
					log(")")
				end
			end
			dump(v)
		else
			log(v.value)
		end

		if i ~= #data.expressions then
			log(", ")
		end
	end
	logn()
end

--local generate = require("lang.luacode-generator")
--print(generate(ast_tree, "test"))

--table.print2(ast_tree.body)

--[[
    a+i < b/2+1          <-->       (a+i) < ((b/2)+1)
    5+x^2*8              <-->       5+((x^2)*8)
    a < y and y <= z     <-->       (a < y) and (y <= z)
    -x^2                 <-->       -(x^2)
    x^y^z                <-->       x^(y^z)

	5+x^2*8              <-->       5+((x^2)*8)

]]
--table.print2(data.expressions)