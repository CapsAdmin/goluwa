local nl = require("nattlua")
local LuaEmitter = require("nattlua.transpiler.emitter").New
local code = io.open("nattlua/parser.lua"):read("*all")
local ast = assert(nl.Compiler(code):Parse()).SyntaxTree
local em = LuaEmitter({preserve_whitespace = false})

function em:OnEmitStatement()
	self:Emit(";")
end

local translate = {
	["not"] = "!",
	["and"] = "&&",
	["or"] = "||",
	["local"] = "var",
	--["for"] = "for (",
	["do"] = "{",
	["end"] = "}",
	["if"] = "if (",
	["then"] = ") {",
	["elseif"] = "} else if (",
	["else"] = "} else {",
}

function em:EmitForStatement(node)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["for"])
	self:Whitespace(" ")
	self:Emit("(")

	if node.fori then
		self:Emit("let ")
		self:EmitIdentifierList(node.identifiers)
		self:Whitespace(" ")
		self:EmitToken(node.tokens["="])
		self:Whitespace(" ")
		self:EmitExpression(node.expressions[1])
		self:Emit("; ")
		self:EmitIdentifierList(node.identifiers)
		self:Emit(" <= ")
		self:EmitExpression(node.expressions[2])
		self:Emit("; ")
		self:EmitIdentifierList(node.identifiers)
		self:Emit(" = ")
		self:EmitIdentifierList(node.identifiers)
		self:Emit(" + ")

		if node.expressions[3] then
			self:EmitExpression(node.expressions[3])
		else
			self:Emit("1")
		end
	else
		self:EmitIdentifierList(node.identifiers)
		self:Whitespace(" ")
		self:EmitToken(node.tokens["in"])
		self:Whitespace(" ")
		self:EmitExpressionList(node.expressions)
	end

	self:Emit(")")
	self:Whitespace(" ")
	self:EmitToken(node.tokens["do"])
	self:Whitespace("\n")
	self:EmitBlock(node.statements)
	self:Whitespace("\t")
	self:EmitToken(node.tokens["end"])
end

function em:TranslateToken(token)
	if translate[token.value] then return translate[token.value] end

	if token.type == "line_comment" then
		return "//" .. token.value:sub(3)
	elseif token.type == "multiline_comment" then
		local content = token.value:sub(5, -3):gsub("%*/", "* /"):gsub("/%*", "/ *")
		return "/*" .. content .. "*/"
	end

	if token.type == "letter" and token.value:upper() ~= token.value then
		return token.value:sub(1, 1):lower() .. token.value:sub(2)
	end
end

local code = em:BuildCode(ast)
print(code)
