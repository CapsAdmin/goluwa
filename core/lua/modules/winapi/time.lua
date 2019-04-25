
--proc/system/time: time functions
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

ffi.cdef[[
DWORD GetTickCount();
ULONGLONG GetTickCount64();
BOOL QueryPerformanceCounter(LARGE_INTEGER *lpPerformanceCount);
BOOL QueryPerformanceFrequency(LARGE_INTEGER *lpFrequency);
BOOL QueryUnbiasedInterruptTime(PULONGLONG UnbiasedTime);
]]

GetTickCount = C.GetTickCount --NOTE: wraps around after 49 days of system runtime

function GetTickCount64() --Vista+
	return C.GetTickCount64()
end

function QueryPerformanceCounter(counter)
	counter = counter or types.LARGE_INTEGER(counter)
	checknz(C.QueryPerformanceCounter(counter))
	return counter
end

function QueryPerformanceFrequency(freq)
	freq = freq or types.LARGE_INTEGER(freq)
	checknz(C.QueryPerformanceFrequency(freq))
	return freq
end

function QueryUnbiasedInterruptTime(time) --Vista+
	time = time or ffi.new'ULONGLONG[1]'
	checknz(C.QueryUnbiasedInterruptTime(time))
	return time[0]
end

if not ... then
	print('GetTickCount', GetTickCount())
	--print('GetTickCount64', GetTickCount64())
	print('QueryPerformanceCounter', QueryPerformanceCounter().QuadPart,
				QueryPerformanceCounter().QuadPart - tonumber(QueryPerformanceCounter().QuadPart))
	print('QueryPerformanceFrequency', QueryPerformanceFrequency().QuadPart)
	--print('QueryUnbiasedInterruptTime', QueryUnbiasedInterruptTime())

end

