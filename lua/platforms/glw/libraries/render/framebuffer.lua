gl.debug = true

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

	gl.ActiveTextureARB(e.GL_TEXTURE0_ARB)
	gl.Enable(e.GL_TEXTURE_2D)

	gl.DrawBuffers(self.draw_buffers_size, self.draw_buffers)
end

function META:End()
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, 0)
	gl.PopAttrib()
end

function META:GetTexture()
	if self.render_buffers[type] then
		return self.render_buffers[type]
	end
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
		
	local id = gl.GenFramebuffer()	
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, id)
	
	self.render_buffers = {}
	self.id = id
	self.width = width
	self.height = height
	self.draw_buffers = {}
	
	for type, info in pairs(format) do
		local id = gl.GenRenderbuffer()
		gl.BindRenderbuffer(e.GL_RENDERBUFFER, id)
		gl.RenderbufferStorage(e.GL_RENDERBUFFER, info.internal_format, width, height)
		gl.FramebufferRenderbuffer(e.GL_FRAMEBUFFER, info.attach, e.GL_RENDERBUFFER, id)
		
		local tex_info = info.texture_format
		local tex = NULL
		
		if tex_info then
			tex_info.min_filter = tex_info.min_filter or e.GL_LINEAR
			tex_info.mag_filter = tex_info.mag_filter or e.GL_LINEAR
			tex_info.wrap_s = tex_info.wrap_s or e.GL_CLAMP_TO_EDGE
			tex_info.wrap_t = tex_info.wrap_t or e.GL_CLAMP_TO_EDGE
			
			tex_info.internal_format = info.internal_format
			tex_info.mip_map_levels = 0
			
			tex = render.CreateTexture(width, height, nil, tex_info.texture_format)			
			
			gl.FramebufferTexture2D(e.GL_FRAMEBUFFER, info.attach, e.GL_TEXTURE_2D, tex.id, 0)
			
			table.insert(self.draw_buffers, info.attach)
		end
		
		self.render_buffers[type] = {id = id, tex = NULL}
	end
	
	if gl.CheckFramebufferStatus(e.GL_FRAMEBUFFER) ~= e.GL_FRAMEBUFFER_COMPLETE then
		self:Remove()
		error(glu.GetLastError(), 2)
	end
	
	self.draw_buffers_size = #self.draw_buffers
	self.draw_buffers = ffi.new("GLenum["..self.draw_buffers_size.."]", self.draw_buffers)
	
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, 0)
	
	utilities.SetGCCallback(self)
	
	return self
end