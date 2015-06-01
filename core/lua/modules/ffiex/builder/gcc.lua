local util = require 'ffiex.util'
local cc = {}
local function error_callback(self, msg)
	if self.error then
		self.error = (self.error .. "\n" .. msg)
	else
		self.error = msg
	end
end
local function clear_option(self)
	self.cmdopts = nil
end
--[[
	options = {
		path = {
			include = { path1, path2, ... },
			sys_include = { syspath1, syspath2, ... },
			lib = { libpath1, libpath2, ... }
		},
		lib = { libname1, libname2, ... },
		define = { booldef1, booldef2, ... def1 = val1, def2 = val2 }
	}
]]
local function apply_option(self)
	if not self.cmdopts then
		local opts = self.opts
		local cmdopts = table.concat({"-fPIC", "-O2"}, " ")
		if type(opts.extra) == 'table' then
			cmdopts = (cmdopts .. " " .. table.concat(opts.extra, " "))
		end
		if type(opts.path.include) == 'table' and #(opts.path.include) > 0 then
			cmdopts = (cmdopts .. " -I" .. table.concat(opts.path.include, " -I"))
		end
		if type(opts.path.lib) == 'table' and #(opts.path.lib) > 0 then
			cmdopts = (cmdopts .. " -L" .. table.concat(opts.path.lib, " -L"))
		end
		if type(opts.lib) == 'table' and #(opts.lib) > 0 then
			cmdopts = (cmdopts .. " -l" .. table.concat(opts.lib, " -l"))
		end
		if type(opts.define) == 'table' then
			for k,v in pairs(opts.define) do
				if type(k) == "number" then
					cmdopts = (cmdopts .. " -D" .. v)
				else
					cmdopts = (cmdopts .. " -D" .. k .. "=" .. v)
				end
			end
		end
		self.cmdopts = cmdopts
	end
	return self.cmdopts
end

-- define method
local builder = {}
function builder.new()
	return setmetatable({}, {__index = cc})
end
function cc:init(state)
	util.add_builtin_defs(state)
	util.add_builtin_paths(state)
end
function cc:exit(state)
	state:clear_paths(true)
	util.clear_builtin_defs(state)
end
function cc:build(code)
	local opts = apply_option(self)
	local obj = os.tmpname()
	-- compile .so
	--[=[print(([[gcc -shared -xc - -o %s %s <<SRC
SRC]]):format(obj, opts, code))]=]

	local ok, r = pcall(os.execute, ([[gcc -shared -xc - -o %s %s <<SRC
%s
SRC]]):format(obj, opts, code))
	local ret, err
	if ok then
		if r ~= 0 then
			ret, err = nil, r
		else
			ret, err = obj, nil
		end
	else
		ret, err = nil, r
	end
	if err then
		error_callback(self, err)
	end
	return ret, err
end
function cc:option(opts)
	clear_option(self)
	self.opts = opts
end
function cc:get_option()
	return self.opts
end

return builder
