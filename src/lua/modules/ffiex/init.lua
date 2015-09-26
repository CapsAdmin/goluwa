local lcpp = require 'ffiex.lcpp'
local ffi = require 'ffi'

-----------------------
-- search header file
-----------------------
local originalCompileFile = lcpp.compileFile
local lastTryPath
local currentState

local function search_header_file(filename, predefines, nxt, _local, no_throw)
	lastTryPath = lastTryPath or predefines.__FILE__:gsub('^(.*/)[^/]+$', '%1')
	if nxt then
		local process
		for _,path in ipairs(currentState.searchPath) do
			if process then
				-- print("search_header_file:", filename, path, lastTryPath)
				local trypath = (path .. filename)
				local ok, r = pcall(io.open, trypath, 'r')
				if ok and r then
					-- print('return trypath:'..trypath)
					r:close()
					return trypath, trypath:gsub('^(.*/)[^/]+$', '%1')
				end
			elseif path == lastTryPath then
				process = true
			end
		end
	else
		local found
		if _local then
			local trypath = (lastTryPath .. filename)
			local ok, r = pcall(io.open, trypath, 'r')
			if ok and r then
				r:close()
				return trypath, lastTryPath
			end
		end
		if not found then
			for _,path in ipairs(currentState.searchPath) do
--print('try:'..path)
				local trypath = (path .. filename)
				local ok, r = pcall(io.open, trypath, 'r')
				if ok and r then
					r:close()
					return trypath, trypath:gsub('^(.*/)[^/]+$', '%1')
				end
			end
		end
	end
	--> OMG header not found...
	if not no_throw then
		local paths = ""
		for _,path in ipairs(currentState.searchPath) do
			paths = paths .. "\n" .. path
		end
		error(filename .. ' not found in:' .. paths .. "\n at \n" .. debug.traceback())
	end
	return nil
end

lcpp.compileFile = function (filename, predefines, macro_sources, nxt, _local)
	filename, lastTryPath = search_header_file(filename, predefines, nxt, _local)
	if ffi.__DEBUG_CDEF__ then
		local out = {originalCompileFile(filename, predefines, macro_sources, nxt)}
 print('include:'..filename)--.."=>"..out[1])
 		return unpack(out)
 	end
	return originalCompileFile(filename, predefines, macro_sources, nxt)
end

-----------------------
-- built in macro defs
-----------------------
local header_name = "__has_include_next%(%s*[\"<]+(.*)[\">]+%s*%)"
local function has_include_next(decl)
	local file = decl:match(header_name)
	-- print("has_include_next:", file, decl)
	return search_header_file(file, currentState.lcpp_defs, true, false, true) ~= nil and "1" or "0"
end
local header_name2 = "__has_include%(%s*[\"<]+(.*)[\">]+%s*%)"
local function has_include(decl)
	local file = decl:match(header_name2)
	-- print("has_include_next:", file, decl)
	return search_header_file(file, currentState.lcpp_defs, false, false, true) ~= nil and "1" or "0"
end
local function __asm(exp)
	return exp:gsub("__asm_*%s*%b()", "")
end



-----------------------
-- utils
-----------------------
local function replace_table(src, rep)
	for k,v in pairs(src) do
		src[k] = rep[k]
	end
	for k,v in pairs(rep) do
		src[k] = rep[k]
	end
end

local function macro_to_lua_func(st, macro_source)
	return function (...)
		local args = {...}
		local state = st:expr_processor()
		local src = macro_source:gsub("%$(%d+)", function (m) return args[tonumber(m)] end)
		local val = state:parseExpr(src)
		-- print(val, src)
		if type(val) ~= 'string' then
			return val
		else -- more parse with lua lexer
			local f, err = loadstring("return "..val)
			if not f then error(err) end
			return f()
		end
	end
end

