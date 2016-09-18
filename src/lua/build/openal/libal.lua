local ffi = require("ffi")
ffi.cdef([[void(alGetBufferSamplesSOFT)(unsigned int,int,int,int,int,void*);
void(alGetEffectfv)(unsigned int,int,float*);
void(alEffectf)(unsigned int,int,float);
void(alBufferi)(unsigned int,int,int);
void(alSourceRewind)(unsigned int);
void(alListenerf)(int,float);
void(alDeleteEffects)(int,const unsigned int*);
void(alGetAuxiliaryEffectSlotf)(unsigned int,int,float*);
void(alGetFilteri)(unsigned int,int,int*);
void(alAuxiliaryEffectSlotiv)(unsigned int,int,const int*);
void(alGetSource3f)(unsigned int,int,float*,float*,float*);
void(alGetSourceiv)(unsigned int,int,int*);
void(alGetBufferi)(unsigned int,int,int*);
void(alSourcePlay)(unsigned int);
void(alSourcePause)(unsigned int);
char(alIsExtensionPresent)(const char*);
void(alGenEffects)(int,unsigned int*);
void(alGetListenerfv)(int,float*);
void(alGetListener3f)(int,float*,float*,float*);
void(alSourcef)(unsigned int,int,float);
void(alGetBufferiv)(unsigned int,int,int*);
void(alListener3i)(int,int,int,int);
void(alDopplerFactor)(float);
void(alListener3f)(int,float,float,float);
void(alBufferSamplesSOFT)(unsigned int,unsigned int,int,int,int,int,const void*);
char(alIsEnabled)(int);
void(alSourcefv)(unsigned int,int,const float*);
void(alGetEffectf)(unsigned int,int,float*);
void(alDeferUpdatesSOFT)();
void(alBufferData)(unsigned int,int,const void*,int,int);
void(alDeleteSources)(int,const unsigned int*);
int(alGetEnumValue)(const char*);
void(alProcessUpdatesSOFT)();
void(alGetSource3i)(unsigned int,int,int*,int*,int*);
char(alIsSource)(unsigned int);
void(alListeneri)(int,int);
void(alBuffer3i)(unsigned int,int,int,int,int);
void(alGetListenerf)(int,float*);
void(alGetFilterfv)(unsigned int,int,float*);
void(alSource3i64SOFT)(unsigned int,int,long,long,long);
void(alGetListener3i)(int,int*,int*,int*);
int(alGetInteger)(int);
void(alGetSource3i64SOFT)(unsigned int,int,long*,long*,long*);
void(alSourcePlayv)(int,const unsigned int*);
void(alSourceRewindv)(int,const unsigned int*);
void(alListenerfv)(int,const float*);
void(alGetBufferf)(unsigned int,int,float*);
void(alGetSourcei64SOFT)(unsigned int,int,long*);
void(alEnable)(int);
void(alGetFilteriv)(unsigned int,int,int*);
void(alBufferDataStatic)(const int,int,void*,int,int);
void(alSourceQueueBuffers)(unsigned int,int,const unsigned int*);
void(alRequestFoldbackStart)(int,int,int,float*,void(*callback)(int,int));
void(alSource3f)(unsigned int,int,float,float,float);
char(alIsBufferFormatSupportedSOFT)(int);
char(alIsBuffer)(unsigned int);
void(alGenSources)(int,unsigned int*);
float(alGetFloat)(int);
void(alSourcedSOFT)(unsigned int,int,double);
void(alGetSourcef)(unsigned int,int,float*);
char(alIsFilter)(unsigned int);
double(alGetDouble)(int);
void(alGenFilters)(int,unsigned int*);
void(alAuxiliaryEffectSlotf)(unsigned int,int,float);
int(alGetError)();
void(alGetSourcei64vSOFT)(unsigned int,int,long*);
void(alSource3i)(unsigned int,int,int,int,int);
void(alEffectfv)(unsigned int,int,const float*);
void(alBufferSubDataSOFT)(unsigned int,int,const void*,int,int);
void(alFilteriv)(unsigned int,int,const int*);
void(alSourcei64SOFT)(unsigned int,int,long);
void(alGetSourcedvSOFT)(unsigned int,int,double*);
void(alGetListeneri)(int,int*);
void(alBufferfv)(unsigned int,int,const float*);
void(alGetSource3dSOFT)(unsigned int,int,double*,double*,double*);
void(alDisable)(int);
void(alSourceStop)(unsigned int);
void(alGetSourcedSOFT)(unsigned int,int,double*);
void(alSourcedvSOFT)(unsigned int,int,const double*);
void(alSource3dSOFT)(unsigned int,int,double,double,double);
void(alGetBuffer3i)(unsigned int,int,int*,int*,int*);
char(alIsEffect)(unsigned int);
void(alBufferSubSamplesSOFT)(unsigned int,int,int,int,int,const void*);
void(alGetDoublev)(int,double*);
char(alIsAuxiliaryEffectSlot)(unsigned int);
void(alGetFloatv)(int,float*);
void(alGetAuxiliaryEffectSloti)(unsigned int,int,int*);
void(alFilterf)(unsigned int,int,float);
void(alGetAuxiliaryEffectSlotfv)(unsigned int,int,float*);
void(alGetAuxiliaryEffectSlotiv)(unsigned int,int,int*);
void(alAuxiliaryEffectSlotfv)(unsigned int,int,const float*);
void(alSourceStopv)(int,const unsigned int*);
void(alDopplerVelocity)(float);
void(alRequestFoldbackStop)();
void(alBufferiv)(unsigned int,int,const int*);
const char*(alGetString)(int);
void(alBuffer3f)(unsigned int,int,float,float,float);
void(alSourceiv)(unsigned int,int,const int*);
void(alGetIntegerv)(int,int*);
void(alSourceUnqueueBuffers)(unsigned int,int,unsigned int*);
void(alGetEffecti)(unsigned int,int,int*);
void(alSpeedOfSound)(float);
void(alDeleteBuffers)(int,const unsigned int*);
void(alGenBuffers)(int,unsigned int*);
void(alGetBuffer3f)(unsigned int,int,float*,float*,float*);
void(alDeleteAuxiliaryEffectSlots)(int,const unsigned int*);
void(alListeneriv)(int,const int*);
void(alSourcei64vSOFT)(unsigned int,int,const long*);
void(alDeleteFilters)(int,const unsigned int*);
void(alAuxiliaryEffectSloti)(unsigned int,int,int);
void(alSourcei)(unsigned int,int,int);
void(alGetFilterf)(unsigned int,int,float*);
void(alGenAuxiliaryEffectSlots)(int,unsigned int*);
void(alGetSourcei)(unsigned int,int,int*);
char(alGetBoolean)(int);
void(alGetSourcefv)(unsigned int,int,float*);
void(alDistanceModel)(int);
void(alGetListeneriv)(int,int*);
void(alFilterfv)(unsigned int,int,const float*);
void(alGetBooleanv)(int,char*);
void(alBufferf)(unsigned int,int,float);
void(alGetBufferfv)(unsigned int,int,float*);
void(alEffecti)(unsigned int,int,int);
void(alEffectiv)(unsigned int,int,const int*);
void*(alGetProcAddress)(const char*);
void(alGetEffectiv)(unsigned int,int,int*);
void(alSourcePausev)(int,const unsigned int*);
void(alFilteri)(unsigned int,int,int);
]])
local CLIB = ffi.load(_G.FFI_LIB or "openal")
local library = {}
local function get_proc_address(func, cast)
	local ptr = CLIB.alGetProcAddress(func)
	if ptr ~= nil then
		return ffi.cast(cast, ptr)
	end
