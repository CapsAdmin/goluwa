local steam = ... or _G.steam

local _debug = false

local header = [[
	string id[4]; // Model format ID, such as "IDST" (0x49 0x44 0x53 0x54)
	int version; // Format version number, such as 48 (0x30,0x00,0x00,0x00)
	int checksum;
	char name[64]; 	// The internal name of the model, padding with null bytes.
					// Typically "my_model.mdl" will have an internal name of "my_model"

	int file_size; // Data size of MDL file in bytes.

	// A vector is 12 bytes, three 4-byte float-values in a row.

	vec3 eye_position; // Position of player viewpoint relative to model origin
	vec3 illumination_position;	// ?? Presumably the point used for lighting when per-vertex lighting is not enabled.
	vec3 hull_min; // Corner of model hull box with the least X/Y/Z values
	vec3 hull_max; // Opposite corner of model hull box
	vec3 view_bbmin;
	vec3 view_bbmax;

	int flags; 	// Binary flags in little-endian order.
				// ex (00000001,00000000,00000000,11000000) means flags for position 0, 30, and 31 are set.
				// Set model flags section for more information

	/*
	 * After this point, the header contains many references to offsets
	 * within the MDL file and the number of items at those offsets.
	 *
	 * Offsets are from the very beginning of the file.
	 *
	 * Note that indexes/counts are not always paired and ordered consistently.
	 */

	 // mstudiobone_t
	int bone_count;	// Number of data sections (of type mstudiobone_t)
	int bone_offset; // Offset of first data section

	// mstudiobonecontroller_t
	int bonecontroller_count;
	int bonecontroller_offset;

	// mstudiohitboxset_t
	int hitbox_count;
	int hitbox_offset;

	// mstudioanimdesc_t
	int localanim_count;
	int localanim_offset;

	// mstudioseqdesc_t
	int localseq_count;
	int localseq_offset;

	int activitylistversion; // initialization flag - have the sequences been indexed?
	int eventsindexed;	// ??

	// VMT material filenames
	// mstudiotexture_t
	int material_count;
	int material_offset;

	// This offset points to a series of ints.
	// Each int value, in turn, is an offset relative to the start of this header/the-file,
	// At which there is a null-terminated string.
	int texturedir_count;
	int texturedir_offset;

	// Each skin-family assigns a texture-id to a skin location
	int skinreference_count;
	int skinrfamily_count;
	int skinreference_offset;

	// mstudiobodyparts_t
	int bodypart_count;
	int bodypart_offset;

	// Local attachment points
	// mstudioattachment_t
	int attachment_count;
	int attachment_offset;

	// Node values appear to be single bytes, while their names are null-terminated strings.
	int localnode_count;
	int localnode_offset;
	int localnode_name_offset;

	// mstudioflexdesc_t
	int flexdesc_count;
	int flexdesc_offset;

	// mstudioflexcontroller_t
	int flexcontroller_count;
	int flexcontroller_offset;

	// mstudioflexrule_t
	int flexrules_count;
	int flexrules_offset;

	// IK probably referse to inverse kinematics
	// mstudioikchain_t
	int ikchain_count;
	int ikchain_offset;

	// Information about any "mouth" on the model for speech animation
	// More than one sounds pretty creepy.
	// mstudiomouth_t
	int mouths_count;
	int mouths_offset;

	// mstudioposeparamdesc_t
	int localposeparam_count;
	int localposeparam_offset;

	/*
	 * For anyone trying to follow along, as of this writing,
	 * the next "surfaceprop_offset" value is at position 0x0134 (308)
	 * from the start of the file.
	 */

	// Surface property value (single null-terminated string)
	//int surfaceprop_count;
	int surfaceprop_offset;

	// Unusual: In this one index comes first, then count.
	// Key-value data is a series of strings. If you can't find
	// what you're interested in, check the associated PHY file as well.
	int keyvalue_offset;
	int keyvalue_size;

	// More inverse-kinematics
	// mstudioiklock_t
	int iklock_count;
	int iklock_offset;


	float mass; 		// Mass of object (4-bytes)
	int contents;	// ??

	// Other models can be referenced for re-used sequences and animations
	// (See also: The $includemodel QC option.)

	// mstudiomodelgroup_t
	int includemodel_count;
	int includemodel_offset;

	int virtualModel;	// Placeholder for mutable-void*

	// mstudioanimblock_t
	int animblocks_name_offset;
	int animblocks_count;
	int animblocks_offset;

	int animblockModel; // Placeholder for mutable-void*

	// Points to a series of bytes?
	int bonetablename_offset;

	int vertex_base;	// Placeholder for void*
	int offset_base;	// Placeholder for void*

	// Used with $constantdirectionallight from the QC
	// Model should have flag #13 set if enabled
	byte directionaldotproduct;

	byte rootLod;	// Preferred rather than clamped

	// 0 means any allowed, N means Lod 0 -> (N-1)
	byte numAllowedRootLods;

	byte unused; // ??
	int unused; // ??

	// mstudioflexcontrollerui_t
	int flexcontrollerui_count;
	int flexcontrollerui_offset;

	/**
	 * Offset for additional header information.
	 * May be zero if not present, or also 408 if it immediately
	 * follows this studiohdr_t
	 */
	// studiohdr2_t
	int studiohdr2index;

	int unused; // ??

	int source_bone_transform_count;
	int source_bone_transform_offset;

	int illumination_position_attachment_index;
	int max_eye_deflection;
	int linear_bone_offset;
]]

