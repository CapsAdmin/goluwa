local TOENUM = function(str) return "GL_" .. str:upper() end

local gl = require("graphics.ffi.opengl")

local META = prototype.CreateTemplate("texture2")

META:GetSet("StorageType", "2d")
META:GetSet("Size", Vec2())
META:GetSet("MipMapLevels", 5)
META:GetSet("Path", "loading")

local texture_formats = {
	r8 = {normalized = true, bits = {8}},
	r8_snorm = {signed = true, normalized = true, bits = {8}},
	r16 = {normalized = true, bits = {16}},
	r16_snorm = {signed = true, normalized = true, bits = {16}},
	rg8 = {normalized = true, bits = {8, 8}},
	rg8_snorm = {signed = true, normalized = true, bits = {8, 8}},
	rg16 = {normalized = true, bits = {16, 16}},
	rg16_snorm = {signed = true, normalized = true, bits = {16, 16}},
	r3_g3_b2 = {normalized = true, bits = {3, 3, 2}},
	rgb4 = {normalized = true, bits = {4, 4, 4}},
	rgb5 = {normalized = true, bits = {5, 5, 5}},
	rgb8 = {normalized = true, bits = {8, 8, 8}},
	rgb8_snorm = {signed = true, normalized = true, bits = {8, 8, 8}},
	rgb10 = {normalized = true, bits = {10, 10, 10}},
	rgb12 = {normalized = true, bits = {12, 12, 12}},
	rgb16_snorm = {normalized = true, bits = {16, 16, 16}},
	rgba2 = {normalized = true, bits = {2, 2, 2, 2}},
	rgba4 = {normalized = true, bits = {4, 4, 4, 4}},
	rgb5_a1 = {normalized = true, bits = {5, 5, 5, 1}},
	rgba8 = {normalized = true, bits = {8, 8, 8, 8}},
	rgba8_snorm = {signed = true, normalized = true, bits = {8, 8, 8, 8}},
	rgb10_a2 = {normalized = true, bits = {10, 10, 10, 2}},
	rgb10_a2ui = {unsigned = true, bits = {10, 10, 10, 2}},
	rgba12 = {normalized = true, bits = {12, 12, 12, 12}},
	rgba16 = {normalized = true, bits = {16, 16, 16, 16}},
	srgb8 = {normalized = true, bits = {8, 8, 8}},
	srgb8_alpha8 = {normalized = true, bits = {8, 8, 8, 8}},
	r16f = {float = true, bits = {16}},
	rg16f = {float = true, bits = {16, 16}},
	rgb16f = {float = true, bits = {16, 16, 16}},
	rgba16f = {float = true, bits = {16, 16, 16, 16}},
	r32f = {float = true, bits = {32}},
	rg32f = {float = true, bits = {32, 32}},
	rgb32f = {float = true, bits = {32, 32, 32}},
	rgba32f = {float = true, bits = {32, 32, 32, 32}},
	r11f_g11f_b10f = {float = true, bits = {11, 11, 10}},
	rgb9_e5 = {normalized = true, bits = {9, 9, 9}},
	r8i = {signed = true, bits = {8}},
	r8ui = {unsigned = true, bits = {8}},
	r16i = {signed = true, bits = {16}},
	r16ui = {unsigned = true, bits = {16}},
	r32i = {signed = true, bits = {32}},
	r32ui = {unsigned = true, bits = {32}},
	rg8i = {signed = true, bits = {8, 8}},
	rg8ui = {unsigned = true, bits = {8, 8}},
	rg16i = {signed = true, bits = {16, 16}},
	rg16ui = {unsigned = true, bits = {16, 16}},
	rg32i = {signed = true, bits = {32, 32}},
	rg32ui = {unsigned = true, bits = {32, 32}},
	rgb8i = {signed = true, bits = {8, 8, 8}},
	rgb8ui = {unsigned = true, bits = {8, 8, 8}},
	rgb16i = {signed = true, bits = {16, 16, 16}},
	rgb16ui = {unsigned = true, bits = {16, 16, 16}},
	rgb32i = {signed = true, bits = {32, 32, 32}},
	rgb32ui = {unsigned = true, bits = {32, 32, 32}},
	rgba8i = {signed = true, bits = {8, 8, 8, 8}},
	rgba8ui = {unsigned = true, bits = {8, 8, 8, 8}},
	rgba16i = {signed = true, bits = {16, 16, 16, 16}},
	rgba16ui = {unsigned = true, bits = {16, 16, 16, 16}},
	rgba32i = {signed = true, bits = {32, 32, 32, 32}},
	rgba32ui = {unsigned = true, bits = {32, 32, 32, 32}},
}

