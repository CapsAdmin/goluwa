
--proc/input/rawinput: Raw Input API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

ffi.cdef[[
struct HRAWINPUT__ { int unused; }; typedef struct HRAWINPUT__ *HRAWINPUT;

typedef struct tagRAWINPUTHEADER {
    DWORD dwType;
    DWORD dwSize;
    HANDLE hDevice;
    WPARAM wParam;
} RAWINPUTHEADER, *PRAWINPUTHEADER, *LPRAWINPUTHEADER;

typedef struct tagRAWMOUSE {
    USHORT usFlags;
    union {
        ULONG ulButtons;
        struct  {
            USHORT  usButtonFlags;
            USHORT  usButtonData;
        };
    };
    ULONG ulRawButtons;
    LONG lLastX;
    LONG lLastY;
    ULONG ulExtraInformation;
} RAWMOUSE, *PRAWMOUSE, *LPRAWMOUSE;

typedef struct tagRAWKEYBOARD {
    USHORT MakeCode;
    USHORT Flags;
    USHORT Reserved;
    USHORT VKey;
    UINT   Message;
    ULONG ExtraInformation;
} RAWKEYBOARD, *PRAWKEYBOARD, *LPRAWKEYBOARD;

typedef struct tagRAWHID {
    DWORD dwSizeHid;
    DWORD dwCount;
    BYTE bRawData[1];
} RAWHID, *PRAWHID, *LPRAWHID;

typedef struct tagRAWINPUT {
    RAWINPUTHEADER header;
    union {
        RAWMOUSE    mouse;
        RAWKEYBOARD keyboard;
        RAWHID      hid;
    } data;
} RAWINPUT, *PRAWINPUT, *LPRAWINPUT;

UINT GetRawInputData(
     HRAWINPUT hRawInput,
     UINT uiCommand,
     LPVOID pData,
     PUINT pcbSize,
     UINT cbSizeHeader);

typedef struct tagRID_DEVICE_INFO_MOUSE {
    DWORD dwId;
    DWORD dwNumberOfButtons;
    DWORD dwSampleRate;
    BOOL  fHasHorizontalWheel;
} RID_DEVICE_INFO_MOUSE, *PRID_DEVICE_INFO_MOUSE;

typedef struct tagRID_DEVICE_INFO_KEYBOARD {
    DWORD dwType;
    DWORD dwSubType;
    DWORD dwKeyboardMode;
    DWORD dwNumberOfFunctionKeys;
    DWORD dwNumberOfIndicators;
    DWORD dwNumberOfKeysTotal;
} RID_DEVICE_INFO_KEYBOARD, *PRID_DEVICE_INFO_KEYBOARD;

typedef struct tagRID_DEVICE_INFO_HID {
    DWORD dwVendorId;
    DWORD dwProductId;
    DWORD dwVersionNumber;
    USHORT usUsagePage;
    USHORT usUsage;
} RID_DEVICE_INFO_HID, *PRID_DEVICE_INFO_HID;

typedef struct tagRID_DEVICE_INFO {
    DWORD cbSize;
    DWORD dwType;
    union {
        RID_DEVICE_INFO_MOUSE mouse;
        RID_DEVICE_INFO_KEYBOARD keyboard;
        RID_DEVICE_INFO_HID hid;
    };
} RID_DEVICE_INFO, *PRID_DEVICE_INFO, *LPRID_DEVICE_INFO;

UINT GetRawInputDeviceInfoW(
     HANDLE hDevice,
     UINT uiCommand,
     LPVOID pData,
     PUINT pcbSize);

UINT GetRawInputBuffer(
     PRAWINPUT pData,
     PUINT pcbSize,
     UINT cbSizeHeader);

typedef struct tagRAWINPUTDEVICE {
    USHORT usUsagePage;
    USHORT usUsage;
    DWORD dwFlags;
    HWND hwndTarget;
} RAWINPUTDEVICE, *PRAWINPUTDEVICE, *LPRAWINPUTDEVICE;

typedef const RAWINPUTDEVICE* PCRAWINPUTDEVICE;

BOOL RegisterRawInputDevices(
     PCRAWINPUTDEVICE pRawInputDevices,
     UINT uiNumDevices,
     UINT cbSize);

UINT GetRegisteredRawInputDevices(
     PRAWINPUTDEVICE pRawInputDevices,
     PUINT puiNumDevices,
     UINT cbSize);

typedef struct tagRAWINPUTDEVICELIST {
    HANDLE hDevice;
    DWORD dwType;
} RAWINPUTDEVICELIST, *PRAWINPUTDEVICELIST;

UINT GetRawInputDeviceList(
     PRAWINPUTDEVICELIST pRawInputDeviceList,
     PUINT puiNumDevices,
     UINT cbSize);

LRESULT DefRawInputProc(
     PRAWINPUT* paRawInput,
     INT nInput,
     UINT cbSizeHeader);
]]

--type of raw input
RIM_TYPEMOUSE       = 0
RIM_TYPEKEYBOARD    = 1
RIM_TYPEHID         = 2

--mouse button state indicators
RI_MOUSE_LEFT_BUTTON_DOWN   = 0x0001  -- Left Button changed to down.
RI_MOUSE_LEFT_BUTTON_UP     = 0x0002  -- Left Button changed to up.
RI_MOUSE_RIGHT_BUTTON_DOWN  = 0x0004  -- Right Button changed to down.
RI_MOUSE_RIGHT_BUTTON_UP    = 0x0008  -- Right Button changed to up.
RI_MOUSE_MIDDLE_BUTTON_DOWN = 0x0010  -- Middle Button changed to down.
RI_MOUSE_MIDDLE_BUTTON_UP   = 0x0020  -- Middle Button changed to up.

