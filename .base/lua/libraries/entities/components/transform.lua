local prototype = (...) or _G.prototype

local COMPONENT = {}

COMPONENT.Name = "transform"

prototype.AddParentingTemplate(COMPONENT)

prototype.GetSet(COMPONENT, "TRMatrix", Matrix44())
prototype.GetSet(COMPONENT, "ScaleMatrix", Matrix44())

prototype.StartStorable()		
	prototype.GetSet(COMPONENT, "Position", Vec3(0, 0, 0), "InvalidateTRMatrix")
	prototype.GetSet(COMPONENT, "Angles", Ang3(0, 0, 0), "InvalidateTRMatrix")
	
	prototype.GetSet(COMPONENT, "Scale", Vec3(1, 1, 1), "InvalidateScaleMatrix")
	prototype.GetSet(COMPONENT, "Shear", Vec3(0, 0, 0), "InvalidateScaleMatrix")
	prototype.GetSet(COMPONENT, "Size", 1, "InvalidateScaleMatrix")
prototype.EndStorable()

prototype.GetSet(COMPONENT, "OverridePosition", nil, "InvalidateTRMatrix")
prototype.GetSet(COMPONENT, "OverrideAngles", nil, "InvalidateTRMatrix")
	
COMPONENT.Network = {
	Position = {"vec3", 1/30, "unreliable"},
	Angles = {"ang3", 1/30, "unreliable"},
	Scale = {"vec3", 1/15},
	Size = {"float", 1/15},
}

function COMPONENT:OnAdd(ent, parent)
	if parent and parent:HasComponent("transform") then
		self:SetParent(parent:GetComponent("transform"))
	end
end

function COMPONENT:OnRemove(ent)

end

do
	COMPONENT.temp_scale = Vec3(1, 1, 1)
	
	function COMPONENT:SetScale(vec3) 
		self.Scale = vec3
		self.temp_scale = vec3 * self.Size
		self:InvalidateScaleMatrix()
	end
			
	function COMPONENT:SetSize(num) 
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
	
	for _, child in ipairs(self:GetChildren(true)) do
		self.rebuild_tr_matrix = true
	end
end

function COMPONENT:GetTRAngles()

end

function COMPONENT:GetTRPosition()
	local x, y, z = self.TRMatrix:GetTranslation()
	return Vec3(-y, -x, -z)
end

function COMPONENT:GetTRAngles()
	local p, y, r = self.TRMatrix:GetAngles()
	
	return Ang3(p, y, r):Deg()
end

function COMPONENT:RebuildMatrix()			
	if self.rebuild_tr_matrix then				
		self.TRMatrix:Identity()

		local pos = self.Position
		local ang = self.Angles
		
		if self.OverrideAngles then
			ang = self.OverrideAngles
		end
		
		if self.OverridePosition then
			pos = self.OverridePosition
		end
		
		self.TRMatrix:Translate(-pos.y, -pos.x, -pos.z)
		
		self.TRMatrix:Rotate(-ang.y, 0, 0, 1)
		self.TRMatrix:Rotate(-ang.p + 90, 1, 0, 0)
		self.TRMatrix:Rotate(ang.r + 180, 0, 0, 1)	
		
		if self:HasParent() then
			self.temp_matrix = self.temp_matrix or Matrix44()
			
			--self.TRMatrix = self.TRMatrix * self.Parent.TRMatrix
			self.TRMatrix:Multiply(self.Parent.TRMatrix, self.temp_matrix)
			self.TRMatrix, self.temp_matrix = self.temp_matrix, self.TRMatrix
		end
		
		self.rebuild_tr_matrix = false
	end

	if self.rebuild_scale_matrix and not (self.temp_scale.x == 1 and self.temp_scale.y == 1 and self.temp_scale.z == 1) then
		self.ScaleMatrix:Identity()
		self.ScaleMatrix:Scale(self.temp_scale.x, self.temp_scale.z, self.temp_scale.y)
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
			temp:Multiply(vp_matrix, self.visible_matrix_cache[i])

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
	
	if self.temp_scale.x == 1 and self.temp_scale.y == 1 and self.temp_scale.z == 1 then
		return self.TRMatrix 
	end
	
	return self.ScaleMatrix * self.TRMatrix 
end

prototype.RegisterComponent(COMPONENT)