local texture_types = {
	unsigned_byte = {type = "uint8_t", false, false},
	byte = {type = "byte", special = false, float = false},
	unsigned_short = {type = "uint16_t", special = false, float = false},
	short = {type = "int16_t", special = false, float = false},
	unsigned_int = {type = "uint32_t", special = false, float = false},
	int = {type = "int32_t", special = false, float = false},
	half_float = {type = "half", special = false, float = true},
	float = {type = "float", special = false, float = true},
	unsigned_byte_3_3_2 = {type = "uint8_t", special = true, float = false},
	unsigned_byte_2_3_3_rev = {type = "uint8_t", special = true, float = false},
	unsigned_short_5_6_5 = {type = "uint16_t", special = true, float = false},
	unsigned_short_5_6_5_rev = {type = "uint16_t", special = true, float = false},
	unsigned_short_4_4_4_4 = {type = "uint16_t", special = true, float = false},
	unsigned_short_4_4_4_4_rev = {type = "uint16_t", special = true, float = false},
	unsigned_short_5_5_5_1 = {type = "uint16_t", special = true, float = false},
	unsigned_short_1_5_5_5_rev = {type = "uint16_t", special = true, float = false},
	unsigned_int_8_8_8_8 = {type = "uint32_t", special = true, float = false},
	unsigned_int_8_8_8_8_rev = {type = "uint32_t", special = true, float = false},
	unsigned_int_10_10_10_2 = {type = "uint32_t", special = true, float = false},
	unsigned_int_2_10_10_10_rev = {type = "uint32_t", special = true, float = false},
	unsigned_int_24_8 = {type = "uint32_t", special = true, float = false},
	unsigned_int_10f_11f_11f_rev = {type = "uint32_t", special = true, float = true},
	unsigned_int_5_9_9_9_rev = {type = "uint32_t", special = true, float = true},
	float_32_unsigned_int_24_8_rev = {type = "", special = true, float = false},
}

local parameters = {
	DEPTH_STENCIL_TEXTURE_MODE = {friendly = "StencilTextureMode", type = "string"}, -- DEPTH_COMPONENT, STENCIL_INDEX
	TEXTURE_BASE_LEVEL = {type = "int", default = 0}, -- any non-negative integer
	TEXTURE_BORDER_COLOR = {type = "color", default = Color()}, --4 floats, any 4 values ints, or uints
	TEXTURE_COMPARE_MODE = {type = "enum", default = "none"}, -- NONE, COMPARE_REF_TO_TEXTURE
	TEXTURE_COMPARE_FUNC = {type = "enum", default = "never"}, -- LEQUAL, GEQUAL, LESS,GREATER, EQUAL, NOTEQUAL,ALWAYS, NEVER
	TEXTURE_LOD_BIAS = {type = "float", default = 0}, -- any value
	TEXTURE_MAG_FILTER = {type = "enum", default = "nearest"}, -- NEAREST, LINEAR
	TEXTURE_MAX_LEVEL = {type = "int", default = 0}, -- any non-negative integer
	TEXTURE_MAX_LOD = {type = "float", default = 0}, -- any value
	TEXTURE_MIN_FILTER = {type = "enum", default = "nearest"}, -- NEAREST, LINEAR, NEAREST_MIPMAP_NEAREST, NEAREST_MIPMAP_LINEAR, LINEAR_MIPMAP_NEAREST, LINEAR_MIPMAP_LINEAR,
	TEXTURE_MIN_LOD = {type = "float", default = 0}, -- any value
	TEXTURE_SWIZZLE_R = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	TEXTURE_SWIZZLE_G = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	TEXTURE_SWIZZLE_B = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	TEXTURE_SWIZZLE_A = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	TEXTURE_SWIZZLE_RGBA = {type = "color", default = Color()}, --4 enums RED, GREEN, BLUE, ALPHA, ZERO, ONE
	TEXTURE_WRAP_S = {type = "enum", default = "repeat"}, -- CLAMP_TO_EDGE, REPEAT, CLAMP_TO_BORDER, MIRRORED_REPEAT, MIRROR_CLAMP_TO_EDGE
	TEXTURE_WRAP_T = {type = "enum", default = "repeat"}, -- CLAMP_TO_EDGE, REPEAT, CLAMP_TO_BORDER, MIRRORED_REPEAT, MIRROR_CLAMP_TO_EDGE
	TEXTURE_WRAP_R = {type = "enum", default = "repeat"}, -- CLAMP_TO_EDGE, REPEAT, CLAMP_TO_BORDER, MIRRORED_REPEAT, MIRROR_CLAMP_TO_EDGE
}

