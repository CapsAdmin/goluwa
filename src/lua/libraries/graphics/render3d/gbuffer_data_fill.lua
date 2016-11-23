render3d.csm_count = 3

local PASS = {}

PASS.DepthFormat = "depth_component32f"

PASS.Buffers = {
	{
		name = "model",
		write = "all",
		layout =
		{
			{
				rgba8 = {
					rgb = "albedo",
					a = "roughness",
				}
			},
			{
				rgb16f = {
					rg = {
						"view_normal", "vec3",
						[[
							vec2 encode(vec3 n)
							{
								vec2 enc = normalize(n.xy) * (sqrt(-n.z*0.5+0.5));
								enc = enc*0.5+0.5;
								return enc;
							}
							vec3 decode(vec2 n)
							{
								vec4 nn = vec4(n,vec2(0))*vec4(2,2,0,0) + vec4(-1,-1,1,-1);
								float l = dot(nn.xyz,-nn.xyw);
								nn.z = l;
								nn.xy *= sqrt(l);
								return nn.xyz * 2 + vec3(0,0,-1);
							}
						]],
					},
					b = "metallic"
				}
			},
		}
	},
	{
		name = "light",
		write = "self",
		layout =
		{
			{
				r11f_g11f_b10f = {
					rgb = "specular",
				}
			}
		},
	}
}

render.AddGlobalShaderCode([[
// https://www.shadertoy.com/view/MslGR8
bool dither(vec2 uv, float alpha)
{
	if (lua[AlphaTest = false] && (alpha*alpha > gl_FragCoord.z/10))
	{
		return false;
	}

	const vec3 magic = vec3( 0.06711056, 0.00583715, 52.9829189 );
	float lol = fract( magic.z * fract( dot( gl_FragCoord.xy, magic.xy ) ) )*0.99;

	return (alpha*alpha*alpha + lol) < 1;
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
	vec4 pos = g_projection_view_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
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
	return (-get_view_normal(uv) * mat3(g_view));
}]])

render.AddGlobalShaderCode([[
vec3 get_view_tangent(vec2 uv)
{
	vec3 norm = get_view_normal(uv);
	vec3 tang = abs(norm.x) < 0.999 ? vec3(1,0,0) : vec3(0,1,0);
	return normalize(cross(norm, tang));
}]])

render.AddGlobalShaderCode([[
vec3 get_world_tangent(vec2 uv)
{
	return normalize(-get_view_tangent(uv) * mat3(g_view));
}]])

render.AddGlobalShaderCode([[
vec3 get_view_bitangent(vec2 uv)
{
	return normalize(cross(get_view_normal(uv), get_view_tangent(uv)));
}]])

render.AddGlobalShaderCode([[
vec3 get_world_bitangent(vec2 uv)
{
	return normalize(-get_view_bitangent(uv) * mat3(g_view));
}]])

render.AddGlobalShaderCode([[
// http://www.geeks3d.com/20130122/normal-mapping-without-precomputed-tangent-space-vectors/
mat3 get_view_tbn(vec2 uv)
{
	vec3 N = (get_view_normal(uv));
	vec3 p = normalize(get_view_pos(uv));

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
}]])

render.AddGlobalShaderCode([[
mat3 get_world_tbn(vec2 uv)
{
	mat3 tbn = get_view_tbn(uv);
	tbn[0] *= -mat3(g_view);
	tbn[1] *= -mat3(g_view);
	tbn[2] *= -mat3(g_view);
	return tbn;
}]])


