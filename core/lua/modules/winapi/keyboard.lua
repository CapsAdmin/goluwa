
--proc/input/keyboard: Keyboard API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

--NOTE: can't distinguish between cursor keys and numpad cursor keys with GetKeyState(), but you can on WM_KEYDOWN et al.
--NOTE: pressing both shift keys and then depressing one of them doesn't trigger WM_KEYUP, but does trigger WM_INPUT.
--NOTE: flags.prev_key_state is a single flag for both left and right ctrl/alt/shift, not for each physical key.
--NOTE: AltGr is LCTRL followed by RALT with the same message timestamp (which we can use to distinguish from CTRL+ALT).
--NOTE: To distinguish Ctrl+Break from Ctrl+ScrollLock and Break from Ctrl+NumLock, check RI_KEY_E1 and RI_KEY_E0 on WM_INPUT.
--NOTE: Ctrl+NumLock doesn't change the NumLock state, unlike other keys + NumLock (same with Ctrl+ScrollLock).

VK_LBUTTON        = 0x01
VK_RBUTTON        = 0x02
VK_CANCEL         = 0x03    -- Ctrl+Break or Ctrl+ScrollLock
VK_MBUTTON        = 0x04    -- NOT contiguous with L & RBUTTON

VK_XBUTTON1       = 0x05    -- NOT contiguous with L & RBUTTON
VK_XBUTTON2       = 0x06    -- NOT contiguous with L & RBUTTON

VK_BACK           = 0x08
VK_TAB            = 0x09

VK_CLEAR          = 0x0C    -- Numpad 5 with NumLock off
VK_RETURN         = 0x0D

VK_SHIFT          = 0x10
VK_CONTROL        = 0x11
VK_MENU           = 0x12    -- Alt
VK_PAUSE          = 0x13    -- Break or Ctrl+NumLock
VK_CAPITAL        = 0x14

VK_KANA           = 0x15
VK_HANGUL         = 0x15
VK_JUNJA          = 0x17
VK_FINAL          = 0x18
VK_HANJA          = 0x19
VK_KANJI          = 0x19

VK_ESCAPE         = 0x1B

VK_CONVERT        = 0x1C
VK_NONCONVERT     = 0x1D
VK_ACCEPT         = 0x1E
VK_MODECHANGE     = 0x1F

VK_SPACE          = 0x20
VK_PRIOR          = 0x21
VK_NEXT           = 0x22
VK_END            = 0x23
VK_HOME           = 0x24
VK_LEFT           = 0x25
VK_UP             = 0x26
VK_RIGHT          = 0x27
VK_DOWN           = 0x28
VK_SELECT         = 0x29
VK_PRINT          = 0x2A
VK_EXECUTE        = 0x2B
VK_SNAPSHOT       = 0x2C
VK_INSERT         = 0x2D
VK_DELETE         = 0x2E
VK_HELP           = 0x2F

--VK_0 - VK_9 are the same as ASCII '0' - '9' (0x30 - 0x39)
--VK_A - VK_Z are the same as ASCII 'A' - 'Z' (0x41 - 0x5A)

VK_LWIN           = 0x5B --"left windows key" is actually 0xff on my keyboard
VK_RWIN           = 0x5C
VK_APPS           = 0x5D --"context menu" key

VK_SLEEP          = 0x5F

