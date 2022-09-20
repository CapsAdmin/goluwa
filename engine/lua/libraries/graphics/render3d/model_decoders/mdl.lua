local render3d = ... or _G.render3d
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
	 * the next "render2dprop_offset" value is at position 0x0134 (308)
	 * from the start of the file.
	 */

	// Surface property value (single null-terminated string)
	//int render2dprop_count;
	int render2dprop_offset;

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

local function find_file(path, ...)
	local extensions = {...}
	local ok, err

	for _, ext in ipairs(extensions) do
		ok, err = vfs.Open(path .. ext)

		if ok then return ok end
	end

	for _, ext in ipairs(extensions) do
		local path = vfs.FindMixedCasePath(path .. ext)

		if path then
			ok, err = vfs.Open(path)

			if ok then return ok end
		end
	end

	if not ok then
		for _, v in pairs(vfs.Find(path:match("(.+/)"), true)) do
			if v:match(".+/(.+)%."):lower() == path:match(".+/(.+)"):lower() then
				for _, ext in ipairs(extensions) do
					if v:endswith(ext) then return assert(vfs.Open(v)) end
				end
			end
		end
	end

	return assert(ok, err)
end

local function load_mdl(path)
	local buffer = find_file(path, ".mdl")
	local header = buffer:ReadStructure(header)
	header.name = "models/" .. header.name:removepadding():gsub("\\", "/")

	local function parse(name, callback)
		local out = {}
		local count = header[name .. "_count"]
		local offset = header[name .. "_offset"]

		if _debug then llog("reading %i %ss (at %i)", count, name, offset) end

		if _debug then profiler.StartTimer(name) end

		if count > 0 then
			buffer:PushPosition(offset)

			for i = 1, count do
				local data = {}

				if callback(data, i) ~= false then out[i] = data end

				if _debug then tasks.ReportProgress("reading " .. name, count) end

				tasks.Wait()
			end

			buffer:PopPosition()
		end

		--header[name .. "_count"] = nil
		--header[name .. "_offset"] = nil
		header[name] = out

		if _debug then profiler.StopTimer() end
	end

	local function string_from_offset(offset, offset2)
		if offset2 == 0 then return "" end

		buffer:PushPosition(offset + offset2)
		local str = buffer:ReadString()
		buffer:PopPosition()
		return str
	end

	do
		buffer:PushPosition(header.material_offset)
		header.materials = {}
		local offset = buffer:ReadInt()

		if offset > -1 then
			buffer:PushPosition(header.material_offset + offset)

			for i = 1, header.material_count do
				local mat = vfs.FixPathSlashes(buffer:ReadString())

				if mat ~= "" and not mat:endswith("/") then
					header.materials[i] = mat
				end
			end

			buffer:PopPosition()
		end

		buffer:PopPosition()

		parse("texturedir", function(data, i)
			local offset = buffer:ReadLong()
			buffer:PushPosition(offset)
			data.path = "materials/" .. vfs.FixPathSlashes(buffer:ReadString())
			buffer:PopPosition()
		end)
	end

	--[[

	local bone_names
	local render2d_prop_names

	parse("bone", function(data, i)
		do -- bone name
			local offset = buffer:ReadInt()
			if not bone_names then
				bone_names = {}
				buffer:PushPosition(header.bone_offset + offset)
					for i = 1, header.bone_count do
						bone_names[i] = buffer:ReadString()
					end
				buffer:PopPosition()
			end
			data.name = bone_names[i]
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
			--matrix[-i-12] = val
		end

		data.pose_to_bone = matrix

		data.quat_alignment = buffer:ReadQuat()

		data.flags = buffer:ReadInt()
		data.procedural_rule_type = buffer:ReadInt()
		data.procedural_rule_offset = buffer:ReadInt()
		data.physics_bone_index = buffer:ReadInt()

		do -- bone name
			local offset = buffer:ReadInt()
			if not render2d_prop_names then
				render2d_prop_names = {}
				buffer:PushPosition(header.bone_offset + offset)
					for i = 1, header.bone_count do
						render2d_prop_names[i] = buffer:ReadString()
					end
				buffer:PopPosition()
			end
			data.render2d_prop_name = render2d_prop_names[i]
		end

		data.contents = buffer:ReadInt()

		buffer:Advance(32)
	end)

	parse("mouths", function(data, i)
		data.bone_index = buffer:ReadInt()
		data.forward = buffer:ReadVec3()
		data.flex_desc_index = buffer:ReadInt()
	end)

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
			header.keyvalues = utility.VDFToTable(str)
		end
		header.keyvalue_offset = nil
		header.keyvalue_count = nil
	buffer:PopPosition()

	logn("these remain to be parsed:")

	for k,v in pairs(header) do
		if k:find("_count") then
			if header[k:gsub("_count", "_offset")] then
				local name = k:gsub("_count", "")
				logf("\t%s (count: %s|offset: %s)\n", name, header[name.."_count"], header[name.."_offset"])
			end
		end
	end]] return header
