local entities = _G.entities or {}

entities.active_entities = entities.active_entities or {}
entities.configurations = entities.configurations or {}
entities.active_components = entities.active_components or {}

function entities.Panic()
	for k,v in pairs(entities.active_entities) do
		if v:IsValid() then
			v:Remove()
		end
	end

	entities.active_entities = {}
end

entities.Panic()

function entities.GetAll()
	return entities.active_entities
end

function entities.SetupComponents(name, components)
	
	local functions = {}
	
	for _, name in ipairs(components) do
		for k, v in pairs(entities.GetComponent(name)) do
			if type(v) == "function" then			
				functions[k] = function(ent, a,b,c,d)
					local obj = ent:GetComponent(name)
					return obj[k](obj, a,b,c,d)
				end
			end
		end
	end

	entities.configurations[name] = {
		components = components,
		functions = functions,
	}
end

do -- base entity
	local ENTITY = metatable.CreateTemplate("ecs_base")

	metatable.GetSet(ENTITY, "Components", {})

	function ENTITY:AddComponent(name, id, ...)
		id = id or "no_id"
		
		self:RemoveComponent(name, id)
		
		self.Components[name] = self.Components[name] or {}
		
		local obj = entities.CreateComponent(name)
				
		for i, other in ipairs(obj.Require) do
			if not self.Components[other] then
				error("component " .. name .. " requires component " .. other, 2)
			end
		end
		
		obj.Id = id
		obj.Entity = self
				
		for i, event_type in ipairs(obj.Events) do
			obj:AddEvent(event_type)
		end
		
		self.Components[name][id] = obj
		
		obj:OnAdd(self, ...)
	end

	function ENTITY:RemoveComponent(name, id)
		id = id or "no_id"
		
		if not self.Components[name] then return end
			
		local obj = self.Components[name][id] or NULL

		if obj:IsValid() then
		
			for i, event_type in ipairs(obj.Events) do
				obj:RemoveEvent(event_type)
			end
					
			for i, component in ipairs(entities.active_components) do
				if component == obj then
					entities.active_components[i] = nil
					break
				end
			end
			
			obj:OnRemove(self)
			obj:Remove()
			
			table.fixindices(entities.active_components)
		end
	end

	function ENTITY:GetComponent(name, id)
		if not self.Components[name] then return NULL end
		
		id = id or "no_id"
		
		return self.Components[name][id] or NULL
	end
	
	function ENTITY:HasComponent(name, id)
		id = id or "no_id"
		
		return self.Components[name][id] ~= nil
	end
	
	function ENTITY:OnRemove()
		for name, components in pairs(self:GetComponents()) do
			for id, obj in pairs(components) do
				self:RemoveComponent(name, id)
			end
		end
		for i, ent in ipairs(entities.active_entities) do
			if ent == self then
				entities.active_entities[i] = nil
				break
			end
		end
		table.fixindices(entities.active_entities)
	end
	
	function entities.CreateEntity(config, ...)
		local ent = ENTITY:New()
		
		table.insert(entities.active_entities, ent)
		
		if entities.configurations[config] then
			ent.config = config

			for _, name in ipairs(entities.configurations[config].components) do
				ent:AddComponent(name, nil, ...)
			end
			
			for name, func in pairs(entities.configurations[config].functions) do
				ent[name] = ent[name] or func
			end
		end
		
		return ent
	end
end

do -- base component
	local BASE = {}
	
	BASE.Require = {}
	BASE.Events = {}
	
	metatable.GetSet(BASE, "Id")
	metatable.Delegate(BASE, "Entity", "GetComponent")
	metatable.Delegate(BASE, "Entity", "AddComponent")
	metatable.Delegate(BASE, "Entity", "RemoveComponent")
	metatable.GetSet(BASE, "Entity", NULL)
	
	function BASE:OnAdd()
	
	end
		
	function BASE:OnRemove()
	
	end
	
	function BASE:OnEvent(component, name, ...)
	
	end
	
	function BASE:GetEntityComponents()
		local out = {}
		
		for name, components in pairs(self:GetEntity():GetComponents()) do
			for id, component in pairs(components) do
				table.insert(out, component)
			end
		end
		
		return out
	end
	
	function BASE:FireEvent(...)
		for i, component in ipairs(self:GetEntityComponents()) do
			component:OnEvent(self, component.Name, ...)
		end
	end
	
	local events = {}
	local ref_count = {}
	
	function BASE:AddEvent(event_type)
		ref_count[event_type] = (ref_count[event_type] or 0) + 1
		
		local func_name = "On" .. event_type
		
		events[event_type] = events[event_type] or {}		
		table.insert(events[event_type], self)
		
		event.AddListener(event_type, "entities", function(a_, b_, c_) 
			for name, self in ipairs(events[event_type]) do
				if self[func_name] then
					self[func_name](self, a_, b_, c_)
				end
			end
		end)
	end
	
	function BASE:RemoveEvent(event_type)
		ref_count[event_type] = (ref_count[event_type] or 0) - 1
	
		events[event_type] = events[event_type] or {}
		
		for i, other in pairs(events[event_type]) do
			if other == self then
				events[event_type][i] = nil
				break
			end
		end
		
		table.fixindices(events[event_type])

		for i, self in ipairs(events[event_type]) do
			self[func_name](self)
		end
		
		if ref_count[event_type] <= 0 then
			event.RemoveListener(event_type, "entities")
		end
	end
	
	entities.components = {}

	function entities.RegisterComponent(COMPONENT)
		
		for k, v in pairs(BASE) do
			COMPONENT[k] = COMPONENT[k] or v
		end
		
		local template = metatable.CreateTemplate(COMPONENT.Name, true)
		
		for k,v in pairs(COMPONENT) do
			template[k] = v
		end
		
		for i, component in ipairs(entities.active_components) do
			for k, v in pairs(template) do
				if type(v) == "function" then
					component[k] = v
				end
			end
			component:OnRemove(component:GetEntity())
			component:OnAdd(component:GetEntity())
		end
		
		entities.components[COMPONENT.Name:lower()] = template
	end

	function entities.GetComponent(name)
		name = name:lower()
		-- get a copy so vectors and such wont be shared between multiple components
		return entities.components[name]
	end

	function entities.CreateComponent(name)
		local obj = entities.GetComponent(name):New()
		
		table.insert(entities.active_components, obj)
		
		return obj
	end
end

include("components/*", entities)

entities.SetupComponents("light", {"transform", "light"})
entities.SetupComponents("clientside", {"transform", "mesh"})
entities.SetupComponents("physical", {"transform", "mesh", "physics"})
entities.SetupComponents("networked", {"transform", "mesh", "physics", "networked"})

return entities