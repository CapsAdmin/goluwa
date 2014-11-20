return  
{
	AVSEEK_FLAG_ANY = 4,
	AV_TIME_BASE = 1000000,
	AV_DICT_IGNORE_SUFFIX = 2,
	AV_NOPTS_VALUE = ffi.cast("uint64_t", math.huge),
	AV_TIME_BASE_Q = ffi.new("AVRational", {num = 1, den = 1000000}),
	CODEC_CAP_DELAY = 0x0020,
}