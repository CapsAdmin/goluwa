if not render then return end

local META = prototype.CreateTemplate()
META.Name = "light"
META.Require = {"transform"}
META.Events = {"Draw3DLights", "DrawShadowMaps", "LargestAABB"}
META:StartStorable()
META:GetSet("Color", Color(1, 1, 1))
META:GetSet("Intensity", 1)
META:GetSet("Shadow", false, {callback = "BuildProjection"})
META:GetSet("ShadowCubemap", false, {callback = "BuildProjection"})
META:GetSet("ShadowSize", 256, {callback = "BuildProjection"})
META:GetSet("FOV", 90, {editor_min = 0, editor_max = 180, callback = "BuildProjection"})
META:GetSet("NearZ", 0, {callback = "BuildProjection"})
META:GetSet("FarZ", 32000, {callback = "BuildProjection"})
META:GetSet("ProjectFromCamera", false, {callback = "BuildProjection"})
META:GetSet("Ortho", true, {callback = "BuildProjection"})
META:GetSet("OrthoSizeMin", 5, {callback = "BuildProjection"})
META:GetSet("OrthoSizeMax", 1000, {callback = "BuildProjection"})
META:GetSet("OrthoBias", 0.05, {callback = "BuildProjection"})
META:EndStorable()

if GRAPHICS then
	function META:SetColor(val)
		self.Color = val
		self.EditorName = utility.FindColor(self.Color)
	end

	function META:OnAdd()
		self.shadow_maps = {}
		self.cameras = {}
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

			list.clear(self.shadow_maps)
			list.clear(self.cameras)
		end

		self:BuildProjection()
	end

	function META:SetShadowSize(size)
		self.ShadowSize = size

		for i, shadow_map in pairs(self.shadow_maps) do
			--shadow_map:SetShadowSize(math.pow2round(size/i))
			shadow_map:SetShadowSize(size)
		end

		self:BuildProjection()
	end

	function META:GetOrthoSize(i)
		local max = self.OrthoSizeMax

		if max <= 0 and render3d.largest_aabb then
			max = render3d.largest_aabb:GetLength() / 2
		end

		return math.lerp(((i - 1) / (#self.shadow_maps - 1)) ^ self.OrthoBias, self.OrthoSizeMin, max)
	end

	function META:BuildProjection()
		for i, cam in ipairs(self.cameras) do
			local projection = Matrix44()

			do -- setup the projection matrix
				if self.Ortho then
					local size = self:GetOrthoSize(i)
					projection:Ortho(-size, size, -size, size, 100, -1000)
					cam:SetViewport(Rect(0, 0, size, size))
				else
					local shadow_map = self.shadow_maps[i]
					projection:Perspective(
						math.rad(self.FOV),
						self.FarZ,
						self.NearZ,
						shadow_map.tex:GetSize().x / shadow_map.tex:GetSize().y
					)
				end
			end

			cam:SetProjection(projection)
			cam:Rebuild()
		end
	end

	function META:OnLargestAABB()
		self:BuildProjection()
	end

	function META:OnDraw3DLights()
		if not render3d.gbuffer_data_pass.light_shader then return end -- grr
		-- automate this!!
		if self.Shadow then self:DrawShadowMap() end

		local shader = render3d.gbuffer_data_pass.light_shader
		shader.light_color = self.Color
		shader.light_intensity = self.Intensity
		shader.light_shadow = self.Shadow
		shader.light_point_shadow = self.ShadowCubemap
		shader.project_from_camera = self.ProjectFromCamera
		local transform = self:GetComponent("transform")
		render3d.camera:SetWorld(transform:GetMatrix())
		shader.light_radius = transform:GetSize()
		render.SetBlendMode("one", "one")
		shader:Bind()

		if render3d.simple_mesh then render3d.simple_mesh:Draw(1) end
	end

	function META:DrawScene(pos, rot, i)
		local cam = self.cameras[i]

		do -- setup the view matrix
			local view = Matrix44()
			view:SetRotation(rot)

			if self.ProjectFromCamera then
				--local size = self:GetOrthoSize(i)
				--local cam_view = render3d.camera:GetMatrices().view
				--local x,y,z = cam_view:TransformPoint(0,0, size)
				--view:Translate(x,y,z)
				--view:SetRotation(cam_view:GetRotation():HamRight(view:GetRotation()))
				--view:Translate(-size/2, -size/2, 0)
				pos = render3d.camera:GetPosition()
				view:Translate(pos.y, pos.x, pos.z)
				local hmm = 0.5
			--view:Translate(math.round(pos.y*hmm)/hmm, math.round(pos.x*hmm)/hmm, math.round(pos.z*hmm)/hmm)
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

		local old = render3d.camera
		render3d.camera = cam
		render3d.shader = render3d.shadow_map_shader
		render3d.draw_once = true
		render.SetForcedCullMode("none")
		render3d.DrawScene("shadow" .. i)
		render.SetForcedCullMode()
		render3d.draw_once = false
		render3d.camera = old
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

	for _, obj in ipairs(prototype.GetCreated(true, "component", META.Name)) do
		if obj.Shadow then
			obj:SetShadow(false)
			obj:SetShadow(true)
		end
	end
end