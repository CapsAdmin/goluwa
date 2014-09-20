local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render
       
render.gbuffer = NULL
render.shadow_maps = render.shadow_maps or utility.CreateWeakTable()
   
local FRAMEBUFFERS = {
	{
		name = "diffuse",
		attach = "color",
		texture_format = {
			internal_format = "RGBA8",
		}
	},
	{
		name = "normal",
		attach = "color",
		texture_format = {
			internal_format = "RGB16F",
		}
	},
	{
		name = "position",
		attach = "color",
		texture_format = {
			internal_format = "RGB16F",
		}
	},
	{
		name = "light",
		attach = "color",
		texture_format = {
			internal_format = "RGBA16F",
		}
	},
	{
		name = "depth",
		attach = "depth",
		draw_manual = true,
		texture_format = {
			internal_format = "DEPTH_COMPONENT32F",	 
			depth_texture_mode = gl.e.GL_RED,
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
				out_color[0].a = texture(specular, uv).r;
				
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
		source = "gl_Position = pvm_matrix * vec4(pos*7.5, 1);"
	},  
	fragment = {
		uniform = {
			tex_depth = "sampler2D",
			tex_diffuse = "sampler2D",
			tex_normal = "sampler2D",
			tex_position = "sampler2D",
			
			cam_pos = "vec3",
			light_pos = Vec3(0,0,0),
			
			screen_size = Vec2(1,1),						
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
			
			cam_nearz = "float",
			cam_farz = "float",
		},  
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = [[
			out vec4 out_color;
			
			vec3 get_pos()
			{ 
				return -texture(tex_position, uv).yxz;
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
			
				out_color.rgb = mix_fog(out_color.rgb, depth, fog_distance, 1-fog_color); //this fog is fucked up, needs to be redone
			
				out_color.rgb *= vec3(ssao());
				out_color.rgb *= texture(tex_light, uv).rgb;								
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
		name = "extract_bloom",
		source = [[
			out vec4 out_color;
			
			float brightThreshold = 0.01;
			
			void main() 
			{ 
				// Calculate luminance
				float lum = dot(vec4(0.30, 0.59, 0.11, 0.0), texture(tex_last, uv)); //MUST EXTRACT FROM LAST BUFFER AND STORE IN A NEW BUFFER
				
				// Extract very bright areas of the map
				if (lum > brightThreshold)
					out_color = texture(tex_last, uv);
				else
					out_color = vec4(0.0, 0.0, 0.0, 1.0);
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
				float dx = 2  / width;
				float dy = 2 / height;
				
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
		down_sample = 2,
		name = "blur_2",
		source = [[
			out vec4 out_color;

			vec4 blur(sampler2D tex, vec2 uv)
			{			
				float dx = 4  / width;
				float dy = 4 / height;
				
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
			
			float exposure = 0.5;
			float bloomFactor = 0.5;
			float brightMax = 2;
			
			void main() 
			{ 
				vec4 original_image = texture(tex_gbuffer, uv); 
				vec4 downsampled_extracted_bloom = texture(tex_last, uv);
				
				vec4 color = original_image + downsampled_extracted_bloom * bloomFactor;
				
				// Perform tone-mapping
				float Y = dot(vec4(0.30, 0.59, 0.11, 0.0), color);
				float YD = exposure * (exposure/brightMax + 1.0) / (exposure + 1.0);
				color *= YD;
				
				color.a = 1;
				
				out_color = color;
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
				internal_format = "RGBA8",
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
	
	if render.debug then
		logn("[render] initializing gbuffer: ", width, " ", height)
	end
	
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
		
		render.gbuffer_light_shader = shader
	end
	
	do -- mesh		
		render.gbuffer_mesh_shader = render.CreateShader(MESH)
		--render.shadow_map_shader = render.CreateShader(SHADOW)
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
				surface.SetRectUV(0,0,1,1)
				
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
				internal_format = "RGBA8",
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
local deferred = console.CreateVariable("r_deferred", true, "whether or not deferred rendering is enabled.")
function render.DrawDeferred(dt, w, h)

	if not deferred:Get() then
		render.Clear(1,1,1,1)
		gl.DepthMask(gl.e.GL_TRUE)
		gl.Enable(gl.e.GL_DEPTH_TEST)
		gl.Disable(gl.e.GL_BLEND)
		event.Call("Draw3DGeometry", render.gbuffer_mesh_shader)
		
		gl.Disable(gl.e.GL_DEPTH_TEST)	
		gl.Enable(gl.e.GL_BLEND)
		render.SetBlendMode("alpha")	
		render.SetCullMode("back")
		gl.Disable(gl.e.GL_DEPTH_TEST)
		event.Call("Draw2D", dt)
	return end
	
	render.Start3D()
		-- geometry
		gl.DepthMask(gl.e.GL_TRUE)
		gl.Enable(gl.e.GL_DEPTH_TEST)
		gl.Disable(gl.e.GL_BLEND)	
		render.SetCullMode("back")
		
		render.gbuffer:Begin()
			render.gbuffer:Clear()
			event.Call("Draw3DGeometry", render.gbuffer_mesh_shader)
		render.gbuffer:End()
		
		--event.Call("DrawShadowMaps", render.shadow_map_shader)	
		
		-- light
		
		gl.Disable(gl.e.GL_DEPTH_TEST)	
		gl.Enable(gl.e.GL_BLEND)
		gl.BlendFunc(gl.e.GL_ONE, gl.e.GL_ONE)
		render.SetCullMode("front")
		
		render.gbuffer:Begin("light")
			render.gbuffer:Clear(0,0,0,0, "light")
			event.Call("Draw3DLights", render.gbuffer_light_shader)
		render.gbuffer:End() 
	render.End3D()
			
	-- gbuffer
	render.SetBlendMode("alpha")	
	render.SetCullMode("back")
	render.Start2D()
		-- draw to the pp buffer		
		local effect = render.pp_shaders[1]
		
		local shader
		local quad
		
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
					
					if not next then
						surface.PopMatrix()
					break end
					
					surface.Scale(next.w, next.h)						
						
					next.buffer:Begin()
						effect.shader:Bind()
						effect.quad:Draw()
					next.buffer:End()					
					
					effect = next
				surface.PopMatrix()
			end			
			
			shader = effect.shader
			quad = effect.quad
		else
			shader = render.gbuffer_shader
			quad = render.gbuffer_screen_quad
		end	
		
		surface.PushMatrix()
			surface.Scale(w, h)
			shader:Bind()
			quad:Draw()
		surface.PopMatrix()
						
		event.Call("Draw2D", dt)
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
