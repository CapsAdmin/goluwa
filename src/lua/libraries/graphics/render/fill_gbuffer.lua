local render = ... or _G.render

local reflection_res_divider = 1

local PASS = {}

PASS.Buffers = {
	{
		name = "model",
		write = "all",
		layout =
		{
			{
				format = "rgba16f",

				albedo = "rgb",
				roughness = "a",
			},
			{
				format = "rgba16f",

				view_normal = "rgb",
				metallic = "a",
			},
		}
	},
	{
		name = "light",
		write = "self",
		layout = {
			{
				format = "rgba16f",

				specular = "rgb",
				shadow = "a",
			}
		},
	}
}

render.AddGlobalShaderCode([[
vec3 compute_specular(vec3 light_dir, vec3 vertex_eye, vec3 normal, float metallic, float roughness, vec3 albedo, vec3 color, float attenuation)
{
	/*float alpha = roughness*roughness;

	vec3 H = normalize(vertex_eye+light_dir);

	float dotNL = clamp(dot(normal,light_dir), 0.0, 1.0);

	float dotLH = clamp(dot(light_dir,H), 0.0, 1.0);
	float dotNH = clamp(dot(normal,H), 0.0, 1.0);

	float F, D, vis;

	// D
	float alphaSqr = alpha*alpha;
	float pi = 3.14159f;
	float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
	D = alphaSqr/(pi * denom * denom);

	// F
	float dotLH5 = pow(1.0f-dotLH,5);
	float F0 = 0.25;
	F = F0 + (1.0-F0)*(dotLH5);

	// V
	float k = alpha/2.0f;
	float k2 = k*k;
	float invK2 = 1.0f-k2;
	vis = (dotLH*dotLH*invK2 + k2);

	return color * ((dotNL * D * F * vis) * attenuation);*/

	float a = max( roughness * roughness, 2e-3 );
	float a2 = a * a + attenuation;

	vec3 H = normalize(light_dir + vertex_eye);
	float NdotH = clamp(dot(-normal,H), 0.0, 1.0);
	float VdotN = clamp(dot(vertex_eye,-normal), 0.0, 1.0);
	float LdotN = clamp(dot(light_dir,-normal), 0.0, 1.0);
	float VdotH = clamp(dot(vertex_eye,H), 0.0, 1.0);


	//horizon
	float atten = attenuation;
	float horizon = 1.0 - LdotN;
	horizon *= horizon; horizon *= horizon;
	atten = atten - atten * horizon;

	//incident light
	vec3 spec = color * (atten + attenuation * LdotN);

	//microfacet distribution
	float d = ( NdotH * a2 - NdotH ) * NdotH + 1.0;
	d *= d;
	float D = a2 / (3.141593 * d);

	//geometric / visibility
	float k = a * 0.5;
	float G_SmithL = LdotN * (1.0 - k) + k;
	float G_SmithV = VdotN * (1.0 - k) + k;
	float G = 0.25 / ( G_SmithL * G_SmithV );

	//fresnel
	float F = (1 + exp2( (-5.55473 * VdotH - 6.98316) * VdotH ));

	//final
	return (D * G) * (F * spec);
}
]])

render.AddGlobalShaderCode([[
vec3 get_view_pos(vec2 uv)
{
	vec4 pos = g_projection_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
	return pos.xyz / pos.w;
}]])

render.AddGlobalShaderCode([[
vec3 get_world_pos(vec2 uv)
{
	vec4 pos = g_view_inverse * g_projection_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
	return pos.xyz / pos.w;
}]])

render.AddGlobalShaderCode([[
vec3 get_view_normal_from_depth(vec2 uv)
{
	const vec2 offset1 = vec2(0.0,0.001);
	const vec2 offset2 = vec2(0.001,0.0);

	float depth = texture(tex_depth, uv).r;
	float depth1 = texture(tex_depth, uv + offset1).r;
	float depth2 = texture(tex_depth, uv + offset2).r;

	vec3 p1 = vec3(offset1, depth1 - depth);
	vec3 p2 = vec3(offset2, depth2 - depth);

	vec3 normal = cross(p1, p2);
	normal.z = -normal.z;

	return normalize(normal);
}]])

render.AddGlobalShaderCode([[
vec3 get_world_normal(vec2 uv)
{
	return normalize(-get_view_normal(uv) * mat3(g_view));
}]])

