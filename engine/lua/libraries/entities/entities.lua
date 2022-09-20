runfile("components/*", prototype)
prototype.SetupComponents("group", {}, "textures/silkicons/world.png")
prototype.SetupComponents("light", {"transform", "light", "network"}, "textures/silkicons/lightbulb.png")
prototype.SetupComponents(
	"visual",
	{"transform", "model", "network"},
	"textures/silkicons/shape_square.png"
)
prototype.SetupComponents(
	"physical",
	{"physics", "transform", "model", "network"},
	"textures/silkicons/shape_handles.png"
)
local entities = _G.entities or {}
entities.active_entities = entities.active_entities or {}
local id = 1

function entities.CreateEntity(name, parent, info)
	if parent == nil then parent = entities.GetWorld() end

	event.Call("EntityCreate", name, parent, info)
	local self = prototype.CreateEntity(name, info)

	if parent then self:SetParent(parent) end

	self.Id = id
	entities.active_entities[id] = self
	id = id + 1
	event.Call("EntityCreated", self)
	return self
end

event.AddListener("EntityRemove", "entities", function(ent)
	entities.active_entities[ent.Id] = nil
end)

function entities.GetAll()
	return entities.active_entities
end

function entities.Panic()
	for _, v in pairs(entities.GetAll()) do
		if v ~= entities.world and v ~= entities.world.sun then v:Remove() end
	end
end

function entities.SafeRemove(ent)
	if hasindex(ent) and ent.IsValid and ent.Remove and ent:IsValid() then
		ent:Remove()
	end
end

entities.world = entities.world or NULL

function entities.GetWorld()
	if not entities.world:IsValid() then
		entities.world = entities.CreateEntity("world", false)
	end

	return entities.world
end

return entities