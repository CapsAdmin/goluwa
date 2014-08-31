local entities = (...) or _G.entities

local COMPONENT = {}

COMPONENT.Name = "light"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DLights", "DrawShadowMaps"}

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
	
	do -- shadow map		
		local gl = require("lj-opengl")
		
		function COMPONENT:SetShadow(b)
			if b then
				self.shadow_map = render.CreateFrameBuffer(render.GetWidth(), render.GetHeight(), {
					name = "depth",
					attach = "depth",
					draw_manual = true,
					texture_format = {
						internal_format = "DEPTH_COMPONENT32",	 
						depth_texture_mode = gl.e.GL_RED,
						min_filter = "nearest",				
					} 
				})
				
				render.shadow_maps[self] = self.shadow_map
			end
		end
						
		function COMPONENT:OnDrawShadowMaps(shader)
			if ohno or not self.shadow_map then return end
			
			local transform = self:GetComponent("transform")

			
			--transform:SetPosition(Vec3(1000, 1000, 1000)*0.2)
			--transform:SetAngles(Ang3(-90, 0, 0)) 			
			transform:SetPosition(Vec3(math.cos(os.clock())*5, 70, 10 + math.sin(os.clock())*5))
			transform:SetAngles(Ang3(-10, -90, 0)) 
			
			--transform:SetPosition(Vec3(0, 90, 0))
			--transform:SetAngles(Ang3(-10, -90, 0)) 
			
			--local pos = Vec3(math.sin(os.clock())*1500, 0, math.cos(os.clock())*500)
			--transform:SetPosition(pos)
			--transform:SetAngles((pos - render.GetCamPos()):GetAng3())
			
		--	transform:SetPosition(render.GetCamPos())
		--	transform:SetAngles(render.GetCamAng())
			
			do
				local pos = transform:GetPosition()
				local ang = transform:GetAngles()
				local forward = ang:GetForward()
				
				local projection = Matrix44()
				local cam = render.camera
				projection:Perspective(60, cam.nearz, cam.farz, cam.ratio) 
				
				--local size = 200
				--projection:Ortho(-size, size, -size, size, 200, 0) 

				local view = Matrix44()
				view:LoadIdentity()		

				view:Rotate(ang.r, 0, 0, 1)
				view:Rotate(ang.p + 90, 1, 0, 0)
				view:Rotate(ang.y, 0, 0, 1)
			
				view:Translate(pos.y, pos.x, pos.z)
						
				self.vp_matrix = view * projection
				
				self.shadow_map:Begin()
					self.shadow_map:Clear()
					event.Call("Draw3DGeometry", shader, self.vp_matrix)
				self.shadow_map:End()
			end
		end
	end

	function COMPONENT:OnDraw3DLights(shader)
		if not render.matrices.vp_matrix then return end -- grr
		local transform = self:GetComponent("transform")
		local matrix = transform:GetMatrix() 
		local screen = matrix * render.matrices.vp_matrix
		
		shader.pvm_matrix = screen.m
		shader.light_pos = transform:GetPosition()
		shader.light_dir = transform:GetAngles():GetForward()
		shader.light_radius = transform:GetSize()
		
		-- automate this!!
		shader.light_color = self.Color
		shader.light_ambient_intensity = self.AmbientIntensity
		shader.light_diffuse_intensity = self.DiffuseIntensity
		shader.light_specular_power = self.SpecularPower
		shader.light_attenuation_constant = self.AttenuationConstant
		shader.light_attenuation_linear = self.AttenuationLinear
		shader.light_attenuation_exponent = self.AttenuationExponent
		
		if self.vp_matrix and self.shadow_map then
			shader.tex_shadow_map = self.shadow_map:GetTexture("depth")
			shader.light_vp_matrix = self.vp_matrix.m
		end
		
		for i, model in ipairs(self.light_mesh.sub_models) do
			shader:Bind()
			model.mesh:Draw()
		end
	end	
end

entities.RegisterComponent(COMPONENT)