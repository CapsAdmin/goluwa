local META = {}

META.ClassName = "model"

class.GetSet(META, "Obj", "")
class.GetSet(META, "Mesh")
class.GetSet(META, "Texture")

META.tex = NULL

function META:SetObj(path)
	self.Obj = path 
	
	local str = vfs.Read("models/" .. path)
	
	utilities.ParseObj(str, function(data)
		self.Mesh = Mesh(data)
	end, true)
end

function META:SetTexture(path)
	self.tex = Image("textures/" .. path)
	self.Texture = path 
end

function META:Draw(...)	
	
	if self.tex:IsValid() then
		self.tex:Bind()
	end
	
	render.PushMatrix(self.Pos, self.Angles, self.Scale * self.Size)
		if self.Mesh then 
			self.Mesh:Draw(...)
		end
		
		for _, ent in pairs(self.Children) do
			if ent.Draw then
				ent:Draw(...)
			end
		end
	render.PopMatrix()
end   

entities.Register(META)