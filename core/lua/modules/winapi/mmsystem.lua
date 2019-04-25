
--proc/system/mmsystem: Multimedia API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'

local winmm = ffi.load'winmm'

TIMERR_BASE           = 96
TIMERR_NOERROR        = 0
TIMERR_NOCANDO        = TIMERR_BASE+1  --request not completed
TIMERR_STRUCT         = TIMERR_BASE+33 --time struct size

ffi.cdef[[
typedef UINT MMRESULT;

typedef struct timecaps_tag {
    UINT    wPeriodMin;     /* minimum period supported  */
    UINT    wPeriodMax;     /* maximum period supported  */
} TIMECAPS, *PTIMECAPS, *LPTIMECAPS;

MMRESULT timeGetDevCaps(LPTIMECAPS ptc, UINT cbtc);
MMRESULT timeBeginPeriod(UINT uPeriod);
MMRESULT timeEndPeriod(UINT uPeriod);
]]

TIMECAPS = types.TIMECAPS

function timeGetDevCaps(ptc)
	ptc = TIMECAPS(ptc)
	checkz(winmm.timeGetDevCaps(ptc, ffi.sizeof(ptc)))
	return ptc
end

timeBeginPeriod = winmm.timeBeginPeriod
timeEndPeriod = winmm.timeEndPeriod --called automatically when the process ends.


--showcase

if not ... then
	local t = timeGetDevCaps()
	print(t.wPeriodMin, t.wPeriodMax)
	timeBeginPeriod(t.wPeriodMin)
	timeEndPeriod(t.wPeriodMin)
end
