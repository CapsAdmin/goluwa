local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render

render.framebuffers = setmetatable({}, { __mode = 'v' })

function render.GetFramebuffers()
	return render.framebuffers
end

local META = metatable.CreateTemplate("framebuffer")

function META:__tostring()
	return ("frame_buffer[%i]"):format(self.id)
end

do
	local stack = {}
	local current = 0
	
	function META:Begin(...)
		table.insert(stack, current)
		
		gl.BindFramebuffer(gl.e.GL_FRAMEBUFFER, self.id)
		current = self.id
		
		if not self.building then
			self:SetDrawBuffers(...)
		end
		
		render.PushViewport(0, 0, self.w, self.h)
	end

	function META:End()
		render.PopViewport()
		local id = table.remove(stack)		
		
		gl.BindFramebuffer(gl.e.GL_FRAMEBUFFER, id)
		current = id
	end
	
	function META:Bind()
		debug.trace()
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

function META:Clear(r,g,b,a)
	gl.ClearColor(r or 0, g or 0, b or 0, a or 1)
	gl.Clear(bit.bor(gl.e.GL_COLOR_BUFFER_BIT, gl.e.GL_DEPTH_BUFFER_BIT))
end

function META:GetTexture(type)
	type = type or "default"
	
	if self.buffers[type] then
		return self.buffers[type].tex
	end
	
	return render.GetErrorTexture()
end

function META:Remove()
	gl.DeleteFramebuffers(1, ffi.new("GLuint[1]", self.id))
	
	for k, v in pairs(self.buffers) do
		gl.DeleteRenderbuffers(1, ffi.new("GLuint[1]", v.id))
	end
		
	utilities.MakeNULL(self)
end

function render.CreateFrameBuffer(width, height, format)
	if not render.CheckSupport("GenFramebuffer") then return NULL end
	
	local self = META:New()

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
				attach = gl.e.GL_STENCIL_ATTACHMENT
			end

			info.attach = attach
		end
	
		local tex_info = info.texture_format
		
		local tex = NULL
		local id
		
		if info.texture then
			
			tex = info.texture
			id = tex.id
			
		elseif tex_info then
			tex_info.upload_format = tex_info.upload_format or "rgba"
			tex_info.channel = i - 1
						
			tex = render.CreateTexture(width, height, nil, tex_info)
			id = tex.id
		
			tex.framebuffer_name = info.name
		else
			id = gl.GenRenderbuffer()
			gl.BindRenderbuffer(gl.e.GL_RENDERBUFFER, id)		
		
			gl.RenderbufferStorage(gl.e.GL_RENDERBUFFER, info.texture_format.internal_format, width, height)
		end
		
		self.buffers[info.name] = {name = info.name, id = id, tex = tex, info = info, attach = info.attach, draw_manual = info.draw_manual, attach_pos = i}
	end

	for i, data in pairs(self.buffers) do
		if data.tex:IsValid() then
			gl.FramebufferTexture2D(gl.e.GL_FRAMEBUFFER, data.info.attach, gl.e.GL_TEXTURE_2D, data.id, 0)
		else
			gl.FramebufferRenderbuffer(gl.e.GL_FRAMEBUFFER, data.info.attach, gl.e.GL_RENDERBUFFER, data.id)
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
	
		
	render.framebuffers[id] = self
	
	return self
end