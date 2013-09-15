 
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
		
		local buffer = ffi.new(self.format.buffer_type.."[?]", self.size.w * self.size.h * self.format.stride)

		gl.BindTexture(e.GL_TEXTURE_2D, self.id)
			gl.GetTexImage(e.GL_TEXTURE_2D, 0, self.format.format, self.format.type, buffer)
		gl.BindTexture(e.GL_TEXTURE_2D, 0)

		return buffer 
	end
	
	function META:Upload(buffer, x, y, w, h)
		x = x or 0
		y = y or 0
		w = w or self.size.w
		h = h or self.size.h
	
		gl.BindTexture(e.GL_TEXTURE_2D, self.id)
			gl.TexStorage2D(e.GL_TEXTURE_2D, 1, self.format.internal_format, self.size.w, self.size.h)
			gl.TexSubImage2D(e.GL_TEXTURE_2D, 0, x,y,w,h, self.format.format, self.format.type, buffer)
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
		local stride = self.format.stride
		local x, y = 0, 0
		local colors

		local buffer
		
		if write_only then
			buffer = ffi.new(self.format.buffer_type.."[?]", width*height*stride)
		else
			buffer = self:Download()
		end
		
		for x = 0, width-1 do
		for y = 0, height-1 do
			local pos = (y * width + x) * stride
			
			if write_only then
				colors = {callback(x, y, pos)}
			else
				local temp = {}
				for i = 1, stride do
					temp[i] = buffer[pos+i-1]
				end
				colors = {callback(x, y, pos, unpack(temp))}
			end
		
			for i = 1, stride do
				buffer[pos+i-1] = colors[i] or 0
			end
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

	function Texture(width, height, buffer, format)
		check(width, "number")
		check(height, "number")
		check(buffer, "nil", "cdata")
		check(format, "table", "nil")
		
		format = format or {}
		
		format.format = format.format or e.GL_BGRA
		format.internal_format = format.internal_format or e.GL_RGBA8
		format.type = format.type or e.GL_UNSIGNED_BYTE
		format.filter = format.filter ~= nil
		format.stride = format.stride or 4
		format.buffer_type = format.buffer_type or "unsigned char"

		-- create a new texture
		local id = gl.GenTexture()

		local self = setmetatable(
			{
				id = id, 
				size = Vec2(width, height), 
				format = format,
				w = width,
				h = height,
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
	local size = 16
	if not ERROR_TEXTURE then
		ERROR_TEXTURE = Texture(128, 128)
		ERROR_TEXTURE:Fill(function(x, y)
			if (math.floor(x/size) + math.floor(y/size % 2)) % 2 < 1 then
				return 255, 0, 255, 255
			else
				return 0, 0, 0, 255
			end
		end)
	end

	local img = vfs.Read(path, "rb")
	
	if not img then
		return ERROR_TEXTURE
	end
	
	local w, h, buffer = freeimage.LoadImage(img)
	
	return Texture(w,h,buffer,{internal_format = e.GL_RGBA8})
end