render.AddGlobalShaderCode([[
#extension GL_ARB_texture_query_levels: enable

vec3 sample_cubemap_roughness(samplerCube tex, vec3 normal, vec3 reflected, float roughness)
{
	vec2 size = textureSize(tex, 0);
	float levels = textureQueryLevels(tex) - 1;
	float mx = log2(roughness * size.x + 1) / log2(size.y);

	return textureLod(tex, normalize(mix(reflected, normal, roughness)), mx * levels).rgb;
}
]], "sample_cubemap_roughness")
render.AddGlobalShaderCode([[
vec3 get_env_color()
{
	float roughness = get_roughness(uv);
	float metallic = get_metallic(uv);

	vec3 cam_dir = -get_camera_dir(uv);
	vec3 sky_normal = get_world_normal(uv);
	vec3 sky_reflect = reflect(cam_dir, sky_normal).xyz;

	vec3 irradiance = sample_cubemap_roughness(lua[tex_sky = render3d.GetSkyTexture()], sky_normal, sky_reflect, -metallic+1);
	vec3 reflection = sample_cubemap_roughness(lua[tex_sky = render3d.GetSkyTexture()], sky_normal, sky_reflect, roughness);

	return mix((irradiance+reflection), reflection, metallic);
}
]], "get_env_color")

function PASS:Initialize()
	function render3d.CreateMesh(vertices, indices, is_valid_table)
		return render.CreateVertexBuffer(render3d.gbuffer_data_pass.model_shader:GetMeshLayout(), vertices, indices)
	end

	local META = self.model_shader:CreateMaterialTemplate("model")

	include("lua/libraries/graphics/render3d/vmt.lua", META)

	function META:OnBind()
		if self.NoCull or self.Translucent then
			render.SetCullMode("none")
		else
			render.SetCullMode("front")
		end
		--self.SkyTexture = render3d.GetSkyTexture()
		--self.EnvironmentProbeTexture = render3d.GetEnvironmentProbeTexture()
		--self.EnvironmentProbePosition = render.GetEnvironmentProbeTexture().probe:GetPosition()
	end

	META:Register()
end

function PASS:BeginPass(name)
	render3d.gbuffer:WriteThese(self.buffers_write_these[name])
	render3d.gbuffer:Begin()
end

function PASS:EndPass()
	render3d.gbuffer:End()
end

function PASS:Draw3D(what)

	if (self.last_update_sky or 0) < system.GetElapsedTime() then
		render3d.UpdateSky()
		self.last_update_sky = system.GetElapsedTime() + 1/30
	end

	render.SetBlendMode()
	render.SetDepth(true)
	self:BeginPass("model")
		render.SetCullMode("front")
		event.Call("PreGBufferModelPass")
			render3d.shader = render3d.gbuffer_data_pass.model_shader
			render3d.DrawScene(what or "models")
		event.Call("PostGBufferModelPass")
	self:EndPass()

	render.SetDepth(false)
	self:BeginPass("light")
		render.SetCullMode("back")
			event.Call("Draw3DLights")
	self:EndPass()
end

