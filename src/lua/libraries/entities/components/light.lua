if not render then return end

render.csm_count = 4

local COMPONENT = {}

COMPONENT.Name = "light"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DLights", "DrawShadowMaps"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1))

	prototype.GetSet(COMPONENT, "Intensity", 1)

	prototype.GetSet(COMPONENT, "Shadow", false)
	prototype.GetSet(COMPONENT, "ShadowCubemap", false)
	prototype.GetSet(COMPONENT, "ShadowSize", 256)
	prototype.GetSet(COMPONENT, "FOV", 90, {editor_min = 0, editor_max = 180})
	prototype.GetSet(COMPONENT, "NearZ", 1)
	prototype.GetSet(COMPONENT, "FarZ", -1)
	prototype.GetSet(COMPONENT, "ProjectFromCamera", false)
	prototype.GetSet(COMPONENT, "OrthoSize", 0)
prototype.EndStorable()

if GRAPHICS then
	function COMPONENT:OnAdd()
		self.shadow_maps = {}
		render.LoadModel("models/low-poly-sphere.obj", function(meshes)
			self.light_mesh = meshes[1]
		end)
	end

	function COMPONENT:SetShadow(b)
		self.Shadow = b
		if b then
			for i = 1, render.csm_count do
				local shadow_map = render.CreateShadowMap(self.ShadowCubemap)
				shadow_map:SetShadowSize(self.ShadowSize)
				self.shadow_maps[i] = shadow_map
			end
		else
			for _, shadow_map in pairs(self.shadow_maps) do
				shadow_map:Remove()
			end
			table.clear(self.shadow_maps)
		end
	end

	function COMPONENT:SetShadowSize(size)
		self.ShadowSize = size
		for _, shadow_map in pairs(self.shadow_maps) do
			shadow_map:SetShadowSize(size)
		end
	end

	function COMPONENT:OnDraw3DLights()
		if not self.light_mesh or not render.gbuffer_fill.light_shader then return end -- grr

		-- automate this!!

		if self.Shadow then
			self:DrawShadowMap()
		end

		local shader = render.gbuffer_fill.light_shader

		shader.light_color = self.Color
		shader.light_intensity = self.Intensity
		shader.light_shadow = self.Shadow
		shader.light_point_shadow = self.ShadowCubemap
		shader.project_from_camera = self.ProjectFromCamera

		local transform = self:GetComponent("transform")

		render.camera_3d:SetWorld(transform:GetMatrix())
		local mat = render.camera_3d:GetMatrices().view_world
		local x,y,z = mat:GetTranslation()

		shader.light_view_pos:Set(x,y,z)
		shader.light_radius = transform:GetSize()

		render.SetShaderOverride(shader)
		render.SetBlendMode("one", "one")
		self.light_mesh:Draw()
	end

	function COMPONENT:DrawScene(projection, rot, pos, i)
		do -- setup the view matrix
			local view = Matrix44()

			view:SetRotation(rot)

			if self.ProjectFromCamera then
				pos = render.camera_3d:GetPosition()
				view:Translate(pos.y, pos.x, pos.z)
			else
				view:Translate(pos.y, pos.x, pos.z)
			end

			render.camera_3d:SetView(view)
		end

		-- render the scene with this matrix
		render.camera_3d:SetProjection(projection)
		render.gbuffer_fill.light_shader["light_projection_view_" .. i] = render.camera_3d:GetMatrices().projection_view
		render.Draw3DScene(self, self.OrthoSize == 0 and self:GetComponent("transform"):GetSize())
	end

	function COMPONENT:DrawShadowMap()
		render.SetCullMode("front")
		local transform = self:GetComponent("transform")
		local pos = transform:GetPosition()
		local rot = transform:GetRotation()

		render.camera_3d:Rebuild()

		local old_view = render.camera_3d:GetView()
		local old_projection = render.camera_3d:GetProjection()
		local old_pos = render.camera_3d:GetPosition()

		for i, shadow_map in ipairs(self.shadow_maps) do
			shadow_map:Begin()

			local projection = Matrix44()

			do -- setup the projection matrix
				if self.OrthoSize == 0 then
					projection:Perspective(math.rad(self.FOV), self.FarZ, self.NearZ, shadow_map.tex.w / shadow_map.tex.h)
				else
					local size = 1 * self.OrthoSize / (i^2)
					projection:Ortho(-size, size, -size, size, size+100, -size)
				end
			end

			if self.ShadowCubemap then
				for i, rot in ipairs(shadow_map:GetDirections()) do
					shadow_map:SetupCube(i)
					shadow_map:Clear()
					self:DrawScene(projection, rot, pos, i)
				end
			else
				shadow_map:Clear()
				self:DrawScene(projection, rot, pos, i)
			end

			shadow_map:End()

			if self.ShadowCubemap then
				render.gbuffer_fill.light_shader["tex_shadow_map_cube"] = shadow_map:GetTexture()
			else
				render.gbuffer_fill.light_shader["tex_shadow_map_" .. i] = shadow_map:GetTexture()
			end

			if self.OrthoSize == 0 then break end
		end

		render.camera_3d:SetView(old_view)
		render.camera_3d:SetProjection(old_projection)
		render.camera_3d:SetPosition(old_pos)

		render.SetCullMode("back")
	end
end

prototype.RegisterComponent(COMPONENT)

if RELOAD then
	render.InitializeGBuffer()
end