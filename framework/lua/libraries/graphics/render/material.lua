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

function META:OnBind() end

function META:SetError(reason)
	self.Error = reason
	self.AlbedoTexture = render.GetErrorTexture()
	logf("[%s] material error: %s\n", self, reason)
end

META:Register()

function render.CreateMaterial(name)
	local self = prototype.CreateDerivedObject("material", name)
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
	local prev = render.current_material
	render.current_material = mat

	if mat and prev ~= mat then mat:OnBind() end
end

function render.GetMaterial()
	return render.current_material
end