function PASS:Initialize()
	local META = self.model_shader:CreateMaterialTemplate(PASS.Name)

	function META:OnBind()
		if self.NoCull or self.Translucent then
			render.SetCullMode("none")
		else
			render.SetCullMode("front")
		end
		self.SkyTexture = render.GetSkyTexture()
		self.EnvironmentProbeTexture = render.GetEnvironmentProbeTexture()
		--self.EnvironmentProbePosition = render.GetEnvironmentProbeTexture().probe:GetPosition()
	end

	META:Register()
end

function PASS:Draw3D(what, dist)
	render.UpdateSky()

	render.SetBlendMode()
	render.EnableDepth(true)
	self:BeginPass("model")
		event.Call("PreGBufferModelPass")
			render.Draw3DScene(what or "models", dist)
		event.Call("PostGBufferModelPass")
	self:EndPass()

	render.EnableDepth(false)
	self:BeginPass("light")
		render.SetCullMode("back")
			event.Call("Draw3DLights")
		render.SetCullMode("front")
	self:EndPass()
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

PASS.Stages = {
	{
		name = "model",
		vertex = {
			mesh_layout = {
				{pos = "vec3"},
				{uv = "vec2"},
				{normal = "vec3"},
				--{tangent = "vec3"},
				{texture_blend = "float"},
			},
			source = [[
				#define GENERATE_TANGENT 1

				out vec3 view_pos;

				#ifdef GENERATE_TANGENT
					out vec3 vertex_view_normal;
				#else
					out mat3 tangent_space;
				#endif

				void main()
				{
					vec4 temp = g_view_world * vec4(pos, 1.0);
					view_pos = temp.xyz;
					gl_Position = g_projection * temp;


					#ifdef GENERATE_TANGENT
						vertex_view_normal = mat3(g_normal_matrix) * normal;
					#else
						vec3 view_normal = mat3(g_normal_matrix) * normal;
						vec3 view_tangent = mat3(g_normal_matrix) * tangent;
						vec3 view_bitangent = cross(view_tangent, view_normal);

						tangent_space = mat3(view_tangent, view_bitangent, view_normal);
					#endif
				}
			]]
		},
		fragment = {
			variables = {
				NoCull = false,
			},
			mesh_layout = {
				{uv = "vec2"},
				{texture_blend = "float"},
			},
			source = [[

				#define GENERATE_TANGENT 1
				//#define DEBUG_NORMALS 1

				in vec3 view_pos;

				#ifdef GENERATE_TANGENT
					in vec3 vertex_view_normal;
					#define tangent_space cotangent_frame(vertex_view_normal, view_pos, uv)
				#else
					in mat3 tangent_space;
					#define vertex_view_normal tangent_space[2]
				#endif

				// https://www.shadertoy.com/view/MslGR8
				bool dither(vec2 uv, float alpha)
				{
					if (lua[AlphaTest = false])
					{
						return alpha*alpha < (-gl_FragDepth+1)/20;
					}

					const vec3 magic = vec3( 0.06711056, 0.00583715, 52.9829189 );
					float lol = fract( magic.z * fract( dot( gl_FragCoord.xy, magic.xy ) ) );

					return (alpha + lol) < 1;
				}

				// http://www.geeks3d.com/20130122/normal-mapping-without-precomputed-tangent-space-vectors/
				mat3 cotangent_frame(vec3 N, vec3 p, vec2 uv)
				{
					// get edge vectors of the pixel triangle
					vec3 dp1 = dFdx( p );
					vec3 dp2 = dFdy( p );
					vec2 duv1 = dFdx( uv );
					vec2 duv2 = dFdy( uv );

					// solve the linear system
					vec3 dp2perp = cross( dp2, N );
					vec3 dp1perp = cross( N, dp1 );
					vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
					vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

					// construct a scale-invariant frame
					float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
					return mat3( T * invmax, B * invmax, N );
				}

				void main()
				{
					//{albedo = vertex_view_normal; return;}

					// albedo
					vec4 color = texture(lua[AlbedoTexture = render.GetErrorTexture()], uv);

					if (texture_blend != 0)
						color = mix(color, texture(lua[Albedo2Texture = "texture"], uv), texture_blend);

					color *= lua[Color = Color(1,1,1,1)];

					albedo = color.rgb;

					if (lua[Translucent = false])
					{
						if (dither(uv, color.a))
						{
							discard;
						}
					}



					// normals
					vec4 normal_map = texture(lua[NormalTexture = render.GetBlackTexture()], uv);

					if (normal_map.xyz != vec3(0))
					{
						if (texture_blend != 0)
						{
							normal_map = mix(normal_map, texture(lua[Normal2Texture = "texture"], uv), texture_blend);
						}

						if (lua[SSBump = false])
						{
							// this is so wrong
							normal_map.xyz = normalize(pow((normal_map.xyz*0.1 + vec3(0,0,1)), vec3(0.1)));
						}

						if (lua[FlipYNormal = false])
						{
							normal_map.rgb = normal_map.rgb * vec3(1, -1, 1) + vec3(0, 1, 0);
						}

						if (lua[FlipXNormal = false])
						{
							normal_map.rgb = normal_map.rgb * vec3(-1, 1, 1) + vec3(1, 0, 0);
						}

						normal_map.xyz = /*normalize*/(normal_map.xyz * 2 - 1).xyz;

						view_normal = tangent_space * normal_map.xyz;
					}
					else
					{
						view_normal = vertex_view_normal;
					}

					view_normal = normalize(view_normal);



					// metallic
					if (lua[NormalAlphaMetallic = false])
					{
						metallic = normal_map.a;
					}
					else if (lua[AlbedoAlphaMetallic = false])
					{
						metallic = -color.a+1;
					}
					else
					{
						metallic = texture(lua[MetallicTexture = render.GetBlackTexture()], uv).r;
					}



					// roughness
					roughness = texture(lua[RoughnessTexture = render.GetBlackTexture()], uv).r;


					//generate roughness and metallic they're zero
					if (roughness == 0)
					{
						if (metallic != 0)
						{
							roughness = pow(-metallic+1, 0.25)/1.5;
						}
						else
						{
							roughness = 0.98;//max(pow((-(length(albedo)/3) + 1), 5), 0.9);
							//albedo *= pow(roughness, 0.5);
						}

						if (metallic == 0)
						{
							metallic = min((-roughness+1)/1.5, 0.075);
						}
					}


					metallic *= lua[MetallicMultiplier = 1];
					roughness *= lua[RoughnessMultiplier = 1];
					specular = vec3(0,0,0);

					//albedo = albedo * (-metallic+1);

					#ifdef DEBUG_NORMALS

					//debug normals

					view_normal = vec3(-1,-1,-1);

					if (get_screen_uv().y > 0.5)
					{
						if (get_screen_uv().x < 0.33)
						{
							albedo = cotangent_frame(normalize(vertex_view_normal), view_pos, uv)[0] * 0.5 + 0.5;
						}
						else if (get_screen_uv().x > 0.33 && get_screen_uv().x < 0.66)
						{
							albedo = cotangent_frame(normalize(vertex_view_normal), view_pos, uv)[1] * 0.5 + 0.5;
						}
						else if (get_screen_uv().x > 0.66)
						{
							albedo = cotangent_frame(normalize(vertex_view_normal), view_pos, uv)[2] * 0.5 + 0.5;
						}
					}
					else
					{
						if (get_screen_uv().x < 0.33)
						{
							albedo = tangent_space[0] * 0.5 + 0.5;
						}
						else if (get_screen_uv().x > 0.33 && get_screen_uv().x < 0.66)
						{
							albedo = tangent_space[1] * 0.5 + 0.5;
						}
						else if (get_screen_uv().x > 0.66)
						{
							albedo = tangent_space[2] * 0.5 + 0.5;
						}
					}

					#endif
				}
			]]
		}
	},
	{
		name = "light",
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
				vec2 uv = get_screen_uv();

				float get_shadow_(vec2 uv)
				{
					float visibility = 0;

					if (lua[light_point_shadow = false])
					{
						vec3 light_dir = (get_view_pos(uv)*0.5+0.5) - (light_view_pos*0.5+0.5);
						vec3 dir = normalize(light_dir) * mat3(g_view);
						dir.z = -dir.z;


						float shadow_view = texture(lua[tex_shadow_map_cube = render.GetSkyTexture()], dir.xzy).r;

						visibility = shadow_view;
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

											visibility = abs(shadow_coord.z - texture(tex_shadow_map, shadow_coord.xy).r);
										}
										]]..(function()
											if i == 1 then
												return [[else if(lua[project_from_camera = false])
												{
													visibility = 0;
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

				float get_attenuation(vec2 uv, vec3 P, vec3 N, float cutoff)
				{
					// calculate normalized light vector and distance to sphere light surface
					float r = lua[light_radius = 1000]/10;
					vec3 L = light_view_pos - P;
					float distance = length(L);
					float d = max(distance - r, 0);
					L /= distance;

					float attenuation = 1;

					float denom = d/r + 1;
					attenuation = 1 / (denom*denom);

					// scale and bias attenuation such that:
					//   attenuation == 0 at extent of max influence
					//   attenuation == 1 when d == 0
					attenuation = (attenuation - cutoff) / (1 - cutoff);
					attenuation = max(attenuation, 0);

					float dot = max(dot(L, N), 0);
					attenuation *= dot;

					return attenuation * light_intensity;
				}

				void main()
				{
					//{specular = vec3(1) self_illumination = 1; return;}

					vec3 pos = get_view_pos(uv);
					vec3 normal = get_view_normal(uv);
					float attenuation = 1;

					if (!lua[project_from_camera = false])
					{
						attenuation = get_attenuation(uv, pos, normal, 0.175);
					}

					specular = compute_specular(
						normalize(pos - light_view_pos),
						normalize(pos),
						normal,
						get_metallic(uv),
						get_roughness(uv),
						get_albedo(uv),
						light_color.rgb * light_intensity,
						attenuation
					);

					//specular = (specular ) * vec3(attenuation);

					if (lua[light_shadow = false])
					{
						shadow = get_shadow_(uv);
					}
				}
			]]
		}
	},
}

