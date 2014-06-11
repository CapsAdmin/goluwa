local vtf_header_structure = [[
long ident; // BSP file identifier
long version; // BSP file version
]]


--[[vfs.Mount(steam.GetGamePath("Counter-Strike Global Offensive") .. "csgo/")
vfs.Mount(steam.GetGamePath("Counter-Strike Global Offensive") .. "csgo/pak01_dir.vpk")
local buffer = Buffer(io.open(R"maps/cs_agency.bsp", "rb"))]]

local buffer

local map = "hl2"

if map == "hl2" then
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/")
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/hl2_misc_dir.vpk")
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/hl2_textures_dir.vpk") 
	buffer = Buffer(io.open(R"maps/d2_coast_04.bsp", "rb"))
elseif map == "gmod" then
	vfs.Mount(steam.GetGamePath("GarrysMod") .. "garrysmod/")
	vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_misc_dir.vpk")
	vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_textures_dir.vpk") 
	vfs.Mount(steam.GetGamePath("GarrysMod") .. "garrysmod/garrysmod_dir.vpk") 
	buffer = Buffer(io.open(R"maps/gm_construct.bsp", "rb"))
elseif map == "ep2" then
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "ep2/")
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/hl2_misc_dir.vpk")
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/hl2_textures_dir.vpk")
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "ep2/ep2_pak_dir.vpk")
	buffer = Buffer(vfs.GetFile("maps/ep2_outland_06a.bsp", "rb"))
elseif map == "l4d2" then
	vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "left4dead2/")
	vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "left4dead2/pak01_dir.vpk")
	buffer = Buffer(vfs.GetFile("maps/c3m1_plankcountry.bsp", "rb"))
end

local header = buffer:ReadStructure(vtf_header_structure)
 

do timer.Start("reading lumps") -- lumps
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
		table.insert(header.lumps, buffer:ReadStructure(struct))
	end

timer.Stop() end

header.map_revision = buffer:ReadLong()

logn("BSP ", header.ident)
logn("VERSION ", header.version)
logn("REVISION ", header.map_revision)

local function read_lump_data(index, size)
	local out = {}
	
	local lump = header.lumps[index]
	local length = lump.filelen / size
	
	buffer:SetPos(lump.fileofs)	
end

do timer.Start("reading verticies")
	local lump = header.lumps[4]
	local length = lump.filelen / 12
	
	buffer:SetPos(lump.fileofs)
	
	header.vertices = {}

	for i = 1, length do
		header.vertices[i] = buffer:ReadVec3()
	end
timer.Stop() end

do timer.Start("reading surfedges")
	local lump = header.lumps[14]
	local length = lump.filelen / 4

	buffer:SetPos(lump.fileofs)
	
	header.surfedges = {}

	for i = 1, length do
		header.surfedges[i] = buffer:ReadLong(true)
	end
timer.Stop() end

do timer.Start("reading edges")
	local lump = header.lumps[13]
	local length = lump.filelen / 4

	buffer:SetPos(lump.fileofs)
	
	header.edges = {}

	for i = 1, length do
		local a = buffer:ReadShort()
		local b = buffer:ReadShort()
		header.edges[i] = {a, b}
	end
timer.Stop() end

do timer.Start("reading faces")
	local struct = [[
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
	]]

	local lump = header.lumps[8]
	local length = lump.filelen / 56

	buffer:SetPos(lump.fileofs)
	
	header.faces = {}

	for i = 1, length do
		header.faces[i] = buffer:ReadStructure(struct)
	end
timer.Stop() end

do timer.Start("reading texinfo")
	local struct = [[
		float textureVecs[8];
		float lightmapVecs[8];
		int flags;
		int texdata;
	]]

	local lump = header.lumps[7]
	local length = lump.filelen / 72

	buffer:SetPos(lump.fileofs)
	
	header.texinfos = {}

	for i = 1, length do
		header.texinfos[i] = buffer:ReadStructure(struct)
	end
timer.Stop() end

do timer.Start("reading texdata")
	local struct = [[
		vec3 reflectivity;
		int nameStringTableID;
		int width;
		int height;
		int view_width;
		int view_height;
	]]

	local lump = header.lumps[3]
	local length = lump.filelen / 32

	buffer:SetPos(lump.fileofs)
	
	header.texdatas = {}

	for i = 1, length do
		header.texdatas[i] = buffer:ReadStructure(struct)
	end
timer.Stop() end

do timer.Start("reading texdatastringtable")
	local lump = header.lumps[45]
	local length = lump.filelen / 4

	buffer:SetPos(lump.fileofs)
	
	local texdatastringtable = {}

	for i = 1, length do
		texdatastringtable[i] = buffer:ReadInt()
	end
	
	local lump = header.lumps[44]

	header.texdatastringdata = {}

	for i = 1, #texdatastringtable do
		buffer:SetPos(lump.fileofs + texdatastringtable[i])
		header.texdatastringdata[i] = buffer:ReadString()
	end
