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
		source = "gl_Position = camera_matrix * model_matrix * vec4(pos, 1.0);"
	},
	
	fragment = { 
		uniform = {
			diffuse = "sampler2D",
			bump = "sampler2D",
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
				out_data[0] = texture2D(diffuse, uv);
				out_data[1] = vec4(normal.xyz * texture2D(bump, uv).xyz, 1);
				out_data[2] = vec4(pos.xyz, 1);	
			}
		]]
	}  
}   

function render.CreateMesh3D(data)
	render.mesh_3d_shader = render.mesh_3d_shader or render.CreateSuperShader("mesh_3d", SHADER)
		
	local mesh = render.mesh_3d_shader:CreateVertexBuffer(data)
	
	mesh.model_matrix = render.GetModelMatrix
	mesh.camera_matrix = render.GetCameraMatrix
	
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