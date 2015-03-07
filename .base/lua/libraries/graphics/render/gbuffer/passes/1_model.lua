local render = ... or _G.render

local gl = require("libraries.ffi.opengl") -- OpenGL

local PASS = {}

PASS.Stage, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Buffers = {
	{"diffuse", "RGBA8"},
	{"normal", "RGBA8_SNORM"},
}

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

local gl = require("libraries.ffi.opengl") -- OpenGL

function PASS:Draw3D()
	gl.DepthMask(gl.e.GL_TRUE)
	render.EnableDepth(true)
	render.SetBlendMode()
	
	render.gbuffer:Begin()
	render.gbuffer:Clear()
		event.Call("Draw3DGeometry", render.gbuffer_model_shader)
		
		--skybox?				
		
		--local scale = 16
		--local view = Matrix44()
		--view = render.SetupView3D(Vec3(234.1, -234.1, 361.967)*scale + render.camera_3d:GetPosition(), render.camera_3d:GetAngles(), render.camera_3d:GetFOV(), view)
		--view:Scale(scale,scale,scale)
		--event.Call("Draw3DGeometry", render.gbuffer_model_shader, true)			
	render.gbuffer:End()
end

PASS.Shader = {
	vertex = {
		attributes = {
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
				
				vec3 tangent = -normalize(mat3(g_normal_matrix) * out_normal);
				vec3 binormal = normalize(cross(out_normal, tangent));

				tangent_to_world = mat3(
					tangent.x, binormal.x, out_normal.x,
					tangent.y, binormal.y, out_normal.y,
					tangent.z, binormal.z, out_normal.z
				);

				gl_Position = g_projection_view_world * vec4(pos, 1.0);
			}
		]]
	},
	fragment = {
		uniform = {	
			--illumination_color = Color(1,1,1,1),
			AlphaSpecular = 1,
		},
		attributes = {
			{uv = "vec2"},
			{normal = "vec3"},
			--[[{tangent = "vec3"},
			{binormal = "vec3"},]]
			{texture_blend = "float"},
		},
		source = [[
			in mat3 tangent_to_world;
		
			out vec4 diffuse_buffer;
			out vec4 normal_buffer;
			
			void main()
			{			
				// diffuse
				{
					diffuse_buffer = texture(DiffuseTexture, uv);
					
					vec4 diffuse_blend = texture(Diffuse2Texture, uv);
					if (diffuse_blend != vec4(1))
						diffuse_buffer = mix(diffuse_buffer, diffuse_blend, texture_blend);
					
					if (lua[AlphaTest = false] == 1 && AlphaSpecular != 0)
					{
						//if (diffuse_buffer.a < pow(rand(uv), 0.5))
						//if (pow(diffuse_buffer.a+0.5, 4) < 0.5)
						if (diffuse_buffer.a < 0.25)
							discard;
					}
					
					//if (lua[DetailBlendFactor = 0] > 0)
						//diffuse_buffer.rgb = (diffuse_buffer.rgb - texture(DetailTexture, uv * lua[DetailScale = 1]*10).rgb);
						
					diffuse_buffer *= lua[Color = Color(1,1,1,1)];
				}
				
				// normals
				{				
					vec4 bump_detail = texture(NormalTexture, uv);
					
					normal_buffer.rgb = normal;
					
					if (bump_detail != vec4(1))
					{
						vec4 bump_detail2 = texture(Normal2Texture, uv);
						
						if (bump_detail2 != vec4(1))
							bump_detail = mix(bump_detail, bump_detail2, texture_blend);
					
						normal_buffer.rgb += (2 * bump_detail.rgb - 1) * tangent_to_world;
					}
					
					normal_buffer.rgb = normalize(normal_buffer.rgb);
				}

				if (AlphaSpecular == 1)
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

do
	local META = render.CreateMaterialTemplate("model")

	prototype.StartStorable()
		META:GetSet("IlluminationColor", Color(1,1,1,1))
		META:GetSet("DetailScale", 1)
		META:GetSet("DetailBlendFactor", 0)
		META:GetSet("NoCull", false)
		META:GetSet("AlphaTest", false)
		META:GetSet("AlphaSpecular", false)
		META:GetSet("RoughnessMultiplier", 0)
		META:GetSet("MetallicMultiplier", 0)
	prototype.EndStorable()

	do
		local function add_texture(name, default)	
			prototype.StartStorable()
				META:GetSet(name .. "Texture", default)
			prototype.EndStorable()
			
			PASS.Shader.fragment.uniform[name .. "Texture"] = default
		end

		add_texture("Diffuse", render.GetErrorTexture())
		add_texture("Diffuse2", render.GetWhiteTexture())
		add_texture("Normal", render.GetWhiteTexture())
		add_texture("Normal2", render.GetWhiteTexture()) 
		
		add_texture("Metallic", render.GetBlackTexture())
		add_texture("Roughness", render.GetGreyTexture()) 

		-- source engine specific
		--add_texture("Illumination", render.GetBlackTexture())
		--add_texture("Detail", render.GetWhiteTexture())
	end

	META:Register()
end

render.RegisterGBufferPass(PASS)