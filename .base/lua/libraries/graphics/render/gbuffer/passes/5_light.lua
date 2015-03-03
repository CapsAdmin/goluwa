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

PASS.Shader = {
	vertex = { 
		uniform = {
			pvm_matrix = {mat4 = render.GetPVWMatrix3D},
		},			
		attributes = {
			{pos = "vec3"},
		},	
		source = "gl_Position = pvm_matrix * vec4(pos, 1);"
	},
	fragment = { 
		uniform = {			
			tex_shadow_map_cube = "samplerCube",
			tex_shadow_map = "sampler2D",
			
			light_view_pos = Vec3(0,0,0),
			light_world_pos = Vec3(0,0,0),
			light_dir = Vec3(0,0,0),
			
			screen_size = {vec2 = render.GetGBufferSize},
			light_color = Color(1,1,1,1),				
			light_intensity = 0.5,
			light_radius = 1000,
			light_vp_matrix = "mat4",
			light_shadow = 0,
			light_point_shadow = 0, 
			project_from_camera = 0,
			cascade_pass = 1,
		},  
		source = [[			
			out vec4 out_color;
			
			#define EPSILON 0.00001			
			#extension GL_NV_shadow_samplers_cube:enable
			
			float get_shadow(vec2 uv)    
			{
				float visibility = 0;
			
				if (light_point_shadow == 1)
				{
					float SampledDistance = textureCube(tex_shadow_map_cube, light_dir).r;

					float Distance = length(light_dir);

					if (Distance <= SampledDistance + EPSILON)
						return 1.0;
					else
						return 0;
				}
				else
				{
					vec4 temp = light_vp_matrix * g_view_projection_inverse * vec4(uv * 2 - 1, texture(tex_depth, uv).r * 2 -1, 1.0);
					vec3 shadow_coord = (temp.xyz / temp.w);
					
					//if (shadow_coord.z < -1) return 0;
					
					if (shadow_coord.x > -1 && shadow_coord.x < 1 && shadow_coord.y > -1 && shadow_coord.y < 1 && shadow_coord.z > -1 && shadow_coord.z < 1)
					{	
						for (int i=0;i<4;i++)
						{
							if (texture(tex_shadow_map, 0.5 * shadow_coord.xy + vec2(0.5) + (g_poisson_disk[i]/5000.0)).r > ((0.5 * shadow_coord.z + 0.5)))
								visibility += 0.25;
						}
					}
					else if(project_from_camera == 1)
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
				distance = distance / light_radius;
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
						
			vec3 CookTorrance2(vec3 cLight, vec3 normal, vec3 world_pos, float metallic, float roughness)
			{
				float normalDotLight = dot(normal, cLight);

				//if (normalDotLight < 0) return vec3(0,0,0);
						
				vec3 cEye = normalize(-world_pos);	

				vec3 cHalf = normalize(cLight + cEye);					
				float normalDotHalf = dot(normal, cHalf);
				
				//if (normalDotHalf < 0) return vec3(0,0,0);
				
				float normalDotEye = dot(normal, cEye);					
				float normalDotHalf2 = normalDotHalf * normalDotHalf;
				
				float roughness2 = roughness;
				float exponent = -(1.0 - normalDotHalf2) / (normalDotHalf2 * roughness2);
				
				float D = pow(e, exponent) / (roughness2 * normalDotHalf2 * normalDotHalf2);
				float F = mix(pow(1.0 - normalDotEye, 5.0), 1.0, 0.5);															
				float X = 2.0 * normalDotHalf / dot(cEye, cHalf);
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
						
				if (light_shadow == 1)
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
					float intensity = light_intensity;
					
					vec3 light_dir = normalize(light_view_pos - view_pos);
					
					out_color.rgb += CookTorrance2(light_dir, normal,  view_pos, metallic, roughness) * intensity * fade * 2;
					
					/*
					float specular = cookTorranceSpecular(
						normalize(-light_view_pos), 
						normal, 
						normalize(-view_pos), 
						roughness*2,
						metallic
					);
										
					out_color.rgb += light_color.rgb + (light_color.rgb * specular) * (intensity * fade * 2);
					*/
				}
			
				out_color.a = 1;
			}
		]]  
	}
}

render.RegisterGBufferPass(PASS)