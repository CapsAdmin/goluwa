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

	function utility.LoadRenderModel(path, callback, callback2)
		check(path, "string")
		callback2 = callback2 or function() end
		
		if utility.render_model_cache[path] and utility.render_model_cache[path].callback then
			local old = utility.render_model_cache[path].callback
			utility.render_model_cache[path].callback = function(...)
				old(...)
				callback(...)
			end
			
			local old = utility.render_model_cache[path].callback2
			utility.render_model_cache[path].callback2 = function(...)
				old(...)
				callback2(...)
			end
			return true
		end
		
		if utility.render_model_cache[path] then
			if callback2 then
				for i, mesh in ipairs(utility.render_model_cache[path]) do
					callback2(mesh)
				end
			end
			callback(utility.render_model_cache[path])
			return true
		end
		
		if not vfs.Exists(path) and vfs.Exists(path .. ".mdl") then
			path = path .. ".mdl"
		end

		if not path:startswith("http") and not vfs.Exists(path) then			
			return nil, path .. " not found"
		end
		
		local dir = path:match("(.+/)")
		
		utility.render_model_cache[path] = {callback = callback, callback2 = callback2}
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
					utility.render_model_cache[path].callback2(mesh)
					table.insert(out, mesh)
					
				end, thread)
			end
			
			function thread.OnFinish()
				utility.render_model_cache[path].callback(out)
				utility.render_model_cache[path] = out
			end
			
			thread:SetIterationsPerTick(15)
			
			thread:Start()			
		elseif path:endswith(".bsp") and steam.LoadMap then
			steam.LoadMap(path, function(data, thread)
				for _, mesh in ipairs(data.render_meshes) do 
					utility.render_model_cache[path].callback2(mesh)
					table.insert(out, mesh)
				end
				
				utility.render_model_cache[path].callback(out)
				utility.render_model_cache[path] = out
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
						utility.render_model_cache[path].callback2(mesh)	
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
						utility.render_model_cache[path].callback2(mesh)
						table.insert(out, mesh)
					end, true)
				end
			end
			
			function thread.OnFinish()
				utility.render_model_cache[path].callback(out)
				utility.render_model_cache[path] = out
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

	function utility.LoadPhysicsModel(path, callback)
		if type(utility.physics_model_cache[path]) == "function" then
			local old = utility.physics_model_cache[path]
			utility.physics_model_cache[path] = function(...)
				old(...)
				callback(...)
			end
			return true
		end
		
		if utility.physics_model_cache[path] then
			callback(utility.physics_model_cache[path])
			return true
		end

		if not vfs.IsFile(path) then
			return nil, path .. " not found"
		end
		
		utility.physics_model_cache[path] = callback
		
		if path:endswith(".bsp") and steam.LoadMap then
			steam.LoadMap(path, function(data, thread)
				utility.physics_model_cache[path](data.physics_meshes)
				utility.physics_model_cache[path] = data.physics_meshes
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
			
			local res = {mesh}
			utility.physics_model_cache[path](res)
			utility.physics_model_cache[path] = res
			
			assimp.ReleaseImport(scene)
		else
			return nil, "unknown format " .. path
		end
		
		return true
	end
end