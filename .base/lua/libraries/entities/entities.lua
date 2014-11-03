include("components/*", prototype)

prototype.SetupComponents("light", {"transform", "light"}, "textures/silkicons/lightbulb.png")
prototype.SetupComponents("clientside", {"transform", "mesh"}, "textures/silkicons/shape_square.png")
prototype.SetupComponents("physical", {"transform", "mesh", "physics"}, "textures/silkicons/shape_handles.png")
prototype.SetupComponents("networked", {"transform", "mesh", "physics", "networked"}, "textures/silkicons/server_connect.png")

local entities = _G.entities or {}

entities.active_entities = entities.active_entities or {}

local id = 1

function entities.CreateEntity(name, ...)
	local self = prototype.CreateEntity(name, ...)
		
	self.Id = id
		
	entities.active_entities[id] = self
	
	id = id + 1
	
	return self
end

event.AddListener("EntityRemove", "entities", function(ent)
	entities.active_entities[ent.Id] = nil
end)

function entities.GetAll()
	return entities.active_entities
end

function entities.Panic()
	for k,v in pairs(entities.GetAll()) do
		v:Remove()
	end
end

function entities.SafeRemove(ent)
	if hasindex(ent) and ent.IsValid and ent.Remove and ent:IsValid() then
		ent:Remove()
	end
end

return entities