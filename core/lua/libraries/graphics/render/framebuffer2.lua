local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

local function attachment_to_enum(str)
	if type(str) == "number" then
		return gl.e.GL_COLOR_ATTACHMENT0 + str - 1
	elseif str:startswith("color") then
		return gl.e.GL_COLOR_ATTACHMENT0 + (tonumber(str:match(".-(%d)")) or 0) - 1
	else
		return gl.e["GL_" .. str:upper() .. "_ATTACHMENT"]
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

local META = prototype.CreateTemplate("framebuffer2")

META:GetSet("BindMode", "all", {"all", "read", "write"})
META:GetSet("Size", Vec2(128,128))

function render.CreateFramebuffer2(...)
	local self = prototype.CreateObject(META)
	self.fb = gl.CreateFramebuffer()
	self.textures = {}
	self.render_buffers = {}
	
	self:SetBindMode("read_write")
	
	return self
end

function META:__tostring2()
	return ("[%i]"):format(self.fb.id)
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
	
function META:SetTexture(pos, tex, mode)		
	local pos_enum = attachment_to_enum(pos)
	local mode_enum = bind_mode_to_enum(mode or "read_write")
	
	if typex(tex) == "texture2" then
		local id = tex and tex.gl_tex.id or 0 -- 0 will be detach if tex is nil
	
		if tex.StorageType == "1d" then
			self.fb:Texture1D("GL_FRAMEBUFFER", pos_enum, tex.gl_tex.target, id, 0)
		elseif tex.StorageType == "2d" then
			self.fb:Texture2D("GL_FRAMEBUFFER", pos_enum, tex.gl_tex.target, id, 0)
		elseif tex.StorageType == "3d" then
			self.fb:Texture3D("GL_FRAMEBUFFER", pos_enum, tex.gl_tex.target, id, 0, 0) -- TODO
		end
	
		if id ~= 0 then
			self.textures[pos_enum] = {tex = tex, mode = mode_enum, pos = pos_enum}
			self:SetSize(tex:GetSize():Copy())
		else
			self.textures[pos_enum] = nil
		end
	else
		if tex then
			local rb = self.render_buffers[pos_enum] or gl.CreateRenderbuffer()
		
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

			self.fb:Renderbuffer("GL_FRAMEBUFFER", pos_enum, "GL_RENDERBUFFER", rb.id)
		
			self.render_buffers[pos_enum] = rb
		else
			if self.render_buffers[pos_enum] then
				self.render_buffers[pos_enum]:Delete()
			end
			
			self.render_buffers[pos_enum] = nil
		end
	end
	
	do
		local draw_buffers = {}
		--self.read_buffer = nil -- TODO
	
		for k,v in pairs(self.textures) do
			if v.mode == "GL_DRAW_FRAMEBUFFER" or v.mode == "GL_FRAMEBUFFER" then
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
			
		self.draw_buffers_size = #draw_buffers
		self.draw_buffers = ffi.new("GLenum["..self.draw_buffers_size.."]", draw_buffers)
	end
end

function META:GetTexture(pos)
	local pos = attachment_to_enum(pos)
	return self.textures[pos] and self.textures[pos].tex or render.GetErrorTexture()
end
	
function META:SetWrite(pos, b)
	local old = self:GetTexture(pos)
	if old ~= render.GetErrorTexture() then
		self:SetTexture(pos, self:GetTexture(pos), b and "all" or "read")
	end
end

function META:WriteOnly(pos)
	local pos = attachment_to_enum(pos)
	
	for k,v in pairs(self.textures) do
		v.old_mode = v.mode
		
		if v.pos == pos then
			self:SetTexture(v.pos, v.tex, "write")	
		else
			self:SetTexture(v.pos, v.tex, "read")
		end
	end
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

local fb = render.CreateFramebuffer2()

local tex = render.CreateTexture2("2d")

tex:Upload({ 
	width = 1024,
	height = 1024,
	format = "rgba",
	internal_format = "rgba8",
})

fb:SetTexture(1, tex, "read_write")

local tex = render.CreateTexture2("2d")

tex:Upload({ 
	width = 1024,
	height = 1024,
	format = "rgba",
	internal_format = "rgba8",
})

fb:SetTexture(2, tex, "read_write")

fb:SetTexture("stencil", {
	internal_format = "depth32f_stencil8",
	width = 1024,
	height = 1024,
})

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

fb:Clear(1, 1,0,0,0.5)

event.AddListener("PostDrawMenu", "lol", function()
	surface.SetTexture(fb:GetTexture(1))
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(0, 0, 1024, 1024)
	
	surface.SetTexture(fb:GetTexture(2))
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(100, 100, 1024, 1024)
end)