local function load_mdl(path, thread)
	local buffer = assert(vfs.Open(path .. ".mdl"))

	local header = buffer:ReadStructure(header)
	header.name = "models/" .. header.name:removepadding():gsub("\\", "/")

	local function parse(name, callback)
		local out = {}

		local count = header[name .. "_count"]
		local offset = header[name .. "_offset"]

		if thread then thread:Report("reading " .. name) end
		
		if _debug then logf("reading %i %ss (at %i)\n", count, name, offset) end

		if _debug then profiler.StartTimer(name) end

		if count > 0 then
			buffer:PushPosition(offset)

			for i = 1, count do
				local data = {}

				if callback(data, i) ~= false then
					out[i] = data
				end
			end

			buffer:PopPosition()
		end

		header[name .. "_count"] = nil
		header[name .. "_offset"] = nil

		header[name] = out
		
		if _debug then profiler.StopTimer() end
	end

	parse("material", function(data, i)
		do -- texture name
			local offset = buffer:ReadInt()

			if offset > 0 then
				buffer:PushPosition(header.material_offset + offset)
					local str = buffer:ReadString()
					if #str > 500 then buffer:PopPosition() logf("%s: tried to read location %i but string size is %i bytes!!!!!!!!!\n", path, header.material_offset + offset, #str) return false end
					data.path = str
				buffer:PopPosition()
			end
		end

		data.flags = buffer:ReadInt()

		buffer:Advance(14 * 4)
	end)
	
	parse("bone", function(data, i)
		do -- bone name
			local offset = buffer:ReadInt()

			if offset > 0 then
				buffer:PushPosition(header.bone_offset + offset)
					data.name = buffer:ReadString()
				buffer:PopPosition()
			else
				data.name = ""
			end
		end

		data.parent_bone_index = buffer:ReadInt()

		do
			data.controller_index = {}

			for i = 1, 6 do
				data.controller_index[i] = buffer:ReadInt()
			end
		end

		data.position = buffer:ReadVec3()

		data.quat = buffer:ReadQuat()

		data.rotation = buffer:ReadVec3()
		data.position_scale = buffer:ReadVec3()
		data.rotation_scale = buffer:ReadVec3()

		local matrix = Matrix44()
		for i = 1, 12 do
			local val = buffer:ReadFloat()
			--matrix.m[-i-12] = val
		end

		data.pose_to_bone = matrix

		data.quat_alignment = buffer:ReadQuat()

		data.flags = buffer:ReadInt()
		data.procedural_rule_type = buffer:ReadInt()
		data.procedural_rule_offset = buffer:ReadInt()
		data.physics_bone_index = buffer:ReadInt()

		do -- bone name
			local offset = buffer:ReadInt()

			if offset > 0 then
				buffer:PushPosition(header.bone_offset + offset)
					data.surface_prop_name = buffer:ReadString()
				buffer:PopPosition()
			else
				data.surface_prop_name = ""
			end
		end

		data.contents = buffer:ReadInt()

		buffer:Advance(32)
	end)

	parse("mouths", function(data, i)
		data.bone_index = buffer:ReadInt()
		data.forward = buffer:ReadVec3()
		data.flex_desc_index = buffer:ReadInt()
	end)

	local function string_from_offset(offset, offset2)
		if offset2 == 0 then return "" end

		buffer:PushPosition(offset + offset2)
		local str = buffer:ReadString()
		buffer:PopPosition()
		return str
	end

	parse("localseq", function(data, i)
		do return end
		data.base_header_offset = buffer:ReadInt()
		data.name = string_from_offset(header.localanim_offset, buffer:ReadInt())
		data.activity_name = string_from_offset(header.localanim_offset, buffer:ReadInt())
		data.flags = buffer:ReadInt()
		data.activity = buffer:ReadInt()
		data.activity_weight = buffer:ReadInt()
		data.event_count = buffer:ReadInt()
		data.event_offset = buffer:ReadInt()

		data.bb_min = buffer:ReadVec3()
		data.bb_max = buffer:ReadVec3()

		data.blend_count = buffer:ReadInt()
		data.anim_index_offset = buffer:ReadInt()

		data.group_size = {buffer:ReadInt(), buffer:ReadInt()}

		data.param_index = {buffer:ReadInt(), buffer:ReadInt()}
		data.param_start = {buffer:ReadFloat(), buffer:ReadFloat()}
		data.param_end = {buffer:ReadFloat(), buffer:ReadFloat()}
		data.param_parent = buffer:ReadInt()

		data.fade_in_time = buffer:ReadFloat()
		data.fade_out_time = buffer:ReadFloat()

		data.localEntryNodeIndex = buffer:ReadInt()
		data.localExitNodeIndex = buffer:ReadInt()
		data.nodeFlags = buffer:ReadInt()

		data.entryPhase = buffer:ReadFloat()
		data.exitPhase = buffer:ReadFloat()
		data.lastFrame = buffer:ReadFloat()

		data.nextSeq = buffer:ReadInt()
		data.pose = buffer:ReadInt()

		data.ikRuleCount = buffer:ReadInt()
		data.autoLayerCount = buffer:ReadInt()
		data.autoLayerOffset = buffer:ReadInt()
		data.weightOffset = buffer:ReadInt()
		data.poseKeyOffset = buffer:ReadInt()

		data.ikLockCount = buffer:ReadInt()
		data.ikLockOffset = buffer:ReadInt()
		data.keyValueOffset = buffer:ReadInt()
		data.keyValueSize = buffer:ReadInt()
		data.cyclePoseIndex = buffer:ReadInt()
	end)

	buffer:PushPosition(header.keyvalue_offset)
		local str = buffer:ReadString(header.keyvalue_size)
		if str then
			header.keyvalues = steam.VDFToTable(str)
		end
		header.keyvalue_offset = nil
		header.keyvalue_count = nil
	buffer:PopPosition()

	--[[
	logn("these remain to be parsed:")

	for k,v in pairs(header) do
		if k:find("_count") then
			if header[k:gsub("_count", "_offset")] then
				local name = k:gsub("_count", "")
				logf("\t%s (count: %s|offset: %s)\n", name, header[name.."_count"], header[name.."_offset"])
			end
		end
	end]]

	return header
