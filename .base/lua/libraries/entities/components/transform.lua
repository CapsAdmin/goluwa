local META = prototype.CreateTemplate()

META.Name = "transform"

META:GetSet("TRMatrix", Matrix44())
META:GetSet("ScaleMatrix", Matrix44())

META:StartStorable()
	META:GetSet("Position", Vec3(0, 0, 0), {callback = "InvalidateTRMatrix"})
	META:GetSet("Rotation", Quat(0, 0, 0, 1), {callback = "InvalidateTRMatrix"})
	
	META:GetSet("Scale", Vec3(1, 1, 1), {callback = "InvalidateScaleMatrix"})
	META:GetSet("Shear", Vec3(0, 0, 0), {callback = "InvalidateScaleMatrix"})
	META:GetSet("Size", 1, {callback = "InvalidateScaleMatrix"})
	META:GetSet("SkipRebuild", false)
META:EndStorable()

META:GetSet("OverridePosition", nil, {callback = "InvalidateTRMatrix"})
META:GetSet("OverrideRotation", nil, {callback = "InvalidateTRMatrix"})
	
META.Network = {
	Position = {"vec3", 1/30, "unreliable"},
	Rotation = {"quat", 1/30, "unreliable"},
	Scale = {"vec3", 1/15},
	Size = {"float", 1/15},
}

function META:OnRemove(ent)

end

do	
	function META:SetScale(vec3) 
		self.temp_scale = self.temp_scale or Vec3(1, 1, 1)
		self.Scale = vec3
		self.temp_scale = vec3 * self.Size
		self:InvalidateScaleMatrix()
	end
			
	function META:SetSize(num) 
		self.temp_scale = self.temp_scale or Vec3(1, 1, 1)
		self.Size = num
		self.temp_scale = num * self.Scale
		self:InvalidateScaleMatrix()
	end
end

function META:InvalidateScaleMatrix()
	self.rebuild_scale_matrix = true
	for i,v in ipairs(self.Entity:GetChildrenList()) do
		local v = v.Components[META.Name]
		if v then
			v.rebuild_scale_matrix = true
		end
	end
end

function META:InvalidateTRMatrix()
	self.rebuild_tr_matrix = true
	for i,v in ipairs(self.Entity:GetChildrenList()) do
		local v = v.Components[META.Name]
		if v then
			v.rebuild_tr_matrix = true
		end
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

function META:SetAngles(ang)
	self.Rotation:SetAngles(ang)
	self:InvalidateTRMatrix()
end

function META:GetAngles()
	return self.Rotation:GetAngles()
end

function META:RebuildMatrix()
	self.temp_scale = self.temp_scale or Vec3(1, 1, 1)
	
	if not self.SkipRebuild and self.rebuild_tr_matrix then				
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
			
			if not parent_transform:IsValid() then
				for i, ent in ipairs(self.Entity:GetParentList()) do
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

	if self.rebuild_scale_matrix and not (self.temp_scale.x == 1 and self.temp_scale.y == 1 and self.temp_scale.z == 1) then
		self.ScaleMatrix:Identity()
		self.ScaleMatrix:Scale(self.temp_scale.y, self.temp_scale.x, self.temp_scale.z)
		--self.ScaleMatrix:Shear(self.Shear)
		
		self.rebuild_scale_matrix = false
	end
end

do
	local temp = Matrix44()

	function META:IsPointsVisible(points, view)
		view = view or render.matrices.vp_matrix
		self.visible_matrix_cache = self.visible_matrix_cache or {}
		
		temp:Identity()
		
		local matrix = self:GetMatrix()

		for i, pos in ipairs(points) do
			self.visible_matrix_cache[i] = self.visible_matrix_cache[i] or Matrix44()
			
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

function META:GetMatrix()
	self:RebuildMatrix()
	
	self.temp_scale = self.temp_scale or Vec3(1, 1, 1)
		
	if self.temp_scale.x == 1 and self.temp_scale.y == 1 and self.temp_scale.z == 1 then
		return self.TRMatrix 
	end
	
	return self.ScaleMatrix * self.TRMatrix 
end

prototype.RegisterComponent(META)