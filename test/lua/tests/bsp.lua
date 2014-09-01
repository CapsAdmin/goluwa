if not steam.mounted then
	timer.Start("mounting source games")
	steam.MountAllSourceGames()
	timer.Stop()
	steam.mounted = true
end

local bsp_file
--= vfs.Open("maps/gm_bluehills_test3.bsp") -- gmod
--= vfs.Open("maps/d2_coast_07.bsp") -- hl2
= vfs.Open("maps/ep2_outland_06a.bsp") -- ep2
--= vfs.Open("maps/c3m1_plankcountry.bsp") -- l4d

local header = bsp_file:ReadStructure([[
long ident; // BSP file identifier
long version; // BSP file version
]])
 
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
		table.insert(header.lumps, bsp_file:ReadStructure(struct))
	end

timer.Stop() end

header.map_revision = bsp_file:ReadLong()

logn("BSP ", header.ident)
logn("VERSION ", header.version)
logn("REVISION ", header.map_revision)

local function read_lump_data(index, size, struct)
	local out = {}
	
	local lump = header.lumps[index]
	
	if lump.filelen == 0 then return end
	
	local length = lump.filelen / size
	
	bsp_file:SetPos(lump.fileofs)
	
	if type(struct) == "function" then
		for i = 1, length do
			out[i] = struct()
		end
	else
		for i = 1, length do
			out[i] = bsp_file:ReadStructure(struct)
		end
	end
		
	return out
end

do -- pak
	local lump = header.lumps[41]
	local length = lump.filelen

	bsp_file:SetPos(lump.fileofs)
	local pak = bsp_file:ReadBytes(length)
	
	local name = "temp_bsp.zip"
	
	vfs.Write(name, pak)
	
	vfs.Mount(R(name))
end

timer.Start("reading brushes")
	header.brushes = read_lump_data(19, 12, [[
		int	firstside;	// first brushside
		int	numsides;	// number of brushsides
		int	contents;	// contents flags
	]])
timer.Stop()

timer.Start("reading brushsides")
	header.brushsides = read_lump_data(20, 8, [[
		unsigned short	planenum;	// facing out of the leaf
		short		texinfo;	// texture info
		short		dispinfo;	// displacement info
		short		bevel;		// is the side a bevel plane?
	]])
timer.Stop()

timer.Start("reading verticies")
	header.vertices = read_lump_data(4, 12, "vec3")
timer.Stop() 

timer.Start("reading surfedges")
	header.surfedges = read_lump_data(14, 4, "long")
timer.Stop()

timer.Start("reading edges")
	header.edges = read_lump_data(13, 4, function() return {bsp_file:ReadUnsignedShort(), bsp_file:ReadUnsignedShort()} end)
timer.Stop()

