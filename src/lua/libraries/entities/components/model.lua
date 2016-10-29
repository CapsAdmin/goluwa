local META = prototype.CreateTemplate()

META.Name = "model"
META.Require = {"transform"}

META:StartStorable()
	META:GetSet("MaterialOverride", nil)
	META:GetSet("Cull", true)
	META:GetSet("ModelPath", "models/cube.obj")
	META:GetSet("AABB", AABB())
	META:GetSet("Color", Color(1,1,1,1))
META:EndStorable()

META:IsSet("Loading", false)
META:GetSet("Model", nil)

META.Network = {
	ModelPath = {"string", 1/5, "reliable"},
	Cull = {"boolean", 1/5},
}

if GRAPHICS then
	function META:Initialize()
		self.sub_models = {}
		self.next_visible = {}
		self.visible = {}
	end

	function META:SetVisible(b)
		if b then
			render3d.AddModel(self)
		else
			render3d.RemoveModel(self)
		end
		self.is_visible = b
	end

	function META:OnAdd()
		self.tr = self:GetComponent("transform")
	end

	function META:OnRemove()
		render3d.RemoveModel(self)
	end

	function META:SetModelPath(path)
		self:RemoveMeshes()

		self.ModelPath = path

		self:SetLoading(true)

		gfx.LoadModel3D(
			path,
			function()
				if steam.LoadMap and path:endswith(".bsp") then
					steam.SpawnMapEntities(path, self:GetEntity())
				end
				self:SetLoading(false)
			end,
			function(mesh)
				self:AddMesh(mesh)
				self:BuildBoundingBox()
			end,
			function(err)
				logf("%s failed to load model %q: %s\n", self, path, err)
				self:MakeError()
			end
		)
	end

	function META:MakeError()
		self:RemoveMeshes()
		self:SetLoading(false)
		self:SetModelPath("models/error.mdl")
	end

	do
		function META:AddMesh(mesh)
			table.insert(self.sub_models, mesh)
			mesh:CallOnRemove(function()
				if self:IsValid() then
					self:RemoveMesh(mesh)
				end
			end, self)
			render3d.AddModel(self)
		end

		function META:RemoveMesh(mesh)
			for i, _mesh in ipairs(self.sub_models) do
				if mesh == _mesh then
					table.remove(self.sub_models, i)
					break
				end
			end
			if not self.sub_models[1] then
				render3d.RemoveModel(self)
			end
		end

		function META:RemoveMeshes()
			table.clear(self.sub_models)
			collectgarbage("step")
		end

		function META:GetMeshes()
			return self.sub_models
		end
	end

	function META:BuildBoundingBox()
		for _, sub_model in ipairs(self.sub_models) do
			if sub_model.AABB.min_x < self.AABB.min_x then self.AABB.min_x = sub_model.AABB.min_x end
			if sub_model.AABB.min_y < self.AABB.min_y then self.AABB.min_y = sub_model.AABB.min_y end
			if sub_model.AABB.min_z < self.AABB.min_z then self.AABB.min_z = sub_model.AABB.min_z end

			if sub_model.AABB.max_x > self.AABB.max_x then self.AABB.max_x = sub_model.AABB.max_x end
			if sub_model.AABB.max_y > self.AABB.max_y then self.AABB.max_y = sub_model.AABB.max_y end
			if sub_model.AABB.max_z > self.AABB.max_z then self.AABB.max_z = sub_model.AABB.max_z end
		end
	end

	local ipairs = ipairs
	local render_SetMaterial = render.SetMaterial
	function META:Draw(what)
		camera.camera_3d:SetWorld(self.tr:GetMatrix())

		if self.MaterialOverride then
			self.MaterialOverride:SetColor(self.Color)
			render_SetMaterial(self.MaterialOverride)
			for _, model in ipairs(self.sub_models) do
				model.mesh:Draw()
			end
		else
			for _, model in ipairs(self.sub_models) do
				model.material:SetColor(self.Color)
				render_SetMaterial(model.material)
				model.mesh:Draw()
			end
		end
	end
end

META:RegisterComponent()

if RELOAD then
	render3d.Initialize()
end