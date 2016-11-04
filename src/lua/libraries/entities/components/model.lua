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

	function META:SetAABB(aabb)
		self.tr:SetAABB(aabb)
		self.AABB = aabb
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
				self:BuildBoundingBox()
			end,
			function(mesh)
				self:AddMesh(mesh)
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
			mesh.material = mesh.material or render3d.default_material
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
			self.AABB:Expand(mesh.AABB)
		end

		self:SetAABB(self.AABB)

		render3d.largest_aabb = render3d.largest_aabb or AABB()
		local old = render3d.largest_aabb:Copy()
		render3d.largest_aabb:Expand(self.AABB)
		if old ~= render3d.largest_aabb then
			event.Call("LargestAABB", render3d.largest_aabb)
		end
	end

	function META:IsVisible(what)
		if self.is_visible == false then return false end

		if not self.next_visible[what] or self.next_visible[what] < system.GetElapsedTime() then
			self.visible[what] = camera.camera_3d:IsAABBVisible(self.tr:GetTranslatedAABB())
			self.next_visible[what] = system.GetElapsedTime() + 0.25
		end

		return self.visible[what]
	end

	local ipairs = ipairs
	local render_SetMaterial = render.SetMaterial

	function META:Draw(what)
		if render3d.draw_once and self.Cull then
			if self.drawn_once then
				return
			end
		else
			self.drawn_once = false
		end

		if self:IsVisible(what) then
			camera.camera_3d:SetWorld(self.tr:GetMatrix())

			for _, mesh in ipairs(self.sub_meshes) do
				mesh.material.Color = self.Color
				render_SetMaterial(mesh.material)
				render3d.shader:Bind()
				mesh.vertex_buffer:Draw()
			end

			if render3d.draw_once then
				self.drawn_once = true
			end
		end
	end
end

META:RegisterComponent()

if RELOAD then
	render3d.Initialize()
end