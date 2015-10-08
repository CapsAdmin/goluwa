local TMPL = prototype.CreateTemplate()

TMPL.Name = "transform"

TMPL:GetSet("TRMatrix", Matrix44())
TMPL:GetSet("ScaleMatrix", Matrix44())

TMPL:StartStorable()
	TMPL:GetSet("Position", Vec3(0, 0, 0), {callback = "InvalidateTRMatrix"})
	TMPL:GetSet("Rotation", Quat(0, 0, 0, 1), {callback = "InvalidateTRMatrix"})

	TMPL:GetSet("Scale", Vec3(1, 1, 1), {callback = "InvalidateScaleMatrix"})
	TMPL:GetSet("Shear", Vec3(0, 0, 0), {callback = "InvalidateScaleMatrix"})
	TMPL:GetSet("Size", 1, {callback = "InvalidateScaleMatrix"})
	TMPL:GetSet("SkipRebuild", false)
TMPL:EndStorable()

TMPL:GetSet("OverridePosition", nil, {callback = "InvalidateTRMatrix"})
TMPL:GetSet("OverrideRotation", nil, {callback = "InvalidateTRMatrix"})

TMPL.Network = {
	Position = {"vec3", 1/30, "unreliable"},
	Rotation = {"quat", 1/30, "unreliable"},
	Scale = {"vec3", 1/15},
	Size = {"float", 1/15},
}

function TMPL:Initialize()
	self.temp_scale = Vec3(1, 1, 1)
	self.visible_matrix_cache = {}
	for i = 1, 8 do
		self.visible_matrix_cache[i] = Matrix44()
	end
end

function TMPL:GetTRPosition()
	local x, y, z = self.TRMatrix:GetTranslation()
	return Vec3(-y, -x, -z)
end

function TMPL:SetTRPosition(vec)
	self.TRMatrix:SetTranslation(vec.x, vec.y, vec.z)
end

function TMPL:GetTRAngles()
	return self.TRMatrix:GetRotation():GetAngles()
end

function TMPL:SetTRAngles(ang)
	self.TRMatrix:SetRotation(Quat():SetAngles(ang))
end

function TMPL:GetTRRotation()
	return self.TRMatrix:GetRotation()
end

function TMPL:SetTRRotation(quat)
	self.TRMatrix:SetRotation(quat)
end

function TMPL:GetAngles()
	return self.Rotation:GetAngles()
end

function TMPL:SetAngles(ang)
	self.Rotation:SetAngles(ang)
	self:InvalidateTRMatrix()
end

function TMPL:GetMatrix()
	self:RebuildMatrix()

	return self.TRMatrix
end

function TMPL:SetScale(vec3)
	self.Scale = vec3
	self.temp_scale = vec3 * self.Size
	self:InvalidateScaleMatrix()
end

function TMPL:SetSize(num)
	self.Size = num
	self.temp_scale = num * self.Scale
	self:InvalidateScaleMatrix()
end

function TMPL:InvalidateScaleMatrix()
	if not self.rebuild_tr_matrix then
		for _, v in ipairs(self.Entity:GetChildrenList()) do
			local v = v.Components[TMPL.Name]
			if v then
				v.rebuild_scale_matrix = true
				v.rebuild_tr_matrix = true
			end
		end
	end
	self.rebuild_scale_matrix = true
	self.rebuild_tr_matrix = true
end

function TMPL:InvalidateTRMatrix()
	if not self.rebuild_tr_matrix then
		for _, v in ipairs(self.Entity:GetChildrenList()) do
			local v = v.Components[TMPL.Name]
			if v then
				v.rebuild_tr_matrix = true
			end
		end
	end
	self.rebuild_tr_matrix = true
end

function TMPL:RebuildMatrix()
	if self.rebuild_scale_matrix and (self.temp_scale.x ~= 1 or self.temp_scale.y ~= 1 or self.temp_scale.z ~= 1) then
		self.ScaleMatrix:Identity()
		self.ScaleMatrix:Scale(self.temp_scale.y, self.temp_scale.x, self.temp_scale.z)
		--self.ScaleMatrix:Shear(self.Shear)
		self.rebuild_scale_matrix = false
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

		if self.temp_scale.x ~= 1 or self.temp_scale.y ~= 1 or self.temp_scale.z ~= 1 then
			self.TRMatrix = self.ScaleMatrix * self.TRMatrix
		end

		if self.Entity:HasParent() then
			local parent_transform = self.Entity.Parent:GetComponent("transform")

			if not parent_transform:IsValid() then
				for _, ent in ipairs(self.Entity:GetParentList()) do
					parent_transform = ent:GetComponent("transform")
					if parent_transform:IsValid() then
						break
					end
				end
			end

			if parent_transform:IsValid() then
				self.temp_matrix = self.temp_matrix or Matrix44()
				--self.TRMatrix = self.TRMatrix * self.Parent.TRMatrix
				self.TRMatrix:Multiply(parent_transform.TRMatrix, self.temp_matrix)
				self.TRMatrix, self.temp_matrix = self.temp_matrix, self.TRMatrix
			end
		end

		self.rebuild_tr_matrix = false
	end
end

do
	local temp = Matrix44()

	function TMPL:IsPointsVisible(points, view)
		view = view or render.GetProjectionViewMatrix()

		temp:Identity()

		local matrix = self:GetMatrix()

		for i, pos in ipairs(points) do
			self.visible_matrix_cache[i]:Identity()
			self.visible_matrix_cache[i]:Translate(pos.x, pos.y, pos.z)

			self.visible_matrix_cache[i]:Multiply(matrix, temp)
			temp:Multiply(view, self.visible_matrix_cache[i])

			local x, y, z = self.visible_matrix_cache[i]:GetClipCoordinates()

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
end

prototype.RegisterComponent(TMPL)