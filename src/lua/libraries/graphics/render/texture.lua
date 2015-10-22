local render = ... or _G.render
local gl = require("graphics.ffi.opengl")

local TOENUM = function(str)
	return "GL_" .. str:upper()
end

local META = prototype.CreateTemplate("texture")

function META:__index2(key)
	if key == "w" then
		return self:GetSize().x
	elseif key == "h" then
		return self:GetSize().y
	end
end

function META:__tostring2()
	if self.error_reason then
		return ("[error: %s][%s]"):format(self.error_reason, self:GetPath())
	else
		return ("[%s]"):format(self:GetPath())
	end
end

META:StartStorable()
META:GetSet("StorageType", "2d")
META:GetSet("Size", Vec2())
META:GetSet("Depth", 0)
META:GetSet("MipMapLevels", -1)
META:GetSet("Path", "")
META:GetSet("Multisample", 0)
META:IsSet("InternalFormat", "rgba8")
META:IsSet("SRGB", true)
META:EndStorable()

META:IsSet("Loading", false)

local texture_formats = {
	depth_component16 = {bits = {16}},
	depth_component24 = {bits = {24}},
	depth_component32f = {bits = {32}, float = true},
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
	rgb10_a2ui = {bits = {10, 10, 10, 2}},
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
	r8ui = {bits = {8}},
	r16i = {signed = true, bits = {16}},
	r16ui = {bits = {16}},
	r32i = {signed = true, bits = {32}},
	r32ui = {bits = {32}},
	rg8i = {signed = true, bits = {8, 8}},
	rg8ui = {bits = {8, 8}},
	rg16i = {signed = true, bits = {16, 16}},
	rg16ui = {bits = {16, 16}},
	rg32i = {signed = true, bits = {32, 32}},
	rg32ui = {bits = {32, 32}},
	rgb8i = {signed = true, bits = {8, 8, 8}},
	rgb8ui = {bits = {8, 8, 8}},
	rgb16i = {signed = true, bits = {16, 16, 16}},
	rgb16ui = {bits = {16, 16, 16}},
	rgb32i = {signed = true, bits = {32, 32, 32}},
	rgb32ui = {bits = {32, 32, 32}},
	rgba8i = {signed = true, bits = {8, 8, 8, 8}},
	rgba8ui = {bits = {8, 8, 8, 8}},
	rgba16i = {signed = true, bits = {16, 16, 16, 16}},
	rgba16ui = {bits = {16, 16, 16, 16}},
	rgba32i = {signed = true, bits = {32, 32, 32, 32}},
	rgba32ui = {bits = {32, 32, 32, 32}},
}

render.texture_formats = texture_formats

local function get_upload_format(size, reverse, integer, depth, stencil)
	if depth and stencil then
		return "depth_stencil"
	elseif depth then
		return "depth_component"
	elseif stencil then
		return "stencil_index"
	end

	if size == 1 then
		if integer then
			return "red_integer"
		else
			return "red"
		end
	elseif size == 2 then
		if integer then
			return "rg_integer"
		else
			return "rg"
		end
	elseif size == 3 then
		if reverse then
			if integer then
				return "bgr_integer"
			else
				return "bgr"
			end
		else
			if integer then
				return "rgb_integer"
			else
				return "rgb"
			end
		end
	elseif size == 4 then
		if reverse then
			if integer then
				return "bgra_integer"
			else
				return "bgra"
			end
		else
			if integer then
				return "rgba_integer"
			else
				return "rgba"
			end
		end
	end
end

local number_types = {
	unsigned_byte = {type = "uint8_t"},
	byte = {type = "int8_t"},
	unsigned_short = {type = "uint16_t"},
	short = {type = "int16_t"},
	unsigned_int = {type = "uint32_t"},
	int = {type = "int32_t"},
	half_float = {type = "float", float = true},
	float = {type = "double", float = true},

	-- these are combined, so like rgba can be packed into one whole integer
	unsigned_byte_3_3_2 = {type = "uint8_t", combined = true},
	unsigned_byte_2_3_3_rev = {type = "uint8_t", combined = true},
	unsigned_short_5_6_5 = {type = "uint16_t", combined = true},
	unsigned_short_5_6_5_rev = {type = "uint16_t", combined = true},
	unsigned_short_4_4_4_4 = {type = "uint16_t", combined = true},
	unsigned_short_4_4_4_4_rev = {type = "uint16_t", combined = true},
	unsigned_short_5_5_5_1 = {type = "uint16_t", combined = true},
	unsigned_short_1_5_5_5_rev = {type = "uint16_t", combined = true},
	unsigned_int_8_8_8_8 = {type = "uint32_t", combined = true},
	unsigned_int_8_8_8_8_rev = {type = "uint32_t", combined = true},
	unsigned_int_10_10_10_2 = {type = "uint32_t", combined = true},
	unsigned_int_2_10_10_10_rev = {type = "uint32_t", combined = true},
	unsigned_int_24_8 = {type = "uint32_t", combined = true},
	unsigned_int_10f_11f_11f_rev = {type = "uint32_t", combined = true, float = true},
	unsigned_int_5_9_9_9_rev = {type = "uint32_t", combined = true, float = true},
	float_32_unsigned_int_24_8_rev = {type = "", combined = true},
}

