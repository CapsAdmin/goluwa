local ffi = require("ffi")
local CLIB = assert(ffi.load("lame"))
ffi.cdef([[typedef enum lame_errorcodes_t{LAME_OKAY=0,LAME_NOERROR=0,LAME_GENERICERROR=-1,LAME_NOMEM=-10,LAME_BADBITRATE=-11,LAME_BADSAMPFREQ=-12,LAME_INTERNALERROR=-13};
struct _IO_marker {};
struct _IO_codecvt {};
struct _IO_wide_data {};
struct _IO_FILE {int _flags;char*_IO_read_ptr;char*_IO_read_end;char*_IO_read_base;char*_IO_write_base;char*_IO_write_ptr;char*_IO_write_end;char*_IO_buf_base;char*_IO_buf_end;char*_IO_save_base;char*_IO_backup_base;char*_IO_save_end;struct _IO_marker*_markers;struct _IO_FILE*_chain;int _fileno;int _flags2;long _old_offset;unsigned short _cur_column;signed char _vtable_offset;char _shortbuf[1];void*_lock;long _offset;struct _IO_codecvt*_codecvt;struct _IO_wide_data*_wide_data;struct _IO_FILE*_freeres_list;void*_freeres_buf;unsigned long __pad5;int _mode;char _unused2[15*sizeof(int)-4*sizeof(void*)-sizeof(size_t)];};
struct lame_global_struct {};
int(lame_get_num_channels)(const struct lame_global_struct*);
int(lame_set_lowpasswidth)(struct lame_global_struct*,int);
int(lame_set_scale)(struct lame_global_struct*,float);
int(lame_get_lowpasswidth)(const struct lame_global_struct*);
int(lame_set_highpassfreq)(struct lame_global_struct*,int);
float(lame_get_scale)(const struct lame_global_struct*);
int(lame_get_highpassfreq)(const struct lame_global_struct*);
int(lame_set_scale_left)(struct lame_global_struct*,float);
int(lame_set_highpasswidth)(struct lame_global_struct*,int);
float(lame_get_scale_left)(const struct lame_global_struct*);
int(lame_get_highpasswidth)(const struct lame_global_struct*);
int(lame_set_scale_right)(struct lame_global_struct*,float);
int(lame_set_ATHonly)(struct lame_global_struct*,int);
float(lame_get_scale_right)(const struct lame_global_struct*);
int(lame_get_ATHonly)(const struct lame_global_struct*);
int(lame_set_out_samplerate)(struct lame_global_struct*,int);
int(lame_set_ATHshort)(struct lame_global_struct*,int);
int(lame_get_out_samplerate)(const struct lame_global_struct*);
int(lame_get_ATHshort)(const struct lame_global_struct*);
int(lame_set_analysis)(struct lame_global_struct*,int);
int(lame_set_noATH)(struct lame_global_struct*,int);
int(lame_get_analysis)(const struct lame_global_struct*);
int(lame_get_noATH)(const struct lame_global_struct*);
int(lame_set_bWriteVbrTag)(struct lame_global_struct*,int);
int(lame_set_ATHtype)(struct lame_global_struct*,int);
int(lame_set_decode_only)(struct lame_global_struct*,int);
int(lame_set_ATHlower)(struct lame_global_struct*,float);
int(lame_get_decode_only)(const struct lame_global_struct*);
float(lame_get_ATHlower)(const struct lame_global_struct*);
int(lame_set_quality)(struct lame_global_struct*,int);
int(lame_set_athaa_type)(struct lame_global_struct*,int);
int(lame_get_quality)(const struct lame_global_struct*);
int(lame_get_athaa_type)(const struct lame_global_struct*);
int(lame_set_mode)(struct lame_global_struct*,enum MPEG_mode_e);
int(lame_set_athaa_sensitivity)(struct lame_global_struct*,float);
float(lame_get_athaa_sensitivity)(const struct lame_global_struct*);
enum MPEG_mode_e(lame_get_mode)(const struct lame_global_struct*);
int(lame_set_allow_diff_short)(struct lame_global_struct*,int);
int(lame_set_force_ms)(struct lame_global_struct*,int);
int(lame_get_allow_diff_short)(const struct lame_global_struct*);
int(lame_get_force_ms)(const struct lame_global_struct*);
int(lame_set_useTemporal)(struct lame_global_struct*,int);
int(lame_set_free_format)(struct lame_global_struct*,int);
int(lame_get_free_format)(const struct lame_global_struct*);
int(lame_set_interChRatio)(struct lame_global_struct*,float);
float(lame_get_interChRatio)(const struct lame_global_struct*);
int(lame_get_findReplayGain)(const struct lame_global_struct*);
int(lame_set_decode_on_the_fly)(struct lame_global_struct*,int);
int(lame_get_no_short_blocks)(const struct lame_global_struct*);
int(lame_get_decode_on_the_fly)(const struct lame_global_struct*);
int(lame_set_force_short_blocks)(struct lame_global_struct*,int);
int(lame_set_nogap_total)(struct lame_global_struct*,int);
int(lame_get_force_short_blocks)(const struct lame_global_struct*);
int(lame_get_nogap_total)(const struct lame_global_struct*);
int(lame_set_nogap_currentindex)(struct lame_global_struct*,int);
int(lame_get_emphasis)(const struct lame_global_struct*);
int(lame_get_nogap_currentindex)(const struct lame_global_struct*);
int(lame_get_version)(const struct lame_global_struct*);
int(lame_set_errorf)(struct lame_global_struct*,void(*unknown_2)(const char*,__builtin_va_list));
int(lame_get_encoder_delay)(const struct lame_global_struct*);
int(lame_set_debugf)(struct lame_global_struct*,void(*unknown_2)(const char*,__builtin_va_list));
int(lame_set_msgf)(struct lame_global_struct*,void(*unknown_2)(const char*,__builtin_va_list));
int(lame_set_brate)(struct lame_global_struct*,int);
int(lame_get_brate)(const struct lame_global_struct*);
int(lame_set_compression_ratio)(struct lame_global_struct*,float);
int(lame_get_frameNum)(const struct lame_global_struct*);
float(lame_get_compression_ratio)(const struct lame_global_struct*);
int(lame_get_totalframes)(const struct lame_global_struct*);
int(lame_set_preset)(struct lame_global_struct*,int);
int(lame_set_asm_optimizations)(struct lame_global_struct*,int,int);
int(lame_set_copyright)(struct lame_global_struct*,int);
int(lame_get_copyright)(const struct lame_global_struct*);
float(lame_get_noclipScale)(const struct lame_global_struct*);
int(lame_set_original)(struct lame_global_struct*,int);
int(lame_get_original)(const struct lame_global_struct*);
int(lame_init_params)(struct lame_global_struct*);
int(lame_get_error_protection)(const struct lame_global_struct*);
int(lame_set_quant_comp)(struct lame_global_struct*,int);
int(lame_get_quant_comp)(const struct lame_global_struct*);
void(lame_print_config)(const struct lame_global_struct*);
int(lame_set_quant_comp_short)(struct lame_global_struct*,int);
void(lame_print_internals)(const struct lame_global_struct*);
int(lame_get_quant_comp_short)(const struct lame_global_struct*);
int(lame_encode_buffer)(struct lame_global_struct*,const short,const short,const int,unsigned char*,const int);
int(lame_encode_buffer_interleaved)(struct lame_global_struct*,short,int,unsigned char*,int);
int(lame_encode_buffer_float)(struct lame_global_struct*,const float,const float,const int,unsigned char*,const int);
int(lame_encode_buffer_ieee_float)(struct lame_global_struct*,const float,const float,const int,unsigned char*,const int);
int(lame_encode_buffer_interleaved_ieee_float)(struct lame_global_struct*,const float,const int,unsigned char*,const int);
void(lame_mp3_tags_fid)(struct lame_global_struct*,struct _IO_FILE*);
int(lame_encode_buffer_ieee_double)(struct lame_global_struct*,const double,const double,const int,unsigned char*,const int);
unsigned long(lame_get_lametag_frame)(const struct lame_global_struct*,unsigned char*,unsigned long);
int(lame_encode_buffer_interleaved_ieee_double)(struct lame_global_struct*,const double,const int,unsigned char*,const int);
int(lame_close)(struct lame_global_struct*);
int(lame_encode_buffer_long)(struct lame_global_struct*,const long,const long,const int,unsigned char*,const int);
int(lame_encode_buffer_long2)(struct lame_global_struct*,const long,const long,const int,unsigned char*,const int);
int(lame_encode_buffer_int)(struct lame_global_struct*,const int,const int,const int,unsigned char*,const int);
int(lame_encode_buffer_interleaved_int)(struct lame_global_struct*,const int,const int,unsigned char*,const int);
int(lame_encode_flush)(struct lame_global_struct*,unsigned char*,int);
int(lame_encode_flush_nogap)(struct lame_global_struct*,unsigned char*,int);
int(lame_init_bitstream)(struct lame_global_struct*);
void(lame_bitrate_hist)(const struct lame_global_struct*,int);
void(lame_bitrate_kbps)(const struct lame_global_struct*,int);
void(lame_stereo_mode_hist)(const struct lame_global_struct*,int);
void(lame_bitrate_stereo_mode_hist)(const struct lame_global_struct*,int);
void(lame_block_type_hist)(const struct lame_global_struct*,int);
void(lame_bitrate_block_type_hist)(const struct lame_global_struct*,int);
int(lame_get_samplerate)(int,int);
int(lame_get_bitrate)(int,int);
int(lame_get_write_id3tag_automatic)(const struct lame_global_struct*);
void(lame_set_write_id3tag_automatic)(struct lame_global_struct*,int);
unsigned long(lame_get_id3v2_tag)(struct lame_global_struct*,unsigned char*,unsigned long);
unsigned long(lame_get_id3v1_tag)(struct lame_global_struct*,unsigned char*,unsigned long);
int(lame_set_no_short_blocks)(struct lame_global_struct*,int);
unsigned long(lame_get_num_samples)(const struct lame_global_struct*);
int(lame_get_AudiophileGain)(const struct lame_global_struct*);
int(lame_set_num_samples)(struct lame_global_struct*,unsigned long);
struct lame_global_struct*(lame_init)();
int(lame_get_RadioGain)(const struct lame_global_struct*);
int(lame_get_useTemporal)(const struct lame_global_struct*);
int(lame_get_ATHtype)(const struct lame_global_struct*);
int(lame_set_findReplayGain)(struct lame_global_struct*,int);
int(lame_get_size_mp3buffer)(const struct lame_global_struct*);
int(lame_get_noclipGainChange)(const struct lame_global_struct*);
int(lame_set_extension)(struct lame_global_struct*,int);
int(lame_get_extension)(const struct lame_global_struct*);
int(lame_set_strict_ISO)(struct lame_global_struct*,int);
int(lame_get_experimentalX)(const struct lame_global_struct*);
int(lame_set_experimentalY)(struct lame_global_struct*,int);
int(lame_get_strict_ISO)(const struct lame_global_struct*);
int(lame_get_experimentalY)(const struct lame_global_struct*);
int(lame_set_experimentalZ)(struct lame_global_struct*,int);
int(lame_get_experimentalZ)(const struct lame_global_struct*);
int(lame_set_disable_reservoir)(struct lame_global_struct*,int);
int(lame_set_exp_nspsytune)(struct lame_global_struct*,int);
int(lame_get_exp_nspsytune)(const struct lame_global_struct*);
int(lame_set_experimentalX)(struct lame_global_struct*,int);
void(lame_set_msfix)(struct lame_global_struct*,double);
int(lame_get_disable_reservoir)(const struct lame_global_struct*);
float(lame_get_msfix)(const struct lame_global_struct*);
int(lame_set_error_protection)(struct lame_global_struct*,int);
int(lame_set_VBR)(struct lame_global_struct*,enum vbr_mode_e);
int(lame_get_bWriteVbrTag)(const struct lame_global_struct*);
int(lame_get_framesize)(const struct lame_global_struct*);
enum vbr_mode_e(lame_get_VBR)(const struct lame_global_struct*);
int(lame_set_VBR_q)(struct lame_global_struct*,int);
int(lame_get_VBR_q)(const struct lame_global_struct*);
int(lame_set_VBR_quality)(struct lame_global_struct*,float);
float(lame_get_VBR_quality)(const struct lame_global_struct*);
int(lame_set_emphasis)(struct lame_global_struct*,int);
int(lame_set_VBR_mean_bitrate_kbps)(struct lame_global_struct*,int);
int(lame_get_mf_samples_to_encode)(const struct lame_global_struct*);
int(lame_get_VBR_mean_bitrate_kbps)(const struct lame_global_struct*);
float(lame_get_PeakSample)(const struct lame_global_struct*);
int(lame_set_VBR_min_bitrate_kbps)(struct lame_global_struct*,int);
int(lame_get_maximum_number_of_samples)(struct lame_global_struct*,unsigned long);
int(lame_get_VBR_min_bitrate_kbps)(const struct lame_global_struct*);
int(lame_set_VBR_max_bitrate_kbps)(struct lame_global_struct*,int);
int(lame_get_VBR_max_bitrate_kbps)(const struct lame_global_struct*);
int(lame_get_encoder_padding)(const struct lame_global_struct*);
int(lame_set_VBR_hard_min)(struct lame_global_struct*,int);
int(lame_set_in_samplerate)(struct lame_global_struct*,int);
int(lame_get_VBR_hard_min)(const struct lame_global_struct*);
int(lame_get_in_samplerate)(const struct lame_global_struct*);
int(lame_set_lowpassfreq)(struct lame_global_struct*,int);
int(lame_set_num_channels)(struct lame_global_struct*,int);
int(lame_get_lowpassfreq)(const struct lame_global_struct*);
]])
local library = {}
library = {
	GetNumChannels = CLIB.lame_get_num_channels,
	SetLowpasswidth = CLIB.lame_set_lowpasswidth,
	SetScale = CLIB.lame_set_scale,
	GetLowpasswidth = CLIB.lame_get_lowpasswidth,
	SetHighpassfreq = CLIB.lame_set_highpassfreq,
	GetScale = CLIB.lame_get_scale,
	GetHighpassfreq = CLIB.lame_get_highpassfreq,
	SetScaleLeft = CLIB.lame_set_scale_left,
	SetHighpasswidth = CLIB.lame_set_highpasswidth,
	GetScaleLeft = CLIB.lame_get_scale_left,
	GetHighpasswidth = CLIB.lame_get_highpasswidth,
	SetScaleRight = CLIB.lame_set_scale_right,
	Set_ATHonly = CLIB.lame_set_ATHonly,
	GetScaleRight = CLIB.lame_get_scale_right,
	Get_ATHonly = CLIB.lame_get_ATHonly,
	SetOutSamplerate = CLIB.lame_set_out_samplerate,
	Set_ATHshort = CLIB.lame_set_ATHshort,
	GetOutSamplerate = CLIB.lame_get_out_samplerate,
	Get_ATHshort = CLIB.lame_get_ATHshort,
	SetAnalysis = CLIB.lame_set_analysis,
	SetNoATH = CLIB.lame_set_noATH,
	GetAnalysis = CLIB.lame_get_analysis,
	GetNoATH = CLIB.lame_get_noATH,
	SetBWriteVbrTag = CLIB.lame_set_bWriteVbrTag,
	Set_ATHtype = CLIB.lame_set_ATHtype,
	SetDecodeOnly = CLIB.lame_set_decode_only,
	Set_ATHlower = CLIB.lame_set_ATHlower,
	GetDecodeOnly = CLIB.lame_get_decode_only,
	Get_ATHlower = CLIB.lame_get_ATHlower,
	SetQuality = CLIB.lame_set_quality,
	SetAthaaType = CLIB.lame_set_athaa_type,
	GetQuality = CLIB.lame_get_quality,
	GetAthaaType = CLIB.lame_get_athaa_type,
	SetMode = CLIB.lame_set_mode,
	SetAthaaSensitivity = CLIB.lame_set_athaa_sensitivity,
	GetAthaaSensitivity = CLIB.lame_get_athaa_sensitivity,
	GetMode = CLIB.lame_get_mode,
	SetAllowDiffShort = CLIB.lame_set_allow_diff_short,
	SetForceMs = CLIB.lame_set_force_ms,
	GetAllowDiffShort = CLIB.lame_get_allow_diff_short,
	GetForceMs = CLIB.lame_get_force_ms,
	SetUseTemporal = CLIB.lame_set_useTemporal,
	SetFreeFormat = CLIB.lame_set_free_format,
	GetFreeFormat = CLIB.lame_get_free_format,
	SetInterChRatio = CLIB.lame_set_interChRatio,
	GetInterChRatio = CLIB.lame_get_interChRatio,
	GetFindReplayGain = CLIB.lame_get_findReplayGain,
	SetDecodeOnTheFly = CLIB.lame_set_decode_on_the_fly,
	GetNoShortBlocks = CLIB.lame_get_no_short_blocks,
	GetDecodeOnTheFly = CLIB.lame_get_decode_on_the_fly,
	SetForceShortBlocks = CLIB.lame_set_force_short_blocks,
	SetNogapTotal = CLIB.lame_set_nogap_total,
	GetForceShortBlocks = CLIB.lame_get_force_short_blocks,
	GetNogapTotal = CLIB.lame_get_nogap_total,
	SetNogapCurrentindex = CLIB.lame_set_nogap_currentindex,
	GetEmphasis = CLIB.lame_get_emphasis,
	GetNogapCurrentindex = CLIB.lame_get_nogap_currentindex,
	GetVersion = CLIB.lame_get_version,
	SetErrorf = CLIB.lame_set_errorf,
	GetEncoderDelay = CLIB.lame_get_encoder_delay,
	SetDebugf = CLIB.lame_set_debugf,
	SetMsgf = CLIB.lame_set_msgf,
	SetBrate = CLIB.lame_set_brate,
	GetBrate = CLIB.lame_get_brate,
	SetCompressionRatio = CLIB.lame_set_compression_ratio,
	GetFrameNum = CLIB.lame_get_frameNum,
	GetCompressionRatio = CLIB.lame_get_compression_ratio,
	GetTotalframes = CLIB.lame_get_totalframes,
	SetPreset = CLIB.lame_set_preset,
	SetAsmOptimizations = CLIB.lame_set_asm_optimizations,
	SetCopyright = CLIB.lame_set_copyright,
	GetCopyright = CLIB.lame_get_copyright,
	GetNoclipScale = CLIB.lame_get_noclipScale,
	SetOriginal = CLIB.lame_set_original,
	GetOriginal = CLIB.lame_get_original,
	InitParams = CLIB.lame_init_params,
	GetErrorProtection = CLIB.lame_get_error_protection,
	SetQuantComp = CLIB.lame_set_quant_comp,
	GetQuantComp = CLIB.lame_get_quant_comp,
	PrintConfig = CLIB.lame_print_config,
	SetQuantCompShort = CLIB.lame_set_quant_comp_short,
	PrintInternals = CLIB.lame_print_internals,
	GetQuantCompShort = CLIB.lame_get_quant_comp_short,
	EncodeBuffer = CLIB.lame_encode_buffer,
	EncodeBufferInterleaved = CLIB.lame_encode_buffer_interleaved,
	EncodeBufferFloat = CLIB.lame_encode_buffer_float,
	EncodeBufferIeeeFloat = CLIB.lame_encode_buffer_ieee_float,
	EncodeBufferInterleavedIeeeFloat = CLIB.lame_encode_buffer_interleaved_ieee_float,
	Mp3TagsFid = CLIB.lame_mp3_tags_fid,
	EncodeBufferIeeeDouble = CLIB.lame_encode_buffer_ieee_double,
	GetLametagFrame = CLIB.lame_get_lametag_frame,
	EncodeBufferInterleavedIeeeDouble = CLIB.lame_encode_buffer_interleaved_ieee_double,
	Close = CLIB.lame_close,
	EncodeBufferLong = CLIB.lame_encode_buffer_long,
	EncodeBufferLong2 = CLIB.lame_encode_buffer_long2,
	EncodeBufferInt = CLIB.lame_encode_buffer_int,
	EncodeBufferInterleavedInt = CLIB.lame_encode_buffer_interleaved_int,
	EncodeFlush = CLIB.lame_encode_flush,
	EncodeFlushNogap = CLIB.lame_encode_flush_nogap,
	InitBitstream = CLIB.lame_init_bitstream,
	BitrateHist = CLIB.lame_bitrate_hist,
	BitrateKbps = CLIB.lame_bitrate_kbps,
	StereoModeHist = CLIB.lame_stereo_mode_hist,
	BitrateStereoModeHist = CLIB.lame_bitrate_stereo_mode_hist,
	BlockTypeHist = CLIB.lame_block_type_hist,
	BitrateBlockTypeHist = CLIB.lame_bitrate_block_type_hist,
	GetSamplerate = CLIB.lame_get_samplerate,
	GetBitrate = CLIB.lame_get_bitrate,
	GetWriteId3tagAutomatic = CLIB.lame_get_write_id3tag_automatic,
	SetWriteId3tagAutomatic = CLIB.lame_set_write_id3tag_automatic,
	GetId3v2Tag = CLIB.lame_get_id3v2_tag,
	GetId3v1Tag = CLIB.lame_get_id3v1_tag,
	SetNoShortBlocks = CLIB.lame_set_no_short_blocks,
	GetNumSamples = CLIB.lame_get_num_samples,
	Get_AudiophileGain = CLIB.lame_get_AudiophileGain,
	SetNumSamples = CLIB.lame_set_num_samples,
	Init = CLIB.lame_init,
	Get_RadioGain = CLIB.lame_get_RadioGain,
	GetUseTemporal = CLIB.lame_get_useTemporal,
	Get_ATHtype = CLIB.lame_get_ATHtype,
	SetFindReplayGain = CLIB.lame_set_findReplayGain,
	GetSizeMp3buffer = CLIB.lame_get_size_mp3buffer,
	GetNoclipGainChange = CLIB.lame_get_noclipGainChange,
	SetExtension = CLIB.lame_set_extension,
	GetExtension = CLIB.lame_get_extension,
	SetStrict_ISO = CLIB.lame_set_strict_ISO,
	GetExperimentalX = CLIB.lame_get_experimentalX,
	SetExperimentalY = CLIB.lame_set_experimentalY,
	GetStrict_ISO = CLIB.lame_get_strict_ISO,
	GetExperimentalY = CLIB.lame_get_experimentalY,
	SetExperimentalZ = CLIB.lame_set_experimentalZ,
	GetExperimentalZ = CLIB.lame_get_experimentalZ,
	SetDisableReservoir = CLIB.lame_set_disable_reservoir,
	SetExpNspsytune = CLIB.lame_set_exp_nspsytune,
	GetExpNspsytune = CLIB.lame_get_exp_nspsytune,
	SetExperimentalX = CLIB.lame_set_experimentalX,
	SetMsfix = CLIB.lame_set_msfix,
	GetDisableReservoir = CLIB.lame_get_disable_reservoir,
	GetMsfix = CLIB.lame_get_msfix,
	SetErrorProtection = CLIB.lame_set_error_protection,
	Set_VBR = CLIB.lame_set_VBR,
	GetBWriteVbrTag = CLIB.lame_get_bWriteVbrTag,
	GetFramesize = CLIB.lame_get_framesize,
	Get_VBR = CLIB.lame_get_VBR,
	Set_VBRQ = CLIB.lame_set_VBR_q,
	Get_VBRQ = CLIB.lame_get_VBR_q,
	Set_VBRQuality = CLIB.lame_set_VBR_quality,
	Get_VBRQuality = CLIB.lame_get_VBR_quality,
	SetEmphasis = CLIB.lame_set_emphasis,
	Set_VBRMeanBitrateKbps = CLIB.lame_set_VBR_mean_bitrate_kbps,
	GetMfSamplesToEncode = CLIB.lame_get_mf_samples_to_encode,
	Get_VBRMeanBitrateKbps = CLIB.lame_get_VBR_mean_bitrate_kbps,
	Get_PeakSample = CLIB.lame_get_PeakSample,
	Set_VBRMinBitrateKbps = CLIB.lame_set_VBR_min_bitrate_kbps,
	GetMaximumNumberOfSamples = CLIB.lame_get_maximum_number_of_samples,
	Get_VBRMinBitrateKbps = CLIB.lame_get_VBR_min_bitrate_kbps,
	Set_VBRMaxBitrateKbps = CLIB.lame_set_VBR_max_bitrate_kbps,
	Get_VBRMaxBitrateKbps = CLIB.lame_get_VBR_max_bitrate_kbps,
	GetEncoderPadding = CLIB.lame_get_encoder_padding,
	Set_VBRHardMin = CLIB.lame_set_VBR_hard_min,
	SetInSamplerate = CLIB.lame_set_in_samplerate,
	Get_VBRHardMin = CLIB.lame_get_VBR_hard_min,
	GetInSamplerate = CLIB.lame_get_in_samplerate,
	SetLowpassfreq = CLIB.lame_set_lowpassfreq,
	SetNumChannels = CLIB.lame_set_num_channels,
	GetLowpassfreq = CLIB.lame_get_lowpassfreq,
}
library.e = {
	OKAY = ffi.cast("enum lame_errorcodes_t", "LAME_OKAY"),
	NOERROR = ffi.cast("enum lame_errorcodes_t", "LAME_NOERROR"),
	GENERICERROR = ffi.cast("enum lame_errorcodes_t", "LAME_GENERICERROR"),
	NOMEM = ffi.cast("enum lame_errorcodes_t", "LAME_NOMEM"),
	BADBITRATE = ffi.cast("enum lame_errorcodes_t", "LAME_BADBITRATE"),
	BADSAMPFREQ = ffi.cast("enum lame_errorcodes_t", "LAME_BADSAMPFREQ"),
	INTERNALERROR = ffi.cast("enum lame_errorcodes_t", "LAME_INTERNALERROR"),
}
library.clib = CLIB
return library