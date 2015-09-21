local render = ... or _G.render

local PASS = {}

PASS.Stage, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Buffers = {
	{"diffuse", "rgba8"},
	{"normal", "rgba16f"},
	{"reflection", "rgba8"},
}

function PASS:Initialize()
	local META = self.shader:CreateMaterialTemplate(PASS.Name)
	
	function META:OnBind()
		if self.NoCull or self.Translucent then
			render.SetCullMode("none") 
		else
			render.SetCullMode("front") 
		end
		self.CubeTexture = render.GetCubemapTexture()
	end

	META:Register()
end

local gl = require("graphics.ffi.opengl") -- OpenGL

function PASS:Draw3D()
	render.EnableDepth(true)
	render.SetBlendMode()
	
	render.gbuffer:Clear("all", 0,0,0,0,  1)
	
	render.gbuffer:Begin()
		event.Call("PreGBufferModelPass")
		render.Draw3DScene("models")
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
			--{binormal = "vec3"},
			{texture_blend = "float"},
		},
		source = [[
			out vec3 view_normal;
			out float dist;
			out vec3 reflect_dir;
		
			void main()
			{				
				gl_Position = g_projection_view_world * vec4(pos, 1.0);
				
				out_normal = normalize(g_normal_matrix * vec4(normal, 1)).xyz;
				//out_binormal = normalize(g_normal_matrix * vec4(binormal, 1)).xyz;
				//out_tangent = normalize(g_normal_matrix * vec4(tangent, 1)).xyz;
				
				view_normal = (g_view_world * vec4(pos, 1)).xyz;
				
				dist = (g_view_world * vec4(pos, 1.0)).z;
				reflect_dir = -(g_view_world * vec4(pos, 1)).xyz;
			}
		]]
	},
	fragment = {
		variables = {	
			NoCull = false,
		},
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{normal = "vec3"},
			--{tangent = "vec3"},
			--{binormal = "vec3"},
			{texture_blend = "float"},
		},
		source = [[			
			in vec3 view_normal;
			in float dist;
			in vec3 reflect_dir;					
		
			out vec4 diffuse_buffer;
			out vec4 normal_buffer;					
			out vec4 reflection_buffer;					

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
			
			vec2 steep_parallax(vec2 uv, float bumpScale, vec3 _tsE)
			{
				/**
				 SteepParallax.glsl.vrt
				 Morgan McGuire 2005 morgan@cs.brown.edu
				 */

				// We are at height bumpScale.  March forward until we hit a hair or the 
				// base surface.  Instead of dropping down discrete y-voxels we should be
				// marching in texels and dropping our y-value accordingly (TODO: fix)
				float height = 1.0;

				// Number of height divisions
				float numSteps = 5;

				/** Texture coordinate marched forward to intersection point */
				vec2 offsetCoord = uv.xy;
				float NB = texture2D(lua[HeightTexture = Texture("textures/sofa/sofa_OCC.png")], offsetCoord).r;

				vec3 tsE = normalize(_tsE);

				// Increase steps at oblique angles
				// Note: tsE.z = N dot V
				numSteps = mix(numSteps*2, numSteps, tsE.z);

				// We have to negate tsE because we're walking away from the eye.
				//vec2 delta = vec2(-_tsE.x, _tsE.y) * bumpScale / (_tsE.z * numSteps);
				float step;
				vec2 delta;


				// Constant in z
				step = 1.0 / numSteps;
				delta = vec2(-_tsE.x, _tsE.y) * bumpScale / (_tsE.z * numSteps);

				// Can also step along constant in xy; the results are essentially
				// the same in each case.
				// delta = 1.0 / (25.6 * numSteps) * vec2(-tsE.x, tsE.y);
				// step = tsE.z * bumpScale * (25.6 * numSteps) / (length(tsE.xy) * 400);

				while (NB < height) {
					height -= step;
					offsetCoord += delta;
					NB = texture2D(HeightTexture, offsetCoord).r;
				}
				
				return offsetCoord;
			}
						
			void main()
			{
				//{diffuse_buffer = texture(DiffuseTexture, uv); return;}
				//vec2 uv = steep_parallax(uv, 0.01, -view_normal);
						
				//if (texture(tex_discard, get_screen_uv()).r > 0) discard;
				
				// diffuse
				{
					diffuse_buffer = texture(lua[DiffuseTexture = render.GetErrorTexture()], uv);
	
					if (texture_blend != 0)
						diffuse_buffer = mix(diffuse_buffer, texture(lua[Diffuse2Texture = "texture"], uv), texture_blend);
					
					diffuse_buffer *= lua[Color = Color(1,1,1,1)];
					
					if (lua[Translucent = false])
					{
						if (dither(uv, diffuse_buffer.a))
						{
							discard;
						}
					}
				}
								
				// normals
				{				
					vec4 normal_detail = texture(lua[NormalTexture = render.GetBlackTexture()], uv);
					
					if (normal_detail.xyz != vec3(0))
					{						
						if (texture_blend != 0)
						{
							normal_detail = mix(normal_detail, texture(lua[Normal2Texture = "texture"], uv), texture_blend);
						}
 
						if (lua[SSBump = false])
						{
							// this is so wrong
							normal_detail.xyz = normalize(normal_detail.xyz*0.5 + vec3(0,0,0.25*0.5));
						}
						
						if (lua[FlipYNormal = false])
						{
							normal_detail.rgb = normal_detail.rgb * vec3(1, -1, 1) + vec3(0, 1, 0);
						}
						
						if (lua[FlipXNormal = false])
						{
							normal_detail.rgb = normal_detail.rgb * vec3(-1, 1, 1) + vec3(1, 0, 0);
						}
						
						normal_detail.xyz = /*normalize*/(normal_detail.xyz * 2 - 1).xyz;
					
						normal_buffer.xyz = cotangent_frame(normalize(normal), view_normal, uv) * normal_detail.xyz;
					}
					else
					{
						normal_buffer.xyz = normal;
					}
					
					normal_buffer.xyz = normalize(normal_buffer.xyz);
					
					if (lua[NormalAlphaMetallic = false])
					{ 
						normal_buffer.a = normal_detail.a;
					}
					else if (lua[DiffuseAlphaMetallic = false])
					{
						normal_buffer.a = -diffuse_buffer.a+1;
					}
					else
					{
						normal_buffer.a = texture(lua[MetallicTexture = render.GetBlackTexture()], uv).r;
					}
				}
				
				diffuse_buffer.a = texture(lua[RoughnessTexture = render.GetBlackTexture()], uv).r;
								
				{
					// hmmm
					
					if (diffuse_buffer.a == 0)
					{
						if (normal_buffer.a != 0)
						{
							diffuse_buffer.a = pow(-normal_buffer.a+1, 1);
						}
						else
						{
							diffuse_buffer.a = clamp(pow(-length(diffuse_buffer.rgb)+1, 0.5)*2,0.5, 1);
						}
					}
					
					if (normal_buffer.a == 0)
					{
						normal_buffer.a = clamp(pow(length(diffuse_buffer.rgb), 0.5)*0.3, 0.1, 1);
					}
					
				}
				
				
				normal_buffer.a *= lua[MetallicMultiplier = 1];
				diffuse_buffer.a *= lua[RoughnessMultiplier = 1];
				
				//vec3 noise = (texture(lua[NoiseTexture = render.GetNoiseTexture()], uv).xyz * vec3(2) - vec3(1)) * (dist * diffuse_buffer.a * diffuse_buffer.a * diffuse_buffer.a)*2.5;
				
				reflection_buffer = texture(lua[CubeTexture = render.GetCubemapTexture()], (mat3(g_view_inverse) * reflect(reflect_dir, normal_buffer.xyz)).yzx);
				reflection_buffer.rgb += vec3(0.001);
				
				reflection_buffer.a = lua[SelfIllumination = 0]; 
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
vec3 get_world_normal(vec2 uv)
{
	return normalize(-texture(tex_normal, uv).xyz * mat3(g_normal_matrix));
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
