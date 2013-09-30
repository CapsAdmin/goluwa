--gl.debug = true

local META = {}
META.__index = META

function META:__tostring()
	return ("render_buffer[%i]"):format(self.id)
end

function META:Begin()
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, self.id)
	gl.PushAttrib(e.GL_VIEWPORT_BIT)
	gl.Viewport(0, 0, self.width, self.height)	
	
	gl.Clear(bit.bor(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT))
	gl.ClearColor(0, 0, 0, 1)

	gl.ActiveTextureARB(e.GL_TEXTURE0)
	gl.Enable(e.GL_TEXTURE_2D)

	gl.DrawBuffers(self.draw_buffers_size, self.draw_buffers)
end

function META:End()
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, 0)
	gl.PopAttrib()
end

function META:GetTexture(type)
	if self.render_buffers[type] then
		return self.render_buffers[type].tex
	end
	
	return NULL
end

function META:Remove()
	gl.DeleteFramebuffers(1, ffi.new("GLuint[1]", self.id))
	
	for k, v in pairs(self.render_buffers) do
		gl.DeleteRenderbuffers(1, ffi.new("GLuint[1]", v.id))
		
		if v.tex:IsValid() then
			v.tex:Remove()
		end
	end
		
	utilities.MakeNULL(self)
end

function render.CreateFrameBuffer(width, height, format)
	
	local self = setmetatable({}, META)

	self.render_buffers = {}
	self.width = width
	self.height = height
	self.draw_buffers = {}
	 
	for i, info in pairs(format) do
		local tex_info = info.texture_format
		
		local tex = NULL
		local id
		
		if tex_info then
			tex_info.min_filter = tex_info.min_filter or e.GL_LINEAR
			tex_info.mag_filter = tex_info.mag_filter or e.GL_LINEAR
			
			tex_info.wrap_s = tex_info.wrap_s or e.GL_CLAMP_TO_EDGE
			tex_info.wrap_t = tex_info.wrap_t or e.GL_CLAMP_TO_EDGE
			
			tex_info.mip_map_levels = 1
			tex_info.format = e.GL_FLOAT
						
			tex = render.CreateTexture(width, height, nil, tex_info)
			tex:SetChannel(i-1)
			id = tex.id
		
			tex.framebuffer_name = info.name
			
			if info.attach ~= e.GL_DEPTH_ATTACHMENT then
				table.insert(self.draw_buffers, info.attach)
			end
		else
			id = gl.GenRenderbuffer()
			gl.BindRenderbuffer(e.GL_RENDERBUFFER, id)		
		
			gl.RenderbufferStorage(e.GL_RENDERBUFFER, info.internal_format, width, height)
		end
		
		self.render_buffers[info.name] = {id = id, tex = tex, info = info}
	end

	local id = gl.GenFramebuffer()	
	self.id = id
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, id)
	
	for i, data in pairs(self.render_buffers) do
		if data.tex:IsValid() then
			gl.FramebufferTexture2D(e.GL_FRAMEBUFFER, data.info.attach, e.GL_TEXTURE_2D, data.id, 0)
		else
			gl.FramebufferRenderbuffer(e.GL_FRAMEBUFFER, data.info.attach, e.GL_RENDERBUFFER, data.id)
		end
		data.info = nil
	end
	
	local err = gl.CheckFramebufferStatus(e.GL_FRAMEBUFFER)
	
	if err ~= e.GL_FRAMEBUFFER_COMPLETE then
		local str = "Unknown error: " .. err
		
		if err == e.GL_FRAMEBUFFER_UNSUPPORTED then
			str = "format not supported"
		elseif err == e.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT then
			str = "incomplete attachment"
		elseif err == e.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT then
			str = "incomplete missing attachment"
		elseif err == e.GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS then
			str = "attached images must have same dimensions"
		elseif err == e.GL_FRAMEBUFFER_INCOMPLETE_FORMATS then
			str = "attached images must have same format"
		elseif err == e.GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER then
			str = "missing draw buffer"
		elseif err == e.GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER then
			str = "missing read buffer"
		end			
		
		self:Remove()
		error(str, 2)
	end
	
	self.draw_buffers_size = #self.draw_buffers
	self.draw_buffers = ffi.new("GLenum["..self.draw_buffers_size.."]", self.draw_buffers)
	
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, 0)
	
	utilities.SetGCCallback(self)
	
	return self
end