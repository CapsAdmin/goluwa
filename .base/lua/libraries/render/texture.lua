local last1
local last2

local base = e.GL_TEXTURE0

function render.BindTexture(tex, location, channel)
	if tex ~= last1 or location ~= last2 then
		
		channel = channel or 0
		
		gl.ActiveTexture(base + channel) 
		gl.BindTexture(tex.format.type, tex.id) 
		gl.Uniform1i(location, channel)

		last1 = tex
		last2 = location
	end
end

local diffuse_suffixes = {
	"_diff",
	"_d",
}

function render.FindTextureFromSuffix(path, ...)

	local suffixes = {...}

	-- try to find the normal texture
	for _, suffix in pairs(suffixes) do
		local new = path:gsub("(.+)(%.)", "%1" .. suffix .. "%2")
		
		if new ~= path and vfs.Exists(new) then
			return new
		end
	end
	
	-- try again without the __diff suffix
	for _, diffuse_suffix in pairs(diffuse_suffixes) do
		for _, suffix in pairs(suffixes) do
			local new = path:gsub(diffuse_suffix .. "%.", suffix ..".")
			
			if new ~= path and vfs.Exists(new) then
				return new
			end
		end
	end
end

do -- texture object
	local META = utilities.CreateBaseMeta("texture")
	META.__index = META

	function META:__tostring()
		return ("texture[%s]"):format(self.id)
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
		-- +1 to height cause there seems to always be some noise on the last line :s
		local length = self.size.w * (self.size.h+1) * self.format.stride
		local buffer = ffi.new(self.format.buffer_type.."[?]", length)
		
		return buffer, length
	end
	
	function META:Clear(val, level)	
		level = level or 0
		local f = self.format
		
		local buffer, length = self:CreateBuffer()

		ffi.fill(buffer, length, val)

		gl.Enable(f.type)
		
		gl.BindTexture(f.type, self.id)			

		gl.TexSubImage2D(
			f.type, 
			level, 
			0,
			0,
			self.size.w,
			self.size.h, 
			f.format, 
			f.format_type, 
			buffer
		)
		
		gl.GenerateMipmap(f.type)
		
		gl.BindTexture(f.type, 0)			
				
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
	
		gl.Enable(f.type)
	
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
				x,
				y,
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
	
	local colors = ffi.new("char[4]")

	function META:Fill(callback, write_only, read_only)
		check(callback, "function")
		
		if write_only == nil then
			write_only = true
		end
		
		local width = self.size.w
		local height = self.size.h		
		local stride = self.format.stride
		local x, y = 0, 0
		

		local buffer
		
		if write_only then
			buffer = ffi.new(self.format.buffer_type.."[?]", width*height*stride)
		else
			buffer = self:Download()
		end	
	
		for y = 0, height-1 do
		for x = 0, width-1 do
			local pos = (y * width + x) * stride
			
			if write_only then
				colors[0], colors[1], colors[2], colors[3] = callback(x, y, pos)
			else
				local temp = {}
				for i = 0, stride-1 do
					temp[i] = buffer[pos+i]
				end
				if read_only then
					if callback(x, y, pos, unpack(temp)) ~= nil then return end
				else
					colors[0], colors[1], colors[2], colors[3] = callback(x, y, pos, unpack(temp))
				end
			end
		
			if not read_only then
				for i = 0, stride-1 do
					buffer[pos+i] = colors[i]
				end
			end
		end
		end

		if not read_only then
			self:Upload(buffer)
		end
		
		return self
	end
	
	function META:Shade(fragment_shader, vars)
		local data = {
			shared = {
				uniform = vars,
			},
			
			vertex = {
				uniform = {
					pwm_matrix = "mat4",
				},			
				attributes = {
					{pos = "vec2"},
					{uv = "vec2"},
				},	
				source = "gl_Position = pwm_matrix * vec4(pos, 0, 1);"
			},
			
			fragment = { 
				uniform = {
					self = "texture",
				},		
				attributes = {
					uv = "vec2",
				},			
				source = fragment_shader,
			} 
		} 
		 
		local shader = SuperShader("temp_" .. tostring(os.clock()):gsub("%p", ""), data)

		local mesh = shader:CreateVertexBuffer({
			{pos = {0, 0}, uv = {0, 1}},
			{pos = {0, 1}, uv = {0, 0}},
			{pos = {1, 1}, uv = {1, 0}},

			{pos = {1, 1}, uv = {1, 0}},
			{pos = {1, 0}, uv = {1, 1}},
			{pos = {0, 0}, uv = {0, 1}},
		})

		mesh.pwm_matrix = render.GetPVWMatrix2D
		
		local fb = render.CreateFrameBuffer(self.w, self.h, {
			attach = e.GL_COLOR_ATTACHMENT1,
			texture_format = self.format,
		})
			
	 	fb:Begin()
			surface.PushMatrix(0, 0, surface.GetScreenSize())
				mesh.self = self
				mesh:Draw()
			surface.PopMatrix()
		fb:End()
		
		local tex = fb:GetTexture()
		local buffer = tex:Download()
		
		tex:Remove()
		shader:Remove()
		
		self:Replace(buffer, self.w, self.h)
	end
	
	local SUPPRESS_GC = false
	
	function META:Replace(data, w, h)
		gl.DeleteTextures(1, ffi.new("GLuint[1]", self.id))
		
		SUPPRESS_GC = true
		local new = render.CreateTexture(w, h,  data, self.format)
		SUPPRESS_GC = false
		
		for k, v in pairs(new) do
			self[k] = v
		end
	end
	
	function META:Remove()
		if self.format.no_remove then return end
		gl.DeleteTextures(1, ffi.new("GLuint[1]", self.id))
		utilities.MakeNULL(self)
	end
	
	function META:IsLoading()
		return self.loading
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
		format.border_size = format.border_size or 4

		format.mip_map_levels = math.max(format.mip_map_levels or 3, 3) --ATI doesn't like level under 3
		format.min_filter = format.min_filter or e.GL_LINEAR_MIPMAP_LINEAR
		format.mag_filter = format.mag_filter or e.GL_LINEAR
				
		format.wrap_s = format.wrap_s or e.GL_REPEAT
		format.wrap_t = format.wrap_t or e.GL_REPEAT
		
		if format.type == e.GL_TEXTURE_3D then
			format.wrap_r = format.wrap_r or e.GL_REPEAT
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
		
		gl.Enable(format.type)
		
		gl.BindTexture(format.type, self.id)

		if gl.TexStorage2D then
			gl.TexStorage2D(
				format.type, 
				format.mip_map_levels, 
				format.internal_format, 
				self.size.w, 
				self.size.h
			)
		else
			gl.TexImage2D(
				format.type,
				format.mip_map_levels,
				format.stride,
				self.size.w,
				self.size.h,
				0,
				format.format,
				format.internal_format,
				nil
			)
				
		end
		
		self:UpdateFormat()
				
		if buffer then	
			self:Upload(buffer)
		end
		
		gl.BindTexture(format.type, 0)
		
		if not SUPPRESS_GC then
			utilities.SetGCCallback(self)
		end
		
		if render.debug then
			logf("creating texture w = %s h = %s buffer size = %s", self.w, self.h, utilities.FormatFileSize(buffer and ffi.sizeof(buffer) or 0)) --The texture size was never broken... someone used two non-existant variables w,h
		end
		
		return self
	end
end

Texture = render.CreateTexture -- reload!