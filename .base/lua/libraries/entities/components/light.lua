local entities = (...) or _G.entities

local COMPONENT = {}

COMPONENT.Name = "light"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DLights"}

metatable.StartStorable()
	metatable.GetSet(COMPONENT, "Color", Color(1, 1, 1))
	
	--metatable.GetSet(COMPONENT, "Color", Color(1,1,1,1))	
	--metatable.GetSet(COMPONENT, "Radius", 1000),
	--metatable.GetSet(COMPONENT, "Pos", Vec3(0,0,0))
	
	-- automate this!!
	metatable.GetSet(COMPONENT, "AmbientIntensity", 0)
	metatable.GetSet(COMPONENT, "DiffuseIntensity", 0.5)
	metatable.GetSet(COMPONENT, "SpecularPower", 32)
	metatable.GetSet(COMPONENT, "AttenuationConstant", 0)
	metatable.GetSet(COMPONENT, "AttenuationLinear", 0)
	metatable.GetSet(COMPONENT, "AttenuationExponent", 0.01)	
metatable.EndStorable()

if CLIENT then			
	function COMPONENT:OnAdd(ent)
		self.light_mesh = render.Create3DMesh("models/sphere.obj")
	end

	function COMPONENT:OnRemove(ent)

	end	

	function COMPONENT:OnDraw3DLights(shader)
		local transform = self:GetComponent("transform")
		local matrix = transform:GetMatrix() 
		local screen = matrix * render.matrices.vp_matrix
		
		shader.pvm_matrix = screen.m
		shader.light_pos = transform:GetPosition()
		shader.light_radius = transform:GetSize()
		
		-- automate this!!
		shader.light_color = self.Color
		shader.light_ambient_intensity = self.AmbientIntensity
		shader.light_diffuse_intensity = self.DiffuseIntensity
		shader.light_specular_power = self.SpecularPower
		shader.light_attenuation_constant = self.AttenuationConstant
		shader.light_attenuation_linear = self.AttenuationLinear
		shader.light_attenuation_exponent = self.AttenuationExponent
		
		for i, model in ipairs(self.light_mesh.sub_models) do
			shader:Bind()
			model.mesh:Draw()
		end
	end	
end

entities.RegisterComponent(COMPONENT)