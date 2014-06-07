local ffi = require("ffi")
local header = require("lj-assimp.header") 
local enums = require("lj-assimp.enums")
 
ffi.cdef(header)

local lib = ffi.load("assimp")

local assimp = {
	lib = lib,
	e = enums,
}

for line in header:gmatch("(.-)\n") do
	if not line:find("enum") and not line:find("struct") and not line:find("typedef") then
		local func = line:match("(ai%u[%a_]-)%(.-%)") 
		
		if func then 
			assimp[func:sub(3)] = lib[func]
		end
		
	end
end

local function fix_path(path)
	return (path:gsub("\\", "/"):gsub("(/+)", "/"))
end

function assimp.ImportFileEx(path, flags, flip_normals, uv_mult)
	local scene = assimp.ImportFile(path, flags)
		
	if not scene then
		return nil, ffi.string(assimp.GetErrorString())
	end
	
	local dir = path:match("(.+)/")

	local out = {}
	
	for i = 1, scene.mNumMeshes do
		local mesh = scene.mMeshes[i-1]
		
		local sub_model = {mesh_data = {}}
		
		local minx, miny, minz = 0,0,0
		local maxx, maxy, maxz = 0,0,0	
		
		for i = 0, scene.mMeshes[i-1].mNumVertices-1 do
			local data = {}
			
			if mesh.mVertices ~= nil then
				local val = mesh.mVertices[i]
				data.pos = {val.x, val.y, val.z}
				
				if val.x < minx then minx = val.x end
				if val.y < miny then miny = val.y end
				if val.z < minz then minz = val.z end
				
				if val.x > maxx then maxx = val.x end
				if val.y > maxy then maxy = val.y end
				if val.z > maxz then maxz = val.z end
			end

			if mesh.mNormals ~= nil then
				local val = mesh.mNormals[i]
				if flip_normals then
					data.normal = {-val.x, -val.y, -val.z}
				else
					data.normal = {val.x, val.y, val.z}
				end
			end

			if mesh.mTangents ~= nil then
				local val = mesh.mTangents[i]
				data.tangent = {val.x, val.y, val.z}
			end	

			if mesh.mBitangents ~= nil then
				local val = mesh.mBitangents[i]
				data.bitangent = {val.x, val.y, val.z}
			end	
						
			if mesh.mTextureCoords ~= nil then
				local val = mesh.mTextureCoords[0] and mesh.mTextureCoords[0][i]
				data.uv = {val.x, val.y}
				if uv_mult then
					data.uv[1] = data.uv[1] * uv_mult
					data.uv[2] = data.uv[2] * uv_mult
				end
			end
			
			sub_model.mesh_data[#sub_model.mesh_data+1] = data
		end
		
		sub_model.bbox = {min = {minx, miny, minz}, max = {maxx, maxy, maxz}}
				
		sub_model.name = ffi.string(mesh.mName.data, mesh.mName.length):trim()
		
		if mesh.mMaterialIndex > 0 then
			local mat = scene.mMaterials[mesh.mMaterialIndex]
			sub_model.material = {}
			for i = 0, mat.mNumProperties-1 do
				local property = mat.mProperties[i]
				local key = ffi.string(property.mKey.data, property.mKey.length)
				local val = ffi.string(property.mData, property.mDataLength)
				
				key = key:sub(2)
				val = val:sub(4) 
					
				val = val:gsub("(.)", function(char) if char:byte() == 0 then return "" end end) 
				
				if key == "mat.name" then
					sub_model.material.name = val
				end
				
				if key == "tex.file" and val then
					if val:sub(1,1) == "." then
						sub_model.material.path = fix_path(dir .. val:sub(2))
					else
						sub_model.material.path = fix_path(val)
					end
				end
			end
		end
				
		out[i] = sub_model
	end	
	
	assimp.ReleaseImport(scene)
	
	return out
end

return assimp