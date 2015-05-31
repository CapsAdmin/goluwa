local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

local META = prototype.CreateTemplate("framebuffer2")

function render.CreateFramebuffer2(...)
	local self = prototype.CreateObject(META)
	self.fb = gl.CreateFramebuffer()
	self.textures = {}
	
	return self
end

function META:__tostring2()
		return ("[%i]"):format(self.id)
	end

function META:AttachTexture(where, tex)
	where = where or "color0"
	
	local attach
	
	if where:startswith("color") then
		attach = gl.e.GL_COLOR_ATTACHMENT0 + (tonumber(where:match(".-(%d)")) or 0)
	else
		attach = gl.e["GL_" .. where:upper() .. "_ATTACHMENT"]
	end
	
	local storage = tex:GetStorageType()
	
	if storage == "1d" then
		self.fb:Texture1D("GL_FRAMEBUFFER", attach, tex.gl_tex.target, tex.gl_tex.id, 0)
	elseif storage == "2d" then
		self.fb:Texture2D("GL_FRAMEBUFFER", attach, tex.gl_tex.target, tex.gl_tex.id, 0)
	elseif storage == "3d" then
		self.fb:Texture3D("GL_FRAMEBUFFER", attach, tex.gl_tex.target, tex.gl_tex.id, 0, 0) -- TODO
	elseif storage == "render_buffer" then
		self.fb:Renderbuffer("GL_FRAMEBUFFER", attach, tex.gl_tex.id, 0)
	end
	
	self.textures[where] = tex
	
	tex.fb_attach = attach
	
	self.w = tex.w
	self.h = tex.h
end

function META:GetTexture(where)
	local tex = self.textures[where]
	if tex then
		return tex, tex.fb_attach
	end
end

do -- binding
	local current_id = 0

	do
		local stack = {}
		
		function render.PushFramebuffer2(fb, ...)
			table.insert(stack, current_id)
			
			gl.BindFramebuffer("GL_FRAMEBUFFER", fb.fb.id)
			current_id = fb.fb.id
		end
		
		function render.PopFramebuffer2()
			local id = table.remove(stack)		
			
			gl.BindFramebuffer("GL_FRAMEBUFFER", id)
			current_id = id
		end
		
		function META:Push(...)
			render.PushFramebuffer2(self, ...)
		end
		
		function META:Pop()		
			render.PopFramebuffer2()
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
		gl.BindFramebuffer("GL_FRAMEBUFFER", self.id)
	end
end

prototype.Register(META)

local fb = render.CreateFramebuffer2()
fb:AttachTexture("color0", render.CreateTexture2("2d"):Upload({width = 1024, height = 1024, format = "rgba", internal_format = "rgba8"}))

fb:Begin()
	surface.SetWhiteTexture()
	surface.SetColor(1,0,0,1)
	surface.DrawRect(30,30,50,50)
fb:End()

event.AddListener("PostDrawMenu", "lol", function()
	surface.SetTexture(fb:GetTexture("color0"))
	surface.SetColor(1,1,1,1)
	surface.DrawRect(0,0,1024,1024)
end)
