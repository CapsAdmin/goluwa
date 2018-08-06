local kua = ... or _G.kua or {}

if not kua.GetTokens then
	runfile("tokenizer.lua", kua)
end

function kua.GetTree(tokens)

	local tree = {}
	tree.children = {}

	while true do
		local info = tokens:GetToken()
		tokens:Next()
		if not info then break end

		if info.value == "local" then
			local res = tokens:GetToken()

			if
				res.type ~= "letter" or
				(
					kua.syntax.keywords[res.value] and
					res.value ~= "function"
				)
			then
				return tokens:CompileError("name expected", res.start, res.start)
			end

			if res.value == "function" then

			else
				local data = {}
				data.type = "assignment"
				data.is_local = true

				data.names = {}

				while true do
					local info = tokens:GetToken()
					tokens:Next()

					if info.value == "=" then
						break
					end

					if info.value ~= "," then
						if info.type ~= "letter" then
							tokens:CompileError("unexpected symbol " .. info.value, info.start, info.stop)
							break
						end

						table.insert(data.names, info)
					end
				end

				data.expressions = {}

				while true do
					local tree, nxt = tokens:MatchExpression()

					table.insert(data.expressions, tree)

					if not nxt or nxt.value ~= "," then
						break
					end
				end

				tokens.i = tokens.i - 2

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
	end

	return tree
end

local code = [==[

local a = a+i < b/2+1
local b = 5+x^2*8
local a = (1+2)+(3+4)

local a = a+i < b/2+1
local b = 5+x^2*8
local a =a < y and y <= z
local a =-x^2
local a =x^y^z
local a = 5+x^2*8
local a = x < y and x*x or y*y
local a = 1+2+3+4
local a = (1+2)+(3+4)
local a = (1+(2)+(3)+4)
local a = (1+(2+3)+4)
local a,b,c = 1,3+2^3,(3+2)^3
local a = 5+(1+2+3+4)

]==]

--[[
]]

local tokens = kua.Tokenize(code)

if tokens then
	tokens:Dump()
	kua.GetTree(tokens)
end

function kua.TestLuajitLangToolkit(code)
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
end