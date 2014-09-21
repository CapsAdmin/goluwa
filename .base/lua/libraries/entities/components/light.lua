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
	do -- shader
		local gl = require("lj-opengl") -- OpenGL
		
		local PASS = render.CreateGBufferPass("light", 2)
		PASS:AddBuffer("light", "RGBA16F")

		function PASS:Draw3D()
			gl.Disable(gl.e.GL_DEPTH_TEST)	
			gl.Enable(gl.e.GL_BLEND)
			gl.BlendFunc(gl.e.GL_ONE, gl.e.GL_ONE)
			render.SetCullMode("front")
			
			render.gbuffer:Begin("light")
				render.gbuffer:Clear(0,0,0,0, "light")
				event.Call("Draw3DLights", render.gbuffer_light_shader)
			render.gbuffer:End() 	
		end

		PASS:ShaderStage("vertex", { 
			uniform = {
				pvm_matrix = {mat4 = render.GetPVWMatrix2D},
			},			
			attributes = {
				{pos = "vec3"},
				{normal = "vec3"},
				{uv = "vec2"},
				{texture_blend = "float"},
			},	
			source = "gl_Position = pvm_matrix * vec4(pos*7.5, 1);"
		})

		PASS:ShaderStage("fragment" ,{ 
			uniform = {
				tex_depth = "sampler2D",
				tex_diffuse = "sampler2D",
				tex_normal = "sampler2D",
				tex_position = "sampler2D",
				
				cam_pos = {vec3 = render.GetCamPos},
				light_pos = Vec3(0,0,0),
				
				screen_size = {vec2 = render.GetScreenSize},
				light_color = Color(1,1,1,1),				
				light_diffuse_intensity = 0.5,
				light_radius = 1000,
			},  
			source = [[			
				out vec4 out_color;
				
				vec2 get_uv()
				{
					return gl_FragCoord.xy / screen_size;
				}
				
				vec3 get_pos()
				{ 				
					vec2 uv = get_uv();
					return -texture(tex_position, uv).yxz;
				}
				
							
				float get_attenuation(vec3 world_pos)
				{
					float distance = length(light_pos - world_pos);
					distance = distance / light_radius / 5;
					distance = -distance + 2; 
					
					return clamp(distance, 0, 1);
				}
							 
				vec3 CookTorrance2(vec3 cLight, vec3 normal, vec3 world_pos, float specular)
				{
					float roughness = 0.1;

					vec3 cEye = normalize(cam_pos - world_pos);
					vec3 cHalf = normalize(cLight + cEye);

					// calculate light lumosity (optimized with custom dist calc)
					float sqDist = pow(light_pos.x - world_pos.x, 2.0) + pow(light_pos.y - world_pos.y, 2.0) + pow(light_pos.z - world_pos.z, 2.0);
					//float cAttenuation = lAtt.y + lAtt.z * sqrt(sqDist) + lAtt.w * sqDist;
					float cLuminosity = 1.0 / light_radius;
					
					// Beckman's distribution function D
					float normalDotHalf = dot(normal, cHalf);
					float normalDotHalf2 = normalDotHalf * normalDotHalf;
					
					float roughness2 = roughness * roughness;
					float exponent = -(1.0 - normalDotHalf2) / (normalDotHalf2 * roughness2);
					float e = 2.71828182845904523536028747135;
					float D = pow(e, exponent) / (roughness2 * normalDotHalf2 * normalDotHalf2);
					
					// Compute Fresnel term F
					float normalDotEye = dot(normal, cEye);
					float F = mix(pow(1.0 - normalDotEye, 5.0), 1.0, 0.5);
					
					// Compute self shadowing term G
					float normalDotLight = dot(normal, cLight);
					float X = 2.0 * normalDotHalf / dot(cEye, cHalf);
					float G = min(1.0, min(X * normalDotLight, X * normalDotEye));
					
					// Compute final Cook-Torrance specular term, load textures, mix them
					float pi = 3.1415926535897932384626433832;
					float CookTorrance = (D*F*G) / (normalDotEye * pi);
					
					vec3 diffuse_ = light_color.rgb * max(0.0, normalDotLight);
					vec3 specular_ = light_color.rgb * max(0.0, CookTorrance) * specular;
					
					return (diffuse_ + specular_) * max(0.0, normalDotLight) * light_diffuse_intensity;
				}
							
				void main()
				{					
					vec2 uv = get_uv();
					
					float specular = texture(tex_diffuse, uv).a;
					vec3 world_pos = get_pos();	

					{					
						vec3 normal = texture(tex_normal, uv).yxz;
						
						vec3 light_dir = normalize(light_pos - world_pos);
						
						float fade = get_attenuation(world_pos);
						
						if (fade > 0)
						{
							out_color.rgb = vec3(fade);
							
							out_color.rgb *= CookTorrance2(light_dir, normal, world_pos, specular);
						}

						out_color.a = light_color.a;
					}
				}
			]]  
		})
	end
	
	function COMPONENT:OnAdd(ent)
		self.light_mesh = render.Create3DMesh("models/cube.obj")
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
		if not self.light_mesh.sub_models[1] then return end
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

		shader:Bind()
		self.light_mesh.sub_models[1].mesh:Draw()
	end	
end

metatable.RegisterComponent(COMPONENT)