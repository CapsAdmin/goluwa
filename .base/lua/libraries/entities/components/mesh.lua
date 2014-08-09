local entities = (...) or _G.entities

local COMPONENT = {}

COMPONENT.Name = "mesh"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DGeometry"}

metatable.StartStorable()		
	metatable.GetSet(COMPONENT, "Texture")
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

	function COMPONENT:OnDraw3DGeometry(shader)

		local model = self.Model

		if not render.matrices.vp_matrix then return end -- FIX ME			
		if not model then return end

		local matrix = self:GetComponent("transform"):GetMatrix() 
		local temp = Matrix44()
		
		local visible = false
		
		if model.corners and self.Cull then
			model.matrix_cache = model.matrix_cache or {}
			
			for i, pos in ipairs(model.corners) do
				model.matrix_cache[i] = model.matrix_cache[i] or Matrix44()
				model.matrix_cache[i]:Identity()
				model.matrix_cache[i]:Translate(pos.x, pos.y, pos.z)
				
				model.matrix_cache[i]:Multiply(matrix, temp)
				temp:Multiply(render.matrices.vp_matrix, model.matrix_cache[i])
				
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
			local screen = matrix * render.matrices.vp_matrix
			
			shader.pvm_matrix = screen.m
			shader.vm_matrix = matrix.m
			shader.v_matrix = render.GetViewMatrix3D()
			shader.color = self.Color
			
			for i, model in ipairs(model.sub_models) do
				shader.diffuse = self.Texture or model.diffuse or render.GetErrorTexture()
				shader.diffuse2 = model.diffuse2 or render.GetErrorTexture()
				shader.specular = model.specular or render.GetWhiteTexture()
				shader.bump = model.bump or render.GetBlackTexture()
				--shader.detail = model.detail or render.GetWhiteTexture()
				shader:Bind()
				model.mesh:Draw()
			end
		end
	end 
	
	COMPONENT.OnDraw2D = COMPONENT.OnDraw3DGeometry
end

entities.RegisterComponent(COMPONENT)