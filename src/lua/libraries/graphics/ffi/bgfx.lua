local enums = {
	BGFX_API_VERSION = 2,
	BGFX_STATE_RGB_WRITE = 0x0000000000000001ULL,
	BGFX_STATE_ALPHA_WRITE = 0x0000000000000002ULL,
	BGFX_STATE_DEPTH_WRITE = 0x0000000000000004ULL,
	BGFX_STATE_DEPTH_TEST_LESS = 0x0000000000000010ULL,
	BGFX_STATE_DEPTH_TEST_LEQUAL = 0x0000000000000020ULL,
	BGFX_STATE_DEPTH_TEST_EQUAL = 0x0000000000000030ULL,
	BGFX_STATE_DEPTH_TEST_GEQUAL = 0x0000000000000040ULL,
	BGFX_STATE_DEPTH_TEST_GREATER = 0x0000000000000050ULL,
	BGFX_STATE_DEPTH_TEST_NOTEQUAL = 0x0000000000000060ULL,
	BGFX_STATE_DEPTH_TEST_NEVER = 0x0000000000000070ULL,
	BGFX_STATE_DEPTH_TEST_ALWAYS = 0x0000000000000080ULL,
	BGFX_STATE_DEPTH_TEST_SHIFT = 4,
	BGFX_STATE_DEPTH_TEST_MASK = 0x00000000000000f0ULL,
	BGFX_STATE_BLEND_ZERO = 0x0000000000001000ULL,
	BGFX_STATE_BLEND_ONE = 0x0000000000002000ULL,
	BGFX_STATE_BLEND_SRC_COLOR = 0x0000000000003000ULL,
	BGFX_STATE_BLEND_INV_SRC_COLOR = 0x0000000000004000ULL,
	BGFX_STATE_BLEND_SRC_ALPHA = 0x0000000000005000ULL,
	BGFX_STATE_BLEND_INV_SRC_ALPHA = 0x0000000000006000ULL,
	BGFX_STATE_BLEND_DST_ALPHA = 0x0000000000007000ULL,
	BGFX_STATE_BLEND_INV_DST_ALPHA = 0x0000000000008000ULL,
	BGFX_STATE_BLEND_DST_COLOR = 0x0000000000009000ULL,
	BGFX_STATE_BLEND_INV_DST_COLOR = 0x000000000000a000ULL,
	BGFX_STATE_BLEND_SRC_ALPHA_SAT = 0x000000000000b000ULL,
	BGFX_STATE_BLEND_FACTOR = 0x000000000000c000ULL,
	BGFX_STATE_BLEND_INV_FACTOR = 0x000000000000d000ULL,
	BGFX_STATE_BLEND_SHIFT = 12,
	BGFX_STATE_BLEND_MASK = 0x000000000ffff000ULL,
	BGFX_STATE_BLEND_EQUATION_ADD = 0x0000000000000000ULL,
	BGFX_STATE_BLEND_EQUATION_SUB = 0x0000000010000000ULL,
	BGFX_STATE_BLEND_EQUATION_REVSUB = 0x0000000020000000ULL,
	BGFX_STATE_BLEND_EQUATION_MIN = 0x0000000030000000ULL,
	BGFX_STATE_BLEND_EQUATION_MAX = 0x0000000040000000ULL,
	BGFX_STATE_BLEND_EQUATION_SHIFT = 28,
	BGFX_STATE_BLEND_EQUATION_MASK = 0x00000003f0000000ULL,
	BGFX_STATE_BLEND_INDEPENDENT = 0x0000000400000000ULL,
	BGFX_STATE_CULL_CW = 0x0000001000000000ULL,
	BGFX_STATE_CULL_CCW = 0x0000002000000000ULL,
	BGFX_STATE_CULL_SHIFT = 36,
	BGFX_STATE_CULL_MASK = 0x0000003000000000ULL,
	BGFX_STATE_ALPHA_REF_SHIFT = 40,
	BGFX_STATE_ALPHA_REF_MASK = 0x0000ff0000000000ULL,
	BGFX_STATE_PT_TRISTRIP = 0x0001000000000000ULL,
	BGFX_STATE_PT_LINES = 0x0002000000000000ULL,
	BGFX_STATE_PT_LINESTRIP = 0x0003000000000000ULL,
	BGFX_STATE_PT_POINTS = 0x0004000000000000ULL,
	BGFX_STATE_PT_SHIFT = 48,
	BGFX_STATE_PT_MASK = 0x0007000000000000ULL,
	BGFX_STATE_POINT_SIZE_SHIFT = 52,
	BGFX_STATE_POINT_SIZE_MASK = 0x0ff0000000000000ULL,
	BGFX_STATE_MSAA = 0x1000000000000000ULL,
	BGFX_STATE_RESERVED_SHIFT = 61,
	BGFX_STATE_RESERVED_MASK = 0xe000000000000000ULL,
	BGFX_STATE_NONE = 0x0000000000000000ULL,
	BGFX_STATE_MASK = 0xffffffffffffffffULL,
	BGFX_STENCIL_FUNC_REF_SHIFT = 0,
	BGFX_STENCIL_FUNC_REF_MASK = 0x000000ff,
	BGFX_STENCIL_FUNC_RMASK_SHIFT = 8,
	BGFX_STENCIL_FUNC_RMASK_MASK = 0x0000ff00,
	BGFX_STENCIL_TEST_LESS = 0x00010000,
	BGFX_STENCIL_TEST_LEQUAL = 0x00020000,
	BGFX_STENCIL_TEST_EQUAL = 0x00030000,
	BGFX_STENCIL_TEST_GEQUAL = 0x00040000,
	BGFX_STENCIL_TEST_GREATER = 0x00050000,
	BGFX_STENCIL_TEST_NOTEQUAL = 0x00060000,
	BGFX_STENCIL_TEST_NEVER = 0x00070000,
	BGFX_STENCIL_TEST_ALWAYS = 0x00080000,
	BGFX_STENCIL_TEST_SHIFT = 16,
	BGFX_STENCIL_TEST_MASK = 0x000f0000,
	BGFX_STENCIL_OP_FAIL_S_ZERO = 0x00000000,
	BGFX_STENCIL_OP_FAIL_S_KEEP = 0x00100000,
	BGFX_STENCIL_OP_FAIL_S_REPLACE = 0x00200000,
	BGFX_STENCIL_OP_FAIL_S_INCR = 0x00300000,
	BGFX_STENCIL_OP_FAIL_S_INCRSAT = 0x00400000,
	BGFX_STENCIL_OP_FAIL_S_DECR = 0x00500000,
	BGFX_STENCIL_OP_FAIL_S_DECRSAT = 0x00600000,
	BGFX_STENCIL_OP_FAIL_S_INVERT = 0x00700000,
	BGFX_STENCIL_OP_FAIL_S_SHIFT = 20,
	BGFX_STENCIL_OP_FAIL_S_MASK = 0x00f00000,
	BGFX_STENCIL_OP_FAIL_Z_ZERO = 0x00000000,
	BGFX_STENCIL_OP_FAIL_Z_KEEP = 0x01000000,
	BGFX_STENCIL_OP_FAIL_Z_REPLACE = 0x02000000,
	BGFX_STENCIL_OP_FAIL_Z_INCR = 0x03000000,
	BGFX_STENCIL_OP_FAIL_Z_INCRSAT = 0x04000000,
	BGFX_STENCIL_OP_FAIL_Z_DECR = 0x05000000,
	BGFX_STENCIL_OP_FAIL_Z_DECRSAT = 0x06000000,
	BGFX_STENCIL_OP_FAIL_Z_INVERT = 0x07000000,
	BGFX_STENCIL_OP_FAIL_Z_SHIFT = 24,
	BGFX_STENCIL_OP_FAIL_Z_MASK = 0x0f000000,
	BGFX_STENCIL_OP_PASS_Z_ZERO = 0x00000000,
	BGFX_STENCIL_OP_PASS_Z_KEEP = 0x10000000,
	BGFX_STENCIL_OP_PASS_Z_REPLACE = 0x20000000,
	BGFX_STENCIL_OP_PASS_Z_INCR = 0x30000000,
	BGFX_STENCIL_OP_PASS_Z_INCRSAT = 0x40000000,
	BGFX_STENCIL_OP_PASS_Z_DECR = 0x50000000,
	BGFX_STENCIL_OP_PASS_Z_DECRSAT = 0x60000000,
	BGFX_STENCIL_OP_PASS_Z_INVERT = 0x70000000,
	BGFX_STENCIL_OP_PASS_Z_SHIFT = 28,
	BGFX_STENCIL_OP_PASS_Z_MASK = 0xf0000000,
	BGFX_STENCIL_NONE = 0x00000000,
	BGFX_STENCIL_MASK = 0xffffffff,
	BGFX_STENCIL_DEFAULT = 0x00000000,
	BGFX_CLEAR_NONE = 0x0000,
	BGFX_CLEAR_COLOR = 0x0001,
	BGFX_CLEAR_DEPTH = 0x0002,
	BGFX_CLEAR_STENCIL = 0x0004,
	BGFX_CLEAR_DISCARD_COLOR_0 = 0x0008,
	BGFX_CLEAR_DISCARD_COLOR_1 = 0x0010,
	BGFX_CLEAR_DISCARD_COLOR_2 = 0x0020,
	BGFX_CLEAR_DISCARD_COLOR_3 = 0x0040,
	BGFX_CLEAR_DISCARD_COLOR_4 = 0x0080,
	BGFX_CLEAR_DISCARD_COLOR_5 = 0x0100,
	BGFX_CLEAR_DISCARD_COLOR_6 = 0x0200,
	BGFX_CLEAR_DISCARD_COLOR_7 = 0x0400,
	BGFX_CLEAR_DISCARD_DEPTH = 0x0800,
	BGFX_CLEAR_DISCARD_STENCIL = 0x1000,
	BGFX_DEBUG_NONE = 0x00000000,
	BGFX_DEBUG_WIREFRAME = 0x00000001,
	BGFX_DEBUG_IFH = 0x00000002,
	BGFX_DEBUG_STATS = 0x00000004,
	BGFX_DEBUG_TEXT = 0x00000008,
	BGFX_BUFFER_NONE = 0x0000,
	BGFX_BUFFER_COMPUTE_FORMAT_8x1 = 0x0001,
	BGFX_BUFFER_COMPUTE_FORMAT_8x2 = 0x0002,
	BGFX_BUFFER_COMPUTE_FORMAT_8x4 = 0x0003,
	BGFX_BUFFER_COMPUTE_FORMAT_16x1 = 0x0004,
	BGFX_BUFFER_COMPUTE_FORMAT_16x2 = 0x0005,
	BGFX_BUFFER_COMPUTE_FORMAT_16x4 = 0x0006,
	BGFX_BUFFER_COMPUTE_FORMAT_32x1 = 0x0007,
	BGFX_BUFFER_COMPUTE_FORMAT_32x2 = 0x0008,
	BGFX_BUFFER_COMPUTE_FORMAT_32x4 = 0x0009,
	BGFX_BUFFER_COMPUTE_FORMAT_SHIFT = 0,
	BGFX_BUFFER_COMPUTE_FORMAT_MASK = 0x000f,
	BGFX_BUFFER_COMPUTE_TYPE_UINT = 0x0010,
	BGFX_BUFFER_COMPUTE_TYPE_INT = 0x0020,
	BGFX_BUFFER_COMPUTE_TYPE_FLOAT = 0x0030,
	BGFX_BUFFER_COMPUTE_TYPE_SHIFT = 4,
	BGFX_BUFFER_COMPUTE_TYPE_MASK = 0x0030,
	BGFX_BUFFER_COMPUTE_READ = 0x0100,
	BGFX_BUFFER_COMPUTE_WRITE = 0x0200,
	BGFX_BUFFER_DRAW_INDIRECT = 0x0400,
	BGFX_BUFFER_ALLOW_RESIZE = 0x0800,
	BGFX_BUFFER_INDEX32 = 0x1000,
	BGFX_TEXTURE_NONE = 0x00000000,
	BGFX_TEXTURE_U_MIRROR = 0x00000001,
	BGFX_TEXTURE_U_CLAMP = 0x00000002,
	BGFX_TEXTURE_U_BORDER = 0x00000003,
	BGFX_TEXTURE_U_SHIFT = 0,
	BGFX_TEXTURE_U_MASK = 0x00000003,
	BGFX_TEXTURE_V_MIRROR = 0x00000004,
	BGFX_TEXTURE_V_CLAMP = 0x00000008,
	BGFX_TEXTURE_V_BORDER = 0x0000000c,
	BGFX_TEXTURE_V_SHIFT = 2,
	BGFX_TEXTURE_V_MASK = 0x0000000c,
	BGFX_TEXTURE_W_MIRROR = 0x00000010,
	BGFX_TEXTURE_W_CLAMP = 0x00000020,
	BGFX_TEXTURE_W_BORDER = 0x00000030,
	BGFX_TEXTURE_W_SHIFT = 4,
	BGFX_TEXTURE_W_MASK = 0x00000030,
	BGFX_TEXTURE_MIN_POINT = 0x00000040,
	BGFX_TEXTURE_MIN_ANISOTROPIC = 0x00000080,
	BGFX_TEXTURE_MIN_SHIFT = 6,
	BGFX_TEXTURE_MIN_MASK = 0x000000c0,
	BGFX_TEXTURE_MAG_POINT = 0x00000100,
	BGFX_TEXTURE_MAG_ANISOTROPIC = 0x00000200,
	BGFX_TEXTURE_MAG_SHIFT = 8,
	BGFX_TEXTURE_MAG_MASK = 0x00000300,
	BGFX_TEXTURE_MIP_POINT = 0x00000400,
	BGFX_TEXTURE_MIP_SHIFT = 10,
	BGFX_TEXTURE_MIP_MASK = 0x00000400,
	BGFX_TEXTURE_RT = 0x00001000,
	BGFX_TEXTURE_RT_MSAA_X2 = 0x00002000,
	BGFX_TEXTURE_RT_MSAA_X4 = 0x00003000,
	BGFX_TEXTURE_RT_MSAA_X8 = 0x00004000,
	BGFX_TEXTURE_RT_MSAA_X16 = 0x00005000,
	BGFX_TEXTURE_RT_MSAA_SHIFT = 12,
	BGFX_TEXTURE_RT_MSAA_MASK = 0x00007000,
	BGFX_TEXTURE_RT_BUFFER_ONLY = 0x00008000,
	BGFX_TEXTURE_RT_MASK = 0x0000f000,
	BGFX_TEXTURE_COMPARE_LESS = 0x00010000,
	BGFX_TEXTURE_COMPARE_LEQUAL = 0x00020000,
	BGFX_TEXTURE_COMPARE_EQUAL = 0x00030000,
	BGFX_TEXTURE_COMPARE_GEQUAL = 0x00040000,
	BGFX_TEXTURE_COMPARE_GREATER = 0x00050000,
	BGFX_TEXTURE_COMPARE_NOTEQUAL = 0x00060000,
	BGFX_TEXTURE_COMPARE_NEVER = 0x00070000,
	BGFX_TEXTURE_COMPARE_ALWAYS = 0x00080000,
	BGFX_TEXTURE_COMPARE_SHIFT = 16,
	BGFX_TEXTURE_COMPARE_MASK = 0x000f0000,
	BGFX_TEXTURE_COMPUTE_WRITE = 0x00100000,
	BGFX_TEXTURE_SRGB = 0x00200000,
	BGFX_TEXTURE_BLIT_DST = 0x00400000,
	BGFX_TEXTURE_READ_BACK = 0x00800000,
	BGFX_TEXTURE_BORDER_COLOR_SHIFT = 24,
	BGFX_TEXTURE_BORDER_COLOR_MASK = 0x0f000000,
	BGFX_TEXTURE_RESERVED_SHIFT = 28,
	BGFX_TEXTURE_RESERVED_MASK = 0xf0000000,
	BGFX_RESET_NONE = 0x00000000,
	BGFX_RESET_FULLSCREEN = 0x00000001,
	BGFX_RESET_FULLSCREEN_SHIFT = 0,
	BGFX_RESET_FULLSCREEN_MASK = 0x00000001,
	BGFX_RESET_MSAA_X2 = 0x00000010,
	BGFX_RESET_MSAA_X4 = 0x00000020,
	BGFX_RESET_MSAA_X8 = 0x00000030,
	BGFX_RESET_MSAA_X16 = 0x00000040,
	BGFX_RESET_MSAA_SHIFT = 4,
	BGFX_RESET_MSAA_MASK = 0x00000070,
	BGFX_RESET_VSYNC = 0x00000080,
	BGFX_RESET_MAXANISOTROPY = 0x00000100,
	BGFX_RESET_CAPTURE = 0x00000200,
	BGFX_RESET_HMD = 0x00000400,
	BGFX_RESET_HMD_DEBUG = 0x00000800,
	BGFX_RESET_HMD_RECENTER = 0x00001000,
	BGFX_RESET_FLUSH_AFTER_RENDER = 0x00002000,
	BGFX_RESET_FLIP_AFTER_RENDER = 0x00004000,
	BGFX_RESET_SRGB_BACKBUFFER = 0x00008000,
	BGFX_RESET_HIDPI = 0x00010000,
	BGFX_RESET_DEPTH_CLAMP = 0x00020000,
	BGFX_RESET_RESERVED_SHIFT = 31,
	BGFX_RESET_RESERVED_MASK = 0x80000000,
	BGFX_CAPS_TEXTURE_COMPARE_LEQUAL = 0x0000000000000001ULL,
	BGFX_CAPS_TEXTURE_COMPARE_ALL = 0x0000000000000003ULL,
	BGFX_CAPS_TEXTURE_3D = 0x0000000000000004ULL,
	BGFX_CAPS_VERTEX_ATTRIB_HALF = 0x0000000000000008ULL,
	BGFX_CAPS_VERTEX_ATTRIB_UINT10 = 0x0000000000000010ULL,
	BGFX_CAPS_INSTANCING = 0x0000000000000020ULL,
	BGFX_CAPS_RENDERER_MULTITHREADED = 0x0000000000000040ULL,
	BGFX_CAPS_FRAGMENT_DEPTH = 0x0000000000000080ULL,
	BGFX_CAPS_BLEND_INDEPENDENT = 0x0000000000000100ULL,
	BGFX_CAPS_COMPUTE = 0x0000000000000200ULL,
	BGFX_CAPS_FRAGMENT_ORDERING = 0x0000000000000400ULL,
	BGFX_CAPS_SWAP_CHAIN = 0x0000000000000800ULL,
	BGFX_CAPS_HMD = 0x0000000000001000ULL,
	BGFX_CAPS_INDEX32 = 0x0000000000002000ULL,
	BGFX_CAPS_DRAW_INDIRECT = 0x0000000000004000ULL,
	BGFX_CAPS_HIDPI = 0x0000000000008000ULL,
	BGFX_CAPS_TEXTURE_BLIT = 0x0000000000010000ULL,
	BGFX_CAPS_TEXTURE_READ_BACK = 0x0000000000020000ULL,
	BGFX_CAPS_OCCLUSION_QUERY = 0x0000000000040000ULL,
	BGFX_CAPS_FORMAT_TEXTURE_NONE = 0x0000,
	BGFX_CAPS_FORMAT_TEXTURE_2D = 0x0001,
	BGFX_CAPS_FORMAT_TEXTURE_2D_SRGB = 0x0002,
	BGFX_CAPS_FORMAT_TEXTURE_2D_EMULATED = 0x0004,
	BGFX_CAPS_FORMAT_TEXTURE_3D = 0x0008,
	BGFX_CAPS_FORMAT_TEXTURE_3D_SRGB = 0x0010,
	BGFX_CAPS_FORMAT_TEXTURE_3D_EMULATED = 0x0020,
	BGFX_CAPS_FORMAT_TEXTURE_CUBE = 0x0040,
	BGFX_CAPS_FORMAT_TEXTURE_CUBE_SRGB = 0x0080,
	BGFX_CAPS_FORMAT_TEXTURE_CUBE_EMULATED = 0x0100,
	BGFX_CAPS_FORMAT_TEXTURE_VERTEX = 0x0200,
	BGFX_CAPS_FORMAT_TEXTURE_IMAGE = 0x0400,
	BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER = 0x0800,
	BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA = 0x1000,
	BGFX_CAPS_FORMAT_TEXTURE_MSAA = 0x2000,
	BGFX_VIEW_NONE = 0x00,
	BGFX_VIEW_STEREO = 0x01,
	BGFX_SUBMIT_EYE_LEFT = 0x01,
	BGFX_SUBMIT_EYE_RIGHT = 0x02,
	BGFX_SUBMIT_EYE_MASK = 0x03,
	BGFX_SUBMIT_RESERVED_SHIFT = 7,
	BGFX_SUBMIT_RESERVED_MASK = 0x80,
	BGFX_PCI_ID_NONE = 0x0000,
	BGFX_PCI_ID_SOFTWARE_RASTERIZER = 0x0001,
	BGFX_PCI_ID_AMD = 0x1002,
	BGFX_PCI_ID_INTEL = 0x8086,
	BGFX_PCI_ID_NVIDIA = 0x10de,
	BGFX_HMD_NONE = 0x00,
	BGFX_HMD_DEVICE_RESOLUTION = 0x01,
	BGFX_HMD_RENDERING = 0x02,
}

