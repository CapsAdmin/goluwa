
--glue r7
--Written by Cosmin Apreutesei. Public domain.

local glue = {}

local select, pairs, tonumber, tostring, unpack, xpcall, assert, getmetatable, setmetatable, type, pcall =
	   select, pairs, tonumber, tostring, unpack, xpcall, assert, getmetatable, setmetatable, type, pcall
local sort, format, byte, char, min, max =
	table.sort, string.format, string.byte, string.char, math.min, math.max

--get t[k] and if not present, set t[k] = v0, which defaults to an empty table, and return that.
function glue.attr(t, k, v0)
	local v = t[k]
	if v == nil then
		if v0 == nil then
			v0 = {}
		end
		v = v0
		t[k] = v
	end
	return v
end

--reverse keys with values.
function glue.index(t)
	local dt={} for k,v in pairs(t) do dt[v]=k end
	return dt
end

--list of keys, optionally sorted.
function glue.keys(t, cmp)
	local dt={}
	for k in pairs(t) do
		dt[#dt+1]=k
	end
	if cmp == true then
		sort(dt)
	elseif cmp then
		sort(dt, cmp)
	end
	return dt
end

--update a table with the contents of other table(s).
function glue.update(dt,...)
	for i=1,select('#',...) do
		local t=select(i,...)
		if t ~= nil then
			for k,v in pairs(t) do dt[k]=v end
		end
	end
	return dt
end

--add the contents of other table(s) without overwrite.
function glue.merge(dt,...)
	for i=1,select('#',...) do
		local t=select(i,...)
		if t ~= nil then
			for k,v in pairs(t) do
				if dt[k] == nil then dt[k]=v end
			end
		end
	end
	return dt
end

--stateless pairs() that iterate elements in key order.
local keys = glue.keys
function glue.sortedpairs(t, cmp)
	local kt = keys(t, cmp or true)
	local i = 0
	return function()
		i = i + 1
		return kt[i], t[kt[i]]
	end
end

--extend a list with the elements of other lists.
function glue.extend(dt,...)
	for j=1,select('#',...) do
		local t=select(j,...)
		if t ~= nil then
			for i=1,#t do dt[#dt+1]=t[i] end
		end
	end
	return dt
end

--append non-nil arguments to a list.
function glue.append(dt,...)
	for i=1,select('#',...) do
		dt[#dt+1] = select(i,...)
	end
	return dt
end

local tinsert, tremove = table.insert, table.remove

--insert n elements at i, shifting elemens on the right of i (i inclusive) to the right.
local function insert(t, i, n)
	if n == 1 then --shift 1
		tinsert(t, i, t[i])
		return
	end
	for p = #t,i,-1 do --shift n
		t[p+n] = t[p]
	end
end

--remove n elements at i, shifting elements on the right of i (i inclusive) to the left.
local function remove(t, i, n)
	n = min(n, #t-i+1)
	if n == 1 then --shift 1
		tremove(t, i)
		return
	end
	for p=i+n,#t do --shift n
		t[p-n] = t[p]
	end
	for p=#t,#t-n+1,-1 do --clean tail
		t[p] = nil
	end
end

--shift all the elements to the right of i (i inclusive) to the left or further to the right.
function glue.shift(t, i, n)
	if n > 0 then
		insert(t, i, n)
	elseif n < 0 then
		remove(t, i, -n)
	end
	return t
end

--string submodule. has its own namespace so it can be merged with _G.string if wanted.
glue.string = {}

--split a string by a separator that can be a pattern or a plain string.
--return a stateless iterator for the pieces.
local function iterate_once(s, s1)
	return s1 == nil and s or nil
end
function glue.string.gsplit(s, sep, start, plain)
	start = start or 1
	plain = plain or false
	if not s:find(sep, start, plain) then
		return iterate_once, s
	end
	local done = false
	local function pass(i, j, ...)
		if i then
			local seg = s:sub(start, i - 1)
			start = j + 1
			return seg, ...
		else
			done = true
			return s:sub(start)
		end
	end
	return function()
		if done then return end
		if sep == '' then done = true return s end
		return pass(s:find(sep, start, plain))
	end
end

--string trim12 from lua wiki.
function glue.string.trim(s)
	local from = s:match('^%s*()')
	return from > #s and '' or s:match('.*%S', from)
end

--escape a string so that it can be taken literally inside a pattern.
local function format_ci_pat(c)
	return format('[%s%s]', c:lower(), c:upper())
end
function glue.string.escape(s, mode)
	s = s:gsub('%%','%%%%'):gsub('%z','%%z'):gsub('([%^%$%(%)%.%[%]%*%+%-%?])', '%%%1')
	if mode == '*i' then s = s:gsub('[%a]', format_ci_pat) end
	return s
end

--string to hex.
function glue.string.tohex(s, upper)
	if type(s) == 'number' then
		return format(upper and '%08.8X' or '%08.8x', s)
	end
	if upper then
		return (s:gsub('.', function(c)
		  return format('%02X', byte(c))
		end))
	else
		return (s:gsub('.', function(c)
		  return format('%02x', byte(c))
		end))
	end
end

--hex to string.
function glue.string.fromhex(s)
	return (s:gsub('..', function(cc)
	  return char(tonumber(cc, 16))
	end))
end

--publish the string submodule in the glue namespace.
glue.update(glue, glue.string)

--run an iterator and collect the n-th return value into a list.
local function select_at(i,...)
	return ...,select(i,...)
end
local function collect_at(i,f,s,v)
	local t = {}
	repeat
		v,t[#t+1] = select_at(i,f(s,v))
	until v == nil
	return t
end
local function collect_first(f,s,v)
	local t = {}
	repeat
		v = f(s,v); t[#t+1] = v
	until v == nil
	return t
end
function glue.collect(n,...)
	if type(n) == 'number' then
		return collect_at(n,...)
	else
		return collect_first(n,...)
	end
end

--no-op filter.
function glue.pass(...) return ... end

--set up dynamic inheritance by creating or updating a table's metatable.
function glue.inherit(t, parent)
	local meta = getmetatable(t)
	if meta then
		meta.__index = parent
	elseif parent ~= nil then
		setmetatable(t, {__index = parent})
	end
	return t
end

--set up a table so that missing keys are created automatically as autotables.
local autotable
local auto_meta = {
	__index = function(t, k)
		t[k] = autotable()
		return t[k]
	end,
}
function autotable(t)
	t = t or {}
	local meta = getmetatable(t)
	if meta then
		assert(not meta.__index or meta.__index == auto_meta.__index,
			'__index already set')
		meta.__index = auto_meta.__index
	else
		setmetatable(t, auto_meta)
	end
	return t
end
glue.autotable = autotable

--check if a file exists and it's available for reading in binary mode.
function glue.fileexists(name)
	local f = io.open(name, 'rb')
	if f then f:close() end
	return f ~= nil and name or nil
end

--read a file into a string (in binary mode by default).
function glue.readfile(name, mode)
	local f, err = io.open(name, mode=='t' and 'r' or 'rb')
	if not f then return nil, err end
	local s = f:read'*a'
	f:close()
	return s
end

--write a string to a file (in binary mode by default).
function glue.writefile(name, s, mode)
	local f = assert(io.open(name, mode=='t' and 'w' or 'wb'))
	f:write(s)
	f:close()
end

--assert() with string formatting (this should be a Lua built-in).
function glue.assert(v,err,...)
	if v then return v,err,... end
	err = err or 'assertion failed!'
	if select('#',...) > 0 then err = format(err,...) end
	error(err, 2)
end

--transform the result of a pcall() to the Lua convention for functions that
--can return an error, i.e. return nil,err for failure, and true if no result.
function glue.unprotect(ok, result, ...)
	if not ok then return nil, result, ... end
	if result == nil then result = true end --to distinguish from error.
	return result, ...
end

--pcall with traceback. LuaJIT and Lua 5.2 only, unfortunately.
local function pcall_error(e)
	return tostring(e) .. '\n' .. debug.traceback()
end
function glue.pcall(f, ...)
	return xpcall(f, pcall_error, ...)
end

--pcall with finally and except "clauses":
--		local ret,err = fpcall(function(finally, except)
--			local foo = getfoo()
--			finally(function() foo:free() end)
--			except(function(err) io.stderr:write(err, '\n') end)
--		emd)
--NOTE: a bit bloated at 2 tables and 4 closures. Can we reduce the overhead?
local function fpcall(f,...)
	local fint, errt = {}, {}
	local function finally(f) fint[#fint+1] = f end
	local function onerror(f) errt[#errt+1] = f end
	local function err(e)
		for i=#errt,1,-1 do errt[i](e) end
		for i=#fint,1,-1 do fint[i]() end
		return tostring(e) .. '\n' .. debug.traceback()
	end
	local function pass(ok,...)
		if ok then
			for i=#fint,1,-1 do fint[i]() end
		end
		return ok,...
	end
	return pass(xpcall(f, err, finally, onerror, ...))
end

local unprotect = glue.unprotect
function glue.fpcall(...)
	return unprotect(fpcall(...))
end

--fcall is like fpcall() but without the protection (i.e. raises errors).
local function assert_fpcall(ok, ...)
	if not ok then error(..., 2) end
	return ...
end
function glue.fcall(...)
	return assert_fpcall(fpcall(...))
end

--declare that certain keys of a module table are implemented in specific submodules.
--eg. glue.autoload(foo, {bar = 'foo.bar'}); then accessing foo.bar triggers require'foo.bar'.
function glue.autoload(t, k, v)
	local mt = getmetatable(t) or {}
	if not mt.__autoload then
		if mt.__index then
			error('__index already assigned for something else')
		end
		local submodules = {}
		mt.__autoload = submodules
		mt.__index = function(t, k)
			if submodules[k] then
				if type(submodules[k]) == 'string' then
					require(submodules[k]) --module
				else
					submodules[k](k) --custom loader
				end
				submodules[k] = nil --prevent loading twice
			end
			return rawget(t, k)
		end
		setmetatable(t, mt)
	end
	if type(k) == 'table' then
		glue.update(mt.__autoload, k) --multiple key -> module associations.
	else
		mt.__autoload[k] = v --single key -> module association.
	end
	return t
end

--portable way to get script's directory, based on arg[0], as long as
--pwd() doesn't change because the path in arg[0] is relative to pwd().
local dir = rawget(_G, 'arg') and arg[0] and arg[0]:gsub('[/\\]?[^/\\]+$', '') or '' --remove file name
glue.bin = dir == '' and '.' or dir

--portable way to add more paths to package.path, at any place in the list.
--negative indices count from the end of the list like string.sub(). index 'after' means 0.
function glue.luapath(path, index, ext)
	ext = ext or 'lua'
	index = index or 1
	local psep = package.config:sub(1,1) --'/'
	local tsep = package.config:sub(3,3) --';'
	local wild = package.config:sub(5,5) --'?'
	local paths = glue.collect(glue.gsplit(package.path, tsep, nil, true))
	path = path:gsub('[/\\]', psep) --normalize slashes
	if index == 'after' then index = 0 end
	if index < 1 then index = #paths + 1 + index end
	table.insert(paths, index,  path .. psep .. wild .. psep .. 'init.' .. ext)
	table.insert(paths, index,  path .. psep .. wild .. '.' .. ext)
	package.path = table.concat(paths, tsep)
end

--portable way to add more paths to package.cpath, at any place in the list.
--negative indices count from the end of the list like string.sub(). index 'after' means 0.
function glue.cpath(path, index)
	index = index or 1
	local psep = package.config:sub(1,1) --'/'
	local tsep = package.config:sub(3,3) --';'
	local wild = package.config:sub(5,5) --'?'
	local ext = package.cpath:match('%.([%a]+)%'..tsep..'?') --dll | so | dylib
	local paths = glue.collect(glue.gsplit(package.cpath, tsep, nil, true))
	path = path:gsub('[/\\]', psep) --normalize slashes
	if index == 'after' then index = 0 end
	if index < 1 then index = #paths + 1 + index end
	table.insert(paths, index,  path .. psep .. wild .. '.' .. ext)
	package.cpath = table.concat(paths, tsep)
end

if jit then

	local ffi = require'ffi'

	ffi.cdef[[
	void* malloc (size_t size);
	void  free   (void*);
	]]

	function glue.malloc(ctype, size)
		if type(ctype) == 'number' then
			ctype, size = 'char', ctype
		end
		ctype = ffi.typeof(ctype or 'char')
		if size then
			ctype = ffi.typeof('$(&)[$]', ctype, size)
		else
			ctype = ffi.typeof('$&', ctype)
		end
		local bytes = ffi.sizeof(ctype)
		local data = ffi.C.malloc(bytes)
		assert(data ~= nil, 'out of memory')
		data = ffi.cast(ctype, data)
		ffi.gc(data, glue.free)
		return data
	end

	function glue.free(cdata)
		ffi.gc(cdata, nil)
		ffi.C.free(ffi.cast('void*', cdata))
	end

end

if not ... then require'glue_test' end

return glue
