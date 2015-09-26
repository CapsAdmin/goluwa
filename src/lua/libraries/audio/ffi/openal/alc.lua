local header = [[
typedef struct ALCdevice_struct ALCdevice;
typedef struct ALCcontext_struct ALCcontext;
typedef char ALCboolean;
typedef char ALCchar;
typedef char ALCbyte;
typedef unsigned char ALCubyte;
typedef short ALCshort;
typedef unsigned short ALCushort;
typedef int ALCint;
typedef unsigned int ALCuint;
typedef int ALCsizei;
typedef int ALCenum;
typedef float ALCfloat;
typedef double ALCdouble;
typedef void ALCvoid;

ALC_API ALCcontext *    ALC_APIENTRY alcCreateContext( ALCdevice *device, const ALCint* attrlist );
ALC_API ALCboolean      ALC_APIENTRY alcMakeContextCurrent( ALCcontext *context );
ALC_API void            ALC_APIENTRY alcProcessContext( ALCcontext *context );
ALC_API void            ALC_APIENTRY alcSuspendContext( ALCcontext *context );
ALC_API void            ALC_APIENTRY alcDestroyContext( ALCcontext *context );
ALC_API ALCcontext *    ALC_APIENTRY alcGetCurrentContext( void );
ALC_API ALCdevice*      ALC_APIENTRY alcGetContextsDevice( ALCcontext *context );
ALC_API ALCdevice *     ALC_APIENTRY alcOpenDevice( const ALCchar *devicename );
ALC_API ALCboolean      ALC_APIENTRY alcCloseDevice( ALCdevice *device );
ALC_API ALCenum         ALC_APIENTRY alcGetError( ALCdevice *device );
ALC_API ALCboolean      ALC_APIENTRY alcIsExtensionPresent( ALCdevice *device, const ALCchar *extname );
ALC_API void  *         ALC_APIENTRY alcGetProcAddress( ALCdevice *device, const ALCchar *funcname );
ALC_API ALCenum         ALC_APIENTRY alcGetEnumValue( ALCdevice *device, const ALCchar *enumname );
ALC_API const ALCchar * ALC_APIENTRY alcGetString( ALCdevice *device, ALCenum param );
ALC_API void            ALC_APIENTRY alcGetIntegerv( ALCdevice *device, ALCenum param, ALCsizei size, ALCint *data );
ALC_API ALCdevice*      ALC_APIENTRY alcCaptureOpenDevice( const ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize );
ALC_API ALCboolean      ALC_APIENTRY alcCaptureCloseDevice( ALCdevice *device );
ALC_API void            ALC_APIENTRY alcCaptureStart( ALCdevice *device );
ALC_API void            ALC_APIENTRY alcCaptureStop( ALCdevice *device );
ALC_API void            ALC_APIENTRY alcCaptureSamples( ALCdevice *device, ALCvoid *buffer, ALCsizei samples );

typedef ALCcontext *   (ALC_APIENTRY *LPALCCREATECONTEXT) (ALCdevice *device, const ALCint *attrlist);
typedef ALCboolean     (ALC_APIENTRY *LPALCMAKECONTEXTCURRENT)( ALCcontext *context );
typedef void           (ALC_APIENTRY *LPALCPROCESSCONTEXT)( ALCcontext *context );
typedef void           (ALC_APIENTRY *LPALCSUSPENDCONTEXT)( ALCcontext *context );
typedef void           (ALC_APIENTRY *LPALCDESTROYCONTEXT)( ALCcontext *context );
typedef ALCcontext *   (ALC_APIENTRY *LPALCGETCURRENTCONTEXT)( void );
typedef ALCdevice *    (ALC_APIENTRY *LPALCGETCONTEXTSDEVICE)( ALCcontext *context );
typedef ALCdevice *    (ALC_APIENTRY *LPALCOPENDEVICE)( const ALCchar *devicename );
typedef ALCboolean     (ALC_APIENTRY *LPALCCLOSEDEVICE)( ALCdevice *device );
typedef ALCenum        (ALC_APIENTRY *LPALCGETERROR)( ALCdevice *device );
typedef ALCboolean     (ALC_APIENTRY *LPALCISEXTENSIONPRESENT)( ALCdevice *device, const ALCchar *extname );
typedef void *         (ALC_APIENTRY *LPALCGETPROCADDRESS)(ALCdevice *device, const ALCchar *funcname );
typedef ALCenum        (ALC_APIENTRY *LPALCGETENUMVALUE)(ALCdevice *device, const ALCchar *enumname );
typedef const ALCchar* (ALC_APIENTRY *LPALCGETSTRING)( ALCdevice *device, ALCenum param );
typedef void           (ALC_APIENTRY *LPALCGETINTEGERV)( ALCdevice *device, ALCenum param, ALCsizei size, ALCint *dest );
typedef ALCdevice *    (ALC_APIENTRY *LPALCCAPTUREOPENDEVICE)( const ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize );
typedef ALCboolean     (ALC_APIENTRY *LPALCCAPTURECLOSEDEVICE)( ALCdevice *device );
typedef void           (ALC_APIENTRY *LPALCCAPTURESTART)( ALCdevice *device );
typedef void           (ALC_APIENTRY *LPALCCAPTURESTOP)( ALCdevice *device );
typedef void           (ALC_APIENTRY *LPALCCAPTURESAMPLES)( ALCdevice *device, ALCvoid *buffer, ALCsizei samples );
]]


