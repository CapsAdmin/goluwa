local META = prototype.CreateTemplate()

META.Name = "material"
META.Icon = "textures/silkicons/palette.png"

function META:OnAdd(ent)
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

function META:OnRemove()
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

META:RegisterComponent()

event.AddListener("GBufferInitialized", "register_material_components", function()
	for name, meta in pairs(prototype.GetRegisteredSubTypes("material")) do
		local META = prototype.CreateTemplate()

		META.Name = name .. "_material"
		META.Base = "material"
		META.Icon = "textures/silkicons/palette.png"

		META.material_type = name

		META:StartStorable()
			META:DelegateProperties(meta, "mat")
		META:EndStorable()

		META:RegisterComponent()

		prototype.SetupComponents(META.Name, {META.Name}, META.Icon)
	end
end)