local TESSELLATION = false

if TESSELLATION then
	PASS.Stages[1].vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{normal = "vec3"},
			--{tangent = "vec3"},
			{texture_blend = "float"},
		},
		source = [[
			#version 420
			out vec3 vPosition;
			out vec2 vTexCoord;
			out vec3 vNormal;
			out float vTextureBlend;

			void main() {
				vPosition = pos;
				vTexCoord = uv;
				vNormal = normal;
				vTextureBlend = texture_blend;
			}
		]]
	}
	PASS.Stages[1].tess_control = {
		source = [[
			#version 420
			layout(vertices = 3) out;

			in vec3 vPosition[];
			in vec2 vTexCoord[];
			in vec3 vNormal[];
			in float vTextureBlend[];

			out vec2 tcTexCoord[];
			out vec3 tcPosition[];
			out vec3 tcNormal[];
			out float tcTextureBlend[];

			void main()
			{
				tcTexCoord[gl_InvocationID] = vTexCoord[gl_InvocationID];
				tcPosition[gl_InvocationID] = vPosition[gl_InvocationID];
				tcNormal[gl_InvocationID] = vNormal[gl_InvocationID];
				tcTextureBlend[gl_InvocationID] = tcTextureBlend[gl_InvocationID];

				if(gl_InvocationID == 0)
				{
					float inTess  = lua[innerTessLevel = 10];
					float outTess = lua[outerTessLevel = 10];

					inTess = 16;
					outTess = 16;

					gl_TessLevelInner[0] = inTess;
					gl_TessLevelInner[1] = inTess;
					gl_TessLevelOuter[0] = outTess;
					gl_TessLevelOuter[1] = outTess;
					gl_TessLevelOuter[2] = outTess;
					gl_TessLevelOuter[3] = outTess;
				}
			}
		]],
	}
	PASS.Stages[1].tess_evaluation = {
		source = [[
			#version 420
			layout(triangles, equal_spacing, ccw) in;

			in vec3 tcPosition[];
			in vec2 tcTexCoord[];
			in vec3 tcNormal[];
			in float tcTextureBlend[];

			out vec3 tePosition;
			out vec2 teTexCoord;
			out vec3 teNormal;
			out float teTextureBlend;

			void main()
			{
				vec3 p0 = gl_TessCoord.x * tcPosition[0];
				vec3 p1 = gl_TessCoord.y * tcPosition[1];
				vec3 p2 = gl_TessCoord.z * tcPosition[2];
				vec3 pos = p0 + p1 + p2;

				vec2 tc0 = gl_TessCoord.x * tcTexCoord[0];
				vec2 tc1 = gl_TessCoord.y * tcTexCoord[1];
				vec2 tc2 = gl_TessCoord.z * tcTexCoord[2];
				teTexCoord = tc0 + tc1 + tc2;

				vec3 n0 = gl_TessCoord.x * tcNormal[0];
				vec3 n1 = gl_TessCoord.y * tcNormal[1];
				vec3 n2 = gl_TessCoord.z * tcNormal[2];
				vec3 normal = normalize(n0 + n1 + n2);
				teNormal = mat3(g_normal_matrix) * normal;

				teTextureBlend = (tcTextureBlend[0] + tcTextureBlend[1] + tcTextureBlend[2]) / 3;

				float height = texture(lua[HeightTexture = Texture("https://upload.wikimedia.org/wikipedia/commons/5/57/Heightmap.png")], teTexCoord).x;
				pos += normal * (height * 0.5f);

				vec4 temp = g_view_world * vec4(pos, 1.0);
				tePosition = temp.xyz;
				gl_Position = g_projection * temp;

			}
		]],
	}
	PASS.Stages[1].geometry = {
		source = [[
			#version 420
			layout (triangles) in;
			layout (triangle_strip) out;
			layout (max_vertices = 3) out;

			in vec3 tePosition[3];
			in vec2 teTexCoord[3];
			in vec3 teNormal[3];
			in float teTextureBlend[3];

			out vec2 gTexCoord;
			out float gTextureBlend;

			out vec3 gPosition;
			out vec3 gFacetNormal;

			void main()
			{
				for ( int i = 0; i < gl_in.length(); i++)
				{
					gTexCoord = teTexCoord[i];
					gPosition = tePosition[i];
					gFacetNormal = vec3(1,0,0);//teNormal[i];
					gTextureBlend = teTextureBlend[i];
					gl_Position = gl_in[i].gl_Position;
					EmitVertex();
				}

				EndPrimitive();
			}
		]],
	}

	PASS.Stages[1].fragment.mesh_layout = nil

	PASS.Stages[1].fragment.source = [[
		#version 420
		//in vec3 pos;
		in vec2 uv;
		//in vec3 normal;
		//in vec3 tangent;
		in float texture_blend;
	]]
	.. PASS.Stages[1].fragment.source

	if RELOAD then
		for mesh in pairs(prototype.GetCreated()) do
			if mesh.Type == "mesh_builder" then
				mesh.mesh:SetMode("patches")
			end
		end
	end
