
--binding/debug: strict mode and debug tools (optional module)
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi.namespace')

--disable stdout buffering so we can print-debug stuff
io.stdout:setvbuf'no'
io.stderr:setvbuf'no'

--set strict mode for the whole winapi namespace
local _G = _G
local declared = {}

local getinfo = debug.getinfo
local rawget, rawset = rawget, rawset

function _M:__index(k)
	if declared[k] then return nil end
	if rawget(_G, k) ~= nil then return rawget(_G, k) end
	error(string.format('Undefined winapi global %s', k), 2)
end

function _M:__newindex(k,v)
	if declared[k] then
		rawset(self, k, v)
	else
		--NOTE: linedefined is always 0 for stripped bytecode, which makes
		--strict mode innefective if winapi is compiled and loaded as bytecode.
		--The reason we don't check for `what == 'main'` like strict.lua does,
		--is because LuaJIT sets `what` to "Lua" on stripped bytecode, while
		--Lua sets it to "main".
		local info = getinfo(2, 'S')
		if info and info.linedefined > 0 then
			error(string.format('Assignment to undeclared winapi global %s', k), 2)
		end
		declared[k] = true
		rawset(self, k, v)
	end
end

--utility to search the name of a constant in the winapi namespace.
function findname(prefix, value)
	for k,v in pairs(_M) do
		if k:match('^'..prefix) and type(v) ~= 'cdata' and type(value) ~= 'cdata' and v == value then return k end
	end
	return tonumber(value) ~= nil and string.format('%x', value) or value
end

--utility to search the names of the bitmasks corresponding to the bits of a value.
--eg. in a WM_WINDOWPOSCHANGING(wp) message you can print(findbits('SWP_', wp.flags)).
function findbits(prefix, value)
	local t = {}
	for k,v in pairs(_M) do
		if k:match('^'..prefix) and getbit(value, v) then
			t[#t+1] = k
		end
	end
	return table.concat(t, ' ')
end