end

local function load_vtx(path)
	local MAX_NUM_BONES_PER_VERT = 3
	local buffer = find_file(path, ".dx90.vtx", ".dx80.vtx", ".sw.vtx")
	local vtx = buffer:ReadStructure([[
		long version;
		long vertex_cache_size;
		short max_bones_per_strip;
		short max_bones_per_tri;
		long max_bones_per_vertex;
		long checksum;
		long lod_count;
		long material_replacement_list_offset;
	]])
	vtx.body_part_count = buffer:ReadLong()
	vtx.body_part_offset = buffer:ReadLong()
	buffer:PushPosition(vtx.body_part_offset)
	vtx.body_parts = {}

	for i = 1, vtx.body_part_count do
		local stream_pos = buffer:GetPosition()
		local body_part = {}
		body_part.model_count = buffer:ReadLong()
		body_part.model_offset = buffer:ReadLong()
		vtx.body_parts[i] = body_part
		buffer:PushPosition(stream_pos + body_part.model_offset)
		body_part.models = {}

		for i = 1, body_part.model_count do
			local stream_pos = buffer:GetPosition()
			local model = {}
			model.lod_count = buffer:ReadLong()
			model.lod_offset = buffer:ReadLong()
			body_part.models[i] = model
			buffer:PushPosition(stream_pos + model.lod_offset)
			model.model_lods = {}

			for i = 1, model.lod_count do
				local stream_pos = buffer:GetPosition()
				local lod_model = {}
				lod_model.mesh_count = buffer:ReadLong()
				lod_model.mesh_offset = buffer:ReadLong()
				lod_model.switchPoint = buffer:Advance(4) --buffer:ReadFloat()
				model.model_lods[i] = lod_model
				buffer:PushPosition(stream_pos + lod_model.mesh_offset)
				lod_model.meshes = {}

				for i = 1, lod_model.mesh_count do
					local stream_pos = buffer:GetPosition()
					local mesh = {}
					mesh.strip_group_count = buffer:ReadLong()
					mesh.strip_group_offset = buffer:ReadLong()
					mesh.flags = buffer:ReadByte()
					lod_model.meshes[i] = mesh
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
						buffer:PushPosition(stream_pos + strip_group.vertices_offset)

						for i = 1, strip_group.vertices_count do
							local vertex = {} --{bone_weight_indices = {}, boneId = {}}
							buffer:Advance(MAX_NUM_BONES_PER_VERT + 1)
							--[[
							for i = 1, MAX_NUM_BONES_PER_VERT do
								vertex.bone_weight_indices[i] = buffer:ReadByte()
							end
							vertex.bone_count = buffer:ReadByte()
							]] vertex.mesh_vertex_index = buffer:ReadShort()
							buffer:Advance(MAX_NUM_BONES_PER_VERT)
							--[[
							for i = 1, MAX_NUM_BONES_PER_VERT do
								vertex.boneId[i] = buffer:ReadByte()
							end]] vertices[i] = vertex
						end

						buffer:PopPosition()
						local indices = {}
						buffer:PushPosition(stream_pos + strip_group.indices_offset)

						for i = 1, strip_group.indices_count do
							indices[i] = buffer:ReadShort() + 1
						end

						buffer:PopPosition()
						local strips = {}
						buffer:PushPosition(stream_pos + strip_group.strip_offset)

						for i = 1, strip_group.strip_count do
							local stream_pos = buffer:GetPosition()
							local strip = {}
							strip.indices_count = buffer:ReadLong()
							strip.index_model_index = buffer:Advance(4) -- buffer:ReadLong()
							strip.vertices_count = buffer:ReadLong()
							buffer:Advance(4 + 2 + 1 + 8)
							--strip.vertex_model_index = buffer:ReadLong()
							--strip.bone_count = buffer:ReadShort()
							--strip.flags = buffer:ReadByte()
							--[[
							strip.bone_state_change_count = buffer:ReadLong()
							strip.bone_state_change_offset = buffer:ReadLong()

							local bone_state_changes = {}
							buffer:PushPosition(stream_pos + strip.bone_state_change_offset)
							for i = 1, strip.bone_state_change_count do
								bone_state_changes[i] = {}
								bone_state_changes[i].hardware_id = buffer:ReadLong()
								bone_state_changes[i].new_bone_id = buffer:ReadLong()
							end
							buffer:PopPosition()
							strip.bone_state_changes = bone_state_changes
]] strip.indices = indices
							strip.vertices = vertices
							strips[i] = strip
						end

						buffer:PopPosition()
						strip_group.strips = strips

						if _debug then
							tasks.ReportProgress(
								"reading body parts",
								vtx.body_part_count * body_part.model_count * model.lod_count * lod_model.mesh_count * mesh.strip_group_count
							)
						end

						tasks.Wait()
					end

					buffer:PopPosition()
				end

				buffer:PopPosition()
			end

			buffer:PopPosition()
		end

		buffer:PopPosition()
	end

	buffer:PopPosition()
	return vtx
