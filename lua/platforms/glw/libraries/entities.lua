local entities = _G.entities or {}

entities.active_entities = entities.active_entities or {}

function entities.Call(name, ...)
	for key, ent in pairs(entities.active_entities) do
		if ent[name] then
			ent[name](ent, ...) 
		end
	end	
end

class.SetupLib(entities, "entity")

_G.Entity = entities.Create

do -- base
	local META = {}
	
	META.ClassName = "base"
	
	class.SetupParentingSystem(META)
	
	function META:__init()
		if entities.world_entity then
			entities.world_entity:AddChild(self)
		end
		self.pool_id = table.insert(entities.active_entities, self)
	end
	
	function META:Remove()
		self:RemoveChildren()
		table.remove(entities.active_entities, self.pool_id)
		utilities.MakeNULL(self)
	end
	
	class.GetSet(META, "Pos", Vec3(0,0,0))
	class.GetSet(META, "Angles", Ang3(0,0,0))
	class.GetSet(META, "Scale", Vec3(1,1,1))
	class.GetSet(META, "Size", 1)
	
	do -- model
		class.GetSet(META, "Obj", "")
		class.GetSet(META, "Mesh")
		class.GetSet(META, "Texture")

		function META:SetObj(path)
			self.Obj = path 
			
			local str = vfs.Read("models/" .. path)
			
			utilities.ParseObj(str, function(data)
				self.Mesh = Mesh(data)
			end, true)
		end
		
		function META:SetTexture(path)
			self.tex = render.CreateTexture("textures/" .. path)
			self.Texture = path 
		end
		
		function META:DrawModel()
			
			if self.tex then
				render.SetTexture(self.tex)
			end
			
			render.PushMatrix(self.Pos, self.Angles, self.Scale * self.Size)
				if self.Mesh then 
					self.Mesh:Draw()
				end
				
				for _, ent in pairs(self.Children) do
					ent:DrawModel()
				end
			render.PopMatrix()
		end     
	end
		
	entities.Register(META)
end

entities.world_entity = entities.world_entity or Entity("base")

return entities