end
library = {
	GetBufferSamplesSOFT = get_proc_address("alGetBufferSamplesSOFT", "void(* )( unsigned int , int , int , int , int , void * )"),
	GetEffectfv = get_proc_address("alGetEffectfv", "void(* )( unsigned int , int , float * )"),
	Effectf = get_proc_address("alEffectf", "void(* )( unsigned int , int , float )"),
	Bufferi = get_proc_address("alBufferi", "void(* )( unsigned int , int , int )"),
	SourceRewind = get_proc_address("alSourceRewind", "void(* )( unsigned int )"),
	Listenerf = get_proc_address("alListenerf", "void(* )( int , float )"),
	DeleteEffects = get_proc_address("alDeleteEffects", "void(* )( int , const unsigned int * )"),
	GetAuxiliaryEffectSlotf = get_proc_address("alGetAuxiliaryEffectSlotf", "void(* )( unsigned int , int , float * )"),
	GetFilteri = get_proc_address("alGetFilteri", "void(* )( unsigned int , int , int * )"),
	AuxiliaryEffectSlotiv = get_proc_address("alAuxiliaryEffectSlotiv", "void(* )( unsigned int , int , const int * )"),
	GetSource3f = get_proc_address("alGetSource3f", "void(* )( unsigned int , int , float * , float * , float * )"),
	GetSourceiv = get_proc_address("alGetSourceiv", "void(* )( unsigned int , int , int * )"),
	GetBufferi = get_proc_address("alGetBufferi", "void(* )( unsigned int , int , int * )"),
	SourcePlay = get_proc_address("alSourcePlay", "void(* )( unsigned int )"),
	SourcePause = get_proc_address("alSourcePause", "void(* )( unsigned int )"),
	IsExtensionPresent = get_proc_address("alIsExtensionPresent", "char(* )( const char * )"),
	GenEffects = get_proc_address("alGenEffects", "void(* )( int , unsigned int * )"),
	GetListenerfv = get_proc_address("alGetListenerfv", "void(* )( int , float * )"),
	GetListener3f = get_proc_address("alGetListener3f", "void(* )( int , float * , float * , float * )"),
	Sourcef = get_proc_address("alSourcef", "void(* )( unsigned int , int , float )"),
	GetBufferiv = get_proc_address("alGetBufferiv", "void(* )( unsigned int , int , int * )"),
	Listener3i = get_proc_address("alListener3i", "void(* )( int , int , int , int )"),
	DopplerFactor = get_proc_address("alDopplerFactor", "void(* )( float )"),
	Listener3f = get_proc_address("alListener3f", "void(* )( int , float , float , float )"),
	BufferSamplesSOFT = get_proc_address("alBufferSamplesSOFT", "void(* )( unsigned int , unsigned int , int , int , int , int , const void * )"),
	IsEnabled = get_proc_address("alIsEnabled", "char(* )( int )"),
	Sourcefv = get_proc_address("alSourcefv", "void(* )( unsigned int , int , const float * )"),
	GetEffectf = get_proc_address("alGetEffectf", "void(* )( unsigned int , int , float * )"),
	DeferUpdatesSOFT = get_proc_address("alDeferUpdatesSOFT", "void(* )(  )"),
	BufferData = get_proc_address("alBufferData", "void(* )( unsigned int , int , const void * , int , int )"),
	DeleteSources = get_proc_address("alDeleteSources", "void(* )( int , const unsigned int * )"),
	GetEnumValue = get_proc_address("alGetEnumValue", "int(* )( const char * )"),
	ProcessUpdatesSOFT = get_proc_address("alProcessUpdatesSOFT", "void(* )(  )"),
	GetSource3i = get_proc_address("alGetSource3i", "void(* )( unsigned int , int , int * , int * , int * )"),
	IsSource = get_proc_address("alIsSource", "char(* )( unsigned int )"),
	Listeneri = get_proc_address("alListeneri", "void(* )( int , int )"),
	Buffer3i = get_proc_address("alBuffer3i", "void(* )( unsigned int , int , int , int , int )"),
	GetListenerf = get_proc_address("alGetListenerf", "void(* )( int , float * )"),
	GetFilterfv = get_proc_address("alGetFilterfv", "void(* )( unsigned int , int , float * )"),
	Source3i64SOFT = get_proc_address("alSource3i64SOFT", "void(* )( unsigned int , int , long , long , long )"),
	GetListener3i = get_proc_address("alGetListener3i", "void(* )( int , int * , int * , int * )"),
	GetInteger = get_proc_address("alGetInteger", "int(* )( int )"),
	GetSource3i64SOFT = get_proc_address("alGetSource3i64SOFT", "void(* )( unsigned int , int , long * , long * , long * )"),
	SourcePlayv = get_proc_address("alSourcePlayv", "void(* )( int , const unsigned int * )"),
	SourceRewindv = get_proc_address("alSourceRewindv", "void(* )( int , const unsigned int * )"),
	Listenerfv = get_proc_address("alListenerfv", "void(* )( int , const float * )"),
	GetBufferf = get_proc_address("alGetBufferf", "void(* )( unsigned int , int , float * )"),
	GetSourcei64SOFT = get_proc_address("alGetSourcei64SOFT", "void(* )( unsigned int , int , long * )"),
	Enable = get_proc_address("alEnable", "void(* )( int )"),
	GetFilteriv = get_proc_address("alGetFilteriv", "void(* )( unsigned int , int , int * )"),
	BufferDataStatic = get_proc_address("alBufferDataStatic", "void(* )( const int , int , void * , int , int )"),
	SourceQueueBuffers = get_proc_address("alSourceQueueBuffers", "void(* )( unsigned int , int , const unsigned int * )"),
	RequestFoldbackStart = get_proc_address("alRequestFoldbackStart", "void(* )( int , int , int , float * , void(* callback)( int , int ) )"),
	Source3f = get_proc_address("alSource3f", "void(* )( unsigned int , int , float , float , float )"),
	IsBufferFormatSupportedSOFT = get_proc_address("alIsBufferFormatSupportedSOFT", "char(* )( int )"),
	IsBuffer = get_proc_address("alIsBuffer", "char(* )( unsigned int )"),
	GenSources = get_proc_address("alGenSources", "void(* )( int , unsigned int * )"),
	GetFloat = get_proc_address("alGetFloat", "float(* )( int )"),
	SourcedSOFT = get_proc_address("alSourcedSOFT", "void(* )( unsigned int , int , double )"),
	GetSourcef = get_proc_address("alGetSourcef", "void(* )( unsigned int , int , float * )"),
	IsFilter = get_proc_address("alIsFilter", "char(* )( unsigned int )"),
	GetDouble = get_proc_address("alGetDouble", "double(* )( int )"),
	GenFilters = get_proc_address("alGenFilters", "void(* )( int , unsigned int * )"),
	AuxiliaryEffectSlotf = get_proc_address("alAuxiliaryEffectSlotf", "void(* )( unsigned int , int , float )"),
	GetError = get_proc_address("alGetError", "int(* )(  )"),
	GetSourcei64vSOFT = get_proc_address("alGetSourcei64vSOFT", "void(* )( unsigned int , int , long * )"),
	Source3i = get_proc_address("alSource3i", "void(* )( unsigned int , int , int , int , int )"),
	Effectfv = get_proc_address("alEffectfv", "void(* )( unsigned int , int , const float * )"),
	BufferSubDataSOFT = get_proc_address("alBufferSubDataSOFT", "void(* )( unsigned int , int , const void * , int , int )"),
	Filteriv = get_proc_address("alFilteriv", "void(* )( unsigned int , int , const int * )"),
	Sourcei64SOFT = get_proc_address("alSourcei64SOFT", "void(* )( unsigned int , int , long )"),
	GetSourcedvSOFT = get_proc_address("alGetSourcedvSOFT", "void(* )( unsigned int , int , double * )"),
	GetListeneri = get_proc_address("alGetListeneri", "void(* )( int , int * )"),
	Bufferfv = get_proc_address("alBufferfv", "void(* )( unsigned int , int , const float * )"),
	GetSource3dSOFT = get_proc_address("alGetSource3dSOFT", "void(* )( unsigned int , int , double * , double * , double * )"),
	Disable = get_proc_address("alDisable", "void(* )( int )"),
	SourceStop = get_proc_address("alSourceStop", "void(* )( unsigned int )"),
	GetSourcedSOFT = get_proc_address("alGetSourcedSOFT", "void(* )( unsigned int , int , double * )"),
	SourcedvSOFT = get_proc_address("alSourcedvSOFT", "void(* )( unsigned int , int , const double * )"),
	Source3dSOFT = get_proc_address("alSource3dSOFT", "void(* )( unsigned int , int , double , double , double )"),
	GetBuffer3i = get_proc_address("alGetBuffer3i", "void(* )( unsigned int , int , int * , int * , int * )"),
	IsEffect = get_proc_address("alIsEffect", "char(* )( unsigned int )"),
	BufferSubSamplesSOFT = get_proc_address("alBufferSubSamplesSOFT", "void(* )( unsigned int , int , int , int , int , const void * )"),
	GetDoublev = get_proc_address("alGetDoublev", "void(* )( int , double * )"),
	IsAuxiliaryEffectSlot = get_proc_address("alIsAuxiliaryEffectSlot", "char(* )( unsigned int )"),
	GetFloatv = get_proc_address("alGetFloatv", "void(* )( int , float * )"),
	GetAuxiliaryEffectSloti = get_proc_address("alGetAuxiliaryEffectSloti", "void(* )( unsigned int , int , int * )"),
	Filterf = get_proc_address("alFilterf", "void(* )( unsigned int , int , float )"),
	GetAuxiliaryEffectSlotfv = get_proc_address("alGetAuxiliaryEffectSlotfv", "void(* )( unsigned int , int , float * )"),
	GetAuxiliaryEffectSlotiv = get_proc_address("alGetAuxiliaryEffectSlotiv", "void(* )( unsigned int , int , int * )"),
	AuxiliaryEffectSlotfv = get_proc_address("alAuxiliaryEffectSlotfv", "void(* )( unsigned int , int , const float * )"),
	SourceStopv = get_proc_address("alSourceStopv", "void(* )( int , const unsigned int * )"),
	DopplerVelocity = get_proc_address("alDopplerVelocity", "void(* )( float )"),
	RequestFoldbackStop = get_proc_address("alRequestFoldbackStop", "void(* )(  )"),
	Bufferiv = get_proc_address("alBufferiv", "void(* )( unsigned int , int , const int * )"),
	GetString = get_proc_address("alGetString", "const char *(* )( int )"),
	Buffer3f = get_proc_address("alBuffer3f", "void(* )( unsigned int , int , float , float , float )"),
	Sourceiv = get_proc_address("alSourceiv", "void(* )( unsigned int , int , const int * )"),
	GetIntegerv = get_proc_address("alGetIntegerv", "void(* )( int , int * )"),
	SourceUnqueueBuffers = get_proc_address("alSourceUnqueueBuffers", "void(* )( unsigned int , int , unsigned int * )"),
	GetEffecti = get_proc_address("alGetEffecti", "void(* )( unsigned int , int , int * )"),
	SpeedOfSound = get_proc_address("alSpeedOfSound", "void(* )( float )"),
	DeleteBuffers = get_proc_address("alDeleteBuffers", "void(* )( int , const unsigned int * )"),
	GenBuffers = get_proc_address("alGenBuffers", "void(* )( int , unsigned int * )"),
	GetBuffer3f = get_proc_address("alGetBuffer3f", "void(* )( unsigned int , int , float * , float * , float * )"),
	DeleteAuxiliaryEffectSlots = get_proc_address("alDeleteAuxiliaryEffectSlots", "void(* )( int , const unsigned int * )"),
	Listeneriv = get_proc_address("alListeneriv", "void(* )( int , const int * )"),
	Sourcei64vSOFT = get_proc_address("alSourcei64vSOFT", "void(* )( unsigned int , int , const long * )"),
	DeleteFilters = get_proc_address("alDeleteFilters", "void(* )( int , const unsigned int * )"),
	AuxiliaryEffectSloti = get_proc_address("alAuxiliaryEffectSloti", "void(* )( unsigned int , int , int )"),
	Sourcei = get_proc_address("alSourcei", "void(* )( unsigned int , int , int )"),
	GetFilterf = get_proc_address("alGetFilterf", "void(* )( unsigned int , int , float * )"),
	GenAuxiliaryEffectSlots = get_proc_address("alGenAuxiliaryEffectSlots", "void(* )( int , unsigned int * )"),
	GetSourcei = get_proc_address("alGetSourcei", "void(* )( unsigned int , int , int * )"),
	GetBoolean = get_proc_address("alGetBoolean", "char(* )( int )"),
	GetSourcefv = get_proc_address("alGetSourcefv", "void(* )( unsigned int , int , float * )"),
	DistanceModel = get_proc_address("alDistanceModel", "void(* )( int )"),
	GetListeneriv = get_proc_address("alGetListeneriv", "void(* )( int , int * )"),
	Filterfv = get_proc_address("alFilterfv", "void(* )( unsigned int , int , const float * )"),
	GetBooleanv = get_proc_address("alGetBooleanv", "void(* )( int , char * )"),
	Bufferf = get_proc_address("alBufferf", "void(* )( unsigned int , int , float )"),
	GetBufferfv = get_proc_address("alGetBufferfv", "void(* )( unsigned int , int , float * )"),
	Effecti = get_proc_address("alEffecti", "void(* )( unsigned int , int , int )"),
	Effectiv = get_proc_address("alEffectiv", "void(* )( unsigned int , int , const int * )"),
	GetProcAddress = get_proc_address("alGetProcAddress", "void *(* )( const char * )"),
	GetEffectiv = get_proc_address("alGetEffectiv", "void(* )( unsigned int , int , int * )"),
	SourcePausev = get_proc_address("alSourcePausev", "void(* )( int , const unsigned int * )"),
	Filteri = get_proc_address("alFilteri", "void(* )( unsigned int , int , int )"),
}
library.e = {
	ALC_H = 1,
	ALEXT_H = 1,
	LOKI_IMA_ADPCM_format = 1,
	FORMAT_IMA_ADPCM_MONO16_EXT = 65536,
	FORMAT_IMA_ADPCM_STEREO16_EXT = 65537,
	LOKI_WAVE_format = 1,
	FORMAT_WAVE_EXT = 65538,
	EXT_vorbis = 1,
	FORMAT_VORBIS_EXT = 65539,
	LOKI_quadriphonic = 1,
	FORMAT_QUAD8_LOKI = 65540,
	FORMAT_QUAD16_LOKI = 65541,
	EXT_float32 = 1,
	FORMAT_MONO_FLOAT32 = 65552,
	FORMAT_STEREO_FLOAT32 = 65553,
	EXT_double = 1,
	FORMAT_MONO_DOUBLE_EXT = 65554,
	FORMAT_STEREO_DOUBLE_EXT = 65555,
	EXT_MULAW = 1,
	FORMAT_MONO_MULAW_EXT = 65556,
	FORMAT_STEREO_MULAW_EXT = 65557,
	EXT_ALAW = 1,
	FORMAT_MONO_ALAW_EXT = 65558,
	FORMAT_STEREO_ALAW_EXT = 65559,
	EXT_MCFORMATS = 1,
	FORMAT_QUAD8 = 4612,
	FORMAT_QUAD16 = 4613,
	FORMAT_QUAD32 = 4614,
	FORMAT_REAR8 = 4615,
	FORMAT_REAR16 = 4616,
	FORMAT_REAR32 = 4617,
	FORMAT_51CHN8 = 4618,
	FORMAT_51CHN16 = 4619,
	FORMAT_51CHN32 = 4620,
	FORMAT_61CHN8 = 4621,
	FORMAT_61CHN16 = 4622,
	FORMAT_61CHN32 = 4623,
	FORMAT_71CHN8 = 4624,
	FORMAT_71CHN16 = 4625,
	FORMAT_71CHN32 = 4626,
	EXT_MULAW_MCFORMATS = 1,
	FORMAT_MONO_MULAW = 65556,
	FORMAT_STEREO_MULAW = 65557,
	FORMAT_QUAD_MULAW = 65569,
	FORMAT_REAR_MULAW = 65570,
	FORMAT_51CHN_MULAW = 65571,
	FORMAT_61CHN_MULAW = 65572,
	FORMAT_71CHN_MULAW = 65573,
	EXT_IMA4 = 1,
	FORMAT_MONO_IMA4 = 4864,
	FORMAT_STEREO_IMA4 = 4865,
	EXT_STATIC_BUFFER = 1,
	EXT_source_distance_model = 1,
	SOURCE_DISTANCE_MODEL = 512,
	SOFT_buffer_sub_data = 1,
	BYTE_RW_OFFSETS_SOFT = 4145,
	SAMPLE_RW_OFFSETS_SOFT = 4146,
	SOFT_loop_points = 1,
	LOOP_POINTS_SOFT = 8213,
	EXT_FOLDBACK = 1,
	EXT_FOLDBACK_NAME = "1",
	FOLDBACK_EVENT_BLOCK = 16658,
	FOLDBACK_EVENT_START = 16657,
	FOLDBACK_EVENT_STOP = 16659,
	FOLDBACK_MODE_MONO = 16641,
	FOLDBACK_MODE_STEREO = 16642,
	DEDICATED_GAIN = 1,
	EFFECT_DEDICATED_DIALOGUE = 36865,
	EFFECT_DEDICATED_LOW_FREQUENCY_EFFECT = 36864,
	SOFT_buffer_samples = 1,
	MONO_SOFT = 5376,
	STEREO_SOFT = 5377,
	REAR_SOFT = 5378,
	QUAD_SOFT = 5379,
	_5POINT1_SOFT = 5380,
	_6POINT1_SOFT = 5381,
	_7POINT1_SOFT = 5382,
	BYTE_SOFT = 5120,
	UNSIGNED_BYTE_SOFT = 5121,
	SHORT_SOFT = 5122,
	UNSIGNED_SHORT_SOFT = 5123,
	INT_SOFT = 5124,
	UNSIGNED_INT_SOFT = 5125,
	FLOAT_SOFT = 5126,
	DOUBLE_SOFT = 5127,
	BYTE3_SOFT = 5128,
	UNSIGNED_BYTE3_SOFT = 5129,
	MONO8_SOFT = 4352,
	MONO16_SOFT = 4353,
	MONO32F_SOFT = 65552,
	STEREO8_SOFT = 4354,
	STEREO16_SOFT = 4355,
	STEREO32F_SOFT = 65553,
	QUAD8_SOFT = 4612,
	QUAD16_SOFT = 4613,
	QUAD32F_SOFT = 4614,
	REAR8_SOFT = 4615,
	REAR16_SOFT = 4616,
	REAR32F_SOFT = 4617,
	_5POINT1_8_SOFT = 4618,
	_5POINT1_16_SOFT = 4619,
	_5POINT1_32F_SOFT = 4620,
	_6POINT1_8_SOFT = 4621,
	_6POINT1_16_SOFT = 4622,
	_6POINT1_32F_SOFT = 4623,
	_7POINT1_8_SOFT = 4624,
	_7POINT1_16_SOFT = 4625,
	_7POINT1_32F_SOFT = 4626,
	INTERNAL_FORMAT_SOFT = 8200,
	BYTE_LENGTH_SOFT = 8201,
	SAMPLE_LENGTH_SOFT = 8202,
	SEC_LENGTH_SOFT = 8203,
	SOFT_direct_channels = 1,
	DIRECT_CHANNELS_SOFT = 4147,
	EXT_STEREO_ANGLES = 1,
	STEREO_ANGLES = 4144,
	EXT_SOURCE_RADIUS = 1,
	SOURCE_RADIUS = 4145,
	SOFT_source_latency = 1,
	SAMPLE_OFFSET_LATENCY_SOFT = 4608,
	SEC_OFFSET_LATENCY_SOFT = 4609,
	SOFT_deferred_updates = 1,
	DEFERRED_UPDATES_SOFT = 49154,
	SOFT_block_alignment = 1,
	UNPACK_BLOCK_ALIGNMENT_SOFT = 8204,
	PACK_BLOCK_ALIGNMENT_SOFT = 8205,
	SOFT_MSADPCM = 1,
	FORMAT_MONO_MSADPCM_SOFT = 4866,
	FORMAT_STEREO_MSADPCM_SOFT = 4867,
	SOFT_source_length = 1,
	EXT_BFORMAT = 1,
	FORMAT_BFORMAT2D_8 = 131105,
	FORMAT_BFORMAT2D_16 = 131106,
	FORMAT_BFORMAT2D_FLOAT32 = 131107,
	FORMAT_BFORMAT3D_8 = 131121,
	FORMAT_BFORMAT3D_16 = 131122,
	FORMAT_BFORMAT3D_FLOAT32 = 131123,
	EXT_MULAW_BFORMAT = 1,
	FORMAT_BFORMAT2D_MULAW = 65585,
	FORMAT_BFORMAT3D_MULAW = 65586,
	AL_H = 1,
	API = 1,
	API = extern,
	APIENTRY = __cdecl,
	APIENTRY = 1,
	INVALID = -1,
	ILLEGAL_ENUM = AL_INVALID_ENUM,
	ILLEGAL_COMMAND = AL_INVALID_OPERATION,
	VERSION_1_0 = 1,
	VERSION_1_1 = 1,
	NONE = 0,
	FALSE = 0,
	TRUE = 1,
	SOURCE_RELATIVE = 514,
	CONE_INNER_ANGLE = 4097,
	CONE_OUTER_ANGLE = 4098,
	PITCH = 4099,
	POSITION = 4100,
	DIRECTION = 4101,
	VELOCITY = 4102,
	LOOPING = 4103,
	BUFFER = 4105,
	GAIN = 4106,
	MIN_GAIN = 4109,
	MAX_GAIN = 4110,
	ORIENTATION = 4111,
	SOURCE_STATE = 4112,
	INITIAL = 4113,
	PLAYING = 4114,
	PAUSED = 4115,
	STOPPED = 4116,
	BUFFERS_QUEUED = 4117,
	BUFFERS_PROCESSED = 4118,
	REFERENCE_DISTANCE = 4128,
	ROLLOFF_FACTOR = 4129,
	CONE_OUTER_GAIN = 4130,
	MAX_DISTANCE = 4131,
	SEC_OFFSET = 4132,
	SAMPLE_OFFSET = 4133,
	BYTE_OFFSET = 4134,
	SOURCE_TYPE = 4135,
	STATIC = 4136,
	STREAMING = 4137,
	UNDETERMINED = 4144,
	FORMAT_MONO8 = 4352,
	FORMAT_MONO16 = 4353,
	FORMAT_STEREO8 = 4354,
	FORMAT_STEREO16 = 4355,
	FREQUENCY = 8193,
	BITS = 8194,
	CHANNELS = 8195,
	SIZE = 8196,
	UNUSED = 8208,
	PENDING = 8209,
	PROCESSED = 8210,
	NO_ERROR = 0,
	INVALID_NAME = 40961,
	INVALID_ENUM = 40962,
	INVALID_VALUE = 40963,
	INVALID_OPERATION = 40964,
	OUT_OF_MEMORY = 40965,
	VENDOR = 45057,
	VERSION = 45058,
	RENDERER = 45059,
	EXTENSIONS = 45060,
	DOPPLER_FACTOR = 49152,
	DOPPLER_VELOCITY = 49153,
	SPEED_OF_SOUND = 49155,
	DISTANCE_MODEL = 53248,
	INVERSE_DISTANCE = 53249,
	INVERSE_DISTANCE_CLAMPED = 53250,
	LINEAR_DISTANCE = 53251,
	LINEAR_DISTANCE_CLAMPED = 53252,
	EXPONENT_DISTANCE = 53253,
	EXPONENT_DISTANCE_CLAMPED = 53254,
	EFX_H = 1,
	METERS_PER_UNIT = 131076,
	DIRECT_FILTER = 131077,
	AUXILIARY_SEND_FILTER = 131078,
	AIR_ABSORPTION_FACTOR = 131079,
	ROOM_ROLLOFF_FACTOR = 131080,
	CONE_OUTER_GAINHF = 131081,
	DIRECT_FILTER_GAINHF_AUTO = 131082,
	AUXILIARY_SEND_FILTER_GAIN_AUTO = 131083,
	AUXILIARY_SEND_FILTER_GAINHF_AUTO = 131084,
	REVERB_DENSITY = 1,
	REVERB_DIFFUSION = 2,
	REVERB_GAIN = 3,
	REVERB_GAINHF = 4,
	REVERB_DECAY_TIME = 5,
	REVERB_DECAY_HFRATIO = 6,
	REVERB_REFLECTIONS_GAIN = 7,
	REVERB_REFLECTIONS_DELAY = 8,
	REVERB_LATE_REVERB_GAIN = 9,
	REVERB_LATE_REVERB_DELAY = 10,
	REVERB_AIR_ABSORPTION_GAINHF = 11,
	REVERB_ROOM_ROLLOFF_FACTOR = 12,
	REVERB_DECAY_HFLIMIT = 13,
	EAXREVERB_DENSITY = 1,
	EAXREVERB_DIFFUSION = 2,
	EAXREVERB_GAIN = 3,
	EAXREVERB_GAINHF = 4,
	EAXREVERB_GAINLF = 5,
	EAXREVERB_DECAY_TIME = 6,
	EAXREVERB_DECAY_HFRATIO = 7,
	EAXREVERB_DECAY_LFRATIO = 8,
	EAXREVERB_REFLECTIONS_GAIN = 9,
	EAXREVERB_REFLECTIONS_DELAY = 10,
	EAXREVERB_REFLECTIONS_PAN = 11,
	EAXREVERB_LATE_REVERB_GAIN = 12,
	EAXREVERB_LATE_REVERB_DELAY = 13,
	EAXREVERB_LATE_REVERB_PAN = 14,
	EAXREVERB_ECHO_TIME = 15,
	EAXREVERB_ECHO_DEPTH = 16,
	EAXREVERB_MODULATION_TIME = 17,
	EAXREVERB_MODULATION_DEPTH = 18,
	EAXREVERB_AIR_ABSORPTION_GAINHF = 19,
	EAXREVERB_HFREFERENCE = 20,
	EAXREVERB_LFREFERENCE = 21,
	EAXREVERB_ROOM_ROLLOFF_FACTOR = 22,
	EAXREVERB_DECAY_HFLIMIT = 23,
	CHORUS_WAVEFORM = 1,
	CHORUS_PHASE = 2,
	CHORUS_RATE = 3,
	CHORUS_DEPTH = 4,
	CHORUS_FEEDBACK = 5,
	CHORUS_DELAY = 6,
	DISTORTION_EDGE = 1,
	DISTORTION_GAIN = 2,
	DISTORTION_LOWPASS_CUTOFF = 3,
	DISTORTION_EQCENTER = 4,
	DISTORTION_EQBANDWIDTH = 5,
	ECHO_DELAY = 1,
	ECHO_LRDELAY = 2,
	ECHO_DAMPING = 3,
	ECHO_FEEDBACK = 4,
	ECHO_SPREAD = 5,
	FLANGER_WAVEFORM = 1,
	FLANGER_PHASE = 2,
	FLANGER_RATE = 3,
	FLANGER_DEPTH = 4,
	FLANGER_FEEDBACK = 5,
	FLANGER_DELAY = 6,
	FREQUENCY_SHIFTER_FREQUENCY = 1,
	FREQUENCY_SHIFTER_LEFT_DIRECTION = 2,
	FREQUENCY_SHIFTER_RIGHT_DIRECTION = 3,
	VOCAL_MORPHER_PHONEMEA = 1,
	VOCAL_MORPHER_PHONEMEA_COARSE_TUNING = 2,
	VOCAL_MORPHER_PHONEMEB = 3,
	VOCAL_MORPHER_PHONEMEB_COARSE_TUNING = 4,
	VOCAL_MORPHER_WAVEFORM = 5,
	VOCAL_MORPHER_RATE = 6,
	PITCH_SHIFTER_COARSE_TUNE = 1,
	PITCH_SHIFTER_FINE_TUNE = 2,
	RING_MODULATOR_FREQUENCY = 1,
	RING_MODULATOR_HIGHPASS_CUTOFF = 2,
	RING_MODULATOR_WAVEFORM = 3,
	AUTOWAH_ATTACK_TIME = 1,
	AUTOWAH_RELEASE_TIME = 2,
	AUTOWAH_RESONANCE = 3,
	AUTOWAH_PEAK_GAIN = 4,
	COMPRESSOR_ONOFF = 1,
	EQUALIZER_LOW_GAIN = 1,
	EQUALIZER_LOW_CUTOFF = 2,
	EQUALIZER_MID1_GAIN = 3,
	EQUALIZER_MID1_CENTER = 4,
	EQUALIZER_MID1_WIDTH = 5,
	EQUALIZER_MID2_GAIN = 6,
	EQUALIZER_MID2_CENTER = 7,
	EQUALIZER_MID2_WIDTH = 8,
	EQUALIZER_HIGH_GAIN = 9,
	EQUALIZER_HIGH_CUTOFF = 10,
	EFFECT_FIRST_PARAMETER = 0,
	EFFECT_LAST_PARAMETER = 32768,
	EFFECT_TYPE = 32769,
	EFFECT_NULL = 0,
	EFFECT_REVERB = 1,
	EFFECT_CHORUS = 2,
	EFFECT_DISTORTION = 3,
	EFFECT_ECHO = 4,
	EFFECT_FLANGER = 5,
	EFFECT_FREQUENCY_SHIFTER = 6,
	EFFECT_VOCAL_MORPHER = 7,
	EFFECT_PITCH_SHIFTER = 8,
	EFFECT_RING_MODULATOR = 9,
	EFFECT_AUTOWAH = 10,
	EFFECT_COMPRESSOR = 11,
	EFFECT_EQUALIZER = 12,
	EFFECT_EAXREVERB = 32768,
	EFFECTSLOT_EFFECT = 1,
	EFFECTSLOT_GAIN = 2,
	EFFECTSLOT_AUXILIARY_SEND_AUTO = 3,
	EFFECTSLOT_NULL = 0,
	LOWPASS_GAIN = 1,
	LOWPASS_GAINHF = 2,
	HIGHPASS_GAIN = 1,
	HIGHPASS_GAINLF = 2,
	BANDPASS_GAIN = 1,
	BANDPASS_GAINLF = 2,
	BANDPASS_GAINHF = 3,
	FILTER_FIRST_PARAMETER = 0,
	FILTER_LAST_PARAMETER = 32768,
	FILTER_TYPE = 32769,
	FILTER_NULL = 0,
	FILTER_LOWPASS = 1,
	FILTER_HIGHPASS = 2,
	FILTER_BANDPASS = 3,
	LOWPASS_MIN_GAIN = 0,
	LOWPASS_MAX_GAIN = 1,
	LOWPASS_DEFAULT_GAIN = 1,
	LOWPASS_MIN_GAINHF = 0,
	LOWPASS_MAX_GAINHF = 1,
	LOWPASS_DEFAULT_GAINHF = 1,
	HIGHPASS_MIN_GAIN = 0,
	HIGHPASS_MAX_GAIN = 1,
	HIGHPASS_DEFAULT_GAIN = 1,
	HIGHPASS_MIN_GAINLF = 0,
	HIGHPASS_MAX_GAINLF = 1,
	HIGHPASS_DEFAULT_GAINLF = 1,
	BANDPASS_MIN_GAIN = 0,
	BANDPASS_MAX_GAIN = 1,
	BANDPASS_DEFAULT_GAIN = 1,
	BANDPASS_MIN_GAINHF = 0,
	BANDPASS_MAX_GAINHF = 1,
	BANDPASS_DEFAULT_GAINHF = 1,
	BANDPASS_MIN_GAINLF = 0,
	BANDPASS_MAX_GAINLF = 1,
	BANDPASS_DEFAULT_GAINLF = 1,
	REVERB_MIN_DENSITY = 0,
	REVERB_MAX_DENSITY = 1,
	REVERB_DEFAULT_DENSITY = 1,
	REVERB_MIN_DIFFUSION = 0,
	REVERB_MAX_DIFFUSION = 1,
	REVERB_DEFAULT_DIFFUSION = 1,
	REVERB_MIN_GAIN = 0,
	REVERB_MAX_GAIN = 1,
	REVERB_DEFAULT_GAIN = 0.32,
	REVERB_MIN_GAINHF = 0,
	REVERB_MAX_GAINHF = 1,
	REVERB_DEFAULT_GAINHF = 0.89,
	REVERB_MIN_DECAY_TIME = 0.1,
	REVERB_MAX_DECAY_TIME = 20,
	REVERB_DEFAULT_DECAY_TIME = 1.49,
	REVERB_MIN_DECAY_HFRATIO = 0.1,
	REVERB_MAX_DECAY_HFRATIO = 2,
	REVERB_DEFAULT_DECAY_HFRATIO = 0.83,
	REVERB_MIN_REFLECTIONS_GAIN = 0,
	REVERB_MAX_REFLECTIONS_GAIN = 3.16,
	REVERB_DEFAULT_REFLECTIONS_GAIN = 0.05,
	REVERB_MIN_REFLECTIONS_DELAY = 0,
	REVERB_MAX_REFLECTIONS_DELAY = 0.3,
	REVERB_DEFAULT_REFLECTIONS_DELAY = 0.007,
	REVERB_MIN_LATE_REVERB_GAIN = 0,
	REVERB_MAX_LATE_REVERB_GAIN = 10,
	REVERB_DEFAULT_LATE_REVERB_GAIN = 1.26,
	REVERB_MIN_LATE_REVERB_DELAY = 0,
	REVERB_MAX_LATE_REVERB_DELAY = 0.1,
	REVERB_DEFAULT_LATE_REVERB_DELAY = 0.011,
	REVERB_MIN_AIR_ABSORPTION_GAINHF = 0.892,
	REVERB_MAX_AIR_ABSORPTION_GAINHF = 1,
	REVERB_DEFAULT_AIR_ABSORPTION_GAINHF = 0.994,
	REVERB_MIN_ROOM_ROLLOFF_FACTOR = 0,
	REVERB_MAX_ROOM_ROLLOFF_FACTOR = 10,
	REVERB_DEFAULT_ROOM_ROLLOFF_FACTOR = 0,
	REVERB_MIN_DECAY_HFLIMIT = AL_FALSE,
	REVERB_MAX_DECAY_HFLIMIT = AL_TRUE,
	REVERB_DEFAULT_DECAY_HFLIMIT = AL_TRUE,
	EAXREVERB_MIN_DENSITY = 0,
	EAXREVERB_MAX_DENSITY = 1,
	EAXREVERB_DEFAULT_DENSITY = 1,
	EAXREVERB_MIN_DIFFUSION = 0,
	EAXREVERB_MAX_DIFFUSION = 1,
	EAXREVERB_DEFAULT_DIFFUSION = 1,
	EAXREVERB_MIN_GAIN = 0,
	EAXREVERB_MAX_GAIN = 1,
	EAXREVERB_DEFAULT_GAIN = 0.32,
	EAXREVERB_MIN_GAINHF = 0,
	EAXREVERB_MAX_GAINHF = 1,
	EAXREVERB_DEFAULT_GAINHF = 0.89,
	EAXREVERB_MIN_GAINLF = 0,
	EAXREVERB_MAX_GAINLF = 1,
	EAXREVERB_DEFAULT_GAINLF = 1,
	EAXREVERB_MIN_DECAY_TIME = 0.1,
	EAXREVERB_MAX_DECAY_TIME = 20,
	EAXREVERB_DEFAULT_DECAY_TIME = 1.49,
	EAXREVERB_MIN_DECAY_HFRATIO = 0.1,
	EAXREVERB_MAX_DECAY_HFRATIO = 2,
	EAXREVERB_DEFAULT_DECAY_HFRATIO = 0.83,
	EAXREVERB_MIN_DECAY_LFRATIO = 0.1,
	EAXREVERB_MAX_DECAY_LFRATIO = 2,
	EAXREVERB_DEFAULT_DECAY_LFRATIO = 1,
	EAXREVERB_MIN_REFLECTIONS_GAIN = 0,
	EAXREVERB_MAX_REFLECTIONS_GAIN = 3.16,
	EAXREVERB_DEFAULT_REFLECTIONS_GAIN = 0.05,
	EAXREVERB_MIN_REFLECTIONS_DELAY = 0,
	EAXREVERB_MAX_REFLECTIONS_DELAY = 0.3,
	EAXREVERB_DEFAULT_REFLECTIONS_DELAY = 0.007,
	EAXREVERB_DEFAULT_REFLECTIONS_PAN_XYZ = 0,
	EAXREVERB_MIN_LATE_REVERB_GAIN = 0,
	EAXREVERB_MAX_LATE_REVERB_GAIN = 10,
	EAXREVERB_DEFAULT_LATE_REVERB_GAIN = 1.26,
	EAXREVERB_MIN_LATE_REVERB_DELAY = 0,
	EAXREVERB_MAX_LATE_REVERB_DELAY = 0.1,
	EAXREVERB_DEFAULT_LATE_REVERB_DELAY = 0.011,
	EAXREVERB_DEFAULT_LATE_REVERB_PAN_XYZ = 0,
	EAXREVERB_MIN_ECHO_TIME = 0.075,
	EAXREVERB_MAX_ECHO_TIME = 0.25,
	EAXREVERB_DEFAULT_ECHO_TIME = 0.25,
	EAXREVERB_MIN_ECHO_DEPTH = 0,
	EAXREVERB_MAX_ECHO_DEPTH = 1,
	EAXREVERB_DEFAULT_ECHO_DEPTH = 0,
	EAXREVERB_MIN_MODULATION_TIME = 0.04,
	EAXREVERB_MAX_MODULATION_TIME = 4,
	EAXREVERB_DEFAULT_MODULATION_TIME = 0.25,
	EAXREVERB_MIN_MODULATION_DEPTH = 0,
	EAXREVERB_MAX_MODULATION_DEPTH = 1,
	EAXREVERB_DEFAULT_MODULATION_DEPTH = 0,
	EAXREVERB_MIN_AIR_ABSORPTION_GAINHF = 0.892,
	EAXREVERB_MAX_AIR_ABSORPTION_GAINHF = 1,
	EAXREVERB_DEFAULT_AIR_ABSORPTION_GAINHF = 0.994,
	EAXREVERB_MIN_HFREFERENCE = 1000,
	EAXREVERB_MAX_HFREFERENCE = 20000,
	EAXREVERB_DEFAULT_HFREFERENCE = 5000,
	EAXREVERB_MIN_LFREFERENCE = 20,
	EAXREVERB_MAX_LFREFERENCE = 1000,
	EAXREVERB_DEFAULT_LFREFERENCE = 250,
	EAXREVERB_MIN_ROOM_ROLLOFF_FACTOR = 0,
	EAXREVERB_MAX_ROOM_ROLLOFF_FACTOR = 10,
	EAXREVERB_DEFAULT_ROOM_ROLLOFF_FACTOR = 0,
	EAXREVERB_MIN_DECAY_HFLIMIT = AL_FALSE,
	EAXREVERB_MAX_DECAY_HFLIMIT = AL_TRUE,
	EAXREVERB_DEFAULT_DECAY_HFLIMIT = AL_TRUE,
	CHORUS_WAVEFORM_SINUSOID = 0,
	CHORUS_WAVEFORM_TRIANGLE = 1,
	CHORUS_MIN_WAVEFORM = 0,
	CHORUS_MAX_WAVEFORM = 1,
	CHORUS_DEFAULT_WAVEFORM = 1,
	CHORUS_MIN_PHASE = -180,
	CHORUS_MAX_PHASE = 180,
	CHORUS_DEFAULT_PHASE = 90,
	CHORUS_MIN_RATE = 0,
	CHORUS_MAX_RATE = 10,
	CHORUS_DEFAULT_RATE = 1.1,
	CHORUS_MIN_DEPTH = 0,
	CHORUS_MAX_DEPTH = 1,
	CHORUS_DEFAULT_DEPTH = 0.1,
	CHORUS_MIN_FEEDBACK = -1,
	CHORUS_MAX_FEEDBACK = 1,
	CHORUS_DEFAULT_FEEDBACK = 0.25,
	CHORUS_MIN_DELAY = 0,
	CHORUS_MAX_DELAY = 0.016,
	CHORUS_DEFAULT_DELAY = 0.016,
	DISTORTION_MIN_EDGE = 0,
	DISTORTION_MAX_EDGE = 1,
	DISTORTION_DEFAULT_EDGE = 0.2,
	DISTORTION_MIN_GAIN = 0.01,
	DISTORTION_MAX_GAIN = 1,
	DISTORTION_DEFAULT_GAIN = 0.05,
	DISTORTION_MIN_LOWPASS_CUTOFF = 80,
	DISTORTION_MAX_LOWPASS_CUTOFF = 24000,
	DISTORTION_DEFAULT_LOWPASS_CUTOFF = 8000,
	DISTORTION_MIN_EQCENTER = 80,
	DISTORTION_MAX_EQCENTER = 24000,
	DISTORTION_DEFAULT_EQCENTER = 3600,
	DISTORTION_MIN_EQBANDWIDTH = 80,
	DISTORTION_MAX_EQBANDWIDTH = 24000,
	DISTORTION_DEFAULT_EQBANDWIDTH = 3600,
	ECHO_MIN_DELAY = 0,
	ECHO_MAX_DELAY = 0.207,
	ECHO_DEFAULT_DELAY = 0.1,
	ECHO_MIN_LRDELAY = 0,
	ECHO_MAX_LRDELAY = 0.404,
	ECHO_DEFAULT_LRDELAY = 0.1,
	ECHO_MIN_DAMPING = 0,
	ECHO_MAX_DAMPING = 0.99,
	ECHO_DEFAULT_DAMPING = 0.5,
	ECHO_MIN_FEEDBACK = 0,
	ECHO_MAX_FEEDBACK = 1,
	ECHO_DEFAULT_FEEDBACK = 0.5,
	ECHO_MIN_SPREAD = -1,
	ECHO_MAX_SPREAD = 1,
	ECHO_DEFAULT_SPREAD = -1,
	FLANGER_WAVEFORM_SINUSOID = 0,
	FLANGER_WAVEFORM_TRIANGLE = 1,
	FLANGER_MIN_WAVEFORM = 0,
	FLANGER_MAX_WAVEFORM = 1,
	FLANGER_DEFAULT_WAVEFORM = 1,
	FLANGER_MIN_PHASE = -180,
	FLANGER_MAX_PHASE = 180,
	FLANGER_DEFAULT_PHASE = 0,
	FLANGER_MIN_RATE = 0,
	FLANGER_MAX_RATE = 10,
	FLANGER_DEFAULT_RATE = 0.27,
	FLANGER_MIN_DEPTH = 0,
	FLANGER_MAX_DEPTH = 1,
	FLANGER_DEFAULT_DEPTH = 1,
	FLANGER_MIN_FEEDBACK = -1,
	FLANGER_MAX_FEEDBACK = 1,
	FLANGER_DEFAULT_FEEDBACK = -0.5,
	FLANGER_MIN_DELAY = 0,
	FLANGER_MAX_DELAY = 0.004,
	FLANGER_DEFAULT_DELAY = 0.002,
	FREQUENCY_SHIFTER_MIN_FREQUENCY = 0,
	FREQUENCY_SHIFTER_MAX_FREQUENCY = 24000,
	FREQUENCY_SHIFTER_DEFAULT_FREQUENCY = 0,
	FREQUENCY_SHIFTER_MIN_LEFT_DIRECTION = 0,
	FREQUENCY_SHIFTER_MAX_LEFT_DIRECTION = 2,
	FREQUENCY_SHIFTER_DEFAULT_LEFT_DIRECTION = 0,
	FREQUENCY_SHIFTER_DIRECTION_DOWN = 0,
	FREQUENCY_SHIFTER_DIRECTION_UP = 1,
	FREQUENCY_SHIFTER_DIRECTION_OFF = 2,
	FREQUENCY_SHIFTER_MIN_RIGHT_DIRECTION = 0,
	FREQUENCY_SHIFTER_MAX_RIGHT_DIRECTION = 2,
	FREQUENCY_SHIFTER_DEFAULT_RIGHT_DIRECTION = 0,
	VOCAL_MORPHER_MIN_PHONEMEA = 0,
	VOCAL_MORPHER_MAX_PHONEMEA = 29,
	VOCAL_MORPHER_DEFAULT_PHONEMEA = 0,
	VOCAL_MORPHER_MIN_PHONEMEA_COARSE_TUNING = -24,
	VOCAL_MORPHER_MAX_PHONEMEA_COARSE_TUNING = 24,
	VOCAL_MORPHER_DEFAULT_PHONEMEA_COARSE_TUNING = 0,
	VOCAL_MORPHER_MIN_PHONEMEB = 0,
	VOCAL_MORPHER_MAX_PHONEMEB = 29,
	VOCAL_MORPHER_DEFAULT_PHONEMEB = 10,
	VOCAL_MORPHER_MIN_PHONEMEB_COARSE_TUNING = -24,
	VOCAL_MORPHER_MAX_PHONEMEB_COARSE_TUNING = 24,
	VOCAL_MORPHER_DEFAULT_PHONEMEB_COARSE_TUNING = 0,
	VOCAL_MORPHER_PHONEME_A = 0,
	VOCAL_MORPHER_PHONEME_E = 1,
	VOCAL_MORPHER_PHONEME_I = 2,
	VOCAL_MORPHER_PHONEME_O = 3,
	VOCAL_MORPHER_PHONEME_U = 4,
	VOCAL_MORPHER_PHONEME_AA = 5,
	VOCAL_MORPHER_PHONEME_AE = 6,
	VOCAL_MORPHER_PHONEME_AH = 7,
	VOCAL_MORPHER_PHONEME_AO = 8,
	VOCAL_MORPHER_PHONEME_EH = 9,
	VOCAL_MORPHER_PHONEME_ER = 10,
	VOCAL_MORPHER_PHONEME_IH = 11,
	VOCAL_MORPHER_PHONEME_IY = 12,
	VOCAL_MORPHER_PHONEME_UH = 13,
	VOCAL_MORPHER_PHONEME_UW = 14,
	VOCAL_MORPHER_PHONEME_B = 15,
	VOCAL_MORPHER_PHONEME_D = 16,
	VOCAL_MORPHER_PHONEME_F = 17,
	VOCAL_MORPHER_PHONEME_G = 18,
	VOCAL_MORPHER_PHONEME_J = 19,
	VOCAL_MORPHER_PHONEME_K = 20,
	VOCAL_MORPHER_PHONEME_L = 21,
	VOCAL_MORPHER_PHONEME_M = 22,
	VOCAL_MORPHER_PHONEME_N = 23,
	VOCAL_MORPHER_PHONEME_P = 24,
	VOCAL_MORPHER_PHONEME_R = 25,
	VOCAL_MORPHER_PHONEME_S = 26,
	VOCAL_MORPHER_PHONEME_T = 27,
	VOCAL_MORPHER_PHONEME_V = 28,
	VOCAL_MORPHER_PHONEME_Z = 29,
	VOCAL_MORPHER_WAVEFORM_SINUSOID = 0,
	VOCAL_MORPHER_WAVEFORM_TRIANGLE = 1,
	VOCAL_MORPHER_WAVEFORM_SAWTOOTH = 2,
	VOCAL_MORPHER_MIN_WAVEFORM = 0,
	VOCAL_MORPHER_MAX_WAVEFORM = 2,
	VOCAL_MORPHER_DEFAULT_WAVEFORM = 0,
	VOCAL_MORPHER_MIN_RATE = 0,
	VOCAL_MORPHER_MAX_RATE = 10,
	VOCAL_MORPHER_DEFAULT_RATE = 1.41,
	PITCH_SHIFTER_MIN_COARSE_TUNE = -12,
	PITCH_SHIFTER_MAX_COARSE_TUNE = 12,
	PITCH_SHIFTER_DEFAULT_COARSE_TUNE = 12,
	PITCH_SHIFTER_MIN_FINE_TUNE = -50,
	PITCH_SHIFTER_MAX_FINE_TUNE = 50,
	PITCH_SHIFTER_DEFAULT_FINE_TUNE = 0,
	RING_MODULATOR_MIN_FREQUENCY = 0,
	RING_MODULATOR_MAX_FREQUENCY = 8000,
	RING_MODULATOR_DEFAULT_FREQUENCY = 440,
	RING_MODULATOR_MIN_HIGHPASS_CUTOFF = 0,
	RING_MODULATOR_MAX_HIGHPASS_CUTOFF = 24000,
	RING_MODULATOR_DEFAULT_HIGHPASS_CUTOFF = 800,
	RING_MODULATOR_SINUSOID = 0,
	RING_MODULATOR_SAWTOOTH = 1,
	RING_MODULATOR_SQUARE = 2,
	RING_MODULATOR_MIN_WAVEFORM = 0,
	RING_MODULATOR_MAX_WAVEFORM = 2,
	RING_MODULATOR_DEFAULT_WAVEFORM = 0,
	AUTOWAH_MIN_ATTACK_TIME = 0.0001,
	AUTOWAH_MAX_ATTACK_TIME = 1,
	AUTOWAH_DEFAULT_ATTACK_TIME = 0.06,
	AUTOWAH_MIN_RELEASE_TIME = 0.0001,
	AUTOWAH_MAX_RELEASE_TIME = 1,
	AUTOWAH_DEFAULT_RELEASE_TIME = 0.06,
	AUTOWAH_MIN_RESONANCE = 2,
	AUTOWAH_MAX_RESONANCE = 1000,
	AUTOWAH_DEFAULT_RESONANCE = 1000,
	AUTOWAH_MIN_PEAK_GAIN = 3e-05,
	AUTOWAH_MAX_PEAK_GAIN = 31621,
	AUTOWAH_DEFAULT_PEAK_GAIN = 11.22,
	COMPRESSOR_MIN_ONOFF = 0,
	COMPRESSOR_MAX_ONOFF = 1,
	COMPRESSOR_DEFAULT_ONOFF = 1,
	EQUALIZER_MIN_LOW_GAIN = 0.126,
	EQUALIZER_MAX_LOW_GAIN = 7.943,
	EQUALIZER_DEFAULT_LOW_GAIN = 1,
	EQUALIZER_MIN_LOW_CUTOFF = 50,
	EQUALIZER_MAX_LOW_CUTOFF = 800,
	EQUALIZER_DEFAULT_LOW_CUTOFF = 200,
	EQUALIZER_MIN_MID1_GAIN = 0.126,
	EQUALIZER_MAX_MID1_GAIN = 7.943,
	EQUALIZER_DEFAULT_MID1_GAIN = 1,
	EQUALIZER_MIN_MID1_CENTER = 200,
	EQUALIZER_MAX_MID1_CENTER = 3000,
	EQUALIZER_DEFAULT_MID1_CENTER = 500,
	EQUALIZER_MIN_MID1_WIDTH = 0.01,
	EQUALIZER_MAX_MID1_WIDTH = 1,
	EQUALIZER_DEFAULT_MID1_WIDTH = 1,
	EQUALIZER_MIN_MID2_GAIN = 0.126,
	EQUALIZER_MAX_MID2_GAIN = 7.943,
	EQUALIZER_DEFAULT_MID2_GAIN = 1,
	EQUALIZER_MIN_MID2_CENTER = 1000,
	EQUALIZER_MAX_MID2_CENTER = 8000,
	EQUALIZER_DEFAULT_MID2_CENTER = 3000,
	EQUALIZER_MIN_MID2_WIDTH = 0.01,
	EQUALIZER_MAX_MID2_WIDTH = 1,
	EQUALIZER_DEFAULT_MID2_WIDTH = 1,
	EQUALIZER_MIN_HIGH_GAIN = 0.126,
	EQUALIZER_MAX_HIGH_GAIN = 7.943,
	EQUALIZER_DEFAULT_HIGH_GAIN = 1,
	EQUALIZER_MIN_HIGH_CUTOFF = 4000,
	EQUALIZER_MAX_HIGH_CUTOFF = 16000,
	EQUALIZER_DEFAULT_HIGH_CUTOFF = 6000,
	MIN_AIR_ABSORPTION_FACTOR = 0,
	MAX_AIR_ABSORPTION_FACTOR = 10,
	DEFAULT_AIR_ABSORPTION_FACTOR = 0,
	MIN_ROOM_ROLLOFF_FACTOR = 0,
	MAX_ROOM_ROLLOFF_FACTOR = 10,
	DEFAULT_ROOM_ROLLOFF_FACTOR = 0,
	MIN_CONE_OUTER_GAINHF = 0,
	MAX_CONE_OUTER_GAINHF = 1,
	DEFAULT_CONE_OUTER_GAINHF = 1,
	MIN_DIRECT_FILTER_GAINHF_AUTO = AL_FALSE,
	MAX_DIRECT_FILTER_GAINHF_AUTO = AL_TRUE,
	DEFAULT_DIRECT_FILTER_GAINHF_AUTO = AL_TRUE,
	MIN_AUXILIARY_SEND_FILTER_GAIN_AUTO = AL_FALSE,
	MAX_AUXILIARY_SEND_FILTER_GAIN_AUTO = AL_TRUE,
	DEFAULT_AUXILIARY_SEND_FILTER_GAIN_AUTO = AL_TRUE,
	MIN_AUXILIARY_SEND_FILTER_GAINHF_AUTO = AL_FALSE,
	MAX_AUXILIARY_SEND_FILTER_GAINHF_AUTO = AL_TRUE,
	DEFAULT_AUXILIARY_SEND_FILTER_GAINHF_AUTO = AL_TRUE,
	MIN_METERS_PER_UNIT = FLT_MIN,
	MAX_METERS_PER_UNIT = FLT_MAX,
	DEFAULT_METERS_PER_UNIT = 1,
}
library.EffectParams = {
	compressor = {
		enum = 11,
		params = {
			onoff = {
				max = 1,
				enum = 1,
				min = 0,
				default = 1,
			},
		},
	},
	dedicated_dialogue = {
		enum = 36865,
		params = {
		},
	},
	reverb = {
		enum = 1,
		params = {
			modulation_depth = {
				max = 1,
				enum = 18,
				min = 0,
				default = 0,
			},
			late_reverb_pan = {
				enum = 14,
			},
			reflections_gain = {
				max = 3.16,
				enum = 9,
				min = 0,
				default = 0.05,
			},
			gainlf = {
				max = 1,
				enum = 5,
				min = 0,
				default = 1,
			},
			gainhf = {
				max = 1,
				enum = 4,
				min = 0,
				default = 0.89,
			},
			density = {
				max = 1,
				enum = 1,
				min = 0,
				default = 1,
			},
			reflections_pan_xyz = {
				default = 0,
			},
			room_rolloff_factor = {
				max = 10,
				enum = 22,
				min = 0,
				default = 0,
			},
			echo_depth = {
				max = 1,
				enum = 16,
				min = 0,
				default = 0,
			},
			late_reverb_delay = {
				max = 0.1,
				enum = 13,
				min = 0,
				default = 0.011,
			},
			air_absorption_gainhf = {
				max = 1,
				enum = 19,
				min = 0.892,
				default = 0.994,
			},
			modulation_time = {
				max = 4,
				enum = 17,
				min = 0.04,
				default = 0.25,
			},
			hfreference = {
				max = 20000,
				enum = 20,
				min = 1000,
				default = 5000,
			},
			lfreference = {
				max = 1000,
				enum = 21,
				min = 20,
				default = 250,
			},
			decay_lfratio = {
				max = 2,
				enum = 8,
				min = 0.1,
				default = 1,
			},
			echo_time = {
				max = 0.25,
				enum = 15,
				min = 0.075,
				default = 0.25,
			},
			reflections_delay = {
				max = 0.3,
				enum = 8,
				min = 0,
				default = 0.007,
			},
			late_reverb_pan_xyz = {
				default = 0,
			},
			decay_time = {
				max = 20,
				enum = 6,
				min = 0.1,
				default = 1.49,
			},
			decay_hflimit = {
				enum = 23,
			},
			decay_hfratio = {
				max = 2,
				enum = 6,
				min = 0.1,
				default = 0.83,
			},
			gain = {
				max = 1,
				enum = 3,
				min = 0,
				default = 0.32,
			},
			late_reverb_gain = {
				max = 10,
				enum = 12,
				min = 0,
				default = 1.26,
			},
			diffusion = {
				max = 1,
				enum = 2,
				min = 0,
				default = 1,
			},
			reflections_pan = {
				enum = 11,
			},
		},
	},
	dedicated_low_frequency_effect = {
		enum = 36864,
		params = {
		},
	},
	eaxreverb = {
		enum = 32768,
		params = {
			modulation_depth = {
				max = 1,
				enum = 18,
				min = 0,
				default = 0,
			},
			late_reverb_pan = {
				enum = 14,
			},
			reflections_gain = {
				max = 3.16,
				enum = 9,
				min = 0,
				default = 0.05,
			},
			gainlf = {
				max = 1,
				enum = 5,
				min = 0,
				default = 1,
			},
			gainhf = {
				max = 1,
				enum = 4,
				min = 0,
				default = 0.89,
			},
			density = {
				max = 1,
				enum = 1,
				min = 0,
				default = 1,
			},
			reflections_pan_xyz = {
				default = 0,
			},
			room_rolloff_factor = {
				max = 10,
				enum = 22,
				min = 0,
				default = 0,
			},
			late_reverb_pan_xyz = {
				default = 0,
			},
			late_reverb_delay = {
				max = 0.1,
				enum = 13,
				min = 0,
				default = 0.011,
			},
			air_absorption_gainhf = {
				max = 1,
				enum = 19,
				min = 0.892,
				default = 0.994,
			},
			decay_time = {
				max = 20,
				enum = 6,
				min = 0.1,
				default = 1.49,
			},
			reflections_pan = {
				enum = 11,
			},
			lfreference = {
				max = 1000,
				enum = 21,
				min = 20,
				default = 250,
			},
			reflections_delay = {
				max = 0.3,
				enum = 10,
				min = 0,
				default = 0.007,
			},
			echo_time = {
				max = 0.25,
				enum = 15,
				min = 0.075,
				default = 0.25,
			},
			hfreference = {
				max = 20000,
				enum = 20,
				min = 1000,
				default = 5000,
			},
			decay_lfratio = {
				max = 2,
				enum = 8,
				min = 0.1,
				default = 1,
			},
			modulation_time = {
				max = 4,
				enum = 17,
				min = 0.04,
				default = 0.25,
			},
			decay_hflimit = {
				enum = 23,
			},
			gain = {
				max = 1,
				enum = 3,
				min = 0,
				default = 0.32,
			},
			echo_depth = {
				max = 1,
				enum = 16,
				min = 0,
				default = 0,
			},
			late_reverb_gain = {
				max = 10,
				enum = 12,
				min = 0,
				default = 1.26,
			},
			diffusion = {
				max = 1,
				enum = 2,
				min = 0,
				default = 1,
			},
			decay_hfratio = {
				max = 2,
				enum = 7,
				min = 0.1,
				default = 0.83,
			},
		},
	},
	equalizer = {
		enum = 12,
		params = {
			mid1_center = {
				max = 3000,
				enum = 4,
				min = 200,
				default = 500,
			},
			mid1_width = {
				max = 1,
				enum = 5,
				min = 0.01,
				default = 1,
			},
			mid2_center = {
				max = 8000,
				enum = 7,
				min = 1000,
				default = 3000,
			},
			mid2_gain = {
				max = 7.943,
				enum = 6,
				min = 0.126,
				default = 1,
			},
			mid2_width = {
				max = 1,
				enum = 8,
				min = 0.01,
				default = 1,
			},
			low_gain = {
				max = 7.943,
				enum = 1,
				min = 0.126,
				default = 1,
			},
			high_cutoff = {
				max = 16000,
				enum = 10,
				min = 4000,
				default = 6000,
			},
			mid1_gain = {
				max = 7.943,
				enum = 3,
				min = 0.126,
				default = 1,
			},
			low_cutoff = {
				max = 800,
				enum = 2,
				min = 50,
				default = 200,
			},
			high_gain = {
				max = 7.943,
				enum = 9,
				min = 0.126,
				default = 1,
			},
		},
	},
	distortion = {
		enum = 3,
		params = {
			eqcenter = {
				max = 24000,
				enum = 4,
				min = 80,
				default = 3600,
			},
			edge = {
				max = 1,
				enum = 1,
				min = 0,
				default = 0.2,
			},
			lowpass_cutoff = {
				max = 24000,
				enum = 3,
				min = 80,
				default = 8000,
			},
			gain = {
				max = 1,
				enum = 2,
				min = 0.01,
				default = 0.05,
			},
			eqbandwidth = {
				max = 24000,
				enum = 5,
				min = 80,
				default = 3600,
			},
		},
	},
	flanger = {
		enum = 5,
		params = {
			waveform_sinusoid = {
				enum = 0,
			},
			phase = {
				max = 180,
				enum = 2,
				min = -180,
				default = 0,
			},
			waveform = {
				max = 1,
				enum = 1,
				min = 0,
				default = 1,
			},
			rate = {
				max = 10,
				enum = 3,
				min = 0,
				default = 0.27,
			},
			delay = {
				max = 0.004,
				enum = 6,
				min = 0,
				default = 0.002,
			},
			depth = {
				max = 1,
				enum = 4,
				min = 0,
				default = 1,
			},
			feedback = {
				max = 1,
				enum = 5,
				min = -1,
				default = -0.5,
			},
			waveform_triangle = {
				enum = 1,
			},
		},
	},
	chorus = {
		enum = 2,
		params = {
			waveform_sinusoid = {
				enum = 0,
			},
			phase = {
				max = 180,
				enum = 2,
				min = -180,
				default = 90,
			},
			waveform = {
				max = 1,
				enum = 1,
				min = 0,
				default = 1,
			},
			rate = {
				max = 10,
				enum = 3,
				min = 0,
				default = 1.1,
			},
			feedback = {
				max = 1,
				enum = 5,
				min = -1,
				default = 0.25,
			},
			delay = {
				max = 0.016,
				enum = 6,
				min = 0,
				default = 0.016,
			},
			depth = {
				max = 1,
				enum = 4,
				min = 0,
				default = 0.1,
			},
			waveform_triangle = {
				enum = 1,
			},
		},
	},
	ring_modulator = {
		enum = 9,
		params = {
			square = {
				enum = 2,
			},
			sinusoid = {
				enum = 0,
			},
			highpass_cutoff = {
				max = 24000,
				enum = 2,
				min = 0,
				default = 800,
			},
			frequency = {
				max = 8000,
				enum = 1,
				min = 0,
				default = 440,
			},
			waveform = {
				max = 2,
				enum = 3,
				min = 0,
				default = 0,
			},
			sawtooth = {
				enum = 1,
			},
		},
	},
	autowah = {
		enum = 10,
		params = {
			release_time = {
				max = 1,
				enum = 2,
				min = 0.0001,
				default = 0.06,
			},
			resonance = {
				max = 1000,
				enum = 3,
				min = 2,
				default = 1000,
			},
			attack_time = {
				max = 1,
				enum = 1,
				min = 0.0001,
				default = 0.06,
			},
			peak_gain = {
				max = 31621,
				enum = 4,
				min = 3e-05,
				default = 11.22,
			},
		},
	},
	echo = {
		enum = 4,
		params = {
			spread = {
				max = 1,
				enum = 5,
				min = -1,
				default = -1,
			},
			lrdelay = {
				max = 0.404,
				enum = 2,
				min = 0,
				default = 0.1,
			},
			delay = {
				max = 0.207,
				enum = 1,
				min = 0,
				default = 0.1,
			},
			damping = {
				max = 0.99,
				enum = 3,
				min = 0,
				default = 0.5,
			},
			time = {
				enum = 0.075,
			},
			feedback = {
				max = 1,
				enum = 4,
				min = 0,
				default = 0.5,
			},
			depth = {
				enum = 16,
			},
		},
	},
}
function library.GetAvailableEffects()
	return library.EffectParams
