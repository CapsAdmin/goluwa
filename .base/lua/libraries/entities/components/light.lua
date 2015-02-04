if not render then return end

local COMPONENT = {}

COMPONENT.Name = "light"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DLights", "DrawShadowMaps", "DrawLensFlare"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1))
	
	-- automate this!!
	prototype.GetSet(COMPONENT, "DiffuseIntensity", 0.5)
	prototype.GetSet(COMPONENT, "SpecularIntensity", 1)
	prototype.GetSet(COMPONENT, "Roughness", 0.5)

	prototype.GetSet(COMPONENT, "Shadow", false)
	prototype.GetSet(COMPONENT, "FOV", 90, {editor_min = 0, editor_max = 180})
	prototype.GetSet(COMPONENT, "NearZ", 1)
	prototype.GetSet(COMPONENT, "FarZ", 32000)
	prototype.GetSet(COMPONENT, "OrthoSize", 0)
	prototype.GetSet(COMPONENT, "LensFlare", false)
prototype.EndStorable()

if GRAPHICS then
	local gl = require("lj-opengl")
	
	do -- shadow map stage 1
		local PASS = render.CreateGBufferPass("shadow", 2)

		function PASS:Draw3D()
			event.Call("DrawShadowMaps", render.gbuffer_shadow_shader)
		end
		
		function PASS:DrawDebug(i,x,y,w,h,size)
			for name, map in pairs(render.shadow_maps) do
				local tex = map:GetTexture("depth")
			
				surface.SetWhiteTexture()
				surface.SetColor(1, 1, 1, 1)
				surface.DrawRect(x, y, w, h)
				
				surface.SetColor(1,1,1,1)
				surface.SetTexture(tex)
				surface.DrawRect(x, y, w, h)
				
				surface.SetTextPosition(x, y + 5)
				surface.DrawText(tostring(name))
				
				if i%size == 0 then
					y = y + h
					x = 0
				else
					x = x + w
				end
				
				i = i + 1
			end
			
			return i,x,y,w,h
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
			source = "gl_Position = pvm_matrix * vec4(pos, 1);"
		})
		
		render.shadow_maps = render.shadow_maps or utility.CreateWeakTable()
								
		function COMPONENT:OnDrawShadowMaps(shader)
			if self.Shadow then
				if not render.shadow_maps[self] then
					self.shadow_map = render.CreateFrameBuffer(render.gbuffer_width, render.gbuffer_height, {
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
			else
				if render.shadow_maps[self] then
					render.shadow_maps[self] = nil
				end
				return
			end
			
			local transform = self:GetComponent("transform")					
			local pos = transform:GetPosition()
			local ang = transform:GetAngles()
			
			-- setup the view matrix
			local view = Matrix44()
			view:Rotate(ang.p, 0, 0, 1)
			view:Rotate(ang.r + math.pi/2, 1, 0, 0)
			view:Rotate(ang.y, 0, 0, 1)
			view:Translate(pos.y, pos.x, pos.z)			
			
			
			-- setup the projection matrix
			local projection = Matrix44()
			
			if self.OrthoSize == 0 then
				projection:Perspective(self.FOV, self.NearZ, self.FarZ, render.camera.ratio) 
			else
				local size = self.OrthoSize
				projection:Ortho(-size, size, -size, size, 200, 0) 
			end
			
			--entities.world:GetComponent("world").sun:SetPosition(render.GetCameraPosition()) 
			--entities.world:GetComponent("world").sun:SetAngles(render.GetCameraAngles())
			
			-- make a view_projection matrix
			self.vp_matrix = view * projection
						
			-- render the scene with this matrix
			self.shadow_map:Begin("depth")
				self.shadow_map:Clear()
				event.Call("Draw3DGeometry", shader, self.vp_matrix)
			self.shadow_map:End("depth")
		end
	end
	
	do -- light stage 2
		local PASS = render.CreateGBufferPass("light", 3)
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

		PASS:ShaderStage("fragment", { 
			uniform = {				
				tex_depth = "sampler2D",
				tex_diffuse = "sampler2D",
				tex_normal = "sampler2D",
				tex_position = "sampler2D",
				
				tex_shadow_map = "sampler2D",
				
				cam_pos = {vec3 = render.GetCameraPosition},
				light_pos = Vec3(0,0,0),
				
				screen_size = {vec2 = render.GetGBufferSize},
				light_color = Color(1,1,1,1),				
				light_diffuse_intensity = 0.5,
				light_radius = 1000,
				light_vp_matrix = "mat4",
				light_specular_intensity = 1,
				light_roughness = 0.5,
				light_shadow = 0,
				
				inverse_projection = "mat4",
				inverse_view_projection = "mat4",
				cam_nearz = {float = function() return render.camera.nearz end},
				cam_farz = {float = function() return render.camera.farz end},
				view_matrix = {mat4 = function() return render.matrices.view_3d.m end},
			},  
			source = [[			
				out vec4 out_color;
				
				vec2 get_uv()
				{
					return gl_FragCoord.xy / screen_size;
				}
									
				float get_depth(vec2 uv) 
				{
					return (2.0 * cam_nearz) / (cam_farz + cam_nearz - texture2D(tex_depth, uv).r * (cam_farz - cam_nearz));
				}
				
				vec3 get_pos(vec2 uv)
				{
					float z = -texture2D(tex_depth, uv).r;
					vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
					sPos = inverse_projection * sPos;

					return (sPos.xyz / sPos.w);
				}
							
				float get_attenuation(vec3 world_pos)
				{												
					float distance = length(light_pos - world_pos);
					distance = distance / light_radius / 9;
					distance = -distance + 2; 
					
					return pow(clamp(distance, 0, 1), 0.5);
				}
				
				const float e = 2.71828182845904523536028747135;
				const float pi = 3.1415926535897932384626433832;

				
				vec3 CookTorrance2(vec3 cLight, vec3 normal, vec3 world_pos, float specular)
				{
					float normalDotLight = dot(normal, cLight);
				
					if (normalDotLight < 0) return vec3(0,0,0);
							
					vec3 cEye = normalize(-world_pos);	

					vec3 cHalf = normalize(cLight + cEye);					
					float normalDotHalf = dot(normal, cHalf);
					
					if (normalDotHalf < 0) return vec3(0,0,0);
					
					float normalDotEye = dot(normal, cEye);
					float roughness = light_roughness;					
					
					float normalDotHalf2 = normalDotHalf * normalDotHalf;
					
					float roughness2 = roughness * roughness;
					float exponent = -(1.0 - normalDotHalf2) / (normalDotHalf2 * roughness2);
					
					float D = pow(e, exponent) / (roughness2 * normalDotHalf2 * normalDotHalf2);
					float F = mix(pow(1.0 - normalDotEye, 5.0), 1.0, 0.5);															
					float X = 2.0 * normalDotHalf / dot(cEye, cHalf);
					float G = min(1.0, min(X * normalDotLight, X * normalDotEye));
					
					// Compute final Cook-Torrance specular term, load textures, mix them
					float CookTorrance = (D*F*G) / (normalDotEye * pi);
					
					vec3 diffuse_ = light_color.rgb * max(0.0, normalDotLight);
					vec3 specular_ = light_color.rgb * max(max(0.0, CookTorrance) * specular * light_specular_intensity, normalDotLight);
					
					return (diffuse_ + specular_) * light_diffuse_intensity;
				}
				
				float get_shadow(vec2 uv)    
				{
					// get world position from depth
					float view_depth = texture(tex_depth, uv).r;
					vec4 temp = light_vp_matrix * inverse_view_projection * vec4(uv * 2.0 - 1.0, -view_depth, 1.0);				
					vec2 shadow_uv = (temp.xyz / temp.w).xy;   

					float shadow_depth = texture(tex_shadow_map, 0.5*shadow_uv.xy+vec2(0.5)).r;

					float shadow = shadow_depth < view_depth ? 0.5 : 1.0;
					
					return shadow;
				}  
				
				void main()
				{					
					vec2 uv = get_uv();					
					vec3 world_pos = get_pos(uv);	
										
					//out_color.rgb = world_pos; out_color.a = 1; {return;}
										
					{					
						float fade = pow(get_attenuation(world_pos), 4);	
						
						if (light_shadow == 1)
							fade = fade*get_shadow(uv);
						
						if (fade > 0)
						{
							out_color.rgb = vec3(fade);
							
							float specular = texture(tex_diffuse, uv).a;
							vec3 normal = texture(tex_normal, uv).xyz;							
							vec3 light_dir = normalize(light_pos - world_pos);
							
							out_color.rgb *= CookTorrance2(light_dir, normal,  world_pos, specular);
						}

						out_color.a = light_color.a;   
					}
				}
			]]  
		})
		
		function COMPONENT:OnDraw3DLights(shader)
			if not render.matrices.vp_matrix or not self.light_mesh then return end -- grr
			
			local transform = self:GetComponent("transform")
			local matrix = transform:GetMatrix() 
			local screen = matrix * render.matrices.vp_matrix
			
			shader.pvm_matrix = screen.m
			self.screen_matrix = screen
			
			local mat = matrix * render.matrices.view_3d
			local x,y,z = mat:GetTranslation()
			shader.light_pos:Set(x*2,y*2,z*2) -- why do i need to multiply by 2?
			shader.light_radius = transform:GetSize()
			shader.inverse_projection = render.matrices.projection_3d_inverse.m
			shader.inverse_view_projection = (render.matrices.vp_3d_inverse).m
			
			-- automate this!!
			shader.light_color = self.Color
			shader.light_ambient_intensity = self.AmbientIntensity
			shader.light_diffuse_intensity = self.DiffuseIntensity
			shader.light_specular_intensity = self.SpecularIntensity
			shader.light_attenuation_constant = self.AttenuationConstant
			shader.light_attenuation_linear = self.AttenuationLinear
			shader.light_attenuation_exponent = self.AttenuationExponent
			shader.light_roughness = self.Roughness
			shader.light_shadow = self.Shadow and 1 or 0
			
			if self.Shadow then
				shader.tex_shadow_map = self.shadow_map:GetTexture("depth")
				shader.light_vp_matrix = self.vp_matrix.m
			end		

			shader:Bind()
			self.light_mesh:Draw()
		end
	end
	
	if true then -- lens flares stage 3
		local PASS = render.CreateGBufferPass("lens_flare", 4)
		PASS:AddBuffer("lens_flare", "RGBA16F")
		
		function PASS:Draw2D()
			render.SetCullMode("front")
			render.gbuffer:Begin("lens_flare")
				--render.gbuffer:Clear(0,0,0,0, "lens_flare")
				event.Call("DrawLensFlare", render.gbuffer_lens_flare_shader)
			render.gbuffer:End()
			render.SetCullMode("back")			
			
			render.SetBlendMode("alpha")
		end
			
		function COMPONENT:OnDrawLensFlare(shader)
			if not self.LensFlare or not self.screen_matrix then return end
			local x, y, z = self.screen_matrix:GetClipCoordinates()
			
			shader.pvm_matrix = self.screen_matrix.m
			
			if z > -1 then
				shader.screen_pos:Set(x, y)
			else
				shader.screen_pos:Set(-2,-2)
			end
			
			shader.intensity = self.DiffuseIntensity^0.25
			
			shader:Bind()
			self.light_mesh:Draw()
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
			source = "gl_Position = pvm_matrix * vec4(pos*7.50, 1);"
		})
		
		PASS:ShaderStage("fragment", { 
			uniform = {				
				tex_depth = "sampler2D",
				tex_diffuse = "sampler2D",
				tex_normal = "sampler2D",
				tex_position = "sampler2D",
				
				tex_noise = render.GetNoiseTexture(),
				noise_tex_size = render.GetNoiseTexture():GetSize(),
		
				screen_pos = Vec2(0,0),
				intensity = 1,
				
				screen_size = {vec2 = render.GetGBufferSize},
				light_color = Color(1,1,1,1),				
				light_diffuse_intensity = 0.5,
				light_radius = 1000,
				
				
				inverse_projection = "mat4",
				cam_nearz = {float = function() return render.camera.nearz end},
				cam_farz = {float = function() return render.camera.farz end},
				view_matrix = {mat4 = function() return render.matrices.view_3d.m end},
			},
			source = [[			
				out vec4 out_color;
				
				vec2 get_uv()
				{
					return gl_FragCoord.xy / screen_size;
				}
									
				float get_depth(vec2 uv) 
				{
					return (2.0 * cam_nearz) / (cam_farz + cam_nearz - texture2D(tex_depth, uv).r * (cam_farz - cam_nearz));
				}
				
				vec3 get_pos(vec2 uv)
				{
					float z = -texture2D(tex_depth, uv).r;
					vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
					sPos = inverse_projection * sPos;

					return (sPos.xyz / sPos.w);
				}
				
				/*by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

				 Trying to get some interesting looking lens flares.

				 13/08/13: 
					published

				muuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuusk!*/

				float noise(float t)
				{
					return texture2D(tex_noise,vec2(t,.0)/noise_tex_size).x;
				}
				float noise(vec2 t)
				{
					return texture2D(tex_noise,t/noise_tex_size).x;
				}

				vec3 lensflare(vec2 uv,vec2 pos)
				{
					vec2 main = uv-pos;
					vec2 uvd = uv*(length(uv));
					
					float ang = atan(main.x,main.y);
					float dist=length(main); dist = pow(dist,.1);
					float n = noise(vec2(ang*16.0,dist*32.0));
					
					float f0 = 1.0/(length(uv-pos)*16.0+1.0);
					
					f0 = f0+f0*(sin(noise((pos.x+pos.y)*2.2+ang*4.0+5.954)*16.0)*.1+dist*.1+.8);
					
					float f1 = max(0.01-pow(length(uv+1.2*pos),1.9),.0)*7.0;

					float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
					float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
					float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;
					
					vec2 uvx = mix(uv,uvd,-0.5);
					
					float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
					float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
					float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;
					
					uvx = mix(uv,uvd,-.4);
					
					float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
					float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
					float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;
					
					uvx = mix(uv,uvd,-0.5);
					
					float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
					float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
					float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;
					
					vec3 c = vec3(.0);
					
					c.r+=f2+f4+f5+f6; 
					c.g+=f22+f42+f52+f62; 
					c.b+=f23+f43+f53+f63;
					
					c = c*1.3 - vec3(length(uvd)*.05);
					c+=vec3(f0);
					
					return c;
				}

				vec3 cc(vec3 color, float factor,float factor2) // color modifier
				{
					float w = color.x+color.y+color.z;
					return mix(color,vec3(w)*factor,w*factor2);
				}
				
				void main()
				{					
					vec2 uv = get_uv();
										
					if (screen_pos != vec2(-2, -2))
					{					
						vec3 color = light_color.rgb*lensflare(uv-vec2(0.5), screen_pos);
						color -= noise(gl_FragCoord.xy)*0.015;
						color = cc(color, 0.5, 0.1)*intensity;
						
						out_color.rgb = color;
						out_color.a = 1;
					}
				}
			]]  
		})
	end
	
	function COMPONENT:OnAdd(ent)
		-- grabbin puke
		-- grabbin puke
		-- grabbin puke
		if LIGHT_MESH then
			self.light_mesh = LIGHT_MESH
			return
		end
		local ent = entities.CreateEntity("visual")
		ent:LoadModelFromDisk("models/cube.obj", nil, function()
			LIGHT_MESH = ent:GetComponent("model").sub_models[1]
			self.light_mesh = LIGHT_MESH
			ent:Remove()
		end)
	end

	function COMPONENT:OnRemove(ent)
		render.shadow_maps[self] = nil
	end
end

prototype.RegisterComponent(COMPONENT)

if RELOAD then
	render.InitializeGBuffer()
	
	do return end
	event.Delay(0.1, function()
	world.sun:SetShadow(true)
	world.sun:SetPosition(render.GetCameraPosition()) 
	world.sun:SetAngles(render.GetCameraAngles()) 
	world.sun:SetFOV(render.GetCameraFOV())
	world.sun:SetSize(1000) 
	end) 
end