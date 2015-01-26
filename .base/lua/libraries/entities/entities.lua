include("components/*", prototype)

prototype.SetupComponents("group", {}, "textures/silkicons/world.png")
prototype.SetupComponents("light", {"transform", "light"}, "textures/silkicons/lightbulb.png")
prototype.SetupComponents("clientside", {"transform", "model"}, "textures/silkicons/shape_square.png")
prototype.SetupComponents("physical", {"transform", "model", "physics"}, "textures/silkicons/shape_handles.png")
prototype.SetupComponents("networked", {"transform", "model", "physics", "networked"}, "textures/silkicons/server_connect.png")
prototype.SetupComponents("world", {"world"}, "textures/silkicons/world.png")

local entities = _G.entities or {}

entities.active_entities = entities.active_entities or {}

local id = 1

function entities.CreateEntity(name, parent)
	local self = prototype.CreateEntity(name, parent or entities.world)
		
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

do -- world
	entities.world = NULL
	
	event.AddListener("GBufferInitialized", "world_parameters", function()
		if not entities.world:IsValid() then
			entities.world = entities.CreateEntity("world")
		end
	end)
end

return entities