for k, v in pairs(parameters) do
	local friendly = v.friendly or k:match("TEXTURE(_.+)"):gsub("_(.)", string.upper)
	local info = META:GetSet(friendly, v.default)
	local enum = "GL_" .. k
	if v.type == "enum" or v.type == "int" then
		META[info.set_name] = function(self, val)
			self[info.var_name] = val
			self.gl_tex:SetParameteri(enum, val)
		end
	elseif v.type == "float" then
		META[info.set_name] = function(self, val)
			self[info.var_name] = val
			self.gl_tex:SetParameterf(enum, val)
		end
	elseif v.type == "color" then
		META[info.set_name] = function(self, val)
			self[info.var_name] = val
			self.gl_tex:SetParameterfv(enum, val)
		end
	end
end

function META:SetPath(path)
	self.Path = path	
	
	resource.Download(path, function(full_path)
		local buffer, w, h, info = render.DecodeTexture(vfs.Read(full_path), full_path)
	
		if buffer then			
			self:Upload({
				buffer = buffer,
				width = w,		
				height = h,
				format = "bgra",
				face = self.face, -- todo
			})
		end
	end)
end

do -- todo
	local faces = {
		"bk",
		"dn",
		"ft",
		"lf",
		"rt",
		"up",
	}

	function META:LoadCubemap(path)
		path = path:sub(0,-1)
		for i, face in pairs(faces) do
			self.face = i -- todo
			self:SetPath(path .. face .. ".vtf", i)
		end
	end
end

function META:OnRemove()
	self.gl_tex:Delete()
end

function META:Upload(data)
	data.mip_map_level = data.mip_map_level or 0
	data.format = data.format or "rgba"
	data.type = data.type or "unsigned_byte"
	data.internal_format = data.internal_format or "rgba8"
	
	if type(data.buffer) == "string" then 
		data.buffer = ffi.cast("uint8_t *", data.buffer) 
	end

	if not self.storage_setup then
		if self.StorageType == "3d" then
			self.gl_tex:Storage3D(
				self.MipMapLevels, 
				TOENUM(data.internal_format), 
				data.width, 
				data.height, 
				data.depth
			)	
		elseif self.StorageType == "2d" or self.StorageType == "rectangle" or self.StorageType == "cube_map" or self.StorageType == "2d_array" then		
			self.gl_tex:Storage2D(
				self.MipMapLevels, 
				TOENUM(data.internal_format), 
				data.width, 
				data.height
			)
		elseif self.StorageType == "1d" or self.StorageType == "1d_array" then		
			self.gl_tex:Storage1D(
				self.MipMapLevels, 
				TOENUM(data.internal_format), 
				data.width
			)
		end
		--self.last_storage_setup = true
	end
	
	if self.StorageType == "cube_map" then
		data.z = data.face or data.z
		data.depth = data.depth or 1
	end
	
	if self.StorageType == "3d" or self.StorageType == "cube_map" or self.StorageType == "2d_array" then		
		data.x = data.x or 0
		data.y = data.y or 0
		data.z = data.z or 0
		
		if data.image_size then
			self.gl_tex:CompressedSubImage3D(
			data.mip_map_level, 
			data.x, 
			data.y, 
			data.z, 
			data.width, 
			data.height, 
			data.depth, 
			TOENUM(data.format), 
			TOENUM(data.type), 
			data.image_size, 
			data.buffer
		)
		else
			self.gl_tex:SubImage3D(
				data.mip_map_level, 
				data.x, 
				data.y, 
				data.z, 
				data.width, 
				data.height, 
				data.depth, 
				TOENUM(data.format), 
				TOENUM(data.type), 
				data.buffer
			)
		end		
	elseif self.StorageType == "2d" or self.StorageType == "1d_array" or self.StorageType == "rectangle" then		
		data.x = data.x or 0
		data.y = data.y or 0
	
		if data.image_size then
			self.gl_tex:CompressedSubImage2D(
				data.mip_map_level, 
				data.x, 
				data.y, 
				data.width, 
				data.height, 
				TOENUM(data.format), 
				TOENUM(data.type), 
				data.image_size, 
				data.buffer
			)
		else
			self.gl_tex:SubImage2D(
				data.mip_map_level, 
				data.x, 
				data.y, 
				data.width, 
				data.height, 
				TOENUM(data.format), 
				TOENUM(data.type), 
				data.buffer
			)
		end
	elseif self.StorageType == "1d" then		
		data.x = data.x or 0
		
		if data.image_size then
			self.gl_tex:CompressedSubImage1D(
				data.mip_map_level, 
				data.x, 
				data.width, 
				TOENUM(data.format), 
				TOENUM(data.type), 
				data.image_size, 
				data.buffer
			)
		else
			self.gl_tex:SubImage1D(
				data.mip_map_level, 
				data.x, 
				data.width, 
				TOENUM(data.format), 
				TOENUM(data.type), 
				data.buffer
			)
		end
	elseif self.StorageType == "buffer" then
		--self.gl_tex:Buffer(TOENUM(self.InternalFormat))
		--self.gl_tex:BufferRange(TOENUM(self.InternalFormat), )
		error("NYI", 2)
	end

	if self.MipMapLevels > 0 then
		self.gl_tex:GenerateMipmap()
	end
	
	self.Size.w = data.width
	self.Size.h = data.height
	
	self.last_storage_setup = true
