local UNROLL_DRAWMODEL = false

local META = prototype.CreateTemplate()

META.Name = "model"
META.Require = {"transform"}

META:StartStorable()
	META:GetSet("Cull", true)
	META:GetSet("ModelPath", "models/cube.obj")
	META:GetSet("Color", Color(1,1,1,1))
	META:GetSet("RoughnessMultiplier", 1)
	META:GetSet("MetallicMultiplier", 1)
	META:GetSet("UVMultiplier", 1)
META:EndStorable()

META:IsSet("Loading", false)
META:GetSet("Model", nil)
META:GetSet("AABB", AABB())
META:GetSet("MaterialOverride", nil)

META.Network = {
	ModelPath = {"string", 1/5, "reliable"},
	Cull = {"boolean", 1/5},
}

if GRAPHICS then
	function META:Initialize()
		self.sub_models = {}
		self.sub_meshes = {}
		self.next_visible = {}
		self.visible = {}
		self.occluders = {}
		self.sub_meshes_length = 0
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
		self:UnrollDrawModel()
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
		for _, v in pairs(self.occluders) do
			v:Delete()
		end
	end

	function META:SetModelPath(path)
		self:RemoveSubModels()

		self.ModelPath = path

		self:SetLoading(true)

		render3d.LoadModel(
			path,
			function()
				self:SetLoading(false)
				self:BuildBoundingBox()
			end,
			function(model)
				self:AddSubModel(model)
			end,
			function(err)
				logf("%s failed to load model %q: %s\n", self, path, err)
				self:MakeError()
			end
		)

		self.EditorName = ("/" .. self.ModelPath):match("^.+/(.+)%."):lower():gsub("_", " "):gsub("%d", ""):gsub("%s+", " ")
	end

	function META:MakeError()
		self:RemoveSubModels()
		self:SetLoading(false)
		self:SetModelPath("models/error.mdl")
	end

	do
		local function check_translucent(self)
			self.translucent = false

			if self.MaterialOverride then
				self.translucent = self.MaterialOverride:GetTranslucent()
			else
				for _, model in ipairs(self.sub_models) do
					for _, data in ipairs(model:GetSubMeshes()) do
						if data.data and data.data:GetTranslucent() then
							self.translucent = true
						end
					end
				end
			end
		end

		function META:AddSubModel(model)
			table.insert(self.sub_models, model)

			model:CallOnRemove(function()
				if self:IsValid() then
					self:RemoveSubModel(model)
				end
			end, self)

			if self.MaterialOverride then
				self:SetMaterialOverride(self:GetMaterialOverride())
			end

			render3d.AddModel(self)

			for i, sub_mesh in ipairs(model:GetSubMeshes()) do

				sub_mesh.i = i
				sub_mesh.model = model
				sub_mesh.data = sub_mesh.data or render3d.default_material

				table.insert(self.sub_meshes, sub_mesh)
			end

			self.sub_meshes_length = #self.sub_meshes
			self:UnrollDrawModel()

			check_translucent(self)
		end

		function META:RemoveSubModel(model)
			for i, v in ipairs(self.sub_models) do
				if v == model then
					table.remove(self.sub_models, i)
					break
				end
			end

			if not self.sub_models[1] then
				render3d.RemoveModel(self)
			end

			for i,v in ipairs(model:GetSubMeshes()) do
				if table.hasvalue(self.sub_meshes, v) then
					table.remove(self.sub_meshes, i)
				end
			end

			self.sub_meshes_length = #self.sub_meshes
			self:UnrollDrawModel()

			check_translucent(self)
		end

		function META:RemoveSubModels()
			for _, model in pairs(self.sub_models) do
				self:RemoveSubModel(model)
			end
		end

		function META:GetSubModels()
			return self.sub_models
		end
	end

	function META:BuildBoundingBox()
		for _, model in ipairs(self.sub_models) do
			self.AABB:Expand(model.AABB)
		end

		self:SetAABB(self.AABB)

		render3d.largest_aabb = render3d.largest_aabb or AABB()
		local old = render3d.largest_aabb:Copy()
		render3d.largest_aabb:Expand(self.AABB)
		if old ~= render3d.largest_aabb then
			event.Call("LargestAABB", render3d.largest_aabb)
		end
	end

	function META:IsTranslucent()
		return self.translucent
	end

	local system_GetElapsedTime = system.GetElapsedTime

	function META:IsVisible(what)
		if not self.next_visible[what] or self.next_visible[what] < system_GetElapsedTime() then
			self.visible[what] = render3d.camera:IsAABBVisible(self.tr:GetTranslatedAABB(), self.tr:GetCameraDistance(), self.tr:GetBoundingSphere())
			self.next_visible[what] = system_GetElapsedTime() + 0.25
		end

		return self.visible[what]
	end

	local ipairs = ipairs
	local render_SetMaterial = render.SetMaterial

	local function apply_material(self, mat)
		mat.Color = self.Color
		mat.RoughnessMultiplier = self.RoughnessMultiplier
		mat.MetallicMultiplier = self.MetallicMultiplier
		mat.UVMultiplier = self.UVMultiplier
		render_SetMaterial(mat)
	end

	function META:DrawModel()
		if self.MaterialOverride then
			apply_material(self, self.MaterialOverride)

			--for _, data in ipairs(self.sub_meshes) do
			for i = 1, self.sub_meshes_length do
				render3d.shader:Bind()
				self.sub_meshes[i].model:Draw(self.sub_meshes[i].i)
			end
		else
			--for _, data in ipairs(self.sub_meshes) do
			for i = 1, self.sub_meshes_length do
				apply_material(self, self.sub_meshes[i].data)
				render3d.shader:Bind()
				self.sub_meshes[i].model:Draw(self.sub_meshes[i].i)
			end
		end
	end

	function META:UnrollDrawModel()
		if not UNROLL_DRAWMODEL then return end
		local lua = "local self, meshes, render3d, apply_material = ...\n"
		lua = lua .. "return function()\n"
		if self.MaterialOverride then
			lua = lua .. "apply_material(self, self.MaterialOverride)\n"
			for i = 1, self.sub_meshes_length do
				lua = lua .. "render3d.shader:Bind()\n"
				lua = lua .. "meshes["..i.."].model:Draw(meshes["..i.."].i)\n"
			end
		else
			for i = 1, self.sub_meshes_length do
				lua = lua .. "apply_material(self, meshes["..i.."].data)\n"
				lua = lua .. "render3d.shader:Bind()\n"
				lua = lua .. "meshes["..i.."].model:Draw(meshes["..i.."].i)\n"
			end
		end
		lua = lua .. "end\n"
		self.DrawModel = assert(loadstring(lua))(self, self.sub_meshes, render3d, apply_material)
	end

	if DISABLE_CULLING then
		function META:Draw()
			render3d.camera:SetWorld(self.tr:GetMatrix())
			self:DrawModel()
		end
	else
		function META:Draw(what)
			if self:IsVisible(what) then
				render3d.camera:SetWorld(self.tr:GetMatrix())

				if self.occluders[what] then
					self.occluders[what]:BeginConditional()
				end

				self:DrawModel()

				if self.occluders[what] then
					self.occluders[what]:EndConditional()
				end
			end
		end
	end

	function META:ToOBJ()
		local out = {}
		local UsedMaterials = {}
		local SubmeshCount = 0
		local Count = 0

		local function export(model)
			local vertices = model.vertex_buffer:GetVertices()

			for _, data in ipairs(model:GetSubMeshes()) do
				local indices = data.index_buffer.Indices

				for I = 0, indices:GetLength() - 1, 3 do
					Count = Count + 1
					local Index = indices[I]
					local Vertex = string.format("v %.6f %.6f %.6f\n", vertices[Index].pos[0], vertices[Index].pos[1], vertices[Index].pos[2])
					Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", vertices[Index].normal[0], vertices[Index].normal[1], vertices[Index].normal[2])
					--Make vertex coordinate Y up.
					Vertex = Vertex .. string.format("vt %.6f %.6f\n", vertices[Index].uv[0], 1.0 - vertices[Index].uv[1])
					Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

					Count = Count + 1
					Index = indices[I + 1]
					Vertex = Vertex .. string.format("v %.6f %.6f %.6f\n", vertices[Index].pos[0], vertices[Index].pos[1], vertices[Index].pos[2])
					Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", vertices[Index].normal[0], vertices[Index].normal[1], vertices[Index].normal[2])
					--Make vertex coordinate Y up.
					Vertex = Vertex .. string.format("vt %.6f %.6f\n", vertices[Index].uv[0], 1.0 - vertices[Index].uv[1])
					Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

					Count = Count + 1
					Index = indices[I + 2]
					Vertex = Vertex .. string.format("v %.6f %.6f %.6f\n", vertices[Index].pos[0], vertices[Index].pos[1], vertices[Index].pos[2])
					Vertex = Vertex .. string.format("vn %.6f %.6f %.6f\n", vertices[Index].normal[0], vertices[Index].normal[1], vertices[Index].normal[2])
					--Make vertex coordinate Y up.
					Vertex = Vertex .. string.format("vt %.6f %.6f\n", vertices[Index].uv[0], 1.0 - vertices[Index].uv[1])
					Vertex = Vertex .. string.format("vs %i %i\n", SubmeshCount, SubmeshCount)

					Vertex = Vertex .. string.format("f %i/%i/%i %i/%i/%i %i/%i/%i\n", Count - 2, Count - 2, Count - 2, Count - 1, Count - 1, Count - 1, Count, Count, Count)

					table.insert(out, Vertex)
				end
			end
		end

		for _, model in ipairs(self:GetSubModels()) do
			for _, data in ipairs(model:GetSubMeshes()) do
				local mat = data.data

				if mat.vmt then
					local MaterialNameRaw = mat.vmt.fullpath
					local MaterialName = mat.vmt.fullpath

					if MaterialName:find("materials/") then
						MaterialName = vfs.RemoveExtensionFromPath(MaterialName:sub(select(1, MaterialName:find("materials/"), #MaterialName)))
					end

					if not UsedMaterials[MaterialName] then
						SubmeshCount = SubmeshCount + 1
						UsedMaterials[MaterialName] = true

						table.insert(out, "o " .. MaterialName .. "\n")

						for _, model in ipairs(self:GetSubModels()) do
							for _, data in ipairs(model:GetSubMeshes()) do
								local mat = data.data
								if mat.vmt and mat.vmt.fullpath == MaterialNameRaw then
									export(model)
								end
							end
						end
					end
				else
					SubmeshCount = SubmeshCount + 1
					table.insert(out, "o error\n")
					export(model)
				end
			end
		end

		return table.concat(out)
	end
end

META:RegisterComponent()

if RELOAD then
	render3d.Initialize()
end