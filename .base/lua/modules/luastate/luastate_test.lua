local luastate = require'luastate'

local lua = luastate.open()
lua:openlibs('base')
lua:openlibs()

assert(lua:loadstring([[
	return ...
]], 'main'))
local a1, a2, a3, a4, a5 = 42.5, nil, false, "str", {k=5,t={},[{a=1}]={b=""}}
local b1, b2, b3, b4, b5 = lua:call(a1, a2, a3, a4, a5)
assert(a1 == b1)
assert(a2 == b2)
assert(a3 == b3)
assert(a4 == b4)
assert(a5.k == b5.k)
assert(next(b5.t) == nil)
local tk, tv
for k,v in pairs(b5) do
	if type(k) == 'table' then
		tk, tv = k, v
	end
end
assert(tk.a == 1)
assert(tv.b == '')

local upvalue = 5
local depth = 3000
lua:push(function(depth, ...)
	assert(upvalue == nil)
	local function deep_table(depth)
		local root = {}
		local t = root
		for i=1,depth do --test stack overflow
			t[1] = {}
			t = t[1]
		end
		return root
	end
	return deep_table(depth)
end)
local function deep_table(depth)
	local root = {}
	local t = root
	for i=1,depth do --test stack overflow
		t[1] = {}
		t = t[1]
	end
	return root
end
local t = lua:call(depth, 'hi', 'there', deep_table(depth))
local n = -1
while t do
	n = n + 1
	t = t[1]
end
assert(n == depth)
lua:push(function(x) return x^2 end)
local f = lua:get()
assert(f(5) == 25)

assert(lua:gettop() == 0)
lua:close()
