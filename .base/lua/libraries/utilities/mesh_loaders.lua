local assimp = requirew("lj-assimp")

do -- render model
	utility.render_model_cache = {}

	local assimp = require("lj-assimp") -- model decoder

	local default_texture_format = {
		mip_map_levels = 4,
		mag_filter = "linear",
		min_filter = "linear_mipmap_linear",
	}

	local function solve_material_paths(mesh, model_data, dir)
		if model_data.material then
			model_data.material.directory = dir							
			
			if model_data.material.paths_solved then
				if model_data.material.diffuse then
					mesh.diffuse = render.CreateTexture(model_data.material.diffuse, default_texture_format)
				elseif model_data.material.bump then
					mesh.bump = render.CreateTexture(model_data.material.bump, default_texture_format)
				elseif model_data.material.specular then
					mesh.specular = render.CreateTexture(model_data.material.specular, default_texture_format)
				end
			elseif model_data.material.path then
				local path = model_data.material.path
				
				-- this is kind of ue4 specific
				if model_data.material.name and model_data.material.name:sub(1, 1) == "/" then
					local ext = path:match("^.+(%..+)$")
					local path = model_data.material.name
					path = model_data.material.directory .. path:sub(2)
					
					mesh.diffuse = render.CreateTexture(path .. "_D" .. ext)
					mesh.bump = render.CreateTexture(path .. "_N" .. ext)
					mesh.specular = render.CreateTexture(path .. "_S" .. ext)
				else	
					local paths = {path, model_data.material.directory .. path}
					
					for _, path in ipairs(paths) do
						if vfs.Exists(path) then
							mesh.diffuse = render.CreateTexture(path, default_texture_format)

							do -- try to find normal map
								local path = utility.FindTextureFromSuffix(path, "_n", "_ddn", "_nrm")

								if path then
									mesh.bump = render.CreateTexture(path, default_texture_format)
								end
							end

							do -- try to find specular map
								local path = utility.FindTextureFromSuffix(path, "_s", "_spec")

								if path then
									mesh.specular = render.CreateTexture(path, default_texture_format)
								end
							end
							break
						end
					end
				end
			end
		end
	end
		
	local cb = utility.CreateCallbackThing(utility.render_model_cache)

	function utility.LoadRenderModel(path, callback, callback2)
		check(path, "string")
		callback2 = callback2 or function() end
		
		if cb:check(path, callback, {mesh = callback2}) then return true end
		
		local data = cb:get(path)
		
		if data then
			if callback2 then
				for i, mesh in ipairs(data) do
					callback2(mesh)
				end
			end
			callback(data)
			return true
		end
		
		if not vfs.Exists(path) and vfs.Exists(path .. ".mdl") then
			path = path .. ".mdl"
		end

		if not path:startswith("http") and not vfs.Exists(path) then			
			return nil, path .. " not found"
		end
		
		local dir = path:match("(.+/)")
		
		cb:start(path, callback, {mesh = callback2})
		
		local out = {}
		
		if path:endswith(".mdl") and steam.LoadModel then
			local thread = utility.CreateThread()
			
			function thread.OnStart()
				local meshes = {}
				steam.LoadModel(path, function(model_data)					
					local mesh = render.CreateMeshBuilder()
					
					solve_material_paths(mesh, model_data, dir)
											
					mesh:SetName(model_data.name)
					mesh:SetVertices(model_data.vertices)
					mesh:SetIndices(model_data.indices)						
					mesh:BuildBoundingBox()
					
					mesh:Upload()
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)
					
				end, thread)
			end
			
			function thread.OnFinish()
				cb:stop(path, out)
			end
			
			thread:SetIterationsPerTick(15)
			
			thread:Start()			
		elseif path:endswith(".bsp") and steam.LoadMap then
			steam.LoadMap(path, function(data, thread)
				for _, mesh in ipairs(data.render_meshes) do 
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)
				end
				
				cb:stop(path, out)
			end)
		elseif assimp then		
			local flags = assimp.e.aiProcessPreset_TargetRealtime_Quality
			--[[
				bit.bor(
					assimp.e.aiProcess_CalcTangentSpace, 
					assimp.e.aiProcess_GenSmoothNormals, 
					assimp.e.aiProcess_Triangulate,
					assimp.e.aiProcess_JoinIdenticalVertices			
				)
			]]
			
			local thread = utility.CreateThread()
			
			if path:startswith("http") then
				vfs.ReadAsync(path, function(data, err)
					if not data then error(err) end
					local meshes = assert(assimp.ImportFileMemory(data, flags, path))
					
					for i, model_data in pairs(meshes) do
						if render.debug then logf("[render] %s loading %q %s\n", path, model_data.name, i .. "/" .. #meshes) end
					
						local mesh = render.CreateMeshBuilder()
						
						solve_material_paths(mesh, model_data, dir)

						mesh:SetName(model_data.name)
						mesh:SetVertices(model_data.vertices)
						mesh:SetIndices(model_data.indices)						
						mesh:BuildBoundingBox()
												
						mesh:Upload()
						cb:callextra(path, "mesh", mesh)
						table.insert(out, mesh)
					end
				end)				
			else						
				function thread.OnStart()
					assimp.ImportFileEx(path, flags, function(model_data, i, total_meshes)
						if render.debug then logf("[render] %s loading %q %s\n", path, model_data.name, i .. "/" .. total_meshes) end
						
						local mesh = render.CreateMeshBuilder()
						
						solve_material_paths(mesh, model_data, dir)

						mesh:SetName(model_data.name)
						mesh:SetVertices(model_data.vertices)
						mesh:SetIndices(model_data.indices)						
						mesh:BuildBoundingBox()
						
						mesh:Upload()
						cb:callextra(path, "mesh", mesh)
						table.insert(out, mesh)
					end, true)
				end
			end
			
			function thread.OnFinish()
				cb:stop(path, out)
			end
			
			thread:SetIterationsPerTick(15)
			
			thread:Start()
		else
			return nil, "unknown format " .. path
		end
		
		return true
	end
end

do -- physics model
	utility.physics_model_cache = {}

	local cb = utility.CreateCallbackThing(utility.physics_model_cache)
	
	function utility.LoadPhysicsModel(path, callback)
		if cb:check(path, callback) then return true end
		
		local data = cb:get(path)
		
		if data then
			callback(data)
			return true
		end

		if not vfs.IsFile(path) then
			return nil, path .. " not found"
		end
		
		cb:start(path, callback)
		
		if path:endswith(".bsp") and steam.LoadMap then
			steam.LoadMap(path, function(data, thread)
				cb:stop(path, data.physics_meshes)
			end)	
		elseif assimp then
			local scene = assimp.ImportFile(R(path), assimp.e.aiProcessPreset_TargetRealtime_Quality)
			
			if scene.mMeshes[0].mNumVertices == 0 then
				return nil, "no vertices found in " .. path
			end
								
			local vertices = ffi.new("float[?]", scene.mMeshes[0].mNumVertices  * 3)
			local triangles = ffi.new("unsigned int[?]", scene.mMeshes[0].mNumFaces * 3)
			
			ffi.copy(vertices, scene.mMeshes[0].mVertices, ffi.sizeof(vertices))

			local i = 0
			for j = 0, scene.mMeshes[0].mNumFaces - 1 do
				for k = 0, scene.mMeshes[0].mFaces[j].mNumIndices - 1 do
					triangles[i] = scene.mMeshes[0].mFaces[j].mIndices[k]
					i = i + 1 
				end
			end
						
			local mesh = {	
				triangles = {
					count = tonumber(scene.mMeshes[0].mNumFaces), 
					pointer = triangles, 
					stride = ffi.sizeof("unsigned int") * 3, 
				},					
				vertices = {
					count = tonumber(scene.mMeshes[0].mNumVertices),  
					pointer = vertices, 
					stride = ffi.sizeof("float") * 3,
				},
			}
			
			cb:stop(path, {mesh})
			
			assimp.ReleaseImport(scene)
		else
			return nil, "unknown format " .. path
		end
		
		return true
	end
end