
--proc/windows/dpiaware: DPI-awareness API

setfenv(1, require'winapi')
require'winapi.monitor'

--Vista+ DPI awareness flag --------------------------------------------------

ffi.cdef[[
BOOL SetProcessDPIAware(void); // Vista+
BOOL IsProcessDPIAware(void);  // Vista+
]]

--NOTE: call this before calling any other window or monitor-related API.
--Calling it later will not return an error but it will have no effect.
function SetProcessDPIAware()
	return checknz(C.SetProcessDPIAware())
end

--NOTE: At scaling levels below 150% this function always returns 1
--because DPI Virtualization is disabled at low scaling levels.
function IsProcessDPIAware()
	return C.IsProcessDPIAware() == 1
end

--Win8.1+ DPI awareness flag -------------------------------------------------

PROCESS_DPI_UNAWARE            = 0
PROCESS_SYSTEM_DPI_AWARE       = 1
PROCESS_PER_MONITOR_DPI_AWARE  = 2

ffi.cdef[[
HRESULT SetProcessDpiAwarenessInternal(int);          // Win8.1+
HRESULT GetProcessDpiAwarenessInternal(HANDLE, int*); // Win8.1+
]]

function SetProcessDPIAwareness(awareness)
	checknz(C.SetProcessDpiAwarenessInternal(flags(awareness)))
end

function GetProcessDPIAwareness(handle)
	local buf = ffi.new'int[1]'
	checknz(C.GetProcessDpiAwarenessInternal(handle, buf))
	return buf[0]
end

--Win8.1+ per-monitor DPI setting --------------------------------------------

MDT_EFFECTIVE_DPI  = 0
MDT_ANGULAR_DPI    = 1
MDT_RAW_DPI        = 2
MDT_DEFAULT        = MDT_EFFECTIVE_DPI

ffi.cdef[[
HRESULT GetDpiForMonitor(
  HMONITOR         hmonitor,
  int              dpiType, // MDT_*
  UINT             *dpiX,
  UINT             *dpiY
); // Win8.1+
]]

local shcore
function GetDPIForMonitor(hmonitor, MDT, dx, dy)
	shcore = shcore or ffi.load'shcore'
	local dx = dx or ffi.new'UINT[1]'
	local dy = dy or ffi.new'UINT[1]'
	checkz(shcore.GetDpiForMonitor(hmonitor, flags(MDT), dx, dy))
	return dx[0], dy[0]
end

--Win8.1+ dpi-changed message ------------------------------------------------

function WM.WM_DPICHANGED(wParam, lParam)
	local x, y = splitlong(wParam)
	local r = ffi.cast('RECT*', lParam)
	return x, y, r.x1, r.y1, r.x2, r.y2
end

if not ... then
	local win8_1 = true --enable this if on Win8.1+
	if win8_1 then
		local awareness = PROCESS_PER_MONITOR_DPI_AWARE
		SetProcessDPIAwareness(awareness)
		assert(GetProcessDPIAwareness() == awareness)

		local mon = assert(MonitorFromPoint())
		print('DPI', GetDPIForMonitor(mon, MDT_EFFECTIVE_DPI))
	else
		SetProcessDPIAware()
		assert(IsProcessDPIAware())
	end
end