RI_MOUSE_BUTTON_1_DOWN      = RI_MOUSE_LEFT_BUTTON_DOWN
RI_MOUSE_BUTTON_1_UP        = RI_MOUSE_LEFT_BUTTON_UP
RI_MOUSE_BUTTON_2_DOWN      = RI_MOUSE_RIGHT_BUTTON_DOWN
RI_MOUSE_BUTTON_2_UP        = RI_MOUSE_RIGHT_BUTTON_UP
RI_MOUSE_BUTTON_3_DOWN      = RI_MOUSE_MIDDLE_BUTTON_DOWN
RI_MOUSE_BUTTON_3_UP        = RI_MOUSE_MIDDLE_BUTTON_UP

RI_MOUSE_BUTTON_4_DOWN      = 0x0040
RI_MOUSE_BUTTON_4_UP        = 0x0080
RI_MOUSE_BUTTON_5_DOWN      = 0x0100
RI_MOUSE_BUTTON_5_UP        = 0x0200

--if usButtonFlags has RI_MOUSE_WHEEL, the wheel delta is stored in usButtonData. Take it as a signed value.
RI_MOUSE_WHEEL = 0x0400

--mouse indicator flags
MOUSE_MOVE_RELATIVE      =    0
MOUSE_MOVE_ABSOLUTE      =    1
MOUSE_VIRTUAL_DESKTOP    = 0x02  -- the coordinates are mapped to the virtual desktop
MOUSE_ATTRIBUTES_CHANGED = 0x04  -- requery for mouse attributes
MOUSE_MOVE_NOCOALESCE    = 0x08  -- do not coalesce mouse moves (Vista+)

-- keyboard overrun MakeCode
KEYBOARD_OVERRUN_MAKE_CODE = 0xFF

--keyboard input data flags
RI_KEY_MAKE             = 0
RI_KEY_BREAK            = 1
RI_KEY_E0               = 2
RI_KEY_E1               = 4
RI_KEY_TERMSRV_SET_LED  = 8
RI_KEY_TERMSRV_SHADOW   = 0x10

if ffi.abi'64bit' then
	function RAWINPUT_ALIGN(x) return math.floor((x + 7) / 8) * 8 end
else
	function RAWINPUT_ALIGN(x) return bit.band(x + 3, bit.bnot(3)) end
end

function NEXTRAWINPUTBLOCK(ptr)
	return ffi.cast('PRAWINPUT', RAWINPUT_ALIGN(ffi.cast('ULONG_PTR', ffi.cast('PBYTE', ptr) + ptr.header.dwSize)))
end

-- flags for GetRawInputData
RID_INPUT   = 0x10000003
RID_HEADER  = 0x10000005

-- Raw Input Device Information
RIDI_PREPARSEDDATA      = 0x20000005
RIDI_DEVICENAME         = 0x20000007  -- the return valus is the character length, not the byte size
RIDI_DEVICEINFO         = 0x2000000b

RIDEV_REMOVE            = 0x00000001
RIDEV_EXCLUDE           = 0x00000010
RIDEV_PAGEONLY          = 0x00000020
RIDEV_NOLEGACY          = 0x00000030
RIDEV_INPUTSINK         = 0x00000100
RIDEV_CAPTUREMOUSE      = 0x00000200  -- effective when mouse nolegacy is specified, otherwise it would be an error
RIDEV_NOHOTKEYS         = 0x00000200  -- effective for keyboard
RIDEV_APPKEYS           = 0x00000400  -- effective for keyboard
RIDEV_EXINPUTSINK       = 0x00001000
RIDEV_DEVNOTIFY         = 0x00002000
RIDEV_EXMODEMASK        = 0x000000F0

function RIDEV_EXMODE(mode)
	return bit.band(mode, RIDEV_EXMODEMASK)
end

--GET_DEVICE_CHANGE_WPARAM(wParam)  (LOWORD(wParam)) --Vista+
--GET_DEVICE_CHANGE_LPARAM(lParam)  (LOWORD(lParam)) --XP

function GetRawInputData(...)
	return checkpoz(C.GetRawInputData(...))
end

GetRawInputDeviceInfo        = C.GetRawInputDeviceInfoW
GetRawInputBuffer            = C.GetRawInputBuffer

function RegisterRawInputDevices(...)
	return checknz(C.RegisterRawInputDevices(...))
end

GetRegisteredRawInputDevices = C.GetRegisteredRawInputDevices
GetRawInputDeviceList        = C.GetRawInputDeviceList
DefRawInputProc              = C.DefRawInputProc

--input message

local hsz = ffi.sizeof'RAWINPUTHEADER'
local sz  = ffi.new'UINT[1]'
local buf, pbuf
local bufsz = 0

--NOTE: the handler must not return a value so that DefWindowProc can be called.
function WM.WM_INPUT(wParam, lParam)
	local hraw = ffi.cast('HRAWINPUT', lParam)
	GetRawInputData(hraw, RID_INPUT, nil, sz, hsz) --get sz
	if sz[0] > bufsz then --grow the buffer
		bufsz = sz[0]
		buf = ffi.new('BYTE[?]', bufsz)
		pbuf = ffi.cast('PRAWINPUT', buf)
	end
	local szz = GetRawInputData(hraw, RID_INPUT, buf, sz, hsz)
	assert(szz == sz[0]) --TODO: this failed once but can't reproduce
	return pbuf
end

-- device change message

local op = {'add', 'remove'}

function WM.WM_INPUT_DEVICE_CHANGE(wParam, lParam)
	return op[wParam], ffi.cast('HRAWINPUT', lParam)
end

