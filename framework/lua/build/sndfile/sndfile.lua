local ffi = require("ffi")
ffi.cdef([[enum{SF_FORMAT_WAV=65536,SF_FORMAT_AIFF=131072,SF_FORMAT_AU=196608,SF_FORMAT_RAW=262144,SF_FORMAT_PAF=327680,SF_FORMAT_SVX=393216,SF_FORMAT_NIST=458752,SF_FORMAT_VOC=524288,SF_FORMAT_IRCAM=655360,SF_FORMAT_W64=720896,SF_FORMAT_MAT4=786432,SF_FORMAT_MAT5=851968,SF_FORMAT_PVF=917504,SF_FORMAT_XI=983040,SF_FORMAT_HTK=1048576,SF_FORMAT_SDS=1114112,SF_FORMAT_AVR=1179648,SF_FORMAT_WAVEX=1245184,SF_FORMAT_SD2=1441792,SF_FORMAT_FLAC=1507328,SF_FORMAT_CAF=1572864,SF_FORMAT_WVE=1638400,SF_FORMAT_OGG=2097152,SF_FORMAT_MPC2K=2162688,SF_FORMAT_RF64=2228224,SF_FORMAT_PCM_S8=1,SF_FORMAT_PCM_16=2,SF_FORMAT_PCM_24=3,SF_FORMAT_PCM_32=4,SF_FORMAT_PCM_U8=5,SF_FORMAT_FLOAT=6,SF_FORMAT_DOUBLE=7,SF_FORMAT_ULAW=16,SF_FORMAT_ALAW=17,SF_FORMAT_IMA_ADPCM=18,SF_FORMAT_MS_ADPCM=19,SF_FORMAT_GSM610=32,SF_FORMAT_VOX_ADPCM=33,SF_FORMAT_G721_32=48,SF_FORMAT_G723_24=49,SF_FORMAT_G723_40=50,SF_FORMAT_DWVW_12=64,SF_FORMAT_DWVW_16=65,SF_FORMAT_DWVW_24=66,SF_FORMAT_DWVW_N=67,SF_FORMAT_DPCM_8=80,SF_FORMAT_DPCM_16=81,SF_FORMAT_VORBIS=96,SF_FORMAT_ALAC_16=112,SF_FORMAT_ALAC_20=113,SF_FORMAT_ALAC_24=114,SF_FORMAT_ALAC_32=115,SF_ENDIAN_FILE=0,SF_ENDIAN_LITTLE=268435456,SF_ENDIAN_BIG=536870912,SF_ENDIAN_CPU=805306368,SF_FORMAT_SUBMASK=65535,SF_FORMAT_TYPEMASK=268369920,SF_FORMAT_ENDMASK=805306368,
SFC_GET_LIB_VERSION=4096,SFC_GET_LOG_INFO=4097,SFC_GET_CURRENT_SF_INFO=4098,SFC_GET_NORM_DOUBLE=4112,SFC_GET_NORM_FLOAT=4113,SFC_SET_NORM_DOUBLE=4114,SFC_SET_NORM_FLOAT=4115,SFC_SET_SCALE_FLOAT_INT_READ=4116,SFC_SET_SCALE_INT_FLOAT_WRITE=4117,SFC_GET_SIMPLE_FORMAT_COUNT=4128,SFC_GET_SIMPLE_FORMAT=4129,SFC_GET_FORMAT_INFO=4136,SFC_GET_FORMAT_MAJOR_COUNT=4144,SFC_GET_FORMAT_MAJOR=4145,SFC_GET_FORMAT_SUBTYPE_COUNT=4146,SFC_GET_FORMAT_SUBTYPE=4147,SFC_CALC_SIGNAL_MAX=4160,SFC_CALC_NORM_SIGNAL_MAX=4161,SFC_CALC_MAX_ALL_CHANNELS=4162,SFC_CALC_NORM_MAX_ALL_CHANNELS=4163,SFC_GET_SIGNAL_MAX=4164,SFC_GET_MAX_ALL_CHANNELS=4165,SFC_SET_ADD_PEAK_CHUNK=4176,SFC_SET_ADD_HEADER_PAD_CHUNK=4177,SFC_UPDATE_HEADER_NOW=4192,SFC_SET_UPDATE_HEADER_AUTO=4193,SFC_FILE_TRUNCATE=4224,SFC_SET_RAW_START_OFFSET=4240,SFC_SET_DITHER_ON_WRITE=4256,SFC_SET_DITHER_ON_READ=4257,SFC_GET_DITHER_INFO_COUNT=4258,SFC_GET_DITHER_INFO=4259,SFC_GET_EMBED_FILE_INFO=4272,SFC_SET_CLIPPING=4288,SFC_GET_CLIPPING=4289,SFC_GET_CUE_COUNT=4301,SFC_GET_CUE=4302,SFC_SET_CUE=4303,SFC_GET_INSTRUMENT=4304,SFC_SET_INSTRUMENT=4305,SFC_GET_LOOP_INFO=4320,SFC_GET_BROADCAST_INFO=4336,SFC_SET_BROADCAST_INFO=4337,SFC_GET_CHANNEL_MAP_INFO=4352,SFC_SET_CHANNEL_MAP_INFO=4353,SFC_RAW_DATA_NEEDS_ENDSWAP=4368,SFC_WAVEX_SET_AMBISONIC=4608,SFC_WAVEX_GET_AMBISONIC=4609,SFC_RF64_AUTO_DOWNGRADE=4624,SFC_SET_VBR_ENCODING_QUALITY=4864,SFC_SET_COMPRESSION_LEVEL=4865,SFC_SET_CART_INFO=5120,SFC_GET_CART_INFO=5121,SFC_TEST_IEEE_FLOAT_REPLACE=24577,SFC_SET_ADD_DITHER_ON_WRITE=4208,SFC_SET_ADD_DITHER_ON_READ=4209,
SF_STR_TITLE=1,SF_STR_COPYRIGHT=2,SF_STR_SOFTWARE=3,SF_STR_ARTIST=4,SF_STR_COMMENT=5,SF_STR_DATE=6,SF_STR_ALBUM=7,SF_STR_LICENSE=8,SF_STR_TRACKNUMBER=9,SF_STR_GENRE=16,
SF_FALSE=0,SF_TRUE=1,SFM_READ=16,SFM_WRITE=32,SFM_RDWR=48,SF_AMBISONIC_NONE=64,SF_AMBISONIC_B_FORMAT=65,
SF_ERR_NO_ERROR=0,SF_ERR_UNRECOGNISED_FORMAT=1,SF_ERR_SYSTEM=2,SF_ERR_MALFORMED_FILE=3,SF_ERR_UNSUPPORTED_ENCODING=4,
SF_CHANNEL_MAP_INVALID=0,SF_CHANNEL_MAP_MONO=1,SF_CHANNEL_MAP_LEFT=2,SF_CHANNEL_MAP_RIGHT=3,SF_CHANNEL_MAP_CENTER=4,SF_CHANNEL_MAP_FRONT_LEFT=5,SF_CHANNEL_MAP_FRONT_RIGHT=6,SF_CHANNEL_MAP_FRONT_CENTER=7,SF_CHANNEL_MAP_REAR_CENTER=8,SF_CHANNEL_MAP_REAR_LEFT=9,SF_CHANNEL_MAP_REAR_RIGHT=10,SF_CHANNEL_MAP_LFE=11,SF_CHANNEL_MAP_FRONT_LEFT_OF_CENTER=12,SF_CHANNEL_MAP_FRONT_RIGHT_OF_CENTER=13,SF_CHANNEL_MAP_SIDE_LEFT=14,SF_CHANNEL_MAP_SIDE_RIGHT=15,SF_CHANNEL_MAP_TOP_CENTER=16,SF_CHANNEL_MAP_TOP_FRONT_LEFT=17,SF_CHANNEL_MAP_TOP_FRONT_RIGHT=18,SF_CHANNEL_MAP_TOP_FRONT_CENTER=19,SF_CHANNEL_MAP_TOP_REAR_LEFT=20,SF_CHANNEL_MAP_TOP_REAR_RIGHT=21,SF_CHANNEL_MAP_TOP_REAR_CENTER=22,SF_CHANNEL_MAP_AMBISONIC_B_W=23,SF_CHANNEL_MAP_AMBISONIC_B_X=24,SF_CHANNEL_MAP_AMBISONIC_B_Y=25,SF_CHANNEL_MAP_AMBISONIC_B_Z=26,SF_CHANNEL_MAP_MAX=27,
SFD_DEFAULT_LEVEL=0,SFD_CUSTOM_LEVEL=1073741824,SFD_NO_DITHER=500,SFD_WHITE=501,SFD_TRIANGULAR_PDF=502,
SF_LOOP_NONE=800,SF_LOOP_FORWARD=801,SF_LOOP_BACKWARD=802,SF_LOOP_ALTERNATING=803,
SF_SEEK_SET=0,SF_SEEK_CUR=1,SF_SEEK_END=2,};struct SNDFILE_tag {};
struct SF_INFO {long frames;int samplerate;int channels;int format;int sections;int seekable;};
struct SF_VIRTUAL_IO {long(*get_filelen)(void*);long(*seek)(long,int,void*);long(*read)(void*,long,void*);long(*write)(const void*,long,void*);long(*tell)(void*);};
struct SF_CHUNK_INFO {char id[64];unsigned int id_size;unsigned int datalen;void*data;};
struct SF_CHUNK_ITERATOR {};
long(sf_readf_int)(struct SNDFILE_tag*,int*,long);
struct SNDFILE_tag*(sf_open_virtual)(struct SF_VIRTUAL_IO*,int,struct SF_INFO*,void*);
int(sf_get_chunk_data)(const struct SF_CHUNK_ITERATOR*,struct SF_CHUNK_INFO*);
int(sf_format_check)(const struct SF_INFO*);
long(sf_readf_float)(struct SNDFILE_tag*,float*,long);
struct SF_CHUNK_ITERATOR*(sf_next_chunk_iterator)(struct SF_CHUNK_ITERATOR*);
struct SNDFILE_tag*(sf_open)(const char*,int,struct SF_INFO*);
long(sf_writef_double)(struct SNDFILE_tag*,const double*,long);
long(sf_seek)(struct SNDFILE_tag*,long,int);
long(sf_writef_short)(struct SNDFILE_tag*,const short*,long);
int(sf_set_chunk)(struct SNDFILE_tag*,const struct SF_CHUNK_INFO*);
long(sf_readf_double)(struct SNDFILE_tag*,double*,long);
long(sf_write_float)(struct SNDFILE_tag*,const float*,long);
long(sf_read_short)(struct SNDFILE_tag*,short*,long);
const char*(sf_version_string)();
int(sf_set_string)(struct SNDFILE_tag*,int,const char*);
int(sf_error_str)(struct SNDFILE_tag*,char*,unsigned long);
const char*(sf_strerror)(struct SNDFILE_tag*);
long(sf_writef_float)(struct SNDFILE_tag*,const float*,long);
const char*(sf_error_number)(int);
const char*(sf_get_string)(struct SNDFILE_tag*,int);
long(sf_writef_int)(struct SNDFILE_tag*,const int*,long);
long(sf_write_raw)(struct SNDFILE_tag*,const void*,long);
long(sf_readf_short)(struct SNDFILE_tag*,short*,long);
struct SF_CHUNK_ITERATOR*(sf_get_chunk_iterator)(struct SNDFILE_tag*,const struct SF_CHUNK_INFO*);
long(sf_read_raw)(struct SNDFILE_tag*,void*,long);
int(sf_get_chunk_size)(const struct SF_CHUNK_ITERATOR*,struct SF_CHUNK_INFO*);
void(sf_write_sync)(struct SNDFILE_tag*);
int(sf_close)(struct SNDFILE_tag*);
long(sf_write_double)(struct SNDFILE_tag*,const double*,long);
long(sf_read_double)(struct SNDFILE_tag*,double*,long);
long(sf_read_float)(struct SNDFILE_tag*,float*,long);
long(sf_write_int)(struct SNDFILE_tag*,const int*,long);
long(sf_read_int)(struct SNDFILE_tag*,int*,long);
long(sf_write_short)(struct SNDFILE_tag*,const short*,long);
int(sf_command)(struct SNDFILE_tag*,int,void*,int);
int(sf_perror)(struct SNDFILE_tag*);
int(sf_error)(struct SNDFILE_tag*);
struct SNDFILE_tag*(sf_open_fd)(int,int,struct SF_INFO*,int);
int(sf_current_byterate)(struct SNDFILE_tag*);
struct SF_FORMAT_INFO { int format ; const char * name ; const char * extension ;  };
struct SF_DITHER_INFO { int type ; double level ; const char * name ;  };
struct SF_EMBED_FILE_INFO { long offset ; long length ;  };
struct SF_CUE_POINT { int indx ; unsigned int position ; int fcc_chunk ; int chunk_start ; int block_start ; unsigned int sample_offset ; char name[ 256 ] ;  };
struct SF_CUES { unsigned int cue_count ; struct SF_CUE_POINT cue_points[ 100 ] ;  };
struct SF_INSTRUMENT { int gain ; char basenote ; char detune ; char velocity_lo ; char velocity_hi ; char key_lo ; char key_hi ; int loop_count ; struct  { int mode ; unsigned int start ; unsigned int end ; unsigned int count ;  } loops [ 16 ] ;  };
struct SF_LOOP_INFO { short time_sig_num ; short time_sig_den ; int loop_mode ; int num_beats ; float bpm ; int root_key ; int future[ 6 ] ;  };
struct SF_BROADCAST_INFO { char description[ 256 ] ; char originator[ 32 ] ; char originator_reference[ 32 ] ; char origination_date[ 10 ] ; char origination_time[ 8 ] ; unsigned int time_reference_low ; unsigned int time_reference_high ; short version ; char umid[ 64 ] ; char reserved[ 190 ] ; unsigned int coding_history_size ; char coding_history[ 256 ] ;  };
struct SF_CART_TIMER { char usage[ 4 ] ; int value ;  };
struct SF_CART_INFO { char version[ 4 ] ; char title[ 64 ] ; char artist[ 64 ] ; char cut_id[ 64 ] ; char client_id[ 64 ] ; char category[ 64 ] ; char classification[ 64 ] ; char out_cue[ 64 ] ; char start_date[ 10 ] ; char start_time[ 8 ] ; char end_date[ 10 ] ; char end_time[ 8 ] ; char producer_app_id[ 64 ] ; char producer_app_version[ 64 ] ; char user_def[ 64 ] ; int level_reference ; struct SF_CART_TIMER post_timers[ 8 ] ; char reserved[ 276 ] ; char url[ 1024 ] ; unsigned int tag_text_size ; char tag_text[ 256 ] ;  };
]])
local CLIB = ffi.load(_G.FFI_LIB or "sndfile")
local library = {}
library = {
	ReadfInt = CLIB.sf_readf_int,
	OpenVirtual = CLIB.sf_open_virtual,
	GetChunkData = CLIB.sf_get_chunk_data,
	FormatCheck = CLIB.sf_format_check,
	ReadfFloat = CLIB.sf_readf_float,
	NextChunkIterator = CLIB.sf_next_chunk_iterator,
	Open = CLIB.sf_open,
	WritefDouble = CLIB.sf_writef_double,
	Seek = CLIB.sf_seek,
	WritefShort = CLIB.sf_writef_short,
	SetChunk = CLIB.sf_set_chunk,
	ReadfDouble = CLIB.sf_readf_double,
	WriteFloat = CLIB.sf_write_float,
	ReadShort = CLIB.sf_read_short,
	VersionString = CLIB.sf_version_string,
	SetString = CLIB.sf_set_string,
	ErrorStr = CLIB.sf_error_str,
	Strerror = CLIB.sf_strerror,
	WritefFloat = CLIB.sf_writef_float,
	ErrorNumber = CLIB.sf_error_number,
	GetString = CLIB.sf_get_string,
	WritefInt = CLIB.sf_writef_int,
	WriteRaw = CLIB.sf_write_raw,
	ReadfShort = CLIB.sf_readf_short,
	GetChunkIterator = CLIB.sf_get_chunk_iterator,
	ReadRaw = CLIB.sf_read_raw,
	GetChunkSize = CLIB.sf_get_chunk_size,
	WriteSync = CLIB.sf_write_sync,
	Close = CLIB.sf_close,
	WriteDouble = CLIB.sf_write_double,
	ReadDouble = CLIB.sf_read_double,
	ReadFloat = CLIB.sf_read_float,
	WriteInt = CLIB.sf_write_int,
	ReadInt = CLIB.sf_read_int,
	WriteShort = CLIB.sf_write_short,
	Command = CLIB.sf_command,
	Perror = CLIB.sf_perror,
	Error = CLIB.sf_error,
	OpenFd = CLIB.sf_open_fd,
	CurrentByterate = CLIB.sf_current_byterate,
}
library.e = {
	FORMAT_WAV = 65536,
	FORMAT_AIFF = 131072,
	FORMAT_AU = 196608,
	FORMAT_RAW = 262144,
	FORMAT_PAF = 327680,
	FORMAT_SVX = 393216,
	FORMAT_NIST = 458752,
	FORMAT_VOC = 524288,
	FORMAT_IRCAM = 655360,
	FORMAT_W64 = 720896,
	FORMAT_MAT4 = 786432,
	FORMAT_MAT5 = 851968,
	FORMAT_PVF = 917504,
	FORMAT_XI = 983040,
	FORMAT_HTK = 1048576,
	FORMAT_SDS = 1114112,
	FORMAT_AVR = 1179648,
	FORMAT_WAVEX = 1245184,
	FORMAT_SD2 = 1441792,
	FORMAT_FLAC = 1507328,
	FORMAT_CAF = 1572864,
	FORMAT_WVE = 1638400,
	FORMAT_OGG = 2097152,
	FORMAT_MPC2K = 2162688,
	FORMAT_RF64 = 2228224,
	FORMAT_PCM_S8 = 1,
	FORMAT_PCM_16 = 2,
	FORMAT_PCM_24 = 3,
	FORMAT_PCM_32 = 4,
	FORMAT_PCM_U8 = 5,
	FORMAT_FLOAT = 6,
	FORMAT_DOUBLE = 7,
	FORMAT_ULAW = 16,
	FORMAT_ALAW = 17,
	FORMAT_IMA_ADPCM = 18,
	FORMAT_MS_ADPCM = 19,
	FORMAT_GSM610 = 32,
	FORMAT_VOX_ADPCM = 33,
	FORMAT_G721_32 = 48,
	FORMAT_G723_24 = 49,
	FORMAT_G723_40 = 50,
	FORMAT_DWVW_12 = 64,
	FORMAT_DWVW_16 = 65,
	FORMAT_DWVW_24 = 66,
	FORMAT_DWVW_N = 67,
	FORMAT_DPCM_8 = 80,
	FORMAT_DPCM_16 = 81,
	FORMAT_VORBIS = 96,
	FORMAT_ALAC_16 = 112,
	FORMAT_ALAC_20 = 113,
	FORMAT_ALAC_24 = 114,
	FORMAT_ALAC_32 = 115,
	ENDIAN_FILE = 0,
	ENDIAN_LITTLE = 268435456,
	ENDIAN_BIG = 536870912,
	ENDIAN_CPU = 805306368,
	FORMAT_SUBMASK = 65535,
	FORMAT_TYPEMASK = 268369920,
	FORMAT_ENDMASK = 805306368,
	GET_LIB_VERSION = 4096,
	GET_LOG_INFO = 4097,
	GET_CURRENT_SF_INFO = 4098,
	GET_NORM_DOUBLE = 4112,
	GET_NORM_FLOAT = 4113,
	SET_NORM_DOUBLE = 4114,
	SET_NORM_FLOAT = 4115,
	SET_SCALE_FLOAT_INT_READ = 4116,
	SET_SCALE_INT_FLOAT_WRITE = 4117,
	GET_SIMPLE_FORMAT_COUNT = 4128,
	GET_SIMPLE_FORMAT = 4129,
	GET_FORMAT_INFO = 4136,
	GET_FORMAT_MAJOR_COUNT = 4144,
	GET_FORMAT_MAJOR = 4145,
	GET_FORMAT_SUBTYPE_COUNT = 4146,
	GET_FORMAT_SUBTYPE = 4147,
	CALC_SIGNAL_MAX = 4160,
	CALC_NORM_SIGNAL_MAX = 4161,
	CALC_MAX_ALL_CHANNELS = 4162,
	CALC_NORM_MAX_ALL_CHANNELS = 4163,
	GET_SIGNAL_MAX = 4164,
	GET_MAX_ALL_CHANNELS = 4165,
	SET_ADD_PEAK_CHUNK = 4176,
	SET_ADD_HEADER_PAD_CHUNK = 4177,
	UPDATE_HEADER_NOW = 4192,
	SET_UPDATE_HEADER_AUTO = 4193,
	FILE_TRUNCATE = 4224,
	SET_RAW_START_OFFSET = 4240,
	SET_DITHER_ON_WRITE = 4256,
	SET_DITHER_ON_READ = 4257,
	GET_DITHER_INFO_COUNT = 4258,
	GET_DITHER_INFO = 4259,
	GET_EMBED_FILE_INFO = 4272,
	SET_CLIPPING = 4288,
	GET_CLIPPING = 4289,
	GET_CUE_COUNT = 4301,
	GET_CUE = 4302,
	SET_CUE = 4303,
	GET_INSTRUMENT = 4304,
	SET_INSTRUMENT = 4305,
	GET_LOOP_INFO = 4320,
	GET_BROADCAST_INFO = 4336,
	SET_BROADCAST_INFO = 4337,
	GET_CHANNEL_MAP_INFO = 4352,
	SET_CHANNEL_MAP_INFO = 4353,
	RAW_DATA_NEEDS_ENDSWAP = 4368,
	WAVEX_SET_AMBISONIC = 4608,
	WAVEX_GET_AMBISONIC = 4609,
	RF64_AUTO_DOWNGRADE = 4624,
	SET_VBR_ENCODING_QUALITY = 4864,
	SET_COMPRESSION_LEVEL = 4865,
	SET_CART_INFO = 5120,
	GET_CART_INFO = 5121,
	TEST_IEEE_FLOAT_REPLACE = 24577,
	SET_ADD_DITHER_ON_WRITE = 4208,
	SET_ADD_DITHER_ON_READ = 4209,
	STR_TITLE = 1,
	STR_COPYRIGHT = 2,
	STR_SOFTWARE = 3,
	STR_ARTIST = 4,
	STR_COMMENT = 5,
	STR_DATE = 6,
	STR_ALBUM = 7,
	STR_LICENSE = 8,
	STR_TRACKNUMBER = 9,
	STR_GENRE = 16,
	FALSE = 0,
	TRUE = 1,
	READ = 16,
	WRITE = 32,
	RDWR = 48,
	AMBISONIC_NONE = 64,
	AMBISONIC_B_FORMAT = 65,
	ERR_NO_ERROR = 0,
	ERR_UNRECOGNISED_FORMAT = 1,
	ERR_SYSTEM = 2,
	ERR_MALFORMED_FILE = 3,
	ERR_UNSUPPORTED_ENCODING = 4,
	CHANNEL_MAP_INVALID = 0,
	CHANNEL_MAP_MONO = 1,
	CHANNEL_MAP_LEFT = 2,
	CHANNEL_MAP_RIGHT = 3,
	CHANNEL_MAP_CENTER = 4,
	CHANNEL_MAP_FRONT_LEFT = 5,
	CHANNEL_MAP_FRONT_RIGHT = 6,
	CHANNEL_MAP_FRONT_CENTER = 7,
	CHANNEL_MAP_REAR_CENTER = 8,
	CHANNEL_MAP_REAR_LEFT = 9,
	CHANNEL_MAP_REAR_RIGHT = 10,
	CHANNEL_MAP_LFE = 11,
	CHANNEL_MAP_FRONT_LEFT_OF_CENTER = 12,
	CHANNEL_MAP_FRONT_RIGHT_OF_CENTER = 13,
	CHANNEL_MAP_SIDE_LEFT = 14,
	CHANNEL_MAP_SIDE_RIGHT = 15,
	CHANNEL_MAP_TOP_CENTER = 16,
	CHANNEL_MAP_TOP_FRONT_LEFT = 17,
	CHANNEL_MAP_TOP_FRONT_RIGHT = 18,
	CHANNEL_MAP_TOP_FRONT_CENTER = 19,
	CHANNEL_MAP_TOP_REAR_LEFT = 20,
	CHANNEL_MAP_TOP_REAR_RIGHT = 21,
	CHANNEL_MAP_TOP_REAR_CENTER = 22,
	CHANNEL_MAP_AMBISONIC_B_W = 23,
	CHANNEL_MAP_AMBISONIC_B_X = 24,
	CHANNEL_MAP_AMBISONIC_B_Y = 25,
	CHANNEL_MAP_AMBISONIC_B_Z = 26,
	CHANNEL_MAP_MAX = 27,
	DEFAULT_LEVEL = 0,
	CUSTOM_LEVEL = 1073741824,
	NO_DITHER = 500,
	WHITE = 501,
	TRIANGULAR_PDF = 502,
	LOOP_NONE = 800,
	LOOP_FORWARD = 801,
	LOOP_BACKWARD = 802,
	LOOP_ALTERNATING = 803,
	SEEK_SET = 0,
	SEEK_CUR = 1,
	SEEK_END = 2,
}
library.clib = CLIB
return library
