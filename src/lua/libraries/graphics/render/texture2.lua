local render = ... or _G.render
local gl = require("graphics.ffi.opengl")

do -- texture binding
	local last_texture
	
	local base = gl.e.GL_TEXTURE0 
	local last
	do
		function render.ActiveTexture(id)
			if id ~= last then
				gl.ActiveTexture(base + id)
				last = id
				last_texture = nil
			end
		end
	end

	do		
		function render.BindTexture(tex)
			if tex ~= last_texture then
				tex:Bind()
				last_texture = tex
			end
		end
	end
	
	function render.BindTexture2(tex, channel, location)
		gl.Uniform1i(location, channel)
		gl.ActiveTexture(base + channel)
		tex:Bind()
	end
end


local TOENUM = function(str) 
	return "GL_" .. str:upper() 
end

local META = prototype.CreateTemplate("texture2")

function META:__index2(key)
	if key == "w" then
		return self:GetSize().w
	elseif key == "h" then
		return self:GetSize().h
	end
end

META:StartStorable()
META:GetSet("StorageType", "2d")
META:GetSet("Size", Vec2())
META:GetSet("Depth", 0)
META:GetSet("MipMapLevels", 0)
META:GetSet("Path", "loading")
META:IsSet("Loading", false)
META:IsSet("InternalFormat", "rgba8")
META:EndStorable()

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
	depth_stencil_texture_mode = {friendly = "StencilTextureMode", type = "string"}, -- DEPTH_COMPONENT, STENCIL_INDEX
	depth_texture_mode = {friendly = "DepthTextureMode", type = "string"}, -- red, green, blue, etc
	texture_base_level = {type = "int", default = 0}, -- any non-negative integer
	texture_border_color = {type = "color", default = Color()}, --4 floats, any 4 values ints, or uints
	texture_compare_mode = {type = "enum", default = "none"}, -- NONE, COMPARE_REF_TO_TEXTURE
	texture_compare_func = {type = "enum", default = "never"}, -- LEQUAL, GEQUAL, LESS,GREATER, EQUAL, NOTEQUAL,ALWAYS, NEVER
	texture_lod_bias = {type = "float", default = 0}, -- any value
	texture_mag_filter = {type = "enum", default = "nearest"}, -- NEAREST, LINEAR
	texture_max_level = {type = "int", default = 0}, -- any non-negative integer
	texture_max_lod = {type = "float", default = 0}, -- any value
	texture_min_filter = {type = "enum", default = "nearest"}, -- NEAREST, LINEAR, NEAREST_MIPMAP_NEAREST, NEAREST_MIPMAP_LINEAR, LINEAR_MIPMAP_NEAREST, LINEAR_MIPMAP_LINEAR,
	texture_min_lod = {type = "float", default = 0}, -- any value
	texture_swizzle_r = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	texture_swizzle_g = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	texture_swizzle_b = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	texture_swizzle_a = {type = "enum", default = "zero"}, -- RED, GREEN, BLUE, ALPHA, ZERO, ONE
	texture_swizzle_rgba = {type = "color", default = Color()}, --4 enums RED, GREEN, BLUE, ALPHA, ZERO, ONE
	texture_wrap_s = {type = "enum", default = "repeat"}, -- CLAMP_TO_EDGE, REPEAT, CLAMP_TO_BORDER, MIRRORED_REPEAT, MIRROR_CLAMP_TO_EDGE
	texture_wrap_t = {type = "enum", default = "repeat"}, -- CLAMP_TO_EDGE, REPEAT, CLAMP_TO_BORDER, MIRRORED_REPEAT, MIRROR_CLAMP_TO_EDGE
	texture_wrap_r = {type = "enum", default = "repeat"}, -- CLAMP_TO_EDGE, REPEAT, CLAMP_TO_BORDER, MIRRORED_REPEAT, MIRROR_CLAMP_TO_EDGE
	texture_max_anisotropy_ext = {friendly = "Anisotropy", type = "int", default = 0, translate = function(num) 
		if not render.max_anisotropy then
			local largest = ffi.new("float[1]")
			gl.GetFloatv("GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT", largest)
			render.max_anisotropy = largest[0]
		end
		
		if num == -1 or num > render.max_anisotropy then
			return render.max_anisotropy
		end
	end}, -- TEXTURE_MAX_ANISOTROPY_EXT
}

