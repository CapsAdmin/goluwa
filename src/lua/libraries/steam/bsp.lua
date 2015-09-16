local steam = ... or _G.steam

local scale = 0.0254

local skyboxes = {
	["gm_construct"] = {AABB(-400, -400, 255,   400, 400, 320) * (1/scale), 0.003},
	["gm_flatgrass"] = {AABB(-400, -400, -430,   400, 400, -360) * (1/scale), 0.003},
	["gm_bluehills_test3"] = {AABB(130, 130, 340,   340, 320, 380) * (1/scale), 0},
	["gm_atomic"] = {AABB(-210, -210, 40,   210, 210, 210) * (1/scale), 0},
}

function steam.SetMap(name)
	steam.bsp_world = steam.bsp_world or entities.CreateEntity("physical")
	steam.bsp_world:SetName(name)
	steam.bsp_world:SetCull(false)
	steam.bsp_world:SetModelPath("maps/" .. name .. ".bsp")
	steam.bsp_world:SetPhysicsModelPath("maps/" .. name .. ".bsp")
end

local function read_lump_data(thread, what, bsp_file, header, index, size, struct)
	local out = {}
	
	local lump = header.lumps[index]
	
	if lump.filelen == 0 then return end
	
	local length = lump.filelen / size
	
	bsp_file:SetPosition(lump.fileofs)
		
	if type(struct) == "function" then
		for i = 1, length do
			out[i] = struct()
			tasks.ReportProgress(what, length)
			tasks.Wait()
		end
	else
		for i = 1, length do
			out[i] = bsp_file:ReadStructure(struct)
			tasks.ReportProgress(what, length)
			tasks.Wait()
		end
	end
				
	return out
end

steam.bsp_cache = steam.bsp_cache or {}

