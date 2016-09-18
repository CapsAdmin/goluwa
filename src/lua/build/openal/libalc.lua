local ffi = require("ffi")
ffi.cdef([[struct ALCdevice_struct {};
struct ALCcontext_struct {};
void(alcDestroyContext)(struct ALCcontext_struct*);
void(alcCaptureStop)(struct ALCdevice_struct*);
void(alcGetIntegerv)(struct ALCdevice_struct*,int,int,int*);
const char*(alcGetString)(struct ALCdevice_struct*,int);
struct ALCcontext_struct*(alcGetCurrentContext)();
struct ALCcontext_struct*(alcGetThreadContext)();
int(alcGetError)(struct ALCdevice_struct*);
char(alcResetDeviceSOFT)(struct ALCdevice_struct*,const int*);
void(alcRenderSamplesSOFT)(struct ALCdevice_struct*,void*,int);
void(alcDeviceResumeSOFT)(struct ALCdevice_struct*);
void*(alcGetProcAddress)(struct ALCdevice_struct*,const char*);
struct ALCcontext_struct*(alcCreateContext)(struct ALCdevice_struct*,const int*);
const char*(alcGetStringiSOFT)(struct ALCdevice_struct*,int,int);
void(alcDevicePauseSOFT)(struct ALCdevice_struct*);
char(alcMakeContextCurrent)(struct ALCcontext_struct*);
struct ALCdevice_struct*(alcGetContextsDevice)(struct ALCcontext_struct*);
int(alcGetEnumValue)(struct ALCdevice_struct*,const char*);
char(alcIsRenderFormatSupportedSOFT)(struct ALCdevice_struct*,int,int,int);
void(alcCaptureStart)(struct ALCdevice_struct*);
char(alcSetThreadContext)(struct ALCcontext_struct*);
char(alcCaptureCloseDevice)(struct ALCdevice_struct*);
struct ALCdevice_struct*(alcCaptureOpenDevice)(const char*,unsigned int,int,int);
struct ALCdevice_struct*(alcOpenDevice)(const char*);
char(alcIsExtensionPresent)(struct ALCdevice_struct*,const char*);
void(alcCaptureSamples)(struct ALCdevice_struct*,void*,int);
void(alcProcessContext)(struct ALCcontext_struct*);
char(alcCloseDevice)(struct ALCdevice_struct*);
struct ALCdevice_struct*(alcLoopbackOpenDeviceSOFT)(const char*);
void(alcSuspendContext)(struct ALCcontext_struct*);
]])
local CLIB = ffi.load(_G.FFI_LIB or "openal")
local library = {}
library = {
	DestroyContext = CLIB.alcDestroyContext,
	CaptureStop = CLIB.alcCaptureStop,
	GetIntegerv = CLIB.alcGetIntegerv,
	GetString = CLIB.alcGetString,
	GetCurrentContext = CLIB.alcGetCurrentContext,
	GetThreadContext = CLIB.alcGetThreadContext,
	GetError = CLIB.alcGetError,
	ResetDeviceSOFT = CLIB.alcResetDeviceSOFT,
	RenderSamplesSOFT = CLIB.alcRenderSamplesSOFT,
	DeviceResumeSOFT = CLIB.alcDeviceResumeSOFT,
	GetProcAddress = CLIB.alcGetProcAddress,
	CreateContext = CLIB.alcCreateContext,
	GetStringiSOFT = CLIB.alcGetStringiSOFT,
	DevicePauseSOFT = CLIB.alcDevicePauseSOFT,
	MakeContextCurrent = CLIB.alcMakeContextCurrent,
	GetContextsDevice = CLIB.alcGetContextsDevice,
	GetEnumValue = CLIB.alcGetEnumValue,
	IsRenderFormatSupportedSOFT = CLIB.alcIsRenderFormatSupportedSOFT,
	CaptureStart = CLIB.alcCaptureStart,
	SetThreadContext = CLIB.alcSetThreadContext,
	CaptureCloseDevice = CLIB.alcCaptureCloseDevice,
	CaptureOpenDevice = CLIB.alcCaptureOpenDevice,
	OpenDevice = CLIB.alcOpenDevice,
	IsExtensionPresent = CLIB.alcIsExtensionPresent,
	CaptureSamples = CLIB.alcCaptureSamples,
	ProcessContext = CLIB.alcProcessContext,
	CloseDevice = CLIB.alcCloseDevice,
	LoopbackOpenDeviceSOFT = CLIB.alcLoopbackOpenDeviceSOFT,
	SuspendContext = CLIB.alcSuspendContext,
}
library.e = {
	API = 1,
	API = extern,
	APIENTRY = __cdecl,
	APIENTRY = 1,
	INVALID = 0,
	VERSION_0_1 = 1,
	FALSE = 0,
	TRUE = 1,
	FREQUENCY = 4103,
	REFRESH = 4104,
	SYNC = 4105,
	MONO_SOURCES = 4112,
	STEREO_SOURCES = 4113,
	NO_ERROR = 0,
	INVALID_DEVICE = 40961,
	INVALID_CONTEXT = 40962,
	INVALID_ENUM = 40963,
	INVALID_VALUE = 40964,
	OUT_OF_MEMORY = 40965,
	MAJOR_VERSION = 4096,
	MINOR_VERSION = 4097,
	ATTRIBUTES_SIZE = 4098,
	ALL_ATTRIBUTES = 4099,
	DEFAULT_DEVICE_SPECIFIER = 4100,
	DEVICE_SPECIFIER = 4101,
	EXTENSIONS = 4102,
	EXT_CAPTURE = 1,
	CAPTURE_DEVICE_SPECIFIER = 784,
	CAPTURE_DEFAULT_DEVICE_SPECIFIER = 785,
	CAPTURE_SAMPLES = 786,
	ENUMERATE_ALL_EXT = 1,
	DEFAULT_ALL_DEVICES_SPECIFIER = 4114,
	ALL_DEVICES_SPECIFIER = 4115,
	LOKI_audio_channel = 1,
	CHAN_MAIN_LOKI = 5242881,
	CHAN_PCM_LOKI = 5242882,
	CHAN_CD_LOKI = 5242883,
	EXT_EFX = 1,
	EXT_disconnect = 1,
	CONNECTED = 787,
	EXT_thread_local_context = 1,
	EXT_DEDICATED = 1,
	SOFT_loopback = 1,
	FORMAT_CHANNELS_SOFT = 6544,
	FORMAT_TYPE_SOFT = 6545,
	BYTE_SOFT = 5120,
	UNSIGNED_BYTE_SOFT = 5121,
	SHORT_SOFT = 5122,
	UNSIGNED_SHORT_SOFT = 5123,
	INT_SOFT = 5124,
	UNSIGNED_INT_SOFT = 5125,
	FLOAT_SOFT = 5126,
	MONO_SOFT = 5376,
	STEREO_SOFT = 5377,
	QUAD_SOFT = 5379,
	_5POINT1_SOFT = 5380,
	_6POINT1_SOFT = 5381,
	_7POINT1_SOFT = 5382,
	EXT_DEFAULT_FILTER_ORDER = 1,
	DEFAULT_FILTER_ORDER = 4352,
	SOFT_pause_device = 1,
	SOFT_HRTF = 1,
	HRTF_SOFT = 6546,
	DONT_CARE_SOFT = 2,
	HRTF_STATUS_SOFT = 6547,
	HRTF_DISABLED_SOFT = 0,
	HRTF_ENABLED_SOFT = 1,
	HRTF_DENIED_SOFT = 2,
	HRTF_REQUIRED_SOFT = 3,
	HRTF_HEADPHONES_DETECTED_SOFT = 4,
	HRTF_UNSUPPORTED_FORMAT_SOFT = 5,
	NUM_HRTF_SPECIFIERS_SOFT = 6548,
	HRTF_SPECIFIER_SOFT = 6549,
	HRTF_ID_SOFT = 6550,
	EXT_EFX_NAME = "ALC_EXT_EFX",
	EFX_MAJOR_VERSION = 131073,
	EFX_MINOR_VERSION = 131074,
	MAX_AUXILIARY_SENDS = 131075,
}
function library.GetErrorString(device)
	local num = library.GetError(device)

	if num == library.e.NO_ERROR then
		return "no error"
	elseif num == library.e.INVALID_DEVICE then
		return "invalid device"
	elseif num == library.e.INVALID_CONTEXT then
		return "invalid context"
	elseif num == library.e.INVALID_ENUM then
		return "invalid enum"
	elseif num == library.e.INVALID_VALUE then
		return "invalid value"
	elseif num == library.e.OUT_OF_MEMORY then
		return "out of memory"
	end
end
library.clib = CLIB
return library
