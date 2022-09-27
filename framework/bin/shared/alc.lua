					local ffi = require("ffi")
					local CLIB = assert(ffi.load("openal"))
					ffi.cdef([[struct ALCdevice {};
struct ALCcontext {};
char(alcCaptureCloseDevice)(struct ALCdevice*);
char(alcCloseDevice)(struct ALCdevice*);
char(alcIsExtensionPresent)(struct ALCdevice*,const char*);
char(alcIsRenderFormatSupportedSOFT)(struct ALCdevice*,int,int,int);
char(alcMakeContextCurrent)(struct ALCcontext*);
char(alcReopenDeviceSOFT)(struct ALCdevice*,const char*,const int*);
char(alcResetDeviceSOFT)(struct ALCdevice*,const int*);
char(alcSetThreadContext)(struct ALCcontext*);
const char*(alcGetString)(struct ALCdevice*,int);
const char*(alcGetStringiSOFT)(struct ALCdevice*,int,int);
int(alcGetEnumValue)(struct ALCdevice*,const char*);
int(alcGetError)(struct ALCdevice*);
struct ALCcontext*(alcCreateContext)(struct ALCdevice*,const int*);
struct ALCcontext*(alcGetCurrentContext)();
struct ALCcontext*(alcGetThreadContext)();
struct ALCdevice*(alcCaptureOpenDevice)(const char*,unsigned int,int,int);
struct ALCdevice*(alcGetContextsDevice)(struct ALCcontext*);
struct ALCdevice*(alcLoopbackOpenDeviceSOFT)(const char*);
struct ALCdevice*(alcOpenDevice)(const char*);
void*(alcGetProcAddress)(struct ALCdevice*,const char*);
void(alcCaptureSamples)(struct ALCdevice*,void*,int);
void(alcCaptureStart)(struct ALCdevice*);
void(alcCaptureStop)(struct ALCdevice*);
void(alcDestroyContext)(struct ALCcontext*);
void(alcDevicePauseSOFT)(struct ALCdevice*);
void(alcDeviceResumeSOFT)(struct ALCdevice*);
void(alcGetInteger64vSOFT)(struct ALCdevice*,int,int,signed long*);
void(alcGetIntegerv)(struct ALCdevice*,int,int,int*);
void(alcProcessContext)(struct ALCcontext*);
void(alcRenderSamplesSOFT)(struct ALCdevice*,void*,int);
void(alcSuspendContext)(struct ALCcontext*);
]])
				local library = {
	CaptureCloseDevice = CLIB.alcCaptureCloseDevice,
	CaptureOpenDevice = CLIB.alcCaptureOpenDevice,
	CaptureSamples = CLIB.alcCaptureSamples,
	CaptureStart = CLIB.alcCaptureStart,
	CaptureStop = CLIB.alcCaptureStop,
	CloseDevice = CLIB.alcCloseDevice,
	CreateContext = CLIB.alcCreateContext,
	DestroyContext = CLIB.alcDestroyContext,
	DevicePauseSOFT = CLIB.alcDevicePauseSOFT,
	DeviceResumeSOFT = CLIB.alcDeviceResumeSOFT,
	GetContextsDevice = CLIB.alcGetContextsDevice,
	GetCurrentContext = CLIB.alcGetCurrentContext,
	GetEnumValue = CLIB.alcGetEnumValue,
	GetError = CLIB.alcGetError,
	GetInteger64vSOFT = CLIB.alcGetInteger64vSOFT,
	GetIntegerv = CLIB.alcGetIntegerv,
	GetProcAddress = CLIB.alcGetProcAddress,
	GetString = CLIB.alcGetString,
	GetStringiSOFT = CLIB.alcGetStringiSOFT,
	GetThreadContext = CLIB.alcGetThreadContext,
	IsExtensionPresent = CLIB.alcIsExtensionPresent,
	IsRenderFormatSupportedSOFT = CLIB.alcIsRenderFormatSupportedSOFT,
	LoopbackOpenDeviceSOFT = CLIB.alcLoopbackOpenDeviceSOFT,
	MakeContextCurrent = CLIB.alcMakeContextCurrent,
	OpenDevice = CLIB.alcOpenDevice,
	ProcessContext = CLIB.alcProcessContext,
	RenderSamplesSOFT = CLIB.alcRenderSamplesSOFT,
	ResetDeviceSOFT = CLIB.alcResetDeviceSOFT,
	SetThreadContext = CLIB.alcSetThreadContext,
	SuspendContext = CLIB.alcSuspendContext,
}
library.e = {
	API = 1,
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
	SOFT_output_limiter = 1,
	OUTPUT_LIMITER_SOFT = 6554,
	SOFT_device_clock = 1,
	DEVICE_CLOCK_SOFT = 5632,
	DEVICE_LATENCY_SOFT = 5633,
	DEVICE_CLOCK_LATENCY_SOFT = 5634,
	SOFT_loopback_bformat = 1,
	AMBISONIC_LAYOUT_SOFT = 6551,
	AMBISONIC_SCALING_SOFT = 6552,
	AMBISONIC_ORDER_SOFT = 6553,
	MAX_AMBISONIC_ORDER_SOFT = 6555,
	BFORMAT3D_SOFT = 5383,
	FUMA_SOFT = 0,
	ACN_SOFT = 1,
	SN3D_SOFT = 1,
	N3D_SOFT = 2,
	SOFT_reopen_device = 1,
	SOFT_output_mode = 1,
	OUTPUT_MODE_SOFT = 6572,
	ANY_SOFT = 6573,
	STEREO_BASIC_SOFT = 6574,
	STEREO_UHJ_SOFT = 6575,
	STEREO_HRTF_SOFT = 6578,
	SURROUND_5_1_SOFT = 5380,
	SURROUND_6_1_SOFT = 5381,
	SURROUND_7_1_SOFT = 5382,
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
