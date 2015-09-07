local render = ... or _G.render

local PASS = {}

PASS.Stage, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Buffers = {
	{"light", "rgb16f"},
}

function PASS:Draw3D()
	render.EnableDepth(false)	
	
	render.SetCullMode("back")
	render.gbuffer:WriteThese("light")
	render.gbuffer:Clear("light")
	render.gbuffer:Begin()
		event.Call("Draw3DLights")
	render.gbuffer:End() 	
	render.SetCullMode("front")
end

function PASS:DrawDebug(i,x,y,w,h,size)
	for name, map in pairs(prototype.GetCreated(true, "shadow_map")) do
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
		source = "gl_Position = g_projection_view_world * vec4(pos*0.5, 1);"
	},
	fragment = { 
		variables = {			
			light_view_pos = Vec3(0,0,0),
			light_color = Color(1,1,1,1),				
			light_intensity = 0.5,
		},  
		source = [[			
			out vec4 out_color;
			
			#define EPSILON 0.00001			
			
			float get_shadow(vec2 uv, float bias)    
			{
				float visibility = 0;
			
				if (lua[light_point_shadow = false])
				{
					vec3 light_dir = get_view_pos(uv) - light_view_pos;
				
					float SampledDistance = texture(lua[tex_shadow_map_cube = "samplerCube"], light_dir).r;


					visibility = SampledDistance;
				}
				else
				{
					vec4 proj_inv = g_projection_view_inverse * vec4(uv * 2 - 1, texture(tex_depth, uv).r * 2 -1, 1.0);
					
						]] .. (function()
							local code = ""
							for i = 1, render.csm_count do
								local str = [[
								{
									vec4 temp = light_projection_view * proj_inv;
									vec3 shadow_coord = temp.xyz / temp.w;

									if (
										shadow_coord.x >= -0.9 && 
										shadow_coord.x <= 0.9 && 
										shadow_coord.y >= -0.9 && 
										shadow_coord.y <= 0.9 && 
										shadow_coord.z >= -0.9 && 
										shadow_coord.z <= 0.9
									)
									{						
										shadow_coord = 0.5 * shadow_coord + 0.5;
									
										visibility = shadow_coord.z - bias < texture(tex_shadow_map, shadow_coord.xy).r ? 1.0 : 0.0;
									}
									]]..(function()										
										if i == 1 then
											return [[else if(lua[project_from_camera = false])
											{
												visibility = 1;
											}]]
										end										
										return ""									
									end)()..[[
								}
								]]
								str = str:gsub("tex_shadow_map", "lua[tex_shadow_map_" .. i .." = \"sampler2D\"]")
								str = str:gsub("light_projection_view", "lua[light_projection_view_" .. i .. " = \"mat4\"]")
								code = code .. str
							end
							return code
						end)() .. [[
				}
				
				return visibility;
			}  
									
			vec3 get_attenuation(vec2 uv, vec3 P, vec3 N, float cutoff)
			{			
				// calculate normalized light vector and distance to sphere light surface
				float r = lua[light_radius = 1000]/10;
				vec3 L = light_view_pos - P;
				float distance = length(L);
				float d = max(distance - r, 0);
				L /= distance;
				 
				float attenuation = 1;
				
				// calculate basic attenuation
				if (!lua[project_from_camera = false])
				{
					float denom = d/r + 1;
					attenuation = 1 / (denom*denom);
				}
				 
				// scale and bias attenuation such that:
				//   attenuation == 0 at extent of max influence
				//   attenuation == 1 when d == 0
				attenuation = (attenuation - cutoff) / (1 - cutoff);
				attenuation = max(attenuation, 0);
				 
				float dot = max(dot(L, N), 0);
				attenuation *= dot;
				
				if (lua[light_shadow = false])
				{					
					attenuation *= get_shadow(uv, attenuation*0.0025);
				}
				
				return light_color.rgb * attenuation * light_intensity;
			}
			
			vec3 get_ambient()
			{
				if (lua[project_from_camera = false])
				{
					vec3 ambient = lua[light_ambient_color = Color(0,0,0)].rgb * light_intensity;
						
					if (ambient == vec3(0,0,0))
					{
						ambient = light_color.rgb * 0.75 * light_intensity;
					}

					return ambient;
				}
				
				return vec3(0,0,0);
			}
						
			float get_specular(vec3 lightDirection, vec3 viewDirection, vec3 surfaceNormal, float roughness, float fresnel) 
			{			
				vec3 H = normalize(lightDirection + viewDirection);
				
				float NdotH = max(dot(surfaceNormal, H), 0.0001);
				float VdotN = max(dot(viewDirection, surfaceNormal), 0.0);
			  
				float cos2Alpha = NdotH * NdotH;
				float beck_dist = exp((cos2Alpha - 1.0) / cos2Alpha / roughness) / (3.141592653589793 * roughness * cos2Alpha);
			
				return 
				min(
					1.0, 
					min(
						(2.0 * NdotH * VdotN) / max(dot(viewDirection, H), 0.000001), 
						(2.0 * NdotH * max(dot(lightDirection, surfaceNormal), 0.0)) / 
						max(dot(lightDirection, H), 0.000001)
					)
				) * 
				(VdotN) * 
				fresnel * 
				beck_dist / 
				max(3.14159265 * VdotN, 0.000001);
			}
			
			void main()
			{		
				//{out_color.rgb = vec3(1); out_color.a = 1; return;}
			
				vec2 uv = get_screen_uv();					
				vec3 view_pos = get_view_pos(uv);
				vec3 normal = get_view_normal(uv);				
				
				vec3 attenuate = get_attenuation(uv, view_pos, normal, 0.175);
				vec3 ambient = get_ambient();
				vec3 diffuse = texture(tex_diffuse, uv).rgb;
				float metallic = get_metallic(uv)+0.025;
				float roughness = get_roughness(uv);
				
				vec3 reflection = texture(tex_reflection, uv).rgb;
				float specular = get_specular(normalize(view_pos - light_view_pos), normalize(view_pos), -normal, (roughness * roughness * roughness) + 0.0005, metallic);
				
				out_color.rgb = diffuse * mix(vec3(1,1,1), reflection, metallic);
				out_color.rgb += specular.rrr * attenuate;
				out_color.rgb *= ambient + attenuate;
				
				//out_color.rgb += vec3(0.1);
			
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
}]])