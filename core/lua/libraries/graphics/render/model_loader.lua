local render = ... or _G.render

local assimp = desire("ffi.assimp")
local cb_render 

local mount_info = {
	["gm_.+"] = {"garry's mod", "tf2", "css"},
	["ep1_.+"] = {"half-life 2: episode one"},
	["ep2_.+"] = {"half-life 2: episode two"},
	["trade_.+"] = {"half-life 2", "team fortress 2"},
	["d%d_.+"] = {"half-life 2"},
	["dm_.*"] = {"half-life 2: deathmatch"},
	["c%dm%d_.+"] = {"left 4 dead 2"},

	["esther"] = {"dear esther"},
	["jakobson"] = {"dear esther"},
	["donnelley"] = {"dear esther"},
	["paul"] = {"dear esther"},
	["aramaki_4d"] = {"team fortress 2", "garry's mod"},
	["de_overpass"] = {"counter-strike: global offensive"},
	["sp_a4_finale1"] = {"portal 2"},
	["c3m1_plankcountry"] = {"left 4 dead 2"},
	["achievement_apg_r11b"] = {"half-life 2", "team fortress 2"},
}

local function mount_needed(path)
	local name = path:match("maps/(.+)%.bsp")

	if name then
		local mounts = mount_info[name]
		
		if not mounts then
			for k,v in pairs(mount_info) do
				if name:find(k) then
					mounts = v
					break
				end
			end
		end
		
		if mounts then
			for _, mount in ipairs(mounts) do
				steam.MountSourceGame(mount)
			end
		end
	end
end

render.model_cache = {}

local assimp = desire("ffi.assimp") -- model decoder

local cb = utility.CreateCallbackThing(render.model_cache)

render.model_loader_cb = cb

function render.LoadModel(path, callback, callback2, on_fail)
	check(path, "string")
	
	if cb:check(path, callback, {mesh = callback2, on_fail = on_fail}) then return true end
	
	steam.MountGamesFromPath(path)
	
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
	
	local dir = path:match("(.+/)")
	
	cb:start(path, callback, {mesh = callback2, on_fail = on_fail})
	
	resource.Download(path, function(full_path)			
		local out = {}

		local thread = threads.CreateThread()
		thread.debug = true
		
		function thread:OnStart()							
			if steam.LoadModel and full_path:endswith(".mdl") then				
				steam.LoadModel(full_path, function(mesh)
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)					
				end)
			elseif steam.LoadMap and full_path:endswith(".bsp") then
				for _, mesh in ipairs(steam.LoadMap(full_path).render_meshes) do 
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)
				end
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
								
				assimp.ImportFileEx(full_path, flags, function(model_data, i, total_meshes)
					if render.debug then logf("[render] %s loading %q %s\n", full_path, model_data.name, i .. "/" .. total_meshes) end
					
					local mesh = render.CreateMeshBuilder()
					
					if model_data.material and model_data.material.path then
						local material = render.CreateMaterial("model")
						
						mesh.material = material
						
						local path = model_data.material.path
						
						-- this is kind of ue4 specific
						if model_data.material.name and model_data.material.name:sub(1, 1) == "/" then
							local ext = path:match("^.+(%..+)$")
							local path = model_data.material.name
							path = model_data.material.directory .. path:sub(2)
							
							material:SetDiffuseTexture(path .. "_D" .. ext)
							material:SetNormalTexture(path .. "_N" .. ext)
							material:SetRoughnessTexture(path .. "_S" .. ext)
						else	
							local paths = {path, model_data.material.directory .. path}
							
							for _, path in ipairs(paths) do
								if vfs.Exists(path) then
									material:SetDiffuseTexture(Texture(path))

									do -- try to find normal map
										local path = utility.FindTextureFromSuffix(path, "_n", "_ddn", "_nrm")

										if path then
											material:SetNormalTexture(path)
										end
									end

									do -- try to find specular map
										local path = utility.FindTextureFromSuffix(path, "_s", "_spec")

										if path then
											material:SetRoughnessTexture(path)
										end
									end
									break
								end
							end
						end
					end
					
					
					mesh:SetName(model_data.name)
					mesh:SetVertices(model_data.vertices)
					mesh:SetIndices(model_data.indices)						
					mesh:BuildBoundingBox()
					
					mesh:Upload()
					cb:callextra(path, "mesh", mesh)
					table.insert(out, mesh)
				end, not vfs.IsFile("os:"..path))
			else
				cb:callextra(path, "on_fail", "unknown format " .. path)
			end
			
			cb:stop(path, out)
		end
		
		thread:Start()
	end, function(reason)
		cb:callextra(path, "on_fail", reason)
	end)
	
	return true
end