local letters = {"r", "g", "b", "a"}

for friendly, info in pairs(texture_formats) do
	local line = "struct {"
	local type

	for i, bit in ipairs(info.bits) do
		type = ""

		if not info.float then
			if not info.signed then
				type = type .. "u"
			end

			type = type .. "int"
		end

		if info.float then
			type = "float"
		else
			if bit > 0 and bit <= 8 then
				bit = 8
			elseif bit >= 8 and bit <= 16 then
				bit = 16
			elseif bit >= 16 and bit <= 32 then
				bit = 32
			end

			type = type .. bit .. "_t"
		end

		line = line .. type .. " " .. letters[i] .. "; "
	end

	local ending = table.concat(info.bits, "_")

	info.combined_number_types = {}

	for friendly2, info2 in pairs(number_types) do
		if not info2.enum then
			info2.enum = gl.e[TOENUM(friendly2)]
			info2.friendly = friendly2
		end

		if info2.combined then
			if friendly2:match(".-_.-_(.+)"):gsub("_rev", "") == ending then
				table.insert(info.combined_number_types, info2)
			end
		else
			if info2.type == type then
				info.number_type = info2
			end
		end
	end

	line = line .. "} "
	info.ctype = ffi.typeof(line)
	info.tdef = friendly .. "_pixel"
	line = line .. info.tdef .. ";"
	ffi.cdef("typedef " .. line)

	info.enum = gl.e[TOENUM(friendly)]
end

do -- add get set functions based on parameters
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
		texture_max_anisotropy_ext = {friendly = "Anisotropy", type = "int", default = -1, translate = function(num)
			if not render.max_anisotropy then
				local largest = ffi.new("float[1]")
				gl.GetFloatv("GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT", largest)
				render.max_anisotropy = largest[0]
			end

			if num == -1 or num > render.max_anisotropy then
				return render.max_anisotropy
			end

			if num == 0 then
				return 1
			end
		end}, -- TEXTURE_MAX_ANISOTROPY_EXT
	}

	for k, v in pairs(parameters) do
		local friendly = v.friendly or k:match("texture(_.+)"):gsub("_(.)", string.upper)
		local info = META:GetSet(friendly, v.default)
		local enum = "GL_" .. k:upper()

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
				self.gl_tex:SetParameterfv(enum, ffi.cast("const float *", (v.translate and v.translate(val) or val)))
			end
		end

		v.getset_info = info
	end

	local old = META.SetMinFilter

	function META:SetMinFilter(val)
		if val == "nearest" then
			self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", 1)
		end
		return old(self, val)
	end

	local old = META.SetMagFilter

	function META:SetMagFilter(val)
		if val == "nearest" then
			self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", 1)
		end
		return old(self, val)
	end

	local old = META.SetAnisotropy

	function META:SetAnisotropy(val)
		if self.MinFilter == "nearest" or self.MagFilter == "nearest" then
			self.Anisotropy = val
			return
		end
		return old(self, val)
	end
end

function META:__copy()
	return self
end

function META:SetPath(path, face, flip_y)
	self.Path = path

	self.Loading = true

	resource.Download(path, function(full_path)
		local buffer, w, h, info = render.DecodeTexture(vfs.Read(full_path), full_path)

		if buffer then
			self:SetSize(Vec2(w, h))

			if info.internal_format then
				self:SetInternalFormat(info.internal_format)
				if not self.storage_setup then
					self:SetupStorage()
				end
			end

			if flip_y == nil then
				flip_y = not full_path:endswith(".vtf")
			end

			self:Upload({
				buffer = buffer,
				width = w,
				height = h,
				format = info.format or "bgra",
				face = face, -- todo
				flip_y = flip_y,
			})
		else
			local reason = w or "unknown"
			reason = "decoding failed: " .. reason
			self:MakeError(reason)
			logf("[%s] unable to find %s: %s\n", self, path, reason)
		end

		self.Loading = false

		if self.OnLoad then
			self:OnLoad()
		end
	end, function(reason)
		logf("[%s] unable to find %s: %s\n", self, path, reason)
		self.Loading = false
		self:MakeError(reason)
	end)
