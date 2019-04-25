local ffi = require("ffi")
local CLIB = assert(ffi.load("bgfx"))
ffi.cdef([[typedef enum bgfx_render_frame{BGFX_RENDER_FRAME_NO_CONTEXT=0,BGFX_RENDER_FRAME_RENDER=1,BGFX_RENDER_FRAME_TIMEOUT=2,BGFX_RENDER_FRAME_EXITING=3,BGFX_RENDER_FRAME_COUNT=4};
typedef enum bgfx_topology_sort{BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MIN=0,BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_AVG=1,BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MAX=2,BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MIN=3,BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_AVG=4,BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MAX=5,BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MIN=6,BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_AVG=7,BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MAX=8,BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MIN=9,BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_AVG=10,BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MAX=11,BGFX_TOPOLOGY_SORT_COUNT=12};
typedef enum bgfx_attrib_type{BGFX_ATTRIB_TYPE_UINT8=0,BGFX_ATTRIB_TYPE_UINT10=1,BGFX_ATTRIB_TYPE_INT16=2,BGFX_ATTRIB_TYPE_HALF=3,BGFX_ATTRIB_TYPE_FLOAT=4,BGFX_ATTRIB_TYPE_COUNT=5};
typedef enum bgfx_fatal{BGFX_FATAL_DEBUG_CHECK=0,BGFX_FATAL_INVALID_SHADER=1,BGFX_FATAL_UNABLE_TO_INITIALIZE=2,BGFX_FATAL_UNABLE_TO_CREATE_TEXTURE=3,BGFX_FATAL_DEVICE_LOST=4,BGFX_FATAL_COUNT=5};
typedef enum bgfx_backbuffer_ratio{BGFX_BACKBUFFER_RATIO_EQUAL=0,BGFX_BACKBUFFER_RATIO_HALF=1,BGFX_BACKBUFFER_RATIO_QUARTER=2,BGFX_BACKBUFFER_RATIO_EIGHTH=3,BGFX_BACKBUFFER_RATIO_SIXTEENTH=4,BGFX_BACKBUFFER_RATIO_DOUBLE=5,BGFX_BACKBUFFER_RATIO_COUNT=6};
typedef enum bgfx_topology_convert{BGFX_TOPOLOGY_CONVERT_TRI_LIST_FLIP_WINDING=0,BGFX_TOPOLOGY_CONVERT_TRI_LIST_TO_LINE_LIST=1,BGFX_TOPOLOGY_CONVERT_TRI_STRIP_TO_TRI_LIST=2,BGFX_TOPOLOGY_CONVERT_LINE_STRIP_TO_LINE_LIST=3,BGFX_TOPOLOGY_CONVERT_COUNT=4};
typedef enum bgfx_access{BGFX_ACCESS_READ=0,BGFX_ACCESS_WRITE=1,BGFX_ACCESS_READWRITE=2,BGFX_ACCESS_COUNT=3};
typedef enum bgfx_renderer_type{BGFX_RENDERER_TYPE_NOOP=0,BGFX_RENDERER_TYPE_DIRECT3D9=1,BGFX_RENDERER_TYPE_DIRECT3D11=2,BGFX_RENDERER_TYPE_DIRECT3D12=3,BGFX_RENDERER_TYPE_GNM=4,BGFX_RENDERER_TYPE_METAL=5,BGFX_RENDERER_TYPE_OPENGLES=6,BGFX_RENDERER_TYPE_OPENGL=7,BGFX_RENDERER_TYPE_VULKAN=8,BGFX_RENDERER_TYPE_COUNT=9};
typedef enum bgfx_texture_format{BGFX_TEXTURE_FORMAT_BC1=0,BGFX_TEXTURE_FORMAT_BC2=1,BGFX_TEXTURE_FORMAT_BC3=2,BGFX_TEXTURE_FORMAT_BC4=3,BGFX_TEXTURE_FORMAT_BC5=4,BGFX_TEXTURE_FORMAT_BC6H=5,BGFX_TEXTURE_FORMAT_BC7=6,BGFX_TEXTURE_FORMAT_ETC1=7,BGFX_TEXTURE_FORMAT_ETC2=8,BGFX_TEXTURE_FORMAT_ETC2A=9,BGFX_TEXTURE_FORMAT_ETC2A1=10,BGFX_TEXTURE_FORMAT_PTC12=11,BGFX_TEXTURE_FORMAT_PTC14=12,BGFX_TEXTURE_FORMAT_PTC12A=13,BGFX_TEXTURE_FORMAT_PTC14A=14,BGFX_TEXTURE_FORMAT_PTC22=15,BGFX_TEXTURE_FORMAT_PTC24=16,BGFX_TEXTURE_FORMAT_UNKNOWN=17,BGFX_TEXTURE_FORMAT_R1=18,BGFX_TEXTURE_FORMAT_A8=19,BGFX_TEXTURE_FORMAT_R8=20,BGFX_TEXTURE_FORMAT_R8I=21,BGFX_TEXTURE_FORMAT_R8U=22,BGFX_TEXTURE_FORMAT_R8S=23,BGFX_TEXTURE_FORMAT_R16=24,BGFX_TEXTURE_FORMAT_R16I=25,BGFX_TEXTURE_FORMAT_R16U=26,BGFX_TEXTURE_FORMAT_R16F=27,BGFX_TEXTURE_FORMAT_R16S=28,BGFX_TEXTURE_FORMAT_R32I=29,BGFX_TEXTURE_FORMAT_R32U=30,BGFX_TEXTURE_FORMAT_R32F=31,BGFX_TEXTURE_FORMAT_RG8=32,BGFX_TEXTURE_FORMAT_RG8I=33,BGFX_TEXTURE_FORMAT_RG8U=34,BGFX_TEXTURE_FORMAT_RG8S=35,BGFX_TEXTURE_FORMAT_RG16=36,BGFX_TEXTURE_FORMAT_RG16I=37,BGFX_TEXTURE_FORMAT_RG16U=38,BGFX_TEXTURE_FORMAT_RG16F=39,BGFX_TEXTURE_FORMAT_RG16S=40,BGFX_TEXTURE_FORMAT_RG32I=41,BGFX_TEXTURE_FORMAT_RG32U=42,BGFX_TEXTURE_FORMAT_RG32F=43,BGFX_TEXTURE_FORMAT_RGB8=44,BGFX_TEXTURE_FORMAT_RGB8I=45,BGFX_TEXTURE_FORMAT_RGB8U=46,BGFX_TEXTURE_FORMAT_RGB8S=47,BGFX_TEXTURE_FORMAT_RGB9E5F=48,BGFX_TEXTURE_FORMAT_BGRA8=49,BGFX_TEXTURE_FORMAT_RGBA8=50,BGFX_TEXTURE_FORMAT_RGBA8I=51,BGFX_TEXTURE_FORMAT_RGBA8U=52,BGFX_TEXTURE_FORMAT_RGBA8S=53,BGFX_TEXTURE_FORMAT_RGBA16=54,BGFX_TEXTURE_FORMAT_RGBA16I=55,BGFX_TEXTURE_FORMAT_RGBA16U=56,BGFX_TEXTURE_FORMAT_RGBA16F=57,BGFX_TEXTURE_FORMAT_RGBA16S=58,BGFX_TEXTURE_FORMAT_RGBA32I=59,BGFX_TEXTURE_FORMAT_RGBA32U=60,BGFX_TEXTURE_FORMAT_RGBA32F=61,BGFX_TEXTURE_FORMAT_R5G6B5=62,BGFX_TEXTURE_FORMAT_RGBA4=63,BGFX_TEXTURE_FORMAT_RGB5A1=64,BGFX_TEXTURE_FORMAT_RGB10A2=65,BGFX_TEXTURE_FORMAT_RG11B10F=66,BGFX_TEXTURE_FORMAT_UNKNOWN_DEPTH=67,BGFX_TEXTURE_FORMAT_D16=68,BGFX_TEXTURE_FORMAT_D24=69,BGFX_TEXTURE_FORMAT_D24S8=70,BGFX_TEXTURE_FORMAT_D32=71,BGFX_TEXTURE_FORMAT_D16F=72,BGFX_TEXTURE_FORMAT_D24F=73,BGFX_TEXTURE_FORMAT_D32F=74,BGFX_TEXTURE_FORMAT_D0S8=75,BGFX_TEXTURE_FORMAT_COUNT=76};
typedef enum bgfx_attrib{BGFX_ATTRIB_POSITION=0,BGFX_ATTRIB_NORMAL=1,BGFX_ATTRIB_TANGENT=2,BGFX_ATTRIB_BITANGENT=3,BGFX_ATTRIB_COLOR0=4,BGFX_ATTRIB_COLOR1=5,BGFX_ATTRIB_COLOR2=6,BGFX_ATTRIB_COLOR3=7,BGFX_ATTRIB_INDICES=8,BGFX_ATTRIB_WEIGHT=9,BGFX_ATTRIB_TEXCOORD0=10,BGFX_ATTRIB_TEXCOORD1=11,BGFX_ATTRIB_TEXCOORD2=12,BGFX_ATTRIB_TEXCOORD3=13,BGFX_ATTRIB_TEXCOORD4=14,BGFX_ATTRIB_TEXCOORD5=15,BGFX_ATTRIB_TEXCOORD6=16,BGFX_ATTRIB_TEXCOORD7=17,BGFX_ATTRIB_COUNT=18};
typedef enum bgfx_view_mode{BGFX_VIEW_MODE_DEFAULT=0,BGFX_VIEW_MODE_SEQUENTIAL=1,BGFX_VIEW_MODE_DEPTH_ASCENDING=2,BGFX_VIEW_MODE_DEPTH_DESCENDING=3,BGFX_VIEW_MODE_CCOUNT=4};
typedef enum bgfx_uniform_type{BGFX_UNIFORM_TYPE_INT1=0,BGFX_UNIFORM_TYPE_END=1,BGFX_UNIFORM_TYPE_VEC4=2,BGFX_UNIFORM_TYPE_MAT3=3,BGFX_UNIFORM_TYPE_MAT4=4,BGFX_UNIFORM_TYPE_COUNT=5};
typedef enum bgfx_occlusion_query_result{BGFX_OCCLUSION_QUERY_RESULT_INVISIBLE=0,BGFX_OCCLUSION_QUERY_RESULT_VISIBLE=1,BGFX_OCCLUSION_QUERY_RESULT_NORESULT=2,BGFX_OCCLUSION_QUERY_RESULT_COUNT=3};
struct bgfx_dynamic_index_buffer_handle {unsigned short idx;};
struct bgfx_dynamic_vertex_buffer_handle {unsigned short idx;};
struct bgfx_frame_buffer_handle {unsigned short idx;};
struct bgfx_index_buffer_handle {unsigned short idx;};
struct bgfx_indirect_buffer_handle {unsigned short idx;};
struct bgfx_occlusion_query_handle {unsigned short idx;};
struct bgfx_program_handle {unsigned short idx;};
struct bgfx_shader_handle {unsigned short idx;};
struct bgfx_texture_handle {unsigned short idx;};
struct bgfx_uniform_handle {unsigned short idx;};
struct bgfx_vertex_buffer_handle {unsigned short idx;};
struct bgfx_vertex_decl_handle {unsigned short idx;};
struct bgfx_memory {unsigned char*data;unsigned int size;};
struct bgfx_transform {float*data;unsigned short num;};
struct bgfx_hmd_eye {float rotation[4];float translation[3];float fov[4];float viewOffset[3];float projection[16];float pixelsPerTanAngle[2];};
struct bgfx_hmd {struct bgfx_hmd_eye eye[2];unsigned short width;unsigned short height;unsigned int deviceWidth;unsigned int deviceHeight;unsigned char flags;};
struct bgfx_view_stats {char name[256];unsigned short view;signed long cpuTimeElapsed;signed long gpuTimeElapsed;};
struct bgfx_encoder_stats {signed long cpuTimeBegin;signed long cpuTimeEnd;};
struct bgfx_stats {signed long cpuTimeFrame;signed long cpuTimeBegin;signed long cpuTimeEnd;signed long cpuTimerFreq;signed long gpuTimeBegin;signed long gpuTimeEnd;signed long gpuTimerFreq;signed long waitRender;signed long waitSubmit;unsigned int numDraw;unsigned int numCompute;unsigned int maxGpuLatency;unsigned short numDynamicIndexBuffers;unsigned short numDynamicVertexBuffers;unsigned short numFrameBuffers;unsigned short numIndexBuffers;unsigned short numOcclusionQueries;unsigned short numPrograms;unsigned short numShaders;unsigned short numTextures;unsigned short numUniforms;unsigned short numVertexBuffers;unsigned short numVertexDecls;signed long gpuMemoryMax;signed long gpuMemoryUsed;unsigned short width;unsigned short height;unsigned short textWidth;unsigned short textHeight;unsigned short numViews;struct bgfx_view_stats*viewStats;unsigned char numEncoders;struct bgfx_encoder_stats*encoderStats;};
struct bgfx_encoder {};
struct bgfx_vertex_decl {unsigned int hash;unsigned short stride;unsigned short offset[BGFX_ATTRIB_COUNT];unsigned short attributes[BGFX_ATTRIB_COUNT];};
struct bgfx_transient_index_buffer {unsigned char*data;unsigned int size;struct bgfx_index_buffer_handle handle;unsigned int startIndex;};
struct bgfx_transient_vertex_buffer {unsigned char*data;unsigned int size;unsigned int startVertex;unsigned short stride;struct bgfx_vertex_buffer_handle handle;struct bgfx_vertex_decl_handle decl;};
struct bgfx_instance_data_buffer {unsigned char*data;unsigned int size;unsigned int offset;unsigned int num;unsigned short stride;struct bgfx_vertex_buffer_handle handle;};
struct bgfx_texture_info {enum bgfx_texture_format format;unsigned int storageSize;unsigned short width;unsigned short height;unsigned short depth;unsigned short numLayers;unsigned char numMips;unsigned char bitsPerPixel;_Bool cubeMap;};
struct bgfx_uniform_info {char name[256];enum bgfx_uniform_type type;unsigned short num;};
struct bgfx_attachment {struct bgfx_texture_handle handle;unsigned short mip;unsigned short layer;};
struct bgfx_caps_gpu {unsigned short vendorId;unsigned short deviceId;};
struct bgfx_caps_limits {unsigned int maxDrawCalls;unsigned int maxBlits;unsigned int maxTextureSize;unsigned int maxTextureLayers;unsigned int maxViews;unsigned int maxFrameBuffers;unsigned int maxFBAttachments;unsigned int maxPrograms;unsigned int maxShaders;unsigned int maxTextures;unsigned int maxTextureSamplers;unsigned int maxVertexDecls;unsigned int maxVertexStreams;unsigned int maxIndexBuffers;unsigned int maxVertexBuffers;unsigned int maxDynamicIndexBuffers;unsigned int maxDynamicVertexBuffers;unsigned int maxUniforms;unsigned int maxOcclusionQueries;unsigned int maxEncoders;};
struct bgfx_caps {enum bgfx_renderer_type rendererType;unsigned long supported;unsigned short vendorId;unsigned short deviceId;_Bool homogeneousDepth;_Bool originBottomLeft;unsigned char numGPUs;struct bgfx_caps_gpu gpu[4];struct bgfx_caps_limits limits;unsigned short formats[BGFX_TEXTURE_FORMAT_COUNT];};
struct bgfx_callback_interface {const struct bgfx_callback_vtbl*vtbl;};
struct bgfx_callback_vtbl {void(*fatal)(struct bgfx_callback_interface*,enum bgfx_fatal,const char*);void(*trace_vargs)(struct bgfx_callback_interface*,const char*,unsigned short,const char*,__builtin_va_list);void(*profiler_begin)(struct bgfx_callback_interface*,const char*,unsigned int,const char*,unsigned short);void(*profiler_begin_literal)(struct bgfx_callback_interface*,const char*,unsigned int,const char*,unsigned short);void(*profiler_end)(struct bgfx_callback_interface*);unsigned int(*cache_read_size)(struct bgfx_callback_interface*,unsigned long);_Bool(*cache_read)(struct bgfx_callback_interface*,unsigned long,void*,unsigned int);void(*cache_write)(struct bgfx_callback_interface*,unsigned long,const void*,unsigned int);void(*screen_shot)(struct bgfx_callback_interface*,const char*,unsigned int,unsigned int,unsigned int,const void*,unsigned int,_Bool);void(*capture_begin)(struct bgfx_callback_interface*,unsigned int,unsigned int,unsigned int,enum bgfx_texture_format,_Bool);void(*capture_end)(struct bgfx_callback_interface*);void(*capture_frame)(struct bgfx_callback_interface*,const void*,unsigned int);};
struct bgfx_allocator_interface {const struct bgfx_allocator_vtbl*vtbl;};
struct bgfx_allocator_vtbl {void*(*realloc)(struct bgfx_allocator_interface*,void*,unsigned long,unsigned long,const char*,unsigned int);};
struct bgfx_platform_data {void*ndt;void*nwh;void*context;void*backBuffer;void*backBufferDS;void*session;};
struct bgfx_internal_datauint8_t {const struct bgfx_caps*caps;void*context;};
void(bgfx_update_dynamic_vertex_buffer)(struct bgfx_dynamic_vertex_buffer_handle,unsigned int,const struct bgfx_memory*);
void(bgfx_set_instance_data_from_vertex_buffer)(struct bgfx_vertex_buffer_handle,unsigned int,unsigned int);
struct bgfx_dynamic_vertex_buffer_handle(bgfx_create_dynamic_vertex_buffer)(unsigned int,const struct bgfx_vertex_decl*,unsigned short);
struct bgfx_occlusion_query_handle(bgfx_create_occlusion_query)();
_Bool(bgfx_is_texture_valid)(unsigned short,_Bool,unsigned short,enum bgfx_texture_format,unsigned int);
void(bgfx_dbg_text_clear)(unsigned char,_Bool);
void(bgfx_set_platform_data)(const struct bgfx_platform_data*);
void(bgfx_set_view_rect_auto)(unsigned short,unsigned short,unsigned short,enum bgfx_backbuffer_ratio);
void(bgfx_set_palette_color)(unsigned char,const float);
void(bgfx_alloc_instance_data_buffer)(struct bgfx_instance_data_buffer*,unsigned int,unsigned short);
void(bgfx_blit)(unsigned short,struct bgfx_texture_handle,unsigned char,unsigned short,unsigned short,unsigned short,struct bgfx_texture_handle,unsigned char,unsigned short,unsigned short,unsigned short,unsigned short,unsigned short,unsigned short);
struct bgfx_texture_handle(bgfx_create_texture_2d)(unsigned short,unsigned short,_Bool,unsigned short,enum bgfx_texture_format,unsigned int,const struct bgfx_memory*);
unsigned int(bgfx_set_transform)(const void*,unsigned short);
const struct bgfx_memory*(bgfx_make_ref_release)(const void*,unsigned int,void(*_releaseFn)(void*,void*),void*);
void(bgfx_destroy_index_buffer)(struct bgfx_index_buffer_handle);
void(bgfx_encoder_set_transient_index_buffer)(struct bgfx_encoder*,const struct bgfx_transient_index_buffer*,unsigned int,unsigned int);
struct bgfx_texture_handle(bgfx_create_texture_3d)(unsigned short,unsigned short,unsigned short,_Bool,enum bgfx_texture_format,unsigned int,const struct bgfx_memory*);
void(bgfx_dbg_text_vprintf)(unsigned short,unsigned short,unsigned char,const char*,__builtin_va_list);
enum bgfx_occlusion_query_result(bgfx_get_result)(struct bgfx_occlusion_query_handle,signed int*);
void(bgfx_encoder_set_instance_data_buffer)(struct bgfx_encoder*,const struct bgfx_instance_data_buffer*,unsigned int,unsigned int);
void(bgfx_set_dynamic_vertex_buffer)(unsigned char,struct bgfx_dynamic_vertex_buffer_handle,unsigned int,unsigned int);
void(bgfx_alloc_transient_vertex_buffer)(struct bgfx_transient_vertex_buffer*,unsigned int,const struct bgfx_vertex_decl*);
struct bgfx_program_handle(bgfx_create_program)(struct bgfx_shader_handle,struct bgfx_shader_handle,_Bool);
const struct bgfx_internal_datauint8_t*(bgfx_get_internal_data)();
void(bgfx_set_state)(unsigned long,unsigned int);
void(bgfx_vertex_decl_add)(struct bgfx_vertex_decl*,enum bgfx_attrib,unsigned char,enum bgfx_attrib_type,_Bool,_Bool);
struct bgfx_frame_buffer_handle(bgfx_create_frame_buffer_from_nwh)(void*,unsigned short,unsigned short,enum bgfx_texture_format);
void(bgfx_reset)(unsigned int,unsigned int,unsigned int);
unsigned int(bgfx_frame)(_Bool);
void(bgfx_encoder_set_compute_vertex_buffer)(struct bgfx_encoder*,unsigned char,struct bgfx_vertex_buffer_handle,enum bgfx_access);
void(bgfx_destroy_dynamic_vertex_buffer)(struct bgfx_dynamic_vertex_buffer_handle);
void(bgfx_reset_view)(unsigned short);
void(bgfx_encoder_set_uniform)(struct bgfx_encoder*,struct bgfx_uniform_handle,const void*,unsigned short);
void(bgfx_vertex_unpack)(float,enum bgfx_attrib,const struct bgfx_vertex_decl*,const void*,unsigned int);
void(bgfx_set_vertex_buffer)(unsigned char,struct bgfx_vertex_buffer_handle,unsigned int,unsigned int);
void(bgfx_set_view_order)(unsigned short,unsigned short,const unsigned short*);
void(bgfx_set_marker)(const char*);
void(bgfx_set_texture)(unsigned char,struct bgfx_uniform_handle,struct bgfx_texture_handle,unsigned int);
_Bool(bgfx_alloc_transient_buffers)(struct bgfx_transient_vertex_buffer*,const struct bgfx_vertex_decl*,unsigned int,struct bgfx_transient_index_buffer*,unsigned int);
void(bgfx_calc_texture_size)(struct bgfx_texture_info*,unsigned short,unsigned short,unsigned short,_Bool,_Bool,unsigned short,enum bgfx_texture_format);
void(bgfx_vertex_convert)(const struct bgfx_vertex_decl*,void*,const struct bgfx_vertex_decl*,const void*,unsigned int);
void(bgfx_destroy_texture)(struct bgfx_texture_handle);
void(bgfx_request_screen_shot)(struct bgfx_frame_buffer_handle,const char*);
void(bgfx_dispatch)(unsigned short,struct bgfx_program_handle,unsigned int,unsigned int,unsigned int,unsigned char);
void(bgfx_encoder_set_index_buffer)(struct bgfx_encoder*,struct bgfx_index_buffer_handle,unsigned int,unsigned int);
void(bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer)(struct bgfx_encoder*,struct bgfx_dynamic_vertex_buffer_handle,unsigned int,unsigned int);
void(bgfx_encoder_set_transient_vertex_buffer)(struct bgfx_encoder*,unsigned char,const struct bgfx_transient_vertex_buffer*,unsigned int,unsigned int);
struct bgfx_dynamic_index_buffer_handle(bgfx_create_dynamic_index_buffer_mem)(const struct bgfx_memory*,unsigned short);
void(bgfx_encoder_set_vertex_buffer)(struct bgfx_encoder*,unsigned char,struct bgfx_vertex_buffer_handle,unsigned int,unsigned int);
void(bgfx_encoder_set_scissor_cached)(struct bgfx_encoder*,unsigned short);
void(bgfx_set_view_name)(unsigned short,const char*);
void(bgfx_encoder_submit_occlusion_query)(struct bgfx_encoder*,unsigned short,struct bgfx_program_handle,struct bgfx_occlusion_query_handle,signed int,_Bool);
void(bgfx_set_view_clear_mrt)(unsigned short,unsigned short,float,unsigned char,unsigned char,unsigned char,unsigned char,unsigned char,unsigned char,unsigned char,unsigned char,unsigned char);
void(bgfx_set_condition)(struct bgfx_occlusion_query_handle,_Bool);
unsigned char(bgfx_get_supported_renderers)(unsigned char,enum bgfx_renderer_type*);
void(bgfx_alloc_transient_index_buffer)(struct bgfx_transient_index_buffer*,unsigned int);
void(bgfx_destroy_frame_buffer)(struct bgfx_frame_buffer_handle);
const struct bgfx_caps*(bgfx_get_caps)();
struct bgfx_texture_handle(bgfx_create_texture_cube)(unsigned short,_Bool,unsigned short,enum bgfx_texture_format,unsigned int,const struct bgfx_memory*);
unsigned short(bgfx_set_scissor)(unsigned short,unsigned short,unsigned short,unsigned short);
struct bgfx_shader_handle(bgfx_create_shader)(const struct bgfx_memory*);
void(bgfx_set_view_frame_buffer)(unsigned short,struct bgfx_frame_buffer_handle);
void(bgfx_update_texture_cube)(struct bgfx_texture_handle,unsigned short,unsigned char,unsigned char,unsigned short,unsigned short,unsigned short,unsigned short,const struct bgfx_memory*,unsigned short);
struct bgfx_indirect_buffer_handle(bgfx_create_indirect_buffer)(unsigned int);
void(bgfx_set_compute_indirect_buffer)(unsigned char,struct bgfx_indirect_buffer_handle,enum bgfx_access);
_Bool(bgfx_init)(enum bgfx_renderer_type,unsigned short,unsigned short,struct bgfx_callback_interface*,struct bgfx_allocator_interface*);
struct bgfx_uniform_handle(bgfx_create_uniform)(const char*,enum bgfx_uniform_type,unsigned short);
struct bgfx_dynamic_vertex_buffer_handle(bgfx_create_dynamic_vertex_buffer_mem)(const struct bgfx_memory*,const struct bgfx_vertex_decl*,unsigned short);
void(bgfx_set_compute_dynamic_vertex_buffer)(unsigned char,struct bgfx_dynamic_vertex_buffer_handle,enum bgfx_access);
unsigned short(bgfx_encoder_set_scissor)(struct bgfx_encoder*,unsigned short,unsigned short,unsigned short,unsigned short);
void(bgfx_encoder_set_compute_dynamic_index_buffer)(struct bgfx_encoder*,unsigned char,struct bgfx_dynamic_index_buffer_handle,enum bgfx_access);
void(bgfx_encoder_set_instance_data_from_vertex_buffer)(struct bgfx_encoder*,struct bgfx_vertex_buffer_handle,unsigned int,unsigned int);
void(bgfx_encoder_set_condition)(struct bgfx_encoder*,struct bgfx_occlusion_query_handle,_Bool);
void(bgfx_topology_sort_tri_list)(enum bgfx_topology_sort,void*,unsigned int,const float,const float,const void*,unsigned int,const void*,unsigned int,_Bool);
struct bgfx_frame_buffer_handle(bgfx_create_frame_buffer_from_attachment)(unsigned char,const struct bgfx_attachment*,_Bool);
const struct bgfx_memory*(bgfx_alloc)(unsigned int);
struct bgfx_program_handle(bgfx_create_compute_program)(struct bgfx_shader_handle,_Bool);
void(bgfx_update_texture_2d)(struct bgfx_texture_handle,unsigned short,unsigned char,unsigned short,unsigned short,unsigned short,unsigned short,const struct bgfx_memory*,unsigned short);
void(bgfx_update_texture_3d)(struct bgfx_texture_handle,unsigned char,unsigned short,unsigned short,unsigned short,unsigned short,unsigned short,unsigned short,const struct bgfx_memory*);
void(bgfx_vertex_decl_skip)(struct bgfx_vertex_decl*,unsigned char);
unsigned int(bgfx_encoder_set_transform)(struct bgfx_encoder*,const void*,unsigned short);
void(bgfx_vertex_decl_end)(struct bgfx_vertex_decl*);
unsigned int(bgfx_get_avail_transient_vertex_buffer)(unsigned int,const struct bgfx_vertex_decl*);
void(bgfx_dbg_text_image)(unsigned short,unsigned short,unsigned short,unsigned short,const void*,unsigned short);
void(bgfx_set_compute_vertex_buffer)(unsigned char,struct bgfx_vertex_buffer_handle,enum bgfx_access);
void(bgfx_encoder_submit)(struct bgfx_encoder*,unsigned short,struct bgfx_program_handle,signed int,_Bool);
unsigned short(bgfx_get_shader_uniforms)(struct bgfx_shader_handle,struct bgfx_uniform_handle*,unsigned short);
void(bgfx_set_index_buffer)(struct bgfx_index_buffer_handle,unsigned int,unsigned int);
void(bgfx_destroy_indirect_buffer)(struct bgfx_indirect_buffer_handle);
void(bgfx_dispatch_indirect)(unsigned short,struct bgfx_program_handle,struct bgfx_indirect_buffer_handle,unsigned short,unsigned short,unsigned char);
void(bgfx_encoder_set_transform_cached)(struct bgfx_encoder*,unsigned int,unsigned short);
void(bgfx_encoder_discard)(struct bgfx_encoder*);
void(bgfx_set_transient_index_buffer)(const struct bgfx_transient_index_buffer*,unsigned int,unsigned int);
void(bgfx_set_scissor_cached)(unsigned short);
void(bgfx_encoder_set_compute_index_buffer)(struct bgfx_encoder*,unsigned char,struct bgfx_index_buffer_handle,enum bgfx_access);
struct bgfx_frame_buffer_handle(bgfx_create_frame_buffer_from_handles)(unsigned char,const struct bgfx_texture_handle*,_Bool);
void(bgfx_submit)(unsigned short,struct bgfx_program_handle,signed int,_Bool);
void(bgfx_destroy_program)(struct bgfx_program_handle);
void(bgfx_encoder_set_dynamic_index_buffer)(struct bgfx_encoder*,struct bgfx_dynamic_index_buffer_handle,unsigned int,unsigned int);
void(bgfx_destroy_vertex_buffer)(struct bgfx_vertex_buffer_handle);
void(bgfx_touch)(unsigned short);
unsigned long(bgfx_override_internal_texture)(struct bgfx_texture_handle,unsigned short,unsigned short,unsigned char,enum bgfx_texture_format,unsigned int);
void(bgfx_set_image)(unsigned char,struct bgfx_texture_handle,unsigned char,enum bgfx_access,enum bgfx_texture_format);
struct bgfx_texture_handle(bgfx_get_texture)(struct bgfx_frame_buffer_handle,unsigned char);
enum bgfx_render_frame(bgfx_render_frame)(signed int);
void(bgfx_encoder_set_state)(struct bgfx_encoder*,unsigned long,unsigned int);
void(bgfx_encoder_blit)(struct bgfx_encoder*,unsigned short,struct bgfx_texture_handle,unsigned char,unsigned short,unsigned short,unsigned short,struct bgfx_texture_handle,unsigned char,unsigned short,unsigned short,unsigned short,unsigned short,unsigned short,unsigned short);
void(bgfx_encoder_dispatch_indirect)(struct bgfx_encoder*,unsigned short,struct bgfx_program_handle,struct bgfx_indirect_buffer_handle,unsigned short,unsigned short,unsigned char);
void(bgfx_encoder_dispatch)(struct bgfx_encoder*,unsigned short,struct bgfx_program_handle,unsigned int,unsigned int,unsigned int,unsigned char);
void(bgfx_encoder_set_compute_indirect_buffer)(struct bgfx_encoder*,unsigned char,struct bgfx_indirect_buffer_handle,enum bgfx_access);
void(bgfx_encoder_set_compute_dynamic_vertex_buffer)(struct bgfx_encoder*,unsigned char,struct bgfx_dynamic_vertex_buffer_handle,enum bgfx_access);
void(bgfx_encoder_set_image)(struct bgfx_encoder*,unsigned char,struct bgfx_texture_handle,unsigned char,enum bgfx_access,enum bgfx_texture_format);
void(bgfx_encoder_submit_indirect)(struct bgfx_encoder*,unsigned short,struct bgfx_program_handle,struct bgfx_indirect_buffer_handle,unsigned short,unsigned short,signed int,_Bool);
struct bgfx_texture_handle(bgfx_create_texture_2d_scaled)(enum bgfx_backbuffer_ratio,_Bool,unsigned short,enum bgfx_texture_format,unsigned int);
unsigned int(bgfx_topology_convert)(enum bgfx_topology_convert,void*,unsigned int,const void*,unsigned int,_Bool);
unsigned short(bgfx_weld_vertices)(unsigned short*,const struct bgfx_vertex_decl*,const void*,unsigned short,float);
void(bgfx_destroy_uniform)(struct bgfx_uniform_handle);
void(bgfx_shutdown)();
void(bgfx_vertex_decl_begin)(struct bgfx_vertex_decl*,enum bgfx_renderer_type);
void(bgfx_set_view_scissor)(unsigned short,unsigned short,unsigned short,unsigned short,unsigned short);
void(bgfx_submit_indirect)(unsigned short,struct bgfx_program_handle,struct bgfx_indirect_buffer_handle,unsigned short,unsigned short,signed int,_Bool);
unsigned int(bgfx_alloc_transform)(struct bgfx_transform*,unsigned short);
void(bgfx_vertex_pack)(const float,_Bool,enum bgfx_attrib,const struct bgfx_vertex_decl*,void*,unsigned int);
void(bgfx_set_stencil)(unsigned int,unsigned int);
struct bgfx_texture_handle(bgfx_create_texture)(const struct bgfx_memory*,unsigned int,unsigned char,struct bgfx_texture_info*);
void(bgfx_encoder_touch)(struct bgfx_encoder*,unsigned short);
void(bgfx_set_view_transform_stereo)(unsigned short,const void*,const void*,unsigned char,const void*);
struct bgfx_frame_buffer_handle(bgfx_create_frame_buffer_scaled)(enum bgfx_backbuffer_ratio,enum bgfx_texture_format,unsigned int);
void(bgfx_submit_occlusion_query)(unsigned short,struct bgfx_program_handle,struct bgfx_occlusion_query_handle,signed int,_Bool);
const struct bgfx_memory*(bgfx_copy)(const void*,unsigned int);
enum bgfx_renderer_type(bgfx_get_renderer_type)();
const struct bgfx_hmd*(bgfx_get_hmd)();
void(bgfx_encoder_set_texture)(struct bgfx_encoder*,unsigned char,struct bgfx_uniform_handle,struct bgfx_texture_handle,unsigned int);
void(bgfx_set_uniform)(struct bgfx_uniform_handle,const void*,unsigned short);
void(bgfx_destroy_dynamic_index_buffer)(struct bgfx_dynamic_index_buffer_handle);
const struct bgfx_stats*(bgfx_get_stats)();
struct bgfx_index_buffer_handle(bgfx_create_index_buffer)(const struct bgfx_memory*,unsigned short);
void(bgfx_set_debug)(unsigned int);
const char*(bgfx_get_renderer_name)(enum bgfx_renderer_type);
void(bgfx_set_shader_name)(struct bgfx_shader_handle,const char*);
void(bgfx_set_texture_name)(struct bgfx_texture_handle,const char*);
const struct bgfx_memory*(bgfx_make_ref)(const void*,unsigned int);
void(bgfx_set_instance_data_buffer)(const struct bgfx_instance_data_buffer*,unsigned int,unsigned int);
unsigned int(bgfx_get_avail_instance_data_buffer)(unsigned int,unsigned short);
void(bgfx_destroy_shader)(struct bgfx_shader_handle);
void(bgfx_get_uniform_info)(struct bgfx_uniform_handle,struct bgfx_uniform_info*);
unsigned int(bgfx_read_texture)(struct bgfx_texture_handle,void*,unsigned char);
struct bgfx_vertex_buffer_handle(bgfx_create_vertex_buffer)(const struct bgfx_memory*,const struct bgfx_vertex_decl*,unsigned short);
struct bgfx_frame_buffer_handle(bgfx_create_frame_buffer)(unsigned short,unsigned short,enum bgfx_texture_format,unsigned int);
unsigned int(bgfx_encoder_alloc_transform)(struct bgfx_encoder*,struct bgfx_transform*,unsigned short);
void(bgfx_set_view_mode)(unsigned short,enum bgfx_view_mode);
unsigned long(bgfx_override_internal_texture_ptr)(struct bgfx_texture_handle,unsigned long);
void(bgfx_destroy_occlusion_query)(struct bgfx_occlusion_query_handle);
void(bgfx_set_view_rect)(unsigned short,unsigned short,unsigned short,unsigned short,unsigned short);
void(bgfx_set_view_transform)(unsigned short,const void*,const void*);
unsigned int(bgfx_get_avail_transient_index_buffer)(unsigned int);
void(bgfx_update_dynamic_index_buffer)(struct bgfx_dynamic_index_buffer_handle,unsigned int,const struct bgfx_memory*);
void(bgfx_set_instance_data_from_dynamic_vertex_buffer)(struct bgfx_dynamic_vertex_buffer_handle,unsigned int,unsigned int);
struct bgfx_dynamic_index_buffer_handle(bgfx_create_dynamic_index_buffer)(unsigned int,unsigned short);
void(bgfx_set_transform_cached)(unsigned int,unsigned short);
void(bgfx_set_dynamic_index_buffer)(struct bgfx_dynamic_index_buffer_handle,unsigned int,unsigned int);
void(bgfx_set_transient_vertex_buffer)(unsigned char,const struct bgfx_transient_vertex_buffer*,unsigned int,unsigned int);
void(bgfx_dbg_text_printf)(unsigned short,unsigned short,unsigned char,const char*,...);
void(bgfx_set_view_clear)(unsigned short,unsigned short,unsigned int,float,unsigned char);
void(bgfx_set_compute_index_buffer)(unsigned char,struct bgfx_index_buffer_handle,enum bgfx_access);
void(bgfx_set_compute_dynamic_index_buffer)(unsigned char,struct bgfx_dynamic_index_buffer_handle,enum bgfx_access);
void(bgfx_discard)();
void(bgfx_encoder_set_marker)(struct bgfx_encoder*,const char*);
void(bgfx_encoder_set_stencil)(struct bgfx_encoder*,unsigned int,unsigned int);
void(bgfx_encoder_set_dynamic_vertex_buffer)(struct bgfx_encoder*,unsigned char,struct bgfx_dynamic_vertex_buffer_handle,unsigned int,unsigned int);
]])
local library = {}
library = {
	UpdateDynamicVertexBuffer = CLIB.bgfx_update_dynamic_vertex_buffer,
	SetInstanceDataFromVertexBuffer = CLIB.bgfx_set_instance_data_from_vertex_buffer,
	CreateDynamicVertexBuffer = CLIB.bgfx_create_dynamic_vertex_buffer,
	CreateOcclusionQuery = CLIB.bgfx_create_occlusion_query,
	IsTextureValid = CLIB.bgfx_is_texture_valid,
	DbgTextClear = CLIB.bgfx_dbg_text_clear,
	SetPlatformData = CLIB.bgfx_set_platform_data,
	SetViewRectAuto = CLIB.bgfx_set_view_rect_auto,
	SetPaletteColor = CLIB.bgfx_set_palette_color,
	AllocInstanceDataBuffer = CLIB.bgfx_alloc_instance_data_buffer,
	Blit = CLIB.bgfx_blit,
	CreateTexture_2d = CLIB.bgfx_create_texture_2d,
	SetTransform = CLIB.bgfx_set_transform,
	MakeRefRelease = CLIB.bgfx_make_ref_release,
	DestroyIndexBuffer = CLIB.bgfx_destroy_index_buffer,
	EncoderSetTransientIndexBuffer = CLIB.bgfx_encoder_set_transient_index_buffer,
	CreateTexture_3d = CLIB.bgfx_create_texture_3d,
	DbgTextVprintf = CLIB.bgfx_dbg_text_vprintf,
	GetResult = CLIB.bgfx_get_result,
	EncoderSetInstanceDataBuffer = CLIB.bgfx_encoder_set_instance_data_buffer,
	SetDynamicVertexBuffer = CLIB.bgfx_set_dynamic_vertex_buffer,
	AllocTransientVertexBuffer = CLIB.bgfx_alloc_transient_vertex_buffer,
	CreateProgram = CLIB.bgfx_create_program,
	GetInternalData = CLIB.bgfx_get_internal_data,
	SetState = CLIB.bgfx_set_state,
	VertexDeclAdd = CLIB.bgfx_vertex_decl_add,
	CreateFrameBufferFromNwh = CLIB.bgfx_create_frame_buffer_from_nwh,
	Reset = CLIB.bgfx_reset,
	Frame = CLIB.bgfx_frame,
	EncoderSetComputeVertexBuffer = CLIB.bgfx_encoder_set_compute_vertex_buffer,
	DestroyDynamicVertexBuffer = CLIB.bgfx_destroy_dynamic_vertex_buffer,
	ResetView = CLIB.bgfx_reset_view,
	EncoderSetUniform = CLIB.bgfx_encoder_set_uniform,
	VertexUnpack = CLIB.bgfx_vertex_unpack,
	SetVertexBuffer = CLIB.bgfx_set_vertex_buffer,
	SetViewOrder = CLIB.bgfx_set_view_order,
	SetMarker = CLIB.bgfx_set_marker,
	SetTexture = CLIB.bgfx_set_texture,
	AllocTransientBuffers = CLIB.bgfx_alloc_transient_buffers,
	CalcTextureSize = CLIB.bgfx_calc_texture_size,
	VertexConvert = CLIB.bgfx_vertex_convert,
	DestroyTexture = CLIB.bgfx_destroy_texture,
	RequestScreenShot = CLIB.bgfx_request_screen_shot,
	Dispatch = CLIB.bgfx_dispatch,
	EncoderSetIndexBuffer = CLIB.bgfx_encoder_set_index_buffer,
	EncoderSetInstanceDataFromDynamicVertexBuffer = CLIB.bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer,
	EncoderSetTransientVertexBuffer = CLIB.bgfx_encoder_set_transient_vertex_buffer,
	CreateDynamicIndexBufferMem = CLIB.bgfx_create_dynamic_index_buffer_mem,
	EncoderSetVertexBuffer = CLIB.bgfx_encoder_set_vertex_buffer,
	EncoderSetScissorCached = CLIB.bgfx_encoder_set_scissor_cached,
	SetViewName = CLIB.bgfx_set_view_name,
	EncoderSubmitOcclusionQuery = CLIB.bgfx_encoder_submit_occlusion_query,
	SetViewClearMrt = CLIB.bgfx_set_view_clear_mrt,
	SetCondition = CLIB.bgfx_set_condition,
	GetSupportedRenderers = CLIB.bgfx_get_supported_renderers,
	AllocTransientIndexBuffer = CLIB.bgfx_alloc_transient_index_buffer,
	DestroyFrameBuffer = CLIB.bgfx_destroy_frame_buffer,
	GetCaps = CLIB.bgfx_get_caps,
	CreateTextureCube = CLIB.bgfx_create_texture_cube,
	SetScissor = CLIB.bgfx_set_scissor,
	CreateShader = CLIB.bgfx_create_shader,
	SetViewFrameBuffer = CLIB.bgfx_set_view_frame_buffer,
	UpdateTextureCube = CLIB.bgfx_update_texture_cube,
	CreateIndirectBuffer = CLIB.bgfx_create_indirect_buffer,
	SetComputeIndirectBuffer = CLIB.bgfx_set_compute_indirect_buffer,
	Init = CLIB.bgfx_init,
	CreateUniform = CLIB.bgfx_create_uniform,
	CreateDynamicVertexBufferMem = CLIB.bgfx_create_dynamic_vertex_buffer_mem,
	SetComputeDynamicVertexBuffer = CLIB.bgfx_set_compute_dynamic_vertex_buffer,
	EncoderSetScissor = CLIB.bgfx_encoder_set_scissor,
	EncoderSetComputeDynamicIndexBuffer = CLIB.bgfx_encoder_set_compute_dynamic_index_buffer,
	EncoderSetInstanceDataFromVertexBuffer = CLIB.bgfx_encoder_set_instance_data_from_vertex_buffer,
	EncoderSetCondition = CLIB.bgfx_encoder_set_condition,
	TopologySortTriList = CLIB.bgfx_topology_sort_tri_list,
	CreateFrameBufferFromAttachment = CLIB.bgfx_create_frame_buffer_from_attachment,
	Alloc = CLIB.bgfx_alloc,
	CreateComputeProgram = CLIB.bgfx_create_compute_program,
	UpdateTexture_2d = CLIB.bgfx_update_texture_2d,
	UpdateTexture_3d = CLIB.bgfx_update_texture_3d,
	VertexDeclSkip = CLIB.bgfx_vertex_decl_skip,
	EncoderSetTransform = CLIB.bgfx_encoder_set_transform,
	VertexDeclEnd = CLIB.bgfx_vertex_decl_end,
	GetAvailTransientVertexBuffer = CLIB.bgfx_get_avail_transient_vertex_buffer,
	DbgTextImage = CLIB.bgfx_dbg_text_image,
	SetComputeVertexBuffer = CLIB.bgfx_set_compute_vertex_buffer,
	EncoderSubmit = CLIB.bgfx_encoder_submit,
	GetShaderUniforms = CLIB.bgfx_get_shader_uniforms,
	SetIndexBuffer = CLIB.bgfx_set_index_buffer,
	DestroyIndirectBuffer = CLIB.bgfx_destroy_indirect_buffer,
	DispatchIndirect = CLIB.bgfx_dispatch_indirect,
	EncoderSetTransformCached = CLIB.bgfx_encoder_set_transform_cached,
	EncoderDiscard = CLIB.bgfx_encoder_discard,
	SetTransientIndexBuffer = CLIB.bgfx_set_transient_index_buffer,
	SetScissorCached = CLIB.bgfx_set_scissor_cached,
	EncoderSetComputeIndexBuffer = CLIB.bgfx_encoder_set_compute_index_buffer,
	CreateFrameBufferFromHandles = CLIB.bgfx_create_frame_buffer_from_handles,
	Submit = CLIB.bgfx_submit,
	DestroyProgram = CLIB.bgfx_destroy_program,
	EncoderSetDynamicIndexBuffer = CLIB.bgfx_encoder_set_dynamic_index_buffer,
	DestroyVertexBuffer = CLIB.bgfx_destroy_vertex_buffer,
	Touch = CLIB.bgfx_touch,
	OverrideInternalTexture = CLIB.bgfx_override_internal_texture,
	SetImage = CLIB.bgfx_set_image,
	GetTexture = CLIB.bgfx_get_texture,
	RenderFrame = CLIB.bgfx_render_frame,
	EncoderSetState = CLIB.bgfx_encoder_set_state,
	EncoderBlit = CLIB.bgfx_encoder_blit,
	EncoderDispatchIndirect = CLIB.bgfx_encoder_dispatch_indirect,
	EncoderDispatch = CLIB.bgfx_encoder_dispatch,
	EncoderSetComputeIndirectBuffer = CLIB.bgfx_encoder_set_compute_indirect_buffer,
	EncoderSetComputeDynamicVertexBuffer = CLIB.bgfx_encoder_set_compute_dynamic_vertex_buffer,
	EncoderSetImage = CLIB.bgfx_encoder_set_image,
	EncoderSubmitIndirect = CLIB.bgfx_encoder_submit_indirect,
	CreateTexture_2dScaled = CLIB.bgfx_create_texture_2d_scaled,
	TopologyConvert = CLIB.bgfx_topology_convert,
	WeldVertices = CLIB.bgfx_weld_vertices,
	DestroyUniform = CLIB.bgfx_destroy_uniform,
	Shutdown = CLIB.bgfx_shutdown,
	VertexDeclBegin = CLIB.bgfx_vertex_decl_begin,
	SetViewScissor = CLIB.bgfx_set_view_scissor,
	SubmitIndirect = CLIB.bgfx_submit_indirect,
	AllocTransform = CLIB.bgfx_alloc_transform,
	VertexPack = CLIB.bgfx_vertex_pack,
	SetStencil = CLIB.bgfx_set_stencil,
	CreateTexture = CLIB.bgfx_create_texture,
	EncoderTouch = CLIB.bgfx_encoder_touch,
	SetViewTransformStereo = CLIB.bgfx_set_view_transform_stereo,
	CreateFrameBufferScaled = CLIB.bgfx_create_frame_buffer_scaled,
	SubmitOcclusionQuery = CLIB.bgfx_submit_occlusion_query,
	Copy = CLIB.bgfx_copy,
	GetRendererType = CLIB.bgfx_get_renderer_type,
	GetHmd = CLIB.bgfx_get_hmd,
	EncoderSetTexture = CLIB.bgfx_encoder_set_texture,
	SetUniform = CLIB.bgfx_set_uniform,
	DestroyDynamicIndexBuffer = CLIB.bgfx_destroy_dynamic_index_buffer,
	GetStats = CLIB.bgfx_get_stats,
	CreateIndexBuffer = CLIB.bgfx_create_index_buffer,
	SetDebug = CLIB.bgfx_set_debug,
	GetRendererName = CLIB.bgfx_get_renderer_name,
	SetShaderName = CLIB.bgfx_set_shader_name,
	SetTextureName = CLIB.bgfx_set_texture_name,
	MakeRef = CLIB.bgfx_make_ref,
	SetInstanceDataBuffer = CLIB.bgfx_set_instance_data_buffer,
	GetAvailInstanceDataBuffer = CLIB.bgfx_get_avail_instance_data_buffer,
	DestroyShader = CLIB.bgfx_destroy_shader,
	GetUniformInfo = CLIB.bgfx_get_uniform_info,
	ReadTexture = CLIB.bgfx_read_texture,
	CreateVertexBuffer = CLIB.bgfx_create_vertex_buffer,
	CreateFrameBuffer = CLIB.bgfx_create_frame_buffer,
	EncoderAllocTransform = CLIB.bgfx_encoder_alloc_transform,
	SetViewMode = CLIB.bgfx_set_view_mode,
	OverrideInternalTexturePtr = CLIB.bgfx_override_internal_texture_ptr,
	DestroyOcclusionQuery = CLIB.bgfx_destroy_occlusion_query,
	SetViewRect = CLIB.bgfx_set_view_rect,
	SetViewTransform = CLIB.bgfx_set_view_transform,
	GetAvailTransientIndexBuffer = CLIB.bgfx_get_avail_transient_index_buffer,
	UpdateDynamicIndexBuffer = CLIB.bgfx_update_dynamic_index_buffer,
	SetInstanceDataFromDynamicVertexBuffer = CLIB.bgfx_set_instance_data_from_dynamic_vertex_buffer,
	CreateDynamicIndexBuffer = CLIB.bgfx_create_dynamic_index_buffer,
	SetTransformCached = CLIB.bgfx_set_transform_cached,
	SetDynamicIndexBuffer = CLIB.bgfx_set_dynamic_index_buffer,
	SetTransientVertexBuffer = CLIB.bgfx_set_transient_vertex_buffer,
	DbgTextPrintf = CLIB.bgfx_dbg_text_printf,
	SetViewClear = CLIB.bgfx_set_view_clear,
	SetComputeIndexBuffer = CLIB.bgfx_set_compute_index_buffer,
	SetComputeDynamicIndexBuffer = CLIB.bgfx_set_compute_dynamic_index_buffer,
	Discard = CLIB.bgfx_discard,
	EncoderSetMarker = CLIB.bgfx_encoder_set_marker,
	EncoderSetStencil = CLIB.bgfx_encoder_set_stencil,
	EncoderSetDynamicVertexBuffer = CLIB.bgfx_encoder_set_dynamic_vertex_buffer,
}
library.e = {
	RENDER_FRAME_NO_CONTEXT = ffi.cast("enum bgfx_render_frame", "BGFX_RENDER_FRAME_NO_CONTEXT"),
	RENDER_FRAME_RENDER = ffi.cast("enum bgfx_render_frame", "BGFX_RENDER_FRAME_RENDER"),
	RENDER_FRAME_TIMEOUT = ffi.cast("enum bgfx_render_frame", "BGFX_RENDER_FRAME_TIMEOUT"),
	RENDER_FRAME_EXITING = ffi.cast("enum bgfx_render_frame", "BGFX_RENDER_FRAME_EXITING"),
	RENDER_FRAME_COUNT = ffi.cast("enum bgfx_render_frame", "BGFX_RENDER_FRAME_COUNT"),
	TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MIN = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MIN"),
	TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_AVG = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_AVG"),
	TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MAX = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MAX"),
	TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MIN = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MIN"),
	TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_AVG = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_AVG"),
	TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MAX = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MAX"),
	TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MIN = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MIN"),
	TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_AVG = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_AVG"),
	TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MAX = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MAX"),
	TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MIN = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MIN"),
	TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_AVG = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_AVG"),
	TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MAX = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MAX"),
	TOPOLOGY_SORT_COUNT = ffi.cast("enum bgfx_topology_sort", "BGFX_TOPOLOGY_SORT_COUNT"),
	ATTRIB_TYPE_UINT8 = ffi.cast("enum bgfx_attrib_type", "BGFX_ATTRIB_TYPE_UINT8"),
	ATTRIB_TYPE_UINT10 = ffi.cast("enum bgfx_attrib_type", "BGFX_ATTRIB_TYPE_UINT10"),
	ATTRIB_TYPE_INT16 = ffi.cast("enum bgfx_attrib_type", "BGFX_ATTRIB_TYPE_INT16"),
	ATTRIB_TYPE_HALF = ffi.cast("enum bgfx_attrib_type", "BGFX_ATTRIB_TYPE_HALF"),
	ATTRIB_TYPE_FLOAT = ffi.cast("enum bgfx_attrib_type", "BGFX_ATTRIB_TYPE_FLOAT"),
	ATTRIB_TYPE_COUNT = ffi.cast("enum bgfx_attrib_type", "BGFX_ATTRIB_TYPE_COUNT"),
	FATAL_DEBUG_CHECK = ffi.cast("enum bgfx_fatal", "BGFX_FATAL_DEBUG_CHECK"),
	FATAL_INVALID_SHADER = ffi.cast("enum bgfx_fatal", "BGFX_FATAL_INVALID_SHADER"),
	FATAL_UNABLE_TO_INITIALIZE = ffi.cast("enum bgfx_fatal", "BGFX_FATAL_UNABLE_TO_INITIALIZE"),
	FATAL_UNABLE_TO_CREATE_TEXTURE = ffi.cast("enum bgfx_fatal", "BGFX_FATAL_UNABLE_TO_CREATE_TEXTURE"),
	FATAL_DEVICE_LOST = ffi.cast("enum bgfx_fatal", "BGFX_FATAL_DEVICE_LOST"),
	FATAL_COUNT = ffi.cast("enum bgfx_fatal", "BGFX_FATAL_COUNT"),
	BACKBUFFER_RATIO_EQUAL = ffi.cast("enum bgfx_backbuffer_ratio", "BGFX_BACKBUFFER_RATIO_EQUAL"),
	BACKBUFFER_RATIO_HALF = ffi.cast("enum bgfx_backbuffer_ratio", "BGFX_BACKBUFFER_RATIO_HALF"),
	BACKBUFFER_RATIO_QUARTER = ffi.cast("enum bgfx_backbuffer_ratio", "BGFX_BACKBUFFER_RATIO_QUARTER"),
	BACKBUFFER_RATIO_EIGHTH = ffi.cast("enum bgfx_backbuffer_ratio", "BGFX_BACKBUFFER_RATIO_EIGHTH"),
	BACKBUFFER_RATIO_SIXTEENTH = ffi.cast("enum bgfx_backbuffer_ratio", "BGFX_BACKBUFFER_RATIO_SIXTEENTH"),
	BACKBUFFER_RATIO_DOUBLE = ffi.cast("enum bgfx_backbuffer_ratio", "BGFX_BACKBUFFER_RATIO_DOUBLE"),
	BACKBUFFER_RATIO_COUNT = ffi.cast("enum bgfx_backbuffer_ratio", "BGFX_BACKBUFFER_RATIO_COUNT"),
	TOPOLOGY_CONVERT_TRI_LIST_FLIP_WINDING = ffi.cast("enum bgfx_topology_convert", "BGFX_TOPOLOGY_CONVERT_TRI_LIST_FLIP_WINDING"),
	TOPOLOGY_CONVERT_TRI_LIST_TO_LINE_LIST = ffi.cast("enum bgfx_topology_convert", "BGFX_TOPOLOGY_CONVERT_TRI_LIST_TO_LINE_LIST"),
	TOPOLOGY_CONVERT_TRI_STRIP_TO_TRI_LIST = ffi.cast("enum bgfx_topology_convert", "BGFX_TOPOLOGY_CONVERT_TRI_STRIP_TO_TRI_LIST"),
	TOPOLOGY_CONVERT_LINE_STRIP_TO_LINE_LIST = ffi.cast("enum bgfx_topology_convert", "BGFX_TOPOLOGY_CONVERT_LINE_STRIP_TO_LINE_LIST"),
	TOPOLOGY_CONVERT_COUNT = ffi.cast("enum bgfx_topology_convert", "BGFX_TOPOLOGY_CONVERT_COUNT"),
	ACCESS_READ = ffi.cast("enum bgfx_access", "BGFX_ACCESS_READ"),
	ACCESS_WRITE = ffi.cast("enum bgfx_access", "BGFX_ACCESS_WRITE"),
	ACCESS_READWRITE = ffi.cast("enum bgfx_access", "BGFX_ACCESS_READWRITE"),
	ACCESS_COUNT = ffi.cast("enum bgfx_access", "BGFX_ACCESS_COUNT"),
	RENDERER_TYPE_NOOP = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_NOOP"),
	RENDERER_TYPE_DIRECT3D9 = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_DIRECT3D9"),
	RENDERER_TYPE_DIRECT3D11 = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_DIRECT3D11"),
	RENDERER_TYPE_DIRECT3D12 = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_DIRECT3D12"),
	RENDERER_TYPE_GNM = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_GNM"),
	RENDERER_TYPE_METAL = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_METAL"),
	RENDERER_TYPE_OPENGLES = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_OPENGLES"),
	RENDERER_TYPE_OPENGL = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_OPENGL"),
	RENDERER_TYPE_VULKAN = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_VULKAN"),
	RENDERER_TYPE_COUNT = ffi.cast("enum bgfx_renderer_type", "BGFX_RENDERER_TYPE_COUNT"),
	TEXTURE_FORMAT_BC1 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BC1"),
	TEXTURE_FORMAT_BC2 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BC2"),
	TEXTURE_FORMAT_BC3 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BC3"),
	TEXTURE_FORMAT_BC4 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BC4"),
	TEXTURE_FORMAT_BC5 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BC5"),
	TEXTURE_FORMAT_BC6H = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BC6H"),
	TEXTURE_FORMAT_BC7 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BC7"),
	TEXTURE_FORMAT_ETC1 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_ETC1"),
	TEXTURE_FORMAT_ETC2 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_ETC2"),
	TEXTURE_FORMAT_ETC2A = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_ETC2A"),
	TEXTURE_FORMAT_ETC2A1 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_ETC2A1"),
	TEXTURE_FORMAT_PTC12 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_PTC12"),
	TEXTURE_FORMAT_PTC14 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_PTC14"),
	TEXTURE_FORMAT_PTC12A = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_PTC12A"),
	TEXTURE_FORMAT_PTC14A = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_PTC14A"),
	TEXTURE_FORMAT_PTC22 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_PTC22"),
	TEXTURE_FORMAT_PTC24 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_PTC24"),
	TEXTURE_FORMAT_UNKNOWN = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_UNKNOWN"),
	TEXTURE_FORMAT_R1 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R1"),
	TEXTURE_FORMAT_A8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_A8"),
	TEXTURE_FORMAT_R8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R8"),
	TEXTURE_FORMAT_R8I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R8I"),
	TEXTURE_FORMAT_R8U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R8U"),
	TEXTURE_FORMAT_R8S = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R8S"),
	TEXTURE_FORMAT_R16 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R16"),
	TEXTURE_FORMAT_R16I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R16I"),
	TEXTURE_FORMAT_R16U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R16U"),
	TEXTURE_FORMAT_R16F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R16F"),
	TEXTURE_FORMAT_R16S = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R16S"),
	TEXTURE_FORMAT_R32I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R32I"),
	TEXTURE_FORMAT_R32U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R32U"),
	TEXTURE_FORMAT_R32F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R32F"),
	TEXTURE_FORMAT_RG8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG8"),
	TEXTURE_FORMAT_RG8I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG8I"),
	TEXTURE_FORMAT_RG8U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG8U"),
	TEXTURE_FORMAT_RG8S = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG8S"),
	TEXTURE_FORMAT_RG16 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG16"),
	TEXTURE_FORMAT_RG16I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG16I"),
	TEXTURE_FORMAT_RG16U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG16U"),
	TEXTURE_FORMAT_RG16F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG16F"),
	TEXTURE_FORMAT_RG16S = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG16S"),
	TEXTURE_FORMAT_RG32I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG32I"),
	TEXTURE_FORMAT_RG32U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG32U"),
	TEXTURE_FORMAT_RG32F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG32F"),
	TEXTURE_FORMAT_RGB8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGB8"),
	TEXTURE_FORMAT_RGB8I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGB8I"),
	TEXTURE_FORMAT_RGB8U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGB8U"),
	TEXTURE_FORMAT_RGB8S = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGB8S"),
	TEXTURE_FORMAT_RGB9E5F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGB9E5F"),
	TEXTURE_FORMAT_BGRA8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_BGRA8"),
	TEXTURE_FORMAT_RGBA8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA8"),
	TEXTURE_FORMAT_RGBA8I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA8I"),
	TEXTURE_FORMAT_RGBA8U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA8U"),
	TEXTURE_FORMAT_RGBA8S = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA8S"),
	TEXTURE_FORMAT_RGBA16 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA16"),
	TEXTURE_FORMAT_RGBA16I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA16I"),
	TEXTURE_FORMAT_RGBA16U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA16U"),
	TEXTURE_FORMAT_RGBA16F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA16F"),
	TEXTURE_FORMAT_RGBA16S = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA16S"),
	TEXTURE_FORMAT_RGBA32I = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA32I"),
	TEXTURE_FORMAT_RGBA32U = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA32U"),
	TEXTURE_FORMAT_RGBA32F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA32F"),
	TEXTURE_FORMAT_R5G6B5 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_R5G6B5"),
	TEXTURE_FORMAT_RGBA4 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGBA4"),
	TEXTURE_FORMAT_RGB5A1 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGB5A1"),
	TEXTURE_FORMAT_RGB10A2 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RGB10A2"),
	TEXTURE_FORMAT_RG11B10F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_RG11B10F"),
	TEXTURE_FORMAT_UNKNOWN_DEPTH = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_UNKNOWN_DEPTH"),
	TEXTURE_FORMAT_D16 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D16"),
	TEXTURE_FORMAT_D24 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D24"),
	TEXTURE_FORMAT_D24S8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D24S8"),
	TEXTURE_FORMAT_D32 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D32"),
	TEXTURE_FORMAT_D16F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D16F"),
	TEXTURE_FORMAT_D24F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D24F"),
	TEXTURE_FORMAT_D32F = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D32F"),
	TEXTURE_FORMAT_D0S8 = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_D0S8"),
	TEXTURE_FORMAT_COUNT = ffi.cast("enum bgfx_texture_format", "BGFX_TEXTURE_FORMAT_COUNT"),
	ATTRIB_POSITION = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_POSITION"),
	ATTRIB_NORMAL = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_NORMAL"),
	ATTRIB_TANGENT = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TANGENT"),
	ATTRIB_BITANGENT = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_BITANGENT"),
	ATTRIB_COLOR0 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_COLOR0"),
	ATTRIB_COLOR1 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_COLOR1"),
	ATTRIB_COLOR2 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_COLOR2"),
	ATTRIB_COLOR3 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_COLOR3"),
	ATTRIB_INDICES = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_INDICES"),
	ATTRIB_WEIGHT = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_WEIGHT"),
	ATTRIB_TEXCOORD0 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD0"),
	ATTRIB_TEXCOORD1 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD1"),
	ATTRIB_TEXCOORD2 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD2"),
	ATTRIB_TEXCOORD3 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD3"),
	ATTRIB_TEXCOORD4 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD4"),
	ATTRIB_TEXCOORD5 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD5"),
	ATTRIB_TEXCOORD6 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD6"),
	ATTRIB_TEXCOORD7 = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_TEXCOORD7"),
	ATTRIB_COUNT = ffi.cast("enum bgfx_attrib", "BGFX_ATTRIB_COUNT"),
	VIEW_MODE_DEFAULT = ffi.cast("enum bgfx_view_mode", "BGFX_VIEW_MODE_DEFAULT"),
	VIEW_MODE_SEQUENTIAL = ffi.cast("enum bgfx_view_mode", "BGFX_VIEW_MODE_SEQUENTIAL"),
	VIEW_MODE_DEPTH_ASCENDING = ffi.cast("enum bgfx_view_mode", "BGFX_VIEW_MODE_DEPTH_ASCENDING"),
	VIEW_MODE_DEPTH_DESCENDING = ffi.cast("enum bgfx_view_mode", "BGFX_VIEW_MODE_DEPTH_DESCENDING"),
	VIEW_MODE_CCOUNT = ffi.cast("enum bgfx_view_mode", "BGFX_VIEW_MODE_CCOUNT"),
	UNIFORM_TYPE_INT1 = ffi.cast("enum bgfx_uniform_type", "BGFX_UNIFORM_TYPE_INT1"),
	UNIFORM_TYPE_END = ffi.cast("enum bgfx_uniform_type", "BGFX_UNIFORM_TYPE_END"),
	UNIFORM_TYPE_VEC4 = ffi.cast("enum bgfx_uniform_type", "BGFX_UNIFORM_TYPE_VEC4"),
	UNIFORM_TYPE_MAT3 = ffi.cast("enum bgfx_uniform_type", "BGFX_UNIFORM_TYPE_MAT3"),
	UNIFORM_TYPE_MAT4 = ffi.cast("enum bgfx_uniform_type", "BGFX_UNIFORM_TYPE_MAT4"),
	UNIFORM_TYPE_COUNT = ffi.cast("enum bgfx_uniform_type", "BGFX_UNIFORM_TYPE_COUNT"),
	OCCLUSION_QUERY_RESULT_INVISIBLE = ffi.cast("enum bgfx_occlusion_query_result", "BGFX_OCCLUSION_QUERY_RESULT_INVISIBLE"),
	OCCLUSION_QUERY_RESULT_VISIBLE = ffi.cast("enum bgfx_occlusion_query_result", "BGFX_OCCLUSION_QUERY_RESULT_VISIBLE"),
	OCCLUSION_QUERY_RESULT_NORESULT = ffi.cast("enum bgfx_occlusion_query_result", "BGFX_OCCLUSION_QUERY_RESULT_NORESULT"),
	OCCLUSION_QUERY_RESULT_COUNT = ffi.cast("enum bgfx_occlusion_query_result", "BGFX_OCCLUSION_QUERY_RESULT_COUNT"),
	DEFINES_H_HEADER_GUARD = 1,
	API_VERSION = 63,
	STATE_WRITE_R = 0x0000000000000001ULL ,
	STATE_WRITE_G = 0x0000000000000002ULL ,
	STATE_WRITE_B = 0x0000000000000004ULL ,
	STATE_WRITE_A = 0x0000000000000008ULL ,
	STATE_WRITE_Z = 0x0000004000000000ULL ,
	STATE_DEPTH_TEST_LESS = 0x0000000000000010ULL ,
	STATE_DEPTH_TEST_LEQUAL = 0x0000000000000020ULL ,
	STATE_DEPTH_TEST_EQUAL = 0x0000000000000030ULL ,
	STATE_DEPTH_TEST_GEQUAL = 0x0000000000000040ULL ,
	STATE_DEPTH_TEST_GREATER = 0x0000000000000050ULL ,
	STATE_DEPTH_TEST_NOTEQUAL = 0x0000000000000060ULL ,
	STATE_DEPTH_TEST_NEVER = 0x0000000000000070ULL ,
	STATE_DEPTH_TEST_ALWAYS = 0x0000000000000080ULL ,
	STATE_DEPTH_TEST_SHIFT = 4,
	STATE_DEPTH_TEST_MASK = 0x00000000000000f0ULL ,
	STATE_BLEND_ZERO = 0x0000000000001000ULL ,
	STATE_BLEND_ONE = 0x0000000000002000ULL ,
	STATE_BLEND_SRC_COLOR = 0x0000000000003000ULL ,
	STATE_BLEND_INV_SRC_COLOR = 0x0000000000004000ULL ,
	STATE_BLEND_SRC_ALPHA = 0x0000000000005000ULL ,
	STATE_BLEND_INV_SRC_ALPHA = 0x0000000000006000ULL ,
	STATE_BLEND_DST_ALPHA = 0x0000000000007000ULL ,
	STATE_BLEND_INV_DST_ALPHA = 0x0000000000008000ULL ,
	STATE_BLEND_DST_COLOR = 0x0000000000009000ULL ,
	STATE_BLEND_INV_DST_COLOR = 0x000000000000a000ULL ,
	STATE_BLEND_SRC_ALPHA_SAT = 0x000000000000b000ULL ,
	STATE_BLEND_FACTOR = 0x000000000000c000ULL ,
	STATE_BLEND_INV_FACTOR = 0x000000000000d000ULL ,
	STATE_BLEND_SHIFT = 12,
	STATE_BLEND_MASK = 0x000000000ffff000ULL ,
	STATE_BLEND_EQUATION_ADD = 0x0000000000000000ULL ,
	STATE_BLEND_EQUATION_SUB = 0x0000000010000000ULL ,
	STATE_BLEND_EQUATION_REVSUB = 0x0000000020000000ULL ,
	STATE_BLEND_EQUATION_MIN = 0x0000000030000000ULL ,
	STATE_BLEND_EQUATION_MAX = 0x0000000040000000ULL ,
	STATE_BLEND_EQUATION_SHIFT = 28,
	STATE_BLEND_EQUATION_MASK = 0x00000003f0000000ULL ,
	STATE_BLEND_INDEPENDENT = 0x0000000400000000ULL ,
	STATE_BLEND_ALPHA_TO_COVERAGE = 0x0000000800000000ULL ,
	STATE_CULL_CW = 0x0000001000000000ULL ,
	STATE_CULL_CCW = 0x0000002000000000ULL ,
	STATE_CULL_SHIFT = 36,
	STATE_CULL_MASK = 0x0000003000000000ULL ,
	STATE_ALPHA_REF_SHIFT = 40,
	STATE_ALPHA_REF_MASK = 0x0000ff0000000000ULL ,
	STATE_PT_TRISTRIP = 0x0001000000000000ULL ,
	STATE_PT_LINES = 0x0002000000000000ULL ,
	STATE_PT_LINESTRIP = 0x0003000000000000ULL ,
	STATE_PT_POINTS = 0x0004000000000000ULL ,
	STATE_PT_SHIFT = 48,
	STATE_PT_MASK = 0x0007000000000000ULL ,
	STATE_POINT_SIZE_SHIFT = 52,
	STATE_POINT_SIZE_MASK = 0x00f0000000000000ULL ,
	STATE_MSAA = 0x0100000000000000ULL ,
	STATE_LINEAA = 0x0200000000000000ULL ,
	STATE_CONSERVATIVE_RASTER = 0x0400000000000000ULL ,
	STATE_RESERVED_SHIFT = 61,
	STATE_RESERVED_MASK = 0xe000000000000000ULL ,
	STATE_NONE = 0x0000000000000000ULL ,
	STATE_MASK = 0xffffffffffffffffULL ,
	STENCIL_FUNC_REF_SHIFT = 0,
	STENCIL_FUNC_REF_MASK = 15,
	STENCIL_FUNC_RMASK_SHIFT = 8,
	STENCIL_FUNC_RMASK_MASK = 65280,
	STENCIL_TEST_LESS = 65536,
	STENCIL_TEST_LEQUAL = 131072,
	STENCIL_TEST_EQUAL = 196608,
	STENCIL_TEST_GEQUAL = 262144,
	STENCIL_TEST_GREATER = 327680,
	STENCIL_TEST_NOTEQUAL = 393216,
	STENCIL_TEST_NEVER = 458752,
	STENCIL_TEST_ALWAYS = 524288,
	STENCIL_TEST_SHIFT = 16,
	STENCIL_TEST_MASK = 983040,
	STENCIL_OP_FAIL_S_ZERO = 0,
	STENCIL_OP_FAIL_S_KEEP = 1048576,
	STENCIL_OP_FAIL_S_REPLACE = 2097152,
	STENCIL_OP_FAIL_S_INCR = 3145728,
	STENCIL_OP_FAIL_S_INCRSAT = 4194304,
	STENCIL_OP_FAIL_S_DECR = 5242880,
	STENCIL_OP_FAIL_S_DECRSAT = 6291456,
	STENCIL_OP_FAIL_S_INVERT = 7340032,
	STENCIL_OP_FAIL_S_SHIFT = 20,
	STENCIL_OP_FAIL_S_MASK = 15728640,
	STENCIL_OP_FAIL_Z_ZERO = 0,
	STENCIL_OP_FAIL_Z_KEEP = 16777216,
	STENCIL_OP_FAIL_Z_REPLACE = 33554432,
	STENCIL_OP_FAIL_Z_INCR = 50331648,
	STENCIL_OP_FAIL_Z_INCRSAT = 67108864,
	STENCIL_OP_FAIL_Z_DECR = 83886080,
	STENCIL_OP_FAIL_Z_DECRSAT = 100663296,
	STENCIL_OP_FAIL_Z_INVERT = 117440512,
	STENCIL_OP_FAIL_Z_SHIFT = 24,
	STENCIL_OP_FAIL_Z_MASK = 251658240,
	STENCIL_OP_PASS_Z_ZERO = 0,
	STENCIL_OP_PASS_Z_KEEP = 268435456,
	STENCIL_OP_PASS_Z_REPLACE = 536870912,
	STENCIL_OP_PASS_Z_INCR = 805306368,
	STENCIL_OP_PASS_Z_INCRSAT = 1073741824,
	STENCIL_OP_PASS_Z_DECR = 1342177280,
	STENCIL_OP_PASS_Z_DECRSAT = 1610612736,
	STENCIL_OP_PASS_Z_INVERT = 1879048192,
	STENCIL_OP_PASS_Z_SHIFT = 28,
	STENCIL_OP_PASS_Z_MASK = 4026531840,
	STENCIL_NONE = 0,
	STENCIL_MASK = 268435455,
	STENCIL_DEFAULT = 0,
	CLEAR_NONE = 0,
	CLEAR_COLOR = 1,
	CLEAR_DEPTH = 2,
	CLEAR_STENCIL = 4,
	CLEAR_DISCARD_COLOR_0 = 8,
	CLEAR_DISCARD_COLOR_1 = 16,
	CLEAR_DISCARD_COLOR_2 = 32,
	CLEAR_DISCARD_COLOR_3 = 64,
	CLEAR_DISCARD_COLOR_4 = 128,
	CLEAR_DISCARD_COLOR_5 = 256,
	CLEAR_DISCARD_COLOR_6 = 512,
	CLEAR_DISCARD_COLOR_7 = 1024,
	CLEAR_DISCARD_DEPTH = 2048,
	CLEAR_DISCARD_STENCIL = 4096,
	DEBUG_NONE = 0,
	DEBUG_WIREFRAME = 1,
	DEBUG_IFH = 2,
	DEBUG_STATS = 4,
	DEBUG_TEXT = 8,
	DEBUG_PROFILER = 16,
	BUFFER_NONE = 0,
	BUFFER_COMPUTE_FORMAT_8x1 = 1,
	BUFFER_COMPUTE_FORMAT_8x2 = 2,
	BUFFER_COMPUTE_FORMAT_8x4 = 3,
	BUFFER_COMPUTE_FORMAT_16x1 = 4,
	BUFFER_COMPUTE_FORMAT_16x2 = 5,
	BUFFER_COMPUTE_FORMAT_16x4 = 6,
	BUFFER_COMPUTE_FORMAT_32x1 = 7,
	BUFFER_COMPUTE_FORMAT_32x2 = 8,
	BUFFER_COMPUTE_FORMAT_32x4 = 9,
	BUFFER_COMPUTE_FORMAT_SHIFT = 0,
	BUFFER_COMPUTE_FORMAT_MASK = 0,
	BUFFER_COMPUTE_TYPE_INT = 16,
	BUFFER_COMPUTE_TYPE_UINT = 32,
	BUFFER_COMPUTE_TYPE_FLOAT = 48,
	BUFFER_COMPUTE_TYPE_SHIFT = 4,
	BUFFER_COMPUTE_TYPE_MASK = 48,
	BUFFER_COMPUTE_READ = 256,
	BUFFER_COMPUTE_WRITE = 512,
	BUFFER_DRAW_INDIRECT = 1024,
	BUFFER_ALLOW_RESIZE = 2048,
	BUFFER_INDEX32 = 4096,
	TEXTURE_NONE = 0,
	TEXTURE_U_MIRROR = 1,
	TEXTURE_U_CLAMP = 2,
	TEXTURE_U_BORDER = 3,
	TEXTURE_U_SHIFT = 0,
	TEXTURE_U_MASK = 3,
	TEXTURE_V_MIRROR = 4,
	TEXTURE_V_CLAMP = 8,
	TEXTURE_V_BORDER = 12,
	TEXTURE_V_SHIFT = 2,
	TEXTURE_V_MASK = 12,
	TEXTURE_W_MIRROR = 16,
	TEXTURE_W_CLAMP = 32,
	TEXTURE_W_BORDER = 48,
	TEXTURE_W_SHIFT = 4,
	TEXTURE_W_MASK = 48,
	TEXTURE_MIN_POINT = 64,
	TEXTURE_MIN_ANISOTROPIC = 128,
	TEXTURE_MIN_SHIFT = 6,
	TEXTURE_MIN_MASK = 192,
	TEXTURE_MAG_POINT = 256,
	TEXTURE_MAG_ANISOTROPIC = 512,
	TEXTURE_MAG_SHIFT = 8,
	TEXTURE_MAG_MASK = 768,
	TEXTURE_MIP_POINT = 1024,
	TEXTURE_MIP_SHIFT = 10,
	TEXTURE_MIP_MASK = 1024,
	TEXTURE_MSAA_SAMPLE = 2048,
	TEXTURE_RT = 4096,
	TEXTURE_RT_MSAA_X2 = 8192,
	TEXTURE_RT_MSAA_X4 = 12288,
	TEXTURE_RT_MSAA_X8 = 16384,
	TEXTURE_RT_MSAA_X16 = 20480,
	TEXTURE_RT_MSAA_SHIFT = 12,
	TEXTURE_RT_MSAA_MASK = 28672,
	TEXTURE_RT_WRITE_ONLY = 32768,
	TEXTURE_RT_MASK = 61440,
	TEXTURE_COMPARE_LESS = 65536,
	TEXTURE_COMPARE_LEQUAL = 131072,
	TEXTURE_COMPARE_EQUAL = 196608,
	TEXTURE_COMPARE_GEQUAL = 262144,
	TEXTURE_COMPARE_GREATER = 327680,
	TEXTURE_COMPARE_NOTEQUAL = 393216,
	TEXTURE_COMPARE_NEVER = 458752,
	TEXTURE_COMPARE_ALWAYS = 524288,
	TEXTURE_COMPARE_SHIFT = 16,
	TEXTURE_COMPARE_MASK = 983040,
	TEXTURE_COMPUTE_WRITE = 1048576,
	TEXTURE_SRGB = 2097152,
	TEXTURE_BLIT_DST = 4194304,
	TEXTURE_READ_BACK = 8388608,
	TEXTURE_BORDER_COLOR_SHIFT = 24,
	TEXTURE_BORDER_COLOR_MASK = 251658240,
	TEXTURE_RESERVED_SHIFT = 28,
	TEXTURE_RESERVED_MASK = 4026531840,
	RESET_NONE = 0,
	RESET_FULLSCREEN = 1,
	RESET_FULLSCREEN_SHIFT = 0,
	RESET_FULLSCREEN_MASK = 1,
	RESET_MSAA_X2 = 16,
	RESET_MSAA_X4 = 32,
	RESET_MSAA_X8 = 48,
	RESET_MSAA_X16 = 64,
	RESET_MSAA_SHIFT = 4,
	RESET_MSAA_MASK = 112,
	RESET_VSYNC = 128,
	RESET_MAXANISOTROPY = 256,
	RESET_CAPTURE = 512,
	RESET_HMD = 1024,
	RESET_HMD_DEBUG = 2048,
	RESET_HMD_RECENTER = 4096,
	RESET_FLUSH_AFTER_RENDER = 8192,
	RESET_FLIP_AFTER_RENDER = 16384,
	RESET_SRGB_BACKBUFFER = 32768,
	RESET_HIDPI = 65536,
	RESET_DEPTH_CLAMP = 131072,
	RESET_SUSPEND = 262144,
	RESET_RESERVED_SHIFT = 31,
	RESET_RESERVED_MASK = 2147483648,
	CAPS_ALPHA_TO_COVERAGE = 0x0000000000000001ULL ,
	CAPS_BLEND_INDEPENDENT = 0x0000000000000002ULL ,
	CAPS_COMPUTE = 0x0000000000000004ULL ,
	CAPS_CONSERVATIVE_RASTER = 0x0000000000000008ULL ,
	CAPS_DRAW_INDIRECT = 0x0000000000000010ULL ,
	CAPS_FRAGMENT_DEPTH = 0x0000000000000020ULL ,
	CAPS_FRAGMENT_ORDERING = 0x0000000000000040ULL ,
	CAPS_GRAPHICS_DEBUGGER = 0x0000000000000080ULL ,
	CAPS_HIDPI = 0x0000000000000100ULL ,
	CAPS_HMD = 0x0000000000000200ULL ,
	CAPS_INDEX32 = 0x0000000000000400ULL ,
	CAPS_INSTANCING = 0x0000000000000800ULL ,
	CAPS_OCCLUSION_QUERY = 0x0000000000001000ULL ,
	CAPS_RENDERER_MULTITHREADED = 0x0000000000002000ULL ,
	CAPS_SWAP_CHAIN = 0x0000000000004000ULL ,
	CAPS_TEXTURE_2D_ARRAY = 0x0000000000008000ULL ,
	CAPS_TEXTURE_3D = 0x0000000000010000ULL ,
	CAPS_TEXTURE_BLIT = 0x0000000000020000ULL ,
	CAPS_TEXTURE_COMPARE_ALL = 0x00000000000c0000ULL ,
	CAPS_TEXTURE_COMPARE_LEQUAL = 0x0000000000080000ULL ,
	CAPS_TEXTURE_CUBE_ARRAY = 0x0000000000100000ULL ,
	CAPS_TEXTURE_DIRECT_ACCESS = 0x0000000000200000ULL ,
	CAPS_TEXTURE_READ_BACK = 0x0000000000400000ULL ,
	CAPS_VERTEX_ATTRIB_HALF = 0x0000000000800000ULL ,
	CAPS_VERTEX_ATTRIB_UINT10 = 0x0000000000800000ULL ,
	CAPS_FORMAT_TEXTURE_NONE = 0,
	CAPS_FORMAT_TEXTURE_2D = 1,
	CAPS_FORMAT_TEXTURE_2D_SRGB = 2,
	CAPS_FORMAT_TEXTURE_2D_EMULATED = 4,
	CAPS_FORMAT_TEXTURE_3D = 8,
	CAPS_FORMAT_TEXTURE_3D_SRGB = 16,
	CAPS_FORMAT_TEXTURE_3D_EMULATED = 32,
	CAPS_FORMAT_TEXTURE_CUBE = 64,
	CAPS_FORMAT_TEXTURE_CUBE_SRGB = 128,
	CAPS_FORMAT_TEXTURE_CUBE_EMULATED = 256,
	CAPS_FORMAT_TEXTURE_VERTEX = 512,
	CAPS_FORMAT_TEXTURE_IMAGE = 1024,
	CAPS_FORMAT_TEXTURE_FRAMEBUFFER = 2048,
	CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA = 4096,
	CAPS_FORMAT_TEXTURE_MSAA = 8192,
	CAPS_FORMAT_TEXTURE_MIP_AUTOGEN = 16384,
	VIEW_NONE = 0,
	VIEW_STEREO = 1,
	SUBMIT_EYE_LEFT = 1,
	SUBMIT_EYE_RIGHT = 2,
	SUBMIT_EYE_MASK = 3,
	SUBMIT_EYE_FIRST = 1,
	SUBMIT_RESERVED_SHIFT = 7,
	SUBMIT_RESERVED_MASK = 128,
	PCI_ID_NONE = 0,
	PCI_ID_SOFTWARE_RASTERIZER = 1,
	PCI_ID_AMD = 4098,
	PCI_ID_INTEL = 32902,
	PCI_ID_NVIDIA = 4318,
	HMD_NONE = 0,
	HMD_DEVICE_RESOLUTION = 1,
	HMD_RENDERING = 2,
	CUBE_MAP_POSITIVE_X = 0,
	CUBE_MAP_NEGATIVE_X = 1,
	CUBE_MAP_POSITIVE_Y = 2,
	CUBE_MAP_NEGATIVE_Y = 3,
	CUBE_MAP_POSITIVE_Z = 4,
	CUBE_MAP_NEGATIVE_Z = 5,
}
library.clib = CLIB
return library