end

local function load_vtx(path)
	local MAX_NUM_BONES_PER_VERT = 3

	local buffer = vfs.Open(path .. ".dx90.vtx") or vfs.Open(path .. ".dx80.vtx") or vfs.Open(path .. ".sw.vtx") 

	local vtx = {}

	vtx.version = buffer:ReadLong()
	vtx.vertexCacheSize = buffer:ReadLong()
	vtx.maxBonesPerStrip = buffer:ReadShort()
	vtx.maxBonesPerTri = buffer:ReadShort()
	vtx.maxBonesPerVertex = buffer:ReadLong()
	vtx.checksum = buffer:ReadLong()
	vtx.lod_count = buffer:ReadLong()
	vtx.materialReplacementListOffset = buffer:ReadLong()

	vtx.body_part_count = buffer:ReadLong()
	vtx.body_part_offset = buffer:ReadLong()

	if vtx.body_part_count > 0 and vtx.body_part_offset ~= 0 then
		buffer:PushPosition(vtx.body_part_offset)
		vtx.body_parts = {}

		for i = 1, vtx.body_part_count do
			local stream_pos = buffer:GetPosition()

			local body_part = {}
			body_part.model_count = buffer:ReadLong()
			body_part.model_offset = buffer:ReadLong()
			vtx.body_parts[i] = body_part

			if body_part.model_count > 0 and body_part.model_offset ~= 0 then
				buffer:PushPosition(stream_pos + body_part.model_offset)
				body_part.models = {}

				for i = 1, body_part.model_count do
					local stream_pos = buffer:GetPosition()

					local model = {}
					model.lod_count = buffer:ReadLong()
					model.lod_offset = buffer:ReadLong()
					body_part.models[i] = model

					if model.lod_count > 0 and model.lod_offset ~= 0 then
						buffer:PushPosition(stream_pos + model.lod_offset)
						model.model_lods = {}

						for i = 1, model.lod_count do
							local stream_pos = buffer:GetPosition()

							local lod_model = {}
							lod_model.mesh_count = buffer:ReadLong()
							lod_model.mesh_offset = buffer:ReadLong()
							lod_model.switchPoint = buffer:ReadFloat()
							model.model_lods[i] = lod_model

							if lod_model.mesh_count > 0 and lod_model.mesh_offset ~= 0 then
								buffer:PushPosition(stream_pos + lod_model.mesh_offset)
								lod_model.meshes = {}

								for i = 1, lod_model.mesh_count do
									local stream_pos = buffer:GetPosition()

									local mesh = {}
									mesh.strip_group_count = buffer:ReadLong()
									mesh.strip_group_offset = buffer:ReadLong()
									mesh.flags = buffer:ReadByte()
									lod_model.meshes[i] = mesh

									if mesh.strip_group_count > 0 and mesh.strip_group_offset ~= 0 then
										buffer:PushPosition(stream_pos + mesh.strip_group_offset)   
										mesh.strip_groups = {}
										
										for i = 1, mesh.strip_group_count do
											local stream_pos = buffer:GetPosition()
											
											local strip_group = {}
											strip_group.vertices_count = buffer:ReadLong()
											strip_group.vertices_offset = buffer:ReadLong()
											strip_group.indices_count = buffer:ReadLong()
											strip_group.indices_offset = buffer:ReadLong()
											strip_group.strip_count = buffer:ReadLong()
											strip_group.strip_offset = buffer:ReadLong()
											strip_group.flags = buffer:ReadByte()
											mesh.strip_groups[i] = strip_group
											
											local vertices = {}
											if strip_group.vertices_count > 0 and strip_group.vertices_offset ~= 0 then
												buffer:PushPosition(stream_pos + strip_group.vertices_offset)

												for i = 1, strip_group.vertices_count do
													local vertex = {bone_weight_indices = {}, boneId = {}}
													for i = 1, MAX_NUM_BONES_PER_VERT do
														vertex.bone_weight_indices[i] = buffer:ReadByte()
													end
													vertex.bone_count = buffer:ReadByte()
													vertex.mesh_vertex_index = buffer:ReadShort()
													for i = 1, MAX_NUM_BONES_PER_VERT do
														vertex.boneId[i] = buffer:ReadByte()
													end
													vertices[i] = vertex
												end

												buffer:PopPosition()
											end
											
											local indices = {}
											if strip_group.indices_count > 0 and strip_group.indices_offset ~= 0 then
												buffer:PushPosition(stream_pos + strip_group.indices_offset)

												for i = 1, strip_group.indices_count do
													indices[i] = buffer:ReadShort()
												end

												buffer:PopPosition()
											end
																						
											local strips = {}											
											if strip_group.strip_count > 0 and strip_group.strip_offset ~= 0 then
												buffer:PushPosition(stream_pos + strip_group.strip_offset)
												
												for i = 1, strip_group.strip_count do
													local strip = {}

													strip.indices_count = buffer:ReadLong()
													strip.index_model_index = buffer:ReadLong()
													strip.vertices_count = buffer:ReadLong()
													strip.vertex_model_index = buffer:ReadLong()
													strip.bone_count = buffer:ReadShort()
													strip.flags = buffer:ReadByte()
													strip.bone_state_change_count = buffer:ReadLong()
													strip.bone_state_change_offset = buffer:ReadLong()

													strip.indices = indices 
													strip.vertices = vertices

													strips[i] = strip
												end
																								
												buffer:PopPosition()
											end						
																						
											strip_group.strips = strips
										end
										buffer:PopPosition()
									end
								end
								buffer:PopPosition()
							end
						end
						buffer:PopPosition()
					end
				end
				buffer:PopPosition()
			end
		end
		buffer:PopPosition()
	end

	return vtx
