
--proc/gdi/ddev: Display Devices API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = 0x00000001
DISPLAY_DEVICE_MULTI_DRIVER        = 0x00000002
DISPLAY_DEVICE_PRIMARY_DEVICE      = 0x00000004
DISPLAY_DEVICE_MIRRORING_DRIVER    = 0x00000008
DISPLAY_DEVICE_VGA_COMPATIBLE      = 0x00000010
DISPLAY_DEVICE_REMOVABLE           = 0x00000020
DISPLAY_DEVICE_MODESPRUNED         = 0x08000000
DISPLAY_DEVICE_REMOTE              = 0x04000000
DISPLAY_DEVICE_DISCONNECT          = 0x02000000
DISPLAY_DEVICE_TS_COMPATIBLE       = 0x00200000
DISPLAY_DEVICE_UNSAFE_MODES_ON     = 0x00080000
DISPLAY_DEVICE_ACTIVE              = 0x00000001
DISPLAY_DEVICE_ATTACHED            = 0x00000002

EDD_GET_DEVICE_INTERFACE_NAME = 0x00000001

ffi.cdef[[
typedef struct _DISPLAY_DEVICEW {
	DWORD cb;
	WCHAR DeviceName[32];
	WCHAR DeviceString[128];
	DWORD StateFlags;
	WCHAR DeviceID[128];
	WCHAR DeviceKey[128];
} DISPLAY_DEVICEW, *PDISPLAY_DEVICEW, *LPDISPLAY_DEVICEW;

BOOL EnumDisplayDevicesW(
	LPCWSTR lpDevice,
	DWORD iDevNum,
	PDISPLAY_DEVICEW lpDisplayDevice,
	DWORD dwFlags);
]]

DISPLAY_DEVICE = struct{ctype = 'DISPLAY_DEVICEW', size = 'cb',
	fields = sfields{
		'device_name',   '', wc_set'DeviceName', wc_get'DeviceName',
		'device_string', '', wc_set'DeviceString', wc_get'DeviceString',
		'state_flags',   'StateFlags', flags, pass,
		'device_id',     '', wc_set'DeviceID', wc_get'DeviceID',
		'device_key',    '', wc_set'DeviceKey', wc_get'DeviceKey',
	}
}

--if devname_or_index is nil, returns an iterator instead!
function EnumDisplayDevices(devname_or_index, dd, EDD)
	dd = DISPLAY_DEVICE(dd)
	if not devname_or_index then
		local i = 0
		return function()
			local ret = EnumDisplayDevices(i, dd, EDD)
			if not ret then return end
			i = i + 1
			return ret
		end
	end
	local devname = type(devname_or_index) == 'string' and wcs(devname_or_index) or nil
	local devindex = tonumber(devname_or_index) or 0
	local ret = C.EnumDisplayDevicesW(devname, devindex, dd, flags(EDD))
	return ret ~= 0 and dd or nil
end


--showcase

if not ... then
	for dd in EnumDisplayDevices() do
		print(dd.device_name, dd.device_string, dd.state_flags, dd.device_id, dd.device_key)
	end
end
