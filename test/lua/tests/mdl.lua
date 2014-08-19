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

vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/")
vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/hl2_misc_dir.vpk")
vfs.Mount(steam.GetGamePath("Half-Life 2") .. "hl2/hl2_textures_dir.vpk")

local function load_mdl(path)
	local buffer = Buffer(vfs.GetFile(path .. ".mdl", "rb"))

	local header = buffer:ReadStructure(header)
	header.name = "models/" .. header.name:removepadding():gsub("\\", "/")


	local function parse(name, callback)
		local out = {}
		
		local count = header[name .. "_count"]
		local offset = header[name .. "_offset"]
		
		if count > 0 then
			buffer:PushPos(offset)
		
			for i = 1, count do 
				local data = {}
				
				if callback(data, i) ~= false then
					table.insert(out, data)
				end
			end
			
			buffer:PopPos()
		end
		
		header[name .. "_count"] = nil
		header[name .. "_offset"] = nil
		
		header[name] = out
	end
	 
	parse("material", function(data, i)
		do -- texture name
			local offset = buffer:ReadInt()

			if offset ~= 0 then
				buffer:PushPos(header.material_offset + offset)
					data.path = "materials/" .. header.name:match("(.+/)") .. buffer:ReadString() .. ".vmt"
				buffer:PopPos()
			else
				data.path = ""
			end			
			
			if not vfs.Exists(data.path) then
				return false
			end
		end
		
		data.flags = buffer:ReadInt()
		
		buffer:Advance(14 * 4)
			
		data.vmt = steam.VDFToTable(vfs.Read(data.path), true)
	end)

	parse("bone", function(data, i)
		do -- bone name
			local offset = buffer:ReadInt()
			
			if offset ~= 0 then
				buffer:PushPos(header.bone_offset + offset)
					data.name = buffer:ReadString()
				buffer:PopPos()
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
			
			if offset ~= 0 then
				buffer:PushPos(header.bone_offset + offset)
					data.surface_prop_name = buffer:ReadString()
				buffer:PopPos()
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
		
		buffer:PushPos(offset + offset2)
		local str = buffer:ReadString()
		buffer:PopPos()
		return str
	end

	parse("localseq", function(data, i)
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

	buffer:PushPos(header.keyvalue_offset)
		header.keyvalues = steam.VDFToTable(buffer:ReadString(header.keyvalue_size))
		header.keyvalue_offset = nil
		header.keyvalue_count = nil
	buffer:PopPos()

	logn("these remain to be parsed:")

	for k,v in pairs(header) do
		if k:find("_count") then
			if header[k:gsub("_count", "_offset")] then
				local name = k:gsub("_count", "")
				logf("\t%s (count: %s|offset: %s)\n", name, header[name.."_count"], header[name.."_offset"])
			end
		end
	end
	
	return header
end

local header = [[
	// file version as defined by OPTIMIZED_MODEL_FILE_VERSION (currently 7)
	int version;
 
	// hardware params that affect how the model is to be optimized.
	int vertCacheSize;
	unsigned short maxBonesPerStrip;
	unsigned short maxBonesPerFace;
	int maxBonesPerVert;
 
	// must match checkSum in the .mdl
	long checkSum;
 
	int numLODs; // garymcthack - this is also specified in ModelHeader_t and should match
 
	// this is an offset to an array of 8 MaterialReplacementListHeader_t's, one of these for each LOD
	int materialReplacementListOffset;
 
	int bodypart_count;
	int bodypart_offset; // offset to an array of BodyPartHeader_t's
	
	/*int model_count;
	int model_offset; 
	
	int lod_model_count;
	int lod_model_offset; 
	
	int mesh_count;
	int mesh_offset; 
	
	int strip_group_count;
	int strip_group_offset; */
]]

local function load_vtx(path)
	local buffer = Buffer(vfs.GetFile(path .. ".sw.vtx", "rb"))
	local header = buffer:ReadStructure(header)
	
	local base = header.bodypart_offset

	table.print(header)
	
	do return end
	
	header.bodies = {}
	
	local function something(base, parent, children_name, callback)
		local child = {}
		child[children_name] = {}
		
		local count = buffer:ReadInt()
		if count > 0 then
			local offset = buffer:ReadInt()
			
			base = base + offset
			
			buffer:PushPos(base)
			for i = 1, count do
				callback(base, child[children_name])
			end			
			buffer:PopPos()
			
			table.insert(parent, child)
		end
	end
	
	something(base, header.bodies, "models", function(base, parent)
		something(base, parent, "lod_models", function(base, parent)
			parent.switch_point = buffer:ReadFloat()
			something(base, parent, "meshes", function(base, parent)			
				parent.flags = buffer:ReadByte()
			end)
		end)
	end)
	
	table.print(header.bodies)
	
	do return end
	
	buffer:PushPos(base)		
	for i = 1, header.bodypart_count do
		
		local body = {}
		body.models = {}
		
		local model_count = buffer:ReadInt()
		local model_offset = buffer:ReadInt()
		
		base = base + model_offset
		
		buffer:PushPos(base)
		for i = 1, model_count do
		
			local model = {}
			model.lod_models = {}
			
			local lod_count = buffer:ReadInt()
			local lod_offset = buffer:ReadInt()
								
			base = base + lod_offset
								
			buffer:PushPos(base)
			for i = 1, lod_count do
				
				local lod_model = {}
				lod_model.meshes = {}
			
				local mesh_count = buffer:ReadInt()
				local mesh_offset = buffer:ReadInt()
				lod_model.switch_point = buffer:ReadFloat()
				
				base = base + mesh_offset
								
				buffer:PushPos(base)
				for i = 1, mesh_count do
					
					local mesh = {}
					mesh.strip_groups = {}
					
					local strip_group_count = buffer:ReadInt()
					local strip_group_offset = buffer:ReadInt()
					
					mesh.flags = buffer:ReadByte()
										
					base = base + strip_group_offset
										
					buffer:PushPos(base)
					for i = 1, strip_group_count do
					
						local strip_group = {}

						do
							local vertexCount = buffer:ReadInt()
							local vertexOffset = buffer:ReadInt()

							strip_group.vertices = {}
							
							buffer:PushPos(base + vertexOffset)
							for i = 1, vertexCount do
								local vertex = {}
								
								vertex.bone_weight_index = {buffer:ReadByte(), buffer:ReadByte(), buffer:ReadByte()}
								vertex.bone_count = buffer:ReadByte()
								vertex.original_mesh_vertex_index = buffer:ReadShort()
								vertex.bone_id = {buffer:ReadByte(), buffer:ReadByte(), buffer:ReadByte()}
								
								strip_group.vertices[i] = vertex
							end
							buffer:PopPos()							
						end
									
						do
							local indexCount = buffer:ReadInt()
							local indexOffset = buffer:ReadInt()

							strip_group.indices = {}
							
							buffer:PushPos(base + indexOffset)
							for i = 1, indexCount do
								strip_group.indices[i] = buffer:ReadShort()
							end
							buffer:PopPos()							
						end
						
						
						do
							local strip_count = buffer:ReadInt()
							local strip_offset = buffer:ReadInt()

							strip_group.strips = {}
							
							buffer:PushPos(base + strip_offset)
							for i = 1, strip_count do
								local strip = {}
								
								strip.indexCount = buffer:ReadInt()
								strip.indexMeshIndex = buffer:ReadInt()
								
								strip.vertexCount = buffer:ReadInt()
								strip.vertexMeshIndex = buffer:ReadInt()
								
								strip.boneCount = buffer:ReadShort()
								
								strip.flags = buffer:ReadByte()
								
								strip.boneStateChangeCount = buffer:ReadInt()
								strip.boneStateChangeOffset = buffer:ReadInt()
								
								strip_group.strips[i] = strip
							end
							buffer:PopPos()							
						end
						
						mesh.strip_groups.flags = buffer:ReadByte()
						
						table.insert(mesh.strip_groups, strip_group)
					end
					buffer:PopPos()
					
					--base = base - strip_group_offset
					
					table.insert(lod_model.meshes, mesh)	
				end
				buffer:PopPos()		

				--base = base - mesh_offset
				
				table.insert(model.lod_models, lod_model)			
			end			
			buffer:PopPos()	
			
			--base = base - lod_offset
			
			table.insert(body.models, model)			
		end			
		buffer:PopPos()
		
		--base = base - model_offset
		
		table.insert(header.bodies, body)
	end		
	buffer:PopPos()
	
	return header
end

local header=[[
	int	id;				// MODEL_VERTEX_FILE_ID
	int version;			// MODEL_VERTEX_FILE_VERSION
	long checksum;			// same as studiohdr_t, ensures sync
	int numLODs;			// num of valid lods
	int numLODVertexes[8];	// num verts for desired root lod
	int numFixups;			// num of vertexFileFixup_t
	int fixupTableStart;		// offset from base to fixup table
	int vertexDataStart;		// offset from base to vertex block
	int tangentDataStart;		// offset from base to tangent block
]]

local function load_vvd(path, mdl)
	local buffer = Buffer(vfs.GetFile(path .. ".vvd", "rb"))
	local header = buffer:ReadStructure(header)
	
	do -- fixups
		header.fixup = {}
		
		buffer:PushPos(header.fixupTableStart)
		for i = 1, header.numFixups do
			table.insert(header.fixup, buffer:ReadStructure[[
				int	lod;			// used to skip culled root lod
				int	sourceVertexID;		// absolute index from start of vertex/tangent blocks
				int	numVertexes;
			]])
		end
		buffer:PopPos()
	end
		
	local material = mdl.material[1].vmt.VertexLitGeneric
	local model = {sub_models = {{mesh = {}}}}
		
	buffer:PushPos(header.vertexDataStart)
	--for i = 1, header.numLODs do
		for n = 1, header.numLODVertexes[1] do
			local boneWeight = buffer:ReadStructure[[
				float weight[3];
				char bone[3]; 
				byte numbones;
			]]
			
			local vertex = buffer:ReadStructure[[
				vec3 m_vecPosition;
				vec3 m_vecNormal;
				vec2 m_vecTexCoord;
			]]
			
			table.insert(model.sub_models[1].mesh, {
				pos = -vertex.m_vecPosition, 
				uv = vertex.m_vecTexCoord, 
				normal = vertex.m_vecNormal
			})
		end
	--end
	buffer:PopPos()
	
	for i, model in ipairs(model.sub_models) do
		--utilities.GenerateNormals(data.mesh_data)
		model.mesh = render.CreateMesh(model.mesh)
		local path = "materials/" .. material["$basetexture"]:lower() .. ".vtf"
		model.diffuse = Texture(path)
	end
	
	local world = utilities.RemoveOldObject(entities.CreateEntity("clientside"))
	world:SetModel(model)
end

local mdl = load_mdl("models/bicycle01a")
--table.print(mdl)

local vtx = load_vtx("models/bicycle01a")

local vvd = load_vvd("models/bicycle01a", mdl, vtx)
table.print(vvd)

--table.print(vtx)