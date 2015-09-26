local ffi = require 'ffiex.init'
local lib

-- initialize cc
local cc
local function error_callback(self, msg)
	msg = ffi.string(msg)
	-- print(msg)
	if self.error then
		self.error = (self.error .. "\n" .. msg)
	else
		self.error = msg
	end
end
local function new_tcc()
	if not lib then
		-- import libtcc
		ffi.cdef [[
//libtcc define following macro on runtime to adjust target platform
//it should be matched with luaJIT's. so make reverse definition.
#if !defined(__SIZE_TYPE__)
#define __SIZE_TYPE__ size_t
#endif
#if !defined(__PTRDIFF_TYPE__)
#define __PTRDIFF_TYPE__ ptrdiff_t
#endif
#if !defined(__WINT_TYPE__)
#define __WINT_TYPE__ wchar_t
#endif
#if !defined(__WCHAR_TYPE__)
#define __WCHAR_TYPE__ wchar_t
#endif
			#include "libtcc.h"
		]]
		lib = ffi.load("tcc")
	end
	local state = lib.tcc_new()
	lib.tcc_set_options(state, "-nostdlib")
	lib.tcc_set_output_type(state, ffi.defs.TCC_OUTPUT_DLL)
	lib.tcc_set_error_func(state, nil, function (opq, msg)
		error_callback(cc, msg)
	end)
	return state
end
local function clear_option(self)
	if self.state then
		lib.tcc_delete(self.state)
	end
	self.state = new_tcc()
	self.opts = nil
	self.option_applied = nil
	self.build_once = nil
end
--[[
	options = {
		path = {
			include = { path1, path2, ... },
			sys_include = { syspath1, syspath2, ... },
			lib = { libpath1, libpath2, ... }
		},
		lib = { libname1, libname2, ... },
		extra = { opt1, opt2, ... },
		define = { booldef1, booldef2, ... def1 = val1, def2 = val2 }
	}
]]
local function apply_option(self)
	local opts = self.opts
	if opts.path then
		if type(opts.path.include) == 'table' then
			for _,p in ipairs(opts.path.include) do
				lib.tcc_add_include_path(self.state, p)
			end
		end
		if type(opts.path.sys_include) == 'table' then
			for _,p in ipairs(opts.path.sys_include) do
				lib.tcc_add_sysinclude_path(self.state, p)
			end
		end
		if type(opts.path.lib) == 'table' then
			for _,p in ipairs(opts.path.lib) do
				lib.tcc_add_library_path(self.state, p)
			end
		end
	end
	if type(opts.lib) == 'table' then
		for _,l in ipairs(opts.lib) do
			lib.tcc_add_library(self.state, l)
		end
	end
	if type(opts.define) == 'table' then
		for k,v in pairs(opts.define) do
			if type(k) == 'number' then
				lib.tcc_define_symbol(self.state, v, "")
			else
				lib.tcc_define_symbol(self.state, k, v)
			end
		end
	end
	if type(opts.extra) == 'table' then
		lib.tcc_set_options(self.state, table.concat(opts.extra, " "))
	end
end
cc = {}

-- define method
local builder = {}
function builder.new()
	return setmetatable({}, {__index = cc})
end
function cc:init(state)
end
function cc:exit(state)
end
function cc:build(code)
	if self.build_once then
		if self.state then
			lib.tcc_delete(self.state)
		end
		self.state = new_tcc()
		self.build_once = nil
		self.option_applied = nil
	end
	if not self.option_applied then
		self.option_applied = true
		apply_option(self)
	end
	if lib.tcc_compile_string(self.state, code) < 0 then
		self.build_once = true
		return nil, self.error
	end
	local tmp = os.tmpname()
	if lib.tcc_output_file(self.state, tmp) < 0 then
		self.build_once = true
		return nil, "output error:to:"..tmp
	end
	self.build_once = true
	return tmp, nil
end
function cc:option(opts)
	clear_option(self)
	self.opts = opts
end
function cc:get_option()
	return self.opts
end

return builder
