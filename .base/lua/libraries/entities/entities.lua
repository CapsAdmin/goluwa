local entities = _G.entities or {}

entities.active_entities = entities.active_entities or {}
entities.is_keys = entities.is_keys or {}

function entities.Initialize()
	event.AddListener("Draw3D", "world_draw", function(dt)
		entities.world_entity:Draw()			
	end)
end

function entities.Shutdown()
	entities.world_entity:RemoveChildren()
	event.RemoveListener("Draw3D", "world_draw")
end

function entities.GetAll()
	return entities.active_entities
end

function entities.GetAllByClass(class)
	local out = {}
	
	for key, ent in pairs(entities.active_entities) do
		if ent.ClassName == class then
			out[#out+1] = ent
		end
	end
	
	return out
end

function entities.Call(name, ...)
	for key, ent in pairs(entities.active_entities) do
		if ent[name] then
			ent[name](ent, ...) 
		end
	end	
end

entities.remove_these = entities.remove_these or {}

class.SetupLib(entities, "entity")
class.SetupSerializing(entities)

function entities.Register(META, name)
	META.TypeBase = "base"
	local _, name = class.Register(META, "entity", name)
	
	entities.is_keys["Is"..name:gsub("^.", function(s) return s:upper() end)] = name
	
	-- update entity functions only
	-- updating variables might mess things up
	for key, ent in pairs(entities.GetAllByClass(name)) do
		for k, v in pairs(META) do
			if type(v) == "function" then
				ent[k] = v
			end
		end
	end	
end

include("base_entity.lua", entities)
 
function entities.LoadAllEntities()
	for relative_path, full_path in vfs.Iterate("lua/libraries/entities/default_entities/") do
		vfs.dofile(full_path, entities)
	end
	
	for relative_path, full_path in vfs.Iterate("lua/entities/") do
		vfs.dofile(full_path, entities)
	end
	
	entities.world_entity = entities.world_entity or Entity("model")
	
	event.CreateTimer("entity_gc", 0.1, 0, function()
		for k, v in pairs(entities.remove_these) do
			v:Remove(true)
			entities.remove_these[k] = nil
		end
	end)
end

_G.Entity = entities.Create

return entities