-- TODO : merged with ffi.parser
local function generate_cdefs(state, code)
	-- matching extern%s+[symbol]%s+[symbol]%b()
	local current = 0
	local decl = ""
	repeat
		local _, offset = string.find(code, '\n', current+1, true)
		local line = code:sub(current+1, offset):gsub('%b{}', '')
		-- print('line = '..line)
		-- matching simple function declaration (e.g. void foo(t1 a1, t2 a2))
		local _, count = line:gsub('^%s*([_%a][_%w]*%s+[_%a][_%w]*%b())%s*', function (s)
			-- print(s)
			decl = (decl .. "extern " .. s .. ";\n")
		end)
		-- matching function declaration with access specifier
		-- (e.g. extern void foo(t1 a1, t2 a2), static void bar())
		-- and not export function declaration contains 'static' specifier
		if count <= 0 then
			line:gsub('(.*)%s+([_%a][_%w]*%s+[_%a][_%w]*%b())%s*', function (s1, s2)
				-- print(s1 .. "|" .. s2)
				if not s1:find('static') then
					decl = (decl .. "extern " .. s2 .. ";\n")
				end
			end)
		end
		current = offset
	until not current
	-- print('code = ['..code..']')
	if #decl > 0 then
		-- print('decl = [' .. decl..']')
		state:cdef(decl)
	end
end
local function parse_stack()
	local stack,current = debug.traceback(),0
	local ret = {}
	-- parse output of debug.traceback()
	-- TODO : need to track the spec change of debug.traceback()
	repeat
		local _, offset = string.find(stack, '\n', current+1, true)
		local line = stack:sub(current+1, offset)
		local res, count = line:gsub('%s*([^%s:]+):([%d]+).*', function (s1, s2)
			table.insert(ret, {file = s1, line = s2})
		end)
		current = offset
	until not current
	return ret
end
local function get_decl_file(name, src, depth)
	if not src then -- means external .c file specified with 'name'
		return name
	end
	local traces = parse_stack()
	depth = (depth or 1)
	for _,tr in ipairs(traces) do
		if not tr.file:find('ffiex/init.lua') then
			depth = (depth - 1)
		end
		if depth <= 0 then
			return tr.file
		end
	end
	return nil
end



-----------------------
-- ffi state
-----------------------
local parser_lib
local ffi_state = {}
function ffi_state.new(try_init_path)
	local r = setmetatable({}, {__index = ffi_state})
	r:init(try_init_path)
	return r
end
local defs_mt = {
	__index = function (t, k)
		local st = t["#state"]
		local def = st.lcpp_defs[k]
		if type(def) == 'number' then
			local ok, r = pcall(loadstring, "return " .. def)
			if ok and r then
				rawset(t, k, r())
				return rawget(t, k)
			end
		elseif type(def) == 'string' then
			local state = st:expr_processor()
			local expr = state:parseExpr(def)
			rawset(t, k, expr)
			return rawget(t, k)
		elseif type(def) == 'function' then
			def = st.lcpp_macro_sources[k]
			if not def then return nil end
			def = macro_to_lua_func(st, def)
		end
		rawset(t, k, def)
		return def
	end
}
function ffi_state:expr_processor()
	if not self.processor then
		self.processor = lcpp.init('', {}, {})
	end
	self.processor.defines = self.lcpp_defs
	self.processor.macro_sources = self.lcpp_macro_sources
	return self.processor
end
function ffi_state:init(try_init_path)
	self.defs = setmetatable({ ["#state"] = self }, defs_mt)
	self.searchPath = {"./"}
	self.systemSearchPath = {}
	self.localSearchPath = {}

	-- add built in macro here
	self.lcpp_defs = {
		["__has_include"] = has_include,
		["__has_include_next"] = has_include_next,
		-- i don't know the reason but OSX __asm alias not works for luajit symbol search
		["__asm"] = __asm, -- just return empty string TODO : investigate reason.
	}

	-- if gcc is available, try using it for initial builder.
	if try_init_path then
		local ok, rv = pcall(os.execute, "gcc -v 2>/dev/null")
		if ok then
			local has_gcc = (rv == 0)
			ok, rv = pcall(require, 'ffiex.builder.gcc')
			if ok and rv then
				local builder = rv.new()
				if has_gcc then
					builder:init(self)
					self.builder = builder
					self:copt({ cc = "gcc" })
				else
					ok, rv = pcall(builder.init, builder, self)
				end
			end
		end
		if not ok then
			print('gcc available but fail to initialize gcc builder:'..rv)
		end
	end
