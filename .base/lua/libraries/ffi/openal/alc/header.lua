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

return header