local COMPONENT = {}

COMPONENT.Name = "material"
COMPONENT.Icon = "textures/silkicons/palette.png"

function COMPONENT:OnAdd(ent)
	local ent = ent:GetParent()
	if ent:IsValid() then
		self.mat = render.CreateMaterial(self.material_type)
		local mdl = ent:GetComponent("model")
		if mdl:IsValid() then
			self.prev_mat = mdl:GetMaterialOverride()
			mdl:SetMaterialOverride(self.mat)
		end
	end
end

function COMPONENT:OnRemove()
	local ent = self:GetEntity():GetParent()
	if ent:IsValid() then
		if self.prev_mat and self.prev_mat:IsValid() then
			local mdl = ent:GetComponent("model")
			if mdl:IsValid() then
				mdl:SetMaterialOverride(self.prev_mat)
			end
			self.prev_mat = nil
		else
			local mdl = ent:GetComponent("model")
			if mdl:IsValid() then
				mdl:SetMaterialOverride()
			end
			self.mat:Remove()
		end
	end
end

prototype.RegisterComponent(COMPONENT)

event.AddListener("GBufferInitialized", "register_material_components", function()
	for name, meta in pairs(prototype.GetRegisteredSubTypes("material")) do
		local COMPONENT = {}

		COMPONENT.Name = name .. "_material"
		COMPONENT.Base = "material"
		COMPONENT.Icon = "textures/silkicons/palette.png"

		COMPONENT.material_type = name

		prototype.StartStorable()
			prototype.DelegateProperties(COMPONENT, meta, "mat")
		prototype.EndStorable()
		
		prototype.RegisterComponent(COMPONENT)
		
		prototype.SetupComponents(COMPONENT.Name, {COMPONENT.Name}, COMPONENT.Icon)
	end  
end)