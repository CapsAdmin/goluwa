local ffi = require("ffi")
ffi.cdef([[typedef enum mpg123_flags{MPG123_CRC=1,MPG123_COPYRIGHT=2,MPG123_PRIVATE=4,MPG123_ORIGINAL=8};
typedef enum mpg123_vbr{MPG123_CBR=0,MPG123_VBR=1,MPG123_ABR=2};
typedef enum mpg123_errors{MPG123_DONE=-12,MPG123_NEW_FORMAT=-11,MPG123_NEED_MORE=-10,MPG123_ERR=-1,MPG123_OK=0,MPG123_BAD_OUTFORMAT=1,MPG123_BAD_CHANNEL=2,MPG123_BAD_RATE=3,MPG123_ERR_16TO8TABLE=4,MPG123_BAD_PARAM=5,MPG123_BAD_BUFFER=6,MPG123_OUT_OF_MEM=7,MPG123_NOT_INITIALIZED=8,MPG123_BAD_DECODER=9,MPG123_BAD_HANDLE=10,MPG123_NO_BUFFERS=11,MPG123_BAD_RVA=12,MPG123_NO_GAPLESS=13,MPG123_NO_SPACE=14,MPG123_BAD_TYPES=15,MPG123_BAD_BAND=16,MPG123_ERR_NULL=17,MPG123_ERR_READER=18,MPG123_NO_SEEK_FROM_END=19,MPG123_BAD_WHENCE=20,MPG123_NO_TIMEOUT=21,MPG123_BAD_FILE=22,MPG123_NO_SEEK=23,MPG123_NO_READER=24,MPG123_BAD_PARS=25,MPG123_BAD_INDEX_PAR=26,MPG123_OUT_OF_SYNC=27,MPG123_RESYNC_FAIL=28,MPG123_NO_8BIT=29,MPG123_BAD_ALIGN=30,MPG123_NULL_BUFFER=31,MPG123_NO_RELSEEK=32,MPG123_NULL_POINTER=33,MPG123_BAD_KEY=34,MPG123_NO_INDEX=35,MPG123_INDEX_FAIL=36,MPG123_BAD_DECODER_SETUP=37,MPG123_MISSING_FEATURE=38,MPG123_BAD_VALUE=39,MPG123_LSEEK_FAILED=40,MPG123_BAD_CUSTOM_IO=41,MPG123_LFS_OVERFLOW=42,MPG123_INT_OVERFLOW=43};
typedef enum mpg123_param_flags{MPG123_FORCE_MONO=7,MPG123_MONO_LEFT=1,MPG123_MONO_RIGHT=2,MPG123_MONO_MIX=4,MPG123_FORCE_STEREO=8,MPG123_FORCE_8BIT=16,MPG123_QUIET=32,MPG123_GAPLESS=64,MPG123_NO_RESYNC=128,MPG123_SEEKBUFFER=256,MPG123_FUZZY=512,MPG123_FORCE_FLOAT=1024,MPG123_PLAIN_ID3TEXT=2048,MPG123_IGNORE_STREAMLENGTH=4096,MPG123_SKIP_ID3V2=8192,MPG123_IGNORE_INFOFRAME=16384,MPG123_AUTO_RESAMPLE=32768,MPG123_PICTURE=65536,MPG123_NO_PEEK_END=131072,MPG123_FORCE_SEEKABLE=262144};
typedef enum mpg123_enc_enum{MPG123_ENC_8=15,MPG123_ENC_16=64,MPG123_ENC_24=16384,MPG123_ENC_32=256,MPG123_ENC_SIGNED=128,MPG123_ENC_FLOAT=3584,MPG123_ENC_SIGNED_16=208,MPG123_ENC_UNSIGNED_16=96,MPG123_ENC_UNSIGNED_8=1,MPG123_ENC_SIGNED_8=130,MPG123_ENC_ULAW_8=4,MPG123_ENC_ALAW_8=8,MPG123_ENC_SIGNED_32=4480,MPG123_ENC_UNSIGNED_32=8448,MPG123_ENC_SIGNED_24=20608,MPG123_ENC_UNSIGNED_24=24576,MPG123_ENC_FLOAT_32=512,MPG123_ENC_FLOAT_64=1024,MPG123_ENC_ANY=30719};
typedef enum mpg123_parms{MPG123_VERBOSE=0,MPG123_FLAGS=1,MPG123_ADD_FLAGS=2,MPG123_FORCE_RATE=3,MPG123_DOWN_SAMPLE=4,MPG123_RVA=5,MPG123_DOWNSPEED=6,MPG123_UPSPEED=7,MPG123_START_FRAME=8,MPG123_DECODE_FRAMES=9,MPG123_ICY_INTERVAL=10,MPG123_OUTSCALE=11,MPG123_TIMEOUT=12,MPG123_REMOVE_FLAGS=13,MPG123_RESYNC_LIMIT=14,MPG123_INDEX_SIZE=15,MPG123_PREFRAMES=16,MPG123_FEEDPOOL=17,MPG123_FEEDBUFFER=18};
typedef enum mpg123_state{MPG123_ACCURATE=1,MPG123_BUFFERFILL=2,MPG123_FRANKENSTEIN=3,MPG123_FRESH_DECODER=4};
typedef enum mpg123_channelcount{MPG123_MONO=1,MPG123_STEREO=2};
typedef enum mpg123_param_rva{MPG123_RVA_OFF=0,MPG123_RVA_MIX=1,MPG123_RVA_ALBUM=2,MPG123_RVA_MAX=2};
typedef enum mpg123_mode{MPG123_M_STEREO=0,MPG123_M_JOINT=1,MPG123_M_DUAL=2,MPG123_M_MONO=3};
typedef enum mpg123_channels{MPG123_LEFT=1,MPG123_RIGHT=2,MPG123_LR=3};
typedef enum mpg123_version{MPG123_1_0=0,MPG123_2_0=1,MPG123_2_5=2};
typedef enum mpg123_feature_set{MPG123_FEATURE_ABI_UTF8OPEN=0,MPG123_FEATURE_OUTPUT_8BIT=1,MPG123_FEATURE_OUTPUT_16BIT=2,MPG123_FEATURE_OUTPUT_32BIT=3,MPG123_FEATURE_INDEX=4,MPG123_FEATURE_PARSE_ID3V2=5,MPG123_FEATURE_DECODE_LAYER1=6,MPG123_FEATURE_DECODE_LAYER2=7,MPG123_FEATURE_DECODE_LAYER3=8,MPG123_FEATURE_DECODE_ACCURATE=9,MPG123_FEATURE_DECODE_DOWNSAMPLE=10,MPG123_FEATURE_DECODE_NTOM=11,MPG123_FEATURE_PARSE_ICY=12,MPG123_FEATURE_TIMEOUT_READ=13,MPG123_FEATURE_EQUALIZER=14};
struct mpg123_handle_struct {};
struct mpg123_frameinfo {enum mpg123_version version;int layer;long rate;enum mpg123_mode mode;int mode_ext;int framesize;enum mpg123_flags flags;int emphasis;int bitrate;int abr_rate;enum mpg123_vbr vbr;};
struct mpg123_string {char*p;unsigned long size;unsigned long fill;};
struct mpg123_text {char lang[3];char id[4];struct mpg123_string description;struct mpg123_string text;};
struct mpg123_picture {char type;struct mpg123_string description;struct mpg123_string mime_type;unsigned long size;unsigned char*data;};
struct mpg123_id3v2 {unsigned char version;struct mpg123_string*title;struct mpg123_string*artist;struct mpg123_string*album;struct mpg123_string*year;struct mpg123_string*genre;struct mpg123_string*comment;struct mpg123_text*comment_list;unsigned long comments;struct mpg123_text*text;unsigned long texts;struct mpg123_text*extra;unsigned long extras;struct mpg123_picture*picture;unsigned long pictures;};
struct mpg123_id3v1 {char tag[3];char title[30];char artist[30];char album[30];char year[4];char comment[30];unsigned char genre;};
struct mpg123_pars_struct {};
long(mpg123_tell_stream)(struct mpg123_handle_struct*);
int(mpg123_scan)(struct mpg123_handle_struct*);
int(mpg123_decoder)(struct mpg123_handle_struct*,const char*);
int(mpg123_meta_check)(struct mpg123_handle_struct*);
struct mpg123_handle_struct*(mpg123_new)(const char*,int*);
int(mpg123_copy_string)(struct mpg123_string*,struct mpg123_string*);
int(mpg123_framebyframe_next)(struct mpg123_handle_struct*);
int(mpg123_getvolume)(struct mpg123_handle_struct*,double*,double*,double*);
int(mpg123_getformat2)(struct mpg123_handle_struct*,long*,int*,int*,int);
const char**(mpg123_decoders)();
int(mpg123_errcode)(struct mpg123_handle_struct*);
int(mpg123_set_index)(struct mpg123_handle_struct*,long*,long,unsigned long);
long(mpg123_length)(struct mpg123_handle_struct*);
int(mpg123_resize_string)(struct mpg123_string*,unsigned long);
int(mpg123_format_none)(struct mpg123_handle_struct*);
void(mpg123_meta_free)(struct mpg123_handle_struct*);
int(mpg123_framebyframe_decode)(struct mpg123_handle_struct*,long*,unsigned char**,unsigned long*);
const char*(mpg123_plain_strerror)(int);
void(mpg123_init_string)(struct mpg123_string*);
int(mpg123_reset_eq)(struct mpg123_handle_struct*);
int(mpg123_set_string)(struct mpg123_string*,const char*);
enum mpg123_text_encoding(mpg123_enc_from_id3)(unsigned char);
unsigned long(mpg123_outblock)(struct mpg123_handle_struct*);
int(mpg123_replace_buffer)(struct mpg123_handle_struct*,unsigned char*,unsigned long);
int(mpg123_getpar)(struct mpg123_pars_struct*,enum mpg123_parms,long*,double*);
int(mpg123_par)(struct mpg123_pars_struct*,enum mpg123_parms,long,double);
int(mpg123_fmt_support)(struct mpg123_pars_struct*,long,int);
int(mpg123_fmt)(struct mpg123_pars_struct*,long,int,int);
int(mpg123_init)();
long(mpg123_seek_frame)(struct mpg123_handle_struct*,long,int);
int(mpg123_fmt_none)(struct mpg123_pars_struct*);
int(mpg123_param)(struct mpg123_handle_struct*,enum mpg123_parms,long,double);
void(mpg123_delete_pars)(struct mpg123_pars_struct*);
int(mpg123_format_all)(struct mpg123_handle_struct*);
long(mpg123_clip)(struct mpg123_handle_struct*);
struct mpg123_handle_struct*(mpg123_parnew)(struct mpg123_pars_struct*,const char*,int*);
int(mpg123_add_string)(struct mpg123_string*,const char*);
int(mpg123_volume_change)(struct mpg123_handle_struct*,double);
char*(mpg123_icy2utf8)(const char*);
int(mpg123_icy)(struct mpg123_handle_struct*,char**);
int(mpg123_id3)(struct mpg123_handle_struct*,struct mpg123_id3v1**,struct mpg123_id3v2**);
int(mpg123_store_utf8)(struct mpg123_string*,enum mpg123_text_encoding,const unsigned char*,unsigned long);
int(mpg123_set_substring)(struct mpg123_string*,const char*,unsigned long,unsigned long);
int(mpg123_add_substring)(struct mpg123_string*,const char*,unsigned long,unsigned long);
int(mpg123_grow_string)(struct mpg123_string*,unsigned long);
int(mpg123_getstate)(struct mpg123_handle_struct*,enum mpg123_state,long*,double*);
void(mpg123_delete)(struct mpg123_handle_struct*);
int(mpg123_spf)(struct mpg123_handle_struct*);
double(mpg123_tpf)(struct mpg123_handle_struct*);
void(mpg123_rates)(const long**,unsigned long*);
unsigned long(mpg123_safe_buffer)();
int(mpg123_decode_frame)(struct mpg123_handle_struct*,long*,unsigned char**,unsigned long*);
const char*(mpg123_strerror)(struct mpg123_handle_struct*);
int(mpg123_set_filesize)(struct mpg123_handle_struct*,long);
long(mpg123_framelength)(struct mpg123_handle_struct*);
int(mpg123_feature)(const enum mpg123_feature_set);
int(mpg123_info)(struct mpg123_handle_struct*,struct mpg123_frameinfo*);
int(mpg123_volume)(struct mpg123_handle_struct*,double);
double(mpg123_geteq)(struct mpg123_handle_struct*,enum mpg123_channels,int);
int(mpg123_position)(struct mpg123_handle_struct*,long,long,long*,long*,double*,double*);
int(mpg123_index)(struct mpg123_handle_struct*,long**,long*,unsigned long*);
long(mpg123_timeframe)(struct mpg123_handle_struct*,double);
long(mpg123_feedseek)(struct mpg123_handle_struct*,long,int,long*);
long(mpg123_seek)(struct mpg123_handle_struct*,long,int);
int(mpg123_eq)(struct mpg123_handle_struct*,enum mpg123_channels,int,double);
long(mpg123_tell)(struct mpg123_handle_struct*);
long(mpg123_framepos)(struct mpg123_handle_struct*);
int(mpg123_framedata)(struct mpg123_handle_struct*,unsigned long*,unsigned char**,unsigned long*);
int(mpg123_decode)(struct mpg123_handle_struct*,const unsigned char*,unsigned long,unsigned char*,unsigned long,unsigned long*);
int(mpg123_format_support)(struct mpg123_handle_struct*,long,int);
int(mpg123_read)(struct mpg123_handle_struct*,unsigned char*,unsigned long,unsigned long*);
int(mpg123_close)(struct mpg123_handle_struct*);
void(mpg123_free_string)(struct mpg123_string*);
int(mpg123_open_handle)(struct mpg123_handle_struct*,void*);
int(mpg123_open_fd)(struct mpg123_handle_struct*,int);
int(mpg123_open)(struct mpg123_handle_struct*,const char*);
int(mpg123_getformat)(struct mpg123_handle_struct*,long*,int*,int*);
void(mpg123_exit)();
const char*(mpg123_current_decoder)(struct mpg123_handle_struct*);
int(mpg123_getparam)(struct mpg123_handle_struct*,enum mpg123_parms,long*,double*);
int(mpg123_encsize)(int);
void(mpg123_encodings)(const int**,unsigned long*);
const char**(mpg123_supported_decoders)();
int(mpg123_feed)(struct mpg123_handle_struct*,const unsigned char*,unsigned long);
long(mpg123_tellframe)(struct mpg123_handle_struct*);
int(mpg123_open_feed)(struct mpg123_handle_struct*);
unsigned long(mpg123_strlen)(struct mpg123_string*,int);
struct mpg123_pars_struct*(mpg123_new_pars)(int*);
int(mpg123_fmt_all)(struct mpg123_pars_struct*);
int(mpg123_chomp_string)(struct mpg123_string*);
int(mpg123_format)(struct mpg123_handle_struct*,long,int,int);
]])
local CLIB = ffi.load(_G.FFI_LIB or "mpg123")
local library = {}
library = {
	TellStream = CLIB.mpg123_tell_stream,
	Scan = CLIB.mpg123_scan,
	Decoder = CLIB.mpg123_decoder,
	MetaCheck = CLIB.mpg123_meta_check,
	New = CLIB.mpg123_new,
	CopyString = CLIB.mpg123_copy_string,
	FramebyframeNext = CLIB.mpg123_framebyframe_next,
	Getvolume = CLIB.mpg123_getvolume,
	Getformat2 = CLIB.mpg123_getformat2,
	Decoders = CLIB.mpg123_decoders,
	Errcode = CLIB.mpg123_errcode,
	SetIndex = CLIB.mpg123_set_index,
	Length = CLIB.mpg123_length,
	ResizeString = CLIB.mpg123_resize_string,
	FormatNone = CLIB.mpg123_format_none,
	MetaFree = CLIB.mpg123_meta_free,
	FramebyframeDecode = CLIB.mpg123_framebyframe_decode,
	PlainStrerror = CLIB.mpg123_plain_strerror,
	InitString = CLIB.mpg123_init_string,
	ResetEq = CLIB.mpg123_reset_eq,
	SetString = CLIB.mpg123_set_string,
	EncFromId3 = CLIB.mpg123_enc_from_id3,
	Outblock = CLIB.mpg123_outblock,
	ReplaceBuffer = CLIB.mpg123_replace_buffer,
	Getpar = CLIB.mpg123_getpar,
	Par = CLIB.mpg123_par,
	FmtSupport = CLIB.mpg123_fmt_support,
	Fmt = CLIB.mpg123_fmt,
	Init = CLIB.mpg123_init,
	SeekFrame = CLIB.mpg123_seek_frame,
	FmtNone = CLIB.mpg123_fmt_none,
	Param = CLIB.mpg123_param,
	DeletePars = CLIB.mpg123_delete_pars,
	FormatAll = CLIB.mpg123_format_all,
	Clip = CLIB.mpg123_clip,
	Parnew = CLIB.mpg123_parnew,
	AddString = CLIB.mpg123_add_string,
	VolumeChange = CLIB.mpg123_volume_change,
	Icy2utf8 = CLIB.mpg123_icy2utf8,
	Icy = CLIB.mpg123_icy,
	Id3 = CLIB.mpg123_id3,
	StoreUtf8 = CLIB.mpg123_store_utf8,
	SetSubstring = CLIB.mpg123_set_substring,
	AddSubstring = CLIB.mpg123_add_substring,
	GrowString = CLIB.mpg123_grow_string,
	Getstate = CLIB.mpg123_getstate,
	Delete = CLIB.mpg123_delete,
	Spf = CLIB.mpg123_spf,
	Tpf = CLIB.mpg123_tpf,
	Rates = CLIB.mpg123_rates,
	SafeBuffer = CLIB.mpg123_safe_buffer,
	DecodeFrame = CLIB.mpg123_decode_frame,
	Strerror = CLIB.mpg123_strerror,
	SetFilesize = CLIB.mpg123_set_filesize,
	Framelength = CLIB.mpg123_framelength,
	Feature = CLIB.mpg123_feature,
	Info = CLIB.mpg123_info,
	Volume = CLIB.mpg123_volume,
	Geteq = CLIB.mpg123_geteq,
	Position = CLIB.mpg123_position,
	Index = CLIB.mpg123_index,
	Timeframe = CLIB.mpg123_timeframe,
	Feedseek = CLIB.mpg123_feedseek,
	Seek = CLIB.mpg123_seek,
	Eq = CLIB.mpg123_eq,
	Tell = CLIB.mpg123_tell,
	Framepos = CLIB.mpg123_framepos,
	Framedata = CLIB.mpg123_framedata,
	Decode = CLIB.mpg123_decode,
	FormatSupport = CLIB.mpg123_format_support,
	Read = CLIB.mpg123_read,
	Close = CLIB.mpg123_close,
	FreeString = CLIB.mpg123_free_string,
	OpenHandle = CLIB.mpg123_open_handle,
	OpenFd = CLIB.mpg123_open_fd,
	Open = CLIB.mpg123_open,
	Getformat = CLIB.mpg123_getformat,
	Exit = CLIB.mpg123_exit,
	CurrentDecoder = CLIB.mpg123_current_decoder,
	Getparam = CLIB.mpg123_getparam,
	Encsize = CLIB.mpg123_encsize,
	Encodings = CLIB.mpg123_encodings,
	SupportedDecoders = CLIB.mpg123_supported_decoders,
	Feed = CLIB.mpg123_feed,
	Tellframe = CLIB.mpg123_tellframe,
	OpenFeed = CLIB.mpg123_open_feed,
	Strlen = CLIB.mpg123_strlen,
	NewPars = CLIB.mpg123_new_pars,
	FmtAll = CLIB.mpg123_fmt_all,
	ChompString = CLIB.mpg123_chomp_string,
	Format = CLIB.mpg123_format,
}
library.e = {
	CRC = ffi.cast("enum mpg123_flags", "MPG123_CRC"),
	COPYRIGHT = ffi.cast("enum mpg123_flags", "MPG123_COPYRIGHT"),
	PRIVATE = ffi.cast("enum mpg123_flags", "MPG123_PRIVATE"),
	ORIGINAL = ffi.cast("enum mpg123_flags", "MPG123_ORIGINAL"),
	CBR = ffi.cast("enum mpg123_vbr", "MPG123_CBR"),
	VBR = ffi.cast("enum mpg123_vbr", "MPG123_VBR"),
	ABR = ffi.cast("enum mpg123_vbr", "MPG123_ABR"),
	DONE = ffi.cast("enum mpg123_errors", "MPG123_DONE"),
	NEW_FORMAT = ffi.cast("enum mpg123_errors", "MPG123_NEW_FORMAT"),
	NEED_MORE = ffi.cast("enum mpg123_errors", "MPG123_NEED_MORE"),
	ERR = ffi.cast("enum mpg123_errors", "MPG123_ERR"),
	OK = ffi.cast("enum mpg123_errors", "MPG123_OK"),
	BAD_OUTFORMAT = ffi.cast("enum mpg123_errors", "MPG123_BAD_OUTFORMAT"),
	BAD_CHANNEL = ffi.cast("enum mpg123_errors", "MPG123_BAD_CHANNEL"),
	BAD_RATE = ffi.cast("enum mpg123_errors", "MPG123_BAD_RATE"),
	ERR_16TO8TABLE = ffi.cast("enum mpg123_errors", "MPG123_ERR_16TO8TABLE"),
	BAD_PARAM = ffi.cast("enum mpg123_errors", "MPG123_BAD_PARAM"),
	BAD_BUFFER = ffi.cast("enum mpg123_errors", "MPG123_BAD_BUFFER"),
	OUT_OF_MEM = ffi.cast("enum mpg123_errors", "MPG123_OUT_OF_MEM"),
	NOT_INITIALIZED = ffi.cast("enum mpg123_errors", "MPG123_NOT_INITIALIZED"),
	BAD_DECODER = ffi.cast("enum mpg123_errors", "MPG123_BAD_DECODER"),
	BAD_HANDLE = ffi.cast("enum mpg123_errors", "MPG123_BAD_HANDLE"),
	NO_BUFFERS = ffi.cast("enum mpg123_errors", "MPG123_NO_BUFFERS"),
	BAD_RVA = ffi.cast("enum mpg123_errors", "MPG123_BAD_RVA"),
	NO_GAPLESS = ffi.cast("enum mpg123_errors", "MPG123_NO_GAPLESS"),
	NO_SPACE = ffi.cast("enum mpg123_errors", "MPG123_NO_SPACE"),
	BAD_TYPES = ffi.cast("enum mpg123_errors", "MPG123_BAD_TYPES"),
	BAD_BAND = ffi.cast("enum mpg123_errors", "MPG123_BAD_BAND"),
	ERR_NULL = ffi.cast("enum mpg123_errors", "MPG123_ERR_NULL"),
	ERR_READER = ffi.cast("enum mpg123_errors", "MPG123_ERR_READER"),
	NO_SEEK_FROM_END = ffi.cast("enum mpg123_errors", "MPG123_NO_SEEK_FROM_END"),
	BAD_WHENCE = ffi.cast("enum mpg123_errors", "MPG123_BAD_WHENCE"),
	NO_TIMEOUT = ffi.cast("enum mpg123_errors", "MPG123_NO_TIMEOUT"),
	BAD_FILE = ffi.cast("enum mpg123_errors", "MPG123_BAD_FILE"),
	NO_SEEK = ffi.cast("enum mpg123_errors", "MPG123_NO_SEEK"),
	NO_READER = ffi.cast("enum mpg123_errors", "MPG123_NO_READER"),
	BAD_PARS = ffi.cast("enum mpg123_errors", "MPG123_BAD_PARS"),
	BAD_INDEX_PAR = ffi.cast("enum mpg123_errors", "MPG123_BAD_INDEX_PAR"),
	OUT_OF_SYNC = ffi.cast("enum mpg123_errors", "MPG123_OUT_OF_SYNC"),
	RESYNC_FAIL = ffi.cast("enum mpg123_errors", "MPG123_RESYNC_FAIL"),
	NO_8BIT = ffi.cast("enum mpg123_errors", "MPG123_NO_8BIT"),
	BAD_ALIGN = ffi.cast("enum mpg123_errors", "MPG123_BAD_ALIGN"),
	NULL_BUFFER = ffi.cast("enum mpg123_errors", "MPG123_NULL_BUFFER"),
	NO_RELSEEK = ffi.cast("enum mpg123_errors", "MPG123_NO_RELSEEK"),
	NULL_POINTER = ffi.cast("enum mpg123_errors", "MPG123_NULL_POINTER"),
	BAD_KEY = ffi.cast("enum mpg123_errors", "MPG123_BAD_KEY"),
	NO_INDEX = ffi.cast("enum mpg123_errors", "MPG123_NO_INDEX"),
	INDEX_FAIL = ffi.cast("enum mpg123_errors", "MPG123_INDEX_FAIL"),
	BAD_DECODER_SETUP = ffi.cast("enum mpg123_errors", "MPG123_BAD_DECODER_SETUP"),
	MISSING_FEATURE = ffi.cast("enum mpg123_errors", "MPG123_MISSING_FEATURE"),
	BAD_VALUE = ffi.cast("enum mpg123_errors", "MPG123_BAD_VALUE"),
	LSEEK_FAILED = ffi.cast("enum mpg123_errors", "MPG123_LSEEK_FAILED"),
	BAD_CUSTOM_IO = ffi.cast("enum mpg123_errors", "MPG123_BAD_CUSTOM_IO"),
	LFS_OVERFLOW = ffi.cast("enum mpg123_errors", "MPG123_LFS_OVERFLOW"),
	INT_OVERFLOW = ffi.cast("enum mpg123_errors", "MPG123_INT_OVERFLOW"),
	FORCE_MONO = ffi.cast("enum mpg123_param_flags", "MPG123_FORCE_MONO"),
	MONO_LEFT = ffi.cast("enum mpg123_param_flags", "MPG123_MONO_LEFT"),
	MONO_RIGHT = ffi.cast("enum mpg123_param_flags", "MPG123_MONO_RIGHT"),
	MONO_MIX = ffi.cast("enum mpg123_param_flags", "MPG123_MONO_MIX"),
	FORCE_STEREO = ffi.cast("enum mpg123_param_flags", "MPG123_FORCE_STEREO"),
	FORCE_8BIT = ffi.cast("enum mpg123_param_flags", "MPG123_FORCE_8BIT"),
	QUIET = ffi.cast("enum mpg123_param_flags", "MPG123_QUIET"),
	GAPLESS = ffi.cast("enum mpg123_param_flags", "MPG123_GAPLESS"),
	NO_RESYNC = ffi.cast("enum mpg123_param_flags", "MPG123_NO_RESYNC"),
	SEEKBUFFER = ffi.cast("enum mpg123_param_flags", "MPG123_SEEKBUFFER"),
	FUZZY = ffi.cast("enum mpg123_param_flags", "MPG123_FUZZY"),
	FORCE_FLOAT = ffi.cast("enum mpg123_param_flags", "MPG123_FORCE_FLOAT"),
	PLAIN_ID3TEXT = ffi.cast("enum mpg123_param_flags", "MPG123_PLAIN_ID3TEXT"),
	IGNORE_STREAMLENGTH = ffi.cast("enum mpg123_param_flags", "MPG123_IGNORE_STREAMLENGTH"),
	SKIP_ID3V2 = ffi.cast("enum mpg123_param_flags", "MPG123_SKIP_ID3V2"),
	IGNORE_INFOFRAME = ffi.cast("enum mpg123_param_flags", "MPG123_IGNORE_INFOFRAME"),
	AUTO_RESAMPLE = ffi.cast("enum mpg123_param_flags", "MPG123_AUTO_RESAMPLE"),
	PICTURE = ffi.cast("enum mpg123_param_flags", "MPG123_PICTURE"),
	NO_PEEK_END = ffi.cast("enum mpg123_param_flags", "MPG123_NO_PEEK_END"),
	FORCE_SEEKABLE = ffi.cast("enum mpg123_param_flags", "MPG123_FORCE_SEEKABLE"),
	ENC_8 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_8"),
	ENC_16 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_16"),
	ENC_24 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_24"),
	ENC_32 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_32"),
	ENC_SIGNED = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_SIGNED"),
	ENC_FLOAT = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_FLOAT"),
	ENC_SIGNED_16 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_SIGNED_16"),
	ENC_UNSIGNED_16 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_UNSIGNED_16"),
	ENC_UNSIGNED_8 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_UNSIGNED_8"),
	ENC_SIGNED_8 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_SIGNED_8"),
	ENC_ULAW_8 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_ULAW_8"),
	ENC_ALAW_8 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_ALAW_8"),
	ENC_SIGNED_32 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_SIGNED_32"),
	ENC_UNSIGNED_32 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_UNSIGNED_32"),
	ENC_SIGNED_24 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_SIGNED_24"),
	ENC_UNSIGNED_24 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_UNSIGNED_24"),
	ENC_FLOAT_32 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_FLOAT_32"),
	ENC_FLOAT_64 = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_FLOAT_64"),
	ENC_ANY = ffi.cast("enum mpg123_enc_enum", "MPG123_ENC_ANY"),
	VERBOSE = ffi.cast("enum mpg123_parms", "MPG123_VERBOSE"),
	FLAGS = ffi.cast("enum mpg123_parms", "MPG123_FLAGS"),
	ADD_FLAGS = ffi.cast("enum mpg123_parms", "MPG123_ADD_FLAGS"),
	FORCE_RATE = ffi.cast("enum mpg123_parms", "MPG123_FORCE_RATE"),
	DOWN_SAMPLE = ffi.cast("enum mpg123_parms", "MPG123_DOWN_SAMPLE"),
	RVA = ffi.cast("enum mpg123_parms", "MPG123_RVA"),
	DOWNSPEED = ffi.cast("enum mpg123_parms", "MPG123_DOWNSPEED"),
	UPSPEED = ffi.cast("enum mpg123_parms", "MPG123_UPSPEED"),
	START_FRAME = ffi.cast("enum mpg123_parms", "MPG123_START_FRAME"),
	DECODE_FRAMES = ffi.cast("enum mpg123_parms", "MPG123_DECODE_FRAMES"),
	ICY_INTERVAL = ffi.cast("enum mpg123_parms", "MPG123_ICY_INTERVAL"),
	OUTSCALE = ffi.cast("enum mpg123_parms", "MPG123_OUTSCALE"),
	TIMEOUT = ffi.cast("enum mpg123_parms", "MPG123_TIMEOUT"),
	REMOVE_FLAGS = ffi.cast("enum mpg123_parms", "MPG123_REMOVE_FLAGS"),
	RESYNC_LIMIT = ffi.cast("enum mpg123_parms", "MPG123_RESYNC_LIMIT"),
	INDEX_SIZE = ffi.cast("enum mpg123_parms", "MPG123_INDEX_SIZE"),
	PREFRAMES = ffi.cast("enum mpg123_parms", "MPG123_PREFRAMES"),
	FEEDPOOL = ffi.cast("enum mpg123_parms", "MPG123_FEEDPOOL"),
	FEEDBUFFER = ffi.cast("enum mpg123_parms", "MPG123_FEEDBUFFER"),
	ACCURATE = ffi.cast("enum mpg123_state", "MPG123_ACCURATE"),
	BUFFERFILL = ffi.cast("enum mpg123_state", "MPG123_BUFFERFILL"),
	FRANKENSTEIN = ffi.cast("enum mpg123_state", "MPG123_FRANKENSTEIN"),
	FRESH_DECODER = ffi.cast("enum mpg123_state", "MPG123_FRESH_DECODER"),
	MONO = ffi.cast("enum mpg123_channelcount", "MPG123_MONO"),
	STEREO = ffi.cast("enum mpg123_channelcount", "MPG123_STEREO"),
	RVA_OFF = ffi.cast("enum mpg123_param_rva", "MPG123_RVA_OFF"),
	RVA_MIX = ffi.cast("enum mpg123_param_rva", "MPG123_RVA_MIX"),
	RVA_ALBUM = ffi.cast("enum mpg123_param_rva", "MPG123_RVA_ALBUM"),
	RVA_MAX = ffi.cast("enum mpg123_param_rva", "MPG123_RVA_MAX"),
	M_STEREO = ffi.cast("enum mpg123_mode", "MPG123_M_STEREO"),
	M_JOINT = ffi.cast("enum mpg123_mode", "MPG123_M_JOINT"),
	M_DUAL = ffi.cast("enum mpg123_mode", "MPG123_M_DUAL"),
	M_MONO = ffi.cast("enum mpg123_mode", "MPG123_M_MONO"),
	LEFT = ffi.cast("enum mpg123_channels", "MPG123_LEFT"),
	RIGHT = ffi.cast("enum mpg123_channels", "MPG123_RIGHT"),
	LR = ffi.cast("enum mpg123_channels", "MPG123_LR"),
	_1_0 = ffi.cast("enum mpg123_version", "MPG123_1_0"),
	_2_0 = ffi.cast("enum mpg123_version", "MPG123_2_0"),
	_2_5 = ffi.cast("enum mpg123_version", "MPG123_2_5"),
	FEATURE_ABI_UTF8OPEN = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_ABI_UTF8OPEN"),
	FEATURE_OUTPUT_8BIT = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_OUTPUT_8BIT"),
	FEATURE_OUTPUT_16BIT = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_OUTPUT_16BIT"),
	FEATURE_OUTPUT_32BIT = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_OUTPUT_32BIT"),
	FEATURE_INDEX = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_INDEX"),
	FEATURE_PARSE_ID3V2 = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_PARSE_ID3V2"),
	FEATURE_DECODE_LAYER1 = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_DECODE_LAYER1"),
	FEATURE_DECODE_LAYER2 = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_DECODE_LAYER2"),
	FEATURE_DECODE_LAYER3 = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_DECODE_LAYER3"),
	FEATURE_DECODE_ACCURATE = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_DECODE_ACCURATE"),
	FEATURE_DECODE_DOWNSAMPLE = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_DECODE_DOWNSAMPLE"),
	FEATURE_DECODE_NTOM = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_DECODE_NTOM"),
	FEATURE_PARSE_ICY = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_PARSE_ICY"),
	FEATURE_TIMEOUT_READ = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_TIMEOUT_READ"),
	FEATURE_EQUALIZER = ffi.cast("enum mpg123_feature_set", "MPG123_FEATURE_EQUALIZER"),
}
library.clib = CLIB
return library
