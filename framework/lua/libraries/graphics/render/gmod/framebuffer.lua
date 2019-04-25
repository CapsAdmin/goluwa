local render = ... or _G.render
local META = prototype.GetRegistered("framebuffer")

function META:GetTexture(pos)
	self:GetRenderTarget()
	return self.textures[pos]
end

local format = {
	rgba8 = gmod.IMAGE_FORMAT_RGBA8888,
	abgr8 = gmod.IMAGE_FORMAT_ABGR8888,
	rgb8 = gmod.IMAGE_FORMAT_RGB888,
	bgr8 = gmod.IMAGE_FORMAT_BGR888,
	rgb565 = gmod.IMAGE_FORMAT_RGB565,
	argb8 = gmod.IMAGE_FORMAT_ARGB8888,
	bgra8 = gmod.IMAGE_FORMAT_BGRA8888,
	rgba16 = gmod.IMAGE_FORMAT_RGBA16161616,
	rgba16f = gmod.IMAGE_FORMAT_RGBA16161616F,
}

function META:SetTexture(pos, tex, mode, uid, face)
	if self.screen_rt then return end

	local depth_mode = gmod.MATERIAL_RT_DEPTH_SHARED

	if pos == "depth_stencil" then
		depth_mode = gmod.MATERIAL_RT_DEPTH_SEPARATE
	elseif pos == "depth" then
		depth_mode = gmod.MATERIAL_RT_DEPTH_ONLY
	elseif pos == "stencil" then
		depth_mode = gmod.MATERIAL_RT_DEPTH_NONE
	end

	self.width = typex(tex) == "texture" and tex:GetSize().x or tex.size.x
	self.height = typex(tex) == "texture" and tex:GetSize().y or tex.size.y

	if typex(tex) == "texture" then
		self.internal_format = format[tex:GetInternalFormat()] or format.rgba8
	end
	self.depth_mode = depth_mode
	self.rt = nil
	self.textures[pos] = tex
end

function META:GetRenderTarget()
	if self.screen_rt then
		return nil
	end

	if not self.rt then
		self.rt = gmod.GetRenderTargetEx(
			"goluwa_rt_" .. ("%p"):format(self),
			self.width,
			self.height,
			gmod.RT_SIZE_NO_CHANGE,
			self.depth_mode,
			1,
			gmod.CREATERENDERTARGETFLAGS_AUTOMIPMAP,
			self.internal_format or format.rgba8
		)

		local tex = self.textures[1]

		tex:SetITexture(self.rt)

		self:SetSize(Vec2(self.width, self.height))
	end

	return self.rt
end

function META:ClearAll(r,g,b,a, d,s)
	r = r or 0
	g = g or 0
	b = b or 0
	a = a or 0
	local old = gmod.render.GetRenderTarget()
	gmod.render.SetRenderTarget(self:GetRenderTarget())

	gmod.render.ClearDepth(d)
	gmod.render.ClearStencilBufferRectangle(0, 0, self.width, self.height, s or 0)
	gmod.render.Clear(r*255, g*255, b*255, a*255)

	gmod.render.SetRenderTarget(old)
end

function META:ClearColor(r,g,b,a)
	local old = gmod.render.GetRenderTarget()
	gmod.render.SetRenderTarget(self:GetRenderTarget())

	gmod.render.Clear(r*255, g*255, b*255, a*255)

	gmod.render.SetRenderTarget(old)
end

function META:ClearDepth(d)
	local old = gmod.render.GetRenderTarget()
	gmod.render.SetRenderTarget(self:GetRenderTarget())

	gmod.render.ClearDepth(d)

	gmod.render.SetRenderTarget(old)
end

function META:ClearStencil(s)
	local old = gmod.render.GetRenderTarget()
	gmod.render.SetRenderTarget(self:GetRenderTarget())

	gmod.render.ClearStencilBufferRectangle(0, 0, self.width, self.height, s)

	gmod.render.SetRenderTarget(old)
end

function render._CreateFrameBuffer(self, id_override)
	if id_override == 0 then
		self.screen_rt = true
		self.width = gmod.ScrW()
		self.height = gmod.ScrH()
	else
		self.textures = {}
	end
end

function META:_Bind()
	gmod.render.SetRenderTarget(self:GetRenderTarget())
end

