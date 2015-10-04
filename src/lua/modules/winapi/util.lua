
--binding/util: binding utilities
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi.namespace')
require'winapi.types'

--ffi, bit, C ----------------------------------------------------------------

ffi = require'ffi'
bit = require'bit'
C = ffi.C

assert(ffi.abi'win', 'platform not Windows')

--glue -----------------------------------------------------------------------

glue = require'glue'

assert       = glue.assert
extend       = glue.extend
fcall        = glue.fcall
index        = glue.index
inherit      = glue.inherit
merge        = glue.merge
pass         = glue.pass
pcall        = glue.pcall
trim         = glue.trim
update       = glue.update

--error reporting -------------------------------------------------------------

ffi.cdef[[
DWORD GetLastError(void);

void SetLastError(DWORD dwErrCode);

DWORD FormatMessageA(
			DWORD dwFlags,
	      LPCVOID lpSource,
			DWORD dwMessageId,
			DWORD dwLanguageId,
			LPSTR lpBuffer,
			DWORD nSize,
		   va_list *Arguments
	 );
]]

GetLastError = C.GetLastError
SetLastError = C.SetLastError

FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000

--get the error message from GetLastError().
local function get_error_message(id)
	if id == 8 then
		error'out of memory' --we might not be able to allocate further memory so let's drop it here
	end
	local bufsize = 2048
	local buf = ffi.new('char[?]', bufsize)
	local sz = C.FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, nil, id, 0, buf, bufsize, nil)
	if sz == 0 and GetLastError() == 8 then
		error('out of memory getting error message for %d', id)
	end
	assert(sz ~= 0, 'error getting error message for %d: %d', id, GetLastError())
	return ffi.string(buf, sz)
end

--error handling -------------------------------------------------------------

local NULL = ffi.new'void*'

--given a validator, create a checker function for checking the return value
--of winapi calls. you should pass all winapi calls that signal errors
--by special return value through a checker. this moves error signaling
--from in-band (return values - C) to out-of-band (secondary return values
--or exceptions - Lua).

function retwith(valid) --nil,err-returning variant
	return function(ret)
		if type(ret) == 'cdata' and ret == NULL then
			--discard NULL pointers
			ret = nil
		end
		local valid, err = valid(ret)
		if not valid then
			local code = GetLastError()
			if code ~= 0 then
				err = get_error_message(code)
			end
			return nil, err, code
		end
		return ret
	end
end

function checkwith(valid) --error raising variant
	local retfunc = retwith(valid)
	return function(ret)
		local ret, err = retfunc(ret)
		if err then
			error(err, 2)
		end
		return ret
	end
end

local function validz(ret) return ret == 0, 'zero expected, got non-zero' end
local function validnz(ret) return ret ~= 0, 'non-zero expected, got zero' end
local function validtrue(ret) return ret == 1, '1 (TRUE) expected, got 0 (FALSE)' end
local function validh(ret) return ret ~= nil, 'non NULL value expected, got NULL' end
local function validpoz(ret) return ret >= 0, 'positive number expected, got negative' end

--common return-value nil,err-returning checkers.
retz    = retwith(validz)     --a not-zero is an error
retnz   = retwith(validnz)    --a zero is an error
rettrue = retwith(validtrue)  --non-TRUE is an error
reth    = retwith(validh)     --a null pointer is an error (also converts NULL->nil)
retpoz  = retwith(validpoz)   --a (strictly) negative number is an error

--common return-value error-raising checkers.
checkz    = checkwith(validz)     --a not-zero is an error
checknz   = checkwith(validnz)    --a zero is an error
checktrue = checkwith(validtrue)  --non-TRUE is an error
checkh    = checkwith(validh)     --a null pointer is an error (also converts NULL->nil)
checkpoz  = checkwith(validpoz)   --a (strictly) negative number is an error

--create a special call wrapper for functions for which the return value alone may or may not
--indicate an error, the differentiator being GetLastError() returning 0 or not.
local function callwith2(valid)
	return function(f,...)
		SetLastError(0)
		local ret = f(...)
		ret = ptr(ret) --discard NULL pointers
		local valid_for_sure, err = valid(ret)
		if not valid_for_sure then --still possibly valid
			local code = GetLastError()
			if code ~= 0 then
				err = get_error_message(code)
				error(err,2)
			end
		end
		return ret
	end
end

--common special call wrappers.
callnz2 = callwith2(validnz) --EnumClipboardFormats() is a candidate for this.
callh2 = callwith2(validh)

--garbage collection ---------------------------------------------------------

--own an object by assigning it a finalizer.
--you should own all objects that winapi doesn't own to avoid leaking.
function own(o, finalizer)
	return o and ffi.gc(o, finalizer)
end

--disown an object by removing its finalizer.
--you should disown an object when winapi takes ownership of it to avoid double-freeing.
function disown(o)
	return o and ffi.gc(o, nil)
end

local pins = setmetatable({}, {__mode = 'v'})

--anchor a resource to a target object so that it is guaranteed not to get collected
--as long as the target is alive. more than one resource can be pinned to the same target.
function pin(resource, target)
	pins[resource] = target
	return resource