end
library.FilterParams = {
	gainhf_auto = {
		enum = 131082,
		params = {
		},
	},
	gain_auto = {
		enum = 131083,
		params = {
		},
	},
	lowpass = {
		enum = 1,
		params = {
			gainhf = {
				max = 1,
				enum = 2,
				min = 0,
				default = 1,
			},
			gain = {
				max = 1,
				enum = 1,
				min = 0,
				default = 1,
			},
			cutoff = {
				enum = 3,
			},
		},
	},
}
function library.GetAvailableFilters()
	return library.FilterParams
end
function library.GenEffect()
	local id = ffi.new("unsigned int[1]")
	library.GenEffects(1, id)
	return id[0]
end
function library.GenSource()
	local id = ffi.new("unsigned int[1]")
	library.GenSources(1, id)
	return id[0]
end
function library.GenFilter()
	local id = ffi.new("unsigned int[1]")
	library.GenFilters(1, id)
	return id[0]
end
function library.GenBuffer()
	local id = ffi.new("unsigned int[1]")
	library.GenBuffers(1, id)
	return id[0]
end
function library.GenAuxiliaryEffectSlot()
	local id = ffi.new("unsigned int[1]")
	library.GenAuxiliaryEffectSlots(1, id)
	return id[0]
end
function library.GetErrorString()
	local num = library.GetError()

	if num == library.e.NO_ERROR then
		return "no error"
	elseif num == library.e.INVALID_NAME then
		return "invalid name"
	elseif num == library.e.INVALID_ENUM then
		return "invalid enum"
	elseif num == library.e.INVALID_VALUE then
		return "invalid value"
	elseif num == library.e.INVALID_OPERATION then
		return "invalid operation"
	elseif num == library.e.OUT_OF_MEMORY then
		return "out of memory"
	end
end
library.clib = CLIB
return library
