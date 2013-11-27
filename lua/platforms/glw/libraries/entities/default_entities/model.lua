local META = {}

META.ClassName = "model"

class.GetSet(META, "Model", NULL)
class.GetSet(META, "ModelPath", "")
class.GetSet(META, "DrawManual", false)

function META:SetModelPath(path, ...)
	self.ModelPath = path
	self:SetModel(Model(path, ...))
end

function META:SetScale(v) self.Scale = v self.temp_scale = v * self.Size end
function META:SetSize(v) self.Size = v self.temp_scale = v * self.Scale end

function META:Draw()
	render.PushMatrix(self.Pos, self.Angles, self.temp_scale)
							
		if self.Model:IsValid() then		
			self.Model:Draw()
		end
		
		for _, ent in pairs(self.Children) do
			if ent.Draw and not ent.DrawManual then
				ent:Draw()
			end
		end
	render.PopMatrix()
end   

entities.Register(META)