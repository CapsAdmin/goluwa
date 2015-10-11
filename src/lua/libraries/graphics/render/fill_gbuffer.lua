local render = ... or _G.render

local PASS = {}

PASS.Buffers = {
	{
		name = "model",
		write = "all",
		layout =
		{
			{
				format = "rgba8",

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

				light = "rgb",
				self_illumination = "a",
			}
		},
	}
}

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
	return normalize(-get_view_normal(uv) * mat3(g_normal_matrix));
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
	render.gbuffer:WriteThese("all")
	render.gbuffer:Clear("all", 0,0,0,0, 1)

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
						return alpha*alpha < 0.25;
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
					//{albedo = texture(AlbedoTexture, uv).rgb; return;}

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
							roughness = -metallic+1;
						}
						else
						{
							roughness = 0.9;//max(pow((-(length(albedo)/3) + 1), 5), 0.9);
							//albedo *= pow(roughness, 0.5);
						}

						if (metallic == 0)
						{
							metallic = min((-roughness+1)/1.5, 0.075);
						}
					}


					metallic *= lua[MetallicMultiplier = 1];
					roughness *= lua[RoughnessMultiplier = 1];

					// self lllumination
					self_illumination = texture(lua[SelfIlluminationTexture = render.GetWhiteTexture()], uv).r * lua[SelfIllumination = 0]*10;

					light = vec3(0,0,0);

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
				#define EPSILON 0.00001

				float get_shadow(vec2 uv, float bias)
				{
					float visibility = 0;

					if (lua[light_point_shadow = false])
					{
						vec3 light_dir = (get_view_pos(uv)*0.5+0.5) - (light_view_pos*0.5+0.5);
						vec3 dir = normalize(light_dir) * mat3(g_view);
						dir.z = -dir.z;


						float shadow_view = texture(lua[tex_shadow_map_cube = render.GetSkyTexture()], dir.xzy).r;

						visibility = shadow_view < 1 ? 0: 1;
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
						attenuation *= get_shadow(uv, 0.002);
					}

					return light_color.rgb * attenuation * light_intensity;
				}

				float get_specular(vec3 L, vec3 V, vec3 N, float roughness, float F0)
				{
					float alpha = roughness*roughness;

					vec3 H = normalize(V+L);

					float dotNL = clamp(dot(N,L), 0, 1);

					float dotLH = clamp(dot(L,H), 0, 1);
					float dotNH = clamp(dot(N,H), 0, 1);

					float F, D, vis;

					// D
					float alphaSqr = alpha*alpha;
					float pi = 3.14159f;
					float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
					D = alphaSqr/(pi * denom * denom);

					// F
					float dotLH5 = pow(1.0f-dotLH,5);
					F = F0 + (1.0-F0)*(dotLH5);

					// V
					float k = alpha/2.0f;
					float k2 = k*k;
					float invK2 = 1.0f-k2;
					vis = (dotLH*dotLH*invK2 + k2);

					return dotNL * D * F * vis;
				}

				void main()
				{
					//{light = vec3(1) self_illumination = 1; return;}

					vec2 uv = get_screen_uv();

					vec3 pos = get_view_pos(uv);
					vec3 normal = get_view_normal(uv);
					float roughness = get_roughness(uv);
					vec3 attenuate = get_attenuation(uv, pos, normal, 0.175);
					float specular = get_specular(normalize(pos - light_view_pos), normalize(pos), -normal, roughness, 0.25);

					light = specular.rrr * attenuate + attenuate;
					self_illumination = 0;
				}
			]]
		}
	},
}

render.gbuffer_fill = PASS

