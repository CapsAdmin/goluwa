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
		
	entities.Register(META)
end 
 
function entities.LoadAllEntities()
	for relative_path, full_path in vfs.Iterate("lua/platforms/glw/libraries/entities/") do
		vfs.dofile(full_path)
	end
	
	for relative_path, full_path in vfs.Iterate("lua/entities/") do
		vfs.dofile(full_path)
	end
	
	entities.world_entity = entities.world_entity or Entity("model")
end

return entities