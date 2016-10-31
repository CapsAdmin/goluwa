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
		self.sub_meshes = {}
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

	function META:SetMaterialOverride(mat)
		self.MaterialOverride = mat
		for _, mesh in ipairs(self.sub_meshes) do
			mesh.material = mat
		end
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
				logf("%s failed to load mesh %q: %s\n", self, path, err)
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
			table.insert(self.sub_meshes, mesh)
			mesh:CallOnRemove(function()
				if self:IsValid() then
					self:RemoveMesh(mesh)
				end
			end, self)
			render3d.AddModel(self)
		end

		function META:RemoveMesh(model_)
			for i, mesh in ipairs(self.sub_meshes) do
				if mesh == model_ then
					table.remove(self.sub_meshes, i)
					break
				end
			end
			if not self.sub_meshes[1] then
				render3d.RemoveModel(self)
			end
		end

		function META:RemoveMeshes()
			table.clear(self.sub_meshes)
			collectgarbage("step")
		end

		function META:GetMeshes()
			return self.sub_meshes
		end
	end

	function META:BuildBoundingBox()
		for _, mesh in ipairs(self.sub_meshes) do
			if mesh.AABB.min_x < self.AABB.min_x then self.AABB.min_x = mesh.AABB.min_x end
			if mesh.AABB.min_y < self.AABB.min_y then self.AABB.min_y = mesh.AABB.min_y end
			if mesh.AABB.min_z < self.AABB.min_z then self.AABB.min_z = mesh.AABB.min_z end

			if mesh.AABB.max_x > self.AABB.max_x then self.AABB.max_x = mesh.AABB.max_x end
			if mesh.AABB.max_y > self.AABB.max_y then self.AABB.max_y = mesh.AABB.max_y end
			if mesh.AABB.max_z > self.AABB.max_z then self.AABB.max_z = mesh.AABB.max_z end
		end
	end

	local ipairs = ipairs
	local render_SetMaterial = render.SetMaterial

	function META:Draw(what)
		camera.camera_3d:SetWorld(self.tr:GetMatrix())

		--[[
		local pos = self.tr:GetPosition()
		local aabb = self:GetAABB():Copy()
		aabb.min_x = aabb.min_x + pos.x
		aabb.min_y = aabb.min_y + pos.y
		aabb.min_z = aabb.min_z + pos.z

		aabb.max_x = aabb.max_x + pos.x
		aabb.max_y = aabb.max_y + pos.y
		aabb.max_z = aabb.max_z + pos.z
		]]

		--if camera.camera_3d:IntersectAABB(aabb) then
			for _, mesh in ipairs(self.sub_meshes) do
				mesh.material.Color = self.Color
				render_SetMaterial(mesh.material)
				render3d.shader:Bind()
				mesh.vertex_buffer:Draw()
			end
		--else
		--	if wait(0.5) then
		--		print(self.ModelPath, os.clock())
		--	end
		--end
	end
end

META:RegisterComponent()

if RELOAD then
	render3d.Initialize()
end