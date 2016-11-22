local META = prototype.CreateTemplate()

META.Name = "transform"

META:GetSet("TRMatrix", Matrix44())
META:GetSet("ScaleMatrix", Matrix44())

META:StartStorable()
	META:GetSet("Position", Vec3(0, 0, 0), {callback = "InvalidateTRMatrix"})
	META:GetSet("Rotation", Quat(0, 0, 0, 1), {callback = "InvalidateTRMatrix"})

	META:GetSet("Scale", Vec3(1, 1, 1), {callback = "InvalidateScaleMatrix"})
	--META:GetSet("Shear", Vec3(0, 0, 0), {callback = "InvalidateScaleMatrix"})
	META:GetSet("Size", 1, {callback = "InvalidateScaleMatrix"})

	META:GetSet("SkipRebuild", false)
META:EndStorable()

META:GetSet("OverridePosition", nil, {callback = "InvalidateTRMatrix"})
META:GetSet("OverrideRotation", nil, {callback = "InvalidateTRMatrix"})
META:GetSet("AABB", AABB(-1,-1,-1, 1,1,1), {callback = "InvalidateTRMatrix"})

META.Network = {
	Position = {"vec3", 1/30, "unreliable"},
	Rotation = {"quat", 1/30, "unreliable"},
	Scale = {"vec3", 1/15},
	Size = {"float", 1/15},
}

function META:Initialize()
	self.temp_scale = Vec3(1, 1, 1)
	self.visible_matrix_cache = {}
	for i = 1, 8 do
		self.visible_matrix_cache[i] = Matrix44()
	end
end

function META:GetTRPosition()
	local x, y, z = self.TRMatrix:GetTranslation()
	return Vec3(-y, -x, -z)
end

function META:SetTRPosition(vec)
	self.TRMatrix:SetTranslation(vec.x, vec.y, vec.z)
end

function META:GetTRAngles()
	return self.TRMatrix:GetRotation():GetAngles()
end

function META:SetTRAngles(ang)
	self.TRMatrix:SetRotation(Quat():SetAngles(ang))
end

function META:GetTRRotation()
	return self.TRMatrix:GetRotation()
end

function META:SetTRRotation(quat)
	self.TRMatrix:SetRotation(quat)
end

function META:GetAngles()
	return self.Rotation:GetAngles()
end

function META:SetAngles(ang)
	self.Rotation:SetAngles(ang)
	self:InvalidateTRMatrix()
end

function META:GetTranslatedAABB()
	return self.translated_aabb
end

function META:GetBoundingSphere()
	return self.bounding_sphere
end

function META:GetCameraDistance()
	local cam = camera.camera_3d:GetPosition()

	local ex,ey,ez = self.TRMatrix.m30, self.TRMatrix.m31, self.TRMatrix.m32
	local cx,cy,cz = -cam.y, -cam.x, -cam.z

	local x = ex-cx
	local y = ey-cy
	local z = ez-cz

	return x * x + y * y + z * z
end

function META:OnAdd()
	self:InvalidateTRMatrix()
	self:RebuildMatrix()
end

function META:GetMatrix()
	self:RebuildMatrix()

	return self.FinalMatrix
end

function META:SetScale(vec3)
	self.Scale = vec3
	self.temp_scale = vec3 * self.Size
	self:InvalidateScaleMatrix()
end

function META:SetSize(num)
	self.Size = num
	self.temp_scale = num * self.Scale
	self:InvalidateScaleMatrix()
end

function META:InvalidateScaleMatrix()
	if not self.rebuild_tr_matrix then
		for _, v in ipairs(self.Entity:GetChildrenList()) do
			local v = v.Components[META.Name]
			if v then
				v.rebuild_scale_matrix = true
				v.rebuild_tr_matrix = true
			end
		end
	end
	self.rebuild_scale_matrix = true
	self.rebuild_tr_matrix = true
end

function META:InvalidateTRMatrix()
	if not self.rebuild_tr_matrix then
		for _, v in ipairs(self.Entity:GetChildrenList()) do
			if v.Components[META.Name] then
				v.Components[META.Name].rebuild_tr_matrix = true
			end
		end
	end
	self.rebuild_tr_matrix = true
end

function META:RebuildMatrix()
	if self.rebuild_scale_matrix and (self.temp_scale.x ~= 1 or self.temp_scale.y ~= 1 or self.temp_scale.z ~= 1) then
		self.ScaleMatrix:Identity()
		self.ScaleMatrix:Scale(self.temp_scale.y, self.temp_scale.x, self.temp_scale.z)
		--self.ScaleMatrix:Shear(self.Shear)
	end

	if self.rebuild_tr_matrix and not self.SkipRebuild then
		local pos = self.Position
		local rot = self.Rotation

		if self.OverrideRotation then
			rot = self.OverrideRotation
		end

		if self.OverridePosition then
			pos = self.OverridePosition
		end

		self.TRMatrix:Identity()
		self.TRMatrix:SetTranslation(-pos.y, -pos.x, -pos.z)
		self.TRMatrix:SetRotation(rot)

		if self.Entity:HasParent() then
			local parent_transform = self.Entity.Parent:GetComponent("transform")

			if not parent_transform then
				for _, ent in ipairs(self.Entity:GetParentList()) do
					parent_transform = ent:GetComponent("transform")
					if parent_transform then
						break
					end
				end
			end

			if parent_transform then
			--	self.temp_matrix = self.temp_matrix or Matrix44()
				self.TRMatrix = self.TRMatrix * parent_transform.TRMatrix
				--parent_transform.TRMatrix:Multiply(self.TRMatrix, self.temp_matrix)
				--self.TRMatrix, self.temp_matrix = self.temp_matrix, self.TRMatrix
			end
		end
	end

	if self.rebuild_tr_matrix or self.rebuild_scale_matrix then
		local aabb = self:GetAABB():Copy()
		local x,y,z = self.TRMatrix:GetTranslation()

		aabb:SetMax(aabb:GetMax() * self.temp_scale * 3)
		aabb:SetMin(aabb:GetMin() * self.temp_scale * 3) -- todo: proper rotation

		aabb.min_x = aabb.min_x + x
		aabb.min_y = aabb.min_y + y
		aabb.min_z = aabb.min_z + z

		aabb.max_x = aabb.max_x + x
		aabb.max_y = aabb.max_y + y
		aabb.max_z = aabb.max_z + z
		self.translated_aabb = aabb

		self.bounding_sphere = aabb:GetMin():Distance(aabb:GetMax())

		if self.temp_scale.x ~= 1 or self.temp_scale.y ~= 1 or self.temp_scale.z ~= 1 then
			self.FinalMatrix = self.TRMatrix * self.ScaleMatrix
		else
			self.FinalMatrix = self.TRMatrix
		end
	end

	self.rebuild_tr_matrix = false
	self.rebuild_scale_matrix = false
end

function META:IsPointsVisible(points, view)
	view = view or render.GetProjectionViewMatrix()

	local matrix = self:GetMatrix()

	for _, pos in ipairs(points) do
		local x, y, z = view:GetMultiplied(matrix, Matrix44(pos.x, pos.y, pos.z)):GetClipCoordinates()

		if
			(x > -1 and x < 1) and
			(y > -1 and y < 1) and
			(z > -1 and z < 1)
		then
			return true
		end
	end

	return false
end

prototype.RegisterComponent(META)

if RELOAD then
	for _, tr in ipairs(prototype.GetCreated(true, "component", META.Name)) do
		tr:InvalidateTRMatrix()
		tr:InvalidateScaleMatrix()
	end
end