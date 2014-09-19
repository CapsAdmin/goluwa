include("components/*", metatable)

metatable.SetupComponents("light", {"transform", "light"})
metatable.SetupComponents("clientside", {"transform", "mesh"})
metatable.SetupComponents("physical", {"transform", "mesh", "physics"})
metatable.SetupComponents("networked", {"transform", "mesh", "physics", "networked"})

local entities = _G.entities or {}

entities.active_entities = entities.active_entities or {}

function entities.CreateEntity(name)
	local self = metatable.CreateEntity(name)
	
	entities.active_entities[self:GetId()] = self
	
	return self
end

event.AddListener("EntityRemove", "entities", function(ent)
	entities.active_entities[ent:GetId()] = nil
end)

function entities.GetAll()
	return entities.active_entities
end

function entities.Panic()
	for k,v in pairs(entities.GetAll()) do
		v:Remove()
	end
end


return entities