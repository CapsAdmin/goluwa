if not render then return end

local COMPONENT = {}

COMPONENT.Name = "light"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DLights", "DrawShadowMaps"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1))
	prototype.GetSet(COMPONENT, "AmbientColor", Color(0, 0, 0))
	
	prototype.GetSet(COMPONENT, "Intensity", 1)

	prototype.GetSet(COMPONENT, "Shadow", false)
	prototype.GetSet(COMPONENT, "ShadowCubemap", false)
	prototype.GetSet(COMPONENT, "ShadowSize", 1024)
	prototype.GetSet(COMPONENT, "FOV", 90, {editor_min = 0, editor_max = 180})
	prototype.GetSet(COMPONENT, "NearZ", 1)
	prototype.GetSet(COMPONENT, "FarZ", 32000)
	prototype.GetSet(COMPONENT, "ProjectFromCamera", false) 
	prototype.GetSet(COMPONENT, "OrthoSize", 0)
prototype.EndStorable()

if GRAPHICS then
	function COMPONENT:OnAdd(ent)
		render.LoadModel("models/low-poly-sphere.obj", function(meshes)
			self.light_mesh = meshes[1]
		end)
	end
	
	function COMPONENT:SetShadow(b)
		self.Shadow = b
		if b then
			self.shadow_map = render.CreateShadowMap(self.ShadowCubemap)
		else
			self.shadow_map:Remove()
		end
	end
	
	function COMPONENT:OnDraw3DLights()
		if not self.light_mesh then return end -- grr
				
		-- automate this!!
		
		if self.Shadow then
			render.SetCullMode("front")
			self:DrawShadowMap()
			render.SetCullMode("back")
			
			if self.ShadowCubemap then
				render.gbuffer_light_shader.tex_shadow_map_cube = self.shadow_map:GetTexture()
			else
				render.gbuffer_light_shader.tex_shadow_map = self.shadow_map:GetTexture()
			end
		end
		
		render.gbuffer_light_shader.light_ambient_color = self.AmbientColor
		render.gbuffer_light_shader.light_color = self.Color
		render.gbuffer_light_shader.light_intensity = self.Intensity
		render.gbuffer_light_shader.light_shadow = self.Shadow
		render.gbuffer_light_shader.light_point_shadow = self.ShadowCubemap
		render.gbuffer_light_shader.project_from_camera = self.ProjectFromCamera
		
		local transform = self:GetComponent("transform")
		
		render.camera_3d:SetWorld(transform:GetMatrix())
		local mat = render.camera_3d:GetMatrices().view_world
		local x,y,z = mat:GetTranslation()
		
		render.gbuffer_light_shader.light_view_pos:Set(x,y,z)
		render.gbuffer_light_shader.light_radius = transform:GetSize()		
		
		render.SetShaderOverride(render.gbuffer_light_shader)
		render.SetBlendMode("one", "one")
		self.light_mesh:Draw()
	end
	
	function COMPONENT:DrawScene(projection, rot, pos)
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
		render.gbuffer_light_shader.light_projection_view = render.camera_3d:GetMatrices().projection_view
		render.Draw3DScene("shadows")
	end

	function COMPONENT:DrawShadowMap(ortho_divider)
		self.shadow_map:Begin()

		local transform = self:GetComponent("transform")
		local pos = transform:GetPosition()
		local rot = transform:GetRotation()
			
		local old_view = render.camera_3d:GetView()
		local old_projection = render.camera_3d:GetProjection()

		local projection = Matrix44()
		
		do -- setup the view matrix
			if self.OrthoSize == 0 then
				projection:Perspective(math.rad(self.FOV), render.camera_3d.FarZ, render.camera_3d.NearZ, render.camera_3d.Viewport.w / render.camera_3d.Viewport.h) 
			else
				local size = self.OrthoSize * (ortho_divider or 1)
				projection:Ortho(-size, size, -size, size, size, -size) 
			end
		end		
				
		if self.ShadowCubemap then
			for i, rot in ipairs(self.shadow_map:GetDirections()) do
				self.shadow_map:SetupCube(i)
				self.shadow_map:Clear()
				self:DrawScene(projection, rot, pos)
			end	
		else
			self.shadow_map:Clear()
			self:DrawScene(projection, rot, pos)
		end
		
		render.camera_3d:SetView(old_view)
		render.camera_3d:SetProjection(old_projection)
		
		self.shadow_map:End()
	end
end

prototype.RegisterComponent(COMPONENT)

if RELOAD then
	render.InitializeGBuffer()
end