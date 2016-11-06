local render3d = ... or _G.render3d

local META = prototype.CreateTemplate("environment_probe")

META:GetSet("Position", Vec3(0,0,0))
META:GetSet("FOV", math.rad(90))
META:GetSet("Resolution", Vec2() + 512, {callback = "CreateTexture"})

function META:CreateTexture()
	local tex = render.CreateTexture("cube_map")
	tex:SetSize(Vec2() + 512)
	tex:SetBaseLevel(0)
	tex:SetMaxLevel(0)
	tex:SetMinFilter("linear")
	tex:SetupStorage()

	local fb = render.CreateFrameBuffer()

	fb:SetTexture(1, tex)
	fb:WriteThese(1)

	self.fb = fb
	self.tex = tex
end

local directions = {
	QuatDeg3(90,-90,-90), -- back
	QuatDeg3(-90,180,0), -- front

	QuatDeg3(0,90,0), -- up
	QuatDeg3(180,-90,0), -- down

	QuatDeg3(0,90,90), -- left
	QuatDeg3(0,-90,-90), -- right
}

function META:Capture()
	local old_view = camera.camera_3d:GetView()
	local old_projection = camera.camera_3d:GetProjection()

	local projection = Matrix44()
	projection:Perspective(self.FOV, camera.camera_3d.FarZ, camera.camera_3d.NearZ, self.tex:GetSize().x / self.tex:GetSize().y)

	self.fb:Begin()
		for i, rot in ipairs(directions) do
			self.fb:SetTexture(1, self.tex, nil, nil, i)
			self.fb:ClearAll()

			local view = Matrix44()
			view:SetRotation(rot)
			view:Translate(self.Position.y ,self.Position.x,self.Position.z)
			camera.camera_3d:SetProjection(projection)
			camera.camera_3d:SetView(view)

			render3d.DrawGBuffer("env_probe")
		end
	self.fb:End()

	camera.camera_3d:SetView(old_view)
	camera.camera_3d:SetProjection(old_projection)
end

function META:SetPreview(b)
	if b then
		local ent = entities.CreateEntity("visual")
		ent:SetModelPath("models/sphere.obj")
		ent:SetPosition(self.Position)
		ent:SetSize(0.1)

		local mat = render.CreateMaterial("model")
		mat:SetAlbedoTexture(render.GetWhiteTexture())
		mat:SetRoughnessTexture(render.GetWhiteTexture())
		mat:SetMetallicTexture(render.GetWhiteTexture())
		mat:SetRoughnessMultiplier(0)
		mat:SetMetallicMultiplier(1)
		ent:SetMaterialOverride(mat)

		self.preview_ent = ent
	else
		prototype.SafeRemove(self.preview_ent)
	end
end

function META:OnRemove()
	self:SetPreview(false)
end

META:Register()

function render3d.CreateEnvironmentProbe()
	local self = META:CreateObject()
	self:CreateTexture()
	return self
end

if RELOAD then
	for _, v in pairs(prototype.GetCreated()) do
		if v.Type == META.Type then
			v:Capture()
		end
	end
end