local render = (...) or _G.render

render.textures = setmetatable({}, { __mode = 'v' })

function render.GetTextures()
	return render.textures
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

do -- texture binding
	do
		local last
		
		function render.ActiveTexture(id)
			if id ~= last then
				gl.ActiveTexture(id)
				last = id
			end
		end
	end

	do
		local last
		
		function render.BindTexture(tex)
			if tex ~= last then
				if typex(tex) == "gif" then
					tex = tex:GetTexture()
				end
				
				render.ActiveTexture(tex.texture_channel)
				gl.BindTexture(tex.format.type, tex.id) 
			end
		end
	end
end

do -- texture object
	local META = utilities.CreateBaseMeta("texture")
	
	function META:__tostring()
		return ("texture[%s]"):format(self.id)
	end
	
	function META:GetSize()
		return self.size
	end

	function META:Download(level, format)
		local f = self.format
		local buffer = self:CreateBuffer()

		gl.BindTexture(f.type, self.id)
			gl.GetTexImage(f.type, level or 0, f.format, format or f.internal_format, buffer)
		gl.BindTexture(f.type, 0)

		return buffer
	end
	
	function META:CreateBuffer()
		-- +1 to height cause there seems to always be some noise on the last line :s
		local length = self.size.w * (self.size.h+1) * self.format.stride
		local buffer = ffi.malloc(self.format.buffer_type.. "*", length)--ffi.new(self.format.buffer_type.."[?]", length)
		
		return buffer, length
	end
	
	function META:Clear(val, level)	
		level = level or 0
		local f = self.format
		
		local buffer, length = self:CreateBuffer()

		ffi.fill(buffer, length, val)
		
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
			buffer = self:CreateBuffer()
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
		if type(width) == "string" and not buffer and not format and (not height or type(height) == "table") then
			return render.CreateTextureFromPath(width, height)
		end
		
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
		format.channel = format.channel or 0

		format.mip_map_levels = math.max(format.mip_map_levels or 3, 3) --ATI doesn't like level under 3
		format.min_filter = format.min_filter or e.GL_LINEAR
		format.mag_filter = format.mag_filter or e.GL_LINEAR
				
		format.wrap_s = format.wrap_s or e.GL_REPEAT
		format.wrap_t = format.wrap_t or e.GL_REPEAT
		
		if format.type == e.GL_TEXTURE_3D then
			format.wrap_r = format.wrap_r or e.GL_REPEAT
		end

		-- create a new texture
		local id = gl.GenTexture()

		local self = META:New(
			{
				id = id, 
				size = Vec2(width, height), 
				format = format,
				w = width,
				h = height,
			},
			SUPPRESS_GC
		)
		
		self.texture_channel = e.GL_TEXTURE0 + format.channel
		
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
						
		if render.debug then
			logf("creating texture w = %s h = %s buffer size = %s\n", self.w, self.h, utilities.FormatFileSize(buffer and ffi.sizeof(buffer) or 0)) --The texture size was never broken... someone used two non-existant variables w,h
		end
		
		render.textures[id] = self
		
		return self
	end
end

render.texture_path_cache = render.texture_path_cache or setmetatable({}, { __mode = 'v' })

function render.CreateTextureFromPath(path, format)
	if render.texture_path_cache[path] then 
		return render.texture_path_cache[path] 
	end
			
	format = format or {}
	
	local loading = render.GetLoadingTexture()
	local tex = Texture(loading.w, loading.h, loading.buffer, format)
	
	tex.loading = true

	vfs.ReadAsync(path, function(data)
		tex.loading = false
		
		local buffer, w, h, info = render.DecodeTexture(data, path)
		
		if not buffer then
			local err = render.GetErrorTexture()
			buffer = err:Download()
			w = err.w
			h = err.h
		end
		
		tex:Replace(buffer, w, h)
		tex.decode_info = info
		
		render.texture_path_cache[path] = tex		
	end)
	
	return tex
end


render.texture_decoders = {}

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
		local ok, buffer, w, h, info = pcall(decoder.callback, system.OnError, data, path_hint)
		if ok then 
			if buffer and w then
				return buffer, w, h, info or {}
			else
				logf("[render] %s failed to decode %s: %s\n", decoder.id, path_hint or "", w)
			end
		else
			logf("[render] decoder %q errored: %s\n", decoder.id, buffer)
		end
	end
end

Texture = render.CreateTexture -- reload!