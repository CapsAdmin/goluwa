local _M = {}
local ffi = require 'ffi'

if ffi.os == "Windows" then
	_M.PATH_SEPS = "¥"
else
	_M.PATH_SEPS = "/"
end
function _M.file_exists(file)
	if ffi.os ~= 'Windows' then
		return io.popen(([[if [ -e '%s' ]; then echo '1'; else echo '0'; fi]]):format(file)):read(1) == '1'
	else
		error('unsupported OS')
	end
end
function _M.current_path()
	local data = debug.getinfo(1)
	return data.source:match('@(.+)'.._M.PATH_SEPS..'.+$')
end
local cache_dir = _M.current_path().._M.PATH_SEPS..'cache'
local version_file = cache_dir.._M.PATH_SEPS..'version'
local builtin_paths = cache_dir.._M.PATH_SEPS..'builtin_paths'
local builtin_defs = cache_dir.._M.PATH_SEPS..'builtin_defs'
_M.path = {
	version_file = version_file,
	builtin_paths = builtin_paths,
	builtin_defs = builtin_defs,
}

-- gcc version cache
function _M.gcc_version()
	local r = io.popen('which gcc'):read('*a')
	return #r > 0 and io.popen('gcc -v 2>&1'):read('*a') or nil
end
local function create_version_file_cache(v)
	v = v or _M.gcc_version()
	assert(v, "gcc need to be installed to create cache")
	local f = io.open(version_file, 'w')
	f:write(v)
	f:close()
end

-- add compiler predefinition
local builtin_defs_cmd = 'echo | gcc -E -dM -'
local function create_builtin_defs_cache()
	assert(_M.gcc_version(), "gcc need to be installed to create cache")
	os.execute(builtin_defs_cmd..'>'..builtin_defs)
end
function _M.builtin_defs()
	if _M.file_exists(version_file) then
		local v = _M.gcc_version()
		if v and (v ~= io.popen(('cat %s'):format(version_file)):read('*a')) then
			create_builtin_defs_cache()
			create_version_file_cache(v)
		end
		return io.popen(([[cat %s]]):format(builtin_defs))
	end
	return io.popen(builtin_defs_cmd)
end
function _M.add_builtin_defs(state)
	local p = _M.builtin_defs()
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
	local p = io.popen(builtin_defs_cmd)
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
local builtin_paths_cmd = 'echo | gcc -xc -v - 2>&1 | cat'
function create_builtin_paths_cache()
	assert(_M.gcc_version(), "gcc need to be installed to create cache")
	os.execute(builtin_paths_cmd..'>'..builtin_paths)
end
function _M.builtin_paths()
	if _M.file_exists(version_file) then
		local v = _M.gcc_version()
		if v and (v ~= io.popen(('cat %s'):format(version_file)):read('*a')) then
			create_builtin_paths_cache()
			create_version_file_cache(v)
		end
		return io.popen(([[cat %s]]):format(builtin_paths))
	end
	return io.popen(builtin_paths_cmd)
end
function _M.add_builtin_paths(state)
	local p = _M.builtin_paths()
	local search_path_start
	while true do
		-- TODO : parsing unstructured compiler output.
		-- that is not stable way to get search paths.
		-- but I cannot find better way than this.
		local line = p:read('*l')
		if not line then break end
		-- print('line = ', line)
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
function _M.create_builtin_config_cache()
	create_version_file_cache()
	create_builtin_paths_cache()
	create_builtin_defs_cache()
	os.execute('chmod -R 766 '..cache_dir)
end
function _M.clear_builtin_config_cache()
	os.execute('rm '..cache_dir.._M.PATH_SEPS.."*")
end

return _M
