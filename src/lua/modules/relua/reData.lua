
local DefaultTable = {}
DefaultTable.__index = DefaultTable
setmetatable(DefaultTable, DefaultTable)
function DefaultTable.__call(table, val)
	local self = {}
	local mt = {}
	if type(val) == "function" then
		mt.__index = function(table, key)
			local v = val(key)
			table[key] = v
			return v
		end
	elseif type(val) == "table" then
		mt.__index = function(table, key)
			local t = {}
			for k,v in pairs(val) do
				t[k]=v
			end
			table[key] = t
			return t
		end
	else
		mt.__index = function(table, key)
			return val
		end
	end
	return setmetatable(self, mt)
end

local ListTable = {}
ListTable.__index = ListTable
setmetatable(ListTable, ListTable)
function ListTable.__call()
	return DefaultTable({})
end

local CharacterClass = {}
setmetatable(CharacterClass, CharacterClass)
function CharacterClass.__call(t, str)
	local self = DefaultTable(false)
	local i=1
	local lastC = ""
	local escaped = false
	local negate = false
	for c in str:sub(2):gmatch(".") do
		i = i+1
		if i == 2 and c == "^" then
			self = DefaultTable(true)
			negate = true
		elseif c == ESC and not escaped then
			escaped = true
		elseif c == "]" and not escaped then
			break
		elseif c == "-" and not escaped and i ~= 1 and i ~= #str then
			local nextC=string.sub(str,i+1,i+1)
			-- add a range of characters
			for n=string.byte(lastC),string.byte(nextC) do
				n = string.char(n)
				self[n] = not negate
			end
		else
			self[c] = not negate
		end
		lastC = c
	end
	self.isCharacterClass = true
	mt = getmetatable(self) -- modify the DefaultTable metatable
	function mt.__tostring(self)
		local str = {}
		table.insert(str, "[")
		if negate then table.insert(str, "^") end
		for k,v in pairs(self) do
			if k ~= "isCharacterClass" then
				table.insert(str, k)
			end
		end
		table.insert(str, "]")
		return table.concat(str)
	end
	return self
end


local Tree = {}
Tree.__index = Tree
-- function newTree(* val, {Tree} children) return Tree A Tree object with val as its value and *children* for children
function Tree.new(val, children)
	local t
	if children then
		t = {val=val, children=children}
	else
		t = {val=val, children={}}
	end
	setmetatable(t, Tree)
	return t
end
--function Tree.empty(Tree self) return Bool True if self is an empty Tree, false otherwise.
--A Tree is empty if has no children and has no val field.
function Tree.empty(self)
	if not self.val then
		return true
	end
	return false
end
-- function Tree.concat(Tree left, Tree right) return Tree The concatenation of the left and right Trees
function Tree.concat(left, right)
	if left:empty() then return right end
	if right:empty() then return left end
	local children = {}
	if left.val == "CONCAT" then
		for _,c in ipairs(left.children) do
			table.insert(children, c)
		end
	else
		table.insert(children, left)
	end
	if right.val == "CONCAT" then
		for _,c in ipairs(right.children) do
			table.insert(children, c)
		end
	else
		table.insert(children, right)
	end
	return Tree.new("CONCAT", children)
end
-- function Tree.print(Tree self) Print the tree to stdout
function Tree.print(self, indent)
	local indent = indent or ""
	local val = tostring(self.val) or "EMPTY"
	print(indent .. "->" .. val)
	for _,t in pairs(self.children) do
		t:print( indent .. "|" )
	end
end
function Tree.__tostring2(self, indent, str)
	local val = tostring(self.val) or "EMPTY"
	for i=1,indent do
		table.insert(str, "|")
	end
	table.insert(str, "_>")
	table.insert(str, val)
	table.insert(str, "\n")
	for _,c in pairs(self.children) do
		c:__tostring2(indent+1, str)
	end
end
function Tree.__tostring(self)
	local s = {}
	self:__tostring2(0, s)
	return table.concat(s)
end

-- object Stack a filo stack.
local Stack = {}
Stack.__index = Stack
--function Stack.new() return Stack A new empty stack
function Stack.new()
	return setmetatable({}, Stack)
end
-- function Stack.push(self, val) Adds val ontop of the stack
function Stack:push(val)
	table.insert(self, val)
end
-- function Stack.pop(self) return * The first item on the stack
function Stack:pop()
	return table.remove(self)
end



local Data = {}
Data.DefaultTable = DefaultTable
Data.ListTable = ListTable
Data.CharacterClass = CharacterClass
Data.Tree = Tree
Data.Stack = Stack
return Data
