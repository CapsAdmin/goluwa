local META = {}

META.ClassName = "model"

class.GetSet(META, "Texture", NULL)
class.GetSet(META, "TexturePath", NULL)

class.GetSet(META, "Mesh", NULL)
class.GetSet(META, "MeshPath", "")

function META:SetMeshPath(path)
	self.MeshPath = path 
	
	local str = vfs.Read("models/" .. path)
	
	utilities.ParseObj(str, function(data)
		self.Mesh = Mesh3D(data)
	end, true)
end

function META:SetTexturePath(path)
	self.TexturePath = path
	self.Texture = Image("textures/" .. path)
end

function META:Draw(...)		
	render.PushMatrix(self.Pos, self.Angles, self.Scale * self.Size)
		if self.Mesh:IsValid() then 				
			if self.Texture:IsValid() then
				self.Mesh.texture = self.Texture
			end
			
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