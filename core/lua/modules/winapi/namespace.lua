
--binding/namespace: namespace module and utils
--Written by Cosmin Apreutesei. Public Domain.

--additional sub-namespaces are published here too.

local _M = {__index = _G}
setmetatable(_M, _M)
_M._M = _M

setfenv(1, _M) --all sub-modules use this pattern to publish their stuff.

--utility to import the contents of a table into the global winapi namespace
--because when strict mode is enabled we can't do glue.update(_M, t)
function import(globals)
	for k,v in pairs(globals) do
		rawset(_M, k, v)
	end
	return globals
end

--import a table as module globals and return the reverse lookup table of it.
function constants(t)
	import(t)
	return index(t)
end

--WM is a namespace for registering window message decoders.
WM = {} --{WM_* = function(wParam, lParam) return decoded values ... end}

--NM is a namespace for registering WM_NOTIFY message decoders.
NM = {} --{NM_* = function(hdr, wParam) return decoded values ... end}

return _M