do -- reflection

	local PASS = {}

	PASS.Position = -1
	PASS.Name = "reflection_merge"
	PASS.Default = true

	PASS.Source = {}

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			size_divider = 2,
			internal_format = "rgb16f",
		},
		source = [[
		const float rayStep = 0.005;
		const float minRayStep = 20;
		const float maxSteps = 50;

		vec2 project(vec3 coord)
		{
			vec4 res = g_projection * vec4(coord, 1.0);
			return (res.xy / res.w) * 0.5 + 0.5;
		}

		vec2 ray_cast(vec3 dir, vec3 hitCoord)
		{
			dir *= rayStep;

			for(int i = 0; i < maxSteps; i++)
			{
				hitCoord += dir;

				float depth = hitCoord.z - get_view_pos(project(hitCoord)).z;

				if(depth < 0.0 && depth > -0.3)
				{
					return project(hitCoord).xy;
				}
			}

			return vec2(0.0, 0.0);
		}

		out vec3 out_color;

		void main()
		{
			vec3 viewNormal = get_view_normal(uv);
			vec3 viewPos = get_view_pos(uv);
			vec3 reflected = normalize(reflect(normalize(viewPos), normalize(viewNormal)));

			vec3 hitPos = viewPos;
			vec2 coords = ray_cast(reflected * max(minRayStep, viewPos.z), hitPos);

			vec3 sky = texture(lua[sky_tex = render.GetSkyTexture()], -reflect(get_camera_dir(uv), get_world_normal(uv)).yzx).rgb;

			if (coords == vec2(0.0))
			{
				out_color = sky;
				return;
			}

			//vec3 probe = texture(lua[probe_tex = render.GetEnvironmentProbeTexture()], -reflect(get_camera_dir(uv), get_world_normal(uv)).yzx).rgb;
			vec3 diffuse = get_albedo(coords.xy);
			vec3 light = diffuse * (sky + get_light(coords.xy)) + (diffuse * diffuse * diffuse * get_self_illumination(coords.xy));

			vec2 dCoords = abs(vec2(0.5, 0.5) - coords.xy);
			float fade = clamp(1.0 - (dCoords.x + dCoords.y)*1.5, 0.0, 1.0);
			fade -= pow(fade, 1.5)/1.75;
			fade *= 2;

			out_color =	mix(sky, light, fade);
		}
	]]
	})

	for x = -1, 1 do
		for y = -1, 1 do
			if x == y or (y == 0 and x == 0) then goto continue end

			local samples = 16
			local total_weight = 0
			local weights = {}

			for i = 1, samples do
				local theta = (i / samples) * math.pi * 2
				local weight = math.lerp(math.sin((i / samples) * math.pi), 0, 0.25)
				total_weight = total_weight + weight
				weights[i] = {
					dir = ("vec2(%s, %s)"):format(math.sin(theta), math.cos(theta)),
					weight = weight,
				}
			end

			table.insert(PASS.Source, {
				buffer = {
					size_divider = 2,
					internal_format = "rgb16f",
				},
				source = [[
					out vec3 out_color;

					const float discard_threshold = 0.5;

					vec3 blur()
					{
						float amount = get_roughness(uv);
						amount = min(pow(amount*3, 2.5) / get_depth(uv) / g_cam_farz / 20, 0.1);

						vec3 normal = normalize(get_view_normal(uv));
						float total_weight = ]]..total_weight..[[;
						vec3 res = vec3(0);
						vec2 offset;

						]] ..(function()
							local str = ""
							for i, weight in ipairs(weights) do
								str = str .. "offset = (" ..weight.dir.." * amount);\n"
								str = str .. "if( dot(normalize(get_view_normal(uv + offset)), normal) < discard_threshold) {\n"
								str = str .."total_weight -= "..weight.weight..";\n"
								str = str .. "} else {\n"
								str = str .. "res += texture(tex_stage_"..#PASS.Source..", uv + offset).rgb * "..weight.weight.."; }\n"
							end
							return str
						end)()..[[

						res /= total_weight;

						return res;
					}

					void main()
					{
						out_color = blur();
					}
				]]
			})
			::continue::
		end
	end

	table.insert(PASS.Source, {
		buffer = {
			size_divider = 1,
			internal_format = "rgb16f",
		},
		source = [[
			const vec2 KERNEL[16] = vec2[](vec2(0.53812504, 0.18565957), vec2(0.13790712, 0.24864247), vec2(0.33715037, 0.56794053), vec2(-0.6999805, -0.04511441), vec2(0.06896307, -0.15983082), vec2(0.056099437, 0.006954967), vec2(-0.014653638, 0.14027752), vec2(0.010019933, -0.1924225), vec2(-0.35775623, -0.5301969), vec2(-0.3169221, 0.106360726), vec2(0.010350345, -0.58698344), vec2(-0.08972908, -0.49408212), vec2(0.7119986, -0.0154690035), vec2(-0.053382345, 0.059675813), vec2(0.035267662, -0.063188605), vec2(-0.47761092, 0.2847911));
			const float SAMPLE_RAD = 1.25;  /// Used in main
			const float INTENSITY = 1.25; /// Used in doAmbientOcclusion

			float ssao(void)
			{
				vec3 p = get_view_pos(uv)*0.996;
				vec3 n = normalize(get_view_normal(uv));
				vec2 rand = normalize(get_noise(uv).xy*2-1);

				float occlusion = 0.0;

				const int ITERATIONS = 16;
				for(int j = 0; j < ITERATIONS; ++j)
				{
					vec2 offset = uv + (reflect(KERNEL[j], rand) / (get_depth(uv)) / g_cam_farz * SAMPLE_RAD);

					vec3 diff = get_view_pos(offset) - p;
					float d = length(diff);

					if (d < 1)
					{
						occlusion += max(0.0, dot(n, normalize(diff))) * (INTENSITY / (1.0 + d));
					}
				}

				return 1.0 - occlusion / ITERATIONS;
			}
			out vec3 out_color;

			void main()
			{
				vec3 color = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;
				float occlusion = ssao();
				//out_color = pow(color*3, vec3(occlusion*3)) * pow(occlusion, 5)/3;
				out_color = color * pow(occlusion, 5);
			}
		]]
	})

	table.insert(PASS.Source, {
		source =  [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(tex_stage_]]..#PASS.Source..[[, uv).rgb;
				vec3 diffuse = get_albedo(uv);
				vec3 specular = get_light(uv);
				float metallic = get_metallic(uv);

				specular = mix(specular, reflection, pow(metallic, 0.5));

				// self illumination
				specular += diffuse * get_self_illumination(uv)/200;

				out_color = (diffuse * specular) + get_sky(uv, get_depth(uv));
				//out_color = reflection;

			}
		]]
	})

	render.AddGBufferShader(PASS)
end