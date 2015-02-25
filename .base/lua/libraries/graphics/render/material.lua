local render = ... or _G.render

local META = prototype.CreateTemplate("material")

META:GetSet("Shader", NULL)

META:Register()

function render.CreateMaterial()
	return prototype.CreateObject(META)
end