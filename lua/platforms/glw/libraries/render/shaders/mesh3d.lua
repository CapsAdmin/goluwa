local SHADER = {      
	shared = {
		uniform = {
			time = 0,
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
		source = [[
			void main()
			{
				// ugh
				//glw_out_normal = normalize(transpose(mat3(camera_matrix)) * transpose(inverse(model_matrix)) * normal);
				
				gl_Position = camera_matrix * model_matrix * vec4(pos, 1.0);
			}
		]]
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
			out vec4 out_data[3];
			
			void main() 
			{
				out_data[0] = texture2D(texture, uv);
				out_data[1] = out_data[0] + vec4(normal.xyz, 0);
				out_data[2] = out_data[0] + vec4(pos.xyz, 0);				
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
			if ent.ModelPath ~= "" then
				ent:SetModelPath(ent.ModelPath)
			end
		end
	end
end