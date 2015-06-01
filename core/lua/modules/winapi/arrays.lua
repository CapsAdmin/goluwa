
--ffi/array: variable length array (VLA) wrapper/memoizer
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi.namespace')
require'winapi.ffi'

--we're changing the VLA initializer a bit: if we get a table as arg#1,
--we're creating a #t-sized VLA array initialized with the elements from the table.
--we're also returning the number of elements as the second argument since APIs usually need that.
--see arrays_test.lua for full semantics.
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

if not ... then require'arrays_test' end
