
--binding/winapi: main winapi module
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi.namespace')
require'winapi.types'
require'winapi.util'
require'winapi.struct'
require'winapi.wcs'
require'winapi.bitmask'
return _M
