local gl = require("libraries.ffi.opengl") -- OpenGL
local render = (...) or _G.render

local META = prototype.CreateTemplate("framebuffer")

function render.CreateFrameBuffer(width, height, format)
	if not render.CheckSupport("GenFramebuffer") then return NULL end
	
	local self = prototype.CreateObject(META)

	self.buffers = {}
	self.w = width
	self.h = height
	self.building = true
	
	if not format then
		format = {
			attach = gl.e.GL_COLOR_ATTACHMENT0,
			texture_format = {}
		}
	end
	
	if not format[1] then 
		format.name = format.name or "default"
		format = {format} 
	end
		
	local id = gl.GenFramebuffer()
	self.id = id
	self:Begin()
	 
	for i, info in pairs(format) do
		info.attach = info.attach or gl.e.GL_COLOR_ATTACHMENT0
		
		if info.texture_format then
			info.texture_format.internal_format = info.texture_format.internal_format or gl.e.GL_RGBA32F
			info.texture_format.mip_map_levels = info.texture_format.mip_map_levels or 1
		end
		
		if type(info.attach) == "string" then 
			local attach, num = info.attach:match("(.-)(%d)") or info.attach
			num = tonumber(num)
			
			if attach == "color" then
				attach = gl.e.GL_COLOR_ATTACHMENT0
				
				if num then 
					attach = attach + num 
				else
					attach = attach + i - 1
				end
				
			elseif attach == "depth" then
				attach = gl.e.GL_DEPTH_ATTACHMENT
			elseif attach == "stencil" then
				attach = gl.e.GL_DEPTH_STENCIL_ATTACHMENT
				info.internal_format = info.internal_format or gl.e.GL_DEPTH_STENCIL
				info.draw_manual = true
			end

			info.attach = attach
		end
	
		local tex_info = info.texture_format
		
		local tex = NULL
		local id
		
		if info.texture then
			
			tex = info.texture
			id = tex.id
		elseif tex_info and info.attach ~= gl.e.GL_DEPTH_STENCIL_ATTACHMENT then
			tex_info.upload_format = tex_info.upload_format or "rgba"
			tex_info.channel = i - 1
						
			tex = render.CreateTexture(width, height, nil, tex_info)
			id = tex.id
		
			tex.framebuffer_name = info.name
		else
			id = gl.GenRenderbuffer()
			gl.BindRenderbuffer(gl.e.GL_RENDERBUFFER, id)		

			gl.RenderbufferStorage(gl.e.GL_RENDERBUFFER, info.internal_format, width, height)
		end
		
		self.buffers[info.name] = {name = info.name, id = id, tex = tex, info = info, attach = info.attach, draw_manual = info.draw_manual, attach_pos = i}
	end

	for i, data in pairs(self.buffers) do
		if not data.info.texture_format or data.info.texture_format.type ~= gl.e.GL_TEXTURE_CUBE_MAP then
			if data.tex:IsValid() then
				gl.FramebufferTexture2D(gl.e.GL_FRAMEBUFFER, data.attach, gl.e.GL_TEXTURE_2D, data.id, 0)
			else
				gl.FramebufferRenderbuffer(gl.e.GL_FRAMEBUFFER, data.attach, gl.e.GL_RENDERBUFFER, data.id)
			end
		end
		data.info = nil
	end
		
	self:SetDrawBuffers()
	
	local err = gl.CheckFramebufferStatus(gl.e.GL_FRAMEBUFFER)
	
	if err ~= gl.e.GL_FRAMEBUFFER_COMPLETE then
		local str = "Unknown error: " .. err
		
		if err == gl.e.GL_FRAMEBUFFER_UNSUPPORTED then
			str = "format not supported"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT then
			str = "incomplete attachment"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT then
			str = "incomplete missing attachment"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS then
			str = "attached images must have same dimensions"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_FORMATS then
			str = "attached images must have same format"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER then
			str = "missing draw buffer"
		elseif err == gl.e.GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER then
			str = "missing read buffer"
		end
		
		self:Remove()
		error(str, 2)
	end
	
	self:End()
	self.building = nil	
	
	return self
end