elseif RELOAD then
	for mesh in pairs(prototype.GetCreated()) do
		if mesh.Type == "mesh_builder" then
			mesh.mesh:SetMode("triangles")
		end
	end
end

render.gbuffer_fill = PASS
if RELOAD then
	render.InitializeGBuffer()
end

do
	local PASS = {}

	PASS.Position = -1
	PASS.Name = "reflection_merge"
	PASS.Default = true

	PASS.Source = {}

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			size_divider = reflection_res_divider,
			internal_format = "rgb16f",
		},
		source = [[
		vec3 project(vec3 coord)
		{
			vec4 res = g_projection * vec4(coord, 1.0);
			return (res.xyz / res.w) * 0.5 + 0.5;
		}

		//Z buffer is nonlinear by default, so we fix this here
		float linearizeDepth(float depth)
		{
			return (2.0 * g_cam_nearz) / (g_cam_farz + g_cam_nearz - depth * (g_cam_farz - g_cam_nearz));
		}

		out vec3 out_color;

		void main()
		{
			if (texture(tex_depth, uv).r == 1)
			{
				out_color = texture(lua[sky_tex = render.GetSkyTexture()], -get_camera_dir(uv) * vec3(-1,1,1)).rgb;
				return;
			}

			//Tweakable variables
			float initialStepAmount = .01;
			int maxDepth = 1;

			//Values from textures
			vec3 cameraSpacePosition = get_view_pos(uv);
			vec3 cameraSpaceNormal = get_view_normal(uv);
			vec3 cam_dir = -get_camera_dir(uv);


			//Screen space vector
			vec3 cameraSpaceViewDir = normalize(cameraSpacePosition);
			vec3 cameraSpaceVector = normalize(reflect(cameraSpaceViewDir,cameraSpaceNormal));
			vec3 screenSpacePosition = project(cameraSpacePosition);
			vec3 cameraSpaceVectorPosition = cameraSpacePosition + cameraSpaceVector;
			vec3 screenSpaceVectorPosition = project(cameraSpaceVectorPosition);
			vec3 screenSpaceVector = initialStepAmount*normalize(screenSpaceVectorPosition - screenSpacePosition);


			vec3 oldPosition = screenSpacePosition + screenSpaceVector;
			vec3 currentPosition = oldPosition + screenSpaceVector;



			float steps = 1000;
			float samples = 4;

			vec3 albedo = get_albedo(uv);
			float metallic = get_metallic(uv);
			float roughness = pow(get_roughness(uv), 5);
			vec3 normal = get_view_normal(uv);
			vec3 vertex_eye = normalize(get_view_pos(uv));



			vec3 sky_color = vec3(0);

			//for (float i = 0; i < samples;i++)
			{
				//vec3 noise = (get_noise(uv+(vec2((i/samples)))).xyz*2-1)*0.5*roughness;

				vec3 vnormal = normalize(normal/*+noise*/);
				vec3 world_normal = -(vnormal) * mat3(g_view);

				vec3 sky_reflect = reflect(cam_dir, world_normal);
				vec3 color = texture(lua[sky_tex = render.GetSkyTexture()], sky_reflect.xyz * vec3(-1,1,1)).rgb;
				color = mix(color*4, compute_specular(-vnormal, vertex_eye, normal, metallic, roughness, albedo, color*40, 1), roughness);
				sky_color += color;
			}

			sky_color /= samples;

			vec3 reflect_color = vec3(0);

			//for (float i = 0; i < samples;i++)
			{
				/*vec3 noise = (get_noise(uv+(vec2((i/samples)))).xyz*2-1)*roughness / get_depth(uv)  / 10000;

				noise.z = noise.z / 30;

				currentPosition += noise;*/

				vec3 res = vec3(0);

				for (float step = 0; step < steps;step++)
				{
					//Stop ray trace when it goes outside screen space
					if(currentPosition.x < 0 || currentPosition.x > 1 ||
					   currentPosition.y < 0 || currentPosition.y > 1 ||
					   currentPosition.z < 0 || currentPosition.z > 1)
						break;

					//intersections


					vec2 samplePos = currentPosition.xy;
					float currentDepth = linearizeDepth(currentPosition.z);
					float sampleDepth = linearizeDepth(texture(tex_depth, samplePos).x);

					float diff = (currentDepth - sampleDepth);
					float error = 0.000025 + (currentDepth/30);
					if(diff >= 0 && diff < error)
					{
						currentPosition = oldPosition;

						vec3 normalAtPos = get_view_normal(samplePos);
						float orientation = dot(cameraSpaceVector, normalAtPos);

						if(orientation < 0)
						{
							float cosAngIncidence = -dot(cameraSpaceViewDir,cameraSpaceNormal);
							cosAngIncidence = clamp(1-cosAngIncidence,0.0,1.0);

							vec2 dCoords = abs(vec2(0.5, 0.5) - samplePos);
							float fade = clamp(1.0 - (dCoords.x + dCoords.y)*1.8, 0.0, 1.0);

							vec3 albedo = get_albedo(samplePos);
							float shadow = get_shadow(samplePos) > 0.0025 ? 0.6 : 1;

							vec3 world_normal = -get_view_normal(samplePos) * mat3(g_view);
							vec3 sky_reflect = reflect(-get_camera_dir(uv), world_normal);
							vec3 sky_color = texture(lua[sky_tex = render.GetSkyTexture()], sky_reflect.xyz * vec3(-1,1,1)).rgb;

							vec3 color = albedo * mix(get_specular(samplePos) * shadow, sky_color, pow(clamp(get_metallic(samplePos), 0.0, 1.0), 0.5));

							color = mix(color, compute_specular(normalAtPos, vertex_eye, normal, metallic, roughness, albedo, color*40, 1.0), roughness);

							res += color;
						}
						break;
					}

					oldPosition = currentPosition;
					currentPosition = oldPosition + screenSpaceVector;
				}


				reflect_color += res;
			}

			//reflect_color /= samples;

			if (reflect_color == vec3(0,0,0))
				reflect_color = sky_color;

			out_color = reflect_color;
		}
	]]})

	local function blur(times, source, format, discard)
		for i = 1, times do
			table.insert(PASS.Source, {
				buffer = {
					size_divider = reflection_res_divider,
					internal_format = format or "rgb16f",
				},
				source = [[
				out vec3 out_color;

				void main()
				{
					//{out_color = texture(tex_stage_]]..#PASS.Source..[[, uv).rgb; return;}
					float RADIUS = 1;

					vec3 center = get_view_normal(uv);
					vec3 result = texture(tex_stage_]]..#PASS.Source..[[, uv).rgb;
					float normalization = 1.0;

					float amount = ]]..source..[[;
					float lol = ]]..(discard or 0.99)..[[;
					for (float j=-RADIUS; j <= RADIUS; j++) {
						for (float i=-RADIUS; i <= RADIUS; i++) {
							vec2 offset = ((vec2(i, j) / g_screen_size)*]]..(i*10)..[[*amount) * g_screen_size / 2500000;
							float closeness = dot(center, get_view_normal(uv + offset));

							if (closeness > lol)
							{
								result += texture(tex_stage_]]..#PASS.Source..[[, uv + offset).rgb * closeness;
								normalization += closeness;
							}
							else
							{
								lol *= 0.98;
							}
						}
					}

					out_color = result / normalization;
				}
				]],
			})
		end
	end

	blur(5, "0.000002/get_depth(uv)*100000*get_roughness(uv)", "rgb16f", "0.99")

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			internal_format = "r16f",
		},
		source =  [[
			const vec2 KERNEL[16] = vec2[](vec2(0.53812504, 0.18565957), vec2(0.13790712, 0.24864247), vec2(0.33715037, 0.56794053), vec2(-0.6999805, -0.04511441), vec2(0.06896307, -0.15983082), vec2(0.056099437, 0.006954967), vec2(-0.014653638, 0.14027752), vec2(0.010019933, -0.1924225), vec2(-0.35775623, -0.5301969), vec2(-0.3169221, 0.106360726), vec2(0.010350345, -0.58698344), vec2(-0.08972908, -0.49408212), vec2(0.7119986, -0.0154690035), vec2(-0.053382345, 0.059675813), vec2(0.035267662, -0.063188605), vec2(-0.47761092, 0.2847911));
			const float SAMPLE_RAD = 0.75;  /// Used in main
			const float INTENSITY = 10; /// Used in doAmbientOcclusion
			const int ITERATIONS = 10;

			float ssao(void)
			{
				vec3 p = get_view_pos(uv)*0.995;
				vec3 n = (get_view_normal(uv));
				vec2 rand = get_noise(uv).xy;

				float occlusion = 0.0;
				float depth = get_depth(uv);

				for(int j = 0; j < ITERATIONS; ++j)
				{
					vec2 offset = uv + (reflect(KERNEL[j], rand) / depth / g_cam_farz * SAMPLE_RAD);

					vec3 diff = get_view_pos(offset) - p;
					float d = length(diff);
					float a = dot(n, diff);

					if (d < 1*SAMPLE_RAD && a > 0.01)
					{
						occlusion += max(0.0, a) * (INTENSITY / (1.0 + d));
					}
				}

				return 1.0 - occlusion / ITERATIONS;
			}

			out float out_color;

			void main()
			{
				float shadow = get_shadow(uv) > 0.0025 ? 0.5 : 1;

				out_color = shadow * (min(ssao() + 0.25, 1));
				//out_color = pow(mix(1, out_color, pow(get_roughness(uv), 0.25)), 2);
			}
		]]
	})

	blur(3, "0.000002/get_depth(uv)*(0.1+get_shadow(uv))*750000", "r16f", 0.99)

	table.insert(PASS.Source, {
		source =  [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(tex_stage_]]..(#PASS.Source - 4)..[[, uv).rgb;

				if (texture(tex_depth, uv).r == 1)
				{
					out_color = reflection;
					return;
				}

				float roughness = get_roughness(uv);
				float shadow = texture(tex_stage_]]..(#PASS.Source)..[[, uv).r;
				vec3 albedo = get_albedo(uv);
				vec3 light = get_specular(uv) * pow(shadow, 2);

				float metallic = get_metallic(uv);

				/*float base = 1 - dot(get_camera_dir(uv), get_world_normal(uv));
				float exp = pow(base, 5*roughness);
				float fresnel = exp * (1.0 - exp);
				metallic += fresnel/10;
				metallic = clamp(metallic, 0.0, 1.0);*/

				vec3 final = albedo * mix(light, reflection, metallic);

				out_color = final;
			}
		]]
	})

	render.AddGBufferShader(PASS)

	if RELOAD then
		PASS:__init()
	end
end

if RELOAD then
	collectgarbage()
end