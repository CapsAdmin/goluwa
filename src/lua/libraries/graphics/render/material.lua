local render = ... or _G.render

local META = prototype.CreateTemplate("material", "base")

do
	META:GetSet("Error", nil)

	function render.GetErrorMaterial()

		if not render.error_material then
			render.error_material = render.CreateMaterial("base")
			render.error_material:SetError("render.GetErrorMaterial")
		end

		return render.error_material
	end
end

function META:OnBind()

end

function META:SetError(reason)
	self.Error = reason
	self.AlbedoTexture = render.GetErrorTexture()
end

META:Register()

function render.CreateMaterial(name, shader)
	local self = prototype.CreateDerivedObject("material", name)

	self.required_shader = shader

	return self
end

function render.CreateMaterialTemplate(name)
	local META = prototype.CreateTemplate()

	META.Name = name

	function META:Register()
		META.TypeBase = "base"
		prototype.Register(META, "material", META.Name)
	end

	return META
end

function render.SetMaterial(mat)
	render.current_material = mat
	if mat then mat:OnBind() end
end

function render.GetMaterial()
	return render.current_material
end

function render.SetShaderOverride(shader)
	render.current_shader_override = shader
end

function render.GetShader()
	return render.current_shader_override
end