local render = (...) or _G.render

render.model_cache = render.model_cache or {}

local assimp = require("lj-assimp") -- model decoder

local default_texture_format = {
	mip_map_levels = 4,
	mag_filter = "linear",
	min_filter = "linear_mipmap_linear",
}

local SHADER = {
	name = "mesh_3d",
	shared = {
		uniform = {
		--	time = 0,
		},
	},
	 
	vertex = { 
		uniform = {
			projection_matrix = "mat4",
			view_matrix = "mat4",
			world_matrix = "mat4",
			
			--pvm_matrix = "mat4",
			
			--cam_forward = "vec3",
		--	cam_right = "vec3",
			--cam_up = "vec3",
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
				out_pos = (view_matrix * world_matrix * vec4 (pos, 1.0)).xyz;
				out_normal = normalize((view_matrix * world_matrix * vec4 (normal, 0.0)).xyz);
				gl_Position = projection_matrix * vec4 (pos, 1.0);
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
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
		},			
		source = [[
			out vec4 out_data[4];
						
			void main() 
			{
				out_data[0] = texture(diffuse, uv);
				out_data[1] = vec4((normal + texture(bump, uv).xyz) / 2, 1);
				out_data[2] = vec4(pos.xyz, 1);	
				out_data[3] = texture(specular, uv);
			}
		]]
	}  
}   

function render.Create3DMesh(data)
	if not render.mesh_3d_shader then
		local shader = render.CreateShader(SHADER)
						
		shader.pvm_matrix = function() return render.GetPVWMatrix3D() end
		shader.projection_matrix = function() return render.GetProjectionMatrix3D() end
		shader.view_matrix = function() return render.matrices.view_3d.m end
		shader.world_matrix = function() return render.matrices.world.m end
		
		shader.cam_forward = function() return render.GetCamAng():GetRad():GetForward() end
		shader.cam_right = function() return render.GetCamAng():GetRad():GetRight() end
		shader.cam_up = function() return render.GetCamAng():GetRad():GetUp() end
		
		render.mesh_3d_shader = shader
	end
		
	return render.mesh_3d_shader:CreateVertexBuffer(data)
end

do -- model meta
	local META = utilities.CreateBaseMeta("model")

	META.__index = META

	class.GetSet(META, "TextureOverride", NULL)

	function render.CreateModel(path, flags, ...)
		check(path, "string")

		if render.model_cache[path] then
			return render.model_cache[path]
		end

		flags = flags or bit.bor(assimp.e.aiProcess_CalcTangentSpace, assimp.e.aiProcess_GenSmoothNormals)

		local new_path = R(path)

		if not vfs.Exists(new_path) then
			return nil, path .. " not found"
		end

		local models, err = assimp.ImportFileEx(new_path, flags, ...)

		if not models then return nil, err end

		local self = setmetatable({}, META)
		self.sub_models = {}

		for i, model in pairs(models) do
			local sub_model = {mesh = render.Create3DMesh(model.mesh_data), name = model.name}

			if model.material and model.material.path then
				sub_model.diffuse = render.CreateTexture(model.material.path, default_texture_format)

				do -- try to find normal map
					local path = render.FindTextureFromSuffix(model.material.path, "_n", "_ddn", "_nrm")

					if path then
						sub_model.bump = render.CreateTexture(path, default_texture_format)
					end
				end

				do -- try to find specular map
					local path = render.FindTextureFromSuffix(model.material.path, "_s", "_spec")

					if path then
						sub_model.specular = render.CreateTexture(path, default_texture_format)
					end
				end
			end
			
			if not sub_model.diffuse then
				sub_model.diffuse = render.GetErrorTexture()
			end
		
			--sub_model.diffuse:SetChannel(1)
			--sub_model.bump:SetChannel(2)
			--sub_model.specular:SetChannel(3)

			self.sub_models[i] = sub_model
		end

		render.model_cache[path] = self

		return self
	end

	function META:Remove()
		for _, model in pairs(self.sub_models) do
			model.mesh.diffuse:Remove()
			model.mesh.bump:Remove()
			model.mesh.specular:Remove()
			model.mesh:Remove()
		end
	end

	function META:Draw()
		for _, model in pairs(self.sub_models) do
			if self.TextureOverride:IsValid() then
				render.mesh_3d_shader.diffuse = self.TextureOverride
				render.mesh_3d_shader.bump = self.TextureOverride
				render.mesh_3d_shader.specular = self.TextureOverride
			else
				render.mesh_3d_shader.diffuse = model.diffuse
				render.mesh_3d_shader.bump = model.bump
				render.mesh_3d_shader.specular = model.specular
			end
			
			render.mesh_3d_shader:Bind()
			model.mesh:Draw()
		end
	end

	function META:IsValid()
		return true
	end
end

-- for reloading
if render.mesh_3d_shader then
	render.mesh_3d_shader = render.CreateShader(SHADER)
	
	if entities then
		for key, ent in pairs(entities.GetAllByClass("model")) do
			if ent.ModelPath ~= "" then
				ent:SetModelPath(ent.ModelPath)
			end
		end
	end
end