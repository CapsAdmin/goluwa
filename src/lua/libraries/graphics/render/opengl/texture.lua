local render = ... or _G.render
local META = prototype.GetRegistered("texture")

local ffi = require("ffi")
local gl = require("opengl")

local TOENUM = function(str)
	return "GL_" .. str:upper()
end

function META:SetMipMapLevels(val)
	self.MipMapLevels = val
	if val < 1 then
		self.gl_tex:SetParameteri("GL_TEXTURE_MAX_LEVEL", self:GetSuggestedMipMapLevels())
	else
		self.gl_tex:SetParameteri("GL_TEXTURE_MAX_LEVEL", val)
	end
end

function META:GetMipSize(mip_map_level)
	mip_map_level = mip_map_level or 1

	local x = ffi.new("GLfloat[1]")
	local y = ffi.new("GLfloat[1]")
	local z = ffi.new("GLfloat[1]")
	self.gl_tex:GetLevelParameterfv(mip_map_level - 1, "GL_TEXTURE_WIDTH", x)
	self.gl_tex:GetLevelParameterfv(mip_map_level - 1, "GL_TEXTURE_HEIGHT", y)
	self.gl_tex:GetLevelParameterfv(mip_map_level - 1, "GL_TEXTURE_DEPTH", z)

	return Vec3(x[0], y[0], z[0])
end

function META:SetSeamlessCubemap(b)
	self.SeamlessCubemap = b
	if render.IsExtensionSupported("GL_ARB_seamless_cubemap_per_texture") then
		self.gl_tex:SetParameteri("GL_TEXTURE_CUBE_MAP_SEAMLESS", b and 1 or 0)
	end
end

function META:SetWrapS(val)
	self.WrapS = val
	self.gl_tex:SetParameteri("GL_TEXTURE_WRAP_S", gl.e[TOENUM(val)])
end
function META:SetWrapT(val)
	self.WrapT = val
	self.gl_tex:SetParameteri("GL_TEXTURE_WRAP_T", gl.e[TOENUM(val)])
end
function META:SetWrapR(val)
	self.WrapR = val
	self.gl_tex:SetParameteri("GL_TEXTURE_WRAP_R", gl.e[TOENUM(val)])
end

function META:SetCompareFunc(val)
	self.CompareFunc = val
	self.gl_tex:SetParameteri("GL_TEXTURE_COMPARE_FUNC", gl.e[TOENUM(val)])
end
function META:SetCompareMode(val)
	self.CompareMode = val
	self.gl_tex:SetParameteri("GL_TEXTURE_COMPARE_MODE", gl.e[TOENUM(val)])
end

function META:SetBorderColor(val)
	self.BorderColor = val
	self.gl_tex:SetParameterfv("GL_TEXTURE_BORDER_COLOR", ffi.cast("const float *", val))
end

function META:SetSwizzleR(val)
	self.SwizzleR = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_R", gl.e[TOENUM(val)])
end
function META:SetSwizzleG(val)
	self.SwizzleG = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_G", gl.e[TOENUM(val)])
end
function META:SetSwizzleB(val)
	self.SwizzleB = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_B", gl.e[TOENUM(val)])
end
function META:SetSwizzleA(val)
	self.SwizzleA = val
	self.gl_tex:SetParameteri("GL_TEXTURE_SWIZZLE_A", gl.e[TOENUM(val)])
end
function META:SetSwizzleRgba(val)
	self.SwizzleRgba = val
	self.gl_tex:SetParameterfv("GL_TEXTURE_SWIZZLE_RGBA", ffi.cast("const float *", val))
end

function META:SetMinLod(val)
	self.MinLod = val
	self.gl_tex:SetParameterf("GL_TEXTURE_MIN_LOD", val)
end
function META:SetMaxLod(val)
	self.MaxLod = val
	self.gl_tex:SetParameterf("GL_TEXTURE_MAX_LOD", val)
end
function META:SetBaseLevel(val)
	self.BaseLevel = val
	self.gl_tex:SetParameteri("GL_TEXTURE_BASE_LEVEL", val)
end
function META:SetMaxLevel(val)
	self.MaxLevel = val
	self.gl_tex:SetParameteri("GL_TEXTURE_MAX_LEVEL", val)
end
function META:SetLodBias(val)
	self.LodBias = val
	self.gl_tex:SetParameterf("GL_TEXTURE_LOD_BIAS", val)
end

function META:SetAnisotropy(num)
	self.Anisotropy = num

	if render.IsExtensionSupported("GL_EXT_texture_filter_anisotropic") then
		if self.MinFilter == "nearest" or self.MagFilter == "nearest" then
			return
		end

		if num == -1 or num > render.max_anisotropy then
			num = render.max_anisotropy
		end

		if num == 0 then
			num = 1
		end

		self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", num)
	end