VK_NUMPAD0        = 0x60
VK_NUMPAD1        = 0x61
VK_NUMPAD2        = 0x62
VK_NUMPAD3        = 0x63
VK_NUMPAD4        = 0x64
VK_NUMPAD5        = 0x65
VK_NUMPAD6        = 0x66
VK_NUMPAD7        = 0x67
VK_NUMPAD8        = 0x68
VK_NUMPAD9        = 0x69
VK_MULTIPLY       = 0x6A
VK_ADD            = 0x6B
VK_SEPARATOR      = 0x6C
VK_SUBTRACT       = 0x6D
VK_DECIMAL        = 0x6E
VK_DIVIDE         = 0x6F
VK_F1             = 0x70
VK_F2             = 0x71
VK_F3             = 0x72
VK_F4             = 0x73
VK_F5             = 0x74
VK_F6             = 0x75
VK_F7             = 0x76
VK_F8             = 0x77
VK_F9             = 0x78
VK_F10            = 0x79
VK_F11            = 0x7A
VK_F12            = 0x7B
VK_F13            = 0x7C
VK_F14            = 0x7D
VK_F15            = 0x7E
VK_F16            = 0x7F
VK_F17            = 0x80
VK_F18            = 0x81
VK_F19            = 0x82
VK_F20            = 0x83
VK_F21            = 0x84
VK_F22            = 0x85
VK_F23            = 0x86
VK_F24            = 0x87

VK_NUMLOCK        = 0x90
VK_SCROLL         = 0x91

-- NEC PC-9800 kbd definitions
VK_OEM_NEC_EQUAL  = 0x92   -- '=' key on numpad

-- Fujitsu/OASYS kbd definitions
VK_OEM_FJ_JISHO    = 0x92   -- 'Dictionary' key
VK_OEM_FJ_MASSHOU  = 0x93   -- 'Unregister word' key
VK_OEM_FJ_TOUROKU  = 0x94   -- 'Register word' key
VK_OEM_FJ_LOYA     = 0x95   -- 'Left OYAYUBI' key
VK_OEM_FJ_ROYA     = 0x96   -- 'Right OYAYUBI' key

-- VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
-- Used only as parameters to GetAsyncKeyState() and GetKeyState().
-- No other API or message will distinguish left and right keys in this way.

VK_LSHIFT         = 0xA0
VK_RSHIFT         = 0xA1
VK_LCONTROL       = 0xA2
VK_RCONTROL       = 0xA3
VK_LMENU          = 0xA4 --left Alt
VK_RMENU          = 0xA5 --right Alt

VK_BROWSER_BACK        = 0xA6
VK_BROWSER_FORWARD     = 0xA7
VK_BROWSER_REFRESH     = 0xA8
VK_BROWSER_STOP        = 0xA9
VK_BROWSER_SEARCH      = 0xAA
VK_BROWSER_FAVORITES   = 0xAB
VK_BROWSER_HOME        = 0xAC

VK_VOLUME_MUTE         = 0xAD
VK_VOLUME_DOWN         = 0xAE
VK_VOLUME_UP           = 0xAF
VK_MEDIA_NEXT_TRACK    = 0xB0
VK_MEDIA_PREV_TRACK    = 0xB1
VK_MEDIA_STOP          = 0xB2
VK_MEDIA_PLAY_PAUSE    = 0xB3
VK_LAUNCH_MAIL         = 0xB4
VK_LAUNCH_MEDIA_SELECT = 0xB5
VK_LAUNCH_APP1         = 0xB6
VK_LAUNCH_APP2         = 0xB7

VK_OEM_1          = 0xBA   -- ';:' for US
VK_OEM_PLUS       = 0xBB   -- '+' any country
VK_OEM_COMMA      = 0xBC   -- ',' any country
VK_OEM_MINUS      = 0xBD   -- '-' any country
VK_OEM_PERIOD     = 0xBE   -- '.' any country
VK_OEM_2          = 0xBF   -- '/?' for US
VK_OEM_3          = 0xC0   -- '`~' for US

VK_OEM_4          = 0xDB  --  '[{' for US
VK_OEM_5          = 0xDC  --  '\|' for US
VK_OEM_6          = 0xDD  --  ']}' for US
VK_OEM_7          = 0xDE  --  ''"' for US
VK_OEM_8          = 0xDF