end
-- importer lib
local importer_lib = {}
function importer_lib.new(state, sym)
	return setmetatable({state = state, sym = sym}, { __index = importer_lib})
end
function importer_lib:from(code)
	local tree = self.state:parse(code)

	return ffi.native_cdef_with_guard(tree, self.sym)
end

function ffi_state:import(sym)
	return importer_lib.new(self, sym)
end
function ffi_state:parse(decl, tmptree)
	if not parser_lib then
		parser_lib = require 'ffiex.parser'
	end
	currentState = self
	local output, state = lcpp.compile(decl, self.lcpp_defs, self.lcpp_macro_sources)
	--print('output='..output)
	local has_ssize_t = output:match('ssize_t;')
	self.lcpp_defs = state.defines
	self.lcpp_macro_sources = state.macro_sources
	if tmptree and self.tree then
		tmptree = parser_lib.parse(nil, output)
		for _,sym in pairs(tmptree[1]) do
			table.insert(self.tree[1], sym)
		end
		for k,v in pairs(tmptree) do
			if not self.tree[k] then self.tree[k] = tmptree[k] end
		end
		return tmptree, output
	else
		self.tree = parser_lib.parse(self.tree, output)
		return self.tree, output
	end
end
function ffi_state:cdef(decl)
	local tmp = self:parse(decl, true)
	ffi.native_cdef_with_guard(tmp, nil)
end
function ffi_state:define(defs)
	for k,v in pairs(defs) do
		self.lcpp_defs[k] = v
	end
end
function ffi_state:undef(defs)
	for i,def in ipairs(defs) do
		self.lcpp_defs[def] = nil
	end
