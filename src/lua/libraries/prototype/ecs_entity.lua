local prototype = ... or _G.prototype

local META = prototype.CreateTemplate("entity")

function META:__tostring2()
	return ("[%s][%s]"):format(self.config, self:GetName())
end

include("lua/libraries/templates/parenting.lua", META)
META:GetSet("Components", {})

local DEFER_COMPONENT_CHECKS_AND_EVENTS

function META:AddComponent(name, ...)
	self:RemoveComponent(name)

	local component = prototype.CreateComponent(name)

	if not component then return end

	if not DEFER_COMPONENT_CHECKS_AND_EVENTS then
		for _, other in ipairs(component.Require) do
			if not self.Components[other] then
				error("component " .. name .. " requires component " .. other, 2)
			end
		end
	end

	component.Entity = self

	for _, event_type in ipairs(component.Events) do
		component:AddEvent(event_type)
	end

	self.Components[name] = component
	self[name] = component

	if not DEFER_COMPONENT_CHECKS_AND_EVENTS then
		component:OnAdd(self, ...)

		for _, component_ in pairs(self:GetComponents()) do
			component_:OnEntityAddComponent(component)
		end
	end

	return component
end

function META:RemoveComponent(name)
	if not self.Components[name] then return end

	local component = self.Components[name] or NULL

	if component:IsValid() then

		for _, event_type in ipairs(component.Events) do
			component:RemoveEvent(event_type)
		end

		component:OnRemove(self)
		component:Remove()
	end

	self.Components[name] = nil
	self[name] = nil
end

function META:GetComponent(name)
	return self.Components[name] or NULL
end

function META:HasComponent(name)
	return self.Components[name] ~= nil
end

function META:OnRemove()
	if self.removed then return end
	event.Call("EntityRemove", self)

	for name in pairs(self:GetComponents()) do
		self:RemoveComponent(name)
	end

	for _, v in pairs(self:GetChildrenList()) do
		v:Remove()
	end

	-- this is important!!
	self:UnParent()

	event.Call("EntityRemoved")
	self.removed = true
end

do -- serializing
	function META:SetStorableTable(data, skip_remove)
		prototype.base_metatable.SetStorableTable(self, data.self)

		if type(data.self) ~= "table" or type(data.config) ~= "string" then return end

		if not skip_remove then
			for _, v in pairs(self:GetChildrenList()) do
				if not v.HideFromEditor then
					v:Remove()
				end
			end
		end

		self.config = data.config

		for name, vars in pairs(data.components) do
			local component = self:GetComponent(name)

			if not component:IsValid() then
				component = self:AddComponent(name)
			end

			component:SetStorableTable(vars)
		end

		for _, data in ipairs(data.children) do
			local ent = entities.CreateEntity(data.config, self)
			ent:SetStorableTable(data, true)
		end
	end

	function META:GetStorableTable()
		local data = {self = prototype.base_metatable.GetStorableTable(self), children = {}, components = {}}

		data.config = self.config

		for name, component in pairs(self:GetComponents()) do
			data.components[name] = component:GetStorableTable()
		end

		for _, v in ipairs(self:GetChildren()) do
			if not v:GetHideFromEditor() then
				table.insert(data.children, v:GetStorableTable())
			end
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
					table.insert(functions, {
						func = function(ent, a,b,c,d)
							local obj = ent:GetComponent(name)
							return obj[k](obj, a,b,c,d)
						end,
						name = k,
						component = name,
					})
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

function prototype.CreateEntity(config, parent, info)
	event.Call("EntityCreate", config, parent, info)

	local self = META:CreateObject()

	if parent then
		self:SetParent(parent)
	end

	if prototype.component_configurations[config] then
		info = info or {}

		self.config = config

		DEFER_COMPONENT_CHECKS_AND_EVENTS = true

		for _, name in ipairs(prototype.component_configurations[config].components) do
			if not info.exclude_components or not table.hasvalue(info.exclude_components, name) then
				self:AddComponent(name)
			end
		end

		for name, component in pairs(self:GetComponents()) do
			for _, other in ipairs(component.Require) do
				if not self.Components[other] then
					self:Remove()
					error("component " .. name .. " requires component " .. other, 1)
				end
			end
			component:OnAdd(self)
		end

		for _, component in pairs(self:GetComponents()) do
			for _, component_ in pairs(self:GetComponents()) do
				component_:OnEntityAddComponent(component)
			end
		end

		DEFER_COMPONENT_CHECKS_AND_EVENTS = false

		for _, data in ipairs(prototype.component_configurations[config].functions) do
			if not info.exclude_components or not table.hasvalue(info.exclude_components, data.component) then
				self[data.name] = self[data.name] or data.func
			end
		end

		self:SetPropertyIcon(prototype.component_configurations[config].icon)
	end

	return self
end