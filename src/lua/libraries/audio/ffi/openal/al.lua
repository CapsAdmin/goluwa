-- https://github.com/malkia/ufo/blob/master/ffi/OpenAL.lua

-- The code below was contributed by David Hollander along with OpenALUT.cpp
-- To run on Windows, there are few choices, easiest one is to download
-- http://connect.creativelabs.com/openal/Downloads/oalinst.zip
-- and run the executable from inside of it (I've seen couple of games use it).

local ffi = require("ffi")

local header = [[

typedef struct ALCdevice_struct ALCdevice;
typedef struct ALCcontext_struct ALCcontext;
typedef char ALCboolean;
typedef char ALCchar;
typedef signed char ALCbyte;
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
typedef char ALboolean;
typedef char ALchar;
typedef signed char ALbyte;
typedef unsigned char ALubyte;
typedef short ALshort;
typedef unsigned short ALushort;
typedef int ALint;
typedef unsigned int ALuint;
typedef int ALsizei;
typedef int ALenum;
typedef float ALfloat;
typedef double ALdouble;
typedef void ALvoid;
typedef uint64_t ALuint64SOFT;
typedef int64_t ALint64SOFT;


typedef ALCcontext*    (__cdecl *LPALCCREATECONTEXT)(ALCdevice *device, const ALCint *attrlist);
typedef ALCboolean     (__cdecl *LPALCMAKECONTEXTCURRENT)(ALCcontext *context);
typedef void           (__cdecl *LPALCPROCESSCONTEXT)(ALCcontext *context);
typedef void           (__cdecl *LPALCSUSPENDCONTEXT)(ALCcontext *context);
typedef void           (__cdecl *LPALCDESTROYCONTEXT)(ALCcontext *context);
typedef ALCcontext*    (__cdecl *LPALCGETCURRENTCONTEXT)(void);
typedef ALCdevice*     (__cdecl *LPALCGETCONTEXTSDEVICE)(ALCcontext *context);
typedef ALCdevice*     (__cdecl *LPALCOPENDEVICE)(const ALCchar *devicename);
typedef ALCboolean     (__cdecl *LPALCCLOSEDEVICE)(ALCdevice *device);
typedef ALCenum        (__cdecl *LPALCGETERROR)(ALCdevice *device);
typedef ALCboolean     (__cdecl *LPALCISEXTENSIONPRESENT)(ALCdevice *device, const ALCchar *extname);
typedef void*          (__cdecl *LPALCGETPROCADDRESS)(ALCdevice *device, const ALCchar *funcname);
typedef ALCenum        (__cdecl *LPALCGETENUMVALUE)(ALCdevice *device, const ALCchar *enumname);
typedef const ALCchar* (__cdecl *LPALCGETSTRING)(ALCdevice *device, ALCenum param);
typedef void           (__cdecl *LPALCGETINTEGERV)(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values);
typedef ALCdevice*     (__cdecl *LPALCCAPTUREOPENDEVICE)(const ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
typedef ALCboolean     (__cdecl *LPALCCAPTURECLOSEDEVICE)(ALCdevice *device);
typedef void           (__cdecl *LPALCCAPTURESTART)(ALCdevice *device);
typedef void           (__cdecl *LPALCCAPTURESTOP)(ALCdevice *device);
typedef void           (__cdecl *LPALCCAPTURESAMPLES)(ALCdevice *device, ALCvoid *buffer, ALCsizei samples);

typedef void          (__cdecl *LPALENABLE)(ALenum capability);
typedef void          (__cdecl *LPALDISABLE)(ALenum capability);
typedef ALboolean     (__cdecl *LPALISENABLED)(ALenum capability);
typedef const ALchar* (__cdecl *LPALGETSTRING)(ALenum param);
typedef void          (__cdecl *LPALGETBOOLEANV)(ALenum param, ALboolean *values);
typedef void          (__cdecl *LPALGETINTEGERV)(ALenum param, ALint *values);
typedef void          (__cdecl *LPALGETFLOATV)(ALenum param, ALfloat *values);
typedef void          (__cdecl *LPALGETDOUBLEV)(ALenum param, ALdouble *values);
typedef ALboolean     (__cdecl *LPALGETBOOLEAN)(ALenum param);
typedef ALint         (__cdecl *LPALGETINTEGER)(ALenum param);
typedef ALfloat       (__cdecl *LPALGETFLOAT)(ALenum param);
typedef ALdouble      (__cdecl *LPALGETDOUBLE)(ALenum param);
typedef ALenum        (__cdecl *LPALGETERROR)(void);
typedef ALboolean     (__cdecl *LPALISEXTENSIONPRESENT)(const ALchar *extname);
typedef void*         (__cdecl *LPALGETPROCADDRESS)(const ALchar *fname);
typedef ALenum        (__cdecl *LPALGETENUMVALUE)(const ALchar *ename);
typedef void          (__cdecl *LPALLISTENERF)(ALenum param, ALfloat value);
typedef void          (__cdecl *LPALLISTENER3F)(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
typedef void          (__cdecl *LPALLISTENERFV)(ALenum param, const ALfloat *values);
typedef void          (__cdecl *LPALLISTENERI)(ALenum param, ALint value);
typedef void          (__cdecl *LPALLISTENER3I)(ALenum param, ALint value1, ALint value2, ALint value3);
typedef void          (__cdecl *LPALLISTENERIV)(ALenum param, const ALint *values);
typedef void          (__cdecl *LPALGETLISTENERF)(ALenum param, ALfloat *value);
typedef void          (__cdecl *LPALGETLISTENER3F)(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
typedef void          (__cdecl *LPALGETLISTENERFV)(ALenum param, ALfloat *values);
typedef void          (__cdecl *LPALGETLISTENERI)(ALenum param, ALint *value);
typedef void          (__cdecl *LPALGETLISTENER3I)(ALenum param, ALint *value1, ALint *value2, ALint *value3);
typedef void          (__cdecl *LPALGETLISTENERIV)(ALenum param, ALint *values);
typedef void          (__cdecl *LPALGENSOURCES)(ALsizei n, ALuint *sources);
typedef void          (__cdecl *LPALDELETESOURCES)(ALsizei n, const ALuint *sources);
typedef ALboolean     (__cdecl *LPALISSOURCE)(ALuint source);
typedef void          (__cdecl *LPALSOURCEF)(ALuint source, ALenum param, ALfloat value);
typedef void          (__cdecl *LPALSOURCE3F)(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
typedef void          (__cdecl *LPALSOURCEFV)(ALuint source, ALenum param, const ALfloat *values);
typedef void          (__cdecl *LPALSOURCEI)(ALuint source, ALenum param, ALint value);
typedef void          (__cdecl *LPALSOURCE3I)(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3);
typedef void          (__cdecl *LPALSOURCEIV)(ALuint source, ALenum param, const ALint *values);
typedef void          (__cdecl *LPALGETSOURCEF)(ALuint source, ALenum param, ALfloat *value);
typedef void          (__cdecl *LPALGETSOURCE3F)(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
typedef void          (__cdecl *LPALGETSOURCEFV)(ALuint source, ALenum param, ALfloat *values);
typedef void          (__cdecl *LPALGETSOURCEI)(ALuint source, ALenum param, ALint *value);
typedef void          (__cdecl *LPALGETSOURCE3I)(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3);
typedef void          (__cdecl *LPALGETSOURCEIV)(ALuint source, ALenum param, ALint *values);
typedef void          (__cdecl *LPALSOURCEPLAYV)(ALsizei n, const ALuint *sources);
typedef void          (__cdecl *LPALSOURCESTOPV)(ALsizei n, const ALuint *sources);
typedef void          (__cdecl *LPALSOURCEREWINDV)(ALsizei n, const ALuint *sources);
typedef void          (__cdecl *LPALSOURCEPAUSEV)(ALsizei n, const ALuint *sources);
typedef void          (__cdecl *LPALSOURCEPLAY)(ALuint source);
typedef void          (__cdecl *LPALSOURCESTOP)(ALuint source);
typedef void          (__cdecl *LPALSOURCEREWIND)(ALuint source);
typedef void          (__cdecl *LPALSOURCEPAUSE)(ALuint source);
typedef void          (__cdecl *LPALSOURCEQUEUEBUFFERS)(ALuint source, ALsizei nb, const ALuint *buffers);
typedef void          (__cdecl *LPALSOURCEUNQUEUEBUFFERS)(ALuint source, ALsizei nb, ALuint *buffers);
typedef void          (__cdecl *LPALGENBUFFERS)(ALsizei n, ALuint *buffers);
typedef void          (__cdecl *LPALDELETEBUFFERS)(ALsizei n, const ALuint *buffers);
typedef ALboolean     (__cdecl *LPALISBUFFER)(ALuint buffer);
typedef void          (__cdecl *LPALBUFFERDATA)(ALuint buffer, ALenum format, const ALvoid *data, ALsizei size, ALsizei freq);
typedef void          (__cdecl *LPALBUFFERF)(ALuint buffer, ALenum param, ALfloat value);
typedef void          (__cdecl *LPALBUFFER3F)(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
typedef void          (__cdecl *LPALBUFFERFV)(ALuint buffer, ALenum param, const ALfloat *values);
typedef void          (__cdecl *LPALBUFFERI)(ALuint buffer, ALenum param, ALint value);
typedef void          (__cdecl *LPALBUFFER3I)(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3);
typedef void          (__cdecl *LPALBUFFERIV)(ALuint buffer, ALenum param, const ALint *values);
typedef void          (__cdecl *LPALGETBUFFERF)(ALuint buffer, ALenum param, ALfloat *value);
typedef void          (__cdecl *LPALGETBUFFER3F)(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
typedef void          (__cdecl *LPALGETBUFFERFV)(ALuint buffer, ALenum param, ALfloat *values);
typedef void          (__cdecl *LPALGETBUFFERI)(ALuint buffer, ALenum param, ALint *value);
typedef void          (__cdecl *LPALGETBUFFER3I)(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3);
typedef void          (__cdecl *LPALGETBUFFERIV)(ALuint buffer, ALenum param, ALint *values);
typedef void          (__cdecl *LPALDOPPLERFACTOR)(ALfloat value);
typedef void          (__cdecl *LPALDOPPLERVELOCITY)(ALfloat value);
typedef void          (__cdecl *LPALSPEEDOFSOUND)(ALfloat value);
typedef void          (__cdecl *LPALDISTANCEMODEL)(ALenum distanceModel);

typedef ALvoid (__cdecl*PFNALBUFFERDATASTATICPROC)(const ALint,ALenum,ALvoid*,ALsizei,ALsizei);
typedef void (__cdecl *LPALGENEFFECTS)(ALsizei, ALuint*);
typedef void (__cdecl *LPALDELETEEFFECTS)(ALsizei, const ALuint*);
typedef ALboolean (__cdecl *LPALISEFFECT)(ALuint);
typedef void (__cdecl *LPALEFFECTI)(ALuint, ALenum, ALint);
typedef void (__cdecl *LPALEFFECTIV)(ALuint, ALenum, const ALint*);
typedef void (__cdecl *LPALEFFECTF)(ALuint, ALenum, ALfloat);
typedef void (__cdecl *LPALEFFECTFV)(ALuint, ALenum, const ALfloat*);
typedef void (__cdecl *LPALGETEFFECTI)(ALuint, ALenum, ALint*);
typedef void (__cdecl *LPALGETEFFECTIV)(ALuint, ALenum, ALint*);
typedef void (__cdecl *LPALGETEFFECTF)(ALuint, ALenum, ALfloat*);
typedef void (__cdecl *LPALGETEFFECTFV)(ALuint, ALenum, ALfloat*);
typedef void (__cdecl *LPALGENFILTERS)(ALsizei, ALuint*);
typedef void (__cdecl *LPALDELETEFILTERS)(ALsizei, const ALuint*);
typedef ALboolean (__cdecl *LPALISFILTER)(ALuint);
typedef void (__cdecl *LPALFILTERI)(ALuint, ALenum, ALint);
typedef void (__cdecl *LPALFILTERIV)(ALuint, ALenum, const ALint*);
typedef void (__cdecl *LPALFILTERF)(ALuint, ALenum, ALfloat);
typedef void (__cdecl *LPALFILTERFV)(ALuint, ALenum, const ALfloat*);
typedef void (__cdecl *LPALGETFILTERI)(ALuint, ALenum, ALint*);
typedef void (__cdecl *LPALGETFILTERIV)(ALuint, ALenum, ALint*);
typedef void (__cdecl *LPALGETFILTERF)(ALuint, ALenum, ALfloat*);
typedef void (__cdecl *LPALGETFILTERFV)(ALuint, ALenum, ALfloat*);
typedef void (__cdecl *LPALGENAUXILIARYEFFECTSLOTS)(ALsizei, ALuint*);
typedef void (__cdecl *LPALDELETEAUXILIARYEFFECTSLOTS)(ALsizei, const ALuint*);
typedef ALboolean (__cdecl *LPALISAUXILIARYEFFECTSLOT)(ALuint);
typedef void (__cdecl *LPALAUXILIARYEFFECTSLOTI)(ALuint, ALenum, ALint);
typedef void (__cdecl *LPALAUXILIARYEFFECTSLOTIV)(ALuint, ALenum, const ALint*);
typedef void (__cdecl *LPALAUXILIARYEFFECTSLOTF)(ALuint, ALenum, ALfloat);
typedef void (__cdecl *LPALAUXILIARYEFFECTSLOTFV)(ALuint, ALenum, const ALfloat*);
typedef void (__cdecl *LPALGETAUXILIARYEFFECTSLOTI)(ALuint, ALenum, ALint*);
typedef void (__cdecl *LPALGETAUXILIARYEFFECTSLOTIV)(ALuint, ALenum, ALint*);
typedef void (__cdecl *LPALGETAUXILIARYEFFECTSLOTF)(ALuint, ALenum, ALfloat*);
typedef void (__cdecl *LPALGETAUXILIARYEFFECTSLOTFV)(ALuint, ALenum, ALfloat*);

typedef ALCboolean  (__cdecl*PFNALCSETTHREADCONTEXTPROC)(ALCcontext *context);
typedef ALCcontext* (__cdecl*PFNALCGETTHREADCONTEXTPROC)(void);
typedef ALvoid (__cdecl*PFNALBUFFERSUBDATASOFTPROC)(ALuint,ALenum,const ALvoid*,ALsizei,ALsizei);
typedef void (__cdecl*LPALFOLDBACKCALLBACK)(ALenum,ALsizei);
typedef void (__cdecl*LPALREQUESTFOLDBACKSTART)(ALenum,ALsizei,ALsizei,ALfloat*,LPALFOLDBACKCALLBACK);
typedef void (__cdecl*LPALREQUESTFOLDBACKSTOP)(void);
typedef void (__cdecl*LPALBUFFERSAMPLESSOFT)(ALuint,ALuint,ALenum,ALsizei,ALenum,ALenum,const ALvoid*);
typedef void (__cdecl*LPALBUFFERSUBSAMPLESSOFT)(ALuint,ALsizei,ALsizei,ALenum,ALenum,const ALvoid*);
typedef void (__cdecl*LPALGETBUFFERSAMPLESSOFT)(ALuint,ALsizei,ALsizei,ALenum,ALenum,ALvoid*);
typedef ALboolean (__cdecl*LPALISBUFFERFORMATSUPPORTEDSOFT)(ALenum);
typedef ALCdevice* (__cdecl*LPALCLOOPBACKOPENDEVICESOFT)(const ALCchar*);
typedef ALCboolean (__cdecl*LPALCISRENDERFORMATSUPPORTEDSOFT)(ALCdevice*,ALCsizei,ALCenum,ALCenum);
typedef void (__cdecl*LPALCRENDERSAMPLESSOFT)(ALCdevice*,ALCvoid*,ALCsizei);

typedef void (__cdecl*LPALSOURCEDSOFT)(ALuint,ALenum,ALdouble);
typedef void (__cdecl*LPALSOURCE3DSOFT)(ALuint,ALenum,ALdouble,ALdouble,ALdouble);
typedef void (__cdecl*LPALSOURCEDVSOFT)(ALuint,ALenum,const ALdouble*);
typedef void (__cdecl*LPALGETSOURCEDSOFT)(ALuint,ALenum,ALdouble*);
typedef void (__cdecl*LPALGETSOURCE3DSOFT)(ALuint,ALenum,ALdouble*,ALdouble*,ALdouble*);
typedef void (__cdecl*LPALGETSOURCEDVSOFT)(ALuint,ALenum,ALdouble*);
typedef struct {
    float flDensity;
    float flDiffusion;
    float flGain;
    float flGainHF;
    float flGainLF;
    float flDecayTime;
    float flDecayHFRatio;
    float flDecayLFRatio;
    float flReflectionsGain;
    float flReflectionsDelay;
    float flReflectionsPan[3];
    float flLateReverbGain;
    float flLateReverbDelay;
    float flLateReverbPan[3];
    float flEchoTime;
    float flEchoDepth;
    float flModulationTime;
    float flModulationDepth;
    float flAirAbsorptionGainHF;
    float flHFReference;
    float flLFReference;
    float flRoomRolloffFactor;
    int   iDecayHFLimit;
} EFXEAXREVERBPROPERTIES, *LPEFXEAXREVERBPROPERTIES;


__declspec(dllimport) ALCcontext* __cdecl alcCreateContext(ALCdevice *device, const ALCint* attrlist);
__declspec(dllimport) ALCboolean  __cdecl alcMakeContextCurrent(ALCcontext *context);
__declspec(dllimport) void        __cdecl alcProcessContext(ALCcontext *context);
__declspec(dllimport) void        __cdecl alcSuspendContext(ALCcontext *context);
__declspec(dllimport) void        __cdecl alcDestroyContext(ALCcontext *context);
__declspec(dllimport) ALCcontext* __cdecl alcGetCurrentContext(void);
__declspec(dllimport) ALCdevice*  __cdecl alcGetContextsDevice(ALCcontext *context);
__declspec(dllimport) ALCdevice* __cdecl alcOpenDevice(const ALCchar *devicename);
__declspec(dllimport) ALCboolean __cdecl alcCloseDevice(ALCdevice *device);
__declspec(dllimport) ALCenum __cdecl alcGetError(ALCdevice *device);
__declspec(dllimport) ALCboolean __cdecl alcIsExtensionPresent(ALCdevice *device, const ALCchar *extname);
__declspec(dllimport) void*      __cdecl alcGetProcAddress(ALCdevice *device, const ALCchar *funcname);
__declspec(dllimport) ALCenum    __cdecl alcGetEnumValue(ALCdevice *device, const ALCchar *enumname);
__declspec(dllimport) const ALCchar* __cdecl alcGetString(ALCdevice *device, ALCenum param);
__declspec(dllimport) void           __cdecl alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values);
__declspec(dllimport) ALCdevice* __cdecl alcCaptureOpenDevice(const ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
__declspec(dllimport) ALCboolean __cdecl alcCaptureCloseDevice(ALCdevice *device);
__declspec(dllimport) void       __cdecl alcCaptureStart(ALCdevice *device);
__declspec(dllimport) void       __cdecl alcCaptureStop(ALCdevice *device);
__declspec(dllimport) void       __cdecl alcCaptureSamples(ALCdevice *device, ALCvoid *buffer, ALCsizei samples);

__declspec(dllimport) void __cdecl alDopplerFactor(ALfloat value);
__declspec(dllimport) void __cdecl alDopplerVelocity(ALfloat value);
__declspec(dllimport) void __cdecl alSpeedOfSound(ALfloat value);
__declspec(dllimport) void __cdecl alDistanceModel(ALenum distanceModel);
__declspec(dllimport) void __cdecl alEnable(ALenum capability);
__declspec(dllimport) void __cdecl alDisable(ALenum capability);
__declspec(dllimport) ALboolean __cdecl alIsEnabled(ALenum capability);
__declspec(dllimport) const ALchar* __cdecl alGetString(ALenum param);
__declspec(dllimport) void __cdecl alGetBooleanv(ALenum param, ALboolean *values);
__declspec(dllimport) void __cdecl alGetIntegerv(ALenum param, ALint *values);
__declspec(dllimport) void __cdecl alGetFloatv(ALenum param, ALfloat *values);
__declspec(dllimport) void __cdecl alGetDoublev(ALenum param, ALdouble *values);
__declspec(dllimport) ALboolean __cdecl alGetBoolean(ALenum param);
__declspec(dllimport) ALint __cdecl alGetInteger(ALenum param);
__declspec(dllimport) ALfloat __cdecl alGetFloat(ALenum param);
__declspec(dllimport) ALdouble __cdecl alGetDouble(ALenum param);
__declspec(dllimport) ALenum __cdecl alGetError(void);
__declspec(dllimport) ALboolean __cdecl alIsExtensionPresent(const ALchar *extname);
__declspec(dllimport) void* __cdecl alGetProcAddress(const ALchar *fname);
__declspec(dllimport) ALenum __cdecl alGetEnumValue(const ALchar *ename);
__declspec(dllimport) void __cdecl alListenerf(ALenum param, ALfloat value);
__declspec(dllimport) void __cdecl alListener3f(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
__declspec(dllimport) void __cdecl alListenerfv(ALenum param, const ALfloat *values);
__declspec(dllimport) void __cdecl alListeneri(ALenum param, ALint value);
__declspec(dllimport) void __cdecl alListener3i(ALenum param, ALint value1, ALint value2, ALint value3);
__declspec(dllimport) void __cdecl alListeneriv(ALenum param, const ALint *values);
__declspec(dllimport) void __cdecl alGetListenerf(ALenum param, ALfloat *value);
__declspec(dllimport) void __cdecl alGetListener3f(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
__declspec(dllimport) void __cdecl alGetListenerfv(ALenum param, ALfloat *values);
__declspec(dllimport) void __cdecl alGetListeneri(ALenum param, ALint *value);
__declspec(dllimport) void __cdecl alGetListener3i(ALenum param, ALint *value1, ALint *value2, ALint *value3);
__declspec(dllimport) void __cdecl alGetListeneriv(ALenum param, ALint *values);
__declspec(dllimport) void __cdecl alGenSources(ALsizei n, ALuint *sources);
__declspec(dllimport) void __cdecl alDeleteSources(ALsizei n, const ALuint *sources);
__declspec(dllimport) ALboolean __cdecl alIsSource(ALuint source);
__declspec(dllimport) void __cdecl alSourcef(ALuint source, ALenum param, ALfloat value);
__declspec(dllimport) void __cdecl alSource3f(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
__declspec(dllimport) void __cdecl alSourcefv(ALuint source, ALenum param, const ALfloat *values);
__declspec(dllimport) void __cdecl alSourcei(ALuint source, ALenum param, ALint value);
__declspec(dllimport) void __cdecl alSource3i(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3);
__declspec(dllimport) void __cdecl alSourceiv(ALuint source, ALenum param, const ALint *values);
__declspec(dllimport) void __cdecl alGetSourcef(ALuint source, ALenum param, ALfloat *value);
__declspec(dllimport) void __cdecl alGetSource3f(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
__declspec(dllimport) void __cdecl alGetSourcefv(ALuint source, ALenum param, ALfloat *values);
__declspec(dllimport) void __cdecl alGetSourcei(ALuint source,  ALenum param, ALint *value);
__declspec(dllimport) void __cdecl alGetSource3i(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3);
__declspec(dllimport) void __cdecl alGetSourceiv(ALuint source,  ALenum param, ALint *values);
__declspec(dllimport) void __cdecl alSourcePlayv(ALsizei n, const ALuint *sources);
__declspec(dllimport) void __cdecl alSourceStopv(ALsizei n, const ALuint *sources);
__declspec(dllimport) void __cdecl alSourceRewindv(ALsizei n, const ALuint *sources);
__declspec(dllimport) void __cdecl alSourcePausev(ALsizei n, const ALuint *sources);
__declspec(dllimport) void __cdecl alSourcePlay(ALuint source);
__declspec(dllimport) void __cdecl alSourceStop(ALuint source);
__declspec(dllimport) void __cdecl alSourceRewind(ALuint source);
__declspec(dllimport) void __cdecl alSourcePause(ALuint source);
__declspec(dllimport) void __cdecl alSourceQueueBuffers(ALuint source, ALsizei nb, const ALuint *buffers);
__declspec(dllimport) void __cdecl alSourceUnqueueBuffers(ALuint source, ALsizei nb, ALuint *buffers);
__declspec(dllimport) void __cdecl alGenBuffers(ALsizei n, ALuint *buffers);
__declspec(dllimport) void __cdecl alDeleteBuffers(ALsizei n, const ALuint *buffers);
__declspec(dllimport) ALboolean __cdecl alIsBuffer(ALuint buffer);
__declspec(dllimport) void __cdecl alBufferData(ALuint buffer, ALenum format, const ALvoid *data, ALsizei size, ALsizei freq);
__declspec(dllimport) void __cdecl alBufferf(ALuint buffer, ALenum param, ALfloat value);
__declspec(dllimport) void __cdecl alBuffer3f(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
__declspec(dllimport) void __cdecl alBufferfv(ALuint buffer, ALenum param, const ALfloat *values);
__declspec(dllimport) void __cdecl alBufferi(ALuint buffer, ALenum param, ALint value);
__declspec(dllimport) void __cdecl alBuffer3i(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3);
__declspec(dllimport) void __cdecl alBufferiv(ALuint buffer, ALenum param, const ALint *values);
__declspec(dllimport) void __cdecl alGetBufferf(ALuint buffer, ALenum param, ALfloat *value);
__declspec(dllimport) void __cdecl alGetBuffer3f(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
__declspec(dllimport) void __cdecl alGetBufferfv(ALuint buffer, ALenum param, ALfloat *values);
__declspec(dllimport) void __cdecl alGetBufferi(ALuint buffer, ALenum param, ALint *value);
__declspec(dllimport) void __cdecl alGetBuffer3i(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3);
__declspec(dllimport) void __cdecl alGetBufferiv(ALuint buffer, ALenum param, ALint *values);
]]
local enums = {
	AL_NONE = 0,
	AL_FALSE = 0,
	AL_TRUE = 1,
	AL_SOURCE_RELATIVE = 0x202,
	AL_CONE_INNER_ANGLE = 0x1001,
	AL_CONE_OUTER_ANGLE = 0x1002,
	AL_PITCH = 0x1003,
	AL_POSITION = 0x1004,
	AL_DIRECTION = 0x1005,
	AL_VELOCITY = 0x1006,
	AL_LOOPING = 0x1007,
	AL_LOOP_POINTS = 0x2015,
	AL_BUFFER = 0x1009,
	AL_GAIN = 0x100A,
	AL_MIN_GAIN = 0x100D,
	AL_MAX_GAIN = 0x100E,
	AL_ORIENTATION = 0x100F,
	AL_SOURCE_STATE = 0x1010,
	AL_INITIAL = 0x1011,
	AL_PLAYING = 0x1012,
	AL_PAUSED = 0x1013,
	AL_STOPPED = 0x1014,
	AL_BUFFERS_QUEUED = 0x1015,
	AL_BUFFERS_PROCESSED = 0x1016,
	AL_SEC_OFFSET = 0x1024,
	AL_SAMPLE_OFFSET = 0x1025,
	AL_BYTE_OFFSET = 0x1026,
	AL_SOURCE_TYPE = 0x1027,
	AL_STATIC = 0x1028,
	AL_STREAMING = 0x1029,
	AL_UNDETERMINED = 0x1030,
	AL_FORMAT_MONO8 = 0x1100,
	AL_FORMAT_MONO16 = 0x1101,
	AL_FORMAT_STEREO8 = 0x1102,
	AL_FORMAT_STEREO16 = 0x1103,
	AL_REFERENCE_DISTANCE = 0x1020,
	AL_ROLLOFF_FACTOR = 0x1021,
	AL_CONE_OUTER_GAIN = 0x1022,
	AL_MAX_DISTANCE = 0x1023,
	AL_FREQUENCY = 0x2001,
	AL_BITS = 0x2002,
	AL_CHANNELS = 0x2003,
	AL_SIZE = 0x2004,
	AL_UNUSED = 0x2010,
	AL_PENDING = 0x2011,
	AL_PROCESSED = 0x2012,
	AL_NO_ERROR = 0,
	AL_INVALID_NAME = 0xA001,
	AL_INVALID_ENUM = 0xA002,
	AL_INVALID_VALUE = 0xA003,
	AL_INVALID_OPERATION = 0xA004,
	AL_OUT_OF_MEMORY = 0xA005,
	AL_VENDOR = 0xB001,
	AL_VERSION = 0xB002,
	AL_RENDERER = 0xB003,
	AL_EXTENSIONS = 0xB004,
	AL_DOPPLER_FACTOR = 0xC000,
	AL_DOPPLER_VELOCITY = 0xC001,
	AL_SPEED_OF_SOUND = 0xC003,
	AL_DISTANCE_MODEL = 0xD000,
	AL_INVERSE_DISTANCE = 0xD001,
	AL_INVERSE_DISTANCE_CLAMPED = 0xD002,
	AL_LINEAR_DISTANCE = 0xD003,
	AL_LINEAR_DISTANCE_CLAMPED = 0xD004,
	AL_EXPONENT_DISTANCE = 0xD005,
	AL_EXPONENT_DISTANCE_CLAMPED = 0xD006,

	AL_FILTER_TYPE = 0x8001,
	AL_EFFECT_TYPE = 0x8001,
	AL_FILTER_NULL = 0x0000,
	AL_FILTER_LOWPASS = 0x0001,
	AL_FILTER_HIGHPASS = 0x0002,
	AL_FILTER_BANDPASS = 0x0003,
	AL_EFFECT_NULL = 0x0000,
	AL_EFFECT_EAXREVERB = 0x8000,
	AL_EFFECT_REVERB = 0x0001,
	AL_EFFECT_CHORUS = 0x0002,
	AL_EFFECT_DISTORTION = 0x0003,
	AL_EFFECT_ECHO = 0x0004,
	AL_EFFECT_FLANGER = 0x0005,
	AL_EFFECT_FREQUENCY_SHIFTER = 0x0006,
	AL_EFFECT_VOCAL_MORPHER = 0x0007,
	AL_EFFECT_PITCH_SHIFTER = 0x0008,
	AL_EFFECT_RING_MODULATOR = 0x0009,
	AL_EFFECT_AUTOWAH = 0x000A,
	AL_EFFECT_COMPRESSOR = 0x000B,
	AL_EFFECT_EQUALIZER = 0x000C,

	AL_METERS_PER_UNIT = 0x20004,
	AL_DIRECT_FILTER = 0x20005,
	AL_AUXILIARY_SEND_FILTER = 0x20006,
	AL_AIR_ABSORPTION_FACTOR = 0x20007,
	AL_ROOM_ROLLOFF_FACTOR = 0x20008,
	AL_CONE_OUTER_GAINHF = 0x20009,
	AL_DIRECT_FILTER_GAINHF_AUTO = 0x2000A,
	AL_AUXILIARY_SEND_FILTER_GAIN_AUTO = 0x2000B,
	AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 0x2000C,
	AL_REVERB_DENSITY = 0x0001,
	AL_REVERB_DIFFUSION = 0x0002,
	AL_REVERB_GAIN = 0x0003,
	AL_REVERB_GAINHF = 0x0004,
	AL_REVERB_DECAY_TIME = 0x0005,
	AL_REVERB_DECAY_HFRATIO = 0x0006,
	AL_REVERB_REFLECTIONS_GAIN = 0x0007,
	AL_REVERB_REFLECTIONS_DELAY = 0x0008,
	AL_REVERB_LATE_REVERB_GAIN = 0x0009,
	AL_REVERB_LATE_REVERB_DELAY = 0x000A,
	AL_REVERB_AIR_ABSORPTION_GAINHF = 0x000B,
	AL_REVERB_ROOM_ROLLOFF_FACTOR = 0x000C,
	AL_REVERB_DECAY_HFLIMIT = 0x000D,
	AL_EAXREVERB_DENSITY = 0x0001,
	AL_EAXREVERB_DIFFUSION = 0x0002,
	AL_EAXREVERB_GAIN = 0x0003,
	AL_EAXREVERB_GAINHF = 0x0004,
	AL_EAXREVERB_GAINLF = 0x0005,
	AL_EAXREVERB_DECAY_TIME = 0x0006,
	AL_EAXREVERB_DECAY_HFRATIO = 0x0007,
	AL_EAXREVERB_DECAY_LFRATIO = 0x0008,
	AL_EAXREVERB_REFLECTIONS_GAIN = 0x0009,
	AL_EAXREVERB_REFLECTIONS_DELAY = 0x000A,
	AL_EAXREVERB_REFLECTIONS_PAN = 0x000B,
	AL_EAXREVERB_LATE_REVERB_GAIN = 0x000C,
	AL_EAXREVERB_LATE_REVERB_DELAY = 0x000D,
	AL_EAXREVERB_LATE_REVERB_PAN = 0x000E,
	AL_EAXREVERB_ECHO_TIME = 0x000F,
	AL_EAXREVERB_ECHO_DEPTH = 0x0010,
	AL_EAXREVERB_MODULATION_TIME = 0x0011,
	AL_EAXREVERB_MODULATION_DEPTH = 0x0012,
	AL_EAXREVERB_AIR_ABSORPTION_GAINHF = 0x0013,
	AL_EAXREVERB_HFREFERENCE = 0x0014,
	AL_EAXREVERB_LFREFERENCE = 0x0015,
	AL_EAXREVERB_ROOM_ROLLOFF_FACTOR = 0x0016,
	AL_EAXREVERB_DECAY_HFLIMIT = 0x0017,
	AL_CHORUS_WAVEFORM = 0x0001,
	AL_CHORUS_PHASE = 0x0002,
	AL_CHORUS_RATE = 0x0003,
	AL_CHORUS_DEPTH = 0x0004,
	AL_CHORUS_FEEDBACK = 0x0005,
	AL_CHORUS_DELAY = 0x0006,
	AL_DISTORTION_EDGE = 0x0001,
	AL_DISTORTION_GAIN = 0x0002,
	AL_DISTORTION_LOWPASS_CUTOFF = 0x0003,
	AL_DISTORTION_EQCENTER = 0x0004,
	AL_DISTORTION_EQBANDWIDTH = 0x0005,
	AL_ECHO_DELAY = 0x0001,
	AL_ECHO_LRDELAY = 0x0002,
	AL_ECHO_DAMPING = 0x0003,
	AL_ECHO_FEEDBACK = 0x0004,
	AL_ECHO_SPREAD = 0x0005,
	AL_FLANGER_WAVEFORM = 0x0001,
	AL_FLANGER_PHASE = 0x0002,
	AL_FLANGER_RATE = 0x0003,
	AL_FLANGER_DEPTH = 0x0004,
	AL_FLANGER_FEEDBACK = 0x0005,
	AL_FLANGER_DELAY = 0x0006,
	AL_FREQUENCY_SHIFTER_FREQUENCY = 0x0001,
	AL_FREQUENCY_SHIFTER_LEFT_DIRECTION = 0x0002,
	AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION = 0x0003,
	AL_VOCAL_MORPHER_PHONEMEA = 0x0001,
	AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING = 0x0002,
	AL_VOCAL_MORPHER_PHONEMEB = 0x0003,
	AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING = 0x0004,
	AL_VOCAL_MORPHER_WAVEFORM = 0x0005,
	AL_VOCAL_MORPHER_RATE = 0x0006,
	AL_PITCH_SHIFTER_COARSE_TUNE = 0x0001,
	AL_PITCH_SHIFTER_FINE_TUNE = 0x0002,
	AL_RING_MODULATOR_FREQUENCY = 0x0001,
	AL_RING_MODULATOR_HIGHPASS_CUTOFF = 0x0002,
	AL_RING_MODULATOR_WAVEFORM = 0x0003,
	AL_AUTOWAH_ATTACK_TIME = 0x0001,
	AL_AUTOWAH_RELEASE_TIME = 0x0002,
	AL_AUTOWAH_RESONANCE = 0x0003,
	AL_AUTOWAH_PEAK_GAIN = 0x0004,
	AL_COMPRESSOR_ONOFF = 0x0001,
	AL_EQUALIZER_LOW_GAIN = 0x0001,
	AL_EQUALIZER_LOW_CUTOFF = 0x0002,
	AL_EQUALIZER_MID1_GAIN = 0x0003,
	AL_EQUALIZER_MID1_CENTER = 0x0004,
	AL_EQUALIZER_MID1_WIDTH = 0x0005,
	AL_EQUALIZER_MID2_GAIN = 0x0006,
	AL_EQUALIZER_MID2_CENTER = 0x0007,
	AL_EQUALIZER_MID2_WIDTH = 0x0008,
	AL_EQUALIZER_HIGH_GAIN = 0x0009,
	AL_EQUALIZER_HIGH_CUTOFF = 0x000A,
	AL_EFFECT_FIRST_PARAMETER = 0x0000,
	AL_EFFECT_LAST_PARAMETER = 0x8000,
	AL_EFFECT_TYPE = 0x8001,
	AL_EFFECT_NULL = 0x0000,
	AL_EFFECT_REVERB = 0x0001,
	AL_EFFECT_CHORUS = 0x0002,
	AL_EFFECT_DISTORTION = 0x0003,
	AL_EFFECT_ECHO = 0x0004,
	AL_EFFECT_FLANGER = 0x0005,
	AL_EFFECT_FREQUENCY_SHIFTER = 0x0006,
	AL_EFFECT_VOCAL_MORPHER = 0x0007,
	AL_EFFECT_PITCH_SHIFTER = 0x0008,
	AL_EFFECT_RING_MODULATOR = 0x0009,
	AL_EFFECT_AUTOWAH = 0x000A,
	AL_EFFECT_COMPRESSOR = 0x000B,
	AL_EFFECT_EQUALIZER = 0x000C,
	AL_EFFECT_EAXREVERB = 0x8000,
	AL_EFFECTSLOT_EFFECT = 0x0001,
	AL_EFFECTSLOT_GAIN = 0x0002,
	AL_EFFECTSLOT_AUXILIARY_SEND_AUTO = 0x0003,
	AL_EFFECTSLOT_NULL = 0x0000,
	AL_LOWPASS_GAIN = 0x0001,
	AL_LOWPASS_GAINHF = 0x0002,
	AL_HIGHPASS_GAIN = 0x0001,
	AL_HIGHPASS_GAINLF = 0x0002,
	AL_BANDPASS_GAIN = 0x0001,
	AL_BANDPASS_GAINLF = 0x0002,
	AL_BANDPASS_GAINHF = 0x0003,
	AL_FILTER_FIRST_PARAMETER = 0x0000,
	AL_FILTER_LAST_PARAMETER = 0x8000,
	AL_FILTER_TYPE = 0x8001,
	AL_FILTER_NULL = 0x0000,
	AL_FILTER_LOWPASS = 0x0001,
	AL_FILTER_HIGHPASS = 0x0002,
	AL_FILTER_BANDPASS = 0x0003,
	AL_LOWPASS_MIN_GAIN = 0.0,
	AL_LOWPASS_MAX_GAIN = 1.0,
	AL_LOWPASS_DEFAULT_GAIN = 1.0,
	AL_LOWPASS_MIN_GAINHF = 0.0,
	AL_LOWPASS_MAX_GAINHF = 1.0,
	AL_LOWPASS_DEFAULT_GAINHF = 1.0,
	AL_HIGHPASS_MIN_GAIN = 0.0,
	AL_HIGHPASS_MAX_GAIN = 1.0,
	AL_HIGHPASS_DEFAULT_GAIN = 1.0,
	AL_HIGHPASS_MIN_GAINLF = 0.0,
	AL_HIGHPASS_MAX_GAINLF = 1.0,
	AL_HIGHPASS_DEFAULT_GAINLF = 1.0,
	AL_BANDPASS_MIN_GAIN = 0.0,
	AL_BANDPASS_MAX_GAIN = 1.0,
	AL_BANDPASS_DEFAULT_GAIN = 1.0,
	AL_BANDPASS_MIN_GAINHF = 0.0,
	AL_BANDPASS_MAX_GAINHF = 1.0,
	AL_BANDPASS_DEFAULT_GAINHF = 1.0,
	AL_BANDPASS_MIN_GAINLF = 0.0,
	AL_BANDPASS_MAX_GAINLF = 1.0,
	AL_BANDPASS_DEFAULT_GAINLF = 1.0,
	AL_REVERB_MIN_DENSITY = 0.0,
	AL_REVERB_MAX_DENSITY = 1.0,
	AL_REVERB_DEFAULT_DENSITY = 1.0,
	AL_REVERB_MIN_DIFFUSION = 0.0,
	AL_REVERB_MAX_DIFFUSION = 1.0,
	AL_REVERB_DEFAULT_DIFFUSION = 1.0,
	AL_REVERB_MIN_GAIN = 0.0,
	AL_REVERB_MAX_GAIN = 1.0,
	AL_REVERB_DEFAULT_GAIN = 0.32,
	AL_REVERB_MIN_GAINHF = 0.0,
	AL_REVERB_MAX_GAINHF = 1.0,
	AL_REVERB_DEFAULT_GAINHF = 0.89,
	AL_REVERB_MIN_DECAY_TIME = 0.1,
	AL_REVERB_MAX_DECAY_TIME = 20.0,
	AL_REVERB_DEFAULT_DECAY_TIME = 1.49,
	AL_REVERB_MIN_DECAY_HFRATIO = 0.1,
	AL_REVERB_MAX_DECAY_HFRATIO = 2.0,
	AL_REVERB_DEFAULT_DECAY_HFRATIO = 0.83,
	AL_REVERB_MIN_REFLECTIONS_GAIN = 0.0,
	AL_REVERB_MAX_REFLECTIONS_GAIN = 3.16,
	AL_REVERB_DEFAULT_REFLECTIONS_GAIN = 0.05,
	AL_REVERB_MIN_REFLECTIONS_DELAY = 0.0,
	AL_REVERB_MAX_REFLECTIONS_DELAY = 0.3,
	AL_REVERB_DEFAULT_REFLECTIONS_DELAY = 0.007,
	AL_REVERB_MIN_LATE_REVERB_GAIN = 0.0,
	AL_REVERB_MAX_LATE_REVERB_GAIN = 10.0,
	AL_REVERB_DEFAULT_LATE_REVERB_GAIN = 1.26,
	AL_REVERB_MIN_LATE_REVERB_DELAY = 0.0,
	AL_REVERB_MAX_LATE_REVERB_DELAY = 0.1,
	AL_REVERB_DEFAULT_LATE_REVERB_DELAY = 0.011,
	AL_REVERB_MIN_AIR_ABSORPTION_GAINHF = 0.892,
	AL_REVERB_MAX_AIR_ABSORPTION_GAINHF = 1.0,
	AL_REVERB_DEFAULT_AIR_ABSORPTION_GAINHF = 0.994,
	AL_REVERB_MIN_ROOM_ROLLOFF_FACTOR = 0.0,
	AL_REVERB_MAX_ROOM_ROLLOFF_FACTOR = 10.0,
	AL_REVERB_DEFAULT_ROOM_ROLLOFF_FACTOR = 0.0,
	AL_REVERB_MIN_DECAY_HFLIMIT = 0,
	AL_REVERB_MAX_DECAY_HFLIMIT = 1,
	AL_REVERB_DEFAULT_DECAY_HFLIMIT = 1,
	AL_EAXREVERB_MIN_DENSITY = 0.0,
	AL_EAXREVERB_MAX_DENSITY = 1.0,
	AL_EAXREVERB_DEFAULT_DENSITY = 1.0,
	AL_EAXREVERB_MIN_DIFFUSION = 0.0,
	AL_EAXREVERB_MAX_DIFFUSION = 1.0,
	AL_EAXREVERB_DEFAULT_DIFFUSION = 1.0,
	AL_EAXREVERB_MIN_GAIN = 0.0,
	AL_EAXREVERB_MAX_GAIN = 1.0,
	AL_EAXREVERB_DEFAULT_GAIN = 0.32,
	AL_EAXREVERB_MIN_GAINHF = 0.0,
	AL_EAXREVERB_MAX_GAINHF = 1.0,
	AL_EAXREVERB_DEFAULT_GAINHF = 0.89,
	AL_EAXREVERB_MIN_GAINLF = 0.0,
	AL_EAXREVERB_MAX_GAINLF = 1.0,
	AL_EAXREVERB_DEFAULT_GAINLF = 1.0,
	AL_EAXREVERB_MIN_DECAY_TIME = 0.1,
	AL_EAXREVERB_MAX_DECAY_TIME = 20.0,
	AL_EAXREVERB_DEFAULT_DECAY_TIME = 1.49,
	AL_EAXREVERB_MIN_DECAY_HFRATIO = 0.1,
	AL_EAXREVERB_MAX_DECAY_HFRATIO = 2.0,
	AL_EAXREVERB_DEFAULT_DECAY_HFRATIO = 0.83,
	AL_EAXREVERB_MIN_DECAY_LFRATIO = 0.1,
	AL_EAXREVERB_MAX_DECAY_LFRATIO = 2.0,
	AL_EAXREVERB_DEFAULT_DECAY_LFRATIO = 1.0,
	AL_EAXREVERB_MIN_REFLECTIONS_GAIN = 0.0,
	AL_EAXREVERB_MAX_REFLECTIONS_GAIN = 3.16,
	AL_EAXREVERB_DEFAULT_REFLECTIONS_GAIN = 0.05,
	AL_EAXREVERB_MIN_REFLECTIONS_DELAY = 0.0,
	AL_EAXREVERB_MAX_REFLECTIONS_DELAY = 0.3,
	AL_EAXREVERB_DEFAULT_REFLECTIONS_DELAY = 0.007,
	AL_EAXREVERB_DEFAULT_REFLECTIONS_PAN_XYZ = 0.0,
	AL_EAXREVERB_MIN_LATE_REVERB_GAIN = 0.0,
	AL_EAXREVERB_MAX_LATE_REVERB_GAIN = 10.0,
	AL_EAXREVERB_DEFAULT_LATE_REVERB_GAIN = 1.26,
	AL_EAXREVERB_MIN_LATE_REVERB_DELAY = 0.0,
	AL_EAXREVERB_MAX_LATE_REVERB_DELAY = 0.1,
	AL_EAXREVERB_DEFAULT_LATE_REVERB_DELAY = 0.011,
	AL_EAXREVERB_DEFAULT_LATE_REVERB_PAN_XYZ = 0.0,
	AL_EAXREVERB_MIN_ECHO_TIME = 0.075,
	AL_EAXREVERB_MAX_ECHO_TIME = 0.25,
	AL_EAXREVERB_DEFAULT_ECHO_TIME = 0.25,
	AL_EAXREVERB_MIN_ECHO_DEPTH = 0.0,
	AL_EAXREVERB_MAX_ECHO_DEPTH = 1.0,
	AL_EAXREVERB_DEFAULT_ECHO_DEPTH = 0.0,
	AL_EAXREVERB_MIN_MODULATION_TIME = 0.04,
	AL_EAXREVERB_MAX_MODULATION_TIME = 4.0,
	AL_EAXREVERB_DEFAULT_MODULATION_TIME = 0.25,
	AL_EAXREVERB_MIN_MODULATION_DEPTH = 0.0,
	AL_EAXREVERB_MAX_MODULATION_DEPTH = 1.0,
	AL_EAXREVERB_DEFAULT_MODULATION_DEPTH = 0.0,
	AL_EAXREVERB_MIN_AIR_ABSORPTION_GAINHF = 0.892,
	AL_EAXREVERB_MAX_AIR_ABSORPTION_GAINHF = 1.0,
	AL_EAXREVERB_DEFAULT_AIR_ABSORPTION_GAINHF = 0.994,
	AL_EAXREVERB_MIN_HFREFERENCE = 1000.0,
	AL_EAXREVERB_MAX_HFREFERENCE = 20000.0,
	AL_EAXREVERB_DEFAULT_HFREFERENCE = 5000.0,
	AL_EAXREVERB_MIN_LFREFERENCE = 20.0,
	AL_EAXREVERB_MAX_LFREFERENCE = 1000.0,
	AL_EAXREVERB_DEFAULT_LFREFERENCE = 250.0,
	AL_EAXREVERB_MIN_ROOM_ROLLOFF_FACTOR = 0.0,
	AL_EAXREVERB_MAX_ROOM_ROLLOFF_FACTOR = 10.0,
	AL_EAXREVERB_DEFAULT_ROOM_ROLLOFF_FACTOR = 0.0,
	AL_EAXREVERB_MIN_DECAY_HFLIMIT = 0,
	AL_EAXREVERB_MAX_DECAY_HFLIMIT = 1,
	AL_EAXREVERB_DEFAULT_DECAY_HFLIMIT = 1,
	AL_CHORUS_WAVEFORM_SINUSOID = 0,
	AL_CHORUS_WAVEFORM_TRIANGLE = 1,
	AL_CHORUS_MIN_WAVEFORM = 0,
	AL_CHORUS_MAX_WAVEFORM = 1,
	AL_CHORUS_DEFAULT_WAVEFORM = 1,
	AL_CHORUS_MIN_PHASE = -180,
	AL_CHORUS_MAX_PHASE = 180,
	AL_CHORUS_DEFAULT_PHASE = 90,
	AL_CHORUS_MIN_RATE = 0.0,
	AL_CHORUS_MAX_RATE = 10.0,
	AL_CHORUS_DEFAULT_RATE = 1.1,
	AL_CHORUS_MIN_DEPTH = 0.0,
	AL_CHORUS_MAX_DEPTH = 1.0,
	AL_CHORUS_DEFAULT_DEPTH = 0.1,
	AL_CHORUS_MIN_FEEDBACK = -1.0,
	AL_CHORUS_MAX_FEEDBACK = 1.0,
	AL_CHORUS_DEFAULT_FEEDBACK = 0.25,
	AL_CHORUS_MIN_DELAY = 0.0,
	AL_CHORUS_MAX_DELAY = 0.016,
	AL_CHORUS_DEFAULT_DELAY = 0.016,
	AL_DISTORTION_MIN_EDGE = 0.0,
	AL_DISTORTION_MAX_EDGE = 1.0,
	AL_DISTORTION_DEFAULT_EDGE = 0.2,
	AL_DISTORTION_MIN_GAIN = 0.01,
	AL_DISTORTION_MAX_GAIN = 1.0,
	AL_DISTORTION_DEFAULT_GAIN = 0.05,
	AL_DISTORTION_MIN_LOWPASS_CUTOFF = 80.0,
	AL_DISTORTION_MAX_LOWPASS_CUTOFF = 24000.0,
	AL_DISTORTION_DEFAULT_LOWPASS_CUTOFF = 8000.0,
	AL_DISTORTION_MIN_EQCENTER = 80.0,
	AL_DISTORTION_MAX_EQCENTER = 24000.0,
	AL_DISTORTION_DEFAULT_EQCENTER = 3600.0,
	AL_DISTORTION_MIN_EQBANDWIDTH = 80.0,
	AL_DISTORTION_MAX_EQBANDWIDTH = 24000.0,
	AL_DISTORTION_DEFAULT_EQBANDWIDTH = 3600.0,
	AL_ECHO_MIN_DELAY = 0.0,
	AL_ECHO_MAX_DELAY = 0.207,
	AL_ECHO_DEFAULT_DELAY = 0.1,
	AL_ECHO_MIN_LRDELAY = 0.0,
	AL_ECHO_MAX_LRDELAY = 0.404,
	AL_ECHO_DEFAULT_LRDELAY = 0.1,
	AL_ECHO_MIN_DAMPING = 0.0,
	AL_ECHO_MAX_DAMPING = 0.99,
	AL_ECHO_DEFAULT_DAMPING = 0.5,
	AL_ECHO_MIN_FEEDBACK = 0.0,
	AL_ECHO_MAX_FEEDBACK = 1.0,
	AL_ECHO_DEFAULT_FEEDBACK = 0.5,
	AL_ECHO_MIN_SPREAD = -1.0,
	AL_ECHO_MAX_SPREAD = 1.0,
	AL_ECHO_DEFAULT_SPREAD = -1.0,
	AL_FLANGER_WAVEFORM_SINUSOID = 0,
	AL_FLANGER_WAVEFORM_TRIANGLE = 1,
	AL_FLANGER_MIN_WAVEFORM = 0,
	AL_FLANGER_MAX_WAVEFORM = 1,
	AL_FLANGER_DEFAULT_WAVEFORM = 1,
	AL_FLANGER_MIN_PHASE = -180,
	AL_FLANGER_MAX_PHASE = 180,
	AL_FLANGER_DEFAULT_PHASE = 0,
	AL_FLANGER_MIN_RATE = 0.0,
	AL_FLANGER_MAX_RATE = 10.0,
	AL_FLANGER_DEFAULT_RATE = 0.27,
	AL_FLANGER_MIN_DEPTH = 0.0,
	AL_FLANGER_MAX_DEPTH = 1.0,
	AL_FLANGER_DEFAULT_DEPTH = 1.0,
	AL_FLANGER_MIN_FEEDBACK = -1.0,
	AL_FLANGER_MAX_FEEDBACK = 1.0,
	AL_FLANGER_DEFAULT_FEEDBACK = -0.5,
	AL_FLANGER_MIN_DELAY = 0.0,
	AL_FLANGER_MAX_DELAY = 0.004,
	AL_FLANGER_DEFAULT_DELAY = 0.002,
	AL_FREQUENCY_SHIFTER_MIN_FREQUENCY = 0.0,
	AL_FREQUENCY_SHIFTER_MAX_FREQUENCY = 24000.0,
	AL_FREQUENCY_SHIFTER_DEFAULT_FREQUENCY = 0.0,
	AL_FREQUENCY_SHIFTER_MIN_LEFT_DIRECTION = 0,
	AL_FREQUENCY_SHIFTER_MAX_LEFT_DIRECTION = 2,
	AL_FREQUENCY_SHIFTER_DEFAULT_LEFT_DIRECTION = 0,
	AL_FREQUENCY_SHIFTER_DIRECTION_DOWN = 0,
	AL_FREQUENCY_SHIFTER_DIRECTION_UP = 1,
	AL_FREQUENCY_SHIFTER_DIRECTION_OFF = 2,
	AL_FREQUENCY_SHIFTER_MIN_RIGHT_DIRECTION = 0,
	AL_FREQUENCY_SHIFTER_MAX_RIGHT_DIRECTION = 2,
	AL_FREQUENCY_SHIFTER_DEFAULT_RIGHT_DIRECTION = 0,
	AL_VOCAL_MORPHER_MIN_PHONEMEA = 0,
	AL_VOCAL_MORPHER_MAX_PHONEMEA = 29,
	AL_VOCAL_MORPHER_DEFAULT_PHONEMEA = 0,
	AL_VOCAL_MORPHER_MIN_PHONEMEA_COARSE_TUNING = -24,
	AL_VOCAL_MORPHER_MAX_PHONEMEA_COARSE_TUNING = 24,
	AL_VOCAL_MORPHER_DEFAULT_PHONEMEA_COARSE_TUNING = 0,
	AL_VOCAL_MORPHER_MIN_PHONEMEB = 0,
	AL_VOCAL_MORPHER_MAX_PHONEMEB = 29,
	AL_VOCAL_MORPHER_DEFAULT_PHONEMEB = 10,
	AL_VOCAL_MORPHER_MIN_PHONEMEB_COARSE_TUNING = -24,
	AL_VOCAL_MORPHER_MAX_PHONEMEB_COARSE_TUNING = 24,
	AL_VOCAL_MORPHER_DEFAULT_PHONEMEB_COARSE_TUNING = 0,
	AL_VOCAL_MORPHER_PHONEME_A = 0,
	AL_VOCAL_MORPHER_PHONEME_E = 1,
	AL_VOCAL_MORPHER_PHONEME_I = 2,
	AL_VOCAL_MORPHER_PHONEME_O = 3,
	AL_VOCAL_MORPHER_PHONEME_U = 4,
	AL_VOCAL_MORPHER_PHONEME_AA = 5,
	AL_VOCAL_MORPHER_PHONEME_AE = 6,
	AL_VOCAL_MORPHER_PHONEME_AH = 7,
	AL_VOCAL_MORPHER_PHONEME_AO = 8,
	AL_VOCAL_MORPHER_PHONEME_EH = 9,
	AL_VOCAL_MORPHER_PHONEME_ER = 10,
	AL_VOCAL_MORPHER_PHONEME_IH = 11,
	AL_VOCAL_MORPHER_PHONEME_IY = 12,
	AL_VOCAL_MORPHER_PHONEME_UH = 13,
	AL_VOCAL_MORPHER_PHONEME_UW = 14,
	AL_VOCAL_MORPHER_PHONEME_B = 15,
	AL_VOCAL_MORPHER_PHONEME_D = 16,
	AL_VOCAL_MORPHER_PHONEME_F = 17,
	AL_VOCAL_MORPHER_PHONEME_G = 18,
	AL_VOCAL_MORPHER_PHONEME_J = 19,
	AL_VOCAL_MORPHER_PHONEME_K = 20,
	AL_VOCAL_MORPHER_PHONEME_L = 21,
	AL_VOCAL_MORPHER_PHONEME_M = 22,
	AL_VOCAL_MORPHER_PHONEME_N = 23,
	AL_VOCAL_MORPHER_PHONEME_P = 24,
	AL_VOCAL_MORPHER_PHONEME_R = 25,
	AL_VOCAL_MORPHER_PHONEME_S = 26,
	AL_VOCAL_MORPHER_PHONEME_T = 27,
	AL_VOCAL_MORPHER_PHONEME_V = 28,
	AL_VOCAL_MORPHER_PHONEME_Z = 29,
	AL_VOCAL_MORPHER_WAVEFORM_SINUSOID = 0,
	AL_VOCAL_MORPHER_WAVEFORM_TRIANGLE = 1,
	AL_VOCAL_MORPHER_WAVEFORM_SAWTOOTH = 2,
	AL_VOCAL_MORPHER_MIN_WAVEFORM = 0,
	AL_VOCAL_MORPHER_MAX_WAVEFORM = 2,
	AL_VOCAL_MORPHER_DEFAULT_WAVEFORM = 0,
	AL_VOCAL_MORPHER_MIN_RATE = 0.0,
	AL_VOCAL_MORPHER_MAX_RATE = 10.0,
	AL_VOCAL_MORPHER_DEFAULT_RATE = 1.41,
	AL_PITCH_SHIFTER_MIN_COARSE_TUNE = -12,
	AL_PITCH_SHIFTER_MAX_COARSE_TUNE = 12,
	AL_PITCH_SHIFTER_DEFAULT_COARSE_TUNE = 12,
	AL_PITCH_SHIFTER_MIN_FINE_TUNE = -50,
	AL_PITCH_SHIFTER_MAX_FINE_TUNE = 50,
	AL_PITCH_SHIFTER_DEFAULT_FINE_TUNE = 0,
	AL_RING_MODULATOR_MIN_FREQUENCY = 0.0,
	AL_RING_MODULATOR_MAX_FREQUENCY = 8000.0,
	AL_RING_MODULATOR_DEFAULT_FREQUENCY = 440.0,
	AL_RING_MODULATOR_MIN_HIGHPASS_CUTOFF = 0.0,
	AL_RING_MODULATOR_MAX_HIGHPASS_CUTOFF = 24000.0,
	AL_RING_MODULATOR_DEFAULT_HIGHPASS_CUTOFF = 800.0,
	AL_RING_MODULATOR_SINUSOID = 0,
	AL_RING_MODULATOR_SAWTOOTH = 1,
	AL_RING_MODULATOR_SQUARE = 2,
	AL_RING_MODULATOR_MIN_WAVEFORM = 0,
	AL_RING_MODULATOR_MAX_WAVEFORM = 2,
	AL_RING_MODULATOR_DEFAULT_WAVEFORM = 0,
	AL_AUTOWAH_MIN_ATTACK_TIME = 0.0001,
	AL_AUTOWAH_MAX_ATTACK_TIME = 1.0,
	AL_AUTOWAH_DEFAULT_ATTACK_TIME = 0.06,
	AL_AUTOWAH_MIN_RELEASE_TIME = 0.0001,
	AL_AUTOWAH_MAX_RELEASE_TIME = 1.0,
	AL_AUTOWAH_DEFAULT_RELEASE_TIME = 0.06,
	AL_AUTOWAH_MIN_RESONANCE = 2.0,
	AL_AUTOWAH_MAX_RESONANCE = 1000.0,
	AL_AUTOWAH_DEFAULT_RESONANCE = 1000.0,
	AL_AUTOWAH_MIN_PEAK_GAIN = 0.00003,
	AL_AUTOWAH_MAX_PEAK_GAIN = 31621.0,
	AL_AUTOWAH_DEFAULT_PEAK_GAIN = 11.22,
	AL_COMPRESSOR_MIN_ONOFF = 0,
	AL_COMPRESSOR_MAX_ONOFF = 1,
	AL_COMPRESSOR_DEFAULT_ONOFF = 1,
	AL_EQUALIZER_MIN_LOW_GAIN = 0.126,
	AL_EQUALIZER_MAX_LOW_GAIN = 7.943,
	AL_EQUALIZER_DEFAULT_LOW_GAIN = 1.0,
	AL_EQUALIZER_MIN_LOW_CUTOFF = 50.0,
	AL_EQUALIZER_MAX_LOW_CUTOFF = 800.0,
	AL_EQUALIZER_DEFAULT_LOW_CUTOFF = 200.0,
	AL_EQUALIZER_MIN_MID1_GAIN = 0.126,
	AL_EQUALIZER_MAX_MID1_GAIN = 7.943,
	AL_EQUALIZER_DEFAULT_MID1_GAIN = 1.0,
	AL_EQUALIZER_MIN_MID1_CENTER = 200.0,
	AL_EQUALIZER_MAX_MID1_CENTER = 3000.0,
	AL_EQUALIZER_DEFAULT_MID1_CENTER = 500.0,
	AL_EQUALIZER_MIN_MID1_WIDTH = 0.01,
	AL_EQUALIZER_MAX_MID1_WIDTH = 1.0,
	AL_EQUALIZER_DEFAULT_MID1_WIDTH = 1.0,
	AL_EQUALIZER_MIN_MID2_GAIN = 0.126,
	AL_EQUALIZER_MAX_MID2_GAIN = 7.943,
	AL_EQUALIZER_DEFAULT_MID2_GAIN = 1.0,
	AL_EQUALIZER_MIN_MID2_CENTER = 1000.0,
	AL_EQUALIZER_MAX_MID2_CENTER = 8000.0,
	AL_EQUALIZER_DEFAULT_MID2_CENTER = 3000.0,
	AL_EQUALIZER_MIN_MID2_WIDTH = 0.01,
	AL_EQUALIZER_MAX_MID2_WIDTH = 1.0,
	AL_EQUALIZER_DEFAULT_MID2_WIDTH = 1.0,
	AL_EQUALIZER_MIN_HIGH_GAIN = 0.126,
	AL_EQUALIZER_MAX_HIGH_GAIN = 7.943,
	AL_EQUALIZER_DEFAULT_HIGH_GAIN = 1.0,
	AL_EQUALIZER_MIN_HIGH_CUTOFF = 4000.0,
	AL_EQUALIZER_MAX_HIGH_CUTOFF = 16000.0,
	AL_EQUALIZER_DEFAULT_HIGH_CUTOFF = 6000.0,
	AL_MIN_AIR_ABSORPTION_FACTOR = 0.0,
	AL_MAX_AIR_ABSORPTION_FACTOR = 10.0,
	AL_DEFAULT_AIR_ABSORPTION_FACTOR = 0.0,
	AL_MIN_ROOM_ROLLOFF_FACTOR = 0.0,
	AL_MAX_ROOM_ROLLOFF_FACTOR = 10.0,
	AL_DEFAULT_ROOM_ROLLOFF_FACTOR = 0.0,
	AL_MIN_CONE_OUTER_GAINHF = 0.0,
	AL_MAX_CONE_OUTER_GAINHF = 1.0,
	AL_DEFAULT_CONE_OUTER_GAINHF = 1.0,
	AL_MIN_DIRECT_FILTER_GAINHF_AUTO = 0,
	AL_MAX_DIRECT_FILTER_GAINHF_AUTO = 1,
	AL_DEFAULT_DIRECT_FILTER_GAINHF_AUTO = 1,
	AL_MIN_AUXILIARY_SEND_FILTER_GAIN_AUTO = 0,
	AL_MAX_AUXILIARY_SEND_FILTER_GAIN_AUTO = 1,
	AL_DEFAULT_AUXILIARY_SEND_FILTER_GAIN_AUTO = 1,
	AL_MIN_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 0,
	AL_MAX_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 1,
	AL_DEFAULT_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 1,
	AL_MIN_METERS_PER_UNIT = FLT_MIN,
	AL_MAX_METERS_PER_UNIT = FLT_MAX,
	AL_DEFAULT_METERS_PER_UNIT = 1.0,

	AL_MIDI_CLOCK_SOFT = 0x9999,
	AL_MIDI_GAIN_SOFT = 0x9998,
	AL_NOTEOFF_SOFT = 0x0080,
	AL_NOTEON_SOFT = 0x0090,
	AL_AFTERTOUCH_SOFT = 0x00A0,
	AL_CONTROLLERCHANGE_SOFT = 0x00B0,
	AL_PROGRAMCHANGE_SOFT = 0x00C0,
	AL_CHANNELPRESSURE_SOFT = 0x00D0,
	AL_PITCHBEND_SOFT = 0x00E0,
}
local extensions = {
	alGenEffects = "LPALGENEFFECTS",
	alDeleteEffects = "LPALDELETEEFFECTS",
	alIsEffect = "LPALISEFFECT",
	alEffecti = "LPALEFFECTI",
	alEffectiv = "LPALEFFECTIV",
	alEffectf = "LPALEFFECTF",
	alEffectfv = "LPALEFFECTFV",
	alGetEffecti = "LPALGETEFFECTI",
	alGetEffectiv = "LPALGETEFFECTIV",
	alGetEffectf = "LPALGETEFFECTF",
	alGetEffectfv = "LPALGETEFFECTFV",

	alGenFilters = "LPALGENFILTERS",
	alDeleteFilters = "LPALDELETEFILTERS",
	alIsFilter = "LPALISFILTER",
	alFilteri = "LPALFILTERI",
	alFilteriv = "LPALFILTERIV",
	alFilterf = "LPALFILTERF",
	alFilterfv = "LPALFILTERFV",
	alGetFilteri = "LPALGETFILTERI",
	alGetFilteriv = "LPALGETFILTERIV",
	alGetFilterf = "LPALGETFILTERF",
	alGetFilterfv = "LPALGETFILTERFV",

	alGenAuxiliaryEffectSlots = "LPALGENAUXILIARYEFFECTSLOTS",
	alDeleteAuxiliaryEffectSlots = "LPALDELETEAUXILIARYEFFECTSLOTS",
	alIsAuxiliaryEffectSlot = "LPALISAUXILIARYEFFECTSLOT",
	alAuxiliaryEffectSloti = "LPALAUXILIARYEFFECTSLOTI",
	alAuxiliaryEffectSlotiv = "LPALAUXILIARYEFFECTSLOTIV",
	alAuxiliaryEffectSlotf = "LPALAUXILIARYEFFECTSLOTF",
	alAuxiliaryEffectSlotfv = "LPALAUXILIARYEFFECTSLOTFV",
	alGetAuxiliaryEffectSloti = "LPALGETAUXILIARYEFFECTSLOTI",
	alGetAuxiliaryEffectSlotiv = "LPALGETAUXILIARYEFFECTSLOTIV",
	alGetAuxiliaryEffectSlotf = "LPALGETAUXILIARYEFFECTSLOTF",
	alGetAuxiliaryEffectSlotfv = "LPALGETAUXILIARYEFFECTSLOTFV",

	alBufferSamplesSOFT = "LPALBUFFERSAMPLESSOFT",
	alIsBufferFormatSupportedSOFT = "LPALISBUFFERFORMATSUPPORTEDSOFT",

	alSourcedSOFT = "LPALSOURCEDSOFT",
	alSource3dSOFT = "LPALSOURCE3DSOFT",
	alSourcedvSOFT = "LPALSOURCEDVSOFT",
	alGetSourcedSOFT = "LPALGETSOURCEDSOFT",
	alGetSource3dSOFT = "LPALGETSOURCE3DSOFT",
	alGetSourcedvSOFT = "LPALGETSOURCEDVSOFT",

	alBufferSamplesSOFT = "LPALBUFFERSAMPLESSOFT",
	alIsBufferFormatSupportedSOFT = "LPALISBUFFERFORMATSUPPORTEDSOFT",

	alGetInteger64SOFT = "ALint64SOFT(*)(ALenum pname)",
	alGetInteger64vSOFT = "void(*)(ALenum pname, ALint64SOFT *values)",

	alMidiPlaySOFT = "void(*)(void)",
	alMidiPauseSOFT = "void(*)(void)",
	alMidiStopSOFT = "void(*)(void)",
	alMidiResetSOFT = "void(*)(void)",

	alMidiGainSOFT = "void(*)(ALfloat value)",

	alIsSoundfontSOFT = "ALboolean(*)(const char *filename)",
	alMidiSoundfontSOFT = "void(*)(ALuint id)",
	alMidiSoundfontvSOFT = "void(*)(ALsizei count, const ALuint *ids)",

	alMidiEventSOFT = "void(*)(ALuint64SOFT time, ALenum event, ALsizei channel, ALsizei param1, ALsizei param2)",
	alMidiSysExSOFT = "void(*)(ALuint64SOFT time, const ALbyte *data, ALsizei size)",
	alLoadSoundfontSOFT = "void(*)(ALuint id, size_t(*cb)(ALvoid*, size_t, ALvoid*), ALvoid *user)",
}

local reverse_enums = {}
for k,v in pairs(enums) do
	k = k:gsub("AL_", "")
	k = k:gsub("_", " ")
	k = k:lower()

	reverse_enums[v] = k
end

ffi.cdef(header)

local lib = assert(ffi.load(WINDOWS and "openal32" or "openal"))

local al = {
	lib = lib,
	e = enums,
}

local function gen_available_params(type, user_unavailable) -- effect params
	local available = {}

	local unavailable = {
		last_parameter = true,
		first_parameter = true,
		type = true,
		null = true,
	}

	for k,v in pairs(user_unavailable) do
		unavailable[v] = true
	end

	local type_pattern = "AL_"..type:upper().."_(.+)"

	for key, val in pairs(enums) do
		local type = key:match(type_pattern)

		if type then
			type = type:lower()
			if not unavailable[type] then
				available[type] = {enum = val, params = {}}
			end
		end
	end

	for name, data in pairs(available) do
		for key, val in pairs(enums) do
			local param = key:match("AL_" .. name:upper() .. "_(.+)")

			if param then
				local name = param:lower()

				if param:find("DEFAULT_") then
					name = param:match("DEFAULT_(.+)")
					key = "default"
				elseif param:find("MIN_") then
					name = param:match("MIN_(.+)")
					key = "min"
				elseif param:find("MAX_") then
					name = param:match("MAX_(.+)")
					key = "max"
				else
					key = "enum"
				end

				name = name:lower()

				data.params[name] = data.params[name] or {}
				data.params[name][key] = val
			end
		end
	end

	al["GetAvailable" .. type .. "s"] = function()
		return available
	end

end

gen_available_params("Effect", {"pitch_shifter", "vocal_morpher", "frequency_shifter"})
gen_available_params("Filter", {"highpass", "bandpass"})

local function add_al_func(name, func)
	al[name] = function(...)
		local val = func(...)

		if al.logcalls then
			setlogfile("al_calls")
				logf("%s = al%s(%s)\n", serializer.GetLibrary("luadata").ToString(val), name, table.concat(tostring_args(...), ",\t"))
			setlogfile()
		end

		if name ~= "GetError" and al.debug then

			local code = al.GetError()

			if code ~= 0 then
				local str = reverse_enums[code] or "unkown error"

				local info = debug.getinfo(2)
				for i = 1, 10 do
					if info.source:find("al.lua", nil, true) then
						info = debug.getinfo(2+i)
					else
						break
					end
				end

				logf("[openal] %q in function %s at %s:%i\n", str, info.name, info.source, info.currentline)
			end
		end

		return val
	end
end

for line in header:gmatch("(.-)\n") do
	local func_name = line:match(" (al%u.-)%(")
	if func_name then
		add_al_func(func_name:sub(3), lib[func_name])
	end
end

for name, type in pairs(extensions) do
	local func = al.GetProcAddress(name)
	func = ffi.cast(type, func)

	al[name:sub(3)] = func
end

for name, func in pairs(al) do
	if name:find("Gen%u%l") then
		al[name:sub(0,-2)] = function()
			local id = ffi.new("ALuint [1]")
			al[name](1, id)
			return id[0]
		end
	end
end

return al
