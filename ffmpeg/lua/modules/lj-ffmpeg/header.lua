-- built with
-- C:\mingw-builds\x64-4.8.1-posix-seh-rev5\mingw64\bin>gcc -E -o lol -I C:\goluwa\.base\bin\src\ffmpeg\include C:\goluwa\.base\bin\src\ffmpeg\include\main.c
-- and some manual work in notepad++ afterwards

return [[
typedef void * FILE;
unsigned avutil_version(void);
const char *avutil_configuration(void);
const char *avutil_license(void);
enum AVMediaType {
    AVMEDIA_TYPE_UNKNOWN = -1,
    AVMEDIA_TYPE_VIDEO,
    AVMEDIA_TYPE_AUDIO,
    AVMEDIA_TYPE_DATA,
    AVMEDIA_TYPE_SUBTITLE,
    AVMEDIA_TYPE_ATTACHMENT,
    AVMEDIA_TYPE_NB
};
const char *av_get_media_type_string(enum AVMediaType media_type);
enum AVPictureType {
    AV_PICTURE_TYPE_NONE = 0,
    AV_PICTURE_TYPE_I,
    AV_PICTURE_TYPE_P,
    AV_PICTURE_TYPE_B,
    AV_PICTURE_TYPE_S,
    AV_PICTURE_TYPE_SI,
    AV_PICTURE_TYPE_SP,
    AV_PICTURE_TYPE_BI,
};
char av_get_picture_type_char(enum AVPictureType pict_type);
extern __attribute__((deprecated)) const uint8_t av_reverse[256];
__attribute__((const)) int av_log2(unsigned v);
__attribute__((const)) int av_log2_16bit(unsigned v);
void *av_malloc(size_t size) __attribute__((__malloc__)) __attribute__((alloc_size(1)));
void *av_realloc(void *ptr, size_t size) __attribute__((alloc_size(2)));
void *av_realloc_f(void *ptr, size_t nelem, size_t elsize);
int av_reallocp(void *ptr, size_t size);
__attribute__((alloc_size(2, 3))) void *av_realloc_array(void *ptr, size_t nmemb, size_t size);
__attribute__((alloc_size(2, 3))) int av_reallocp_array(void *ptr, size_t nmemb, size_t size);
void av_free(void *ptr);
void *av_mallocz(size_t size) __attribute__((__malloc__)) __attribute__((alloc_size(1)));
void *av_calloc(size_t nmemb, size_t size) __attribute__((__malloc__));
char *av_strdup(const char *s) __attribute__((__malloc__));
void *av_memdup(const void *p, size_t size);
void av_freep(void *ptr);
void av_dynarray_add(void *tab_ptr, int *nb_ptr, void *elem);
int av_dynarray_add_nofree(void *tab_ptr, int *nb_ptr, void *elem);
void *av_dynarray2_add(void **tab_ptr, int *nb_ptr, size_t elem_size,
                       const uint8_t *elem_data);
void av_max_alloc(size_t max);
void av_memcpy_backptr(uint8_t *dst, int back, int cnt);
void *av_fast_realloc(void *ptr, unsigned int *size, size_t min_size);
void av_fast_malloc(void *ptr, unsigned int *size, size_t min_size);
typedef struct AVRational{
    int num;
    int den;
} AVRational;
int av_reduce(int *dst_num, int *dst_den, int64_t num, int64_t den, int64_t max);
AVRational av_mul_q(AVRational b, AVRational c) __attribute__((const));
AVRational av_div_q(AVRational b, AVRational c) __attribute__((const));
AVRational av_add_q(AVRational b, AVRational c) __attribute__((const));
AVRational av_sub_q(AVRational b, AVRational c) __attribute__((const));
AVRational av_d2q(double d, int max) __attribute__((const));
int av_nearer_q(AVRational q, AVRational q1, AVRational q2);
int av_find_nearest_q_idx(AVRational q, const AVRational* q_list);
union av_intfloat32 {
    uint32_t i;
    float f;
};
union av_intfloat64 {
    uint64_t i;
    double f;
};
enum AVRounding {
    AV_ROUND_ZERO = 0,
    AV_ROUND_INF = 1,
    AV_ROUND_DOWN = 2,
    AV_ROUND_UP = 3,
    AV_ROUND_NEAR_INF = 5,
    AV_ROUND_PASS_MINMAX = 8192,
};
int64_t __attribute__((const)) av_gcd(int64_t a, int64_t b);
int64_t av_rescale(int64_t a, int64_t b, int64_t c) __attribute__((const));
int64_t av_rescale_rnd(int64_t a, int64_t b, int64_t c, enum AVRounding) __attribute__((const));
int64_t av_rescale_q(int64_t a, AVRational bq, AVRational cq) __attribute__((const));
int64_t av_rescale_q_rnd(int64_t a, AVRational bq, AVRational cq,
                         enum AVRounding) __attribute__((const));
int av_compare_ts(int64_t ts_a, AVRational tb_a, int64_t ts_b, AVRational tb_b);
int64_t av_compare_mod(uint64_t a, uint64_t b, uint64_t mod);
int64_t av_rescale_delta(AVRational in_tb, int64_t in_ts, AVRational fs_tb, int duration, int64_t *last, AVRational out_tb);
int64_t av_add_stable(AVRational ts_tb, int64_t ts, AVRational inc_tb, int64_t inc);
typedef enum {
    AV_CLASS_CATEGORY_NA = 0,
    AV_CLASS_CATEGORY_INPUT,
    AV_CLASS_CATEGORY_OUTPUT,
    AV_CLASS_CATEGORY_MUXER,
    AV_CLASS_CATEGORY_DEMUXER,
    AV_CLASS_CATEGORY_ENCODER,
    AV_CLASS_CATEGORY_DECODER,
    AV_CLASS_CATEGORY_FILTER,
    AV_CLASS_CATEGORY_BITSTREAM_FILTER,
    AV_CLASS_CATEGORY_SWSCALER,
    AV_CLASS_CATEGORY_SWRESAMPLER,
    AV_CLASS_CATEGORY_DEVICE_VIDEO_OUTPUT = 40,
    AV_CLASS_CATEGORY_DEVICE_VIDEO_INPUT,
    AV_CLASS_CATEGORY_DEVICE_AUDIO_OUTPUT,
    AV_CLASS_CATEGORY_DEVICE_AUDIO_INPUT,
    AV_CLASS_CATEGORY_DEVICE_OUTPUT,
    AV_CLASS_CATEGORY_DEVICE_INPUT,
    AV_CLASS_CATEGORY_NB,
}AVClassCategory;
struct AVOptionRanges;
typedef struct AVClass {
    const char* class_name;
    const char* (*item_name)(void* ctx);
    const struct AVOption *option;
    int version;
    int log_level_offset_offset;
    int parent_log_context_offset;
    void* (*child_next)(void *obj, void *prev);
    const struct AVClass* (*child_class_next)(const struct AVClass *prev);
    AVClassCategory category;
    AVClassCategory (*get_category)(void* ctx);
    int (*query_ranges)(struct AVOptionRanges **, void *obj, const char *key, int flags);
} AVClass;
void av_log(void *avcl, int level, const char *fmt, ...) __attribute__((__format__(__printf__, 3, 4)));
void av_vlog(void *avcl, int level, const char *fmt, va_list vl);
int av_log_get_level(void);
void av_log_set_level(int level);
void av_log_set_callback(void (*callback)(void*, int, const char*, va_list));
void av_log_default_callback(void *avcl, int level, const char *fmt,
                             va_list vl);
const char* av_default_item_name(void* ctx);
AVClassCategory av_default_get_category(void *ptr);
void av_log_format_line(void *ptr, int level, const char *fmt, va_list vl,
                        char *line, int line_size, int *print_prefix);
void av_log_set_flags(int arg);
int av_log_get_flags(void);
enum AVPixelFormat {
    AV_PIX_FMT_NONE = -1,
    AV_PIX_FMT_YUV420P,
    AV_PIX_FMT_YUYV422,
    AV_PIX_FMT_RGB24,
    AV_PIX_FMT_BGR24,
    AV_PIX_FMT_YUV422P,
    AV_PIX_FMT_YUV444P,
    AV_PIX_FMT_YUV410P,
    AV_PIX_FMT_YUV411P,
    AV_PIX_FMT_GRAY8,
    AV_PIX_FMT_MONOWHITE,
    AV_PIX_FMT_MONOBLACK,
    AV_PIX_FMT_PAL8,
    AV_PIX_FMT_YUVJ420P,
    AV_PIX_FMT_YUVJ422P,
    AV_PIX_FMT_YUVJ444P,
    AV_PIX_FMT_XVMC_MPEG2_MC,
    AV_PIX_FMT_XVMC_MPEG2_IDCT,
    AV_PIX_FMT_UYVY422,
    AV_PIX_FMT_UYYVYY411,
    AV_PIX_FMT_BGR8,
    AV_PIX_FMT_BGR4,
    AV_PIX_FMT_BGR4_BYTE,
    AV_PIX_FMT_RGB8,
    AV_PIX_FMT_RGB4,
    AV_PIX_FMT_RGB4_BYTE,
    AV_PIX_FMT_NV12,
    AV_PIX_FMT_NV21,
    AV_PIX_FMT_ARGB,
    AV_PIX_FMT_RGBA,
    AV_PIX_FMT_ABGR,
    AV_PIX_FMT_BGRA,
    AV_PIX_FMT_GRAY16BE,
    AV_PIX_FMT_GRAY16LE,
    AV_PIX_FMT_YUV440P,
    AV_PIX_FMT_YUVJ440P,
    AV_PIX_FMT_YUVA420P,
    AV_PIX_FMT_VDPAU_H264,
    AV_PIX_FMT_VDPAU_MPEG1,
    AV_PIX_FMT_VDPAU_MPEG2,
    AV_PIX_FMT_VDPAU_WMV3,
    AV_PIX_FMT_VDPAU_VC1,
    AV_PIX_FMT_RGB48BE,
    AV_PIX_FMT_RGB48LE,
    AV_PIX_FMT_RGB565BE,
    AV_PIX_FMT_RGB565LE,
    AV_PIX_FMT_RGB555BE,
    AV_PIX_FMT_RGB555LE,
    AV_PIX_FMT_BGR565BE,
    AV_PIX_FMT_BGR565LE,
    AV_PIX_FMT_BGR555BE,
    AV_PIX_FMT_BGR555LE,
    AV_PIX_FMT_VAAPI_MOCO,
    AV_PIX_FMT_VAAPI_IDCT,
    AV_PIX_FMT_VAAPI_VLD,
    AV_PIX_FMT_YUV420P16LE,
    AV_PIX_FMT_YUV420P16BE,
    AV_PIX_FMT_YUV422P16LE,
    AV_PIX_FMT_YUV422P16BE,
    AV_PIX_FMT_YUV444P16LE,
    AV_PIX_FMT_YUV444P16BE,
    AV_PIX_FMT_VDPAU_MPEG4,
    AV_PIX_FMT_DXVA2_VLD,
    AV_PIX_FMT_RGB444LE,
    AV_PIX_FMT_RGB444BE,
    AV_PIX_FMT_BGR444LE,
    AV_PIX_FMT_BGR444BE,
    AV_PIX_FMT_GRAY8A,
    AV_PIX_FMT_BGR48BE,
    AV_PIX_FMT_BGR48LE,
    AV_PIX_FMT_YUV420P9BE,
    AV_PIX_FMT_YUV420P9LE,
    AV_PIX_FMT_YUV420P10BE,
    AV_PIX_FMT_YUV420P10LE,
    AV_PIX_FMT_YUV422P10BE,
    AV_PIX_FMT_YUV422P10LE,
    AV_PIX_FMT_YUV444P9BE,
    AV_PIX_FMT_YUV444P9LE,
    AV_PIX_FMT_YUV444P10BE,
    AV_PIX_FMT_YUV444P10LE,
    AV_PIX_FMT_YUV422P9BE,
    AV_PIX_FMT_YUV422P9LE,
    AV_PIX_FMT_VDA_VLD,
    AV_PIX_FMT_GBRP,
    AV_PIX_FMT_GBRP9BE,
    AV_PIX_FMT_GBRP9LE,
    AV_PIX_FMT_GBRP10BE,
    AV_PIX_FMT_GBRP10LE,
    AV_PIX_FMT_GBRP16BE,
    AV_PIX_FMT_GBRP16LE,
    AV_PIX_FMT_YUVA422P_LIBAV,
    AV_PIX_FMT_YUVA444P_LIBAV,
    AV_PIX_FMT_YUVA420P9BE,
    AV_PIX_FMT_YUVA420P9LE,
    AV_PIX_FMT_YUVA422P9BE,
    AV_PIX_FMT_YUVA422P9LE,
    AV_PIX_FMT_YUVA444P9BE,
    AV_PIX_FMT_YUVA444P9LE,
    AV_PIX_FMT_YUVA420P10BE,
    AV_PIX_FMT_YUVA420P10LE,
    AV_PIX_FMT_YUVA422P10BE,
    AV_PIX_FMT_YUVA422P10LE,
    AV_PIX_FMT_YUVA444P10BE,
    AV_PIX_FMT_YUVA444P10LE,
    AV_PIX_FMT_YUVA420P16BE,
    AV_PIX_FMT_YUVA420P16LE,
    AV_PIX_FMT_YUVA422P16BE,
    AV_PIX_FMT_YUVA422P16LE,
    AV_PIX_FMT_YUVA444P16BE,
    AV_PIX_FMT_YUVA444P16LE,
    AV_PIX_FMT_VDPAU,
    AV_PIX_FMT_XYZ12LE,
    AV_PIX_FMT_XYZ12BE,
    AV_PIX_FMT_NV16,
    AV_PIX_FMT_NV20LE,
    AV_PIX_FMT_NV20BE,
    AV_PIX_FMT_RGBA64BE_LIBAV,
    AV_PIX_FMT_RGBA64LE_LIBAV,
    AV_PIX_FMT_BGRA64BE_LIBAV,
    AV_PIX_FMT_BGRA64LE_LIBAV,
    AV_PIX_FMT_YVYU422,
    AV_PIX_FMT_RGBA64BE=0x123,
    AV_PIX_FMT_RGBA64LE,
    AV_PIX_FMT_BGRA64BE,
    AV_PIX_FMT_BGRA64LE,
    AV_PIX_FMT_0RGB=0x123+4,
    AV_PIX_FMT_RGB0,
    AV_PIX_FMT_0BGR,
    AV_PIX_FMT_BGR0,
    AV_PIX_FMT_YUVA444P,
    AV_PIX_FMT_YUVA422P,
    AV_PIX_FMT_YUV420P12BE,
    AV_PIX_FMT_YUV420P12LE,
    AV_PIX_FMT_YUV420P14BE,
    AV_PIX_FMT_YUV420P14LE,
    AV_PIX_FMT_YUV422P12BE,
    AV_PIX_FMT_YUV422P12LE,
    AV_PIX_FMT_YUV422P14BE,
    AV_PIX_FMT_YUV422P14LE,
    AV_PIX_FMT_YUV444P12BE,
    AV_PIX_FMT_YUV444P12LE,
    AV_PIX_FMT_YUV444P14BE,
    AV_PIX_FMT_YUV444P14LE,
    AV_PIX_FMT_GBRP12BE,
    AV_PIX_FMT_GBRP12LE,
    AV_PIX_FMT_GBRP14BE,
    AV_PIX_FMT_GBRP14LE,
    AV_PIX_FMT_GBRAP,
    AV_PIX_FMT_GBRAP16BE,
    AV_PIX_FMT_GBRAP16LE,
    AV_PIX_FMT_YUVJ411P,
    AV_PIX_FMT_BAYER_BGGR8,
    AV_PIX_FMT_BAYER_RGGB8,
    AV_PIX_FMT_BAYER_GBRG8,
    AV_PIX_FMT_BAYER_GRBG8,
    AV_PIX_FMT_BAYER_BGGR16LE,
    AV_PIX_FMT_BAYER_BGGR16BE,
    AV_PIX_FMT_BAYER_RGGB16LE,
    AV_PIX_FMT_BAYER_RGGB16BE,
    AV_PIX_FMT_BAYER_GBRG16LE,
    AV_PIX_FMT_BAYER_GBRG16BE,
    AV_PIX_FMT_BAYER_GRBG16LE,
    AV_PIX_FMT_BAYER_GRBG16BE,
    AV_PIX_FMT_NB,
    PIX_FMT_NONE = AV_PIX_FMT_NONE,
    PIX_FMT_YUV420P,
    PIX_FMT_YUYV422,
    PIX_FMT_RGB24,
    PIX_FMT_BGR24,
    PIX_FMT_YUV422P,
    PIX_FMT_YUV444P,
    PIX_FMT_YUV410P,
    PIX_FMT_YUV411P,
    PIX_FMT_GRAY8,
    PIX_FMT_MONOWHITE,
    PIX_FMT_MONOBLACK,
    PIX_FMT_PAL8,
    PIX_FMT_YUVJ420P,
    PIX_FMT_YUVJ422P,
    PIX_FMT_YUVJ444P,
    PIX_FMT_XVMC_MPEG2_MC,
    PIX_FMT_XVMC_MPEG2_IDCT,
    PIX_FMT_UYVY422,
    PIX_FMT_UYYVYY411,
    PIX_FMT_BGR8,
    PIX_FMT_BGR4,
    PIX_FMT_BGR4_BYTE,
    PIX_FMT_RGB8,
    PIX_FMT_RGB4,
    PIX_FMT_RGB4_BYTE,
    PIX_FMT_NV12,
    PIX_FMT_NV21,
    PIX_FMT_ARGB,
    PIX_FMT_RGBA,
    PIX_FMT_ABGR,
    PIX_FMT_BGRA,
    PIX_FMT_GRAY16BE,
    PIX_FMT_GRAY16LE,
    PIX_FMT_YUV440P,
    PIX_FMT_YUVJ440P,
    PIX_FMT_YUVA420P,
    PIX_FMT_VDPAU_H264,
    PIX_FMT_VDPAU_MPEG1,
    PIX_FMT_VDPAU_MPEG2,
    PIX_FMT_VDPAU_WMV3,
    PIX_FMT_VDPAU_VC1,
    PIX_FMT_RGB48BE,
    PIX_FMT_RGB48LE,
    PIX_FMT_RGB565BE,
    PIX_FMT_RGB565LE,
    PIX_FMT_RGB555BE,
    PIX_FMT_RGB555LE,
    PIX_FMT_BGR565BE,
    PIX_FMT_BGR565LE,
    PIX_FMT_BGR555BE,
    PIX_FMT_BGR555LE,
    PIX_FMT_VAAPI_MOCO,
    PIX_FMT_VAAPI_IDCT,
    PIX_FMT_VAAPI_VLD,
    PIX_FMT_YUV420P16LE,
    PIX_FMT_YUV420P16BE,
    PIX_FMT_YUV422P16LE,
    PIX_FMT_YUV422P16BE,
    PIX_FMT_YUV444P16LE,
    PIX_FMT_YUV444P16BE,
    PIX_FMT_VDPAU_MPEG4,
    PIX_FMT_DXVA2_VLD,
    PIX_FMT_RGB444LE,
    PIX_FMT_RGB444BE,
    PIX_FMT_BGR444LE,
    PIX_FMT_BGR444BE,
    PIX_FMT_GRAY8A,
    PIX_FMT_BGR48BE,
    PIX_FMT_BGR48LE,
    PIX_FMT_YUV420P9BE,
    PIX_FMT_YUV420P9LE,
    PIX_FMT_YUV420P10BE,
    PIX_FMT_YUV420P10LE,
    PIX_FMT_YUV422P10BE,
    PIX_FMT_YUV422P10LE,
    PIX_FMT_YUV444P9BE,
    PIX_FMT_YUV444P9LE,
    PIX_FMT_YUV444P10BE,
    PIX_FMT_YUV444P10LE,
    PIX_FMT_YUV422P9BE,
    PIX_FMT_YUV422P9LE,
    PIX_FMT_VDA_VLD,
    PIX_FMT_GBRP,
    PIX_FMT_GBRP9BE,
    PIX_FMT_GBRP9LE,
    PIX_FMT_GBRP10BE,
    PIX_FMT_GBRP10LE,
    PIX_FMT_GBRP16BE,
    PIX_FMT_GBRP16LE,
    PIX_FMT_RGBA64BE=0x123,
    PIX_FMT_RGBA64LE,
    PIX_FMT_BGRA64BE,
    PIX_FMT_BGRA64LE,
    PIX_FMT_0RGB=0x123+4,
    PIX_FMT_RGB0,
    PIX_FMT_0BGR,
    PIX_FMT_BGR0,
    PIX_FMT_YUVA444P,
    PIX_FMT_YUVA422P,
    PIX_FMT_YUV420P12BE,
    PIX_FMT_YUV420P12LE,
    PIX_FMT_YUV420P14BE,
    PIX_FMT_YUV420P14LE,
    PIX_FMT_YUV422P12BE,
    PIX_FMT_YUV422P12LE,
    PIX_FMT_YUV422P14BE,
    PIX_FMT_YUV422P14LE,
    PIX_FMT_YUV444P12BE,
    PIX_FMT_YUV444P12LE,
    PIX_FMT_YUV444P14BE,
    PIX_FMT_YUV444P14LE,
    PIX_FMT_GBRP12BE,
    PIX_FMT_GBRP12LE,
    PIX_FMT_GBRP14BE,
    PIX_FMT_GBRP14LE,
    PIX_FMT_NB,
};
unsigned av_int_list_length_for_size(unsigned elsize,
                                     const void *list, uint64_t term) __attribute__((pure));
FILE *av_fopen_utf8(const char *path, const char *mode);
AVRational av_get_time_base_q(void);
enum AVSampleFormat {
    AV_SAMPLE_FMT_NONE = -1,
    AV_SAMPLE_FMT_U8,
    AV_SAMPLE_FMT_S16,
    AV_SAMPLE_FMT_S32,
    AV_SAMPLE_FMT_FLT,
    AV_SAMPLE_FMT_DBL,
    AV_SAMPLE_FMT_U8P,
    AV_SAMPLE_FMT_S16P,
    AV_SAMPLE_FMT_S32P,
    AV_SAMPLE_FMT_FLTP,
    AV_SAMPLE_FMT_DBLP,
    AV_SAMPLE_FMT_NB
};
const char *av_get_sample_fmt_name(enum AVSampleFormat sample_fmt);
enum AVSampleFormat av_get_sample_fmt(const char *name);
enum AVSampleFormat av_get_alt_sample_fmt(enum AVSampleFormat sample_fmt, int planar);
enum AVSampleFormat av_get_packed_sample_fmt(enum AVSampleFormat sample_fmt);
enum AVSampleFormat av_get_planar_sample_fmt(enum AVSampleFormat sample_fmt);
char *av_get_sample_fmt_string(char *buf, int buf_size, enum AVSampleFormat sample_fmt);
__attribute__((deprecated))
int av_get_bits_per_sample_fmt(enum AVSampleFormat sample_fmt);
int av_get_bytes_per_sample(enum AVSampleFormat sample_fmt);
int av_sample_fmt_is_planar(enum AVSampleFormat sample_fmt);
int av_samples_get_buffer_size(int *linesize, int nb_channels, int nb_samples,
                               enum AVSampleFormat sample_fmt, int align);
int av_samples_fill_arrays(uint8_t **audio_data, int *linesize,
                           const uint8_t *buf,
                           int nb_channels, int nb_samples,
                           enum AVSampleFormat sample_fmt, int align);
int av_samples_alloc(uint8_t **audio_data, int *linesize, int nb_channels,
                     int nb_samples, enum AVSampleFormat sample_fmt, int align);
int av_samples_alloc_array_and_samples(uint8_t ***audio_data, int *linesize, int nb_channels,
                                       int nb_samples, enum AVSampleFormat sample_fmt, int align);
int av_samples_copy(uint8_t **dst, uint8_t * const *src, int dst_offset,
                    int src_offset, int nb_samples, int nb_channels,
                    enum AVSampleFormat sample_fmt);
int av_samples_set_silence(uint8_t **audio_data, int offset, int nb_samples,
                           int nb_channels, enum AVSampleFormat sample_fmt);
typedef struct AVBuffer AVBuffer;
typedef struct AVBufferRef {
    AVBuffer *buffer;
    uint8_t *data;
    int size;
} AVBufferRef;
AVBufferRef *av_buffer_alloc(int size);
AVBufferRef *av_buffer_allocz(int size);
AVBufferRef *av_buffer_create(uint8_t *data, int size,
                              void (*free)(void *opaque, uint8_t *data),
                              void *opaque, int flags);
void av_buffer_default_free(void *opaque, uint8_t *data);
AVBufferRef *av_buffer_ref(AVBufferRef *buf);
void av_buffer_unref(AVBufferRef **buf);
int av_buffer_is_writable(const AVBufferRef *buf);
void *av_buffer_get_opaque(const AVBufferRef *buf);
int av_buffer_get_ref_count(const AVBufferRef *buf);
int av_buffer_make_writable(AVBufferRef **buf);
int av_buffer_realloc(AVBufferRef **buf, int size);
typedef struct AVBufferPool AVBufferPool;
AVBufferPool *av_buffer_pool_init(int size, AVBufferRef* (*alloc)(int size));
void av_buffer_pool_uninit(AVBufferPool **pool);
AVBufferRef *av_buffer_pool_get(AVBufferPool *pool);
int av_get_cpu_flags(void);
void av_force_cpu_flags(int flags);
__attribute__((deprecated)) void av_set_cpu_flags_mask(int mask);
__attribute__((deprecated))
int av_parse_cpu_flags(const char *s);
int av_parse_cpu_caps(unsigned *flags, const char *s);
int av_cpu_count(void);
enum AVMatrixEncoding {
    AV_MATRIX_ENCODING_NONE,
    AV_MATRIX_ENCODING_DOLBY,
    AV_MATRIX_ENCODING_DPLII,
    AV_MATRIX_ENCODING_DPLIIX,
    AV_MATRIX_ENCODING_DPLIIZ,
    AV_MATRIX_ENCODING_DOLBYEX,
    AV_MATRIX_ENCODING_DOLBYHEADPHONE,
    AV_MATRIX_ENCODING_NB
};
uint64_t av_get_channel_layout(const char *name);
void av_get_channel_layout_string(char *buf, int buf_size, int nb_channels, uint64_t channel_layout);
struct AVBPrint;
void av_bprint_channel_layout(struct AVBPrint *bp, int nb_channels, uint64_t channel_layout);
int av_get_channel_layout_nb_channels(uint64_t channel_layout);
int64_t av_get_default_channel_layout(int nb_channels);
int av_get_channel_layout_channel_index(uint64_t channel_layout,
                                        uint64_t channel);
uint64_t av_channel_layout_extract_channel(uint64_t channel_layout, int index);
const char *av_get_channel_name(uint64_t channel);
const char *av_get_channel_description(uint64_t channel);
int av_get_standard_channel_layout(unsigned index, uint64_t *layout,
                                   const char **name);
typedef struct AVDictionaryEntry {
    char *key;
    char *value;
} AVDictionaryEntry;
typedef struct AVDictionary AVDictionary;
AVDictionaryEntry *
av_dict_get(const AVDictionary *m, const char *key, const AVDictionaryEntry *prev, int flags);
int av_dict_count(const AVDictionary *m);
int av_dict_set(AVDictionary **pm, const char *key, const char *value, int flags);
int av_dict_parse_string(AVDictionary **pm, const char *str,
                         const char *key_val_sep, const char *pairs_sep,
                         int flags);
void av_dict_copy(AVDictionary **dst, const AVDictionary *src, int flags);
void av_dict_free(AVDictionary **m);
enum AVColorSpace{
    AVCOL_SPC_RGB = 0,
    AVCOL_SPC_BT709 = 1,
    AVCOL_SPC_UNSPECIFIED = 2,
    AVCOL_SPC_FCC = 4,
    AVCOL_SPC_BT470BG = 5,
    AVCOL_SPC_SMPTE170M = 6,
    AVCOL_SPC_SMPTE240M = 7,
    AVCOL_SPC_YCOCG = 8,
    AVCOL_SPC_BT2020_NCL = 9,
    AVCOL_SPC_BT2020_CL = 10,
    AVCOL_SPC_NB ,
};
enum AVColorRange{
    AVCOL_RANGE_UNSPECIFIED = 0,
    AVCOL_RANGE_MPEG = 1,
    AVCOL_RANGE_JPEG = 2,
    AVCOL_RANGE_NB ,
};
enum AVFrameSideDataType {
    AV_FRAME_DATA_PANSCAN,
    AV_FRAME_DATA_A53_CC,
    AV_FRAME_DATA_STEREO3D,
    AV_FRAME_DATA_MATRIXENCODING,
    AV_FRAME_DATA_DOWNMIX_INFO,
    AV_FRAME_DATA_REPLAYGAIN,
};
typedef struct AVFrameSideData {
    enum AVFrameSideDataType type;
    uint8_t *data;
    int size;
    AVDictionary *metadata;
} AVFrameSideData;
typedef struct AVFrame {
    uint8_t *data[8];
    int linesize[8];
    uint8_t **extended_data;
    int width, height;
    int nb_samples;
    int format;
    int key_frame;
    enum AVPictureType pict_type;
    __attribute__((deprecated))
    uint8_t *base[8];
    AVRational sample_aspect_ratio;
    int64_t pts;
    int64_t pkt_pts;
    int64_t pkt_dts;
    int coded_picture_number;
    int display_picture_number;
    int quality;
    __attribute__((deprecated))
    int reference;
    __attribute__((deprecated))
    int8_t *qscale_table;
    __attribute__((deprecated))
    int qstride;
    __attribute__((deprecated))
    int qscale_type;
    __attribute__((deprecated))
    uint8_t *mbskip_table;
    int16_t (*motion_val[2])[2];
    __attribute__((deprecated))
    uint32_t *mb_type;
    __attribute__((deprecated))
    short *dct_coeff;
    __attribute__((deprecated))
    int8_t *ref_index[2];
    void *opaque;
    uint64_t error[8];
    __attribute__((deprecated))
    int type;
    int repeat_pict;
    int interlaced_frame;
    int top_field_first;
    int palette_has_changed;
    __attribute__((deprecated))
    int buffer_hints;
    __attribute__((deprecated))
    struct AVPanScan *pan_scan;
    int64_t reordered_opaque;
    __attribute__((deprecated)) void *hwaccel_picture_private;
    __attribute__((deprecated))
    struct AVCodecContext *owner;
    __attribute__((deprecated))
    void *thread_opaque;
    uint8_t motion_subsample_log2;
    int sample_rate;
    uint64_t channel_layout;
    AVBufferRef *buf[8];
    AVBufferRef **extended_buf;
    int nb_extended_buf;
    AVFrameSideData **side_data;
    int nb_side_data;
    int flags;
    int64_t best_effort_timestamp;
    int64_t pkt_pos;
    int64_t pkt_duration;
    AVDictionary *metadata;
    int decode_error_flags;
    int channels;
    int pkt_size;
    enum AVColorSpace colorspace;
    enum AVColorRange color_range;
    AVBufferRef *qp_table_buf;
} AVFrame;
int64_t av_frame_get_best_effort_timestamp(const AVFrame *frame);
void av_frame_set_best_effort_timestamp(AVFrame *frame, int64_t val);
int64_t av_frame_get_pkt_duration (const AVFrame *frame);
void av_frame_set_pkt_duration (AVFrame *frame, int64_t val);
int64_t av_frame_get_pkt_pos (const AVFrame *frame);
void av_frame_set_pkt_pos (AVFrame *frame, int64_t val);
int64_t av_frame_get_channel_layout (const AVFrame *frame);
void av_frame_set_channel_layout (AVFrame *frame, int64_t val);
int av_frame_get_channels (const AVFrame *frame);
void av_frame_set_channels (AVFrame *frame, int val);
int av_frame_get_sample_rate (const AVFrame *frame);
void av_frame_set_sample_rate (AVFrame *frame, int val);
AVDictionary *av_frame_get_metadata (const AVFrame *frame);
void av_frame_set_metadata (AVFrame *frame, AVDictionary *val);
int av_frame_get_decode_error_flags (const AVFrame *frame);
void av_frame_set_decode_error_flags (AVFrame *frame, int val);
int av_frame_get_pkt_size(const AVFrame *frame);
void av_frame_set_pkt_size(AVFrame *frame, int val);
AVDictionary **avpriv_frame_get_metadatap(AVFrame *frame);
int8_t *av_frame_get_qp_table(AVFrame *f, int *stride, int *type);
int av_frame_set_qp_table(AVFrame *f, AVBufferRef *buf, int stride, int type);
enum AVColorSpace av_frame_get_colorspace(const AVFrame *frame);
void av_frame_set_colorspace(AVFrame *frame, enum AVColorSpace val);
enum AVColorRange av_frame_get_color_range(const AVFrame *frame);
void av_frame_set_color_range(AVFrame *frame, enum AVColorRange val);
const char *av_get_colorspace_name(enum AVColorSpace val);
AVFrame *av_frame_alloc(void);
void av_frame_free(AVFrame **frame);
int av_frame_ref(AVFrame *dst, const AVFrame *src);
AVFrame *av_frame_clone(const AVFrame *src);
void av_frame_unref(AVFrame *frame);
void av_frame_move_ref(AVFrame *dst, AVFrame *src);
int av_frame_get_buffer(AVFrame *frame, int align);
int av_frame_is_writable(AVFrame *frame);
int av_frame_make_writable(AVFrame *frame);
int av_frame_copy(AVFrame *dst, const AVFrame *src);
int av_frame_copy_props(AVFrame *dst, const AVFrame *src);
AVBufferRef *av_frame_get_plane_buffer(AVFrame *frame, int plane);
AVFrameSideData *av_frame_new_side_data(AVFrame *frame,
                                        enum AVFrameSideDataType type,
                                        int size);
AVFrameSideData *av_frame_get_side_data(const AVFrame *frame,
                                        enum AVFrameSideDataType type);
void av_frame_remove_side_data(AVFrame *frame, enum AVFrameSideDataType type);
enum AVCodecID {
    AV_CODEC_ID_NONE,
    AV_CODEC_ID_MPEG1VIDEO,
    AV_CODEC_ID_MPEG2VIDEO,
    AV_CODEC_ID_MPEG2VIDEO_XVMC,
    AV_CODEC_ID_H261,
    AV_CODEC_ID_H263,
    AV_CODEC_ID_RV10,
    AV_CODEC_ID_RV20,
    AV_CODEC_ID_MJPEG,
    AV_CODEC_ID_MJPEGB,
    AV_CODEC_ID_LJPEG,
    AV_CODEC_ID_SP5X,
    AV_CODEC_ID_JPEGLS,
    AV_CODEC_ID_MPEG4,
    AV_CODEC_ID_RAWVIDEO,
    AV_CODEC_ID_MSMPEG4V1,
    AV_CODEC_ID_MSMPEG4V2,
    AV_CODEC_ID_MSMPEG4V3,
    AV_CODEC_ID_WMV1,
    AV_CODEC_ID_WMV2,
    AV_CODEC_ID_H263P,
    AV_CODEC_ID_H263I,
    AV_CODEC_ID_FLV1,
    AV_CODEC_ID_SVQ1,
    AV_CODEC_ID_SVQ3,
    AV_CODEC_ID_DVVIDEO,
    AV_CODEC_ID_HUFFYUV,
    AV_CODEC_ID_CYUV,
    AV_CODEC_ID_H264,
    AV_CODEC_ID_INDEO3,
    AV_CODEC_ID_VP3,
    AV_CODEC_ID_THEORA,
    AV_CODEC_ID_ASV1,
    AV_CODEC_ID_ASV2,
    AV_CODEC_ID_FFV1,
    AV_CODEC_ID_4XM,
    AV_CODEC_ID_VCR1,
    AV_CODEC_ID_CLJR,
    AV_CODEC_ID_MDEC,
    AV_CODEC_ID_ROQ,
    AV_CODEC_ID_INTERPLAY_VIDEO,
    AV_CODEC_ID_XAN_WC3,
    AV_CODEC_ID_XAN_WC4,
    AV_CODEC_ID_RPZA,
    AV_CODEC_ID_CINEPAK,
    AV_CODEC_ID_WS_VQA,
    AV_CODEC_ID_MSRLE,
    AV_CODEC_ID_MSVIDEO1,
    AV_CODEC_ID_IDCIN,
    AV_CODEC_ID_8BPS,
    AV_CODEC_ID_SMC,
    AV_CODEC_ID_FLIC,
    AV_CODEC_ID_TRUEMOTION1,
    AV_CODEC_ID_VMDVIDEO,
    AV_CODEC_ID_MSZH,
    AV_CODEC_ID_ZLIB,
    AV_CODEC_ID_QTRLE,
    AV_CODEC_ID_TSCC,
    AV_CODEC_ID_ULTI,
    AV_CODEC_ID_QDRAW,
    AV_CODEC_ID_VIXL,
    AV_CODEC_ID_QPEG,
    AV_CODEC_ID_PNG,
    AV_CODEC_ID_PPM,
    AV_CODEC_ID_PBM,
    AV_CODEC_ID_PGM,
    AV_CODEC_ID_PGMYUV,
    AV_CODEC_ID_PAM,
    AV_CODEC_ID_FFVHUFF,
    AV_CODEC_ID_RV30,
    AV_CODEC_ID_RV40,
    AV_CODEC_ID_VC1,
    AV_CODEC_ID_WMV3,
    AV_CODEC_ID_LOCO,
    AV_CODEC_ID_WNV1,
    AV_CODEC_ID_AASC,
    AV_CODEC_ID_INDEO2,
    AV_CODEC_ID_FRAPS,
    AV_CODEC_ID_TRUEMOTION2,
    AV_CODEC_ID_BMP,
    AV_CODEC_ID_CSCD,
    AV_CODEC_ID_MMVIDEO,
    AV_CODEC_ID_ZMBV,
    AV_CODEC_ID_AVS,
    AV_CODEC_ID_SMACKVIDEO,
    AV_CODEC_ID_NUV,
    AV_CODEC_ID_KMVC,
    AV_CODEC_ID_FLASHSV,
    AV_CODEC_ID_CAVS,
    AV_CODEC_ID_JPEG2000,
    AV_CODEC_ID_VMNC,
    AV_CODEC_ID_VP5,
    AV_CODEC_ID_VP6,
    AV_CODEC_ID_VP6F,
    AV_CODEC_ID_TARGA,
    AV_CODEC_ID_DSICINVIDEO,
    AV_CODEC_ID_TIERTEXSEQVIDEO,
    AV_CODEC_ID_TIFF,
    AV_CODEC_ID_GIF,
    AV_CODEC_ID_DXA,
    AV_CODEC_ID_DNXHD,
    AV_CODEC_ID_THP,
    AV_CODEC_ID_SGI,
    AV_CODEC_ID_C93,
    AV_CODEC_ID_BETHSOFTVID,
    AV_CODEC_ID_PTX,
    AV_CODEC_ID_TXD,
    AV_CODEC_ID_VP6A,
    AV_CODEC_ID_AMV,
    AV_CODEC_ID_VB,
    AV_CODEC_ID_PCX,
    AV_CODEC_ID_SUNRAST,
    AV_CODEC_ID_INDEO4,
    AV_CODEC_ID_INDEO5,
    AV_CODEC_ID_MIMIC,
    AV_CODEC_ID_RL2,
    AV_CODEC_ID_ESCAPE124,
    AV_CODEC_ID_DIRAC,
    AV_CODEC_ID_BFI,
    AV_CODEC_ID_CMV,
    AV_CODEC_ID_MOTIONPIXELS,
    AV_CODEC_ID_TGV,
    AV_CODEC_ID_TGQ,
    AV_CODEC_ID_TQI,
    AV_CODEC_ID_AURA,
    AV_CODEC_ID_AURA2,
    AV_CODEC_ID_V210X,
    AV_CODEC_ID_TMV,
    AV_CODEC_ID_V210,
    AV_CODEC_ID_DPX,
    AV_CODEC_ID_MAD,
    AV_CODEC_ID_FRWU,
    AV_CODEC_ID_FLASHSV2,
    AV_CODEC_ID_CDGRAPHICS,
    AV_CODEC_ID_R210,
    AV_CODEC_ID_ANM,
    AV_CODEC_ID_BINKVIDEO,
    AV_CODEC_ID_IFF_ILBM,
    AV_CODEC_ID_IFF_BYTERUN1,
    AV_CODEC_ID_KGV1,
    AV_CODEC_ID_YOP,
    AV_CODEC_ID_VP8,
    AV_CODEC_ID_PICTOR,
    AV_CODEC_ID_ANSI,
    AV_CODEC_ID_A64_MULTI,
    AV_CODEC_ID_A64_MULTI5,
    AV_CODEC_ID_R10K,
    AV_CODEC_ID_MXPEG,
    AV_CODEC_ID_LAGARITH,
    AV_CODEC_ID_PRORES,
    AV_CODEC_ID_JV,
    AV_CODEC_ID_DFA,
    AV_CODEC_ID_WMV3IMAGE,
    AV_CODEC_ID_VC1IMAGE,
    AV_CODEC_ID_UTVIDEO,
    AV_CODEC_ID_BMV_VIDEO,
    AV_CODEC_ID_VBLE,
    AV_CODEC_ID_DXTORY,
    AV_CODEC_ID_V410,
    AV_CODEC_ID_XWD,
    AV_CODEC_ID_CDXL,
    AV_CODEC_ID_XBM,
    AV_CODEC_ID_ZEROCODEC,
    AV_CODEC_ID_MSS1,
    AV_CODEC_ID_MSA1,
    AV_CODEC_ID_TSCC2,
    AV_CODEC_ID_MTS2,
    AV_CODEC_ID_CLLC,
    AV_CODEC_ID_MSS2,
    AV_CODEC_ID_VP9,
    AV_CODEC_ID_AIC,
    AV_CODEC_ID_ESCAPE130_DEPRECATED,
    AV_CODEC_ID_G2M_DEPRECATED,
    AV_CODEC_ID_WEBP_DEPRECATED,
    AV_CODEC_ID_HNM4_VIDEO,
    AV_CODEC_ID_HEVC_DEPRECATED,
    AV_CODEC_ID_FIC,
    AV_CODEC_ID_ALIAS_PIX,
    AV_CODEC_ID_BRENDER_PIX_DEPRECATED,
    AV_CODEC_ID_PAF_VIDEO_DEPRECATED,
    AV_CODEC_ID_EXR_DEPRECATED,
    AV_CODEC_ID_VP7_DEPRECATED,
    AV_CODEC_ID_SANM_DEPRECATED,
    AV_CODEC_ID_SGIRLE_DEPRECATED,
    AV_CODEC_ID_MVC1_DEPRECATED,
    AV_CODEC_ID_MVC2_DEPRECATED,
    AV_CODEC_ID_BRENDER_PIX= (('X') | (('I') << 8) | (('P') << 16) | ((unsigned)('B') << 24)),
    AV_CODEC_ID_Y41P = (('P') | (('1') << 8) | (('4') << 16) | ((unsigned)('Y') << 24)),
    AV_CODEC_ID_ESCAPE130 = (('0') | (('3') << 8) | (('1') << 16) | ((unsigned)('E') << 24)),
    AV_CODEC_ID_EXR = (('R') | (('X') << 8) | (('E') << 16) | ((unsigned)('0') << 24)),
    AV_CODEC_ID_AVRP = (('P') | (('R') << 8) | (('V') << 16) | ((unsigned)('A') << 24)),
    AV_CODEC_ID_012V = (('V') | (('2') << 8) | (('1') << 16) | ((unsigned)('0') << 24)),
    AV_CODEC_ID_G2M = (('M') | (('2') << 8) | (('G') << 16) | ((unsigned)(0) << 24)),
    AV_CODEC_ID_AVUI = (('I') | (('U') << 8) | (('V') << 16) | ((unsigned)('A') << 24)),
    AV_CODEC_ID_AYUV = (('V') | (('U') << 8) | (('Y') << 16) | ((unsigned)('A') << 24)),
    AV_CODEC_ID_TARGA_Y216 = (('6') | (('1') << 8) | (('2') << 16) | ((unsigned)('T') << 24)),
    AV_CODEC_ID_V308 = (('8') | (('0') << 8) | (('3') << 16) | ((unsigned)('V') << 24)),
    AV_CODEC_ID_V408 = (('8') | (('0') << 8) | (('4') << 16) | ((unsigned)('V') << 24)),
    AV_CODEC_ID_YUV4 = (('4') | (('V') << 8) | (('U') << 16) | ((unsigned)('Y') << 24)),
    AV_CODEC_ID_SANM = (('M') | (('N') << 8) | (('A') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_PAF_VIDEO = (('V') | (('F') << 8) | (('A') << 16) | ((unsigned)('P') << 24)),
    AV_CODEC_ID_AVRN = (('n') | (('R') << 8) | (('V') << 16) | ((unsigned)('A') << 24)),
    AV_CODEC_ID_CPIA = (('A') | (('I') << 8) | (('P') << 16) | ((unsigned)('C') << 24)),
    AV_CODEC_ID_XFACE = (('C') | (('A') << 8) | (('F') << 16) | ((unsigned)('X') << 24)),
    AV_CODEC_ID_SGIRLE = (('R') | (('I') << 8) | (('G') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_MVC1 = (('1') | (('C') << 8) | (('V') << 16) | ((unsigned)('M') << 24)),
    AV_CODEC_ID_MVC2 = (('2') | (('C') << 8) | (('V') << 16) | ((unsigned)('M') << 24)),
    AV_CODEC_ID_SNOW = (('W') | (('O') << 8) | (('N') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_WEBP = (('P') | (('B') << 8) | (('E') << 16) | ((unsigned)('W') << 24)),
    AV_CODEC_ID_SMVJPEG = (('J') | (('V') << 8) | (('M') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_HEVC = (('5') | (('6') << 8) | (('2') << 16) | ((unsigned)('H') << 24)),
    AV_CODEC_ID_VP7 = (('0') | (('7') << 8) | (('P') << 16) | ((unsigned)('V') << 24)),
    AV_CODEC_ID_FIRST_AUDIO = 0x10000,
    AV_CODEC_ID_PCM_S16LE = 0x10000,
    AV_CODEC_ID_PCM_S16BE,
    AV_CODEC_ID_PCM_U16LE,
    AV_CODEC_ID_PCM_U16BE,
    AV_CODEC_ID_PCM_S8,
    AV_CODEC_ID_PCM_U8,
    AV_CODEC_ID_PCM_MULAW,
    AV_CODEC_ID_PCM_ALAW,
    AV_CODEC_ID_PCM_S32LE,
    AV_CODEC_ID_PCM_S32BE,
    AV_CODEC_ID_PCM_U32LE,
    AV_CODEC_ID_PCM_U32BE,
    AV_CODEC_ID_PCM_S24LE,
    AV_CODEC_ID_PCM_S24BE,
    AV_CODEC_ID_PCM_U24LE,
    AV_CODEC_ID_PCM_U24BE,
    AV_CODEC_ID_PCM_S24DAUD,
    AV_CODEC_ID_PCM_ZORK,
    AV_CODEC_ID_PCM_S16LE_PLANAR,
    AV_CODEC_ID_PCM_DVD,
    AV_CODEC_ID_PCM_F32BE,
    AV_CODEC_ID_PCM_F32LE,
    AV_CODEC_ID_PCM_F64BE,
    AV_CODEC_ID_PCM_F64LE,
    AV_CODEC_ID_PCM_BLURAY,
    AV_CODEC_ID_PCM_LXF,
    AV_CODEC_ID_S302M,
    AV_CODEC_ID_PCM_S8_PLANAR,
    AV_CODEC_ID_PCM_S24LE_PLANAR_DEPRECATED,
    AV_CODEC_ID_PCM_S32LE_PLANAR_DEPRECATED,
    AV_CODEC_ID_PCM_S24LE_PLANAR = (('P') | (('S') << 8) | (('P') << 16) | ((unsigned)(24) << 24)),
    AV_CODEC_ID_PCM_S32LE_PLANAR = (('P') | (('S') << 8) | (('P') << 16) | ((unsigned)(32) << 24)),
    AV_CODEC_ID_PCM_S16BE_PLANAR = ((16) | (('P') << 8) | (('S') << 16) | ((unsigned)('P') << 24)),
    AV_CODEC_ID_ADPCM_IMA_QT = 0x11000,
    AV_CODEC_ID_ADPCM_IMA_WAV,
    AV_CODEC_ID_ADPCM_IMA_DK3,
    AV_CODEC_ID_ADPCM_IMA_DK4,
    AV_CODEC_ID_ADPCM_IMA_WS,
    AV_CODEC_ID_ADPCM_IMA_SMJPEG,
    AV_CODEC_ID_ADPCM_MS,
    AV_CODEC_ID_ADPCM_4XM,
    AV_CODEC_ID_ADPCM_XA,
    AV_CODEC_ID_ADPCM_ADX,
    AV_CODEC_ID_ADPCM_EA,
    AV_CODEC_ID_ADPCM_G726,
    AV_CODEC_ID_ADPCM_CT,
    AV_CODEC_ID_ADPCM_SWF,
    AV_CODEC_ID_ADPCM_YAMAHA,
    AV_CODEC_ID_ADPCM_SBPRO_4,
    AV_CODEC_ID_ADPCM_SBPRO_3,
    AV_CODEC_ID_ADPCM_SBPRO_2,
    AV_CODEC_ID_ADPCM_THP,
    AV_CODEC_ID_ADPCM_IMA_AMV,
    AV_CODEC_ID_ADPCM_EA_R1,
    AV_CODEC_ID_ADPCM_EA_R3,
    AV_CODEC_ID_ADPCM_EA_R2,
    AV_CODEC_ID_ADPCM_IMA_EA_SEAD,
    AV_CODEC_ID_ADPCM_IMA_EA_EACS,
    AV_CODEC_ID_ADPCM_EA_XAS,
    AV_CODEC_ID_ADPCM_EA_MAXIS_XA,
    AV_CODEC_ID_ADPCM_IMA_ISS,
    AV_CODEC_ID_ADPCM_G722,
    AV_CODEC_ID_ADPCM_IMA_APC,
    AV_CODEC_ID_ADPCM_VIMA_DEPRECATED,
    AV_CODEC_ID_ADPCM_VIMA = (('A') | (('M') << 8) | (('I') << 16) | ((unsigned)('V') << 24)),
    AV_CODEC_ID_VIMA = (('A') | (('M') << 8) | (('I') << 16) | ((unsigned)('V') << 24)),
    AV_CODEC_ID_ADPCM_AFC = ((' ') | (('C') << 8) | (('F') << 16) | ((unsigned)('A') << 24)),
    AV_CODEC_ID_ADPCM_IMA_OKI = ((' ') | (('I') << 8) | (('K') << 16) | ((unsigned)('O') << 24)),
    AV_CODEC_ID_ADPCM_DTK = ((' ') | (('K') << 8) | (('T') << 16) | ((unsigned)('D') << 24)),
    AV_CODEC_ID_ADPCM_IMA_RAD = ((' ') | (('D') << 8) | (('A') << 16) | ((unsigned)('R') << 24)),
    AV_CODEC_ID_ADPCM_G726LE = (('G') | (('7') << 8) | (('2') << 16) | ((unsigned)('6') << 24)),
    AV_CODEC_ID_AMR_NB = 0x12000,
    AV_CODEC_ID_AMR_WB,
    AV_CODEC_ID_RA_144 = 0x13000,
    AV_CODEC_ID_RA_288,
    AV_CODEC_ID_ROQ_DPCM = 0x14000,
    AV_CODEC_ID_INTERPLAY_DPCM,
    AV_CODEC_ID_XAN_DPCM,
    AV_CODEC_ID_SOL_DPCM,
    AV_CODEC_ID_MP2 = 0x15000,
    AV_CODEC_ID_MP3,
    AV_CODEC_ID_AAC,
    AV_CODEC_ID_AC3,
    AV_CODEC_ID_DTS,
    AV_CODEC_ID_VORBIS,
    AV_CODEC_ID_DVAUDIO,
    AV_CODEC_ID_WMAV1,
    AV_CODEC_ID_WMAV2,
    AV_CODEC_ID_MACE3,
    AV_CODEC_ID_MACE6,
    AV_CODEC_ID_VMDAUDIO,
    AV_CODEC_ID_FLAC,
    AV_CODEC_ID_MP3ADU,
    AV_CODEC_ID_MP3ON4,
    AV_CODEC_ID_SHORTEN,
    AV_CODEC_ID_ALAC,
    AV_CODEC_ID_WESTWOOD_SND1,
    AV_CODEC_ID_GSM,
    AV_CODEC_ID_QDM2,
    AV_CODEC_ID_COOK,
    AV_CODEC_ID_TRUESPEECH,
    AV_CODEC_ID_TTA,
    AV_CODEC_ID_SMACKAUDIO,
    AV_CODEC_ID_QCELP,
    AV_CODEC_ID_WAVPACK,
    AV_CODEC_ID_DSICINAUDIO,
    AV_CODEC_ID_IMC,
    AV_CODEC_ID_MUSEPACK7,
    AV_CODEC_ID_MLP,
    AV_CODEC_ID_GSM_MS,
    AV_CODEC_ID_ATRAC3,
    AV_CODEC_ID_VOXWARE,
    AV_CODEC_ID_APE,
    AV_CODEC_ID_NELLYMOSER,
    AV_CODEC_ID_MUSEPACK8,
    AV_CODEC_ID_SPEEX,
    AV_CODEC_ID_WMAVOICE,
    AV_CODEC_ID_WMAPRO,
    AV_CODEC_ID_WMALOSSLESS,
    AV_CODEC_ID_ATRAC3P,
    AV_CODEC_ID_EAC3,
    AV_CODEC_ID_SIPR,
    AV_CODEC_ID_MP1,
    AV_CODEC_ID_TWINVQ,
    AV_CODEC_ID_TRUEHD,
    AV_CODEC_ID_MP4ALS,
    AV_CODEC_ID_ATRAC1,
    AV_CODEC_ID_BINKAUDIO_RDFT,
    AV_CODEC_ID_BINKAUDIO_DCT,
    AV_CODEC_ID_AAC_LATM,
    AV_CODEC_ID_QDMC,
    AV_CODEC_ID_CELT,
    AV_CODEC_ID_G723_1,
    AV_CODEC_ID_G729,
    AV_CODEC_ID_8SVX_EXP,
    AV_CODEC_ID_8SVX_FIB,
    AV_CODEC_ID_BMV_AUDIO,
    AV_CODEC_ID_RALF,
    AV_CODEC_ID_IAC,
    AV_CODEC_ID_ILBC,
    AV_CODEC_ID_OPUS_DEPRECATED,
    AV_CODEC_ID_COMFORT_NOISE,
    AV_CODEC_ID_TAK_DEPRECATED,
    AV_CODEC_ID_METASOUND,
    AV_CODEC_ID_PAF_AUDIO_DEPRECATED,
    AV_CODEC_ID_ON2AVC,
    AV_CODEC_ID_FFWAVESYNTH = (('S') | (('W') << 8) | (('F') << 16) | ((unsigned)('F') << 24)),
    AV_CODEC_ID_SONIC = (('C') | (('N') << 8) | (('O') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_SONIC_LS = (('L') | (('N') << 8) | (('O') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_PAF_AUDIO = (('A') | (('F') << 8) | (('A') << 16) | ((unsigned)('P') << 24)),
    AV_CODEC_ID_OPUS = (('S') | (('U') << 8) | (('P') << 16) | ((unsigned)('O') << 24)),
    AV_CODEC_ID_TAK = (('K') | (('a') << 8) | (('B') << 16) | ((unsigned)('t') << 24)),
    AV_CODEC_ID_EVRC = (('c') | (('v') << 8) | (('e') << 16) | ((unsigned)('s') << 24)),
    AV_CODEC_ID_SMV = (('v') | (('m') << 8) | (('s') << 16) | ((unsigned)('s') << 24)),
    AV_CODEC_ID_DSD_LSBF = (('L') | (('D') << 8) | (('S') << 16) | ((unsigned)('D') << 24)),
    AV_CODEC_ID_DSD_MSBF = (('M') | (('D') << 8) | (('S') << 16) | ((unsigned)('D') << 24)),
    AV_CODEC_ID_DSD_LSBF_PLANAR = (('1') | (('D') << 8) | (('S') << 16) | ((unsigned)('D') << 24)),
    AV_CODEC_ID_DSD_MSBF_PLANAR = (('8') | (('D') << 8) | (('S') << 16) | ((unsigned)('D') << 24)),
    AV_CODEC_ID_FIRST_SUBTITLE = 0x17000,
    AV_CODEC_ID_DVD_SUBTITLE = 0x17000,
    AV_CODEC_ID_DVB_SUBTITLE,
    AV_CODEC_ID_TEXT,
    AV_CODEC_ID_XSUB,
    AV_CODEC_ID_SSA,
    AV_CODEC_ID_MOV_TEXT,
    AV_CODEC_ID_HDMV_PGS_SUBTITLE,
    AV_CODEC_ID_DVB_TELETEXT,
    AV_CODEC_ID_SRT,
    AV_CODEC_ID_MICRODVD = (('D') | (('V') << 8) | (('D') << 16) | ((unsigned)('m') << 24)),
    AV_CODEC_ID_EIA_608 = (('8') | (('0') << 8) | (('6') << 16) | ((unsigned)('c') << 24)),
    AV_CODEC_ID_JACOSUB = (('B') | (('U') << 8) | (('S') << 16) | ((unsigned)('J') << 24)),
    AV_CODEC_ID_SAMI = (('I') | (('M') << 8) | (('A') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_REALTEXT = (('T') | (('X') << 8) | (('T') << 16) | ((unsigned)('R') << 24)),
    AV_CODEC_ID_SUBVIEWER1 = (('1') | (('V') << 8) | (('b') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_SUBVIEWER = (('V') | (('b') << 8) | (('u') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_SUBRIP = (('p') | (('i') << 8) | (('R') << 16) | ((unsigned)('S') << 24)),
    AV_CODEC_ID_WEBVTT = (('T') | (('T') << 8) | (('V') << 16) | ((unsigned)('W') << 24)),
    AV_CODEC_ID_MPL2 = (('2') | (('L') << 8) | (('P') << 16) | ((unsigned)('M') << 24)),
    AV_CODEC_ID_VPLAYER = (('r') | (('l') << 8) | (('P') << 16) | ((unsigned)('V') << 24)),
    AV_CODEC_ID_PJS = (('S') | (('J') << 8) | (('h') << 16) | ((unsigned)('P') << 24)),
    AV_CODEC_ID_ASS = ((' ') | (('S') << 8) | (('S') << 16) | ((unsigned)('A') << 24)),
    AV_CODEC_ID_FIRST_UNKNOWN = 0x18000,
    AV_CODEC_ID_TTF = 0x18000,
    AV_CODEC_ID_BINTEXT = (('T') | (('X') << 8) | (('T') << 16) | ((unsigned)('B') << 24)),
    AV_CODEC_ID_XBIN = (('N') | (('I') << 8) | (('B') << 16) | ((unsigned)('X') << 24)),
    AV_CODEC_ID_IDF = (('F') | (('D') << 8) | (('I') << 16) | ((unsigned)(0) << 24)),
    AV_CODEC_ID_OTF = (('F') | (('T') << 8) | (('O') << 16) | ((unsigned)(0) << 24)),
    AV_CODEC_ID_SMPTE_KLV = (('A') | (('V') << 8) | (('L') << 16) | ((unsigned)('K') << 24)),
    AV_CODEC_ID_DVD_NAV = (('V') | (('A') << 8) | (('N') << 16) | ((unsigned)('D') << 24)),
    AV_CODEC_ID_TIMED_ID3 = (('3') | (('D') << 8) | (('I') << 16) | ((unsigned)('T') << 24)),
    AV_CODEC_ID_PROBE = 0x19000,
    AV_CODEC_ID_MPEG2TS = 0x20000,
    AV_CODEC_ID_MPEG4SYSTEMS = 0x20001,
    AV_CODEC_ID_FFMETADATA = 0x21000,
    CODEC_ID_NONE = AV_CODEC_ID_NONE,
    CODEC_ID_MPEG1VIDEO,
    CODEC_ID_MPEG2VIDEO,
    CODEC_ID_MPEG2VIDEO_XVMC,
    CODEC_ID_H261,
    CODEC_ID_H263,
    CODEC_ID_RV10,
    CODEC_ID_RV20,
    CODEC_ID_MJPEG,
    CODEC_ID_MJPEGB,
    CODEC_ID_LJPEG,
    CODEC_ID_SP5X,
    CODEC_ID_JPEGLS,
    CODEC_ID_MPEG4,
    CODEC_ID_RAWVIDEO,
    CODEC_ID_MSMPEG4V1,
    CODEC_ID_MSMPEG4V2,
    CODEC_ID_MSMPEG4V3,
    CODEC_ID_WMV1,
    CODEC_ID_WMV2,
    CODEC_ID_H263P,
    CODEC_ID_H263I,
    CODEC_ID_FLV1,
    CODEC_ID_SVQ1,
    CODEC_ID_SVQ3,
    CODEC_ID_DVVIDEO,
    CODEC_ID_HUFFYUV,
    CODEC_ID_CYUV,
    CODEC_ID_H264,
    CODEC_ID_INDEO3,
    CODEC_ID_VP3,
    CODEC_ID_THEORA,
    CODEC_ID_ASV1,
    CODEC_ID_ASV2,
    CODEC_ID_FFV1,
    CODEC_ID_4XM,
    CODEC_ID_VCR1,
    CODEC_ID_CLJR,
    CODEC_ID_MDEC,
    CODEC_ID_ROQ,
    CODEC_ID_INTERPLAY_VIDEO,
    CODEC_ID_XAN_WC3,
    CODEC_ID_XAN_WC4,
    CODEC_ID_RPZA,
    CODEC_ID_CINEPAK,
    CODEC_ID_WS_VQA,
    CODEC_ID_MSRLE,
    CODEC_ID_MSVIDEO1,
    CODEC_ID_IDCIN,
    CODEC_ID_8BPS,
    CODEC_ID_SMC,
    CODEC_ID_FLIC,
    CODEC_ID_TRUEMOTION1,
    CODEC_ID_VMDVIDEO,
    CODEC_ID_MSZH,
    CODEC_ID_ZLIB,
    CODEC_ID_QTRLE,
    CODEC_ID_TSCC,
    CODEC_ID_ULTI,
    CODEC_ID_QDRAW,
    CODEC_ID_VIXL,
    CODEC_ID_QPEG,
    CODEC_ID_PNG,
    CODEC_ID_PPM,
    CODEC_ID_PBM,
    CODEC_ID_PGM,
    CODEC_ID_PGMYUV,
    CODEC_ID_PAM,
    CODEC_ID_FFVHUFF,
    CODEC_ID_RV30,
    CODEC_ID_RV40,
    CODEC_ID_VC1,
    CODEC_ID_WMV3,
    CODEC_ID_LOCO,
    CODEC_ID_WNV1,
    CODEC_ID_AASC,
    CODEC_ID_INDEO2,
    CODEC_ID_FRAPS,
    CODEC_ID_TRUEMOTION2,
    CODEC_ID_BMP,
    CODEC_ID_CSCD,
    CODEC_ID_MMVIDEO,
    CODEC_ID_ZMBV,
    CODEC_ID_AVS,
    CODEC_ID_SMACKVIDEO,
    CODEC_ID_NUV,
    CODEC_ID_KMVC,
    CODEC_ID_FLASHSV,
    CODEC_ID_CAVS,
    CODEC_ID_JPEG2000,
    CODEC_ID_VMNC,
    CODEC_ID_VP5,
    CODEC_ID_VP6,
    CODEC_ID_VP6F,
    CODEC_ID_TARGA,
    CODEC_ID_DSICINVIDEO,
    CODEC_ID_TIERTEXSEQVIDEO,
    CODEC_ID_TIFF,
    CODEC_ID_GIF,
    CODEC_ID_DXA,
    CODEC_ID_DNXHD,
    CODEC_ID_THP,
    CODEC_ID_SGI,
    CODEC_ID_C93,
    CODEC_ID_BETHSOFTVID,
    CODEC_ID_PTX,
    CODEC_ID_TXD,
    CODEC_ID_VP6A,
    CODEC_ID_AMV,
    CODEC_ID_VB,
    CODEC_ID_PCX,
    CODEC_ID_SUNRAST,
    CODEC_ID_INDEO4,
    CODEC_ID_INDEO5,
    CODEC_ID_MIMIC,
    CODEC_ID_RL2,
    CODEC_ID_ESCAPE124,
    CODEC_ID_DIRAC,
    CODEC_ID_BFI,
    CODEC_ID_CMV,
    CODEC_ID_MOTIONPIXELS,
    CODEC_ID_TGV,
    CODEC_ID_TGQ,
    CODEC_ID_TQI,
    CODEC_ID_AURA,
    CODEC_ID_AURA2,
    CODEC_ID_V210X,
    CODEC_ID_TMV,
    CODEC_ID_V210,
    CODEC_ID_DPX,
    CODEC_ID_MAD,
    CODEC_ID_FRWU,
    CODEC_ID_FLASHSV2,
    CODEC_ID_CDGRAPHICS,
    CODEC_ID_R210,
    CODEC_ID_ANM,
    CODEC_ID_BINKVIDEO,
    CODEC_ID_IFF_ILBM,
    CODEC_ID_IFF_BYTERUN1,
    CODEC_ID_KGV1,
    CODEC_ID_YOP,
    CODEC_ID_VP8,
    CODEC_ID_PICTOR,
    CODEC_ID_ANSI,
    CODEC_ID_A64_MULTI,
    CODEC_ID_A64_MULTI5,
    CODEC_ID_R10K,
    CODEC_ID_MXPEG,
    CODEC_ID_LAGARITH,
    CODEC_ID_PRORES,
    CODEC_ID_JV,
    CODEC_ID_DFA,
    CODEC_ID_WMV3IMAGE,
    CODEC_ID_VC1IMAGE,
    CODEC_ID_UTVIDEO,
    CODEC_ID_BMV_VIDEO,
    CODEC_ID_VBLE,
    CODEC_ID_DXTORY,
    CODEC_ID_V410,
    CODEC_ID_XWD,
    CODEC_ID_CDXL,
    CODEC_ID_XBM,
    CODEC_ID_ZEROCODEC,
    CODEC_ID_MSS1,
    CODEC_ID_MSA1,
    CODEC_ID_TSCC2,
    CODEC_ID_MTS2,
    CODEC_ID_CLLC,
    CODEC_ID_Y41P = (('P') | (('1') << 8) | (('4') << 16) | ((unsigned)('Y') << 24)),
    CODEC_ID_ESCAPE130 = (('0') | (('3') << 8) | (('1') << 16) | ((unsigned)('E') << 24)),
    CODEC_ID_EXR = (('R') | (('X') << 8) | (('E') << 16) | ((unsigned)('0') << 24)),
    CODEC_ID_AVRP = (('P') | (('R') << 8) | (('V') << 16) | ((unsigned)('A') << 24)),
    CODEC_ID_G2M = (('M') | (('2') << 8) | (('G') << 16) | ((unsigned)(0) << 24)),
    CODEC_ID_AVUI = (('I') | (('U') << 8) | (('V') << 16) | ((unsigned)('A') << 24)),
    CODEC_ID_AYUV = (('V') | (('U') << 8) | (('Y') << 16) | ((unsigned)('A') << 24)),
    CODEC_ID_V308 = (('8') | (('0') << 8) | (('3') << 16) | ((unsigned)('V') << 24)),
    CODEC_ID_V408 = (('8') | (('0') << 8) | (('4') << 16) | ((unsigned)('V') << 24)),
    CODEC_ID_YUV4 = (('4') | (('V') << 8) | (('U') << 16) | ((unsigned)('Y') << 24)),
    CODEC_ID_SANM = (('M') | (('N') << 8) | (('A') << 16) | ((unsigned)('S') << 24)),
    CODEC_ID_PAF_VIDEO = (('V') | (('F') << 8) | (('A') << 16) | ((unsigned)('P') << 24)),
    CODEC_ID_SNOW = AV_CODEC_ID_SNOW,
    CODEC_ID_FIRST_AUDIO = 0x10000,
    CODEC_ID_PCM_S16LE = 0x10000,
    CODEC_ID_PCM_S16BE,
    CODEC_ID_PCM_U16LE,
    CODEC_ID_PCM_U16BE,
    CODEC_ID_PCM_S8,
    CODEC_ID_PCM_U8,
    CODEC_ID_PCM_MULAW,
    CODEC_ID_PCM_ALAW,
    CODEC_ID_PCM_S32LE,
    CODEC_ID_PCM_S32BE,
    CODEC_ID_PCM_U32LE,
    CODEC_ID_PCM_U32BE,
    CODEC_ID_PCM_S24LE,
    CODEC_ID_PCM_S24BE,
    CODEC_ID_PCM_U24LE,
    CODEC_ID_PCM_U24BE,
    CODEC_ID_PCM_S24DAUD,
    CODEC_ID_PCM_ZORK,
    CODEC_ID_PCM_S16LE_PLANAR,
    CODEC_ID_PCM_DVD,
    CODEC_ID_PCM_F32BE,
    CODEC_ID_PCM_F32LE,
    CODEC_ID_PCM_F64BE,
    CODEC_ID_PCM_F64LE,
    CODEC_ID_PCM_BLURAY,
    CODEC_ID_PCM_LXF,
    CODEC_ID_S302M,
    CODEC_ID_PCM_S8_PLANAR,
    CODEC_ID_ADPCM_IMA_QT = 0x11000,
    CODEC_ID_ADPCM_IMA_WAV,
    CODEC_ID_ADPCM_IMA_DK3,
    CODEC_ID_ADPCM_IMA_DK4,
    CODEC_ID_ADPCM_IMA_WS,
    CODEC_ID_ADPCM_IMA_SMJPEG,
    CODEC_ID_ADPCM_MS,
    CODEC_ID_ADPCM_4XM,
    CODEC_ID_ADPCM_XA,
    CODEC_ID_ADPCM_ADX,
    CODEC_ID_ADPCM_EA,
    CODEC_ID_ADPCM_G726,
    CODEC_ID_ADPCM_CT,
    CODEC_ID_ADPCM_SWF,
    CODEC_ID_ADPCM_YAMAHA,
    CODEC_ID_ADPCM_SBPRO_4,
    CODEC_ID_ADPCM_SBPRO_3,
    CODEC_ID_ADPCM_SBPRO_2,
    CODEC_ID_ADPCM_THP,
    CODEC_ID_ADPCM_IMA_AMV,
    CODEC_ID_ADPCM_EA_R1,
    CODEC_ID_ADPCM_EA_R3,
    CODEC_ID_ADPCM_EA_R2,
    CODEC_ID_ADPCM_IMA_EA_SEAD,
    CODEC_ID_ADPCM_IMA_EA_EACS,
    CODEC_ID_ADPCM_EA_XAS,
    CODEC_ID_ADPCM_EA_MAXIS_XA,
    CODEC_ID_ADPCM_IMA_ISS,
    CODEC_ID_ADPCM_G722,
    CODEC_ID_ADPCM_IMA_APC,
    CODEC_ID_VIMA = (('A') | (('M') << 8) | (('I') << 16) | ((unsigned)('V') << 24)),
    CODEC_ID_AMR_NB = 0x12000,
    CODEC_ID_AMR_WB,
    CODEC_ID_RA_144 = 0x13000,
    CODEC_ID_RA_288,
    CODEC_ID_ROQ_DPCM = 0x14000,
    CODEC_ID_INTERPLAY_DPCM,
    CODEC_ID_XAN_DPCM,
    CODEC_ID_SOL_DPCM,
    CODEC_ID_MP2 = 0x15000,
    CODEC_ID_MP3,
    CODEC_ID_AAC,
    CODEC_ID_AC3,
    CODEC_ID_DTS,
    CODEC_ID_VORBIS,
    CODEC_ID_DVAUDIO,
    CODEC_ID_WMAV1,
    CODEC_ID_WMAV2,
    CODEC_ID_MACE3,
    CODEC_ID_MACE6,
    CODEC_ID_VMDAUDIO,
    CODEC_ID_FLAC,
    CODEC_ID_MP3ADU,
    CODEC_ID_MP3ON4,
    CODEC_ID_SHORTEN,
    CODEC_ID_ALAC,
    CODEC_ID_WESTWOOD_SND1,
    CODEC_ID_GSM,
    CODEC_ID_QDM2,
    CODEC_ID_COOK,
    CODEC_ID_TRUESPEECH,
    CODEC_ID_TTA,
    CODEC_ID_SMACKAUDIO,
    CODEC_ID_QCELP,
    CODEC_ID_WAVPACK,
    CODEC_ID_DSICINAUDIO,
    CODEC_ID_IMC,
    CODEC_ID_MUSEPACK7,
    CODEC_ID_MLP,
    CODEC_ID_GSM_MS,
    CODEC_ID_ATRAC3,
    CODEC_ID_VOXWARE,
    CODEC_ID_APE,
    CODEC_ID_NELLYMOSER,
    CODEC_ID_MUSEPACK8,
    CODEC_ID_SPEEX,
    CODEC_ID_WMAVOICE,
    CODEC_ID_WMAPRO,
    CODEC_ID_WMALOSSLESS,
    CODEC_ID_ATRAC3P,
    CODEC_ID_EAC3,
    CODEC_ID_SIPR,
    CODEC_ID_MP1,
    CODEC_ID_TWINVQ,
    CODEC_ID_TRUEHD,
    CODEC_ID_MP4ALS,
    CODEC_ID_ATRAC1,
    CODEC_ID_BINKAUDIO_RDFT,
    CODEC_ID_BINKAUDIO_DCT,
    CODEC_ID_AAC_LATM,
    CODEC_ID_QDMC,
    CODEC_ID_CELT,
    CODEC_ID_G723_1,
    CODEC_ID_G729,
    CODEC_ID_8SVX_EXP,
    CODEC_ID_8SVX_FIB,
    CODEC_ID_BMV_AUDIO,
    CODEC_ID_RALF,
    CODEC_ID_IAC,
    CODEC_ID_ILBC,
    CODEC_ID_FFWAVESYNTH = (('S') | (('W') << 8) | (('F') << 16) | ((unsigned)('F') << 24)),
    CODEC_ID_SONIC = (('C') | (('N') << 8) | (('O') << 16) | ((unsigned)('S') << 24)),
    CODEC_ID_SONIC_LS = (('L') | (('N') << 8) | (('O') << 16) | ((unsigned)('S') << 24)),
    CODEC_ID_PAF_AUDIO = (('A') | (('F') << 8) | (('A') << 16) | ((unsigned)('P') << 24)),
    CODEC_ID_OPUS = (('S') | (('U') << 8) | (('P') << 16) | ((unsigned)('O') << 24)),
    CODEC_ID_FIRST_SUBTITLE = 0x17000,
    CODEC_ID_DVD_SUBTITLE = 0x17000,
    CODEC_ID_DVB_SUBTITLE,
    CODEC_ID_TEXT,
    CODEC_ID_XSUB,
    CODEC_ID_SSA,
    CODEC_ID_MOV_TEXT,
    CODEC_ID_HDMV_PGS_SUBTITLE,
    CODEC_ID_DVB_TELETEXT,
    CODEC_ID_SRT,
    CODEC_ID_MICRODVD = (('D') | (('V') << 8) | (('D') << 16) | ((unsigned)('m') << 24)),
    CODEC_ID_EIA_608 = (('8') | (('0') << 8) | (('6') << 16) | ((unsigned)('c') << 24)),
    CODEC_ID_JACOSUB = (('B') | (('U') << 8) | (('S') << 16) | ((unsigned)('J') << 24)),
    CODEC_ID_SAMI = (('I') | (('M') << 8) | (('A') << 16) | ((unsigned)('S') << 24)),
    CODEC_ID_REALTEXT = (('T') | (('X') << 8) | (('T') << 16) | ((unsigned)('R') << 24)),
    CODEC_ID_SUBVIEWER = (('V') | (('b') << 8) | (('u') << 16) | ((unsigned)('S') << 24)),
    CODEC_ID_FIRST_UNKNOWN = 0x18000,
    CODEC_ID_TTF = 0x18000,
    CODEC_ID_BINTEXT = (('T') | (('X') << 8) | (('T') << 16) | ((unsigned)('B') << 24)),
    CODEC_ID_XBIN = (('N') | (('I') << 8) | (('B') << 16) | ((unsigned)('X') << 24)),
    CODEC_ID_IDF = (('F') | (('D') << 8) | (('I') << 16) | ((unsigned)(0) << 24)),
    CODEC_ID_OTF = (('F') | (('T') << 8) | (('O') << 16) | ((unsigned)(0) << 24)),
    CODEC_ID_PROBE = 0x19000,
    CODEC_ID_MPEG2TS = 0x20000,
    CODEC_ID_MPEG4SYSTEMS = 0x20001,
    CODEC_ID_FFMETADATA = 0x21000,
};
typedef struct AVCodecDescriptor {
    enum AVCodecID id;
    enum AVMediaType type;
    const char *name;
    const char *long_name;
    int props;
} AVCodecDescriptor;
enum Motion_Est_ID {
    ME_ZERO = 1,
    ME_FULL,
    ME_LOG,
    ME_PHODS,
    ME_EPZS,
    ME_X1,
    ME_HEX,
    ME_UMH,
    ME_TESA,
    ME_ITER=50,
};
enum AVDiscard{
    AVDISCARD_NONE =-16,
    AVDISCARD_DEFAULT = 0,
    AVDISCARD_NONREF = 8,
    AVDISCARD_BIDIR = 16,
    AVDISCARD_NONKEY = 32,
    AVDISCARD_ALL = 48,
};
enum AVColorPrimaries{
    AVCOL_PRI_BT709 = 1,
    AVCOL_PRI_UNSPECIFIED = 2,
    AVCOL_PRI_BT470M = 4,
    AVCOL_PRI_BT470BG = 5,
    AVCOL_PRI_SMPTE170M = 6,
    AVCOL_PRI_SMPTE240M = 7,
    AVCOL_PRI_FILM = 8,
    AVCOL_PRI_BT2020 = 9,
    AVCOL_PRI_NB ,
};
enum AVColorTransferCharacteristic{
    AVCOL_TRC_BT709 = 1,
    AVCOL_TRC_UNSPECIFIED = 2,
    AVCOL_TRC_GAMMA22 = 4,
    AVCOL_TRC_GAMMA28 = 5,
    AVCOL_TRC_SMPTE170M = 6,
    AVCOL_TRC_SMPTE240M = 7,
    AVCOL_TRC_LINEAR = 8,
    AVCOL_TRC_LOG = 9,
    AVCOL_TRC_LOG_SQRT = 10,
    AVCOL_TRC_IEC61966_2_4 = 11,
    AVCOL_TRC_BT1361_ECG = 12,
    AVCOL_TRC_IEC61966_2_1 = 13,
    AVCOL_TRC_BT2020_10 = 14,
    AVCOL_TRC_BT2020_12 = 15,
    AVCOL_TRC_NB ,
};
enum AVChromaLocation{
    AVCHROMA_LOC_UNSPECIFIED = 0,
    AVCHROMA_LOC_LEFT = 1,
    AVCHROMA_LOC_CENTER = 2,
    AVCHROMA_LOC_TOPLEFT = 3,
    AVCHROMA_LOC_TOP = 4,
    AVCHROMA_LOC_BOTTOMLEFT = 5,
    AVCHROMA_LOC_BOTTOM = 6,
    AVCHROMA_LOC_NB ,
};
enum AVAudioServiceType {
    AV_AUDIO_SERVICE_TYPE_MAIN = 0,
    AV_AUDIO_SERVICE_TYPE_EFFECTS = 1,
    AV_AUDIO_SERVICE_TYPE_VISUALLY_IMPAIRED = 2,
    AV_AUDIO_SERVICE_TYPE_HEARING_IMPAIRED = 3,
    AV_AUDIO_SERVICE_TYPE_DIALOGUE = 4,
    AV_AUDIO_SERVICE_TYPE_COMMENTARY = 5,
    AV_AUDIO_SERVICE_TYPE_EMERGENCY = 6,
    AV_AUDIO_SERVICE_TYPE_VOICE_OVER = 7,
    AV_AUDIO_SERVICE_TYPE_KARAOKE = 8,
    AV_AUDIO_SERVICE_TYPE_NB ,
};
typedef struct RcOverride{
    int start_frame;
    int end_frame;
    int qscale;
    float quality_factor;
} RcOverride;
typedef struct AVPanScan{
    int id;
    int width;
    int height;
    int16_t position[3][2];
}AVPanScan;
enum AVPacketSideDataType {
    AV_PKT_DATA_PALETTE,
    AV_PKT_DATA_NEW_EXTRADATA,
    AV_PKT_DATA_PARAM_CHANGE,
    AV_PKT_DATA_H263_MB_INFO,
    AV_PKT_DATA_REPLAYGAIN,
    AV_PKT_DATA_SKIP_SAMPLES=70,
    AV_PKT_DATA_JP_DUALMONO,
    AV_PKT_DATA_STRINGS_METADATA,
    AV_PKT_DATA_SUBTITLE_POSITION,
    AV_PKT_DATA_MATROSKA_BLOCKADDITIONAL,
    AV_PKT_DATA_WEBVTT_IDENTIFIER,
    AV_PKT_DATA_WEBVTT_SETTINGS,
    AV_PKT_DATA_METADATA_UPDATE,
};
typedef struct AVPacketSideData {
    uint8_t *data;
    int size;
    enum AVPacketSideDataType type;
} AVPacketSideData;
typedef struct AVPacket {
    AVBufferRef *buf;
    int64_t pts;
    int64_t dts;
    uint8_t *data;
    int size;
    int stream_index;
    int flags;
    AVPacketSideData *side_data;
    int side_data_elems;
    int duration;
    __attribute__((deprecated))
    void (*destruct)(struct AVPacket *);
    __attribute__((deprecated))
    void *priv;
    int64_t pos;
    int64_t convergence_duration;
} AVPacket;
enum AVSideDataParamChangeFlags {
    AV_SIDE_DATA_PARAM_CHANGE_CHANNEL_COUNT = 0x0001,
    AV_SIDE_DATA_PARAM_CHANGE_CHANNEL_LAYOUT = 0x0002,
    AV_SIDE_DATA_PARAM_CHANGE_SAMPLE_RATE = 0x0004,
    AV_SIDE_DATA_PARAM_CHANGE_DIMENSIONS = 0x0008,
};
struct AVCodecInternal;
enum AVFieldOrder {
    AV_FIELD_UNKNOWN,
    AV_FIELD_PROGRESSIVE,
    AV_FIELD_TT,
    AV_FIELD_BB,
    AV_FIELD_TB,
    AV_FIELD_BT,
};
typedef struct AVCodecContext {
    const AVClass *av_class;
    int log_level_offset;
    enum AVMediaType codec_type;
    const struct AVCodec *codec;
    char codec_name[32];
    enum AVCodecID codec_id;
    unsigned int codec_tag;
    unsigned int stream_codec_tag;
    void *priv_data;
    struct AVCodecInternal *internal;
    void *opaque;
    int bit_rate;
    int bit_rate_tolerance;
    int global_quality;
    int compression_level;
    int flags;
    int flags2;
    uint8_t *extradata;
    int extradata_size;
    AVRational time_base;
    int ticks_per_frame;
    int delay;
    int width, height;
    int coded_width, coded_height;
    int gop_size;
    enum AVPixelFormat pix_fmt;
    int me_method;
    void (*draw_horiz_band)(struct AVCodecContext *s,
                            const AVFrame *src, int offset[8],
                            int y, int type, int height);
    enum AVPixelFormat (*get_format)(struct AVCodecContext *s, const enum AVPixelFormat * fmt);
    int max_b_frames;
    float b_quant_factor;
    int rc_strategy;
    int b_frame_strategy;
    float b_quant_offset;
    int has_b_frames;
    int mpeg_quant;
    float i_quant_factor;
    float i_quant_offset;
    float lumi_masking;
    float temporal_cplx_masking;
    float spatial_cplx_masking;
    float p_masking;
    float dark_masking;
    int slice_count;
     int prediction_method;
    int *slice_offset;
    AVRational sample_aspect_ratio;
    int me_cmp;
    int me_sub_cmp;
    int mb_cmp;
    int ildct_cmp;
    int dia_size;
    int last_predictor_count;
    int pre_me;
    int me_pre_cmp;
    int pre_dia_size;
    int me_subpel_quality;
    int dtg_active_format;
    int me_range;
    int intra_quant_bias;
    int inter_quant_bias;
    int slice_flags;
    __attribute__((deprecated)) int xvmc_acceleration;
    int mb_decision;
    uint16_t *intra_matrix;
    uint16_t *inter_matrix;
    int scenechange_threshold;
    int noise_reduction;
    int me_threshold;
    int mb_threshold;
    int intra_dc_precision;
    int skip_top;
    int skip_bottom;
    float border_masking;
    int mb_lmin;
    int mb_lmax;
    int me_penalty_compensation;
    int bidir_refine;
    int brd_scale;
    int keyint_min;
    int refs;
    int chromaoffset;
    int scenechange_factor;
    int mv0_threshold;
    int b_sensitivity;
    enum AVColorPrimaries color_primaries;
    enum AVColorTransferCharacteristic color_trc;
    enum AVColorSpace colorspace;
    enum AVColorRange color_range;
    enum AVChromaLocation chroma_sample_location;
    int slices;
    enum AVFieldOrder field_order;
    int sample_rate;
    int channels;
    enum AVSampleFormat sample_fmt;
    int frame_size;
    int frame_number;
    int block_align;
    int cutoff;
    __attribute__((deprecated)) int request_channels;
    uint64_t channel_layout;
    uint64_t request_channel_layout;
    enum AVAudioServiceType audio_service_type;
    enum AVSampleFormat request_sample_fmt;
    __attribute__((deprecated))
    int (*get_buffer)(struct AVCodecContext *c, AVFrame *pic);
    __attribute__((deprecated))
    void (*release_buffer)(struct AVCodecContext *c, AVFrame *pic);
    __attribute__((deprecated))
    int (*reget_buffer)(struct AVCodecContext *c, AVFrame *pic);
    int (*get_buffer2)(struct AVCodecContext *s, AVFrame *frame, int flags);
    int refcounted_frames;
    float qcompress;
    float qblur;
    int qmin;
    int qmax;
    int max_qdiff;
    float rc_qsquish;
    float rc_qmod_amp;
    int rc_qmod_freq;
    int rc_buffer_size;
    int rc_override_count;
    RcOverride *rc_override;
    const char *rc_eq;
    int rc_max_rate;
    int rc_min_rate;
    float rc_buffer_aggressivity;
    float rc_initial_cplx;
    float rc_max_available_vbv_use;
    float rc_min_vbv_overflow_use;
    int rc_initial_buffer_occupancy;
    int coder_type;
    int context_model;
    int lmin;
    int lmax;
    int frame_skip_threshold;
    int frame_skip_factor;
    int frame_skip_exp;
    int frame_skip_cmp;
    int trellis;
    int min_prediction_order;
    int max_prediction_order;
    int64_t timecode_frame_start;
    void (*rtp_callback)(struct AVCodecContext *avctx, void *data, int size, int mb_nb);
    int rtp_payload_size;
    int mv_bits;
    int header_bits;
    int i_tex_bits;
    int p_tex_bits;
    int i_count;
    int p_count;
    int skip_count;
    int misc_bits;
    int frame_bits;
    char *stats_out;
    char *stats_in;
    int workaround_bugs;
    int strict_std_compliance;
    int error_concealment;
    int debug;
    int debug_mv;
    int err_recognition;
    int64_t reordered_opaque;
    struct AVHWAccel *hwaccel;
    void *hwaccel_context;
    uint64_t error[8];
    int dct_algo;
    int idct_algo;
     int bits_per_coded_sample;
    int bits_per_raw_sample;
     int lowres;
    AVFrame *coded_frame;
    int thread_count;
    int thread_type;
    int active_thread_type;
    int thread_safe_callbacks;
    int (*execute)(struct AVCodecContext *c, int (*func)(struct AVCodecContext *c2, void *arg), void *arg2, int *ret, int count, int size);
    int (*execute2)(struct AVCodecContext *c, int (*func)(struct AVCodecContext *c2, void *arg, int jobnr, int threadnr), void *arg2, int *ret, int count);
    __attribute__((deprecated))
    void *thread_opaque;
     int nsse_weight;
     int profile;
     int level;
    enum AVDiscard skip_loop_filter;
    enum AVDiscard skip_idct;
    enum AVDiscard skip_frame;
    uint8_t *subtitle_header;
    int subtitle_header_size;
    __attribute__((deprecated))
    int error_rate;
    __attribute__((deprecated))
    AVPacket *pkt;
    uint64_t vbv_delay;
    AVRational pkt_timebase;
    const AVCodecDescriptor *codec_descriptor;
    int64_t pts_correction_num_faulty_pts;
    int64_t pts_correction_num_faulty_dts;
    int64_t pts_correction_last_pts;
    int64_t pts_correction_last_dts;
    char *sub_charenc;
    int sub_charenc_mode;
    int skip_alpha;
    int seek_preroll;
    uint16_t *chroma_intra_matrix;
} AVCodecContext;
AVRational av_codec_get_pkt_timebase (const AVCodecContext *avctx);
void av_codec_set_pkt_timebase (AVCodecContext *avctx, AVRational val);
const AVCodecDescriptor *av_codec_get_codec_descriptor(const AVCodecContext *avctx);
void av_codec_set_codec_descriptor(AVCodecContext *avctx, const AVCodecDescriptor *desc);
int av_codec_get_lowres(const AVCodecContext *avctx);
void av_codec_set_lowres(AVCodecContext *avctx, int val);
int av_codec_get_seek_preroll(const AVCodecContext *avctx);
void av_codec_set_seek_preroll(AVCodecContext *avctx, int val);
uint16_t *av_codec_get_chroma_intra_matrix(const AVCodecContext *avctx);
void av_codec_set_chroma_intra_matrix(AVCodecContext *avctx, uint16_t *val);
typedef struct AVProfile {
    int profile;
    const char *name;
} AVProfile;
typedef struct AVCodecDefault AVCodecDefault;
struct AVSubtitle;
typedef struct AVCodec {
    const char *name;
    const char *long_name;
    enum AVMediaType type;
    enum AVCodecID id;
    int capabilities;
    const AVRational *supported_framerates;
    const enum AVPixelFormat *pix_fmts;
    const int *supported_samplerates;
    const enum AVSampleFormat *sample_fmts;
    const uint64_t *channel_layouts;
    uint8_t max_lowres;
    const AVClass *priv_class;
    const AVProfile *profiles;
    int priv_data_size;
    struct AVCodec *next;
    int (*init_thread_copy)(AVCodecContext *);
    int (*update_thread_context)(AVCodecContext *dst, const AVCodecContext *src);
    const AVCodecDefault *defaults;
    void (*init_static_data)(struct AVCodec *codec);
    int (*init)(AVCodecContext *);
    int (*encode_sub)(AVCodecContext *, uint8_t *buf, int buf_size,
                      const struct AVSubtitle *sub);
    int (*encode2)(AVCodecContext *avctx, AVPacket *avpkt, const AVFrame *frame,
                   int *got_packet_ptr);
    int (*decode)(AVCodecContext *, void *outdata, int *outdata_size, AVPacket *avpkt);
    int (*close)(AVCodecContext *);
    void (*flush)(AVCodecContext *);
} AVCodec;
int av_codec_get_max_lowres(const AVCodec *codec);
struct MpegEncContext;
typedef struct AVHWAccel {
    const char *name;
    enum AVMediaType type;
    enum AVCodecID id;
    enum AVPixelFormat pix_fmt;
    int capabilities;
    struct AVHWAccel *next;
    int (*start_frame)(AVCodecContext *avctx, const uint8_t *buf, uint32_t buf_size);
    int (*decode_slice)(AVCodecContext *avctx, const uint8_t *buf, uint32_t buf_size);
    int (*end_frame)(AVCodecContext *avctx);
    int priv_data_size;
    void (*decode_mb)(struct MpegEncContext *s);
} AVHWAccel;
typedef struct AVPicture {
    uint8_t *data[8];
    int linesize[8];
} AVPicture;
enum AVSubtitleType {
    SUBTITLE_NONE,
    SUBTITLE_BITMAP,
    SUBTITLE_TEXT,
    SUBTITLE_ASS,
};
typedef struct AVSubtitleRect {
    int x;
    int y;
    int w;
    int h;
    int nb_colors;
    AVPicture pict;
    enum AVSubtitleType type;
    char *text;
    char *ass;
    int flags;
} AVSubtitleRect;
typedef struct AVSubtitle {
    uint16_t format;
    uint32_t start_display_time;
    uint32_t end_display_time;
    unsigned num_rects;
    AVSubtitleRect **rects;
    int64_t pts;
} AVSubtitle;
AVCodec *av_codec_next(const AVCodec *c);
unsigned avcodec_version(void);
const char *avcodec_configuration(void);
const char *avcodec_license(void);
void avcodec_register(AVCodec *codec);
void avcodec_register_all(void);
AVCodecContext *avcodec_alloc_context3(const AVCodec *codec);
int avcodec_get_context_defaults3(AVCodecContext *s, const AVCodec *codec);
const AVClass *avcodec_get_class(void);
const AVClass *avcodec_get_frame_class(void);
const AVClass *avcodec_get_subtitle_rect_class(void);
int avcodec_copy_context(AVCodecContext *dest, const AVCodecContext *src);
__attribute__((deprecated))
AVFrame *avcodec_alloc_frame(void);
__attribute__((deprecated))
void avcodec_get_frame_defaults(AVFrame *frame);
__attribute__((deprecated))
void avcodec_free_frame(AVFrame **frame);
int avcodec_open2(AVCodecContext *avctx, const AVCodec *codec, AVDictionary **options);
int avcodec_close(AVCodecContext *avctx);
void avsubtitle_free(AVSubtitle *sub);
__attribute__((deprecated))
void av_destruct_packet(AVPacket *pkt);
void av_init_packet(AVPacket *pkt);
int av_new_packet(AVPacket *pkt, int size);
void av_shrink_packet(AVPacket *pkt, int size);
int av_grow_packet(AVPacket *pkt, int grow_by);
int av_packet_from_data(AVPacket *pkt, uint8_t *data, int size);
int av_dup_packet(AVPacket *pkt);
int av_copy_packet(AVPacket *dst, const AVPacket *src);
int av_copy_packet_side_data(AVPacket *dst, const AVPacket *src);
void av_free_packet(AVPacket *pkt);
uint8_t* av_packet_new_side_data(AVPacket *pkt, enum AVPacketSideDataType type,
                                 int size);
int av_packet_shrink_side_data(AVPacket *pkt, enum AVPacketSideDataType type,
                               int size);
uint8_t* av_packet_get_side_data(AVPacket *pkt, enum AVPacketSideDataType type,
                                 int *size);
int av_packet_merge_side_data(AVPacket *pkt);
int av_packet_split_side_data(AVPacket *pkt);
uint8_t *av_packet_pack_dictionary(AVDictionary *dict, int *size);
int av_packet_unpack_dictionary(const uint8_t *data, int size, AVDictionary **dict);
void av_packet_free_side_data(AVPacket *pkt);
int av_packet_ref(AVPacket *dst, const AVPacket *src);
void av_packet_unref(AVPacket *pkt);
void av_packet_move_ref(AVPacket *dst, AVPacket *src);
int av_packet_copy_props(AVPacket *dst, const AVPacket *src);
AVCodec *avcodec_find_decoder(enum AVCodecID id);
AVCodec *avcodec_find_decoder_by_name(const char *name);
__attribute__((deprecated)) int avcodec_default_get_buffer(AVCodecContext *s, AVFrame *pic);
__attribute__((deprecated)) void avcodec_default_release_buffer(AVCodecContext *s, AVFrame *pic);
__attribute__((deprecated)) int avcodec_default_reget_buffer(AVCodecContext *s, AVFrame *pic);
int avcodec_default_get_buffer2(AVCodecContext *s, AVFrame *frame, int flags);
__attribute__((deprecated))
unsigned avcodec_get_edge_width(void);
void avcodec_align_dimensions(AVCodecContext *s, int *width, int *height);
void avcodec_align_dimensions2(AVCodecContext *s, int *width, int *height,
                               int linesize_align[8]);
int avcodec_enum_to_chroma_pos(int *xpos, int *ypos, enum AVChromaLocation pos);
enum AVChromaLocation avcodec_chroma_pos_to_enum(int xpos, int ypos);
__attribute__((deprecated)) int avcodec_decode_audio3(AVCodecContext *avctx, int16_t *samples,
                         int *frame_size_ptr,
                         AVPacket *avpkt);
int avcodec_decode_audio4(AVCodecContext *avctx, AVFrame *frame,
                          int *got_frame_ptr, const AVPacket *avpkt);
int avcodec_decode_video2(AVCodecContext *avctx, AVFrame *picture,
                         int *got_picture_ptr,
                         const AVPacket *avpkt);
int avcodec_decode_subtitle2(AVCodecContext *avctx, AVSubtitle *sub,
                            int *got_sub_ptr,
                            AVPacket *avpkt);
enum AVPictureStructure {
    AV_PICTURE_STRUCTURE_UNKNOWN,
    AV_PICTURE_STRUCTURE_TOP_FIELD,
    AV_PICTURE_STRUCTURE_BOTTOM_FIELD,
    AV_PICTURE_STRUCTURE_FRAME,
};
typedef struct AVCodecParserContext {
    void *priv_data;
    struct AVCodecParser *parser;
    int64_t frame_offset;
    int64_t cur_offset;
    int64_t next_frame_offset;
    int pict_type;
    int repeat_pict;
    int64_t pts;
    int64_t dts;
    int64_t last_pts;
    int64_t last_dts;
    int fetch_timestamp;
    int cur_frame_start_index;
    int64_t cur_frame_offset[4];
    int64_t cur_frame_pts[4];
    int64_t cur_frame_dts[4];
    int flags;
    int64_t offset;
    int64_t cur_frame_end[4];
    int key_frame;
    int64_t convergence_duration;
    int dts_sync_point;
    int dts_ref_dts_delta;
    int pts_dts_delta;
    int64_t cur_frame_pos[4];
    int64_t pos;
    int64_t last_pos;
    int duration;
    enum AVFieldOrder field_order;
    enum AVPictureStructure picture_structure;
    int output_picture_number;
} AVCodecParserContext;
typedef struct AVCodecParser {
    int codec_ids[5];
    int priv_data_size;
    int (*parser_init)(AVCodecParserContext *s);
    int (*parser_parse)(AVCodecParserContext *s,
                        AVCodecContext *avctx,
                        const uint8_t **poutbuf, int *poutbuf_size,
                        const uint8_t *buf, int buf_size);
    void (*parser_close)(AVCodecParserContext *s);
    int (*split)(AVCodecContext *avctx, const uint8_t *buf, int buf_size);
    struct AVCodecParser *next;
} AVCodecParser;
AVCodecParser *av_parser_next(AVCodecParser *c);
void av_register_codec_parser(AVCodecParser *parser);
AVCodecParserContext *av_parser_init(int codec_id);
int av_parser_parse2(AVCodecParserContext *s,
                     AVCodecContext *avctx,
                     uint8_t **poutbuf, int *poutbuf_size,
                     const uint8_t *buf, int buf_size,
                     int64_t pts, int64_t dts,
                     int64_t pos);
int av_parser_change(AVCodecParserContext *s,
                     AVCodecContext *avctx,
                     uint8_t **poutbuf, int *poutbuf_size,
                     const uint8_t *buf, int buf_size, int keyframe);
void av_parser_close(AVCodecParserContext *s);
AVCodec *avcodec_find_encoder(enum AVCodecID id);
AVCodec *avcodec_find_encoder_by_name(const char *name);
int __attribute__((deprecated)) avcodec_encode_audio(AVCodecContext *avctx,
                                              uint8_t *buf, int buf_size,
                                              const short *samples);
int avcodec_encode_audio2(AVCodecContext *avctx, AVPacket *avpkt,
                          const AVFrame *frame, int *got_packet_ptr);
__attribute__((deprecated))
int avcodec_encode_video(AVCodecContext *avctx, uint8_t *buf, int buf_size,
                         const AVFrame *pict);
int avcodec_encode_video2(AVCodecContext *avctx, AVPacket *avpkt,
                          const AVFrame *frame, int *got_packet_ptr);
int avcodec_encode_subtitle(AVCodecContext *avctx, uint8_t *buf, int buf_size,
                            const AVSubtitle *sub);
struct ReSampleContext;
struct AVResampleContext;
typedef struct ReSampleContext ReSampleContext;
__attribute__((deprecated))
ReSampleContext *av_audio_resample_init(int output_channels, int input_channels,
                                        int output_rate, int input_rate,
                                        enum AVSampleFormat sample_fmt_out,
                                        enum AVSampleFormat sample_fmt_in,
                                        int filter_length, int log2_phase_count,
                                        int linear, double cutoff);
__attribute__((deprecated))
int audio_resample(ReSampleContext *s, short *output, short *input, int nb_samples);
__attribute__((deprecated))
void audio_resample_close(ReSampleContext *s);
__attribute__((deprecated))
struct AVResampleContext *av_resample_init(int out_rate, int in_rate, int filter_length, int log2_phase_count, int linear, double cutoff);
__attribute__((deprecated))
int av_resample(struct AVResampleContext *c, short *dst, short *src, int *consumed, int src_size, int dst_size, int update_ctx);
__attribute__((deprecated))
void av_resample_compensate(struct AVResampleContext *c, int sample_delta, int compensation_distance);
__attribute__((deprecated))
void av_resample_close(struct AVResampleContext *c);
int avpicture_alloc(AVPicture *picture, enum AVPixelFormat pix_fmt, int width, int height);
void avpicture_free(AVPicture *picture);
int avpicture_fill(AVPicture *picture, const uint8_t *ptr,
                   enum AVPixelFormat pix_fmt, int width, int height);
int avpicture_layout(const AVPicture *src, enum AVPixelFormat pix_fmt,
                     int width, int height,
                     unsigned char *dest, int dest_size);
int avpicture_get_size(enum AVPixelFormat pix_fmt, int width, int height);
__attribute__((deprecated))
int avpicture_deinterlace(AVPicture *dst, const AVPicture *src,
                          enum AVPixelFormat pix_fmt, int width, int height);
void av_picture_copy(AVPicture *dst, const AVPicture *src,
                     enum AVPixelFormat pix_fmt, int width, int height);
int av_picture_crop(AVPicture *dst, const AVPicture *src,
                    enum AVPixelFormat pix_fmt, int top_band, int left_band);
int av_picture_pad(AVPicture *dst, const AVPicture *src, int height, int width, enum AVPixelFormat pix_fmt,
            int padtop, int padbottom, int padleft, int padright, int *color);
void avcodec_get_chroma_sub_sample(enum AVPixelFormat pix_fmt, int *h_shift, int *v_shift);
unsigned int avcodec_pix_fmt_to_codec_tag(enum AVPixelFormat pix_fmt);
int avcodec_get_pix_fmt_loss(enum AVPixelFormat dst_pix_fmt, enum AVPixelFormat src_pix_fmt,
                             int has_alpha);
enum AVPixelFormat avcodec_find_best_pix_fmt_of_list(const enum AVPixelFormat *pix_fmt_list,
                                            enum AVPixelFormat src_pix_fmt,
                                            int has_alpha, int *loss_ptr);
enum AVPixelFormat avcodec_find_best_pix_fmt_of_2(enum AVPixelFormat dst_pix_fmt1, enum AVPixelFormat dst_pix_fmt2,
                                            enum AVPixelFormat src_pix_fmt, int has_alpha, int *loss_ptr);
__attribute__((deprecated))
enum AVPixelFormat avcodec_find_best_pix_fmt2(enum AVPixelFormat dst_pix_fmt1, enum AVPixelFormat dst_pix_fmt2,
                                            enum AVPixelFormat src_pix_fmt, int has_alpha, int *loss_ptr);
enum AVPixelFormat avcodec_default_get_format(struct AVCodecContext *s, const enum AVPixelFormat * fmt);
__attribute__((deprecated))
void avcodec_set_dimensions(AVCodecContext *s, int width, int height);
size_t av_get_codec_tag_string(char *buf, size_t buf_size, unsigned int codec_tag);
void avcodec_string(char *buf, int buf_size, AVCodecContext *enc, int encode);
const char *av_get_profile_name(const AVCodec *codec, int profile);
int avcodec_default_execute(AVCodecContext *c, int (*func)(AVCodecContext *c2, void *arg2),void *arg, int *ret, int count, int size);
int avcodec_default_execute2(AVCodecContext *c, int (*func)(AVCodecContext *c2, void *arg2, int, int),void *arg, int *ret, int count);
int avcodec_fill_audio_frame(AVFrame *frame, int nb_channels,
                             enum AVSampleFormat sample_fmt, const uint8_t *buf,
                             int buf_size, int align);
void avcodec_flush_buffers(AVCodecContext *avctx);
int av_get_bits_per_sample(enum AVCodecID codec_id);
enum AVCodecID av_get_pcm_codec(enum AVSampleFormat fmt, int be);
int av_get_exact_bits_per_sample(enum AVCodecID codec_id);
int av_get_audio_frame_duration(AVCodecContext *avctx, int frame_bytes);
typedef struct AVBitStreamFilterContext {
    void *priv_data;
    struct AVBitStreamFilter *filter;
    AVCodecParserContext *parser;
    struct AVBitStreamFilterContext *next;
} AVBitStreamFilterContext;
typedef struct AVBitStreamFilter {
    const char *name;
    int priv_data_size;
    int (*filter)(AVBitStreamFilterContext *bsfc,
                  AVCodecContext *avctx, const char *args,
                  uint8_t **poutbuf, int *poutbuf_size,
                  const uint8_t *buf, int buf_size, int keyframe);
    void (*close)(AVBitStreamFilterContext *bsfc);
    struct AVBitStreamFilter *next;
} AVBitStreamFilter;
void av_register_bitstream_filter(AVBitStreamFilter *bsf);
AVBitStreamFilterContext *av_bitstream_filter_init(const char *name);
int av_bitstream_filter_filter(AVBitStreamFilterContext *bsfc,
                               AVCodecContext *avctx, const char *args,
                               uint8_t **poutbuf, int *poutbuf_size,
                               const uint8_t *buf, int buf_size, int keyframe);
void av_bitstream_filter_close(AVBitStreamFilterContext *bsf);
AVBitStreamFilter *av_bitstream_filter_next(AVBitStreamFilter *f);
void av_fast_padded_malloc(void *ptr, unsigned int *size, size_t min_size);
void av_fast_padded_mallocz(void *ptr, unsigned int *size, size_t min_size);
unsigned int av_xiphlacing(unsigned char *s, unsigned int v);
__attribute__((deprecated))
void av_log_missing_feature(void *avc, const char *feature, int want_sample);
__attribute__((deprecated))
void av_log_ask_for_sample(void *avc, const char *msg, ...) __attribute__((__format__(__printf__, 2, 3)));
void av_register_hwaccel(AVHWAccel *hwaccel);
AVHWAccel *av_hwaccel_next(AVHWAccel *hwaccel);
enum AVLockOp {
  AV_LOCK_CREATE,
  AV_LOCK_OBTAIN,
  AV_LOCK_RELEASE,
  AV_LOCK_DESTROY,
};
int av_lockmgr_register(int (*cb)(void **mutex, enum AVLockOp op));
enum AVMediaType avcodec_get_type(enum AVCodecID codec_id);
const char *avcodec_get_name(enum AVCodecID id);
int avcodec_is_open(AVCodecContext *s);
int av_codec_is_encoder(const AVCodec *codec);
int av_codec_is_decoder(const AVCodec *codec);
const AVCodecDescriptor *avcodec_descriptor_get(enum AVCodecID id);
const AVCodecDescriptor *avcodec_descriptor_next(const AVCodecDescriptor *prev);
const AVCodecDescriptor *avcodec_descriptor_get_by_name(const char *name);
typedef float FFTSample;
typedef struct FFTComplex {
    FFTSample re, im;
} FFTComplex;
typedef struct FFTContext FFTContext;
FFTContext *av_fft_init(int nbits, int inverse);
void av_fft_permute(FFTContext *s, FFTComplex *z);
void av_fft_calc(FFTContext *s, FFTComplex *z);
void av_fft_end(FFTContext *s);
FFTContext *av_mdct_init(int nbits, int inverse, double scale);
void av_imdct_calc(FFTContext *s, FFTSample *output, const FFTSample *input);
void av_imdct_half(FFTContext *s, FFTSample *output, const FFTSample *input);
void av_mdct_calc(FFTContext *s, FFTSample *output, const FFTSample *input);
void av_mdct_end(FFTContext *s);
enum RDFTransformType {
    DFT_R2C,
    IDFT_C2R,
    IDFT_R2C,
    DFT_C2R,
};
typedef struct RDFTContext RDFTContext;
RDFTContext *av_rdft_init(int nbits, enum RDFTransformType trans);
void av_rdft_calc(RDFTContext *s, FFTSample *data);
void av_rdft_end(RDFTContext *s);
typedef struct DCTContext DCTContext;
enum DCTTransformType {
    DCT_II = 0,
    DCT_III,
    DCT_I,
    DST_I,
};
DCTContext *av_dct_init(int nbits, enum DCTTransformType type);
void av_dct_calc(DCTContext *s, FFTSample *data);
void av_dct_end (DCTContext *s);
struct vaapi_context {
    void *display;
    uint32_t config_id;
    uint32_t context_id;
    uint32_t pic_param_buf_id;
    uint32_t iq_matrix_buf_id;
    uint32_t bitplane_buf_id;
    uint32_t *slice_buf_ids;
    unsigned int n_slice_buf_ids;
    unsigned int slice_buf_ids_alloc;
    void *slice_params;
    unsigned int slice_param_size;
    unsigned int slice_params_alloc;
    unsigned int slice_count;
    const uint8_t *slice_data;
    uint32_t slice_data_size;
};
enum AVOptionType{
    AV_OPT_TYPE_FLAGS,
    AV_OPT_TYPE_INT,
    AV_OPT_TYPE_INT64,
    AV_OPT_TYPE_DOUBLE,
    AV_OPT_TYPE_FLOAT,
    AV_OPT_TYPE_STRING,
    AV_OPT_TYPE_RATIONAL,
    AV_OPT_TYPE_BINARY,
    AV_OPT_TYPE_CONST = 128,
    AV_OPT_TYPE_IMAGE_SIZE = (('E') | (('Z') << 8) | (('I') << 16) | ((unsigned)('S') << 24)),
    AV_OPT_TYPE_PIXEL_FMT = (('T') | (('M') << 8) | (('F') << 16) | ((unsigned)('P') << 24)),
    AV_OPT_TYPE_SAMPLE_FMT = (('T') | (('M') << 8) | (('F') << 16) | ((unsigned)('S') << 24)),
    AV_OPT_TYPE_VIDEO_RATE = (('T') | (('A') << 8) | (('R') << 16) | ((unsigned)('V') << 24)),
    AV_OPT_TYPE_DURATION = ((' ') | (('R') << 8) | (('U') << 16) | ((unsigned)('D') << 24)),
    AV_OPT_TYPE_COLOR = (('R') | (('L') << 8) | (('O') << 16) | ((unsigned)('C') << 24)),
    AV_OPT_TYPE_CHANNEL_LAYOUT = (('A') | (('L') << 8) | (('H') << 16) | ((unsigned)('C') << 24)),
    FF_OPT_TYPE_FLAGS = 0,
    FF_OPT_TYPE_INT,
    FF_OPT_TYPE_INT64,
    FF_OPT_TYPE_DOUBLE,
    FF_OPT_TYPE_FLOAT,
    FF_OPT_TYPE_STRING,
    FF_OPT_TYPE_RATIONAL,
    FF_OPT_TYPE_BINARY,
    FF_OPT_TYPE_CONST=128,
};
typedef struct AVOption {
    const char *name;
    const char *help;
    int offset;
    enum AVOptionType type;
    union {
        int64_t i64;
        double dbl;
        const char *str;
        AVRational q;
    } default_val;
    double min;
    double max;
    int flags;
    const char *unit;
} AVOption;
typedef struct AVOptionRange {
    const char *str;
    double value_min, value_max;
    double component_min, component_max;
    int is_range;
} AVOptionRange;
typedef struct AVOptionRanges {
    AVOptionRange **range;
    int nb_ranges;
    int nb_components;
} AVOptionRanges;
__attribute__((deprecated))
const AVOption *av_find_opt(void *obj, const char *name, const char *unit, int mask, int flags);
__attribute__((deprecated))
int av_set_string3(void *obj, const char *name, const char *val, int alloc, const AVOption **o_out);
__attribute__((deprecated)) const AVOption *av_set_double(void *obj, const char *name, double n);
__attribute__((deprecated)) const AVOption *av_set_q(void *obj, const char *name, AVRational n);
__attribute__((deprecated)) const AVOption *av_set_int(void *obj, const char *name, int64_t n);
double av_get_double(void *obj, const char *name, const AVOption **o_out);
AVRational av_get_q(void *obj, const char *name, const AVOption **o_out);
int64_t av_get_int(void *obj, const char *name, const AVOption **o_out);
__attribute__((deprecated)) const char *av_get_string(void *obj, const char *name, const AVOption **o_out, char *buf, int buf_len);
__attribute__((deprecated)) const AVOption *av_next_option(void *obj, const AVOption *last);
int av_opt_show2(void *obj, void *av_log_obj, int req_flags, int rej_flags);
void av_opt_set_defaults(void *s);
__attribute__((deprecated))
void av_opt_set_defaults2(void *s, int mask, int flags);
int av_set_options_string(void *ctx, const char *opts,
                          const char *key_val_sep, const char *pairs_sep);
int av_opt_set_from_string(void *ctx, const char *opts,
                           const char *const *shorthand,
                           const char *key_val_sep, const char *pairs_sep);
void av_opt_free(void *obj);
int av_opt_flag_is_set(void *obj, const char *field_name, const char *flag_name);
int av_opt_set_dict(void *obj, struct AVDictionary **options);
int av_opt_get_key_value(const char **ropts,
                         const char *key_val_sep, const char *pairs_sep,
                         unsigned flags,
                         char **rkey, char **rval);
enum {
    AV_OPT_FLAG_IMPLICIT_KEY = 1,
};
int av_opt_eval_flags (void *obj, const AVOption *o, const char *val, int *flags_out);
int av_opt_eval_int (void *obj, const AVOption *o, const char *val, int *int_out);
int av_opt_eval_int64 (void *obj, const AVOption *o, const char *val, int64_t *int64_out);
int av_opt_eval_float (void *obj, const AVOption *o, const char *val, float *float_out);
int av_opt_eval_double(void *obj, const AVOption *o, const char *val, double *double_out);
int av_opt_eval_q (void *obj, const AVOption *o, const char *val, AVRational *q_out);
const AVOption *av_opt_find(void *obj, const char *name, const char *unit,
                            int opt_flags, int search_flags);
const AVOption *av_opt_find2(void *obj, const char *name, const char *unit,
                             int opt_flags, int search_flags, void **target_obj);
const AVOption *av_opt_next(void *obj, const AVOption *prev);
void *av_opt_child_next(void *obj, void *prev);
const AVClass *av_opt_child_class_next(const AVClass *parent, const AVClass *prev);
int av_opt_set (void *obj, const char *name, const char *val, int search_flags);
int av_opt_set_int (void *obj, const char *name, int64_t val, int search_flags);
int av_opt_set_double(void *obj, const char *name, double val, int search_flags);
int av_opt_set_q (void *obj, const char *name, AVRational val, int search_flags);
int av_opt_set_bin (void *obj, const char *name, const uint8_t *val, int size, int search_flags);
int av_opt_set_image_size(void *obj, const char *name, int w, int h, int search_flags);
int av_opt_set_pixel_fmt (void *obj, const char *name, enum AVPixelFormat fmt, int search_flags);
int av_opt_set_sample_fmt(void *obj, const char *name, enum AVSampleFormat fmt, int search_flags);
int av_opt_set_video_rate(void *obj, const char *name, AVRational val, int search_flags);
int av_opt_set_channel_layout(void *obj, const char *name, int64_t ch_layout, int search_flags);
int av_opt_get (void *obj, const char *name, int search_flags, uint8_t **out_val);
int av_opt_get_int (void *obj, const char *name, int search_flags, int64_t *out_val);
int av_opt_get_double(void *obj, const char *name, int search_flags, double *out_val);
int av_opt_get_q (void *obj, const char *name, int search_flags, AVRational *out_val);
int av_opt_get_image_size(void *obj, const char *name, int search_flags, int *w_out, int *h_out);
int av_opt_get_pixel_fmt (void *obj, const char *name, int search_flags, enum AVPixelFormat *out_fmt);
int av_opt_get_sample_fmt(void *obj, const char *name, int search_flags, enum AVSampleFormat *out_fmt);
int av_opt_get_video_rate(void *obj, const char *name, int search_flags, AVRational *out_val);
int av_opt_get_channel_layout(void *obj, const char *name, int search_flags, int64_t *ch_layout);
void *av_opt_ptr(const AVClass *avclass, void *obj, const char *name);
void av_opt_freep_ranges(AVOptionRanges **ranges);
int av_opt_query_ranges(AVOptionRanges **, void *obj, const char *key, int flags);
int av_opt_query_ranges_default(AVOptionRanges **, void *obj, const char *key, int flags);
typedef struct AVIOInterruptCB {
    int (*callback)(void*);
    void *opaque;
} AVIOInterruptCB;
typedef struct AVIOContext {
    const AVClass *av_class;
    unsigned char *buffer;
    int buffer_size;
    unsigned char *buf_ptr;
    unsigned char *buf_end;
    void *opaque;
    int (*read_packet)(void *opaque, uint8_t *buf, int buf_size);
    int (*write_packet)(void *opaque, uint8_t *buf, int buf_size);
    int64_t (*seek)(void *opaque, int64_t offset, int whence);
    int64_t pos;
    int must_flush;
    int eof_reached;
    int write_flag;
    int max_packet_size;
    unsigned long checksum;
    unsigned char *checksum_ptr;
    unsigned long (*update_checksum)(unsigned long checksum, const uint8_t *buf, unsigned int size);
    int error;
    int (*read_pause)(void *opaque, int pause);
    int64_t (*read_seek)(void *opaque, int stream_index,
                         int64_t timestamp, int flags);
    int seekable;
    int64_t maxsize;
    int direct;
    int64_t bytes_read;
    int seek_count;
    int writeout_count;
    int orig_buffer_size;
} AVIOContext;
const char *avio_find_protocol_name(const char *url);
int avio_check(const char *url, int flags);
AVIOContext *avio_alloc_context(
                  unsigned char *buffer,
                  int buffer_size,
                  int write_flag,
                  void *opaque,
                  int (*read_packet)(void *opaque, uint8_t *buf, int buf_size),
                  int (*write_packet)(void *opaque, uint8_t *buf, int buf_size),
                  int64_t (*seek)(void *opaque, int64_t offset, int whence));
void avio_w8(AVIOContext *s, int b);
void avio_write(AVIOContext *s, const unsigned char *buf, int size);
void avio_wl64(AVIOContext *s, uint64_t val);
void avio_wb64(AVIOContext *s, uint64_t val);
void avio_wl32(AVIOContext *s, unsigned int val);
void avio_wb32(AVIOContext *s, unsigned int val);
void avio_wl24(AVIOContext *s, unsigned int val);
void avio_wb24(AVIOContext *s, unsigned int val);
void avio_wl16(AVIOContext *s, unsigned int val);
void avio_wb16(AVIOContext *s, unsigned int val);
int avio_put_str(AVIOContext *s, const char *str);
int avio_put_str16le(AVIOContext *s, const char *str);
int64_t avio_seek(AVIOContext *s, int64_t offset, int whence);
int64_t avio_skip(AVIOContext *s, int64_t offset);
int64_t avio_size(AVIOContext *s);
int url_feof(AVIOContext *s);
int avio_printf(AVIOContext *s, const char *fmt, ...) __attribute__((__format__(__printf__, 2, 3)));
void avio_flush(AVIOContext *s);
int avio_read(AVIOContext *s, unsigned char *buf, int size);
int avio_r8 (AVIOContext *s);
unsigned int avio_rl16(AVIOContext *s);
unsigned int avio_rl24(AVIOContext *s);
unsigned int avio_rl32(AVIOContext *s);
uint64_t avio_rl64(AVIOContext *s);
unsigned int avio_rb16(AVIOContext *s);
unsigned int avio_rb24(AVIOContext *s);
unsigned int avio_rb32(AVIOContext *s);
uint64_t avio_rb64(AVIOContext *s);
int avio_get_str(AVIOContext *pb, int maxlen, char *buf, int buflen);
int avio_get_str16le(AVIOContext *pb, int maxlen, char *buf, int buflen);
int avio_get_str16be(AVIOContext *pb, int maxlen, char *buf, int buflen);
int avio_open(AVIOContext **s, const char *url, int flags);
int avio_open2(AVIOContext **s, const char *url, int flags,
               const AVIOInterruptCB *int_cb, AVDictionary **options);
int avio_close(AVIOContext *s);
int avio_closep(AVIOContext **s);
int avio_open_dyn_buf(AVIOContext **s);
int avio_close_dyn_buf(AVIOContext *s, uint8_t **pbuffer);
const char *avio_enum_protocols(void **opaque, int output);
int avio_pause(AVIOContext *h, int pause);
int64_t avio_seek_time(AVIOContext *h, int stream_index,
                       int64_t timestamp, int flags);
struct AVFormatContext;
struct AVDeviceInfoList;
struct AVDeviceCapabilitiesQuery;
int av_get_packet(AVIOContext *s, AVPacket *pkt, int size);
int av_append_packet(AVIOContext *s, AVPacket *pkt, int size);
typedef struct AVFrac {
    int64_t val, num, den;
} AVFrac;
struct AVCodecTag;
typedef struct AVProbeData {
    const char *filename;
    unsigned char *buf;
    int buf_size;
} AVProbeData;
typedef struct AVOutputFormat {
    const char *name;
    const char *long_name;
    const char *mime_type;
    const char *extensions;
    enum AVCodecID audio_codec;
    enum AVCodecID video_codec;
    enum AVCodecID subtitle_codec;
    int flags;
    const struct AVCodecTag * const *codec_tag;
    const AVClass *priv_class;
    struct AVOutputFormat *next;
    int priv_data_size;
    int (*write_header)(struct AVFormatContext *);
    int (*write_packet)(struct AVFormatContext *, AVPacket *pkt);
    int (*write_trailer)(struct AVFormatContext *);
    int (*interleave_packet)(struct AVFormatContext *, AVPacket *out,
                             AVPacket *in, int flush);
    int (*query_codec)(enum AVCodecID id, int std_compliance);
    void (*get_output_timestamp)(struct AVFormatContext *s, int stream,
                                 int64_t *dts, int64_t *wall);
    int (*control_message)(struct AVFormatContext *s, int type,
                           void *data, size_t data_size);
    int (*write_uncoded_frame)(struct AVFormatContext *, int stream_index,
                               AVFrame **frame, unsigned flags);
    int (*get_device_list)(struct AVFormatContext *s, struct AVDeviceInfoList *device_list);
    int (*create_device_capabilities)(struct AVFormatContext *s, struct AVDeviceCapabilitiesQuery *caps);
    int (*free_device_capabilities)(struct AVFormatContext *s, struct AVDeviceCapabilitiesQuery *caps);
} AVOutputFormat;
typedef struct AVInputFormat {
    const char *name;
    const char *long_name;
    int flags;
    const char *extensions;
    const struct AVCodecTag * const *codec_tag;
    const AVClass *priv_class;
    struct AVInputFormat *next;
    int raw_codec_id;
    int priv_data_size;
    int (*read_probe)(AVProbeData *);
    int (*read_header)(struct AVFormatContext *);
    int (*read_packet)(struct AVFormatContext *, AVPacket *pkt);
    int (*read_close)(struct AVFormatContext *);
    int (*read_seek)(struct AVFormatContext *,
                     int stream_index, int64_t timestamp, int flags);
    int64_t (*read_timestamp)(struct AVFormatContext *s, int stream_index,
                              int64_t *pos, int64_t pos_limit);
    int (*read_play)(struct AVFormatContext *);
    int (*read_pause)(struct AVFormatContext *);
    int (*read_seek2)(struct AVFormatContext *s, int stream_index, int64_t min_ts, int64_t ts, int64_t max_ts, int flags);
    int (*get_device_list)(struct AVFormatContext *s, struct AVDeviceInfoList *device_list);
    int (*create_device_capabilities)(struct AVFormatContext *s, struct AVDeviceCapabilitiesQuery *caps);
    int (*free_device_capabilities)(struct AVFormatContext *s, struct AVDeviceCapabilitiesQuery *caps);
} AVInputFormat;
enum AVStreamParseType {
    AVSTREAM_PARSE_NONE,
    AVSTREAM_PARSE_FULL,
    AVSTREAM_PARSE_HEADERS,
    AVSTREAM_PARSE_TIMESTAMPS,
    AVSTREAM_PARSE_FULL_ONCE,
    AVSTREAM_PARSE_FULL_RAW=((0) | (('R') << 8) | (('A') << 16) | ((unsigned)('W') << 24)),
};
typedef struct AVIndexEntry {
    int64_t pos;
    int64_t timestamp;
    int flags:2;
    int size:30;
    int min_distance;
} AVIndexEntry;
typedef struct AVStream {
    int index;
    int id;
    AVCodecContext *codec;
    void *priv_data;
    struct AVFrac pts;
    AVRational time_base;
    int64_t start_time;
    int64_t duration;
    int64_t nb_frames;
    int disposition;
    enum AVDiscard discard;
    AVRational sample_aspect_ratio;
    AVDictionary *metadata;
    AVRational avg_frame_rate;
    AVPacket attached_pic;
    AVPacketSideData *side_data;
    int nb_side_data;
    struct {
        int64_t last_dts;
        int64_t duration_gcd;
        int duration_count;
        int64_t rfps_duration_sum;
        double (*duration_error)[2][(60*12+6)];
        int64_t codec_info_duration;
        int64_t codec_info_duration_fields;
        int found_decoder;
        int64_t last_duration;
        int64_t fps_first_dts;
        int fps_first_dts_idx;
        int64_t fps_last_dts;
        int fps_last_dts_idx;
    } *info;
    int pts_wrap_bits;
    int64_t do_not_use;
    int64_t first_dts;
    int64_t cur_dts;
    int64_t last_IP_pts;
    int last_IP_duration;
    int probe_packets;
    int codec_info_nb_frames;
    enum AVStreamParseType need_parsing;
    struct AVCodecParserContext *parser;
    struct AVPacketList *last_in_packet_buffer;
    AVProbeData probe_data;
    int64_t pts_buffer[16 +1];
    AVIndexEntry *index_entries;
    int nb_index_entries;
    unsigned int index_entries_allocated_size;
    AVRational r_frame_rate;
    int stream_identifier;
    int64_t interleaver_chunk_size;
    int64_t interleaver_chunk_duration;
    int request_probe;
    int skip_to_keyframe;
    int skip_samples;
    int nb_decoded_frames;
    int64_t mux_ts_offset;
    int64_t pts_wrap_reference;
    int pts_wrap_behavior;
    int update_initial_durations_done;
    int64_t pts_reorder_error[16 +1];
    uint8_t pts_reorder_error_count[16 +1];
    int64_t last_dts_for_order_check;
    uint8_t dts_ordered;
    uint8_t dts_misordered;
    int inject_global_side_data;
} AVStream;
AVRational av_stream_get_r_frame_rate(const AVStream *s);
void av_stream_set_r_frame_rate(AVStream *s, AVRational r);
typedef struct AVProgram {
    int id;
    int flags;
    enum AVDiscard discard;
    unsigned int *stream_index;
    unsigned int nb_stream_indexes;
    AVDictionary *metadata;
    int program_num;
    int pmt_pid;
    int pcr_pid;
    int64_t start_time;
    int64_t end_time;
    int64_t pts_wrap_reference;
    int pts_wrap_behavior;
} AVProgram;
typedef struct AVChapter {
    int id;
    AVRational time_base;
    int64_t start, end;
    AVDictionary *metadata;
} AVChapter;
typedef int (*av_format_control_message)(struct AVFormatContext *s, int type,
                                         void *data, size_t data_size);
enum AVDurationEstimationMethod {
    AVFMT_DURATION_FROM_PTS,
    AVFMT_DURATION_FROM_STREAM,
    AVFMT_DURATION_FROM_BITRATE
};
typedef struct AVFormatInternal AVFormatInternal;
typedef struct AVFormatContext {
    const AVClass *av_class;
    struct AVInputFormat *iformat;
    struct AVOutputFormat *oformat;
    void *priv_data;
    AVIOContext *pb;
    int ctx_flags;
    unsigned int nb_streams;
    AVStream **streams;
    char filename[1024];
    int64_t start_time;
    int64_t duration;
    int bit_rate;
    unsigned int packet_size;
    int max_delay;
    int flags;
    unsigned int probesize;
    int max_analyze_duration;
    const uint8_t *key;
    int keylen;
    unsigned int nb_programs;
    AVProgram **programs;
    enum AVCodecID video_codec_id;
    enum AVCodecID audio_codec_id;
    enum AVCodecID subtitle_codec_id;
    unsigned int max_index_size;
    unsigned int max_picture_buffer;
    unsigned int nb_chapters;
    AVChapter **chapters;
    AVDictionary *metadata;
    int64_t start_time_realtime;
    int fps_probe_size;
    int error_recognition;
    AVIOInterruptCB interrupt_callback;
    int debug;
    int64_t max_interleave_delta;
    int ts_id;
    int audio_preload;
    int max_chunk_duration;
    int max_chunk_size;
    int use_wallclock_as_timestamps;
    int avoid_negative_ts;
    int avio_flags;
    enum AVDurationEstimationMethod duration_estimation_method;
    unsigned int skip_initial_bytes;
    unsigned int correct_ts_overflow;
    int seek2any;
    int flush_packets;
    int probe_score;
    struct AVPacketList *packet_buffer;
    struct AVPacketList *packet_buffer_end;
    int64_t data_offset;
    struct AVPacketList *raw_packet_buffer;
    struct AVPacketList *raw_packet_buffer_end;
    struct AVPacketList *parse_queue;
    struct AVPacketList *parse_queue_end;
    int raw_packet_buffer_remaining_size;
    int64_t offset;
    AVRational offset_timebase;
    AVFormatInternal *internal;
    int io_repositioned;
    AVCodec *video_codec;
    AVCodec *audio_codec;
    AVCodec *subtitle_codec;
    int metadata_header_padding;
    void *opaque;
    av_format_control_message control_message_cb;
    int64_t output_ts_offset;
} AVFormatContext;
int av_format_get_probe_score(const AVFormatContext *s);
AVCodec * av_format_get_video_codec(const AVFormatContext *s);
void av_format_set_video_codec(AVFormatContext *s, AVCodec *c);
AVCodec * av_format_get_audio_codec(const AVFormatContext *s);
void av_format_set_audio_codec(AVFormatContext *s, AVCodec *c);
AVCodec * av_format_get_subtitle_codec(const AVFormatContext *s);
void av_format_set_subtitle_codec(AVFormatContext *s, AVCodec *c);
int av_format_get_metadata_header_padding(const AVFormatContext *s);
void av_format_set_metadata_header_padding(AVFormatContext *s, int c);
void * av_format_get_opaque(const AVFormatContext *s);
void av_format_set_opaque(AVFormatContext *s, void *opaque);
av_format_control_message av_format_get_control_message_cb(const AVFormatContext *s);
void av_format_set_control_message_cb(AVFormatContext *s, av_format_control_message callback);
void av_format_inject_global_side_data(AVFormatContext *s);
enum AVDurationEstimationMethod av_fmt_ctx_get_duration_estimation_method(const AVFormatContext* ctx);
typedef struct AVPacketList {
    AVPacket pkt;
    struct AVPacketList *next;
} AVPacketList;
unsigned avformat_version(void);
const char *avformat_configuration(void);
const char *avformat_license(void);
void av_register_all(void);
void av_register_input_format(AVInputFormat *format);
void av_register_output_format(AVOutputFormat *format);
int avformat_network_init(void);
int avformat_network_deinit(void);
AVInputFormat *av_iformat_next(AVInputFormat *f);
AVOutputFormat *av_oformat_next(AVOutputFormat *f);
AVFormatContext *avformat_alloc_context(void);
void avformat_free_context(AVFormatContext *s);
const AVClass *avformat_get_class(void);
AVStream *avformat_new_stream(AVFormatContext *s, const AVCodec *c);
AVProgram *av_new_program(AVFormatContext *s, int id);
__attribute__((deprecated))
AVFormatContext *avformat_alloc_output_context(const char *format,
                                               AVOutputFormat *oformat,
                                               const char *filename);
int avformat_alloc_output_context2(AVFormatContext **ctx, AVOutputFormat *oformat,
                                   const char *format_name, const char *filename);
AVInputFormat *av_find_input_format(const char *short_name);
AVInputFormat *av_probe_input_format(AVProbeData *pd, int is_opened);
AVInputFormat *av_probe_input_format2(AVProbeData *pd, int is_opened, int *score_max);
AVInputFormat *av_probe_input_format3(AVProbeData *pd, int is_opened, int *score_ret);
int av_probe_input_buffer2(AVIOContext *pb, AVInputFormat **fmt,
                           const char *filename, void *logctx,
                           unsigned int offset, unsigned int max_probe_size);
int av_probe_input_buffer(AVIOContext *pb, AVInputFormat **fmt,
                          const char *filename, void *logctx,
                          unsigned int offset, unsigned int max_probe_size);
int avformat_open_input(AVFormatContext **ps, const char *filename, AVInputFormat *fmt, AVDictionary **options);
__attribute__((deprecated))
int av_demuxer_open(AVFormatContext *ic);
__attribute__((deprecated))
int av_find_stream_info(AVFormatContext *ic);
int avformat_find_stream_info(AVFormatContext *ic, AVDictionary **options);
AVProgram *av_find_program_from_stream(AVFormatContext *ic, AVProgram *last, int s);
int av_find_best_stream(AVFormatContext *ic,
                        enum AVMediaType type,
                        int wanted_stream_nb,
                        int related_stream,
                        AVCodec **decoder_ret,
                        int flags);
__attribute__((deprecated))
int av_read_packet(AVFormatContext *s, AVPacket *pkt);
int av_read_frame(AVFormatContext *s, AVPacket *pkt);
int av_seek_frame(AVFormatContext *s, int stream_index, int64_t timestamp,
                  int flags);
int avformat_seek_file(AVFormatContext *s, int stream_index, int64_t min_ts, int64_t ts, int64_t max_ts, int flags);
int av_read_play(AVFormatContext *s);
int av_read_pause(AVFormatContext *s);
__attribute__((deprecated))
void av_close_input_file(AVFormatContext *s);
void avformat_close_input(AVFormatContext **s);
__attribute__((deprecated))
AVStream *av_new_stream(AVFormatContext *s, int id);
__attribute__((deprecated))
void av_set_pts_info(AVStream *s, int pts_wrap_bits,
                     unsigned int pts_num, unsigned int pts_den);
int avformat_write_header(AVFormatContext *s, AVDictionary **options);
int av_write_frame(AVFormatContext *s, AVPacket *pkt);
int av_interleaved_write_frame(AVFormatContext *s, AVPacket *pkt);
int av_write_uncoded_frame(AVFormatContext *s, int stream_index,
                           AVFrame *frame);
int av_interleaved_write_uncoded_frame(AVFormatContext *s, int stream_index,
                                       AVFrame *frame);
int av_write_uncoded_frame_query(AVFormatContext *s, int stream_index);
int av_write_trailer(AVFormatContext *s);
AVOutputFormat *av_guess_format(const char *short_name,
                                const char *filename,
                                const char *mime_type);
enum AVCodecID av_guess_codec(AVOutputFormat *fmt, const char *short_name,
                            const char *filename, const char *mime_type,
                            enum AVMediaType type);
int av_get_output_timestamp(struct AVFormatContext *s, int stream,
                            int64_t *dts, int64_t *wall);
void av_hex_dump(FILE *f, const uint8_t *buf, int size);
void av_hex_dump_log(void *avcl, int level, const uint8_t *buf, int size);
void av_pkt_dump2(FILE *f, const AVPacket *pkt, int dump_payload, const AVStream *st);
void av_pkt_dump_log2(void *avcl, int level, const AVPacket *pkt, int dump_payload,
                      const AVStream *st);
enum AVCodecID av_codec_get_id(const struct AVCodecTag * const *tags, unsigned int tag);
unsigned int av_codec_get_tag(const struct AVCodecTag * const *tags, enum AVCodecID id);
int av_codec_get_tag2(const struct AVCodecTag * const *tags, enum AVCodecID id,
                      unsigned int *tag);
int av_find_default_stream_index(AVFormatContext *s);
int av_index_search_timestamp(AVStream *st, int64_t timestamp, int flags);
int av_add_index_entry(AVStream *st, int64_t pos, int64_t timestamp,
                       int size, int distance, int flags);
void av_url_split(char *proto, int proto_size,
                  char *authorization, int authorization_size,
                  char *hostname, int hostname_size,
                  int *port_ptr,
                  char *path, int path_size,
                  const char *url);
void av_dump_format(AVFormatContext *ic,
                    int index,
                    const char *url,
                    int is_output);
int av_get_frame_filename(char *buf, int buf_size,
                          const char *path, int number);
int av_filename_number_test(const char *filename);
int av_sdp_create(AVFormatContext *ac[], int n_files, char *buf, int size);
int av_match_ext(const char *filename, const char *extensions);
int avformat_query_codec(AVOutputFormat *ofmt, enum AVCodecID codec_id, int std_compliance);
const struct AVCodecTag *avformat_get_riff_video_tags(void);
const struct AVCodecTag *avformat_get_riff_audio_tags(void);
const struct AVCodecTag *avformat_get_mov_video_tags(void);
const struct AVCodecTag *avformat_get_mov_audio_tags(void);
AVRational av_guess_sample_aspect_ratio(AVFormatContext *format, AVStream *stream, AVFrame *frame);
AVRational av_guess_frame_rate(AVFormatContext *ctx, AVStream *stream, AVFrame *frame);
int avformat_match_stream_specifier(AVFormatContext *s, AVStream *st,
                                    const char *spec);
int avformat_queue_attached_pictures(AVFormatContext *s);
unsigned avdevice_version(void);
const char *avdevice_configuration(void);
const char *avdevice_license(void);
void avdevice_register_all(void);
AVInputFormat *av_input_audio_device_next(AVInputFormat *d);
AVInputFormat *av_input_video_device_next(AVInputFormat *d);
AVOutputFormat *av_output_audio_device_next(AVOutputFormat *d);
AVOutputFormat *av_output_video_device_next(AVOutputFormat *d);
typedef struct AVDeviceRect {
    int x;
    int y;
    int width;
    int height;
} AVDeviceRect;
enum AVAppToDevMessageType {
    AV_APP_TO_DEV_NONE = (('E') | (('N') << 8) | (('O') << 16) | ((unsigned)('N') << 24)),
    AV_APP_TO_DEV_WINDOW_SIZE = (('M') | (('O') << 8) | (('E') << 16) | ((unsigned)('G') << 24)),
    AV_APP_TO_DEV_WINDOW_REPAINT = (('A') | (('P') << 8) | (('E') << 16) | ((unsigned)('R') << 24)),
    AV_APP_TO_DEV_PAUSE = ((' ') | (('U') << 8) | (('A') << 16) | ((unsigned)('P') << 24)),
    AV_APP_TO_DEV_PLAY = (('Y') | (('A') << 8) | (('L') << 16) | ((unsigned)('P') << 24)),
    AV_APP_TO_DEV_TOGGLE_PAUSE = (('T') | (('U') << 8) | (('A') << 16) | ((unsigned)('P') << 24)),
    AV_APP_TO_DEV_SET_VOLUME = (('L') | (('O') << 8) | (('V') << 16) | ((unsigned)('S') << 24)),
    AV_APP_TO_DEV_MUTE = (('T') | (('U') << 8) | (('M') << 16) | ((unsigned)(' ') << 24)),
    AV_APP_TO_DEV_UNMUTE = (('T') | (('U') << 8) | (('M') << 16) | ((unsigned)('U') << 24)),
    AV_APP_TO_DEV_TOGGLE_MUTE = (('T') | (('U') << 8) | (('M') << 16) | ((unsigned)('T') << 24)),
    AV_APP_TO_DEV_GET_VOLUME = (('L') | (('O') << 8) | (('V') << 16) | ((unsigned)('G') << 24)),
    AV_APP_TO_DEV_GET_MUTE = (('T') | (('U') << 8) | (('M') << 16) | ((unsigned)('G') << 24)),
};
enum AVDevToAppMessageType {
    AV_DEV_TO_APP_NONE = (('E') | (('N') << 8) | (('O') << 16) | ((unsigned)('N') << 24)),
    AV_DEV_TO_APP_CREATE_WINDOW_BUFFER = (('E') | (('R') << 8) | (('C') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_PREPARE_WINDOW_BUFFER = (('E') | (('R') << 8) | (('P') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_DISPLAY_WINDOW_BUFFER = (('S') | (('I') << 8) | (('D') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_DESTROY_WINDOW_BUFFER = (('S') | (('E') << 8) | (('D') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_BUFFER_OVERFLOW = (('L') | (('F') << 8) | (('O') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_BUFFER_UNDERFLOW = (('L') | (('F') << 8) | (('U') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_BUFFER_READABLE = ((' ') | (('D') << 8) | (('R') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_BUFFER_WRITABLE = ((' ') | (('R') << 8) | (('W') << 16) | ((unsigned)('B') << 24)),
    AV_DEV_TO_APP_MUTE_STATE_CHANGED = (('T') | (('U') << 8) | (('M') << 16) | ((unsigned)('C') << 24)),
    AV_DEV_TO_APP_VOLUME_LEVEL_CHANGED = (('L') | (('O') << 8) | (('V') << 16) | ((unsigned)('C') << 24)),
};
int avdevice_app_to_dev_control_message(struct AVFormatContext *s,
                                        enum AVAppToDevMessageType type,
                                        void *data, size_t data_size);
int avdevice_dev_to_app_control_message(struct AVFormatContext *s,
                                        enum AVDevToAppMessageType type,
                                        void *data, size_t data_size);
typedef struct AVDeviceCapabilitiesQuery {
    const AVClass *av_class;
    AVFormatContext *device_context;
    enum AVCodecID codec;
    enum AVSampleFormat sample_format;
    enum AVPixelFormat pixel_format;
    int sample_rate;
    int channels;
    int64_t channel_layout;
    int window_width;
    int window_height;
    int frame_width;
    int frame_height;
    AVRational fps;
} AVDeviceCapabilitiesQuery;
extern const AVOption av_device_capabilities[];
int avdevice_capabilities_create(AVDeviceCapabilitiesQuery **caps, AVFormatContext *s,
                                 AVDictionary **device_options);
void avdevice_capabilities_free(AVDeviceCapabilitiesQuery **caps, AVFormatContext *s);
typedef struct AVDeviceInfo {
    char *device_name;
    char *device_description;
} AVDeviceInfo;
typedef struct AVDeviceInfoList {
    AVDeviceInfo **devices;
    int nb_devices;
    int default_device;
} AVDeviceInfoList;
int avdevice_list_devices(struct AVFormatContext *s, AVDeviceInfoList **device_list);
void avdevice_free_list_devices(AVDeviceInfoList **device_list);
unsigned avfilter_version(void);
const char *avfilter_configuration(void);
const char *avfilter_license(void);
typedef struct AVFilterContext AVFilterContext;
typedef struct AVFilterLink AVFilterLink;
typedef struct AVFilterPad AVFilterPad;
typedef struct AVFilterFormats AVFilterFormats;
typedef struct AVFilterBuffer {
    uint8_t *data[8];
    uint8_t **extended_data;
    int linesize[8];
    void *priv;
    void (*free)(struct AVFilterBuffer *buf);
    int format;
    int w, h;
    unsigned refcount;
} AVFilterBuffer;
typedef struct AVFilterBufferRefAudioProps {
    uint64_t channel_layout;
    int nb_samples;
    int sample_rate;
    int channels;
} AVFilterBufferRefAudioProps;
typedef struct AVFilterBufferRefVideoProps {
    int w;
    int h;
    AVRational sample_aspect_ratio;
    int interlaced;
    int top_field_first;
    enum AVPictureType pict_type;
    int key_frame;
    int qp_table_linesize;
    int qp_table_size;
    int8_t *qp_table;
} AVFilterBufferRefVideoProps;
typedef struct AVFilterBufferRef {
    AVFilterBuffer *buf;
    uint8_t *data[8];
    uint8_t **extended_data;
    int linesize[8];
    AVFilterBufferRefVideoProps *video;
    AVFilterBufferRefAudioProps *audio;
    int64_t pts;
    int64_t pos;
    int format;
    int perms;
    enum AVMediaType type;
    AVDictionary *metadata;
} AVFilterBufferRef;
__attribute__((deprecated))
void avfilter_copy_buffer_ref_props(AVFilterBufferRef *dst, const AVFilterBufferRef *src);
__attribute__((deprecated))
AVFilterBufferRef *avfilter_ref_buffer(AVFilterBufferRef *ref, int pmask);
__attribute__((deprecated))
void avfilter_unref_buffer(AVFilterBufferRef *ref);
__attribute__((deprecated))
void avfilter_unref_bufferp(AVFilterBufferRef **ref);
__attribute__((deprecated))
int avfilter_ref_get_channels(AVFilterBufferRef *ref);
struct AVFilterPad {
    const char *name;
    enum AVMediaType type;
    __attribute__((deprecated)) int min_perms;
    __attribute__((deprecated)) int rej_perms;
    int (*start_frame)(AVFilterLink *link, AVFilterBufferRef *picref);
    AVFrame *(*get_video_buffer)(AVFilterLink *link, int w, int h);
    AVFrame *(*get_audio_buffer)(AVFilterLink *link, int nb_samples);
    int (*end_frame)(AVFilterLink *link);
    int (*draw_slice)(AVFilterLink *link, int y, int height, int slice_dir);
    int (*filter_frame)(AVFilterLink *link, AVFrame *frame);
    int (*poll_frame)(AVFilterLink *link);
    int (*request_frame)(AVFilterLink *link);
    int (*config_props)(AVFilterLink *link);
    int needs_fifo;
    int needs_writable;
};
int avfilter_pad_count(const AVFilterPad *pads);
const char *avfilter_pad_get_name(const AVFilterPad *pads, int pad_idx);
enum AVMediaType avfilter_pad_get_type(const AVFilterPad *pads, int pad_idx);
typedef struct AVFilter {
    const char *name;
    const char *description;
    const AVFilterPad *inputs;
    const AVFilterPad *outputs;
    const AVClass *priv_class;
    int flags;
    int (*init)(AVFilterContext *ctx);
    int (*init_dict)(AVFilterContext *ctx, AVDictionary **options);
    void (*uninit)(AVFilterContext *ctx);
    int (*query_formats)(AVFilterContext *);
    int priv_size;
    struct AVFilter *next;
    int (*process_command)(AVFilterContext *, const char *cmd, const char *arg, char *res, int res_len, int flags);
    int (*init_opaque)(AVFilterContext *ctx, void *opaque);
} AVFilter;
typedef struct AVFilterInternal AVFilterInternal;
struct AVFilterContext {
    const AVClass *av_class;
    const AVFilter *filter;
    char *name;
    AVFilterPad *input_pads;
    AVFilterLink **inputs;
    __attribute__((deprecated)) unsigned input_count;
    unsigned nb_inputs;
    AVFilterPad *output_pads;
    AVFilterLink **outputs;
    __attribute__((deprecated)) unsigned output_count;
    unsigned nb_outputs;
    void *priv;
    struct AVFilterGraph *graph;
    int thread_type;
    AVFilterInternal *internal;
    struct AVFilterCommand *command_queue;
    char *enable_str;
    void *enable;
    double *var_values;
    int is_disabled;
};
struct AVFilterLink {
    AVFilterContext *src;
    AVFilterPad *srcpad;
    AVFilterContext *dst;
    AVFilterPad *dstpad;
    enum AVMediaType type;
    int w;
    int h;
    AVRational sample_aspect_ratio;
    uint64_t channel_layout;
    int sample_rate;
    int format;
    AVRational time_base;
    AVFilterFormats *in_formats;
    AVFilterFormats *out_formats;
    AVFilterFormats *in_samplerates;
    AVFilterFormats *out_samplerates;
    struct AVFilterChannelLayouts *in_channel_layouts;
    struct AVFilterChannelLayouts *out_channel_layouts;
    int request_samples;
    enum {
        AVLINK_UNINIT = 0,
        AVLINK_STARTINIT,
        AVLINK_INIT
    } init_state;
    struct AVFilterPool *pool;
    struct AVFilterGraph *graph;
    int64_t current_pts;
    int age_index;
    AVRational frame_rate;
    AVFrame *partial_buf;
    int partial_buf_size;
    int min_samples;
    int max_samples;
    AVFilterBufferRef *cur_buf_copy;
    int closed;
    int channels;
    unsigned frame_requested;
    unsigned flags;
    int64_t frame_count;
};
int avfilter_link(AVFilterContext *src, unsigned srcpad,
                  AVFilterContext *dst, unsigned dstpad);
void avfilter_link_free(AVFilterLink **link);
int avfilter_link_get_channels(AVFilterLink *link);
void avfilter_link_set_closed(AVFilterLink *link, int closed);
int avfilter_config_links(AVFilterContext *filter);
__attribute__((deprecated))
AVFilterBufferRef *
avfilter_get_video_buffer_ref_from_arrays(uint8_t * const data[4], const int linesize[4], int perms,
                                          int w, int h, enum AVPixelFormat format);
__attribute__((deprecated))
AVFilterBufferRef *avfilter_get_audio_buffer_ref_from_arrays(uint8_t **data,
                                                             int linesize,
                                                             int perms,
                                                             int nb_samples,
                                                             enum AVSampleFormat sample_fmt,
                                                             uint64_t channel_layout);
__attribute__((deprecated))
AVFilterBufferRef *avfilter_get_audio_buffer_ref_from_arrays_channels(uint8_t **data,
                                                                      int linesize,
                                                                      int perms,
                                                                      int nb_samples,
                                                                      enum AVSampleFormat sample_fmt,
                                                                      int channels,
                                                                      uint64_t channel_layout);
int avfilter_process_command(AVFilterContext *filter, const char *cmd, const char *arg, char *res, int res_len, int flags);
void avfilter_register_all(void);
__attribute__((deprecated))
void avfilter_uninit(void);
int avfilter_register(AVFilter *filter);
AVFilter *avfilter_get_by_name(const char *name);
const AVFilter *avfilter_next(const AVFilter *prev);
__attribute__((deprecated))
AVFilter **av_filter_next(AVFilter **filter);
__attribute__((deprecated))
int avfilter_open(AVFilterContext **filter_ctx, AVFilter *filter, const char *inst_name);
__attribute__((deprecated))
int avfilter_init_filter(AVFilterContext *filter, const char *args, void *opaque);
int avfilter_init_str(AVFilterContext *ctx, const char *args);
int avfilter_init_dict(AVFilterContext *ctx, AVDictionary **options);
void avfilter_free(AVFilterContext *filter);
int avfilter_insert_filter(AVFilterLink *link, AVFilterContext *filt,
                           unsigned filt_srcpad_idx, unsigned filt_dstpad_idx);
__attribute__((deprecated))
int avfilter_copy_frame_props(AVFilterBufferRef *dst, const AVFrame *src);
__attribute__((deprecated))
int avfilter_copy_buf_props(AVFrame *dst, const AVFilterBufferRef *src);
const AVClass *avfilter_get_class(void);
typedef struct AVFilterGraphInternal AVFilterGraphInternal;
typedef int (avfilter_action_func)(AVFilterContext *ctx, void *arg, int jobnr, int nb_jobs);
typedef int (avfilter_execute_func)(AVFilterContext *ctx, avfilter_action_func *func,
                                    void *arg, int *ret, int nb_jobs);
typedef struct AVFilterGraph {
    const AVClass *av_class;
    __attribute__((deprecated))
    unsigned filter_count_unused;
    AVFilterContext **filters;
    char *scale_sws_opts;
    char *resample_lavr_opts;
    unsigned nb_filters;
    int thread_type;
    int nb_threads;
    AVFilterGraphInternal *internal;
    void *opaque;
    avfilter_execute_func *execute;
    char *aresample_swr_opts;
    AVFilterLink **sink_links;
    int sink_links_count;
    unsigned disable_auto_convert;
} AVFilterGraph;
AVFilterGraph *avfilter_graph_alloc(void);
AVFilterContext *avfilter_graph_alloc_filter(AVFilterGraph *graph,
                                             const AVFilter *filter,
                                             const char *name);
AVFilterContext *avfilter_graph_get_filter(AVFilterGraph *graph, const char *name);
__attribute__((deprecated))
int avfilter_graph_add_filter(AVFilterGraph *graphctx, AVFilterContext *filter);
int avfilter_graph_create_filter(AVFilterContext **filt_ctx, const AVFilter *filt,
                                 const char *name, const char *args, void *opaque,
                                 AVFilterGraph *graph_ctx);
void avfilter_graph_set_auto_convert(AVFilterGraph *graph, unsigned flags);
enum {
    AVFILTER_AUTO_CONVERT_ALL = 0,
    AVFILTER_AUTO_CONVERT_NONE = -1,
};
int avfilter_graph_config(AVFilterGraph *graphctx, void *log_ctx);
void avfilter_graph_free(AVFilterGraph **graph);
typedef struct AVFilterInOut {
    char *name;
    AVFilterContext *filter_ctx;
    int pad_idx;
    struct AVFilterInOut *next;
} AVFilterInOut;
AVFilterInOut *avfilter_inout_alloc(void);
void avfilter_inout_free(AVFilterInOut **inout);
__attribute__((deprecated))
int avfilter_graph_parse(AVFilterGraph *graph, const char *filters,
                         AVFilterInOut **inputs, AVFilterInOut **outputs,
                         void *log_ctx);
int avfilter_graph_parse_ptr(AVFilterGraph *graph, const char *filters,
                             AVFilterInOut **inputs, AVFilterInOut **outputs,
                             void *log_ctx);
int avfilter_graph_parse2(AVFilterGraph *graph, const char *filters,
                          AVFilterInOut **inputs,
                          AVFilterInOut **outputs);
int avfilter_graph_send_command(AVFilterGraph *graph, const char *target, const char *cmd, const char *arg, char *res, int res_len, int flags);
int avfilter_graph_queue_command(AVFilterGraph *graph, const char *target, const char *cmd, const char *arg, int flags, double ts);
char *avfilter_graph_dump(AVFilterGraph *graph, const char *options);
int avfilter_graph_request_oldest(AVFilterGraph *graph);
__attribute__((deprecated))
int av_asrc_buffer_add_samples(AVFilterContext *abuffersrc,
                               uint8_t *data[8], int linesize[8],
                               int nb_samples, int sample_rate,
                               int sample_fmt, int64_t ch_layout, int planar,
                               int64_t pts, int __attribute__((unused)) flags);
__attribute__((deprecated))
int av_asrc_buffer_add_buffer(AVFilterContext *abuffersrc,
                              uint8_t *buf, int buf_size,
                              int sample_rate,
                              int sample_fmt, int64_t ch_layout, int planar,
                              int64_t pts, int __attribute__((unused)) flags);
__attribute__((deprecated))
int av_asrc_buffer_add_audio_buffer_ref(AVFilterContext *abuffersrc,
                                        AVFilterBufferRef *samplesref,
                                        int __attribute__((unused)) flags);
__attribute__((deprecated))
AVFilterBufferRef *avfilter_get_video_buffer_ref_from_frame(const AVFrame *frame, int perms);
__attribute__((deprecated))
AVFilterBufferRef *avfilter_get_audio_buffer_ref_from_frame(const AVFrame *frame,
                                                            int perms);
__attribute__((deprecated))
AVFilterBufferRef *avfilter_get_buffer_ref_from_frame(enum AVMediaType type,
                                                      const AVFrame *frame,
                                                      int perms);
__attribute__((deprecated))
int avfilter_fill_frame_from_audio_buffer_ref(AVFrame *frame,
                                              const AVFilterBufferRef *samplesref);
__attribute__((deprecated))
int avfilter_fill_frame_from_video_buffer_ref(AVFrame *frame,
                                              const AVFilterBufferRef *picref);
__attribute__((deprecated))
int avfilter_fill_frame_from_buffer_ref(AVFrame *frame,
                                        const AVFilterBufferRef *ref);
__attribute__((deprecated))
int av_buffersink_get_buffer_ref(AVFilterContext *buffer_sink,
                                 AVFilterBufferRef **bufref, int flags);
__attribute__((deprecated))
int av_buffersink_poll_frame(AVFilterContext *ctx);
__attribute__((deprecated))
int av_buffersink_read(AVFilterContext *ctx, AVFilterBufferRef **buf);
__attribute__((deprecated))
int av_buffersink_read_samples(AVFilterContext *ctx, AVFilterBufferRef **buf,
                               int nb_samples);
int av_buffersink_get_frame_flags(AVFilterContext *ctx, AVFrame *frame, int flags);
typedef struct {
    const enum AVPixelFormat *pixel_fmts;
} AVBufferSinkParams;
AVBufferSinkParams *av_buffersink_params_alloc(void);
typedef struct {
    const enum AVSampleFormat *sample_fmts;
    const int64_t *channel_layouts;
    const int *channel_counts;
    int all_channel_counts;
    int *sample_rates;
} AVABufferSinkParams;
AVABufferSinkParams *av_abuffersink_params_alloc(void);
void av_buffersink_set_frame_size(AVFilterContext *ctx, unsigned frame_size);
AVRational av_buffersink_get_frame_rate(AVFilterContext *ctx);
int av_buffersink_get_frame(AVFilterContext *ctx, AVFrame *frame);
int av_buffersink_get_samples(AVFilterContext *ctx, AVFrame *frame, int nb_samples);
enum {
    AV_BUFFERSRC_FLAG_NO_CHECK_FORMAT = 1,
    AV_BUFFERSRC_FLAG_NO_COPY = 2,
    AV_BUFFERSRC_FLAG_PUSH = 4,
    AV_BUFFERSRC_FLAG_KEEP_REF = 8,
};
int av_buffersrc_add_ref(AVFilterContext *buffer_src,
                         AVFilterBufferRef *picref, int flags);
unsigned av_buffersrc_get_nb_failed_requests(AVFilterContext *buffer_src);
__attribute__((deprecated))
int av_buffersrc_buffer(AVFilterContext *ctx, AVFilterBufferRef *buf);
int av_buffersrc_write_frame(AVFilterContext *ctx, const AVFrame *frame);
int av_buffersrc_add_frame(AVFilterContext *ctx, AVFrame *frame);
int av_buffersrc_add_frame_flags(AVFilterContext *buffer_src,
                                 AVFrame *frame, int flags);
unsigned long av_adler32_update(unsigned long adler, const uint8_t *buf,
                                unsigned int len) __attribute__((pure));
extern const int av_aes_size;
struct AVAES;
struct AVAES *av_aes_alloc(void);
int av_aes_init(struct AVAES *a, const uint8_t *key, int key_bits, int decrypt);
void av_aes_crypt(struct AVAES *a, uint8_t *dst, const uint8_t *src, int count, uint8_t *iv, int decrypt);
typedef struct AVFifoBuffer {
    uint8_t *buffer;
    uint8_t *rptr, *wptr, *end;
    uint32_t rndx, wndx;
} AVFifoBuffer;
AVFifoBuffer *av_fifo_alloc(unsigned int size);
void av_fifo_free(AVFifoBuffer *f);
void av_fifo_reset(AVFifoBuffer *f);
int av_fifo_size(AVFifoBuffer *f);
int av_fifo_space(AVFifoBuffer *f);
int av_fifo_generic_read(AVFifoBuffer *f, void *dest, int buf_size, void (*func)(void*, void*, int));
int av_fifo_generic_write(AVFifoBuffer *f, void *src, int size, int (*func)(void*, void*, int));
int av_fifo_realloc2(AVFifoBuffer *f, unsigned int size);
int av_fifo_grow(AVFifoBuffer *f, unsigned int additional_space);
void av_fifo_drain(AVFifoBuffer *f, int size);

typedef struct AVAudioFifo AVAudioFifo;
void av_audio_fifo_free(AVAudioFifo *af);
AVAudioFifo *av_audio_fifo_alloc(enum AVSampleFormat sample_fmt, int channels,
                                 int nb_samples);
int av_audio_fifo_realloc(AVAudioFifo *af, int nb_samples);
int av_audio_fifo_write(AVAudioFifo *af, void **data, int nb_samples);
int av_audio_fifo_read(AVAudioFifo *af, void **data, int nb_samples);
int av_audio_fifo_drain(AVAudioFifo *af, int nb_samples);
void av_audio_fifo_reset(AVAudioFifo *af);
int av_audio_fifo_size(AVAudioFifo *af);
int av_audio_fifo_space(AVAudioFifo *af);
int av_strstart(const char *str, const char *pfx, const char **ptr);
int av_stristart(const char *str, const char *pfx, const char **ptr);
char *av_stristr(const char *haystack, const char *needle);
char *av_strnstr(const char *haystack, const char *needle, size_t hay_length);
size_t av_strlcpy(char *dst, const char *src, size_t size);
size_t av_strlcat(char *dst, const char *src, size_t size);
size_t av_strlcatf(char *dst, size_t size, const char *fmt, ...) __attribute__((__format__(__printf__, 3, 4)));

char *av_asprintf(const char *fmt, ...) __attribute__((__format__(__printf__, 1, 2)));
char *av_d2str(double d);
char *av_get_token(const char **buf, const char *term);
char *av_strtok(char *s, const char *delim, char **saveptr);
int av_isdigit(int c);
int av_isgraph(int c);
int av_isspace(int c);

int av_isxdigit(int c);
int av_strcasecmp(const char *a, const char *b);
int av_strncasecmp(const char *a, const char *b, size_t n);
const char *av_basename(const char *path);
const char *av_dirname(char *path);
enum AVEscapeMode {
    AV_ESCAPE_MODE_AUTO,
    AV_ESCAPE_MODE_BACKSLASH,
    AV_ESCAPE_MODE_QUOTE,
};
int av_escape(char **dst, const char *src, const char *special_chars,
              enum AVEscapeMode mode, int flags);
int av_utf8_decode(int32_t *codep, const uint8_t **bufp, const uint8_t *buf_end,
                   unsigned int flags);
int av_base64_decode(uint8_t *out, const char *in, int out_size);
char *av_base64_encode(char *out, int out_size, const uint8_t *in, int in_size);
typedef struct AVBlowfish {
    uint32_t p[16 + 2];
    uint32_t s[4][256];
} AVBlowfish;
void av_blowfish_init(struct AVBlowfish *ctx, const uint8_t *key, int key_len);
void av_blowfish_crypt_ecb(struct AVBlowfish *ctx, uint32_t *xl, uint32_t *xr,
                           int decrypt);
void av_blowfish_crypt(struct AVBlowfish *ctx, uint8_t *dst, const uint8_t *src,
                       int count, uint8_t *iv, int decrypt);
typedef struct AVBPrint {
    char *str; unsigned len; unsigned size; unsigned size_max; char reserved_internal_buffer[1]; char reserved_padding[1024 - sizeof(struct { char *str; unsigned len; unsigned size; unsigned size_max; char reserved_internal_buffer[1]; })];
} AVBPrint;
void av_bprint_init(AVBPrint *buf, unsigned size_init, unsigned size_max);
void av_bprint_init_for_buffer(AVBPrint *buf, char *buffer, unsigned size);
void av_bprintf(AVBPrint *buf, const char *fmt, ...) __attribute__((__format__(__printf__, 2, 3)));
void av_vbprintf(AVBPrint *buf, const char *fmt, va_list vl_arg);
void av_bprint_chars(AVBPrint *buf, char c, unsigned n);
void av_bprint_append_data(AVBPrint *buf, const char *data, unsigned size);
struct tm;
void av_bprint_strftime(AVBPrint *buf, const char *fmt, const struct tm *tm);
void av_bprint_get_buffer(AVBPrint *buf, unsigned size,
                          unsigned char **mem, unsigned *actual_size);
void av_bprint_clear(AVBPrint *buf);

int av_bprint_finalize(AVBPrint *buf, char **ret_str);
void av_bprint_escape(AVBPrint *dstbuf, const char *src, const char *special_chars,
                      enum AVEscapeMode mode, int flags);

typedef uint32_t AVCRC;
typedef enum {
    AV_CRC_8_ATM,
    AV_CRC_16_ANSI,
    AV_CRC_16_CCITT,
    AV_CRC_32_IEEE,
    AV_CRC_32_IEEE_LE,
    AV_CRC_16_ANSI_LE,
    AV_CRC_24_IEEE = 12,
    AV_CRC_MAX,
}AVCRCId;
int av_crc_init(AVCRC *ctx, int le, int bits, uint32_t poly, int ctx_size);
const AVCRC *av_crc_get_table(AVCRCId crc_id);
uint32_t av_crc(const AVCRC *ctx, uint32_t crc,
                const uint8_t *buffer, size_t length) __attribute__((pure));
enum AVDownmixType {
    AV_DOWNMIX_TYPE_UNKNOWN,
    AV_DOWNMIX_TYPE_LORO,
    AV_DOWNMIX_TYPE_LTRT,
    AV_DOWNMIX_TYPE_DPLII,
    AV_DOWNMIX_TYPE_NB
};
typedef struct AVDownmixInfo {
    enum AVDownmixType preferred_downmix_type;
    double center_mix_level;
    double center_mix_level_ltrt;
    double surround_mix_level;
    double surround_mix_level_ltrt;
    double lfe_mix_level;
} AVDownmixInfo;
AVDownmixInfo *av_downmix_info_update_side_data(AVFrame *frame);
typedef struct AVExpr AVExpr;
int av_expr_parse_and_eval(double *res, const char *s,
                           const char * const *const_names, const double *const_values,
                           const char * const *func1_names, double (* const *funcs1)(void *, double),
                           const char * const *func2_names, double (* const *funcs2)(void *, double, double),
                           void *opaque, int log_offset, void *log_ctx);
int av_expr_parse(AVExpr **expr, const char *s,
                  const char * const *const_names,
                  const char * const *func1_names, double (* const *funcs1)(void *, double),
                  const char * const *func2_names, double (* const *funcs2)(void *, double, double),
                  int log_offset, void *log_ctx);
double av_expr_eval(AVExpr *e, const double *const_values, void *opaque);
void av_expr_free(AVExpr *e);
double av_strtod(const char *numstr, char **tail);
int av_file_map(const char *filename, uint8_t **bufptr, size_t *size,
                int log_offset, void *log_ctx);
void av_file_unmap(uint8_t *bufptr, size_t size);
int av_tempfile(const char *prefix, char **filename, int log_offset, void *log_ctx);
enum AVHMACType {
    AV_HMAC_MD5,
    AV_HMAC_SHA1,
    AV_HMAC_SHA224 = 10,
    AV_HMAC_SHA256,
    AV_HMAC_SHA384,
    AV_HMAC_SHA512,
};
typedef struct AVHMAC AVHMAC;
AVHMAC *av_hmac_alloc(enum AVHMACType type);
void av_hmac_free(AVHMAC *ctx);
void av_hmac_init(AVHMAC *ctx, const uint8_t *key, unsigned int keylen);
void av_hmac_update(AVHMAC *ctx, const uint8_t *data, unsigned int len);
int av_hmac_final(AVHMAC *ctx, uint8_t *out, unsigned int outlen);
int av_hmac_calc(AVHMAC *ctx, const uint8_t *data, unsigned int len,
                 const uint8_t *key, unsigned int keylen,
                 uint8_t *out, unsigned int outlen);
typedef struct AVComponentDescriptor{
    uint16_t plane :2;
    uint16_t step_minus1 :3;
    uint16_t offset_plus1 :3;
    uint16_t shift :3;
    uint16_t depth_minus1 :4;
}AVComponentDescriptor;
typedef struct AVPixFmtDescriptor{
    const char *name;
    uint8_t nb_components;
    uint8_t log2_chroma_w;
    uint8_t log2_chroma_h;
    uint8_t flags;
    AVComponentDescriptor comp[4];
}AVPixFmtDescriptor;
extern __attribute__((deprecated)) const AVPixFmtDescriptor av_pix_fmt_descriptors[];
void av_read_image_line(uint16_t *dst, const uint8_t *data[4], const int linesize[4],
                        const AVPixFmtDescriptor *desc, int x, int y, int c, int w, int read_pal_component);
void av_write_image_line(const uint16_t *src, uint8_t *data[4], const int linesize[4],
                         const AVPixFmtDescriptor *desc, int x, int y, int c, int w);
enum AVPixelFormat av_get_pix_fmt(const char *name);
const char *av_get_pix_fmt_name(enum AVPixelFormat pix_fmt);
char *av_get_pix_fmt_string (char *buf, int buf_size, enum AVPixelFormat pix_fmt);
int av_get_bits_per_pixel(const AVPixFmtDescriptor *pixdesc);
int av_get_padded_bits_per_pixel(const AVPixFmtDescriptor *pixdesc);
const AVPixFmtDescriptor *av_pix_fmt_desc_get(enum AVPixelFormat pix_fmt);
const AVPixFmtDescriptor *av_pix_fmt_desc_next(const AVPixFmtDescriptor *prev);
enum AVPixelFormat av_pix_fmt_desc_get_id(const AVPixFmtDescriptor *desc);
int av_pix_fmt_get_chroma_sub_sample(enum AVPixelFormat pix_fmt,
                                     int *h_shift, int *v_shift);
int av_pix_fmt_count_planes(enum AVPixelFormat pix_fmt);
void ff_check_pixfmt_descriptors(void);
enum AVPixelFormat av_pix_fmt_swap_endianness(enum AVPixelFormat pix_fmt);
void av_image_fill_max_pixsteps(int max_pixsteps[4], int max_pixstep_comps[4],
                                const AVPixFmtDescriptor *pixdesc);
int av_image_get_linesize(enum AVPixelFormat pix_fmt, int width, int plane);
int av_image_fill_linesizes(int linesizes[4], enum AVPixelFormat pix_fmt, int width);
int av_image_fill_pointers(uint8_t *data[4], enum AVPixelFormat pix_fmt, int height,
                           uint8_t *ptr, const int linesizes[4]);
int av_image_alloc(uint8_t *pointers[4], int linesizes[4],
                   int w, int h, enum AVPixelFormat pix_fmt, int align);
void av_image_copy_plane(uint8_t *dst, int dst_linesize,
                         const uint8_t *src, int src_linesize,
                         int bytewidth, int height);
void av_image_copy(uint8_t *dst_data[4], int dst_linesizes[4],
                   const uint8_t *src_data[4], const int src_linesizes[4],
                   enum AVPixelFormat pix_fmt, int width, int height);
int av_image_fill_arrays(uint8_t *dst_data[4], int dst_linesize[4],
                         const uint8_t *src,
                         enum AVPixelFormat pix_fmt, int width, int height, int align);
int av_image_get_buffer_size(enum AVPixelFormat pix_fmt, int width, int height, int align);
int av_image_copy_to_buffer(uint8_t *dst, int dst_size,
                            const uint8_t * const src_data[4], const int src_linesize[4],
                            enum AVPixelFormat pix_fmt, int width, int height, int align);
int av_image_check_size(unsigned int w, unsigned int h, int log_offset, void *log_ctx);
int avpriv_set_systematic_pal2(uint32_t pal[256], enum AVPixelFormat pix_fmt);
typedef struct AVExtFloat {
    uint8_t exponent[2];
    uint8_t mantissa[8];
} AVExtFloat;
__attribute__((deprecated)) double av_int2dbl(int64_t v) __attribute__((const));
__attribute__((deprecated)) float av_int2flt(int32_t v) __attribute__((const));
__attribute__((deprecated)) double av_ext2dbl(const AVExtFloat ext) __attribute__((const));
__attribute__((deprecated)) int64_t av_dbl2int(double d) __attribute__((const));
__attribute__((deprecated)) int32_t av_flt2int(float d) __attribute__((const));
__attribute__((deprecated)) AVExtFloat av_dbl2ext(double d) __attribute__((const));
typedef union {
    uint64_t u64;
    uint32_t u32[2];
    uint16_t u16[4];
    uint8_t u8 [8];
    double f64;
    float f32[2];
} __attribute__((may_alias)) av_alias64;
typedef union {
    uint32_t u32;
    uint16_t u16[2];
    uint8_t u8 [4];
    float f32;
} __attribute__((may_alias)) av_alias32;
typedef union {
    uint16_t u16;
    uint8_t u8 [2];
} __attribute__((may_alias)) av_alias16;
union unaligned_64 { uint64_t l; } __attribute__((packed)) __attribute__((may_alias));
union unaligned_32 { uint32_t l; } __attribute__((packed)) __attribute__((may_alias));
union unaligned_16 { uint16_t l; } __attribute__((packed)) __attribute__((may_alias));
typedef struct AVLFG {
    unsigned int state[64];
    int index;
} AVLFG;
void av_lfg_init(AVLFG *c, unsigned int seed);

void av_bmg_get(AVLFG *lfg, double out[2]);
int av_lzo1x_decode(void *out, int *outlen, const void *in, int *inlen);
extern const int av_md5_size;
struct AVMD5;
struct AVMD5 *av_md5_alloc(void);
void av_md5_init(struct AVMD5 *ctx);
void av_md5_update(struct AVMD5 *ctx, const uint8_t *src, int len);
void av_md5_final(struct AVMD5 *ctx, uint8_t *dst);
void av_md5_sum(uint8_t *dst, const uint8_t *src, const int len);
struct AVMurMur3 *av_murmur3_alloc(void);
void av_murmur3_init_seeded(struct AVMurMur3 *c, uint64_t seed);
void av_murmur3_init(struct AVMurMur3 *c);
void av_murmur3_update(struct AVMurMur3 *c, const uint8_t *src, int len);
void av_murmur3_final(struct AVMurMur3 *c, uint8_t dst[16]);
int av_parse_ratio(AVRational *q, const char *str, int max,
                   int log_offset, void *log_ctx);
int av_parse_video_size(int *width_ptr, int *height_ptr, const char *str);
int av_parse_video_rate(AVRational *rate, const char *str);
int av_parse_color(uint8_t *rgba_color, const char *color_string, int slen,
                   void *log_ctx);
const char *av_get_known_color_name(int color_idx, const uint8_t **rgb);
int av_parse_time(int64_t *timeval, const char *timestr, int duration);
char *av_small_strptime(const char *p, const char *fmt, struct tm *dt);
int av_find_info_tag(char *arg, int arg_size, const char *tag1, const char *info);
void *av_timegm(struct tm *tm);
uint32_t av_get_random_seed(void);
typedef struct AVReplayGain {
    int32_t track_gain;
    uint32_t track_peak;
    int32_t album_gain;
    uint32_t album_peak;
} AVReplayGain;
extern const int av_ripemd_size;
struct AVRIPEMD;
struct AVRIPEMD *av_ripemd_alloc(void);
int av_ripemd_init(struct AVRIPEMD* context, int bits);
void av_ripemd_update(struct AVRIPEMD* context, const uint8_t* data, unsigned int len);
void av_ripemd_final(struct AVRIPEMD* context, uint8_t *digest);
extern const int av_sha_size;
struct AVSHA;
struct AVSHA *av_sha_alloc(void);
int av_sha_init(struct AVSHA* context, int bits);
void av_sha_update(struct AVSHA* context, const uint8_t* data, unsigned int len);
void av_sha_final(struct AVSHA* context, uint8_t *digest);
extern const int av_sha512_size;
struct AVSHA512;
struct AVSHA512 *av_sha512_alloc(void);
int av_sha512_init(struct AVSHA512* context, int bits);
void av_sha512_update(struct AVSHA512* context, const uint8_t* data, unsigned int len);
void av_sha512_final(struct AVSHA512* context, uint8_t *digest);
enum AVStereo3DType {
    AV_STEREO3D_2D,
    AV_STEREO3D_SIDEBYSIDE,
    AV_STEREO3D_TOPBOTTOM,
    AV_STEREO3D_FRAMESEQUENCE,
    AV_STEREO3D_CHECKERBOARD,
    AV_STEREO3D_SIDEBYSIDE_QUINCUNX,
    AV_STEREO3D_LINES,
    AV_STEREO3D_COLUMNS,
};
typedef struct AVStereo3D {
    enum AVStereo3DType type;
    int flags;
} AVStereo3D;
AVStereo3D *av_stereo3d_alloc(void);
AVStereo3D *av_stereo3d_create_side_data(AVFrame *frame);
int64_t av_gettime(void);
int av_usleep(unsigned usec);
enum AVTimecodeFlag {
    AV_TIMECODE_FLAG_DROPFRAME = 1<<0,
    AV_TIMECODE_FLAG_24HOURSMAX = 1<<1,
    AV_TIMECODE_FLAG_ALLOWNEGATIVE = 1<<2,
};
typedef struct {
    int start;
    uint32_t flags;
    AVRational rate;
    unsigned fps;
} AVTimecode;
int av_timecode_adjust_ntsc_framenum2(int framenum, int fps);
uint32_t av_timecode_get_smpte_from_framenum(const AVTimecode *tc, int framenum);
char *av_timecode_make_string(const AVTimecode *tc, char *buf, int framenum);
char *av_timecode_make_smpte_tc_string(char *buf, uint32_t tcsmpte, int prevent_df);
char *av_timecode_make_mpeg_tc_string(char *buf, uint32_t tc25bit);
int av_timecode_init(AVTimecode *tc, AVRational rate, int flags, int frame_start, void *log_ctx);
int av_timecode_init_from_string(AVTimecode *tc, AVRational rate, const char *str, void *log_ctx);
int av_timecode_check_frame_rate(AVRational rate);

typedef struct AVXTEA {
    uint32_t key[16];
} AVXTEA;
void av_xtea_init(struct AVXTEA *ctx, const uint8_t key[16]);
void av_xtea_crypt(struct AVXTEA *ctx, uint8_t *dst, const uint8_t *src,
                   int count, uint8_t *iv, int decrypt);
unsigned postproc_version(void);
const char *postproc_configuration(void);
const char *postproc_license(void);
typedef void pp_context;
typedef void pp_mode;
extern const char pp_help[];
void pp_postprocess(const uint8_t * src[3], const int srcStride[3],
                     uint8_t * dst[3], const int dstStride[3],
                     int horizontalSize, int verticalSize,
                     const int8_t *QP_store, int QP_stride,
                     pp_mode *mode, pp_context *ppContext, int pict_type);
pp_mode *pp_get_mode_by_name_and_quality(const char *name, int quality);
void pp_free_mode(pp_mode *mode);
pp_context *pp_get_context(int width, int height, int flags);
void pp_free_context(pp_context *ppContext);
unsigned swscale_version(void);
const char *swscale_configuration(void);
const char *swscale_license(void);
const int *sws_getCoefficients(int colorspace);
typedef struct SwsVector {
    double *coeff;
    int length;
} SwsVector;
typedef struct SwsFilter {
    SwsVector *lumH;
    SwsVector *lumV;
    SwsVector *chrH;
    SwsVector *chrV;
} SwsFilter;
struct SwsContext;
int sws_isSupportedInput(enum AVPixelFormat pix_fmt);
int sws_isSupportedOutput(enum AVPixelFormat pix_fmt);
int sws_isSupportedEndiannessConversion(enum AVPixelFormat pix_fmt);
struct SwsContext *sws_alloc_context(void);
int sws_init_context(struct SwsContext *sws_context, SwsFilter *srcFilter, SwsFilter *dstFilter);
void sws_freeContext(struct SwsContext *swsContext);
struct SwsContext *sws_getContext(int srcW, int srcH, enum AVPixelFormat srcFormat,
                                  int dstW, int dstH, enum AVPixelFormat dstFormat,
                                  int flags, SwsFilter *srcFilter,
                                  SwsFilter *dstFilter, const double *param);
int sws_scale(struct SwsContext *c, const uint8_t *const srcSlice[],
              const int srcStride[], int srcSliceY, int srcSliceH,
              uint8_t *const dst[], const int dstStride[]);
int sws_setColorspaceDetails(struct SwsContext *c, const int inv_table[4],
                             int srcRange, const int table[4], int dstRange,
                             int brightness, int contrast, int saturation);
int sws_getColorspaceDetails(struct SwsContext *c, int **inv_table,
                             int *srcRange, int **table, int *dstRange,
                             int *brightness, int *contrast, int *saturation);
SwsVector *sws_allocVec(int length);
SwsVector *sws_getGaussianVec(double variance, double quality);
SwsVector *sws_getConstVec(double c, int length);
SwsVector *sws_getIdentityVec(void);
void sws_scaleVec(SwsVector *a, double scalar);
void sws_normalizeVec(SwsVector *a, double height);
void sws_convVec(SwsVector *a, SwsVector *b);
void sws_addVec(SwsVector *a, SwsVector *b);
void sws_subVec(SwsVector *a, SwsVector *b);
void sws_shiftVec(SwsVector *a, int shift);
SwsVector *sws_cloneVec(SwsVector *a);
void sws_printVec2(SwsVector *a, AVClass *log_ctx, int log_level);
void sws_freeVec(SwsVector *a);
SwsFilter *sws_getDefaultFilter(float lumaGBlur, float chromaGBlur,
                                float lumaSharpen, float chromaSharpen,
                                float chromaHShift, float chromaVShift,
                                int verbose);
void sws_freeFilter(SwsFilter *filter);
struct SwsContext *sws_getCachedContext(struct SwsContext *context,
                                        int srcW, int srcH, enum AVPixelFormat srcFormat,
                                        int dstW, int dstH, enum AVPixelFormat dstFormat,
                                        int flags, SwsFilter *srcFilter,
                                        SwsFilter *dstFilter, const double *param);
void sws_convertPalette8ToPacked32(const uint8_t *src, uint8_t *dst, int num_pixels, const uint8_t *palette);
void sws_convertPalette8ToPacked24(const uint8_t *src, uint8_t *dst, int num_pixels, const uint8_t *palette);
const AVClass *sws_get_class(void);
enum SwrDitherType {
    SWR_DITHER_NONE = 0,
    SWR_DITHER_RECTANGULAR,
    SWR_DITHER_TRIANGULAR,
    SWR_DITHER_TRIANGULAR_HIGHPASS,
    SWR_DITHER_NS = 64,
    SWR_DITHER_NS_LIPSHITZ,
    SWR_DITHER_NS_F_WEIGHTED,
    SWR_DITHER_NS_MODIFIED_E_WEIGHTED,
    SWR_DITHER_NS_IMPROVED_E_WEIGHTED,
    SWR_DITHER_NS_SHIBATA,
    SWR_DITHER_NS_LOW_SHIBATA,
    SWR_DITHER_NS_HIGH_SHIBATA,
    SWR_DITHER_NB,
};
enum SwrEngine {
    SWR_ENGINE_SWR,
    SWR_ENGINE_SOXR,
    SWR_ENGINE_NB,
};
enum SwrFilterType {
    SWR_FILTER_TYPE_CUBIC,
    SWR_FILTER_TYPE_BLACKMAN_NUTTALL,
    SWR_FILTER_TYPE_KAISER,
};
typedef struct SwrContext SwrContext;
const AVClass *swr_get_class(void);
struct SwrContext *swr_alloc(void);
int swr_init(struct SwrContext *s);
int swr_is_initialized(struct SwrContext *s);
struct SwrContext *swr_alloc_set_opts(struct SwrContext *s,
                                      int64_t out_ch_layout, enum AVSampleFormat out_sample_fmt, int out_sample_rate,
                                      int64_t in_ch_layout, enum AVSampleFormat in_sample_fmt, int in_sample_rate,
                                      int log_offset, void *log_ctx);
void swr_free(struct SwrContext **s);
int swr_convert(struct SwrContext *s, uint8_t **out, int out_count,
                                const uint8_t **in , int in_count);
int64_t swr_next_pts(struct SwrContext *s, int64_t pts);
int swr_set_compensation(struct SwrContext *s, int sample_delta, int compensation_distance);
int swr_set_channel_mapping(struct SwrContext *s, const int *channel_map);
int swr_set_matrix(struct SwrContext *s, const double *matrix, int stride);
int swr_drop_output(struct SwrContext *s, int count);
int swr_inject_silence(struct SwrContext *s, int count);
int64_t swr_get_delay(struct SwrContext *s, int64_t base);
unsigned swresample_version(void);
const char *swresample_configuration(void);
const char *swresample_license(void);
]]