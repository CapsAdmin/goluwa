local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

local function attachment_to_enum(self, var)
	if not var then return end
	
	if self.textures[var] then
		return var
	elseif type(var) == "number" then
		return gl.e.GL_COLOR_ATTACHMENT0 + var - 1
	elseif var == "depth" then
		return gl.e.GL_DEPTH_ATTACHMENT
	elseif var == "stencil" then
		return gl.e.GL_STENCIL_ATTACHMENT
	elseif var == "depth_stencil" then
		return gl.e.GL_DEPTH_STENCIL_ATTACHMENT
	elseif var:startswith("color") then
		return gl.e.GL_COLOR_ATTACHMENT0 + (tonumber(var:match(".-(%d)")) or 0) - 1
	end
end

local function bind_mode_to_enum(str)		
	if str == "all" or str == "read_write" then
		return "GL_FRAMEBUFFER"
	elseif str == "read" then
		return "GL_READ_FRAMEBUFFER"
	elseif str == "write" or str == "draw" then
		return "GL_DRAW_FRAMEBUFFER"
	end
end

local function generate_draw_buffers(self)
	local draw_buffers = {}
	--self.read_buffer = nil -- TODO

	for k,v in pairs(self.textures) do
		if v.mode == "GL_DRAW_FRAMEBUFFER" or v.mode == "GL_FRAMEBUFFER" and not v.tex.draw_manual then
			table.insert(draw_buffers, v.pos)
		else
			--if self.read_buffer then
			--	warning("more than one read buffer attached", 2)
			--end
			--self.read_buffer = v.mode
		end
	end
	
	for k,v in pairs(self.render_buffers) do
		if v.mode == "GL_DRAW_FRAMEBUFFER" or v.mode == "GL_FRAMEBUFFER" then
			table.insert(draw_buffers, v.pos)
		else
			--if self.read_buffer then
			--	warning("more than one read buffer attached", 2)
			--end
			--self.read_buffer = v.mode
		end
	end

	return ffi.new("GLenum["..#draw_buffers.."]", draw_buffers), #draw_buffers
end

local META = prototype.CreateTemplate("framebuffer2")

META:GetSet("BindMode", "all", {"all", "read", "write"})
META:GetSet("Size", Vec2(128,128))

function render.CreateFrameBuffer(width, height, textures)
	local self = prototype.CreateObject(META)
	self.fb = gl.CreateFramebuffer()
	self.textures = {}
	self.render_buffers = {}
	self.draw_buffers_cache = {}
	
	self:SetBindMode("read_write")
	
	if width and height then
		self:SetSize(Vec2(width, height))
	end
	
	if textures then
		if not textures[1] then textures = {textures} end
		
		for i, v in ipairs(textures) do
			local attach = v.attach or "color"
			if attach == "color" then
				attach = i
			end
			
			local tex = render.CreateTexture()
			tex:SetSize(self:GetSize():Copy())
			
			tex.draw_manual = v.draw_manual
			
			local info = v.texture_format
			if info then
				if info.internal_format then 
					tex:SetInternalFormat(info.internal_format)
				end
				
				if info.depth_texture_mode then
					tex:SetDepthTextureMode(info.depth_texture_mode)
				end
			end
			
			tex:SetupStorage()
			tex:Clear()
			
			self:SetTexture(attach, tex, nil, v.name)
		end
		
		self:CheckCompletness()
	end
	
	return self
end

function META:__tostring2()
	return ("[%i]"):format(self.fb.id)
end

function META:CheckCompletness()
	local err = self.fb:CheckStatus("GL_FRAMEBUFFER")
	
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
		
		for k, v in pairs(self.textures) do
			logn(v.tex, " attached to ", v.pos)
			v.tex:DumpInfo()
		end
		
		error(str, 2)
	end
end

function META:SetBindMode(str)
	self.BindMode = str
	
	self.enum_bind_mode = bind_mode_to_enum(str)
end

do -- binding
	local current_id = 0

	do
		local stack = {}
		
		function META:Push(...)
			table.insert(stack, current_id)
		
			self:Bind()
			
			if self.draw_buffers_size then
				gl.DrawBuffers(self.draw_buffers_size, self.draw_buffers)
			end
			
			--if fb.read_buffer then
			--	gl.ReadBuffer(fb.read_buffer)
			--end
				
			current_id = self.fb.id
		end
		
		function META:Pop()		
			local id = table.remove(stack)		
			
			--fb:Unbind()
			gl.BindFramebuffer("GL_FRAMEBUFFER", id)
			
			current_id = id
		end
		
		function META:Begin(...)
			self:Push(...)
			render.PushViewport(0, 0, self.Size.w, self.Size.h)
		end

		function META:End()
			render.PopViewport()
			self:Pop()
		end
	end

	function META:Bind()
		gl.BindFramebuffer(self.enum_bind_mode, self.fb.id)
	end
	
	function META:Unbind()
		gl.BindFramebuffer(self.enum_bind_mode, 0) -- uh
	end
end
	
function META:SetTexture(pos, tex, mode, uid)
	pos = attachment_to_enum(self, pos)
	mode = bind_mode_to_enum(mode or "read_write")
	
	if not uid then
		uid = pos
	end
	
	if typex(tex) == "texture2" then
		local id = tex and tex.gl_tex.id or 0 -- 0 will be detach if tex is nil
	
		self.fb:Texture(pos, id, 0, 0)
		
		if id ~= 0 then
			self.textures[uid] = {tex = tex, mode = mode, pos = pos, uid = uid}
			self:SetSize(tex:GetSize():Copy())
		else
			self.textures[uid] = nil
		end
	else
		if tex then
			local rb = self.render_buffers[uid] or gl.CreateRenderbuffer()
		
			-- ASDF
			if tex.size then
				tex.width = tex.size.w
				tex.height = tex.size.h
				tex.size = nil
			end
		
			rb:StorageMultisample(
				"GL_RENDERBUFFER",
				0,				
				"GL_" .. tex.internal_format:upper(),
				tex.width, 
				tex.height
			)

			self.fb:Renderbuffer("GL_FRAMEBUFFER", pos, "GL_RENDERBUFFER", rb.id)
		
			self.render_buffers[uid] = {rb = rb}
		else
			if self.render_buffers[uid] then
				self.render_buffers[uid].rb:Delete()
			end
			
			self.render_buffers[uid] = nil
		end
	end
		
	self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
end

function META:GetTexture(pos)
	local uid = attachment_to_enum(self, pos or 1)
		
	if not uid then
		return render.GetErrorTexture()
	end
	
	return self.textures[uid] and self.textures[uid].tex or render.GetErrorTexture()
end
	
function META:SetWrite(pos, b)
	pos = attachment_to_enum(self, pos)
	if pos then
		local val = self.textures[pos]
		local mode = val.mode
		
		if b then
			if mode == "GL_READ_FRAMEBUFFER" then
				val.mode = "GL_FRAMEBUFFER"
			end
		else
			if mode == "GL_FRAMEBUFFER" or mode == "GL_DRAW_FRAMEBUFFER" then
				val.mode = "GL_READ_FRAMEBUFFER"
			end
		end
		
		if mode ~= val.mode then
			self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
		end
	end
end

function META:SetRead(pos, b)
	pos = attachment_to_enum(self, pos)
	
	if pos then
		local val = self.textures[pos]
		local mode = val.mode
		
		if b then
			if val.mode == "GL_DRAW_FRAMEBUFFER" then
				val.mode = "GL_FRAMEBUFFER"
				self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
			end
		else
			if mode == "GL_FRAMEBUFFER" or mode == "GL_READ_FRAMEBUFFER" then
				val.mode = "GL_DRAW_FRAMEBUFFER"
			end
		end
		
		if mode ~= val.mode then
			self.draw_buffers, self.draw_buffers_size = generate_draw_buffers(self)
		end
	end
end

function META:WriteThese(str)
	if not self.draw_buffers_cache[str] then
		for pos in pairs(self.textures) do
			self:SetWrite(pos, false)
		end
		
		if str == "all" then
			for pos in pairs(self.textures) do
				self:SetWrite(pos, true)
			end
		elseif str == "none" then
			for pos in pairs(self.textures) do
				self:SetWrite(pos, false)
			end
		else
			for _, pos in pairs(str:explode("|")) do
				pos = tonumber(pos) or pos
				self:SetWrite(pos, true)
			end
		end
		
		self.draw_buffers_cache[str] = {self.draw_buffers, self.draw_buffers_size}
	end
	
	self.draw_buffers, self.draw_buffers_size = unpack(self.draw_buffers_cache[str])
end

function META:Clear(i, r,g,b,a)
	i = i or 0
			
	self:Begin()
		if type(i) == "number" then
			if g and b then
				r = Color(r, g, b, a or 0)
			end
		
			if i == 0 then
				r = r or Color()
				gl.ClearColor(r.r, r.g, r.b, r.a)
				gl.Clear(gl.e.GL_COLOR_BUFFER_BIT)
				render.SetClearColor(render.GetClearColor())
			else	
				gl.ClearBufferfv("GL_COLOR", i - 1, r.ptr)
			end
		elseif i == "depth" then
			gl.ClearDepth(r)
		elseif i == "stencil" then
			gl.ClearStencil(r)
		end
	self:End()
end
	
prototype.Register(META)


if not RELOAD then return end

local fb = render.CreateFrameBuffer()

local tex = render.CreateTexture("2d")
tex:SetSize(Vec2(1024, 1024))
tex:SetInternalFormat("rgba8")
tex:Clear()

fb:SetTexture(1, tex, "read_write")

local tex = render.CreateTexture("2d") 
tex:SetSize(Vec2(1024, 1024))
tex:SetInternalFormat("rgba8")
tex:Clear()

fb:SetTexture(2, tex, "read_write")

local tex = render.CreateTexture("2d")
tex:SetSize(Vec2(1024, 1024))
tex:SetInternalFormat("depth24_stencil8")
tex:SetupStorage()
fb:SetTexture("stencil", tex)

fb:SetWrite(1, false)

fb:Begin()
	surface.SetWhiteTexture()
	surface.SetColor(1,0,0,1)
	surface.DrawRect(30,30,50,50)
fb:End()

fb:SetWrite(1, true)

fb:SetWrite(2, false)

fb:Begin()
	surface.SetWhiteTexture()
	surface.SetColor(1,0,1,1)
	surface.DrawRect(30,30,50,50)
fb:End()

fb:SetWrite(2, true)

fb:WriteThese("stencil")
 
fb:Begin()
	surface.SetWhiteTexture()
	surface.SetColor(0,1,0,0.5)
	surface.DrawRect(20,20,50,50, 50)
fb:End()

fb:WriteThese("all")

--fb:Clear(1, 1,0,0,0.5) 

event.AddListener("PostDrawMenu", "lol", function()
	surface.SetTexture(fb:GetTexture(1))
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(0, 0, 1024, 1024)
	
	surface.SetTexture(fb:GetTexture(2))
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(100, 100, 1024, 1024)
end)
