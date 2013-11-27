local SHADER = {      
	shared = {
		uniform = {
			time = 0,
		},
	},
	 
	vertex = { 
		uniform = {
			projection_matrix = "mat4",
			view_matrix = "mat4",
			world_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
		},	
		source = [[		
			void main()
			{							
				mat3 world_inverse = transpose(mat3(world_matrix));
				mat3 normal_matrix = transpose(inverse(mat3(projection_matrix)));
				
				
				gl_Position = projection_matrix * world_matrix * vec4(pos, 1.0);
				
				glw_out_normal = normalize(world_inverse * normal_matrix * normal);
				glw_out_pos = (view_matrix * vec4(pos, 1.0)).xyz;   
			}
		]]
	},
	
	fragment = { 
		uniform = {
			diffuse = "sampler2D",
			bump = "sampler2D",
			specular = "sampler2D",
		},		
		attributes = {
			pos = "vec3",
			normal = "vec3",
			uv = "vec2",
		},			
		source = [[
			out vec4 out_data[4];
						
			void main() 
			{
				out_data[0] = texture2D(diffuse, uv);
				out_data[1] = vec4(normalize(normal + texture2D(bump, uv).xyz), 1);
				out_data[2] = vec4(pos.xyz, 1);	
				out_data[3] = texture2D(specular, uv);
			}
		]]
	}  
}   

function render.CreateMesh3D(data)
	render.mesh_3d_shader = render.mesh_3d_shader or render.CreateSuperShader("mesh_3d", SHADER)
		
	local mesh = render.mesh_3d_shader:CreateVertexBuffer(data)
	
	mesh.view_matrix = render.GetViewMatrix
	mesh.world_matrix = render.GetWorldMatrix
	mesh.projection_matrix = render.GetProjectionMatrix
	
	return mesh
end

-- for reloading
if render.mesh_3d_shader then
	render.mesh_3d_shader = render.CreateSuperShader("mesh_3d", SHADER)
	
	if entities then
		for key, ent in pairs(entities.GetAllByClass("model")) do
			if ent.ModelPath ~= "" then
				ent:SetModelPath(ent.ModelPath)
			end
		end
	end
end