-- Various extended or enhanced keyboards
VK_OEM_AX         = 0xE1  --  'AX' key on Japanese AX kbd
VK_OEM_102        = 0xE2  --  "<>" or "\|" on RT 102-key kbd.
VK_ICO_HELP       = 0xE3  --  Help key on ICO
VK_ICO_00         = 0xE4  --  00 key on ICO
VK_PROCESSKEY     = 0xE5
VK_ICO_CLEAR      = 0xE6
VK_PACKET         = 0xE7

-- Nokia/Ericsson definitions
VK_OEM_RESET      = 0xE9
VK_OEM_JUMP       = 0xEA
VK_OEM_PA1        = 0xEB
VK_OEM_PA2        = 0xEC
VK_OEM_PA3        = 0xED
VK_OEM_WSCTRL     = 0xEE
VK_OEM_CUSEL      = 0xEF
VK_OEM_ATTN       = 0xF0
VK_OEM_FINISH     = 0xF1
VK_OEM_COPY       = 0xF2
VK_OEM_AUTO       = 0xF3
VK_OEM_ENLW       = 0xF4
VK_OEM_BACKTAB    = 0xF5

VK_ATTN           = 0xF6
VK_CRSEL          = 0xF7
VK_EXSEL          = 0xF8
VK_EREOF          = 0xF9
VK_PLAY           = 0xFA
VK_ZOOM           = 0xFB
VK_NONAME         = 0xFC
VK_PA1            = 0xFD
VK_OEM_CLEAR      = 0xFE

ffi.cdef[[
UINT  GetKBCodePage(void);

SHORT GetKeyState(int nVirtKey);
SHORT GetAsyncKeyState(int vKey);

BOOL  GetKeyboardState(PBYTE lpKeyState);
BOOL  SetKeyboardState(LPBYTE lpKeyState);

int   GetKeyNameTextW(LONG lParam, LPWSTR lpString, int cchSize);
int   GetKeyboardType( int nTypeFlag);

int   ToAscii(UINT uVirtKey, UINT uScanCode, const BYTE *lpKeyState, LPWORD lpChar, UINT uFlags);
int   ToUnicode(UINT wVirtKey, UINT wScanCode, const BYTE *lpKeyState, LPWSTR pwszBuff, int cchBuff, UINT wFlags);

DWORD OemKeyScan(WORD wOemChar);
SHORT VkKeyScanW(WCHAR ch);
void  keybd_event(BYTE bVk, BYTE bScan, DWORD dwFlags, ULONG_PTR dwExtraInfo);

typedef struct tagMOUSEINPUT {
    LONG    dx;
    LONG    dy;
    DWORD   mouseData;
    DWORD   dwFlags;
    DWORD   time;
    ULONG_PTR dwExtraInfo;
} MOUSEINPUT, *PMOUSEINPUT, * LPMOUSEINPUT;

typedef struct tagKEYBDINPUT {
    WORD    wVk;
    WORD    wScan;
    DWORD   dwFlags;
    DWORD   time;
    ULONG_PTR dwExtraInfo;
} KEYBDINPUT, *PKEYBDINPUT, * LPKEYBDINPUT;

typedef struct tagHARDWAREINPUT {
    DWORD   uMsg;
    WORD    wParamL;
    WORD    wParamH;
} HARDWAREINPUT, *PHARDWAREINPUT, * LPHARDWAREINPUT;

typedef struct tagINPUT {
    DWORD   type;
    union
    {
        MOUSEINPUT      mi;
        KEYBDINPUT      ki;
        HARDWAREINPUT   hi;
    };
} INPUT, *PINPUT, * LPINPUT;

UINT SendInput(UINT cInputs, LPINPUT pInputs, int cbSize);

typedef struct tagLASTINPUTINFO {
    UINT cbSize;
    DWORD dwTime;
} LASTINPUTINFO, * PLASTINPUTINFO;

BOOL GetLastInputInfo(PLASTINPUTINFO plii);

UINT MapVirtualKeyW(UINT uCode, UINT uMapType);


// keyboard layouts

HKL  LoadKeyboardLayoutW(LPCWSTR pwszKLID, UINT Flags);
HKL  ActivateKeyboardLayout(HKL hkl, UINT Flags);
BOOL UnloadKeyboardLayout(HKL hkl);
BOOL GetKeyboardLayoutNameW(LPWSTR pwszKLID);
int  GetKeyboardLayoutList(int nBuff, HKL  *lpList);
HKL  GetKeyboardLayout(DWORD idThread);

int   ToAsciiEx(UINT uVirtKey, UINT uScanCode, const BYTE *lpKeyState, LPWORD lpChar, UINT uFlags, HKL dwhkl);
int   ToUnicodeEx(UINT wVirtKey, UINT wScanCode, const BYTE *lpKeyState,
						LPWSTR pwszBuff, int cchBuff, UINT wFlags, HKL dwhkl);
SHORT VkKeyScanExW(WCHAR ch, HKL dwhkl);
UINT  MapVirtualKeyExW(UINT uCode, UINT uMapType, HKL dwhkl);

]]

