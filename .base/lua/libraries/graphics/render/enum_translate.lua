local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

local enums = {
	texture = {
		wrap = {
			CLAMP_TO_EDGE = gl.e.GL_CLAMP_TO_EDGE, 
			CLAMP_TO_BORDER = gl.e.GL_CLAMP_TO_BORDER, 
			MIRRORED_REPEAT = gl.e.GL_MIRRORED_REPEAT, 
			REPEAT = gl.e.GL_REPEAT, 
			MIRROR_CLAMP_TO_EDGE = gl.e.GL_MIRROR_CLAMP_TO_EDGE,
		},
		
		min_filter = {
			NEAREST = gl.e.GL_NEAREST,
			LINEAR = gl.e.GL_LINEAR,
			NEAREST_MIPMAP_NEAREST = gl.e.GL_NEAREST_MIPMAP_NEAREST,
			LINEAR_MIPMAP_NEAREST = gl.e.GL_LINEAR_MIPMAP_NEAREST,
			NEAREST_MIPMAP_LINEAR = gl.e.GL_NEAREST_MIPMAP_LINEAR,
			LINEAR_MIPMAP_LINEAR = gl.e.GL_LINEAR_MIPMAP_LINEAR,
		},
		
		mag_filter = {
			NEAREST = gl.e.GL_NEAREST,
			LINEAR = gl.e.GL_LINEAR,
		},
			
		parameters = {
			DEPTH_STENCIL_MODE = gl.e.GL_DEPTH_STENCIL_TEXTURE_MODE, 
			BASE_LEVEL = gl.e.GL_TEXTURE_BASE_LEVEL, 
			COMPARE_FUNC = gl.e.GL_TEXTURE_COMPARE_FUNC, 
			COMPARE_MODE = gl.e.GL_TEXTURE_COMPARE_MODE, 
			LOD_BIAS = gl.e.GL_TEXTURE_LOD_BIAS, 
			MIN_FILTER = gl.e.GL_TEXTURE_MIN_FILTER, 
			MAG_FILTER = gl.e.GL_TEXTURE_MAG_FILTER, 
			MIN_LOD = gl.e.GL_TEXTURE_MIN_LOD, 
			MAX_LOD = gl.e.GL_TEXTURE_MAX_LOD, 
			MAX_LEVEL = gl.e.GL_TEXTURE_MAX_LEVEL, 
			SWIZZLE_R = gl.e.GL_TEXTURE_SWIZZLE_R, 
			SWIZZLE_G = gl.e.GL_TEXTURE_SWIZZLE_G, 
			SWIZZLE_B = gl.e.GL_TEXTURE_SWIZZLE_B, 
			SWIZZLE_A = gl.e.GL_TEXTURE_SWIZZLE_A, 
			WRAP_S = gl.e.GL_TEXTURE_WRAP_S, 
			WRAP_T = gl.e.GL_TEXTURE_WRAP_T, 
			WRAP_R = gl.e.GL_TEXTURE_WRAP_R,
			BORDER_COLOR = gl.e.GL_TEXTURE_BORDER_COLOR,
			SWIZZLE_RGBA = gl.e.GL_TEXTURE_SWIZZLE_RGBA,		
			DEPTH_TEXTURE_MODE = gl.e.GL_DEPTH_TEXTURE_MODE,
			ANISOTROPY = gl.e.GL_TEXTURE_MAX_ANISOTROPY_EXT,
		},
		
		format_type = {
			UNSIGNED_BYTE = gl.e.GL_UNSIGNED_BYTE, 
			BYTE = gl.e.GL_BYTE, 
			UNSIGNED_SHORT = gl.e.GL_UNSIGNED_SHORT, 
			SHORT = gl.e.GL_SHORT, 
			UNSIGNED_INT = gl.e.GL_UNSIGNED_INT, 
			INT = gl.e.GL_INT, 
			FLOAT = gl.e.GL_FLOAT, 
			UNSIGNED_BYTE_3_3_2 = gl.e.GL_UNSIGNED_BYTE_3_3_2, 
			UNSIGNED_BYTE_2_3_3_REV = gl.e.GL_UNSIGNED_BYTE_2_3_3_REV, 
			UNSIGNED_SHORT_5_6_5 = gl.e.GL_UNSIGNED_SHORT_5_6_5, 
			UNSIGNED_SHORT_5_6_5_REV = gl.e.GL_UNSIGNED_SHORT_5_6_5_REV, 
			UNSIGNED_SHORT_4_4_4_4 = gl.e.GL_UNSIGNED_SHORT_4_4_4_4, 
			UNSIGNED_SHORT_4_4_4_4_REV = gl.e.GL_UNSIGNED_SHORT_4_4_4_4_REV, 
			UNSIGNED_SHORT_5_5_5_1 = gl.e.GL_UNSIGNED_SHORT_5_5_5_1, 
			UNSIGNED_SHORT_1_5_5_5_REV = gl.e.GL_UNSIGNED_SHORT_1_5_5_5_REV, 
			UNSIGNED_INT_8_8_8_8 = gl.e.GL_UNSIGNED_INT_8_8_8_8, 
			UNSIGNED_INT_8_8_8_8_REV = gl.e.GL_UNSIGNED_INT_8_8_8_8_REV, 
			UNSIGNED_INT_10_10_10_2 = gl.e.GL_UNSIGNED_INT_10_10_10_2, 
			UNSIGNED_INT_2_10_10_10_REV = gl.e.GL_UNSIGNED_INT_2_10_10_10_REV,
		},
		
		upload_format = {
			ALPHA = gl.e.GL_ALPHA,
			RED = gl.e.GL_RED,
			RG = gl.e.GL_RG,
			RGB = gl.e.GL_RGB,
			BGR = gl.e.GL_BGR,
			RGBA = gl.e.GL_RGBA,
			BGRA = gl.e.GL_BGRA,
			RED_INTEGER = gl.e.GL_RED_INTEGER,
			RG_INTEGER = gl.e.GL_RG_INTEGER,
			RGB_INTEGER = gl.e.GL_RGB_INTEGER,
			BGR_INTEGER = gl.e.GL_BGR_INTEGER,
			RGBA_INTEGER = gl.e.GL_RGBA_INTEGER,
			BGRA_INTEGER = gl.e.GL_BGRA_INTEGER,
			STENCIL_INDEX = gl.e.GL_STENCIL_INDEX,
			DEPTH_COMPONENT = gl.e.GL_DEPTH_COMPONENT,
			DEPTH_STENCIL = gl.e.GL_DEPTH_STENCIL,
			
			COMPRESSED_RGB_S3TC_DXT1 = gl.e.GL_COMPRESSED_RGB_S3TC_DXT1_EXT, 
			COMPRESSED_SRGB_S3TC_DXT1 = gl.e.GL_COMPRESSED_SRGB_S3TC_DXT1_EXT,
			COMPRESSED_RGBA_S3TC_DXT1 = gl.e.GL_COMPRESSED_RGBA_S3TC_DXT1_EXT,
			COMPRESSED_SRGB_ALPHA_S3TC_DXT1 = gl.e.GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT,
			COMPRESSED_RGBA_S3TC_DXT3 = gl.e.GL_COMPRESSED_RGBA_S3TC_DXT3_EXT, 
			COMPRESSED_SRGB_ALPHA_S3TC_DXT3 = gl.e.GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT,
			COMPRESSED_RGBA_S3TC_DXT5 = gl.e.GL_COMPRESSED_RGBA_S3TC_DXT5_EXT, 
			COMPRESSED_SRGB_ALPHA_S3TC_DXT5 = gl.e.GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT,
		},
		internal_format = {
			A8 = gl.e.GL_ALPHA8,
			R8 = gl.e.GL_R8,
			R8_SNORM = gl.e.GL_R8_SNORM,
			R16 = gl.e.GL_R16,
			R16_SNORM = gl.e.GL_R16_SNORM,
			RG8 = gl.e.GL_RG8,
			RG8_SNORM = gl.e.GL_RG8_SNORM,
			RG16 = gl.e.GL_RG16,
			RG16_SNORM = gl.e.GL_RG16_SNORM,
			R3_G3_B2 = gl.e.GL_R3_G3_B2,
			RGB4 = gl.e.GL_RGB4,
			RGB5 = gl.e.GL_RGB5,
			RGB8 = gl.e.GL_RGB8,
			RGB8_SNORM = gl.e.GL_RGB8_SNORM,
			RGB10 = gl.e.GL_RGB10,
			RGB12 = gl.e.GL_RGB12,
			RGB16_SNORM = gl.e.GL_RGB16_SNORM,
			RGBA2 = gl.e.GL_RGBA2,
			RGBA4 = gl.e.GL_RGBA4,
			RGB5_A1 = gl.e.GL_RGB5_A1,
			RGBA8 = gl.e.GL_RGBA8,
			RGBA8_SNORM = gl.e.GL_RGBA8_SNORM,
			RGB10_A2 = gl.e.GL_RGB10_A2,
			RGB10_A2UI = gl.e.GL_RGB10_A2UI,
			RGBA12 = gl.e.GL_RGBA12,
			RGBA16 = gl.e.GL_RGBA16,
			SRGB8 = gl.e.GL_SRGB8,
			SRGB8_ALPHA8 = gl.e.GL_SRGB8_ALPHA8,
			R16F = gl.e.GL_R16F,
			RG16F = gl.e.GL_RG16F,
			RGB16F = gl.e.GL_RGB16F,
			RGBA16F = gl.e.GL_RGBA16F,
			R32F = gl.e.GL_R32F,
			RG32F = gl.e.GL_RG32F,
			RGB32F = gl.e.GL_RGB32F,
			RGBA32F = gl.e.GL_RGBA32F,
			R11F_G11F_B10F = gl.e.GL_R11F_G11F_B10F,
			RGB9_E5 = gl.e.GL_RGB9_E5,
			R8I = gl.e.GL_R8I,
			R8UI = gl.e.GL_R8UI,
			R16I = gl.e.GL_R16I,
			R16UI = gl.e.GL_R16UI,
			R32I = gl.e.GL_R32I,
			R32UI = gl.e.GL_R32UI,
			RG8I = gl.e.GL_RG8I,
			RG8UI = gl.e.GL_RG8UI,
			RG16I = gl.e.GL_RG16I,
			RG16UI = gl.e.GL_RG16UI,
			RG32I = gl.e.GL_RG32I,
			RG32UI = gl.e.GL_RG32UI,
			RGB8I = gl.e.GL_RGB8I,
			RGB8UI = gl.e.GL_RGB8UI,
			RGB16I = gl.e.GL_RGB16I,
			RGB16UI = gl.e.GL_RGB16UI,
			RGB32I = gl.e.GL_RGB32I,
			RGB32UI = gl.e.GL_RGB32UI,
			RGBA8I = gl.e.GL_RGBA8I,
			RGBA8UI = gl.e.GL_RGBA8UI,
			RGBA16I = gl.e.GL_RGBA16I,
			RGBA16UI = gl.e.GL_RGBA16UI,
			RGBA32I = gl.e.GL_RGBA32I,
			RGBA32UI = gl.e.GL_RGBA32UI,
			DEPTH_COMPONENT32F = gl.e.GL_DEPTH_COMPONENT32F,
			DEPTH_COMPONENT32 = gl.e.GL_DEPTH_COMPONENT32,
			DEPTH_COMPONENT24 = gl.e.GL_DEPTH_COMPONENT24,
			DEPTH_COMPONENT16 = gl.e.GL_DEPTH_COMPONENT16,
			DEPTH_STENCIL = gl.e.GL_DEPTH_STENCIL,
		},
		type = {
			["2D"] = gl.e.GL_TEXTURE_2D,
			["PROXY_2D"] = gl.e.GL_PROXY_TEXTURE_2D,
			["1D_ARRAY"] = gl.e.GL_TEXTURE_1D_ARRAY,
			["PROXY_1D_ARRAY"] = gl.e.GL_PROXY_TEXTURE_1D_ARRAY,
			["RECTANGLE"] = gl.e.GL_TEXTURE_RECTANGLE,
			["PROXY_RECTANGLE"] = gl.e.GL_PROXY_TEXTURE_RECTANGLE,
			["PROXY_CUBE_MAP"] = gl.e.GL_PROXY_TEXTURE_CUBE_MAP,
			["CUBEMAP"] = gl.e.GL_TEXTURE_CUBE_MAP,
		}
	}
}

function render.GetAvaibleEnums(env, what)
	return enums[env][what]
end

function render.TranslateStringToEnum(env, what, str, error_level)
	if type(str) ~= "string" then return end
	if not enums[env] or not enums[env][what] then return end
	
	str = str:upper()
	
	if not enums[env][what][str] then 
		local valid = {} for k,v in pairs(enums[env][what]) do table.insert(valid, k) end valid = table.concat(valid, "\n"):lower()
		
		errorf("%s is not a valid %s enum. These are valid enums %s", level or 3, str, what, valid) 
	end
	
	return enums[env][what][str]
end