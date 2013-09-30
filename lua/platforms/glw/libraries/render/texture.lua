local last1
local last2

function render.BindTexture(tex, location)
	if tex ~= last1 or location ~= last2 then

		if tex.lol then
			--print(tex.lol, tex.gl_channel, location)
		end
	
		gl.ActiveTexture(tex.gl_channel) 
		gl.BindTexture(tex.format.type, tex.id) 
		gl.Uniform1i(location, tex.Channel)

		last1 = tex
		last2 = location
	end
end

do -- texture object
	local META = {}

	META.__index = META
	META.Type = "texture"

	function META:__tostring()
		return ("texture[%s]"):format(self.id)
	end
	
	class.GetSet(META, "Channel", 0)
	META.gl_channel = e.GL_TEXTURE0
	
	function META:SetChannel(num)
		self.Channel = num
		
		self.gl_channel = e.GL_TEXTURE0 + num
	end

	function META:GetSize()
		return self.size
	end

	function META:Download()
		local f = self.format
		local buffer = ffi.new(self.format.buffer_type.."[?]", self.size.w * self.size.h * self.format.stride)

		gl.BindTexture(f.type, self.id)
			gl.GetTexImage(f.type, 0, self.format.format, self.format.format_type, buffer)
		gl.BindTexture(f.type, 0)

		return buffer 
	end
	
	function META:CreateBuffer()
		local length = self.size.w * self.size.h * self.format.stride
		local buffer = ffi.new(self.format.buffer_type.."[?]", length)
		
		return buffer, length
	end
	
	function META:Clear(val)	
		local f = self.format
		
		local buffer, length = self:CreateBuffer()

		ffi.fill(buffer, length, val)

		gl.TexSubImage2D(
			f.type, 
			0, 
			0,
			0,
			self.size.w,
			self.size.h, 
			f.format, 
			f.format_type, 
			buffer
		)
		
		return self
	end
	
	local tex_params = {}
	for k,v in pairs(e) do
		if k:find("GL_TEXTURE_") then
			local friendly = k:match("GL_TEXTURE_(.+)")
			friendly = friendly:lower()
			tex_params[friendly] = v
		end
	end
	
	tex_params.internal_format = nil
	
	function META:UpdateFormat()
		local f = self.format		

		for k,v in pairs(f) do
			if tex_params[k] then
				gl.TexParameterf(f.type, tex_params[k], v)
			elseif type(k) == "number" then
				gl.TexParameterf(f.type, k, v)
			end
		end
	end
	
	function META:Upload(buffer, x, y, w, h, level)
		x = x or 0
		y = y or 0
		w = w or self.size.w
		h = h or self.size.h
		level = level or 0
		
		local f = self.format		
	
		gl.BindTexture(f.type, self.id)			
	
			gl.PixelStorei(e.GL_PACK_ALIGNMENT, f.stride)
			gl.PixelStorei(e.GL_UNPACK_ALIGNMENT, f.stride)
				
			self:UpdateFormat()
		
			if f.clear then
				if f.clear == true then
					self:Clear(nil)
				else
					self:Clear(f.clear)
				end
			end
			
			gl.TexSubImage2D(
				f.type, 
				level, 
				x + f.border_size,
				y + f.border_size,
				w,
				h, 
				f.format, 
				f.format_type, 
				buffer
			)

			gl.GenerateMipmap(f.type)

		gl.BindTexture(f.type, 0)
		
		return self
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
		
		return self
	end
		
	function META:IsValid()
		return true
	end
	
	function META:Remove()
		gl.DeleteTextures(1, ffi.new("GLuint[1]", self.id))
		utilities.MakeNULL(self)
	end

	function render.CreateTexture(width, height, buffer, format)
		check(width, "number")
		check(height, "number")
		check(buffer, "nil", "cdata")
		check(format, "table", "nil")
		
		if width == 0 or height == 0 then
			errorf("bad texture size (w = %i, h = %i)", 2, width, height)
		end
				
		format = format or {}
		
		format.type = format.type or e.GL_TEXTURE_2D
		format.format = format.format or e.GL_BGRA
		format.internal_format = format.internal_format or e.GL_RGBA8
		format.format_type = format.format_type or e.GL_UNSIGNED_BYTE
		format.filter = format.filter ~= nil
		format.stride = format.stride or 4
		format.buffer_type = format.buffer_type or "unsigned char"
		format.mip_map_levels = format.mip_map_levels or 4
		format.border_size = format.border_size or 0
		
		format.wrap_t = format.wrap_t or e.GL_MIRRORED_REPEAT
		format.wrap_s = format.wrap_s or e.GL_MIRRORED_REPEAT
		
		if format.type == e.GL_TEXTURE_3D then
			format.wrap_r = format.wrap_r or e.GL_MIRRORED_REPEAT
		end

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
		
		gl.BindTexture(format.type, self.id)

		gl.TexStorage2D(
			format.type, 
			format.mip_map_levels, 
			format.internal_format, 
			self.size.w + format.border_size, 
			self.size.h + format.border_size
		)
		
		self:UpdateFormat()
				
		if buffer then	
			self:Upload(buffer)
		end
		
		gl.BindTexture(format.type, 0)
		
		utilities.SetGCCallback(self)
		
		return self
	end
end