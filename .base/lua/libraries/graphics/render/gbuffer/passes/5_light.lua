local render = ... or _G.render

local gl = require("lj-opengl")

local PASS = {}

PASS.Name = "light"
PASS.Stage = FILE_NAME:sub(1, 1)

PASS.Buffers = {
	{"light", "RGBA16F"},
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
			pvm_matrix = {mat4 = render.GetPVWMatrix2D},
		},			
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},	
		source = "gl_Position = pvm_matrix * vec4(pos, 1);"
	},
	fragment = { 
		uniform = {				
			tex_depth = "sampler2D",
			tex_diffuse = "sampler2D",
			tex_normal = "sampler2D",
			tex_illumination = "sampler2D",
			
			tex_shadow_map_cube = "samplerCube",
			tex_shadow_map = "sampler2D",
			
			light_pos = Vec3(0,0,0),
			light_dir = Vec3(0,0,0),
			
			screen_size = {vec2 = render.GetGBufferSize},
			light_color = Color(1,1,1,1),				
			light_diffuse_intensity = 0.5,
			light_radius = 1000,
			light_vp_matrix = "mat4",
			light_specular_intensity = 1,
			light_roughness = 0.5,
			light_shadow = 0,
			light_point_shadow = 0, 
			project_from_camera = 0,
			cascade_pass = 1,
			
			inverse_projection = "mat4",
			inverse_view_projection = "mat4",
		},  
		source = [[			
			out vec4 out_color;
			
			vec2 get_uv()
			{
				return gl_FragCoord.xy / screen_size;
			}
			
			vec3 get_pos(vec2 uv)
			{
				vec4 pos = inverse_projection * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
				return pos.xyz / pos.w;
			}
			
			
			#define EPSILON 0.00001			
			#extension GL_NV_shadow_samplers_cube:enable
			
			float rand(vec2 co){
				return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
			}
			
			vec2 poissonDisk[4] = vec2[](
			  vec2( -0.94201624, -0.39906216 ),
			  vec2( 0.94558609, -0.76890725 ),
			  vec2( -0.094184101, -0.92938870 ),
			  vec2( 0.34495938, 0.29387760 )
			);
			
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
					vec4 temp = light_vp_matrix * inverse_view_projection * vec4(uv * 2 - 1, texture(tex_depth, uv).r * 2 -1, 1.0);
					vec3 shadow_coord = (temp.xyz / temp.w);
					
					//if (shadow_coord.z < -1) return 0;
					
					if (shadow_coord.x > -1 && shadow_coord.x < 1 && shadow_coord.y > -1 && shadow_coord.y < 1 && shadow_coord.z > -1 && shadow_coord.z < 1)
					{	
						for (int i=0;i<4;i++)
						{
							if (texture(tex_shadow_map, 0.5 * shadow_coord.xy + vec2(0.5) + (poissonDisk[i]/5000.0)).r > ((0.5 * shadow_coord.z + 0.5)))
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
						
			float get_attenuation(vec3 world_pos, vec2 uv)
			{												
				if (project_from_camera == 1) return 1;
				
				float distance = length(light_pos - world_pos);
				distance = distance / light_radius;
				distance = -distance + 1;
				float fade = clamp(distance, 0, 1);
	
				return fade;
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
						
			void main()
			{
				out_color.rgb = vec3(0);
			
				vec2 uv = get_uv();					
				vec3 world_pos = get_pos(uv);	

				float fade = get_attenuation(world_pos, uv);
			
				if (light_shadow == 1)
				{
					float shadow = get_shadow(uv);
					
					if (shadow <= 1)
					{
						out_color.rgb += normalize(light_color.rgb) * light_diffuse_intensity*2;
					}
					
					fade *= shadow;
				}
				
				if (fade > 0)
				{							
					vec4 normal = texture(tex_normal, uv);							
					float specular = normal.a;
					vec3 light_dir = normalize(light_pos - world_pos);
					
					float intensity = light_diffuse_intensity;
					
					out_color.rgb += CookTorrance2(light_dir, normal.xyz,  world_pos, specular * light_specular_intensity, light_roughness) * intensity * fade * 2;
				}
			
				out_color.a = 1;
			}
		]]  
	}
}

render.RegisterGBufferPass(PASS)