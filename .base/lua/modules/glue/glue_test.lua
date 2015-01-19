local glue = require'glue'
require'unit'

test(select(2,pcall(glue.assert,false,'bad %s','dog')), 'bad dog')
test(select(2,pcall(glue.assert,false,'bad dog %s')), 'bad dog %s')
test({pcall(glue.assert,1,2,3)}, {true,1,2,3})

test(glue.index{a=5,b=7,c=3}, {[5]='a',[7]='b',[3]='c'})
test(glue.update({a=1,b=2,c=3}, {d='add',b='overwrite'}, {b='over2'}), {a=1,b='over2',c=3,d='add'})
test(glue.merge({a=1,b=2,c=3}, {d='add',b='overwrite'}, {b='over2'}), {a=1,b=2,c=3,d='add'})
test(glue.extend({5,6,8}, {1,2}, {'b','x'}), {5,6,8,1,2,'b','x'})
test(glue.append({1,2,3}, 5,6), {1,2,3,5,6})

local function insert(t,i,...)
	local n = select('#',...)
	glue.shift(t,i,n)
	for j=1,n do t[i+j-1] = select(j,...) end
	return t
end
test(insert({'a','b'}, 1, 'x','y'), {'x','y','a','b'}) --2 shifts
test(insert({'a','b','c','d'}, 3, 'x', 'y'), {'a','b','x','y','c','d'}) --2 shifts
test(insert({'a','b','c','d'}, 4, 'x', 'y'), {'a','b','c','x','y','d'}) --1 shift
test(insert({'a','b','c','d'}, 5, 'x', 'y'), {'a','b','c','d','x','y'}) --0 shifts
test(insert({'a','b','c','d'}, 6, 'x', 'y'), {'a','b','c','d',nil,'x','y'}) --out of bounds
test(insert({'a','b','c','d'}, 1, 'x', 'y'), {'x','y','a','b','c','d'}) --first pos
test(insert({}, 1, 'x', 'y'), {'x','y'}) --empty dest
test(insert({}, 3, 'x', 'y'), {nil,nil,'x','y'}) --out of bounds

local function remove(t,i,n) return glue.shift(t,i,-n) end
test(remove({'a','b','c','d'}, 1, 3), {'d'})
test(remove({'a','b','c','d'}, 2, 2), {'a', 'd'})
test(remove({'a','b','c','d'}, 3, 2), {'a', 'b'})
test(remove({'a','b','c','d'}, 1, 5), {}) --too many
test(remove({'a','b','c','d'}, 4, 2), {'a', 'b', 'c'}) --too many
test(remove({'a','b','c','d'}, 5, 5), {'a', 'b', 'c', 'd'}) --from too far
test(remove({}, 5, 5), {}) --from too far

local function test1(s,sep,expect)
	local t={} for c in glue.gsplit(s,sep) do t[#t+1]=c end
	assert(#t == #expect)
	for i=1,#t do assert(t[i] == expect[i]) end
	test(t, expect)
end
test1('','',{''})
test1('','asdf',{''})
test1('asdf','',{'asdf'})
test1('', ',', {''})
test1(',', ',', {'',''})
test1('a', ',', {'a'})
test1('a,b', ',', {'a','b'})
test1('a,b,', ',', {'a','b',''})
test1(',a,b', ',', {'','a','b'})
test1(',a,b,', ',', {'','a','b',''})
test1(',a,,b,', ',', {'','a','','b',''})
test1('a,,b', ',', {'a','','b'})
test1('asd  ,   fgh  ,;  qwe, rty.   ,jkl', '%s*[,.;]%s*', {'asd','fgh','','qwe','rty','','jkl'})
test1('Spam eggs spam spam and ham', 'spam', {'Spam eggs ',' ',' and ham'})
t = {} for s,n in glue.gsplit('a 12,b 15x,c 20', '%s*(%d*),') do t[#t+1]={s,n} end
test(t, {{'a','12'},{'b 15x',''},{'c 20',nil}})
--TODO: use case with () capture

test(glue.trim('  a  d '), 'a  d')

test(glue.escape'^{(.-)}$', '%^{%(%.%-%)}%$')
test(glue.escape'%\0%', '%%%z%%')

test(glue.collect(('abc'):gmatch('.')), {'a','b','c'})
test(glue.collect(2,ipairs{5,7,2}), {5,7,2})

local t0 = {a = 1, b = 2}
local t1 = glue.inherit({}, t0)
local t2 = glue.inherit({}, t1)
assert(t2.a == 1)
assert(t2.b == 2)
t0.b = 3
assert(t2.b == 3)
glue.inherit(t1)
assert(not t2.a)

local t = glue.autotable()
t.a.b.c = 'x'
assert(t.a.b.c == 'x')

glue.luapath('foo')
glue.cpath('bar')
glue.luapath('baz', 'after')
glue.cpath('zab', 'after')
local norm = function(s) return s:gsub('/', package.config:sub(1,1)) end
assert(package.path:match('^'..glue.escape(norm'foo/?.lua;')))
assert(package.cpath:match('^'..glue.escape(norm'bar/?.dll;')))
assert(package.path:match(glue.escape(norm'baz/?.lua;baz/?/init.lua')..'$'))
assert(package.cpath:match(glue.escape(norm'zab/?.dll')..'$'))

local M = {}
local x, y, z, p = 0, 0, 0, 0
glue.autoload(M, 'x', function() x = x + 1 end)
glue.autoload(M, 'y', function() y = y + 1 end)
glue.autoload(M, {z = function() z = z + 1 end, p = function() p = p + 1 end})
local _ = M.x, M.x, M.y, M.y, M.z, M.z, M.p, M.p
assert(x == 1)
assert(y == 1)
assert(z == 1)
assert(p == 1)

if jit then
	local ffi = require'ffi'
	local function malloc(bytes, ctype, size)
		local data = glue.malloc(ctype, size)
		assert(ffi.sizeof(data) == bytes)
		if size then
			assert(ffi.typeof(data) == ffi.typeof('$(&)[$]', ffi.typeof(ctype or 'char'), size))
		else
			assert(ffi.typeof(data) == ffi.typeof('$&', ffi.typeof(ctype or 'char')))
		end
		glue.free(data)
	end
	malloc(400, 'int32_t', 100)
	malloc(200, 'int16_t', 100)
	malloc(100, nil, 100)
	malloc(1)
	malloc(4, 'int32_t')
end

--list the namespace
for k,v in glue.sortedpairs(glue) do
	print(string.format('glue.%-20s %s', k, v))
end
