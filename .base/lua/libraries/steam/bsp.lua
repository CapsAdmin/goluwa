local steam = ... or _G.steam

local mount_info = {
	["gm_.+"] = {"garry's mod"},
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

console.AddCommand("map", function(path)
	local mounts = mount_info[path]
	
	if not mounts then
		for k,v in pairs(mount_info) do
			if path:find(k) then
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
	
	steam.LoadMap("maps/" .. path .. ".bsp")	
end)

local function read_lump_data(thread, what, bsp_file, header, index, size, struct)
	local out = {}
	
	local lump = header.lumps[index]
	
	if lump.filelen == 0 then return end
	
	local length = lump.filelen / size
	
	bsp_file:SetPosition(lump.fileofs)
		
	if type(struct) == "function" then
		for i = 1, length do
			out[i] = struct()
		end
	else
		for i = 1, length do
			out[i] = bsp_file:ReadStructure(struct)
		end
	end
		
	thread:Report(what)
	thread:Sleep()
		
	return out
end

function steam.LoadMap(path, callback)
	local thread = utility.CreateThread()
	
	thread:SetFrequency(120)
	thread:SetIterationsPerTick(10)
	
	function thread:OnStart()
		
		local bsp_file = assert(vfs.Open(path))

		local header = bsp_file:ReadStructure([[
		long ident; // BSP file identifier
		long version; // BSP file version
		]])
		 
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
				thread:ReportProgress("reading lumps", 64)
				thread:Sleep()
			end
			
		end 

		header.map_revision = bsp_file:ReadLong()

		if steam.debug or _debug then
			logn("BSP ", header.ident)
			logn("VERSION ", header.version)
			logn("REVISION ", header.map_revision)
		end
		
		do 
			thread:Report("mounting pak")-- pak
			local lump = header.lumps[41]
			local length = lump.filelen

			bsp_file:SetPosition(lump.fileofs)
			local pak = bsp_file:ReadBytes(length)
			
			local name = "temp_bsp.zip"
			
			vfs.Write(name, pak)
			
			vfs.Mount(R(name))
			
		end
		 
		if false then
			thread:Report("reading game lump")
			
			local lump = header.lumps[36]
			
			bsp_file:SetPosition(lump.fileofs)
			
			local game_lumps = bsp_file:ReadLong()
			
			logf("gamelumps = %s\n", game_lumps)
					
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

					logf("\tprps paths = %s\n", count)
					
					for i = 1,count do 
						local str = bsp_file:ReadString()
						if str ~= "" then
							paths[i] = str
						end
						print(str)
					end
													
					local count = bsp_file:ReadLong()
					local leafs = {}
					logf("\tprps leafs = %s\n", count)
					
					for i = 1, count do
						leafs[i] = bsp_file:ReadShort()
					end
					
					local count = bsp_file:ReadLong()
					local lumps = {}
					logf("\tprps info = %s\n", count)
											
					for i = 1, count do
						lumps[i] = bsp_file:ReadStructure([[
							vec3 m_Origin;
							ang3 m_Angles;
							short m_PropType;
							short m_FirstLeaf;
							short m_LeafCount;
							byte m_Solid;
							byte m_Flags;
							long m_Skin;
							float m_FadeMinDist;
							float m_FadeMaxDist;
							vec3 m_LightingOrigin;
							float m_flForcedFadeScale;
							short m_nMinDXLevel;
							short m_nMaxDXLevel;
						]])
					end
					
					bsp_file:PopPosition()
				end
				
				if id == "prpd" then
					bsp_file:PushPosition(fileofs)
					
					local count = bsp_file:ReadLong()
					local paths = {}
					logf("\tprpd paths = %s\n", count)
					
					for i = 1, count do 
						local str = bsp_file:ReadString()
						if str ~= "" then
							paths[i] = str
						end
					end 			
														
					bsp_file:PopPosition()
				end
						
				if id == "tlpd" then
					bsp_file:PushPosition(fileofs)

					local count = bsp_file:ReadLong()
					logf("\ttlpd paths = %s\n", count)
					--for i = 1, count do
					--	local a = bsp_file:ReadBytes(4)
					--	local b = bsp_file:ReadByte()
					--	
					--end
					
					bsp_file:PopPosition()
				end
			end
			
		end

		do
			local function unpack_numbers(str)
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
				entities[i] = ent
				i = i + 1  
				
				thread:Report("reading entities")
				thread:Sleep()
			end
			bsp_file:PopPosition()
			header.entities = entities
			
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
			thread:Sleep()
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
				
				thread:ReportProgress("reading displacements", length)
				thread:Sleep()
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

		local bsp_mesh = {sub_models = {}}

		do 
			local scale = 0.0254
			
			local function add_vertex(model, texinfo, texdata, pos, blend, normal)
				local a = texinfo.textureVecs
				
				if blend then 
					blend = blend / 255 
				else
					blend = 0
				end
				
				blend = math.clamp(blend, 0, 1)
				
				table.insert(model.vertices, {
					pos = Vec3(-pos.x * scale, pos.y * scale, -pos.z * scale), -- copy
					texture_blend = blend,
					uv = Vec2(
						(a[1] * pos.x + a[2] * pos.y + a[3] * pos.z + a[4]) / texdata.width,
						(a[5] * pos.x + a[6] * pos.y + a[7] * pos.z + a[8]) / texdata.height
					),
					normal = normal,
				}) 
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
			local texture_format = {mip_map_levels = 8, read_speed = math.huge}

			for _, model in ipairs(header.models) do
				local sub_model =  {vertices = {}}
						
				for i = 1, model.numfaces do
					local face = header.faces[model.firstface + i]
								
					local texinfo = header.texinfos[1 + face.texinfo]
					local texdata = texinfo and header.texdatas[1 + texinfo.texdata]
					local texname = header.texdatastringdata[1 + texdata.nameStringTableID]:lower()
								
					if texname:sub(0, 5) == "maps/" then
						texname = texname:gsub("maps/.-/(.+)_.-_.-_.+", "%1")
					end
					
					if texname:find("skyb") then goto continue end
					if texname:find("water") then goto continue end
									
					-- split the world up into sub models by texture
					if not meshes[texname] then				
						local model = {vertices = {}}
										
						meshes[texname] = model
						
						if CLIENT then
							local vmt = steam.LoadMaterial(texname)
							
							if vmt.error then
								logn(vmt.error)
							else
								if vmt.basetexture then
									model.diffuse = Texture(vmt.basetexture, texture_format)
								end
								
								if vmt.basetexture2 then
									model.diffuse2 = Texture(vmt.basetexture2, texture_format)
								end
								
								if vmt.bumpmap then
									model.bump = Texture(vmt.bumpmap, texture_format)
								end
								
								if vmt.specular then
									model.specular = Texture(vmt.envmap, texture_format)
								end
							end
						end
						table.insert(bsp_mesh.sub_models, meshes[texname])
					end

					sub_model = meshes[texname]
					
					if face.dispinfo < 0 then
						local first, previous, current
					
						for j = 1, face.numedges do
							local surfedge = header.surfedges[face.firstedge + j]
							local edge = header.edges[1 + math.abs(surfedge)]
							local current = edge[surfedge < 0 and 2 or 1] + 1

							if j >= 3 then
								if header.vertices[first] and header.vertices[current] and header.vertices[previous] then
									add_vertex(sub_model, texinfo, texdata, header.vertices[first])
									add_vertex(sub_model, texinfo, texdata, header.vertices[current])
									add_vertex(sub_model, texinfo, texdata, header.vertices[previous])
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
								add_vertex(sub_model, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x, y))
								add_vertex(sub_model, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x + 1, y + 1))
								add_vertex(sub_model, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x, y + 1))
								
								add_vertex(sub_model, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x, y))
								add_vertex(sub_model, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x + 1, y))
								add_vertex(sub_model, texinfo, texdata, qwerty(dims, corners, start_corner, dispinfo, x + 1, y + 1))
							end
						end
						
						sub_model.displacement = true
					end
					
					::continue::
					thread:ReportProgress("building meshes", model.numfaces)
					thread:Sleep()
				end
				
				-- only world needed
				break 
			end
			
		end
		
		for i, data in ipairs(bsp_mesh.sub_models) do
			utility.GenerateNormals(data.vertices)	
			thread:ReportProgress("generating normals", #bsp_mesh.sub_models)
			thread:Sleep()
		end 		

		for i, data in ipairs(bsp_mesh.sub_models) do
			if data.displacement then
				utility.SmoothNormals(data.vertices) 
			end
			thread:Report("smoothing displacements", #bsp_mesh.sub_models)
			thread:Sleep()
		end 
		

		if CLIENT then
			for i, data in ipairs(bsp_mesh.sub_models) do
				data.mesh = render.CreateMesh(data.vertices)
				--data.vertices = nil
				thread:ReportProgress("creating meshes", #bsp_mesh.sub_models)
				thread:Sleep()
			end
			
		end

		if steam.debug or _debug then 
			logn("SUB_MODELS ", #bsp_mesh.sub_models) 
		end
		
		entities.SafeRemove(steam.bsp_world)
		
		steam.bsp_world = entities.CreateEntity("clientside")
		steam.bsp_world:SetName(path:match(".+/(.+)%.bsp"))
		
		if CLIENT then 
			steam.bsp_world:SetModel(bsp_mesh) 
		end
		
		local count = table.count(header.entities)
		for _, info in pairs(header.entities) do
			if CLIENT and info.classname then
				if info.classname and info.classname:find("light_environment") then
					local ang = Deg3(info.angles.y, info.pitch, 0)
					
					entities.world:SetSunAngles(ang)					
					entities.world:SetSunSpecularIntensity(0.15)
					entities.world:SetSunIntensity(1)
					
					info._light.a = 1
					entities.world:SetSunColor(Color(info._light.r, info._light.g, info._light.b))
					entities.world:SetAmbientLighting(Color(info._ambient.r, info._ambient.g, info._ambient.b))
				elseif info.classname:lower():find("light") and info._light then		
					local ent = entities.CreateEntity("light", steam.bsp_world)
					ent:SetName(info.classname)
					local pos = info.origin * 0.0254
					ent:SetPosition(Vec3(-pos.y, pos.x, pos.z))
					
					ent:SetColor(Color(info._light.r, info._light.g, info._light.b, 1))
					ent:SetSize(2)
					ent:SetDiffuseIntensity(info._light.a/25) 
					ent:SetRoughness(0.5)
				elseif CLIENT and info.classname == "env_fog_controller" then
					entities.world:SetFogColor(info.fogcolor*0.5)
					entities.world:SetFogStart(info.fogstart* 0.0254)
					entities.world:SetFogEnd(info.fogend * 0.0254 * 2)
				end
			end
		
			if info.origin and info.angles and info.model and not info.classname:lower():find("npc") then	
				if vfs.IsFile(info.model) then
					local ent = entities.CreateEntity("clientside", steam.bsp_world)
					ent:SetName(info.classname)
					ent:SetModelPath(info.model)
					local pos = info.origin * 0.0254
					ent:SetPosition(Vec3(-pos.y, pos.x, pos.z))
					local ang = info.angles:Rad()
					ent:SetAngles(Ang3(ang.p, ang.y, ang.r))
				end
			end
			
			thread:ReportProgress("spawning entities", count)
			thread:Sleep()
		end
		

		local count = #bsp_mesh.sub_models
		for i_, model in ipairs(bsp_mesh.sub_models) do	
			local triangles = ffi.new("unsigned int[?]", #model.vertices)
			for i = 0, #model.vertices - 1 do triangles[i] = i end
			
			local vertices = ffi.new("float[?]", #model.vertices * 3)
			
			local i = 0
			
			if SERVER then
				for j, data in ipairs(model.vertices) do 
					vertices[i] = data.pos.x i = i + 1		
					vertices[i] = data.pos.y i = i + 1		
					vertices[i] = data.pos.z i = i + 1		
				end	
			end
			
			if CLIENT then
				for j, data in ipairs(model.vertices) do 
					vertices[i] = data.pos[1] i = i + 1		
					vertices[i] = data.pos[2] i = i + 1		
					vertices[i] = data.pos[3] i = i + 1		
				end	
			end
			
			local mesh = {	
				triangles = {
					count = #model.vertices / 3, 
					pointer = triangles, 
					stride = ffi.sizeof("unsigned int") * 3, 
				},					
				vertices = {
					count = #model.vertices,  
					pointer = vertices, 
					stride = ffi.sizeof("float") * 3,
				},
			}
			
			local chunk = entities.CreateEntity("physical", steam.bsp_world)
			chunk:SetName("physics chunk " .. i_)
			chunk:SetPhysicsModel(mesh)
			chunk:InitPhysicsTriangles(true)
			chunk:SetMass(0)
			
			thread:ReportProgress("building physics meshes", count)
		end

		if SERVER and WORLD then 
			WORLD:Remove() 
		end
		
		thread:ReportProgress("finished reading " .. path)
	end

	thread:Start()
end