local render = ... or _G.render

local gl = require("lj-opengl")

local PASS = {}

PASS.Name = "light"
PASS.Stage = FILE_NAME:sub(1, 1)

PASS.Buffers = {
	{"light", "RGB16F"},
}

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
		uniform = {
			pvm_matrix = {mat4 = render.GetProjectionViewWorld3DMatrix},
		},			
		attributes = {
			{pos = "vec3"},
		},	
		source = "gl_Position = pvm_matrix * vec4(pos, 1);"
	},
	fragment = { 
		uniform = {			
			light_view_pos = Vec3(0,0,0),
			light_color = Color(1,1,1,1),				
			light_intensity = 0.5,
			light_vp_matrix = "mat4",
		},  
		source = [[			
			out vec4 out_color;
			
			#define EPSILON 0.00001			
			#extension GL_NV_shadow_samplers_cube:enable
			
			float get_shadow(vec2 uv)    
			{
				float visibility = 0;
			
				if (lua[light_point_shadow = 0] == 1)
				{
					/*float SampledDistance = textureCube(lua[tex_shadow_map_cube = "samplerCube"], light_dir).r;

					float Distance = length(light_dir);

					if (Distance <= SampledDistance + EPSILON)
						return 1.0;
					else
						return 0;*/
				}
				else
				{
					vec4 temp = light_vp_matrix * g_projection_view_inverse * vec4(uv * 2 - 1, texture(tex_depth, uv).r * 2 -1, 1.0);
					vec3 shadow_coord = (temp.xyz / temp.w);
					
					//if (shadow_coord.z < -1) return 0;
					
					if (shadow_coord.x > -1 && shadow_coord.x < 1 && shadow_coord.y > -1 && shadow_coord.y < 1 && shadow_coord.z > -1 && shadow_coord.z < 1)
					{	
						for (int i=0;i<4;i++)
						{
							if (texture(lua[tex_shadow_map = "sampler2D"], 0.5 * shadow_coord.xy + vec2(0.5) + (g_poisson_disk[i]/5000.0)).r > ((0.5 * shadow_coord.z + 0.5)))
								visibility += 0.25;
						}
					}
					else if(lua[project_from_camera = 0] == 1)
					{
						visibility = 1;
					}
				}
				
				return visibility;
			}  
						
			float get_attenuation(vec3 view_pos, vec2 uv)
			{												
				if (project_from_camera == 1) return 1;
				
				float distance = length(light_view_pos - view_pos);
				distance = distance / lua[light_radius = 1000];
				distance = -distance + 1;
				float fade = clamp(distance, 0, 1);
	
				return fade;
			}
			
			const float e = 2.71828182845904523536028747135;
			const float pi = 3.1415926535897932384626433832;

			
			float beckmannDistribution(float x, float roughness) {
			  float NdotH = max(x, 0.0001);
			  float cos2Alpha = NdotH * NdotH;
			  float tan2Alpha = (cos2Alpha - 1.0) / cos2Alpha;
			  float roughness2 = roughness * roughness;
			  float denom = 3.141592653589793 * roughness2 * cos2Alpha * cos2Alpha;
			  return exp(tan2Alpha / roughness2) / denom;
			}
			
			float cookTorranceSpecular(
			  vec3 lightDirection,
			  vec3 viewDirection,
			  vec3 surfaceNormal,
			  float roughness,
			  float fresnel) {

			  float VdotN = max(dot(viewDirection, surfaceNormal), 0.0);
			  float LdotN = max(dot(lightDirection, surfaceNormal), 0.0);

			  //Half angle vector
			  vec3 H = normalize(lightDirection + viewDirection);

			  //Geometric term
			  float NdotH = max(dot(surfaceNormal, H), 0.0);
			  float VdotH = max(dot(viewDirection, H), 0.000001);
			  float LdotH = max(dot(lightDirection, H), 0.000001);
			  float G1 = (2.0 * NdotH * VdotN) / VdotH;
			  float G2 = (2.0 * NdotH * LdotN) / LdotH;
			  float G = min(1.0, min(G1, G2));
			  
			  //Distribution term
			  float D = beckmannDistribution(NdotH, roughness);
			  
			  //Fresnel term
			  float F = pow(1.0 - VdotN, fresnel);

			  //Multiply terms and done
			  return  G * F * D / max(3.14159265 * VdotN, 0.000001);
			}
						
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
				vec3 specular_ = light_color.rgb * max(max(0.0, CookTorrance) * metallic * 5, normalDotLight);
				
				return diffuse_ + specular_;
			} 
						
			void main()
			{
				out_color.rgb = vec3(0);
			
				vec2 uv = get_screen_uv();					
				vec3 view_pos = get_view_pos(uv);

				float fade = get_attenuation(view_pos, uv);
						
				if (lua[light_shadow = 0] == 1)
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
					) * light_intensity * fade * 2;
					
					/*
					float specular = cookTorranceSpecular(
						normalize(-light_view_pos), 
						normal, 
						normalize(-view_pos), 
						roughness*2,
						metallic
					);
										
					out_color.rgb += light_color.rgb + (light_color.rgb * specular) * (light_intensity * fade * 2);
					*/
				}
			
				out_color.a = 1;
			}
		]]  
	}
}

render.RegisterGBufferPass(PASS)