timer.Start("reading faces")
	header.faces = read_lump_data(8, 56, [[
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
timer.Stop()

timer.Start("reading texinfo")	
	header.texinfos = read_lump_data(7, 72, [[
		float textureVecs[8];
		float lightmapVecs[8];
		int flags;
		int texdata;
	]])
timer.Stop()

timer.Start("reading texdata")
	header.texdatas = read_lump_data(3, 32, [[
		vec3 reflectivity;
		int nameStringTableID;
		int width;
		int height;
		int view_width;
		int view_height;
	]])
timer.Stop()

timer.Start("reading texdatastringtable")
	local texdatastringtable = read_lump_data(45, 4, "int")

	local lump = header.lumps[44]

	header.texdatastringdata = {}

	for i = 1, #texdatastringtable do
		bsp_file:SetPos(lump.fileofs + texdatastringtable[i])
		header.texdatastringdata[i] = bsp_file:ReadString()
	end
timer.Stop()

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
	
	bsp_file:SetPos(lump.fileofs)
	
	header.displacements = {}
	
	for i = 1, length do
		local data = bsp_file:ReadStructure(structure)
		
		do -- http://fal.xrea.jp/plugin/SourceSDK/bspfile_8h-source.html				
			data.EdgeNeighbors = {}
			
			for i = 1, 4 do
				data.EdgeNeighbors[i] = {m_SubNeighbors = {bsp_file:ReadStructure(edge_neighbor), bsp_file:ReadStructure(edge_neighbor)}}
			end
			
			data.CornerNeighbors = {}
			
			for i = 1, 4 do
				data.CornerNeighbors[i] = bsp_file:ReadStructure(corner_neighbors)
			end
			
			data.AllowedVerts = {}
			
			for i = 1, 10 do
				data.AllowedVerts[i] = bsp_file:ReadLong()
			end
		end
		
		local old_pos = bsp_file:GetPos()
		
		local lump = header.lumps[34]
		local length = lump.filelen / 20
		bsp_file:SetPos(lump.fileofs + (data.DispVertStart * 20))
		
		local DispVertLength = ((2 ^ data.power) + 1) ^ 2
		
		data.vertex_info = {}

		for i = 1, DispVertLength do

			local vertex = bsp_file:ReadVec3()
			local dist = bsp_file:ReadFloat()
			local alpha = bsp_file:ReadFloat()

			data.vertex_info[i] = {vertex = vertex, dist = dist, alpha = alpha}
		end

		bsp_file:SetPos(old_pos)
		
		header.displacements[i] = data
	end
timer.Stop() end

timer.Start("reading models")
	header.models = read_lump_data(15, 48, [[
		vec3 mins;
		vec3 maxs;
		vec3 origin;
		int headnode;
		int firstface;
		int numfaces;
	]])
timer.Stop()

--[==[
timer.Start("reading physdisp")
	header.physmodels = {}

	local lump = header.lumps[29]

	bsp_file:SetPos(lump.fileofs)

	local numDisplacements = bsp_file:ReadShort()
	local dataSizes = {}

	for i = 1, numDisplacements do
		dataSizes[i] = bsp_file:ReadShort()
	end

	print("physdisps.numDisplacements: " .. numDisplacements)

	--for i = 1, #dataSizes do
	--	print("\t" .. dataSizes[i])
	--end
timer.Stop()

timer.Start("reading physmodels")
	header.physmodels = {}

	local struct = [[
		int modelIndex;
		int dataSize;
		int keydataSize;
		int solidCount;
	]]

	local lump = header.lumps[30]

	bsp_file:SetPos(lump.fileofs)

	while (bsp_file:GetPos() - lump.fileofs) < lump.filelen do
		local physmodel = bsp_file:ReadStructure(struct)

		if physmodel.dataSize > 0 then
			bsp_file:SetPos(bsp_file:GetPos() + physmodel.dataSize + physmodel.keydataSize)
		end

		header.physmodels[#header.physmodels + 1] = physmodel
	end
timer.Stop()]==]


--for i = 1, #header.brushes do
--	local brush = header.brushes[i]
--end

local bsp_mesh = {sub_models = {}}

do timer.Start("building mesh")

	local scale = 0.0254
	
	local function add_vertex(model, texinfo, texdata, pos, blend)
		local a = texinfo.textureVecs
		
		if blend then 
			blend = blend / 255 
		else
			blend = 0
		end
		
		blend = math.clamp(blend, 0, 1)
		
		table.insert(model.mesh_data, {
			pos = Vec3(pos.x * scale, -pos.y * scale, -pos.z * scale), -- copy
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
	
	local function load_texture(material, field)	
		local shader, data = next(material)
		
		if not shader or not data then
			logn("invalid field ", field)
			table.print(material)
		end
		
		if not data[field] then
			if field ~= "$bumpmap" then
				logn("invalid field ", field)
				table.print(material)
			end
			return
		end

		local path = "materials/" .. data[field] .. ".vtf"
		path = path:lower()
		
		if not vfs.IsFile(path) then
			path = "materials/" .. data[field] .. "b.vtf"
		
			if not vfs.IsFile(path) then
				logf("unable to find %s in %s.%s\n", path, shader, field)
				table.print(material)

				return render.GetErrorTexture()
			end
		end
				
		local tex = Texture(path, {mip_map_levels = 8, read_speed = math.huge})
		
		if not tex or tex == render.GetErrorTexture() then
			logf("unable to find %s in %s.%s\n", path, shader, field)
			table.print(material)

			return render.GetErrorTexture()
		end 
		
		return tex
	end

	local meshes = {}

	for model_index = 1, #header.models do
		local sub_model =  {mesh_data = {}}
		
		for i = 1, header.models[model_index].numfaces do
			local face = header.faces[header.models[model_index].firstface + i]
			local texinfo = header.texinfos[1 + face.texinfo]
			local texdata = texinfo and header.texdatas[1 + texinfo.texdata] or nil
			local texname = header.texdatastringdata[1 + texdata.nameStringTableID]:lower()
			
			if texname:sub(0, 5) == "maps/" then
				texname = texname:gsub("maps/.-/(.+)_.-_.-_.+", "%1")
			end
							
			-- split the world up into sub models by texture
			if not meshes[texname] then				
				local model = {mesh_data = {}}
				meshes[texname] = model
				
				local material
				local path = "materials/" .. texname:lower() .. ".vmt"
				
				if vfs.IsFile(path) then
					local str = vfs.Read(path)
					if str then
						material = steam.VDFToTable(str, true)
					else
						material = {LightmappedGeneric = {["$basetexture"] = texname}}
					end
				else
					material = {LightmappedGeneric = {["$basetexture"] = texname}}
				end
			
				if material.water then						
					model.diffuse = load_texture(material, "$normalmap")
				else
					model.diffuse = load_texture(material, "$basetexture")
					model.bump = load_texture(material, "$bumpmap")
					
					if material.worldvertextransition then
						model.diffuse2 = load_texture(material, "$basetexture2")
					end
				end
				
				table.insert(bsp_mesh.sub_models, meshes[texname])
			end

			sub_model = meshes[texname]

			local edge_first = face.firstedge
			local edge_count = face.numedges

			local first, previous, current
			
			if face.dispinfo < 0 then
				for j = 1, edge_count do
					local surfedge = header.surfedges[edge_first + j]
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
				local count = size ^ 2
				
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
	utilities.GenerateNormals(data.mesh_data)
	data.mesh = render.CreateMesh(data.mesh_data)
end

timer.Stop()

logn("SUB_MODELS ", #bsp_mesh.sub_models)

if bsp_world then bsp_world:Remove() end

local world = entities.CreateEntity("clientside")
world:SetModel(bsp_mesh)

bsp_world = world

do return end

if bsp_world then
	for i,v in ipairs(bsp_world) do
		if v:IsValid() then
			v:Remove()
		end
	end
	bsp_world = {}
end

bsp_world = bsp_world or {}

for i, model in ipairs(bsp_mesh.sub_models) do
	local chunk = entities.CreateEntity("physical")
	chunk:SetModel(bsp_mesh)
	
	local triangles = ffi.new("unsigned int[?]", #model.mesh_data)
	for i = 0, #model.mesh_data do triangles[i] = i	end
	
	local vertices = ffi.new("float[?]", #model.mesh_data * 3)
	
	local i = 0
	
	for j, data in ipairs(model.mesh_data) do 
		vertices[i] = data.pos[1] i = i + 1		
		vertices[i] = data.pos[2] i = i + 1		
		vertices[i] = data.pos[3] i = i + 1		
	end	
	
	local mesh = {	
		triangles = {
			count = #model.mesh_data / 3, 
			pointer = triangles, 
			stride = ffi.sizeof("unsigned int") * 3, 
		},					
		vertices = {
			count = #model.mesh_data,  
			pointer = vertices, 
			stride = ffi.sizeof("float") * 3,
		},
	}
	
	chunk:InitPhysics("concave", 0, mesh, true)
	table.insert(bsp_world, chunk)
end

event.AddListener("MouseInput", "bsp_lol", function(button, press)
	
	local ent = entities.CreateEntity("physical")
	ent:InitPhysics("box", 100, 1, 1, 1)
	ent:SetPos(render.GetCamPos())
	ent:SetVelocity(render.GetCamAng():GetForward() * 10)	
end)
