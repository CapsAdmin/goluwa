local render = ... or _G.render

local META = prototype.CreateTemplate("material")

META:GetSet("Shader", NULL)

function META:__newindex(key, val)
	self.variables[key] = val
end

function META:__index2(key)
	return self.variables[key]
end

function META:Bind()
	for k,v in pairs(self.variables) do self.Shader[k] = v end -- TODO
	self.Shader:Bind()
end

META:Register()

function render.CreateMaterial()
	local self = prototype.CreateObject(META)
	self.variables = {}
	return self
end

function render.SetMaterial(mat)
	render.material = mat
end

function render.GetMaterial()
	return render.material
end