local COMPONENT = {}

COMPONENT.Name = "model"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DGeometry"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1, 1))
	prototype.GetSet(COMPONENT, "IlluminationColor", Color(1, 1, 1, 1))
	prototype.GetSet(COMPONENT, "Alpha", 1)
	prototype.GetSet(COMPONENT, "Cull", true)
	prototype.GetSet(COMPONENT, "ModelPath", "")
	prototype.GetSet(COMPONENT, "DiffuseTexturePath", "")
	prototype.GetSet(COMPONENT, "BumpTexturePath", "")
	prototype.GetSet(COMPONENT, "SpecularTexturePath", "")

	prototype.GetSet(COMPONENT, "BBMin", Vec3())
	prototype.GetSet(COMPONENT, "BBMax", Vec3())
prototype.EndStorable()

prototype.GetSet(COMPONENT, "DiffuseTexture")
prototype.GetSet(COMPONENT, "BumpTexture")
prototype.GetSet(COMPONENT, "SpecularTexture")
prototype.GetSet(COMPONENT, "IlluminationTexture")
prototype.GetSet(COMPONENT, "Model", nil)

COMPONENT.Network = {
	ModelPath = {"string", 1/5, "reliable", true},
	Cull = {"boolean", 1/5},
	Alpha = {"float", 1/30, "unreliable"},
	Color = {"color", 1/5},
}

if GRAPHICS then 
	function COMPONENT:OnAdd(ent)
	end

	function COMPONENT:OnRemove(ent)

	end

	function COMPONENT:SetModelPath(path)
		self.ModelPath = path
		
		utility.LoadRenderModel(
			path, 
			function() 
				if steam.LoadMap and path:endswith(".bsp") then
					steam.SpawnMapEntities(path, self:GetEntity())
				end
			end, 
			function(mesh)
				self:AddMesh(mesh)
				self:BuildBoundingBox()
			end,
			function(err)
				logf("%s failed to load model %q: %s\n", self, path, err)
				self:RemoveMeshes()
			end
		)
		
	end

	function COMPONENT:SetDiffuseTexturePath(path)
		self.DiffuseTexturePath = path
		self.DiffuseTexture = Texture(path)
	end
	
	function COMPONENT:SetBumpTexturePath(path)
		self.BumpTexturePath = path
		self.BumpTexture = Texture(path)
	end
	
	function COMPONENT:SetSpecularTexturePath(path)
		self.SpecularTexturePath = path
		self.SpecularTexture = Texture(path)
	end

	do		
		function COMPONENT:AddMesh(mesh)
			self.sub_models = self.sub_models or {}
			checkx(mesh, "mesh_builder")
			table.insert(self.sub_models, mesh)
			mesh:CallOnRemove(function()
				if self:IsValid() then
					self:RemoveMesh(mesh)
				end
			end, self)
		end
		
		function COMPONENT:RemoveMesh(mesh)
			self.sub_models = self.sub_models or {}
			for i, _mesh in ipairs(self.sub_models) do
				if mesh == _mesh then
					table.remove(self.sub_models, i)
					break
				end
			end
		end
		
		function COMPONENT:RemoveMeshes()
			self.sub_models = {}
			collectgarbage("step")
		end
		
		function COMPONENT:GetMeshes()
			self.sub_models = self.sub_models or {}
			return self.sub_models
		end
	end

	do		
		local function corner_helper(self, i, j)
			return bit.band(bit.rshift(i, j), 1) == 0 and self.BBMin or self.BBMax
		end
		
		function COMPONENT:BuildBoundingBox()	
			self.sub_models = self.sub_models or {}
			local min, max = Vec3(), Vec3()

			for i, sub_model in ipairs(self.sub_models) do				
				if sub_model.BBMin.x < min.x then min.x = sub_model.BBMin.x end
				if sub_model.BBMin.y < min.y then min.y = sub_model.BBMin.y end
				if sub_model.BBMin.z < min.z then min.z = sub_model.BBMin.z end
				
				if sub_model.BBMax.x > max.x then max.x = sub_model.BBMax.x end
				if sub_model.BBMax.y > max.y then max.y = sub_model.BBMax.y end
				if sub_model.BBMax.z > max.z then max.z = sub_model.BBMax.z end
			end
			
			self.BBMin = min
			self.BBMax = max
			
			self.corners = {}
			
			for i = 0, 7 do
				local x = corner_helper(self, i, 2).x
				local y = corner_helper(self, i, 1).y
				local z = corner_helper(self, i, 0).z
				
				self.corners[i+1] = Vec3(x, y, z)
			end
		end
	end

	function COMPONENT:OnDraw3DGeometry(shader, vp_matrix, skip_cull)
		self.sub_models = self.sub_models or {}
		vp_matrix = vp_matrix or render.matrices.vp_matrix

		local matrix = self:GetComponent("transform"):GetMatrix()
		
		if not self.Cull or not self.corners or self:GetComponent("transform"):IsPointsVisible(self.corners, vp_matrix) then

			local screen = matrix * vp_matrix
			shader.pvm_matrix = screen.m
			shader.vm_matrix = (matrix * render.matrices.view_3d).m
			shader.v_matrix = render.GetViewMatrix3D()
			shader.color = self.Color

			for i, model in ipairs(self.sub_models) do
				if not skip_cull then if model.no_cull then render.SetCullMode("none") else render.SetCullMode("front") end end
				shader.alpha_test = model.alpha_test and 1 or 0
				shader.diffuse = self.DiffuseTexture or model.diffuse or render.GetErrorTexture()
				shader.diffuse2 = self.DiffuseTexture2 or model.diffuse2 or render.GetErrorTexture()
				shader.specular = self.SpecularTexture or model.specular or render.GetWhiteTexture()
				shader.illumination = self.IlluminationTexture or model.illumination or render.GetBlackTexture()
				shader.illumination_color = model.illumination_color or self.IlluminationColor
				shader.bump = self.BumpTexture or model.bump or render.GetBlackTexture()
				shader.bump2 = self.BumpTexture2 or model.bump2 or render.GetBlackTexture()
				shader.displacement = self.Displacement or model.displacement or render.GetWhiteTexture()
				shader.detail = model.detail or render.GetWhiteTexture()
				shader.detail_blend_factor = model.detail_blend_factor 

				shader:Bind()
				model:Draw()
			end
		end
	end
end

prototype.RegisterComponent(COMPONENT)

if RELOAD then
	render.InitializeGBuffer()
end