
--proc/windows/wmapp: user-defined (WM_APP+N) messages
--Written by Cosmin Apreutesei. Public Domain.

--this module is loaded by `winapi.window` module.
--WM_APP messages are shared resources. this module keeps track of them
--and allows you to acquire and release them as needed.
setfenv(1, require'winapi')

local codes = {} --sparse array of codes
local min_code = WM_APP + 1
local max_code = min_code - 1 --start with no slots

local function add_message()
	--scan array for gaps.
	for code = min_code, max_code do
		if not codes[code] then
			codes[code] = true
			return code
		end
	end
	--no gaps, grow array.
	max_code = max_code + 1
	codes[max_code] = true
	return max_code
end

local function remove_message(code)
	assert(code >= min_code and code <= max_code) --not an acquired code
	codes[code] = nil
	--released the last code: shrink array.
	if code == max_code then
		max_code = max_code - 1
	end
end

function register_message(name)
	local code = add_message()
	if name then
		WM_NAMES[code] = name
		rawset(_M, name, code)
	end
	return code
end

local function unregister_message(code)
	local name
	if type(code) == 'string' then
		name, code = code, rawget(_M, code)
	else
		name, code = WM_NAMES[code], code
	end
	remove_message(code)
	if name then
		WM_NAMES[code] = nil
		rawset(_M, name, nil)
	end
end

--usage:
--WM_FOO = register_message'WM_FOO'
--unregister_message(WM_FOO)
