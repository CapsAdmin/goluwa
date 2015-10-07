local render = ... or _G.render

local PASS = {}

PASS.Stage, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Buffers = {
	{"diffuse", "rgba8"},
	{"normal", "rgba16f"},
}

function PASS:Initialize()
	local META = self.shader:CreateMaterialTemplate(PASS.Name)

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

local gl = require("graphics.ffi.opengl") -- OpenGL

function PASS:Draw3D(what, dist)
	render.UpdateSky()

	render.EnableDepth(true)
	render.SetBlendMode()

	render.gbuffer:Begin()
		event.Call("PreGBufferModelPass")
		render.Draw3DScene(what or "models", dist)
		event.Call("PostGBufferModelPass")
	render.gbuffer:End()
end

PASS.Shader = {
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
				out vec3 view_normal;
			#else
				out mat3 tangent_space;
			#endif

			void main()
			{
				vec4 temp = g_view_world * vec4(pos, 1.0);
				view_pos = temp.xyz;
				gl_Position = g_projection * temp;


				#ifdef GENERATE_TANGENT
					view_normal = mat3(g_normal_matrix) * normal;
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
				in vec3 view_normal;
				#define tangent_space cotangent_frame(view_normal, view_pos, uv)
			#else
				in mat3 tangent_space;
				#define view_normal tangent_space[2]
			#endif

			out vec4 diffuse_buffer;
			out vec4 normal_buffer;
			out vec4 light_buffer; // AUTOMATE THIS

			#define roughness diffuse_buffer.a
			#define metallic normal_buffer.a
			#define self_illumination light_buffer.a
			#define normal normal_buffer.xyz
			#define diffuse diffuse_buffer.rgb

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
				//{diffuse = texture(DiffuseTexture, uv).rgb; return;}

				// diffuse
				vec4 color = texture(lua[DiffuseTexture = render.GetErrorTexture()], uv);

				if (texture_blend != 0)
					color = mix(color, texture(lua[Diffuse2Texture = "texture"], uv), texture_blend);

				color *= lua[Color = Color(1,1,1,1)];

				diffuse = color.rgb;

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

					normal = tangent_space * normal_map.xyz;
				}
				else
				{
					normal = view_normal;
				}

				normal = normalize(normal);



				// metallic
				if (lua[NormalAlphaMetallic = false])
				{
					metallic = normal_map.a;
				}
				else if (lua[DiffuseAlphaMetallic = false])
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
						roughness = 0.9;//max(pow((-(length(diffuse)/3) + 1), 5), 0.9);
						//diffuse *= pow(roughness, 0.5);
					}

					if (metallic == 0)
					{
						metallic = (-roughness+1)/1.5;
					}
				}


				metallic *= lua[MetallicMultiplier = 1];
				roughness *= lua[RoughnessMultiplier = 1];

				// self lllumination
				self_illumination = texture(lua[SelfIlluminationTexture = render.GetWhiteTexture()], uv).r * lua[SelfIllumination = 0]*10;

				light_buffer.rgb = vec3(0,0,0);

				#ifdef DEBUG_NORMALS

				//debug normals

				normal = vec3(-1,-1,-1);

				if (get_screen_uv().y > 0.5)
				{
					if (get_screen_uv().x < 0.33)
					{
						diffuse = cotangent_frame(normalize(view_normal), view_pos, uv)[0] * 0.5 + 0.5;
					}
					else if (get_screen_uv().x > 0.33 && get_screen_uv().x < 0.66)
					{
						diffuse = cotangent_frame(normalize(view_normal), view_pos, uv)[1] * 0.5 + 0.5;
					}
					else if (get_screen_uv().x > 0.66)
					{
						diffuse = cotangent_frame(normalize(view_normal), view_pos, uv)[2] * 0.5 + 0.5;
					}
				}
				else
				{
					if (get_screen_uv().x < 0.33)
					{
						diffuse = tangent_space[0] * 0.5 + 0.5;
					}
					else if (get_screen_uv().x > 0.33 && get_screen_uv().x < 0.66)
					{
						diffuse = tangent_space[1] * 0.5 + 0.5;
					}
					else if (get_screen_uv().x > 0.66)
					{
						diffuse = tangent_space[2] * 0.5 + 0.5;
					}
				}

				#endif
			}
		]]
	}
}

render.RegisterGBufferPass(PASS)

function render.CreateMesh(vertices, indices, is_valid_table)
	if render.IsGBufferReady() then
		return render.gbuffer_model_shader:CreateVertexBuffer(vertices, indices, is_valid_table)
	end

	return nil, "gbuffer not ready"
end

render.AddGlobalShaderCode([[
vec3 get_view_pos(vec2 uv)
{
	vec4 pos = g_projection_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
	return pos.xyz / pos.w;
}]])

render.AddGlobalShaderCode([[
vec3 get_view_normal(vec2 uv)
{
	return texture(tex_normal, uv).xyz;
}]])

render.AddGlobalShaderCode([[
vec3 get_normal_from_depth(vec2 uv)
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

render.AddGlobalShaderCode([[
vec3 get_diffuse(vec2 uv)
{
	return texture(tex_diffuse, uv).rgb;
}]])

render.AddGlobalShaderCode([[
float get_metallic(vec2 uv)
{
	return texture(tex_normal, uv).a;
}]])

render.AddGlobalShaderCode([[
float get_roughness(vec2 uv)
{
	return texture(tex_diffuse, uv).a;
}]])

render.AddGlobalShaderCode([[
vec3 get_world_pos(vec2 uv)
{
	vec4 pos = g_view_inverse * g_projection_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
	return pos.xyz / pos.w;
}]])

render.AddGlobalShaderCode([[
float get_self_illumination(vec2 uv)
{
	return texture(tex_light, uv).a;
}]])