end

local function load_vvd(path)
	local MAX_NUM_LODS = 8
	local MAX_NUM_BONES_PER_VERT = 3

	local buffer = vfs.Open(path .. ".vvd")

	local vvd = {lod_vertices_count = {}}

	vvd.id = buffer:ReadBytes(4)
	vvd.version = buffer:ReadLong()
	vvd.checksum = buffer:ReadLong()
	vvd.lod_count = buffer:ReadLong()
	for i = 1, MAX_NUM_LODS do
		vvd.lod_vertices_count[i] = buffer:ReadLong()
	end
	vvd.fixup_count = buffer:ReadLong()
	vvd.fixup_offset = buffer:ReadLong()
	vvd.vertices_offset = buffer:ReadLong()
	vvd.tangentDataOffset = buffer:ReadLong()

	if vvd.lod_count > 0 then
		buffer:SetPosition(vvd.vertices_offset)

		local vertices_count = vvd.lod_vertices_count[1]
		vvd.vertices = {}
		for i = 1, vertices_count do
			local boneWeight = {weight = {}, bone = {}}

			for x = 0, MAX_NUM_BONES_PER_VERT - 1 do
				boneWeight.weight[x] = buffer:ReadFloat()
			end
			for x = 0, MAX_NUM_BONES_PER_VERT - 1 do
				boneWeight.bone[x] = buffer:ReadByte()
			end
			boneWeight.bone_count = buffer:ReadByte()

			local vertex = {}

			--vertex.boneWeight = boneWeight

			vertex.pos = -buffer:ReadVec3() * 0.0254
			vertex.normal = -buffer:ReadVec3()
			vertex.uv = buffer:ReadVec2()

			vvd.vertices[i] = vertex
		end
	end

	vvd.fixed_vertices_by_lod = {}
	
	if _debug then profiler.StartTimer("processed %i fixups", vvd.fixup_count) end
	if vvd.fixup_count > 0 and vvd.fixup_offset ~= 0 then
		buffer:SetPosition(vvd.fixup_offset)

		vvd.theFixups = {}

		for i = 1, vvd.fixup_count do
			local fixup = {}

			fixup.lod_index = buffer:ReadLong()
			fixup.vertex_index = buffer:ReadLong()
			fixup.vertices_count = buffer:ReadLong()

			vvd.theFixups[i] = fixup
		end

		if vvd.lod_count > 0 then
			buffer:SetPosition(vvd.vertices_offset)

			for lod_index = 1, vvd.lod_count do
				vvd.fixed_vertices_by_lod[lod_index] = {}

				for i, fixup in ipairs(vvd.theFixups) do
					if fixup.lod_index >= lod_index-1 then
						for i = 1, fixup.vertices_count do
							vvd.fixed_vertices_by_lod[lod_index][i] = vvd.vertices[fixup.vertex_index + i]
						end
					end
				end
			end
		end
	end
	if _debug then profiler.StopTimer() end

	return vvd
