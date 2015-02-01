local COMPONENT = {}

COMPONENT.Name = "transform"

prototype.GetSet(COMPONENT, "TRMatrix", Matrix44())
prototype.GetSet(COMPONENT, "ScaleMatrix", Matrix44())

prototype.StartStorable(COMPONENT)	
	prototype.GetSet("Position", Vec3(0, 0, 0), {callback = "InvalidateTRMatrix"})
	prototype.GetSet("Rotation", Quat(0, 0, 0, 1), {callback = "InvalidateTRMatrix"})
	
	prototype.GetSet("Scale", Vec3(1, 1, 1), {callback = "InvalidateScaleMatrix"})
	prototype.GetSet("Shear", Vec3(0, 0, 0), {callback = "InvalidateScaleMatrix"})
	prototype.GetSet("Size", 1, {callback = "InvalidateScaleMatrix"})
	prototype.GetSet("SkipRebuild", false)
prototype.EndStorable()

prototype.GetSet(COMPONENT, "OverridePosition", nil, {callback = "InvalidateTRMatrix"})
prototype.GetSet(COMPONENT, "OverrideRotation", nil, {callback = "InvalidateTRMatrix"})
	
COMPONENT.Network = {
	Position = {"vec3", 1/30, "unreliable"},
	Rotation = {"quat", 1/30, "unreliable"},
	Scale = {"vec3", 1/15},
	Size = {"float", 1/15},
}

function COMPONENT:OnRemove(ent)

end

do	
	function COMPONENT:SetScale(vec3) 
		self.temp_scale = self.temp_scale or Vec3(1, 1, 1)
		self.Scale = vec3
		self.temp_scale = vec3 * self.Size
		self:InvalidateScaleMatrix()
	end
			
	function COMPONENT:SetSize(num) 
		self.temp_scale = self.temp_scale or Vec3(1, 1, 1)
		self.Size = num
		self.temp_scale = num * self.Scale
		self:InvalidateScaleMatrix()
	end
end

function COMPONENT:InvalidateScaleMatrix()
	self.rebuild_scale_matrix = true
end

function COMPONENT:InvalidateTRMatrix()
	self.rebuild_tr_matrix = true
end

function COMPONENT:GetTRPosition()
	local x, y, z = self.TRMatrix:GetTranslation()
	return Vec3(-y, -x, -z)
end

function COMPONENT:SetTRPosition(vec)
	self.TRMatrix:SetTranslation(vec.x, vec.y, vec.z)
end

function COMPONENT:GetTRAngles()	
	return self.TRMatrix:GetRotation():GetAngles()
end

function COMPONENT:SetTRAngles(ang)
	self.TRMatrix:SetRotation(Quat():SetAngles(ang))
end

function COMPONENT:GetTRRotation()
	return self.TRMatrix:GetRotation()
end

function COMPONENT:SetTRRotation(quat)
	self.TRMatrix:SetRotation(quat)
end

function COMPONENT:SetAngles(ang)
	self.Rotation:SetAngles(ang)
	self:InvalidateTRMatrix()
end

function COMPONENT:GetAngles()
	return self.Rotation:GetAngles()
end

function COMPONENT:RebuildMatrix()
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
			
			-- todo, skip to a higher parent?
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

	function COMPONENT:IsPointsVisible(points, view)
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

function COMPONENT:GetMatrix()
	self:RebuildMatrix()
	
	self.temp_scale = self.temp_scale or Vec3(1, 1, 1)
		
	if self.temp_scale.x == 1 and self.temp_scale.y == 1 and self.temp_scale.z == 1 then
		return self.TRMatrix 
	end
	
	return self.ScaleMatrix * self.TRMatrix 
end

prototype.RegisterComponent(COMPONENT)