local prototype = ... or _G.prototype

local META = prototype.CreateTemplate("ecs_entity")

prototype.GetSet(META, "Components", {})
prototype.GetSet(META, "Id", {})

function META:AddComponent(name, id, ...)
	id = id or "no_id"
	
	self:RemoveComponent(name, id)
	
	self.Components[name] = self.Components[name] or {}
	
	local component = prototype.CreateComponent(name)
					
	for i, other in ipairs(component.Require) do
		if not self.Components[other] then
			error("component " .. name .. " requires component " .. other, 2)
		end
	end
	
	component.Id = id
	component.Entity = self
			
	for i, event_type in ipairs(component.Events) do
		component:AddEvent(event_type)
	end
	
	self.Components[name][id] = component
	
	component:OnAdd(self, ...)
end

function META:RemoveComponent(name, id)
	id = id or "no_id"
	
	if not self.Components[name] then return end
		
	local component = self.Components[name][id] or NULL

	if component:IsValid() then
	
		for i, event_type in ipairs(component.Events) do
			component:RemoveEvent(event_type)
		end
				
		component:OnRemove(self)
		component:Remove()
	end
end

function META:GetComponent(name, id)
	if not self.Components[name] then return NULL end
	
	id = id or "no_id"
	
	return self.Components[name][id] or NULL
end

function META:HasComponent(name, id)
	id = id or "no_id"
	
	return self.Components[name][id] ~= nil
end

function META:OnRemove()
	for name, components in pairs(self:GetComponents()) do
		for id, component in pairs(components) do
			self:RemoveComponent(name, id)
		end
	end
	event.Call("EntityRemove", self)
end

prototype.component_configurations = prototype.component_configurations or {}

function prototype.SetupComponents(name, components)	
	local functions = {}
	
	for _, name in ipairs(components) do
		for k, v in pairs(prototype.GetRegistered("ecs_component", name)) do
			if type(v) == "function" then			
				functions[k] = function(ent, a,b,c,d)
					local obj = ent:GetComponent(name)
					return obj[k](obj, a,b,c,d)
				end
			end
		end
	end

	prototype.component_configurations[name] = {
		components = components,
		functions = functions,
	}
end

function prototype.CreateEntity(config, ...)
	local self = prototype.CreateObject(META)
	
	if prototype.component_configurations[config] then
		self.config = config

		for _, name in ipairs(prototype.component_configurations[config].components) do
			self:AddComponent(name, nil, ...)
		end
		
		for name, func in pairs(prototype.component_configurations[config].functions) do
			self[name] = self[name] or func
		end
	end
	
	event.Call("EntityCreate", self)
	
	return self
end