end

--index adjustment -----------------------------------------------------------

--adjust a number from counting from 1 to counting from 0.
--nil turns to -1. anything else passes through.
--you should pass all Lua args that indicate an index into something through this function.
function countfrom0(n)
	if n == nil then return -1 end
	if type(n) ~= 'number' then return n end
	return n-1
end

--adjust a number from counting from 0 to counting from 1.
--anything not a number passes through. negative numbers turn to nil.
--you should pass all winapi return values that indicate an index into something through this function.
function countfrom1(n)
	if type(n) ~= 'number' then return n end
	if n < 0 then return nil end
	return n+1
end

--pointer filters ------------------------------------------------------------

--turn a pointer into a number to make it indexable in a Lua table. nil passes through.
--NOTE: winapi handles are are safe to convert on x64 as they are kept into the low 32bit.
function ptonumber(p)
	return p and tonumber(ffi.cast('ULONG', p))
end

--turn NULL pointers to nil. anything else passes through.
--you should pass all pointers coming into Lua through this function.
function ptr(p)
	return p ~= NULL and p or nil
end

--flags parser ---------------------------------------------------------------

local band, bor, bnot, rshift = bit.band, bit.bor, bit.bnot, bit.rshift --cache

local flags_cache = setmetatable({}, {__mode = 'kv'})

--compute bit OR'ing of a list flags 'flag1 flag2'. flags are uppercased
--and looked up in the winapi namespace. anything that's not a letter,
--digit or underscore is a separator. nil turns to 0.
--you should pass all flag args through this function.
function flags(s)
	if s == nil or s == '' then return 0 end
	if type(s) ~= 'string' then return s end
	local x = flags_cache[s]
	if x then return x end
	local x = 0
	for flag in s:gmatch'[_%w]+' do --any separator works.
		flag = flag:upper()
		flag = assert(_M[flag], 'invalid flag %s', flag)
		x = bor(x, flag)
	end
	flags_cache[s] = x
	return x
end

--integer splitter -----------------------------------------------------------

--return the low and the high word of a signed long (usually WPARAM, LPARAM or LRESULT).
--TODO: make a platform-dependent splitlongptr() for splitting wParam and lParam.
function splitlong(n)
	n = tonumber(n) --because lParam is uint64 in x64 (which leaves 20 clean bits for the high part)
	return band(n, 0xffff), rshift(n, 16)
end

--use this instead of splitlong to extract signed integers out of a signed long
--(usually LPARAM). this is good for extracting coordinate values which can be negative.
--TODO: make a platform-dependent splitsignedptr() for splitting wParam and lParam.
function splitsigned(n)
	n = tonumber(n) --because lParam is int64 in x64 (which leaves 20 clean bits for the high part)
	local x, y = band(n, 0xffff), rshift(n, 16)
	if x >= 0x8000 then x = x-0xffff end
	if y >= 0x8000 then y = y-0xffff end
	return x, y
end

function split_uint64(x)
	if not x or x == 0 then
		return 0, 0
	end
	local m = ffi.new'ULARGE_INTEGER'
	m.QuadPart = x
	return m.HighPart, m.LowPart
end

--bitmask utils --------------------------------------------------------------

--extract the bool value of a bitmask from a value.
function getbit(from, mask)
	return band(from, mask) == mask
end

--set a single bit of a value without affecting other bits.
function setbit(over, mask, yes)
	return bor(yes and mask or 0, band(over, bnot(mask)))
end

--set one or more bits of a value without affecting other bits.
function setbits(over, mask, bits)
	return bor(bits, band(over, bnot(mask)))
end

--ctype constructor ----------------------------------------------------------

--use arg = types.FOO(arg) instead of arg = ffi.new('FOO', arg): if arg is
--already a FOO or FOO*, it is passed through instead of being copied over,
--thus allowing the user to pre-allocate args if needed to lower gc pressure.

types = {}
setmetatable(types, types)

function types:__index(type_str)
	local ctype = ffi.typeof(type_str)
	self[type_str] = function(t,...)
		if ffi.istype(ctype, t) then return t end
		if t == nil then return ctype() end
		return ctype(t,...)
	end
	return self[type_str]
end

--array constructor ----------------------------------------------------------

--use arg = arrays.FOO(arg) instead of arg == ffi.new('FOO[?]', n, arg).
--if arg is a table, this allows the creation of a #t-sized VLA array
--initialized with the elements from the table, so no need to pass the length.
--the constructor is also returning the number of elements as the second
--retval since APIs usually need that. see arrays_test.lua for full semantics.
arrays = setmetatable({}, {
	__index = function(t,k)
		local ctype = ffi.typeof(k..'[?]')
		t[k] = function(t,...)
			local n
			if type(t) == 'table' then --arr{elem1, elem2, ...} constructor
 				n = #t
				t = ctype(n, t)
			else --arr(n, elem1, elem2, ...) constructor
				n = t
				t = ctype(t,...)
			end
			return t, n
		end
		return t[k]
	end
})

