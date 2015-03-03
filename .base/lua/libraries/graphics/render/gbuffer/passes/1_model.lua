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
	fragment = {
		uniform = {	
		
			pvm_matrix = "mat4",
			color = Color(1,1,1,1),
			vm_matrix = "mat4",
			--detail_scale = 1,
			--detail_blend_factor = 0,
			alpha_test = 0,
			illumination_color = Color(1,1,1,1),
			alpha_specular = 0,
			roughness_multiplier = 1,
			metallic_multiplier = 1,
		},
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},
		source = [[
			out vec4 diffuse_buffer;
			out vec4 normal_buffer;
			out vec4 illumination_buffer;

			float rand(vec2 co){
				return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
			}
			
			void main()
			{	
				// diffuse
				{
					diffuse_buffer.rgb = texture(tex_model_diffuse, uv).rgb;
					
					vec3 diffuse_blend = texture(tex_model_diffuse2, uv).rgb;
					if (diffuse_blend != vec3(0,0,0))
						diffuse_buffer.rgb = mix(diffuse_buffer.rgb, diffuse_blend, texture_blend);
					
					if (alpha_test == 1)
					{
						//if (diffuse_buffer.a < pow(rand(uv), 0.5))
						//if (pow(diffuse_buffer.a+0.5, 4) < 0.5)
						if (diffuse_buffer.a < 0.25)
							discard;
					}
					else
					{
						diffuse_buffer.a = 1;
					}
					
					//if (detail_blend_factor > 0)
						//diffuse_buffer.rgb = (diffuse_buffer.rgb - texture(tex_model_detail, uv * detail_scale*10).rgb);
				}
				
				// normals
				{					
					normal_buffer.rgb = mat3(vm_matrix) * normal;
					
					
					vec3 bump_detail = texture(tex_model_normal, uv).rgb;
					
					vec3 bump_detail2 = texture(tex_model_normal2, uv).rgb;
					if (bump_detail2 != vec3(0,0,0))
						bump_detail = mix(bump_detail, bump_detail2, texture_blend);
				
					if (bump_detail != vec3(0,0,0))
					{
						mat3 normal_matrix = mat3(inverse(transpose(vm_matrix)));
						
						vec3 Normal = normalize(normal_matrix * normal);
						vec3 Tangent = -normalize(normal_matrix[1]);
						vec3 Binormal = normalize(normal_matrix[0] + normal_matrix[2]);
						
						mat3 tangentToWorld = mat3(
							Tangent.x, Binormal.x, Normal.x,
							Tangent.y, Binormal.y, Normal.y,
							Tangent.z, Binormal.z, Normal.z
						);
						
						normal_buffer.rgb = (2 * bump_detail - 1) * tangentToWorld;
					}
					
					//normal_buffer.rgb = normalize(normal_buffer.rgb);
				}
				
				normal_buffer.a = texture(tex_model_metallic, uv).r + metallic_multiplier;
				diffuse_buffer.a = texture(tex_model_roughness, uv).r + roughness_multiplier;
				
				/*
				// illumination
				{
					illumination_buffer.r = texture(tex_model_illumination, uv).r;
					
					// metallic
					illumination_buffer.g = -texture(tex_model_metallic, uv).r+1;
					
					if (alpha_specular == 1)
					{
						illumination_buffer.g = texture(tex_model_normal, uv).a;
					}
					else
					{
						illumination_buffer.b = texture(tex_model_roughness, uv).r;
					}
					
					illumination_buffer.g += metallic_multiplier;
					illumination_buffer.b += roughness_multiplier;
					
					illumination_buffer.a = 1;
				}
				*/
			}
		]]
	}
}

for i,v in ipairs(render.model_textures) do
	PASS.Shader.fragment.uniform[v.shader_name] = "sampler2D"
end

render.RegisterGBufferPass(PASS)