PASS.Stages = {
	{
		name = "model",
		vertex = {
			mesh_layout = {
				{pos = "vec3"},
				{uv = "vec2"},
				{texture_blend = "float"},
				{normal = "vec3"},
				{tangent = "vec3"},
			},
			source = [[
				]].. (render3d.shader_name == "flat" and "#define FLAT_SHADING" or "") ..[[

				#ifdef FLAT_SHADING
					out vec3 vertex_view_normal;
				#else
					out mat3 tangent_space;
				#endif

				void main()
				{
					#ifdef FLAT_SHADING
						gl_Position = g_projection_view_world * vec4(pos, 1);
						vertex_view_normal = mat3(g_normal_matrix) * normal;
					#else
						gl_Position = g_projection_view_world * vec4(pos, 1);
						tangent_space = mat3(g_normal_matrix) * mat3(tangent, cross(tangent, normal), normal);
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
				render3d.shader_name == "flat" and {normal = "vec3"} or nil,
			},
			source = [[
				]].. (render3d.shader_name == "flat" and "#define FLAT_SHADING" or "") ..[[

#ifdef FLAT_SHADING
				in vec3 vertex_view_normal;
				void main()
				{
					set_albedo(texture(lua[AlbedoTexture = render.GetErrorTexture()], uv).rgb);
					set_view_normal(vertex_view_normal);
					set_specular(vec3(0,0,0));
				}
#else
				in mat3 tangent_space;

				void main()
				{
					vec2 uv = uv*lua[UVMultiplier = 1];

					vec2 blend_data = texture(lua[BlendTexture = render.GetBlackTexture()], uv).rg;
					float blend = blend_data.g;
					float blend_power = blend_data.r;

					if (texture_blend != 0)
					{
						blend = mix(texture_blend, blend, 0.5);
					}

					if (blend != 0)
					{
						blend = pow(blend, blend_power);
					}

					// albedo
					vec4 albedo = texture(lua[AlbedoTexture = render.GetErrorTexture()], uv);

					if (blend != 0)
						albedo = mix(albedo, texture(lua[Albedo2Texture = "texture"], uv), blend);

					if (lua[BlendTintByBaseAlpha = false])
					{
						albedo.rgb = mix(albedo.rgb, albedo.rgb * lua[Color = Color(1,1,1,1)].rgb, albedo.a);
					}
					else
					{
						albedo *= lua[Color = Color(1,1,1,1)];
					}

					set_albedo(albedo.rgb);
					//set_albedo(pow(albedo.rgb, vec3(0.75)) * normalize(albedo.rgb));

					if (lua[Translucent = false] && dither(uv, albedo.a))
					{
						discard;
					}

					// normals
					vec3 normal = vec3(0,0,0);

					vec4 normal_map = texture(lua[NormalTexture = render.GetBlackTexture()], uv);

					if (normal_map.xyz != vec3(0))
					{
						if (blend != 0)
						{
							normal_map = mix(normal_map, texture(lua[Normal2Texture = "texture"], uv), blend);
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

						normal_map.xyz = (normal_map.xyz * 2 - 1).xyz;

						normal = tangent_space * normal_map.xyz;
					}
					else
					{
						normal = tangent_space[2];
					}
					normal = normalize(normal);

					set_view_normal(normal);



					float metallic = 1;

					// metallic
					if (lua[NormalAlphaMetallic = false])
					{
						metallic = normal_map.a;
					}
					else if (lua[AlbedoAlphaMetallic = false])
					{
						metallic = -albedo.a+1;
					}
					else
					{
						metallic = texture(lua[MetallicTexture = render.GetBlackTexture()], uv).r;
					}

					// roughness
					float roughness = texture(lua[RoughnessTexture = render.GetBlackTexture()], uv).r;

					//generate roughness and metallic they're zero
					if (roughness == 0)
					{
						if (lua[AlbedoLuminancePhongMask = false])
						{
							roughness = length(albedo);
						}
						else if (lua[AlbedoPhongMask = false])
						{
							roughness = albedo.a;
						}
						else if (metallic != 0)
						{
							roughness = pow(-metallic+1, 0.25)/1.5;
						}
						else
						{
							roughness = 0.98;//max(pow((-(length(albedo)/3) + 1), 5), 0.9);
						}

						if (metallic == 0)
						{
							metallic = min((-roughness+1)/1.5, 0.075);
						}
					}

					roughness *= lua[RoughnessMultiplier = 1];
					metallic *= lua[MetallicMultiplier = 1];

					set_metallic(handle_metallic(metallic));
					set_roughness(handle_roughness(roughness));


					if (lua[SelfIllumination = false])
					{
						vec4 illum = texture(lua[SelfIlluminationTexture = render.GetWhiteTexture()], uv);

						illum *= lua[IlluminationColor = Color(1,1,1,1)];

						set_specular(pow(illum.rgb, vec3(0.25))*2.5);
					}
					else
					{
						set_specular(vec3(0,0,0));
					}
				}
#endif
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
				light_color = Color(1,1,1,1),
				light_intensity = 0.5,
			},
			source = [[
				vec2 uv = get_screen_uv();

				float calc_shadow(vec2 uv, vec3 light_view_pos, vec3 L, vec3 N)
				{
					float cosTheta = -dot(N, L);
					float bias = 0.0005*tan(acos(cosTheta));
					float div = 1;

					float shadow = 1;

					if (lua[light_point_shadow = false])
					{
						vec3 light_dir = (get_view_pos(uv)*0.5+0.5) - (light_view_pos*0.5+0.5);
						vec3 dir = normalize(light_dir) * mat3(g_view);
						dir.z = -dir.z;

						float shadow_view = texture(lua[tex_shadow_map_cube = render3d.GetSkyTexture()], dir.xzy).r;

						shadow = shadow_view;
					}
					else
					{
						vec3 world_pos = get_world_pos(uv)*0.9999;

						]] .. (function()
							local code = ""
							for i = render3d.csm_count, 1, -1 do
								local str = [[
								{
									vec4 temp = light_projection_view * vec4(world_pos, 1);
									vec3 shadow_coord = temp.xyz / temp.w;

									if (
										shadow_coord.x >= -0.995 &&
										shadow_coord.x <= 0.995 &&
										shadow_coord.y >= -0.995 &&
										shadow_coord.y <= 0.995 &&
										shadow_coord.z >= -0.995 &&
										shadow_coord.z <= 0.995
									)
									{
										shadow_coord = 0.5 * shadow_coord + 0.5;

										float depth = texture(tex_shadow_map, shadow_coord.xy).r - shadow_coord.z;
										shadow = depth > -bias ? 1 : 0;
									}
								}
								]]

								str = str:gsub("tex_shadow_map", "lua[tex_shadow_map_" .. i .." = \"sampler2D\"]")

								if DEBUG_SHADOWS then
									if i == 1 then
										str = str:gsub("shadow = vec3(depth);", "shadow = vec3(depth, 0, 0)*3;")
									elseif i == 2 then
										str = str:gsub("shadow = vec3(depth);", "shadow = vec3(0, depth, 0)*3;")
									elseif i == 3 then
										str = str:gsub("shadow = vec3(depth);", "shadow = vec3(0, 0, depth)*3;")
									elseif i == 4 then
										str = str:gsub("shadow = vec3(depth);", "shadow = vec3(depth, depth, 0)*3;")
									end
								end

								if camera.camera_3d:GetMatrices().projection_view then
									str = str:gsub("light_projection_view", "lua[light_projection_view" .. i .. " = \"mat4\"]")
								else
									str = str:gsub("light_projection_view", "(light_projection * light_view)")
									str = str:gsub("light_view", "lua[light_view" .. i .. " = \"mat4\"]")
									str = str:gsub("light_projection", "lua[light_projection" .. i .. " = \"mat4\"]")
								end
								code = code .. str
							end
							return code
						end)() .. [[
					}

					return shadow;
				}

				void main()
				{

					vec3 pos = get_view_pos(uv);
					vec3 light_view_pos = g_view_world[3].xyz;

					vec3 L = normalize(pos - light_view_pos);
					vec3 V = normalize(pos);
					vec3 N = get_view_normal(uv);

					float attenuation = 1;

					if (!lua[project_from_camera = false])
					{
						float radius = lua[light_radius = 1000];

						attenuation = gbuffer_compute_light_attenuation(pos, light_view_pos, radius, N);
					}

					float shadow = 1;

					if (lua[light_shadow = false])
					{
						shadow = calc_shadow(uv, light_view_pos, L, N);
					}

					set_specular(gbuffer_compute_specular(L, V, N, attenuation, light_color.rgb * light_intensity) * shadow);

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
			{tangent = "vec3"},
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

				float height = texture(lua[HeightTexture = render.CreateTextureFromPath("https://upload.wikimedia.org/wikipedia/commons/5/57/Heightmap.png")], teTexCoord).x;
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
end

if RELOAD then
	if TESSELLATION then
		for mesh in pairs(prototype.GetCreated()) do
			if mesh.Type == "polygon_3d" then
				mesh.vertex_buffer:SetMode("patches")
			end
		end
	else
		for mesh in pairs(prototype.GetCreated()) do
			if mesh.Type == "polygon_3d" then
				mesh.vertex_buffer:SetMode("triangles")
			end
		end
	end

	render3d.Initialize()
	return
end

return PASS