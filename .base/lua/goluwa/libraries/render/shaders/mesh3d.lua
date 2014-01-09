local SHADER = {      
	shared = {
		uniform = {
			time = 0,
		},
	},
	 
	vertex = { 
		uniform = {
			view_matrix = "mat4",
			world_matrix = "mat4",
			pvm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
		},	
		source = [[		
			void main()
			{											
				gl_Position = pvm_matrix * vec4(pos, 1.0);
				
				glw_out_normal = (world_matrix * vec4(normal, 0.0)).xyz;
				glw_out_pos = (world_matrix * vec4(pos, 1.0)).xyz;
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
	
	mesh.pvm_matrix = function() return render.GetPVWMatrix3D() end
	mesh.view_matrix = function() return  render.matrices.view_3d.m end
	mesh.world_matrix = function() return  render.matrices.world.m end
	
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