function META:OnRemove()
	gl.DeleteFramebuffers(1, ffi.new("GLuint[1]", self.id))
	
	for k, v in pairs(self.buffers) do
		gl.DeleteRenderbuffers(1, ffi.new("GLuint[1]", v.id))
	end
end

function META:__tostring2()
	return ("[%i]"):format(self.id)
end

local current_id = 0

do
	local stack = {}
	
	function render.PushFramebuffer(fb, ...)
		table.insert(stack, current_id)
		
		gl.BindFramebuffer(gl.e.GL_FRAMEBUFFER, fb.id)
		current_id = fb.id
		
		if not fb.building then
			fb:SetDrawBuffers(...)
		end
	end
	
	function render.PopFramebuffer()
		local id = table.remove(stack)		
		
		gl.BindFramebuffer(gl.e.GL_FRAMEBUFFER, id)
		current_id = id
	end
	
	function META:Push(...)
		render.PushFramebuffer(self, ...)
	end
	
	function META:Pop()		
		render.PopFramebuffer()
	end
	
	function META:Begin(...)
		self:Push(...)
		render.PushViewport(0, 0, self.w, self.h)
	end

	function META:End()
		render.PopViewport()
		self:Pop()
	end
end

function META:Bind()
	gl.BindFramebuffer(gl.e.GL_FRAMEBUFFER, self.id)
end

function META:SetWriteBuffer(name, target)
	local buffer = self.buffers[name]
	if buffer then
		gl.FramebufferTexture2D(gl.e.GL_DRAW_FRAMEBUFFER, buffer.attach, target or gl.e.GL_TEXTURE_2D, buffer.id, 0)
	end
end

function META:SetReadBuffer(name, target)
	local buffer = self.buffers[name]
	if buffer then
		gl.FramebufferTexture2D(gl.e.GL_READ_FRAMEBUFFER, buffer.attach, target or gl.e.GL_TEXTURE_2D, buffer.id, 0)
	end
end

function META:SetDrawBuffers(...)	
	local key = ... and table.concat({...}, "") or ""
	
	if key ~= self.last_draw_buffers then
		
		self.draw_buffers = {}
			
		if ... then			
			local args = {...}
			
			for i, buffer in pairs(self.buffers) do
				if not buffer.draw_manual then
					if table.hasvalue(args, buffer.name) then
						self.draw_buffers[buffer.attach_pos] = buffer.attach
					else
						self.draw_buffers[buffer.attach_pos] = gl.e.GL_NONE
					end
				end
			end
		else
			for i, buffer in pairs(self.buffers) do
				if not buffer.draw_manual then
					self.draw_buffers[buffer.attach_pos] = buffer.attach
				end
			end
		end
				
		self.draw_buffers_size = #self.draw_buffers
		self.draw_buffers = ffi.new("GLenum["..self.draw_buffers_size.."]", self.draw_buffers)
		
		gl.DrawBuffers(self.draw_buffers_size, self.draw_buffers)
				
		self.last_draw_buffers = key
	end
end

function META:Clear(r,g,b,a, buffer)
	r = r or 0
	g = g or 0
	b = b or 0
	a = a or 0
	
	if buffer then
		local buffer = self.buffers[name]
		if buffer then
			gl.ClearBufferfv(gl.e.GL_COLOR, buffer.attach_pos - 1, ffi.cast("float *", Color(r,g,b,a)))
		end
	else
		gl.ClearColor(r, g, b, a)
		gl.Clear(bit.bor(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT))
	end
end

function META:GetTexture(type)
	type = type or "default"
	
	if self.buffers[type] then
		return self.buffers[type].tex
	end
	
	return render.GetErrorTexture()
end

function META:Copy(framebuffer)
	gl.BindFramebuffer(gl.e.GL_DRAW_FRAMEBUFFER, self.id)
	gl.BindFramebuffer(gl.e.GL_READ_FRAMEBUFFER, framebuffer.id)
	gl.BlitFramebuffer(0,0,framebuffer.w,framebuffer.h, 0,0,self.w,self.h, gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_LINEAR)
	gl.BindFramebuffer(gl.e.GL_FRAMEBUFFER, current_id)
end

prototype.Register(META)