end

local function load_vvd(path)
	local MAX_NUM_LODS = 8
	local MAX_NUM_BONES_PER_VERT = 3
	local buffer = find_file(path, ".vvd")
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
	vvd.vertices = {}

	local function read_vertex(i)
		--[[
		local boneWeight = {weight = {}, bone = {}}

		for x = 1, MAX_NUM_BONES_PER_VERT do
			boneWeight.weight[x] = buffer:ReadFloat()
		end
		for x = 1, MAX_NUM_BONES_PER_VERT do
			boneWeight.bone[x] = buffer:ReadByte()
		end
		boneWeight.bone_count = buffer:ReadByte()
		]] buffer:Advance((4 * MAX_NUM_BONES_PER_VERT) + MAX_NUM_BONES_PER_VERT + 1)
		local vertex = {}
		local x, y, z = buffer:ReadFloat(), buffer:ReadFloat(), buffer:ReadFloat()
		vertex.pos = Vec3(y * -steam.source2meters, x * -steam.source2meters, z * -steam.source2meters)
		local x, y, z = buffer:ReadFloat(), buffer:ReadFloat(), buffer:ReadFloat()
		vertex.normal = Vec3(-y, -x, -z)
		vertex.uv = buffer:ReadVec2()
		vvd.vertices[i] = vertex

		if _debug then tasks.ReportProgress("reading vertices", vertices_count) end

		tasks.Wait()
	end

	if vvd.lod_count > 0 and vvd.fixup_count == 0 then
		local vertices_count = vvd.lod_vertices_count[1]
		buffer:SetPosition(vvd.vertices_offset)

		for i = 1, vertices_count do
			read_vertex(i)
		end
	end

	vvd.fixed_vertices_by_lod = {}

	if vvd.fixup_count > 0 and vvd.fixup_offset ~= 0 then
		buffer:SetPosition(vvd.fixup_offset)
		vvd.theFixups = {}

		for i = 1, vvd.fixup_count do
			local fixup = {}
			fixup.lod_index = buffer:ReadLong() + 1
			fixup.vertex_index = buffer:ReadLong() + 1
			fixup.vertices_count = buffer:ReadLong()
			vvd.theFixups[i] = fixup
		end

		if vvd.lod_count > 0 then
			buffer:SetPosition(vvd.vertices_offset)

			for lod_index = 1, vvd.lod_count do
				vvd.fixed_vertices_by_lod[lod_index] = {}
				local i2 = 1

				for _, fixup in ipairs(vvd.theFixups) do
					if fixup.lod_index >= lod_index then
						for i = 1, fixup.vertices_count do
							local vertex_i = fixup.vertex_index + (i - 1)
							buffer:SetPosition(
								vvd.vertices_offset + (
										(
											(
												4 * MAX_NUM_BONES_PER_VERT
											) + MAX_NUM_BONES_PER_VERT + 1
										) + 12 + 12 + 8
									) * (
										vertex_i - 1
									)
							)
							read_vertex(vertex_i)
							vvd.fixed_vertices_by_lod[lod_index][i2] = vvd.vertices[fixup.vertex_index + (i - 1)]
							i2 = i2 + 1
						end
					end
				end

				-- only first lod needed
				break
			end
		end
	end

	if _debug then profiler.StopTimer() end

	return vvd
