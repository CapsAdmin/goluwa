local SHADER = {      
	shared = {
		uniform = {
			time = 2,
		},
	},
	 
	vertex = { 
		uniform = {
			camera_matrix = "mat4",
			model_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
		},	
		source = "gl_Position = camera_matrix * model_matrix * vec4(pos, 1.0);"
	},
	
	fragment = { 
		uniform = {
			cam_pos = Vec3(0,0,0),
			texture = "sampler2D",
		},		
		attributes = {
			pos = "vec3",
			normal = "vec3",
			uv = "vec2",
		},			
		source = [[
			out vec4 frag_color;

			vec4 texel = texture2D(texture, uv);
			
			vec3 light_direction = normalize(vec3(sin(time), sin(time * 1.234), cos(time)));
			vec3 viewer_direction = normalize(cam_pos - pos);	
			
			vec3 get_specular()
			{		
				float factor = clamp(dot(reflect(light_direction, normal), viewer_direction) * 0.96, 0.0, 1.0);
				float value = pow(factor, 32.0);
				return texel.xyz * value;
			}

			vec3 get_diffuse()
			{
				return texel.xyz * clamp(dot(normal, light_direction), 0.0, 1.0);
			}

			vec3 get_ambient()
			{
				return texel.xyz * 0.15;
			}
			
			void main()
			{	
				frag_color = 
				vec4(
					get_ambient() +
					get_diffuse() +
					get_specular(), 
					texel.w
				);
			}
		]]
	}  
} 

function render.CreateMesh3D(data)
	render.mesh_3d_shader = render.mesh_3d_shader or render.CreateSuperShader("mesh_3d", SHADER)
		
	local mesh = render.mesh_3d_shader:CreateVertexBuffer(data)
	
	mesh.model_matrix = render.GetModelMatrix
	mesh.camera_matrix = render.GetCameraMatrix
	mesh.cam_pos = render.GetCamPos
	
	return mesh
end

-- for reloading
if render.mesh_3d_shader then
	render.mesh_3d_shader = render.CreateSuperShader("mesh_3d", SHADER)
	
	if entities then
		for key, ent in pairs(entities.GetAllByClass("model")) do
			ent:SetMeshPath(ent:GetMeshPath())
		end
	end
end