if jit.os == "Windows" then
	header = header:gsub("ALC_APIENTRY", "__cdecl")
	header = header:gsub("ALC_API", "__declspec(dllimport)")
else
	header = header:gsub("ALC_APIENTRY", "")
	header = header:gsub("ALC_API", "extern")
end
local enums =  {
	ALC_INVALID = 0,
	ALC_VERSION_0_1 = 1,
	ALC_FALSE = 0,
	ALC_TRUE = 1,
	ALC_FREQUENCY = 0x1007,
	ALC_REFRESH = 0x1008,
	ALC_SYNC = 0x1009,
	ALC_MONO_SOURCES = 0x1010,
	ALC_STEREO_SOURCES = 0x1011,
	ALC_NO_ERROR = 0,
	ALC_INVALID_DEVICE = 0xA001,
	ALC_INVALID_CONTEXT = 0xA002,
	ALC_INVALID_ENUM = 0xA003,
	ALC_INVALID_VALUE = 0xA004,
	ALC_OUT_OF_MEMORY = 0xA005,
	ALC_DEFAULT_DEVICE_SPECIFIER = 0x1004,
	ALC_DEVICE_SPECIFIER = 0x1005,
	ALC_EXTENSIONS = 0x1006,
	ALC_MAJOR_VERSION = 0x1000,
	ALC_MINOR_VERSION = 0x1001,
	ALC_ATTRIBUTES_SIZE = 0x1002,
	ALC_ALL_ATTRIBUTES = 0x1003,
	ALC_CAPTURE_DEVICE_SPECIFIER = 0x310,
	ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = 0x311,
	ALC_CAPTURE_SAMPLES = 0x312,

	ALC_ALL_ATTRIBUTES = 4099,
	ALC_ALL_DEVICES_SPECIFIER = 4115,
	ALC_ATTRIBUTES_SIZE = 4098,
	ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = 785,
	ALC_CAPTURE_DEVICE_SPECIFIER = 784,
	ALC_CAPTURE_SAMPLES = 786,
	ALC_DEFAULT_ALL_DEVICES_SPECIFIER = 4114,
	ALC_DEFAULT_DEVICE_SPECIFIER = 4100,
	ALC_DEVICE_SPECIFIER = 4101,
	ALC_ENUMERATE_ALL_EXT = 1,
	ALC_EXT_CAPTURE = 1,
	ALC_EXTENSIONS = 4102,
	ALC_FALSE = 0,
	ALC_FREQUENCY = 4103,
	ALC_INVALID = 0,
	ALC_INVALID_CONTEXT = 40962,
	ALC_INVALID_DEVICE = 40961,
	ALC_INVALID_ENUM = 40963,
	ALC_INVALID_VALUE = 40964,
	ALC_MAJOR_VERSION = 4096,
	ALC_MINOR_VERSION = 4097,
	ALC_MONO_SOURCES = 4112,
	ALC_NO_ERROR = 0,
	ALC_OUT_OF_MEMORY = 40965,
	ALC_REFRESH = 4104,
	ALC_STEREO_SOURCES = 4113,
	ALC_SYNC = 4105,
	ALC_TRUE = 1,
	ALC_VERSION_0_1 = 1,

	ALC_EFX_MAJOR_VERSION = 0x20001,
	ALC_EFX_MINOR_VERSION = 0x20002,
	ALC_MAX_AUXILIARY_SENDS = 0x20003,



	ALC_EXT_EFX_NAME = "ALC_EXT_EFX",
	ALC_EFX_MAJOR_VERSION = 0x20001,
	ALC_EFX_MINOR_VERSION = 0x20002,
	ALC_MAX_AUXILIARY_SENDS = 0x20003,
}

local reverse_enums = {}
for k,v in pairs(enums) do
	k = k:gsub("AL_", "")
	k = k:gsub("_", " ")
	k = k:lower()

	reverse_enums[v] = k
end

ffi.cdef(header)

local lib = assert(ffi.load(jit.os == "Windows" and "openal32" or "openal"))

local alc = {
	lib = lib,
	e = enums,
	re = reverse_enums,
}

for line in header:gmatch("(.-)\n") do
	local func_name = line:match(" (alc%u.-)%(")
	if func_name then
		local name = func_name:sub(4)
		alc[name] = function(...)

			if name ~= "GetError" and alc.debug and alc.device then

				local code = alc.GetError(alc.device)

				if code ~= 0 then
					local str = reverse_enums[code] or "unkown error"

					local info = debug.getinfo(2)

					logf("[alc] %q in function %s at %s:%i\n", str, info.name, info.source, info.currentline)
				end
			end

			return lib[func_name](...)
		end
	end
end

return alc