end

render3d.AddModelDecoder("mdl", function(path, full_path, mesh_callback)
	local models = {}

	if full_path:endswith(".mdl") then full_path = full_path:sub(1, -#".mdl" - 1) end

	--utility.PushTimeWarning()
	local mdl = load_mdl(full_path)
	local vvd = load_vvd(full_path)
	local vtx = load_vtx(full_path)

	--	utility.PopTimeWarning("model read", 0)
	--utility.PushTimeWarning()
	if _debug then tasks.Report("generating mesh") end

	for _, body_part in ipairs(vtx.body_parts) do
		for _, model_ in ipairs(body_part.models) do
			for lod_index, lod_model in ipairs(model_.model_lods) do
				if lod_model.meshes and lod_model.meshes[1] then
					local mesh = gfx.CreatePolygon3D()
					local vertices = vvd.fixed_vertices_by_lod[lod_index] or vvd.vertices
					local copy = {}

					for i, v in ipairs(vertices) do
						copy[i] = {pos = v.pos:Copy(), normal = v.normal:Copy(), uv = v.uv:Copy()}
					end

					mesh:SetVertices(copy)
					local WHAT2 = 0

					for model_i, mesh_data in ipairs(lod_model.meshes) do
						if _debug then
							tasks.ReportProgress("generating mesh", #vtx.body_parts * #model_.model_lods * #lod_model.meshes)
						end

						tasks.Wait()
						local WHAT = 0
						local indices = {}
						local index_i = 1

						for _, strip_group in ipairs(mesh_data.strip_groups) do
							for _, strip in ipairs(strip_group.strips) do
								for _, index in ipairs(strip.indices) do
									WHAT = math.max(WHAT, strip.vertices[index].mesh_vertex_index + 1)
									local v = strip.vertices[index].mesh_vertex_index + WHAT2
									indices[index_i] = v
									index_i = index_i + 1
								end
							end
						end

						WHAT2 = WHAT
						mesh:SetName(full_path)
						local material
						local path = mdl.materials[model_i]

						if path then
							if path:find("/", nil, true) or path:find("\\", nil, true) then
								path = vfs.FindMixedCasePath("materials/" .. path .. ".vmt") or path
							else
								for _, dir in ipairs(mdl.texturedir) do
									local new_path = vfs.FindMixedCasePath(dir.path .. path .. ".vmt")

									if new_path then
										path = new_path

										break
									end
								end
							end

							material = render.CreateMaterial("model")
							material:LoadVMT(path)
						end

						mesh:AddSubMesh(indices, material)
					end

					mesh:BuildBoundingBox()
					mesh:BuildTangents()
					mesh:Upload()
					mesh_callback(mesh)
					table.insert(models, mesh)
				end

				break -- only first lod_model for now
			end
		end
	end

	--utility.PopTimeWarning("model generation", 0)
	return models
end)

if RELOAD then
	render3d.model_cache = {}
	render3d.model_loader_cb = utility.CreateCallbackThing(render3d.model_cache)
	steam.MountSourceGame("hl2")
	steam.MountSourceGame("csgo")
	utility.PushTimeWarning()
	local ent = utility.RemoveOldObject(entities.CreateEntity("visual"), "test")
	local mdl = "models/props_wasteland/exterior_fence001b.mdl"
	local mdl = "models/props_interiors/sinkkitchen01a.mdl"
	local mdl = "models/inventory_items/trophy_majors.mdl"
	ent:SetModelPath(mdl)
	ent:SetPosition(render3d.camera:GetPosition() + render3d.camera:GetAngles():GetForward() * 3)
	utility.PopTimeWarning("mdl", 0)
end