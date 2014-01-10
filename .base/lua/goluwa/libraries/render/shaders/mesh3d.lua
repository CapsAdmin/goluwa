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
			
			pvm_matrix = "mat4",
			
			cam_forward = "vec3",
			cam_right = "vec3",
			cam_up = "vec3",
		},			
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			--{tangent = "vec3"},
			--{bitangent = "vec3"},
		},	
		source = [[		
			void main()
			{											
				glw_out_pos = (view_matrix * world_matrix * vec4 (pos, 1.0)).xyz;
				glw_out_normal = normalize((view_matrix * world_matrix * vec4 (normal, 0.0)).xyz);
				gl_Position = projection_matrix * vec4 (glw_out_pos, 1.0);
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
				out_data[1] = vec4((normal + texture2D(bump, uv).xyz) / 2, 1);
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
	mesh.projection_matrix = function() return render.GetProjectionMatrix3D() end
	mesh.view_matrix = function() return  render.matrices.view_3d.m end
	mesh.world_matrix = function() return  render.matrices.world.m end
	
	mesh.cam_forward = function() return render.GetCamAng():GetRad():GetForward() end
	mesh.cam_right = function() return render.GetCamAng():GetRad():GetRight() end
	mesh.cam_up = function() return render.GetCamAng():GetRad():GetUp() end
	
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