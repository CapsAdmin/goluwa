local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render
       
render.gbuffer = NULL
render.shadow_maps = render.shadow_maps or setmetatable({}, { __mode = 'v' })
   
local FRAMEBUFFERS = {
	{
		name = "diffuse",
		attach = "color",
		texture_format = {
			internal_format = "RGBA16F",
			min_filter = "nearest",
		}
	},
	{
		name = "normal",
		attach = "color",
		texture_format = {
			internal_format = "RGBA16F",
			min_filter = "nearest",
		}
	},
	{
		name = "position",
		attach = "color",
		texture_format = {
			internal_format = "RGBA16F",
			min_filter = "nearest",
		}
	},
	{
		name = "light",
		attach = "color",
		texture_format = {
			internal_format = "RGBA16F",
			min_filter = "nearest",
		}
	},
	{
		name = "depth",
		attach = "depth",
		draw_manual = true,
		texture_format = {
			internal_format = "DEPTH_COMPONENT32F",	 
			depth_texture_mode = gl.e.GL_RED,
			min_filter = "nearest",				
		} 
	} 
} 

local MESH = {
	name = "mesh_ecs",
	vertex = { 
		uniform = {
			pvm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},	
		source = "gl_Position = pvm_matrix * vec4(pos, 1.0);"
	}, 
	--[==[tess_control = {
		uniform = {
			cam_pos = "vec3",
			tess_scale = 4;
		},
		attributes = {
			{pos = "vec3"},
		},
		source = [[			
			layout(vertices = 3) out;
			
			out vec4 SIGH[];
			
			void main()
			{			
				SIGH[gl_InvocationID] = LOL[gl_InvocationID];

				if(gl_InvocationID == 0) {
				   vec3 terrainpos = cam_pos;
				   terrainpos.z -= clamp(terrainpos.z,-0.1, 0.1); 
				   
				   vec4 center = (LOL[1]+LOL[2])/2.0;
				   gl_TessLevelOuter[0] = min(6.0, 1+tess_scale*0.5/distance(center.xyz, terrainpos));
				   
				   center = (LOL[2]+LOL[0])/2.0;				   
				   gl_TessLevelOuter[1] = min(6.0, 1+tess_scale*0.5/distance(center.xyz, terrainpos));
				   
				   center = (LOL[0]+LOL[1])/2.0;				   
				   gl_TessLevelOuter[2] = min(6.0, 1+tess_scale*0.5/distance(center.xyz, terrainpos));
				   
				   center = (LOL[0]+LOL[1]+LOL[2])/3.0;				   
				   gl_TessLevelInner[0] = min(7.0, 1+tess_scale*0.7/distance(center.xyz, terrainpos));
				}
			};
		]]
	},
	tess_eval = {
		uniform = {
			v_matrix = "mat4",
		},
		attributes = {
			{pos = "vec3"},
		}, 
		source = [[
			uniform sampler2D displacement;
			
			layout(triangles, equal_spacing, cw) in;
			
			in vec4 SIGH[];
			out vec2 tecoord;
			out vec4 teposition;
			
			void main()
			{
			   teposition = gl_TessCoord.x * SIGH[0];
			   teposition += gl_TessCoord.y * SIGH[1];
			   teposition += gl_TessCoord.z * SIGH[2];
			   tecoord = teposition.xy;
			   vec3 offset = texture(displacement, tecoord).xyz;
			   teposition.xyz = offset;
			   gl_Position = v_matrix * teposition;
			};
		]]
	},]==]
	fragment = { 
		uniform = {
			color = Color(1,1,1,1),
			diffuse = "sampler2D",
			diffuse2 = "sampler2D",
			vm_matrix = "mat4",
			v_matrix = "mat4",
			--detail = "sampler2D",
			--detailscale = 1,
			
			bump = "sampler2D",
			specular = "sampler2D",
		},		
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},			
		source = [[
			out vec4 out_color[4];

			void main() 
			{
				// diffuse
				out_color[0] = mix(texture(diffuse, uv), texture(diffuse2, uv), texture_blend) * color;			
				
				// specular
				out_color[0].a = texture2D(specular, uv).r;
				
				// normals
				{
					out_color[1] = vec4(normalize(mat3(vm_matrix) * -normal), 1);
									
					vec3 bump_detail = texture(bump, uv).rgb;
					
					if (bump_detail != vec3(1,1,1))
					{
						out_color[1].rgb = normalize(mix(out_color[1].rgb, bump_detail, 0.5));
					}
				}
				
				// position
				out_color[2] = vm_matrix * vec4(pos, 1);
								
				//out_color.rgb *= texture(detail, uv * detailscale).rgb;
			}
		]]
	}  
}

