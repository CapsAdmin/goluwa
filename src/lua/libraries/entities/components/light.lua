if not render then return end

local META = prototype.CreateTemplate()

META.Name = "light"
META.Require = {"transform"}
META.Events = {"Draw3DLights", "DrawShadowMaps"}

META:StartStorable()
	META:GetSet("Color", Color(1, 1, 1))
	META:GetSet("Intensity", 1)
	META:GetSet("Shadow", false)
	META:GetSet("ShadowCubemap", false)
	META:GetSet("ShadowSize", 256)
	META:GetSet("FOV", 90, {editor_min = 0, editor_max = 180, callback = "BuildProjection"})
	META:GetSet("NearZ", 1, {callback = "BuildProjection"})
	META:GetSet("FarZ", -1, {callback = "BuildProjection"})
	META:GetSet("ProjectFromCamera", false)
	META:GetSet("Ortho", true, {callback = "BuildProjection"})
	META:GetSet("OrthoSizeMin", 5, {callback = "BuildProjection"})
	META:GetSet("OrthoSizeMax", 1000, {callback = "BuildProjection"})
	META:GetSet("OrthoBias", 0.05, {callback = "BuildProjection"})
META:EndStorable()

if GRAPHICS then
	function META:OnAdd()
		self.shadow_maps = {}
		self.cameras = {}

		gfx.LoadModel3D("models/low-poly-sphere.obj", function(meshes)
			self.light_mesh = meshes[1]
		end)
	end

	function META:SetShadow(b)
		self.Shadow = b
		if b then
			for i = 1, render3d.csm_count do
				local shadow_map = render3d.CreateShadowMap(self.ShadowCubemap)
				shadow_map:SetShadowSize(self.ShadowSize)
				self.shadow_maps[i] = shadow_map

				local cam = camera.CreateCamera()
				cam:Set3D(true)
				self.cameras[i] = cam
			end
		else
			for _, shadow_map in pairs(self.shadow_maps) do
				shadow_map:Remove()
			end
			table.clear(self.shadow_maps)
			table.clear(self.cameras)
		end
	end

	function META:SetShadowSize(size)
		self.ShadowSize = size
		for _, shadow_map in pairs(self.shadow_maps) do
			shadow_map:SetShadowSize(size)
		end
	end

	function META:BuildProjection()
		for i, cam in ipairs(self.cameras) do
			local projection = Matrix44()

			do -- setup the projection matrix
				if self.Ortho then
					local size = math.lerp(((i-1)/(#self.shadow_maps-1))^self.OrthoBias, self.OrthoSizeMax, self.OrthoSizeMin)
					projection:Ortho(-size, size, -size, size, size+200, -size-100)
				else
					local shadow_map = self.shadow_maps[i]
					projection:Perspective(math.rad(self.FOV), self.FarZ, self.NearZ, shadow_map.tex:GetSize().x / shadow_map.tex:GetSize().y)
				end
			end

			cam:SetProjection(projection)
		end
	end

	function META:OnDraw3DLights()
		if not self.light_mesh or not render3d.gbuffer_data_pass.light_shader then return end -- grr

		-- automate this!!

		if self.Shadow then
			self:DrawShadowMap()
		end

		local shader = render3d.gbuffer_data_pass.light_shader

		shader.light_color = self.Color
		shader.light_intensity = self.Intensity
		shader.light_shadow = self.Shadow
		shader.light_point_shadow = self.ShadowCubemap
		shader.project_from_camera = self.ProjectFromCamera

		local transform = self:GetComponent("transform")

		camera.camera_3d:SetWorld(transform:GetMatrix())
		shader.light_radius = transform:GetSize()

		render.SetBlendMode("one", "one")
		shader:Bind()
		self.light_mesh:Draw()
	end

	function META:DrawScene(pos, rot, i)
		local cam = self.cameras[i]

		do -- setup the view matrix
			local view = Matrix44()

			view:SetRotation(rot)

			if self.ProjectFromCamera then
				pos = camera.camera_3d:GetPosition()
				local hmm = 0.25
				view:Translate(math.ceil(pos.y*hmm)/hmm, math.ceil(pos.x*hmm)/hmm, math.ceil(pos.z*hmm)/hmm)
			else
				view:Translate(pos.y, pos.x, pos.z)
			end

			cam:SetView(view)
		end

		if cam:GetMatrices().projection_view then
			render3d.gbuffer_data_pass.light_shader["light_projection_view" .. i] = cam:GetMatrices().projection_view
		else
			render3d.gbuffer_data_pass.light_shader["light_view" .. i] = cam:GetMatrices().view
			render3d.gbuffer_data_pass.light_shader["light_projection" .. i] = cam:GetMatrices().projection
		end

		local old = camera.camera_3d
		camera.camera_3d = cam
		render3d.shader = render3d.shadow_map_shader
		render3d.DrawScene("shadow"..i)
		camera.camera_3d = old
	end

	function META:DrawShadowMap()
		local transform = self:GetComponent("transform")
		local pos = transform:GetPosition()
		local rot = transform:GetRotation()

		for i, shadow_map in ipairs(self.shadow_maps) do
			shadow_map:Begin()

			if self.ShadowCubemap then
				for i2, rot in ipairs(shadow_map:GetDirections()) do
					shadow_map:SetupCube(i2)
					shadow_map:Clear()
					self:DrawScene(pos, rot, i)
				end
			else
				shadow_map:Clear()
				self:DrawScene(pos, rot, i)
			end

			shadow_map:End()

			if self.ShadowCubemap then
				render3d.gbuffer_data_pass.light_shader["tex_shadow_map_cube"] = shadow_map:GetTexture()
			else
				render3d.gbuffer_data_pass.light_shader["tex_shadow_map_" .. i] = shadow_map:GetTexture()
			end

			if not self.Ortho then break end
		end
	end
end

META:RegisterComponent()

if RELOAD then
	render3d.Initialize()
end