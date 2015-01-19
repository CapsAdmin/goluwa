
--proc/winbase: winbase.h. incomplete :)
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

ffi.cdef[[
DWORD GetCurrentThreadId(void);
]]

GetCurrentThreadId = C.GetCurrentThreadId
