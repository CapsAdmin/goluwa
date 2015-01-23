local ffi = require("ffi")
local header = require("lj-assimp.header") 
local enums = require("lj-assimp.enums")
 
ffi.cdef(header)

local lib = assert(ffi.load("assimp"))

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

function assimp.ImportFileEx(path, flags, callback, custom_io)		
	local scene

	if custom_io then
		local file_io_data = ffi.new("aiFileIO", {
			OpenProc = function(self, path, mode)
				path = ffi.string(path)
				path = vfs.FixPath(path)
				path = path:gsub("/./", "/")
				
				local file, err = vfs.Open(path, "read")
				--print("file open", file, err, path)
				
				if not file then return nil end
				
				local proxy_data = ffi.new("aiFile", {
					ReadProc = function(proxy, buffer_out, size, count)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						local length = size * count
						--print("read", file, buffer_out, size)
												
						local str = file:ReadBytes(tonumber(length))
						
						local temp = ffi.cast("char *", str)
						ffi.copy(buffer_out, temp, #str)
						
						--print(#str, length, ffi.string(buffer_out, #str) == str)
						
						return #str
					end,
					WriteProc = function(proxy, buffer_in, buffer_length, length)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("write", file, buffer_in, buffer_length, length)
						
						file:WriteBytes(ffi.string(buffer_in, buffer_length))
					
						return buffer_length
					end,
					TellProc = function(proxy)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("tell", file)
						
						return file:GetPosition()
					end,
					FileSizeProc = function(proxy)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("file size", file)
						
						return file:GetSize()
					end,
					SeekProc = function(proxy, pos, current_pos)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("seek", file)
						
						file:SetPosition(pos)
						return 0 -- 0 = success, -1 = failure, -3 = out of memory
					end,
					FlushProc = function(proxy)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("flush", file)
						
					end,
				})
				--ffi.gc(proxy_data, print)
				local proxy = ffi.new("aiFile[1]", proxy_data)
				
				vfs.proxies = vfs.proxies or {}
				vfs.proxies[tostring(proxy):match(".+: (.+)")] = file
								
				return ffi.cast("aiFile_*", proxy)
			end,
			CloseProc = function(self, proxy)
				local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
				--print("file close", file)

				file:Close()
			end,
		})
		--ffi.gc(file_io_data, print)
		local file_io = ffi.new("aiFileIO[1]", file_io_data)
		
		assimp.file_ios = assimp.file_ios or {}
		assimp.file_ios[path] = file_io
			
		scene = lib.aiImportFileEx(path, flags, file_io)
	else
		scene = assimp.ImportFile(path, flags)
	end
		
	if not scene then
		return nil, ffi.string(assimp.GetErrorString())
	end
	
	local dir = path:match("(.+)/")

	local out = {}
		
	for i = 0, scene.mNumMeshes - 1 do
		local mesh = scene.mMeshes[i]
		
		local sub_model = {vertices = {}, indices = {}}
				
		for i = 0, mesh.mNumVertices - 1 do
			local data = {}
		
			local val = mesh.mVertices[i]
			data.pos = Vec3(val.x, val.y, val.z)

			if mesh.mNormals ~= nil then
				local val = mesh.mNormals[i]
				data.normal = Vec3(val.x, val.y, val.z)
			end

			if mesh.mTangents ~= nil then
				local val = mesh.mTangents[i]
				data.tangent = Vec3(val.x, val.y, val.z)
			end	

			if mesh.mBitangents ~= nil then
				local val = mesh.mBitangents[i]
				data.bitangent = Vec3(val.x, val.y, val.z)
			end	
						
			if mesh.mTextureCoords ~= nil and mesh.mTextureCoords[0] ~= nil then
				local val = mesh.mTextureCoords[0][i]
				data.uv = Vec3(val.x, val.y)
			end
			
			table.insert(sub_model.vertices, data)
			
			if callback then
				coroutine.yield()
			end
		end
		
		for i = 0, mesh.mNumFaces - 1 do
			local face = mesh.mFaces[i]
			
			for i = 0, face.mNumIndices - 1 do
				local i = face.mIndices[i]
				
				table.insert(sub_model.indices, i)
			end
		end
		
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
		
		if callback then
			callback(sub_model, i+1, scene.mNumMeshes)
		end
		
		if callback then
			coroutine.yield()
		end
	end	
	
	assimp.ReleaseImport(scene)
	
	return out
end

return assimp