function steam.LoadMap(path)
	path = R(path)

	if steam.bsp_cache[path] then
		return steam.bsp_cache[path]
	end
	
	logn("loading map: ", path)
		
	local bsp_file = assert(vfs.Open(path))

	local header = bsp_file:ReadStructure([[
	long ident; // BSP file identifier
	long version; // BSP file version
	]])
	
	local info = skyboxes[path:match(".+/(.+)%.bsp")]
	
	if info then
		header.sky_aabb = info[1]
		header.sky_scale = info[2]
	end
	 
	do 
		local struct = [[
			int	fileofs;	// offset into file (bytes)
			int	filelen;	// length of lump (bytes)
			int	version;	// lump format version
			char fourCC[4];	// lump ident code
		]]

		local struct_21 = [[
			int	version;	// lump format version
			int	fileofs;	// offset into file (bytes)
			int	filelen;	// length of lump (bytes)
			char fourCC[4];	// lump ident code
		]]

		if header.version > 21 then 
			struct = struct_21
		end
		
		header.lumps = {}

		for i = 1, 64 do
			header.lumps[i] = bsp_file:ReadStructure(struct) 
			tasks.ReportProgress("reading lumps", 64)
			tasks.Wait()
		end
		
	end 

	header.map_revision = bsp_file:ReadLong()

	if steam.debug or _debug then
		logn("BSP ", header.ident)
		logn("VERSION ", header.version)
		logn("REVISION ", header.map_revision)
	end
	
	do	
		tasks.Wait()
		tasks.Report("mounting pak")-- pak
		local lump = header.lumps[41]
		local length = lump.filelen

		bsp_file:SetPosition(lump.fileofs)
		local pak = bsp_file:ReadBytes(length)
		
		local name = "temp_bsp.zip"
		
		vfs.Write(name, pak)
		
		--FIX ME
		
		if LINUX then
			local dir = R(name):match("(.+)%.zip")
			os.execute("rm -f " .. dir)
			os.execute("mkdir " .. dir)
			vfs.PushWorkingDirectory(dir)
				os.execute("unzip -o ../temp_bsp.zip")
			vfs.PopWorkingDirectory()
			vfs.Mount(dir)
		else
			vfs.Mount(R(name))			
		end
	end

	do
		tasks.Wait()
		local function unpack_numbers(str)
			str = str:gsub("%s+", " ")
			local t = str:explode(" ")
			for k,v in ipairs(t) do t[k] = tonumber(v) end
			return unpack(t)
		end
		local entities = {}
		local i = 1 
		bsp_file:PushPosition(header.lumps[1].fileofs)
		for vdf in bsp_file:ReadString():gmatch("{(.-)}") do
			local ent = {}
			for k, v in vdf:gmatch([["(.-)" "(.-)"]]) do
				if k == "angles" then
					v = Ang3(unpack_numbers(v))
				elseif k == "_light" or k == "_ambient" or k:find("color", nil, true) then
					v = ColorBytes(unpack_numbers(v))
				elseif k == "origin" or k:find("dir", nil, true) or k:find("mins", nil, true) or k:find("maxs", nil, true) then
					v = Vec3(unpack_numbers(v))
				end
				ent[k] = tonumber(v) or v
			end
			ent.classname = ent.classname or "unknown"
			if header.sky_aabb and ent.classname == "sky_camera" then
				header.sky_origin = ent.origin
				header.sky_scale = header.sky_scale + ent.scale
			end
			entities[i] = ent
			i = i + 1  
			
			tasks.Wait()
		end
		bsp_file:PopPosition()
		header.entities = entities
	end
		
	do
		tasks.Wait()
		tasks.Report("reading game lump")
		
		local lump = header.lumps[36]
		
		bsp_file:SetPosition(lump.fileofs)
		
		local game_lumps = bsp_file:ReadLong()
		
		for i = 1, game_lumps do
			local id = bsp_file:ReadBytes(4)
			local flags = bsp_file:ReadShort()
			local version = bsp_file:ReadShort()
			local fileofs = bsp_file:ReadLong()
			local filelen = bsp_file:ReadLong()

			if id == "prps" then
				bsp_file:PushPosition(fileofs)					
				
				local count = bsp_file:ReadLong()
				local paths = {}					
				for i = 1, count do 
					local str = bsp_file:ReadString(128, true)
					if str ~= "" then
						paths[i] = str
					end
				end

				local count = bsp_file:ReadLong()
				local leafs = {}					
				for i = 1, count do
					leafs[i] = bsp_file:ReadShort()
				end
				
				local count = bsp_file:ReadLong()
				
				for i = 1, count do
					local lump = bsp_file:ReadStructure([[
						vec3 origin;
						ang3 angles;
						short prop_type;
						short first_leaf;
						short leaf_count;
						byte solid;
						byte flags;
						long skin;
						float fade_min_dist;
						float fade_max_dist;
						
						long lighting_origin_x;
						long lighting_origin_y;
						long lighting_origin_z;
					]])
										
					if version > 4 then
						lump.forced_fade_scale = bsp_file:ReadFloat()
					end						
					
					if version > 5 then
						lump.min_dx_level = bsp_file:ReadShort()
						lump.max_dx_level = bsp_file:ReadShort()
					end
					
					if version > 6 then
						bsp_file:Advance(4*3) -- ???
					end
											
					lump.model = paths[lump.prop_type + 1] or paths[1]
					lump.classname = "static_entity"
					
					table.insert(header.entities, lump)
					
					tasks.Wait()
					tasks.ReportProgress("reading static props", count)
				end
								
				bsp_file:PopPosition()
			end

			--[[if id == "prpd" then
				bsp_file:PushPosition(fileofs)
				
				local count = bsp_file:ReadLong()
				local paths = {}
				logf("prpd paths = %s\n", count)
				
				-- for i = 1, count do 
					-- local str = bsp_file:ReadString()
					-- if str ~= "" then
						-- paths[i] = str
					-- end
				-- end
													
				bsp_file:PopPosition()
			end
					
			if id == "tlpd" then
				bsp_file:PushPosition(fileofs)

				local count = bsp_file:ReadLong()
				logf("tlpd paths = %s\n", count)
				--for i = 1, count do
				--	local a = bsp_file:ReadBytes(4)
				--	local b = bsp_file:ReadByte()
				--	
				--end
				
				bsp_file:PopPosition()
			end]]
		end
		
	end
	
	header.brushes = read_lump_data(thread, "reading brushes", bsp_file, header, 19, 12, [[
		int	firstside;	// first brushside
		int	numsides;	// number of brushsides
		int	contents;	// contents flags
	]])
	
	header.brushsides = read_lump_data(thread, "reading brushsides", bsp_file, header, 20, 8, [[
		unsigned short	planenum;	// facing out of the leaf
		short		texinfo;	// texture info
		short		dispinfo;	// displacement info
		short		bevel;		// is the side a bevel plane?
	]])
	
	header.vertices = read_lump_data(thread, "reading verticies", bsp_file, header, 4, 12, "vec3")
	
	header.surfedges = read_lump_data(thread, "reading surfedges", bsp_file, header, 14, 4, "long")
	
	header.edges = read_lump_data(thread, "reading edges", bsp_file, header, 13, 4, function() return {bsp_file:ReadUnsignedShort(), bsp_file:ReadUnsignedShort()} end)

	header.faces = read_lump_data(thread, "reading faces", bsp_file, header, 8, 56, [[
		unsigned short	planenum;		// the plane number
		byte		side;			// header.faces opposite to the node's plane direction
		byte		onNode;			// 1 of on node, 0 if in leaf
		int		firstedge;		// index into header.surfedges
		short		numedges;		// number of header.surfedges
		short		texinfo;		// texture info
		short		dispinfo;		// displacement info
		short		surfaceFogVolumeID;	// ?
		byte		styles[4];		// switchable lighting info
		int		lightofs;		// offset into lightmap lump
		float		area;			// face area in units^2
		int		LightmapTextureMinsInLuxels[2];	// texture lighting info
		int		LightmapTextureSizeInLuxels[2];	// texture lighting info
		int		origFace;		// original face this was split from
		unsigned short	numPrims;		// primitives
		unsigned short	firstPrimID;
		unsigned int	smoothingGroups;	// lightmap smoothing group
	]])

	header.texinfos = read_lump_data(thread, "reading texinfo", bsp_file, header, 7, 72, [[
		float textureVecs[8];
		float lightmapVecs[8];
		int flags;
		int texdata;
	]])	

	header.texdatas = read_lump_data(thread, "reading texdata", bsp_file, header, 3, 32, [[
		vec3 reflectivity;
		int nameStringTableID;
		int width;
		int height;
		int view_width;
		int view_height;
	]])

	local texdatastringtable = read_lump_data(thread, "reading texdatastringtable", bsp_file, header, 45, 4, "int")

	local lump = header.lumps[44]

	header.texdatastringdata = {}

	for i = 1, #texdatastringtable do
		bsp_file:SetPosition(lump.fileofs + texdatastringtable[i])
		header.texdatastringdata[i] = bsp_file:ReadString()
		tasks.Wait()
	end

	do 
		local structure = [[
			vec3 startPosition; // start position used for orientation
			int DispVertStart; // Index into LUMP_DISP_VERTS.
			int DispTriStart; // Index into LUMP_DISP_TRIS.
			int power; // power - indicates size of surface (2^power	1)
			int minTess; // minimum tesselation allowed
			float smoothingAngle; // lighting smoothing angle
			int contents; // surface contents
			unsigned short MapFace; // Which map face this displacement comes from.
			char asdf[2];
			int LightmapAlphaStart;	// Index into ddisplightmapalpha.
			int LightmapSamplePositionStart; // Index into LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS.
			
			padding byte padding[128];
		]]
			
		local lump = header.lumps[27]
		local length = lump.filelen / 176 
		
		bsp_file:SetPosition(lump.fileofs)
		
		header.displacements = {}
		
		for i = 1, length do
			local data = bsp_file:ReadStructure(structure)
									
			local lump = header.lumps[34]
			
			data.vertex_info = {}
			
			bsp_file:PushPosition(lump.fileofs + (data.DispVertStart * 20))
				for i = 1, ((2 ^ data.power) + 1) ^ 2 do
					local vertex = bsp_file:ReadVec3()
					local dist = bsp_file:ReadFloat()
					local alpha = bsp_file:ReadFloat()
					
					data.vertex_info[i] = {
						vertex = vertex, 
						dist = dist, 
						alpha = alpha
					}
				end

			bsp_file:PopPosition(old_pos)
			
			header.displacements[i] = data
			
			tasks.ReportProgress("reading displacements", length)
			tasks.Wait()
		end
		
	end

	header.models = read_lump_data(thread, "reading models", bsp_file, header, 15, 48, [[
		vec3 mins;
		vec3 maxs;
		vec3 origin;
		int headnode;
		int firstface;
		int numfaces;
	]])
		
	--for i = 1, #header.brushes do
	--	local brush = header.brushes[i]
	--end
	
	local function sky_to_world(pos)
		if header.sky_aabb:IsPointInside(pos) then
			return (pos - header.sky_origin) * header.sky_scale, header.sky_scale
		end
		
		return pos
	end
	
	if header.sky_aabb then
		for i,v in ipairs(header.entities) do
			if v.origin then
				v.origin, v.model_size_mult = sky_to_world(v.origin)
			end
		end
	end
	
	local models = {}

	do 				
		local function add_vertex(model, texinfo, texdata, pos, blend, normal)
			local a = texinfo.textureVecs
			
			if blend then 
				blend = blend / 255 
			else
				blend = 0
			end
			
			blend = math.clamp(blend, 0, 1)
			
			local uv_scale
			
			if header.sky_aabb then
				pos, uv_scale = sky_to_world(pos)
				if uv_scale then uv_scale = 1/uv_scale  end
			end
			
			uv_scale = uv_scale or 1
			
			local vertex = {
				pos = -Vec3(pos.y, pos.x, pos.z) * scale, -- copy
				texture_blend = blend,
				uv = Vec2(
					uv_scale * (a[1] * pos.x + a[2] * pos.y + a[3] * pos.z + a[4]) / texdata.width,
					uv_scale * (a[5] * pos.x + a[6] * pos.y + a[7] * pos.z + a[8]) / texdata.height
				)
			}
			
			if GRAPHICS then
				model:AddVertex(vertex) 
			end
			
			if SERVER then
				table.insert(model, vertex)
			end
		end

		local function bilerpvec(a, b, c, d, alpha1, alpha2)
			return a:Copy():Lerp(alpha1, b):Lerp(alpha2, c:Copy():Lerp(alpha1, d))
		end
		
		local function asdf(corners, start_corner, dims, x, y)
			return bilerpvec(
				corners[1 + (start_corner + 0) % 4], 
				corners[1 + (start_corner + 1) % 4], 
				corners[1 + (start_corner + 3) % 4], 
				corners[1 + (start_corner + 2) % 4], 
				(y - 1) / (dims - 1), 
				(x - 1) / (dims - 1)
			)
		end
		
		local function qwerty(dims, corners, start_corner, dispinfo, x, y)
			local index = (y - 1) * dims + x
			local data = dispinfo.vertex_info[index]
			return asdf(corners, start_corner, dims, x, y) + (data.vertex * data.dist), data.alpha
		end
		
		local meshes = {}
		
		for _, model in ipairs(header.models) do						
			for i = 1, model.numfaces do
				local face = header.faces[model.firstface + i]
							
				local texinfo = header.texinfos[1 + face.texinfo]
				local texdata = texinfo and header.texdatas[1 + texinfo.texdata]
				local texname = header.texdatastringdata[1 + texdata.nameStringTableID]
												
				if texname:lower():find("skyb", nil, true) then goto continue end
				if texname:lower():find("water", nil, true) then goto continue end
									
				-- split the world up into sub models by texture
				if not meshes[texname] then				
					local mesh = GRAPHICS and render.CreateMeshBuilder() or {}
					
					meshes[texname] = mesh
					
					if GRAPHICS then
						mesh.material = render.CreateMaterial("model")
						steam.LoadMaterial("materials/" .. texname .. ".vmt", mesh.material)
					end
					table.insert(models, meshes[texname])
				end

				do
					local mesh = meshes[texname]
					
					if face.dispinfo < 0 then
						local first, previous, current
					
						for j = 1, face.numedges do
							local surfedge = header.surfedges[face.firstedge + j]
							local edge = header.edges[1 + math.abs(surfedge)]
							local current = edge[surfedge < 0 and 2 or 1] + 1

							if j >= 3 then
								if header.vertices[first] and header.vertices[current] and header.vertices[previous] then
									add_vertex(mesh, texinfo, texdata, header.vertices[current])
									add_vertex(mesh, texinfo, texdata, header.vertices[first])
									add_vertex(mesh, texinfo, texdata, header.vertices[previous])
								end
							elseif j == 1 then
								first = current
							end

							previous = current
						end
					else
						local dispinfo = header.displacements[face.dispinfo + 1]
						local size = 2 ^ dispinfo.power + 1
						
						local start_corner_dist = math.huge
						local start_corner = 0
						
						local corners = {}
						
						for j = 1, 4 do
							local face = header.faces[1 + dispinfo.MapFace]
							local surfedge = header.surfedges[1 + face.firstedge + (j - 1)]
							local edge = header.edges[1 + math.abs(surfedge)]
							local vertex = edge[1 + (surfedge < 0 and 1 or 0)]
						
							local corner = header.vertices[1 + vertex]
							local cough = corner:Distance(dispinfo.startPosition)
								
							if cough < start_corner_dist then
								start_corner_dist = cough
								start_corner = j - 1
							end
							
							corners[j] = corner
						end

						local dims = 2 ^ dispinfo.power + 1
										
						for x = 1, dims - 1 do
							for y = 1, dims - 1 do
								add_vertex(mesh, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x + 1, y + 1))
								add_vertex(mesh, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x, y))
								add_vertex(mesh, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x, y + 1))
								
								add_vertex(mesh, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x + 1, y))
								add_vertex(mesh, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x, y))
								add_vertex(mesh, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x + 1, y + 1))
							end
						end
						
						mesh.displacement = true
					end
				end
				
				::continue::
				tasks.ReportProgress("building meshes", model.numfaces)
				tasks.Wait()
			end
			
			-- only world needed
			break 
		end
		
	end
	
	if GRAPHICS then			
		for i, mesh in ipairs(models) do
			mesh:BuildNormals(thread)
			tasks.ReportProgress("generating normals", #models)
			tasks.Wait()
		end 		

		for i, mesh in ipairs(models) do
			if mesh.displacement then
				mesh:SmoothNormals(thread)
			end
			tasks.Report("smoothing displacements", #models)
			tasks.Wait()
		end 
					
		for i, mesh in ipairs(models) do
			mesh:BuildBoundingBox()
			mesh:Upload(true)
			tasks.ReportProgress("creating meshes", #models)
			tasks.Wait()
		end
	end
	
	local physics_meshes = {}
	
	local count = #models

	for i_, model in ipairs(models) do	
		local vertices_tbl = GRAPHICS and model:GetVertices() or model
		local vertices_count = #vertices_tbl
		
		local triangles = ffi.new("unsigned int[?]", vertices_count)
		for i = 0, vertices_count - 1 do triangles[i] = i end
		
		local vertices = ffi.new("float[?]", vertices_count * 3)
		
		local i = 0
		
		--FIX ME
		local _, huh = next(vertices_tbl)
		if type(huh.pos) == "cdata" then
			for j, data in ipairs(vertices_tbl) do 
				vertices[i] = data.pos.x i = i + 1		
				vertices[i] = data.pos.y i = i + 1		
				vertices[i] = data.pos.z i = i + 1		
			end	
		else
			for j, data in ipairs(vertices_tbl) do 
				vertices[i] = data.pos[1] i = i + 1		
				vertices[i] = data.pos[2] i = i + 1		
				vertices[i] = data.pos[3] i = i + 1		
			end	
		end
		
		local mesh = {	
			triangles = {
				count = vertices_count / 3, 
				pointer = triangles, 
				stride = ffi.sizeof("unsigned int") * 3, 
			},					
			vertices = {
				count = vertices_count,  
				pointer = vertices, 
				stride = ffi.sizeof("float") * 3,
			},
		}
		
		physics_meshes[i_] = mesh

		tasks.Wait()
		tasks.ReportProgress("building physics meshes", count)
	end
	
	if GRAPHICS then
		for i, mesh in ipairs(models) do
			mesh:UnreferenceVertices()
		end
	end
	
	local func = steam.bsp_cache[path]
	
	steam.bsp_cache[path] = {
		render_meshes = models,
		entities = header.entities,
		physics_meshes = physics_meshes,
	}

	tasks.ReportProgress("finished reading " .. path)
	return steam.bsp_cache[path]
end

function steam.SpawnMapEntities(path, parent)
	path = R(path)	
	local data = steam.bsp_cache[path]
	
	local thread = tasks.CreateTask()
	thread.debug = true
	
	logn("spawning map entities: ", path)

	function thread:OnStart()
		
		for k,v in ipairs(parent:GetChildrenList()) do
			if v.spawned_from_bsp then
				v:Remove()
			end
		end

		if GRAPHICS then		
			prototype.SafeRemove(parent.world_params)
			parent.world_params = entities.CreateEntity("world", parent)
			parent.world_params.spawned_from_bsp = true
			
			parent:RemoveMeshes()
			
			for i, model in ipairs(data.render_meshes) do
				parent:AddMesh(model)
			end
		end
		
		local count = table.count(data.entities)
		for i, info in pairs(data.entities) do
			if GRAPHICS then
				if info.classname and info.classname:find("light_environment") then
					
					local p, y = info.pitch, info.angles.y
					parent.world_params:SetSunAngles(Deg3(p or 0, y+180, 0))
					
					--info._light.a = 1
					parent.world_params:SetSunColor(Color(info._light.r, info._light.g, info._light.b))
					--parent.world_params:SetAmbientLighting(Color(info._ambient.r, info._ambient.g, info._ambient.b, 0)*0.25)
					parent.world_params:SetSunIntensity(1)
					
					if path:find("esther") then
						parent.world_params:SetSunIntensity(0)
						parent.world_params:GetChildren()[1]:SetShadow(false)
						parent.world_params:SetAmbientLighting(parent.world_params:GetAmbientLighting()*0.25)
					end
										
				elseif info.classname:lower():find("light") and info._light then		
					local ent = entities.CreateEntity("light", parent)
					ent:SetName(info.classname .. "_" .. i)
					ent:SetPosition(info.origin * 0.0254)
					ent:SetHideFromEditor(true)
					
					ent:SetColor(Color(info._light.r, info._light.g, info._light.b, 1))
					ent:SetSize(math.max(info._light.a, 25))
					ent:SetIntensity(math.clamp(info._light.a/9, 0.5, 3))
					
					if info._zero_percent_distance then
						ent:SetSize(ent:GetSize() + info._zero_percent_distance*0.02)
					end
					
					if ent:GetPosition():Distance(render.camera_3d:GetPosition()) < 1 then table.print(info) end
					ent.spawned_from_bsp = true
				elseif info.classname == "env_fog_controller" then
					parent.world_params:SetFogColor(Color(info.fogcolor.r, info.fogcolor.g, info.fogcolor.b, info.fogcolor.a * (info.fogmaxdensity or 1)/4))
					parent.world_params:SetFogStart(info.fogstart* scale)
					parent.world_params:SetFogEnd(info.fogend * scale)
				end
			end
		
			if info.origin and info.angles and info.model and not info.classname:lower():find("npc") then	
				if vfs.IsFile(info.model) then
					local ent = entities.CreateEntity("visual", parent)
					ent:SetName(info.classname .. "_" .. i)
					ent:SetModelPath(info.model)
					ent:SetPosition(info.origin * scale)
					if info.model_size_mult then ent:SetSize(info.model_size_mult) end
					ent:SetAngles(info.angles:GetRad())
					ent:SetHideFromEditor(true)
					ent.spawned_from_bsp = true
				end
			end
			tasks.ReportProgress("spawning entities", count)
			tasks.Wait()
		end	
	end
	
	thread:Start() 
end


for k,v in pairs(entities.GetAll()) do 
	if v:HasComponent("model") then 
		local mesh = v.model.sub_models[1]
		if mesh and mesh.bump2 then
			print(mesh.bump2) 
		end
	end 
end