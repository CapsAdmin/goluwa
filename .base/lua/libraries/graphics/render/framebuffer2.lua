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
	
	local id = tex and tex.gl_tex.id or 0 -- 0 will be detach if tex is nil
	
	if tex.StorageType == "1d" then
		self.fb:Texture1D("GL_FRAMEBUFFER", pos_enum, tex.gl_tex.target, id, 0)
	elseif tex.StorageType == "2d" then
		self.fb:Texture2D("GL_FRAMEBUFFER", pos_enum, tex.gl_tex.target, id, 0)
	elseif tex.StorageType == "3d" then
		self.fb:Texture3D("GL_FRAMEBUFFER", pos_enum, tex.gl_tex.target, id, 0, 0) -- TODO
	elseif tex.StorageType == "render_buffer" then
		self.fb:Renderbuffer("GL_FRAMEBUFFER", pos_enum, "GL_RENDERBUFFER", id)
	end
	
	if id ~= 0 then
		self.textures[pos_enum] = {tex = tex, mode = mode_enum, pos = pos_enum}
		self:SetSize(tex:GetSize():Copy())
	else
		self.textures[pos_enum] = nil
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
				self.read_buffer = v.mode
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

event.AddListener("PostDrawMenu", "lol", function()
	surface.SetTexture(fb:GetTexture(1))
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(0, 0, 1024, 1024)
	
	surface.SetTexture(fb:GetTexture(2))
	surface.SetColor(1, 1, 1, 1)
	surface.DrawRect(100, 100, 1024, 1024)
end)