end

ffi.cdef("typedef struct {uint8_t r, g, b, a;} rgba_pixel;")

function META:Download(mip_map_level)
	mip_map_level = mip_map_level or 0
	
	local size = self.Size.w * self.Size.h * ffi.sizeof("rgba_pixel")
	local buffer = ffi.new("rgba_pixel[?]", size)
	
	--gl.PixelStorei("GL_PACK_ALIGNMENT", 4)
	--gl.PixelStorei("GL_UNPACK_ALIGNMENT", 4)
			
	self.gl_tex:GetImage(mip_map_level, "GL_RGBA", "GL_UNSIGNED_BYTE", size, buffer)
	
	return {
		type = "unsigned_byte",
		buffer = buffer,
		width = self.Size.w,
		height = self.Size.h,
		format = "rgba",
		internal_format = "rgba8",
		mip_map_level = mip_map_level,
		length = (self.Size.w*self.Size.h) - 1, -- for i = 0, data.length do
	}
end

function META:Bind(location)
	gl.BindTextureUnit(location, self.gl_tex.id)
end

META:Register()

local function Texture(storage_type)	
	local self = prototype.CreateObject(META)
	if storage_type then self:SetStorageType(storage_type) end
	self.gl_tex = gl.CreateTexture("GL_TEXTURE_" .. self.StorageType:upper())
	
	return self
end

local tex = Texture("2d")

tex:SetPath("http://members.jcom.home.ne.jp/i-am-a-student-boy/soft/032.png")

local data = tex:Download()

for i = 0, data.length do
	data.buffer[i].r = 0
end

local tex = Texture("2d") -- what

tex:Upload(data)

local shader = render.CreateShader({
	name = "test",
	fragment = {
		variables = {
			cam_dir = {vec3 = function() return render.camera_3d:GetAngles():GetForward() end},
		},
		mesh_layout = {
			{uv = "vec2"},
		},			
		source = [[
			#version 420
			#extension GL_NV_shadow_samplers_cube:enable
			
			layout(binding = 0) uniform sampler2D tex1;
			out highp vec4 frag_color;
			
			void main()
			{	
				vec4 tex_color = texture(tex1, uv); 
				
				frag_color = tex_color;
			}
		]],
	}
})

gl.Enable("GL_TEXTURE_CUBE_MAP") 

event.AddListener("PostDrawMenu", "lol", function()
	tex:Bind(0)
	surface.PushMatrix(0, 0, tex:GetSize():Unpack())
		render.SetShaderOverride(shader)
		surface.rect_mesh:Draw()
		render.SetShaderOverride()
	surface.PopMatrix()
end)
