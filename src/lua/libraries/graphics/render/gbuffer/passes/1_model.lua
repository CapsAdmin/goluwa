local render = ... or _G.render

local PASS = {}

PASS.Stage, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Buffers = {
	{"diffuse", "RGBA8"},
	{"normal", "RGBA8_SNORM"},
}

function PASS:Initialize()
	local META = self.shader:CreateMaterialTemplate(PASS.Name)
	
	function META:OnBind()
		if self.NoCull then
			render.SetCullMode("none") 
		else
			render.SetCullMode("front") 
		end
	end

	META:Register()
end

local gl = require("graphics.ffi.opengl") -- OpenGL

function PASS:Draw3D()
	render.EnableDepth(false)
	render.SetBlendMode()
	
	render.gbuffer:Begin()
		event.Call("PreGBufferModelPass")
		render.Draw3DScene()
		event.Call("PostGBufferModelPass")
	render.gbuffer:End()
end

PASS.Shader = {
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{normal = "vec3"},
			--[[{tangent = "vec3"},
			{binormal = "vec3"},]]
			{texture_blend = "float"},
		},
		source = [[
			out mat3 tangent_to_world;
		
			void main()
			{				
				out_normal =  mat3(g_view_world) * normal;
				
				vec3 tangent = normalize(mat3(g_normal_matrix) * out_normal);
				vec3 binormal = -normalize(cross(out_normal, tangent));

				tangent_to_world = mat3(
					binormal.x, tangent.x, out_normal.x,
					binormal.y, tangent.y, out_normal.y,
					binormal.z, tangent.z, out_normal.z
				);

				gl_Position = g_projection_view_world * vec4(pos, 1.0);
			}
		]]
	},
	fragment = {
		variables = {	
			--illumination_color = Color(1,1,1,1),
			AlphaSpecular = false,
			NoCull = false,
			
			DiffuseTexture = render.GetErrorTexture(),
			Diffuse2Texture = "texture",
			NormalTexture = render.GetBlackTexture(),
			Normal2Texture = "texture",
			
			MetallicTexture = render.GetBlackTexture(),
			RoughnessTexture = render.GetGreyTexture(),
			-- source engine specific
			--IlluminationTexture = render.GetBlackTexture(),
			--DetailTexture = render.GetBlackTexture(),
		},
		mesh_layout = {
			{uv = "vec2"},
			{normal = "vec3"},
			--[[{tangent = "vec3"},
			{binormal = "vec3"},]]
			{texture_blend = "float"},
		},
		source = [[
			#extension GL_ARB_arrays_of_arrays: enable
			
			in mat3 tangent_to_world;
		
			out vec4 diffuse_buffer;
			out vec4 normal_buffer;					

			// https://www.shadertoy.com/view/MslGR8
			bool dither(vec2 uv, float alpha)
			{			
				//{return alpha < 0.5;}
			
				vec2 ij = floor(mod( gl_FragCoord.xy, vec2(2.0)));
				float idx = ij.x + 2.0*ij.y;
				vec4 m = step( abs(vec4(idx)-vec4(0,1,2,3)), vec4(0.5)) * vec4(0.75,0.25,0.00,0.50);
				float d = m.x+m.y+m.z+m.w;
				
				return (alpha + d) < 0.9;
			}
			
			void main()
			{			
				if (texture(tex_discard, get_screen_uv()).r > 0) discard;
				
				// diffuse
				{
					diffuse_buffer = texture(DiffuseTexture, uv);
	
					if (texture_blend != 0)
						diffuse_buffer = mix(diffuse_buffer, texture(Diffuse2Texture, uv), texture_blend);
					
					if (lua[Translucent = false])
					{
						if (dither(uv, diffuse_buffer.a))
						{
							discard;
						}
					}
					
					//if (lua[DetailBlendFactor = 0] > 0)
						//diffuse_buffer.rgb = (diffuse_buffer.rgb - texture(DetailTexture, uv * lua[DetailScale = 1]*10).rgb);
						
					diffuse_buffer *= lua[Color = Color(1,1,1,1)];
				}
				
				// normals
				{				
					vec3 bump_detail = texture(NormalTexture, uv).xyz;

					normal_buffer.xyz = normal;
					
					if (bump_detail != vec3(0))
					{						
						if (texture_blend != 0)
							bump_detail = bump_detail + (texture(Normal2Texture, uv).xyz * texture_blend);
					
						normal_buffer.xyz += ((2 * bump_detail - 1) * tangent_to_world);
					}
					
					normal_buffer.xyz = normalize(normal_buffer.xyz);
				}

				if (AlphaSpecular)
				{
					normal_buffer.a = -diffuse_buffer.a+1;
				}
				else
				{
					normal_buffer.a = texture(MetallicTexture, uv).r;
				}
				
				diffuse_buffer.a = texture(RoughnessTexture, uv).r;
				
				normal_buffer.a += lua[MetallicMultiplier = 0];
				diffuse_buffer.a += lua[RoughnessMultiplier = 0];
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
}]], "get_view_pos")

render.AddGlobalShaderCode([[
vec3 get_view_normal(vec2 uv)
{
	return texture(tex_normal, uv).xyz;
}]], "get_view_normal")

render.AddGlobalShaderCode([[
vec3 get_world_normal(vec2 uv)
{
	return normalize(-texture(tex_normal, uv).xyz * mat3(g_normal_matrix));
}]], "get_world_normal")

render.AddGlobalShaderCode([[
float get_metallic(vec2 uv)
{
	return texture(tex_normal, uv).a;
}]], "get_metallic")

render.AddGlobalShaderCode([[
float get_roughness(vec2 uv)
{
	return texture(tex_diffuse, uv).a;
}]], "get_roughness")
 
render.AddGlobalShaderCode([[
vec3 get_world_pos(vec2 uv)
{
	vec4 pos = g_view_inverse * g_projection_inverse * vec4(uv * 2.0 - 1.0, texture(tex_depth, uv).r * 2 - 1, 1.0);
	return pos.xyz / pos.w;
}]], "get_world_pos")
