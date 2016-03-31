local render, META = ...
render = render or _G.render
META = META or prototype.GetRegistered("texture")

local ffi = require("ffi")

local gl = require("libopengl")

local TOENUM = function(str)
	return "GL_" .. str:upper()
end

function META:SetWrapS(val)
	self.WrapS = val
	self.gl_tex:SetParameteri("GL_TEXTURE_WRAP_S", gl.e[TOENUM(val)])
end
function META:SetSwizzleRgba(val)
	self.SwizzleRgba = val
	self.gl_tex:SetParameterfv("GL_TEXTURE_SWIZZLE_RGBA", ffi.cast("const float *", val))
end
function META:SetSwizzleG(val)
	self.SwizzleG = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_G", gl.e[TOENUM(val)])
end
function META:SetCompareFunc(val)
	self.CompareFunc = val
	self.gl_tex:SetParameteri("GL_TEXTURE_COMPARE_FUNC", gl.e[TOENUM(val)])
end
function META:SetMagFilter(val)
	self.MagFilter = val
	if val == "nearest" then
		self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", 1)
	end
	self.gl_tex:SetParameteri("GL_TEXTURE_MAG_FILTER", gl.e[TOENUM(val)])
end
function META:SetWrapR(val)
	self.WrapR = val
	self.gl_tex:SetParameteri("GL_TEXTURE_WRAP_R", gl.e[TOENUM(val)])
end
function META:SetBaseLevel(val)
	self.BaseLevel = val
	self.gl_tex:SetParameteri("GL_TEXTURE_BASE_LEVEL", val)
end
function META:SetAnisotropy(num)
	self.Anisotropy = num

	if self.MinFilter == "nearest" or self.MagFilter == "nearest" then
		return
	end

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

	self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", num)
end
function META:SetCompareMode(val)
	self.CompareMode = val
	self.gl_tex:SetParameteri("GL_TEXTURE_COMPARE_MODE", gl.e[TOENUM(val)])
end
function META:SetWrapT(val)
	self.WrapT = val
	self.gl_tex:SetParameteri("GL_TEXTURE_WRAP_T", gl.e[TOENUM(val)])
end
function META:SetMaxLod(val)
	self.MaxLod = val
	self.gl_tex:SetParameterf("GL_TEXTURE_MAX_LOD", val)
end
function META:SetSwizzleA(val)
	self.SwizzleA = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_A", gl.e[TOENUM(val)])
end
function META:SetLodBias(val)
	self.LodBias = val
	self.gl_tex:SetParameterf("GL_TEXTURE_LOD_BIAS", val)
end
function META:SetMaxLevel(val)
	self.MaxLevel = val
	self.gl_tex:SetParameteri("GL_TEXTURE_MAX_LEVEL", val)
end
function META:SetBorderColor(val)
	self.BorderColor = val
	self.gl_tex:SetParameterfv("GL_TEXTURE_BORDER_COLOR", ffi.cast("const float *", val))
end
function META:SetSwizzleR(val)
	self.SwizzleR = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_R", gl.e[TOENUM(val)])
end
function META:SetSwizzleB(val)
	self.SwizzleB = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_B", gl.e[TOENUM(val)])
end
function META:SetMinFilter(val)
	self.MinFilter = val
	if val == "nearest" then
		self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", 1)
	end
	self.gl_tex:SetParameteri("GL_TEXTURE_MIN_FILTER", gl.e[TOENUM(val)])
end
function META:SetMinLod(val)
	self.MinLod = val
	self.gl_tex:SetParameterf("GL_TEXTURE_MIN_LOD", val)
end

function META:OnRemove()
	self.gl_tex:Delete()
end

function META:_SetupStorage()
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
		if window.IsExtensionSupported("GL_ARB_texture_storage") then
			self.gl_tex:Storage3D(
				levels,
				TOENUM(self.InternalFormat),
				self.Size.x,
				self.Size.y,
				self.Depth
			)
		else
			local format = render.GetTextureFormatInfo(self.InternalFormat)
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
		if window.IsExtensionSupported("GL_ARB_texture_storage") then
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
			local format = render.GetTextureFormatInfo(self.InternalFormat)
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
		if window.IsExtensionSupported("GL_ARB_texture_storage") then
			self.gl_tex:Storage1D(
				levels,
				TOENUM(self.InternalFormat),
				self.Size.x
			)
		else
			local format = render.GetTextureFormatInfo(self.InternalFormat)
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

	local msg = render.StopDebug()
	if msg then
		logn("==================================")
		logn(self, ":SetupStorage() failed")
		logn("==================================")
		self:DumpInfo()
		logn("==================================")
		warning("\n" .. msg, 2)
	end
end

function META:MakeError(reason)
	if render.GetErrorTexture() then self.gl_tex = render.GetErrorTexture().gl_tex end -- :(
	self.error_reason = reason
end

function META:_Upload(data)

	if data.internal_format then
		self:SetInternalFormat(data.internal_format)
	end

	if not self.storage_setup then
		self:SetupStorage()
	end

	render.StartDebug()

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
end

function META:_GenerateMipMap()
	self.gl_tex:GenerateMipmap()
	return self
end

function META:_Download(mip_map_level, buffer, size, format)
	render.StartDebug()

	self.gl_tex:GetImage(mip_map_level, TOENUM(format.preferred_upload_format), gl.e[TOENUM(format.number_type.friendly)], size, buffer)

	local msg = render.StopDebug()

	if msg then
		logn("==================================")
		logn(tostring(self) .. ":Upload() failed")
		self:DumpInfo()
		table.print(data)
		warning("\n" .. msg, 2)
	end
end

function META:Clear(mip_map_level)
	if window.IsExtensionSupported("GL_ARB_clear_texture") then
		gl.ClearTexImage(self.gl_tex.id, mip_map_level or 0, "GL_RGBA", "GL_UNSIGNED_BYTE", nil)
	else
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
end

function META:GetID()
	return self.gl_tex.id
end

function META:Bind(location)
	if self.Loading then
		self = render.GetLoadingTexture()
	end

	self.gl_tex:Bind(location or 0)
end

function render._CreateTexture(self, type)
	self.gl_tex = gl.CreateTexture("GL_TEXTURE_" .. self.StorageType:upper())

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
end