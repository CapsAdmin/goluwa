
--core/winapi: winapi namespace + core + ffi: the platform for loading any proc/ file or oo/ file.
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi.namespace')
require'winapi.debug'
require'winapi.types'
require'winapi.util'
require'winapi.struct'
require'winapi.wcs'
require'winapi.bitmask'
return _M
