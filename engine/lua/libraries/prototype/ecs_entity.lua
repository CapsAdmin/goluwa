local prototype = ... or _G.prototype

local META = prototype.CreateTemplate("entity")

function META:__tostring2()
	return ("[%s][%s]"):format(self.config, self:GetName())
end

function META:GetEditorName()
	if self.Name ~= "" then
		return self.Name
	end
	for _, v in ipairs(self.Components) do
		if v.EditorName then
			return v.EditorName
		end
	end
	return self.EditorName or ""
end

runfile("parenting_template.lua", META)
META:GetSet("Components", {})

local DEFER_COMPONENT_CHECKS_AND_EVENTS

function META:AddComponent(name, ...)
	self:RemoveComponent(name)

	local component = prototype.CreateComponent(name)

	if not component then return end

	if not DEFER_COMPONENT_CHECKS_AND_EVENTS then
		for _, other in ipairs(component.Require) do
			if not self.components_hash[other] then
				error("component " .. name .. " requires component " .. other, 2)
			end
		end
	end

	component.Entity = self

	for _, event_type in ipairs(component.Events) do
		component:AddEvent(event_type)
	end

	self.components_hash[name] = component
	table.insert(self.Components, component)

	self[name] = component

	if not DEFER_COMPONENT_CHECKS_AND_EVENTS then
		component:OnAdd(self, ...)

		for _, component_ in ipairs(self:GetComponents()) do
			component_:OnEntityAddComponent(component)
		end
	end

	return component
end

function META:RemoveComponent(name)
	if not self.components_hash[name] then return end

	local component = self.components_hash[name] or NULL

	if component:IsValid() then

		for _, event_type in ipairs(component.Events) do
			component:RemoveEvent(event_type)
		end

		component:OnRemove(self)
		component:Remove()
	end

	if not self.removed then
		self.components_hash[name] = nil
		self[name] = nil
		for i,v in ipairs(self.Components) do
			if v.Name == name then
				table.remove(self.Components, i)
				break
			end
		end
	end
end

function META:GetComponent(name)
	return self.components_hash[name]
end

function META:HasComponent(name)
	return self.components_hash[name] ~= nil
end

function META:OnRemove()
	if self.removed then return end
	self.removed = true

	event.Call("EntityRemove", self)

	for _, component in ipairs(self:GetComponents()) do
		self:RemoveComponent(component.Name)
	end

	for _, v in ipairs(self:GetChildrenList()) do
		v:Remove()
	end

	-- this is important!!
	self:UnParent()

	event.Call("EntityRemoved")
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

			if not component then
				component = self:AddComponent(name)
			end

			if component then
				component:SetStorableTable(vars)
			end
		end

		for _, data in ipairs(data.children) do
			local ent = entities.CreateEntity(data.config, self)
			ent:SetStorableTable(data, true)
		end
	end

	function META:GetStorableTable(force)
		local data = {self = prototype.base_metatable.GetStorableTable(self), children = {}, components = {}}

		data.config = self.config

		for _, component in ipairs(self:GetComponents()) do
			data.components[component.Name] = component:GetStorableTable(force)
		end

		for _, v in ipairs(self:GetChildren()) do
			if force or not v:GetHideFromEditor() then
				table.insert(data.children, v:GetStorableTable(force))
			end
		end

		return table.copy(data)
	end
end

function META:OnParent(ent)
	event.Call("EntityParent", self, ent)
	for _, component in ipairs(self:GetComponents()) do
		if component.OnEntityParent then
			component:OnEntityParent(ent)
		end
	end
end

META:Register()

prototype.component_configurations = prototype.component_configurations or {}

function prototype.SetupComponents(name, components, icon, friendly)
	prototype.component_configurations[name] = {
		name = friendly or name,
		components = components,
		functions = {},
		icon = icon,
		setup = false,
	}

	prototype.components_need_setup = true
end

function prototype.GetConfigurations()
	return prototype.component_configurations
end

function prototype.CreateEntity(config, info)
	local self = META:CreateObject()

	if prototype.component_configurations[config] then

		if prototype.components_need_setup then
			for name, data in pairs(prototype.component_configurations) do
				if not data.setup then
					for _, name in ipairs(data.components) do
						if prototype.GetRegistered("component", name) then
							for k, v in pairs(prototype.GetRegistered("component", name)) do
								if type(v) == "function" then
									table.insert(data.functions, {
										func = function(ent, a,b,c,d)
											--local obj = ent:GetComponent(name)
											--return obj[k](obj, a,b,c,d)
											return ent.components_hash[name][k](ent.components_hash[name], a,b,c,d)
										end,
										name = k,
										component = name,
									})
								end
							end
						end
					end
					local temp = {}
					if data.exclude_components then
						for i,v in ipairs(data.exclude_components) do
							temp[v] = true
						end
					end
					data.exclude_components2 = temp
					data.setup = true
				end
			end
			prototype.components_need_setup = false
		end

		info = info or {}

		self.config = config
		self.components_hash = {}

		DEFER_COMPONENT_CHECKS_AND_EVENTS = true

		for _, name in ipairs(prototype.component_configurations[config].components) do
			if not info.exclude_components2 or not info.exclude_components2[name] then
				self:AddComponent(name)
			end
		end

		for _, component in ipairs(self:GetComponents()) do
			for _, other in ipairs(component.Require) do
				if not self.components_hash[other] then
					self:Remove()
					error("component " .. component.Name .. " requires component " .. other, 1)
				end
			end
			component:OnAdd(self)
		end

		for _, component in ipairs(self:GetComponents()) do
			for _, component_ in ipairs(self:GetComponents()) do
				component_:OnEntityAddComponent(component)
			end
		end

		DEFER_COMPONENT_CHECKS_AND_EVENTS = false

		for _, data in ipairs(prototype.component_configurations[config].functions) do
			if not info.exclude_components2 or not info.exclude_components2[data.component] then
				self[data.name] = self[data.name] or data.func
			end
		end

		self:SetPropertyIcon(prototype.component_configurations[config].icon)
	end

	return self
end
