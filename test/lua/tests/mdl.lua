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

local function load_mdl(path)
	local buffer = vfs.Open(path .. ".mdl")

	local header = buffer:ReadStructure(header)
	header.name = "models/" .. header.name:removepadding():gsub("\\", "/")

	local function parse(name, callback)
		local out = {}
		
		local count = header[name .. "_count"]
		local offset = header[name .. "_offset"]
		
		logf("reading %i %ss (at %i)\n", count, name, offset)
		
		profiler.StartTimer(name) 
				
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
		
		profiler.StopTimer()
	end
	 
	parse("material", function(data, i)
		do -- texture name
			local offset = buffer:ReadInt()
			
			if offset ~= 0 then
				buffer:PushPos(header.material_offset + offset)
					local str = buffer:ReadString()
					if #str > 50 then buffer:PopPos() logf("tried to read location %i but string size is %i bytes!!!!!!!!!\n", header.material_offset + offset, #str) return false end
					data.path1 = "materials/" .. header.name:match("(.+)%.") .. "/" .. str .. ".vmt"
					data.path2 = "materials/" .. header.name:match("(.+/)") .. "/" .. str .. ".vmt"
				buffer:PopPos()
			else
				data.path = ""
			end			
						
			if not vfs.IsFile(data.path1) then
				if not vfs.IsFile(data.path2) then
					logn("could not find ", data.path1)
					logn("could not find ", data.path2)
					return false
				else
					data.path = data.path2
				end
			else
				data.path = data.path1
			end
		end
		
		data.flags = buffer:ReadInt()
		
		buffer:Advance(14 * 4)
		
		local str = assert(vfs.Read(data.path))
		if str then
			data.vmt = steam.VDFToTable(str, true)
		else
			data.vmt = {}
		end
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

	buffer:PushPos(header.keyvalue_offset)
		local str = buffer:ReadString(header.keyvalue_size)
		if str then
			header.keyvalues = steam.VDFToTable(str)
		end
		header.keyvalue_offset = nil
		header.keyvalue_count = nil
	buffer:PopPos()

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

	local buffer = vfs.Open(path .. ".sw.vtx")
	
	local vtx = {}
	vtx.version = buffer:ReadLong()
	vtx.vertexCacheSize = buffer:ReadLong()
	vtx.maxBonesPerStrip = buffer:ReadShort()
	vtx.maxBonesPerTri = buffer:ReadShort()
	vtx.maxBonesPerVertex = buffer:ReadLong()
	vtx.checksum = buffer:ReadLong()
	vtx.lodCount = buffer:ReadLong()
	vtx.materialReplacementListOffset = buffer:ReadLong()
	vtx.bodyPartCount = buffer:ReadLong()
	vtx.bodyPartOffset = buffer:ReadLong()

	vtx.theFirstMeshWithStripGroups = nil
	vtx.theFirstMeshWithStripGroupsInputFileStreamPosition = -1
	vtx.theSecondMeshWithStripGroups = nil
	vtx.theExpectedStartOfSecondStripGroupList = -1
	vtx.theStripGroupUsesExtra8Bytes = false

	if vtx.bodyPartCount > 0 and vtx.bodyPartOffset ~= 0 then
		buffer:PushPos(vtx.bodyPartOffset)
		vtx.theVtxBodyParts = {}
		
		for i = 0, vtx.bodyPartCount - 1 do
			local bodyPartInputFileStreamPosition = buffer:GetPos()
			
			local aBodyPart = {}
			aBodyPart.modelCount = buffer:ReadLong()
			aBodyPart.modelOffset = buffer:ReadLong()
			table.insert(vtx.theVtxBodyParts, aBodyPart)

			if aBodyPart.modelCount > 0 and aBodyPart.modelOffset ~= 0 then
				buffer:PushPos(bodyPartInputFileStreamPosition + aBodyPart.modelOffset)
				aBodyPart.theVtxModels = {}
				
				for j = 0, aBodyPart.modelCount - 1 do
					local modelInputFileStreamPosition = buffer:GetPos()
					
					local aModel = {}
					aModel.lodCount = buffer:ReadLong()
					aModel.lodOffset = buffer:ReadLong()
					table.insert(aBodyPart.theVtxModels, aModel)
					
					if aModel.lodCount > 0 and aModel.lodOffset ~= 0 then
						buffer:PushPos(modelInputFileStreamPosition + aModel.lodOffset)
						aModel.theVtxModelLods = {}
						
						for j = 0, aModel.lodCount - 1 do
							local modelLodInputFileStreamPosition = buffer:GetPos()
							
							local aModelLod = {}
							aModelLod.meshCount = buffer:ReadLong()
							aModelLod.meshOffset = buffer:ReadLong()
							aModelLod.switchPoint = buffer:ReadFloat() 
							table.insert(aModel.theVtxModelLods, aModelLod)
							
							if aModelLod.meshCount > 0 and aModelLod.meshOffset ~= 0 then
								buffer:PushPos(modelLodInputFileStreamPosition + aModelLod.meshOffset)
								aModelLod.theVtxMeshes = {}
								
								for j = 0, aModelLod.meshCount - 1 do
									local meshInputFileStreamPosition = buffer:GetPos()
									
									local aMesh = {}
									aMesh.stripGroupCount = buffer:ReadLong()
									aMesh.stripGroupOffset = buffer:ReadLong()
									aMesh.flags = buffer:ReadByte()
									table.insert(aModelLod.theVtxMeshes, aMesh)
									
									if aMesh.stripGroupCount > 0 and aMesh.stripGroupOffset ~= 0 then
										buffer:PushPos(meshInputFileStreamPosition + aMesh.stripGroupOffset)
										aMesh.theVtxStripGroups = {}
										
										for j = 0, aMesh.stripGroupCount - 1 do
											local stripGroupInputFileStreamPosition = buffer:GetPos()
																						
											local aStripGroup = {}					
											aStripGroup.vertexCount = buffer:ReadLong()
											aStripGroup.vertexOffset = buffer:ReadLong()
											aStripGroup.indexCount = buffer:ReadLong()
											aStripGroup.indexOffset = buffer:ReadLong()
											aStripGroup.stripCount = buffer:ReadLong()
											aStripGroup.stripOffset = buffer:ReadLong()
											aStripGroup.flags = buffer:ReadByte()
											--buffer:ReadLong()
											--buffer:ReadLong()
											table.insert(aMesh.theVtxStripGroups, aStripGroup)
											
											if aStripGroup.vertexCount > 0 and aStripGroup.vertexOffset ~= 0 then
												buffer:PushPos(stripGroupInputFileStreamPosition + aStripGroup.vertexOffset)													
												aStripGroup.theVtxVertexes = {}
												
												for j = 0, aStripGroup.vertexCount - 1 do
													local aVertex = {boneWeightIndex = {}, boneId = {}}
													for i = 0, MAX_NUM_BONES_PER_VERT - 1 do
														aVertex.boneWeightIndex[i] = buffer:ReadByte()
													end
													aVertex.boneCount = buffer:ReadByte()
													aVertex.originalMeshVertexIndex = buffer:ReadShort()
													for i = 0, MAX_NUM_BONES_PER_VERT - 1 do
														aVertex.boneId[i] = buffer:ReadByte()
													end
													table.insert(aStripGroup.theVtxVertexes, aVertex)
												end
												
												buffer:PopPos()
											end
											
											if aStripGroup.indexCount > 0 and aStripGroup.indexOffset ~= 0 then
												buffer:PushPos(stripGroupInputFileStreamPosition + aStripGroup.indexOffset)
												aStripGroup.theVtxIndexes = {}
												
												for j = 0, aStripGroup.indexCount - 1 do
													table.insert(aStripGroup.theVtxIndexes, buffer:ReadShort())
												end
												
												buffer:PopPos()
											end
											
											if aStripGroup.stripCount > 0 and aStripGroup.stripOffset ~= 0 then
												buffer:PushPos(stripGroupInputFileStreamPosition + aStripGroup.stripOffset)
												aStripGroup.theVtxStrips = {}
												
												for j = 0, aStripGroup.stripCount - 1 do
													local aStrip = {}
													
													aStrip.indexCount = buffer:ReadLong()
													aStrip.indexMeshIndex = buffer:ReadLong()
													aStrip.vertexCount = buffer:ReadLong()
													aStrip.vertexMeshIndex = buffer:ReadLong()
													aStrip.boneCount = buffer:ReadShort()
													aStrip.flags = buffer:ReadByte()
													aStrip.boneStateChangeCount = buffer:ReadLong()
													aStrip.boneStateChangeOffset = buffer:ReadLong()
													
													table.insert(aStripGroup.theVtxStrips, aStrip)
												end
												
												buffer:PopPos()
											end
										end
										buffer:PopPos() 
									end
								end
								buffer:PopPos()
							end
						end
						buffer:PopPos()
					end
				end
				buffer:PopPos()
			end
		end
		buffer:PopPos()
	end

	return vtx
end

local function load_vvd(path)
	local MAX_NUM_LODS = 8
	local MAX_NUM_BONES_PER_VERT = 3 
	
	local buffer = vfs.Open(path .. ".vvd")

	local vvd = {lodVertexCount = {}}

	vvd.id = buffer:ReadBytes(4)
	vvd.version = buffer:ReadLong()
	vvd.checksum = buffer:ReadLong()
	vvd.lodCount = buffer:ReadLong()
	for i = 0, MAX_NUM_LODS - 1 do
		vvd.lodVertexCount[i] = buffer:ReadLong()
	end
	vvd.fixupCount = buffer:ReadLong()
	vvd.fixupTableOffset = buffer:ReadLong()
	vvd.vertexDataOffset = buffer:ReadLong()
	vvd.tangentDataOffset = buffer:ReadLong()

	if vvd.lodCount > 0 then
		buffer:SetPos(vvd.vertexDataOffset)

		local vertexCount = vvd.lodVertexCount[0]
		vvd.theVertexes = {}
		for j = 0, vertexCount - 1 do
			local boneWeight = {weight = {}, bone = {}}
			
			for x = 0, MAX_NUM_BONES_PER_VERT - 1 do
				boneWeight.weight[x] = buffer:ReadFloat()
			end
			for x = 0, MAX_NUM_BONES_PER_VERT - 1 do
				boneWeight.bone[x] = buffer:ReadByte()
			end
			boneWeight.boneCount = buffer:ReadByte()
			
			local aStudioVertex = {}

			--aStudioVertex.boneWeight = boneWeight

			aStudioVertex.pos = -buffer:ReadVec3() * 0.0254
			aStudioVertex.normal = -buffer:ReadVec3()
			aStudioVertex.uv = buffer:ReadVec2()
			
			table.insert(vvd.theVertexes, aStudioVertex)
		end
	end
	
	vvd.theFixedVertexesByLod = {}
	
	if vvd.fixupCount > 0 then
		buffer:SetPos(vvd.fixupTableOffset)

		vvd.theFixups = {}
		
		for fixupIndex = 0, vvd.fixupCount - 1 do
			local aFixup = {}

			aFixup.lodIndex = buffer:ReadLong()
			aFixup.vertexIndex = buffer:ReadLong()
			aFixup.vertexCount = buffer:ReadLong()
			
			table.insert(vvd.theFixups, aFixup)
		end
		
		if vvd.lodCount > 0 then
			buffer:SetPos(vvd.vertexDataOffset)
			
			for lodIndex = 0, vvd.lodCount - 1 do
				vvd.theFixedVertexesByLod[lodIndex + 1] = {}
				
				for i, aFixup in ipairs(vvd.theFixups) do
					if aFixup.lodIndex >= lodIndex then
						for j = 0, aFixup.vertexCount - 1 do
							table.insert(vvd.theFixedVertexesByLod[lodIndex + 1], vvd.theVertexes[aFixup.vertexIndex + j + 1])
						end
					end
				end
			end
		end
	end
	
	return vvd
end

steam.MountSourceGame("hl2") 

local path = "models/props_c17/fountain_01"  

local mdl = load_mdl(path)
local vvd = load_vvd(path)
local vtx = load_vtx(path)

local model = {sub_models = {}}

for i, body_part in ipairs(vtx.theVtxBodyParts) do
	for _, vertex_model in ipairs(body_part.theVtxModels) do
		for lod_index, lod_model in ipairs(vertex_model.theVtxModelLods) do
			if lod_model.theVtxMeshes then
				for _, mesh in ipairs(lod_model.theVtxMeshes) do
					local vertices = vvd.theFixedVertexesByLod[lod_index] or vvd.theVertexes
					local indices = {}
					
					for _, strip_group in ipairs(mesh.theVtxStripGroups) do	
						for i, v in ipairs(strip_group.theVtxIndexes) do
							local i = strip_group.theVtxVertexes[v+1].originalMeshVertexIndex
							table.insert(indices, i)
						end
						break -- ?
					end
					
					local sub_model = {mesh = render.CreateMesh(vertices, indices)}
						
					if mdl.material[i] and mdl.material[i].vmt then 
						local shader, info = next(mdl.material[i].vmt)
						
						if info["$basetexture"] then sub_model.diffuse = Texture("materials/" .. info["$basetexture"]:lower() .. ".vtf") end
						if info["$bumpmap"] then sub_model.bump = Texture("materials/" .. info["$bumpmap"]:lower() .. ".vtf") end
					end	
					
					table.insert(model.sub_models, sub_model)
					break
				end
			end
				
			break -- only first lod_model for now
		end
	end
	break
end

logf("loaded %i sub models\n", #model.sub_models)

entities.SafeRemove(MDL_ENT)
local ent = entities.CreateEntity("clientside")
ent:SetModel(model)
--ent:SetPosition(render.GetCamPos())   
MDL_ENT = ent