local LIGHT = {
	name = "gbuffer_light",
	vertex = { 
		uniform = {
			pvm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},	
		source = "gl_Position = pvm_matrix * vec4(pos*4, 1);"
	}, 
	fragment = {
		uniform = {
			tex_depth = "sampler2D",
			tex_diffuse = "sampler2D",
			tex_normal = "sampler2D",
			tex_position = "sampler2D",
			
			p_matrix_inverse = "mat4",
			
			tex_shadow_map = "sampler2D",
			light_vp_matrix = "mat4",
			
			cam_pos = "vec3",
			cam_dir = "vec3",
			cam_nearz = "float",
			cam_farz = "float",
			screen_size = Vec2(1,1),
						
			light_pos = Vec3(0,0,0),
			light_dir = Vec3(0,0,0),
			light_color = Color(1,1,1,1),				
			light_ambient_intensity = 0,
			light_diffuse_intensity = 0.5,
			light_specular_power = 64,
			light_radius = 1000,
			light_attenuation_constant = 0,
			light_attenuation_linear = 0,
			light_attenuation_exponent = 0.01,
		},  
		source = [[			
			out vec4 out_color;
			
			vec2 get_uv()
			{
				return gl_FragCoord.xy / screen_size;
			}
			
			float get_depth(vec2 coord) 
			{
				return (2.0 * cam_nearz) / (cam_farz + cam_nearz - texture2D(tex_depth, coord).r * (cam_farz - cam_nearz));
			}
			
			vec3 get_pos()
			{ 
				
				vec2 uv = get_uv();
				{return -texture(tex_position, uv).yxz;}
				
				vec4 pos = vec4(uv.x, uv.y, 2 * texture(tex_depth, uv.xy).x - 1, 1.0);
				pos = p_matrix_inverse * pos; 
				return pos.yxz / pos.w;
			}
			
			vec4 calc_light_internal(vec3 light_direction, vec3 world_pos, vec3 normal, float specular)
			{
				vec4 ambient_color = light_color * light_ambient_intensity;
				float diffuse_factor = dot(normal, -light_direction);

				vec4 diffuse_color  = vec4(0, 0, 0, 0);
				vec4 specular_color = vec4(0, 0, 0, 0);

				if (diffuse_factor > 0) 
				{
					diffuse_color = light_color * light_diffuse_intensity * diffuse_factor * 0.5;
										
					if (specular > 0 && light_specular_power > 0)
					{

						vec3 vertex_to_eye = normalize(cam_pos - world_pos);
						vec3 light_reflect = normalize(reflect(light_direction, normal));
						
						float specular_factor = dot(vertex_to_eye, light_reflect);
						specular_factor = pow(specular_factor, light_specular_power);
								
						if (specular_factor > 0) 
						{
							specular_color = light_color * specular * specular_factor;
						}
					}
				}

				return (ambient_color + diffuse_color + specular_color);
			}
			
			vec4 calc_point_light(vec3 world_pos, vec3 normal, float specular)
			{
				vec3 light_direction = world_pos - light_pos;
				float distance = length(light_direction);
				
				if (distance > light_radius * 10)
					return vec4(0,0,0,0);
				
				light_direction = normalize(light_direction);

				vec4 color = calc_light_internal(light_direction, world_pos, normal, specular);

				float attenuation =  light_attenuation_constant +
									 light_attenuation_linear * distance +
									 light_attenuation_exponent * distance * distance;

				attenuation = min(1.0, attenuation);
				
				
				return color / attenuation;
			}
			
			vec4 calc_point_light2(vec3 diffuse, float specular, vec3 normal, vec3 world_pos)
			{																			
				vec3 final_color = vec3(0);
				
				vec3 light_vec = light_pos - world_pos;
				float light_dist = length(light_vec);
				
				if (light_dist > light_radius * 20) 
				{
					return vec4(final_color, 1);
				}
				
				vec3 light_dir = normalize(light_vec);
				
				float lambertian = dot(light_dir, normal);
	
				if (lambertian > 0.0)
				{						
					vec3 R = reflect(-light_dir, normal);
					  
					vec3 half_dir = normalize(light_dir + -cam_dir);
					float spec_angle = max(dot(R, half_dir), 0.0);
					float S = pow(spec_angle, light_specular_power);
					
					final_color = (lambertian * diffuse + S * specular) * light_color.rgb;
				}
						
				final_color = final_color / light_dist * light_diffuse_intensity*50;
				
				return vec4(final_color, 1);
			}
			
			vec4 CookTorrance(vec3 _normal, vec3 _light, vec3 _view, float _fresnel, float _roughness)
			{
			  vec3  half_vec = normalize( _view + _light ); // вектор H
			  // теперь вычислим разнообразные скалярные произведения
			  float NdotL = max( dot(_normal, _light), 0.0 );
			  float NdotV = max( dot(_normal, _view), 0.0 );
			  float NdotH = max( dot(_normal, half_vec), 1.0e-7 );
			  float VdotH = max( dot(_view, half_vec), 1.0e-7 );

			  // геометрическая составляющая
			  float geometric = 2.0 * NdotH / VdotH;
			  geometric = min( 1.0, geometric * min(NdotV, NdotL) );

			  // шероховатость
			  float r_sq = _roughness * _roughness;
			  float NdotH_sq = NdotH * NdotH;
			  float NdotH_sq_r = 1.0 / (NdotH_sq * r_sq);
			  float roughness_exp = (NdotH_sq - 1.0) * ( NdotH_sq_r );
			  float roughness = 0.25 * exp(roughness_exp) * NdotH_sq_r / NdotH_sq;

			  // финальный результат
			  return vec4(vec3(min(1.0, _fresnel * geometric * roughness / (NdotV + 1.0e-7))), 1);
			}
	
			
			vec4 CookTorrance2(/*vec3 diffuse, */vec3 normal, vec3 world_pos, float specular)
			{
				float roughness = 0.1;

				// light, eye, normal, half vectors	
				vec3 dir = (light_pos - world_pos);
				
				//if (length(dir) > light_radius*20) 
				{
					//return vec4(0,0,0, 1);
				}
				
				vec3 cLight = normalize(dir);
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
				
				vec4 diffuse_ = light_color * max(0.0, normalDotLight);
				vec4 specular_ = light_color * max(0.0, CookTorrance) * specular;
				
				vec4 aaa = (diffuse_ + specular_) * max(0.0, normalDotLight) * light_diffuse_intensity;
				
				aaa.a = 1;
				
				return aaa;
			}
			
					
			float is_in_shadow(vec3 light_space_pos, float z)
			{
				//if (light_space_pos.x > 1 || light_space_pos.x < -1) return 0;
				//if (light_space_pos.y > 1 || light_space_pos.y < -1) return 0;
				//if (light_space_pos.z > 1 || light_space_pos.z < -1) return 0;
			
				float depth = texture(tex_shadow_map, 0.5 * light_space_pos.xy + 0.5).x;
			
				return depth;//z > depth ? 0 : 1;
			}
			
			
			void main()
			{					
				vec2 uv = get_uv();
				
				float specular = texture(tex_diffuse, uv).a;
				vec3 world_pos = get_pos();				
				vec3 normal = texture(tex_normal, uv).yxz;
				    
				out_color = CookTorrance2(normal, world_pos, specular);
				//out_color = CookTorrance(normal, normalize(light_pos - world_pos), -cam_dir, 1, 0.8);
				//out_color += calc_point_light(world_pos, normal, specular);
				//out_color = vec4(0.02,0.02,0.02,1);
				
				/*
				vec4 temp1 = light_vp_matrix * vec4(light_pos, 1);
				vec3 light_pos2 = vec3(temp1.xyz) / temp1.w;
				
				vec4 temp = vec4(world_pos.xyz, 1) * light_vp_matrix;
				vec3 light_space_pos = vec3(temp.xyz) / temp.w;
				
				//float z = texture(tex_depth, uv).x;
				float z = get_depth(uv);
				//float z2 = length((light_pos - light_space_pos))/95;

				out_color.rgb = vec3(is_in_shadow(light_space_pos, z));
				*/
				//out_color = calc_point_light2(texture(tex_diffuse, uv).rgb, specular, normal, world_pos);
			}
		]]  
	}
} 

