entities = entities or {}

entities.active_entities = entities.active_entities or {}
entities.is_keys = entities.is_keys or {}

function entities.GetAll()
	return entities.active_entities
end

function entities.GetAllByClass(class)
	local out = {}
	
	for key, ent in pairs(entities.active_entities) do
		if ent.ClassName == class then
			table.insert(out, ent)
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

class.SetupLib(entities, "entity")

function entities.Register(META, name)
	META.TypeBase = "base"
	local _, name = class.Register(META, "entity", name)
	
	entities.is_keys["Is"..name:gsub("^.", function(s) return s:upper() end)] = name
end
	

_G.Entity = entities.Create

do -- base
	local META = {}
	
	META.ClassName = "base"	
		
	class.GetSet(META, "Pos", Vec3(0,0,0))
	class.GetSet(META, "Angles", Ang3(0,0,0))
	class.GetSet(META, "Scale", Vec3(1,1,1))
	class.GetSet(META, "Size", 1)
	class.GetSet(META, "ID", 0)
	
	class.SetupParentingSystem(META)

	function META:__init()
		if entities.world_entity then
			entities.world_entity:AddChild(self)
		end
		self.ID = table.insert(entities.active_entities, self)
	end
		
	function META:__index(key)
		if entities.is_keys[key] then
			return function() return entities.is_keys[key] == self.ClassName end
		end
	end
	
	function META:IsValid() return true end
	
	function META:Remove()
		if self.remove_me then return end
	
		self:OnRemove()
		self:RemoveChildren()
		table.remove(entities.active_entities, self.ID)
		
		self.remove_me = true
		timer.Simple(0, function()
			utilities.MakeNULL(self)
		end)
	end
	
	function META:Create(class_name)
		local ent = Entity(class_name)
		ent:SetParent(self)
		return ent
	end
	
	local not_implemented = function() end
	META.OnRemove = not_implemented
		
	entities.Register(META)
end 
 
function entities.LoadAllEntities()
	for relative_path, full_path in vfs.Iterate("lua/platforms/glw/libraries/entities/default_entities/") do
		vfs.dofile(full_path)
	end
	
	for relative_path, full_path in vfs.Iterate("lua/entities/") do
		vfs.dofile(full_path)
	end
	
	entities.world_entity = entities.world_entity or Entity("model")
end