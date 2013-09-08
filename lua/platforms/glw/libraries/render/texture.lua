 
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

	function META:GetSize()
		return self.size
	end

	function META:Download()
		
		local buffer = ffi.new("GLubyte[?]", self.size.w * self.size.h * 4)

		gl.BindTexture(e.GL_TEXTURE_2D, self.id)
			gl.GetTexImage(e.GL_TEXTURE_2D, 0, self.format, self.type, buffer)
		gl.BindTexture(e.GL_TEXTURE_2D, 0)

		return buffer 
	end
	
	function META:Upload(buffer, x, y, w, h)
		x = x or 0
		y = y or 0
		w = w or self.size.w
		h = h or self.size.h
	
		gl.BindTexture(e.GL_TEXTURE_2D, self.id)
			gl.TexStorage2D(e.GL_TEXTURE_2D, 1, self.internal_format, self.size.w, self.size.h)
			gl.TexSubImage2D(e.GL_TEXTURE_2D, 0, x,y,w,h, self.format, self.type, buffer)
			--render.SetTextureFiltering()
		gl.BindTexture(e.GL_TEXTURE_2D, 0)
	end

	function META:Fill(callback, write_only)
		check(callback, "function")
		
		if write_only == nil then
			write_only = true
		end
		
		local width = self.size.w
		local height = self.size.h		
		local x, y = 0, 0
		local r, g, b, a

		local size = width*height*4
		local buffer
		
		if write_only then
			buffer = ffi.new("GLubyte[?]", size)
		else
			buffer = self:Download()
		end
		
		for y = 0, height-1 do
		for x = 0, width-1 do
			local i = 4*width*y+4*x		
			
			if write_only then
				r, g, b, a = callback(x, y)
				
				r = r or 1
				g = g or 1
				b = b or 1
				a = a or 1
			else
				r, g, b, a = callback(x, y, buffer[i+0], buffer[i+1], buffer[i+2], buffer[i+3])
			end
		
			if r then buffer[i+0] = r*255 end
			if g then buffer[i+1] = g*255 end
			if b then buffer[i+2] = b*255 end
			if a then buffer[i+3] = a*255 end
		end
		end
		
		self:Upload(buffer)
	end
		
	function META:IsValid()
		return true
	end
	
	function META:Remove()
		gl.DeleteTextures(1, ffi.new("GLuint[1]", self.id))
		utilities.MakeNULL(self)
	end

	function Texture(width, height, buffer, format, internal_format, type)
		check(width, "number")
		check(height, "number")
		check(buffer, "nil", "cdata")
		check(format, "number", "nil")
		
		format = format or e.GL_BGRA
		internal_format = internal_format or e.GL_RGBA8
		type = type or e.GL_UNSIGNED_BYTE

		-- create a new texture
		local id = gl.GenTexture()

		local self = setmetatable(
			{
				id = id, 
				size = Vec2(width, height), 
				format = format,
				internal_format = internal_format,
				type = type,
			}, 
			META
		)
		
		if buffer then
			self:Upload(buffer)
		end
		
		return self
	end
end

function Image(path)
	if not ERROR_TEXTURE then
		ERROR_TEXTURE = Texture(128, 128)
		ERROR_TEXTURE:Fill(function(x, y)
			if (y+x)%32 > 16 then
				return 1, 0.75, 0.5, 1
			end
			
			return 0,0,0, 1
		end)
	end

	local img = vfs.Read(path, "rb")
	
	if not img then
		return ERROR_TEXTURE
	end
	
	local w, h, buffer = freeimage.LoadImage(img)
	local internal_format = e.GL_RGBA8
	
	return Texture(w,h,buffer,nil,internal_format)
end