--[[#local type { Token } = import("~/nattlua/lexer/token.lua")]]

--[[#local type { ExpressionKind, StatementKind, Node } = import("~/nattlua/parser/nodes.nlua")]]

--[[#local type NodeType = "expression" | "statement"]]
local ipairs = _G.ipairs
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local type = _G.type
local table = _G.table
local helpers = require("nattlua.other.helpers")
local quote_helper = require("nattlua.other.quote")
local class = require("nattlua.other.class")
local META = class.CreateTemplate("node")
--[[#type META.@Name = "Node"]]
--[[#type META.@Self = Node]]

function META.New(init--[[#: Omit<|META.@Self, "id" | "tokens"|>]])--[[#: Node]]
	init.tokens = {}
	return setmetatable(init--[[# as META.@Self]], META)
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
		--[[#-- we have to do this because nattlua.transpiler.emitter is not yet typed
		-- so if it's hoisted the self/nodes.nlua will fail
		attest.expect_diagnostic<|"warning", "always false"|>]]
		--[[#attest.expect_diagnostic<|"warning", "always true"|>]]

		if _G.IMPORTS--[[# as false]] then
			emitter = IMPORTS["nattlua.transpiler.emitter"]()
		else
			--[[#£ parser.dont_hoist_next_import = true]]

			emitter = require("nattlua.transpiler.emitter"--[[# as string]])
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

function META:GetNodes()--[[#: List<|any|>]]
	local statements = self.statements--[[# as any]]

	if self.kind == "if" then
		local flat--[[#: List<|any|>]] = {}

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
	node--[[#: META.@Self]],
	what--[[#: StatementKind | ExpressionKind]],
	out--[[#: List<|META.@Name|>]]
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

function META:FindNodesByType(what--[[#: StatementKind | ExpressionKind]])
	return find_by_type(self, what, {})
end

return META