timer.Stop() end

do timer.Start("reading displacements")
	local structure = [[
		vec3			startPosition;		// start position used for orientation
		int			DispVertStart;		// Index into LUMP_DISP_VERTS.
		int			DispTriStart;		// Index into LUMP_DISP_TRIS.
		int			power;			// power - indicates size of surface (2^power	1)
		int			minTess;		// minimum tesselation allowed
		float			smoothingAngle;		// lighting smoothing angle
		int			contents;		// surface contents
		unsigned short		MapFace;		// Which map face this displacement comes from.
		char asdf[2];
		int			LightmapAlphaStart;	// Index into ddisplightmapalpha.
		int			LightmapSamplePositionStart;	// Index into LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS.
		
		
		//CDispNeighbor		EdgeNeighbors[4];	// Indexed by NEIGHBOREDGE_ defines.
		//CDispCornerNeighbors	CornerNeighbors[4];	// Indexed by CORNER_ defines.
		//unsigned int		AllowedVerts[10];	// active verticies
	]]
	
	local edge_neighbor = [[
		unsigned short 	m_iNeighbor;
		unsigned char 	m_NeighborOrientation;
		unsigned char 	m_Span;
		unsigned char 	m_NeighborSpan;
		char llol;
	]]
	
	local corner_neighbors = [[
		unsigned short m_Neighbors[4]; // indices of neighbors.
		unsigned char m_nNeighbors;
		char llol;
	]]
	
	local lump = header.lumps[27]
	local length = lump.filelen / 176 
	
	buffer:SetPos(lump.fileofs)
	
	header.displacements = {}
	
	for i = 1, length do
		local data = buffer:ReadStructure(structure)
		
		do -- http://fal.xrea.jp/plugin/SourceSDK/bspfile_8h-source.html				
			data.EdgeNeighbors = {}
			
			for i = 1, 4 do
				data.EdgeNeighbors[i] = {m_SubNeighbors = {buffer:ReadStructure(edge_neighbor), buffer:ReadStructure(edge_neighbor)}}
			end
			
			data.CornerNeighbors = {}
			
			for i = 1, 4 do
				data.CornerNeighbors[i] = buffer:ReadStructure(corner_neighbors)
			end
			
			data.AllowedVerts = {}
			
			for i = 1, 10 do
				data.AllowedVerts[i] = buffer:ReadLong()
			end
		end
		
		local old_pos = buffer:GetPos()
		
		local lump = header.lumps[34]
		local length = lump.filelen / 20
		buffer:SetPos(lump.fileofs + (data.DispVertStart * 20))
		
		local DispVertLength = ((2 ^ data.power) + 1) ^ 2
		
		data.vertex_info = {}

		for i = 1, DispVertLength do

			local vertex = buffer:ReadVec3()
			local dist = buffer:ReadFloat()
			local alpha = buffer:ReadFloat()

			data.vertex_info[i] = {vertex = vertex, dist = dist, alpha = alpha}
		end

		buffer:SetPos(old_pos)
		
		header.displacements[i] = data
	end
timer.Stop() end

do timer.Start("reading models")
	local model_struct = [[
		vec3 mins;
		vec3 maxs;
		vec3 origin;
		int headnode;
		int firstface;
		int numfaces;
	]]

	local lump = header.lumps[15]
	local length = lump.filelen / 48

	buffer:SetPos(lump.fileofs)

	header.models = {}
	
	for i = 1, length do
		header.models[i] = buffer:ReadStructure(model_struct)
	end
timer.Stop() end

local bsp_mesh = {sub_models = {}}

