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
	local META = prototype.CreateTemplate("mesh3d")
	
	function render.Create3DMesh(path, flags, now)
		
		if path and render.model_cache[path] then
			return render.model_cache[path]
		end
	
		local self = prototype.CreateObject(META)
		self.sub_models = {}
		
		self:InvalidateBoundingBox()
		
		if path then				
			if render.model_cache[path] then
				return render.model_cache[path]
			end
			
			self:LoadFromDisk(path, flags)
			
			render.model_cache[path] = self
		end
				
		return self
	end
		
	function META:LoadFromDisk(path, flags)
		check(path, "string")
					
		flags = flags or bit.bor(
			assimp.e.aiProcess_CalcTangentSpace, 
			assimp.e.aiProcess_GenSmoothNormals, 
			assimp.e.aiProcess_Triangulate,
			assimp.e.aiProcess_JoinIdenticalVertices			
		)
		
		flags = assimp.e.aiProcessPreset_TargetRealtime_Quality
		
		if render.debug then 
			logn("[render] loading mesh: ", path) 
		end
		
		if not vfs.Exists(path) and vfs.Exists(path .. ".mdl") then
			path = path .. ".mdl"
		end

		if not vfs.Exists(path) then
			return nil, path .. " not found"
		end
		
		self.done = false
		self.path = path
		self.dir = path:match("(.+/)")
							
		self:InvalidateBoundingBox()
		
		local thread = utility.CreateThread()
		
		if path:endswith(".mdl") and steam.LoadModel then
			function thread.OnStart()
				steam.LoadModel(path, function(sub_model_data)
					self:InsertSubmodel(sub_model_data)
					self:InvalidateBoundingBox()
				end, thread)
			end
		else
			function thread.OnStart()
				assimp.ImportFileEx(path, flags, function(sub_model_data, i, total_meshes)
					if render.debug then logf("[render] %s loading %q %s\n", path, sub_model_data.name, i .. "/" .. total_meshes) end
					self:InsertSubmodel(sub_model_data)
					self:InvalidateBoundingBox()
				end, true)
			end
		end
		
		function thread.OnFinish()
			self.done = true
		end
		
		thread:SetIterationsPerTick(15)
		--thread:SetIterationsPerTick(math.huge)
		
		thread:Start()
	end
	
	function META:InsertSubmodel(model_data)
		local sub_model = {
			mesh = render.CreateMesh(model_data.vertices, model_data.indices), 
			name = model_data.name, 
			bbox = {
				min = model_data.bbox.min, 
				max = model_data.bbox.max
			}
		}
		
		-- don't store the geometry on the lua side
		sub_model.mesh:UnreferenceMesh()
				
		if model_data.material then 
			if model_data.material.paths_solved then
				if model_data.material.diffuse then
					sub_model.diffuse = render.CreateTexture(model_data.material.diffuse, default_texture_format)
				elseif model_data.material.bump then
					sub_model.bump = render.CreateTexture(model_data.material.bump, default_texture_format)
				elseif model_data.material.specular then
					sub_model.specular = render.CreateTexture(model_data.material.specular, default_texture_format)
				end
			elseif model_data.material.path then
				local path = model_data.material.path
				
				-- this is kind of ue4 specific
				if model_data.material.name and model_data.material.name:sub(1, 1) == "/" then
					local ext = path:match("^.+(%..+)$")
					local path = model_data.material.name
					path = self.dir .. path:sub(2)
					
					sub_model.diffuse = render.CreateTexture(path .. "_D" .. ext)
					sub_model.bump = render.CreateTexture(path .. "_N" .. ext)
					sub_model.specular = render.CreateTexture(path .. "_S" .. ext)
				else	
					local paths = {path, self.dir .. path}
					
					for _, path in ipairs(paths) do
						if vfs.Exists(path) then
							sub_model.diffuse = render.CreateTexture(path, default_texture_format)

							do -- try to find normal map
								local path = utility.FindTextureFromSuffix(path, "_n", "_ddn", "_nrm")

								if path then
									sub_model.bump = render.CreateTexture(path, default_texture_format)
								end
							end

							do -- try to find specular map
								local path = utility.FindTextureFromSuffix(path, "_s", "_spec")

								if path then
									sub_model.specular = render.CreateTexture(path, default_texture_format)
								end
							end
							break
						end
					end
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
		for _, model in ipairs(self.sub_models) do
			model.mesh:Draw()
		end
	end
	
	prototype.Register(META)
end