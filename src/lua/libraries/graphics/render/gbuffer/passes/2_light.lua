local render = ... or _G.render

local PASS = {}

PASS.Stage, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Buffers = {
	{"light", "RGB16F"},
}

function PASS:Draw3D()
	render.EnableDepth(false)	
	render.SetBlendMode("one", "one")
	render.SetCullMode("front")
	
	render.gbuffer:WriteThese("light")
	render.gbuffer:Clear("light")
	render.gbuffer:Begin()
		event.Call("Draw3DLights")
	render.gbuffer:End() 	
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

PASS.Shader = {
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
		},	
		source = "gl_Position = g_projection_view_world * vec4(pos, 1);"
	},
	fragment = { 
		variables = {			
			light_view_pos = Vec3(0,0,0),
			light_color = Color(1,1,1,1),				
			light_intensity = 0.5,
			light_projection_view = "mat4",
		},  
		source = [[			
			out vec4 out_color;
			
			#define EPSILON 0.00001			
			
			float get_shadow(vec2 uv)    
			{
				float visibility = 0;
			
				if (lua[light_point_shadow = false])
				{
					vec3 light_dir = get_view_pos(uv) - light_view_pos;
				
					float SampledDistance = texture(lua[tex_shadow_map_cube = "samplerCube"], light_dir).r;

					float Distance = length(light_dir);

					if (Distance <= SampledDistance + EPSILON)
						return 100.0;
					else
						return SampledDistance;
				}
				else
				{
					vec4 temp = light_projection_view * g_projection_view_inverse * vec4(uv * 2 - 1, texture(tex_depth, uv).r * 2 -1, 1.0);
					vec3 shadow_coord = (temp.xyz / temp.w);
					
					//if (shadow_coord.z < -1) return 0.0;
					
					if (shadow_coord.x > -1 && shadow_coord.x < 1 && shadow_coord.y > -1 && shadow_coord.y < 1 && shadow_coord.z > -1 && shadow_coord.z < 1)
					{	
						for (int i=0;i<4;i++)
						{
							if (texture(lua[tex_shadow_map = "sampler2D"], 0.5 * shadow_coord.xy + vec2(0.5) + (g_poisson_disk[i]/5000.0)).r > ((0.5 * shadow_coord.z + 0.5)))
								visibility += 0.25;
						}
					}
					else if(lua[project_from_camera = false])
					{
						visibility = 1;
					}
				}
				
				return visibility;
			}  
						
			float get_attenuation(vec3 view_pos, vec2 uv)
			{												
				if (project_from_camera) return 1.0;
				
				float distance = length(light_view_pos - view_pos);
				distance = distance / lua[light_radius = 1000];
				distance = -distance + 1;
				float fade = clamp(distance, 0, 1);
	
				return fade;
			}
			
			const float e = 2.71828182845904523536028747135;
			const float pi = 3.1415926535897932384626433832;
									
			vec3 CookTorrance2(vec3 direction, vec3 surface_normal, vec3 eye_dir, float metallic, float roughness)
			{
				float normalDotLight = dot(surface_normal, direction);
						
				vec3 cHalf = normalize(direction + eye_dir);					
				float normalDotHalf = dot(surface_normal, cHalf);
								
				float normalDotEye = dot(surface_normal, eye_dir);					
				float normalDotHalf2 = normalDotHalf * normalDotHalf;
				
				float roughness2 = roughness*roughness;
				float exponent = -(1.0 - normalDotHalf2) / (normalDotHalf2 * roughness2);
				
				float D = pow(e, exponent) / (roughness2 * normalDotHalf2 * normalDotHalf2);
				float F = mix(pow(1.0 - normalDotEye, 5.0), 1.0, 0.5);															
				float X = 2.0 * normalDotHalf / dot(eye_dir, cHalf);
				float G = min(1.0, min(X * normalDotLight, X * normalDotEye));
				
				// Compute final Cook-Torrance specular term, load textures, mix them
				float CookTorrance = (D*F*G) / (normalDotEye * pi);
				
				vec3 diffuse_ = light_color.rgb * max(0.0, normalDotLight);
				vec3 specular_ = light_color.rgb * max(max(0.0, CookTorrance) * metallic, normalDotLight);
				
				return diffuse_ + specular_;
			} 
						
			void main()
			{
				out_color.rgb = vec3(0);
			
				vec2 uv = get_screen_uv();					
				vec3 view_pos = get_view_pos(uv);

				float fade = get_attenuation(view_pos, uv);
										
				if (lua[light_shadow = false])
				{
					float shadow = get_shadow(uv);
					
					if (shadow <= 1)
					{
						out_color.rgb += normalize(light_color.rgb) * light_intensity * fade;
					}
					
					fade *= shadow;
				}
				
				if (fade > 0)
				{							
					vec3 normal = get_view_normal(uv);
					float metallic = get_metallic(uv);
					float roughness = get_roughness(uv);

					out_color.rgb += CookTorrance2(
						normalize(light_view_pos - view_pos), 
						normal, 
						normalize(-view_pos), 
						metallic, 
						roughness
					) * light_intensity * fade;
				}
			
				out_color.a = 1;
			}
		]]  
	}
}

render.RegisterGBufferPass(PASS)

render.AddGlobalShaderCode([[
vec3 get_light(vec2 uv)
{
	return texture(tex_light, uv).rgb;
}]], "get_light")