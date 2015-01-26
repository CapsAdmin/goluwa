local prototype = ... or _G.prototype

local META = prototype.CreateTemplate("entity")

prototype.AddParentingTemplate(META)
prototype.GetSet(META, "Components", {})

function META:AddComponent(name, ...)	
	self:RemoveComponent(name)
		
	local component = prototype.CreateComponent(name)
	
	if not component then return end
					
	for i, other in ipairs(component.Require) do
		if not self.Components[other] then
			error("component " .. name .. " requires component " .. other, 2)
		end
	end
	
	component.Entity = self
			
	for i, event_type in ipairs(component.Events) do
		component:AddEvent(event_type)
	end
	
	self.Components[name] = component
	
	component:OnAdd(self, ...)
	
	for name, component_ in pairs(self:GetComponents()) do
		component_:OnEntityAddComponent(component)
	end
	
	return component
end

function META:RemoveComponent(name)	
	if not self.Components[name] then return end
		
	local component = self.Components[name] or NULL

	if component:IsValid() then
	
		for i, event_type in ipairs(component.Events) do
			component:RemoveEvent(event_type)
		end
				
		component:OnRemove(self)
		component:Remove()
	end
end

function META:GetComponent(name)		
	return self.Components[name] or NULL
end

function META:HasComponent(name)	
	return self.Components[name] ~= nil
end

function META:OnRemove()
	event.Call("EntityRemove", self)
	
	for name, component in pairs(self:GetComponents()) do
		self:RemoveComponent(name)
	end
	
	for k,v in pairs(self:GetChildrenList()) do
		v:Remove(a)
	end
		
	-- this is important!!
	self:UnParent()
	
	event.Call("EntityRemoved")
end

do -- serializing
	function META:SetStorableTable(data, skip_remove)
		if type(data.self) ~= "table" or type(data.config) ~= "string" then return end
		
		if not skip_remove then
			for name, component in pairs(self:GetComponents()) do
				component:Remove()
			end
			
			for k,v in pairs(self:GetChildrenList()) do
				v:Remove(a)
			end
		end

		self.config = data.config
		
		for name, vars in pairs(data.self) do
			local component = self:GetComponent(name)
			
			if not component:IsValid() then
				component = self:AddComponent(name)
			end

			component:SetStorableTable(vars)
		end
		
		for i, data in ipairs(data.children) do
			local ent = entities.CreateEntity(data.config, self)
			ent:SetStorableTable(data, true)
		end
	end
	
	function META:GetStorableTable()
		local data = {self = {}, children = {}}
		
		data.config = self.config
		
		for name, component in pairs(self:GetComponents()) do
			data.self[name] = component:GetStorableTable()
		end
		
		for i, v in ipairs(self:GetChildren()) do
			data.children[i] = v:GetStorableTable()
		end
		
		return table.copy(data)
	end
end

function META:OnParent(ent)
	event.Call("EntityParent", self, ent)
end

prototype.Register(META)

prototype.component_configurations = prototype.component_configurations or {}

function prototype.SetupComponents(name, components, icon, friendly)	
	local functions = {}
	
	for _, name in ipairs(components) do
		if prototype.GetRegistered("component", name) then
			for k, v in pairs(prototype.GetRegistered("component", name)) do
				if type(v) == "function" then			
					functions[k] = function(ent, a,b,c,d)
						local obj = ent:GetComponent(name)
						return obj[k](obj, a,b,c,d)
					end
				end
			end
		end
	end
	
	prototype.component_configurations[name] = {
		name = friendly or name, 
		components = components,
		functions = functions,
		icon = icon,
	}
end

function prototype.GetConfigurations()
	return prototype.component_configurations
end

function prototype.CreateEntity(config, parent)
	local self = prototype.CreateObject(META)
	
	if parent then
		self:SetParent(parent)
	end
	
	if prototype.component_configurations[config] then
		self.config = config

		for _, name in ipairs(prototype.component_configurations[config].components) do
			self:AddComponent(name)
		end
		
		for name, func in pairs(prototype.component_configurations[config].functions) do
			self[name] = self[name] or func
		end
		
		self:SetPropertyIcon(prototype.component_configurations[config].icon)
	end
	
	event.Call("EntityCreate", self)
	
	return self
end