end

do -- todo
	local faces = {
		"ft",
		"bk",
		"up",
		"dn",
		"rt",
		"lf",
	}
--[[
"FRONT",
"BACK",
"LEFT",
"RIGHT",
"TOP",
"BOTTOM",
]]

	function META:LoadCubemap(path)
		path = path:sub(0,-1)
		for i, face in pairs(faces) do
			self:SetPath(path:gsub("(%..+)", function(rest) return face .. rest end), i, false)
		end
	end
end

function META:OnRemove()
	self.gl_tex:Delete()
end

function META:SetupStorage()
	render.StartDebug()

	local internal_format = TOENUM(self.InternalFormat)

	local mip_map_levels = self.MipMapLevels

	if mip_map_levels <= 0 then
		mip_map_levels = math.floor(math.log(math.max(self.Size.x, self.Size.y)) / math.log(2)) + 1
	end

	self:SetMaxLevel(mip_map_levels)
	self:SetBaseLevel(0)

	if self.SRGB and SRGB then
		if internal_format == "GL_RGB8" then
			internal_format = "GL_SRGB8"
		elseif internal_format == "GL_RGBA8" then
			internal_format = "GL_SRGB8_ALPHA8"
		end
	end

	if self.StorageType == "3d" then
		if gl.TexStorage3D then
			self.gl_tex:Storage3D(
				levels,
				TOENUM(self.InternalFormat),
				self.Size.x,
				self.Size.y,
				self.Depth
			)
		else
			local format = self:GetFormatInfo()
			self.gl_tex:Image3D(
				"GL_TEXTURE_3D",
				mip_map_levels,
				internal_format,
				self.Size.x,
				self.Size.y,
				self.Depth,
				0,
				TOENUM(format.preferred_upload_format),
				TOENUM(format.preferred_upload_type),
				nil
			)
		end
	elseif self.StorageType == "2d" or self.StorageType == "rectangle" or self.StorageType == "cube_map" or self.StorageType == "2d_array" then
		if gl.TexStorage2D then
			if self.Multisample > 0 then
				self.gl_tex:Storage2DMultisample(
					self.Multisample,
					mip_map_levels,
					internal_format,
					self.Size.x,
					self.Size.y,
					1
				)
			else
				self.gl_tex:Storage2D(
					mip_map_levels,
					internal_format,
					self.Size.x,
					self.Size.y
				)
			end
		else
			local format = self:GetFormatInfo()
			self.gl_tex:Image2D(
				"GL_TEXTURE_2D",
				mip_map_levels,
				internal_format,
				self.Size.x,
				self.Size.y,
				0,
				TOENUM(format.preferred_upload_format),
				TOENUM(format.preferred_upload_type),
				nil
			)
		end
	elseif self.StorageType == "1d" or self.StorageType == "1d_array" then
		if gl.TexStorage1D then
			self.gl_tex:Storage1D(
				levels,
				TOENUM(self.InternalFormat),
				self.Size.x
			)
		else
			local format = self:GetFormatInfo()
			self.gl_tex:Image1D(
				"GL_TEXTURE_1D",
				mip_map_levels,
				internal_format,
				self.Size.x,
				0,
				TOENUM(format.preferred_upload_format),
				TOENUM(format.preferred_upload_type),
				nil
			)
		end
	end

	if gl.GetTextureHandleARB then
		self.bindless_handle = gl.GetTextureHandleARB(self.id)
		gl.MakeTextureHandleResidentARB(self.bindless_handle)
	end

	local msg = render.StopDebug()
	if msg then
		logn("==================================")
		logn(self, ":SetupStorage() failed")
		logn("==================================")
		self:DumpInfo()
		logn("==================================")
		warning("\n" .. msg, 2)
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
	data.width = data.width or self:GetSize().x
	data.height = data.height or self:GetSize().y

	if type(data.buffer) == "string" then
		data.buffer = ffi.cast("uint8_t *", data.buffer)
	elseif type(data.buffer) == "table" and typex(data.buffer[1]) == "color" then
		local numbers = {}
		local i2 = 0
		for i = 1, #data.buffer do
			numbers[i2] = data.buffer[i].r * 255 i2 = i2 + 1
			numbers[i2] = data.buffer[i].g * 255 i2 = i2 + 1
			numbers[i2] = data.buffer[i].b * 255 i2 = i2 + 1
			numbers[i2] = data.buffer[i].a * 255 i2 = i2 + 1
		end
		data.buffer = ffi.new("uint8_t[".. (data.width * data.height) * 4 .."]", numbers)
		data.flip_y = true
	end

	check(data.buffer, "cdata")

	if self.StorageType == "cube_map" then
		if data.face then
			data.z = data.face - 1
		end
		data.depth = data.depth or 1
	end

	local y

	if data.y then
		y = -data.y + self.Size.y - data.height
	end

	if data.flip_y or data.flip_x then
		local stride

		if data.format == "rgba" or data.format == "bgra" then
			stride = 4
		elseif data.format == "rgb" or data.format == "bgr" then
			stride = 3
		else
			stride = 1
		end

		local buffer = ffi.cast("uint8_t *", data.buffer)
		local new_buffer = ffi.new("uint8_t[?]", data.width * data.height * stride)

		if data.flip_y and data.flip_x then
			for s = 0, stride - 1 do
			for x = 0, data.width - 1 do
			for y = 0, data.height - 1 do
				local i1 = (y * stride * data.width + x * stride) + s
				local i2 = ((-y+data.height-1) * stride * data.width + (-x+data.width-1) * stride) + s
				new_buffer[i1] = buffer[i2]
			end
			end
			end
		elseif data.flip_y then
			for s = 0, stride - 1 do
			for x = 0, data.width - 1 do
			for y = 0, data.height - 1 do
				local i1 = (y * stride * data.width + x * stride) + s
				local i2 = ((-y+data.height-1) * stride * data.width + x * stride) + s
				new_buffer[i1] = buffer[i2]
			end
			end
			end
		elseif data.flip_x then
			for s = 0, stride - 1 do
			for x = 0, data.width - 1 do
			for y = 0, data.height - 1 do
				local i1 = (y * stride * data.width + x * stride) + s
				local i2 = (y * stride * data.width + (-x+data.width-1) * stride) + s
				new_buffer[i1] = buffer[i2]
			end
			end
			end
		end

		data.buffer = new_buffer
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

	self:GenerateMipMap()

	self.downloaded_image = nil

	local msg = render.StopDebug()
	if msg then
		logn("==================================")
		logn(tostring(self) .. ":Upload() failed")
		logf("format = %s\n", TOENUM(data.format))
		logf("type = %s\n", TOENUM(data.type))
		logf("x,y,z = %s, %s, %s\n", data.x, y or 0, data.z or 0)
		logf("w,h,d = %s, %s\n", data.width, data.height or 0, data.depth or 0)
		logf("buffer = %s\n", data.buffer)
		self:DumpInfo()
		warning("\n" .. msg)
	end

	return self