end
function META:SetMagFilter(val)
	self.MagFilter = val
	if val == "nearest" and render.IsExtensionSupported("GL_EXT_texture_filter_anisotropic") then
		self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", 1)
	end
	self.gl_tex:SetParameteri("GL_TEXTURE_MAG_FILTER", gl.e[TOENUM(val)])
end
function META:SetMinFilter(val)
	self.MinFilter = val
	if val == "nearest" and render.IsExtensionSupported("GL_EXT_texture_filter_anisotropic") then
		self.gl_tex:SetParameteri("GL_TEXTURE_MAX_ANISOTROPY_EXT", 1)
	end
	self.gl_tex:SetParameteri("GL_TEXTURE_MIN_FILTER", gl.e[TOENUM(val)])
end

function META:OnRemove()
	self.gl_tex:Delete()
end

function META:SetupStorage()
	local internal_format = TOENUM(self.InternalFormat)

	local mip_map_levels = self.MipMapLevels

	if mip_map_levels < 1 then
		mip_map_levels = self:GetSuggestedMipMapLevels()
	end

	if self.SRGB and SRGB then
		if internal_format == "GL_RGB8" then
			internal_format = "GL_SRGB8"
		elseif internal_format == "GL_RGBA8" then
			internal_format = "GL_SRGB8_ALPHA8"
		end
	end

	if self.StorageType == "3d" then
		if render.IsExtensionSupported("GL_ARB_texture_storage") then
			self.gl_tex:Storage3D(
				mip_map_levels,
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
		if render.IsExtensionSupported("GL_ARB_texture_storage") then
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
		if render.IsExtensionSupported("GL_ARB_texture_storage") then
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

	self.storage_setup = true
end

function META:SetBindless(b)
	if render.IsExtensionSupported("GL_ARB_bindless_texture") then
		self.gl_bindless_handle = self.gl_bindless_handle or gl.GetTextureHandleARB(self.gl_tex.id)

		if b then
			if not self:GetBindless() then
				gl.MakeTextureHandleResidentARB(self.gl_bindless_handle)
			end
		else
			if self:GetBindless() then
				gl.MakeTextureHandleNonResidentARB(self.gl_bindless_handle)
			end
		end
	end
end

function META:GetBindless()
	return self.gl_bindless_handle and gl.IsTextureHandleResidentARB(self.gl_bindless_handle) == 1
end

function META:MakeError(reason)
	if render.GetErrorTexture() then self.gl_tex = render.GetErrorTexture().gl_tex end -- :(
	self.error_reason = reason
end

function META:_Upload(data, y)

	if data.internal_format then
		self:SetInternalFormat(data.internal_format)
	end

	if not self.storage_setup then
		self:SetupStorage()
	end

	if self.StorageType == "3d" or self.StorageType == "cube_map" or self.StorageType == "2d_array" then
		data.x = data.x or 0
		y = y or 0
		data.z = data.z or 0

		if data.image_size then
			self.gl_tex:CompressedSubImage3D(
				data.mip_map_level - 1,
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
				data.mip_map_level - 1,
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
				data.mip_map_level - 1,
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
				data.mip_map_level - 1,
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
				data.mip_map_level - 1,
				data.x,
				data.width,
				TOENUM(data.format),
				TOENUM(data.type),
				data.image_size,
				data.buffer
			)
		else
			self.gl_tex:SubImage1D(
				data.mip_map_level - 1,
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
		wlog("NYI", 2)
	end

	self:GenerateMipMap()
end

function META:GenerateMipMap()
	self.gl_tex:GenerateMipmap()
	return self
end

function META:_Download(mip_map_level, buffer, size, format)
	self.gl_tex:GetImage(mip_map_level - 1, TOENUM(format.preferred_upload_format), gl.e[TOENUM(format.number_type.friendly)], size, buffer)
end

function META:Clear(mip_map_level)
	mip_map_level = mip_map_level or 1
	if render.IsExtensionSupported("GL_ARB_clear_texture") then
		gl.ClearTexImage(self.gl_tex.id, mip_map_level - 1, "GL_RGBA", "GL_UNSIGNED_BYTE", nil)
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
	if type == "cube_map" then
		self.gl_tex = gl.CreateTextureNODSA("GL_TEXTURE_" .. self.StorageType:upper())
		self:SetWrapS("clamp_to_edge")
		self:SetWrapT("clamp_to_edge")
		self:SetWrapR("clamp_to_edge")
		self:SetMinFilter("linear_mipmap_linear")
		self:SetMagFilter("linear")
		self:SetSeamlessCubemap(true)
		--self:SetBaseLevel(0)
		--self:SetMaxLevel(0)
	else
		self.gl_tex = gl.CreateTexture("GL_TEXTURE_" .. self.StorageType:upper())
		self:SetWrapS("repeat")
		self:SetWrapT("repeat")
		self:SetWrapR("repeat")
		self:SetMinFilter("linear_mipmap_linear")
		self:SetMagFilter("linear")
		self:SetAnisotropy(100)
	end
end

prototype.Register(META)
