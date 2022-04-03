local CUBEMAPS = false
local render3d = ... or _G.render3d

local ffi = require("ffi")

steam.loaded_bsp = steam.loaded_bsp or {}

local scale = 1/0.0254

local skyboxes = {
	["gm_construct"] = {AABB(-400, -400, 255,   400, 400, 320) * scale, 0.003},
	["gm_flatgrass"] = {AABB(-400, -400, -430,   400, 400, -360) * scale, 0.003},
	["gm_bluehills_test3"] = {AABB(130, 130, 340,   340, 320, 380) * scale, 0},
	["gm_atomic"] = {AABB(-210, -210, 40,   210, 210, 210) * scale, 0},
	["de_bank"] = {AABB(115, -74, -77, 261, 64, -28) * scale, 0.003},
	["rp_hometown1999"] = {AABB(78, -61, -1, 98, -45, 5) * scale, 0.003},
	["gm_freespace_13"] = {AABB(-500, -500, 200, 500, 500, 600) * scale, 0},
}

function steam.SetMap(name)
	if tonumber(name) then
		local workshop_id = tonumber(name)
		local info = serializer.LookupInFile("luadata", "workshop_maps.cfg", workshop_id)
		if info and vfs.IsFile(info.path) then
			steam.MountSourceGame(info.appid)
			vfs.Mount(info.path, "maps/")
			steam.SetMap(info.name)
		else
			steam.DownloadWorkshop(workshop_id, function(path, info)
				local name = info.publishedfiledetails[1].filename:match(".+/(.+)%.bsp")
				local appid = info.publishedfiledetails[1].creator_app_id
				serializer.StoreInFile("luadata", "workshop_maps.cfg", workshop_id, {
					path = path,
					name = name,
					appid = appid,
				})
				steam.MountSourceGame(appid)
				vfs.Mount(path, "maps/")
				steam.SetMap(name)
			end)
		end
		return
	end

	local path = "maps/" .. name .. ".bsp"

	steam.bsp_world = steam.bsp_world or entities.CreateEntity("physical", entities.GetWorld())
	steam.bsp_world:SetName(name)
	steam.bsp_world:SetModelPath(path)
	steam.bsp_world:SetPhysicsModelPath(path)
	steam.bsp_world:RemoveChildren()

	-- hack because promises will force SetModelPath to run one frame later
	event.Delay(0.1, function() 
		tasks.WaitForTask(path, function()
			utility.PushTimeWarning()
			steam.SpawnMapEntities(path, steam.bsp_world)
			utility.PopTimeWarning("spawning map entities")
		end)
	end)
end

do
	local function init()
		local tex = render.CreateTexture("cube_map")
		tex:SetMinFilter("linear")
		tex:SetMagFilter("linear")
		tex:SetWrapS("clamp_to_edge")
		tex:SetWrapT("clamp_to_edge")
		tex:SetWrapR("clamp_to_edge")
		return tex
	end

	function steam.LoadSkyTexture(name)
		if not name or name == "painted" then
			name = "sky_wasteland02"
		end
		steam.sky_tex = init()
		logn("using ", name, " as sky texture")
		steam.sky_tex:LoadCubemap("materials/skybox/"..name..".vmt")
	end

	function steam.GetSkyTexture()
		if not steam.sky_tex then
			steam.sky_tex = init()
			steam.LoadSkyTexture()
		end

		return steam.sky_tex
	end
end

local function read_lump_data(what, bsp_file, header, index, size, struct)
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