end

function META:GenerateMipMap()
	self.gl_tex:GenerateMipmap()

	return self
end

function META:DumpInfo()
	logn("==================================")
		logn("storage type = ", self.StorageType)
		logn("internal format = ", TOENUM(self.InternalFormat))
		if self.MipMapLevels > 0 then
			logn("mip map levels = ", self.MipMapLevels)
		else
			logn("mip map levels = ", math.floor(math.log(math.max(self.Size.x, self.Size.y)) / math.log(2)) + 1, "(", self, ".MipMapLevels = ", self.MipMapLevels ,")")
		end
		logn("size = ", self.Size)
		if self.StorageType == "3d" then
			logn("depth = ", self.Depth)
		end
		log(self:GetDebugTrace())
	logn("==================================")
end

function META:MakeError(reason)
	if render.GetErrorTexture() then self.gl_tex = render.GetErrorTexture().gl_tex end -- :(
	self.error_reason = reason
end

function META:GetFormatInfo(format_override)
	local internal_format = format_override or self.InternalFormat
	local format = table.copy(texture_formats[internal_format:lower()])

	format.preferred_upload_format = get_upload_format(#format.bits, false, false, internal_format:lower():find("depth", nil, true), internal_format:lower():find("stencil", nil, true))
	format.preferred_upload_type = format.number_type.friendly

	return format
end

function META:CreateBuffer(format_override)
	local format = self:GetFormatInfo(format_override)
	local size = self.Size.x * self.Size.y * ffi.sizeof(format.ctype)
	local buffer = ffi.malloc(format.tdef, size)

	return buffer, size, format
end

function META:Download(mip_map_level, format_override)
	render.StartDebug()

	mip_map_level = mip_map_level or 0

	local buffer, size, format = self:CreateBuffer(format_override)

	self.gl_tex:GetImage(mip_map_level, TOENUM(format.preferred_upload_format), format.number_type.enum, size, buffer)

	local msg = render.StopDebug()
	if msg then
		logn("==================================")
		logn(tostring(self) .. ":Upload() failed")
		self:DumpInfo()
		table.print(data)
		warning("\n" .. msg, 2)
	end

	return {
		type = format.number_type.friendly,
		buffer = buffer,
		width = self.Size.x,
		height = self.Size.y,
		format = format.preferred_upload_format,
		mip_map_level = mip_map_level,
		size = self.Size.x * self.Size.y * ffi.sizeof(format.ctype),
		length = (self.Size.x * self.Size.y) - 1, -- for i = 0, data.length do
		channels = #format.bits,
	}
end

function META:Clear(mip_map_level)
	local data = self:Download(mip_map_level)

	if data.channels == 4 then
		for i = 0, data.length do
			data.buffer[i].r = 0
			data.buffer[i].g = 0
			data.buffer[i].b = 0
			data.buffer[i].a = 0
		end
	elseif data.channels == 3 then
		for i = 0, data.length do
			data.buffer[i].r = 0
			data.buffer[i].g = 0
			data.buffer[i].b = 0
		end
	elseif data.channels == 2 then
		for i = 0, data.length do
			data.buffer[i].r = 0
			data.buffer[i].g = 0
		end
	elseif data.channels == 1 then
		for i = 0, data.length do
			data.buffer[i].r = 0
		end
	end

	self:Upload(data)
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

	function META:Shade(fragment_shader, vars)
		if not surface.IsReady() then
			event.AddListener("SurfaceInitialized", self, function()
				self:Shade(fragment_shader, vars)
			end, {remove_after_one_call = true})
			return
		end

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

			render.SetShaderOverride(shader)
			surface.rect_mesh:Draw()
			render.SetShaderOverride()
		self:EndWrite()

		return self
	end

end

function META:Bind(location)
	if BINDLESS then return end
	if self.Loading then
		self = render.GetLoadingTexture()
	end

	self.gl_tex:Bind(location or 0)
end

META:Register()

function render.CreateTexture(type)
	local self = prototype.CreateObject(META)

	if type then
		self.StorageType = type
	end

	self.gl_tex = gl.CreateTexture("GL_TEXTURE_" .. self.StorageType:upper())
	self.not_dsa = not gl.CreateTextures
	self.id = self.gl_tex.id -- backwards compatibility

	if type == "cube_map" then
		self:SetWrapS("clamp_to_edge")
		self:SetWrapT("clamp_to_edge")
		self:SetWrapR("clamp_to_edge")
		self:SetMinFilter("linear_mipmap_linear")
		self:SetMagFilter("linear")
		--self:SetBaseLevel(0)
		--self:SetMaxLevel(0)
	else
		self:SetWrapS("repeat")
		self:SetWrapT("repeat")
		self:SetWrapR("repeat")
		self:SetMinFilter("linear_mipmap_linear")
		self:SetMagFilter("linear")
		self:SetAnisotropy(100)
	end

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
	local path, srgb = ...
	if type(path) == "string" then
		if render.texture_path_cache[path] then
			return render.texture_path_cache[path]
		end

		local self = render.CreateTexture("2d")
		if srgb ~= nil then
			self:SetSRGB(srgb)
		end
		self:SetPath(path)

		render.texture_path_cache[path] = self

		return self
	end

	local w,h,shade = ...
	if type(w) == "number" and type(h) == "number" then
		local self = render.CreateTexture("2d")
		self:SetSize(Vec2(w, h))
		self:SetupStorage()
		self:Clear()

		if shade then
			self:Shade(shade)
			self:GenerateMipMap()
			self.fb = nil
			self.shaders = nil
		end

		return self
	end

	local size, shade = ...
	if typex(size) == "vec2" then
		local self = render.CreateTexture("2d")
		self:SetSize(size:Copy())
		self:SetupStorage()
		self:Clear()

		if shade then
			self:Shade(shade)
			self:GenerateMipMap()
			self.fb = nil
			self.shaders = nil
		end

		return self
	end

	return render.CreateTexture(...)
end

serializer.GetLibrary("luadata").SetModifier("texture", function(var) return ("Texture(%q)"):format(var:GetPath()) end, "Texture")