local render = ... or _G.render

local gl = require("lj-opengl")

local PASS = render.CreateGBufferPass("light", FILE_NAME:sub(1, 1))
PASS:AddBuffer("light", "RGBA16F")

function PASS:Draw3D()
	gl.Disable(gl.e.GL_DEPTH_TEST)	
	gl.Enable(gl.e.GL_BLEND)
	--render.SetBlendMode("additive")
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
	source = "gl_Position = pvm_matrix * vec4(pos, 1);"
})

PASS:ShaderStage("fragment", { 
	uniform = {				
		tex_depth = "sampler2D",
		tex_diffuse = "sampler2D",
		tex_normal = "sampler2D",
		tex_illumination = "sampler2D",
		
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
			distance = distance / (light_radius * 2);
			distance = -distance + 1;
			
			return clamp(distance, 0, 1);
		}
		
		const float e = 2.71828182845904523536028747135;
		const float pi = 3.1415926535897932384626433832;

		
		vec3 CookTorrance2(vec3 cLight, vec3 normal, vec3 world_pos, float specular, float roughness)
		{
			float normalDotLight = dot(normal, cLight);
		
			//if (normalDotLight < 0) return vec3(0,0,0);
					
			vec3 cEye = normalize(-world_pos);	

			vec3 cHalf = normalize(cLight + cEye);					
			float normalDotHalf = dot(normal, cHalf);
			
			//if (normalDotHalf < 0) return vec3(0,0,0);
			
			float normalDotEye = dot(normal, cEye);					
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
			vec3 specular_ = light_color.rgb * max(max(0.0, CookTorrance) * specular, normalDotLight);
			
			return diffuse_ + specular_;
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
				float fade = get_attenuation(world_pos);
				
				//{out_color.rgb = vec3(fade, 0,0); return;}
					
				if (light_shadow == 1)
					fade = fade*get_shadow(uv);
				
				if (fade > 0)
				{							
					vec4 normal = texture(tex_normal, uv);							
					float specular = normal.a;
					vec3 light_dir = normalize(light_pos - world_pos);
					
					fade = pow(fade * 4, 2) / 2;
					float intensity = light_diffuse_intensity * light_diffuse_intensity;
					
					out_color.rgb += CookTorrance2(light_dir, normal.xyz,  world_pos, specular * light_specular_intensity, light_roughness) * intensity * fade;
				} 

				out_color.a = light_color.a;   
			}
		}
	]]  
})