--[[
BGFX_SUBMIT_EYE_FIRST = BGFX_SUBMIT_EYE_LEFT
BGFX_TEXTURE_BORDER_COLOR(_index) ( (_index << BGFX_TEXTURE_BORDER_COLOR_SHIFT) & BGFX_TEXTURE_BORDER_COLOR_MASK)
BGFX_TEXTURE_SAMPLER_BITS_MASK (0 | BGFX_TEXTURE_U_MASK | BGFX_TEXTURE_V_MASK | BGFX_TEXTURE_W_MASK | BGFX_TEXTURE_MIN_MASK | BGFX_TEXTURE_MAG_MASK | BGFX_TEXTURE_MIP_MASK | BGFX_TEXTURE_COMPARE_MASK )


BGFX_BUFFER_COMPUTE_READ_WRITE (0 | BGFX_BUFFER_COMPUTE_READ | BGFX_BUFFER_COMPUTE_WRITE )

BGFX_CLEAR_DISCARD_COLOR_MASK (0 | BGFX_CLEAR_DISCARD_COLOR_0 | BGFX_CLEAR_DISCARD_COLOR_1 | BGFX_CLEAR_DISCARD_COLOR_2 | BGFX_CLEAR_DISCARD_COLOR_3 | BGFX_CLEAR_DISCARD_COLOR_4 | BGFX_CLEAR_DISCARD_COLOR_5 | BGFX_CLEAR_DISCARD_COLOR_6 | BGFX_CLEAR_DISCARD_COLOR_7 )
BGFX_CLEAR_DISCARD_MASK (0 | BGFX_CLEAR_DISCARD_COLOR_MASK | BGFX_CLEAR_DISCARD_DEPTH | BGFX_CLEAR_DISCARD_STENCIL )


BGFX_STENCIL_FUNC_REF(_ref) ( (uint32_t(_ref)<<BGFX_STENCIL_FUNC_REF_SHIFT)&BGFX_STENCIL_FUNC_REF_MASK)
BGFX_STENCIL_FUNC_RMASK(_mask) ( (uint32_t(_mask)<<BGFX_STENCIL_FUNC_RMASK_SHIFT)&BGFX_STENCIL_FUNC_RMASK_MASK)

BGFX_STATE_DEFAULT = bit.bor(0, BGFX_STATE_RGB_WRITE, BGFX_STATE_ALPHA_WRITE, BGFX_STATE_DEPTH_TEST_LESS, BGFX_STATE_DEPTH_WRITE, BGFX_STATE_CULL_CW, BGFX_STATE_MSAA )
BGFX_STATE_ALPHA_REF = function(_ref) return bit.band(bit.lshift(_ref, BGFX_STATE_ALPHA_REF_SHIFT), BGFX_STATE_ALPHA_REF_MASK) end
BGFX_STATE_POINT_SIZE = function(_size) return bit.band(bit.lshift(_size, BGFX_STATE_POINT_SIZE_SHIFT), BGFX_STATE_POINT_SIZE_MASK) end
BGFX_STATE_BLEND_FUNC_SEPARATE(_srcRGB, _dstRGB, _srcA, _dstA) (0) | ( ( (uint64_t)(_srcRGB)|( (uint64_t)(_dstRGB)<<4) )   ) | ( ( (uint64_t)(_srcA  )|( (uint64_t)(_dstA  )<<4) )<<8ULL
BGFX_STATE_BLEND_EQUATION_SEPARATE(_rgb, _a) ( (uint64_t)(_rgb)|( (uint64_t)(_a)<<3) )
BGFX_STATE_BLEND_FUNC(_src, _dst)    BGFX_STATE_BLEND_FUNC_SEPARATE(_src, _dst, _src, _dst)
BGFX_STATE_BLEND_EQUATION(_equation) BGFX_STATE_BLEND_EQUATION_SEPARATE(_equation, _equation)
BGFX_STATE_BLEND_ADD         (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_ONE,       BGFX_STATE_BLEND_ONE          ) )
BGFX_STATE_BLEND_ALPHA       (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA) )
BGFX_STATE_BLEND_DARKEN      (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_ONE,       BGFX_STATE_BLEND_ONE          ) | BGFX_STATE_BLEND_EQUATION(BGFX_STATE_BLEND_EQUATION_MIN) )
BGFX_STATE_BLEND_LIGHTEN     (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_ONE,       BGFX_STATE_BLEND_ONE          ) | BGFX_STATE_BLEND_EQUATION(BGFX_STATE_BLEND_EQUATION_MAX) )
BGFX_STATE_BLEND_MULTIPLY    (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_DST_COLOR, BGFX_STATE_BLEND_ZERO         ) )
BGFX_STATE_BLEND_NORMAL      (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_ONE,       BGFX_STATE_BLEND_INV_SRC_ALPHA) )
BGFX_STATE_BLEND_SCREEN      (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_ONE,       BGFX_STATE_BLEND_INV_SRC_COLOR) )
BGFX_STATE_BLEND_LINEAR_BURN (BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_DST_COLOR, BGFX_STATE_BLEND_INV_DST_COLOR) | BGFX_STATE_BLEND_EQUATION(BGFX_STATE_BLEND_EQUATION_SUB) )
BGFX_STATE_BLEND_FUNC_RT_x(_src, _dst) (0 | ( uint32_t( (_src)>>BGFX_STATE_BLEND_SHIFT) | ( uint32_t( (_dst)>>BGFX_STATE_BLEND_SHIFT)<<4) ) )
BGFX_STATE_BLEND_FUNC_RT_xE(_src, _dst, _equation) (0 | BGFX_STATE_BLEND_FUNC_RT_x(_src, _dst) | ( uint32_t( (_equation)>>BGFX_STATE_BLEND_EQUATION_SHIFT)<<8) )
BGFX_STATE_BLEND_FUNC_RT_1(_src, _dst)  (BGFX_STATE_BLEND_FUNC_RT_x(_src, _dst)<< 0)
BGFX_STATE_BLEND_FUNC_RT_2(_src, _dst)  (BGFX_STATE_BLEND_FUNC_RT_x(_src, _dst)<<11)
BGFX_STATE_BLEND_FUNC_RT_3(_src, _dst)  (BGFX_STATE_BLEND_FUNC_RT_x(_src, _dst)<<22)
BGFX_STATE_BLEND_FUNC_RT_1E(_src, _dst, _equation) (BGFX_STATE_BLEND_FUNC_RT_xE(_src, _dst, _equation)<< 0)
BGFX_STATE_BLEND_FUNC_RT_2E(_src, _dst, _equation) (BGFX_STATE_BLEND_FUNC_RT_xE(_src, _dst, _equation)<<11)
BGFX_STATE_BLEND_FUNC_RT_3E(_src, _dst, _equation) (BGFX_STATE_BLEND_FUNC_RT_xE(_src, _dst, _equation)<<22)]]

