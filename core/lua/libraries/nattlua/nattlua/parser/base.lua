--[[#local type { Token, TokenType } = import("~/nattlua/lexer/token.lua")]]

--[[#local type { ExpressionKind, StatementKind, statement, expression, Node } = import("./nodes.nlua")]]

--[[#local type { ParserConfig } = import("./../config.nlua")]]

--[[#local type { Code } = import<|"~/nattlua/code.lua"|>]]

--[[#local type NodeType = "expression" | "statement"]]
local CreateNode = require("nattlua.parser.node").New
local ipairs = _G.ipairs
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local type = _G.type
local table = _G.table
local helpers = require("nattlua.other.helpers")
local quote_helper = require("nattlua.other.quote")
local class = require("nattlua.other.class")
local META = class.CreateTemplate("parser")
--[[#type META.@Self = {
	@Name = "Parser",
	config = ParserConfig,
	nodes = List<|Node|>,
	Code = Code,
	current_statement = false | Node,
	current_expression = false | Node,
	root = false | Node,
	i = number,
	tokens = List<|Token|>,
	environment_stack = List<|"typesystem" | "runtime"|>,
	OnNode = nil | function=(self, Node)>(nil),
	suppress_on_node = nil | {parent = Node, nodes = List<|Node|>},
}]]
--[[#type META.@Name = "Parser"]]
--[[#local type Parser = META.@Self]]

function META.New(
	tokens--[[#: List<|Token|>]],
	code--[[#: Code]],
	config--[[#: nil | {
		root = nil | Node,
		on_node = nil | function=(Parser, Node)>(Node),
		path = nil | string,
	}]]
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

	function META:PushParserEnvironment(env--[[#: "runtime" | "typesystem"]])
		table.insert(self.environment_stack, env)
	end

	function META:PopParserEnvironment()
		table.remove(self.environment_stack)
	end
end

function META:StartNode(
	node_type--[[#: ref ("statement" | "expression")]],
	kind--[[#: ref (StatementKind | ExpressionKind)]],
	start_node--[[#: nil | Node]]
)--[[#: ref Node]]
	--[[#local type T = node_type == "statement" and statement[kind] or expression[kind] ]]
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
	return node--[[# as T]]
end

function META:EndNode(node--[[#: Node]])
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
				node = new_node--[[# as any]]
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
	msg--[[#: string]],
	start_token--[[#: Token | nil]],
	stop_token--[[#: Token | nil]],
	...--[[#: ...any]]
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
	code--[[#: Code]],
	message--[[#: string]],
	start--[[#: number]],
	stop--[[#: number]],
	...--[[#: ...any]]
) end

function META:GetToken(offset--[[#: number | nil]])
	return self.tokens[self.i + (offset or 0)]
end

function META:GetLength()
	return #self.tokens
end

function META:Advance(offset--[[#: number]])
	self.i = self.i + offset
end

function META:IsValue(str--[[#: string]], offset--[[#: number | nil]])
	local tk = self:GetToken(offset)

	if tk then return tk.value == str end
end

function META:IsType(token_type--[[#: TokenType]], offset--[[#: number | nil]])
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

function META:AddTokens(tokens--[[#: {[1 .. inf] = Token}]])
	local eof = table.remove(self.tokens)--[[# as Token]]

	for i, token in ipairs(tokens) do
		if token.type == "end_of_file" then break end

		table.insert(self.tokens, self.i + i - 1, token)
	end

	table.insert(self.tokens, eof)
end

do
	local function error_expect(
		self--[[#: META.@Self]],
		str--[[#: string]],
		what--[[#: string]],
		start--[[#: Token | nil]],
		stop--[[#: Token | nil]]
	)
		local tk = self:GetToken()

		if not tk then
			self:Error("expected $1 $2: reached end of code", start, stop, what, str)
		else
			self:Error("expected $1 $2: got $3", start, stop, what, str, tk[what])
		end
	end

	function META:ExpectValue(str--[[#: string]], error_start--[[#: Token | nil]], error_stop--[[#: Token | nil]])--[[#: Token]]
		if not self:IsValue(str) then
			error_expect(self, str, "value", error_start, error_stop)
		end

		return self:ParseToken()--[[# as Token]]
	end

	function META:ExpectValueTranslate(
		str--[[#: string]],
		new_str--[[#: string]],
		error_start--[[#: Token | nil]],
		error_stop--[[#: Token | nil]]
	)--[[#: Token]]
		if not self:IsValue(str) then
			error_expect(self, str, "value", error_start, error_stop)
		end

		local tk = self:ParseToken()--[[# as Token]]
		tk.value = new_str
		return tk
	end

	function META:ExpectType(
		str--[[#: TokenType]],
		error_start--[[#: Token | nil]],
		error_stop--[[#: Token | nil]]
	)--[[#: Token]]
		if not self:IsType(str) then
			error_expect(self, str, "type", error_start, error_stop)
		end

		return self:ParseToken()--[[# as Token]]
	end

	function META:NewToken(type--[[#: TokenType]], value--[[#: string]])
		local tk = {}
		tk.type = type
		tk.is_whitespace = false
		tk.value = value
		return tk
	end
end

function META:ParseValues(
	values--[[#: Map<|string, true|>]],
	start--[[#: Token | nil]],
	stop--[[#: Token | nil]]
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

function META:ParseStatements(stop_token--[[#: {[string] = true} | nil]])
	local out = {}
	local i = 1

	for _ = 1, self:GetLength() do
		local tk = self:GetToken()

		if not tk then break end

		if stop_token and stop_token[tk.value] then break end

		local node = (self--[[# as any]]):ParseStatement()

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

function META:ResolvePath(path--[[#: string]])
	return path
end

function META:ParseMultipleValues(
	max--[[#: nil | number]],
	reader--[[#: ref function=(Parser, ...: ref ...any)>(ref (nil | Node))]],
	a--[[#: ref any]],
	b--[[#: ref any]],
	c--[[#: ref any]]
)
	local out = {}

	for i = 1, max or self:GetLength() do
		local node = reader(self, a, b, c)

		if not node then break end

		out[i] = node

		if not self:IsValue(",") then break end

		(node.tokens--[[# as any]])[","] = self:ExpectValue(",")
	end

	return out
end

return META