function steam.LoadMap(path)
	path = R(path)
	
	logn("loading map: ", path)

	local bsp_file = assert(vfs.Open(path))

	if bsp_file:GetSize() == 0 then
		error("map is empty? (size is 0)")
	end

	local header = bsp_file:ReadStructure([[
	long ident; // BSP file identifier
	long version; // BSP file version
	]])

	do
		local info = skyboxes[path:match(".+/(.+)%.bsp")]

		if info then
			header.sky_aabb = info[1]
			header.sky_scale = info[2]
		end
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

	if steam.debug then
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

		local ok, err = vfs.Mount(R(name))
		
		if not vfs.IsDirectory(R(name)) then
			wlog("cannot mount bsp zip " .. name .. " because the zip file is not a directory")
			wlog("assets from this map will be missing")
		end
	end

	do
		tasks.Wait()
		local function unpack_numbers(str)
			str = str:gsub("%s+", " ")
			local t = str:split(" ")
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

		for _ = 1, game_lumps do
			local id = bsp_file:ReadBytes(4)
			local flags = bsp_file:ReadShort()
			local version = bsp_file:ReadShort()
			local fileofs = bsp_file:ReadLong()
			local filelen = bsp_file:ReadLong()

			if id == "prps" then
				bsp_file:PushPosition(fileofs)

				local count

				count = bsp_file:ReadLong()
				local paths = {}
				for i = 1, count do
					local str = bsp_file:ReadString(128, true)
					if str ~= "" then
						paths[i] = str
					end
				end

				count = bsp_file:ReadLong()
				local leafs = {}
				for i = 1, count do
					leafs[i] = bsp_file:ReadShort()
				end
				
				count = bsp_file:ReadLong()
				
				local lump_size = ((filelen + fileofs) - bsp_file:GetPosition()) / count
				for _ = 1, count do
					local pos = bsp_file:GetPosition()
					
					local lump = bsp_file:ReadStructure([[
						vec3 origin; // origin
						ang3 angles; // orientation (pitch yaw roll)

						unsigned short prop_type; // index into model name dictionary
						unsigned short first_leaf; // index into leaf array
						unsigned short leaf_count; // solidity type
						byte solid;
						byte flags; // model skin numbers

						int skin;
						float fade_min_dist;
						float fade_max_dist;

						vec3 lighting_origin; // for lighting
					]])
					
					if version >= 5 then
						lump.forced_fade_scale = bsp_file:ReadFloat()
					end

					if version == 6 or version == 7 then
						lump.min_dx_level = bsp_file:ReadUnsignedShort()
						lump.max_dx_level = bsp_file:ReadUnsignedShort()
					end

					if version >= 8 then
						lump.min_cpu_level = bsp_file:ReadUnsignedByte()
						lump.max_cpu_level = bsp_file:ReadUnsignedByte()

						lump.min_gpu_level = bsp_file:ReadUnsignedByte()
						lump.max_gpu_level = bsp_file:ReadUnsignedByte()
					end

					if version >= 7 then
						lump.rendercolor = bsp_file:ReadByteColor()
					end


					if version == 11  then
						-- not sure what this padding is
						bsp_file:Advance(4)

						if version == 9 or version == 10 then
							lump.disable_xbox360 = bsp_file:ReadBoolean()
						end

						if version >= 10 then
							lump.flags_ex = bsp_file:ReadUnsignedLong()
						end

						if version >= 11 then
							lump.uniform_scale = bsp_file:ReadFloat()
						end
					else
						local remaining = tonumber(lump_size - (bsp_file:GetPosition() - pos))
						bsp_file:Advance(remaining)
						--local bytes = bsp_file:ReadBytes(remaining)
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

	if CUBEMAPS then
		header.cubemaps = read_lump_data("reading cubemaps", bsp_file, header, 43, 12 + 1, [[
			int origin[3];
			unsigned byte size;
		]])

		for k,v in ipairs(header.cubemaps) do
			v.origin = Vec3(unpack(v.origin))
		end
	end

	header.brushes = read_lump_data("reading brushes", bsp_file, header, 19, 12, [[
		int	firstside;	// first brushside
		int	numsides;	// number of brushsides
		int	contents;	// contents flags
	]])

	header.brushsides = read_lump_data("reading brushsides", bsp_file, header, 20, 8, [[
		unsigned short	planenum;	// facing out of the leaf
		short		texinfo;	// texture info
		short		dispinfo;	// displacement info
		short		bevel;		// is the side a bevel plane?
	]])

	header.vertices = read_lump_data("reading verticies", bsp_file, header, 4, 12, "vec3")

	header.surfedges = read_lump_data("reading surfedges", bsp_file, header, 14, 4, "long")

	header.edges = read_lump_data("reading edges", bsp_file, header, 13, 4, function() return {bsp_file:ReadUnsignedShort(), bsp_file:ReadUnsignedShort()} end)

	header.faces = read_lump_data("reading faces", bsp_file, header, 8, 56, [[
		unsigned short	planenum;		// the plane number
		byte		side;			// header.faces opposite to the node's plane direction
		byte		onNode;			// 1 of on node, 0 if in leaf
		int		firstedge;		// index into header.surfedges
		short		numedges;		// number of header.surfedges
		short		texinfo;		// texture info
		short		dispinfo;		// displacement info
		short		render2dFogVolumeID;	// ?
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

	header.texinfos = read_lump_data("reading texinfo", bsp_file, header, 7, 72, [[
		float textureVecs[8];
		float lightmapVecs[8];
		int flags;
		int texdata;
	]])

	header.texdatas = read_lump_data("reading texdata", bsp_file, header, 3, 32, [[
		vec3 reflectivity;
		int nameStringTableID;
		int width;
		int height;
		int view_width;
		int view_height;
	]])

	local texdatastringtable = read_lump_data("reading texdatastringtable", bsp_file, header, 45, 4, "int")

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
			int power; // power - indicates size of render2d (2^power	1)
			int minTess; // minimum tesselation allowed
			float smoothingAngle; // lighting smoothing angle
			int contents; // render2d contents
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

			data.heightmap = {}

			bsp_file:PushPosition(lump.fileofs + (data.DispVertStart * 20))
			for i = 1, ((2 ^ data.power) + 1) ^ 2 do
				local pos = bsp_file:ReadVec3()
				local dist = bsp_file:ReadFloat()
				local alpha = bsp_file:ReadFloat()

				data.heightmap[i] = {
					pos = pos,
					dist = dist,
					alpha = alpha
				}
			end
			bsp_file:PopPosition()

			header.displacements[i] = data

			tasks.ReportProgress("reading displacements", length)
			tasks.Wait()
		end

	end

	header.models = read_lump_data("reading models", bsp_file, header, 15, 48, [[
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
		for _, v in ipairs(header.entities) do
			if v.origin then
				v.origin, v.model_size_mult = sky_to_world(v.origin)
			end
		end
	end

	local models = {}

	do
		local function add_vertex(model, texinfo, texdata, pos, blend)
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
				pos = -Vec3(pos.y, pos.x, pos.z) * steam.source2meters, -- copy
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

		local function lerp_corners(dims, corners, start_corner, dispinfo, x, y)
			local index = (y - 1) * dims + x
			local data = dispinfo.heightmap[index]
			return math3d.BilerpVec3(
				corners[1 + (start_corner + 0) % 4],
				corners[1 + (start_corner + 1) % 4],
				corners[1 + (start_corner + 3) % 4],
				corners[1 + (start_corner + 2) % 4],
				(y - 1) / (dims - 1),
				(x - 1) / (dims - 1)
			) + (data.pos * data.dist), data.alpha
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
					local mesh = GRAPHICS and gfx.CreatePolygon3D() or {}

					meshes[texname] = mesh

					if GRAPHICS then
						mesh:SetName(path .. ": " .. texname)
						mesh.material = render.CreateMaterial("model")
						mesh.material:LoadVMT("materials/" .. texname .. ".vmt")
					end
					table.insert(models, meshes[texname])
				end

				do
					local mesh = meshes[texname]

					if face.dispinfo == -1 then
						local first, previous

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
						local info = header.displacements[face.dispinfo + 1]

						local start_corner_dist = math.huge
						local start_corner = 0

						local corners = {}

						for j = 1, 4 do
							local face = header.faces[1 + info.MapFace]
							local surfedge = header.surfedges[1 + face.firstedge + (j - 1)]
							local edge = header.edges[1 + math.abs(surfedge)]
							local vertex = edge[1 + (surfedge < 0 and 1 or 0)]

							local corner = header.vertices[1 + vertex]
							local cough = corner:Distance(info.startPosition)

							if cough < start_corner_dist then
								start_corner_dist = cough
								start_corner = j - 1
							end

							corners[j] = corner
						end

						local dims = 2 ^ info.power + 1

						for x = 1, dims - 1 do
							for y = 1, dims - 1 do
								add_vertex(mesh, texinfo, texdata, lerp_corners(dims, corners, start_corner, info, x + 1, y + 1))
								add_vertex(mesh, texinfo, texdata, lerp_corners(dims, corners, start_corner, info, x, y))
								add_vertex(mesh, texinfo, texdata, lerp_corners(dims, corners, start_corner, info, x, y + 1))

								add_vertex(mesh, texinfo, texdata, lerp_corners(dims, corners, start_corner, info, x + 1, y))
								add_vertex(mesh, texinfo, texdata, lerp_corners(dims, corners, start_corner, info, x, y))
								add_vertex(mesh, texinfo, texdata, lerp_corners(dims, corners, start_corner, info, x + 1, y + 1))
							end
						end

						mesh.smooth_normals = true
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
		for _, mesh in ipairs(models) do
			mesh:AddSubMesh(mesh:GetVertices(), mesh.material)
			mesh:BuildNormals()
			mesh:BuildTangents()
			tasks.ReportProgress("generating normals", #models)
			tasks.Wait()
		end

		for _, mesh in ipairs(models) do
			if mesh.smooth_normals then
				mesh:SmoothNormals()
			end
			tasks.Report("smoothing displacements", #models)
			tasks.Wait()
		end

		for _, mesh in ipairs(models) do
			mesh:BuildBoundingBox()
			mesh:Upload()
			tasks.ReportProgress("creating meshes", #models)
			tasks.Wait()
		end
	end

	local physics_meshes

	if PHYSICS then
		physics_meshes = {}

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
				for _, data in ipairs(vertices_tbl) do
					vertices[i] = data.pos.x i = i + 1
					vertices[i] = data.pos.y i = i + 1
					vertices[i] = data.pos.z i = i + 1
				end
			else
				for _, data in ipairs(vertices_tbl) do
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
	end

	local render_meshes = {}

	for _, v in ipairs(models) do
		if v.vertex_buffer then
			table.insert(render_meshes, v)
		end
	end

	steam.loaded_bsp[path] = {
		render_meshes = render_meshes,
		entities = header.entities,
		physics_meshes = physics_meshes,
		cubemaps = header.cubemaps,
	}

	tasks.ReportProgress("finished reading " .. path)

	return steam.loaded_bsp[path]
end

function steam.SpawnMapEntities(path, parent)
	local original_path = path
	path = R(path)
	local data = steam.loaded_bsp[path]

	if not data then
		wlog("cannot spawn map entities because %s is not loaded", path or original_path)
		return
	end

	local thread = tasks.CreateTask()
	thread.debug = true

	logn("spawning map entities: ", path)

	function thread:OnStart()

		for _, v in ipairs(parent:GetChildrenList()) do
			if v.spawned_from_bsp then
				v:Remove()
			end
		end

		if CUBEMAPS then
			for k,v in pairs(data.cubemaps) do
				local ent = entities.CreateEntity("visual", parent)
				ent:SetModelPath("models/sphere.obj")
				ent:SetSize(0.25)
				ent:SetRoughnessMultiplier(0)
				ent:SetPosition(v.origin * steam.source2meters)
				print(v.origin * steam.source2meters)
			end
		end

		local count = table.count(data.entities)

		for i, info in pairs(data.entities) do
			if GRAPHICS then
				if info.skyname then
					steam.LoadSkyTexture(info.skyname)
				elseif info.classname and info.classname:find("light_environment") then

					--local p, y = info.pitch, info.angles.y
					--parent.world_params:SetSunAngles(Deg3(p or 0, y+180, 0))

					--info._light.a = 1
					--parent.world_params:SetSunColor(Color(info._light.r, info._light.g, info._light.b))
					--parent.world_params:SetSunIntensity(1)

				elseif info.classname:lower():find("light") and info._light and (not GRAPHICS or render3d.shader_name ~= "flat") then
					parent.light_group = parent.light_group or entities.CreateEntity("group", parent)
					parent.light_group:SetName("lights")

					local ent = entities.CreateEntity("light", parent.light_group)
					ent:SetPosition(info.origin * steam.source2meters)
--					ent:SetHideFromEditor(true)

					ent:SetColor(Color(info._light.r, info._light.g, info._light.b, 1))
					ent:SetSize(math.max(info._light.a, 25))
					ent:SetIntensity(math.clamp(info._light.a/9, 0.5, 3))

					if info._zero_percent_distance then
						ent:SetSize(ent:GetSize() + info._zero_percent_distance*0.02)
					end

					ent.spawned_from_bsp = true
				elseif info.classname == "env_fog_controller" then
					--parent.world_params:SetFogColor(Color(info.fogcolor.r, info.fogcolor.g, info.fogcolor.b, info.fogcolor.a * (info.fogmaxdensity or 1)/4))
					--parent.world_params:SetFogStart(info.fogstart* steam.source2meters)
					--parent.world_params:SetFogEnd(info.fogend * steam.source2meters)
				end
			end

			if info.origin and info.angles and info.model and not info.classname:lower():find("npc") and info.classname ~= "env_sprite" then
				if vfs.IsFile(info.model) then
					parent[info.classname .. "_group"] = parent[info.classname .. "_group"] or entities.CreateEntity("group", parent)
					parent[info.classname .. "_group"]:SetName(info.classname)

					local ent = entities.CreateEntity("visual", parent[info.classname .. "_group"])
					ent:SetModelPath(info.model)
					ent:SetPosition(info.origin * steam.source2meters)
					if info.rendercolor and not info.rendercolor:IsZero() then ent:SetColor(info.rendercolor) end
					if info.model_size_mult then ent:SetSize(info.model_size_mult) end
					ent:SetAngles(info.angles:GetRad())
					--ent:SetHideFromEditor(true)
					ent.spawned_from_bsp = true
				end
			end
			tasks.ReportProgress("spawning entities", count)
			tasks.Wait()
		end
	end

	thread:Start()
end

render3d.AddModelDecoder("bsp", function(path, full_path, mesh_callback)
	for _, mesh in ipairs(steam.LoadMap(full_path).render_meshes) do
		mesh_callback(mesh)
	end
end)

event.AddListener("PreLoad3DModel", "bsp_mount_games", steam.MountGamesFromMapPath)