local prototype = ... or _G.prototype

local META = prototype.CreateTemplate("base")

META.Require = {}
META.Events = {}

META:GetSet("Id")
META:GetSet("Entity", NULL)
META:Delegate("Entity", "GetComponent")
META:Delegate("Entity", "AddComponent")
META:Delegate("Entity", "RemoveComponent")

function META:Initialize()

end

function META:OnAdd(ent)

end

function META:OnEntityAddComponent(component)

end

function META:OnRemove()
	if self.Entity:IsValid() and self.Entity.Components and self.Entity.Components[self.Type] then
		self.Entity.Components[self.Type] = nil
	end
end

function META:OnEvent(component, name, ...)

end

function META:GetEntityComponents()
	return self:GetEntity():GetComponents()
end

function META:FireEvent(...)
	for _, component in ipairs(self:GetEntityComponents()) do
		component:OnEvent(self, component.Name, ...)
	end
end

function prototype.RegisterComponent(META)
	META.TypeBase = "base"
	META.ClassName = META.Name
	prototype.Register(META, "component")
end

function prototype.CreateComponent(name)
	local meta = prototype.GetRegistered("component", name)
	if meta and meta.PreCreate and meta:PreCreate() == false then
		return
	end

	local self = prototype.CreateDerivedObject("component", name)
	if self then
		self:Initialize()
	end
	return self
end

META.Type = nil
META:Register("component")
