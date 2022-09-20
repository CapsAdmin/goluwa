local oh = ... or _G.oh
local table_insert = table.insert
local table_remove = table.remove
local PARSER = {}
PARSER.__index = PARSER

function PARSER:Node(t, val)
	local node = {}
	node.type = t
	node.tokens = {}
	return node
end

function PARSER:Error(msg, start, stop, level, offset)
	if not self.on_error then return end

	if type(start) == "table" then start = start.start end

	if type(stop) == "table" then stop = stop.stop end

	local tk = self:GetTokenOffset(offset or 0) or self.chunks[#self.chunks]
	start = start or tk.start
	stop = stop or tk.stop
	self:on_error(msg, start, stop)
end

function PARSER:GetToken()
	return self.chunks[self.i] and
		self.chunks[self.i].type ~= "end_of_file" and
		self.chunks[self.i] or
		nil
end

function PARSER:GetTokenOffset(offset)
	return self.chunks[self.i + offset]
end

function PARSER:ReadToken()
	local tk = self:GetToken()
	self:Advance(1)
	return tk
end

function PARSER:IsValue(str)
	return self.chunks[self.i] and self.chunks[self.i].value == str and self.chunks[self.i]
end

function PARSER:IsType(str)
	local tk = self:GetToken()
	return tk and tk.type == str
end

function PARSER:ReadExpectType(type, start, stop)
	local tk = self:GetToken()

	if not tk then
		self:Error("expected " .. oh.QuoteToken(type) .. " reached end of code", start, stop, 3, -1)
	elseif tk.type ~= type then
		self:Error(
			"expected " .. oh.QuoteToken(type) .. " got " .. oh.QuoteToken(tk.type) .. "(" .. tk.value .. ")",
			start,
			stop,
			3,
			-1
		)
	end

	self:Advance(1)
	return tk
end

function PARSER:ReadExpectValue(value, start, stop)
	local tk = self:ReadToken()

	if not tk then
		self:Error(
			"expected " .. oh.QuoteToken(value) .. ": reached end of code",
			start,
			stop,
			3,
			-1
		)
	elseif tk.value ~= value then
		self:Error(
			"expected " .. oh.QuoteToken(value) .. ": got " .. oh.QuoteToken(tk.value),
			start,
			stop,
			3,
			-1
		)
	end

	return tk
end

do
	local function table_hasvalue(tbl, val)
		for k, v in ipairs(tbl) do
			if v == val then return k end
		end

		return false
	end

	function PARSER:ReadExpectValues(values, start, stop)
		local tk = self:GetToken()

		if not tk then
			self:Error("expected " .. oh.QuoteTokens(values) .. ": reached end of code", start, stop)
		elseif not table_hasvalue(values, tk.value) then
			self:Error("expected " .. oh.QuoteTokens(values) .. " got " .. tk.value, start, stop)
		end

		self:Advance(1)
		return tk
	end
end

function PARSER:GetLength()
	return self.chunks_length
end

function PARSER:Advance(offset)
	self.i = self.i + offset
end

function PARSER:PushLoopBlock(node)
	table_insert(self.loop_stack, node)
end

function PARSER:PopLoopBlock()
	table_remove(self.loop_stack)
end

do
	function PARSER:PushNode(type)
		local node = self:Node(type)
		self.node_stack = self.node_stack or {}
		node.parent = self.node_stack[#self.node_stack]
		table.insert(self.node_stack, node)

		if node.parent then
			node.parent.children = node.parent.children or {}
			table.insert(node.parent.children, node)
		end

		return node
	end

	function PARSER:PopNode()
		table.remove(self.node_stack)
	end

	function PARSER:StoreToken(what, tk)
		self.node_stack[#self.node_stack].tokens[what] = tk
	end

	function PARSER:Store(key, val)
		self.node_stack[#self.node_stack][key] = val
	end
end

function PARSER:BuildAST(tokens)
	self.chunks = tokens
	self.chunks_length = #tokens
	self.i = 1
	self.loop_stack = {}
	local shebang

	if self:IsType("shebang") then
		shebang = self:Node("shebang")
		shebang.tokens["shebang"] = self:ReadToken()
	end

	local block = self:Block()

	if shebang then table.insert(block.statements, 1, shebang) end

	if tokens[#tokens] and tokens[#tokens].type == "end_of_file" then
		local node = self:Node("end_of_file")
		node.tokens["end_of_file"] = tokens[#tokens]
		table.insert(block.statements, node)
	end

	return block
end

return PARSER