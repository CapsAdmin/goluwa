local _M = {}
local ffi = require 'ffi'

-- add compiler predefinition
function _M.add_builtin_defs(state)
	local p = io.popen('echo | gcc -E -dM -')
	local predefs = p:read('*a')
	state:cdef(predefs)
	p:close()
	-- os dependent tweak.
	if ffi.os == 'OSX' then
		-- luajit cannot parse objective-C code correctly
		-- e.g.  int      atexit_b(void (^)(void)) ;
		state:undef({"__BLOCKS__"})
	end
end
function _M.clear_builtin_defs(state)
	local p = io.popen('echo | gcc -E -dM -')
	local undefs = {}
	while true do 
		local line = p:read('*l')
		if line then
			local tmp,cnt = line:gsub('^#define%s+([_%w]+)%s+.*', '%1')
			if cnt > 0 then
				table.insert(undefs, tmp)
			end
		else
			break
		end
	end
	state:undef(undefs)
	p:close()
end

-- add compiler built in header search path
function _M.add_builtin_paths(state)
	local p = io.popen('echo | gcc -xc -v - 2>&1 | cat')	
	local search_path_start
	while true do
		-- TODO : parsing unstructured compiler output.
		-- that is not stable way to get search paths.
		-- but I cannot find better way than this.
		local line = p:read('*l')
		if not line then break end
		if search_path_start then
			local tmp,cnt = line:gsub('^%s+(.*)', '%1')
			if cnt > 0 then
				-- remove unnecessary output of osx clang.
				tmp = tmp:gsub(' %(framework directory%)', '')
				-- print('builtin_paths:'..tmp)
				state:path(tmp, true)
			else
				break
			end
		elseif line:find('#include <...>') then
			search_path_start = true
		end
	end
end

return _M