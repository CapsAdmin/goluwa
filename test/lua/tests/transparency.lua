ffi.cdef([[
BOOL SetLayeredWindowAttributes(
	HWND hwnd,
	COLORREF crKey,
	BYTE bAlpha,
	DWORD dwFlags
);

typedef struct _DWM_BLURBEHIND {
  DWORD dwFlags;
  BOOL  fEnable;
  HRGN  hRgnBlur;
  BOOL  fTransitionOnMaximized;
} DWM_BLURBEHIND, *PDWM_BLURBEHIND;

HRESULT DwmEnableBlurBehindWindow(
  HWND hWnd,
  const DWM_BLURBEHIND *pBlurBehind
);

]])

require("winapi.window")


local style = winapi.GetWindowLong()
style = bit.band(style, bit.bnot(winapi.WS_OVERLAPPEDWINDOW))
style = bit.bor(style, winapi.WS_POPUP)
winapi.SetWindowLong(winapi.GetForegroundWindow(), winapi.GWL_STYLE, style)

local s = ffi.new("DWM_BLURBEHIND")
s.dwFlags = 1
s.fEnable = true
s.hRgnBlur = nil
ffi.load("Dwmapi.dll").DwmEnableBlurBehindWindow(winapi.GetForegroundWindow(), s)
render.SetClearColor(0,0,0,0)