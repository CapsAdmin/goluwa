_E.TEX_CHANNEL_AUTO = 0
_E.TEX_CHANNEL_L = 1
_E.TEX_CHANNEL_LA = 2
_E.TEX_CHANNEL_RGB = 3
_E.TEX_CHANNEL_RGBA = 4

_E.TEX_FLAG_POWER_OF_TWO = 1
_E.TEX_FLAG_MIPMAPS = 2
_E.TEX_FLAG_TEXTURE_REPEATS = 4
_E.TEX_FLAG_MULTIPLY_ALPHA = 8
_E.TEX_FLAG_INVERT_Y = 16
_E.TEX_FLAG_COMPRESS_TO_DXT = 32
_E.TEX_FLAG_DDS_LOAD_DIRECT = 64
_E.TEX_FLAG_NTSC_SAFE_RGB = 128
_E.TEX_FLAG_COCG_Y = 256
_E.TEX_FLAG_TEXTURE_RECTANGLE = 512

do
	local META = {}

	META.__index = META
	META.Type = "texture"

	function META:__tostring()
		return ("texture[%s]"):format(self.id)
	end

	function META:Bind(...)
		render.SetTexture(self.id, ...)
	end

	function META:GetSize(mip_map_level)
		mip_map_level = mip_map_level or 0

		local width, height = ffi.new("GLint[1]"), ffi.new("GLint[1]")


		gl.BindTexture(e.GL_TEXTURE_2D, self.id)
		gl.GetTexLevelParameteriv(e.GL_TEXTURE_2D, mip_map_level, e.GL_TEXTURE_WIDTH, width)
		gl.GetTexLevelParameteriv(e.GL_TEXTURE_2D, mip_map_level, e.GL_TEXTURE_HEIGHT, height)
		gl.BindTexture(e.GL_TEXTURE_2D, 0)

		return Vec2(width[0], height[0])
	end

	function META:GetBuffer(mip_map_level)
		mip_map_level = mip_map_level or 0

		local size = self:GetSize(mip_map_level)
		local length = size.w * size.h * 4
		local buffer = ffi.new("GLubyte[?]", length)

		gl.BindTexture(e.GL_TEXTURE_2D, self.id)
		gl.GetTexImage(e.GL_TEXTURE_2D, mip_map_level, e.GL_RGBA, e.GL_UNSIGNED_BYTE, buffer)
		gl.BindTexture(e.GL_TEXTURE_2D, 0)

		return buffer, size, length
	end

	function META:Fill(callback, mip_map_level)
		check(callback, "function")
		mip_map_level = mip_map_level or 0

		local buffer, size, length = self:GetBuffer(mip_map_level)
		local w = size.w
		local x, y = 0, 0

		for i = 0, length do

			if x >= w then
				x = 0
				y = y + 1
			else
				x = x + 1
			end

			local r, g, b, a = callback(x, y, buffer[i+0], buffer[i+1], buffer[i+2], buffer[i+3])

			if r then buffer[i+0] = r end
			if g then buffer[i+1] = g end
			if b then buffer[i+2] = b end
			if a then buffer[i+3] = a end
		end

		gl.BindTexture(e.GL_TEXTURE_2D, self.id)
		gl.TexImage2D(e.GL_TEXTURE_2D, 0, e.GL_RGBA, size.w, size.h, 0, e.GL_RGBA, e.GL_UNSIGNED_BYTE, buffer)
		gl.BindTexture(e.GL_TEXTURE_2D, 0)
	end

	function META:IteratePixels(mip_map_level)
		mip_map_level = mip_map_level or 0
		local buffer, size, length = self:GetBuffer(mip_map_level)
		local w = size.w
		local x, y = 0, 0
		local i = 0

		return function()
			i = i + 1

			if i >= length then return end

			if x >= w then
				x = 0
				y = y + 1
			else
				x = x + 1
			end

			return x, y, buffer[i+0], buffer[i+1], buffer[i+2], buffer[i+3]
		end
	end
	
	function META:IsValid()
		return true
	end
	
	function META:Remove()
		gl.DeleteTextures(1, ffi.new("GLuint[1]", self.id))
		utilities.MakeNULL(self)
	end

	function Texture(width, height, buffer)
		check(width, "number")
		check(height, "number")
		check(buffer, "nil", "cdata")

		-- create a new texture
		local id = ffi.new("GLuint[1]") gl.GenTextures(1, id) id = id[0]

		gl.BindTexture(e.GL_TEXTURE_2D, id)
			render.SetTextureFiltering()
			gl.TexImage2D(e.GL_TEXTURE_2D, 0, e.GL_RGBA, width, height, 0, e.GL_RGBA, e.GL_UNSIGNED_BYTE, buffer)
		gl.BindTexture(e.GL_TEXTURE_2D, 0)
		
		return setmetatable({id = id, w = width, h = height}, META)
	end
end

function Image(path)
	return Texture(freeimage.LoadImage(vfs.Read(path, "rb")))
end