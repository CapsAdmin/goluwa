local render = (...) or _G.render

render.model_cache = {}

local assimp = require("lj-assimp") -- model decoder

local default_texture_format = {
	mip_map_levels = 4,
	mag_filter = "linear",
	min_filter = "linear_mipmap_linear",
}

function render.CreateMesh(vertices, indices, is_valid_table)		
	return vertices and render.gbuffer_mesh_shader:CreateVertexBuffer(vertices, indices, is_valid_table) or NULL
end

do -- model meta
	local META = metatable.CreateTemplate("mesh3d")
	META.__index = META
	
	function render.Create3DMesh(path, flags, now)
		check(path, "string")
			
		if render.model_cache[path] then
			return render.model_cache[path]
		end
		
		if render.debug then logn("[render] loading mesh: ", path) end

		flags = flags or bit.bor(
			assimp.e.aiProcess_CalcTangentSpace, 
			assimp.e.aiProcess_GenSmoothNormals, 
			assimp.e.aiProcess_Triangulate,
			assimp.e.aiProcess_JoinIdenticalVertices			
		)
		
		flags = assimp.e.aiProcessPreset_TargetRealtime_Quality

		if not vfs.Exists(path) then
			return nil, path .. " not found"
		end
					
		local self = setmetatable({}, META)
		self.sub_models = {}
		self.done = false
		self.path = path
		self.dir = path:match("(.+/)")
		
		render.model_cache[path] = self
		
		self:InvalidateBoundingBox()
		
		local thread = utility.CreateThread()
		
		function thread.OnStart()
			assimp.ImportFileEx(path, flags, function(sub_model_data, i, total_meshes)
				if render.debug then logf("[render] %s loading %q %s\n", path, sub_model_data.name, i .. "/" .. total_meshes) end
				self:InsertSubmodel(sub_model_data)
				self:InvalidateBoundingBox()
			end, true)
		end
		
		function thread.OnFinish()
			self.done = true
		end
		
		--thread:SetIterationsPerTick(10)
		thread:SetIterationsPerTick(math.huge)
		
		thread:Start()
		
		return self
	end
	
	function META:InsertSubmodel(model_data)
		local sub_model = {
			mesh = render.CreateMesh(model_data.mesh_data, model_data.indices), 
			name = model_data.name, 
			bbox = {
				min = Vec3(unpack(model_data.bbox.min)), 
				max = Vec3(unpack(model_data.bbox.max))
			}
		}
				
		if model_data.material and model_data.material.path then
			local paths = {model_data.material.path, self.dir .. model_data.material.path}
			
			for _, path in ipairs(paths) do
				if vfs.Exists(path) then
					sub_model.diffuse = render.CreateTexture(path, default_texture_format)

					do -- try to find normal map
						local path = render.FindTextureFromSuffix(path, "_n", "_ddn", "_nrm")

						if path then
							sub_model.bump = render.CreateTexture(path, default_texture_format)
						end
					end

					do -- try to find specular map
						local path = render.FindTextureFromSuffix(path, "_s", "_spec")

						if path then
							sub_model.specular = render.CreateTexture(path, default_texture_format)
						end
					end
					break
				end
			end
		end
		
		if not sub_model.diffuse then
			sub_model.diffuse = render.GetErrorTexture()
		end
			
		table.insert(self.sub_models, sub_model)
	end
	
	function META:Export(path)
		
	end
	
	do
		local function corner_helper(self, i, j)
			return bit.band(bit.rshift(i, j), 1) == 0 and self.bbox.min or self.bbox.max
		end
		
		function META:InvalidateBoundingBox()
			local min, max = Vec3(), Vec3()

			for i, sub_model in ipairs(self.sub_models) do
				if 
					sub_model.bbox.min.x < min.x and 
					sub_model.bbox.min.y < min.y and 
					sub_model.bbox.min.z < min.z 
				then
					min = sub_model.bbox.min
				end
				
				if 
					sub_model.bbox.max.x > max.x and 
					sub_model.bbox.max.y > max.y and 
					sub_model.bbox.max.z > max.z 
				then
					max = sub_model.bbox.max
				end
			end
			
			self.bbox = {min = min, max = max}
			self.corners = {}
			
			for i = 0, 7 do
				local x = corner_helper(self, i, 2).x
				local y = corner_helper(self, i, 1).y
				local z = corner_helper(self, i, 0).z
				
				self.corners[i+1] = Vec3(x, y, z)
			end
		end
	end

	function META:Draw()
		for _, model in pairs(self.sub_models) do
			model.mesh:Draw()
		end
	end
end