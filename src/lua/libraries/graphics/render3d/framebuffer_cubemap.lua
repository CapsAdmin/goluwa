local render3d = ... or render3d

local META = prototype.CreateTemplate("framebuffer_cubemap")

META:GetSet("Texture")
META:GetSet("Framebuffer")

local function update(self, shader, i, view)
	self.Framebuffer:SetTextureLayer(1, self.Texture, i)

	local pos = camera.camera_3d:GetPosition()
	view:SetPosition(pos)
	camera.camera_3d = view

	render2d.PushMatrix(0, 0, self.Texture:GetSize():Unpack())
		shader:Bind()
		render2d.rectangle:Draw()
	render2d.PopMatrix()
end

function META:Update(shader, i)
	if i == true then
		self.i = (self.i or 0) + 1

		if self.i >= 7 then
			self.i = 1
		end

		i = self.i
	end

	render.SetPresetBlendMode("none")

	self.Framebuffer:Begin()
		local old = camera.camera_3d

		if i then
			update(self, shader, i, self.camera_views[i])
		else
			for i, view in ipairs(self.camera_views) do
				update(self, shader, i, view)
			end
		end

		camera.camera_3d = old
	self.Framebuffer:End()
end

function META:Clear(r,g,b,a)
	self.Framebuffer:Begin()
		for i = 1, 6 do
			self.Framebuffer:SetTextureLayer(1, self.Texture, i)
			self.Framebuffer:ClearTexture(1, r,g,b,a)
		end
	self.Framebuffer:End()
end

META:Register()

function render3d.CreateFramebufferCubemap(format, size)
	format = format or "r11f_g11f_b10f"
	size = size or Vec2() + 256

	local self = META:CreateObject()

	local tex = render.CreateTexture("cube_map")
	tex:SetInternalFormat(format)
	tex:SetSize(size)
	tex:SetupStorage()
	self.Texture = tex

	local fb = render.CreateFrameBuffer()
	fb:SetTexture(1, tex, "write", nil, 1)
	fb:WriteThese(1)
	self.Framebuffer = fb

	do
		local views = {
			Matrix44():SetRotation(QuatDeg3(0,-90,-90)), -- back
			Matrix44():SetRotation(QuatDeg3(0,90,90)), -- front

			Matrix44():SetRotation(QuatDeg3(0,0,0)), -- up
			Matrix44():SetRotation(QuatDeg3(180,0,0)), -- down

			Matrix44():SetRotation(QuatDeg3(90,0,0)), -- left
			Matrix44():SetRotation(QuatDeg3(-90,180,0)), -- right
		}

		local sky_projection = Matrix44():Perspective(
			math.rad(90),
			camera.camera_3d.FarZ,
			camera.camera_3d.NearZ,
			size.x / size.y
		)

		for i, view in pairs(views) do
			local cam = camera.CreateCamera()
			cam:SetView(view)
			cam:SetProjection(sky_projection)
			views[i] = cam
		end

		self.camera_views = views
	end

	self:Clear()

	return self
end