local header = [[
typedef enum bgfx_renderer_type
{
    BGFX_RENDERER_TYPE_NULL,
    BGFX_RENDERER_TYPE_DIRECT3D9,
    BGFX_RENDERER_TYPE_DIRECT3D11,
    BGFX_RENDERER_TYPE_DIRECT3D12,
    BGFX_RENDERER_TYPE_METAL,
    BGFX_RENDERER_TYPE_OPENGLES,
    BGFX_RENDERER_TYPE_OPENGL,
    BGFX_RENDERER_TYPE_VULKAN,
    BGFX_RENDERER_TYPE_COUNT
} bgfx_renderer_type_t;
typedef enum bgfx_access
{
    BGFX_ACCESS_READ,
    BGFX_ACCESS_WRITE,
    BGFX_ACCESS_READWRITE,
    BGFX_ACCESS_COUNT
} bgfx_access_t;
typedef enum bgfx_attrib
{
    BGFX_ATTRIB_POSITION,
    BGFX_ATTRIB_NORMAL,
    BGFX_ATTRIB_TANGENT,
    BGFX_ATTRIB_BITANGENT,
    BGFX_ATTRIB_COLOR0,
    BGFX_ATTRIB_COLOR1,
    BGFX_ATTRIB_INDICES,
    BGFX_ATTRIB_WEIGHT,
    BGFX_ATTRIB_TEXCOORD0,
    BGFX_ATTRIB_TEXCOORD1,
    BGFX_ATTRIB_TEXCOORD2,
    BGFX_ATTRIB_TEXCOORD3,
    BGFX_ATTRIB_TEXCOORD4,
    BGFX_ATTRIB_TEXCOORD5,
    BGFX_ATTRIB_TEXCOORD6,
    BGFX_ATTRIB_TEXCOORD7,
    BGFX_ATTRIB_COUNT
} bgfx_attrib_t;
typedef enum bgfx_attrib_type
{
    BGFX_ATTRIB_TYPE_UINT8,
    BGFX_ATTRIB_TYPE_UINT10,
    BGFX_ATTRIB_TYPE_INT16,
    BGFX_ATTRIB_TYPE_HALF,
    BGFX_ATTRIB_TYPE_FLOAT,
    BGFX_ATTRIB_TYPE_COUNT
} bgfx_attrib_type_t;
typedef enum bgfx_texture_format
{
    BGFX_TEXTURE_FORMAT_BC1,
    BGFX_TEXTURE_FORMAT_BC2,
    BGFX_TEXTURE_FORMAT_BC3,
    BGFX_TEXTURE_FORMAT_BC4,
    BGFX_TEXTURE_FORMAT_BC5,
    BGFX_TEXTURE_FORMAT_BC6H,
    BGFX_TEXTURE_FORMAT_BC7,
    BGFX_TEXTURE_FORMAT_ETC1,
    BGFX_TEXTURE_FORMAT_ETC2,
    BGFX_TEXTURE_FORMAT_ETC2A,
    BGFX_TEXTURE_FORMAT_ETC2A1,
    BGFX_TEXTURE_FORMAT_PTC12,
    BGFX_TEXTURE_FORMAT_PTC14,
    BGFX_TEXTURE_FORMAT_PTC12A,
    BGFX_TEXTURE_FORMAT_PTC14A,
    BGFX_TEXTURE_FORMAT_PTC22,
    BGFX_TEXTURE_FORMAT_PTC24,
    BGFX_TEXTURE_FORMAT_UNKNOWN,
    BGFX_TEXTURE_FORMAT_R1,
    BGFX_TEXTURE_FORMAT_A8,
    BGFX_TEXTURE_FORMAT_R8,
    BGFX_TEXTURE_FORMAT_R8I,
    BGFX_TEXTURE_FORMAT_R8U,
    BGFX_TEXTURE_FORMAT_R8S,
    BGFX_TEXTURE_FORMAT_R16,
    BGFX_TEXTURE_FORMAT_R16I,
    BGFX_TEXTURE_FORMAT_R16U,
    BGFX_TEXTURE_FORMAT_R16F,
    BGFX_TEXTURE_FORMAT_R16S,
    BGFX_TEXTURE_FORMAT_R32I,
    BGFX_TEXTURE_FORMAT_R32U,
    BGFX_TEXTURE_FORMAT_R32F,
    BGFX_TEXTURE_FORMAT_RG8,
    BGFX_TEXTURE_FORMAT_RG8I,
    BGFX_TEXTURE_FORMAT_RG8U,
    BGFX_TEXTURE_FORMAT_RG8S,
    BGFX_TEXTURE_FORMAT_RG16,
    BGFX_TEXTURE_FORMAT_RG16I,
    BGFX_TEXTURE_FORMAT_RG16U,
    BGFX_TEXTURE_FORMAT_RG16F,
    BGFX_TEXTURE_FORMAT_RG16S,
    BGFX_TEXTURE_FORMAT_RG32I,
    BGFX_TEXTURE_FORMAT_RG32U,
    BGFX_TEXTURE_FORMAT_RG32F,
    BGFX_TEXTURE_FORMAT_RGB9E5F,
    BGFX_TEXTURE_FORMAT_BGRA8,
    BGFX_TEXTURE_FORMAT_RGBA8,
    BGFX_TEXTURE_FORMAT_RGBA8I,
    BGFX_TEXTURE_FORMAT_RGBA8U,
    BGFX_TEXTURE_FORMAT_RGBA8S,
    BGFX_TEXTURE_FORMAT_RGBA16,
    BGFX_TEXTURE_FORMAT_RGBA16I,
    BGFX_TEXTURE_FORMAT_RGBA16U,
    BGFX_TEXTURE_FORMAT_RGBA16F,
    BGFX_TEXTURE_FORMAT_RGBA16S,
    BGFX_TEXTURE_FORMAT_RGBA32I,
    BGFX_TEXTURE_FORMAT_RGBA32U,
    BGFX_TEXTURE_FORMAT_RGBA32F,
    BGFX_TEXTURE_FORMAT_R5G6B5,
    BGFX_TEXTURE_FORMAT_RGBA4,
    BGFX_TEXTURE_FORMAT_RGB5A1,
    BGFX_TEXTURE_FORMAT_RGB10A2,
    BGFX_TEXTURE_FORMAT_R11G11B10F,
    BGFX_TEXTURE_FORMAT_UNKNOWN_DEPTH,
    BGFX_TEXTURE_FORMAT_D16,
    BGFX_TEXTURE_FORMAT_D24,
    BGFX_TEXTURE_FORMAT_D24S8,
    BGFX_TEXTURE_FORMAT_D32,
    BGFX_TEXTURE_FORMAT_D16F,
    BGFX_TEXTURE_FORMAT_D24F,
    BGFX_TEXTURE_FORMAT_D32F,
    BGFX_TEXTURE_FORMAT_D0S8,
    BGFX_TEXTURE_FORMAT_COUNT
} bgfx_texture_format_t;
typedef enum bgfx_uniform_type
{
    BGFX_UNIFORM_TYPE_INT1,
    BGFX_UNIFORM_TYPE_END,
    BGFX_UNIFORM_TYPE_VEC4,
    BGFX_UNIFORM_TYPE_MAT3,
    BGFX_UNIFORM_TYPE_MAT4,
    BGFX_UNIFORM_TYPE_COUNT
} bgfx_uniform_type_t;
typedef enum bgfx_backbuffer_ratio
{
    BGFX_BACKBUFFER_RATIO_EQUAL,
    BGFX_BACKBUFFER_RATIO_HALF,
    BGFX_BACKBUFFER_RATIO_QUARTER,
    BGFX_BACKBUFFER_RATIO_EIGHTH,
    BGFX_BACKBUFFER_RATIO_SIXTEENTH,
    BGFX_BACKBUFFER_RATIO_DOUBLE,
    BGFX_BACKBUFFER_RATIO_COUNT
} bgfx_backbuffer_ratio_t;
typedef enum bgfx_occlusion_query_result
{
    BGFX_OCCLUSION_QUERY_RESULT_INVISIBLE,
    BGFX_OCCLUSION_QUERY_RESULT_VISIBLE,
    BGFX_OCCLUSION_QUERY_RESULT_NORESULT,
    BGFX_OCCLUSION_QUERY_RESULT_COUNT
} bgfx_occlusion_query_result_t;
]]..(function()
	local out = ""

	local BGFX_HANDLE_T = function(name) out = out .. "typedef struct " .. name .. "{ uint16_t idx; } "..name.."_t;\n" end
	BGFX_HANDLE_T("bgfx_indirect_buffer_handle")
	BGFX_HANDLE_T("bgfx_dynamic_index_buffer_handle")
	BGFX_HANDLE_T("bgfx_dynamic_vertex_buffer_handle")
	BGFX_HANDLE_T("bgfx_frame_buffer_handle")
	BGFX_HANDLE_T("bgfx_index_buffer_handle")
	BGFX_HANDLE_T("bgfx_occlusion_query_handle")
	BGFX_HANDLE_T("bgfx_program_handle")
	BGFX_HANDLE_T("bgfx_shader_handle")
	BGFX_HANDLE_T("bgfx_texture_handle")
	BGFX_HANDLE_T("bgfx_uniform_handle")
	BGFX_HANDLE_T("bgfx_vertex_buffer_handle")
	BGFX_HANDLE_T("bgfx_vertex_decl_handle")

	return out
end)()..[[
typedef void (*bgfx_release_fn_t)(void* _ptr, void* _userData);
typedef struct bgfx_memory
{
    uint8_t* data;
    uint32_t size;
} bgfx_memory_t;
typedef struct bgfx_transform
{
    float* data;
    uint16_t num;
} bgfx_transform_t;
typedef struct bgfx_hmd_eye
{
    float rotation[4];
    float translation[3];
    float fov[4];
    float adjust[3];
    float pixelsPerTanAngle[2];
} bgfx_hmd_eye_t;
typedef struct bgfx_hmd
{
    bgfx_hmd_eye_t eye[2];
    uint16_t width;
    uint16_t height;
    uint32_t deviceWidth;
    uint32_t deviceHeight;
    uint8_t flags;
} bgfx_hmd_t;
typedef struct bgfx_stats
{
    uint64_t cpuTime;
    uint64_t cpuTimerFreq;
    uint64_t gpuTime;
    uint64_t gpuTimerFreq;
} bgfx_stats_t;
typedef struct bgfx_vertex_decl
{
    uint32_t hash;
    uint16_t stride;
    uint16_t offset[BGFX_ATTRIB_COUNT];
    uint16_t attributes[BGFX_ATTRIB_COUNT];
} bgfx_vertex_decl_t;
typedef struct bgfx_transient_index_buffer
{
    uint8_t* data;
    uint32_t size;
    bgfx_index_buffer_handle_t handle;
    uint32_t startIndex;
} bgfx_transient_index_buffer_t;
typedef struct bgfx_transient_vertex_buffer
{
    uint8_t* data;
    uint32_t size;
    uint32_t startVertex;
    uint16_t stride;
    bgfx_vertex_buffer_handle_t handle;
    bgfx_vertex_decl_handle_t decl;
} bgfx_transient_vertex_buffer_t;
typedef struct bgfx_instance_data_buffer
{
    uint8_t* data;
    uint32_t size;
    uint32_t offset;
    uint32_t num;
    uint16_t stride;
    bgfx_vertex_buffer_handle_t handle;
} bgfx_instance_data_buffer_t;
typedef struct bgfx_texture_info
{
    bgfx_texture_format_t format;
    uint32_t storageSize;
    uint16_t width;
    uint16_t height;
    uint16_t depth;
    uint8_t numMips;
    uint8_t bitsPerPixel;
    bool    cubeMap;
} bgfx_texture_info_t;
typedef struct bgfx_caps_gpu
{
    uint16_t vendorId;
    uint16_t deviceId;
} bgfx_caps_gpu_t;
typedef struct bgfx_caps
{
    bgfx_renderer_type_t rendererType;
    uint64_t supported;
    uint32_t maxDrawCalls;
    uint16_t maxTextureSize;
    uint16_t maxViews;
    uint8_t  maxFBAttachments;
    uint8_t  numGPUs;
    uint16_t vendorId;
    uint16_t deviceId;
    bgfx_caps_gpu_t gpu[4];
    uint16_t formats[BGFX_TEXTURE_FORMAT_COUNT];
} bgfx_caps_t;
typedef enum bgfx_fatal
{
    BGFX_FATAL_DEBUG_CHECK,
    BGFX_FATAL_MINIMUM_REQUIRED_SPECS,
    BGFX_FATAL_INVALID_SHADER,
    BGFX_FATAL_UNABLE_TO_INITIALIZE,
    BGFX_FATAL_UNABLE_TO_CREATE_TEXTURE,
    BGFX_FATAL_DEVICE_LOST,
    BGFX_FATAL_COUNT
} bgfx_fatal_t;
typedef struct bgfx_callback_interface
{
    const struct bgfx_callback_vtbl* vtbl;
} bgfx_callback_interface_t;
typedef struct bgfx_callback_vtbl
{
    void (*fatal)(bgfx_callback_interface_t* _this, bgfx_fatal_t _code, const char* _str);
    void (*trace_vargs)(bgfx_callback_interface_t* _this, const char* _filePath, uint16_t _line, const char* _format, va_list _argList);
    uint32_t (*cache_read_size)(bgfx_callback_interface_t* _this, uint64_t _id);
    bool (*cache_read)(bgfx_callback_interface_t* _this, uint64_t _id, void* _data, uint32_t _size);
    void (*cache_write)(bgfx_callback_interface_t* _this, uint64_t _id, const void* _data, uint32_t _size);
    void (*screen_shot)(bgfx_callback_interface_t* _this, const char* _filePath, uint32_t _width, uint32_t _height, uint32_t _pitch, const void* _data, uint32_t _size, bool _yflip);
    void (*capture_begin)(bgfx_callback_interface_t* _this, uint32_t _width, uint32_t _height, uint32_t _pitch, bgfx_texture_format_t _format, bool _yflip);
    void (*capture_end)(bgfx_callback_interface_t* _this);
    void (*capture_frame)(bgfx_callback_interface_t* _this, const void* _data, uint32_t _size);
} bgfx_callback_vtbl_t;
typedef struct bgfx_allocator_interface
{
    const struct bgfx_allocator_vtbl* vtbl;
} bgfx_allocator_interface_t;
typedef struct bgfx_allocator_vtbl
{
    void* (*realloc)(bgfx_allocator_interface_t* _this, void* _ptr, size_t _size, size_t _align, const char* _file, uint32_t _line);
} bgfx_allocator_vtbl_t;

typedef enum bgfx_render_frame
{
    BGFX_RENDER_FRAME_NO_CONTEXT,
    BGFX_RENDER_FRAME_RENDER,
    BGFX_RENDER_FRAME_EXITING,

    BGFX_RENDER_FRAME_COUNT

} bgfx_render_frame_t;

bgfx_render_frame_t bgfx_render_frame();

typedef struct bgfx_platform_data
{
    void* ndt;
    void* nwh;
    void* context;
    void* backBuffer;
    void* backBufferDS;

} bgfx_platform_data_t;

typedef struct bgfx_interface_vtbl
{
    bgfx_render_frame_t (*render_frame)();
    void (*set_platform_data)(bgfx_platform_data_t* _pd);
    void (*vertex_decl_begin)(bgfx_vertex_decl_t* _decl, bgfx_renderer_type_t _renderer);
    void (*vertex_decl_add)(bgfx_vertex_decl_t* _decl, bgfx_attrib_t _attrib, uint8_t _num, bgfx_attrib_type_t _type, bool _normalized, bool _asInt);
    void (*vertex_decl_skip)(bgfx_vertex_decl_t* _decl, uint8_t _num);
    void (*vertex_decl_end)(bgfx_vertex_decl_t* _decl);
    void (*vertex_pack)(const float _input[4], bool _inputNormalized, bgfx_attrib_t _attr, const bgfx_vertex_decl_t* _decl, void* _data, uint32_t _index);
    void (*vertex_unpack)(float _output[4], bgfx_attrib_t _attr, const bgfx_vertex_decl_t* _decl, const void* _data, uint32_t _index);
    void (*vertex_convert)(const bgfx_vertex_decl_t* _destDecl, void* _destData, const bgfx_vertex_decl_t* _srcDecl, const void* _srcData, uint32_t _num);
    uint16_t (*weld_vertices)(uint16_t* _output, const bgfx_vertex_decl_t* _decl, const void* _data, uint16_t _num, float _epsilon);
    void (*image_swizzle_bgra8)(uint32_t _width, uint32_t _height, uint32_t _pitch, const void* _src, void* _dst);
    void (*image_rgba8_downsample_2x2)(uint32_t _width, uint32_t _height, uint32_t _pitch, const void* _src, void* _dst);
    uint8_t (*get_supported_renderers)(bgfx_renderer_type_t _enum[BGFX_RENDERER_TYPE_COUNT]);
    const char* (*get_renderer_name)(bgfx_renderer_type_t _type);
    bool (*init)(bgfx_renderer_type_t _type, uint16_t _vendorId, uint16_t _deviceId, bgfx_callback_interface_t* _callback, bgfx_allocator_interface_t* _allocator);
    void (*shutdown)();
    void (*reset)(uint32_t _width, uint32_t _height, uint32_t _flags);
    uint32_t (*frame)();
    bgfx_renderer_type_t (*get_renderer_type)();
    const bgfx_caps_t* (*get_caps)();
    const bgfx_hmd_t* (*get_hmd)();
    const bgfx_stats_t* (*get_stats)();
    const bgfx_memory_t* (*alloc)(uint32_t _size);
    const bgfx_memory_t* (*copy)(const void* _data, uint32_t _size);
    const bgfx_memory_t* (*make_ref)(const void* _data, uint32_t _size);
    const bgfx_memory_t* (*make_ref_release)(const void* _data, uint32_t _size, bgfx_release_fn_t _releaseFn, void* _userData);
    void (*set_debug)(uint32_t _debug);
    void (*dbg_text_clear)(uint8_t _attr, bool _small);
    void (*dbg_text_printf)(uint16_t _x, uint16_t _y, uint8_t _attr, const char* _format, ...);
    void (*dbg_text_image)(uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const void* _data, uint16_t _pitch);
    bgfx_index_buffer_handle_t (*create_index_buffer)(const bgfx_memory_t* _mem, uint16_t _flags);
    void (*destroy_index_buffer)(bgfx_index_buffer_handle_t _handle);
    bgfx_vertex_buffer_handle_t (*create_vertex_buffer)(const bgfx_memory_t* _mem, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
    void (*destroy_vertex_buffer)(bgfx_vertex_buffer_handle_t _handle);
    bgfx_dynamic_index_buffer_handle_t (*create_dynamic_index_buffer)(uint32_t _num, uint16_t _flags);
    bgfx_dynamic_index_buffer_handle_t (*create_dynamic_index_buffer_mem)(const bgfx_memory_t* _mem, uint16_t _flags);
    void (*update_dynamic_index_buffer)(bgfx_dynamic_index_buffer_handle_t _handle, uint32_t _startIndex, const bgfx_memory_t* _mem);
    void (*destroy_dynamic_index_buffer)(bgfx_dynamic_index_buffer_handle_t _handle);
    bgfx_dynamic_vertex_buffer_handle_t (*create_dynamic_vertex_buffer)(uint32_t _num, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
    bgfx_dynamic_vertex_buffer_handle_t (*create_dynamic_vertex_buffer_mem)(const bgfx_memory_t* _mem, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
    void (*update_dynamic_vertex_buffer)(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, const bgfx_memory_t* _mem);
    void (*destroy_dynamic_vertex_buffer)(bgfx_dynamic_vertex_buffer_handle_t _handle);
    bool (*check_avail_transient_index_buffer)(uint32_t _num);
    bool (*check_avail_transient_vertex_buffer)(uint32_t _num, const bgfx_vertex_decl_t* _decl);
    bool (*check_avail_instance_data_buffer)(uint32_t _num, uint16_t _stride);
    bool (*check_avail_transient_buffers)(uint32_t _numVertices, const bgfx_vertex_decl_t* _decl, uint32_t _numIndices);
    void (*alloc_transient_index_buffer)(bgfx_transient_index_buffer_t* _tib, uint32_t _num);
    void (*alloc_transient_vertex_buffer)(bgfx_transient_vertex_buffer_t* _tvb, uint32_t _num, const bgfx_vertex_decl_t* _decl);
    bool (*alloc_transient_buffers)(bgfx_transient_vertex_buffer_t* _tvb, const bgfx_vertex_decl_t* _decl, uint32_t _numVertices, bgfx_transient_index_buffer_t* _tib, uint32_t _numIndices);
    const bgfx_instance_data_buffer_t* (*alloc_instance_data_buffer)(uint32_t _num, uint16_t _stride);
    bgfx_indirect_buffer_handle_t (*create_indirect_buffer)(uint32_t _num);
    void (*destroy_indirect_buffer)(bgfx_indirect_buffer_handle_t _handle);
    bgfx_shader_handle_t (*create_shader)(const bgfx_memory_t* _mem);
    uint16_t (*get_shader_uniforms)(bgfx_shader_handle_t _handle, bgfx_uniform_handle_t* _uniforms, uint16_t _max);
    void (*destroy_shader)(bgfx_shader_handle_t _handle);
    bgfx_program_handle_t (*create_program)(bgfx_shader_handle_t _vsh, bgfx_shader_handle_t _fsh, bool _destroyShaders);
    bgfx_program_handle_t (*create_compute_program)(bgfx_shader_handle_t _csh, bool _destroyShaders);
    void (*destroy_program)(bgfx_program_handle_t _handle);
    void (*calc_texture_size)(bgfx_texture_info_t* _info, uint16_t _width, uint16_t _height, uint16_t _depth, bool _cubeMap, uint8_t _numMips, bgfx_texture_format_t _format);
    bgfx_texture_handle_t (*create_texture)(const bgfx_memory_t* _mem, uint32_t _flags, uint8_t _skip, bgfx_texture_info_t* _info);
    bgfx_texture_handle_t (*create_texture_2d)(uint16_t _width, uint16_t _height, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags, const bgfx_memory_t* _mem);
    bgfx_texture_handle_t (*create_texture_2d_scaled)(bgfx_backbuffer_ratio_t _ratio, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags);
    bgfx_texture_handle_t (*create_texture_3d)(uint16_t _width, uint16_t _height, uint16_t _depth, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags, const bgfx_memory_t* _mem);
    bgfx_texture_handle_t (*create_texture_cube)(uint16_t _size, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags, const bgfx_memory_t* _mem);
    void (*update_texture_2d)(bgfx_texture_handle_t _handle, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const bgfx_memory_t* _mem, uint16_t _pitch);
    void (*update_texture_3d)(bgfx_texture_handle_t _handle, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _z, uint16_t _width, uint16_t _height, uint16_t _depth, const bgfx_memory_t* _mem);
    void (*update_texture_cube)(bgfx_texture_handle_t _handle, uint8_t _side, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const bgfx_memory_t* _mem, uint16_t _pitch);
    void (*destroy_texture)(bgfx_texture_handle_t _handle);
    bgfx_frame_buffer_handle_t (*create_frame_buffer)(uint16_t _width, uint16_t _height, bgfx_texture_format_t _format, uint32_t _textureFlags);
    bgfx_frame_buffer_handle_t (*create_frame_buffer_scaled)(bgfx_backbuffer_ratio_t _ratio, bgfx_texture_format_t _format, uint32_t _textureFlags);
    bgfx_frame_buffer_handle_t (*create_frame_buffer_from_handles)(uint8_t _num, const bgfx_texture_handle_t* _handles, bool _destroyTextures);
    bgfx_frame_buffer_handle_t (*create_frame_buffer_from_nwh)(void* _nwh, uint16_t _width, uint16_t _height, bgfx_texture_format_t _depthFormat);
    void (*destroy_frame_buffer)(bgfx_frame_buffer_handle_t _handle);
    bgfx_uniform_handle_t (*create_uniform)(const char* _name, bgfx_uniform_type_t _type, uint16_t _num);
    void (*destroy_uniform)(bgfx_uniform_handle_t _handle);
    bgfx_occlusion_query_handle_t (*create_occlusion_query)();
    bgfx_occlusion_query_result_t (*get_result)(bgfx_occlusion_query_handle_t _handle);
    void (*destroy_occlusion_query)(bgfx_occlusion_query_handle_t _handle);
    void (*set_palette_color)(uint8_t _index, const float _rgba[4]);
    void (*set_view_name)(uint8_t _id, const char* _name);
    void (*set_view_rect)(uint8_t _id, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
    void (*set_view_scissor)(uint8_t _id, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
    void (*set_view_clear)(uint8_t _id, uint16_t _flags, uint32_t _rgba, float _depth, uint8_t _stencil);
    void (*set_view_clear_mrt)(uint8_t _id, uint16_t _flags, float _depth, uint8_t _stencil, uint8_t _0, uint8_t _1, uint8_t _2, uint8_t _3, uint8_t _4, uint8_t _5, uint8_t _6, uint8_t _7);
    void (*set_view_seq)(uint8_t _id, bool _enabled);
    void (*set_view_frame_buffer)(uint8_t _id, bgfx_frame_buffer_handle_t _handle);
    void (*set_view_transform)(uint8_t _id, const void* _view, const void* _proj);
    void (*set_view_transform_stereo)(uint8_t _id, const void* _view, const void* _projL, uint8_t _flags, const void* _projR);
    void (*set_view_remap)(uint8_t _id, uint8_t _num, const void* _remap);
    void (*set_marker)(const char* _marker);
    void (*set_state)(uint64_t _state, uint32_t _rgba);
    void (*set_condition)(bgfx_occlusion_query_handle_t _handle, bool _visible);
    void (*set_stencil)(uint32_t _fstencil, uint32_t _bstencil);
    uint16_t (*set_scissor)(uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
    void (*set_scissor_cached)(uint16_t _cache);
    uint32_t (*set_transform)(const void* _mtx, uint16_t _num);
    uint32_t (*alloc_transform)(bgfx_transform_t* _transform, uint16_t _num);
    void (*set_transform_cached)(uint32_t _cache, uint16_t _num);
    void (*set_uniform)(bgfx_uniform_handle_t _handle, const void* _value, uint16_t _num);
    void (*set_index_buffer)(bgfx_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
    void (*set_dynamic_index_buffer)(bgfx_dynamic_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
    void (*set_transient_index_buffer)(const bgfx_transient_index_buffer_t* _tib, uint32_t _firstIndex, uint32_t _numIndices);
    void (*set_vertex_buffer)(bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _numVertices);
    void (*set_dynamic_vertex_buffer)(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _numVertices);
    void (*set_transient_vertex_buffer)(const bgfx_transient_vertex_buffer_t* _tvb, uint32_t _startVertex, uint32_t _numVertices);
    void (*set_instance_data_buffer)(const bgfx_instance_data_buffer_t* _idb, uint32_t _num);
    void (*set_instance_data_from_vertex_buffer)(bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
    void (*set_instance_data_from_dynamic_vertex_buffer)(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
    void (*set_texture)(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_texture_handle_t _handle, uint32_t _flags);
    void (*set_texture_from_frame_buffer)(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_frame_buffer_handle_t _handle, uint8_t _attachment, uint32_t _flags);
    uint32_t (*touch)(uint8_t _id);
    uint32_t (*submit)(uint8_t _id, bgfx_program_handle_t _handle, int32_t _depth);
    uint32_t (*submit_occlusion_query)(uint8_t _id, bgfx_program_handle_t _program, bgfx_occlusion_query_handle_t _occlusionQuery, int32_t _depth);
    uint32_t (*submit_indirect)(uint8_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, int32_t _depth);
    void (*set_image)(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_texture_handle_t _handle, uint8_t _mip, bgfx_access_t _access, bgfx_texture_format_t _format);
    void (*set_image_from_frame_buffer)(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_frame_buffer_handle_t _handle, uint8_t _attachment, bgfx_access_t _access, bgfx_texture_format_t _format);
    void (*set_compute_index_buffer)(uint8_t _stage, bgfx_index_buffer_handle_t _handle, bgfx_access_t _access);
    void (*set_compute_vertex_buffer)(uint8_t _stage, bgfx_vertex_buffer_handle_t _handle, bgfx_access_t _access);
    void (*set_compute_dynamic_index_buffer)(uint8_t _stage, bgfx_dynamic_index_buffer_handle_t _handle, bgfx_access_t _access);
    void (*set_compute_dynamic_vertex_buffer)(uint8_t _stage, bgfx_dynamic_vertex_buffer_handle_t _handle, bgfx_access_t _access);
    void (*set_compute_indirect_buffer)(uint8_t _stage, bgfx_indirect_buffer_handle_t _handle, bgfx_access_t _access);
    uint32_t (*dispatch)(uint8_t _id, bgfx_program_handle_t _handle, uint16_t _numX, uint16_t _numY, uint16_t _numZ, uint8_t _flags);
    uint32_t (*dispatch_indirect)(uint8_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, uint8_t _flags);
    void (*discard)();
    void (*blit)(uint8_t _id, bgfx_texture_handle_t _dst, uint8_t _dstMip, uint16_t _dstX, uint16_t _dstY, uint16_t _dstZ, bgfx_texture_handle_t _src, uint8_t _srcMip, uint16_t _srcX, uint16_t _srcY, uint16_t _srcZ, uint16_t _width, uint16_t _height, uint16_t _depth);
    void (*save_screen_shot)(const char* _filePath);
} bgfx_interface_vtbl_t;
typedef bgfx_interface_vtbl_t* (*PFN_BGFX_GET_INTERFACE)(uint32_t _version);
void bgfx_vertex_decl_begin(bgfx_vertex_decl_t* _decl, bgfx_renderer_type_t _renderer);
void bgfx_vertex_decl_add(bgfx_vertex_decl_t* _decl, bgfx_attrib_t _attrib, uint8_t _num, bgfx_attrib_type_t _type, bool _normalized, bool _asInt);
void bgfx_vertex_decl_skip(bgfx_vertex_decl_t* _decl, uint8_t _num);
void bgfx_vertex_decl_end(bgfx_vertex_decl_t* _decl);
void bgfx_vertex_pack(const float _input[4], bool _inputNormalized, bgfx_attrib_t _attr, const bgfx_vertex_decl_t* _decl, void* _data, uint32_t _index);
void bgfx_vertex_unpack(float _output[4], bgfx_attrib_t _attr, const bgfx_vertex_decl_t* _decl, const void* _data, uint32_t _index);
void bgfx_vertex_convert(const bgfx_vertex_decl_t* _destDecl, void* _destData, const bgfx_vertex_decl_t* _srcDecl, const void* _srcData, uint32_t _num);
uint16_t bgfx_weld_vertices(uint16_t* _output, const bgfx_vertex_decl_t* _decl, const void* _data, uint16_t _num, float _epsilon);
void bgfx_image_swizzle_bgra8(uint32_t _width, uint32_t _height, uint32_t _pitch, const void* _src, void* _dst);
void bgfx_image_rgba8_downsample_2x2(uint32_t _width, uint32_t _height, uint32_t _pitch, const void* _src, void* _dst);
uint8_t bgfx_get_supported_renderers(bgfx_renderer_type_t _enum[BGFX_RENDERER_TYPE_COUNT]);
const char* bgfx_get_renderer_name(bgfx_renderer_type_t _type);
bool bgfx_init(bgfx_renderer_type_t _type, uint16_t _vendorId, uint16_t _deviceId, bgfx_callback_interface_t* _callback, bgfx_allocator_interface_t* _allocator);
void bgfx_shutdown();
void bgfx_reset(uint32_t _width, uint32_t _height, uint32_t _flags);
uint32_t bgfx_frame();
bgfx_renderer_type_t bgfx_get_renderer_type();
const bgfx_caps_t* bgfx_get_caps();
const bgfx_hmd_t* bgfx_get_hmd();
const bgfx_stats_t* bgfx_get_stats();
const bgfx_memory_t* bgfx_alloc(uint32_t _size);
const bgfx_memory_t* bgfx_copy(const void* _data, uint32_t _size);
const bgfx_memory_t* bgfx_make_ref(const void* _data, uint32_t _size);
const bgfx_memory_t* bgfx_make_ref_release(const void* _data, uint32_t _size, bgfx_release_fn_t _releaseFn, void* _userData);
void bgfx_set_debug(uint32_t _debug);
void bgfx_dbg_text_clear(uint8_t _attr, bool _small);
void bgfx_dbg_text_printf(uint16_t _x, uint16_t _y, uint8_t _attr, const char* _format, ...);
void bgfx_dbg_text_image(uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const void* _data, uint16_t _pitch);
bgfx_index_buffer_handle_t bgfx_create_index_buffer(const bgfx_memory_t* _mem, uint16_t _flags);
void bgfx_destroy_index_buffer(bgfx_index_buffer_handle_t _handle);
bgfx_vertex_buffer_handle_t bgfx_create_vertex_buffer(const bgfx_memory_t* _mem, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
void bgfx_destroy_vertex_buffer(bgfx_vertex_buffer_handle_t _handle);
bgfx_dynamic_index_buffer_handle_t bgfx_create_dynamic_index_buffer(uint32_t _num, uint16_t _flags);
bgfx_dynamic_index_buffer_handle_t bgfx_create_dynamic_index_buffer_mem(const bgfx_memory_t* _mem, uint16_t _flags);
void bgfx_update_dynamic_index_buffer(bgfx_dynamic_index_buffer_handle_t _handle, uint32_t _startIndex, const bgfx_memory_t* _mem);
void bgfx_destroy_dynamic_index_buffer(bgfx_dynamic_index_buffer_handle_t _handle);
bgfx_dynamic_vertex_buffer_handle_t bgfx_create_dynamic_vertex_buffer(uint32_t _num, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
bgfx_dynamic_vertex_buffer_handle_t bgfx_create_dynamic_vertex_buffer_mem(const bgfx_memory_t* _mem, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
void bgfx_update_dynamic_vertex_buffer(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, const bgfx_memory_t* _mem);
void bgfx_destroy_dynamic_vertex_buffer(bgfx_dynamic_vertex_buffer_handle_t _handle);
bool bgfx_check_avail_transient_index_buffer(uint32_t _num);
bool bgfx_check_avail_transient_vertex_buffer(uint32_t _num, const bgfx_vertex_decl_t* _decl);
bool bgfx_check_avail_instance_data_buffer(uint32_t _num, uint16_t _stride);
bool bgfx_check_avail_transient_buffers(uint32_t _numVertices, const bgfx_vertex_decl_t* _decl, uint32_t _numIndices);
void bgfx_alloc_transient_index_buffer(bgfx_transient_index_buffer_t* _tib, uint32_t _num);
void bgfx_alloc_transient_vertex_buffer(bgfx_transient_vertex_buffer_t* _tvb, uint32_t _num, const bgfx_vertex_decl_t* _decl);
bool bgfx_alloc_transient_buffers(bgfx_transient_vertex_buffer_t* _tvb, const bgfx_vertex_decl_t* _decl, uint32_t _numVertices, bgfx_transient_index_buffer_t* _tib, uint32_t _numIndices);
const bgfx_instance_data_buffer_t* bgfx_alloc_instance_data_buffer(uint32_t _num, uint16_t _stride);
bgfx_indirect_buffer_handle_t bgfx_create_indirect_buffer(uint32_t _num);
void bgfx_destroy_indirect_buffer(bgfx_indirect_buffer_handle_t _handle);
bgfx_shader_handle_t bgfx_create_shader(const bgfx_memory_t* _mem);
uint16_t bgfx_get_shader_uniforms(bgfx_shader_handle_t _handle, bgfx_uniform_handle_t* _uniforms, uint16_t _max);
void bgfx_destroy_shader(bgfx_shader_handle_t _handle);
bgfx_program_handle_t bgfx_create_program(bgfx_shader_handle_t _vsh, bgfx_shader_handle_t _fsh, bool _destroyShaders);
bgfx_program_handle_t bgfx_create_compute_program(bgfx_shader_handle_t _csh, bool _destroyShaders);
void bgfx_destroy_program(bgfx_program_handle_t _handle);
void bgfx_calc_texture_size(bgfx_texture_info_t* _info, uint16_t _width, uint16_t _height, uint16_t _depth, bool _cubeMap, uint8_t _numMips, bgfx_texture_format_t _format);
bgfx_texture_handle_t bgfx_create_texture(const bgfx_memory_t* _mem, uint32_t _flags, uint8_t _skip, bgfx_texture_info_t* _info);
bgfx_texture_handle_t bgfx_create_texture_2d(uint16_t _width, uint16_t _height, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags, const bgfx_memory_t* _mem);
bgfx_texture_handle_t bgfx_create_texture_2d_scaled(bgfx_backbuffer_ratio_t _ratio, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags);
bgfx_texture_handle_t bgfx_create_texture_3d(uint16_t _width, uint16_t _height, uint16_t _depth, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags, const bgfx_memory_t* _mem);
bgfx_texture_handle_t bgfx_create_texture_cube(uint16_t _size, uint8_t _numMips, bgfx_texture_format_t _format, uint32_t _flags, const bgfx_memory_t* _mem);
void bgfx_update_texture_2d(bgfx_texture_handle_t _handle, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const bgfx_memory_t* _mem, uint16_t _pitch);
void bgfx_update_texture_3d(bgfx_texture_handle_t _handle, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _z, uint16_t _width, uint16_t _height, uint16_t _depth, const bgfx_memory_t* _mem);
void bgfx_update_texture_cube(bgfx_texture_handle_t _handle, uint8_t _side, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const bgfx_memory_t* _mem, uint16_t _pitch);
void bgfx_read_texture(bgfx_texture_handle_t _handle, void* _data);
void bgfx_read_frame_buffer(bgfx_frame_buffer_handle_t _handle, uint8_t _attachment, void* _data);
void bgfx_destroy_texture(bgfx_texture_handle_t _handle);
bgfx_frame_buffer_handle_t bgfx_create_frame_buffer(uint16_t _width, uint16_t _height, bgfx_texture_format_t _format, uint32_t _textureFlags);
bgfx_frame_buffer_handle_t bgfx_create_frame_buffer_scaled(bgfx_backbuffer_ratio_t _ratio, bgfx_texture_format_t _format, uint32_t _textureFlags);
bgfx_frame_buffer_handle_t bgfx_create_frame_buffer_from_handles(uint8_t _num, const bgfx_texture_handle_t* _handles, bool _destroyTextures);
bgfx_frame_buffer_handle_t bgfx_create_frame_buffer_from_nwh(void* _nwh, uint16_t _width, uint16_t _height, bgfx_texture_format_t _depthFormat);
void bgfx_destroy_frame_buffer(bgfx_frame_buffer_handle_t _handle);
bgfx_uniform_handle_t bgfx_create_uniform(const char* _name, bgfx_uniform_type_t _type, uint16_t _num);
void bgfx_destroy_uniform(bgfx_uniform_handle_t _handle);
bgfx_occlusion_query_handle_t bgfx_create_occlusion_query();
bgfx_occlusion_query_result_t bgfx_get_result(bgfx_occlusion_query_handle_t _handle);
void bgfx_destroy_occlusion_query(bgfx_occlusion_query_handle_t _handle);
void bgfx_set_palette_color(uint8_t _index, const float _rgba[4]);
void bgfx_set_view_name(uint8_t _id, const char* _name);
void bgfx_set_view_rect(uint8_t _id, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
void bgfx_set_view_rect_auto(uint8_t _id, uint16_t _x, uint16_t _y, bgfx_backbuffer_ratio_t _ratio);
void bgfx_set_view_scissor(uint8_t _id, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
void bgfx_set_view_clear(uint8_t _id, uint16_t _flags, uint32_t _rgba, float _depth, uint8_t _stencil);
void bgfx_set_view_clear_mrt(uint8_t _id, uint16_t _flags, float _depth, uint8_t _stencil, uint8_t _0, uint8_t _1, uint8_t _2, uint8_t _3, uint8_t _4, uint8_t _5, uint8_t _6, uint8_t _7);
void bgfx_set_view_seq(uint8_t _id, bool _enabled);
void bgfx_set_view_frame_buffer(uint8_t _id, bgfx_frame_buffer_handle_t _handle);
void bgfx_set_view_transform(uint8_t _id, const void* _view, const void* _proj);
void bgfx_set_view_transform_stereo(uint8_t _id, const void* _view, const void* _projL, uint8_t _flags, const void* _projR);
void bgfx_set_view_remap(uint8_t _id, uint8_t _num, const void* _remap);
void bgfx_reset_view(uint8_t _id);
void bgfx_set_marker(const char* _marker);
void bgfx_set_state(uint64_t _state, uint32_t _rgba);
void bgfx_set_condition(bgfx_occlusion_query_handle_t _handle, bool _visible);
void bgfx_set_stencil(uint32_t _fstencil, uint32_t _bstencil);
uint16_t bgfx_set_scissor(uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
void bgfx_set_scissor_cached(uint16_t _cache);
uint32_t bgfx_set_transform(const void* _mtx, uint16_t _num);
uint32_t bgfx_alloc_transform(bgfx_transform_t* _transform, uint16_t _num);
void bgfx_set_transform_cached(uint32_t _cache, uint16_t _num);
void bgfx_set_uniform(bgfx_uniform_handle_t _handle, const void* _value, uint16_t _num);
void bgfx_set_index_buffer(bgfx_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
void bgfx_set_dynamic_index_buffer(bgfx_dynamic_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
void bgfx_set_transient_index_buffer(const bgfx_transient_index_buffer_t* _tib, uint32_t _firstIndex, uint32_t _numIndices);
void bgfx_set_vertex_buffer(bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _numVertices);
void bgfx_set_dynamic_vertex_buffer(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _numVertices);
void bgfx_set_transient_vertex_buffer(const bgfx_transient_vertex_buffer_t* _tvb, uint32_t _startVertex, uint32_t _numVertices);
void bgfx_set_instance_data_buffer(const bgfx_instance_data_buffer_t* _idb, uint32_t _num);
void bgfx_set_instance_data_from_vertex_buffer(bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
void bgfx_set_instance_data_from_dynamic_vertex_buffer(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
void bgfx_set_texture(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_texture_handle_t _handle, uint32_t _flags);
void bgfx_set_texture_from_frame_buffer(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_frame_buffer_handle_t _handle, uint8_t _attachment, uint32_t _flags);
uint32_t bgfx_touch(uint8_t _id);
uint32_t bgfx_submit(uint8_t _id, bgfx_program_handle_t _handle, int32_t _depth);
uint32_t bgfx_submit_occlusion_query(uint8_t _id, bgfx_program_handle_t _program, bgfx_occlusion_query_handle_t _occlusionQuery, int32_t _depth);
uint32_t bgfx_submit_indirect(uint8_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, int32_t _depth);
void bgfx_set_image(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_texture_handle_t _handle, uint8_t _mip, bgfx_access_t _access, bgfx_texture_format_t _format);
void bgfx_set_image_from_frame_buffer(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_frame_buffer_handle_t _handle, uint8_t _attachment, bgfx_access_t _access, bgfx_texture_format_t _format);
void bgfx_set_compute_index_buffer(uint8_t _stage, bgfx_index_buffer_handle_t _handle, bgfx_access_t _access);
void bgfx_set_compute_vertex_buffer(uint8_t _stage, bgfx_vertex_buffer_handle_t _handle, bgfx_access_t _access);
void bgfx_set_compute_dynamic_index_buffer(uint8_t _stage, bgfx_dynamic_index_buffer_handle_t _handle, bgfx_access_t _access);
void bgfx_set_compute_dynamic_vertex_buffer(uint8_t _stage, bgfx_dynamic_vertex_buffer_handle_t _handle, bgfx_access_t _access);
void bgfx_set_compute_indirect_buffer(uint8_t _stage, bgfx_indirect_buffer_handle_t _handle, bgfx_access_t _access);
uint32_t bgfx_dispatch(uint8_t _id, bgfx_program_handle_t _handle, uint16_t _numX, uint16_t _numY, uint16_t _numZ, uint8_t _flags);
uint32_t bgfx_dispatch_indirect(uint8_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, uint8_t _flags);
void bgfx_discard();
void bgfx_blit(uint8_t _id, bgfx_texture_handle_t _dst, uint8_t _dstMip, uint16_t _dstX, uint16_t _dstY, uint16_t _dstZ, bgfx_texture_handle_t _src, uint8_t _srcMip, uint16_t _srcX, uint16_t _srcY, uint16_t _srcZ, uint16_t _width, uint16_t _height, uint16_t _depth);
void bgfx_blit_frame_buffer(uint8_t _id, bgfx_texture_handle_t _dst, uint8_t _dstMip, uint16_t _dstX, uint16_t _dstY, uint16_t _dstZ, bgfx_frame_buffer_handle_t _src, uint8_t _attachment, uint8_t _srcMip, uint16_t _srcX, uint16_t _srcY, uint16_t _srcZ, uint16_t _width, uint16_t _height, uint16_t _depth);
void bgfx_save_screen_shot(const char* _filePath);
]]

local ffi = require("ffi")

ffi.cdef(header)

local lib = ffi.load("bgfx")

local width  = 1280
local height = 720
local debug  = enums.BGFX_DEBUG_TEXT
local reset  = enums.BGFX_RESET_VSYNC

local sdl = require("graphics.ffi.sdl")
local info = ffi.new("SDL_SysWMinfo[1]")
sdl.GetWindowWMInfo(window.wnd.__ptr, info)

lib.set_platform_data({
	void* ndt;
    void* nwh;
    void* context;
    void* backBuffer;
    void* backBufferDS;
})
lib.bgfx_init(enums.BGFX_RENDERER_TYPE_COUNT, enums.BGFX_PCI_ID_NONE, 0, nil, nil)
lib.bgfx_reset(width, height, reset);

-- Enable debug text.
lib.bgfx_set_debug(debug);

bgfx_set_view_clear(0, bit.bor(enums.BGFX_CLEAR_COLOR, enums.BGFX_CLEAR_DEPTH), 0x303030ff, 1.0f, 0)

event.AddListener("Update", "bgfx", function()
	-- Set view 0 default viewport.
	lib.bgfx_set_view_rect(0, 0, 0, width, height)
	lib.bgfx_touch(0)


	lib.bgfx_dbg_text_clear(0, false);
	--lib.bgfx_dbg_text_image(width/2/8, 20-20, height/2/16, 6-6, 40, 12, s_logo, 160)
	lib.bgfx_dbg_text_printf(0, 1, 0x4f, "bgfx/examples/25-c99")
	lib.bgfx_dbg_text_printf(0, 2, 0x6f, "Description: Initialization and debug text with C99 API.")
	lib.bgfx_frame()
end)