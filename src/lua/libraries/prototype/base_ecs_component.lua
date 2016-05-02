local prototype = ... or _G.prototype

local META = {}
META.ClassName = "base"

META.Require = {}
META.Events = {}

prototype.GetSet(META, "Id")
prototype.GetSet(META, "Entity", NULL)
prototype.Delegate(META, "Entity", "GetComponent")
prototype.Delegate(META, "Entity", "AddComponent")
prototype.Delegate(META, "Entity", "RemoveComponent")

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
	local out = {}

	for _, component in pairs(self:GetEntity():GetComponents()) do
		table.insert(out, component)
	end

	return out
end

function META:FireEvent(...)
	for _, component in ipairs(self:GetEntityComponents()) do
		component:OnEvent(self, component.Name, ...)
	end
end

function prototype.RegisterComponent(meta)
	meta.TypeBase = "base"
	meta.ClassName = meta.Name
	prototype.Register(meta, "component")
end

function prototype.CreateComponent(name)
	local meta = prototype.GetRegistered("component", name)
	if meta and meta.PreCreate and meta:PreCreate() == false then
		return
	end

	local self = prototype.CreateDerivedObject("component", name)
	self:Initialize()
	return self
end

prototype.Register(META, "component")