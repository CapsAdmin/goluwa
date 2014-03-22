local META = {}

META.ClassName = "model"

entities.GetSet(META, "Model", NULL)
entities.GetSet(META, "Matrix", Matrix44())

entities.StartStorableProperties()
	entities.GetSet(META, "ModelPath", "")
	entities.GetSet(META, "DrawManual", false)
entities.EndStorableProperties()

function META:SetModelPath(path, ...)
	self.ModelPath = path
	self:SetModel(Model(path, ...))
end

function META:SetPos(vec)
	self.Pos = vec
	self:InvalidateMatrix()
end

function META:SetAngles(ang)
	self.Angles = ang
	self:InvalidateMatrix()
end

function META:SetScale(v) 
	self.Scale = v 
	self.temp_scale = v * self.Size 
	self:InvalidateMatrix()
end

function META:SetSize(v) 
	self.Size = v 
	self.temp_scale = v * self.Scale 
	self:InvalidateMatrix()
end

function META:InvalidateMatrix()
	self.rebuild_matrix = true
end

function META:Draw(parent)
	if self.rebuild_matrix then
		local m = self.Matrix
		
		m:Identity()
		
		m:Translate(-self.Pos.x, -self.Pos.y, -self.Pos.z)	
		
		m:Rotate(self.Angles.p, 0, 1, 0)
		m:Rotate(-self.Angles.y, 0, 0, 1)
		m:Rotate(-self.Angles.r, 1, 0, 0)				
		
		m:Scale(self.Scale.x * self.Size, self.Scale.y * self.Size, self.Scale.z * self.Size) 
		
		self.rebuild_matrix = false
	end
						
	if self.Model:IsValid() then
		render.matrices.world = self.Matrix
		self.Model:Draw()
	end
	
	for _, ent in ipairs(self:GetChildren()) do
		if ent.Draw and not ent.DrawManual then
			ent:Draw(self)
		end
	end
end   

entities.Register(META)