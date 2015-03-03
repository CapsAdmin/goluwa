local COMPONENT = {}

COMPONENT.Name = "model"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DGeometry"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1, 1))
	prototype.GetSet(COMPONENT, "IlluminationColor", Color(1, 1, 1, 1))
	prototype.GetSet(COMPONENT, "Alpha", 1)
	prototype.GetSet(COMPONENT, "Roughness", 0)
	prototype.GetSet(COMPONENT, "Metallic", 0)
	prototype.GetSet(COMPONENT, "Cull", true)
	prototype.GetSet(COMPONENT, "ModelPath", "")
	prototype.GetSet(COMPONENT, "BBMin", Vec3())
	prototype.GetSet(COMPONENT, "BBMax", Vec3())
prototype.EndStorable()

prototype.GetSet(COMPONENT, "Model", nil)

render.model_textures = {}

local function add_texture(name, default)
	prototype.StartStorable()
	prototype.GetSet(COMPONENT, name .. "TexturePath", "")
	prototype.EndStorable()
	
	prototype.GetSet(COMPONENT, name .. "Texture")
	
	COMPONENT["Set" .. name .. "TexturePath"] = function(self, path)
		self[name .. "TexturePath"] = path
		self[name .. "Texture"] = Texture(path)
	end
	
	table.insert(render.model_textures, {
		shader_name = "tex_model_" .. name:lower(), 
		lookup_name = name .. "Texture", 
		lookup_name2 = name:lower(),
		default_texture = default
	})
end

add_texture("Diffuse", render.GetErrorTexture())
add_texture("Normal", render.GetBlackTexture())
add_texture("Metallic", render.GetBlackTexture())
add_texture("Roughness", render.GetGreyTexture()) 

-- source engine specific
--add_texture("Illumination", render.GetBlackTexture())
--add_texture("Detail", render.GetWhiteTexture())
add_texture("Diffuse2", render.GetBlackTexture())
add_texture("Normal2", render.GetBlackTexture()) 

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

	function COMPONENT:OnDraw3DGeometry(shader, projection_view, simple)
		self.sub_models = self.sub_models or {}
		projection_view = projection_view or render.matrices.vp_matrix
		
		if simple then
			local matrix = self:GetComponent("transform"):GetMatrix()

			shader.projection_view_world = matrix * projection_view
			for i, model in ipairs(self.sub_models) do
				shader.tex_diffuse = self.DiffuseTexture
				shader:Bind()
				model:Draw()
				shader.alpha_test = model.alpha_test and 1 or 0
			end
			return
		end

		local matrix = self:GetComponent("transform"):GetMatrix()
		
		if not self.Cull or not self.corners or self:GetComponent("transform"):IsPointsVisible(self.corners, projection_view) then
			shader.projection_view_world = matrix * projection_view
			shader.view_world = matrix * render.matrices.view_3d -- for bump maps
			shader.color = self.Color

			for i, model in ipairs(self.sub_models) do
				if model.no_cull then 
					render.SetCullMode("none") 
				else 
					render.SetCullMode("front") 
				end 
				
				shader.alpha_test = model.alpha_test and 1 or 0
			
				for i,v in ipairs(render.model_textures) do
					shader[v.shader_name] = self[v.lookup_name] or model[v.lookup_name2] or v.default_texture
				end
				
				shader.alpha_specular = model.alpha_specular
				shader.illumination_color = model.illumination_color or self.IlluminationColor
				shader.detail_blend_factor = model.detail_blend_factor 
				
				shader.roughness_multiplier = model.roughness_multiplier or self.Roughness
				shader.metallic_multiplier = model.metallic_multiplier or self.Metallic
			
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