function GetKeyState(vk) --down, toggled
	local state = C.GetKeyState(flags(vk))
	return bit.band(state, 0x8000) ~= 0, bit.band(state, 1) ~= 0
end

function GetAsyncKeyState(vk) --down
	return bit.band(C.GetAsyncKeyState(flags(vk)), 0x8000) ~= 0
end

MAPVK_VK_TO_VSC    = 0
MAPVK_VSC_TO_VK    = 1
MAPVK_VK_TO_CHAR   = 2
MAPVK_VSC_TO_VK_EX = 3

function MapVirtualKey(code, maptype)
	return C.MapVirtualKeyW(code, flags(maptype))
end

--messages

local key_bitmask = bitmask{
	extended_key = 2^24, --distinguish between numpad keys and the rest
	context_code = 2^29, --0 for WM_KEYDOWN
	prev_key_state = 2^30,
	transition_state = 2^31, --0 for WM_KEYDOWN
}

local function get_bitrange(from, b1, b2)
	return bit.band(bit.rshift(from, b1), 2^(b2-b1+1)-1)
end

local function key_flags(lParam)
	local t = key_bitmask:get(lParam)
	t.repeat_count = get_bitrange(lParam, 0, 15) --always 1
	t.scan_code = get_bitrange(lParam, 16, 23)
	return t
end

function WM.WM_KEYDOWN(wParam, lParam)
	return tonumber(wParam), key_flags(lParam) --VK_*, flags
end

WM.WM_KEYUP = WM.WM_KEYDOWN
WM.WM_SYSKEYDOWN = WM.WM_KEYDOWN
WM.WM_SYSKEYUP = WM.WM_KEYDOWN

function WM.WM_CHAR(wParam, lParam)
	return mbs(ffi.new('WCHAR[?]', 2, wParam, 0)), key_flags(lParam)
end

WM.WM_SYSCHAR = WM.WM_CHAR
WM.WM_DEADCHAR = WM.WM_CHAR
WM.WM_SYSDEADCHAR = WM.WM_CHAR

--check for Alt-Gr, which is left-Ctrl followed by right-Alt where both messages have the same timestamp.
--pass the VK and flags of the current key event. note that the next event will be a right-Alt,
--so you need to filter that out, but not just by removing the event, because windows needs to interpret Alt-Gr too.
function IsAltGr(VK, flags)
	if VK == VK_CONTROL and flags.extended_key then
		local time = GetMessageTime()
		local ok, msg = PeekMessage(nil, 0, 0, PM_NOREMOVE)
		if ok then
			if (msg.message == WM_KEYDOWN
				or msg.message == WM_SYSKEYDOWN
				or msg.message == WM_KEYUP
				or msg.message == WM_SYSKEYUP)
				and msg.time == time
				and msg.wParam == VK_MENU
				and bit.band(msg.lParam, 2^24) ~= 0 --extended flag, meaning this is a right Alt
			then
				return true
			end
		end
	end
	return false
end
