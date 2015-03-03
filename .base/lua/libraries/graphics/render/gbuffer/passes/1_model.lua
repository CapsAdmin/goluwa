local render = ... or _G.render

local gl = require("lj-opengl") -- OpenGL

local PASS = {}

PASS.Name = "model"
PASS.Stage = FILE_NAME:sub(1,1)

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

local gl = require("lj-opengl") -- OpenGL

function PASS:Draw3D()
	gl.DepthMask(gl.e.GL_TRUE)
	gl.Enable(gl.e.GL_DEPTH_TEST)
	gl.Disable(gl.e.GL_BLEND)

	render.gbuffer:Begin()
		render.gbuffer:Clear()
		
		--gl.Clear(gl.e.GL_DEPTH_BUFFER_BIT)
		event.Call("Draw3DGeometry", render.gbuffer_model_shader)
		
		--skybox?				
		
		--local scale = 16
		--local view = Matrix44()
		--view = render.SetupView3D(Vec3(234.1, -234.1, 361.967)*scale + render.GetCameraPosition(), render.GetCameraAngles(), render.GetCameraFOV(), view)
		--view:Scale(scale,scale,scale)
		--event.Call("Draw3DGeometry", render.gbuffer_model_shader, view * render.matrices.projection_3d, true)			
	render.gbuffer:End()
end

PASS.Shader = {
	vertex = {
		uniform = {
			projection_view_world = "mat4",
		},
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},
		source = "gl_Position = projection_view_world * vec4(pos, 1.0);"
	},
	fragment = {
		uniform = {	
			view_world = "mat4",
			--illumination_color = Color(1,1,1,1),
			alpha_specular = 1,
		},
		attributes = {
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},
		source = [[
			out vec4 diffuse_buffer;
			out vec4 normal_buffer;

			float rand(vec2 co){
				return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
			}
			
			void main()
			{	
				// diffuse
				{
					diffuse_buffer = texture(tex_model_diffuse, uv);
					
					vec4 diffuse_blend = texture(tex_model_diffuse2, uv);
					if (diffuse_blend != vec4(0))
						diffuse_buffer = mix(diffuse_buffer, diffuse_blend, texture_blend);
					
					if (lua[alpha_test = 0] == 1 && alpha_specular != 0)
					{
						//if (diffuse_buffer.a < pow(rand(uv), 0.5))
						//if (pow(diffuse_buffer.a+0.5, 4) < 0.5)
						if (diffuse_buffer.a < 0.25)
							discard;
					}
					
					//if (lua[detail_blend_factor = 0] > 0)
						//diffuse_buffer.rgb = (diffuse_buffer.rgb - texture(tex_model_detail, uv * lua[detail_scale = 1]*10).rgb);
						
					diffuse_buffer *= lua[color = Color(1,1,1,1)];
				}
				
				// normals
				{				
					vec3 bump_detail = texture(tex_model_normal, uv).rgb;
					
					if (bump_detail == vec3(0,0,0))
					{				
						normal_buffer.rgb = mat3(view_world) * normal;
					}
					else
					{
						vec3 bump_detail2 = texture(tex_model_normal2, uv).rgb;
						
						if (bump_detail2 != vec3(0,0,0))
							bump_detail = mix(bump_detail, bump_detail2, texture_blend);
					
						mat3 normal_matrix = mat3(inverse(transpose(view_world)));
						
						vec3 Normal = normalize(normal_matrix * normal);
						vec3 Tangent = -normalize(normal_matrix[1]);
						vec3 Binormal = normalize(normal_matrix[2]);
						
						mat3 tangentToWorld = mat3(
							Tangent.x, Binormal.x, Normal.x,
							Tangent.y, Binormal.y, Normal.y,
							Tangent.z, Binormal.z, Normal.z
						);
						
						normal_buffer.rgb = (2 * bump_detail - 1) * tangentToWorld;
					}
					
					normal_buffer.rgb = normalize(normal_buffer.rgb);
				}

				if (alpha_specular == 1)
				{
					normal_buffer.a = -diffuse_buffer.a+1;
				}
				else
				{
					normal_buffer.a = texture(tex_model_metallic, uv).r;
				}
				
				diffuse_buffer.a = texture(tex_model_roughness, uv).r;
				
				normal_buffer.a += lua[metallic_multiplier = 0];
				diffuse_buffer.a += lua[roughness_multiplier = 0];
			}
		]]
	}
}

for i,v in ipairs(render.model_textures) do
	PASS.Shader.fragment.uniform[v.shader_name] = "sampler2D"
end

render.RegisterGBufferPass(PASS)