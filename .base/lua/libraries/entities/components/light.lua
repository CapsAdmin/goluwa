local entities = (...) or _G.entities

local COMPONENT = {}

COMPONENT.Name = "light"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"DrawLights"}

metatable.StartStorable()		

metatable.EndStorable()

if CLIENT then
			
	function COMPONENT:OnAdd(ent)
		self.light_mesh = render.Create3DMesh("models/sphere.obj")
	end

	function COMPONENT:OnRemove(ent)

	end	

	function COMPONENT:OnDrawLights(shader)
		local transform = self:GetComponent("transform")
		local matrix = transform:GetMatrix() 
		local screen = matrix * render.matrices.vp_matrix
		
		shader.pvm_matrix = screen.m
		shader.light_pos = transform:GetPosition()
		shader.light_radius = transform:GetSize()
		
		for i, model in ipairs(self.light_mesh.sub_models) do
			model.mesh:Draw()
		end
	end	
end

entities.RegisterComponent(COMPONENT)