end
function ffi_state:path(path, system)
	if path[#path] ~= '/' then
		path = (path .. '/')
	end
	table.insert(self.searchPath, path)
	if system then
		table.insert(self.systemSearchPath, path)
	else
		-- print("add localSerchPath:" .. path)
		table.insert(self.localSearchPath, path)
	end
end
function ffi_state:clear_paths(system)
	local tmp = {}
	local removed = system and self.systemSearchPath or self.localSearchPath
	for _,s in ipairs(self.searchPath) do
		local found
		for _,t in ipairs(removed) do
			if s == t then
				found = true
			end
		end
		if not found then
			table.insert(tmp, s)
		end
	end
	replace_table(self.searchPath, tmp)
	if system then
		replace_table(self.systemSearchPath, {})
	else
		replace_table(self.localSearchPath, {})
	end
end
function ffi_state:search(path, file, add)
	local p = io.popen(('find %s -name %s'):format(path, file), 'r')
	if not p then return nil end
	local line
	while true do
		line = p:read('*l')
		if not line then
			break -- eof
		else
			-- if matches find:, log of find itself.
			if (not line:match('^find:')) and line:match((file .. '$')) then
				break
			end
		end
	end
	if line and add then
		--print('find path and add to header path:' .. line .. "|" .. line:gsub('^(.*/)[^/]+$', '%1'))
		self:path(line:gsub('^(.*/)[^/]+$', '%1'))
	end
	return line
end
function ffi_state:clear_copt()
	local builder = self.builder
	if not builder or not builder:get_option() then
		return
	end
	local undefs = {}
	if builder:get_option().define then
		for k,v in pairs(builder:get_option().define) do
			table.insert(undefs, type(k) == 'number' and v or k)
		end
	end
	if builder:get_option().extra then
		for _,o in ipairs(builder:get_option().extra) do
			local def,val = o:match("-D([_%w]+)=?(.*)")
			if def then table.insert(undefs, def) end
 		end
 	end
 	self:undef(undefs)
 	if builder then
		builder:exit(self)
	end
	self.builder = nil
end
function ffi_state:copt(opts)
	if opts[1] and (not opts.extra) then
		opts = { extra = opts }
	end
	self:clear_copt()
	local defs = {}
	local builder
	if opts.cc then
		if type(opts.cc) == 'string' then
			builder = require ('ffiex.builder.'..opts.cc).new()
		elseif type(opts.cc) == 'table' then
			builder = opts.cc
		else
			error("invalid cc:" .. type(opts.cc))
		end
		if builder then
			builder:init(self)
			self.builder = builder
		end
	else
		error("ffi.copt: opts.cc must be specified")
	end
	if opts.define then
		for k,v in pairs(opts.define) do
			if type(k) == "number" then
				defs[v] = ""
			else
				defs[k] = v
			end
		end
	end
	if opts.extra then
		for _,o in ipairs(opts.extra) do
			local def,val = o:match("-D([_%w]+)=?(.*)")
			if def then
				defs[def] = val
			end
 		end
	end
	self:define(defs)
	if not opts.path then
		opts.path = {}
	end
	if type(opts.path.include) ~= 'table' or #opts.path.include <= 0 then
		opts.path.include = self.localSearchPath
	end
	if type(opts.path.sys_include) ~= 'table' or #opts.path.sys_include <= 0 then
		opts.path.sys_include = self.systemSearchPath
	end
	if not opts.cache_callback then
		opts.cache_callback = function (name, src, search)
		end
	end
	builder:option(opts)
end
-- compiler object (tcc/gcc is natively supported)
function ffi_state:build(name, code)
	-- load source code
	if not code then
		local f = io.open(name, 'r')
		code = f:read('*a')
		f:close()
	end
	-- dummy preprocess to inject macro definition for external use
	self:cdef(code)
	-- generate cdefs from source code
	generate_cdefs(self, code)
	return self.builder:build(code)
end
function ffi_state:csrc(name, src, opts)
	if opts then
		self:copt(opts)
	end
	local builder = self.builder
	assert(builder, "builder not specified. please set opts.cc = 'tcc'/'gcc'/your customized cc table")
	local ext
	local path = builder:get_option().cache_callback(name, src, get_decl_file(name, src), true)
	if not path then
		path,ext = self:build(name, src)
	end
	if path then
		local ok, lib = pcall(ffi.load, path)
		if ok and lib then
			builder:get_option().cache_callback(name, src, get_decl_file(name, src), false)
			-- os.remove(path)
			return lib,ext
		else
			-- os.remove(path)
			return nil,lib
		end
	else
		return nil,ext
	end
end
function ffi_state:load(...)
	ffi.load(...)
end
function ffi_state:src_of(symbol, recursive)
	symbol = parser_lib.name(self.tree, symbol)
	return recursive and
		parser_lib.inject(self.tree, {symbol}) or
		assert(self.tree[symbol], "no such symbol:"..symbol).cdef
end



-----------------------
-- ffiex module
-----------------------
-- already imported symbols (and guard them from dupe)
ffi.imported_csymbols = {}
function ffi.native_cdef_with_guard(tree, symbols_or_ppcode)
	local injected = parser_lib.inject(tree, symbols_or_ppcode, ffi.imported_csymbols)
	if ffi.__DEBUG_CDEF__ then
		print('injected source:[['..injected..']]')
		local f = io.open('./tmp.txt', 'w')
		f:write(injected)
		f:close()
	end
	ffi.lcpp_cdef_backup(injected)
	return injected
end

-- wrappers of ffi_state object.
local main_ffi_state = ffi_state.new(true)
ffi.main_ffi_state = main_ffi_state
function ffi.path(path, system)
	return main_ffi_state:path(path, system)
end
function ffi.clear_paths(system)
	return main_ffi_state:clear_paths(system)
end
function ffi.search(path, file, add)
	return main_ffi_state:search(path, file, add)
end
function ffi.cdef(decl)
	return main_ffi_state:cdef(decl)
end
function ffi.define(defs)
	return main_ffi_state:define(defs)
end
function ffi.undef(defs)
	return main_ffi_state:undef(defs)
end
ffi.defs = main_ffi_state.defs
function ffi.clear_copt()
	return main_ffi_state:clear_copt()
end
function ffi.copt(opts)
	return main_ffi_state:copt(opts)
end
function ffi.csrc(name, src, opts)
	return main_ffi_state:csrc(name, src, opts)
end
function ffi.import(symbols)
	return main_ffi_state:import(symbols)
end
function ffi.newstate()
	return ffi_state.new()
end
function ffi.init_cdef_cache()
	(require 'ffiex.util').create_builtin_config_cache()
end
function ffi.clear_cdef_cache()
	(require 'ffiex.util').clear_builtin_config_cache()
end

return ffi
