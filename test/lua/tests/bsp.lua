local vtf_header_structure = [[
long ident; // BSP file identifier
long version; // BSP file version
]]

vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/")
vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/hl2_textures_dir.vpk")

local buffer = Buffer(io.open(R"maps/d1_trainstation_01.bsp", "rb"))

--print(buffer:ReadBytes(4):dumphex())
--print(buffer:ReadBytes(4):dumphex())
--print(buffer:ReadLong())
--print(buffer:ReadBytes(4):dumphex())
--do return end
local header = buffer:ReadStructure(vtf_header_structure)

table.print(header)
--do return end

local lump_struct = [[
	int	fileofs;	// offset into file (bytes)
	int	filelen;	// length of lump (bytes)
	int	version;	// lump format version
	char fourCC[4];	// lump ident code
]]

local face_struct = [[
	unsigned short	planenum;		// the plane number
	byte		side;			// faces opposite to the node's plane direction
	byte		onNode;			// 1 of on node, 0 if in leaf
	int		firstedge;		// index into surfedges
	short		numedges;		// number of surfedges
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

local texinfo_struct = [[
	float textureVecs[8];
	float lightmapVecs[8];
	int flags;
	int texdata;
]]

local texdata_struct = [[
	vec3 reflectivity;
	int nameStringTableID;
	int width;
	int height;
	int view_width;
	int view_height;
]]

local model_struct = [[
	vec3 mins;
	vec3 maxs;
	vec3 origin;
	int headnode;
	int firstface;
	int numfaces;
]]

header.lumps = {}

for i = 1, 64 do
	table.insert(header.lumps, buffer:ReadStructure(lump_struct))
end

header.map_revision = buffer:ReadLong()
print("BSP " .. header.ident .. " VERSION " .. header.version .. " REVISION " .. header.map_revision)

--[[{
	{
		pos = {x, y, z},
		normal = {x, y, z},
		uv = {x, y},
	},
}]]

local vertices = {}

do -- vertices
	local lump = header.lumps[4]
	local length = lump.filelen / 12
	
	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		local x = buffer:ReadFloat()
		local y = buffer:ReadFloat()
		local z = buffer:ReadFloat()
		vertices[i] = {x, y, z}
		--mesh[i] = {}
		--mesh[i].pos  = {buffer:ReadFloat(), buffer:ReadFloat(), buffer:ReadFloat()}
	end
end

--[[do -- vertices
	local lump = header.lumps[4]
	local length = lump.filelen / 12
	
	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		mesh[i] = {}
		mesh[i].pos  = {buffer:ReadFloat(), buffer:ReadFloat(), buffer:ReadFloat()}
	end
end]]

local surfedges = {}

do -- surfedges
	local lump = header.lumps[14]
	local length = lump.filelen / 4

	buffer:SetPos(lump.fileofs)

	print("awdawdwa", length, lump.filelen, lump.fileofs)

	for i = 1, length do
		surfedges[i] = buffer:ReadLong(true)
	end
end

local edges = {}

do -- edges
	local lump = header.lumps[13]
	local length = lump.filelen / 4

	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		local a = buffer:ReadShort()
		local b = buffer:ReadShort()
		edges[i] = {a, b}
	end
end

local faces = {}

-- greatest common divisor
local function gcd(a, b)
	return b ~= 0 and gcd(b, a % b) or math.abs(a)
end

do -- faces
	local lump = header.lumps[8]
	local length = lump.filelen / 56

	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		faces[i] = buffer:ReadStructure(face_struct)
	end
end

local texinfos = {}

do -- texinfo
	local lump = header.lumps[7]
	local length = lump.filelen / 72

	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		texinfos[i] = buffer:ReadStructure(texinfo_struct)
	end
end

local texdatas = {}

do -- texdata
	local lump = header.lumps[3]
	local length = lump.filelen / 32

	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		texdatas[i] = buffer:ReadStructure(texdata_struct)
	end
end

local texdatastringtable = {}

do -- texdatastringtable
	local lump = header.lumps[45]
	local length = lump.filelen / 4

	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		texdatastringtable[i] = buffer:ReadInt()
	end
end

local texdatastringdata = {}

do
	local lump = header.lumps[44]

	--buffer:SetPos(lump.fileofs)

	for i = 1, #texdatastringtable do
		buffer:SetPos(lump.fileofs + texdatastringtable[i])
		texdatastringdata[i] = buffer:ReadString()
	end
end

print(header.lumps[41].filelen)

local models = {}

do -- model
	local lump = header.lumps[15]
	local length = lump.filelen / 36

	buffer:SetPos(lump.fileofs)

	for i = 1, length do
		models[i] = buffer:ReadStructure(model_struct)
	end
end

print("WADWAD MODELS " , #models)

local function calc_texture_coords(texinfo, texdata, x, y, z)
	local a = texinfo.textureVecs
	local u = a[1] * x + a[2] * y + a[3] * z + a[4]
	local v = a[5] * x + a[6] * y + a[7] * z + a[8]
	return u / texdata.width, v / texdata.height
end

local function add_vertex(model, texinfo, texdata, x, y, z)
	table.insert(model.mesh, {
		pos = {x, y, z},
		uv = {calc_texture_coords(texinfo, texdata, x, y, z)},
	})
end

local bsp_mesh = {sub_models = {}}

local meshes = {}

for model_index = 1, #models do
	local sub_model--  =  {mesh = {}}
	
	for i = 1, models[model_index].numfaces do
		local face = faces[models[model_index].firstface + i]
		local texinfo = texinfos[1 + face.texinfo]
		local texdata = texinfo and texdatas[1 + texinfo.texdata] or nil

		local texname = texdatastringdata[1 + texdata.nameStringTableID]:lower()

		if not meshes[texname] then
			meshes[texname] = {
				diffuse = vfs.Exists("materials/" .. texname:lower() .. ".vtf") and Texture("materials/" .. texname:lower() .. ".vtf") or render.GetErrorTexture(), 
				mesh = {}
			}
			table.insert(bsp_mesh.sub_models, meshes[texname])
		end

		sub_model = meshes[texname]

		if true or bit.band(texinfo.flags, 0x2 + 0x4) == 0 then

			local edge_first = face.firstedge
			local edge_count = face.numedges

			local first, previous, current

			for j = 1, edge_count do
				local surfedge = surfedges[edge_first + j]
				local edge = edges[1 + math.abs(surfedge)]
				
				local current = edge[surfedge < 0 and 2 or 1] + 1

				if j >= 3 then
					local p1 = vertices[first]
					local p2 = vertices[current]
					local p3 = vertices[previous]

					if p1 and p2 and p3 then
						add_vertex(sub_model, texinfo, texdata, unpack(p1))
						add_vertex(sub_model, texinfo, texdata, unpack(p2))
						add_vertex(sub_model, texinfo, texdata, unpack(p3))
					end
				elseif j == 1 then
					first = current
				end

				previous = current
			end
		end
	end
	
	--sub_model.diffuse = Texture("materials/brick/brickfloor001a.vtf")
---	sub_model.mesh = render.CreateMesh(sub_model.mesh)	
	---table.insert(bsp_mesh.sub_models, sub_model)
	
	-- only world needed
	break 
end

table.print(bsp_mesh.sub_models[1], 1)

for i, data in ipairs(bsp_mesh.sub_models) do
	if not next(data.mesh) then
		bsp_mesh.sub_models[i] = nil
		print(i)
	else
		bsp_mesh.sub_models[i].mesh = render.CreateMesh(data.mesh)
	end
end 

BSP_MODEL = bsp_mesh
 
include("libraries/ecs.lua")