end

local scale = 0.0254

function steam.LoadModel(path, callback, thread)

	if path:endswith(".mdl") then
		path = path:sub(1,-#".mdl"-1)
	end

	local mdl = load_mdl(path, thread)
	local vvd = load_vvd(path, thread)
	local vtx = load_vtx(path, thread)
	
	local models = {}

	for i, body_part in ipairs(vtx.body_parts) do
		for _, model_ in ipairs(body_part.models) do
			for lod_index, lod_model in ipairs(model_.model_lods) do
				if lod_model.meshes then
					for _, mesh in ipairs(lod_model.meshes) do
						for _, strip_group in ipairs(mesh.strip_groups) do
							for _, strip in ipairs(strip_group.strips) do
								local vertices = vvd.fixed_vertices_by_lod[lod_index] or vvd.vertices
								local indices = {}

								for i, v in ipairs(strip.indices) do
									indices[i] = strip.vertices[v+1].mesh_vertex_index 
								end

								local sub_model = {}
								sub_model.vertices = vertices
								sub_model.indices = indices								
								sub_model.bbox = {min = mdl.hull_min*scale, max = mdl.hull_max*scale}

								if mdl.material[i] and mdl.material[i].path then
									local vmt = steam.LoadMaterial(mdl.material[i].path, path)
									if vmt.error then
										logn(vmt.error) 
									else
										sub_model.material = {
											paths_solved = true,
											diffuse = vmt.basetexture,
											bump = vmt.bumpmap,
											specular = vmt.envmapmask,
										}
									end
								end
								
								if callback then
									callback(sub_model)
								else
									table.insert(models, sub_model)
								end
								if thread then 
									thread:Report("creating submodels")
									thread:Sleep() 
								end
							end
						end
					end
				end

				break -- only first lod_model for now
			end
		end
		break -- only first body part
	end
	
	return model
end

--for i = 1, #model.sub_models do model.sub_models[i] = nil end
--local huh = model.sub_models[4]
--table.clear(model.sub_models)
--model.sub_models[1] = huh

local path = "models/airboat"
local path = "models/alyx"
local path = "models/props_canal/canal_bridge02"
local path = "models/cranes/crane_frame"
local path = "models/props_borealis/door_wheel001a"
local path = "models/props_citizen_tech/steamengine001a"
local path = "models/props_combine/cell_array_01_extended" -- broken ish
local path = "models/antlion" -- broken
local path = "models/airboat"
local path = "models/buggy" -- broken
local path = "models/zombie/poison" -- broken
local path = "models/pot" 
local path = "models/majoras_mask/clocktown/pot"

if RELOAD then 
	if true then
		local bsp_file = assert(vfs.Open("G:/SteamLibrary/SteamApps/common/Team Fortress 2/tf/download/maps/trade_clocktown_b2a.bsp"))

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
			end		
		end
		
		header.map_revision = bsp_file:ReadLong()
		do 
			local lump = header.lumps[41]
			local length = lump.filelen

			bsp_file:SetPosition(lump.fileofs)
			local pak = bsp_file:ReadBytes(length) 
			
			local name = "data/temp_bsp.zip"
			
			vfs.Write(name, pak)
			
			vfs.Mount(R(name))			
		end
	end

	steam.MountSourceGame("half-life 2")
	
	entities.SafeRemove(MDL_ENT)
	local ent = entities.CreateEntity("clientside")
	ent:SetModelPath(path)
	MDL_ENT = ent
end 