for k, v in pairs(parameters) do
	local friendly = v.friendly or k:match("texture(_.+)"):gsub("_(.)", string.upper)
	local info = META:GetSet(friendly, v.default)
	local enum = gl.e["GL_" .. k:upper()]
	
	if v.type == "enum" then
		META[info.set_name] = function(self, val)
			self[info.var_name] = val
			self.gl_tex:SetParameteri(enum, gl.e[TOENUM(val)])
		end
	elseif v.type == "int" then
		META[info.set_name] = function(self, val)
			self[info.var_name] = val
			self.gl_tex:SetParameteri(enum, v.translate and v.translate(val) or val)
		end
	elseif v.type == "float" then
		META[info.set_name] = function(self, val)
			self[info.var_name] = val
			self.gl_tex:SetParameterf(enum, v.translate and v.translate(val) or val)
		end
	elseif v.type == "color" then
		META[info.set_name] = function(self, val)
			self[info.var_name] = val
			self.gl_tex:SetParameterfv(enum, v.translate and v.translate(val) or val)
		end
	end
	
	v.getset_info = info
end

function META:__copy()
	return self
end

function META:SetPath(path, face)
	self.Path = path
	
	self.Loading = true
	
	resource.Download(path, function(full_path)
		local buffer, w, h, info = render.DecodeTexture(vfs.Read(full_path), full_path)
		
		self:SetSize(Vec2(w, h))
				
		if buffer then			
			self:Upload({
				buffer = buffer,
				width = w,		
				height = h,
				format = "bgra",
				face = face, -- todo
			})
		end

		self.Loading = false
		
		if self.OnLoad then 
			self:OnLoad() 
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
			self:SetPath(path .. face .. ".vtf", i)
		end
	end
end

function META:OnRemove()
	self.gl_tex:Delete()
end

function META:SetupStorage()
	render.StartDebug()
	
	--[[local levels = self.MipMapLevels
	
	if levels == 0 then
		levels = math.floor(math.log(math.max(self.Size.w, self.Size.h)) / math.log(2)) + 1
	end]]
	
	local internal_format = TOENUM(self.InternalFormat)
	
	local upload_format = "GL_RGBA"
	local upload_type = "GL_UNSIGNED_BYTE"
	
	do
		local depth = internal_format:find("DEPTH", nil, true)
		local stencil = internal_format:find("STENCIL", nil, true)
		
		if depth and stencil then
			upload_format = "GL_DEPTH_STENCIL"
			upload_type = "GL_UNSIGNED_INT_24_8"
		elseif depth then
			upload_format = "GL_DEPTH_COMPONENT"
		elseif stencil then
			upload_format = "GL_STENCIL_COMPONENTS"
		end
	end
	
	internal_format = gl.e[internal_format]
	
	if self.StorageType == "3d" then
		--[[self.gl_tex:Storage3D(
			levels,
			TOENUM(self.InternalFormat), 
			self.Size.w, 
			self.Size.h, 
			self.Depth
		)]]
		self.gl_tex:Image3D(
			"GL_TEXTURE_3D",
			self.MipMapLevels,
			internal_format, 
			self.Size.w,
			self.Size.h,
			self.Depth,
			0,
			upload_format,
			upload_type,
			nil
		)
	elseif self.StorageType == "2d" or self.StorageType == "rectangle" or self.StorageType == "cube_map" or self.StorageType == "2d_array" then		
		--[[self.gl_tex:Storage2D(
			levels,
			TOENUM(self.InternalFormat), 
			self.Size.w, 
			self.Size.h
		)]]
		self.gl_tex:Image2D(
			"GL_TEXTURE_2D",
			self.MipMapLevels,
			internal_format, 
			self.Size.w,
			self.Size.h,
			0,
			upload_format,
			upload_type,
			nil
			
		)
	elseif self.StorageType == "1d" or self.StorageType == "1d_array" then		
		--[[self.gl_tex:Storage1D(
			levels,
			TOENUM(self.InternalFormat), 
			self.Size.w
		)]]
		self.gl_tex:Image1D(
			"GL_TEXTURE_1D",
			self.MipMapLevels,
			internal_format, 
			self.Size.w,
			0,
			upload_format,
			upload_type,
			nil
		)
	end
	
	local msg = render.StopDebug()
	if msg then
		logn("==================================")
		logn(self, ":SetupStorage() failed")
		logn("==================================")
		self:DumpInfo()
		logn("==================================")
		error("\n" .. msg, 2)
	end
	
	self.storage_setup = true
end

function META:Upload(data)	
	if not self.storage_setup then
		self:SetupStorage()
	end
	
	render.StartDebug()
	
	data.mip_map_level = data.mip_map_level or 0
	data.format = data.format or "rgba"
	data.type = data.type or "unsigned_byte"
	
	if type(data.buffer) == "string" then 
		data.buffer = ffi.cast("uint8_t *", data.buffer) 
	end
	
	if self.StorageType == "cube_map" then
		data.z = data.face or data.z
		data.depth = data.depth or 1
	end
	
	local y
	
	if data.y then
		y = -data.y + self.Size.h - data.height
	end
	
	if self.StorageType == "3d" or self.StorageType == "cube_map" or self.StorageType == "2d_array" then		
		data.x = data.x or 0
		y = y or 0
		data.z = data.z or 0
		
		if data.image_size then
			self.gl_tex:CompressedSubImage3D(
				data.mip_map_level, 
				data.x, 
				y, 
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
				y, 
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
		y = y or 0
	
		if data.image_size then
			self.gl_tex:CompressedSubImage2D(
				data.mip_map_level, 
				data.x, 
				y, 
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
				y, 
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
		warning("NYI", 2)
	end

	self.gl_tex:GenerateMipmap()

	self.downloaded_image = nil
	
	local msg = render.StopDebug()
	if msg then
		logn("==================================")
		logn(tostring(self) .. ":Upload() failed")
		self:DumpInfo()
		table.print(data)
		error("\n" .. msg, 2)
	end
end

function META:DumpInfo()
	logn("==================================")
		logn("storage type = ", self.StorageType)
		logn("internal format = ", TOENUM(self.InternalFormat))
		logn("mip map levels = ", self.MipMapLevels)
		logn("size = ", self.Size)		
		if self.StorageType == "3d" then
			logn("depth = ", self.Depth)
		end
		logn("==================================")
end

function META:MakeError()
	self:Upload(render.GetErrorTexture():Download())
end

ffi.cdef("typedef struct {uint8_t r, g, b, a;} rgba_pixel;")

function META:Download(mip_map_level)
	render.StartDebug()
	
	mip_map_level = mip_map_level or 0
	
	local size = self.Size.w * self.Size.h * ffi.sizeof("rgba_pixel")
	local buffer = ffi.new("rgba_pixel[?]", size)
	
	self.gl_tex:GetImage(mip_map_level, "GL_RGBA", "GL_UNSIGNED_BYTE", size, buffer)
	
	local msg = render.StopDebug()
	if msg then
		table.print(self:GetStorableTable())
		error(msg, 2)
	end
	
	return {
		type = "unsigned_byte",
		buffer = buffer,
		width = self.Size.w,
		height = self.Size.h,
		format = self.upload_format or "rgba",
		mip_map_level = mip_map_level,
		length = (self.Size.w * self.Size.h) - 1, -- for i = 0, data.length do
	}
end

function META:Clear(mip_map_level)
	local size = self.Size.w * self.Size.h * ffi.sizeof("rgba_pixel")
	local buffer = ffi.new("rgba_pixel[?]", size)
	
	self:Upload({
		buffer = buffer,
		width = self.Size.w,
		height = self.Size.h,
		format = "rgba",
		mip_map_level = mip_map_level,
	})
end

function META:Fill(callback)
	check(callback, "function")
		
	local image = self:Download()
	
	local x = 0
	local y = 0
	local buffer = image.buffer

	for i = 0, image.length do
		if x >= image.width then
			y = y + 1
			x = 0
		end
		
		local r,g,b,a
		
		if image.format == "bgra" then
			r,g,b,a = callback(x, y, i, buffer[i].b, buffer[i].g, buffer[i].r, buffer[i].a)
		elseif image.format == "rgba" then
			r,g,b,a = callback(x, y, i, buffer[i].r, buffer[i].b, buffer[i].g, buffer[i].a)
		elseif image.format == "bgr" then
			b,g,r = callback(x, y, i, buffer[i].b, buffer[i].g, buffer[i].r)
		elseif image.format == "rgb" then
			r,g,b = callback(x, y, i, buffer[i].r, buffer[i].g, buffer[i].b)
		elseif image.format == "red" then
			r = callback(x, y, i, buffer[i].r)
		end
		
		if r then buffer[i].r = r end
		if g then buffer[i].g = g end
		if b then buffer[i].b = b end
		if a then buffer[i].a = a end
		
		x = x + 1
	end
	
	self:Upload(image)
	
	return self
end

function META:GetPixelColor(x, y)
	x = math.clamp(math.floor(x), 1, self.w)		
	y = math.clamp(math.floor(y), 1, self.h)		
	
	y = self.h-y
	
	local i = y * self.w + x
			
	local image = self.downloaded_image or self:Download()
	self.downloaded_image = image

	local buffer = image.buffer
	
	if image.format == "bgra" then
		return buffer[i].b, buffer[i].g, buffer[i].r, buffer[i].a
	elseif image.format == "rgba" then
		return buffer[i].r, buffer[i].b, buffer[i].g, buffer[i].a		
	elseif image.format == "bgr" then
		return buffer[i].b, buffer[i].g, buffer[i].r
	elseif image.format == "rgb" then
		return buffer[i].r, buffer[i].g, buffer[i].b
	elseif image.format == "red" then
		return buffer[i].r
	end
end

function META:BeginWrite()
	local fb = self.fb or render.CreateFrameBuffer()
	fb:SetSize(self:GetSize():Copy())
	fb:SetTexture(1, self)
	self.fb = fb
	
	fb:Begin()
	surface.PushMatrix()
	surface.LoadIdentity()
	surface.Scale(self.w, self.h)
end

function META:EndWrite()
	surface.PopMatrix()
	self.fb:End()
end

do
	local template = [[
		out vec4 out_color;
		
		vec4 shade()
		{
			%s
		}
		
		void main()
		{
			out_color = shade();
		}
	]]
	
	function META:Shade(fragment_shader, vars, dont_blend)		
		self.shaders = self.shaders or {}
		
		local name = "shade_texture_" .. tostring(self.gl_tex.id) .. "_" .. crypto.CRC32(fragment_shader)
		local shader = self.shaders[name]
		
		
		if not self.shaders[name] then
			local data = {
				name = name,
				shared = {
					variables = vars,
				},
				fragment = { 
					variables = {
						self = self,
						size = self:GetSize(),
					},		
					mesh_layout = {
						{uv = "vec2"},
					},			
					source = template:format(fragment_shader),
				} 
			} 
				
			shader = render.CreateShader(data)
			
			self.shaders[name] = shader
		end
		
		
		self:BeginWrite()
			if vars then
				for k,v in pairs(vars) do
					shader[k] = v
				end				
			end
		
			if not dont_blend then 
				render.SetBlendMode("src_alpha", "one_minus_src_alpha")
			end
			
			render.SetShaderOverride(shader)
			surface.rect_mesh:Draw()
			render.SetShaderOverride()
		self:EndWrite()
		
		return self
	end

end

function META:Bind(location)
	if self.dsa then
		gl.BindTextureUnit(location or 0, self.gl_tex.id)
	else
		gl.BindTexture(self.gl_tex.target, self.gl_tex.id)
	end
end

META:Register()

function render.CreateTexture(type)
	local self = prototype.CreateObject(META)
	
	if type then 
		self.StorageType = type
	end

	self.gl_tex = gl.CreateTexture("GL_TEXTURE_" .. self.StorageType:upper())
	self.id = self.gl_tex.id -- backwards compatibility
	
	self.dsa = self.not_dsa -- ...
		
	return self
end

render.texture_decoders = render.texture_decoders or {}

function render.AddTextureDecoder(id, callback)
	render.RemoveTextureDecoder(id)
	table.insert(render.texture_decoders, {id = id, callback = callback})
end

function render.RemoveTextureDecoder(id)
	for k,v in pairs(render.texture_decoders) do
		if v.id == id then
			table.remove(render.texture_decoders)
			return true
		end
	end
end

function render.DecodeTexture(data, path_hint)
	for i, decoder in ipairs(render.texture_decoders) do
		local ok, buffer, w, h, info = pcall(decoder.callback, data, path_hint)
		if ok then 
			if buffer and w then
				return buffer, w, h, info or {}
			elseif not w:find("unknown format") then
				logf("[render] %s failed to decode %s: %s\n", decoder.id, path_hint or "", w)
			end
		else
			logf("[render] decoder %q errored: %s\n", decoder.id, buffer)
		end
	end
end

render.texture_path_cache = {}

function Texture(...)
	local path = ...
	if type(path) == "string" then
		if render.texture_path_cache[path] then 
			return render.texture_path_cache[path] 
		end
		
		local self = render.CreateTexture("2d")
		self:SetPath(path)
		
		render.texture_path_cache[path] = self
		
		return self
	end
	
	local w,h = ...
	if type(w) == "number" and type(h) == "number" then
		local self = render.CreateTexture("2d")
		self:SetSize(Vec2(w, h))
		self:SetupStorage()
		self:Clear()
		return self	
	end
	
	local size = ...
	if typex(size) == "vec2" then
		local self = render.CreateTexture("2d")
		self:SetSize(size:Copy())
		self:SetupStorage()
		self:Clear()
		return self	
	end
	
	return render.CreateTexture(...)
end

if not RELOAD then return end

local tex = render.CreateTexture("2d")

--tex:LoadCubemap("materials/skybox/sky_borealis01")
--tex:SetPath("https://i.ytimg.com/vi/YC4mDN7ltT0/default.jpg")
tex:SetPath("textures/greendog.png")

local function blur_texture(dir)
	tex:Shade([[
		//this will be our RGBA sum
		vec4 sum = vec4(0.0);

		//the amount to blur, i.e. how far off center to sample from 
		//1.0 -> blur by one pixel
		//2.0 -> blur by two pixels, etc.
		float blur = radius/resolution; 

		//the direction of our blur
		//(1.0, 0.0) -> x-axis blur
		//(0.0, 1.0) -> y-axis blur
		float hstep = dir.x;
		float vstep = dir.y;

		//apply blurring, using a 9-tap filter with predefined gaussian weights

		sum += texture(self, vec2(uv.x - 4.0*blur*hstep, uv.y - 4.0*blur*vstep)) * 0.0162162162;
		sum += texture(self, vec2(uv.x - 3.0*blur*hstep, uv.y - 3.0*blur*vstep)) * 0.0540540541;
		sum += texture(self, vec2(uv.x - 2.0*blur*hstep, uv.y - 2.0*blur*vstep)) * 0.1216216216;
		sum += texture(self, vec2(uv.x - 1.0*blur*hstep, uv.y - 1.0*blur*vstep)) * 0.1945945946;

		sum += texture(self, vec2(uv.x, uv.y)) * 0.2270270270;

		sum += texture(self, vec2(uv.x + 1.0*blur*hstep, uv.y + 1.0*blur*vstep)) * 0.1945945946;
		sum += texture(self, vec2(uv.x + 2.0*blur*hstep, uv.y + 2.0*blur*vstep)) * 0.1216216216;
		sum += texture(self, vec2(uv.x + 3.0*blur*hstep, uv.y + 3.0*blur*vstep)) * 0.0540540541;
		sum += texture(self, vec2(uv.x + 4.0*blur*hstep, uv.y + 4.0*blur*vstep)) * 0.0162162162;

		return sum;
	]], { 
		radius = 1, 
		resolution = render.GetScreenSize(),
		dir = dir,
	})  
end

blur_texture(Vec2(0,5))
blur_texture(Vec2(5,0))

local shader = render.CreateShader({
	name = "test",
	fragment = {
		variables = {
			cam_dir = {vec3 = function() return render.camera_3d:GetAngles():GetForward() end},
			tex = tex,
		},
		mesh_layout = {
			{uv = "vec2"},
		},			
		source = [[
			out highp vec4 frag_color;
			
			void main()
			{	
				vec4 tex_color = texture(tex, uv); 
				//vec4 tex_color = texture(tex, cam_dir); 
				
				frag_color = tex_color;
			}
		]],
	}
})

serializer.WriteFile("msgpack", "lol.wtf", tex:Download())
local info = serializer.ReadFile("msgpack", "lol.wtf")
tex:Upload(info)
--[[local size = 16
tex:Fill(function(x, y)
	if (math.floor(x/size) + math.floor(y/size % 2)) % 2 < 1 then
		return 255, 0, 255, 255
	else
		return 0, 0, 0, 255
	end
end)]]
--tex:Clear()

local tex = Texture(128, 128)
local image = ffi.new("uint8_t[8][8][4]")
for x = 0, 8 - 1 do
for y = 0, 8 - 1 do
	image[x][y][0] = math.random(255)
	image[x][y][3] = 255
end
end

tex:Upload({
	x = 50,
	y = 50,
	buffer = image,
	width = 8,
	height = 8,
})

event.AddListener("PostDrawMenu", "lol", function()
	--surface.PushMatrix(0, 0, tex:GetSize():Unpack())
		--render.SetShaderOverride(shader)
		--surface.rect_mesh:Draw()
		--render.SetShaderOverride()
	--surface.PopMatrix()
	
	surface.SetTexture(tex)
	surface.SetColor(1,1,1,1)
	surface.DrawRect(0,0,tex.w,tex.h)
	
	surface.SetWhiteTexture()
	surface.SetColor(ColorBytes(tex:GetPixelColor(surface.GetMousePosition())))
	surface.DrawRect(50,50,50,50)
end)