do timer.Start("building mesh")

	local function add_vertex(model, texinfo, texdata, pos, blend)
		local a = texinfo.textureVecs
		
		if blend then 
			blend = blend / 255 
		else
			blend = 0
		end
		
		table.insert(model.mesh, {
			pos = Vec3(pos.x, -pos.y, -pos.z), -- copy
			texture_blend = blend,
			uv = Vec2(
				(a[1] * pos.x + a[2] * pos.y + a[3] * pos.z + a[4]) / texdata.width,
				(a[5] * pos.x + a[6] * pos.y + a[7] * pos.z + a[8]) / texdata.height
			)
		})
	end

	local function get_face_vertex(face_index, i)
		local face = header.faces[1 + face_index]

		local surfedge = header.surfedges[1 + face.firstedge + (i - 1)]
		local edge = header.edges[1 + math.abs(surfedge)]
		local vertex = edge[1 + (surfedge < 0 and 1 or 0)]

		return vertex
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

	for model_index = 1, #header.models do
		local sub_model =  {mesh = {}}
		
		for i = 1, header.models[model_index].numfaces do
			local face = header.faces[header.models[model_index].firstface + i]
			local texinfo = header.texinfos[1 + face.texinfo]
			local texdata = texinfo and header.texdatas[1 + texinfo.texdata] or nil

			-- split the world up into sub models by texture
			if model_index == 1 then
				local texname = header.texdatastringdata[1 + texdata.nameStringTableID]:lower()
				
				if not meshes[texname] then
					
					if texname:sub(0, 5) == "maps/" then
						texname = texname:gsub("maps/.-/(.+)_.-_.-_.+", "%1")
					end
					
					local path = "materials/" .. texname:lower() .. ".vtf"
					local path2
					local detail
					local detailscale
					local exists = vfs.Exists(path) 

					if not exists then
						path = "materials/" .. texname:lower() .. ".vmt"
						
						if vfs.Exists(path) then
							local str = vfs.Read(path)
							local tbl = steam.VDFToTable(str)
							
							if tbl.WorldVertexTransition then
								path = "materials/" .. tbl.WorldVertexTransition["$basetexture"]:lower() .. ".vtf"
								path2 = "materials/" .. tbl.WorldVertexTransition["$basetexture2"]:lower() .. ".vtf"
								if tbl.WorldVertexTransition["$detail"] then
									detail = "materials/" .. tbl.WorldVertexTransition["$detail"]:lower() .. ".vtf"
									detailscale = tbl.WorldVertexTransition["$detailscale"]
								end
								if vfs.Exists(path) then
									exists = true
								end
							end
							
							if tbl.LightmappedGeneric and tbl.LightmappedGeneric["$basetexture"] then
								path = "materials/" .. tbl.LightmappedGeneric["$basetexture"]:lower() .. ".vtf"								
								if vfs.Exists(path) then
									exists = true
								end
							end
							
							if tbl.Water and tbl.Water["$normalmap"] then
								path = "materials/" .. tbl.Water["$normalmap"]:lower() .. ".vtf"								
								if vfs.Exists(path) then
									exists = true
								end
							end
						end
					end
					
					if not exists then
						print(string.format("Texture %q not found", path))
					end
					
					meshes[texname] = { 
						diffuse = exists and Texture(path, {mip_map_levels = 8}) or render.GetErrorTexture(), 
						diffuse2 = path2 and Texture(path2, {mip_map_levels = 8}) or diffuse,
						--detail = detail and Texture(detail, {mip_map_levels = 8}),
						--detailscale = detailscale,
						mesh = {}
					}

					table.insert(bsp_mesh.sub_models, meshes[texname])
				end

				sub_model = meshes[texname]
			end

			local edge_first = face.firstedge
			local edge_count = face.numedges

			local first, previous, current

			if face.dispinfo < 0 then
				for j = 1, edge_count do
					local surfedge = header.surfedges[edge_first + j]
					local edge = header.edges[1 + math.abs(surfedge)]
					
					local current = edge[surfedge < 0 and 2 or 1] + 1

					if j >= 3 then
						add_vertex(sub_model, texinfo, texdata, header.vertices[first])
						add_vertex(sub_model, texinfo, texdata, header.vertices[current])
						add_vertex(sub_model, texinfo, texdata, header.vertices[previous])
					elseif j == 1 then
						first = current
					end

					previous = current
				end
			else
				local dispinfo = header.displacements[face.dispinfo + 1]
				local size = 2 ^ dispinfo.power + 1
				local count = size ^ 2
				
				local start_corner_dist = math.huge
				local start_corner = 0
				local corners = {}
				
				for i = 1, 4 do
					local face = header.faces[1 + dispinfo.MapFace]
					local surfedge = header.surfedges[1 + face.firstedge + (i - 2)]
					local edge = header.edges[1 + math.abs(surfedge)]
					local vertex = edge[1 + (surfedge < 0 and 1 or 0)]
				
					corners[i] = header.vertices[1 + vertex]
					
					local cough = corners[i]:Distance(dispinfo.startPosition)
					
					if cough < start_corner_dist then
						start_corner_dist = cough
						start_corner = i - 1
					end
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
			end
		end
		
		if model_index ~= 1 then
			sub_model.diffuse = render.GetErrorTexture()
			sub_model.mesh = render.CreateMesh(sub_model.mesh)	
			table.insert(bsp_mesh.sub_models, sub_model)
		end
		
		-- only world needed
		break 
	end
timer.Stop() end

timer.Start("render.CreateMesh")

for i, data in ipairs(bsp_mesh.sub_models) do
	bsp_mesh.sub_models[i].mesh = render.CreateMesh(data.mesh)
end

timer.Stop()

logn("SUB_MODELS ", #bsp_mesh.sub_models)
 
include("libraries/ecs.lua")

local world = ecs.CreateEntity("shape")
world:SetModel(bsp_mesh)
