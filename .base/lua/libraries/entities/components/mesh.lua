local entities = (...) or _G.entities

local COMPONENT = {}

COMPONENT.Name = "mesh"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DGeometry"}

metatable.StartStorable()		
	metatable.GetSet(COMPONENT, "DiffuseTexture")
	metatable.GetSet(COMPONENT, "BumpTexture")
	metatable.GetSet(COMPONENT, "SpecularTexture")
	metatable.GetSet(COMPONENT, "Color", Color(1, 1, 1))
	metatable.GetSet(COMPONENT, "Alpha", 1)
	metatable.GetSet(COMPONENT, "Cull", true)
	metatable.GetSet(COMPONENT, "ModelPath", "models/face.obj")
metatable.EndStorable()

metatable.GetSet(COMPONENT, "Model", nil)

COMPONENT.Network = {
	ModelPath = {"string", 1/5},
	Cull = {"boolean", 1/5},
	Alpha = {"float", 1/30, "unreliable"},
	--Color = {"boolean", 1/5},	
}


if CLIENT then						
	function COMPONENT:OnAdd(ent)
	end

	function COMPONENT:OnRemove(ent)

	end	

	function COMPONENT:SetModelPath(path)
		self.ModelPath = path
		self.Model = render.Create3DMesh(path)
	end

	function COMPONENT:OnDraw3DGeometry(shader, vp_matrix)
		if not self.Model then return end
		
		vp_matrix = vp_matrix or render.matrices.vp_matrix

		local matrix = self:GetComponent("transform"):GetMatrix() 
		local model = self.Model
		
		local visible = false
		
		if model.corners and self.Cull then
			local temp = Matrix44()
			
			model.matrix_cache = model.matrix_cache or {}
			
			for i, pos in ipairs(model.corners) do
				model.matrix_cache[i] = model.matrix_cache[i] or Matrix44()
				model.matrix_cache[i]:Identity()
				model.matrix_cache[i]:Translate(pos.x, pos.y, pos.z)
				
				model.matrix_cache[i]:Multiply(matrix, temp)
				temp:Multiply(vp_matrix, model.matrix_cache[i])
				
				local x, y, z = model.matrix_cache[i]:GetClipCoordinates()
				
				if 	
					(x > -1 and x < 1) and 
					(y > -1 and y < 1) and 
					(z > -1 and z < 1) 
				then
					visible = true
					break
				end
			end
		else
			visible = true
		end
		
		if true or visible then
			local screen = matrix * vp_matrix
			
			shader.pvm_matrix = screen.m
			shader.vm_matrix = matrix.m
			shader.v_matrix = render.GetViewMatrix3D()
			shader.color = self.Color
			
			for i, model in ipairs(model.sub_models) do
				shader.diffuse = self.DiffuseTexture or model.diffuse or render.GetErrorTexture()
				shader.diffuse2 = self.DiffuseTexture or model.diffuse2 or render.GetErrorTexture()
				shader.specular = self.SpecularTexture or model.specular or render.GetBlackTexture()
				shader.bump = self.BumpTexture or model.bump or render.GetBlackTexture()
				
				--shader.detail = model.detail or render.GetWhiteTexture()
				
				shader:Bind()
				model.mesh:Draw()
			end
		end
	end 
	
	COMPONENT.OnDraw2D = COMPONENT.OnDraw3DGeometry
end

entities.RegisterComponent(COMPONENT)