local GBUFFER = {
	name = "gbuffer",
	vertex = {
		uniform = {
			pvm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = "gl_Position = pvm_matrix * vec4(pos, 0.0, 1.0);"
	},
	fragment = {
		uniform = {
			tex_diffuse = "sampler2D",
			tex_light = "sampler2D",
			tex_normal = "sampler2D",
			tex_position = "sampler2D", 
			tex_depth = "sampler2D",
			tex_noise = "sampler2D",
						
			width = "float",
			height = "float",
			time = "float",
			
			cam_pos = "vec3",
			cam_vec = "vec3",
			cam_fov = "float",
			cam_nearz = "float",
			cam_farz = "float",
			
			pv_matrix = "mat4",
			v_matrix = "mat4",
			p_matrix_inverse = "mat4",
		},  
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = [[
			out vec4 out_color;
			
			vec3 get_pos()
			{ 
				{return -texture(tex_position, uv).yxz;}
				
				vec4 pos = vec4(uv.x, uv.y, 2 * texture(tex_depth, uv).x - 1, 1.0);

				pos = p_matrix_inverse * pos; 

				return pos.xyz / pos.w;
			}
			
			float get_depth(vec2 coord) 
			{
				return (2.0 * cam_nearz) / (cam_farz + cam_nearz - texture2D(tex_depth, coord).r * (cam_farz - cam_nearz));
			}
			
			//
			//SSAO
			//
			float compareDepths( in float depth1, in float depth2 ) {
				float aoCap = 0.25;
				float aoMultiplier=1500.0;
				float depthTolerance=0.0000;
				float aorange = 100000.0;// units in space the AO effect extends to (this gets divided by the camera far range
				float diff = sqrt( clamp(1.0-(depth1-depth2) / (aorange/(cam_farz-cam_nearz)),0.0,1.0) );
				float ao = min(aoCap,max(0.0,depth1-depth2-depthTolerance) * aoMultiplier) * diff;
				return ao;
			}

			float ssao()
			{

				float depth = get_depth(uv);
				float d;

				float pw = 1.0 / width;
				float ph = 1.0 / height;

				float ao = 2;
				
				float aoscale=0.4;

				for (int i = 1; i < 5; i++)
				{					
					ao += compareDepths(depth, get_depth(vec2(uv.x+pw,uv.y+ph))) / aoscale;
					ao += compareDepths(depth, get_depth(vec2(uv.x-pw,uv.y+ph))) / aoscale;
					ao += compareDepths(depth, get_depth(vec2(uv.x+pw,uv.y-ph))) / aoscale;
					ao += compareDepths(depth, get_depth(vec2(uv.x-pw,uv.y-ph))) / aoscale;
				 
					pw *= 2.0;
					ph *= 2.0;
					aoscale *= 1.2;
				}			 
			 
				ao/=16.0;
			 
				return 1-ao;
			}
			
			//
			//FOG
			//
			vec3 mix_fog(vec3 color, float depth, float fog_intensity, vec3 fog_color)
			{
				color = mix( 1 - fog_color, color, clamp(1.0 - (pow(depth, fog_intensity)), 0.0, 1.0));
				
				return color;
			}
									
			void main ()
			{			
				vec3 diffuse = texture(tex_diffuse, uv).rgb;
				float depth = get_depth(uv);
				
				out_color.rgb = diffuse;
				out_color.a = 1;

				vec3 ambient_light_color = vec3(191.0 / 255.0, 205.0 / 255.0, 214.0 / 255.0) * 0.9;
				vec3 atmosphere_color = ambient_light_color;
				vec3 fog_color = atmosphere_color;
				float fog_distance = 750.0;
				
				out_color.rgb *= vec3(ssao());
				out_color.rgb *= texture(tex_light, uv).rgb;
				
				
				/*
				// debug get_pos
				vec3 wpos = -get_pos().yxz; 
				
				if (length(wpos - vec3(0,0,0)) < 10)
				{
					out_color.rgb = vec3(1,1,1);
				}*/
				
				out_color.rgb = mix_fog(out_color.rgb, depth, fog_distance, 1-fog_color); //this fog is fucked up, needs to be redone
								
			}
		]]  
	}
}  

local SHADOW = {
	name = "shadow_map",
	vertex = { 
		uniform = {
			pvm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec3"},
		},	
		source = "gl_Position = pvm_matrix * vec4(pos, 1);"
	},
	fragment = {	
		source = ""
	}  
}

local EFFECTS = {
	{
		name = "fxaa",
		source = [[
			out vec4 out_color;
					
			//
			//FXAA
			//
			float FXAA_SPAN_MAX = 8.0;
			float FXAA_REDUCE_MUL = 1.0/8.0;
			float FXAA_SUBPIX_SHIFT = 1.0/128.0;

			#define FxaaInt2 ivec2
			#define FxaaFloat2 vec2
			#define FxaaTexLod0(t, p) textureLod(t, p, 0.0)
			#define FxaaTexOff(t, p, o, r) textureLodOffset(t, p, 0.0, o)
			
			vec2 rcpFrame = vec2(1.0/width, 1.0/height);
			vec4 posPos = vec4(uv, uv - (rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT)));

			vec3 FxaaPixelShader(vec4 posPos, sampler2D tex)
			{   

				#define FXAA_REDUCE_MIN   (1.0/128.0)
				//#define FXAA_REDUCE_MUL   (1.0/8.0)
				//#define FXAA_SPAN_MAX     8.0
				

				vec3 rgbNW = FxaaTexLod0(tex, posPos.zw).xyz;
				vec3 rgbNE = FxaaTexOff(tex, posPos.zw, FxaaInt2(1,0), rcpFrame.xy).xyz;
				vec3 rgbSW = FxaaTexOff(tex, posPos.zw, FxaaInt2(0,1), rcpFrame.xy).xyz;
				vec3 rgbSE = FxaaTexOff(tex, posPos.zw, FxaaInt2(1,1), rcpFrame.xy).xyz;
				vec3 rgbM  = FxaaTexLod0(tex, posPos.xy).xyz;
				

				vec3 luma = vec3(0.299, 0.587, 0.114);
				float lumaNW = dot(rgbNW, luma);
				float lumaNE = dot(rgbNE, luma);
				float lumaSW = dot(rgbSW, luma);
				float lumaSE = dot(rgbSE, luma);
				float lumaM  = dot(rgbM,  luma);
				
				float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
				float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

				
				vec2 dir; 
				dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
				dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));


				float dirReduce = max(
					(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
					FXAA_REDUCE_MIN);
				float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
				dir = min(FxaaFloat2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX), 
					  max(FxaaFloat2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), 
					  dir * rcpDirMin)) * rcpFrame.xy;


				vec3 rgbA = (1.0/2.0) * (
					FxaaTexLod0(tex, posPos.xy + dir * (1.0/3.0 - 0.5)).xyz +
					FxaaTexLod0(tex, posPos.xy + dir * (2.0/3.0 - 0.5)).xyz);
					
				vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
					FxaaTexLod0(tex, posPos.xy + dir * (0.0/3.0 - 0.5)).xyz +
					FxaaTexLod0(tex, posPos.xy + dir * (3.0/3.0 - 0.5)).xyz);
					
				float lumaB = dot(rgbB, luma);

				if ((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;

				return rgbB; 
			}
			
			void main() 
			{ 
				out_color.rgb = FxaaPixelShader(posPos, tex_gbuffer);
				out_color.a = 1;
			}
		]],
	},
	
	--[==[
	{
		name = "contrast",
		source = [[
			out vec4 out_color;

			void main() 
			{ 
				out_color = pow(texture(tex_last, uv), vec4(4))*500;
				out_color.a = 1;
			}
		]],
	},
	{
		down_sample = 2,
		name = "blur_1",
		source = [[
			out vec4 out_color;

			vec4 blur(sampler2D tex, vec2 uv)
			{			
				float dx = 1  / width;
				float dy = 1 / height;
				
				// Apply 3x3 gaussian filter
				vec4 color = 4.0 * texture(tex, uv);
				color += texture(tex, uv + vec2(+dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(-dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(0.0, +dy)) * 2.0;
				color += texture(tex, uv + vec2(0.0, -dy)) * 2.0;
				color += texture(tex, uv + vec2(+dx, +dy));
				color += texture(tex, uv + vec2(-dx, +dy));
				color += texture(tex, uv + vec2(-dx, -dy));
				color += texture(tex, uv + vec2(+dx, -dy));
				
				return color / 16.0;
			}

			void main() 
			{ 
				out_color = blur(tex_last, uv);
				
				out_color.a = 1;
			}
		]],
	},	
	{
		down_sample = 4,
		name = "blur_2",
		source = [[
			out vec4 out_color;

			vec4 blur(sampler2D tex, vec2 uv)
			{			
				float dx = 1  / width;
				float dy = 1 / height;
				
				// Apply 3x3 gaussian filter
				vec4 color = 4.0 * texture(tex, uv);
				color += texture(tex, uv + vec2(+dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(-dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(0.0, +dy)) * 2.0;
				color += texture(tex, uv + vec2(0.0, -dy)) * 2.0;
				color += texture(tex, uv + vec2(+dx, +dy));
				color += texture(tex, uv + vec2(-dx, +dy));
				color += texture(tex, uv + vec2(-dx, -dy));
				color += texture(tex, uv + vec2(+dx, -dy));
				
				return color / 16.0;
			}

			void main() 
			{ 
				out_color = blur(tex_last, uv);
				
				out_color.a = 1;
			}
		]],
	},	
	{
		down_sample = 8,
		name = "blur_3",
		source = [[
			out vec4 out_color;

			vec4 blur(sampler2D tex, vec2 uv)
			{			
				float dx = 1  / width;
				float dy = 1 / height;
				
				// Apply 3x3 gaussian filter
				vec4 color = 4.0 * texture(tex, uv);
				color += texture(tex, uv + vec2(+dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(-dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(0.0, +dy)) * 2.0;
				color += texture(tex, uv + vec2(0.0, -dy)) * 2.0;
				color += texture(tex, uv + vec2(+dx, +dy));
				color += texture(tex, uv + vec2(-dx, +dy));
				color += texture(tex, uv + vec2(-dx, -dy));
				color += texture(tex, uv + vec2(+dx, -dy));
				
				return color / 16.0;
			}

			void main() 
			{ 
				out_color = blur(tex_last, uv);
				
				out_color.a = 1;
			}
		]],
	},		
	{		
		name = "hdr",
		source = [[
			out vec4 out_color;

			void main() 
			{ 
				out_color = texture(tex_last, uv) * texture(tex_gbuffer, uv);
				out_color.a = 1;
			}
		]],
	},	
	
	]==]
}

render.pp_shaders = {}

function render.AddPostProcessShader(name, source, priority, down_sample)
	priority = priority or #render.pp_shaders
	down_sample = down_sample or 1
	
	local width = render.GetWidth() / down_sample
	local height = render.GetHeight() / down_sample  
	
	local shader = render.CreateShader({
		name = "gbuffer_post_process_" .. name,
		vertex = {
			uniform = {
				pvm_matrix = "mat4",
			},			
			attributes = {
				{pos = "vec2"},
				{uv = "vec2"},
			},
			source = "gl_Position = pvm_matrix * vec4(pos, 0.0, 1.0);"
		},
		fragment = {
			uniform = {
				tex_gbuffer = "sampler2D",
				tex_last = "sampler2D",
				tex_light = "sampler2D",
				tex_diffuse = "sampler2D",
				tex_normal = "sampler2D",
				tex_depth = "sampler2D",
				
				width = "float",
				height = "float",
			},
			attributes = {
				{pos = "vec2"},
				{uv = "vec2"},
			},
			source = source
		}
	})
	
	local buffer = render.CreateFrameBuffer(width, height, {
		{
			name = "tex_last",
			attach = "color",
			texture_format = {
				internal_format = "RGBA16F",
				min_filter = "nearest",
			}
		},
	})
	
	shader.pvm_matrix = render.GetPVWMatrix2D
	shader.tex_last = buffer:GetTexture("tex_last")
	shader.tex_gbuffer = render.screen_buffer:GetTexture("screen_buffer")
	
	shader.tex_light = render.gbuffer:GetTexture("light")
	shader.tex_diffuse = render.gbuffer:GetTexture("diffuse")
	shader.tex_position = render.gbuffer:GetTexture("position") 
	shader.tex_normal = render.gbuffer:GetTexture("normal")
	shader.tex_depth = render.gbuffer:GetTexture("depth")
	shader.p_matrix_inverse = function() return ((render.matrices.view_3d * render.matrices.projection_3d):GetInverse()).m end
	
	shader.width = width
	shader.height = height
		
	local quad = shader:CreateVertexBuffer({
		{pos = {0, 0}, uv = {0, 1}},
		{pos = {0, 1}, uv = {0, 0}},
		{pos = {1, 1}, uv = {1, 0}},

		{pos = {1, 1}, uv = {1, 0}},
		{pos = {1, 0}, uv = {1, 1}},
		{pos = {0, 0}, uv = {0, 1}},
	})

	for k, v in pairs(render.pp_shaders) do
		if v.name == name then
			table.remove(render.pp_shaders, k)
			break
		end
	end
	
	table.insert(render.pp_shaders, {shader = shader, quad = quad, buffer = buffer, name = name, priority = priority, w = width, h = height, down_sample = down_sample})
	
	table.sort(render.pp_shaders, function(a, b) return a.priority < b.priority end)
end
 
local sphere = NULL

function render.InitializeGBuffer(width, height)
	width = width or render.GetWidth()
	height = height or render.GetHeight()
	
	if width == 0 or height == 0 then return end
	
	logn("[render] initializing gbuffer: ", width, " ", height)
	
	local noise = Texture(width, height):Fill(function() 
		return math.random(255), math.random(255), math.random(255), math.random(255)
	end)
	
	do -- gbuffer	  
		render.gbuffer = render.CreateFrameBuffer(width, height, FRAMEBUFFERS)  
		
		if not render.gbuffer:IsValid() then
			logn("[render] failed to initialize gbuffer")
			return
		end

		local shader = render.CreateShader(GBUFFER)
		
		shader.pvm_matrix = render.GetPVWMatrix2D
		shader.v_matrix = function() return (render.matrices.view_3d).m end
		shader.pv_matrix = function() return (render.matrices.projection_3d*render.matrices.view_3d).m end
		shader.p_matrix_inverse = function() return ((render.matrices.view_3d * render.matrices.projection_3d):GetInverse()).m end
		shader.cam_pos = render.GetCamPos
		shader.cam_vec = function() return render.GetCamAng():GetRad():GetForward() end
		shader.cam_fov = function() return math.rad(render.GetCamFOV()) end
		shader.cam_nearz = function() return render.camera.nearz end
		shader.cam_farz = function() return render.camera.farz end
		shader.time = function() return tonumber(timer.GetSystemTime()) end
		 
		shader.tex_light = render.gbuffer:GetTexture("light")
		shader.tex_diffuse = render.gbuffer:GetTexture("diffuse")
		shader.tex_position = render.gbuffer:GetTexture("position") 
		shader.tex_normal = render.gbuffer:GetTexture("normal")
		shader.tex_depth = render.gbuffer:GetTexture("depth")
		shader.tex_noise = noise
		
		shader.width = width
		shader.height = height

		local vbo = shader:CreateVertexBuffer({
			{pos = {0, 0}, uv = {0, 1}},
			{pos = {0, 1}, uv = {0, 0}},
			{pos = {1, 1}, uv = {1, 0}},

			{pos = {1, 1}, uv = {1, 0}},
			{pos = {1, 0}, uv = {1, 1}},
			{pos = {0, 0}, uv = {0, 1}},
		})
		
		render.gbuffer_shader = shader
		render.gbuffer_screen_quad = vbo
	end
	
	do -- light
		local shader = render.CreateShader(LIGHT)

		shader.pvm_matrix = render.GetPVWMatrix2D
		shader.cam_dir = function() return render.GetCamAng():GetRad():GetForward() end
		shader.cam_pos = render.GetCamPos
		shader.cam_nearz = function() return render.camera.nearz end
		shader.cam_farz = function() return render.camera.farz end
		 
		shader.tex_depth = render.gbuffer:GetTexture("depth")
		shader.tex_diffuse = render.gbuffer:GetTexture("diffuse")
		shader.tex_position = render.gbuffer:GetTexture("position")
		shader.tex_normal = render.gbuffer:GetTexture("normal")
		shader.screen_size = Vec2(width, height)
		shader.p_matrix_inverse = function() return ((render.matrices.view_3d * render.matrices.projection_3d):GetInverse()).m end
		
		render.gbuffer_light_shader = shader
	end
	
	do -- mesh		
		render.gbuffer_mesh_shader = render.CreateShader(MESH)
		render.shadow_map_shader = render.CreateShader(SHADOW)
	end
			
	event.AddListener("WindowFramebufferResized", "gbuffer", function(window, w, h)
		render.InitializeGBuffer(w, h)
	end)
	
	event.AddListener("Draw2D", "gbuffer_debug", function()
		local size = 4
		local w, h = surface.GetScreenSize()
		if render.debug then
			w = w / size
			h = h / size
			
			local x = 0
			local y = 0
						
			local grey = 0.5 + math.sin(os.clock() * 10) / 10
			surface.SetFont("default")
			
			for i, data in pairs(FRAMEBUFFERS) do
				surface.SetWhiteTexture()
				surface.SetColor(grey, grey, grey, 1)
				surface.DrawRect(x, y, w, h)
				
				surface.SetColor(1,1,1,1)
				surface.SetTexture(render.gbuffer:GetTexture(data.name))
				surface.DrawRect(x, y, w, h)
				
				surface.SetTextPos(x, y + 5)
				surface.DrawText(data.name)
				
				if i%size == 0 then
					y = y + h
					x = 0
				else
					x = x + w
				end
			end
			
			local i = 1
						
			for light, map in pairs(render.shadow_maps) do
				local tex = map:GetTexture("depth")
		
			
				surface.SetWhiteTexture()
				surface.SetColor(grey, grey, grey, 1)
				surface.DrawRect(x, y, w, h)
				
				surface.SetColor(1,1,1,1)
				surface.SetTexture(tex)
				surface.DrawRect(x, y, w, h)
				
				surface.SetTextPos(x, y + 5)
				surface.DrawText(light)
				
				if i%size == 0 then
					y = y + h
					x = 0
				else
					x = x + w
				end
				
				i = i + 1
			end
			
			
		end
	end)
	
	render.screen_buffer = render.CreateFrameBuffer(width, height, {
		{
			name = "screen_buffer",
			attach = "color",
			texture_format = {
				internal_format = "RGBA16F",
				min_filter = "nearest",
			}
		},
	})

	for i, data in pairs(EFFECTS) do
		render.AddPostProcessShader(data.name, data.source, i, data.down_sample)
	end	
end

function render.ShutdownGBuffer()
	event.RemoveListener("PreDisplay", "gbuffer")
	event.RemoveListener("PostDisplay", "gbuffer")
	event.RemoveListener("WindowFramebufferResized", "gbuffer")
	
	if render.gbuffer:IsValid() then
		render.gbuffer:Remove()
	end
	
	if render.gbuffer_shader:IsValid() then
		render.gbuffer_shader:Remove()
	end
	
	if render.gbuffer_screen_quad:IsValid() then
		render.gbuffer_screen_quad:Remove()
	end
	
	logn("[render] gbuffer shutdown")
end

local size = 4

function render.DrawDeferred(w, h)

	-- geometry
	gl.DepthMask(gl.e.GL_TRUE)
	gl.Enable(gl.e.GL_DEPTH_TEST)
	gl.Disable(gl.e.GL_BLEND)	
	
	render.gbuffer:Begin()
		render.gbuffer:Clear()
		event.Call("Draw3DGeometry", render.gbuffer_mesh_shader)
	render.gbuffer:End()
	
	event.Call("DrawShadowMaps", render.shadow_map_shader)	
	
	-- light
	gl.DepthMask(gl.e.GL_FALSE)
	gl.Disable(gl.e.GL_DEPTH_TEST)	
	gl.Enable(gl.e.GL_BLEND)
	render.SetBlendMode("additive")
	
	render.gbuffer:Begin("light")
		event.Call("Draw3DLights", render.gbuffer_light_shader)
	render.gbuffer:End() 
	
	-- gbuffer
	render.SetBlendMode("alpha")	
	render.Start2D()
		-- draw to the pp buffer		
		local effect = render.pp_shaders[1]
		
		if effect then
			
			surface.PushMatrix(0,0,w,h)
				render.screen_buffer:Begin()
					render.gbuffer_shader:Bind()
					render.gbuffer_screen_quad:Draw()
				render.screen_buffer:End()
			surface.PopMatrix()
		
			for i = 0, #render.pp_shaders do 
				surface.PushMatrix()
					local next = render.pp_shaders[i+1]
					
					if not next then break end
					
					surface.Scale(next.w, next.h)						
						
					next.buffer:Begin()
						effect.shader:Bind()
						effect.quad:Draw()
					next.buffer:End()					
					
					effect = next
				surface.PopMatrix()
			end			
		
			
			-- draw the pp texture as quad
			surface.PushMatrix()
				surface.Scale(w, h)
				effect.shader:Bind()
				effect.quad:Draw()
			surface.PopMatrix()
		else
			surface.PushMatrix()
				surface.Scale(w, h)
				render.gbuffer_shader:Bind()
				render.gbuffer_screen_quad:Draw()
			surface.PopMatrix()		
		end		
	render.End2D()
end

local gbuffer_enabled = true

function render.EnableGBuffer(b)
	gbuffer_enabled = b
	if b then 
		render.InitializeGBuffer()
	else
		render.ShutdownGBuffer()
	end
end

if render.gbuffer_shader then
	render.InitializeGBuffer()
end

event.AddListener("RenderContextInitialized", nil, function() 
	local ok, err = xpcall(render.InitializeGBuffer, system.OnError)
	
	if not ok then
		logn("[render] failed to initialize gbuffer: ", err)
		render.ShutdownGBuffer()
	end
end)
